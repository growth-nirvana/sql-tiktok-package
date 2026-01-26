-- ad_group_history
-- SCD Type 2 Table for TikTok Ad Groups
{% assign target_dataset = vars.target_dataset_id %}
{% assign target_table_id = 'ad_group_history' %}

{% assign source_dataset = vars.source_dataset_id %}
{% assign source_table_id = 'ad_groups' %}

{% assign drop_source_table = vars.drop_source_table | default: false %}

-- Guard clause: check if source table exists
DECLARE table_exists BOOL DEFAULT FALSE;
SET table_exists = (
  SELECT COUNT(*) > 0
  FROM `{{source_dataset}}.INFORMATION_SCHEMA.TABLES`
  WHERE table_name = '{{source_table_id}}'
);

IF table_exists THEN

ALTER TABLE `{{source_dataset}}.{{source_table_id}}`
  ADD COLUMN IF NOT EXISTS creative_material_mode STRING,
  ADD COLUMN IF NOT EXISTS budget_mode STRING,
  ADD COLUMN IF NOT EXISTS scheduled_budget FLOAT64,
  ADD COLUMN IF NOT EXISTS placement_type STRING,
  ADD COLUMN IF NOT EXISTS languages STRING,
  ADD COLUMN IF NOT EXISTS deep_bid_type STRING,
  ADD COLUMN IF NOT EXISTS skip_learning_phase BOOL,
  ADD COLUMN IF NOT EXISTS gender STRING,
  ADD COLUMN IF NOT EXISTS pixel_id STRING,
  ADD COLUMN IF NOT EXISTS frequency_schedule INT64,
  ADD COLUMN IF NOT EXISTS frequency INT64,
  ADD COLUMN IF NOT EXISTS ios14_quota_type STRING,
  ADD COLUMN IF NOT EXISTS bid_type STRING,
  ADD COLUMN IF NOT EXISTS advertiser_id STRING,
  ADD COLUMN IF NOT EXISTS dayparting STRING,
  ADD COLUMN IF NOT EXISTS pacing STRING,
  ADD COLUMN IF NOT EXISTS is_hfss BOOL,
  ADD COLUMN IF NOT EXISTS campaign_name STRING,
  ADD COLUMN IF NOT EXISTS campaign_id STRING,
  ADD COLUMN IF NOT EXISTS adgroup_name STRING,
  ADD COLUMN IF NOT EXISTS billing_event STRING,
  ADD COLUMN IF NOT EXISTS budget FLOAT64,
  ADD COLUMN IF NOT EXISTS is_new_structure BOOL,
  ADD COLUMN IF NOT EXISTS schedule_type STRING,
  ADD COLUMN IF NOT EXISTS modify_time TIMESTAMP,
  ADD COLUMN IF NOT EXISTS schedule_end_time TIMESTAMP,
  ADD COLUMN IF NOT EXISTS create_time TIMESTAMP,
  ADD COLUMN IF NOT EXISTS schedule_start_time TIMESTAMP;


-- Create SCD table if it doesn't exist
CREATE TABLE IF NOT EXISTS `{{target_dataset}}.{{target_table_id}}` (
  adgroup_id STRING NOT NULL,
  creative_material_mode STRING,
  budget_mode STRING,
  scheduled_budget FLOAT64,
  placement_type STRING,
  languages STRING,
  deep_bid_type STRING,
  skip_learning_phase BOOL,
  gender STRING,
  pixel_id STRING,
  frequency_schedule INT64,
  frequency INT64,
  ios14_quota_type STRING,
  bid_type STRING,
  advertiser_id STRING,
  dayparting STRING,
  pacing STRING,
  is_hfss BOOL,
  campaign_name STRING,
  campaign_id STRING,
  adgroup_name STRING,
  billing_event STRING,
  budget FLOAT64,
  is_new_structure BOOL,
  schedule_type STRING,
  modify_time TIMESTAMP,
  schedule_end_time TIMESTAMP,
  create_time TIMESTAMP,
  schedule_start_time TIMESTAMP,
  tenant STRING,
  effective_from TIMESTAMP,
  effective_to TIMESTAMP,
  is_current BOOLEAN,
  _gn_id STRING
);

