-- Détecter les NULLs
SELECT
    SUM(CASE WHEN is_canceled              IS NULL THEN 1 ELSE 0 END) AS is_canceled_nulls,
    SUM(CASE WHEN lead_time_in_days        IS NULL THEN 1 ELSE 0 END) AS lead_time_nulls,
    SUM(CASE WHEN arrival_date             IS NULL THEN 1 ELSE 0 END) AS arrival_date_nulls,
    SUM(CASE WHEN nb_of_weekend_nights        IS NULL THEN 1 ELSE 0 END) AS weekdd_nulls,
    SUM(CASE WHEN nb_of_week_nights         IS NULL THEN 1 ELSE 0 END) AS weekenddd_nulls,
    SUM(CASE WHEN adults               IS NULL THEN 1 ELSE 0 END) AS adults_nulls,
    SUM(CASE WHEN children       IS NULL THEN 1 ELSE 0 END) AS children_nulls,
    SUM(CASE WHEN babies       IS NULL THEN 1 ELSE 0 END) AS babies_nulls,
    SUM(CASE WHEN meal       IS NULL THEN 1 ELSE 0 END) AS meal_nulls,
    SUM(CASE WHEN country_of_origin       IS NULL THEN 1 ELSE 0 END) AS country_nulls,
    SUM(CASE WHEN market_segment       IS NULL THEN 1 ELSE 0 END) AS market_nulls,
    SUM(CASE WHEN distribution_channel       IS NULL THEN 1 ELSE 0 END) AS dist_nulls,
    SUM(CASE WHEN repeated_guest       IS NULL THEN 1 ELSE 0 END) AS repeat_nulls,
    SUM(CASE WHEN nb_of_booking_cancelled       IS NULL THEN 1 ELSE 0 END) AS nb_cancel_nulls,
    SUM(CASE WHEN nb_of_booking_not_cancelled       IS NULL THEN 1 ELSE 0 END) AS nb_not_cancel_nulls,
    SUM(CASE WHEN reserved_room_type       IS NULL THEN 1 ELSE 0 END) AS room_res_nulls,
    SUM(CASE WHEN assigned_romm_type       IS NULL THEN 1 ELSE 0 END) AS room_ass_nulls,
    SUM(CASE WHEN nb_of_changes_into_the_booking       IS NULL THEN 1 ELSE 0 END) AS change_bk_nulls,
    SUM(CASE WHEN deposit_type       IS NULL THEN 1 ELSE 0 END) AS deposit_nulls,
    SUM(CASE WHEN travel_agency_id       IS NULL THEN 1 ELSE 0 END) AS travel_agent_nulls,
    SUM(CASE WHEN company_id       IS NULL THEN 1 ELSE 0 END) AS cie_nulls,
    SUM(CASE WHEN days_in_waiting_list       IS NULL THEN 1 ELSE 0 END) AS wait_list_nulls,
    SUM(CASE WHEN customer_type       IS NULL THEN 1 ELSE 0 END) AS custom_type_nulls,
    SUM(CASE WHEN average_daily_rate       IS NULL THEN 1 ELSE 0 END) AS adr_nulls,
    SUM(CASE WHEN nb_of_carpark_required       IS NULL THEN 1 ELSE 0 END) AS car_nulls,
    SUM(CASE WHEN nb_of_special_requests       IS NULL THEN 1 ELSE 0 END) AS request_nulls,
    SUM(CASE WHEN reservation_status       IS NULL THEN 1 ELSE 0 END) AS status_nulls,
    SUM(CASE WHEN reservation_status_date       IS NULL THEN 1 ELSE 0 END) AS status_date_nulls
FROM resort_hotel;

/*
À voir peut-être pour créer une table avec seulement les réservations qui ont pas de travel agent
cie_nulls 36952
travel_agent_nulls 8209


Concernant les children nuls que faire un COALESCE qui reprend la donnée de baby de la même manière 
que je l'ai fait sur l'autre table afin d'harmoniser les requêtes.

Et pour les compagnies nulls et les travel agent nulls du coup je pense supprimer la colonne compagnie
Car sur un total de 40060 lignes 36952 lignes de vide c'est conséquent Quant au travel agent à voir
*/
SELECT *
FROM resort_hotel

-- NETTOYAGE

-- suppression de la colonne company_id avec trop de valeur NULL
ALTER TABLE resort_hotel DROP COLUMN company_id;

-- Renommer la colonne avec une faute de frappe
EXEC sp_rename 'resort_hotel.assigned_romm_type', 'assigned_room_type', 'COLUMN';

