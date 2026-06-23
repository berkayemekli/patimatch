/* eslint-disable no-console */
const { spawnSync } = require("child_process");

const projectId = readArg("--project") || "patimatch-staging";
const count = readArg("--count") || "250";
const matchPairs = readArg("--match-pairs") || "125";
const ttlDays = readArg("--ttl-days") || "7";
const networkProfile = readArg("--network-profile") || "paired";
const runId =
  readArg("--run-id") ||
  `lt_${new Date().toISOString().replace(/[-:]/g, "").replace(/\..+/, "").replace("T", "_")}`;
const cleanupAfter = process.argv.includes("--cleanup-after");

function readArg(name) {
  const index = process.argv.indexOf(name);
  return index === -1 ? "" : process.argv[index + 1] || "";
}

function run(script, args) {
  console.log(`\n> ${script} ${args.join(" ")}`);
  const result = spawnSync(process.execPath, [script, ...args], {
    cwd: process.cwd(),
    stdio: "inherit",
  });
  if (result.status !== 0) {
    throw new Error(`${script} failed with exit code ${result.status}`);
  }
}

function main() {
  run("scripts/load_test_preflight.js", ["--project", projectId]);
  run("scripts/load_test_seed.js", [
    "--project",
    projectId,
    "--run-id",
    runId,
    "--count",
    count,
    "--match-pairs",
    matchPairs,
    "--ttl-days",
    ttlDays,
    "--network-profile",
    networkProfile,
    "--write",
  ]);
  run("scripts/validate_load_test.js", [
    "--project",
    projectId,
    "--run-id",
    runId,
    "--prefix",
    runId,
    "--count",
    count,
    "--match-pairs",
    matchPairs,
    "--network-profile",
    networkProfile,
  ]);
  if (cleanupAfter) {
    run("scripts/cleanup_load_test.js", [
      "--project",
      projectId,
      "--run-id",
      runId,
      "--count",
      count,
      "--match-pairs",
      matchPairs,
      "--network-profile",
      networkProfile,
      "--execute",
    ]);
  }
  console.log(`\nLoad-test pipeline completed. runId=${runId}`);
}

try {
  main();
} catch (error) {
  console.error(error.stack || error.message || error);
  process.exit(1);
}
