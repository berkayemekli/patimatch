# PatiParent Unicorn Product Strategy

Tarih: 26 Haziran 2026

Amaç: PatiParent'i sadece pet hizmet marketplace'i değil, AI-native pet parenting operating system haline getirmek.

## Kısa Tez

PatiParent'in unicorn olma ihtimali, 4 ayrı modül yapmasından değil; pet ebeveynliğinin en stresli kararlarını tek güven katmanında birleştirmesinden gelir.

Bugünkü ürün şu dört ihtiyacı topluyor:

- PatiGezdirme: günlük operasyon.
- PatiBnB: seyahat ve emanet güveni.
- PatiMatch: sosyal/çiftleşme/uyum keşfi.
- PatiFamily: sahiplendirme ve aile olma.

Unicorn farkı için bunların üstünde şu katman kurulmalı:

> Pet Passport + Trust Graph + AI Care Copilot + Service OS + Local Pet Network

Bu, PatiParent'i “Rover'ın Türkiye versiyonu” olmaktan çıkarıp “pet ebeveynliği için güvenli işletim sistemi” yapar.

## Pazar Mantığı

2026 itibarıyla büyüyen alanlar:

- Pet services pazarı büyüyor; premium bakım, grooming, vet, insurance ve dijital rezervasyon talebi artıyor.
- Pet sitting ve dog walking pazarı abonelik ve güvenli marketplace yapısına kayıyor.
- Veterinary telehealth hızlı büyüyen bir kategori.
- Pet insurance ve vet cost inflation kullanıcı için ciddi pain point.
- Smart collar / wearable tarafı sağlık, konum ve davranış verisini büyütüyor.
- AI pet health ve belge okuma, bakım önerisi, davranış analizi gibi alanlarda ürünleşiyor.

Sonuç: Kullanıcının sorunu “gezdirici bulmak” değil. Asıl sorun: “Canımı emanet ettiğim canlı için güvenilir kararları hızlı ve sakin verebilmek.”

## North Star

PatiParent North Star Metric:

**Güvenle tamamlanan pet bakım günü**

Bu metrik şu olaylardan oluşur:

- Pet profili tamamlandı.
- Güvenli hizmet verenle eşleşti.
- Tarihli talep oluşturuldu.
- Hizmet kabul edildi.
- Hizmet güvenli tamamlandı.
- Report card geldi.
- Kullanıcı tekrar hizmet aldı veya tavsiye etti.

Neden iyi metrik?

- Sadece trafik değil gerçek değer ölçer.
- Her modülü kapsar.
- Güven, tekrar kullanım ve operasyon kalitesini bağlar.
- Gelire giden yolu gösterir.

## Fark Yaratacak 12 Büyük Ürün Bahsi

### 1. Pet Passport

Her pet için tek dijital profil:

- Tür, cins, yaş, kilo, cinsiyet.
- Aşı takvimi.
- Alerji, hastalık, ilaç.
- Karakter: enerjik, sakin, sosyal, çekingen.
- Davranış riskleri: tasma çeker, kedilerle anlaşır/anlaşmaz, çocuklarla durumu.
- Beslenme rutini.
- Veteriner bilgisi.
- Acil kişi.
- Pasaport/aşı kartı görselleri.

Neden unicorn potansiyeli?

Pet Passport her modülün ortak veri çekirdeği olur. Kullanıcı bir kere doldurur; gezdirici, host, veteriner, kuaför, sahiplendirme ve match hepsi bundan beslenir.

MVP:

- Pet profili tamamlanma skoru.
- Aşı kartı upload alanı.
- Bakım notları.
- Hizmet verenle paylaşılabilir özet.

### 2. Trust Graph

Kişi, pet, hizmet veren, veteriner, kuaför ve mekanlar arasında güven ağı.

Sinyaller:

- Telefon doğrulama.
- E-posta doğrulama.
- Kimlik doğrulama.
- Aşı belgesi.
- Geçmiş tamamlanan hizmetler.
- Tekrar eden müşteri.
- Hizmet sonrası report card.
- Karşılıklı değerlendirme.
- Referans.
- Şüpheli davranış / iptal / no-show.

Çıktı:

- Güven skoru.
- Mavi tik.
- Hizmet veren kalite seviyesi.
- Kullanıcı risk seviyesi.
- Sahiplendirme başvuru kalitesi.

MVP:

- `trust_score` modeli.
- Kartlarda güven skoru.
- Detayda “neden güvenilir?” açıklaması.

### 3. AI Care Copilot

Kullanıcının yanında sakin, pratik, güvenilir AI asistan.

Kullanım alanları:

