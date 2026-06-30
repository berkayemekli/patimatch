from __future__ import annotations

import html
import json
from collections import Counter
from pathlib import Path
from typing import Any, Iterable

ROOT = Path(__file__).resolve().parents[1]
MASTER_DATA = ROOT / "app" / "assets" / "master_data"
OUTPUT = ROOT / "docs" / "data_mapping.html"


def load_json(name: str) -> dict[str, Any]:
    return json.loads((MASTER_DATA / name).read_text(encoding="utf-8-sig"))


def repair_mojibake(value: str) -> str:
    replacements = {
        "\u00c4\u00b0": "\u0130",
        "\u00c4\u00b1": "\u0131",
        "\u00c4\u0178": "\u011f",
        "\u00c4\u017e": "\u011e",
        "\u00c5\u0178": "\u015f",
        "\u00c5\u017e": "\u015e",
        "\u00c3\u00a7": "\u00e7",
        "\u00c3\u0087": "\u00c7",
        "\u00c3\u00b6": "\u00f6",
        "\u00c3\u0096": "\u00d6",
        "\u00c3\u00bc": "\u00fc",
        "\u00c3\u009c": "\u00dc",
        "Veteriner klini\u00c4\u0178i": "Veteriner klini\u011fi",
        "Kopek egitmeni": "K\u00f6pek e\u011fitmeni",
    }
    text_value = value
    for bad, good in replacements.items():
        text_value = text_value.replace(bad, good)
    return text_value


def esc(value: Any) -> str:
    if value is None:
        return ""
    return html.escape(repair_mojibake(str(value)), quote=True)


def text(value: Any, fallback: str = "-") -> str:
    if value is None:
        return fallback
    if isinstance(value, (list, tuple)):
        value = ", ".join(str(item) for item in value if str(item).strip())
    if isinstance(value, dict):
        value = json.dumps(value, ensure_ascii=False)
    cleaned = repair_mojibake(str(value)).strip()
    return cleaned if cleaned else fallback


def tag(items: Iterable[Any], limit: int = 18) -> str:
    values = [text(item, "") for item in items if text(item, "")]
    visible = values[:limit]
    extra = len(values) - len(visible)
    body = "".join(f'<span class="tag">{esc(item)}</span>' for item in visible)
    if extra > 0:
        body += f'<span class="tag more">+{extra}</span>'
    return body or '<span class="muted">Yok</span>'


def count_missing(rows: list[dict[str, Any]], field: str) -> int:
    return sum(1 for row in rows if not text(row.get(field), ""))


def table(table_id: str, rows: list[dict[str, Any]], columns: list[tuple[str, str]], *, limit: int | None = None) -> str:
    visible_rows = rows if limit is None else rows[:limit]
    head = "".join(f"<th>{esc(label)}</th>" for _, label in columns)
    body = []
    for row in visible_rows:
        cells = []
        for key, _ in columns:
            value = row.get(key)
            if key == "maps":
                lat = row.get("latitude")
                lon = row.get("longitude")
                if lat and lon:
                    href = f"https://www.google.com/maps/search/?api=1&query={lat},{lon}"
                    cells.append(f'<td><a href="{esc(href)}" target="_blank" rel="noreferrer">Harita</a></td>')
                else:
                    cells.append("<td>-</td>")
            elif key == "website" and text(value, ""):
                href = text(value, "")
                cells.append(f'<td><a href="{esc(href)}" target="_blank" rel="noreferrer">{esc(href)}</a></td>')
            else:
                cells.append(f"<td>{esc(text(value))}</td>")
        body.append("<tr>" + "".join(cells) + "</tr>")
    note = ""
    if limit is not None and len(rows) > limit:
        note = f'<p class="muted table-note">İlk {limit} kayıt gösteriliyor. Toplam {len(rows)} kayıt var.</p>'
    return f"""
<div class="table-wrap">
  {note}
  <table id="{esc(table_id)}">
    <thead><tr>{head}</tr></thead>
    <tbody>{''.join(body)}</tbody>
  </table>
</div>
"""


