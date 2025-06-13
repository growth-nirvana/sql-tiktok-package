# Ad History Table

This table implements a Slowly Changing Dimension (SCD) Type 2 pattern for TikTok Ads, tracking historical changes to ad attributes over time. It maintains a complete history of ad changes while providing an easy way to access the current state of each ad.

## Table Structure

| Column                | Type      | Description                                                      |
|-----------------------|-----------|------------------------------------------------------------------|
| ad_id                 | STRING    | The unique identifier for the TikTok Ad                          |
| ad_format             | STRING    | Ad format                                                        |
| campaign_name         | STRING    | Campaign name                                                    |
| identity_type         | STRING    | Identity type                                                    |
| campaign_id           | STRING    | Campaign ID                                                      |
| brand_safety_postbid_partner | STRING | Brand safety partner                                         |
| ad_name               | STRING    | Ad name                                                          |
| avatar_icon_web_uri   | STRING    | Avatar icon URI                                                  |
| adgroup_id            | STRING    | Ad group ID                                                      |
| image_ids             | STRING    | Image IDs                                                        |
| call_to_action_id     | STRING    | Call to action ID                                                |
| video_id              | STRING    | Video ID                                                         |
| adgroup_name          | STRING    | Ad group name                                                    |
| advertiser_id         | STRING    | Advertiser ID                                                    |
| creative_type         | STRING    | Creative type                                                    |
| landing_page_url      | STRING    | Landing page URL                                                 |
| call_to_action        | STRING    | Call to action                                                   |
| identity_id           | STRING    | Identity ID                                                      |
| page_id               | FLOAT64   | Page ID                                                          |
| display_name          | STRING    | Display name                                                     |
| playable_url          | STRING    | Playable URL                                                     |
| is_new_structure      | BOOL      | New structure flag                                               |
| click_tracking_url    | STRING    | Click tracking URL                                               |
| ad_text               | STRING    | Ad text                                                          |
| is_aco                | BOOL      | ACO flag                                                         |
| app_name              | STRING    | App name                                                         |
| fallback_type         | STRING    | Fallback type                                                    |
| modify_time           | TIMESTAMP | Last modification time                                           |
| create_time           | TIMESTAMP | Creation time                                                    |
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

- **Get current ad state**: Filter where `is_current = TRUE`
- **Track historical changes**: Query without the `is_current` filter to see all versions
- **Point-in-time analysis**: Use `effective_from` and `effective_to` to see ad state at any point in time
- **Change analysis**: Compare different versions of the same ad to see what changed and when

## Notes

- The table is updated incrementally, only processing new or changed records
- A guard clause checks for source table existence before running ETL
- All fields in the hash are cast to STRING to ensure consistent change detection
- The table maintains referential integrity with other TikTok Ads tables through the `ad_id` field 