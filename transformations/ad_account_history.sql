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

-- Merge Logic
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
  FROM `{{source_dataset}}.{{source_table_id}}`
) AS source
ON target.advertiser_id = source.advertiser_id
WHEN MATCHED THEN UPDATE SET
  name = source.name,
  company = source.company,
  contacter = source.contacter,
  promotion_area = source.promotion_area,
  balance = source.balance,
  currency = source.currency,
  display_timezone = source.display_timezone,
  email = source.email,
  language = source.language,
  industry = source.industry,
  create_time = source.create_time,
  role = source.role,
  timezone = source.timezone,
  country = source.country,
  status = source.status,
  description = source.description,
  license_no = source.license_no,
  tenant = source.tenant,
  effective_from = source.effective_from,
  effective_to = source.effective_to,
  is_current = source.is_current,
  _gn_id = source._gn_id
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