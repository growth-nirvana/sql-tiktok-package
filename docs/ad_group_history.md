# Ad Group History Table

This table implements a Slowly Changing Dimension (SCD) Type 2 pattern for TikTok Ad Groups, tracking historical changes to ad group attributes over time. It maintains a complete history of ad group changes while providing an easy way to access the current state of each ad group.

## Table Structure

| Column                | Type      | Description                                                      |
|-----------------------|-----------|------------------------------------------------------------------|
| adgroup_id            | STRING    | The unique identifier for the TikTok Ad Group                    |
| creative_material_mode| STRING    | Creative material mode                                           |
| budget_mode           | STRING    | Budget mode                                                      |
| scheduled_budget      | FLOAT64   | Scheduled budget                                                 |
| placement_type        | STRING    | Placement type                                                   |
| languages             | STRING    | Languages                                                        |
| deep_bid_type         | STRING    | Deep bid type                                                    |
| skip_learning_phase   | BOOL      | Whether learning phase is skipped                                |
| gender                | STRING    | Gender targeting                                                 |
| pixel_id              | STRING    | Pixel ID                                                         |
| frequency_schedule    | INT64     | Frequency schedule                                               |
| frequency             | INT64     | Frequency                                                        |
| ios14_quota_type      | STRING    | iOS 14 quota type                                                |
| bid_type              | STRING    | Bid type                                                         |
| advertiser_id         | STRING    | Advertiser ID                                                    |
| dayparting            | STRING    | Dayparting schedule                                              |
| pacing                | STRING    | Pacing                                                           |
| is_hfss               | BOOL      | HFSS flag                                                        |
| campaign_name         | STRING    | Campaign name                                                    |
| campaign_id           | STRING    | Campaign ID                                                      |
| adgroup_name          | STRING    | Ad group name                                                    |
| billing_event         | STRING    | Billing event                                                    |
| budget                | FLOAT64   | Budget                                                           |
| is_new_structure      | BOOL      | New structure flag                                               |
| schedule_type         | STRING    | Schedule type                                                    |
| modify_time           | TIMESTAMP | Last modification time                                           |
| schedule_end_time     | TIMESTAMP | Schedule end time                                                |
| create_time           | TIMESTAMP | Creation time                                                    |
| schedule_start_time   | TIMESTAMP | Schedule start time                                              |
| tenant                | STRING    | Tenant identifier (for multi-tenant environments)                |
| effective_from        | TIMESTAMP | Start time of when this version of the record was valid          |
| effective_to          | TIMESTAMP | End time of when this version of the record was valid (NULL for current records) |
| is_current            | BOOLEAN   | Flag indicating whether this is the current version of the record |
| _gn_id                | STRING    | Hash of key attributes used for change detection                 |

## Change Detection

The table uses a hash-based change detection mechanism (`_gn_id`) that includes all business attributes. When any of these attributes change, a new version of the record is created with:
- `effective_from` set to the current timestamp
- `effective_to` set to NULL
- `is_current` set to TRUE

The previous version is updated with:
- `effective_to` set to the new version's `effective_from`
- `is_current` set to FALSE

## Usage

- **Get current ad group state**: Filter where `is_current = TRUE`
- **Track historical changes**: Query without the `is_current` filter to see all versions
- **Point-in-time analysis**: Use `effective_from` and `effective_to` to see ad group state at any point in time
- **Change analysis**: Compare different versions of the same ad group to see what changed and when

## Notes

- The table is updated incrementally, only processing new or changed records
- A guard clause checks for source table existence before running ETL
- All fields in the hash are cast to STRING to ensure consistent change detection
- The table maintains referential integrity with other TikTok Ads tables through the `adgroup_id` field 