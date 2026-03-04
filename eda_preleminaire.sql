
-- créer une VIEW des 2 tables
CREATE VIEW all_hotel AS 
    SELECT *
    FROM city_hotel

    UNION ALL

    SELECT *
    FROM resort_hotel;

SELECT *
FROM all_hotel;

-- EDA

-- Nombre de lignes total
SELECT COUNT(*) AS nb_lignes FROM city_hotel;
-- 
SELECT COUNT(*) AS nb_lignes FROM resort_hotel;


-- Période couverte par les données
SELECT
MIN(arrival_date) AS date_debut,
MAX(arrival_date) AS date_fin,
DATEDIFF(day, MIN(arrival_date), MAX(arrival_date)) AS nb_jours
FROM city_hotel;
--
SELECT
MIN(arrival_date) AS date_debut,
MAX(arrival_date) AS date_fin,
DATEDIFF(day, MIN(arrival_date), MAX(arrival_date)) AS nb_jours
FROM resort_hotel;

-- Y a-t-il des doublons sur la clé principale ?
SELECT COUNT(*) AS nb_lignes, COUNT(DISTINCT booking_id) AS nb_ids_uniques FROM city_hotel;
--
SELECT COUNT(*) AS nb_lignes, COUNT(DISTINCT booking_id) AS nb_ids_uniques FROM resort_hotel;
-- Si nb_lignes > nb_ids_uniques → doublons sur id


-- Valeurs uniques et leur fréquence avec % du total sur le pays d'origine
SELECT TOP 5
country_of_origin,
COUNT(*) AS nb,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS pct
FROM city_hotel
GROUP BY country_of_origin
ORDER BY nb DESC;
--
SELECT TOP 5
country_of_origin,
COUNT(*) AS nb,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS pct
FROM resort_hotel
GROUP BY country_of_origin
ORDER BY nb DESC;


-- VERIFICATION DES COLONNES CATEGORIELLE

-- Valeurs uniques et leur fréquence avec % du total
SELECT
market_segment,
COUNT(*) AS nb,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS pct
FROM city_hotel
GROUP BY market_segment
ORDER BY nb DESC;
--
SELECT
market_segment,
COUNT(*) AS nb,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS pct
FROM resort_hotel
GROUP BY market_segment
ORDER BY nb DESC;


-- Valeurs uniques et leur fréquence avec % du total
SELECT
distribution_channel,
COUNT(*) AS nb,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS pct
FROM city_hotel
GROUP BY distribution_channel
ORDER BY nb DESC;
--
SELECT
distribution_channel,
COUNT(*) AS nb,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS pct
FROM resort_hotel
GROUP BY distribution_channel
ORDER BY nb DESC;


-- Valeurs uniques et leur fréquence avec % du total
SELECT
assigned_romm_type,
COUNT(*) AS nb,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS pct
FROM city_hotel
GROUP BY assigned_romm_type
ORDER BY nb DESC;
--
SELECT
assigned_romm_type,
COUNT(*) AS nb,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS pct
FROM resort_hotel
GROUP BY assigned_romm_type
ORDER BY nb DESC;


-- Valeurs uniques et leur fréquence avec % du total
SELECT
deposit_type,
COUNT(*) AS nb,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS pct
FROM city_hotel
GROUP BY deposit_type
ORDER BY nb DESC;
--
SELECT
deposit_type,
COUNT(*) AS nb,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS pct
FROM resort_hotel
GROUP BY deposit_type
ORDER BY nb DESC;

/*
city_hotel
No Deposit	66442	83.800000000000
Non Refund	12868	16.200000000000
Refundable	20	    0.000000000000

resort_hotel
No Deposit	38199	95.400000000000
Non Refund	1719	4.300000000000
Refundable	142	    0.400000000000

Très intéressant de voir la part de résa sans Deposit, à creuser pour voir 
la part d'annulation pour chaque
*/


-- Valeurs uniques et leur fréquence avec % du total
SELECT
reservation_status,
COUNT(*) AS nb,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS pct
FROM city_hotel
GROUP BY reservation_status
ORDER BY nb DESC;
--
SELECT
reservation_status,
COUNT(*) AS nb,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS pct
FROM resort_hotel
GROUP BY reservation_status
ORDER BY nb DESC;

/*
city_hotel
Check-Out	46228	58.300000000000
Canceled	32186	40.600000000000
No-Show 	916	    1.200000000000

resort_hotel
Check-Out	28938	72.200000000000
Canceled	10831	27.000000000000
No-Show	    291	    0.700000000000

Hypothése : Les No-Show sont pour tous ou presque sans Deposit
*/


