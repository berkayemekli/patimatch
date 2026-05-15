# PatiParent Master Data Import

This folder contains data infrastructure scripts only. It should not change UI files.

## Files

- `master_data_manifest.json`
- `validate_master_data.js`
- `import_master_data_to_firestore.js`

## Validate data

From repo root:

```bash
node scripts/validate_master_data.js
```

Expected current data:

- `veterinaryClinics`: 597 OSM-sourced clinics
- `patiFriendlyPlaces`: 40 OSM-sourced pet-friendly place candidates

## Dry-run import

```bash
node scripts/import_master_data_to_firestore.js --dry-run
node scripts/import_master_data_to_firestore.js --dry-run --only=veterinaryClinics
node scripts/import_master_data_to_firestore.js --dry-run --only=patiFriendlyPlaces
```

Dry-run is the default mode, so running without flags does not write:

```bash
node scripts/import_master_data_to_firestore.js
```

## Live Firestore import

Only run this after dry-run validation.

```bash
set FIREBASE_SERVICE_ACCOUNT_PATH=C:\secure\service-account.json
node scripts/import_master_data_to_firestore.js --write --yes
```

Or import one collection:

```bash
node scripts/import_master_data_to_firestore.js --write --yes --only=patiFriendlyPlaces
```

## Important

All OpenStreetMap records are unverified seed data.

Keep:

- `verified: false`
- `verificationStatus: "unverified_seed"`
- `© OpenStreetMap contributors` attribution

The importer preserves source license metadata and writes
`verificationStatus: "unverified_seed"` when a source row does not already
include it.

Do not show these records to users as guaranteed pet-friendly places.
