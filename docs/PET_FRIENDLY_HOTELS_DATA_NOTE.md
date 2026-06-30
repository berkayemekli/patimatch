# Pati Dostu Oteller Data Notu

Tarih: 30 Haziran 2026

## Sonuç

Evet, pati dostu otellerin listeleri var; fakat ürün için doğrudan tek bir temiz ve güvenilir kaynak gibi kullanmak doğru değil. Kaynaklar ticari OTA/dizin yapısında, politika detayları sık değişiyor ve çoğu otel için pet fee, kilo limiti, ortak alan kuralı gibi kritik bilgiler rezervasyon öncesi doğrulanmalı.

## Bulunan Kaynak Tipleri

- Booking.com pet-friendly Turkey filtre/dizinleri.
- BringFido Türkiye ve şehir bazlı pet-friendly lodging dizinleri.
- Setur evcil hayvan kabul eden oteller sayfası.
- Etstur evcil hayvan dostu oteller sayfası.
- TatilBudur hayvan dostu oteller sayfası.
- Oggusto gibi editoryal pet-friendly otel listeleri.
- HayvanSever Oteller gibi niş pet-friendly otel rehberleri.
- OpenStreetMap pets/dog/pets_allowed etiketleri.

## Repo'ya Eklenenler

- `app/assets/master_data/pet_friendly_hotels_tr.json`
  - 8 kaynak dizini.
  - 13 doğrulanmamış başlangıç otel/kamp adayı.
  - Rezervasyon öncesi doğrulanacak policy alanları.

- `docs/data_mapping.html`
  - Yeni sekme: `Pati Dostu Oteller`.
  - Kaynak envanteri, şehir dağılımı, durum/kaynak kırılımı ve aday otel tablosu.

## PatiParent İçin Doğru Konumlandırma

Bu data ana PatiBnB rakibi gibi değil, destek katmanı gibi konumlanmalı:

1. `PatiCare / Yakınımda`
   - Veteriner, kuaför, eğitmen, pet dostu otel/mekan birlikte gösterilir.

2. `PatiBnB alternatifleri`
   - Kullanıcı ev ortamı host bulamazsa pet-friendly otel adayı gösterilir.

3. `Partner aday havuzu`
   - PatiParent ileride otellerle anlaşma yapıp doğrulanmış pet policy yayınlayabilir.

4. `SEO içerik`
   - “İstanbul pati dostu oteller”, “Bodrum köpek kabul eden oteller” gibi landing sayfaları üretilebilir.

## Doğrulanması Gereken Alanlar

- Hangi tür kabul ediliyor: köpek, kedi, ikisi de.
- Maksimum kilo.
- Maksimum pet sayısı.
- Ek ücret veya depozito.
- Ortak alan kuralı.
- Odada yalnız bırakma kuralı.
- Aşı/pasaport şartı.
- Yakın veteriner/acil durum planı.
- Son doğrulama tarihi.

## Sonraki Akıllı Adım

`PatiCare / Yakınımda` sayfasında kategori filtresine `Otel / Konaklama` ekleyip bu data setini harita/listede göstermek. Her kayıt `Doğrulanmamış kaynak` etiketiyle gelmeli; kullanıcıdan “Bu otel pet kabul ediyor mu?” sinyali toplanmalı.
