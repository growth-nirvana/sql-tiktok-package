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

-- Extract latest snapshot from source
CREATE TEMP TABLE latest_snapshot AS
SELECT
  *,
  ROW_NUMBER() OVER (PARTITION BY adgroup_id ORDER BY _time_extracted DESC) AS rn
FROM `{{source_dataset}}.{{source_table_id}}`;

-- SCD Merge Logic
MERGE `{{target_dataset}}.{{target_table_id}}` AS target
USING (
  SELECT
    adgroup_id,
    creative_material_mode,
    budget_mode,
    scheduled_budget,
    placement_type,
    languages,
    deep_bid_type,
    skip_learning_phase,
    gender,
    pixel_id,
    frequency_schedule,
    frequency,
    ios14_quota_type,
    bid_type,
    advertiser_id,
    dayparting,
    pacing,
    is_hfss,
    campaign_name,
    campaign_id,
    adgroup_name,
    billing_event,
    budget,
    is_new_structure,
    schedule_type,
    modify_time,
    schedule_end_time,
    create_time,
    schedule_start_time,
    tenant,
    _time_extracted AS effective_from,
    CAST(NULL AS TIMESTAMP) AS effective_to,
    TRUE AS is_current,
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
  FROM latest_snapshot
  WHERE rn = 1
) AS source
ON target.adgroup_id = source.adgroup_id AND target.is_current = TRUE
WHEN MATCHED AND
  TO_HEX(MD5(TO_JSON_STRING([
    SAFE_CAST(target.adgroup_id AS STRING),
    SAFE_CAST(target.creative_material_mode AS STRING),
    SAFE_CAST(target.budget_mode AS STRING),
    SAFE_CAST(target.scheduled_budget AS STRING),
    SAFE_CAST(target.placement_type AS STRING),
    SAFE_CAST(target.languages AS STRING),
    SAFE_CAST(target.deep_bid_type AS STRING),
    SAFE_CAST(target.skip_learning_phase AS STRING),
    SAFE_CAST(target.gender AS STRING),
    SAFE_CAST(target.pixel_id AS STRING),
    SAFE_CAST(target.frequency_schedule AS STRING),
    SAFE_CAST(target.frequency AS STRING),
    SAFE_CAST(target.ios14_quota_type AS STRING),
    SAFE_CAST(target.bid_type AS STRING),
    SAFE_CAST(target.advertiser_id AS STRING),
    SAFE_CAST(target.dayparting AS STRING),
    SAFE_CAST(target.pacing AS STRING),
    SAFE_CAST(target.is_hfss AS STRING),
    SAFE_CAST(target.campaign_name AS STRING),
    SAFE_CAST(target.campaign_id AS STRING),
    SAFE_CAST(target.adgroup_name AS STRING),
    SAFE_CAST(target.billing_event AS STRING),
    SAFE_CAST(target.budget AS STRING),
    SAFE_CAST(target.is_new_structure AS STRING),
    SAFE_CAST(target.schedule_type AS STRING),
    SAFE_CAST(target.modify_time AS STRING),
    SAFE_CAST(target.schedule_end_time AS STRING),
    SAFE_CAST(target.create_time AS STRING),
    SAFE_CAST(target.schedule_start_time AS STRING),
    SAFE_CAST(target.tenant AS STRING)
  ]))) !=
  TO_HEX(MD5(TO_JSON_STRING([
    SAFE_CAST(source.adgroup_id AS STRING),
    SAFE_CAST(source.creative_material_mode AS STRING),
    SAFE_CAST(source.budget_mode AS STRING),
    SAFE_CAST(source.scheduled_budget AS STRING),
    SAFE_CAST(source.placement_type AS STRING),
    SAFE_CAST(source.languages AS STRING),
    SAFE_CAST(source.deep_bid_type AS STRING),
    SAFE_CAST(source.skip_learning_phase AS STRING),
    SAFE_CAST(source.gender AS STRING),
    SAFE_CAST(source.pixel_id AS STRING),
    SAFE_CAST(source.frequency_schedule AS STRING),
    SAFE_CAST(source.frequency AS STRING),
    SAFE_CAST(source.ios14_quota_type AS STRING),
    SAFE_CAST(source.bid_type AS STRING),
    SAFE_CAST(source.advertiser_id AS STRING),
    SAFE_CAST(source.dayparting AS STRING),
    SAFE_CAST(source.pacing AS STRING),
    SAFE_CAST(source.is_hfss AS STRING),
    SAFE_CAST(source.campaign_name AS STRING),
    SAFE_CAST(source.campaign_id AS STRING),
    SAFE_CAST(source.adgroup_name AS STRING),
    SAFE_CAST(source.billing_event AS STRING),
    SAFE_CAST(source.budget AS STRING),
    SAFE_CAST(source.is_new_structure AS STRING),
    SAFE_CAST(source.schedule_type AS STRING),
    SAFE_CAST(source.modify_time AS STRING),
    SAFE_CAST(source.schedule_end_time AS STRING),
    SAFE_CAST(source.create_time AS STRING),
    SAFE_CAST(source.schedule_start_time AS STRING),
    SAFE_CAST(source.tenant AS STRING)
  ])))
  THEN UPDATE SET
    effective_to = source.effective_from,
    is_current = FALSE
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