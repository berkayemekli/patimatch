$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$repo = "C:\AI\Dog_Date"
$target = Join-Path $repo "app\assets\master_data\veterinary_clinics_tr.json"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Get-Tag {
  param($Tags, [string]$Key)
  if ($null -eq $Tags) { return "" }
  $prop = $Tags.PSObject.Properties[$Key]
  if ($null -eq $prop -or $null -eq $prop.Value) { return "" }
  return ([string]$prop.Value).Trim()
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
    -TimeoutSec 240
}

$query = @'
[out:json][timeout:180];
area["ISO3166-1"="TR"][admin_level=2]->.searchArea;
(
  node["amenity"="veterinary"](area.searchArea);
  way["amenity"="veterinary"](area.searchArea);
  relation["amenity"="veterinary"](area.searchArea);
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
  if ($null -ne $lastError) {
    throw $lastError
  }
  throw "Overpass response did not include elements."
}

$clinics = @()

foreach ($el in $response.elements) {
  $tags = $el.tags

  $name = Get-Tag $tags "name"
  if ([string]::IsNullOrWhiteSpace($name)) {
    $name = Get-Tag $tags "brand"
  }
  if ([string]::IsNullOrWhiteSpace($name)) {
    $name = "Veteriner kliniği"
  }

  $lat = $null
  $lon = $null
  if ($null -ne $el.lat -and $null -ne $el.lon) {
    $lat = [double]$el.lat
    $lon = [double]$el.lon
  } elseif ($null -ne $el.center) {
    $lat = [double]$el.center.lat
    $lon = [double]$el.center.lon
  }

  if ($null -eq $lat -or $null -eq $lon) {
    continue
  }

  $street = Get-Tag $tags "addr:street"
  $housenumber = Get-Tag $tags "addr:housenumber"
  $neighbourhood = Get-Tag $tags "addr:neighbourhood"
  $district = Get-Tag $tags "addr:district"
  if ([string]::IsNullOrWhiteSpace($district)) { $district = Get-Tag $tags "addr:suburb" }
  $city = Get-Tag $tags "addr:city"
  if ([string]::IsNullOrWhiteSpace($city)) { $city = Get-Tag $tags "addr:province" }

  $addressParts = @($street, $housenumber, $neighbourhood, $district, $city) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
  $address = ($addressParts -join ", ")

  $osmId = "$($el.type)/$($el.id)"

  $clinics += [ordered]@{
    id = ("osm_" + $el.type + "_" + $el.id)
    source = "openstreetmap"
    sourceId = $osmId
    verified = $false
    name = $name
    city = $city
    district = $district
    address = $address
    phone = Get-Tag $tags "phone"
    website = Get-Tag $tags "website"
    openingHours = Get-Tag $tags "opening_hours"
    latitude = $lat
    longitude = $lon
    category = "veterinary_clinic"
    tags = @("veteriner", "klinik")
  }
}

$clinics = $clinics | Sort-Object @{Expression="city"; Ascending=$true}, @{Expression="district"; Ascending=$true}, @{Expression="name"; Ascending=$true}

$out = [ordered]@{
  sourceStatus = "osm_unverified_seed"
  note = "Bu dosya OpenStreetMap amenity=veterinary verisinden otomatik üretilmiş doğrulanmamış başlangıç datasıdır. Kullanıcıya gösterilecek kritik bilgiler manuel veya sağlayıcı API ile doğrulanmalıdır."
  generatedAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
  license = [ordered]@{
    name = "Open Database License (ODbL)"
    attribution = "© OpenStreetMap contributors"
    url = "https://www.openstreetmap.org/copyright"
  }
  clinics = $clinics
}

$json = $out | ConvertTo-Json -Depth 20
[System.IO.File]::WriteAllText($target, $json, [System.Text.UTF8Encoding]::new($false))

Write-Host ("Saved: " + $target)
Write-Host ("Clinic count: " + $clinics.Count)
