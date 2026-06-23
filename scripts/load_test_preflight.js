/* eslint-disable no-console */
const fs = require("fs");
const path = require("path");

const projectId = readArg("--project") || "patimatch-staging";
const reportPath = path.resolve(__dirname, "..", "docs", "load_test_preflight_report.json");
const productionProject = "patimatch-app-2026-berkay";

function readArg(name) {
  const index = process.argv.indexOf(name);
  return index === -1 ? "" : process.argv[index + 1] || "";
}

function findFirebaseAuthModule() {
  const candidates = [
    "C:/Users/berka/AppData/Roaming/npm/node_modules/firebase-tools/lib/auth.js",
    path.join(process.env.APPDATA || "", "npm/node_modules/firebase-tools/lib/auth.js"),
  ];
  return candidates.find((candidate) => candidate && fs.existsSync(candidate));
}

async function getAccessToken() {
  const authModule = findFirebaseAuthModule();
  if (!authModule) {
    throw new Error("Firebase CLI module not found. Install firebase-tools first.");
  }
  const auth = require(authModule);
  const account = auth.getGlobalDefaultAccount();
  const refreshToken = account && account.tokens && account.tokens.refresh_token;
  if (!refreshToken) throw new Error("Firebase CLI session missing. Run `firebase login`.");
  const token = await auth.getAccessToken(refreshToken, [
    "email",
    "openid",
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/firebase",
  ]);
  if (!token || !token.access_token) throw new Error("Firebase access token unavailable.");
  return token.access_token;
}

async function fetchJson(url, accessToken) {
  const response = await fetch(url, {
    headers: { Authorization: `Bearer ${accessToken}` },
  });
  const payload = await response.json().catch(() => ({}));
  return { response, payload };
}

async function run() {
  const checks = [];
  const add = (name, passed, detail) => checks.push({ name, passed, detail });

  add("production_guard", projectId !== productionProject, `Target project: ${projectId}`);
  add("staging_name", projectId.includes("staging"), "Project id should clearly identify staging.");

  let accessToken = "";
  try {
    accessToken = await getAccessToken();
    add("firebase_cli_auth", true, "Firebase CLI session is available.");
  } catch (error) {
    add("firebase_cli_auth", false, error.message);
  }

  if (accessToken) {
    const project = await fetchJson(
      `https://cloudresourcemanager.googleapis.com/v1/projects/${projectId}`,
      accessToken,
    );
    add(
      "project_access",
      project.response.ok,
      project.response.ok ? "Project is accessible." : JSON.stringify(project.payload),
    );

    const service = await fetchJson(
      `https://serviceusage.googleapis.com/v1/projects/${projectId}/services/firestore.googleapis.com`,
      accessToken,
    );
    add(
      "firestore_api",
      service.response.ok && service.payload.state === "ENABLED",
      service.response.ok ? `State: ${service.payload.state}` : JSON.stringify(service.payload),
    );

    const database = await fetchJson(
      `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)`,
      accessToken,
    );
    add(
      "firestore_database",
      database.response.ok,
      database.response.ok
        ? `Location: ${database.payload.locationId}; type: ${database.payload.type}`
        : JSON.stringify(database.payload),
    );
  }

  const report = {
    generatedAt: new Date().toISOString(),
    projectId,
    passed: checks.every((check) => check.passed),
    checks,
  };
  fs.writeFileSync(reportPath, `${JSON.stringify(report, null, 2)}\n`, "utf8");
  console.log(JSON.stringify(report, null, 2));
  if (!report.passed) process.exitCode = 1;
}

run().catch((error) => {
  console.error(error.stack || error.message || error);
  process.exit(1);
});
