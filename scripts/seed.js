/* eslint-disable no-console */
const admin = require("firebase-admin");

const projectId = process.env.FIREBASE_PROJECT_ID || "patimatch-app-2026-berkay";

function nowIso() {
  return new Date().toISOString();
}

function requireMinText(value, min, label) {
  const text = (value || "").trim();
  if (text.length < min) {
    throw new Error(`${label} must be at least ${min} chars.`);
  }
}

function firestoreValue(value) {
  if (value === null || value === undefined) return { nullValue: null };
  if (typeof value === "string") return { stringValue: value };
  if (typeof value === "boolean") return { booleanValue: value };
  if (Number.isInteger(value)) return { integerValue: String(value) };
  if (typeof value === "number") return { doubleValue: value };
  if (value instanceof Date) return { timestampValue: value.toISOString() };
  if (Array.isArray(value)) {
    return { arrayValue: { values: value.map(firestoreValue) } };
  }
  if (typeof value === "object") {
    return {
      mapValue: {
        fields: Object.fromEntries(
          Object.entries(value).map(([key, inner]) => [key, firestoreValue(inner)]),
        ),
      },
    };
  }
  throw new Error(`Unsupported Firestore value: ${value}`);
}

function firestoreDocument(collection, id, data) {
  return {
    name: `projects/${projectId}/databases/(default)/documents/${collection}/${id}`,
    fields: Object.fromEntries(
      Object.entries(data).map(([key, value]) => [key, firestoreValue(value)]),
    ),
  };
}

async function getFirebaseCliToken() {
  const auth = require("C:/Users/berka/AppData/Roaming/npm/node_modules/firebase-tools/lib/auth.js");
  const account = auth.getGlobalDefaultAccount();
  const refreshToken = account && account.tokens && account.tokens.refresh_token;
  const scopes = [
    "email",
    "openid",
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/firebase",
  ];
  const token = await auth.getAccessToken(refreshToken, scopes);
  if (!token || !token.access_token) {
    throw new Error("Firebase CLI access token could not be read. Run `firebase login` first.");
  }
  return token.access_token;
}

