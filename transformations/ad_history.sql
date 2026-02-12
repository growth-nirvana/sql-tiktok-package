-- ad_history
-- Simple merge on ad_id (source truncated each run)
{% assign target_dataset = vars.target_dataset_id %}
{% assign target_table_id = 'ad_history' %}

{% assign source_dataset = vars.source_dataset_id %}
{% assign source_table_id = 'ads' %}

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
  ADD COLUMN IF NOT EXISTS ad_id STRING,
  ADD COLUMN IF NOT EXISTS ad_format STRING,
  ADD COLUMN IF NOT EXISTS campaign_name STRING,
  ADD COLUMN IF NOT EXISTS identity_type STRING,
  ADD COLUMN IF NOT EXISTS campaign_id STRING,
  ADD COLUMN IF NOT EXISTS brand_safety_postbid_partner STRING,
  ADD COLUMN IF NOT EXISTS ad_name STRING,
  ADD COLUMN IF NOT EXISTS avatar_icon_web_uri STRING,
  ADD COLUMN IF NOT EXISTS adgroup_id STRING,
  ADD COLUMN IF NOT EXISTS image_ids STRING,
  ADD COLUMN IF NOT EXISTS call_to_action_id STRING,
  ADD COLUMN IF NOT EXISTS video_id STRING,
  ADD COLUMN IF NOT EXISTS adgroup_name STRING,
  ADD COLUMN IF NOT EXISTS advertiser_id STRING,
  ADD COLUMN IF NOT EXISTS creative_type STRING,
  ADD COLUMN IF NOT EXISTS landing_page_url STRING,
  ADD COLUMN IF NOT EXISTS call_to_action STRING,
  ADD COLUMN IF NOT EXISTS identity_id STRING,
  ADD COLUMN IF NOT EXISTS page_id FLOAT64,
  ADD COLUMN IF NOT EXISTS display_name STRING,
  ADD COLUMN IF NOT EXISTS playable_url STRING,
  ADD COLUMN IF NOT EXISTS is_new_structure BOOL,
  ADD COLUMN IF NOT EXISTS click_tracking_url STRING,
  ADD COLUMN IF NOT EXISTS ad_text STRING,
  ADD COLUMN IF NOT EXISTS is_aco BOOL,
  ADD COLUMN IF NOT EXISTS app_name STRING,
  ADD COLUMN IF NOT EXISTS fallback_type STRING,
  ADD COLUMN IF NOT EXISTS modify_time TIMESTAMP,
  ADD COLUMN IF NOT EXISTS create_time TIMESTAMP,
  ADD COLUMN IF NOT EXISTS tenant STRING;

CREATE TABLE IF NOT EXISTS `{{target_dataset}}.{{target_table_id}}` (
  ad_id STRING NOT NULL,
  ad_format STRING,
  campaign_name STRING,
  identity_type STRING,
  campaign_id STRING,
  brand_safety_postbid_partner STRING,
  ad_name STRING,
  avatar_icon_web_uri STRING,
  adgroup_id STRING,
  image_ids STRING,
  call_to_action_id STRING,
  video_id STRING,
  adgroup_name STRING,
  advertiser_id STRING,
  creative_type STRING,
  landing_page_url STRING,
  call_to_action STRING,
  identity_id STRING,
  page_id FLOAT64,
  display_name STRING,
  playable_url STRING,
  is_new_structure BOOL,
  click_tracking_url STRING,
  ad_text STRING,
  is_aco BOOL,
  app_name STRING,
  fallback_type STRING,
  modify_time TIMESTAMP,
  create_time TIMESTAMP,
  tenant STRING,
  _gn_synced TIMESTAMP
);

