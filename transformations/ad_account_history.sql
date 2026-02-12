-- ad_accounts_history
-- Simple merge on advertiser_id (source truncated each run)
{% assign target_dataset = vars.target_dataset_id %}
{% assign target_table_id = 'ad_accounts_history' %}

{% assign source_dataset = vars.source_dataset_id %}
{% assign source_table_id = 'ad_accounts' %}

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
  ADD COLUMN IF NOT EXISTS advertiser_id STRING,
  ADD COLUMN IF NOT EXISTS name STRING,
  ADD COLUMN IF NOT EXISTS company STRING,
  ADD COLUMN IF NOT EXISTS contacter STRING,
  ADD COLUMN IF NOT EXISTS promotion_area STRING,
  ADD COLUMN IF NOT EXISTS balance FLOAT64,
  ADD COLUMN IF NOT EXISTS currency STRING,
  ADD COLUMN IF NOT EXISTS display_timezone STRING,
  ADD COLUMN IF NOT EXISTS email STRING,
  ADD COLUMN IF NOT EXISTS language STRING,
  ADD COLUMN IF NOT EXISTS industry STRING,
  ADD COLUMN IF NOT EXISTS create_time INT64,
  ADD COLUMN IF NOT EXISTS role STRING,
  ADD COLUMN IF NOT EXISTS timezone STRING,
  ADD COLUMN IF NOT EXISTS country STRING,
  ADD COLUMN IF NOT EXISTS status STRING,
  ADD COLUMN IF NOT EXISTS description STRING,
  ADD COLUMN IF NOT EXISTS license_no STRING,
  ADD COLUMN IF NOT EXISTS tenant STRING;

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
  _gn_synced TIMESTAMP
);

MERGE `{{target_dataset}}.{{target_table_id}}` AS target
USING `{{source_dataset}}.{{source_table_id}}` AS source
ON target.advertiser_id = source.advertiser_id
WHEN MATCHED THEN UPDATE SET
  name = CAST(source.name AS STRING),
  company = CAST(source.company AS STRING),
  contacter = CAST(source.contacter AS STRING),
  promotion_area = CAST(source.promotion_area AS STRING),
  balance = CAST(source.balance AS FLOAT64),
  currency = CAST(source.currency AS STRING),
  display_timezone = CAST(source.display_timezone AS STRING),
  email = CAST(source.email AS STRING),
  language = CAST(source.language AS STRING),
  industry = CAST(source.industry AS STRING),
  create_time = CAST(source.create_time AS INT64),
  role = CAST(source.role AS STRING),
  timezone = CAST(source.timezone AS STRING),
  country = CAST(source.country AS STRING),
  status = CAST(source.status AS STRING),
  description = CAST(source.description AS STRING),
  license_no = CAST(source.license_no AS STRING),
  tenant = CAST(source.tenant AS STRING),
  _gn_synced = CURRENT_TIMESTAMP()
WHEN NOT MATCHED THEN INSERT (
  advertiser_id, name, company, contacter, promotion_area, balance, currency, display_timezone, email, language, industry, create_time, role, timezone, country, status, description, license_no, tenant, _gn_synced
)
VALUES (
  source.advertiser_id,
  CAST(source.name AS STRING),
  CAST(source.company AS STRING),
  CAST(source.contacter AS STRING),
  CAST(source.promotion_area AS STRING),
  CAST(source.balance AS FLOAT64),
  CAST(source.currency AS STRING),
  CAST(source.display_timezone AS STRING),
  CAST(source.email AS STRING),
  CAST(source.language AS STRING),
  CAST(source.industry AS STRING),
  CAST(source.create_time AS INT64),
  CAST(source.role AS STRING),
  CAST(source.timezone AS STRING),
  CAST(source.country AS STRING),
  CAST(source.status AS STRING),
  CAST(source.description AS STRING),
  CAST(source.license_no AS STRING),
  CAST(source.tenant AS STRING),
  CURRENT_TIMESTAMP()
);

{% if drop_source_table %}
DROP TABLE IF EXISTS `{{source_dataset}}.{{source_table_id}}`;
{% endif %}

END IF;
