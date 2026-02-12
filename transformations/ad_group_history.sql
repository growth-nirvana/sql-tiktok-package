-- ad_group_history
-- Simple merge on adgroup_id (source truncated each run)
{% assign target_dataset = vars.target_dataset_id %}
{% assign target_table_id = 'ad_group_history' %}

{% assign source_dataset = vars.source_dataset_id %}
{% assign source_table_id = 'ad_groups' %}

{% assign drop_source_table = vars.drop_source_table | default: false %}

DECLARE table_exists BOOL DEFAULT FALSE;
SET table_exists = (
  SELECT COUNT(*) > 0
  FROM `{{source_dataset}}.INFORMATION_SCHEMA.TABLES`
  WHERE table_name = '{{source_table_id}}'
);

IF table_exists THEN

-- Ensure source table has all columns (tap may omit columns not in API response)
ALTER TABLE `{{source_dataset}}.{{source_table_id}}`
  ADD COLUMN IF NOT EXISTS adgroup_id STRING,
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
  ADD COLUMN IF NOT EXISTS schedule_start_time TIMESTAMP,
  ADD COLUMN IF NOT EXISTS tenant STRING;

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
  _gn_synced TIMESTAMP
);

MERGE `{{target_dataset}}.{{target_table_id}}` AS target
USING `{{source_dataset}}.{{source_table_id}}` AS source
ON target.adgroup_id = source.adgroup_id
WHEN MATCHED THEN UPDATE SET
  creative_material_mode = SAFE_CAST(source.creative_material_mode AS STRING),
  budget_mode = SAFE_CAST(source.budget_mode AS STRING),
  scheduled_budget = SAFE_CAST(source.scheduled_budget AS FLOAT64),
  placement_type = SAFE_CAST(source.placement_type AS STRING),
  languages = SAFE_CAST(source.languages AS STRING),
  deep_bid_type = SAFE_CAST(source.deep_bid_type AS STRING),
  skip_learning_phase = SAFE_CAST(source.skip_learning_phase AS BOOL),
  gender = SAFE_CAST(source.gender AS STRING),
  pixel_id = SAFE_CAST(source.pixel_id AS STRING),
  frequency_schedule = SAFE_CAST(source.frequency_schedule AS INT64),
  frequency = SAFE_CAST(source.frequency AS INT64),
  ios14_quota_type = SAFE_CAST(source.ios14_quota_type AS STRING),
  bid_type = SAFE_CAST(source.bid_type AS STRING),
  advertiser_id = SAFE_CAST(source.advertiser_id AS STRING),
  dayparting = SAFE_CAST(source.dayparting AS STRING),
  pacing = SAFE_CAST(source.pacing AS STRING),
  is_hfss = SAFE_CAST(source.is_hfss AS BOOL),
  campaign_name = SAFE_CAST(source.campaign_name AS STRING),
  campaign_id = SAFE_CAST(source.campaign_id AS STRING),
  adgroup_name = SAFE_CAST(source.adgroup_name AS STRING),
  billing_event = SAFE_CAST(source.billing_event AS STRING),
  budget = SAFE_CAST(source.budget AS FLOAT64),
  is_new_structure = SAFE_CAST(source.is_new_structure AS BOOL),
  schedule_type = SAFE_CAST(source.schedule_type AS STRING),
  modify_time = SAFE_CAST(source.modify_time AS TIMESTAMP),
  schedule_end_time = SAFE_CAST(source.schedule_end_time AS TIMESTAMP),
  create_time = SAFE_CAST(source.create_time AS TIMESTAMP),
  schedule_start_time = SAFE_CAST(source.schedule_start_time AS TIMESTAMP),
  tenant = SAFE_CAST(source.tenant AS STRING),
  _gn_synced = CURRENT_TIMESTAMP()
WHEN NOT MATCHED THEN INSERT (
  adgroup_id, creative_material_mode, budget_mode, scheduled_budget, placement_type, languages, deep_bid_type, skip_learning_phase, gender, pixel_id, frequency_schedule, frequency, ios14_quota_type, bid_type, advertiser_id, dayparting, pacing, is_hfss, campaign_name, campaign_id, adgroup_name, billing_event, budget, is_new_structure, schedule_type, modify_time, schedule_end_time, create_time, schedule_start_time, tenant, _gn_synced
)
VALUES (
  SAFE_CAST(source.adgroup_id AS STRING),
  SAFE_CAST(source.creative_material_mode AS STRING),
  SAFE_CAST(source.budget_mode AS STRING),
  SAFE_CAST(source.scheduled_budget AS FLOAT64),
  SAFE_CAST(source.placement_type AS STRING),
  SAFE_CAST(source.languages AS STRING),
  SAFE_CAST(source.deep_bid_type AS STRING),
  SAFE_CAST(source.skip_learning_phase AS BOOL),
  SAFE_CAST(source.gender AS STRING),
  SAFE_CAST(source.pixel_id AS STRING),
  SAFE_CAST(source.frequency_schedule AS INT64),
  SAFE_CAST(source.frequency AS INT64),
  SAFE_CAST(source.ios14_quota_type AS STRING),
  SAFE_CAST(source.bid_type AS STRING),
  SAFE_CAST(source.advertiser_id AS STRING),
  SAFE_CAST(source.dayparting AS STRING),
  SAFE_CAST(source.pacing AS STRING),
  SAFE_CAST(source.is_hfss AS BOOL),
  SAFE_CAST(source.campaign_name AS STRING),
  SAFE_CAST(source.campaign_id AS STRING),
  SAFE_CAST(source.adgroup_name AS STRING),
  SAFE_CAST(source.billing_event AS STRING),
  SAFE_CAST(source.budget AS FLOAT64),
  SAFE_CAST(source.is_new_structure AS BOOL),
  SAFE_CAST(source.schedule_type AS STRING),
  SAFE_CAST(source.modify_time AS TIMESTAMP),
  SAFE_CAST(source.schedule_end_time AS TIMESTAMP),
  SAFE_CAST(source.create_time AS TIMESTAMP),
  SAFE_CAST(source.schedule_start_time AS TIMESTAMP),
  SAFE_CAST(source.tenant AS STRING),
  CURRENT_TIMESTAMP()
);

{% if drop_source_table %}
DROP TABLE IF EXISTS `{{source_dataset}}.{{source_table_id}}`;
{% endif %}

END IF;
