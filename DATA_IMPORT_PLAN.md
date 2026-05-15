# DATA_IMPORT_PLAN

## Scope

This branch prepares reusable master data for PatiParent without touching UI screens.

Prepared files:

- pp/assets/master_data/veterinary_clinics_tr.json
- pp/assets/master_data/pati_friendly_places_tr.json
- scripts/download_veterinary_clinics_osm.ps1
- scripts/download_pati_friendly_places_osm.ps1

## Recommended Firestore collections

### eterinaryClinics

Use records from eterinary_clinics_tr.json.

Recommended indexes:

- city
- city + district
- erified + city
- Later: geohash/location index for near-me search

### patiFriendlyPlaces

Use records from pati_friendly_places_tr.json.

Recommended indexes:

- category
- category + city
- category + city + district
- petPolicy.status + category
- erified + category + city
- Later: geohash/location index for near-me search

## Verification model

All OSM seed records must start as:

- erified: false
- erificationStatus: "unverified_seed"

Do not present these as guaranteed pet-friendly places.

## Attribution

OpenStreetMap-derived data must preserve attribution:

- "Â© OpenStreetMap contributors"

Keep the license metadata in JSON files.

## Next app task

Codex should wire the prepared data into app screens/repositories without modifying the source data format unless necessary.
