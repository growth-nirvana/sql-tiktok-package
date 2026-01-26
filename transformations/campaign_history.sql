-- campaign_history
-- SCD Type 2 Table for TikTok Campaigns
{% assign target_dataset = vars.target_dataset_id %}
{% assign target_table_id = 'campaign_history' %}

{% assign source_dataset = vars.source_dataset_id %}
{% assign source_table_id = 'campaigns' %}

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
  ADD COLUMN IF NOT EXISTS campaign_name STRING,
  ADD COLUMN IF NOT EXISTS campaign_type STRING,
  ADD COLUMN IF NOT EXISTS objective STRING,
  ADD COLUMN IF NOT EXISTS objective_type STRING,
  ADD COLUMN IF NOT EXISTS advertiser_id STRING,
  ADD COLUMN IF NOT EXISTS budget_mode STRING,
  ADD COLUMN IF NOT EXISTS is_new_structure BOOL,
  ADD COLUMN IF NOT EXISTS budget FLOAT64,
  ADD COLUMN IF NOT EXISTS roas_bid FLOAT64,
  ADD COLUMN IF NOT EXISTS create_time TIMESTAMP,
  ADD COLUMN IF NOT EXISTS modify_time TIMESTAMP;

-- Create SCD table if it doesn't exist
CREATE TABLE IF NOT EXISTS `{{target_dataset}}.{{target_table_id}}` (
  campaign_id STRING NOT NULL,
  campaign_name STRING,
  campaign_type STRING,
  objective STRING,
  objective_type STRING,
  advertiser_id STRING,
  budget_mode STRING,
  is_new_structure BOOL,
  budget FLOAT64,
  roas_bid FLOAT64,
  create_time TIMESTAMP,
  modify_time TIMESTAMP,
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
    campaign_id,
    campaign_name,
    campaign_type,
    objective,
    objective_type,
    advertiser_id,
    budget_mode,
    is_new_structure,
    budget,
    roas_bid,
    create_time,
    modify_time,
    tenant,
    _time_extracted AS effective_from,
    CAST(NULL AS TIMESTAMP) AS effective_to,
    TRUE AS is_current,
    TO_HEX(MD5(TO_JSON_STRING([
      SAFE_CAST(campaign_id AS STRING),
      SAFE_CAST(campaign_name AS STRING),
      SAFE_CAST(campaign_type AS STRING),
      SAFE_CAST(objective AS STRING),
      SAFE_CAST(objective_type AS STRING),
      SAFE_CAST(advertiser_id AS STRING),
      SAFE_CAST(budget_mode AS STRING),
      SAFE_CAST(is_new_structure AS STRING),
      SAFE_CAST(budget AS STRING),
      SAFE_CAST(roas_bid AS STRING),
      SAFE_CAST(create_time AS STRING),
      SAFE_CAST(modify_time AS STRING),
      SAFE_CAST(tenant AS STRING)
    ]))) AS _gn_id
  FROM `{{source_dataset}}.{{source_table_id}}`
) AS source
ON target.campaign_id = source.campaign_id
WHEN MATCHED THEN UPDATE SET
  campaign_name = source.campaign_name,
  campaign_type = source.campaign_type,
  objective = source.objective,
  objective_type = source.objective_type,
  advertiser_id = source.advertiser_id,
  budget_mode = source.budget_mode,
  is_new_structure = source.is_new_structure,
  budget = source.budget,
  roas_bid = source.roas_bid,
  create_time = source.create_time,
  modify_time = source.modify_time,
  tenant = source.tenant,
  effective_from = source.effective_from,
  effective_to = source.effective_to,
  is_current = source.is_current,
  _gn_id = source._gn_id
WHEN NOT MATCHED BY TARGET
  THEN INSERT (
    campaign_id, campaign_name, campaign_type, objective, objective_type, advertiser_id, budget_mode, is_new_structure, budget, roas_bid, create_time, modify_time, tenant, effective_from, effective_to, is_current, _gn_id
  )
  VALUES (
    source.campaign_id, source.campaign_name, source.campaign_type, source.objective, source.objective_type, source.advertiser_id, source.budget_mode, source.is_new_structure, source.budget, source.roas_bid, source.create_time, source.modify_time, source.tenant, source.effective_from, source.effective_to, source.is_current, source._gn_id
  );

-- Optionally drop the source table if drop_source_table is true
{% if drop_source_table %}
  DROP TABLE IF EXISTS `{{source_dataset}}.{{source_table_id}}`;
{% endif %}

END IF; 