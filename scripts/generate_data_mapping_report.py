from __future__ import annotations

import html
import json
from pathlib import Path
from typing import Any, Iterable


ROOT = Path(__file__).resolve().parents[1]
MASTER_DATA = ROOT / "app" / "assets" / "master_data"
OUTPUT = ROOT / "docs" / "data_mapping.html"


def tr(value: str) -> str:
    """Return text after repairing common mojibake without adding dependencies."""
    text = value
    for _ in range(4):
        if not any(marker in text for marker in ("Ã", "Ä", "Å", "Â", "þ", "ð", "ý")):
            break
        changed = False
        for encoding in ("latin1", "cp1252"):
            try:
                candidate = text.encode(encoding).decode("utf-8")
            except UnicodeError:
                continue
            if candidate != text:
                text = candidate
                changed = True
                break
        if not changed:
            break
    text = text.translate(
        str.maketrans(
            {
                "þ": "ş",
                "Þ": "Ş",
                "ð": "ğ",
                "Ð": "Ğ",
                "ý": "ı",
                "Ý": "İ",
            }
        )
    )
    replacements = {
        "Ã‡": "Ç",
        "Ã–": "Ö",
        "Ãœ": "Ü",
        "Ä°": "İ",
        "Ä±": "ı",
        "ÄŸ": "ğ",
        "ÅŸ": "ş",
        "Ã§": "ç",
        "Ã¶": "ö",
        "Ã¼": "ü",
        "Â·": "·",
        "â€™": "'",
    }
    for bad, good in replacements.items():
        text = text.replace(bad, good)
    return text


def load_json(name: str) -> dict[str, Any]:
    return json.loads((MASTER_DATA / name).read_text(encoding="utf-8-sig"))


def esc(value: Any) -> str:
    return html.escape(tr(str(value)), quote=True)


def tag_list(items: Iterable[Any] | None, limit: int = 18, *, warn: bool = False) -> str:
    values = [tr(str(item)) for item in (items or []) if str(item).strip()]
    visible = values[:limit]
    class_name = "tag warn" if warn else "tag"
    markup = "".join(f'<span class="{class_name}">{esc(item)}</span>' for item in visible)
    extra = len(values) - len(visible)
    if extra > 0:
        markup += f'<span class="tag more">+{extra}</span>'
    return markup or '<span class="muted">Yok</span>'


def rows(pairs: Iterable[tuple[str, str]]) -> str:
    return "".join(f'<div class="row"><b>{esc(label)}</b><div>{body}</div></div>' for label, body in pairs)


def list_markup(items: Iterable[Any]) -> str:
    return "<ul>" + "".join(f"<li>{esc(item)}</li>" for item in items) + "</ul>"


def trust_names(items: Any) -> list[str]:
    if isinstance(items, dict):
        return [tr(str(value.get("label") or value.get("name") or key)) for key, value in items.items()]
    if isinstance(items, list):
        result = []
        for item in items:
            if isinstance(item, dict):
                result.append(tr(str(item.get("label") or item.get("name") or item.get("key") or "")))
            else:
                result.append(tr(str(item)))
        return [item for item in result if item]
    return []


