/* eslint-disable no-console */
const fs = require("fs");
const path = require("path");

const projectId = readArg("--project") || process.env.FIREBASE_PROJECT_ID || "patimatch-staging";
const count = Number(readArg("--count") || process.env.LOAD_TEST_COUNT || 250);
const matchPairs = Number(readArg("--match-pairs") || process.env.LOAD_TEST_MATCH_PAIRS || 120);
const prefix = readArg("--prefix") || process.env.LOAD_TEST_PREFIX || "lt_2026";
const writeEnabled = hasFlag("--write") || process.env.LOAD_TEST_WRITE === "1";
const allowProd = hasFlag("--allow-prod") || process.env.ALLOW_PROD_LOAD_TEST === "1";

const ROOT = path.resolve(__dirname, "..");
const REPORT = path.join(ROOT, "docs", "load_test_seed_report.json");

if (projectId === "patimatch-app-2026-berkay" && !allowProd) {
  throw new Error(
    "Refusing to seed production. Use --project patimatch-staging or pass --allow-prod intentionally.",
  );
}

if (!Number.isInteger(count) || count < 1 || count > 500) {
  throw new Error("--count must be an integer between 1 and 500.");
}

function readArg(name) {
  const index = process.argv.indexOf(name);
  if (index === -1) return "";
  return process.argv[index + 1] || "";
}

function hasFlag(name) {
  return process.argv.includes(name);
}

function nowIso() {
  return new Date().toISOString();
}

function addDays(days, hour = 10) {
  const date = new Date();
  date.setDate(date.getDate() + days);
  date.setHours(hour, 0, 0, 0);
  return date;
}

function pad(value, size = 3) {
  return String(value).padStart(size, "0");
}

function pick(list, index) {
  return list[index % list.length];
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
    console.log(`Committed ${Math.min(i + chunk.length, writes.length)}/${writes.length}`);
  }
}

