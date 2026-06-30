# Search Engine Distribution Plan

PatiParent'in tum ana arama motorlarinda gorunmesi icin teknik ve manuel dagitim plani.

## Teknik Durum

- Canonical host: `https://www.patiparent.com`
- Sitemap: `https://www.patiparent.com/sitemap.xml`
- Robots: `https://www.patiparent.com/robots.txt`
- IndexNow key: `https://www.patiparent.com/indexnow.txt`
- IndexNow local key file: `app/web/indexnow.txt`
- Saglik raporu: `docs/seo_index_health_report.md`

## Arama Motoru Bazinda Aksiyon

### Google

Google IndexNow desteklemez. Resmi yol Search Console'dur.

1. Google Search Console'da domain ya da URL-prefix property ekle.
2. Sitemap gonder: `https://www.patiparent.com/sitemap.xml`.
3. URL Inspection ile Request indexing yap:
   - `https://www.patiparent.com/`
   - `https://www.patiparent.com/pati-gezdirme`
   - `https://www.patiparent.com/pati-bnb`
   - `https://www.patiparent.com/pati-match`
   - `https://www.patiparent.com/pati-family`

### Bing / Edge

1. Bing Webmaster Tools'a siteyi ekle.
2. Sitemap gonder: `https://www.patiparent.com/sitemap.xml`.
3. IndexNow'u calistir:

```powershell
cd C:\AI\Dog_Date
python scripts\submit_indexnow.py
```

### Yandex ve diger IndexNow destekleyenler

IndexNow submission tek endpoint uzerinden katilimci motorlara sinyal gonderir.

```powershell
python scripts\submit_indexnow.py
```

## Her Deploy Sonrasi Kontrol

```powershell
python scripts\generate_seo_index_report.py
python scripts\submit_indexnow.py
```

## Notlar

- Sitemap gondermek indeks garantisi degildir, ama resmi tarama sinyalidir.
- Google sonucu eski `A new Flutter project` gosterebilir; bu Google cache'i temizleyene kadar normaldir.
- Edge/Bing Google'dan farkli indeks kullanir, bu yuzden ayrica Bing Webmaster gereklidir.