-- Mise à jour de la colonne children pour remplir les NULLs par les valeurs de la colonne babies
UPDATE resort_hotel SET children = babies WHERE children IS NULL;

-- Vérification
SELECT *
FROM resort_hotel
WHERE children IS NULL;



-- Détecter les doublons
SELECT booking_id, COUNT(*) FROM resort_hotel GROUP BY booking_id HAVING COUNT(*) > 1;


--Profil des colonnes numérique

-- Prix moyen par jour
SELECT
COUNT(*) AS total_lignes,
COUNT(average_daily_rate) AS valeurs_renseignees,
COUNT(*) - COUNT(average_daily_rate) AS nb_nulls,
MIN(average_daily_rate) AS minimum,
MAX(average_daily_rate) AS maximum,
ROUND(AVG(average_daily_rate), 2) AS moyenne,
ROUND(STDEV(average_daily_rate), 2) AS ecart_type
FROM resort_hotel;

SELECT *
FROM resort_hotel
ORDER BY average_daily_rate DESC;

/*
Pas de faute apparente sur la colonne ADR

Les minimum en négatif creuser cette partie afin de segmenter les ce type de clients que ça peut être 
*/


-- Changement dans la résa
SELECT
COUNT(*) AS total_lignes,
COUNT(nb_of_changes_into_the_booking) AS valeurs_renseignees,
COUNT(*) - COUNT(nb_of_changes_into_the_booking) AS nb_nulls,
MIN(nb_of_changes_into_the_booking) AS minimum,
MAX(nb_of_changes_into_the_booking) AS maximum,
ROUND(AVG(nb_of_changes_into_the_booking), 2) AS moyenne,
ROUND(STDEV(nb_of_changes_into_the_booking), 2) AS ecart_type
FROM resort_hotel;

SELECT *
FROM resort_hotel
ORDER BY nb_of_changes_into_the_booking;

/*
Pas de pattern particulier sur le nombre de changements dans la réservation 
*/

-- Annulation
SELECT
COUNT(*) AS total_lignes,
COUNT(nb_of_booking_not_cancelled) AS valeurs_renseignees,
COUNT(*) - COUNT(nb_of_booking_not_cancelled) AS nb_nulls,
MIN(nb_of_booking_not_cancelled) AS minimum,
MAX(nb_of_booking_not_cancelled) AS maximum,
ROUND(AVG(nb_of_booking_not_cancelled), 2) AS moyenne,
ROUND(STDEV(nb_of_booking_not_cancelled), 2) AS ecart_type
FROM resort_hotel;

SELECT *
FROM resort_hotel
ORDER BY nb_of_booking_not_cancelled DESC;

/*
Pas de pattern particulier sur le nombre de changements dans la réservation 
*/

SELECT
COUNT(*) AS total_lignes,
COUNT(nb_of_booking_cancelled) AS valeurs_renseignees,
COUNT(*) - COUNT(nb_of_booking_cancelled) AS nb_nulls,
MIN(nb_of_booking_cancelled) AS minimum,
MAX(nb_of_booking_cancelled) AS maximum,
ROUND(AVG(nb_of_booking_cancelled), 2) AS moyenne,
ROUND(STDEV(nb_of_booking_cancelled), 2) AS ecart_type
FROM resort_hotel;

SELECT *
FROM resort_hotel
ORDER BY nb_of_booking_cancelled DESC;

/*
Il semble que certains agents de voyage réservent plusieurs chambres en avance et les annule plus tard 
probablement des invendus, probablement pertinent de regarder ces Markets segments afin de creuser 
Un peu plus cette partie et d'adapter ma stratégie et politique d'annulation 

Je vais créer une colonne pour calculer le nombre de réservations au total 
effectué par les clients, l'idée va être de faire un ratio
*/

ALTER TABLE resort_hotel
ADD nb_total_of_booking AS (nb_of_booking_cancelled + nb_of_booking_not_cancelled);

SELECT
COUNT(*) AS total_lignes,
COUNT(nb_total_of_booking) AS valeurs_renseignees,
COUNT(*) - COUNT(nb_total_of_booking) AS nb_nulls,
MIN(nb_total_of_booking) AS minimum,
MAX(nb_total_of_booking) AS maximum,
ROUND(AVG(nb_total_of_booking), 2) AS moyenne,
ROUND(STDEV(nb_total_of_booking), 2) AS ecart_type
FROM resort_hotel;

