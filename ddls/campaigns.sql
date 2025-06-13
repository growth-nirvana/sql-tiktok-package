CREATE TABLE `campaigns`
(
  campaign_id STRING NOT NULL,
  campaign_name STRING,
  campaign_type STRING,
  objective STRING,
  objective_type STRING,
  advertiser_id STRING,
  budget_mode STRING,
  is_new_structure BOOL,
  budget FLOAT64,
  roas_bid FLOAT64,
  create_time TIMESTAMP,
  modify_time TIMESTAMP,
  tenant STRING,
  _time_extracted TIMESTAMP,
  _time_loaded TIMESTAMP
);