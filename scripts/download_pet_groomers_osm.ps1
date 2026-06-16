$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$repo = "C:\AI\Dog_Date"
$target = Join-Path $repo "app\assets\master_data\pet_groomers_tr.json"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Get-Tag {
  param($Tags, [string]$Key)
  if ($null -eq $Tags) { return "" }
  $prop = $Tags.PSObject.Properties[$Key]
  if ($null -eq $prop -or $null -eq $prop.Value) { return "" }
  return ([string]$prop.Value).Trim()
}

function Has-GroomingSignal {
  param($Tags)

  $name = ((Get-Tag $Tags "name") + " " + (Get-Tag $Tags "name:tr") + " " + (Get-Tag $Tags "brand")).ToLowerInvariant()
  $shop = (Get-Tag $Tags "shop").ToLowerInvariant()
  $serviceGrooming = ((Get-Tag $Tags "service:animal:grooming") + " " + (Get-Tag $Tags "grooming") + " " + (Get-Tag $Tags "pet:grooming")).ToLowerInvariant()
  $description = ((Get-Tag $Tags "description") + " " + (Get-Tag $Tags "description:tr") + " " + (Get-Tag $Tags "services")).ToLowerInvariant()

  if ($shop -in @("pet_grooming", "dog_grooming")) { return $true }
  if ($serviceGrooming -match "(yes|true|1|only|available|dog|cat)") { return $true }
  if ($name -match "(kuaf|groom|tra[sş]|bak[ıi]m|pet kuaf|pati kuaf)") { return $true }
  if ($description -match "(kuaf|groom|tra[sş]|bak[ıi]m|y[ıi]kama|t[ıi]ra[sş])") { return $true }
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
  node["shop"~"^(pet_grooming|dog_grooming)$"](area.searchArea);
  way["shop"~"^(pet_grooming|dog_grooming)$"](area.searchArea);
  relation["shop"~"^(pet_grooming|dog_grooming)$"](area.searchArea);

  node["service:animal:grooming"](area.searchArea);
  way["service:animal:grooming"](area.searchArea);
  relation["service:animal:grooming"](area.searchArea);

  node["grooming"](area.searchArea);
  way["grooming"](area.searchArea);
  relation["grooming"](area.searchArea);

  node["shop"]["name"~"(pet.*kuaf|kuaf.*pet|pati.*kuaf|groom|Groom|dog.*kuaf|kedi.*kuaf|köpek.*kuaf|kopek.*kuaf)", i](area.searchArea);
  way["shop"]["name"~"(pet.*kuaf|kuaf.*pet|pati.*kuaf|groom|Groom|dog.*kuaf|kedi.*kuaf|köpek.*kuaf|kopek.*kuaf)", i](area.searchArea);
  relation["shop"]["name"~"(pet.*kuaf|kuaf.*pet|pati.*kuaf|groom|Groom|dog.*kuaf|kedi.*kuaf|köpek.*kuaf|kopek.*kuaf)", i](area.searchArea);
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

$groomers = @()
$seen = @{}

foreach ($el in $response.elements) {
  $tags = $el.tags
  if (-not (Has-GroomingSignal $tags)) { continue }

  $name = Get-Tag $tags "name:tr"
  if ([string]::IsNullOrWhiteSpace($name)) { $name = Get-Tag $tags "name" }
  if ([string]::IsNullOrWhiteSpace($name)) { $name = Get-Tag $tags "brand" }
  if ([string]::IsNullOrWhiteSpace($name)) { $name = "Pet kuaförü" }

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
  if (-not [string]::IsNullOrWhiteSpace((Get-Tag $tags "service:animal:grooming"))) { $serviceSignals += "grooming_tag" }
  if (-not [string]::IsNullOrWhiteSpace((Get-Tag $tags "grooming"))) { $serviceSignals += "grooming" }
  if ((Get-Tag $tags "name") -match "(kuaf|groom|tra[sş]|bak[ıi]m)") { $serviceSignals += "name_signal" }
  if ($serviceSignals.Count -eq 0) { $serviceSignals += "inferred_from_osm" }

  $groomers += [ordered]@{
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
    category = "pet_groomer"
    acceptedSpecies = @("dog", "cat")
    serviceSignals = @($serviceSignals | Select-Object -Unique)
    tags = @("pet kuaförü", "bakım", "grooming")
  }
}

$groomers = $groomers | Sort-Object @{Expression="city"; Ascending=$true}, @{Expression="district"; Ascending=$true}, @{Expression="name"; Ascending=$true}

$missingCityCount = @($groomers | Where-Object { [string]::IsNullOrWhiteSpace($_.city) }).Count
$missingContactCount = @($groomers | Where-Object { [string]::IsNullOrWhiteSpace($_.phone) -and [string]::IsNullOrWhiteSpace($_.website) }).Count

$out = [ordered]@{
  sourceStatus = "osm_unverified_seed"
  note = "Bu dosya OpenStreetMap pet kuafor/grooming sinyallerinden otomatik uretilmis dogrulanmamis baslangic datasidir. Kullaniciya gosterilecek kritik bilgiler manuel veya saglayici API ile dogrulanmalidir."
  generatedAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
  license = [ordered]@{
    name = "Open Database License (ODbL)"
    attribution = "OpenStreetMap contributors"
    url = "https://www.openstreetmap.org/copyright"
  }
  queryTags = @("shop=pet", "shop=pet_grooming", "service:animal:grooming", "grooming", "name grooming signals")
  quality = [ordered]@{
    totalGroomers = $groomers.Count
    missingCityCount = $missingCityCount
    missingContactCount = $missingContactCount
  }
  groomers = $groomers
}

$json = $out | ConvertTo-Json -Depth 20
[System.IO.File]::WriteAllText($target, $json, [System.Text.UTF8Encoding]::new($false))

Write-Host ("Saved: " + $target)
Write-Host ("Groomer count: " + $groomers.Count)