- “Köpeğim 8 saat yalnız kalabilir mi?”
- “Yarın 18:00 için Kadıköy'de yürüyüş planla.”
- “Bu host benim kedime uygun mu?”
- “Aşı kartımdan eksikleri çıkar.”
- “Bu davranış normal mi, veterinere gitmeli miyim?”
- “Sahiplendirme başvurum güçlü mü?”

MVP:

- Pet profilinden bakım önerisi.
- Aşı takvimi açıklaması.
- Hizmet seçimi rehberi.
- Detay modalında “Bu profil petine uygun mu?” AI insight.

Risk notu:

Veteriner teşhisi vermemeli; sadece bilgilendirme ve vet yönlendirme yapmalı.

### 4. Service OS

Hizmetin yaşam döngüsünü uçtan uca takip eden operasyon katmanı.

Aşamalar:

- Talep gönderildi.
- Hizmet veren onayladı.
- Sohbet açıldı.
- Planlandı.
- Başladı.
- Canlı takip.
- Tamamlandı.
- Report card.
- Değerlendirme.
- Tekrar rezervasyon.

MVP:

- Detay modalında “sonra ne olur?” timeline.
- Chat içinde aşama çubuğu.
- Tamamlandı sonrası report card formu.

### 5. Wag-Style Report Card

Her hizmetin sonunda kullanıcıya güven veren çıktı.

PatiGezdirme:

- Başlangıç/bitiş saati.
- Rota veya yaklaşık lokasyon.
- Fotoğraf.
- Su/mama notu.
- Çiş/dışkı notu.
- Enerji seviyesi.
- Davranış notu.

PatiBnB:

- Günlük fotoğraf.
- Beslenme.
- Uyku.
- Tuvalet.
- Sosyal durum.
- Host notu.

PatiFamily:

- Görüşme notu.
- Uyum değerlendirmesi.
- Takip adımı.

MVP:

- Manuel report card formu.
- Chat'e otomatik özet mesajı.
- Kullanıcıya tekrar rezervasyon CTA.

### 6. PatiCare / Yakınımda Network

Veteriner, pet kuaför, köpek eğitmeni, pet dostu restoran/otel/mekan.

Bu bir beşinci ana modül gibi değil; destek katmanı olmalı.

Konumlandırma:

- Ana modüllerin içinde bağlamsal öneri.
- PatiBnB detayında “yakındaki veteriner”.
- PatiGezdirme sonrası “yakındaki pet kuaför”.
- PatiFamily'de “sahiplendirme sonrası veteriner kontrolü”.
- Pet Passport içinde kayıtlı veteriner.

MVP:

- Yakınımda sayfası.
- Harita/list view.
- Kategori filtresi: vet, kuaför, eğitmen, pet dostu mekan.
- “Doğrulanmamış kaynak” etiketi.

### 7. Subscription / PatiParent Plus

Gelir modeli sadece komisyon olursa marketplace büyümesi yavaş olabilir. Abonelikle güven ve tekrar kullanım artar.

PatiParent Plus:

- Öncelikli destek.
- Aylık bakım planı.
- AI Care Copilot gelişmiş kullanım.
- Aşı/ilaç hatırlatıcıları.
- Vet telehealth indirimleri.
- Kuaför/gezdirme paket avantajları.
- Güvenli emanet garantisi.

MVP:

- Free / Plus plan UI mock.
- Gerçek ödeme sonraya.

### 8. Insurance / Vet Cost Protection Partner Layer

Petflation önemli pain point. Kullanıcı veteriner masrafından korkuyor.

PatiParent direkt sigorta şirketi olmak zorunda değil; partner/lead layer olabilir.

Özellikler:

- Pet sigortası bilgilendirme.
- Teklif al yönlendirmesi.
- Aşı/vet geçmişinden risk özeti.
- Acil durum fonu veya bakım paketi.

MVP:

- “Yakında: PatiParent güvence” landing bölümü.
- Partner readiness data modeli.

### 9. Provider Academy

Hizmet veren kalitesini ölçeklemek için eğitim şart.

İçerik:

- Güvenli yürüyüş.
- İlk yardım temel bilgisi.
- Kedi/köpek davranışı.
- Evde konaklama standartları.
- Fotoğraf ve report card standardı.
- Acil durumda ne yapılır.

MVP:

- Hizmet veren profilinde “PatiParent Academy tamamlandı” rozeti.
- 5 soruluk safety quiz.

### 10. Local Liquidity Engine

Marketplace'in en büyük riski arz-talep dengesidir.

MVP şehir stratejisi:

- Önce İstanbul/Kadıköy-Beşiktaş-Şişli-Ataşehir.
- Sonra İzmit, İzmir, Ankara.
- Her ilçede minimum likidite hedefi:
  - 20 gezdirici
  - 10 host
  - 5 kuaför/vet partner
  - 50 pet owner

Ürün içinde:

