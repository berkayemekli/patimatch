# Load Test Önerileri - Uygulama Durumu

Tarih: 23 Haziran 2026

## 1. Preflight kontrolü - Tamamlandı

`scripts/load_test_preflight.js` eklendi.

Kontroller:

- Prod koruması
- Staging proje adı
- Firebase CLI oturumu
- Proje erişimi
- Firestore API durumu
- Default Firestore database

Son test: `PASS`

## 2. runId, manifest, TTL ve cleanup - Tamamlandı

- Her koşu ayrı `runId` alıyor.
- Tüm dokümanlara `loadTestRunId` ve `expiresAt` ekleniyor.
- `load_test_runs/{runId}` manifesti oluşuyor.
- Cleanup önce dry-run gösteriyor.
- Gerçek silme yalnızca `--execute` ile yapılıyor.
- Cleanup Firestore listesi okumadan deterministik yolları siliyor.

Smoke sonucu: 50/50 doküman temizlendi.

## 3. Tek komut pipeline ve CI - Tamamlandı

`scripts/run_load_test_pipeline.js`:

1. Preflight
2. Seed
3. Validate
4. Opsiyonel cleanup

GitHub Actions `load-test-contract.yml`:

- Node syntax kontrolü
- Dry-run sayaç sözleşmesi
- Flutter analyze
- Flutter test

## 4. Auth Emulator - Tamamlandı

- Gerçek SMS/e-posta göndermeyen Auth Emulator seed scripti eklendi.
- 1.000 kullanıcı oluşturma testi başarılı.
- İlk, orta ve son kullanıcıyla password login doğrulandı.
- 1, 500 ve 1.000 numaralı hesaplarla password login doğrulandı.

## 5. Pagination, filtre ve performans kontratı - Tamamlandı

- 250 kayıt, 20'lik 13 sayfada eksiksiz ve tekrarsız test edildi.
- Şehir, ilçe, tür, cins ve doğrulama filtreleri birlikte test edildi.
- 100 tekrar filtreleme performans bütçesi eklendi.
- Takvim sorgu limiti 50'den 250'ye yükseltildi.

## 6. PatiMatch ağ profilleri - Tamamlandı

- `paired`
- `sparse`
- `normal`
- `dense`

Her profil farklı swipe yoğunluğu üretir; match/chat sayısı ayrıca yönetilir.

## 7. Yerel staging görselleri - Tamamlandı

- Dört staging görsel asset'i eklendi.
- `SmartPetImage` asset veya network kaynağını tek bileşende yönetiyor.
- Load-test seed dış fotoğraf servislerine ihtiyaç duymuyor.

## 8. Merkezi modül üyeliği - Tamamlandı

- `ModuleMembershipRepository` eklendi.
- Rol seçim ekranı `module_memberships` koleksiyonunu senkronluyor.
- Firestore rules kullanıcıların yalnızca kendi üyeliklerini yönetmesine izin veriyor.

Rules kodu hazırdır. 23 Haziran 2026'daki Firebase Rules API bağlantı hatası nedeniyle staging/prod deploy tekrar denenmelidir.

## 9. Gözlem paneli ve aktivite olayları - Tamamlandı

- Modül başına 250 aktivite olayı üretilebiliyor.
- Validator koleksiyon okuma sürelerini kaydediyor.
- `docs/load_test_dashboard.html` sağlık paneli oluşturuldu.

## Kullanım

```powershell
npm.cmd run load-test:preflight
npm.cmd run load-test:pipeline -- --run-id lt_manual_001
npm.cmd run load-test:validate -- --run-id lt_manual_001 --prefix lt_manual_001
npm.cmd run load-test:cleanup -- --run-id lt_manual_001
npm.cmd run load-test:cleanup -- --run-id lt_manual_001 --execute
npm.cmd run auth-test:emulator
npm.cmd run load-test:dashboard
```

Prod'a sahte kullanıcı veya load-test datası basılmaz.
