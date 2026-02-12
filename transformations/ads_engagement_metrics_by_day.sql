-- ads_engagement_metrics_by_day_report
-- Batch-based daily snapshot table for TikTok Ads Engagement Metrics
{% assign target_dataset = vars.target_dataset_id %}
{% assign target_table_id = 'ads_engagement_metrics_by_day' %}

{% assign source_dataset = vars.source_dataset_id %}
{% assign source_table_id = 'ads_engagement_metrics_by_day' %}

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
    profile_visits FLOAT64,
    profile_visits_rate FLOAT64,
    likes FLOAT64,
    comments FLOAT64,
    shares FLOAT64,
    follows FLOAT64,
    clicks_on_music_disc FLOAT64,
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
      profile_visits,
      profile_visits_rate,
      likes,
      comments,
      shares,
      follows,
      clicks_on_music_disc,
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
      SAFE_CAST(profile_visits AS FLOAT64),
      SAFE_CAST(profile_visits_rate AS FLOAT64),
      SAFE_CAST(likes AS FLOAT64),
      SAFE_CAST(comments AS FLOAT64),
      SAFE_CAST(shares AS FLOAT64),
      SAFE_CAST(follows AS FLOAT64),
      SAFE_CAST(clicks_on_music_disc AS FLOAT64),
      CURRENT_TIMESTAMP() AS _fivetran_synced
    FROM latest_batch;

  COMMIT TRANSACTION;

  -- Optionally drop the source table if drop_source_table is true
  {% if drop_source_table %}
    DROP TABLE IF EXISTS `{{source_dataset}}.{{source_table_id}}`;
  {% endif %}

END IF; 