-- VERIFICATION DES COLONNES NUMERIQUE

-- Vérification générale de la colonne de résa en avance
SELECT DISTINCT
    COUNT(lead_time_in_days) OVER() AS nb_valeurs,
    COUNT(*) OVER() - COUNT(lead_time_in_days) OVER() AS nb_nulls,
    MIN(lead_time_in_days) OVER() AS minimum,
    MAX(lead_time_in_days) OVER() AS maximum,
    ROUND(AVG(CAST(lead_time_in_days AS FLOAT)) OVER(), 2) AS moyenne,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY lead_time_in_days) OVER() AS mediane,
    ROUND(STDEV(lead_time_in_days) OVER(), 2) AS ecart_type
FROM city_hotel;
--
SELECT DISTINCT
    COUNT(lead_time_in_days) OVER() AS nb_valeurs,
    COUNT(*) OVER() - COUNT(lead_time_in_days) OVER() AS nb_nulls,
    MIN(lead_time_in_days) OVER() AS minimum,
    MAX(lead_time_in_days) OVER() AS maximum,
    ROUND(AVG(CAST(lead_time_in_days AS FLOAT)) OVER(), 2) AS moyenne,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY lead_time_in_days) OVER() AS mediane,
    ROUND(STDEV(lead_time_in_days) OVER(), 2) AS ecart_type
FROM resort_hotel;

/*
city_hotel
79330	0	0	629	109,74	74	110,95
resort_hotel
40060	0	0	737	92,68	57	97,29
*/


-- Vérification générale de la colonne de jour resté en semaine
SELECT DISTINCT
    COUNT(nb_of_week_nights) OVER() AS nb_valeurs,
    COUNT(*) OVER() - COUNT(nb_of_week_nights) OVER() AS nb_nulls,
    MIN(nb_of_week_nights) OVER() AS minimum,
    MAX(nb_of_week_nights) OVER() AS maximum,
    ROUND(AVG(CAST(nb_of_week_nights AS FLOAT)) OVER(), 2) AS moyenne,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY nb_of_week_nights) OVER() AS mediane,
    ROUND(STDEV(nb_of_week_nights) OVER(), 2) AS ecart_type
FROM city_hotel;
--
SELECT DISTINCT
    COUNT(nb_of_week_nights) OVER() AS nb_valeurs,
    COUNT(*) OVER() - COUNT(nb_of_week_nights) OVER() AS nb_nulls,
    MIN(nb_of_week_nights) OVER() AS minimum,
    MAX(nb_of_week_nights) OVER() AS maximum,
    ROUND(AVG(CAST(nb_of_week_nights AS FLOAT)) OVER(), 2) AS moyenne,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY nb_of_week_nights) OVER() AS mediane,
    ROUND(STDEV(nb_of_week_nights) OVER(), 2) AS ecart_type
FROM resort_hotel;

-- Vérification générale de la colonne de jour resté le weekend
SELECT DISTINCT
    COUNT(nb_of_weekend_nights) OVER() AS nb_valeurs,
    COUNT(*) OVER() - COUNT(nb_of_weekend_nights) OVER() AS nb_nulls,
    MIN(nb_of_weekend_nights) OVER() AS minimum,
    MAX(nb_of_weekend_nights) OVER() AS maximum,
    ROUND(AVG(CAST(nb_of_weekend_nights AS FLOAT)) OVER(), 2) AS moyenne,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY nb_of_weekend_nights) OVER() AS mediane,
    ROUND(STDEV(nb_of_weekend_nights) OVER(), 2) AS ecart_type
FROM city_hotel;
--
SELECT DISTINCT
    COUNT(nb_of_weekend_nights) OVER() AS nb_valeurs,
    COUNT(*) OVER() - COUNT(nb_of_weekend_nights) OVER() AS nb_nulls,
    MIN(nb_of_weekend_nights) OVER() AS minimum,
    MAX(nb_of_weekend_nights) OVER() AS maximum,
    ROUND(AVG(CAST(nb_of_weekend_nights AS FLOAT)) OVER(), 2) AS moyenne,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY nb_of_weekend_nights) OVER() AS mediane,
    ROUND(STDEV(nb_of_weekend_nights) OVER(), 2) AS ecart_type
FROM resort_hotel;


-- Vérification générale de la colonne de nombre de changements dans les résa
SELECT DISTINCT
    COUNT(nb_of_changes_into_the_booking) OVER() AS nb_valeurs,
    COUNT(*) OVER() - COUNT(nb_of_changes_into_the_booking) OVER() AS nb_nulls,
    MIN(nb_of_changes_into_the_booking) OVER() AS minimum,
    MAX(nb_of_changes_into_the_booking) OVER() AS maximum,
    ROUND(AVG(CAST(nb_of_changes_into_the_booking AS FLOAT)) OVER(), 2) AS moyenne,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY nb_of_changes_into_the_booking) OVER() AS mediane,
    ROUND(STDEV(nb_of_changes_into_the_booking) OVER(), 2) AS ecart_type
