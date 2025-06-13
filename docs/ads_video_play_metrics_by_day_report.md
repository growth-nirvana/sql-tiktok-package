# Ads Video Play Metrics by Day Report

This table contains TikTok Ads video play metrics at the ad and day level, with one row per ad and stat_time_day. It provides video engagement metrics for each ad, enabling granular analysis and reporting.

## Table Structure

| Column      | Type      | Description                                                                 |
|-------------|-----------|-----------------------------------------------------------------------------|
| ad_id       | STRING    | The unique identifier for the TikTok Ad                                     |
| stat_time_day | DATE    | The reporting date for the record                                           |
| _gn_id      | STRING    | Hash of key dimensions for deduplication and uniqueness                     |
| tenant      | STRING    | Tenant identifier (for multi-tenant environments)                           |
| video_play_actions | FLOAT64 | Number of video play actions                                         |
| video_watched_2s  | FLOAT64 | Number of 2-second video watches                                      |
| video_watched_6s  | FLOAT64 | Number of 6-second video watches                                      |
| average_video_play | FLOAT64 | Average video play duration                                           |
| average_video_play_per_user | FLOAT64 | Average video play per user                                 |
| video_views_p25   | FLOAT64 | Number of 25% video views                                            |
| video_views_p50   | FLOAT64 | Number of 50% video views                                            |
| video_views_p75   | FLOAT64 | Number of 75% video views                                            |
| video_views_p100  | FLOAT64 | Number of 100% video views                                           |
| _fivetran_synced  | TIMESTAMP | ETL load timestamp                                                 |

## How to Use This Table

- **Video Engagement Analysis**: Aggregate or filter by `ad_id` or `stat_time_day` to analyze video engagement over time.
- **KPI Tracking**: Use video view columns to calculate completion rates and engagement metrics.
- **Join with Dimensions**: Join with ad, campaign, or account dimension tables using `ad_id` for richer analysis.
- **Tenant Filtering**: Use the `tenant` column to filter results for specific clients or business units in multi-tenant environments.

## Notes

- The table is batch-based, loading only the latest batch of data using `_time_extracted` logic for deduplication and idempotency.
- The grain is (`ad_id`, `stat_time_day`), with one row per ad per day.
- The `_gn_id` column is a deterministic hash of key dimensions for uniqueness and deduplication.
- All metrics are cast to FLOAT64 for consistency.
- The table is designed for easy joins with other TikTok Ads reporting and dimension tables. 