-- Merge Logic
MERGE `{{target_dataset}}.{{target_table_id}}` AS target
USING (
  SELECT
    SAFE_CAST(adgroup_id AS STRING) AS adgroup_id,
    SAFE_CAST(creative_material_mode AS STRING) AS creative_material_mode,
    SAFE_CAST(budget_mode AS STRING) AS budget_mode,
    SAFE_CAST(scheduled_budget AS FLOAT64) AS scheduled_budget,
    SAFE_CAST(placement_type AS STRING) AS placement_type,
    SAFE_CAST(languages AS STRING) AS languages,
    SAFE_CAST(deep_bid_type AS STRING) AS deep_bid_type,
    SAFE_CAST(skip_learning_phase AS BOOL) AS skip_learning_phase,
    SAFE_CAST(gender AS STRING) AS gender,
    SAFE_CAST(pixel_id AS STRING) AS pixel_id,
    SAFE_CAST(frequency_schedule AS INT64) AS frequency_schedule,
    SAFE_CAST(frequency AS INT64) AS frequency,
    SAFE_CAST(ios14_quota_type AS STRING) AS ios14_quota_type,
    SAFE_CAST(bid_type AS STRING) AS bid_type,
    SAFE_CAST(advertiser_id AS STRING) AS advertiser_id,
    SAFE_CAST(dayparting AS STRING) AS dayparting,
    SAFE_CAST(pacing AS STRING) AS pacing,
    SAFE_CAST(is_hfss AS BOOL) AS is_hfss,
    SAFE_CAST(campaign_name AS STRING) AS campaign_name,
    SAFE_CAST(campaign_id AS STRING) AS campaign_id,
    SAFE_CAST(adgroup_name AS STRING) AS adgroup_name,
    SAFE_CAST(billing_event AS STRING) AS billing_event,
    SAFE_CAST(budget AS FLOAT64) AS budget,
    SAFE_CAST(is_new_structure AS BOOL) AS is_new_structure,
    SAFE_CAST(schedule_type AS STRING) AS schedule_type,
    SAFE_CAST(modify_time AS TIMESTAMP) AS modify_time,
    SAFE_CAST(schedule_end_time AS TIMESTAMP) AS schedule_end_time,
    SAFE_CAST(create_time AS TIMESTAMP) AS create_time,
    SAFE_CAST(schedule_start_time AS TIMESTAMP) AS schedule_start_time,
    SAFE_CAST(tenant AS STRING) AS tenant,
    SAFE_CAST(_time_extracted AS TIMESTAMP) AS effective_from,
    CAST(NULL AS TIMESTAMP) AS effective_to,
    CAST(TRUE AS BOOLEAN) AS is_current,
    TO_HEX(MD5(TO_JSON_STRING([
      SAFE_CAST(adgroup_id AS STRING),
      SAFE_CAST(creative_material_mode AS STRING),
      SAFE_CAST(budget_mode AS STRING),
      SAFE_CAST(scheduled_budget AS STRING),
      SAFE_CAST(placement_type AS STRING),
      SAFE_CAST(languages AS STRING),
      SAFE_CAST(deep_bid_type AS STRING),
      SAFE_CAST(skip_learning_phase AS STRING),
      SAFE_CAST(gender AS STRING),
      SAFE_CAST(pixel_id AS STRING),
      SAFE_CAST(frequency_schedule AS STRING),
      SAFE_CAST(frequency AS STRING),
      SAFE_CAST(ios14_quota_type AS STRING),
      SAFE_CAST(bid_type AS STRING),
      SAFE_CAST(advertiser_id AS STRING),
      SAFE_CAST(dayparting AS STRING),
      SAFE_CAST(pacing AS STRING),
      SAFE_CAST(is_hfss AS STRING),
      SAFE_CAST(campaign_name AS STRING),
      SAFE_CAST(campaign_id AS STRING),
      SAFE_CAST(adgroup_name AS STRING),
      SAFE_CAST(billing_event AS STRING),
      SAFE_CAST(budget AS STRING),
      SAFE_CAST(is_new_structure AS STRING),
      SAFE_CAST(schedule_type AS STRING),
      SAFE_CAST(modify_time AS STRING),
      SAFE_CAST(schedule_end_time AS STRING),
      SAFE_CAST(create_time AS STRING),
      SAFE_CAST(schedule_start_time AS STRING),
      SAFE_CAST(tenant AS STRING)
    ]))) AS _gn_id
  FROM `{{source_dataset}}.{{source_table_id}}`
) AS source
ON target.adgroup_id = source.adgroup_id
WHEN MATCHED THEN UPDATE SET
  creative_material_mode = source.creative_material_mode,
  budget_mode = source.budget_mode,
  scheduled_budget = source.scheduled_budget,
  placement_type = source.placement_type,
  languages = source.languages,
  deep_bid_type = source.deep_bid_type,
  skip_learning_phase = source.skip_learning_phase,
  gender = source.gender,
  pixel_id = source.pixel_id,
  frequency_schedule = source.frequency_schedule,
  frequency = source.frequency,
  ios14_quota_type = source.ios14_quota_type,
  bid_type = source.bid_type,
  advertiser_id = source.advertiser_id,
  dayparting = source.dayparting,
  pacing = source.pacing,
  is_hfss = source.is_hfss,
  campaign_name = source.campaign_name,
  campaign_id = source.campaign_id,
  adgroup_name = source.adgroup_name,
  billing_event = source.billing_event,
  budget = source.budget,
  is_new_structure = source.is_new_structure,
  schedule_type = source.schedule_type,
  modify_time = source.modify_time,
  schedule_end_time = source.schedule_end_time,
  create_time = source.create_time,
  schedule_start_time = source.schedule_start_time,
  tenant = source.tenant,
  effective_from = source.effective_from,
  effective_to = source.effective_to,
  is_current = source.is_current,
  _gn_id = source._gn_id
WHEN NOT MATCHED BY TARGET
  THEN INSERT (
    adgroup_id, creative_material_mode, budget_mode, scheduled_budget, placement_type, languages, deep_bid_type, skip_learning_phase, gender, pixel_id, frequency_schedule, frequency, ios14_quota_type, bid_type, advertiser_id, dayparting, pacing, is_hfss, campaign_name, campaign_id, adgroup_name, billing_event, budget, is_new_structure, schedule_type, modify_time, schedule_end_time, create_time, schedule_start_time, tenant, effective_from, effective_to, is_current, _gn_id
  )
  VALUES (
    source.adgroup_id, source.creative_material_mode, source.budget_mode, source.scheduled_budget, source.placement_type, source.languages, source.deep_bid_type, source.skip_learning_phase, source.gender, source.pixel_id, source.frequency_schedule, source.frequency, source.ios14_quota_type, source.bid_type, source.advertiser_id, source.dayparting, source.pacing, source.is_hfss, source.campaign_name, source.campaign_id, source.adgroup_name, source.billing_event, source.budget, source.is_new_structure, source.schedule_type, source.modify_time, source.schedule_end_time, source.create_time, source.schedule_start_time, source.tenant, source.effective_from, source.effective_to, source.is_current, source._gn_id
  );

-- Optionally drop the source table if drop_source_table is true
{% if drop_source_table %}
  DROP TABLE IF EXISTS `{{source_dataset}}.{{source_table_id}}`;
{% endif %}

END IF; 