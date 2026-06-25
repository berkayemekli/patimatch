# PatiParent Global UX Benchmark 2026

Tarih: 26 Haziran 2026  
Baz alınan PatiParent çıktıları:

- `docs/live_ux_walkthrough.html`
- `docs/live_ux_video_player.html`
- Canlı site: https://patiparent.com

Bu rapor PatiParent'in mevcut canlı kullanıcı deneyimini dünyadaki güçlü pet-care, marketplace, rezervasyon, güven ve sosyal eşleşme ürünleriyle karşılaştırır.

## Kıyaslanan 10 Referans

1. Rover - pet sitting, dog walking, boarding.
2. Wag! - hızlı dog walking, GPS takip, report card.
3. TrustedHousesitters - ev/pet emanet modeli, verified/reviewed sitter ağı.
4. Pawshake - insured pet sitter marketplace, günlük güncellemeler.
5. Airbnb - konaklama marketplace, kimlik doğrulama, güven ve ödeme koruması.
6. Booking.com - yoğun filtre, sıralama, availability ve booking UX.
7. Uber - canlı takip, güvenlik merkezi, acil durum ve rota paylaşımı.
8. Taskrabbit - hizmet veren marketplace, hızlı görev seçimi, fiyat/yorum bazlı karar.
9. Thumbtack - profesyonel hizmet matching, availability/instant book, lead kalitesi.
10. Bumble - sosyal eşleşme, güvenli konuşma başlatma, swipe yorgunluğu dersleri.

## Yönetici Özeti

PatiParent'in şu anki güçlü tarafı: ürün vizyonu ve ana modül kurgusu doğru. Kullanıcı siteye giriş yapmadan ana sayfayı, 4 modülü, güven merkezini, filtreleri ve kartları görebiliyor. PatiBnB görsel olarak en olgun modül; PatiMatch artık üyeliksiz preview veriyor; PatiGezdirme detay modalı iyi bir karar ekranı yaratıyor.

En büyük açıklar:

1. Filtre deneyimi henüz Booking/Airbnb seviyesinde değil.
2. Boş sonuçlar kullanıcıya güven vermiyor; aktif filtre/temizle mantığı eksik.
3. Rezervasyon/talep sonrası yaşam döngüsü Wag/Uber kadar görünür değil.
4. Güven Merkezi var ama Rover/Airbnb seviyesinde profil içine gömülü ve aksiyona bağlı değil.
5. PatiFamily duygusal güven ve başvuru kriterleri açısından yeterince ayırt edici değil.
6. PatiMatch preview var ama Bumble gibi net aksiyon döngüsü ve match sonrası hikaye henüz zayıf.

Genel değerlendirme: PatiParent MVP görsel/ürün yönüyle 6.5/10 seviyesinde. Doğru önceliklerle 8/10'a çıkabilecek ana kaldıraçlar: filtre/boş sonuç, güven skoru, rezervasyon yaşam döngüsü, report card ve modül bazlı farklılaşma.

## 1. Açılış ve Keşif

### Referanslardan ders

Airbnb ve Booking.com kullanıcının önce arama/keşif yapmasına izin verir. Booking.com filtreleri fiyat, review score, WiFi, pet-friendly gibi çok pratik ihtiyaçlarla bağlar. Airbnb tarafında kimlik doğrulama kritik ama ürün önce keşfedilebilir kalır. Rover da pet care ihtiyacını hizmet kategorileriyle anlatır: boarding, house sitting, walking gibi.

### PatiParent durumu

Canlı kayıtta ana ekran iyi görünüyor:

- Hero yeterince net.
- 4 modül görünür.
- Login zorunlu değil.
- Kartlar ve filtre ilk sayfada erişilebilir.

### Gap

PatiParent'te arama niyeti henüz yeterince güçlü değil. Kullanıcı “ne arıyorum?” alanından başlamıyor; önce modül seçiyor. Bu güzel ama Armut/Booking tarzı kullanıcı için hızlı problem çözme sorusu eklenebilir.

### Öneri

Hero altında tek satırlık akıllı arama ekle:

