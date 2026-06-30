# PatiParent SEO Checklist

Tarih: 30 Haziran 2026

## Mevcut Durum

Google aramasında site görünüyor ama kötü metadata ile görünüyor:

- Başlık: `patimatch_app`
- Açıklama: `A new Flutter project.`

Bu yüzden ilk profesyonel SEO adımı teknik kimliği düzeltmekti.

## Yapılanlar

- `app/web/index.html`
  - Türkçe `lang="tr"` eklendi.
  - Marka title güncellendi.
  - Meta description güncellendi.
  - Canonical URL eklendi.
  - OpenGraph ve Twitter kart meta tag'leri eklendi.
  - Organization ve WebSite schema.org JSON-LD eklendi.
  - JavaScript kapalı kullanıcı/arayıcı için kısa noscript içerik eklendi.

- `app/web/manifest.json`
  - Flutter default `patimatch_app` adı PatiParent olarak değiştirildi.
  - Açıklama ve tema renkleri güncellendi.

- `app/web/robots.txt`
  - Google ve diğer botlara siteyi tarama izni verildi.
  - Sitemap adresi eklendi.

- `app/web/sitemap.xml`
  - Ana sayfa sitemap'e eklendi.

## Search Console'da Yapılacaklar

1. Google Search Console'a gir.
2. Domain property olarak `patiparent.com` ekle.
3. DNS TXT doğrulaması yap.
4. Sitemaps bölümüne şu adresi gönder:

```text
https://patiparent.com/sitemap.xml
```

5. URL Inspection bölümünde şu adres için `Request indexing` yap:

```text
https://patiparent.com/
```

## Sonraki SEO Adımları

1. Flutter tek sayfa uygulama olduğu için gerçek SEO landing sayfaları eklenmeli.
2. Önerilen ilk landing sayfaları:
   - `/pati-gezdirme`
   - `/pati-bnb`
   - `/pati-match`
   - `/pati-family`
   - `/pati-dostu-oteller`
   - `/veterinerler`
   - `/pet-kuaforleri`
3. Her landing sayfası statik HTML veya pre-render edilmiş içerik taşımalı.
4. Blog/SEO içerikleri ile long-tail arama yakalanmalı:
   - “İstanbul köpek gezdirici”
   - “Bodrum evcil hayvan kabul eden oteller”
   - “Kedi pansiyonu yerine ev ortamı konaklama”
   - “Köpek sahiplendirme başvuru süreci”

## Not

Bu commit Google'ın sonucu anında değiştirmez. Deployment sonrası Google'ın yeniden taraması gerekir. Search Console ile manuel index isteği süreci hızlandırır.
