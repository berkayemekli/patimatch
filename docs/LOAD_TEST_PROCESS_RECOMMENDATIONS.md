# PatiParent Staging Load Test - Süreç Geliştirme Önerileri

> Uygulama durumu: Önerilerin teknik karşılıkları tamamlandı. Ayrıntılı adım kaydı için `LOAD_TEST_IMPLEMENTATION_PROGRESS.md` dosyasına bak.

Tarih: 23 Haziran 2026  
Ortam: `patimatch-staging`  
Test prefix: `lt_2026`

## Doğrulanan Sonuç

| Modül | Üyelik | Profil / İlan | İşlem |
|---|---:|---:|---:|
| PatiGezdirme | 250 | 250 gezdirici | 250 yürüyüş talebi |
| PatiBnB | 250 | 250 host | 250 konaklama talebi |
| PatiMatch | 250 | 250 pet profili | 250 swipe, 125 match, 125 chat |
| PatiFamily | 250 | 250 ilan | 250 sahiplendirme başvurusu |

Toplam 4.250 idempotent seed dokümanı staging'e yazıldı.  
`docs/load_test_validation_report.json` bağımsız geri-okuma kontrolü `passed: true` sonucu verdi.

## Yaşanan Zorluklar ve İyileştirmeler

### 1. Profil sayısı gerçek kullanım hacmini temsil etmiyordu

İlk seed sürümünde her modülde 250 profil bulunmasına rağmen yürüyüş, konaklama ve sahiplendirme akışlarında yalnızca 80'er işlem vardı.

**Risk:** Liste ekranı dolu görünürken rezervasyon, takvim ve operasyon ekranları gerçek hacimde test edilmiyordu.

**İyileştirme:** Talep ve başvuru sayıları 250'ye çıkarıldı. Her modül için 250 kayıt içeren merkezi `module_memberships` koleksiyonu eklendi.

### 2. Seed sonucu bağımsız doğrulanmıyordu

Script yalnızca yazmayı denediği doküman sayısını bildiriyordu.

**Risk:** Kısmi commit, bağlantı kesintisi veya yanlış proje nedeniyle eksik veri fark edilmeyebilirdi.

**İyileştirme:** `scripts/validate_load_test.js` eklendi. Firestore'dan kayıtları geri okuyarak beklenen-gerçek karşılaştırması yapıyor.

### 3. Staging altyapısı başlangıçta eksikti

İlk koşuda staging projesinde Cloud Firestore API ve default database aktif değildi.

**Öneri:** Load-test öncesi otomatik preflight kontrolü eklenmeli:

1. Firebase proje erişimi
2. Firestore API durumu
3. `(default)` database varlığı
4. Firebase CLI oturumu
5. Hedef projenin prod olmadığının doğrulanması

### 4. Windows PowerShell `npm.ps1` engeli

Execution policy nedeniyle `npm` çalışmadı; `npm.cmd` kullanmak gerekti.

**Öneri:** Windows otomasyonlarında doğrudan `npm.cmd` ve `firebase.cmd` kullanılmalı.

### 5. Test kullanıcıları Firebase Auth hesabı değil

Oluşturulan kullanıcılar Firestore profil dokümanlarıdır; Auth hesapları değildir.

**Risk:** Login, token, onboarding ve client security rules yük altında test edilmiyor.

**Öneri:** Auth Emulator veya kontrollü staging Auth seed süreci kurulmalı. Gerçek SMS/e-posta gönderilmemeli.

### 6. PatiMatch ağ yoğunluğu tek senaryolu

250 üye ikili eşleştirildiğinde 125 benzersiz karşılıklı eşleşme oluşur.

**Öneri:** Üç senaryo oluşturulmalı:

- Seyrek ağ: kişi başı 1-2 like
- Normal ağ: kişi başı 10-20 swipe
- Yoğun ağ: kişi başı 50+ swipe ve çoklu match

### 7. Veri hacmi doğrulanıyor, UI performansı ölçülmüyor

Firestore sayıları doğru olsa da render, pagination, görsel yükleme ve scroll akıcılığı otomatik ölçülmüyor.

**Öneri:** Flutter integration test ve browser performans ölçümü:

- İlk içerik görünme süresi
- İlk 20 kartın render süresi
- Pagination süresi
- Filtre sonrası sonuç süresi
- Scroll frame drop
- Firestore read sayısı

### 8. Görseller dış servislere bağımlı

Unsplash/placedog rate-limit veya yavaşlık üretebilir.

**Öneri:** Staging için Firebase Storage altında küçük ve optimize edilmiş yerel görsel seti tutulmalı.

### 9. Cleanup ve test koşusu ayrımı eksik

Deterministik ID'ler tekrar çalıştırıldığında kayıtları güncelliyor. Bu güvenli, ancak eski koşuları karşılaştırmak ve temizlemek zor.

**Öneri:**

- Her koşuya `runId` ekle.
- `load_test_runs/{runId}` manifesti oluştur.
- İlgili koşuyu silen cleanup scripti ekle.
- Test verilerine TTL ekle.

### 10. `module_memberships` henüz ürün modeline bağlı değil

Koleksiyon test ve gelecek rol/üyelik modeli için hazırlandı ancak UI ve rules entegrasyonu yok.

**Öneri:** Kullanıcının modül, hizmet alan/veren rolü, plan, üyelik durumu, onboarding ve doğrulama seviyesi tek sözleşmeyle yönetilmeli.

## Öncelikli Yol Haritası

### P0 - Güvenli test altyapısı

1. Preflight scripti
2. Cleanup scripti ve `runId`
3. Auth Emulator kullanıcı testi
4. CI içinde seed + validate

### P1 - Ürün ve performans

1. 250 kayıtla pagination integration testi
2. Filtre doğruluk testleri
3. Takvimde 250 rezervasyon senaryosu
4. PatiMatch seyrek/normal/yoğun ağ testleri
5. Firestore read ve index maliyet ölçümü

### P2 - Operasyon ve gözlem

1. Load-test dashboard
2. Hata oranı ve sorgu süresi
3. İşlem durum dağılımı
4. Günlük aktif kullanıcı simülasyonu
5. Geçmiş test koşularıyla karşılaştırma

## Komutlar

```powershell
npm.cmd run load-test:dry
npm.cmd run load-test:staging
npm.cmd run load-test:validate
```

Prod'a load-test seed basılmamalıdır.
