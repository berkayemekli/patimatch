-- PatiParent SQL analytics views.
-- Run after schema.sql and after data starts landing in the tables.

CREATE OR REPLACE VIEW `patiparent_analytics.v_user_profile_health` AS
SELECT
  u.user_id,
  u.city,
  u.district,
  u.auth_provider,
  u.verification_status,
  u.blue_badge,
  COUNT(p.pet_id) AS pet_count,
  COUNTIF(p.is_profile_complete) AS complete_pet_profiles,
  MAX(u.last_active_at) AS last_active_at,
  DATE(u.created_at) AS user_created_date
FROM `patiparent_analytics.users_dim` u
LEFT JOIN `patiparent_analytics.pets_dim` p
  ON p.owner_user_id = u.user_id
GROUP BY
  u.user_id,
  u.city,
  u.district,
  u.auth_provider,
  u.verification_status,
  u.blue_badge,
  DATE(u.created_at);

CREATE OR REPLACE VIEW `patiparent_analytics.v_module_demand_daily` AS
SELECT
  DATE(created_at) AS metric_date,
  module,
  city,
  district,
  COUNT(*) AS request_count,
  COUNTIF(status IN ('accepted', 'completed')) AS accepted_or_completed_count,
  COUNTIF(status = 'cancelled') AS cancelled_count,
  AVG(estimated_price) AS avg_estimated_price
FROM `patiparent_analytics.requests_fact`
GROUP BY metric_date, module, city, district;

CREATE OR REPLACE VIEW `patiparent_analytics.v_event_funnel_daily` AS
SELECT
  DATE(created_at) AS metric_date,
  module,
  COUNT(DISTINCT IF(event_name = 'login_success', user_id, NULL)) AS logged_in_users,
  COUNT(DISTINCT IF(event_name = 'pet_profile_saved', user_id, NULL)) AS pet_profile_users,
  COUNT(DISTINCT IF(event_name IN (
    'walk_request_created',
    'bnb_request_created',
    'adoption_application_created'
  ), user_id, NULL)) AS request_users
FROM `patiparent_analytics.analytics_events_fact`
GROUP BY metric_date, module;

CREATE OR REPLACE VIEW `patiparent_analytics.v_city_supply_demand` AS
SELECT
  COALESCE(s.city, d.city) AS city,
  COALESCE(s.module, d.module) AS module,
  COUNT(DISTINCT s.supply_id) AS active_supply,
  SUM(COALESCE(d.request_count, 0)) AS request_count
FROM `patiparent_analytics.service_supply_dim` s
FULL OUTER JOIN `patiparent_analytics.v_module_demand_daily` d
  ON d.city = s.city
  AND d.module = s.module
WHERE s.status = 'active' OR s.status IS NULL
GROUP BY city, module;

CREATE OR REPLACE VIEW `patiparent_analytics.v_vet_city_coverage` AS
SELECT
  city,
  district,
  COUNT(*) AS clinic_count,
  COUNTIF(verification_status = 'verified') AS verified_clinic_count,
  AVG(rating) AS avg_rating,
  SUM(review_count) AS review_count
FROM `patiparent_analytics.veterinary_clinics_dim`
WHERE status IN ('active', 'seed')
GROUP BY city, district;
