/* eslint-disable no-console */
const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");
const docs = path.join(root, "docs");

function readJson(name) {
  const file = path.join(docs, name);
  return fs.existsSync(file) ? JSON.parse(fs.readFileSync(file, "utf8")) : {};
}

const seed = readJson("load_test_seed_report.json");
const validation = readJson("load_test_validation_report.json");
const preflight = readJson("load_test_preflight_report.json");
const auth = readJson("auth_emulator_report.json");
const cleanup = readJson("load_test_cleanup_report.json");

const cards = [
  ["Preflight", preflight.passed === true ? "PASS" : "Bekliyor"],
  ["Firestore doğrulama", validation.passed === true ? "PASS" : "Bekliyor"],
  ["Hedef modül üyeliği", seed.countPerModule ?? validation.expectedPerModule ?? "-"],
  ["Hedef toplam profil", seed.counters?.users ?? validation.actual?.users ?? "-"],
  ["Hedef toplam üyelik", seed.counters?.module_memberships ?? validation.actual?.module_memberships ?? "-"],
  ["Son doğrulama run", validation.runId ?? "-"],
  ["Auth login smoke", auth.passed === true ? "PASS" : "Bekliyor"],
  ["Son cleanup", cleanup.execute ? `${cleanup.deleted} silindi` : "Dry-run"],
  ["Firestore okuma", validation.totalReadMs ? `${validation.totalReadMs} ms` : "eski rapor"],
];

const rows = Object.entries(validation.actual || {})
  .map(([name, value]) => {
    const expected = validation.expected?.[name] ?? "-";
    const duration = validation.collectionReadMs?.[name] ?? "-";
    const status = value === expected ? "PASS" : "CHECK";
    return `<tr><td>${name}</td><td>${expected}</td><td>${value}</td><td>${duration}</td><td>${status}</td></tr>`;
  })
  .join("");
const stageRows = Object.entries(validation.serviceStageCounts || {})
  .map(([stage, value]) => `<tr><td>${stage}</td><td>${value}</td></tr>`)
  .join("");

const html = `<!doctype html>
<html lang="tr"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>PatiParent Load Test Dashboard</title>
<style>
:root{--bg:#f7f5f1;--ink:#111827;--muted:#64748b;--line:#e2e8f0;--ok:#0f766e}
*{box-sizing:border-box}body{margin:0;background:linear-gradient(135deg,#f8fafc,#f7f5f1);font-family:system-ui,sans-serif;color:var(--ink)}
main{max-width:1120px;margin:auto;padding:36px 20px 70px}header{padding:30px;border-radius:28px;background:#111827;color:white}
h1{font-size:clamp(34px,6vw,62px);line-height:1;margin:8px 0 12px;letter-spacing:-2px}.muted{color:#cbd5e1}
.grid{display:grid;grid-template-columns:repeat(4,1fr);gap:12px;margin:18px 0}.card{padding:18px;border:1px solid var(--line);border-radius:20px;background:white}
.card b{display:block;font-size:25px;margin-top:5px}.card span{color:var(--muted);font-size:13px;font-weight:700}
.table{overflow:auto;background:white;border:1px solid var(--line);border-radius:20px}table{width:100%;border-collapse:collapse;min-width:700px}
th,td{text-align:left;padding:12px;border-bottom:1px solid var(--line)}th{background:#f8fafc}.pass{color:var(--ok)}
@media(max-width:800px){.grid{grid-template-columns:repeat(2,1fr)}}
</style></head><body><main>
<header><div>PatiParent · staging</div><h1>Load test sağlık paneli</h1><p class="muted">Seed, doğrulama, Auth Emulator ve cleanup sonuçlarının tek görünümü.</p></header>
<section class="grid">${cards.map(([label, value]) => `<div class="card"><span>${label}</span><b>${value}</b></div>`).join("")}</section>
<section class="table"><table><thead><tr><th>Koleksiyon</th><th>Beklenen</th><th>Gerçek</th><th>Okuma ms</th><th>Durum</th></tr></thead><tbody>${rows}</tbody></table></section>
<h2>Hizmet yaşam döngüsü</h2>
<section class="table"><table><thead><tr><th>Aşama</th><th>Eşleşme</th></tr></thead><tbody>${stageRows || '<tr><td colspan="2">Doğrulama sonrası oluşacak</td></tr>'}</tbody></table></section>
<p>Oluşturulma: ${new Date().toISOString()}</p>
</main></body></html>`;

fs.writeFileSync(path.join(docs, "load_test_dashboard.html"), html, "utf8");
console.log("Wrote docs/load_test_dashboard.html");