- “Bugün neye ihtiyacın var?”
- Placeholder: “Kadıköy'de küçük köpeğim için gezdirici ara”
- Sonrasında modül + lokasyon + tarih + pet profili otomatik doldurulsun.

## 2. Filtre ve Liste Deneyimi

### Referanslardan ders

Booking.com filtreleri listeyle sıkı bağlı kurar ve sonuçların recommendation/sorting mantığı olduğunu açıklar. Airbnb'de kullanıcı filtreleri çok aktif kullanır ama boş sonuç olduğunda alternatifler, tarih/lokasyon genişletme ve harita davranışı önemlidir.

### PatiParent durumu

Canlı kayıtta filtre alanı güçlü:

- İl, ilçe
- Köpek cinsi
- Yaş
- Cinsiyet
- Aşı durumu
- Boyut
- Arama alanı
- Rozet chipleri

### Gap

Kritik problem: “Kimlik doğrulandı” chip'i seçili kalınca sonuç boşalıyor ve kullanıcı site boş sanabilir. Filtre açıkken dropdown kartların üstüne biniyor; kart tıklama davranışı karışıyor.

### Öneri

1. Filtre paneline “Aktif filtreler” satırı ekle.
2. Boş sonuçta tek kart göster:
   - “Bu filtrelerle sonuç yok”
   - “Kimlik doğrulandı filtresini kaldır”
   - “Yakın ilçelerde ara”
   - “Tüm gezdiricileri göster”
3. Filtre seçildikten sonra panel otomatik kompakt moda dönsün.
4. Liste üstünde sonuç sayısı yazsın: “3 gezdirici bulundu”.
5. Harita/konum modunda “yakınımda” ileride eklenmeli.

## 3. Kart ve Detay Profili

### Referanslardan ders

Rover güveni detaylı pet ve sitter profilleriyle kurar: verified reviews, detailed pet profiles, advanced search filters. Pawshake günlük güncelleme, garanti ve ödeme sonrası koruma mesajlarını öne çıkarır. Airbnb'de fotoğraf, review, ev kuralları, iptal politikası ve host bilgisi kararın merkezindedir.

### PatiParent durumu

PatiGezdirme detay modalı iyi:

- Büyük fotoğraf
- Verified badge
- Puan
- Fiyat
- Tarih/saat
- Güven nedeni
- Profil özeti
- Yürüyüş yaklaşımı
- Uzmanlıklar
- Güvenlik checklist'i

### Gap

Detay paneli iyi ama kart üstü karar bilgisi sınırlı. Kullanıcı karta basmadan şu kritik bilgileri göremiyor:

- Son aktiflik
- Tekrar eden müşteri oranı iyi ama daha anlamlı etiketlenmeli
- Mesafe/yakınlık
- Uygun tarih
- Hizmet kapsamı
- İptal/garanti bilgisi

### Öneri

Kart altına mini trust row ekle:

- “312 yürüyüş”
- “%72 tekrar”
- “Bugün uygun”
- “2.4 km”

Detay modalına Rover/Wag tarzı “hizmet sonrası ne alırsın?” bölümü ekle:

- Fotoğraf güncellemesi
- Rota özeti
- Mama/su notu
- Dışkı/çiş bildirimi
- Mini report card

## 4. Rezervasyon ve Yaşam Döngüsü

### Referanslardan ders

Wag! güçlü çünkü yürüyüş anını canlı bir servise dönüştürüyor: GPS tracked walks, in-app messaging, live pee/poop notifications, detailed report card. Uber de canlı konum, trip details, emergency button ve paylaşılabilir yolculuk bilgisiyle servis anını görünür kılar.

### PatiParent durumu

Talep gönderme anında login gate açılıyor. Detay modalında tarih/saat görünüyor. Daha önce service engagement ve hizmet chat altyapısı kuruldu.

### Gap

Canlı deneyimde kullanıcı henüz “talep sonrası ne olacak?”ı yeterince hissedemiyor. Yani talep butonu var ama servis yaşam döngüsü kartta/önizlemede görünmüyor.

### Öneri

Talep butonunun hemen üstüne “sonra ne olur?” mini timeline ekle:

