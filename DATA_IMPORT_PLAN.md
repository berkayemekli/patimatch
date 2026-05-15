# DATA_IMPORT_PLAN

## Current branch

`feature/data-downloads`

## Prepared master data

- `app/assets/master_data/veterinary_clinics_tr.json`
  - Collection: `veterinaryClinics`
  - Current count: 597
  - Source: OpenStreetMap / Overpass API
  - Status: unverified seed data

- `app/assets/master_data/pati_friendly_places_tr.json`
  - Collection: `patiFriendlyPlaces`
  - Current count: 40
  - Source: OpenStreetMap / Overpass API
  - Status: unverified seed data

## Import tooling

- `scripts/master_data_manifest.json`
- `scripts/validate_master_data.js`
- `scripts/import_master_data_to_firestore.js`
- `scripts/README_MASTER_DATA_IMPORT.md`

Safety rules:

- Import is dry-run by default.
- Live Firestore writes require both `--write` and `--yes`.
- Use `--only=veterinaryClinics` or `--only=patiFriendlyPlaces` for scoped imports.
- OSM records remain unverified seed data during import.
- Import adds `verificationStatus: "unverified_seed"` when source records do not include it.
- OpenStreetMap attribution is preserved on imported documents.

## Recommended flow

1. Validate local JSON files:

```bash
node scripts/validate_master_data.js
```

2. Dry-run import:

```bash
node scripts/import_master_data_to_firestore.js --dry-run
node scripts/import_master_data_to_firestore.js --dry-run --only=veterinaryClinics
node scripts/import_master_data_to_firestore.js --dry-run --only=patiFriendlyPlaces
```

3. Run live import only in a controlled environment:

```bash
set FIREBASE_SERVICE_ACCOUNT_PATH=C:\secure\service-account.json
node scripts/import_master_data_to_firestore.js --write --yes
```

## Recommended Firestore collections

### `veterinaryClinics`

Recommended indexes:

- `city`
- `city + district`
- `verified + city`
- Later: geohash/location index for near-me search

### `patiFriendlyPlaces`

Recommended indexes:

- `category`
- `category + city`
- `category + city + district`
- `petPolicy.status + category`
- `verified + category + city`
- Later: geohash/location index for near-me search

## Verification model

All OSM seed records must start as:

- `verified: false`
- `verificationStatus: "unverified_seed"`

Suggested user-facing wording:

- "Topluluk ve açık veri kaynaklarından derlenen aday mekanlar"
- "Gitmeden önce mekanla iletişime geçmeni öneririz"
- "PatiParent doğrulaması bekleniyor"

## Attribution

OpenStreetMap-derived data must preserve:

- `© OpenStreetMap contributors`

Keep license metadata in JSON files and surface attribution in relevant app screens or legal/about pages.
