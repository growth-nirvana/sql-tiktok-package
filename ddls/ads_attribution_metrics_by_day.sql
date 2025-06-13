CREATE TABLE `ads_attribution_metrics_by_day`
(
  ad_id STRING NOT NULL,
  vta_app_install STRING,
  vta_conversion STRING,
  cost_per_vta_conversion STRING,
  vta_registration STRING,
  cost_per_vta_registration STRING,
  vta_purchase STRING,
  cost_per_vta_purchase STRING,
  cta_app_install STRING,
  cta_conversion STRING,
  cost_per_cta_conversion STRING,
  cta_registration STRING,
  cost_per_cta_registration STRING,
  cta_purchase STRING,
  cost_per_cta_purchase STRING,
  stat_time_day TIMESTAMP NOT NULL,
  tenant STRING,
  _time_extracted TIMESTAMP,
  _time_loaded TIMESTAMP
);