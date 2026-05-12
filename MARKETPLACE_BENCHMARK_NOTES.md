# PatiParent Marketplace Benchmark Notes

Bu notlar Airbnb, Armut ve Sahibinden benzeri pazar yeri mantigini PatiParent'in 4 modulune cevirmek icin hazirlandi.

## Ana dersler

- Airbnb tarafi guven katmaninda cok guclu: kimlik dogrulama, konum/listing dogrulama, yorumlar, ev kurallari ve platform icinde iletisim/odeme.
- Armut tarafi hizmet talebi mantiginda guclu: kullanici ihtiyacini anlatir, hizmet veren teklif verir, karar yorum/profil/kapsam netligiyle verilir.
- Sahibinden tarafi kategori ve filtre omurgasinda guclu: her kategori kendi ozellik setiyle ilanlanir, kullanici hizli eleyerek ilerler.

## Bizim urun karari

PatiParent tek bir pet shop veya ilan sitesi gibi degil, guvenli pet ebeveynligi ekosistemi olmali. Bu yuzden veri modeli dort katmanli olmali:

1. Pet profili: tur, cins, yas, cinsiyet, asi, saglik, karakter, boyut, konum.
2. Insan/profil guveni: kimlik, telefon, yorum, tamamlanan hizmet, sikayet/rapor gecmisi.
3. Hizmet/ilan detaylari: modulle ilgili ozellikler, fiyat, tarih, uygunluk, kurallar.
4. Guven operasyonu: raporla, blokla, acil destek, belge dogrulama, platform ici mesaj/odeme.

## Ilk entegre edilecek dosyalar

- `marketplace_product_taxonomy.json`: 4 modulun veri, filtre ve risk modeli.
- `trust_safety_framework.json`: guven rozetleri, yorum boyutlari, fraud sinyalleri, guvenlik checklistleri.

## Kaynak notlari

- Airbnb yardim dokumanlari kimlik dogrulama, konum dogrulama, profil gorunurlugu ve platform icinde iletisim/odeme vurgusu yapiyor.
- Armut yardim dokumani teklif seciminde yorumlar, profil bilgileri, is kapsami ve platform uzerinden anlasma vurgusu yapiyor.
- Sahibinden benzeri ilan mantiginda kategoriye ozel alanlar ve guvenli islem/dis link riski kritik ders.
