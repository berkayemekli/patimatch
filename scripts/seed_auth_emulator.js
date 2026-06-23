/* eslint-disable no-console */
const fs = require("fs");
const path = require("path");

const count = Number(readArg("--count") || 1000);
const projectId = readArg("--project") || process.env.GCLOUD_PROJECT || "demo-patiparent";
const host = process.env.FIREBASE_AUTH_EMULATOR_HOST || "127.0.0.1:9099";
const reportPath = path.resolve(__dirname, "..", "docs", "auth_emulator_report.json");

function readArg(name) {
  const index = process.argv.indexOf(name);
  return index === -1 ? "" : process.argv[index + 1] || "";
}

async function createUser(index) {
  const email = `loadtest-${String(index).padStart(4, "0")}@patiparent.test`;
  const response = await fetch(
    `http://${host}/identitytoolkit.googleapis.com/v1/accounts:signUp?key=fake-api-key`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        email,
        password: "PatiParent-Test-2026!",
        displayName: `Load Test User ${index}`,
        returnSecureToken: false,
      }),
    },
  );
  const payload = await response.json().catch(() => ({}));
  if (!response.ok && payload.error?.message !== "EMAIL_EXISTS") {
    throw new Error(`Auth create failed for ${email}: ${JSON.stringify(payload)}`);
  }
  return { email, created: response.ok };
}

async function verifyUser(index) {
  const email = `loadtest-${String(index).padStart(4, "0")}@patiparent.test`;
  const response = await fetch(
    `http://${host}/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=fake-api-key`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        email,
        password: "PatiParent-Test-2026!",
        returnSecureToken: true,
      }),
    },
  );
  const payload = await response.json().catch(() => ({}));
  if (!response.ok || !payload.localId || !payload.idToken) {
    throw new Error(`Auth login verification failed for ${email}: ${JSON.stringify(payload)}`);
  }
  return email;
}

async function run() {
  if (!Number.isInteger(count) || count < 1 || count > 2000) {
    throw new Error("--count must be between 1 and 2000.");
  }
  let created = 0;
  for (let start = 1; start <= count; start += 50) {
    const batch = [];
    for (let index = start; index < Math.min(start + 50, count + 1); index += 1) {
      batch.push(createUser(index));
    }
    const results = await Promise.all(batch);
    created += results.filter((result) => result.created).length;
    console.log(`Auth emulator users processed: ${Math.min(start + 49, count)}/${count}`);
  }

  const verificationIndexes = [...new Set([1, Math.ceil(count / 2), count])];
  const verifiedLogins = [];
  for (const index of verificationIndexes) {
    verifiedLogins.push(await verifyUser(index));
  }
  const report = {
    generatedAt: new Date().toISOString(),
    projectId,
    host,
    requested: count,
    created,
    processed: count,
    verifiedLogins,
    passed: created === count && verifiedLogins.length === verificationIndexes.length,
    note: "Emulator-only accounts; no real email or SMS is sent.",
  };
  fs.writeFileSync(reportPath, `${JSON.stringify(report, null, 2)}\n`, "utf8");
  console.log(JSON.stringify(report, null, 2));
  if (!report.passed) process.exitCode = 1;
}

run().catch((error) => {
  console.error(error.stack || error.message || error);
  process.exit(1);
});
