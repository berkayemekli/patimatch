# Database and SQL Analytics Plan

Bu plan PatiParent icin Firestore koleksiyonlarini raporlanabilir bir veri modeline oturtur.
Firestore NoSQL oldugu icin burada "tablo" yerine "collection" kullanilir; rapor mantigi ise tablo gibi dusunulur.

SQL analitik katmani `analytics/bigquery/` altinda baslatildi. Operasyonel veri Firestore'da kalacak; rapor ve analiz tarafi BigQuery dataset'i uzerinden SQL ile okunacak.

Onerilen dataset:
- `patiparent_analytics`

Ilk SQL dosyalari:
- `analytics/bigquery/schema.sql`
- `analytics/bigquery/views.sql`
- `analytics/bigquery/sample_queries.sql`

## Ana koleksiyonlar

### users
Kullanici hesap bilgileri.

Zorunlu alanlar:
- `userId`
- `displayName`
- `email`
- `phone`
- `city`
- `district`
- `createdAt`
- `updatedAt`
- `lastActiveAt`

Raporlar:
- Toplam kullanici
- Sehir/ilce bazli kullanici
- Profil tamamlayan kullanici
- Google/e-posta/telefon giris kirilimi

### dogs
Kullanicinin pet profili. Rony veya kullanicinin kendi peti burada tutulur.

Zorunlu alanlar:
- `dogId`
- `ownerId`
- `userId`
- `name`
- `animalCategory`
- `breed`
- `ageMonths`
- `weightKg`
- `city`
- `district`
- `photoUrls`
- `isProfileComplete`
- `createdAt`
- `updatedAt`

Raporlar:
- Pet turu ve cins dagilimi
- Sehir bazli pet sayisi
- Profil tamamlama orani
- Asi / mikrocip / pasaport doluluk orani

### walkers
PatiGezdirme hizmet veren profilleri.

Zorunlu alanlar:
- `walkerId`
- `ownerUserId`
- `displayName`
- `city`
- `district`
- `acceptedBreeds`
- `acceptedSizes`
- `hourlyPrice`
- `badges`
- `rating`
- `completedWalks`
- `status`

Raporlar:
- Aktif gezdirici sayisi
- Sehir bazli arz
- Ortalama fiyat
- Tamamlanan yuruyus sayisi

### bnb_hosts
PatiBnB konaklama veren profilleri.

Zorunlu alanlar:
- `hostId`
- `ownerUserId`
- `displayName`
- `city`
- `district`
- `homeType`
- `acceptedPetTypes`
- `nightlyPrice`
- `badges`
- `rating`
- `completedStays`
- `status`

Raporlar:
- Aktif host sayisi
- Ortalama gecelik fiyat
- Ev tipi dagilimi
- Sehir bazli konaklama arzi

### adoption_posts
PatiFamily sahiplendirme / gecici yuva ilanlari.

Zorunlu alanlar:
- `postId`
- `ownerUserId`
- `dogName`
- `animalCategory`
- `breed`
- `city`
- `district`
- `urgency`
- `badges`
- `status`
- `createdAt`
- `updatedAt`

Raporlar:
- Aktif sahiplendirme ilani
- Acil yuva sayisi
- Tur/cins dagilimi
- Sehir bazli ihtiyac

## Islem koleksiyonlari

### walk_requests
Gezdirme talepleri.

Rapor alanlari:
- `requestId`
- `requesterUserId`
- `requesterDogId`
- `walkerId`
- `walkerOwnerUserId`
- `city`
- `district`
- `preferredAt`
- `price`
- `status`
- `createdAt`

Raporlar:
- Gunluk/haftalik talep sayisi
- Talep -> tamamlanma donusumu
- Iptal orani
- Gelir tahmini

### bnb_requests
Konaklama talepleri.

Rapor alanlari:
- `requestId`
- `requesterUserId`
- `requesterDogId`
- `hostId`
- `hostOwnerUserId`
- `city`
- `district`
- `checkIn`
- `checkOut`
- `nightlyPrice`
- `totalPrice`
- `status`
- `createdAt`

