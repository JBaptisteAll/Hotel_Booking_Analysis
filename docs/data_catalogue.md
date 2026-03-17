# Data Catalogue — Hotel Booking Analysis

This document inventories all data assets in the project: their origin, format, row count, status, and lineage.

---

## 1. Data Assets Overview

| Asset | Type | Format | Location | Status | Rows |
|---|---|---|---|---|---|
| `hotel_bookings` | Raw source table | SQL Server table (from CSV) | SQL Server DB | Active | 119 390 |
| `resort_hotel` | Typed analytical table | SQL Server table | SQL Server DB | Active | 40 060 |
| `city_hotel` | Typed analytical table | SQL Server table | SQL Server DB | Active | 79 330 |
| `all_hotel` | Analytical VIEW | SQL Server VIEW | SQL Server DB | Active | 119 390 |

---

## 2. Source File

### `hotel_bookings.csv`

| Attribute | Value |
|---|---|
| Path | `Data/hotel_bookings.csv` |
| Format | CSV (comma-separated) |
| Encoding | UTF-8 |
| Size | ~16 MB |
| Rows | 119 390 |
| Columns | 32 |
| Period | July 2015 – August 2017 |
| Origin | Published research dataset (Kaggle / Antonio, Almeida & Nunes, 2019) |
| Refresh | Static — no automated refresh |

---

## 3. Tables

### `hotel_bookings` (raw)

| Attribute | Value |
|---|---|
| Description | Direct import of `hotel_bookings.csv` into SQL Server with minimal typing |
| Role | Single source of truth — all downstream tables derive from this one |
| Columns | 32 |
| Rows | 119 390 |
| Known data quality issues | `children` column contains `'NA'` strings instead of NULL; `agent` and `company` are VARCHAR with NULL strings; `arrival_date_month` is stored as English text |
| Loaded by | SQL Server Import Wizard (manual) |
| Script | — |

---

### `resort_hotel` (typed, cleaned)

| Attribute | Value |
|---|---|
| Description | Typed, validated, and cleaned subset of `hotel_bookings` filtered on `hotel = 'Resort Hotel'` |
| Location | Algarve region, Faro area (Portugal) |
| Role | Primary analytical table for Resort Hotel analysis |
| Columns | 32 (30 after load → `company_id` dropped, 3 computed columns added) |
| Rows | 40 060 |
| Loaded by | `01_schema_and_load.sql` |
| Cleaned by | `04_nettoyage_des_données_resort_hotel.sql` |
| Filter | `WHERE hotel = 'Resort Hotel'` |
| Transformations | Date reconstruction, `TRY_CAST` on `children` / `agent` / `company`, column renaming, type enforcement |
| CHECK constraints | `hotel`, `meal`, `distribution_channel`, `deposit_type`, `customer_type`, `reservation_status` |
| Cleaning decisions | `company_id` dropped (92 % NULLs); `assigned_romm_type` renamed; `children` NULLs filled from `babies`; `children = 10` → `1`; negative ADR kept (billing corrections); 3 computed columns added |

---

### `city_hotel` (typed, cleaned)

| Attribute | Value |
|---|---|
| Description | Typed, validated, and cleaned subset of `hotel_bookings` filtered on `hotel = 'City Hotel'` |
| Location | Lisbon (Portugal) |
| Role | Primary analytical table for City Hotel analysis |
| Columns | 32 (30 after load → `company_id` dropped, 3 computed columns added) |
| Rows | 79 330 |
| Loaded by | `01_schema_and_load.sql` |
| Cleaned by | `03_nettoyage_des_données_city_hotel.sql` |
| Filter | `WHERE hotel = 'City Hotel'` |
| Transformations | Same as `resort_hotel` |
| CHECK constraints | Same as `resort_hotel` |
| Cleaning decisions | `company_id` dropped (95 % NULLs); `assigned_romm_type` renamed; `children` NULLs filled from `babies`; `babies = 10` → `1`; `average_daily_rate = 5400` → `540`; 3 computed columns added |

---

## 4. Lineage

