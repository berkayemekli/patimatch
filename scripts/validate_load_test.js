/* eslint-disable no-console */
const fs = require("fs");
const path = require("path");

const projectId = readArg("--project") || "patimatch-staging";
const prefix = readArg("--prefix") || "lt_2026";
const expectedPerModule = Number(readArg("--count") || 250);
const expectedPairs = Number(readArg("--match-pairs") || 125);
const root = path.resolve(__dirname, "..");
const reportPath = path.join(root, "docs", "load_test_validation_report.json");

const collections = [
  "users",
  "module_memberships",
  "walkers",
  "bnb_hosts",
  "dogs",
  "adoption_posts",
  "walk_requests",
  "bnb_requests",
  "adoption_applications",
  "swipes",
  "matches",
  "chats",
];

function readArg(name) {
  const index = process.argv.indexOf(name);
  return index === -1 ? "" : process.argv[index + 1] || "";
}

async function getFirebaseCliToken() {
  const auth = require("C:/Users/berka/AppData/Roaming/npm/node_modules/firebase-tools/lib/auth.js");
  const account = auth.getGlobalDefaultAccount();
  const refreshToken = account && account.tokens && account.tokens.refresh_token;
  const token = await auth.getAccessToken(refreshToken, [
    "email",
    "openid",
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/firebase",
  ]);
  if (!token || !token.access_token) {
    throw new Error("Firebase CLI token unavailable. Run `firebase login`.");
  }
  return token.access_token;
}

function decodeValue(value) {
  if (!value) return null;
  if ("stringValue" in value) return value.stringValue;
  if ("booleanValue" in value) return value.booleanValue;
  if ("integerValue" in value) return Number(value.integerValue);
  if ("doubleValue" in value) return value.doubleValue;
  if ("timestampValue" in value) return value.timestampValue;
  if ("arrayValue" in value) return (value.arrayValue.values || []).map(decodeValue);
  if ("mapValue" in value) return decodeFields(value.mapValue.fields || {});
  return null;
}

function decodeFields(fields) {
  return Object.fromEntries(
    Object.entries(fields || {}).map(([key, value]) => [key, decodeValue(value)]),
  );
}

async function readCollection(collection, accessToken) {
  const documents = [];
  let pageToken = "";
  do {
    const url = new URL(
      `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/${collection}`,
    );
    url.searchParams.set("pageSize", "1000");
    if (pageToken) url.searchParams.set("pageToken", pageToken);
    const response = await fetch(url, {
      headers: { Authorization: `Bearer ${accessToken}` },
    });
    const payload = await response.json().catch(() => ({}));
    if (!response.ok) {
      throw new Error(`${collection} read failed (${response.status}): ${JSON.stringify(payload)}`);
    }
    for (const document of payload.documents || []) {
      documents.push({
        id: document.name.split("/").pop(),
        data: decodeFields(document.fields),
      });
    }
    pageToken = payload.nextPageToken || "";
  } while (pageToken);
  return documents;
}

function expectedCounts() {
  return {
    users: expectedPerModule * 4,
    module_memberships: expectedPerModule * 4,
    walkers: expectedPerModule,
    bnb_hosts: expectedPerModule,
    dogs: expectedPerModule,
    adoption_posts: expectedPerModule,
    walk_requests: expectedPerModule,
    bnb_requests: expectedPerModule,
    adoption_applications: expectedPerModule,
    swipes: expectedPairs * 2,
    matches: expectedPairs,
    chats: expectedPairs,
  };
}

async function run() {
  if (projectId === "patimatch-app-2026-berkay") {
    throw new Error("Validation is staging-only by default.");
  }
  const accessToken = await getFirebaseCliToken();
  const actual = {};
  const membershipByModule = {};

  for (const collection of collections) {
    const documents = await readCollection(collection, accessToken);
    const loadTestDocuments = documents.filter(
      (document) =>
        document.id.startsWith(`${prefix}_`) ||
        document.data.loadTestPrefix === prefix,
    );
    actual[collection] = loadTestDocuments.length;
    if (collection === "module_memberships") {
      for (const document of loadTestDocuments) {
        const module = document.data.module || "unknown";
        membershipByModule[module] = (membershipByModule[module] || 0) + 1;
      }
    }
    console.log(`${collection}: ${actual[collection]}`);
  }

  const expected = expectedCounts();
  const mismatches = Object.keys(expected)
    .filter((collection) => actual[collection] !== expected[collection])
    .map((collection) => ({
      collection,
      expected: expected[collection],
      actual: actual[collection],
    }));

  const expectedMemberships = {
    pati_gezdirme: expectedPerModule,
    pati_bnb: expectedPerModule,
    pati_match: expectedPerModule,
    pati_family: expectedPerModule,
  };
  for (const [module, count] of Object.entries(expectedMemberships)) {
    if (membershipByModule[module] !== count) {
      mismatches.push({
        collection: `module_memberships:${module}`,
        expected: count,
        actual: membershipByModule[module] || 0,
      });
    }
  }

  const report = {
    generatedAt: new Date().toISOString(),
    projectId,
    prefix,
    expectedPerModule,
    expectedPairs,
    passed: mismatches.length === 0,
    expected,
    actual,
    membershipByModule,
    mismatches,
  };
  fs.writeFileSync(reportPath, `${JSON.stringify(report, null, 2)}\n`, "utf8");
  console.log(JSON.stringify(report, null, 2));
  if (!report.passed) process.exitCode = 1;
}

run().catch((error) => {
  console.error(error.stack || error.message || error);
  process.exit(1);
});