def service_panel(panel_id: str, title: str, rows: list[dict[str, Any]], description: str, extra: str = "") -> str:
    city_counter = Counter(text(row.get("city"), "Eksik") for row in rows)
    top_cities = [f"{city}: {count}" for city, count in city_counter.most_common(8)]
    columns = [
        ("name", "İsim"),
        ("city", "İl"),
        ("district", "İlçe"),
        ("address", "Adres"),
        ("phone", "Telefon"),
        ("website", "Web"),
        ("openingHours", "Saat"),
        ("category", "Kategori"),
        ("maps", "Harita"),
    ]
    return f"""
<section id="{esc(panel_id)}" class="panel">
  <div class="section-title">
    <div><h2>{esc(title)}</h2><p class="hint">{esc(description)}</p></div>
    <strong>{len(rows)} kayıt</strong>
  </div>
  <div class="mini-stats">
    <div><b>{len(rows)}</b><span>toplam kayıt</span></div>
    <div><b>{count_missing(rows, 'city')}</b><span>il bilgisi eksik</span></div>
    <div><b>{sum(1 for row in rows if text(row.get('phone'), ''))}</b><span>telefon var</span></div>
    <div><b>{sum(1 for row in rows if text(row.get('website'), ''))}</b><span>web var</span></div>
  </div>
  <div class="card"><h3>Şehir Dağılımı</h3>{tag(top_cities, 12)}{extra}</div>
  {table(panel_id + '-table', rows, columns)}
</section>
"""


def hotel_panel(hotels_data: dict[str, Any]) -> str:
    hotels = hotels_data.get("hotels", [])
    sources = hotels_data.get("sourceDirectories", [])
    city_counter = Counter(text(row.get("city"), "Eksik") for row in hotels)
    status_counter = Counter(text(row.get("verificationStatus"), "Eksik") for row in hotels)
    source_counter = Counter(text(row.get("source"), "Eksik") for row in hotels)
    policy_fields = hotels_data.get("policyFieldsToVerify", [])
    rows = []
    for hotel in hotels:
        policy = hotel.get("petPolicy", {}) if isinstance(hotel.get("petPolicy"), dict) else {}
        rows.append({
            **hotel,
            "policyStatus": policy.get("status", ""),
            "species": ", ".join(policy.get("species", [])) if isinstance(policy.get("species"), list) else policy.get("species", ""),
            "policySummary": policy.get("policySummary", ""),
        })
    columns = [
        ("name", "Otel"),
        ("city", "İl"),
        ("district", "İlçe"),
        ("category", "Kategori"),
        ("verificationStatus", "Durum"),
        ("policyStatus", "Pet policy"),
        ("species", "Tür"),
        ("policySummary", "Not"),
        ("phone", "Telefon"),
        ("website", "Web"),
        ("sourceUrl", "Kaynak"),
        ("maps", "Harita"),
    ]
    source_cards = "".join(
        f"""
<article class="card">
  <h3>{esc(source.get('name'))}</h3>
  <p class="muted">{esc(source.get('observedSignal'))}</p>
  <div class="row"><b>Kaynak</b><div><a href="{esc(source.get('url'))}" target="_blank" rel="noreferrer">{esc(source.get('url'))}</a></div></div>
  <div class="row"><b>Entegrasyon notu</b><div>{esc(source.get('integrationNote'))}</div></div>
</article>
"""
        for source in sources
    )
    return f"""
<section id="hotels" class="panel">
  <div class="section-title">
    <div><h2>Pati Dostu Oteller</h2><p class="hint">Pet-friendly konaklama için kaynak envanteri, doğrulanmamış adaylar ve policy kontrol alanları.</p></div>
    <strong>{len(hotels)} kayıt</strong>
  </div>
  <div class="mini-stats">
    <div><b>{len(hotels)}</b><span>otel/kamp adayı</span></div>
    <div><b>{len(sources)}</b><span>kaynak dizin</span></div>
    <div><b>{sum(1 for row in rows if text(row.get('phone'), ''))}</b><span>telefon var</span></div>
    <div><b>{sum(1 for row in rows if text(row.get('latitude'), '') and text(row.get('longitude'), ''))}</b><span>koordinat var</span></div>
  </div>
  <div class="card"><h3>Doğru ürün modeli</h3><p class="hint">Bu data doğrudan rezervasyon datası değil; PatiCare/Yakınımda, PatiBnB alternatifleri ve otel partner aday havuzu için doğrulama bekleyen seed katmanıdır.</p></div>
  <div class="card"><h3>Şehir Dağılımı</h3>{tag([f"{k}: {v}" for k, v in city_counter.most_common(12)], 12)}</div>
  <div class="card"><h3>Durum / Kaynak</h3>{tag([f"{k}: {v}" for k, v in status_counter.items()], 12)}<br>{tag([f"{k}: {v}" for k, v in source_counter.items()], 18)}</div>
  <div class="card"><h3>Rezervasyon Öncesi Doğrulanacak Policy Alanları</h3>{tag(policy_fields, 24)}</div>
  <h3>Kaynak Envanteri</h3>
  <div class="grid">{source_cards}</div>
  <h3>Otel Adayları</h3>
  {table("hotels-table", rows, columns)}
</section>
"""


