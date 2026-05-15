#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

const repoRoot = path.resolve(__dirname, "..");
const manifestPath = path.join(__dirname, "master_data_manifest.json");

function readJson(filePath) {
  const raw = fs.readFileSync(filePath, "utf8").replace(/^\uFEFF/, "");
  return JSON.parse(raw);
}

function isFiniteNumber(value) {
  return typeof value === "number" && Number.isFinite(value);
}

function validateCollection(entry) {
  const filePath = path.join(repoRoot, entry.file);
  const errors = [];
  const warnings = [];

  if (!fs.existsSync(filePath)) {
    return {
      name: entry.name,
      ok: false,
      count: 0,
      errors: [`Missing file: ${entry.file}`],
      warnings,
    };
  }

  let root;
  try {
    root = readJson(filePath);
  } catch (error) {
    return {
      name: entry.name,
      ok: false,
      count: 0,
      errors: [`Invalid JSON: ${error.message}`],
      warnings,
    };
  }

  const rows = root[entry.rootKey];
  if (!Array.isArray(rows)) {
    return {
      name: entry.name,
      ok: false,
      count: 0,
      errors: [`Root key "${entry.rootKey}" must be an array`],
      warnings,
    };
  }

  if (rows.length < entry.minCount) {
    errors.push(
      `Expected at least ${entry.minCount} records, found ${rows.length}`
    );
  }

  const seenIds = new Set();
  let missingCity = 0;
  let missingContact = 0;
  let missingAddress = 0;
  let missingVerificationStatus = 0;
  let nonUnverifiedSeed = 0;
  const categoryCounts = new Map();

  rows.forEach((row, index) => {
    for (const field of entry.requiredFields) {
      if (
        row[field] === undefined ||
        row[field] === null ||
        row[field] === ""
      ) {
        errors.push(`Row ${index}: missing required field "${field}"`);
      }
    }

    const id = row[entry.idField];
    if (id) {
      if (seenIds.has(id)) {
        errors.push(`Duplicate id: ${id}`);
      }
      seenIds.add(id);
    }

    if (!isFiniteNumber(row.latitude) || !isFiniteNumber(row.longitude)) {
      errors.push(`Row ${index}: latitude/longitude must be numbers`);
    }

    if (!row.city) missingCity += 1;
    if (!row.address) missingAddress += 1;
    if (!row.phone && !row.website) missingContact += 1;
    if (row.verified !== false) {
      errors.push(`Row ${index}: OSM seed record must have verified=false`);
    }
    if (!row.verificationStatus) {
      missingVerificationStatus += 1;
    } else if (row.verificationStatus !== "unverified_seed") {
      nonUnverifiedSeed += 1;
    }

    const category = row.category || "unknown";
    categoryCounts.set(category, (categoryCounts.get(category) || 0) + 1);
  });

  const categorySummary = Array.from(categoryCounts.entries())
    .sort(([a], [b]) => a.localeCompare(b))
    .map(([key, value]) => `${key}=${value}`)
    .join(", ");

  if (missingCity > 0) warnings.push(`Missing city: ${missingCity}`);
  if (missingAddress > 0) warnings.push(`Missing address: ${missingAddress}`);
  if (missingContact > 0) {
    warnings.push(`Missing phone+website: ${missingContact}`);
  }
  if (missingVerificationStatus > 0) {
    warnings.push(
      `Missing verificationStatus: ${missingVerificationStatus}; importer will write unverified_seed`
    );
  }
  if (nonUnverifiedSeed > 0) {
    errors.push(
      `Expected verificationStatus=unverified_seed, found ${nonUnverifiedSeed} non-matching records`
    );
  }
  if (!String(root.license?.attribution || "").includes("OpenStreetMap")) {
    errors.push("Missing OpenStreetMap attribution in license metadata");
  }

  return {
    name: entry.name,
    ok: errors.length === 0,
    count: rows.length,
    categorySummary,
    sourceStatus: root.sourceStatus || "unknown",
    licenseAttribution: root.license?.attribution || "",
    errors,
    warnings,
  };
}

function main() {
  const manifest = readJson(manifestPath);
  console.log("PatiParent master data validation");
  console.log(`Manifest version: ${manifest.version}`);
  console.log("");

  let hasError = false;

  for (const entry of manifest.collections) {
    const result = validateCollection(entry);
    console.log(`--- ${entry.name} ---`);
    console.log(`File: ${entry.file}`);
    console.log(`Collection: ${entry.collectionPath}`);
    console.log(`Count: ${result.count}`);
    console.log(`Source status: ${result.sourceStatus || "-"}`);
    if (result.categorySummary) {
      console.log(`Categories: ${result.categorySummary}`);
    }
    if (result.licenseAttribution) {
      console.log(`Attribution: ${result.licenseAttribution}`);
    }
    for (const warning of result.warnings) {
      console.log(`WARNING: ${warning}`);
    }
    for (const error of result.errors) {
      console.log(`ERROR: ${error}`);
    }
    console.log(`Status: ${result.ok ? "OK" : "FAILED"}`);
    console.log("");

    if (!result.ok) hasError = true;
  }

  if (hasError) {
    process.exitCode = 1;
  }
}

main();