MERGE `{{target_dataset}}.{{target_table_id}}` AS target
USING `{{source_dataset}}.{{source_table_id}}` AS source
ON target.ad_id = source.ad_id
WHEN MATCHED THEN UPDATE SET
  ad_format = SAFE_CAST(source.ad_format AS STRING),
  campaign_name = SAFE_CAST(source.campaign_name AS STRING),
  identity_type = SAFE_CAST(source.identity_type AS STRING),
  campaign_id = SAFE_CAST(source.campaign_id AS STRING),
  brand_safety_postbid_partner = SAFE_CAST(source.brand_safety_postbid_partner AS STRING),
  ad_name = SAFE_CAST(source.ad_name AS STRING),
  avatar_icon_web_uri = SAFE_CAST(source.avatar_icon_web_uri AS STRING),
  adgroup_id = SAFE_CAST(source.adgroup_id AS STRING),
  image_ids = SAFE_CAST(source.image_ids AS STRING),
  call_to_action_id = SAFE_CAST(source.call_to_action_id AS STRING),
  video_id = SAFE_CAST(source.video_id AS STRING),
  adgroup_name = SAFE_CAST(source.adgroup_name AS STRING),
  advertiser_id = SAFE_CAST(source.advertiser_id AS STRING),
  creative_type = SAFE_CAST(source.creative_type AS STRING),
  landing_page_url = SAFE_CAST(source.landing_page_url AS STRING),
  call_to_action = SAFE_CAST(source.call_to_action AS STRING),
  identity_id = SAFE_CAST(source.identity_id AS STRING),
  page_id = SAFE_CAST(source.page_id AS FLOAT64),
  display_name = SAFE_CAST(source.display_name AS STRING),
  playable_url = SAFE_CAST(source.playable_url AS STRING),
  is_new_structure = SAFE_CAST(source.is_new_structure AS BOOL),
  click_tracking_url = SAFE_CAST(source.click_tracking_url AS STRING),
  ad_text = SAFE_CAST(source.ad_text AS STRING),
  is_aco = SAFE_CAST(source.is_aco AS BOOL),
  app_name = SAFE_CAST(source.app_name AS STRING),
  fallback_type = SAFE_CAST(source.fallback_type AS STRING),
  modify_time = SAFE_CAST(source.modify_time AS TIMESTAMP),
  create_time = SAFE_CAST(source.create_time AS TIMESTAMP),
  tenant = SAFE_CAST(source.tenant AS STRING),
  _gn_synced = CURRENT_TIMESTAMP()
WHEN NOT MATCHED THEN INSERT (
  ad_id, ad_format, campaign_name, identity_type, campaign_id, brand_safety_postbid_partner, ad_name, avatar_icon_web_uri, adgroup_id, image_ids, call_to_action_id, video_id, adgroup_name, advertiser_id, creative_type, landing_page_url, call_to_action, identity_id, page_id, display_name, playable_url, is_new_structure, click_tracking_url, ad_text, is_aco, app_name, fallback_type, modify_time, create_time, tenant, _gn_synced
)
VALUES (
  source.ad_id,
  SAFE_CAST(source.ad_format AS STRING),
  SAFE_CAST(source.campaign_name AS STRING),
  SAFE_CAST(source.identity_type AS STRING),
  SAFE_CAST(source.campaign_id AS STRING),
  SAFE_CAST(source.brand_safety_postbid_partner AS STRING),
  SAFE_CAST(source.ad_name AS STRING),
  SAFE_CAST(source.avatar_icon_web_uri AS STRING),
  SAFE_CAST(source.adgroup_id AS STRING),
  SAFE_CAST(source.image_ids AS STRING),
  SAFE_CAST(source.call_to_action_id AS STRING),
  SAFE_CAST(source.video_id AS STRING),
  SAFE_CAST(source.adgroup_name AS STRING),
  SAFE_CAST(source.advertiser_id AS STRING),
  SAFE_CAST(source.creative_type AS STRING),
  SAFE_CAST(source.landing_page_url AS STRING),
  SAFE_CAST(source.call_to_action AS STRING),
  SAFE_CAST(source.identity_id AS STRING),
  SAFE_CAST(source.page_id AS FLOAT64),
  SAFE_CAST(source.display_name AS STRING),
  SAFE_CAST(source.playable_url AS STRING),
  SAFE_CAST(source.is_new_structure AS BOOL),
  SAFE_CAST(source.click_tracking_url AS STRING),
  SAFE_CAST(source.ad_text AS STRING),
  SAFE_CAST(source.is_aco AS BOOL),
  SAFE_CAST(source.app_name AS STRING),
  SAFE_CAST(source.fallback_type AS STRING),
  SAFE_CAST(source.modify_time AS TIMESTAMP),
  SAFE_CAST(source.create_time AS TIMESTAMP),
  SAFE_CAST(source.tenant AS STRING),
  CURRENT_TIMESTAMP()
);

{% if drop_source_table %}
DROP TABLE IF EXISTS `{{source_dataset}}.{{source_table_id}}`;
{% endif %}

END IF;