function buildDocuments() {
  const timestamp = nowIso();
  const cities = [
    ["İstanbul", "Kadıköy"],
    ["İstanbul", "Beşiktaş"],
    ["İstanbul", "Şişli"],
    ["Ankara", "Çankaya"],
    ["İzmir", "Karşıyaka"],
    ["Bursa", "Nilüfer"],
    ["Antalya", "Muratpaşa"],
    ["Muğla", "Bodrum"],
  ];
  const dogBreeds = ["Golden Retriever", "Labrador Retriever", "Maltese", "Poodle", "French Bulldog", "Beagle", "Border Collie", "Kangal", "Melez", "Tekir"];
  const catBreeds = ["Tekir", "British Shorthair", "Scottish Fold", "Van Kedisi", "Ankara Kedisi", "Sarman", "Russian Blue"];
  const docs = [];
  const counters = {};

  function add(collection, id, data) {
    docs.push({ collection, id, data });
    counters[collection] = (counters[collection] || 0) + 1;
  }

  for (let i = 1; i <= count; i += 1) {
    const id = pad(i);
    const [city, district] = pick(cities, i);
    const verified = i % 5 === 0;
    const userId = `${prefix}_walk_user_${id}`;
    add("users", userId, baseUser(userId, `Gezdirici ${id}`, city, district, ["provider"], timestamp, verified));
    add("walkers", `${prefix}_walker_${id}`, {
      id: `${prefix}_walker_${id}`,
      ownerUserId: userId,
      name: `PatiGezdirme Test ${id}`,
      city,
      district,
      pricePerHour: 220 + (i % 10) * 25,
      rating: Number((4.2 + (i % 8) / 10).toFixed(1)),
      reviewCount: 8 + (i % 80),
      walkCount: 20 + i,
      availability: i % 2 === 0 ? "Hafta içi akşam" : "Hafta sonu gündüz",
      responseTime: i % 3 === 0 ? "30 dk içinde" : "2 saat içinde",
      repeatClientRate: 55 + (i % 40),
      routeStyle: "Güvenli rota, su molası, fotoğraflı yürüyüş özeti",
      cancellationPolicy: "24 saat önce ücretsiz iptal",
      specialties: [pick(["Küçük ırklar", "Büyük ırklar", "Yavru köpek", "Yaşlı köpek"], i), "Canlı takip"],
      safetyChecklist: ["Canlı konum", "Su molası", "Yürüyüş sonrası özet"],
      bio: `Load test gezdirici ${id}. Şehir içi güvenli rota, düzenli saat, davranış notu ve fotoğraflı takip sunan test profilidir.`,
      imageUrl: `https://placedog.net/900/700?id=${1000 + i}`,
      instantBooking: i % 4 === 0,
      featured: i % 11 === 0,
      status: "active",
      verificationStatus: verified ? "verified" : "phone_email",
      trustBadges: verified ? ["Kimlik doğrulandı", "Telefon doğrulandı"] : ["Telefon doğrulandı"],
      createdAt: timestamp,
      updatedAt: timestamp,
    });
  }

  for (let i = 1; i <= count; i += 1) {
    const id = pad(i);
    const [city, district] = pick(cities, i + 2);
    const verified = i % 6 === 0;
    const userId = `${prefix}_bnb_user_${id}`;
    add("users", userId, baseUser(userId, `PatiBnB Host ${id}`, city, district, ["provider"], timestamp, verified));
    add("bnb_hosts", `${prefix}_bnb_${id}`, {
      id: `${prefix}_bnb_${id}`,
      ownerUserId: userId,
      name: `PatiBnB Test Host ${id}`,
      city,
      district,
      nightlyPrice: 550 + (i % 12) * 60,
      rating: Number((4.1 + (i % 9) / 10).toFixed(1)),
      reviewCount: 5 + (i % 90),
      homeType: pick(["Bahçeli ev", "Modern daire", "Teraslı ev", "Villa", "Bahçe katı"], i),
      yard: i % 3 === 0,
      petTypes: i % 4 === 0 ? ["Kedi"] : ["Köpek", "Kedi"],
      breeds: [pick(dogBreeds, i), pick(catBreeds, i)],
      bio: `Load test PatiBnB host ${id}. Ev ortamında güvenli konaklama, günlük fotoğraf ve rutin takibi sunar.`,
      houseRules: ["Aşı kartı istenir", "Ön görüşme önerilir", "Beslenme rutini yazılı alınır"],
      safetyFeatures: ["Ayrı dinlenme alanı", "Yakın veteriner planı", "Güvenli kapı/pencere kontrolü"],
      dailyRoutine: "Sabah adaptasyon, gün içinde fotoğraflı durum, akşam sakin oyun.",
      responseTime: i % 3 === 0 ? "1 saat içinde" : "2 saat içinde",
      acceptedPetSize: pick(["Küçük ve orta", "Tüm boyutlar", "Kedi odaklı", "Orta ve büyük"], i),
      imageUrl: `https://images.unsplash.com/photo-1494526585095-c41746248156?auto=format&fit=crop&w=1200&q=80&sig=${i}`,
      status: "active",
      verificationStatus: verified ? "verified" : "phone_email",
      trustBadges: verified ? ["Kimlik doğrulandı", "Ev ön kontrolü"] : ["Telefon doğrulandı"],
      createdAt: timestamp,
      updatedAt: timestamp,
    });
  }

  for (let i = 1; i <= count; i += 1) {
    const id = pad(i);
    const [city, district] = pick(cities, i + 4);
    const userId = `${prefix}_match_user_${id}`;
    const dogId = `${prefix}_match_dog_${id}`;
    const animalCategory = i % 5 === 0 ? "Kedi" : "Köpek";
    add("users", userId, baseUser(userId, `PatiMatch Üye ${id}`, city, district, ["customer"], timestamp, i % 7 === 0));
    add("dogs", dogId, {
      dogId,
      ownerId: userId,
      name: `${animalCategory === "Kedi" ? "Mırmır" : "Pati"} ${id}`,
      animalCategory,
      breed: animalCategory === "Kedi" ? pick(catBreeds, i) : pick(dogBreeds, i),
      ageMonths: 6 + (i % 84),
      weightKg: animalCategory === "Kedi" ? 3 + (i % 6) : 5 + (i % 42),
      sex: i % 2 === 0 ? "female" : "male",
      temperamentTags: [pick(["Sosyal", "Oyuncu", "Sakin", "Enerjik"], i), "Load test"],
      activityLevel: pick(["low", "medium", "high"], i),
      bio: `PatiMatch load test profili ${id}. Eşleşme, filtre ve chat akışını test etmek için oluşturuldu.`,
      city,
      district,
      isProfileComplete: true,
      isVaccinated: i % 8 !== 0,
      vaccineStatus: i % 8 === 0 ? "Eksik" : "Tam",
      photoUrls: [`https://placedog.net/900/700?id=${2000 + i}`],
      matchGoal: pick(["oyun arkadaşı", "sosyal tanışma", "yürüyüş arkadaşı"], i),
      status: "active",
      createdAt: timestamp,
      updatedAt: timestamp,
    });
  }

  for (let i = 1; i <= count; i += 1) {
    const id = pad(i);
    const [city, district] = pick(cities, i + 6);
    const userId = `${prefix}_family_owner_${id}`;
    const postId = `${prefix}_family_post_${id}`;
    const animalCategory = i % 4 === 0 ? "Kedi" : "Köpek";
    const petName = `${animalCategory === "Kedi" ? "Boncuk" : "Mavi"} ${id}`;
    add("users", userId, baseUser(userId, `PatiFamily Sahip ${id}`, city, district, ["provider"], timestamp, i % 9 === 0));
    add("adoption_posts", postId, {
      id: postId,
      ownerUserId: userId,
      dogName: petName,
      animalType: animalCategory,
      breed: animalCategory === "Kedi" ? pick(catBreeds, i) : pick(dogBreeds, i),
      ageMonths: 4 + (i % 72),
      size: pick(["Küçük", "Orta", "Büyük"], i),
      sex: i % 2 === 0 ? "Dişi" : "Erkek",
      city,
      district,
      vaccinated: i % 6 !== 0,
      urgency: pick(["Acil yuva", "Geçici yuva", "Doğrulanmış", "Yeni"], i),
      featured: i % 10 === 0,
      bio: `PatiFamily load test ilanı ${id}. Uyum, başvuru ve filtre akışlarını test etmek için oluşturuldu.`,
      ownerNote: "İlk ay takip, veteriner kontrolü ve sakin adaptasyon süreci önerilir.",
      trustBadges: ["Aşı kartı", "Sahiplendirme formu"],
      careNeeds: ["Sabit rutin", "Veteriner kontrolü", "İlk hafta sabır"],
      imageUrl: animalCategory === "Kedi"
        ? `https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&w=1200&q=80&sig=${i}`
        : `https://placedog.net/900/700?id=${3000 + i}`,
      status: "active",
      createdAt: timestamp,
      updatedAt: timestamp,
    });
  }

  simulateRequestsAndMatches(docs, counters, timestamp);
  return { docs, counters };
}

