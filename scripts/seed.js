/* eslint-disable no-console */
const admin = require("firebase-admin");

if (!process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  console.error("GOOGLE_APPLICATION_CREDENTIALS env var is required.");
  process.exit(1);
}

admin.initializeApp({
  credential: admin.credential.applicationDefault()
});

const db = admin.firestore();

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
      lastActiveAt: now
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
      lastActiveAt: now
    }
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
      verificationStatus: "pending",
      createdAt: now,
      updatedAt: now
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
      verificationStatus: "pending",
      createdAt: now,
      updatedAt: now
    }
  ];

  const batch = db.batch();

  for (const user of users) {
    const ref = db.collection("users").doc(user.userId);
    batch.set(ref, user, { merge: true });
  }

  for (const dog of dogs) {
    const ref = db.collection("dogs").doc(dog.dogId);
    batch.set(ref, dog, { merge: true });
  }

  await batch.commit();
  console.log("Seed completed: users + dogs written.");
}

run()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });

