-- ad_accounts_history
-- SCD Type 2 Table for TikTok Ad Accounts
{% assign target_dataset = vars.target_dataset_id %}
{% assign target_table_id = 'ad_accounts_history' %}

{% assign source_dataset = vars.source_dataset_id %}
{% assign source_table_id = 'ad_accounts' %}

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
  advertiser_id STRING NOT NULL,
  name STRING,
  company STRING,
  contacter STRING,
  promotion_area STRING,
  balance FLOAT64,
  currency STRING,
  display_timezone STRING,
  email STRING,
  language STRING,
  industry STRING,
  create_time INT64,
  role STRING,
  timezone STRING,
  country STRING,
  status STRING,
  description STRING,
  license_no STRING,
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
  ROW_NUMBER() OVER (PARTITION BY advertiser_id ORDER BY _time_extracted DESC) AS rn
FROM `{{source_dataset}}.{{source_table_id}}`;

-- SCD Merge Logic
MERGE `{{target_dataset}}.{{target_table_id}}` AS target
USING (
  SELECT
    advertiser_id,
    name,
    company,
    contacter,
    promotion_area,
    balance,
    currency,
    display_timezone,
    email,
    language,
    industry,
    create_time,
    role,
    timezone,
    country,
    status,
    description,
    license_no,
    tenant,
    _time_extracted AS effective_from,
    CAST(NULL AS TIMESTAMP) AS effective_to,
    TRUE AS is_current,
    TO_HEX(MD5(TO_JSON_STRING([
      SAFE_CAST(advertiser_id AS STRING),
      SAFE_CAST(name AS STRING),
      SAFE_CAST(company AS STRING),
      SAFE_CAST(contacter AS STRING),
      SAFE_CAST(promotion_area AS STRING),
      SAFE_CAST(balance AS STRING),
      SAFE_CAST(currency AS STRING),
      SAFE_CAST(display_timezone AS STRING),
      SAFE_CAST(email AS STRING),
      SAFE_CAST(language AS STRING),
      SAFE_CAST(industry AS STRING),
      SAFE_CAST(create_time AS STRING),
      SAFE_CAST(role AS STRING),
      SAFE_CAST(timezone AS STRING),
      SAFE_CAST(country AS STRING),
      SAFE_CAST(status AS STRING),
      SAFE_CAST(description AS STRING),
      SAFE_CAST(license_no AS STRING),
      SAFE_CAST(tenant AS STRING)
    ]))) AS _gn_id
  FROM latest_snapshot
  WHERE rn = 1
) AS source
ON target.advertiser_id = source.advertiser_id AND target.is_current = TRUE
WHEN MATCHED AND
  TO_HEX(MD5(TO_JSON_STRING([
    SAFE_CAST(target.advertiser_id AS STRING),
    SAFE_CAST(target.name AS STRING),
    SAFE_CAST(target.company AS STRING),
    SAFE_CAST(target.contacter AS STRING),
    SAFE_CAST(target.promotion_area AS STRING),
    SAFE_CAST(target.balance AS STRING),
    SAFE_CAST(target.currency AS STRING),
    SAFE_CAST(target.display_timezone AS STRING),
    SAFE_CAST(target.email AS STRING),
    SAFE_CAST(target.language AS STRING),
    SAFE_CAST(target.industry AS STRING),
    SAFE_CAST(target.create_time AS STRING),
    SAFE_CAST(target.role AS STRING),
    SAFE_CAST(target.timezone AS STRING),
    SAFE_CAST(target.country AS STRING),
    SAFE_CAST(target.status AS STRING),
    SAFE_CAST(target.description AS STRING),
    SAFE_CAST(target.license_no AS STRING),
    SAFE_CAST(target.tenant AS STRING)
  ]))) !=
  TO_HEX(MD5(TO_JSON_STRING([
    SAFE_CAST(source.advertiser_id AS STRING),
    SAFE_CAST(source.name AS STRING),
    SAFE_CAST(source.company AS STRING),
    SAFE_CAST(source.contacter AS STRING),
    SAFE_CAST(source.promotion_area AS STRING),
    SAFE_CAST(source.balance AS STRING),
    SAFE_CAST(source.currency AS STRING),
    SAFE_CAST(source.display_timezone AS STRING),
    SAFE_CAST(source.email AS STRING),
    SAFE_CAST(source.language AS STRING),
    SAFE_CAST(source.industry AS STRING),
    SAFE_CAST(source.create_time AS STRING),
    SAFE_CAST(source.role AS STRING),
    SAFE_CAST(source.timezone AS STRING),
    SAFE_CAST(source.country AS STRING),
    SAFE_CAST(source.status AS STRING),
    SAFE_CAST(source.description AS STRING),
    SAFE_CAST(source.license_no AS STRING),
    SAFE_CAST(source.tenant AS STRING)
  ])))
  THEN UPDATE SET
    effective_to = source.effective_from,
    is_current = FALSE
WHEN NOT MATCHED BY TARGET
  THEN INSERT (
    advertiser_id, name, company, contacter, promotion_area, balance, currency, display_timezone, email, language, industry, create_time, role, timezone, country, status, description, license_no, tenant, effective_from, effective_to, is_current, _gn_id
  )
  VALUES (
    source.advertiser_id, source.name, source.company, source.contacter, source.promotion_area, source.balance, source.currency, source.display_timezone, source.email, source.language, source.industry, source.create_time, source.role, source.timezone, source.country, source.status, source.description, source.license_no, source.tenant, source.effective_from, source.effective_to, source.is_current, source._gn_id
  );

-- Optionally drop the source table if drop_source_table is true
{% if drop_source_table %}
  DROP TABLE IF EXISTS `{{source_dataset}}.{{source_table_id}}`;
{% endif %}

END IF; 