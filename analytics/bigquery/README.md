# PatiParent SQL Analytics

Bu klasor PatiParent icin SQL tabanli analitik katmaninin sozlesmesidir.

## Karar

- Operasyonel app verisi Firestore'da kalir.
- Raporlama verisi BigQuery dataset'ine akar.
- Sen raporlari SQL ile `patiparent_analytics` tablolarindan cekersin.
- Odeme metrikleri MVP ve uzun ilk donem kapsaminda yoktur.

## Dosyalar

- `schema.sql`: Ana tablo yapilari.
- `views.sql`: Gunluk urun, funnel, sehir ve arz/talep view'lari.
- `sample_queries.sql`: Kullanabilecegin ilk rapor sorgulari.

## Dataset

Onerilen BigQuery dataset adi:

```text
patiparent_analytics
```

Onerilen lokasyon:

```text
EU
```

## Veri akisi

1. Flutter uygulamasi Firestore'a yazar.
2. Kritik olaylar `analytics_events` koleksiyonuna yazilir.
3. Firestore -> BigQuery export veya Cloud Functions aktarimi SQL tablolarini besler.
4. Raporlar BigQuery SQL ile okunur.
5. Istenirse Looker Studio ayni dataset'e baglanir.

## Ilk rapor hedefleri

- Gunluk yeni kullanici ve aktif kullanici.
- Pet profil tamamlama orani.
- Sehir bazli pet ve kullanici dagilimi.
- PatiGezdirme / PatiBnB / PatiFamily talep trendi.
- Sehir bazli arz / talep boslugu.
- Login -> pet profile -> request funnel.
- Mavi tik / kimlik dogrulama etkisi.

## Not

Client tarafindan SQL'e direkt baglanma yapilmayacak. SQL erisimi admin, BigQuery veya backend uzerinden yapilacak. Bu hem guvenlik hem de maliyet kontrolu icin daha dogru mimaridir.
