# Ads Engagement Metrics by Day Report

This table contains TikTok Ads engagement metrics at the ad and day level, with one row per ad and stat_time_day. It provides engagement metrics such as likes, comments, shares, and more for each ad, enabling granular analysis and reporting.

## Table Structure

| Column      | Type      | Description                                                                 |
|-------------|-----------|-----------------------------------------------------------------------------|
| ad_id       | STRING    | The unique identifier for the TikTok Ad                                     |
| stat_time_day | DATE    | The reporting date for the record                                           |
| _gn_id      | STRING    | Hash of key dimensions for deduplication and uniqueness                     |
| tenant      | STRING    | Tenant identifier (for multi-tenant environments)                           |
| profile_visits | FLOAT64 | Number of profile visits                                                    |
| profile_visits_rate | FLOAT64 | Profile visit rate                                                    |
| likes       | FLOAT64   | Number of likes                                                           |
| comments    | FLOAT64   | Number of comments                                                        |
| shares      | FLOAT64   | Number of shares                                                          |
| follows     | FLOAT64   | Number of follows                                                         |
| clicks_on_music_disc | FLOAT64 | Number of clicks on music disc                                      |
| _fivetran_synced | TIMESTAMP | ETL load timestamp                                                    |

## How to Use This Table

- **Engagement Analysis**: Aggregate or filter by `ad_id` or `stat_time_day` to analyze engagement over time.
- **KPI Tracking**: Use engagement columns to calculate rates and totals.
- **Join with Dimensions**: Join with ad, campaign, or account dimension tables using `ad_id` for richer analysis.
- **Tenant Filtering**: Use the `tenant` column to filter results for specific clients or business units in multi-tenant environments.

## Notes

- The table is batch-based, loading only the latest batch of data using `_time_extracted` logic for deduplication and idempotency.
- The grain is (`ad_id`, `stat_time_day`), with one row per ad per day.
- The `_gn_id` column is a deterministic hash of key dimensions for uniqueness and deduplication.
- All engagement metrics are cast to FLOAT64 for consistency.
- The table is designed for easy joins with other TikTok Ads reporting and dimension tables. 