def module_panel(taxonomy: dict[str, Any], seed: dict[str, Any]) -> str:
    seed_keys = {
        "PatiGezdirme": "walkers",
        "PatiBnB": "stays",
        "PatiMatch": "matches",
        "PatiFamily": "familyListings",
    }
    cards = []
    for module in taxonomy.get("modules", []):
        label = text(module.get("label"))
        seed_key = seed_keys.get(label, "")
        cards.append(f"""
<article class="card module-card">
  <h3>{esc(label)}</h3>
  <p class="muted">{esc(', '.join(module.get('inspiredBy', [])))}</p>
  <div class="row"><b>Kullanıcı amacı</b><div>{tag(module.get('primaryUserIntents', []), 14)}</div></div>
  <div class="row"><b>Filtreler</b><div>{tag(module.get('filters', []), 24)}</div></div>
  <div class="row"><b>Profil alanları</b><div>{tag(module.get('providerProfileFields', []), 24)}</div></div>
  <div class="row"><b>Talep/ilan alanları</b><div>{tag(module.get('requestFields', []), 24)}</div></div>
  <div class="row"><b>Güven sinyalleri</b><div>{tag(module.get('trustSignals', []), 24)}</div></div>
  <div class="row"><b>Seed</b><div>{esc(seed_key)} · {len(seed.get(seed_key, []))} kayıt</div></div>
</article>
""")
    return f"""
<section id="modules" class="panel active">
  <div class="section-title"><div><h2>Modül Haritası</h2><p class="hint">Dört ana iş kolunun data, filtre ve güven alanları.</p></div></div>
  <div class="grid">{''.join(cards)}</div>
</section>
"""


def reference_panel(cities: list[dict[str, Any]], breeds: dict[str, Any], trust: dict[str, Any]) -> str:
    city_rows = [{"city": city.get("name"), "district": ", ".join(city.get("districts", []))} for city in cities]
    breed_rows = []
    for category in breeds.get("animalCategories", []):
        label = text(category.get("label"))
        for item in category.get("mixOptions", []) + category.get("breeds", []):
            breed_rows.append({"type": label, "breed": item})
    city_table = table("cities-table", city_rows, [("city", "İl"), ("district", "İlçeler")])
    breed_table = table("breeds-table", breed_rows, [("type", "Tür"), ("breed", "Cins / kırma seçenek")])
    return f"""
<section id="reference" class="panel">
  <div class="section-title"><div><h2>Temel Referans Data</h2><p class="hint">İl/ilçe, kedi/köpek cinsleri ve güven framework'ü.</p></div></div>
  <div class="mini-stats">
    <div><b>{len(cities)}</b><span>il</span></div>
    <div><b>{sum(len(city.get('districts', [])) for city in cities)}</b><span>ilçe</span></div>
    <div><b>{len(breed_rows)}</b><span>cins/kırma</span></div>
    <div><b>{len(trust.get('trustBadges', []))}</b><span>güven rozeti</span></div>
  </div>
  <div class="card"><h3>Aşılar</h3>{tag(breeds.get('vaccines', []), 30)}</div>
  <h3>İl / İlçe Listesi</h3>{city_table}
  <h3>Kedi / Köpek Cinsleri</h3>{breed_table}
</section>
"""