function baseUser(userId, displayName, city, district, roles, timestamp, verified) {
  return {
    userId,
    displayName,
    email: `${userId}@loadtest.patiparent.local`,
    phone: `+90555${Math.floor(1000000 + Math.random() * 8999999)}`,
    city,
    district,
    roles,
    onboardingCompleted: true,
    verificationStatus: verified ? "verified" : "phone_email",
    blueBadge: verified,
    trustBadges: verified ? ["Kimlik doğrulandı", "Telefon doğrulandı"] : ["Telefon doğrulandı"],
    isLoadTest: true,
    loadTestPrefix: prefix,
    createdAt: timestamp,
    updatedAt: timestamp,
  };
}

function simulateRequestsAndMatches(docs, counters, timestamp) {
  const add = (collection, id, data) => {
    docs.push({ collection, id, data });
    counters[collection] = (counters[collection] || 0) + 1;
  };

  const requestCount = Math.min(80, count);
  for (let i = 1; i <= requestCount; i += 1) {
    const id = pad(i);
    const requester = `${prefix}_match_user_${id}`;
    const dogId = `${prefix}_match_dog_${id}`;
    add("walk_requests", `${prefix}_walk_request_${id}`, {
      requestId: `${prefix}_walk_request_${id}`,
      requesterUserId: requester,
      requesterDogId: dogId,
      walkerId: `${prefix}_walker_${id}`,
      walkerOwnerUserId: `${prefix}_walk_user_${id}`,
      walkerName: `PatiGezdirme Test ${id}`,
      preferredAt: addDays(1 + (i % 21), 8 + (i % 10)),
      note: "Load test tarihli gezdirme talebi.",
      status: i % 4 === 0 ? "accepted" : "pending",
      createdAt: timestamp,
      updatedAt: timestamp,
    });
    add("bnb_requests", `${prefix}_bnb_request_${id}`, {
      requestId: `${prefix}_bnb_request_${id}`,
      requesterUserId: requester,
      requesterDogId: dogId,
      hostId: `${prefix}_bnb_${id}`,
      hostOwnerUserId: `${prefix}_bnb_user_${id}`,
      hostName: `PatiBnB Test Host ${id}`,
      checkIn: addDays(7 + (i % 30), 14),
      checkOut: addDays(8 + (i % 30), 11),
      note: "Load test konaklama talebi.",
      status: i % 5 === 0 ? "accepted" : "pending",
      createdAt: timestamp,
      updatedAt: timestamp,
    });
    add("adoption_applications", `${prefix}_family_application_${id}`, {
      applicationId: `${prefix}_family_application_${id}`,
      requesterUserId: requester,
      requesterDogId: dogId,
      postId: `${prefix}_family_post_${id}`,
      ownerUserId: `${prefix}_family_owner_${id}`,
      dogName: `Mavi ${id}`,
      note: `Load test sahiplenme başvurusu. Tanışma/adaptasyon görüşmesi: ${addDays(3 + (i % 20), 12).toISOString()}`,
      status: "pending",
      createdAt: timestamp,
      updatedAt: timestamp,
    });
  }

  const pairs = Math.min(matchPairs, Math.floor(count / 2));
  for (let i = 1; i <= pairs; i += 1) {
    const a = pad(i);
    const b = pad(count - i + 1);
    const dogA = `${prefix}_match_dog_${a}`;
    const dogB = `${prefix}_match_dog_${b}`;
    const ownerA = `${prefix}_match_user_${a}`;
    const ownerB = `${prefix}_match_user_${b}`;
    const matchId = [dogA, dogB].sort().join("_");
    add("swipes", `${dogA}_${dogB}`, swipe(`${dogA}_${dogB}`, dogA, ownerA, dogB, ownerB, true, timestamp));
    add("swipes", `${dogB}_${dogA}`, swipe(`${dogB}_${dogA}`, dogB, ownerB, dogA, ownerA, true, timestamp));
    add("matches", matchId, {
      matchId,
      dogAId: dogA,
      dogBId: dogB,
      dogIds: [dogA, dogB].sort(),
      ownerIds: [ownerA, ownerB],
      status: "active",
      isLoadTest: true,
      loadTestPrefix: prefix,
      createdAt: timestamp,
      updatedAt: timestamp,
    });
    add("chats", matchId, {
      chatId: matchId,
      matchId,
      participantDogIds: [dogA, dogB],
      participantOwnerIds: [ownerA, ownerB],
      lastMessage: "Load test eşleşmesi oluşturuldu.",
      lastMessageAt: addDays(0, 12),
      status: "active",
      isLoadTest: true,
      loadTestPrefix: prefix,
      createdAt: timestamp,
      updatedAt: timestamp,
    });
  }
}