- Boş sonuçta “talep bırak” formu.
- Provider bekleme listesi.
- İlçe bazlı supply gap dashboard.

### 11. AI Matching Engine

PatiMatch ve servis seçiminde sadece filtre değil, uygunluk skoru.

Sinyaller:

- Pet enerji seviyesi.
- Cins/yaş/boyut.
- Lokasyon.
- Hizmet veren geçmişi.
- Ev koşulları.
- Kullanıcı tercihleri.
- Risk sinyalleri.

Çıktı:

- “%94 uyum”
- “Neden önerildi?”
- “Dikkat edilmesi gerekenler”

MVP:

- Rule-based scoring.
- Sonra ML/AI.

### 12. Family & Adoption Trust Flow

PatiFamily farklılaşmanın en duygusal alanı olabilir.

Akış:

- Pet ilanı.
- Başvuru formu.
- Uygunluk skoru.
- Ön görüşme.
- Deneme süreci.
- Takip görüşmesi.
- Veteriner kontrolü.

MVP:

- Başvuru checklist.
- “Ön görüşme talep et” CTA.
- Başvuru kalite skoru.

## PatiParent'in Rakiplere Karşı Net Farkı

### Rover/Wag'e karşı

Onlar hizmet marketplace'i. Biz pet ebeveynliği işletim sistemi olabiliriz.

Fark:

- Pet Passport.
- Aşı/vet/kuaför/eğitmen/mekan network.
- PatiFamily ve PatiMatch ile yaşam döngüsü.
- Türkiye yerel güven katmanı.

### Airbnb/Booking'e karşı

Onlar konaklama uzmanı. Biz pet bağlamına özel güven ve bakım uzmanı olabiliriz.

Fark:

- Pet özel ev kuralları.
- Pet karakter uyumu.
- Veteriner/acil durum bağlamı.
- Report card.

### Bumble'a karşı

Bumble insan sosyal eşleşmesi. Biz pet sosyal uyumu ve güvenli buluşma akışı olabiliriz.

Fark:

- Pet karakter skoru.
- Güvenli rota/mekan önerisi.
- Aşı/profil doğrulama.
- Sahip güven skoru.

### Armut/Taskrabbit'e karşı

Onlar yatay hizmet pazarı. Biz tek vertikalde güven ve veri derinliği kurarız.

Fark:

- Pet-specific forms.
- Pet-specific trust.
- Pet-specific report card.
- Pet-specific care history.

## İlk 90 Günlük Uygulama Planı

### Faz 1 - Trust & Conversion Foundation (0-30 gün)

Hedef: Kullanıcının dolandırılma/fishing hissi yaşamasını tamamen bitirmek.

Yapılacaklar:

1. Filtre boş sonuç UX.
2. Aktif filtre chipleri ve filtre temizleme.
3. Kartlarda trust mini row.
4. Detay modalında “sonra ne olur?” timeline.
5. Login sonrası talep bağlamına dönüş.
6. Profil güven skoru.
7. Pet Passport v1.
8. Report card v1 tasarım.

Başarı metriği:

- Kart detaya tıklama oranı.
- Detaydan talep başlatma oranı.
- Boş sonuçtan geri kazanım oranı.

### Faz 2 - Service OS & Provider Quality (30-60 gün)

Hedef: Hizmet alan ve veren arasında gerçek operasyon akışı kurmak.

Yapılacaklar:

1. Hizmet veren dashboard.
2. Taleplerim ekranını güçlendirme.
3. Chat içinde hizmet aşamaları.
4. Tamamlandı sonrası report card.
5. Provider academy quiz.
6. Takvim/availability iyileştirme.
7. PatiBnB ev kuralları ve availability.
8. PatiFamily başvuru checklist.

Başarı metriği:

- Talep kabul oranı.
- Talep -> chat dönüşümü.
- Chat -> planlandı dönüşümü.
- Tamamlanan hizmet sayısı.

### Faz 3 - AI & Network Effects (60-90 gün)

Hedef: Ürünü basit marketplace'ten AI-native platforma çıkarmak.

Yapılacaklar:

1. AI Care Copilot v1.
2. AI matching açıklamaları.
3. PatiCare Yakınımda.
4. Vet/kuaför/eğitmen/mekan data enrichment.
5. Abonelik mock + pricing experiment.
6. Supply gap dashboard.
7. Referral/invite sistemi.
8. Review + trust graph analytics.

Başarı metriği:

- Haftalık aktif pet profili.
- Tekrar hizmet alma oranı.
- Report card tamamlama oranı.
- AI önerisinden talebe dönüşüm.

## İlk Yapılacak 10 Somut Ürün Geliştirmesi

