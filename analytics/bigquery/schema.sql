-- PatiParent SQL analytics warehouse schema.
-- Target engine: BigQuery Standard SQL.
-- Dataset suggestion: `patiparent_analytics`.

CREATE TABLE IF NOT EXISTS `patiparent_analytics.users_dim` (
  user_id STRING NOT NULL,
  display_name STRING,
  email STRING,
  phone STRING,
  city STRING,
  district STRING,
  auth_provider STRING,
  verification_status STRING,
  blue_badge BOOL,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  last_active_at TIMESTAMP
)
PARTITION BY DATE(created_at)
CLUSTER BY city, district, verification_status;

CREATE TABLE IF NOT EXISTS `patiparent_analytics.pets_dim` (
  pet_id STRING NOT NULL,
  owner_user_id STRING NOT NULL,
  name STRING,
  animal_category STRING,
  breed STRING,
  age_months INT64,
  weight_kg NUMERIC,
  city STRING,
  district STRING,
  is_profile_complete BOOL,
  vaccination_filled BOOL,
  microchip_filled BOOL,
  passport_filled BOOL,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
)
PARTITION BY DATE(created_at)
CLUSTER BY animal_category, breed, city;

CREATE TABLE IF NOT EXISTS `patiparent_analytics.service_supply_dim` (
  supply_id STRING NOT NULL,
  owner_user_id STRING,
  module STRING NOT NULL,
  display_name STRING,
  city STRING,
  district STRING,
  accepted_pet_types ARRAY<STRING>,
  accepted_breeds ARRAY<STRING>,
  badges ARRAY<STRING>,
  rating NUMERIC,
  completed_jobs INT64,
  status STRING,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
)
PARTITION BY DATE(created_at)
CLUSTER BY module, city, status;

CREATE TABLE IF NOT EXISTS `patiparent_analytics.requests_fact` (
  request_id STRING NOT NULL,
  module STRING NOT NULL,
  requester_user_id STRING NOT NULL,
  requester_pet_id STRING,
  supply_id STRING,
  supply_owner_user_id STRING,
  city STRING,
  district STRING,
  preferred_at TIMESTAMP,
  check_in TIMESTAMP,
  check_out TIMESTAMP,
  status STRING,
  estimated_price NUMERIC,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
)
PARTITION BY DATE(created_at)
CLUSTER BY module, city, status;

CREATE TABLE IF NOT EXISTS `patiparent_analytics.adoption_applications_fact` (
  application_id STRING NOT NULL,
  requester_user_id STRING NOT NULL,
  requester_pet_id STRING,
  post_id STRING NOT NULL,
  owner_user_id STRING,
  animal_category STRING,
  breed STRING,
  city STRING,
  district STRING,
  urgency STRING,
  status STRING,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
)
PARTITION BY DATE(created_at)
CLUSTER BY city, urgency, status;

CREATE TABLE IF NOT EXISTS `patiparent_analytics.veterinary_clinics_dim` (
  clinic_id STRING NOT NULL,
  name STRING NOT NULL,
  city STRING,
  district STRING,
  services ARRAY<STRING>,
  badges ARRAY<STRING>,
  rating NUMERIC,
  review_count INT64,
  source STRING,
  verification_status STRING,
  status STRING,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
)
PARTITION BY DATE(created_at)
CLUSTER BY city, district, verification_status;

CREATE TABLE IF NOT EXISTS `patiparent_analytics.vet_reviews_fact` (
  review_id STRING NOT NULL,
  clinic_id STRING NOT NULL,
  user_id STRING,
  pet_id STRING,
  rating INT64,
  visit_reason STRING,
  review_text STRING,
  moderation_status STRING,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
)
PARTITION BY DATE(created_at)
CLUSTER BY clinic_id, moderation_status;

CREATE TABLE IF NOT EXISTS `patiparent_analytics.analytics_events_fact` (
  event_id STRING NOT NULL,
  user_id STRING,
  event_name STRING NOT NULL,
  module STRING,
  entity_type STRING,
  entity_id STRING,
  properties JSON,
  created_at TIMESTAMP NOT NULL
)
PARTITION BY DATE(created_at)
CLUSTER BY event_name, module, user_id;

CREATE TABLE IF NOT EXISTS `patiparent_analytics.daily_metrics` (
  metric_date DATE NOT NULL,
  new_users INT64,
  active_users INT64,
  new_pets INT64,
  completed_pet_profiles INT64,
  walk_requests INT64,
  bnb_requests INT64,
  adoption_applications INT64,
  vet_clinic_views INT64,
  vet_reviews INT64,
  verified_users INT64,
  updated_at TIMESTAMP
)
PARTITION BY metric_date;
