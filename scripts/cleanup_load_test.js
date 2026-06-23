/* eslint-disable no-console */
const fs = require("fs");
const path = require("path");

const projectId = readArg("--project") || "patimatch-staging";
const runId = readArg("--run-id");
const count = Number(readArg("--count") || 250);
const matchPairs = Number(readArg("--match-pairs") || 125);
const networkProfile = readArg("--network-profile") || "paired";
const execute = process.argv.includes("--execute");
const root = path.resolve(__dirname, "..");
const reportPath = path.join(root, "docs", "load_test_cleanup_report.json");
function readArg(name) {
  const index = process.argv.indexOf(name);
  return index === -1 ? "" : process.argv[index + 1] || "";
}

async function getAccessToken() {
  const authPath = path.join(
    process.env.APPDATA || "C:/Users/berka/AppData/Roaming",
    "npm/node_modules/firebase-tools/lib/auth.js",
  );
  if (!fs.existsSync(authPath)) throw new Error("firebase-tools is not installed.");
  const auth = require(authPath);
  const account = auth.getGlobalDefaultAccount();
  const refreshToken = account && account.tokens && account.tokens.refresh_token;
  const token = await auth.getAccessToken(refreshToken, [
    "email",
    "openid",
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/firebase",
  ]);
  if (!token || !token.access_token) throw new Error("Run `firebase login` first.");
  return token.access_token;
}

function pad(value, size = 3) {
  return String(value).padStart(size, "0");
}

function documentName(collection, id) {
  return `projects/${projectId}/databases/(default)/documents/${collection}/${id}`;
}

function buildDocumentNames() {
  const byCollection = {};
  const add = (collection, id) => {
    byCollection[collection] ||= [];
    byCollection[collection].push(documentName(collection, id));
  };

  for (let i = 1; i <= count; i += 1) {
    const id = pad(i);
    add("users", `${runId}_walk_user_${id}`);
    add("users", `${runId}_bnb_user_${id}`);
    add("users", `${runId}_match_user_${id}`);
    add("users", `${runId}_family_owner_${id}`);
    add("module_memberships", `${runId}_walk_membership_${id}`);
    add("module_memberships", `${runId}_bnb_membership_${id}`);
    add("module_memberships", `${runId}_match_membership_${id}`);
    add("module_memberships", `${runId}_family_membership_${id}`);
    add("activity_events", `${runId}_walk_activity_${id}`);
    add("activity_events", `${runId}_bnb_activity_${id}`);
    add("activity_events", `${runId}_match_activity_${id}`);
    add("activity_events", `${runId}_family_activity_${id}`);
    add("walkers", `${runId}_walker_${id}`);
    add("bnb_hosts", `${runId}_bnb_${id}`);
    add("dogs", `${runId}_match_dog_${id}`);
    add("adoption_posts", `${runId}_family_post_${id}`);
    add("walk_requests", `${runId}_walk_request_${id}`);
    add("bnb_requests", `${runId}_bnb_request_${id}`);
    add("adoption_applications", `${runId}_family_application_${id}`);
  }

  const pairs = Math.min(matchPairs, Math.floor(count / 2));
  if (networkProfile !== "paired") {
    const swipesPerUser = { sparse: 2, normal: 12, dense: 50 }[networkProfile];
    for (let from = 1; from <= count; from += 1) {
      for (let offset = 1; offset <= Math.min(swipesPerUser, count - 1); offset += 1) {
        const to = ((from - 1 + offset) % count) + 1;
        add(
          "swipes",
          `${runId}_match_dog_${pad(from)}_${runId}_match_dog_${pad(to)}`,
        );
      }
    }
  }
  for (let i = 1; i <= pairs; i += 1) {
    const a = pad(i);
    const b = pad(count - i + 1);
    const dogA = `${runId}_match_dog_${a}`;
    const dogB = `${runId}_match_dog_${b}`;
    if (networkProfile === "paired") {
      add("swipes", `${dogA}_${dogB}`);
      add("swipes", `${dogB}_${dogA}`);
    }
    const matchId = [dogA, dogB].sort().join("_");
    add("matches", matchId);
    add("chats", matchId);
  }
  add("load_test_runs", runId);
  return byCollection;
}

async function deleteDocuments(names, accessToken) {
  const url = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents:commit`;
  for (let index = 0; index < names.length; index += 400) {
    const chunk = names.slice(index, index + 400);
    const response = await fetch(url, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        writes: chunk.map((name) => ({ delete: name })),
      }),
    });
    const payload = await response.json().catch(() => ({}));
    if (!response.ok) throw new Error(`Delete failed: ${JSON.stringify(payload)}`);
  }
}

async function run() {
  if (!runId || !runId.startsWith("lt_")) {
    throw new Error("A load-test --run-id starting with `lt_` is required.");
  }
  if (projectId === "patimatch-app-2026-berkay" || !projectId.includes("staging")) {
    throw new Error("Cleanup is restricted to staging.");
  }
  const accessToken = await getAccessToken();
  const byCollection = buildDocumentNames();
  const found = Object.fromEntries(
    Object.entries(byCollection).map(([collection, names]) => [collection, names.length]),
  );
  const names = Object.values(byCollection).flat();
  if (execute) await deleteDocuments(names, accessToken);
  const report = {
    generatedAt: new Date().toISOString(),
    projectId,
    runId,
    count,
    matchPairs,
    networkProfile,
    execute,
    deleted: execute ? names.length : 0,
    wouldDelete: names.length,
    found,
  };
  fs.writeFileSync(reportPath, `${JSON.stringify(report, null, 2)}\n`, "utf8");
  console.log(JSON.stringify(report, null, 2));
}

run().catch((error) => {
  console.error(error.stack || error.message || error);
  process.exit(1);
});