SELECT *
FROM resort_hotel
ORDER BY nb_total_of_booking DESC;

/*
Il semble que les corporates et le moins de réservation non annulée 
Au contraire les groupes ainsi que les offline TA/TO soit ceux qui annulent le plus de réservation

Je pense donc qu'il est intéressant de regarder cette colonne Market segment et de voir le type de deposit 
Qu'on leur propose 
*/


-- Bébé / Enfants / adultes
SELECT
COUNT(*) AS total_lignes,
COUNT(babies) AS valeurs_renseignees,
COUNT(*) - COUNT(babies) AS nb_nulls,
MIN(babies) AS minimum,
MAX(babies) AS maximum,
ROUND(AVG(babies), 2) AS moyenne,
ROUND(STDEV(babies), 2) AS ecart_type
FROM resort_hotel;

SELECT
COUNT(*) AS total_lignes,
COUNT(children) AS valeurs_renseignees,
COUNT(*) - COUNT(children) AS nb_nulls,
MIN(children) AS minimum,
MAX(children) AS maximum,
ROUND(AVG(children), 2) AS moyenne,
ROUND(STDEV(children), 2) AS ecart_type
FROM resort_hotel;

/*
Il y a une ligne avec 10 enfants, je suppose que c'est une erreur vu qu'elle est en No-Show 
je préfère la changer pour un enfant 
*/
UPDATE resort_hotel
SET children = 1 WHERE children = 10;


SELECT
COUNT(*) AS total_lignes,
COUNT(adults) AS valeurs_renseignees,
COUNT(*) - COUNT(adults) AS nb_nulls,
MIN(adults) AS minimum,
MAX(adults) AS maximum,
ROUND(AVG(adults), 2) AS moyenne,
ROUND(STDEV(adults), 2) AS ecart_type
FROM resort_hotel;

SELECT *
FROM resort_hotel
ORDER BY adults DESC;

/*
Il y a pas mal de groupes avec beaucoup de personnes mais il semble aussi beaucoup annulé 
*/

-- Nombre de nuits
SELECT
COUNT(*) AS total_lignes,
COUNT(nb_of_weekend_nights) AS valeurs_renseignees,
COUNT(*) - COUNT(nb_of_weekend_nights) AS nb_nulls,
MIN(nb_of_weekend_nights) AS minimum,
MAX(nb_of_weekend_nights) AS maximum,
ROUND(AVG(nb_of_weekend_nights), 2) AS moyenne,
ROUND(STDEV(nb_of_weekend_nights), 2) AS ecart_type
FROM resort_hotel;

SELECT *
FROM resort_hotel
ORDER BY nb_of_weekend_nights DESC;


-- Nombre de jours avant arrivée
SELECT
COUNT(*) AS total_lignes,
COUNT(lead_time_in_days) AS valeurs_renseignees,
COUNT(*) - COUNT(lead_time_in_days) AS nb_nulls,
MIN(lead_time_in_days) AS minimum,
MAX(lead_time_in_days) AS maximum,
ROUND(AVG(lead_time_in_days), 2) AS moyenne,
ROUND(STDEV(lead_time_in_days), 2) AS ecart_type
FROM resort_hotel;

SELECT *
FROM resort_hotel
ORDER BY lead_time_in_days DESC;

/*
Encore une fois pas mal de réservations qui ont été annulées lorsqu'elles ont été faites longtemps en avance 
Mais ça reste des gros blocs d'annulation, donc je pense que pour cette table la le Market segment et le plus important 

segmenter cette colonne afin de les regrouper, afin d'harmoniser les 2 tables
*/

ALTER TABLE resort_hotel
ADD lead_time_segment AS (
    CASE
        WHEN lead_time_in_days = 0 THEN 'Same Day'
        WHEN lead_time_in_days <= 5 THEN 'Last Minute'
        WHEN lead_time_in_days <= 15 THEN 'Short'
        WHEN lead_time_in_days <= 30 THEN 'Medium'
        WHEN lead_time_in_days <= 100 THEN 'Long'
        WHEN lead_time_in_days <= 360 THEN 'X Long'
        ELSE 'XXL'
    END
) PERSISTED;



/*
Ajouter une colonne avec le montant total par résa
(nb_of_weekend_nights + nb_of_week_nights) * average_daily_rate
*/
ALTER TABLE resort_hotel
ADD total_revenue AS (nb_of_weekend_nights + nb_of_week_nights) * average_daily_rate PERSISTED;


SELECT *
FROM resort_hotel
ORDER BY total_revenue DESC;