1. Talep gönderilir
2. Gezdirici onaylar
3. Sohbet açılır
4. Yürüyüş takip edilir
5. Report card gelir

Hizmet chat ekranında Wag/Uber esintili servis paneli:

- Planlandı
- Başladı
- Canlı rota
- Foto güncellemesi
- Tamamlandı
- Değerlendir

## 5. Güven Merkezi ve Mavi Tik

### Referanslardan ders

Airbnb primary hosts, co-hosts ve booking guests için identity verification gerektirdiğini söylüyor. Rover, verified reviews ve detailed pet profiles ile güveni dağıtıyor. Wag! tarafında caregiver screening/background check ve 24/7 support güven dili yaratıyor. Uber güvenliği tek butona değil, safety toolkit ve trip paylaşımına yayıyor.

### PatiParent durumu

Güven Merkezi kartı ana sayfada görünüyor:

- Kimlik kontrolü
- Telefon onayı
- Güven rozetleri
- Doğrula CTA

### Gap

Güven Merkezi ana sayfada iyi ama listing ve detay kararına daha fazla gömülmeli. Kullanıcı “bu kişi neden güvenilir?” sorusunu kart/detail içinde cevapsız bırakmamalı.

### Öneri

Profil güven skoru üret:

- Telefon doğrulandı: +15
- E-posta doğrulandı: +10
- Kimlik doğrulandı: +25
- Pet profili tam: +15
- Aşı kartı yüklendi: +15
- 3+ yorum: +10
- Tekrar müşteri: +10

Kartta görünüm:

- “Güven skoru 82/100”
- “Kimlik doğrulandı”
- “Aşı kartı var”
- “3 doğrulanmış yorum”

## 6. Ödeme, İptal ve Garanti

### Referanslardan ders

Pawshake tarafında bookings guarantee, free veterinary coverage, easy cancellation ve sitter'a ödemenin booking tamamlanınca yapılması gibi güven mesajları var. Airbnb'nin platform içi ödeme ve check-in sonrası ödeme mantığı dolandırıcılık riskini azaltır. Thumbtack/Taskrabbit tarafında fiyat ve ödeme beklentisi çok net olmalı; aksi halde kullanıcı ve hizmet veren arasında güven kırılır.

### PatiParent durumu

Şu an fiyatlar görünüyor ama ödeme/garanti/iptal politikası deneyimi görünür değil.

### Gap

Kullanıcı şu sorulara cevap alamıyor:

- Talep gönderince ödeme olacak mı?
- İptal edersem ne olur?
- Pet zarar görürse ne olur?
- Gezdirici gelmezse ne olur?
- PatiParent arada neyi garanti ediyor?

### Öneri

MVP için ödeme almadan bile “güven politikası” alanı koy:

- “Ödeme şu an platform dışında; güvenli ödeme yakında.” veya ödeme aktifse “PatiParent güvencesiyle ödeme.”
- İptal politikası
- Acil destek
- Veteriner yönlendirme
- Anlaşmazlık bildirme

## 7. PatiBnB Karşılaştırması

### Referanslardan ders

Airbnb ve Booking.com'da konaklama listing'leri şu bilgileri çok iyi taşır:

- Fotoğraf kalitesi
- Lokasyon
- Fiyat/gece
- Review score
- Uygunluk
- Ev kuralları
- İptal politikası
- Harita
- Favori/kaydet

### PatiParent durumu

PatiBnB canlı kayıtta en olgun modüllerden biri. Ev görselleri ve host kartları doğru yöne gidiyor.

### Gap

PatiBnB'de henüz güçlü availability/booking hissi yok. Airbnb gibi “tarih seç, müsaitliği gör, ev kurallarını oku, talep et” akışı daha belirgin olmalı.

### Öneri

PatiBnB kartında 5 zorunlu bilgi:

- Ev tipi
- Kabul edilen pet türü
- Başka pet var mı
- Bahçe/balkon
- Uygun ilk tarih

Detayda 5 bölüm:

- Evden fotoğraflar
- Günlük bakım rutini
- Ev kuralları
- Acil durumda veteriner
- İptal/garanti

## 8. PatiMatch Karşılaştırması

### Referanslardan ders

