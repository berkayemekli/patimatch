-- Practical SQL questions for PatiParent analytics.

-- 1. Daily product health.
SELECT
  metric_date,
  new_users,
  active_users,
  new_pets,
  completed_pet_profiles,
  walk_requests,
  bnb_requests,
  adoption_applications,
  verified_users
FROM `patiparent_analytics.daily_metrics`
ORDER BY metric_date DESC
LIMIT 30;

-- 2. Which cities have demand but not enough supply?
SELECT
  city,
  module,
  active_supply,
  request_count,
  SAFE_DIVIDE(request_count, NULLIF(active_supply, 0)) AS demand_per_supply
FROM `patiparent_analytics.v_city_supply_demand`
ORDER BY demand_per_supply DESC, request_count DESC;

-- 3. Pet profile completion by city.
SELECT
  city,
  COUNT(*) AS users,
  COUNTIF(complete_pet_profiles > 0) AS users_with_complete_pet_profile,
  SAFE_DIVIDE(COUNTIF(complete_pet_profiles > 0), COUNT(*)) AS completion_rate
FROM `patiparent_analytics.v_user_profile_health`
GROUP BY city
ORDER BY users DESC;

-- 4. PatiGezdirme / PatiBnB / PatiFamily demand trend.
SELECT
  metric_date,
  module,
  SUM(request_count) AS request_count,
  SUM(accepted_or_completed_count) AS accepted_or_completed_count,
  SAFE_DIVIDE(SUM(accepted_or_completed_count), SUM(request_count)) AS conversion_rate
FROM `patiparent_analytics.v_module_demand_daily`
GROUP BY metric_date, module
ORDER BY metric_date DESC, module;

-- 5. Login -> pet profile -> request funnel.
SELECT
  metric_date,
  module,
  logged_in_users,
  pet_profile_users,
  request_users,
  SAFE_DIVIDE(pet_profile_users, NULLIF(logged_in_users, 0)) AS login_to_pet_profile,
  SAFE_DIVIDE(request_users, NULLIF(pet_profile_users, 0)) AS pet_profile_to_request
FROM `patiparent_analytics.v_event_funnel_daily`
ORDER BY metric_date DESC, module;

-- 6. Breed distribution.
SELECT
  animal_category,
  breed,
  COUNT(*) AS pet_count
FROM `patiparent_analytics.pets_dim`
GROUP BY animal_category, breed
ORDER BY pet_count DESC
LIMIT 50;

-- 7. PatiVet city coverage.
SELECT
  city,
  SUM(clinic_count) AS clinic_count,
  SUM(verified_clinic_count) AS verified_clinic_count,
  AVG(avg_rating) AS avg_rating,
  SUM(review_count) AS review_count
FROM `patiparent_analytics.v_vet_city_coverage`
GROUP BY city
ORDER BY clinic_count DESC, review_count DESC;
