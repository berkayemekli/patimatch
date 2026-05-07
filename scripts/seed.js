/* eslint-disable no-console */
const admin = require("firebase-admin");

if (!process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  console.error("GOOGLE_APPLICATION_CREDENTIALS env var is required.");
  process.exit(1);
}

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
});

const db = admin.firestore();

function requireMinText(value, min, label) {
  const text = (value || "").trim();
  if (text.length < min) {
    throw new Error(`${label} must be at least ${min} chars.`);
  }
}

function validateWalker(w) {
  requireMinText(w.bio, 120, `walker:${w.id}.bio`);
}

function validateHost(h) {
  requireMinText(h.bio, 120, `bnb_host:${h.id}.bio`);
}

function validateAdoptionPost(p) {
  requireMinText(p.bio, 120, `adoption_post:${p.id}.bio`);
  requireMinText(p.ownerNote, 80, `adoption_post:${p.id}.ownerNote`);
}

async function run() {
  const now = admin.firestore.FieldValue.serverTimestamp();

  const users = [
    {
      userId: "demoUserA",
      phone: "+905000000001",
      displayName: "Ayse",
      city: "Istanbul",
      district: "Kadikoy",
      experienceLevel: "experienced",
      isBlocked: false,
      blockedReason: null,
      consentKvkk: true,
      consentTerms: true,
      createdAt: now,
      updatedAt: now,
      lastActiveAt: now,
    },
    {
      userId: "demoUserB",
      phone: "+905000000002",
      displayName: "Mert",
      city: "Istanbul",
      district: "Besiktas",
      experienceLevel: "intermediate",
      isBlocked: false,
      blockedReason: null,
      consentKvkk: true,
      consentTerms: true,
      createdAt: now,
      updatedAt: now,
      lastActiveAt: now,
    },
  ];

  const dogs = [
    {
      dogId: "dogA",
      ownerId: "demoUserA",
      name: "Luna",
      breed: "Golden Retriever",
      ageMonths: 30,
      weightKg: 26,
      sex: "female",
      temperamentTags: ["friendly", "social"],
      bio: "Enerjik ve oyuncu.",
      photoUrls: [],
      city: "Istanbul",
      location: { lat: 41.0082, lng: 28.9784 },
      isProfileComplete: true,
      verificationStatus: "verified",
      createdAt: now,
      updatedAt: now,
    },
    {
      dogId: "dogB",
      ownerId: "demoUserB",
      name: "Milo",
      breed: "Golden Retriever",
      ageMonths: 36,
      weightKg: 30,
      sex: "male",
      temperamentTags: ["calm", "friendly"],
      bio: "Sakin ve uyumlu.",
      photoUrls: [],
      city: "Istanbul",
      location: { lat: 41.043, lng: 29.0094 },
      isProfileComplete: true,
      verificationStatus: "verified",
      createdAt: now,
      updatedAt: now,
    },
  ];

  const walkers = [
    ["walker_01", "Ece A.", "Istanbul", 4.9, 312, 290, true, true, "Veteriner teknikeri olarak calisiyorum ve gunde en fazla dort kopekle birebir ilgileniyorum. Enerjik kopekler icin tempo ayari yapiyor, sakin karakterlerde ise guven odakli yavas adaptasyon uyguluyorum."],
    ["walker_02", "Mert K.", "Istanbul", 4.8, 188, 250, false, true, "Aksam saatlerinde duzenli yuruyus hizmeti veriyorum. Rota planini kopegin yasina, hava durumuna ve enerji seviyesine gore ayarliyorum. Sure sonunda kisa aktivite raporu iletiyorum."],
    ["walker_03", "Sena D.", "Ankara", 4.7, 140, 220, true, false, "Kucuk ve orta irk kopeklerle uzun suredir calisiyorum. Ilk bulusmada bag kurmaya odaklanip sonraki seanslarda ritmik yuruyus ve odak egzersizi uyguluyorum. Tasma cekme problemlerinde destek sagliyorum."],
    ["walker_04", "Yigit T.", "Izmir", 5.0, 92, 320, true, true, "Sahil hattinda planli yuruyus yaptiriyorum ve ozellikle aktif irklarda dogru tempo kuruyorum. Isi stresi yuksek sahipler icin haftalik zamanlama cizelgesi olusturarak duzenli takip sunuyorum."],
    ["walker_05", "Burcu N.", "Bursa", 4.8, 121, 240, false, false, "Calisma modelim guven ve devamli rutine dayanir. Kopegin aliskanliklarini once kayda alip yuruyus suresince ayni ritmi korurum. Ozellikle yavru kopeklerin dis ortam adaptasyonunu nazikce yonetirim."],
    ["walker_06", "Caner O.", "Istanbul", 4.6, 98, 210, true, false, "Trafik yogun bolgelerde sessiz ve guvenli park rotalari kullaniyorum. Yuruyus sonrasi su tuketimi, dinlenme suresi ve genel ruh haliyle ilgili standart bir ozet paylasiyorum."],
    ["walker_07", "Derya P.", "Ankara", 4.9, 167, 270, true, true, "Kopek davranis gozlemi egitimi aldim. Endiseli karakterlerde sabit rota ve net komutlarla ilerliyorum. Sosyallesme ihtiyaci olan kopekler icin kontrollu kisa tanisma seanslari planliyorum."],
    ["walker_08", "Kaan R.", "Izmir", 4.7, 133, 260, false, false, "Duzenli haftalik paketlerle hizmet veriyorum. Is sahibi ailelerin programina uygun saat bloklari aciyorum ve her seans sonunda aktivite, mola ve davranis notlarini tek ekranda paylasiyorum."],
    ["walker_09", "Melis S.", "Bursa", 4.9, 156, 280, true, true, "Yuruyuslerde fiziksel aktivite kadar zihinsel uyarimi da onemsiyorum. Koku takip, bekle-komutu ve dikkat calismalariyla yorucu ama dengeli bir program uygularim. Acil durum kitim her zaman yanimda olur."],
    ["walker_10", "Onur E.", "Istanbul", 4.8, 175, 300, true, true, "Yuksek enerjili buyuk irklarda kontrollu tempo kurmak uzmani oldugum alan. Seans once hedef belirleyip sonrasinda sonuc odakli ozet geciyorum. Guvenli tasma kullanimi konusunda titizim."],
  ].map((w) => ({
    id: w[0], name: w[1], city: w[2], rating: w[3], walkCount: w[4], pricePerHour: w[5],
    instantBooking: w[6], featured: w[7], bio: w[8], status: "active", createdAt: now, updatedAt: now,
  }));

  const bnbHosts = [
    ["host_01", "Can B.", "Istanbul", 4.9, 850, true, true, true, "Bahceli mustakil evde az sayida kopek kabul ederek sakin bir konaklama sunuyorum. Beslenme saatleri, yuruyus suresi ve ilac takibi gunluk olarak kayda alinir. Gece kamera gozetimiyle guvenlik saglanir."],
    ["host_02", "Aylin S.", "Ankara", 4.8, 620, true, false, false, "Apartman dairesinde tekli konaklama modeli uyguluyorum. Kaygiya yatkin kopekler icin dusuk uyaranli bir ortam sunarim. Sahiplerle her gun foto ve kisa rapor paylasarak sureci seffaf yuruturum."],
    ["host_03", "Kerem T.", "Izmir", 4.6, 540, false, true, false, "Uzun yuruyus odakli bir rutinim var ve aktif kopekleri gun icinde iki ana seansla desteklerim. Sosyallesme ihtiyacina gore kontrollu temas planlarim. Beslenme hassasiyetlerini birebir uygularim."],
    ["host_04", "Nisa Y.", "Bursa", 5.0, 780, true, true, true, "Veteriner referansli premium konaklama hizmeti veriyorum. Ilac ve ozel diyet takibi protokole baglidir. Sahiplerin talep etmesi halinde gunluk davranis ve enerji durumu raporu paylasirim."],
    ["host_05", "Pelin K.", "Istanbul", 4.7, 700, true, false, false, "Sakin mizaçli kopekler icin huzurlu bir ev ortami sagliyorum. Konaklama boyunca ayni oyun rutini korunur. Uyum surecinde ilk gun daha kisa seanslarla ilerleyip ikinci gunden itibaren normal duzene gecerim."],
    ["host_06", "Selim D.", "Ankara", 4.8, 640, true, true, true, "Bahceli evimde ayni anda en fazla iki kopek agirlarim. Guvenli ayrik alanlar ile stres yonetimi saglanir. Her kopegin bireysel ihtiyacina gore hareket plani olusturup sahip ile onceden netlestiririm."],
    ["host_07", "Tuna M.", "Izmir", 4.7, 690, false, true, false, "Konaklamayi yalnizca on gorusme tamamlanan kopekler icin aciyorum. Boylece karakter uyumunu bastan dogru kuruyoruz. Kisa sureli deneme seansiyle baslayip uzun rezervasyona gecis yapiyorum."],
    ["host_08", "Zeynep I.", "Bursa", 4.9, 760, true, false, true, "Ev ortami konforunu korurken disiplinli bir gunluk plan uygularim. Beslenme saatleri sabittir, yuruyusler hava durumuna gore optimize edilir. Geceleri ayri dinlenme bolmesiyle guvenli ortam saglanir."],
    ["host_09", "Asli C.", "Istanbul", 4.8, 820, true, true, true, "Uzun tatillerde duzenli ruh hali takibi yapiyorum. Kopegin oyun, dinlenme ve beslenme dengesi kayit altinda tutulur. Sahiplerle acik iletisim kurarak ani degisimlerde hizli aksiyon aliyorum."],
    ["host_10", "Baris G.", "Ankara", 4.7, 610, false, false, false, "Daha cok haftasonu emanet taleplerine odaklanirim. Kisa sureli konaklamada adaptasyon asamasini dikkatli yonetirim. Ev icerisi kurallarini net uygulayip sakin bir rutin olustururum."],
  ].map((h) => ({
    id: h[0], name: h[1], city: h[2], rating: h[3], nightlyPrice: h[4], verified: h[5], yard: h[6],
    featured: h[7], bio: h[8], status: "active", createdAt: now, updatedAt: now,
  }));

  const adoptionPosts = [
    ["adoption_01", "Mavi", "Istanbul", 10, "Kucuk", true, true, "Evde bakilmis, insan odakli ve oyun seven bir yavru. Temel tuvalet rutini olusmus durumda. Kucuk adimlarla sosyallesmeye acik oldugu icin sabirli ve duzenli bir ailede hizla guven kuruyor.", "Sahiplendirme kararinda uzun vadeli sorumluluk ve duzenli veteriner takibi bizim icin oncelikli. Ilk bir ayda uyum surecini birlikte takip etmek istiyoruz.", "demoOwner01"],
    ["adoption_02", "Tarcin", "Ankara", 18, "Orta", true, false, "Temel komutlari biliyor ve cocuklarla kontrollu sekilde iyi anlasiyor. Enerjisi gun icinde dengeli dagiliyor. Sabah ve aksam yuruyuslerini aksatmayan ailelerde davranis olarak cok daha huzurlu kaliyor.", "Bahceli ev tercihimiz var ama zorunlu degil. Onemli olan sabit rutin, guvenli alan ve ayrilik kaygisini yonetebilecek ilgi duzeyi.", "demoOwner02"],
    ["adoption_03", "Duman", "Izmir", 28, "Buyuk", false, false, "Aktif ve guclu bir karaktere sahip. Uzun yuruyus seven, fiziksel aktivite ihtiyaci yuksek bir kopek. Dogru liderlik ve net komutlarla cok hizli odaklanabiliyor, deneyimli sahipte potansiyeli yuksek.", "Tercihen buyuk irk tecrubesi olan bir aile ariyoruz. Ilk iki haftada kademeli adaptasyon ve kontrollu sosyallesme talep ediyoruz.", "demoOwner03"],
    ["adoption_04", "Boncuk", "Bursa", 14, "Kucuk", true, true, "Sakin ve sevgi odakli bir mizaci var. Ev ortamina hizli uyum sagliyor ve gurultuden kolay etkilenmiyor. Kucuk rutinlerle gununu dengeleyebilen bir ailede oldukca mutlu bir yasam surduruyor.", "Ev ziyareti ve on gorusme bizim icin kritik. Beslenme rutini ve uyku duzeni korunursa adaptasyon suresi cok rahat geciyor.", "demoOwner04"],
    ["adoption_05", "Fistik", "Istanbul", 20, "Orta", true, false, "Insanlarla kolay iletisim kuruyor ancak yeni ortamlarda ilk gun cekingen davranabiliyor. Kisa sureli oyun seanslariyla guvenini hizli topluyor. Duzenli egzersizle davranis dengesi gucleniyor.", "Aileden beklentimiz sabirli bir yaklasim ve ilk ay boyunca temel rutinlerin degistirilmeden uygulanmasi.", "demoOwner05"],
    ["adoption_06", "Panda", "Ankara", 24, "Buyuk", true, true, "Guvenli alanlarda cok uyumlu, yabanci ortamlarda once gozlemci bir tavir sergiliyor. Komut odakli calismaya acik ve odul sistemiyle motive oluyor. Buyuk irklar icin uygun fiziksel aktiviteye ihtiyac duyuyor.", "Gunluk uzun yuruyus zorunlu. Ailenin zaman ayirabilir olmasi ve davranis sinirlarini net koyabilmesi gerekiyor.", "demoOwner06"],
    ["adoption_07", "Loki", "Izmir", 12, "Kucuk", true, true, "Yuksek oyun istegi var ve insan temasini seviyor. Evin icinde oyuncakla kendi kendine de vakit gecirebiliyor. Cocuklu ailelerde kontrollu tanismayla cok iyi uyum gosterdigini gozlemledik.", "Asi takvimi duzenli takip edilmeli. Ilk haftalarda guvenli alan olusturulup ani kalabalik ortamlardan kacinilmasini istiyoruz.", "demoOwner07"],
    ["adoption_08", "Kopuk", "Bursa", 30, "Orta", false, false, "Sakin tempoda yasamayi seven bir karakter. Gun icinde dinlenme periyotlari uzun, disarida ise koklama odakli yuruyuslerden hoslaniyor. Sakin evlerde davranis dengesi cok daha iyi oluyor.", "Veteriner kontrolu tamamlandiktan sonra sahiplendirme yapacagiz. Bu surecte ailenin iletisimde kalmasini bekliyoruz.", "demoOwner08"],
    ["adoption_09", "Ciko", "Istanbul", 16, "Kucuk", true, false, "Yuksek sosyal bag kurabilen bir kopek. Evde yalniz kalma suresine kademeli alistirildiginda huzurlu kaliyor. Oyun ve odul odakli calismalarla temel komutlarda hizli ilerleme kaydediyor.", "Ilk bir ayda haftalik kontrol ve geri bildirim rica ediyoruz. Kademeli adaptasyon planiyla daha saglikli gecis oluyor.", "demoOwner09"],
    ["adoption_10", "Tarcin", "Ankara", 22, "Buyuk", true, true, "Dis ortamlarda enerjisi yuksek ama evde sakinlesebilen dengeli bir yapida. Net sinirlar koyuldugunda komutlara uyumu kuvvetli. Uzun yuruyus ve zihinsel oyun ihtiyaci birlikte karsilanmali.", "Sahiplenecek ailede buyuk irk tecrubesi tercih ediyoruz. Guvenli tasma ekipmani ve duzenli veteriner takibi sart.", "demoOwner10"],
  ].map((p) => ({
    id: p[0], dogName: p[1], city: p[2], ageMonths: p[3], size: p[4], vaccinated: p[5], featured: p[6],
    bio: p[7], ownerNote: p[8], ownerUserId: p[9], status: "active", createdAt: now, updatedAt: now,
  }));

  walkers.forEach(validateWalker);
  bnbHosts.forEach(validateHost);
  adoptionPosts.forEach(validateAdoptionPost);

  const batch = db.batch();

  for (const user of users) {
    batch.set(db.collection("users").doc(user.userId), user, { merge: true });
  }

  for (const dog of dogs) {
    batch.set(db.collection("dogs").doc(dog.dogId), dog, { merge: true });
  }

  for (const w of walkers) {
    batch.set(db.collection("walkers").doc(w.id), w, { merge: true });
  }

  for (const h of bnbHosts) {
    batch.set(db.collection("bnb_hosts").doc(h.id), h, { merge: true });
  }

  for (const p of adoptionPosts) {
    batch.set(db.collection("adoption_posts").doc(p.id), p, { merge: true });
  }

  await batch.commit();
  console.log("Seed completed: users, dogs, walkers(10), bnb_hosts(10), adoption_posts(10) written.");
}

run()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