Bumble güvenli sosyal eşleşme dilinde güçlü. Ancak güncel trendler swipe yorgunluğu ve “shopping-style” hissin azalması yönünde. Bumble'ın Opening Moves gibi yönlendirilmiş konuşma başlatıcıları kullanıcı üzerindeki mesaj yükünü azaltıyor.

### PatiParent durumu

PatiMatch artık girişsiz preview gösteriyor. Uyum analizi ve kart preview iyi başlangıç.

### Gap

PatiMatch henüz tam “aksiyon loop” vermiyor:

- Kartı beğen/geç
- Uyum nedeni
- İlk mesaj önerisi
- Güvenli buluşma önerisi
- Match sonrası sohbet

### Öneri

PatiMatch için swipe yerine daha güvenli pet sosyal akışı:

- “Oyun arkadaşı olabilir”
- “Yürüyüş uyumu yüksek”
- “Sakin karakter eşleşmesi”
- “İlk mesaj önerisi: Bu hafta sonu Caddebostan sahilde yürüyüşe uygun musunuz?”

Bumble'dan alınacak ders: kullanıcıyı mesaj yazma yüküyle yalnız bırakma; prompt ver.

## 9. PatiFamily Karşılaştırması

### Referanslardan ders

TrustedHousesitters ve adoption/foster mantığında temel güven unsuru sadece listeleme değil; sorumluluk, beklenti yönetimi ve ön görüşmedir. Ev/pet emanetinde doğru iletişim ve ön görüşme kritik.

### PatiParent durumu

PatiFamily çalışıyor ama canlı kayıtta diğer modüllere göre daha az karakterli hissettiriyor.

### Gap

PatiFamily bir marketplace gibi değil, kontrollü başvuru süreci gibi görünmeli. Şu alanlar daha görünür olmalı:

- Aciliyet seviyesi
- Geçici/kalıcı yuva
- Veteriner/aşı durumu
- Karakter ve hassasiyetler
- Aile uygunluk kriterleri
- Takip görüşmesi

### Öneri

PatiFamily kartlarında CTA “Başvur” değil:

- “Uyum sürecini başlat”
- “Ön görüşme talep et”
- “Geçici yuva olabilirim”

Detayda mini başvuru checklist'i:

- Evde başka pet var mı?
- Gün içinde yalnız kalma süresi
- Daha önce pet deneyimi
- Veteriner takibi kabulü
- 2 hafta sonra takip görüşmesi kabulü

## 10. Hizmet Veren Deneyimi

### Referanslardan ders

Taskrabbit ve Thumbtack'te hizmet veren tarafı da üründür. Provider için şu kritikler vardır:

- Uygunluk takvimi
- Talep kalitesi
- Mesajlaşma
- Ödeme beklentisi
- Review kazanma
- Profil tamamlama

Thumbtack'in lead ücretleriyle ilgili eleştiriler şunu gösterir: hizmet veren tarafı kötü hissederse marketplace likiditesi düşer.

### PatiParent durumu

Hizmet veren deneyiminin temeli var: Taleplerim, kabul, hizmet sohbeti, takvim.

### Gap

Canlı UX kaydı daha çok hizmet alan tarafını gösterdi. Hizmet veren için ayrıca canlı kayıt yapılmalı.

### Öneri

Provider dashboard MVP:

- Bugünkü talepler
- Bekleyen talepler
- Kabul oranı
- Ortalama cevap süresi
- Profil güven skoru
- Uygunluk takvimi
- Kazanç/rezervasyon geçmişi

## Skor Kartı