```
hotel_bookings.csv
        │
        ▼
hotel_bookings  (raw SQL Server table — full import)
        │
        ├──── resort_hotel  (DDL + ETL via 01_schema_and_load.sql, WHERE hotel = 'Resort Hotel')
        │         │
        │         └──┐
        │            ▼
        └──── city_hotel    (DDL + ETL via 01_schema_and_load.sql, WHERE hotel = 'City Hotel')
                  │
                  └──┐
                     ▼
               all_hotel  (VIEW — UNION ALL of resort_hotel + city_hotel, via eda_preleminaire.sql)
```

---

## 5. Scripts

| Script | Role | Tables affected |
|---|---|---|
| `01_schema_and_load.sql` | Creates `resort_hotel` and `city_hotel`, applies CHECK constraints, inserts data from `hotel_bookings` | `resort_hotel`, `city_hotel` |
| `02_eda_exploratory.sql` | Exploratory Data Analysis — row counts, period, duplicate check, categorical distributions, numeric stats, cross-dimension analysis, hypotheses | `city_hotel`, `resort_hotel`, VIEW `all_hotel` |
| `03_nettoyage_des_données_city_hotel.sql` | Data cleaning for city_hotel — NULL audit, column drops, typo corrections, outlier fixes, computed columns | `city_hotel` |
| `04_nettoyage_des_données_resort_hotel.sql` | Data cleaning for resort_hotel — NULL audit, column drops, typo corrections, outlier fixes, computed columns | `resort_hotel` |

---

## 6. Known Data Quality Issues

| Table | Column | Issue | Handling |
|---|---|---|---|
| `hotel_bookings` | `children` | Contains `'NA'` strings instead of NULL | `TRY_CAST(children AS INT)` → NULL |
| `hotel_bookings` | `agent` | VARCHAR with NULL strings | `TRY_CAST(agent AS INT)` → NULL |
| `hotel_bookings` | `company` | VARCHAR with NULL strings | `TRY_CAST(company AS INT)` → NULL |
| `hotel_bookings` | `arrival_date_month` | Stored as English text (`'July'`, `'August'`…) | `SET LANGUAGE English` + `CAST('01 ' + month + ' 2000' AS DATE)` |
| `hotel_bookings` | `adr` | Some values are 0 or negative | Not filtered — to be handled at analysis layer |
| `hotel_bookings` | `adults` | Some rows have `adults = 0` | Not filtered at load — to be handled at analysis layer |
| `city_hotel` | `booking_id` | Starts at 850 instead of 0 due to a failed INSERT consuming identity values | Cosmetic only — `booking_id` is a surrogate key, not a business identifier |
| `city_hotel` | `company_id` | 75 641 NULLs / 79 330 rows (95 %) | **Dropped** — `03_nettoyage_des_données_city_hotel.sql` |
| `city_hotel` | `assigned_romm_type` | Typo in column name | **Renamed** to `assigned_room_type` — `03_nettoyage_des_données_city_hotel.sql` |
| `city_hotel` | `children` | 4 NULLs remaining after TRY_CAST | **Filled** from `babies` value — `03_nettoyage_des_données_city_hotel.sql` |
| `city_hotel` | `babies` | 1 row with `babies = 10` — likely entry error | **Corrected** to `1` — `03_nettoyage_des_données_city_hotel.sql` |
| `city_hotel` | `average_daily_rate` | 1 row with `5 400` — likely typo (next max = 510, booking canceled) | **Corrected** to `540` — `03_nettoyage_des_données_city_hotel.sql` |
| `resort_hotel` | `company_id` | 36 952 NULLs / 40 060 rows (92 %) | **Dropped** — `04_nettoyage_des_données_resort_hotel.sql` |
| `resort_hotel` | `assigned_romm_type` | Typo in column name | **Renamed** to `assigned_room_type` — `04_nettoyage_des_données_resort_hotel.sql` |
| `resort_hotel` | `children` | 4 NULLs remaining after TRY_CAST | **Filled** from `babies` value — `04_nettoyage_des_données_resort_hotel.sql` |
| `resort_hotel` | `children` | 1 row with `children = 10` — No-Show row, likely entry error | **Corrected** to `1` — `04_nettoyage_des_données_resort_hotel.sql` |
| `resort_hotel` | `average_daily_rate` | Minimum value is -6.38 (negative ADR) — likely billing corrections | **Kept** — to be investigated and filtered at analysis layer (H5 open) |

