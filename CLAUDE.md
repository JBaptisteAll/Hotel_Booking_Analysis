# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Hotel Booking Analysis** — Analyzing hotel booking patterns and cancellations by correlating reservation data with weather conditions and special events to identify demand drivers and revenue optimization opportunities.

This project is part of Jean-Baptiste Allombert's data analytics portfolio. See the root-level `CLAUDE.md` for the broader repository context and common stack conventions.

## Dataset

**`Data/hotel_bookings.csv`** — 119,390 rows, ~16 MB. Source: the well-known Kaggle hotel bookings dataset.

Key columns:
| Column | Description |
|---|---|
| `hotel` | `Resort Hotel` or `City Hotel` |
| `is_canceled` | 1 = canceled, 0 = not canceled |
| `lead_time` | Days between booking date and arrival |
| `arrival_date_year/month/week_number/day_of_month` | Arrival date components |
| `stays_in_weekend_nights`, `stays_in_week_nights` | Length of stay breakdown |
| `market_segment`, `distribution_channel` | Booking channel |
| `reserved_room_type`, `assigned_room_type` | Room upgrade/downgrade tracking |
| `adr` | Average Daily Rate (revenue metric) |
| `deposit_type` | No Deposit / Non Refund / Refundable |
| `customer_type` | Transient / Contract / Group / Transient-Party |
| `reservation_status` | Check-Out / Canceled / No-Show |
| `country` | Origin country (ISO 3166) |
| `agent`, `company` | Booking agent/company IDs (NULLs present) |

## Current State

- `main.sql` — skeleton query (`SELECT * FROM hotel_bookings`), to be expanded
- `Data/hotel_bookings.csv` — raw dataset, not transformed yet
- No ETL scripts, dashboards, or weather/events integration yet

## Anticipated Stack

Consistent with the portfolio's other SQL + Python projects:
- **SQL** (analysis queries) — target SQL Server or PostgreSQL
- **Python + Pandas** (ETL, enrichment with weather/events data)
- **Streamlit + Plotly** (dashboard, if a front-end is added)
- **Power BI** (reporting layer, optional)

## Key Analysis Goals

1. **Cancellation drivers** — lead time, deposit type, market segment, season
2. **Revenue optimization** — ADR trends by hotel type, room type, customer segment
3. **Demand patterns** — seasonality, country of origin, special request frequency
4. **Weather/events correlation** — external enrichment to explain demand spikes/drops
