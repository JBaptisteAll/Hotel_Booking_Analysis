# Data Dictionary — Hotel Booking Analysis

This document defines every column present in the project's tables, including the raw source table and the two typed analytical tables.

---

## Table: `hotel_bookings` (raw)

Source: `Data/hotel_bookings.csv` — imported as-is, minimal typing.

| Column | Raw Type | Description | Example Values |
|---|---|---|---|
| `hotel` | varchar | Hotel identifier | `Resort Hotel`, `City Hotel` |
| `is_canceled` | int | Cancellation flag | `0`, `1` |
| `lead_time` | int | Days between booking date and arrival date | `0`, `45`, `365` |
| `arrival_date_year` | int | Year of arrival | `2015`, `2016`, `2017` |
| `arrival_date_month` | varchar | Month of arrival (English text) | `July`, `August`, `January` |
| `arrival_date_week_number` | int | ISO week number of arrival | `1`–`53` |
| `arrival_date_day_of_month` | int | Day of month of arrival | `1`–`31` |
| `stays_in_weekend_nights` | int | Number of weekend nights (Sat/Sun) in the stay | `0`, `1`, `2` |
| `stays_in_week_nights` | int | Number of weekday nights (Mon–Fri) in the stay | `0`–`50` |
| `adults` | int | Number of adults | `1`, `2`, `3` |
| `children` | varchar | Number of children — **contains `'NA'` strings** | `0`, `1`, `NA` |
| `babies` | int | Number of babies | `0`, `1`, `2` |
| `meal` | varchar | Meal plan booked | `BB`, `HB`, `FB`, `SC`, `Undefined` |
| `country` | varchar | Guest origin country (ISO 3166-1 alpha-3) | `PRT`, `GBR`, `FRA`, `DEU` |
| `market_segment` | varchar | Booking market segment | `Online TA`, `Offline TA/TO`, `Direct`, `Corporate`, `Groups`, `Complementary`, `Aviation` |
| `distribution_channel` | varchar | Booking distribution channel | `TA/TO`, `Direct`, `Corporate`, `GDS`, `Undefined` |
| `is_repeated_guest` | int | Whether the guest has previously stayed at the hotel | `0`, `1` |
| `previous_cancellations` | int | Number of prior bookings cancelled by the guest | `0`, `1`, `26` |
| `previous_bookings_not_canceled` | int | Number of prior bookings not cancelled by the guest | `0`, `1`, `72` |
| `reserved_room_type` | varchar | Room type code requested at booking | `A`–`L` |
| `assigned_room_type` | varchar | Room type code actually assigned at check-in | `A`–`L` |
| `booking_changes` | int | Number of changes made to the booking before arrival or cancellation | `0`, `1`, `2` |
| `deposit_type` | varchar | Deposit policy applied to the booking | `No Deposit`, `Non Refund`, `Refundable` |
| `agent` | varchar | ID of the travel agency that made the booking — **NULLs present** | `240`, `9`, `NULL` |
| `company` | varchar | ID of the company that made the booking — **NULLs present** | `45`, `NULL` |
| `days_in_waiting_list` | int | Days the booking spent on the waiting list before confirmation | `0`, `1`, `391` |
| `customer_type` | varchar | Type of booking/customer | `Transient`, `Transient-Party`, `Contract`, `Group` |
| `adr` | float | Average Daily Rate — total room revenue divided by number of nights | `0.00`, `75.00`, `254.50` |
| `required_car_parking_spaces` | int | Number of car parking spaces requested | `0`, `1`, `2` |
| `total_of_special_requests` | int | Number of special requests made by the guest | `0`–`5` |
| `reservation_status` | varchar | Final reservation status | `Check-Out`, `Canceled`, `No-Show` |
| `reservation_status_date` | date | Date of the last reservation status update | `2015-07-01` |

---

## Tables: `resort_hotel` & `city_hotel` (typed)

Both tables share the same structure. They are populated from `hotel_bookings` via `01_schema_and_load.sql`.

