CREATE TABLE `ads_video_play_metrics_by_day`
(
  ad_id STRING NOT NULL,
  video_play_actions STRING,
  video_watched_2s STRING,
  video_watched_6s STRING,
  average_video_play STRING,
  average_video_play_per_user STRING,
  video_views_p25 STRING,
  video_views_p50 STRING,
  video_views_p75 STRING,
  video_views_p100 STRING,
  stat_time_day TIMESTAMP NOT NULL,
  tenant STRING,
  _time_extracted TIMESTAMP,
  _time_loaded TIMESTAMP
);