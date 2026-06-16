$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$repo = "C:\AI\Dog_Date"
$target = Join-Path $repo "app\assets\master_data\dog_trainers_tr.json"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Get-Tag {
  param($Tags, [string]$Key)
  if ($null -eq $Tags) { return "" }
  $prop = $Tags.PSObject.Properties[$Key]
  if ($null -eq $prop -or $null -eq $prop.Value) { return "" }
  return ([string]$prop.Value).Trim()
}

function Has-TrainingSignal {
  param($Tags)

  $name = ((Get-Tag $Tags "name") + " " + (Get-Tag $Tags "name:tr") + " " + (Get-Tag $Tags "brand")).ToLowerInvariant()
  $description = ((Get-Tag $Tags "description") + " " + (Get-Tag $Tags "description:tr") + " " + (Get-Tag $Tags "services")).ToLowerInvariant()
  $training = ((Get-Tag $Tags "animal_training") + " " + (Get-Tag $Tags "service:animal:training") + " " + (Get-Tag $Tags "dog:training") + " " + (Get-Tag $Tags "training")).ToLowerInvariant()
  $amenity = (Get-Tag $Tags "amenity").ToLowerInvariant()
  $shop = (Get-Tag $Tags "shop").ToLowerInvariant()

  if ($amenity -in @("animal_training", "dog_training", "training")) { return $true }
  if ($shop -in @("pet_training", "dog_training")) { return $true }
  if ($training -match "(yes|true|1|dog|animal|obedience|puppy)") { return $true }
  if ($name -match "(k.pek.*e.it|e.it.*k.pek|dog.*train|train.*dog|obedience|canine|pati.*e.it)") { return $true }
  if ($description -match "(kopek.*egit|egit.*kopek|dog.*train|obedience|puppy|davranis|itaat|davranis)") { return $true }
  return $false
}

function Invoke-OverpassQuery {
  param(
    [string]$Endpoint,
    [string]$Query
  )

  $headers = @{
    "User-Agent" = "PatiParent data seed script; contact: patiparent.com"
    "Accept" = "application/json"
  }

  $encoded = [System.Uri]::EscapeDataString($Query)
  $body = "data=$encoded"

  Write-Host ("Trying endpoint: " + $Endpoint)

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
  node["amenity"~"^(animal_training|dog_training|training)$"](area.searchArea);
  way["amenity"~"^(animal_training|dog_training|training)$"](area.searchArea);
  relation["amenity"~"^(animal_training|dog_training|training)$"](area.searchArea);

  node["shop"~"^(pet_training|dog_training)$"](area.searchArea);
  way["shop"~"^(pet_training|dog_training)$"](area.searchArea);
  relation["shop"~"^(pet_training|dog_training)$"](area.searchArea);

  node["animal_training"](area.searchArea);
  way["animal_training"](area.searchArea);
  relation["animal_training"](area.searchArea);

  node["service:animal:training"](area.searchArea);
  way["service:animal:training"](area.searchArea);
  relation["service:animal:training"](area.searchArea);

  node["dog:training"](area.searchArea);
  way["dog:training"](area.searchArea);
  relation["dog:training"](area.searchArea);

  node["name"~"(k.pek.*e.it|e.it.*k.pek|dog.*train|Dog.*Train|canine|Canine|obedience|pati.*e.it)", i](area.searchArea);
  way["name"~"(k.pek.*e.it|e.it.*k.pek|dog.*train|Dog.*Train|canine|Canine|obedience|pati.*e.it)", i](area.searchArea);
  relation["name"~"(k.pek.*e.it|e.it.*k.pek|dog.*train|Dog.*Train|canine|Canine|obedience|pati.*e.it)", i](area.searchArea);
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
    Write-Host ("Endpoint failed: " + $_.Exception.Message)
    Write-Host ""
  }
}

if ($null -eq $response -or $null -eq $response.elements) {
  if ($null -ne $lastError) { throw $lastError }
  throw "Overpass response did not include elements."
}

$trainers = @()
$seen = @{}

foreach ($el in $response.elements) {
  $tags = $el.tags
  if (-not (Has-TrainingSignal $tags)) { continue }

  $name = Get-Tag $tags "name:tr"
  if ([string]::IsNullOrWhiteSpace($name)) { $name = Get-Tag $tags "name" }
  if ([string]::IsNullOrWhiteSpace($name)) { $name = Get-Tag $tags "brand" }
  if ([string]::IsNullOrWhiteSpace($name)) { $name = "Kopek egitmeni" }

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

  $serviceSignals = @()
  if (-not [string]::IsNullOrWhiteSpace((Get-Tag $tags "animal_training"))) { $serviceSignals += "animal_training" }
  if (-not [string]::IsNullOrWhiteSpace((Get-Tag $tags "service:animal:training"))) { $serviceSignals += "service_animal_training" }
  if (-not [string]::IsNullOrWhiteSpace((Get-Tag $tags "dog:training"))) { $serviceSignals += "dog_training" }
  if ((Get-Tag $tags "name") -match "(k.pek.*e.it|e.it.*k.pek|dog.*train|canine|obedience|pati.*e.it)") { $serviceSignals += "name_signal" }
  if ($serviceSignals.Count -eq 0) { $serviceSignals += "inferred_from_osm" }

  $trainers += [ordered]@{
    id = ("osm_" + $el.type + "_" + $el.id)
    source = "openstreetmap"
    sourceId = $osmKey
    verified = $false
    verificationStatus = "unverified_seed"
    name = $name
    city = $city
    district = $district
    address = $address
    phone = Get-Tag $tags "phone"
    website = Get-Tag $tags "website"
    openingHours = Get-Tag $tags "opening_hours"
    latitude = $lat
    longitude = $lon
    category = "dog_trainer"
    acceptedSpecies = @("dog")
    trainingTypes = @("basic_obedience", "puppy_training", "behavior_support")
    serviceSignals = @($serviceSignals | Select-Object -Unique)
    tags = @("kopek egitimi", "itaat", "davranis destegi")
  }
}

$trainers = $trainers | Sort-Object @{Expression="city"; Ascending=$true}, @{Expression="district"; Ascending=$true}, @{Expression="name"; Ascending=$true}

$missingCityCount = @($trainers | Where-Object { [string]::IsNullOrWhiteSpace($_.city) }).Count
$missingContactCount = @($trainers | Where-Object { [string]::IsNullOrWhiteSpace($_.phone) -and [string]::IsNullOrWhiteSpace($_.website) }).Count

$out = [ordered]@{
  sourceStatus = "osm_unverified_seed"
  note = "Bu dosya OpenStreetMap kopek egitimi/dog training sinyallerinden otomatik uretilmis dogrulanmamis baslangic datasidir. Kullaniciya gosterilecek kritik bilgiler manuel veya saglayici API ile dogrulanmalidir."
  generatedAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
  license = [ordered]@{
    name = "Open Database License (ODbL)"
    attribution = "OpenStreetMap contributors"
    url = "https://www.openstreetmap.org/copyright"
  }
  queryTags = @("animal_training", "service:animal:training", "dog:training", "dog trainer name signals")
  quality = [ordered]@{
    totalTrainers = $trainers.Count
    missingCityCount = $missingCityCount
    missingContactCount = $missingContactCount
  }
  trainers = $trainers
}

$json = $out | ConvertTo-Json -Depth 20
[System.IO.File]::WriteAllText($target, $json, [System.Text.UTF8Encoding]::new($false))

Write-Host ("Saved: " + $target)
Write-Host ("Trainer count: " + $trainers.Count)


