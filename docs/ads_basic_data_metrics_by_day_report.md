# Ads Basic Data Metrics by Day Report

This table contains TikTok Ads basic data metrics at the ad and day level, with one row per ad and stat_time_day. It provides core performance metrics for each ad, enabling granular analysis and reporting.

## Table Structure

| Column      | Type      | Description                                                                 |
|-------------|-----------|-----------------------------------------------------------------------------|
| ad_id       | STRING    | The unique identifier for the TikTok Ad                                     |
| stat_time_day | DATE    | The reporting date for the record                                           |
| _gn_id      | STRING    | Hash of key dimensions for deduplication and uniqueness                     |
| tenant      | STRING    | Tenant identifier (for multi-tenant environments)                           |
| ...         | FLOAT64   | All basic data metrics, cast to FLOAT64 (see SQL for full list)             |
| _fivetran_synced | TIMESTAMP | ETL load timestamp                                                    |

## How to Use This Table

- **Performance Analysis**: Aggregate or filter by `ad_id` or `stat_time_day` to analyze ad performance over time.
- **KPI Tracking**: Use metrics columns to calculate key metrics such as CTR, CPC, CPM, and more.
- **Join with Dimensions**: Join with ad, campaign, or account dimension tables using `ad_id` for richer analysis.
- **Tenant Filtering**: Use the `tenant` column to filter results for specific clients or business units in multi-tenant environments.

## Notes

- The table is batch-based, loading only the latest batch of data using `_time_extracted` logic for deduplication and idempotency.
- The grain is (`ad_id`, `stat_time_day`), with one row per ad per day.
- The `_gn_id` column is a deterministic hash of key dimensions for uniqueness and deduplication.
- All metrics are cast to FLOAT64 for consistency.
- The table is designed for easy joins with other TikTok Ads reporting and dimension tables. 