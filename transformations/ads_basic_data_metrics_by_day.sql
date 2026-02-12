-- ads_basic_data_metrics_by_day_report
-- Batch-based daily snapshot table for TikTok Ads Basic Data Metrics
{% assign target_dataset = vars.target_dataset_id %}
{% assign target_table_id = 'ads_basic_data_metrics_by_day' %}

{% assign source_dataset = vars.source_dataset_id %}
{% assign source_table_id = 'ads_basic_data_metrics_by_day' %}

{% assign drop_source_table = vars.drop_source_table | default: false %}

-- Declare all variables at the top
DECLARE table_exists BOOL DEFAULT FALSE;
DECLARE min_date DATE;
DECLARE max_date DATE;

-- Check if the source table exists
SET table_exists = (
  SELECT COUNT(*) > 0
  FROM `{{source_dataset}}.INFORMATION_SCHEMA.TABLES`
  WHERE table_name = '{{source_table_id}}'
);

-- Only run the ETL logic if the source table exists
IF table_exists THEN

  -- Create target table if it doesn't exist
  CREATE TABLE IF NOT EXISTS `{{target_dataset}}.{{target_table_id}}` (
    ad_id STRING NOT NULL,
    stat_time_day DATE NOT NULL,
    _gn_id STRING,
    tenant STRING,
    spend FLOAT64,
    cpc FLOAT64,
    cpm FLOAT64,
    impressions FLOAT64,
    clicks FLOAT64,
    ctr FLOAT64,
    reach FLOAT64,
    cost_per_1000_reached FLOAT64,
    conversion FLOAT64,
    cost_per_conversion FLOAT64,
    conversion_rate FLOAT64,
    real_time_conversion FLOAT64,
    real_time_cost_per_conversion FLOAT64,
    real_time_conversion_rate FLOAT64,
    result FLOAT64,
    cost_per_result FLOAT64,
    result_rate FLOAT64,
    real_time_result FLOAT64,
    real_time_cost_per_result FLOAT64,
    real_time_result_rate FLOAT64,
    secondary_goal_result FLOAT64,
    cost_per_secondary_goal_result FLOAT64,
    secondary_goal_result_rate FLOAT64,
    frequency FLOAT64,
    _fivetran_synced TIMESTAMP
  );

  -- Step 1: Create temp table for latest batch
  CREATE TEMP TABLE latest_batch AS
  WITH base AS (
    SELECT * FROM `{{source_dataset}}.{{source_table_id}}`
  ),
  ordered AS (
    SELECT *,
      TIMESTAMP_DIFF(
        _time_extracted,
        LAG(_time_extracted) OVER (ORDER BY _time_extracted),
        SECOND
      ) AS diff_seconds
    FROM base
  ),
  batches AS (
    SELECT *,
      SUM(CASE WHEN diff_seconds IS NULL OR diff_seconds > 120 THEN 1 ELSE 0 END)
        OVER (ORDER BY _time_extracted) AS batch_id
    FROM ordered
  ),
  ranked_batches AS (
    SELECT *,
      RANK() OVER (ORDER BY batch_id DESC) AS batch_rank
    FROM batches
  )
  SELECT *
  FROM ranked_batches
  WHERE batch_rank = 1;

  -- Step 2: Assign min/max dates using SET + scalar subqueries
  SET min_date = (
    SELECT MIN(DATE(stat_time_day)) FROM latest_batch
  );

  SET max_date = (
    SELECT MAX(DATE(stat_time_day)) FROM latest_batch
  );

  -- Step 3: Conditional delete and insert
  BEGIN TRANSACTION;

    IF EXISTS (
      SELECT 1
      FROM `{{target_dataset}}.{{target_table_id}}`
      WHERE stat_time_day BETWEEN min_date AND max_date
        AND ad_id IN (
          SELECT DISTINCT ad_id FROM latest_batch
        )
      LIMIT 1
    ) THEN
      DELETE FROM `{{target_dataset}}.{{target_table_id}}`
      WHERE stat_time_day BETWEEN min_date AND max_date
        AND ad_id IN (
          SELECT DISTINCT ad_id FROM latest_batch
        );
    END IF;

    INSERT INTO `{{target_dataset}}.{{target_table_id}}` (
      ad_id,
      stat_time_day,
      _gn_id,
      tenant,
      spend,
      cpc,
      cpm,
      impressions,
      clicks,
      ctr,
      reach,
      cost_per_1000_reached,
      conversion,
      cost_per_conversion,
      conversion_rate,
      real_time_conversion,
      real_time_cost_per_conversion,
      real_time_conversion_rate,
      result,
      cost_per_result,
      result_rate,
      real_time_result,
      real_time_cost_per_result,
      real_time_result_rate,
      secondary_goal_result,
      cost_per_secondary_goal_result,
      secondary_goal_result_rate,
      frequency,
      _fivetran_synced
    )
    SELECT
      ad_id,
      DATE(stat_time_day) AS stat_time_day,
      TO_HEX(MD5(TO_JSON_STRING([
        SAFE_CAST(ad_id AS STRING),
        CAST(DATE(stat_time_day) AS STRING)
      ]))) AS _gn_id,
      tenant,
      SAFE_CAST(spend AS FLOAT64),
      SAFE_CAST(cpc AS FLOAT64),
      SAFE_CAST(cpm AS FLOAT64),
      SAFE_CAST(impressions AS FLOAT64),
      SAFE_CAST(clicks AS FLOAT64),
      SAFE_CAST(ctr AS FLOAT64),
      SAFE_CAST(reach AS FLOAT64),
      SAFE_CAST(cost_per_1000_reached AS FLOAT64),
      SAFE_CAST(conversion AS FLOAT64),
      SAFE_CAST(cost_per_conversion AS FLOAT64),
      SAFE_CAST(conversion_rate AS FLOAT64),
      SAFE_CAST(real_time_conversion AS FLOAT64),
      SAFE_CAST(real_time_cost_per_conversion AS FLOAT64),
      SAFE_CAST(real_time_conversion_rate AS FLOAT64),
      SAFE_CAST(result AS FLOAT64),
      SAFE_CAST(cost_per_result AS FLOAT64),
      SAFE_CAST(result_rate AS FLOAT64),
      SAFE_CAST(real_time_result AS FLOAT64),
      SAFE_CAST(real_time_cost_per_result AS FLOAT64),
      SAFE_CAST(real_time_result_rate AS FLOAT64),
      SAFE_CAST(secondary_goal_result AS FLOAT64),
      SAFE_CAST(cost_per_secondary_goal_result AS FLOAT64),
      SAFE_CAST(secondary_goal_result_rate AS FLOAT64),
      SAFE_CAST(frequency AS FLOAT64),
      CURRENT_TIMESTAMP() AS _fivetran_synced
    FROM latest_batch;

  COMMIT TRANSACTION;

  -- Optionally drop the source table if drop_source_table is true
  {% if drop_source_table %}
    DROP TABLE IF EXISTS `{{source_dataset}}.{{source_table_id}}`;
  {% endif %}

END IF; 