| Column | Type | Description | Transformation vs. Source | Domain / Constraints |
|---|---|---|---|---|
| `booking_id` | `INT IDENTITY(0,1)` | Auto-generated surrogate key | Added — not in source | — |
| `hotel` | `VARCHAR(20)` | Hotel identifier | Direct copy | CHECK: `'Resort Hotel'` or `'City Hotel'` |
| `is_canceled` | `BIT` | Cancellation flag | Direct cast | `0` or `1` |
| `lead_time_in_days` | `INT` | Days between booking and arrival | Renamed from `lead_time` | ≥ 0 |
| `arrival_date` | `DATE` | Full arrival date | Reconstructed from `arrival_date_year`, `arrival_date_month`, `arrival_date_day_of_month` using `DATEFROMPARTS` | — |
| `arrival_week_nb` | `INT` | ISO week number of arrival | Renamed from `arrival_date_week_number` | `1`–`53` |
| `nb_of_weekend_nights` | `INT` | Weekend nights in stay | Renamed from `stays_in_weekend_nights` | ≥ 0 |
| `nb_of_week_nights` | `INT` | Weekday nights in stay | Renamed from `stays_in_week_nights` | ≥ 0 |
| `adults` | `INT` | Number of adults | Direct copy | ≥ 0 |
| `children` | `INT` | Number of children | `TRY_CAST(children AS INT)` — `'NA'` → `NULL` | ≥ 0 or NULL |
| `babies` | `INT` | Number of babies | Direct copy | ≥ 0 |
| `meal` | `VARCHAR(10)` | Meal plan | Direct copy | CHECK: `FB`, `HB`, `SC`, `BB`, `Undefined` |
| `country_of_origin` | `VARCHAR(5)` | Guest origin country (ISO 3166-1 alpha-3) | Renamed from `country` | — |
| `market_segment` | `VARCHAR(20)` | Booking market segment | Direct copy | — |
| `distribution_channel` | `VARCHAR(20)` | Booking distribution channel | Direct copy | CHECK: `Corporate`, `TA/TO`, `Direct`, `Undefined`, `GDS` |
| `repeated_guest` | `BIT` | Whether guest previously stayed | Renamed from `is_repeated_guest` | `0` or `1` |
| `nb_of_booking_cancelled` | `INT` | Prior cancellations by this guest | Renamed from `previous_cancellations` | ≥ 0 |
| `nb_of_booking_not_cancelled` | `INT` | Prior completed stays by this guest | Renamed from `previous_bookings_not_canceled` | ≥ 0 |
| `reserved_room_type` | `VARCHAR(1)` | Room type requested at booking | Direct copy | `A`–`L` |
| `assigned_romm_type` | `VARCHAR(1)` | Room type assigned at check-in | Renamed from `assigned_room_type` | `A`–`L` |
| `nb_of_changes_into_the_booking` | `INT` | Number of booking modifications | Renamed from `booking_changes` | ≥ 0 |
| `deposit_type` | `VARCHAR(10)` | Deposit policy | Direct copy | CHECK: `No Deposit`, `Refundable`, `Non Refund` |
| `travel_agency_id` | `INT` | Travel agency ID | `TRY_CAST(agent AS INT)` — `NULL` strings → `NULL` | NULL = direct booking |
| `company_id` | `INT` | Company ID | `TRY_CAST(company AS INT)` — `NULL` strings → `NULL` | NULL = non-corporate booking |
| `days_in_waiting_list` | `INT` | Days on waiting list before confirmation | Direct copy | ≥ 0 |
| `customer_type` | `VARCHAR(20)` | Customer/booking type | Direct copy | CHECK: `Group`, `Contract`, `Transient`, `Transient-Party` |
| `average_daily_rate` | `DECIMAL(18,2)` | Revenue per room per night (EUR) | Renamed + retyped from `adr` (float → DECIMAL) | Can be 0 or negative (corrections) |
| `nb_of_carpark_required` | `INT` | Parking spaces requested | Renamed from `required_car_parking_spaces` | ≥ 0 |
| `nb_of_special_requests` | `INT` | Number of special requests | Renamed from `total_of_special_requests` | `0`–`5` |
| `reservation_status` | `VARCHAR(15)` | Final reservation status | Direct copy | CHECK: `Check-Out`, `Canceled`, `No-Show` |
| `reservation_status_date` | `DATETIME` | Date of last status change | Direct copy | — |

---

## Meal Plan Codes

| Code | Description |
|---|---|
| `BB` | Bed & Breakfast |
| `HB` | Half Board (breakfast + dinner) |
| `FB` | Full Board (breakfast + lunch + dinner) |
| `SC` | Self Catering (no meals) |
| `Undefined` | Not specified |

## Room Type Codes

Room types are anonymized letter codes (`A` through `L`). `A` is the most common room type. Comparing `reserved_room_type` vs. `assigned_romm_type` indicates upgrades (assigned > reserved) or downgrades (assigned < reserved).