1. `Pet Passport v1` ekranı: pet profili + aşı + bakım notları + paylaşılabilir özet.
2. `Trust Score v1`: kullanıcı/hizmet veren güven puanı ve rozetleri.
3. `No Results Rescue`: boş filtre sonucunda akıllı alternatifler.
4. `What Happens Next`: detay modalında hizmet timeline'ı.
5. `Report Card v1`: tamamlanan hizmet sonrası özet.
6. `Provider Dashboard v1`: hizmet veren için talepler, takvim, cevap süresi.
7. `PatiCare Nearby v1`: veteriner/kuaför/eğitmen/mekan keşfi.
8. `PatiBnB Rules & Availability`: ev kuralları, uygunluk, pet kabul şartları.
9. `PatiFamily Application Flow`: başvuru checklist ve takip görüşmesi.
10. `AI Match Explanation`: “neden bu kişi/host/pet önerildi?” açıklaması.

## İlk Teknik Taslaklar

### Koleksiyonlar

- `pets/{petId}`
- `pet_passports/{petId}` veya pets içinde nested data
- `trust_scores/{userId}`
- `service_report_cards/{reportId}`
- `provider_academy_progress/{userId}`
- `care_places/{placeId}`
- `ai_recommendations/{recommendationId}`
- `availability_slots/{slotId}`

### Event Tracking

- `home_viewed`
- `module_selected`
- `filter_opened`
- `filter_changed`
- `no_results_shown`
- `no_results_rescued`
- `card_opened`
- `request_started`
- `login_gate_shown`
- `login_completed`
- `request_submitted`
- `request_accepted`
- `service_started`
- `report_card_submitted`
- `review_submitted`

### Analytics Dashboard

- Funnel: home -> module -> card -> request -> accepted -> completed.
- Module liquidity: city/district supply-demand ratio.
- Trust: verification completion by role.
- Quality: report card scores by provider.
- AI: recommendation acceptance rate.

## Konumlandırma Cümlesi

Kısa:

> PatiParent, evcil dostun için güvenli bakım, konaklama, eşleşme ve aile olma süreçlerini tek akıllı güven katmanında birleştiren AI-native pet parenting platformudur.

Daha duygusal:

> Evcil dostunu emanet ederken içinin rahat etmesini sağlayan, güveni, bakımı ve doğru insanları tek yerde buluşturan yeni nesil pet ebeveynliği ekosistemi.

Yatırımcı cümlesi:

> PatiParent is building the trust and care operating system for pet parents, combining verified services, pet identity data, AI-assisted care decisions, and local pet networks in one vertical marketplace.

## Riskler ve Cevaplar

### Risk 1: Marketplace likiditesi

Cevap: İlçe bazlı başla, supply gap dashboard kur, provider academy ile arz kalitesini artır.

### Risk 2: Güven olayları

Cevap: Kimlik doğrulama, report card, güven skoru, platform içi chat, dispute flow, acil destek.

### Risk 3: Çok modül karmaşası

Cevap: Kullanıcıya modül değil ihtiyaç sor: “Bugün neye ihtiyacın var?” AI intent routing.

### Risk 4: Gelir modeli geç kalır

Cevap: Komisyon + abonelik + partner lead + provider premium + insurance affiliate.

### Risk 5: AI yanlış yönlendirir

Cevap: AI sadece öneri ve açıklama verir; sağlıkta veteriner yönlendirme ve disclaimer.

## Kaynak Temelli Pazar Sinyalleri

- Global pet tech pazarı 2026'da yaklaşık 19.1B USD seviyesinden 2035'te 52.9B USD seviyesine çıkabilir; yıllık yaklaşık %12 büyüme beklentisi var.
- Pet sitting pazarı 2024'te yaklaşık 2.7B USD iken 2030'da 5.1B USD seviyesine yaklaşabilir; büyüme pet humanization ve abonelik hizmetleriyle destekleniyor.
- Veterinary telehealth 2026-2033 döneminde yüksek büyüme beklentisine sahip; uzaktan danışmanlık ve dijital sağlık platformları yükseliyor.
- Pet insurance pazarı veteriner maliyetleri ve pet humanization sebebiyle büyüyor.
- Smart collar/wearable pazarı gerçek zamanlı sağlık, konum ve davranış verisiyle PatiParent'in gelecekte bağlanabileceği veri katmanı yaratıyor.

## Sonuç

PatiParent'in unicorn yolu “daha fazla sekme” değil, “daha fazla güven ve veri”dir.

Öncelik sırası:

1. Güven.
2. Tekrarlanabilir hizmet akışı.
3. Pet Passport veri çekirdeği.
4. AI destekli karar verme.
5. Yerel pet bakım network'ü.
6. Abonelik ve güvence katmanı.

Buna göre bir sonraki ürün sprinti için en doğru başlangıç:

**Pet Passport + Trust Score + No Results Rescue + What Happens Next + Report Card v1**
