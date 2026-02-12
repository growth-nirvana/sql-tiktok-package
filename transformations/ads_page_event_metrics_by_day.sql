-- ads_page_event_metrics_by_day_report
-- Batch-based daily snapshot table for TikTok Ads Page Event Metrics
{% assign target_dataset = vars.target_dataset_id %}
{% assign target_table_id = 'ads_page_event_metrics_by_day' %}

{% assign source_dataset = vars.source_dataset_id %}
{% assign source_table_id = 'ads_page_event_metrics_by_day' %}

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
    complete_payment_roas FLOAT64,
    complete_payment FLOAT64,
    cost_per_complete_payment FLOAT64,
    complete_payment_rate FLOAT64,
    value_per_complete_payment FLOAT64,
    total_complete_payment_rate FLOAT64,
    page_browse_view FLOAT64,
    cost_per_page_browse_view FLOAT64,
    page_browse_view_rate FLOAT64,
    total_page_browse_view_value FLOAT64,
    value_per_page_browse_view FLOAT64,
    button_click FLOAT64,
    cost_per_button_click FLOAT64,
    button_click_rate FLOAT64,
    value_per_button_click FLOAT64,
    total_button_click_value FLOAT64,
    online_consult FLOAT64,
    cost_per_online_consult FLOAT64,
    online_consult_rate FLOAT64,
    value_per_online_consult FLOAT64,
    total_online_consult_value FLOAT64,
    user_registration FLOAT64,
    cost_per_user_registration FLOAT64,
    user_registration_rate FLOAT64,
    value_per_user_registration FLOAT64,
    total_user_registration_value FLOAT64,
    product_details_page_browse FLOAT64,
    cost_per_product_details_page_browse FLOAT64,
    product_details_page_browse_rate FLOAT64,
    value_per_product_details_page_browse FLOAT64,
    total_product_details_page_browse_value FLOAT64,
    web_event_add_to_cart FLOAT64,
    cost_per_web_event_add_to_cart FLOAT64,
    web_event_add_to_cart_rate FLOAT64,
    value_per_web_event_add_to_cart FLOAT64,
    total_web_event_add_to_cart_value FLOAT64,
    on_web_order FLOAT64,
    cost_per_on_web_order FLOAT64,
    on_web_order_rate FLOAT64,
    value_per_on_web_order FLOAT64,
    total_on_web_order_value FLOAT64,
    initiate_checkout FLOAT64,
    cost_per_initiate_checkout FLOAT64,
    initiate_checkout_rate FLOAT64,
    value_per_initiate_checkout FLOAT64,
    total_initiate_checkout_value FLOAT64,
    add_billing FLOAT64,
    cost_per_add_billing FLOAT64,
    add_billing_rate FLOAT64,
    value_per_add_billing FLOAT64,
    total_add_billing_value FLOAT64,
    page_event_search FLOAT64,
    cost_per_page_event_search FLOAT64,
    page_event_search_rate FLOAT64,
    value_per_page_event_search FLOAT64,
    total_page_event_search_value FLOAT64,
    form FLOAT64,
    cost_per_form FLOAT64,
    form_rate FLOAT64,
    value_per_form FLOAT64,
    total_form_value FLOAT64,
    download_start FLOAT64,
    cost_per_download_start FLOAT64,
    download_start_rate FLOAT64,
    value_per_download_start FLOAT64,
    total_download_start_value FLOAT64,
    on_web_add_to_wishlist FLOAT64,
    cost_per_on_web_add_to_wishlist FLOAT64,
    on_web_add_to_wishlist_per_click FLOAT64,
    value_per_on_web_add_to_wishlist FLOAT64,
    total_on_web_add_to_wishlist_value FLOAT64,
    on_web_subscribe FLOAT64,
    cost_per_on_web_subscribe FLOAT64,
    on_web_subscribe_per_click FLOAT64,
    value_per_on_web_subscribe FLOAT64,
    total_on_web_subscribe_value FLOAT64,
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
      complete_payment_roas,
      complete_payment,
      cost_per_complete_payment,
      complete_payment_rate,
      value_per_complete_payment,
      total_complete_payment_rate,
      page_browse_view,
      cost_per_page_browse_view,
      page_browse_view_rate,
      total_page_browse_view_value,
      value_per_page_browse_view,
      button_click,
      cost_per_button_click,
      button_click_rate,
      value_per_button_click,
      total_button_click_value,
      online_consult,
      cost_per_online_consult,
      online_consult_rate,
      value_per_online_consult,
      total_online_consult_value,
      user_registration,
      cost_per_user_registration,
      user_registration_rate,
      value_per_user_registration,
      total_user_registration_value,
      product_details_page_browse,
      cost_per_product_details_page_browse,
      product_details_page_browse_rate,
      value_per_product_details_page_browse,
      total_product_details_page_browse_value,
      web_event_add_to_cart,
      cost_per_web_event_add_to_cart,
      web_event_add_to_cart_rate,
      value_per_web_event_add_to_cart,
      total_web_event_add_to_cart_value,
      on_web_order,
      cost_per_on_web_order,
      on_web_order_rate,
      value_per_on_web_order,
      total_on_web_order_value,
      initiate_checkout,
      cost_per_initiate_checkout,
      initiate_checkout_rate,
      value_per_initiate_checkout,
      total_initiate_checkout_value,
      add_billing,
      cost_per_add_billing,
      add_billing_rate,
      value_per_add_billing,
      total_add_billing_value,
      page_event_search,
      cost_per_page_event_search,
      page_event_search_rate,
      value_per_page_event_search,
      total_page_event_search_value,
      form,
      cost_per_form,
      form_rate,
      value_per_form,
      total_form_value,
      download_start,
      cost_per_download_start,
      download_start_rate,
      value_per_download_start,
      total_download_start_value,
      on_web_add_to_wishlist,
      cost_per_on_web_add_to_wishlist,
      on_web_add_to_wishlist_per_click,
      value_per_on_web_add_to_wishlist,
      total_on_web_add_to_wishlist_value,
      on_web_subscribe,
      cost_per_on_web_subscribe,
      on_web_subscribe_per_click,
      value_per_on_web_subscribe,
      total_on_web_subscribe_value,
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
      SAFE_CAST(complete_payment_roas AS FLOAT64),
      SAFE_CAST(complete_payment AS FLOAT64),
      SAFE_CAST(cost_per_complete_payment AS FLOAT64),
      SAFE_CAST(complete_payment_rate AS FLOAT64),
      SAFE_CAST(value_per_complete_payment AS FLOAT64),
      SAFE_CAST(total_complete_payment_rate AS FLOAT64),
      SAFE_CAST(page_browse_view AS FLOAT64),
      SAFE_CAST(cost_per_page_browse_view AS FLOAT64),
      SAFE_CAST(page_browse_view_rate AS FLOAT64),
      SAFE_CAST(total_page_browse_view_value AS FLOAT64),
      SAFE_CAST(value_per_page_browse_view AS FLOAT64),
      SAFE_CAST(button_click AS FLOAT64),
      SAFE_CAST(cost_per_button_click AS FLOAT64),
      SAFE_CAST(button_click_rate AS FLOAT64),
      SAFE_CAST(value_per_button_click AS FLOAT64),
      SAFE_CAST(total_button_click_value AS FLOAT64),
      SAFE_CAST(online_consult AS FLOAT64),
      SAFE_CAST(cost_per_online_consult AS FLOAT64),
      SAFE_CAST(online_consult_rate AS FLOAT64),
      SAFE_CAST(value_per_online_consult AS FLOAT64),
      SAFE_CAST(total_online_consult_value AS FLOAT64),
      SAFE_CAST(user_registration AS FLOAT64),
      SAFE_CAST(cost_per_user_registration AS FLOAT64),
      SAFE_CAST(user_registration_rate AS FLOAT64),
      SAFE_CAST(value_per_user_registration AS FLOAT64),
      SAFE_CAST(total_user_registration_value AS FLOAT64),
      SAFE_CAST(product_details_page_browse AS FLOAT64),
      SAFE_CAST(cost_per_product_details_page_browse AS FLOAT64),
      SAFE_CAST(product_details_page_browse_rate AS FLOAT64),
      SAFE_CAST(value_per_product_details_page_browse AS FLOAT64),
      SAFE_CAST(total_product_details_page_browse_value AS FLOAT64),
      SAFE_CAST(web_event_add_to_cart AS FLOAT64),
      SAFE_CAST(cost_per_web_event_add_to_cart AS FLOAT64),
      SAFE_CAST(web_event_add_to_cart_rate AS FLOAT64),
      SAFE_CAST(value_per_web_event_add_to_cart AS FLOAT64),
      SAFE_CAST(total_web_event_add_to_cart_value AS FLOAT64),
      SAFE_CAST(on_web_order AS FLOAT64),
      SAFE_CAST(cost_per_on_web_order AS FLOAT64),
      SAFE_CAST(on_web_order_rate AS FLOAT64),
      SAFE_CAST(value_per_on_web_order AS FLOAT64),
      SAFE_CAST(total_on_web_order_value AS FLOAT64),
      SAFE_CAST(initiate_checkout AS FLOAT64),
      SAFE_CAST(cost_per_initiate_checkout AS FLOAT64),
      SAFE_CAST(initiate_checkout_rate AS FLOAT64),
      SAFE_CAST(value_per_initiate_checkout AS FLOAT64),
      SAFE_CAST(total_initiate_checkout_value AS FLOAT64),
      SAFE_CAST(add_billing AS FLOAT64),
      SAFE_CAST(cost_per_add_billing AS FLOAT64),
      SAFE_CAST(add_billing_rate AS FLOAT64),
      SAFE_CAST(value_per_add_billing AS FLOAT64),
      SAFE_CAST(total_add_billing_value AS FLOAT64),
      SAFE_CAST(page_event_search AS FLOAT64),
      SAFE_CAST(cost_per_page_event_search AS FLOAT64),
      SAFE_CAST(page_event_search_rate AS FLOAT64),
      SAFE_CAST(value_per_page_event_search AS FLOAT64),
      SAFE_CAST(total_page_event_search_value AS FLOAT64),
      SAFE_CAST(form AS FLOAT64),
      SAFE_CAST(cost_per_form AS FLOAT64),
      SAFE_CAST(form_rate AS FLOAT64),
      SAFE_CAST(value_per_form AS FLOAT64),
      SAFE_CAST(total_form_value AS FLOAT64),
      SAFE_CAST(download_start AS FLOAT64),
      SAFE_CAST(cost_per_download_start AS FLOAT64),
      SAFE_CAST(download_start_rate AS FLOAT64),
      SAFE_CAST(value_per_download_start AS FLOAT64),
      SAFE_CAST(total_download_start_value AS FLOAT64),
      SAFE_CAST(on_web_add_to_wishlist AS FLOAT64),
      SAFE_CAST(cost_per_on_web_add_to_wishlist AS FLOAT64),
      SAFE_CAST(on_web_add_to_wishlist_per_click AS FLOAT64),
      SAFE_CAST(value_per_on_web_add_to_wishlist AS FLOAT64),
      SAFE_CAST(total_on_web_add_to_wishlist_value AS FLOAT64),
      SAFE_CAST(on_web_subscribe AS FLOAT64),
      SAFE_CAST(cost_per_on_web_subscribe AS FLOAT64),
      SAFE_CAST(on_web_subscribe_per_click AS FLOAT64),
      SAFE_CAST(value_per_on_web_subscribe AS FLOAT64),
      SAFE_CAST(total_on_web_subscribe_value AS FLOAT64),
      CURRENT_TIMESTAMP() AS _fivetran_synced
    FROM latest_batch;

  COMMIT TRANSACTION;

  -- Optionally drop the source table if drop_source_table is true
  {% if drop_source_table %}
    DROP TABLE IF EXISTS `{{source_dataset}}.{{source_table_id}}`;
  {% endif %}

END IF; 