def main() -> None:
    cities = load_json("cities_districts_tr.json")["cities"]
    breeds = load_json("animal_breeds_tr.json")
    taxonomy = load_json("marketplace_product_taxonomy.json")
    seed = load_json("seed_marketplace_examples.json")
    trust = load_json("trust_safety_framework.json")
    vets = load_json("veterinary_clinics_tr.json")["clinics"]
    groomers = load_json("pet_groomers_tr.json")["groomers"]
    trainers = load_json("dog_trainers_tr.json")["trainers"]
    places = load_json("pati_friendly_places_tr.json")["places"]
    hotels_data = load_json("pet_friendly_hotels_tr.json")

    place_categories = Counter(text(row.get("category"), "Eksik") for row in places)
    panels = [
        module_panel(taxonomy, seed),
        reference_panel(cities, breeds, trust),
        service_panel("vets", "Veterinerler", vets, "İsim, adres, telefon, web ve koordinat ile tam kontrol listesi."),
        service_panel("groomers", "Pet Kuaförleri", groomers, "Bakım, tıraş ve yıkama servisleri için OSM seed listesi."),
        service_panel("trainers", "Köpek Eğitmenleri", trainers, "İleri faz PatiTraining/PatiCare destek datası."),
        hotel_panel(hotels_data),
        service_panel("places", "Pet Dostu Mekanlar", places, "Restoran, otel, park ve yakın çevre keşfi için seed liste.", extra=f'<div class="row"><b>Kategoriler</b><div>{tag([f"{k}: {v}" for k, v in place_categories.items()], 20)}</div></div>'),
    ]

    html_doc = f"""<!doctype html>
<html lang="tr">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>PatiParent Data Mapping</title>
<style>
:root{{--bg:#f6f3ee;--paper:#fff;--ink:#101828;--muted:#667085;--line:rgba(16,24,40,.11);--teal:#0f766e;--blue:#2563eb;--shadow:0 24px 80px rgba(16,24,40,.10)}}
*{{box-sizing:border-box}}body{{margin:0;font-family:ui-sans-serif,-apple-system,BlinkMacSystemFont,"SF Pro Display","Segoe UI",sans-serif;color:var(--ink);background:radial-gradient(circle at 8% 0%,rgba(37,99,235,.12),transparent 28rem),radial-gradient(circle at 90% 6%,rgba(249,115,22,.12),transparent 26rem),linear-gradient(180deg,#fbfaf7 0%,var(--bg) 100%)}}
.wrap{{max-width:1280px;margin:0 auto;padding:36px 22px 72px}}.hero{{padding:34px;border-radius:34px;background:rgba(255,255,255,.92);box-shadow:var(--shadow);border:1px solid rgba(255,255,255,.75)}}
.eyebrow{{display:inline-flex;padding:8px 12px;border-radius:999px;background:rgba(15,118,110,.1);color:var(--teal);font-weight:900;font-size:13px}}h1{{font-size:clamp(34px,5vw,64px);line-height:1;letter-spacing:-2.4px;margin:18px 0 12px;max-width:880px}}.lead{{color:var(--muted);font-size:17px;line-height:1.58;max-width:860px;margin:0}}
.tabs{{position:sticky;top:0;z-index:5;display:flex;gap:8px;overflow:auto;padding:14px 0;margin:18px 0;background:linear-gradient(180deg,#fbfaf7 60%,rgba(251,250,247,.72));backdrop-filter:blur(12px)}}.tab{{border:1px solid var(--line);background:rgba(255,255,255,.86);border-radius:999px;padding:11px 15px;font-weight:900;color:#344054;cursor:pointer;white-space:nowrap}}.tab.active{{background:#111827;color:white;border-color:#111827}}
.panel{{display:none}}.panel.active{{display:block}}.section-title{{display:flex;align-items:flex-end;justify-content:space-between;gap:16px;margin:24px 0 14px}}h2{{margin:0;font-size:28px;letter-spacing:-1px}}h3{{letter-spacing:-.3px}}.hint,.muted{{color:var(--muted)}}
.grid{{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:16px}}.card,.mini-stats>div{{background:rgba(255,255,255,.9);border:1px solid var(--line);border-radius:24px;box-shadow:0 14px 42px rgba(16,24,40,.055)}}.card{{padding:20px;margin-bottom:14px}}.mini-stats{{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:12px;margin-bottom:14px}}.mini-stats>div{{padding:16px}}.mini-stats b{{display:block;font-size:28px}}.mini-stats span{{color:var(--muted);font-weight:750;font-size:13px}}
.row{{display:grid;grid-template-columns:170px 1fr;gap:12px;padding:10px 0;border-top:1px solid var(--line)}}.row:first-of-type{{border-top:0}}.tag{{display:inline-flex;align-items:center;margin:3px 5px 3px 0;padding:7px 10px;border-radius:999px;background:#f2f4f7;color:#344054;font-weight:800;font-size:12px}}.tag.more{{background:#e0f2fe;color:#0369a1}}
.table-wrap{{overflow:auto;background:white;border:1px solid var(--line);border-radius:22px;box-shadow:0 12px 40px rgba(16,24,40,.055);margin-bottom:24px}}table{{width:100%;border-collapse:collapse;min-width:980px}}th,td{{text-align:left;padding:12px 14px;border-bottom:1px solid #eef2f7;vertical-align:top;font-size:13px}}th{{position:sticky;top:0;background:#f8fafc;color:#475467;font-size:12px;text-transform:uppercase;letter-spacing:.04em}}td a{{color:var(--blue);font-weight:800;text-decoration:none}}.table-note{{padding:12px 14px;margin:0;border-bottom:1px solid #eef2f7}}.footer{{margin-top:34px;color:var(--muted);font-size:13px}}
@media(max-width:900px){{.hero{{padding:24px;border-radius:26px}}.grid,.mini-stats{{grid-template-columns:1fr}}.row{{grid-template-columns:1fr}}h1{{letter-spacing:-1.2px}}}}
</style>
</head>
<body>
<main class="wrap">
<header class="hero"><div class="eyebrow">PatiParent Data Mapping</div><h1>Master data kontrol paneli.</h1><p class="lead">Üstteki sekmelere tıklayarak modül haritasını ve tam veteriner, kuaför, eğitmen, pet dostu mekan listelerini isim, adres, telefon, web ve harita linkleriyle kontrol edebilirsin.</p></header>
<nav class="tabs" aria-label="Data sections">
<button class="tab active" data-target="modules">Modüller</button><button class="tab" data-target="reference">Temel Data</button><button class="tab" data-target="vets">Veterinerler</button><button class="tab" data-target="groomers">Kuaförler</button><button class="tab" data-target="trainers">Eğitmenler</button><button class="tab" data-target="hotels">Pati Dostu Oteller</button><button class="tab" data-target="places">Pet Dostu Mekanlar</button>
</nav>
{''.join(panels)}
<p class="footer">Generated from app/assets/master_data · yeniden üretmek için: <code>python scripts/generate_data_mapping_report.py</code></p>
</main>
<script>
const tabs = [...document.querySelectorAll('.tab')];
const panels = [...document.querySelectorAll('.panel')];
function showPanel(id) {{
  tabs.forEach(tab => tab.classList.toggle('active', tab.dataset.target === id));
  panels.forEach(panel => panel.classList.toggle('active', panel.id === id));
  history.replaceState(null, '', '#' + id);
}}
tabs.forEach(tab => tab.addEventListener('click', () => showPanel(tab.dataset.target)));
if (location.hash) {{
  const id = location.hash.slice(1);
  if (document.getElementById(id)) showPanel(id);
}}
</script>
</body>
</html>
"""
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    html_doc = "\n".join(line.rstrip() for line in html_doc.splitlines()) + "\n"
    OUTPUT.write_text(html_doc, encoding="utf-8")
    print(f"Wrote {OUTPUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
