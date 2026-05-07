# Dog Date MVP - Smoke Checklist

## 1) Auth ve Acilis
- [ ] Uygulama acilisinda giris yapilmamissa Login sayfasi gorunuyor.
- [ ] OTP ile giris basarili oldugunda dogru ekrana yonleniyor.
- [ ] Girisli kullanici uygulamayi yeniden acinca Login'e dusmuyor.

## 2) Profil
- [ ] Yeni kullanici kopek profili olusturabiliyor.
- [ ] Mevcut kullanici profil sayfasinda verileri dolu goruyor.
- [ ] Fotograf degistirme ve profil guncelleme calisiyor.

## 3) Discover / Swipe
- [ ] Kartlar listeleniyor, saga swipe = Begen, sola swipe = Gec.
- [ ] Butonlar (`Begen`, `Gec`) jestle ayni sonucu veriyor.
- [ ] `Undo` son swipe'i geri aliyor.
- [ ] Sehir filtresi (`Tum Sehirler` / `Benim Sehir`) calisiyor.
- [ ] `Verified only` filtresi calisiyor.
- [ ] Filtreler app restart sonrasi korunuyor.

## 4) Match ve Chat
- [ ] Karsilikli begenide `matches` ve `chats` dokumani olusuyor.
- [ ] Matches listesinde sohbete giris yapiliyor.
- [ ] Mesaj gonderme/alma canli calisiyor.
- [ ] Mesaj saatleri gorunuyor.
- [ ] Uzun bas: Kopyala / Raporla / (kendi mesajiysa) Sil calisiyor.
- [ ] Soft delete sonrasi mesaj metni placeholder'a donuyor.

## 5) Block / Report
- [ ] Discover'dan kullanici engellenebiliyor.
- [ ] Chat icinden kullanici engellenebiliyor.
- [ ] Engellenen kullanicilar Discover/Matches'te gorunmuyor.
- [ ] Engellenenler ekranindan engel kaldirilabiliyor.
- [ ] Rapor kaydi `reports` koleksiyonuna dusuyor.

## 6) Guvenlik ve Backend
- [ ] `firestore.rules` deploy edildi.
- [ ] `firestore.indexes.json` deploy edildi.
- [ ] `matches` ve `discover` sorgulari index hatasi vermiyor.
