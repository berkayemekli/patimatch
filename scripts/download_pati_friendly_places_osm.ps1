$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$repo = "C:\AI\Dog_Date"
$target = Join-Path $repo "app\assets\master_data\pati_friendly_places_tr.json"
$worklog = Join-Path $repo "DATA_WORKLOG.md"
$importPlan = Join-Path $repo "DATA_IMPORT_PLAN.md"
$nextPrompt = Join-Path $repo "NEXT_CODEX_PROMPT.txt"
$report = Join-Path $env:USERPROFILE "Desktop\pati_friendly_places_run_report.txt"

$lines = New-Object System.Collections.Generic.List[string]
function Log-Line([string]$line) {
  $lines.Add($line) | Out-Null
  Write-Host $line
}

try {
  Log-Line "Pati-friendly places data run"
  Log-Line ("Generated: " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss"))
  Log-Line ("Repo: " + $repo)

  if (!(Test-Path $repo)) { throw "Repo not found: $repo" }
  Set-Location $repo

  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

  function Get-Tag {
    param($Tags, [string]$Key)
    if ($null -eq $Tags) { return "" }
    $prop = $Tags.PSObject.Properties[$Key]
    if ($null -eq $prop -or $null -eq $prop.Value) { return "" }
    return ([string]$prop.Value).Trim()
  }

  function Get-PlaceType {
    param($Tags)

    $amenity = Get-Tag $Tags "amenity"
    $tourism = Get-Tag $Tags "tourism"
    $leisure = Get-Tag $Tags "leisure"
    $natural = Get-Tag $Tags "natural"
    $shop = Get-Tag $Tags "shop"

    if (@("restaurant","fast_food","food_court") -contains $amenity) {
      return @{ category="restaurant"; subCategory=$amenity }
    }
    if (@("cafe","ice_cream") -contains $amenity) {
      return @{ category="cafe"; subCategory=$amenity }
    }
    if (@("bar","pub") -contains $amenity) {
      return @{ category="bar"; subCategory=$amenity }
    }
    if (@("hotel","guest_house","hostel","motel","apartment","apartments","chalet","camp_site","caravan_site","resort") -contains $tourism) {
      return @{ category="accommodation"; subCategory=$tourism }
    }
    if ($natural -eq "beach") {
      return @{ category="beach"; subCategory=$natural }
    }
    if (@("park","dog_park","garden","beach_resort","marina","picnic_table") -contains $leisure) {
      if ($leisure -eq "dog_park") { return @{ category="dog_park"; subCategory=$leisure } }
      return @{ category="outdoor"; subCategory=$leisure }
    }
    if (@("mall","department_store","supermarket","convenience","pet","clothes","sports","outdoor") -contains $shop) {
      return @{ category="shopping"; subCategory=$shop }
    }

    return $null
  }

  function Get-PetPolicy {
    param($Tags)

    $dog = (Get-Tag $Tags "dog").ToLowerInvariant()
    $pets = (Get-Tag $Tags "pets").ToLowerInvariant()
    $petsAllowed = (Get-Tag $Tags "pets_allowed").ToLowerInvariant()

    $scope = "all_or_unspecified"
    $requiresLeash = $false
    $species = @()

    if (-not [string]::IsNullOrWhiteSpace($dog)) { $species += "dog" }
    if (-not [string]::IsNullOrWhiteSpace($pets) -or -not [string]::IsNullOrWhiteSpace($petsAllowed)) { $species += "pet" }
    if ($species.Count -eq 0) { $species += "pet" }

    if ($dog -in @("outside","outdoor","outdoor_seating") -or $pets -in @("outside","outdoor","outdoor_seating")) {
      $scope = "outside_only"
    }

    if ($dog -eq "leashed" -or $pets -eq "leashed") {
      $requiresLeash = $true
    }

    return [ordered]@{
      status = "allowed"
      scope = $scope
      species = @($species | Select-Object -Unique)
      requiresLeash = $requiresLeash
      raw = [ordered]@{
        dog = $dog
        pets = $pets
        petsAllowed = $petsAllowed
      }
    }
  }

  function Invoke-OverpassQuery {
    param([string]$Endpoint, [string]$Query)

    $headers = @{
      "User-Agent" = "PatiParent data seed script; contact: patiparent.com"
      "Accept" = "application/json"
    }

    $encoded = [System.Uri]::EscapeDataString($Query)
    $body = "data=$encoded"

    Log-Line ("Trying endpoint: " + $Endpoint)

    return Invoke-RestMethod `
      -Method Post `
      -Uri $Endpoint `
      -Headers $headers `
      -ContentType "application/x-www-form-urlencoded; charset=UTF-8" `
      -Body $body `
      -TimeoutSec 300
  }

  $query = @'
[out:json][timeout:240];
area["ISO3166-1"="TR"][admin_level=2]->.searchArea;
(
  node["dog"~"^(yes|outside|outdoor|outdoor_seating|leashed|designated|permissive)$"](area.searchArea);
  way["dog"~"^(yes|outside|outdoor|outdoor_seating|leashed|designated|permissive)$"](area.searchArea);
  relation["dog"~"^(yes|outside|outdoor|outdoor_seating|leashed|designated|permissive)$"](area.searchArea);

  node["pets"~"^(yes|allowed|outside|outdoor|outdoor_seating|leashed)$"](area.searchArea);
  way["pets"~"^(yes|allowed|outside|outdoor|outdoor_seating|leashed)$"](area.searchArea);
  relation["pets"~"^(yes|allowed|outside|outdoor|outdoor_seating|leashed)$"](area.searchArea);

  node["pets_allowed"~"^(yes|true|1|allowed)$"](area.searchArea);
  way["pets_allowed"~"^(yes|true|1|allowed)$"](area.searchArea);
  relation["pets_allowed"~"^(yes|true|1|allowed)$"](area.searchArea);
);
out center tags;
'@

  $endpoints = @(
    "https://overpass-api.de/api/interpreter",
    "https://overpass.kumi.systems/api/interpreter"
  )

  $response = $null
  $lastError = $null

  foreach ($endpoint in $endpoints) {
    try {
      $response = Invoke-OverpassQuery -Endpoint $endpoint -Query $query
      if ($null -ne $response -and $null -ne $response.elements) {
        break
      }
    } catch {
      $lastError = $_
      Log-Line ("Endpoint failed: " + $_.Exception.Message)
      Log-Line ""
    }
  }

  if ($null -eq $response -or $null -eq $response.elements) {
    if ($null -ne $lastError) { throw $lastError }
    throw "Overpass response did not include elements."
  }

  $places = @()
  $seen = @{}

  foreach ($el in $response.elements) {
    $tags = $el.tags
    $typeInfo = Get-PlaceType $tags
    if ($null -eq $typeInfo) { continue }

    $lat = $null
    $lon = $null
    if ($null -ne $el.lat -and $null -ne $el.lon) {
      $lat = [double]$el.lat
      $lon = [double]$el.lon
    } elseif ($null -ne $el.center) {
      $lat = [double]$el.center.lat
      $lon = [double]$el.center.lon
    }
    if ($null -eq $lat -or $null -eq $lon) { continue }

    $name = Get-Tag $tags "name:tr"
    if ([string]::IsNullOrWhiteSpace($name)) { $name = Get-Tag $tags "name" }
    if ([string]::IsNullOrWhiteSpace($name)) { $name = Get-Tag $tags "brand" }
    if ([string]::IsNullOrWhiteSpace($name)) { continue }

    $osmKey = "$($el.type)/$($el.id)"
    if ($seen.ContainsKey($osmKey)) { continue }
    $seen[$osmKey] = $true

    $district = Get-Tag $tags "addr:district"
    if ([string]::IsNullOrWhiteSpace($district)) { $district = Get-Tag $tags "addr:suburb" }
    if ([string]::IsNullOrWhiteSpace($district)) { $district = Get-Tag $tags "addr:county" }

    $city = Get-Tag $tags "addr:city"
    if ([string]::IsNullOrWhiteSpace($city)) { $city = Get-Tag $tags "addr:province" }
    if ([string]::IsNullOrWhiteSpace($city)) { $city = Get-Tag $tags "is_in:city" }

    $street = Get-Tag $tags "addr:street"
    $housenumber = Get-Tag $tags "addr:housenumber"
    $neighbourhood = Get-Tag $tags "addr:neighbourhood"
    $addressParts = @($street, $housenumber, $neighbourhood, $district, $city) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    $address = ($addressParts -join ", ")

    $places += [ordered]@{
      id = ("osm_" + $el.type + "_" + $el.id)
      source = "openstreetmap"
      sourceId = $osmKey
      verified = $false
      verificationStatus = "unverified_seed"
      name = $name
      category = $typeInfo.category
      subCategory = $typeInfo.subCategory
      city = $city
      district = $district
      address = $address
      phone = Get-Tag $tags "phone"
      website = Get-Tag $tags "website"
      openingHours = Get-Tag $tags "opening_hours"
      latitude = $lat
      longitude = $lon
      petPolicy = Get-PetPolicy $tags
      userSignals = [ordered]@{
        confirmedCount = 0
        rejectedCount = 0
        lastUserSignalAt = $null
      }
    }
  }

  $places = $places | Sort-Object @{Expression="category"; Ascending=$true}, @{Expression="city"; Ascending=$true}, @{Expression="district"; Ascending=$true}, @{Expression="name"; Ascending=$true}

  $categoryCounts = @{}
  foreach ($p in $places) {
    if (-not $categoryCounts.ContainsKey($p.category)) { $categoryCounts[$p.category] = 0 }
    $categoryCounts[$p.category] += 1
  }

  $missingCityCount = @($places | Where-Object { [string]::IsNullOrWhiteSpace($_.city) }).Count
  $missingContactCount = @($places | Where-Object { [string]::IsNullOrWhiteSpace($_.phone) -and [string]::IsNullOrWhiteSpace($_.website) }).Count

  $out = [ordered]@{
    sourceStatus = "osm_unverified_seed"
    note = "Bu dosya OpenStreetMap dog/pets/pets_allowed etiketlerinden otomatik üretilmiş doğrulanmamış başlangıç datasıdır. Kullanıcıya gösterilecek kritik bilgiler manuel veya kullanıcı sinyalleriyle doğrulanmalıdır."
    generatedAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    license = [ordered]@{
      name = "Open Database License (ODbL)"
      attribution = "© OpenStreetMap contributors"
      url = "https://www.openstreetmap.org/copyright"
    }
    queryTags = @("dog", "pets", "pets_allowed")
    quality = [ordered]@{
      totalPlaces = $places.Count
      missingCityCount = $missingCityCount
      missingContactCount = $missingContactCount
      categoryCounts = $categoryCounts
    }
    places = $places
  }

  $json = $out | ConvertTo-Json -Depth 20
  [System.IO.File]::WriteAllText($target, $json, [System.Text.UTF8Encoding]::new($false))

  $generatedAt = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
  $categorySummary = ($categoryCounts.GetEnumerator() | Sort-Object Name | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join ", "

  $worklogEntry = @"

## $generatedAt - Pati-friendly places seed

- Created/updated: `app/assets/master_data/pati_friendly_places_tr.json`
- Source: OpenStreetMap via Overpass API
- Script: `scripts/download_pati_friendly_places_osm.ps1`
- Total places: $($places.Count)
- Category counts: $categorySummary
- Missing city: $missingCityCount
- Missing phone+website: $missingContactCount
- Status: unverified seed data. Requires user confirmation and/or manual verification before strong claims.
- Attribution to preserve: © OpenStreetMap contributors

"@

  if (Test-Path $worklog) {
    Add-Content -Path $worklog -Value $worklogEntry -Encoding UTF8
  } else {
    Set-Content -Path $worklog -Value ("# DATA_WORKLOG" + [Environment]::NewLine + $worklogEntry) -Encoding UTF8
  }

  $importPlanText = @"
# DATA_IMPORT_PLAN

## Scope

This branch prepares reusable master data for PatiParent without touching UI screens.

Prepared files:

- `app/assets/master_data/veterinary_clinics_tr.json`
- `app/assets/master_data/pati_friendly_places_tr.json`
- `scripts/download_veterinary_clinics_osm.ps1`
- `scripts/download_pati_friendly_places_osm.ps1`

## Recommended Firestore collections

### `veterinaryClinics`

Use records from `veterinary_clinics_tr.json`.

Recommended indexes:

- `city`
- `city + district`
- `verified + city`
- Later: geohash/location index for near-me search

### `patiFriendlyPlaces`

Use records from `pati_friendly_places_tr.json`.

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

Do not present these as guaranteed pet-friendly places.

## Attribution

OpenStreetMap-derived data must preserve attribution:

- "© OpenStreetMap contributors"

Keep the license metadata in JSON files.

## Next app task

Codex should wire the prepared data into app screens/repositories without modifying the source data format unless necessary.
"@
  Set-Content -Path $importPlan -Value $importPlanText -Encoding UTF8

  $promptText = @"
Continue from branch feature/data-downloads.

Read these files first:
- DATA_WORKLOG.md
- DATA_IMPORT_PLAN.md
- app/assets/master_data/veterinary_clinics_tr.json
- app/assets/master_data/pati_friendly_places_tr.json
- scripts/download_veterinary_clinics_osm.ps1
- scripts/download_pati_friendly_places_osm.ps1

Important:
- Do not modify unrelated UI files.
- Treat OpenStreetMap records as unverified seed data.
- Preserve "© OpenStreetMap contributors" attribution.
- Wire data through repositories/services first, then screens.
- Suggested next task: create data repository methods for veterinary clinics and pati-friendly places with category/city/district filters.
"@
  Set-Content -Path $nextPrompt -Value $promptText -Encoding UTF8

  Log-Line ""
  Log-Line ("Saved: " + $target)
  Log-Line ("Place count: " + $places.Count)
  Log-Line ("Category counts: " + $categorySummary)
  Log-Line ("Missing city: " + $missingCityCount)
  Log-Line ("Missing phone+website: " + $missingContactCount)
  Log-Line "Updated: DATA_WORKLOG.md, DATA_IMPORT_PLAN.md, NEXT_CODEX_PROMPT.txt"
  Log-Line ""
  Log-Line "Git status:"
  (git status --short) | ForEach-Object { Log-Line $_ }

  $lines | Set-Content -Path $report -Encoding UTF8
}
catch {
  Log-Line ""
  Log-Line ("ERROR: " + $_.Exception.Message)
  try { $lines | Set-Content -Path $report -Encoding UTF8 } catch {}
  exit 1
}