FROM city_hotel;
--
SELECT DISTINCT
    COUNT(nb_of_changes_into_the_booking) OVER() AS nb_valeurs,
    COUNT(*) OVER() - COUNT(nb_of_changes_into_the_booking) OVER() AS nb_nulls,
    MIN(nb_of_changes_into_the_booking) OVER() AS minimum,
    MAX(nb_of_changes_into_the_booking) OVER() AS maximum,
    ROUND(AVG(CAST(nb_of_changes_into_the_booking AS FLOAT)) OVER(), 2) AS moyenne,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY nb_of_changes_into_the_booking) OVER() AS mediane,
    ROUND(STDEV(nb_of_changes_into_the_booking) OVER(), 2) AS ecart_type
FROM resort_hotel;

/*
city_hotel      79330	0	0	21	0,19	0	0,61
resort_hotel    40060	0	0	17	0,29	0	0,73

une moyenne proche de zéro mais des MAX élevés, donc peu de changement mais
les résa qui effectue des changements en font beaucoup.
Et si ils finissent par annulé. quel deposit et quand ont ils réservé
*/


-- Vérification générale de la colonne de nombre de Spécial Request
SELECT DISTINCT
    COUNT(nb_of_special_requests) OVER() AS nb_valeurs,
    COUNT(*) OVER() - COUNT(nb_of_special_requests) OVER() AS nb_nulls,
    MIN(nb_of_special_requests) OVER() AS minimum,
    MAX(nb_of_special_requests) OVER() AS maximum,
    ROUND(AVG(CAST(nb_of_special_requests AS FLOAT)) OVER(), 2) AS moyenne,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY nb_of_special_requests) OVER() AS mediane,
    ROUND(STDEV(nb_of_special_requests) OVER(), 2) AS ecart_type
FROM city_hotel;
--
SELECT DISTINCT
    COUNT(nb_of_special_requests) OVER() AS nb_valeurs,
    COUNT(*) OVER() - COUNT(nb_of_special_requests) OVER() AS nb_nulls,
    MIN(nb_of_special_requests) OVER() AS minimum,
    MAX(nb_of_special_requests) OVER() AS maximum,
    ROUND(AVG(CAST(nb_of_special_requests AS FLOAT)) OVER(), 2) AS moyenne,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY nb_of_special_requests) OVER() AS mediane,
    ROUND(STDEV(nb_of_special_requests) OVER(), 2) AS ecart_type
FROM resort_hotel;

/*
Moyenne proche de Zéro, mais un max à 5. voir si les mêmes changent beaucoup leur résa
et si ils finissent par annulé. quel deposit et quand ont ils réservé
*/


-- Vérification générale de la colonne de nombre de Spécial Request
SELECT DISTINCT
    COUNT(average_daily_rate) OVER() AS nb_valeurs,
    COUNT(*) OVER() - COUNT(average_daily_rate) OVER() AS nb_nulls,
    MIN(average_daily_rate) OVER() AS minimum,
    MAX(average_daily_rate) OVER() AS maximum,
    ROUND(AVG(CAST(average_daily_rate AS FLOAT)) OVER(), 2) AS moyenne,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY average_daily_rate) OVER() AS mediane,
    ROUND(STDEV(average_daily_rate) OVER(), 2) AS ecart_type
FROM city_hotel;
--
SELECT DISTINCT
    COUNT(average_daily_rate) OVER() AS nb_valeurs,
    COUNT(*) OVER() - COUNT(average_daily_rate) OVER() AS nb_nulls,
    MIN(average_daily_rate) OVER() AS minimum,
    MAX(average_daily_rate) OVER() AS maximum,
    ROUND(AVG(CAST(average_daily_rate AS FLOAT)) OVER(), 2) AS moyenne,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY average_daily_rate) OVER() AS mediane,
    ROUND(STDEV(average_daily_rate) OVER(), 2) AS ecart_type
FROM resort_hotel;
/*
city_hotel      79330	0	0.00	5400.00	105,3	99,9	43,6
resort_hotel    40060	0	-6.38	508.00	94,95	75	    61,44

Médianne et moyenne plutôt proche
verifier les minimum négatif sur le resort_hotel, et les Zéro également.
Vérifier le max 5400 city_hotel (Outlier)
*/
