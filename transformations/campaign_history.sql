-- campaign_history
-- Simple merge on campaign_id (source truncated each run)
{% assign target_dataset = vars.target_dataset_id %}
{% assign target_table_id = 'campaign_history' %}

{% assign source_dataset = vars.source_dataset_id %}
{% assign source_table_id = 'campaigns' %}

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
  ADD COLUMN IF NOT EXISTS campaign_id STRING,
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
  ADD COLUMN IF NOT EXISTS modify_time TIMESTAMP,
  ADD COLUMN IF NOT EXISTS tenant STRING;

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
  _gn_synced TIMESTAMP
);

MERGE `{{target_dataset}}.{{target_table_id}}` AS target
USING `{{source_dataset}}.{{source_table_id}}` AS source
ON target.campaign_id = source.campaign_id
WHEN MATCHED THEN UPDATE SET
  campaign_name = SAFE_CAST(source.campaign_name AS STRING),
  campaign_type = SAFE_CAST(source.campaign_type AS STRING),
  objective = SAFE_CAST(source.objective AS STRING),
  objective_type = SAFE_CAST(source.objective_type AS STRING),
  advertiser_id = SAFE_CAST(source.advertiser_id AS STRING),
  budget_mode = SAFE_CAST(source.budget_mode AS STRING),
  is_new_structure = SAFE_CAST(source.is_new_structure AS BOOL),
  budget = SAFE_CAST(source.budget AS FLOAT64),
  roas_bid = SAFE_CAST(source.roas_bid AS FLOAT64),
  create_time = SAFE_CAST(source.create_time AS TIMESTAMP),
  modify_time = SAFE_CAST(source.modify_time AS TIMESTAMP),
  tenant = SAFE_CAST(source.tenant AS STRING),
  _gn_synced = CURRENT_TIMESTAMP()
WHEN NOT MATCHED THEN INSERT (
  campaign_id, campaign_name, campaign_type, objective, objective_type, advertiser_id, budget_mode, is_new_structure, budget, roas_bid, create_time, modify_time, tenant, _gn_synced
)
VALUES (
  source.campaign_id,
  SAFE_CAST(source.campaign_name AS STRING),
  SAFE_CAST(source.campaign_type AS STRING),
  SAFE_CAST(source.objective AS STRING),
  SAFE_CAST(source.objective_type AS STRING),
  SAFE_CAST(source.advertiser_id AS STRING),
  SAFE_CAST(source.budget_mode AS STRING),
  SAFE_CAST(source.is_new_structure AS BOOL),
  SAFE_CAST(source.budget AS FLOAT64),
  SAFE_CAST(source.roas_bid AS FLOAT64),
  SAFE_CAST(source.create_time AS TIMESTAMP),
  SAFE_CAST(source.modify_time AS TIMESTAMP),
  SAFE_CAST(source.tenant AS STRING),
  CURRENT_TIMESTAMP()
);

{% if drop_source_table %}
DROP TABLE IF EXISTS `{{source_dataset}}.{{source_table_id}}`;
{% endif %}

END IF;