function swipe(swipeId, fromDogId, fromOwnerId, toDogId, toOwnerId, liked, timestamp) {
  return {
    swipeId,
    fromDogId,
    fromOwnerId,
    toDogId,
    toOwnerId,
    decision: liked ? "like" : "pass",
    liked,
    isLoadTest: true,
    loadTestPrefix: prefix,
    createdAt: timestamp,
    updatedAt: timestamp,
  };
}

function writeReport(counters, written) {
  const report = {
    generatedAt: nowIso(),
    projectId,
    prefix,
    countPerModule: count,
    matchPairs,
    writeEnabled,
    written,
    counters,
    notes: [
      "Use staging by default; production requires --allow-prod.",
      "Generated users are Firestore profile docs, not Firebase Auth accounts.",
      "PatiMatch mutual swipes create matches and chats for regression testing.",
    ],
  };
  fs.mkdirSync(path.dirname(REPORT), { recursive: true });
  fs.writeFileSync(REPORT, `${JSON.stringify(report, null, 2)}\n`, "utf8");
  return report;
}

async function run() {
  const { docs, counters } = buildDocuments();
  const report = writeReport(counters, false);
  console.log(`Prepared ${docs.length} documents for ${projectId}.`);
  console.log(JSON.stringify(report.counters, null, 2));
  if (!writeEnabled) {
    console.log("Dry-run only. Re-run with --write to commit to Firestore.");
    return;
  }
  await writeWithRest(docs);
  writeReport(counters, true);
  console.log("Load test seed completed.");
}

run().catch((err) => {
  console.error(err.stack || err.message || err);
  process.exit(1);
});
