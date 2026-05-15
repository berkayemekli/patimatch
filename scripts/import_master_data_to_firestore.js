#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

const repoRoot = path.resolve(__dirname, "..");
const manifestPath = path.join(__dirname, "master_data_manifest.json");

function parseArgs(argv) {
  const args = {
    dryRun: true,
    write: false,
    yes: false,
    only: null,
    limit: null,
  };

  for (const arg of argv) {
    if (arg === "--dry-run") args.dryRun = true;
    else if (arg === "--write") {
      args.write = true;
      args.dryRun = false;
    } else if (arg === "--yes") args.yes = true;
    else if (arg.startsWith("--only=")) args.only = arg.slice("--only=".length);
    else if (arg.startsWith("--limit=")) {
      const value = Number(arg.slice("--limit=".length));
      if (Number.isFinite(value) && value > 0) args.limit = value;
    } else if (arg === "--help" || arg === "-h") {
      printHelp();
      process.exit(0);
    } else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }

  return args;
}

function printHelp() {
  console.log(`
PatiParent master data Firestore importer

Dry-run validation:
  node scripts/import_master_data_to_firestore.js --dry-run
  node scripts/import_master_data_to_firestore.js --dry-run --only=veterinaryClinics

Live write:
  GOOGLE_APPLICATION_CREDENTIALS=C:\\path\\service-account.json node scripts/import_master_data_to_firestore.js --write --yes
  node scripts/import_master_data_to_firestore.js --write --yes --only=patiFriendlyPlaces

Options:
  --dry-run             Validate and show what would be imported. Default.
  --write               Write to Firestore.
  --yes                 Required with --write.
  --only=<name>         Import one manifest entry.
  --limit=<number>      Limit records during testing.
`);
}

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8").replace(/^\uFEFF/, ""));
}

function getRows(entry) {
  const filePath = path.join(repoRoot, entry.file);
  const root = readJson(filePath);
  const rows = root[entry.rootKey];

  if (!Array.isArray(rows)) {
    throw new Error(`${entry.file}: root key "${entry.rootKey}" is not an array`);
  }

  return { root, rows };
}

function sanitizeDocId(value) {
  return String(value)
    .trim()
    .replace(/[\/#[\]?]/g, "_")
    .slice(0, 500);
}

function buildDoc(record, root, entry, admin) {
  const doc = {
    ...record,
    verified: record.verified === true ? true : false,
    verificationStatus: record.verificationStatus || "unverified_seed",
    dataSourceFile: entry.file,
    dataSourceStatus: root.sourceStatus || "unknown",
    dataImportedFrom: "master_data_import_script",
    dataVersion: root.generatedAt || null,
    license: root.license || null,
    sourceAttribution:
      root.license?.attribution || "© OpenStreetMap contributors",
  };

  if (admin) {
    doc.importedAt = admin.firestore.FieldValue.serverTimestamp();
    doc.updatedAt = admin.firestore.FieldValue.serverTimestamp();
  } else {
    doc.importedAt = "SERVER_TIMESTAMP";
    doc.updatedAt = "SERVER_TIMESTAMP";
  }

  return doc;
}

async function writeCollection(admin, db, entry, root, rows) {
  const collection = db.collection(entry.collectionPath);
  let batch = db.batch();
  let batchSize = 0;
  let written = 0;

  for (const record of rows) {
    const id = sanitizeDocId(record[entry.idField]);
    if (!id) {
      throw new Error(`${entry.name}: record missing id`);
    }

    const ref = collection.doc(id);
    batch.set(ref, buildDoc(record, root, entry, admin), { merge: true });
    batchSize += 1;

    if (batchSize >= 400) {
      await batch.commit();
      written += batchSize;
      console.log(`Committed ${written}/${rows.length} to ${entry.collectionPath}`);
      batch = db.batch();
      batchSize = 0;
    }
  }

  if (batchSize > 0) {
    await batch.commit();
    written += batchSize;
    console.log(`Committed ${written}/${rows.length} to ${entry.collectionPath}`);
  }

  return written;
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  const manifest = readJson(manifestPath);

  let entries = manifest.collections;
  if (args.only) {
    entries = entries.filter((entry) => entry.name === args.only);
    if (entries.length === 0) {
      throw new Error(`No manifest entry found for --only=${args.only}`);
    }
  }

  if (args.write && !args.yes) {
    throw new Error("Live writes require --yes. Run with --dry-run first.");
  }

  let admin = null;
  let db = null;

  if (args.write) {
    try {
      admin = require("firebase-admin");
    } catch (error) {
      throw new Error(
        "firebase-admin is not available. Install it in the environment that runs the import."
      );
    }

    if (!admin.apps.length) {
      const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;
      if (serviceAccountPath) {
        const serviceAccount = readJson(serviceAccountPath);
        admin.initializeApp({
          credential: admin.credential.cert(serviceAccount),
        });
      } else {
        admin.initializeApp();
      }
    }

    db = admin.firestore();
  }

  console.log("PatiParent master data Firestore importer");
  console.log(`Mode: ${args.write ? "WRITE" : "DRY-RUN"}`);
  console.log("");

  for (const entry of entries) {
    const { root, rows: allRows } = getRows(entry);
    const rows = args.limit ? allRows.slice(0, args.limit) : allRows;

    console.log(`--- ${entry.name} ---`);
    console.log(`File: ${entry.file}`);
    console.log(`Collection: ${entry.collectionPath}`);
    console.log(`Records: ${rows.length}${args.limit ? ` of ${allRows.length}` : ""}`);
    console.log(`Source status: ${root.sourceStatus || "unknown"}`);
    console.log(`Attribution: ${root.license?.attribution || "-"}`);

    if (!args.write) {
      const sample = rows.slice(0, 3).map((row) => ({
        id: row[entry.idField],
        name: row.name,
        city: row.city || "",
        district: row.district || "",
        category: row.category || "",
      }));
      console.log("Sample:");
      console.log(JSON.stringify(sample, null, 2));
      console.log("");
      continue;
    }

    const written = await writeCollection(admin, db, entry, root, rows);
    console.log(`Written: ${written}`);
    console.log("");
  }

  if (!args.write) {
    console.log("Dry-run complete. No Firestore writes were made.");
  }
}

main().catch((error) => {
  console.error(`ERROR: ${error.message}`);
  process.exit(1);
});