Raporlar:
- Gecelik talep hacmi
- Ortalama konaklama suresi
- Sehir bazli gelir potansiyeli
- Host donusum orani

### adoption_applications
Sahiplendirme basvurulari.

Rapor alanlari:
- `applicationId`
- `requesterUserId`
- `requesterDogId`
- `postId`
- `ownerUserId`
- `dogName`
- `status`
- `createdAt`

Raporlar:
- Ilan basina basvuru
- Acil yuva basvuru hizi
- Basvuru -> onay donusumu

### payments (deferred)
Odeme kayitlari uzun ilk donem icin MVP kapsaminda degil. Uygulama odeme adimi gostermeyecek; bu koleksiyon sadece ileride business model degisirse tekrar ele alinacak.

Rapor alanlari:
- `paymentId`
- `userId`
- `module`
- `relatedRequestId`
- `amount`
- `currency`
- `status`
- `provider`
- `createdAt`
- `updatedAt`

Raporlar:
- MVP'de raporlanmayacak
- Ileride acilirsa gunluk/aylik gelir
- Ileride acilirsa modul bazli gelir

## Analitik olay koleksiyonu

### analytics_events
Uygulama icindeki raporlanabilir olaylar icin ortak event log.

Zorunlu alanlar:
- `eventId`
- `userId`
- `eventName`
- `module`
- `entityType`
- `entityId`
- `properties`
- `createdAt`

Ornek eventName degerleri:
- `login_success`
- `guest_started`
- `profile_saved`
- `pet_profile_saved`
- `walk_request_created`
- `bnb_request_created`
- `adoption_application_created`
- `verification_started`
- `notification_opened`

Raporlar:
- Gunluk aktif kullanici
- Modul bazli kullanim
- Funnel: login -> pet profile -> request
- Funnel: listing view -> request

## Agregasyon koleksiyonlari

### daily_metrics
Gunluk dashboard icin onceden hesaplanmis ozetler. Firestore'da MVP icin tutulabilir; kalici analitik hedefi BigQuery `daily_metrics` tablosudur.

Doc id formati:
- `YYYY-MM-DD`

Alanlar:
- `date`
- `newUsers`
- `activeUsers`
- `newDogs`
- `walkRequests`
- `bnbRequests`
- `adoptionApplications`
- `updatedAt`

### module_metrics
Modul bazli ozetler.

Doc id formati:
- `walk_YYYY-MM-DD`
- `bnb_YYYY-MM-DD`
- `match_YYYY-MM-DD`
- `family_YYYY-MM-DD`

Alanlar:
- `module`
- `date`
- `views`
- `requests`
- `conversions`
- `activeSupply`
- `updatedAt`

## Admin rapor ekranlari

MVP rapor ekrani:
- Kullanici sayisi
- Pet profili sayisi
- PatiGezdirme talep sayisi
- PatiBnB talep sayisi
- PatiFamily basvuru sayisi
- Son 7 gun trend
- Sehir bazli kirilim

SQL rapor ekrani hedefi:
- BigQuery `views.sql` view'larini okur.
- Baslangicta Looker Studio veya BigQuery UI ile raporlar incelenebilir.
- Sonra admin panel icinde backend uzerinden bu sorgular guvenli sekilde gosterilir.

## Uygulama sirasi

1. `analytics_events` koleksiyonu icin repository ekle.
2. Login, pet profile save ve request create olaylarini event olarak yaz.
3. BigQuery dataset'i olustur ve `analytics/bigquery/schema.sql` calistir.
4. `analytics/bigquery/views.sql` ile ilk SQL view'larini kur.
5. Firestore -> BigQuery export veya Cloud Functions aktarimini sec.
6. Blaze plan aktif olana kadar admin raporu direkt Firestore sorgulariyla MVP olarak goster.
7. Daha sonra BigQuery SQL ve Looker Studio ile gercek dashboard kur.