| Alan | PatiParent Bugün | Dünya standardı | Skor | Öncelik |
|---|---:|---:|---:|---|
| Login'siz keşif | Var | Var | 8/10 | Koru |
| Modül ayrışması | Orta-iyi | Çok net | 7/10 | Orta |
| Filtre UX | Güçlü ama pürüzlü | Sonuç odaklı | 5/10 | Çok yüksek |
| Boş sonuç yönetimi | Zayıf | Alternatif önerir | 3/10 | Çok yüksek |
| Kart tasarımı | İyi | Çok güven yoğun | 7/10 | Orta |
| Detay modalı | İyi | Karar destekli | 8/10 | Koru/geliştir |
| Rezervasyon akışı | Temel var | Uçtan uca | 5/10 | Çok yüksek |
| Servis takip/report card | Başlangıç | Wag/Uber seviyesi | 3/10 | Çok yüksek |
| Güven merkezi | Var | Profil içine gömülü | 6/10 | Yüksek |
| PatiMatch sosyal loop | Preview var | Etkileşim döngüsü net | 5/10 | Yüksek |
| PatiBnB konaklama hissi | İyi | Airbnb/Booking seviyesi | 7/10 | Orta |
| PatiFamily başvuru hissi | Zayıf-orta | Kontrollü süreç | 5/10 | Yüksek |

## En Kritik 10 Ürün Kararı

1. Filtre boş sonucuna “filtreleri temizle / yakın ilçelerde ara / tümünü göster” getir.
2. Filtre paneli seçim sonrası kompakt moda dönsün.
3. Her kartta trust mini row göster.
4. Her detay modalında “sonra ne olur?” timeline'ı göster.
5. Talep sonrası login bağlamını koru: login bitince aynı talep modalına dön.
6. Wag tarzı hizmet report card tasarla.
7. PatiBnB için ev kuralları + uygunluk + iptal politikası görünür olsun.
8. PatiFamily için başvuru checklist'i ve takip görüşmesi ekle.
9. PatiMatch için prompt/ilk mesaj önerileri ekle.
10. Hizmet veren dashboard'u ayrı UX kaydıyla test et.

## 30 Günlük Yol Haritası

### Hafta 1 - Filtre ve boş sonuç

- Aktif filtre chipleri
- Filtreleri temizle CTA
- Sonuç sayısı
- Panel kompakt modu

### Hafta 2 - Detay ve talep dönüşümü

- Sonra ne olur timeline
- Login sonrası talep bağlamı
- Report card tasarım iskeleti
- Takvim görünürlüğü

### Hafta 3 - Güven katmanı

- Profil güven skoru
- Mavi tik açıklaması
- Aşı kartı / telefon / kimlik rozetleri
- Güvenli ödeme/iptal metinleri

### Hafta 4 - Modül ayrışması

- PatiBnB ev kuralları ve availability
- PatiFamily başvuru checklist'i
- PatiMatch prompt + match sonrası akış
- Hizmet veren dashboard ilk versiyon

## Kaynaklar

- Rover ana ürün sayfası: https://www.rover.com/
- Rover Trust & Safety: https://www.rover.com/blog/safety/
- Wag App Store/Google Play açıklamaları: GPS tracked walks, in-app messaging, report card, background check.
- Wag Service Report Card help: https://support.wagwalking.com/en_us/service-report-card-S1rkYA7A
- TrustedHousesitters ana sayfası: https://www.trustedhousesitters.com/
- Pawshake how it works: https://support.pawshake.com/hc/en-gb/articles/115002038303-How-does-Pawshake-work
- Pawshake Google Play: guarantee, daily updates, veterinary coverage.
- Airbnb identity verification: https://www.airbnb.com/help/article/1237
- Airbnb trust commitment: https://news.airbnb.com/building-on-our-commitment-to-trust-2/
- Booking.com how ranking/filter works: https://www.booking.com/content/how_we_work.html
- Booking.com app store/google play filter descriptions.
- Uber safety features: https://www.uber.com/us/en/ride/safety/
- Taskrabbit marketplace home: https://www.taskrabbit.com/
- Taskrabbit reviews support: https://support.taskrabbit.com/hc/en-us/articles/46260428700059-How-Do-I-Leave-a-Review
- Thumbtack Instant Book: https://press.thumbtack.com/announcements/thumbtack-launches-instant-book-to-make-hiring-pros-even-easier/
- Thumbtack pro matching: https://www.thumbtack.com/pro
- Bumble App Store and Bumble first move guidance: https://apps.apple.com/us/app/bumble-dating-app-meet-date/id930441707 and https://bumble.com/en-us/the-buzz/bumble-make-the-first-move
- Apple Human Interface Guidelines: https://developer.apple.com/design/human-interface-guidelines