async function writeWithRest(documents) {
  const accessToken = await getFirebaseCliToken();
  const url = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents:commit`;
  const writes = documents.map(({ collection, id, data }) => ({
    update: firestoreDocument(collection, id, data),
  }));

  for (let i = 0; i < writes.length; i += 400) {
    const chunk = writes.slice(i, i + 400);
    const response = await fetch(url, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ writes: chunk }),
    });
    const payload = await response.json().catch(() => ({}));
    if (!response.ok) {
      throw new Error(`Firestore REST commit failed (${response.status}): ${JSON.stringify(payload)}`);
    }
  }
}

async function writeWithAdmin(documents) {
  admin.initializeApp({ credential: admin.credential.applicationDefault(), projectId });
  const db = admin.firestore();
  const batch = db.batch();
  for (const { collection, id, data } of documents) {
    batch.set(db.collection(collection).doc(id), data, { merge: true });
  }
  await batch.commit();
}

function buildSeedDocuments() {
  const timestamp = nowIso();
  const commonTrust = ["Telefon doğrulandı", "Demo profil", "Referans kontrolü"];
  const walkerRows = [
    ["01", "Ece Aras", "İstanbul", "Kadıköy", 330, 4.9, 312, "Hafta içi 18:00 sonrası, hafta sonu sabah", "Enerjik orta ve büyük ırklarda tempo ayarlı yürüyüş planı yapıyorum. İlk görüşmede tasma alışkanlığı, tetikleyiciler ve su molası ihtiyacını not alırım. Her yürüyüş sonunda kısa durum özeti paylaşırım.", "https://images.unsplash.com/photo-1516734212186-a967f81ad0d7?auto=format&fit=crop&w=1200&q=80"],
    ["02", "Mert Kaya", "İstanbul", "Beşiktaş", 290, 4.8, 188, "Her gün 19:00-22:00", "Küçük ve hassas köpeklerde sakin başlangıç, kısa mola ve güvenli rota yaklaşımı kullanıyorum. Apartman çıkışı, asansör ve yoğun cadde geçişlerinde kontrollü ilerleyerek stresi azaltırım.", "https://images.unsplash.com/photo-1544568100-847a948585b9?auto=format&fit=crop&w=1200&q=80"],
    ["03", "Sena Demir", "Ankara", "Çankaya", 260, 4.7, 140, "Pazartesi, çarşamba, cuma öğlen", "Veteriner kliniği deneyimim sayesinde yaşlı köpeklerde tempo, eklem hassasiyeti ve ilaç saatlerine dikkat ederim. Yürüyüşleri oyun değil sağlık rutini gibi planlar, sahipleri net bilgilendiririm.", "https://images.unsplash.com/photo-1567225557594-88d73e55f2cb?auto=format&fit=crop&w=1200&q=80"],
    ["04", "Yiğit Tunç", "İzmir", "Karşıyaka", 340, 5.0, 92, "Sabah 07:00-10:00", "Sahil hattında güvenli ve düzenli yürüyüş rotaları kullanırım. Yüksek enerjili köpekler için koşu-yürüyüş dengesi kurar, sıcak havalarda gölge ve su molalarını önceden planlarım.", "https://images.unsplash.com/photo-1548199973-03cce0bbc87b?auto=format&fit=crop&w=1200&q=80"],
    ["05", "Burcu Narin", "Bursa", "Nilüfer", 250, 4.8, 121, "Hafta içi 12:00-16:00", "Yavru köpeklerin dış ortama alışmasını sabırlı ve düşük uyaranlı rotalarla destekliyorum. İlk yürüyüşte hedefim performans değil güven kurmak; sonraki seanslarda süreyi kademeli artırırım.", "https://images.unsplash.com/photo-1525253086316-d0c936c814f8?auto=format&fit=crop&w=1200&q=80"],
    ["06", "Caner Öz", "İstanbul", "Şişli", 275, 4.6, 98, "Esnek saat, aynı gün talep uygun", "Yoğun şehir bölgelerinde sessiz park rotaları seçerim. Reaktif köpeklerde mesafe yönetimi, sabit komutlar ve kısa dikkat egzersizleriyle güvenli yürüyüş deneyimi sağlamaya çalışırım.", "https://images.unsplash.com/photo-1518020382113-a7e8fc38eac9?auto=format&fit=crop&w=1200&q=80"],
    ["07", "Derya Polat", "Ankara", "Keçiören", 300, 4.9, 167, "Hafta sonu tam gün", "Köpek davranış gözlemi eğitimi aldım. Endişeli karakterlerde sabit rota ve tekrarlı rutinlerle ilerlerim. Sosyalleşme ihtiyacı olan köpeklerde kontrollü kısa tanışmalar planlarım.", "https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&w=1200&q=80"],
    ["08", "Kaan Rüzgar", "İzmir", "Bornova", 285, 4.7, 133, "Salı-perşembe akşam", "Düzenli haftalık paketlerde aynı saat ve aynı rota prensibini severim. Sahiplerin iş programına uygun saat blokları açar, her yürüyüş sonrası aktivite ve davranış notu gönderirim.", "https://images.unsplash.com/photo-1537151608828-ea2b11777ee8?auto=format&fit=crop&w=1200&q=80"],
    ["09", "Melis Soyer", "Bursa", "Osmangazi", 310, 4.9, 156, "Hafta içi sabah ve öğlen", "Yürüyüşlerde fiziksel aktivite kadar zihinsel uyarımı da önemserim. Koku takip, bekle komutu ve sakinleşme molalarıyla yorucu ama dengeli bir program uygularım.", "https://images.unsplash.com/photo-1517849845537-4d257902454a?auto=format&fit=crop&w=1200&q=80"],
    ["10", "Onur Eren", "İstanbul", "Ataşehir", 320, 4.8, 175, "Her gün 08:00-11:00", "Büyük ırklarda kontrollü tempo ve güvenli tasma kullanımı benim uzmanlık alanım. Seans öncesi hedef belirler, seans sonrası yürüyüş süresi, mola ve genel ruh hali özetini paylaşırım.", "https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=1200&q=80"],
  ];

  const ownerRows = [
    ["01", "Ayşe Yılmaz", "Luna", "Golden Retriever", "İstanbul", "Kadıköy", 30, 26, "female", "Oyuncu ve sosyal, uzun yürüyüşlerden hoşlanır."],
    ["02", "Mert Aksoy", "Milo", "Labrador Retriever", "İstanbul", "Beşiktaş", 36, 30, "male", "Sakin ama dışarıda koklamayı çok sever."],
    ["03", "Selin Demir", "Zeytin", "French Bulldog", "Ankara", "Çankaya", 20, 12, "female", "Kısa yürüyüş ve sık mola ister."],
    ["04", "Kerem Şahin", "Rüzgar", "Border Collie", "İzmir", "Karşıyaka", 28, 18, "male", "Yüksek enerjili, komutlara hızlı yanıt verir."],
    ["05", "Deniz Arslan", "Boncuk", "Maltese", "Bursa", "Nilüfer", 18, 5, "female", "Küçük ırk, kalabalık ortamlarda çekingen."],
    ["06", "Ebru Çelik", "Tarçın", "Beagle", "İstanbul", "Şişli", 42, 14, "male", "Koku takip etmeyi sever, tasma kontrolü gerekir."],
    ["07", "Alp Koç", "Duman", "Kangal", "Ankara", "Keçiören", 48, 42, "male", "Büyük ırk tecrübesi olan gezdirici tercih edilir."],
    ["08", "Cemre Aydın", "Pati", "Poodle", "İzmir", "Bornova", 22, 8, "female", "Sosyal ve çocuklarla uyumlu."],
    ["09", "Bora Keskin", "Köpük", "Cocker Spaniel", "Bursa", "Osmangazi", 34, 13, "male", "Orta tempolu düzenli yürüyüş iyi gelir."],
    ["10", "Nisa Er", "Çiko", "Pomeranian", "İstanbul", "Ataşehir", 16, 4, "male", "Kısa ama sık yürüyüşlere uygundur."],
  ];

  const documents = [];

  for (const row of walkerRows) {
    const [n, name, city, district, pricePerHour, rating, walkCount, availability, bio, imageUrl] = row;
    const userId = `seed_walker_${n}`;
    documents.push({
      collection: "users",
      id: userId,
      data: {
        userId,
        displayName: name,
        phone: `+9055500100${n}`,
        city,
        district,
        moduleRoles: { PatiGezdirme: ["provider"] },
        serviceMemberships: ["walk_provider"],
        roles: ["service_provider"],
        onboardingCompleted: true,
        verificationStatus: n === "01" || n === "04" ? "verified" : "phone_email",
        blueBadge: n === "01" || n === "04",
        trustBadges: commonTrust,
        createdAt: timestamp,
        updatedAt: timestamp,
      },
    });
    documents.push({
      collection: "walkers",
      id: userId,
      data: {
        id: userId,
        ownerUserId: userId,
        name,
        city,
        district,
        pricePerHour,
        rating,
        reviewCount: Math.max(3, Math.round(walkCount / 18)),
        walkCount,
        availability,
        responseTime: ["01", "04", "09"].includes(n) ? "30 dk i\u{00E7}inde" : "2 saat i\u{00E7}inde",
        repeatClientRate: 62 + Number(n) * 3,
        routeStyle: ["01", "06", "10"].includes(n)
          ? "Sakin park rotas?, kontroll? cadde ge?i?i ve su molas?"
          : "Mahalle i\u{00E7}i g\u{00FC}venli rota ve enerjiye g\u{00F6}re tempo ayar\u{0131}",
        cancellationPolicy: "24 saat \u{00F6}nce \u{00FC}cretsiz iptal",
        specialties: Number(n) % 3 === 0
          ? ["Ya?l? k?pek", "Sakin tempo", "?la? saati takibi"]
          : Number(n) % 2 === 0
            ? ["K\u{00FC}\u{00E7}\u{00FC}k \u{0131}rklar", "Ak\u{015F}am y\u{00FC}r\u{00FC}y\u{00FC}\u{015F}\u{00FC}", "Apartman \u{00E7}\u{0131}k\u{0131}\u{015F}\u{0131}"]
            : ["Enerjik k\u{00F6}pek", "B\u{00FC}y\u{00FC}k \u{0131}rk", "Tempo ayar\u{0131}"],
        safetyChecklist: [
          "Canl\u{0131} konum payla\u{015F}\u{0131}m\u{0131}",
          "Su molas\u{0131} ve hava durumu takibi",
          "Y\u{00FC}r\u{00FC}y\u{00FC}\u{015F} sonras\u{0131} foto\u{011F}rafl\u{0131} \u{00F6}zet",
          "Acil durumda sahip ve veteriner aramas\u{0131}",
        ],
        bio,
        imageUrl,
        instantBooking: ["01", "04", "06", "09", "10"].includes(n),
        featured: ["01", "04", "09"].includes(n),
        status: "active",
        verificationStatus: n === "01" || n === "04" ? "verified" : "phone_email",
        trustBadges: commonTrust,
        createdAt: timestamp,
        updatedAt: timestamp,
      },
    });
  }

  for (const row of ownerRows) {
    const [n, displayName, dogName, breed, city, district, ageMonths, weightKg, sex, bio] = row;
    const userId = `seed_owner_${n}`;
    const dogId = `seed_dog_${n}`;
    documents.push({
      collection: "users",
      id: userId,
      data: {
        userId,
        displayName,
        phone: `+9055500200${n}`,
        city,
        district,
        moduleRoles: { PatiGezdirme: ["customer"] },
        serviceMemberships: ["walk_customer"],
        roles: ["pet_owner"],
        onboardingCompleted: true,
        verificationStatus: "phone_email",
        trustBadges: ["Telefon doğrulandı", "Pet pasaportu eklendi"],
        createdAt: timestamp,
        updatedAt: timestamp,
      },
    });
    documents.push({
      collection: "dogs",
      id: dogId,
      data: {
        dogId,
        ownerId: userId,
        name: dogName,
        animalCategory: "Köpek",
        breed,
        passportCode: `TR-PATI-${n}-2026`,
        microchipNo: `900000000000${n}`,
        ageMonths,
        weightKg,
        sex,
        color: n % 2 === 0 ? "Karamel" : "Açık kahve",
        temperamentTags: ["Sosyal", "Oyuncu"],
        activityLevel: weightKg > 20 ? "high" : "medium",
        healthNotes: bio,
        bio,
        isNeutered: ["02", "05", "08"].includes(n),
        isVaccinated: true,
        vaccineStatus: "Tam",
        vaccines: ["Karma", "Kuduz", "Parazit"],
        friendlyWithDogs: true,
        friendlyWithKids: !["07"].includes(n),
        photoUrls: [`https://placedog.net/900/700?id=${Number(n) + 20}`],
        city,
        district,
        isProfileComplete: true,
        verificationStatus: "verified",
        createdAt: timestamp,
        updatedAt: timestamp,
      },
    });
  }

  for (const doc of documents) {
    if (doc.collection === "walkers") requireMinText(doc.data.bio, 120, `walker:${doc.id}.bio`);
  }
  return documents;
}

async function run() {
  const documents = buildSeedDocuments();
  if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    await writeWithAdmin(documents);
    console.log(`Seed completed with Admin SDK: ${documents.length} documents written.`);
    return;
  }
  await writeWithRest(documents);
  console.log(`Seed completed with Firebase CLI login: ${documents.length} documents written.`);
  console.log("Created/updated: 10 walkers, 10 walker users, 10 dog owners, 10 dogs.");
}

run().catch((err) => {
  console.error(err.message || err);
  process.exit(1);
});
