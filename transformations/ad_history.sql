-- ad_history
-- SCD Type 2 Table for TikTok Ads
{% assign target_dataset = vars.target_dataset_id %}
{% assign target_table_id = 'ad_history' %}

{% assign source_dataset = vars.source_dataset_id %}
{% assign source_table_id = 'ads' %}

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
  ADD COLUMN IF NOT EXISTS create_time TIMESTAMP;

-- Create SCD table if it doesn't exist
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
  effective_from TIMESTAMP,
  effective_to TIMESTAMP,
  is_current BOOLEAN,
  _gn_id STRING
);

-- Merge Logic
MERGE `{{target_dataset}}.{{target_table_id}}` AS target
USING (
  SELECT
    ad_id,
    ad_format,
    campaign_name,
    identity_type,
    campaign_id,
    brand_safety_postbid_partner,
    ad_name,
    avatar_icon_web_uri,
    adgroup_id,
    image_ids,
    call_to_action_id,
    video_id,
    adgroup_name,
    advertiser_id,
    creative_type,
    landing_page_url,
    call_to_action,
    identity_id,
    page_id,
    display_name,
    playable_url,
    is_new_structure,
    click_tracking_url,
    ad_text,
    is_aco,
    app_name,
    fallback_type,
    modify_time,
    create_time,
    tenant,
    _time_extracted AS effective_from,
    CAST(NULL AS TIMESTAMP) AS effective_to,
    TRUE AS is_current,
    TO_HEX(MD5(TO_JSON_STRING([
      SAFE_CAST(ad_id AS STRING),
      SAFE_CAST(ad_format AS STRING),
      SAFE_CAST(campaign_name AS STRING),
      SAFE_CAST(identity_type AS STRING),
      SAFE_CAST(campaign_id AS STRING),
      SAFE_CAST(brand_safety_postbid_partner AS STRING),
      SAFE_CAST(ad_name AS STRING),
      SAFE_CAST(avatar_icon_web_uri AS STRING),
      SAFE_CAST(adgroup_id AS STRING),
      SAFE_CAST(image_ids AS STRING),
      SAFE_CAST(call_to_action_id AS STRING),
      SAFE_CAST(video_id AS STRING),
      SAFE_CAST(adgroup_name AS STRING),
      SAFE_CAST(advertiser_id AS STRING),
      SAFE_CAST(creative_type AS STRING),
      SAFE_CAST(landing_page_url AS STRING),
      SAFE_CAST(call_to_action AS STRING),
      SAFE_CAST(identity_id AS STRING),
      SAFE_CAST(page_id AS STRING),
      SAFE_CAST(display_name AS STRING),
      SAFE_CAST(playable_url AS STRING),
      SAFE_CAST(is_new_structure AS STRING),
      SAFE_CAST(click_tracking_url AS STRING),
      SAFE_CAST(ad_text AS STRING),
      SAFE_CAST(is_aco AS STRING),
      SAFE_CAST(app_name AS STRING),
      SAFE_CAST(fallback_type AS STRING),
      SAFE_CAST(modify_time AS STRING),
      SAFE_CAST(create_time AS STRING),
      SAFE_CAST(tenant AS STRING)
    ]))) AS _gn_id
  FROM `{{source_dataset}}.{{source_table_id}}`
) AS source
ON target.ad_id = source.ad_id
WHEN MATCHED THEN UPDATE SET
  ad_format = source.ad_format,
  campaign_name = source.campaign_name,
  identity_type = source.identity_type,
  campaign_id = source.campaign_id,
  brand_safety_postbid_partner = source.brand_safety_postbid_partner,
  ad_name = source.ad_name,
  avatar_icon_web_uri = source.avatar_icon_web_uri,
  adgroup_id = source.adgroup_id,
  image_ids = source.image_ids,
  call_to_action_id = source.call_to_action_id,
  video_id = source.video_id,
  adgroup_name = source.adgroup_name,
  advertiser_id = source.advertiser_id,
  creative_type = source.creative_type,
  landing_page_url = source.landing_page_url,
  call_to_action = source.call_to_action,
  identity_id = source.identity_id,
  page_id = source.page_id,
  display_name = source.display_name,
  playable_url = source.playable_url,
  is_new_structure = source.is_new_structure,
  click_tracking_url = source.click_tracking_url,
  ad_text = source.ad_text,
  is_aco = source.is_aco,
  app_name = source.app_name,
  fallback_type = source.fallback_type,
  modify_time = source.modify_time,
  create_time = source.create_time,
  tenant = source.tenant,
  effective_from = source.effective_from,
  effective_to = source.effective_to,
  is_current = source.is_current,
  _gn_id = source._gn_id
WHEN NOT MATCHED BY TARGET
  THEN INSERT (
    ad_id, ad_format, campaign_name, identity_type, campaign_id, brand_safety_postbid_partner, ad_name, avatar_icon_web_uri, adgroup_id, image_ids, call_to_action_id, video_id, adgroup_name, advertiser_id, creative_type, landing_page_url, call_to_action, identity_id, page_id, display_name, playable_url, is_new_structure, click_tracking_url, ad_text, is_aco, app_name, fallback_type, modify_time, create_time, tenant, effective_from, effective_to, is_current, _gn_id
  )
  VALUES (
    source.ad_id, source.ad_format, source.campaign_name, source.identity_type, source.campaign_id, source.brand_safety_postbid_partner, source.ad_name, source.avatar_icon_web_uri, source.adgroup_id, source.image_ids, source.call_to_action_id, source.video_id, source.adgroup_name, source.advertiser_id, source.creative_type, source.landing_page_url, source.call_to_action, source.identity_id, source.page_id, source.display_name, source.playable_url, source.is_new_structure, source.click_tracking_url, source.ad_text, source.is_aco, source.app_name, source.fallback_type, source.modify_time, source.create_time, source.tenant, source.effective_from, source.effective_to, source.is_current, source._gn_id
  );

-- Optionally drop the source table if drop_source_table is true
{% if drop_source_table %}
  DROP TABLE IF EXISTS `{{source_dataset}}.{{source_table_id}}`;
{% endif %}

END IF; 