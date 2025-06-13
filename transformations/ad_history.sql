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

-- Extract latest snapshot from source
CREATE TEMP TABLE latest_snapshot AS
SELECT
  *,
  ROW_NUMBER() OVER (PARTITION BY ad_id ORDER BY _time_extracted DESC) AS rn
FROM `{{source_dataset}}.{{source_table_id}}`;

-- SCD Merge Logic
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
  FROM latest_snapshot
  WHERE rn = 1
) AS source
ON target.ad_id = source.ad_id AND target.is_current = TRUE
WHEN MATCHED AND
  TO_HEX(MD5(TO_JSON_STRING([
    SAFE_CAST(target.ad_id AS STRING),
    SAFE_CAST(target.ad_format AS STRING),
    SAFE_CAST(target.campaign_name AS STRING),
    SAFE_CAST(target.identity_type AS STRING),
    SAFE_CAST(target.campaign_id AS STRING),
    SAFE_CAST(target.brand_safety_postbid_partner AS STRING),
    SAFE_CAST(target.ad_name AS STRING),
    SAFE_CAST(target.avatar_icon_web_uri AS STRING),
    SAFE_CAST(target.adgroup_id AS STRING),
    SAFE_CAST(target.image_ids AS STRING),
    SAFE_CAST(target.call_to_action_id AS STRING),
    SAFE_CAST(target.video_id AS STRING),
    SAFE_CAST(target.adgroup_name AS STRING),
    SAFE_CAST(target.advertiser_id AS STRING),
    SAFE_CAST(target.creative_type AS STRING),
    SAFE_CAST(target.landing_page_url AS STRING),
    SAFE_CAST(target.call_to_action AS STRING),
    SAFE_CAST(target.identity_id AS STRING),
    SAFE_CAST(target.page_id AS STRING),
    SAFE_CAST(target.display_name AS STRING),
    SAFE_CAST(target.playable_url AS STRING),
    SAFE_CAST(target.is_new_structure AS STRING),
    SAFE_CAST(target.click_tracking_url AS STRING),
    SAFE_CAST(target.ad_text AS STRING),
    SAFE_CAST(target.is_aco AS STRING),
    SAFE_CAST(target.app_name AS STRING),
    SAFE_CAST(target.fallback_type AS STRING),
    SAFE_CAST(target.modify_time AS STRING),
    SAFE_CAST(target.create_time AS STRING),
    SAFE_CAST(target.tenant AS STRING)
  ]))) !=
  TO_HEX(MD5(TO_JSON_STRING([
    SAFE_CAST(source.ad_id AS STRING),
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
    SAFE_CAST(source.page_id AS STRING),
    SAFE_CAST(source.display_name AS STRING),
    SAFE_CAST(source.playable_url AS STRING),
    SAFE_CAST(source.is_new_structure AS STRING),
    SAFE_CAST(source.click_tracking_url AS STRING),
    SAFE_CAST(source.ad_text AS STRING),
    SAFE_CAST(source.is_aco AS STRING),
    SAFE_CAST(source.app_name AS STRING),
    SAFE_CAST(source.fallback_type AS STRING),
    SAFE_CAST(source.modify_time AS STRING),
    SAFE_CAST(source.create_time AS STRING),
    SAFE_CAST(source.tenant AS STRING)
  ])))
  THEN UPDATE SET
    effective_to = source.effective_from,
    is_current = FALSE
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