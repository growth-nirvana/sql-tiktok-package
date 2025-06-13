CREATE TABLE `ads_engagement_metrics_by_day`
(
  ad_id STRING NOT NULL,
  profile_visits STRING,
  profile_visits_rate STRING,
  likes STRING,
  comments STRING,
  shares STRING,
  follows STRING,
  clicks_on_music_disc STRING,
  stat_time_day TIMESTAMP NOT NULL,
  tenant STRING,
  _time_extracted TIMESTAMP,
  _time_loaded TIMESTAMP
);