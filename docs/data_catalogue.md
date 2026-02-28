# Data Catalogue — Hotel Booking Analysis

This document inventories all data assets in the project: their origin, format, row count, status, and lineage.

---

## 1. Data Assets Overview

| Asset | Type | Format | Location | Status | Rows |
|---|---|---|---|---|---|
| `hotel_bookings` | Raw source table | SQL Server table (from CSV) | SQL Server DB | Active | 119 390 |
| `resort_hotel` | Typed analytical table | SQL Server table | SQL Server DB | Active | ~40 060 |
| `city_hotel` | Typed analytical table | SQL Server table | SQL Server DB | Active | ~79 330 |

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

### `resort_hotel` (typed)

| Attribute | Value |
|---|---|
| Description | Typed, validated subset of `hotel_bookings` filtered on `hotel = 'Resort Hotel'` |
| Location | Algarve region, Faro area (Portugal) |
| Role | Primary analytical table for Resort Hotel analysis |
| Columns | 30 (32 source columns → 1 date column reconstructed, `booking_id` added) |
| Rows | ~40 060 |
| Loaded by | `01_schema_and_load.sql` |
| Filter | `WHERE hotel = 'Resort Hotel'` |
| Transformations | Date reconstruction, `TRY_CAST` on `children` / `agent` / `company`, column renaming, type enforcement |
| CHECK constraints | `hotel`, `meal`, `distribution_channel`, `deposit_type`, `customer_type`, `reservation_status` |

---

### `city_hotel` (typed)

| Attribute | Value |
|---|---|
| Description | Typed, validated subset of `hotel_bookings` filtered on `hotel = 'City Hotel'` |
| Location | Lisbon (Portugal) |
| Role | Primary analytical table for City Hotel analysis |
| Columns | 30 |
| Rows | ~79 330 |
| Loaded by | `01_schema_and_load.sql` |
| Filter | `WHERE hotel = 'City Hotel'` |
| Transformations | Same as `resort_hotel` |
| CHECK constraints | Same as `resort_hotel` |

---

## 4. Lineage

```
hotel_bookings.csv
        │
        ▼
hotel_bookings  (raw SQL Server table — full import)
        │
        ├──── resort_hotel  (DDL + ETL via 01_schema_and_load.sql, WHERE hotel = 'Resort Hotel')
        │
        └──── city_hotel    (DDL + ETL via 01_schema_and_load.sql, WHERE hotel = 'City Hotel')
```

---

## 5. Scripts

| Script | Role | Tables affected |
|---|---|---|
| `01_schema_and_load.sql` | Creates `resort_hotel` and `city_hotel`, applies CHECK constraints, inserts data from `hotel_bookings` | `resort_hotel`, `city_hotel` |

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