---

## 7. EDA Findings & Initial Hypotheses

Produced by `eda_preleminaire.sql` (2026-03-04).

### 7.1 Confirmed Row Counts & Period

| Table | Rows | Period |
|---|---|---|
| `city_hotel` | 79 330 | To be confirmed by query |
| `resort_hotel` | 40 060 | To be confirmed by query |

No duplicate `booking_id` values detected in either table.

### 7.2 Categorical Distributions (key columns)

#### `deposit_type`

| Value | city_hotel | resort_hotel |
|---|---|---|
| No Deposit | 83.8 % | 95.4 % |
| Non Refund | 16.2 % | 4.3 % |
| Refundable | 0.0 % | 0.4 % |

**Observation:** The vast majority of bookings carry no deposit — especially at the Resort Hotel. This makes the financial exposure from cancellations significant.

#### `reservation_status`

| Value | city_hotel | resort_hotel |
|---|---|---|
| Check-Out | 58.3 % | 72.2 % |
| Canceled | 40.6 % | 27.0 % |
| No-Show | 1.2 % | 0.7 % |

**Observation:** The City Hotel has a strikingly high cancellation rate (40.6 %) compared to the Resort Hotel (27.0 %).

### 7.3 Numeric Column Stats

| Column | Table | Min | Max | Mean | Median | Std | NULLs |
|---|---|---|---|---|---|---|---|
| `lead_time_in_days` | city_hotel | 0 | 629 | 109.74 | 74 | 110.95 | 0 |
| `lead_time_in_days` | resort_hotel | 0 | 737 | 92.68 | 57 | 97.29 | 0 |
| `nb_of_changes_into_the_booking` | city_hotel | 0 | 21 | 0.19 | 0 | 0.61 | 0 |
| `nb_of_changes_into_the_booking` | resort_hotel | 0 | 17 | 0.29 | 0 | 0.73 | 0 |
| `nb_of_special_requests` | city_hotel | 0 | 5 | ~0 | 0 | — | 0 |
| `nb_of_special_requests` | resort_hotel | 0 | 5 | ~0 | 0 | — | 0 |
| `average_daily_rate` | city_hotel | 0.00 | 5 400.00 | 105.30 | 99.90 | 43.60 | 0 |
| `average_daily_rate` | resort_hotel | **-6.38** | 508.00 | 94.95 | 75.00 | 61.44 | 0 |

### 7.4 Initial Hypotheses

| # | Hypothesis | Supporting observation | Next step |
|---|---|---|---|
| H1 | No-Show bookings are almost exclusively "No Deposit" | No-Show rate is small (1.2 % / 0.7 %) and correlates structurally with lack of financial commitment | Cross-tab `reservation_status` × `deposit_type` |
| H2 | "Non Refund" deposit strongly reduces cancellation rate | Only 16.2 % of city_hotel bookings are Non Refund yet they may account for a disproportionally low share of cancellations | Cancellation rate by `deposit_type` |
| H3 | Bookings with many modifications are more likely to cancel | Mean changes ≈ 0 but max = 21 — high-change bookings are an outlier group worth profiling | Cancellation rate segmented by `nb_of_changes_into_the_booking` buckets |
| H4 | High number of special requests may correlate with more changes or cancellations | Same pattern: low mean, non-trivial max | Special request count × cancellation rate cross-tab |
| H5 | Negative ADR records in `resort_hotel` are billing correction entries and should be excluded from revenue analysis | Min ADR = -6.38 on resort_hotel | Investigate rows WHERE `average_daily_rate` < 0 |
| H6 | Zero ADR bookings are either complimentary stays or data errors | Min ADR = 0.00 on city_hotel | Investigate rows WHERE `average_daily_rate` = 0 |
