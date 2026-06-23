# Hizmet Alan / Hizmet Veren Eşleşme Akışı

Tarih: 23 Haziran 2026

## Kurulan Akış

1. Kullanıcı PatiGezdirme, PatiBnB veya PatiFamily talebi oluşturur.
2. Hizmet veren talebi `Taleplerim > Bana gelen` ekranında görür.
3. Talep kabul edildiğinde atomik olarak:
   - Talep `accepted` olur.
   - `service_engagements` kaydı oluşur.
   - Hizmet konuşması `chats` koleksiyonunda açılır.
   - İlk karşılama mesajı oluşur.
4. Her iki taraf:
   - Talep kartındaki `Sohbete geç` butonundan,
   - Üst menüdeki `Hizmet Mesajları` alanından
   konuşmaya ulaşır.
5. Sohbet içinde yaşam döngüsü takip edilir:
   - Konuşma
   - Planlandı
   - Devam ediyor
   - Tamamlandı

PatiMatch sosyal sohbetleri bu hizmet konuşmalarından ayrı kalır.

## Staging Simülasyonu

Koşu: `lt_service_flow_20260623`

- 10 PatiGezdirme alan/veren çifti
- 10 PatiBnB alan/veren çifti
- 10 PatiFamily alan/veren çifti
- 30 hizmet ilişkisi
- 30 hizmet konuşması
- 5 PatiMatch sosyal konuşması
- Toplam 35 chat

Staging yazımı başarılı oldu. Ücretsiz Firestore okuma kotası dolduğu için aynı anda geri-okuma validator'ı `429 RESOURCE_EXHAUSTED` aldı. Dry-run sayaç sözleşmesi ve Flutter testleri geçti.

## Gözlem Alanları

`service_engagements.stage` dağılımı üzerinden şu sorular izlenebilir:

- Kaç kabul konuşmaya dönüştü?
- Kaç konuşma planlandı?
- Kaç hizmet başladı?
- Kaç hizmet tamamlandı?
- Hangi modülde konuşmadan planlamaya geçiş düşük?
- Hangi aşamada kullanıcılar bırakıyor?

## Sonraki Mantıklı Geliştirmeler

1. Hizmet tamamlanınca iki taraflı değerlendirme.
2. Planlandı aşamasında kesin tarih/saat ve takvim senkronu.
3. İptal ve uyuşmazlık akışı.
4. Konuşma içinde fotoğraf/dosya paylaşımı.
5. Okunmamış hizmet mesajı rozeti.
6. Yönetim panelinde aşama dönüşüm hunisi.