def main() -> None:
    cities = load_json("cities_districts_tr.json")["cities"]
    breeds = load_json("animal_breeds_tr.json")
    taxonomy = load_json("marketplace_product_taxonomy.json")
    seed = load_json("seed_marketplace_examples.json")
    trust = load_json("trust_safety_framework.json")
    vet = load_json("veterinary_clinics_tr.json")
    places = load_json("pati_friendly_places_tr.json")
    groomers = load_json("pet_groomers_tr.json")
    trainers = load_json("dog_trainers_tr.json")

    district_count = sum(len(city["districts"]) for city in cities)
    breed_total = sum(
        len(category.get("breeds", [])) + len(category.get("mixOptions", []))
        for category in breeds["animalCategories"]
    )

    module_class = {
        "PatiGezdirme": "walk",
        "PatiBnB": "bnb",
        "PatiMatch": "match",
        "PatiFamily": "family",
    }
    module_screens = {
        "PatiGezdirme": "app/lib/pati_gezdirme_page.dart",
        "PatiBnB": "app/lib/pati_bnb_page.dart",
        "PatiMatch": "app/lib/pati_match_page.dart",
        "PatiFamily": "app/lib/pati_parent_page.dart",
    }
    seed_keys = {
        "PatiGezdirme": "walkers",
        "PatiBnB": "stays",
        "PatiMatch": "matches",
        "PatiFamily": "familyListings",
    }

    module_cards = []
    for module in taxonomy["modules"]:
        name = tr(str(module["label"]))
        seed_key = seed_keys.get(name, "")
        inspired = ", ".join(tr(str(item)) for item in module.get("inspiredBy", []))
        seed_summary = f"{esc(seed_key)} · {len(seed.get(seed_key, []))} kayıt"
        module_rows = rows([
            ("Ekran", esc(module_screens.get(name, ""))),
            ("Kullanıcı amacı", tag_list(module.get("primaryUserIntents", []), 12)),
            ("Filtreler", tag_list(module.get("filters", []), 24)),
            ("Hizmet veren profil", tag_list(module.get("providerProfileFields", []), 24)),
            ("Talep/ilan alanları", tag_list(module.get("requestFields", []), 24)),
            ("Güven Sinyalleri", tag_list(module.get("trustSignals", []), 24)),
            ("Riskler", tag_list(module.get("importantRisks", []), 14)),
            ("Seed İçerik", seed_summary),
        ])
        module_cards.append(
            f'''<article class="card module {module_class.get(name, "")}"><h3>{esc(name)}</h3><p class="muted">{esc(inspired)}</p>{module_rows}</article>'''
        )

    category_cards = []
    for category in breeds["animalCategories"]:
        options = [*category.get("mixOptions", []), *category.get("breeds", [])]
        category_cards.append(
            f'''<article class="card"><h3>{esc(category["label"])}</h3><p class="muted">{len(category.get("breeds", []))} safkan \u00b7 {len(category.get("mixOptions", []))} k\u0131rma/melez</p>{tag_list(options, 18)}</article>'''
        )

    vet_missing_city = sum(1 for clinic in vet["clinics"] if not clinic.get("city"))
    place_missing_city = sum(1 for place in places["places"] if not place.get("city"))
    groomer_missing_city = sum(1 for groomer in groomers["groomers"] if not groomer.get("city"))
    trainer_missing_city = sum(1 for trainer in trainers["trainers"] if not trainer.get("city"))
    place_categories: dict[str, int] = {}
    for place in places["places"]:
        category = tr(str(place.get("category", "unknown")))
        place_categories[category] = place_categories.get(category, 0) + 1

    clinic_names = [clinic.get("name", "Veteriner klini\u011fi") for clinic in vet["clinics"] if clinic.get("name")][:10]
    place_names = [place.get("name", "Pet dostu mekan") for place in places["places"] if place.get("name")][:10]
    groomer_names = [groomer.get("name", "Pet kuaförü") for groomer in groomers["groomers"] if groomer.get("name")][:10]
    trainer_names = [trainer.get("name", "Köpek eğitmeni") for trainer in trainers["trainers"] if trainer.get("name")][:10]

    html_doc = f'''<!doctype html>
<html lang="tr">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>PatiParent Data Mapping</title>
<style>
:root{{--bg:#f6f3ee;--paper:rgba(255,255,255,.9);--ink:#101828;--muted:#667085;--line:rgba(16,24,40,.1);--teal:#0f766e;--rose:#e11d48;--orange:#f97316;--violet:#4f46e5;--shadow:0 24px 80px rgba(16,24,40,.1)}}
*{{box-sizing:border-box}}body{{margin:0;font-family:ui-sans-serif,-apple-system,BlinkMacSystemFont,"SF Pro Display","Segoe UI",sans-serif;color:var(--ink);background:radial-gradient(circle at 8% 0%,rgba(37,99,235,.12),transparent 28rem),radial-gradient(circle at 90% 6%,rgba(249,115,22,.12),transparent 26rem),linear-gradient(180deg,#fbfaf7 0%,var(--bg) 100%)}}.wrap{{max-width:1180px;margin:0 auto;padding:42px 22px 72px}}.hero{{padding:42px;border-radius:34px;background:linear-gradient(135deg,rgba(255,255,255,.94),rgba(255,255,255,.68));box-shadow:var(--shadow);border:1px solid rgba(255,255,255,.72)}}.eyebrow{{display:inline-flex;padding:8px 12px;border-radius:999px;background:rgba(15,118,110,.1);color:var(--teal);font-weight:800;font-size:13px}}h1{{font-size:clamp(38px,6vw,72px);line-height:.96;letter-spacing:-3px;margin:18px 0 16px;max-width:860px}}.lead{{color:var(--muted);font-size:18px;line-height:1.6;max-width:800px;margin:0}}.stats{{display:grid;grid-template-columns:repeat(auto-fit,minmax(145px,1fr));gap:14px;margin-top:28px}}.stat,.card{{background:var(--paper);border:1px solid var(--line);border-radius:26px;box-shadow:0 14px 50px rgba(16,24,40,.06)}}.stat{{padding:18px}}.stat strong{{display:block;font-size:30px;letter-spacing:-1px}}.stat span{{color:var(--muted);font-size:13px;font-weight:700}}section{{margin-top:30px}}.section-title{{display:flex;align-items:flex-end;justify-content:space-between;gap:16px;margin:34px 0 14px}}h2{{margin:0;font-size:28px;letter-spacing:-1px}}.hint,.muted{{color:var(--muted)}}.grid{{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:16px}}.grid-3{{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:16px}}.card{{padding:22px}}.card h3{{margin:0 0 8px;font-size:20px;letter-spacing:-.4px}}.module.walk{{border-top:5px solid var(--teal)}}.module.bnb{{border-top:5px solid var(--orange)}}.module.match{{border-top:5px solid var(--rose)}}.module.family{{border-top:5px solid var(--violet)}}.row{{display:grid;grid-template-columns:180px 1fr;gap:12px;padding:10px 0;border-top:1px solid var(--line)}}.row:first-of-type{{border-top:0}}.row b{{color:#344054}}.tag{{display:inline-flex;align-items:center;margin:3px 5px 3px 0;padding:7px 10px;border-radius:999px;background:#f2f4f7;color:#344054;font-weight:700;font-size:12px}}.tag.more{{background:#e0f2fe;color:#0369a1}}.tag.warn{{background:#fff7ed;color:#c2410c}}ul,ol{{margin:8px 0 0;padding-left:20px;color:#344054;line-height:1.55}}.footer{{margin-top:38px;color:var(--muted);font-size:13px}}@media(max-width:900px){{.hero{{padding:26px;border-radius:26px}}.stats,.grid,.grid-3{{grid-template-columns:1fr}}.row{{grid-template-columns:1fr}}h1{{letter-spacing:-1.5px}}}}
</style>
</head>
<body>
<main class="wrap">
<header class="hero">
<div class="eyebrow">PatiParent Data Mapping · Güncel Ürün Haritası</div>
<h1>Pet super app’in arka plan veri omurgası.</h1>
<p class="lead">Bu rapor, uygulamadaki master data dosyalarının hangi modülleri beslediğini, hangi filtre/form alanlarının hazır olduğunu ve sıradaki entegrasyon noktalarını gösterir. Her data güncellemesinden sonra <code>python scripts/generate_data_mapping_report.py</code> ile yeniden üretilebilir.</p>
<div class="stats">
<div class="stat"><strong>{len(cities)}</strong><span>il</span></div>
<div class="stat"><strong>{district_count}</strong><span>ilçe</span></div>
<div class="stat"><strong>{breed_total}</strong><span>kedi/köpek cinsi + kırma</span></div>
<div class="stat"><strong>{len(vet["clinics"])}</strong><span>veteriner seed</span></div>
<div class="stat"><strong>{len(groomers["groomers"])}</strong><span>kuafÃ¶r seed</span></div>
<div class="stat"><strong>{len(places["places"])}</strong><span>pet dostu mekan</span></div>
</div>
</header>
<section><div class="section-title"><h2>Modül Haritası</h2><span class="hint">marketplace_product_taxonomy.json</span></div><div class="grid">{''.join(module_cards)}</div></section>
<section><div class="section-title"><h2>Temel Veri Kütüphaneleri</h2><span class="hint">şehir, ilçe, tür, cins, aşı</span></div><div class="grid-3"><article class="card"><h3>Türkiye Lokasyon</h3><p class="muted">{len(cities)} il, {district_count} ilçe.</p>{tag_list([city["name"] for city in cities], 27)}</article>{''.join(category_cards)}</div></section>
<section><div class="section-title"><h2>Destek Servisleri Veri Katmanı</h2><span class="hint">OpenStreetMap seed · PatiCare / Yakınımda altyapısı</span></div><div class="grid-3">
<article class="card"><h3>Veteriner Klinikleri</h3><p class="muted">{len(vet["clinics"])} klinik seed datası. Kullanıcıya kritik bilgi göstermeden önce manuel veya sağlayıcı API ile doğrulama gerekir.</p>{rows([
    ("Kaynak", "OpenStreetMap amenity=veterinary"),
    ("Kalite", f'<span class="tag warn">{vet_missing_city} kayıtta il/ilçe eksik</span><span class="tag">koordinat mevcut</span><span class="tag">doğrulanmamış seed</span>'),
    ("Örnekler", tag_list(clinic_names, 10)),
    ("Kullanım", tag_list(["PatiBnB acil veteriner planı", "PatiGezdirme rota yakınlığı", "PatiFamily veteriner belgesi doğrulama", "Harita tabanlı yakın klinikler"], 10)),
])}</article>
<article class="card"><h3>Pet KuafÃ¶rleri</h3><p class="muted">{len(groomers["groomers"])} kuafÃ¶r seed datasÄ±. BakÄ±m, tÄ±raş ve yÄ±kama ihtiyaÃ§larÄ± iÃ§in destek servis katmanÄ±.</p>{rows([
    ("Kaynak", "OpenStreetMap grooming / pet kuafÃ¶r sinyalleri"),
    ("Kalite", f'<span class="tag warn">{groomer_missing_city} kayÄ±tta il/ilÃ§e eksik</span><span class="tag">koordinat mevcut</span><span class="tag">doğrulanmamÄ±ş seed</span>'),
    ("Ãrnekler", tag_list(groomer_names, 10)),
    ("KullanÄ±m", tag_list(["PatiBnB konaklama Ã¶ncesi bakÄ±m", "PatiFamily sahiplendirme sonrasÄ± bakÄ±m", "PatiGezdirme yakÄ±n bakÄ±m noktalarÄ±", "PatiCare destek servisleri"], 10)),
])}</article>
<article class="card"><h3>Köpek Eğitmenleri</h3><p class="muted">{len(trainers["trainers"])} eğitmen seed datası. Temel itaat, yavru eğitimi ve davranış desteği için ileri faz destek katmanı.</p>{rows([
    ("Kaynak", "OpenStreetMap dog training / köpek eğitimi sinyalleri"),
    ("Kalite", f'<span class="tag warn">{trainer_missing_city} kayıtta il/ilçe eksik</span><span class="tag">koordinat mevcut</span><span class="tag">doğrulanmamış seed</span>'),
    ("Örnekler", tag_list(trainer_names, 10)),
    ("Kullanım", tag_list(["PatiGezdirme davranış desteği", "PatiFamily adaptasyon eğitimi", "PatiBnB ev uyumu", "İleri faz PatiTraining alt başlığı"], 10)),
])}</article>

<article class="card"><h3>Pet Dostu Mekanlar</h3><p class="muted">{len(places["places"])} mekan seed datası. Park, açık alan, konaklama ve bazı mekan kategorileri için ilk harita omurgası.</p>{rows([
    ("Kaynak", "OpenStreetMap dog/pets/pets_allowed etiketleri"),
    ("Kategori", tag_list([f"{name}: {count}" for name, count in sorted(place_categories.items())], 10)),
    ("Kalite", f'<span class="tag warn">{place_missing_city} kayıtta il/ilçe eksik</span><span class="tag">pet policy mevcut</span><span class="tag">kullanıcı sinyaliyle doğrulanacak</span>'),
    ("Örnekler", tag_list(place_names, 10)),
    ("Kullanım", tag_list(["PatiGezdirme yürüyüş rotaları", "PatiBnB yakın pet dostu alanlar", "PatiMatch güvenli buluşma noktaları", "PatiFamily adaptasyon rotaları"], 10)),
])}</article>
</div></section>
<section><div class="section-title"><h2>Yan Servis Konumlandırma Önerisi</h2><span class="hint">ana modülleri bölmeden güven ve kolaylık katmanı</span></div><div class="grid">
<article class="card"><h3>PatiCare / Yakınımda</h3><p class="muted">Veteriner, kuaför, pet dostu restoran/otel ve parklar ayrı bir beşinci ana modül gibi değil; tüm deneyimin altında çalışan destek katmanı gibi durmalı.</p>{rows([
    ("PatiGezdirme", tag_list(["rota üzerindeki veteriner", "yakın pet kuaförü", "pet dostu mola noktaları"], 10)),
    ("PatiBnB", tag_list(["konaklama yakınında veteriner", "bakım/kuaför servisi", "pet dostu restoran ve oteller"], 10)),
    ("PatiFamily", tag_list(["sahiplendirme sonrası ilk veteriner", "aşı/bakım checklist", "güvenilir destek servisleri"], 10)),
    ("PatiMatch", tag_list(["güvenli buluşma mekanı", "pet dostu kafe/park", "yakın acil veteriner"], 10)),
])}</article>
<article class="card"><h3>Ürün Prensibi</h3><p class="muted">Kullanıcı ana akışta kaybolmasın; bu veriler ihtiyaç anında bağlamsal kart, harita noktaları ve güven sinyali olarak görünsün.</p>{list_markup([
    "Ana navigasyon 4 modülde kalsın.",
    "Harita ekranında PatiCare filtreleri açılsın.",
    "Her profil detayında yakın destek servisleri gösterilsin.",
    "OSM seed kayıtları kullanıcı yorumu veya işletme doğrulamasıyla zenginleşsin.",
])}</article>
</div></section>
<section><div class="section-title"><h2>Onboarding ve Güven</h2><span class="hint">onboarding + trust safety</span></div><div class="grid">
<article class="card"><h3>Kullanıcı Yolları</h3>{rows([
    ("Hizmet almak", list_markup(["Petini tanıt", "Konumunu seç", "İhtiyacını netleştir", "Güven tercihlerini belirle"])),
    ("Hizmet vermek", list_markup(["Profil ve doğrulama", "Hizmetlerini seç", "Bölge ve uygunluk gir", "Fiyat ve kurallarını oluştur"])),
    ("İkisini de kullanmak", tag_list(["need_service", "provide_service"], 10)),
])}</article>
<article class="card"><h3>Güven Katmanı</h3>{rows([
    ("Doğrulama", tag_list(trust_names(trust.get("verificationLevels", [])), 10)),
    ("Rozetler", tag_list(trust.get("trustBadges", []), 16)),
    ("Yorum Boyutları", tag_list(trust.get("reviewDimensions", []), 16)),
    ("Fraud", tag_list(trust.get("fraudSignals", []), 10)),
])}</article>
</div></section>
<section><div class="section-title"><h2>Bağlantı Yol Haritası</h2><span class="hint">sıradaki pratik işler</span></div><div class="card"><ol><li>Veteriner ve pet dostu mekan datasını harita/nearby discovery ekranına bağla.</li><li>İl/ilçe eksik kayıtları koordinattan normalize et veya sağlayıcı API ile zenginleştir.</li><li>Seed içerikleri tüm kartlara tek kaynak olarak bağla.</li><li>Taxonomy filtrelerini UI bileşenlerine tek kaynaktan üret.</li><li>Onboarding playbook ile profil tamamlama skoru kur.</li></ol></div></section>
<p class="footer">Generated from app/assets/master_data · PatiParent internal product map.</p>
</main>
</body>
</html>
'''

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    with OUTPUT.open("w", encoding="utf-8", newline="\n") as file:
        file.write(tr(html_doc))
    print(f"Wrote {OUTPUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
