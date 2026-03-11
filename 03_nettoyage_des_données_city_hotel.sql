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
FROM city_hotel;

/*
À voir peut-être pour créer une table avec seulement les réservations qui ont pas de travel agent
cie_nulls 75641
travel_agent_nulls 8131

children_nulls 4

Concernant les children nuls que faire un COALESCE qui reprend la donnée de baby nulle comme ça si
Je n'ai pas lu il faut des enfants je reprends celles des bébés.

Et pour les compagnies nues et les travel legent nuls du coup je pense supprimer la colonne compagnie
Car sur un total de 79000 lignes 75000 lignes de vide c'est conséquent Quant au travel agent à voir
*/

-- NETTOYAGE

-- suppression de la colonne company_id avec trop de valeur NULL
ALTER TABLE city_hotel DROP COLUMN company_id;

-- Renommer la colonne avec une faute de frappe
EXEC sp_rename 'city_hotel.assigned_romm_type', 'assigned_room_type', 'COLUMN';

-- Mise à jour de la colonne children pour remplir les NULLs par les valeurs de la colonne babies
UPDATE city_hotel SET children = babies WHERE children IS NULL;

-- Vérification
SELECT *
FROM city_hotel
WHERE children IS NULL;



-- Détecter les doublons
SELECT booking_id, COUNT(*) FROM city_hotel GROUP BY booking_id HAVING COUNT(*) > 1;


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
FROM city_hotel;

SELECT *
FROM city_hotel
ORDER BY average_daily_rate DESC;

/*
La réservation avec un montant de 5400 et probablement une faute de frappe
Étant donné que la valeur maximale juste après est de 510 et que la reservation
concerné 2 adultes pour 1 nuit.
De toute façon la réservation à 5400a été annulé, je vais changer 5400 pour 540.
*/
UPDATE city_hotel SET average_daily_rate = 540 WHERE average_daily_rate = 5400;

-- Changement dans la résa
SELECT
COUNT(*) AS total_lignes,
COUNT(nb_of_changes_into_the_booking) AS valeurs_renseignees,
COUNT(*) - COUNT(nb_of_changes_into_the_booking) AS nb_nulls,
MIN(nb_of_changes_into_the_booking) AS minimum,
MAX(nb_of_changes_into_the_booking) AS maximum,
ROUND(AVG(nb_of_changes_into_the_booking), 2) AS moyenne,
ROUND(STDEV(nb_of_changes_into_the_booking), 2) AS ecart_type
FROM city_hotel;

SELECT *
FROM city_hotel
ORDER BY nb_of_changes_into_the_booking;

/*
Un grand nombre de réservations avec beaucoup de changements ils ne sont pas annulés
Il semble que moins le changements sont effectués sur la réservation et plus
Il y a de chance pour qu'il annule, cela reste à vérifier.
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
FROM city_hotel;

SELECT *
FROM city_hotel
ORDER BY nb_of_booking_not_cancelled;

/*
Également on retrouve un pattern 2 plus le client NA PAS annuler précédemment
Alors il y a moins de chances pour cette réservation soit annulée
*/

SELECT
COUNT(*) AS total_lignes,
COUNT(nb_of_booking_cancelled) AS valeurs_renseignees,
COUNT(*) - COUNT(nb_of_booking_cancelled) AS nb_nulls,
MIN(nb_of_booking_cancelled) AS minimum,
MAX(nb_of_booking_cancelled) AS maximum,
ROUND(AVG(nb_of_booking_cancelled), 2) AS moyenne,
ROUND(STDEV(nb_of_booking_cancelled), 2) AS ecart_type
FROM city_hotel;

SELECT *
FROM city_hotel
ORDER BY nb_of_booking_cancelled DESC;

/*
Je vais créer une colonne pour calculer le nombre de réservations au total 
effectué par les clients, l'idée va être de faire un ratio
*/

ALTER TABLE city_hotel
ADD nb_total_of_booking AS (nb_of_booking_cancelled + nb_of_booking_not_cancelled);

SELECT
COUNT(*) AS total_lignes,
COUNT(nb_total_of_booking) AS valeurs_renseignees,
COUNT(*) - COUNT(nb_total_of_booking) AS nb_nulls,
MIN(nb_total_of_booking) AS minimum,
MAX(nb_total_of_booking) AS maximum,
ROUND(AVG(nb_total_of_booking), 2) AS moyenne,
ROUND(STDEV(nb_total_of_booking), 2) AS ecart_type
FROM city_hotel;

SELECT *
FROM city_hotel
ORDER BY nb_total_of_booking;

/*
Donc il est possible que les clients qui ont le plus de réservation au total annulez et non annulé
Annule le moins
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
FROM city_hotel;


SELECT *
FROM city_hotel
ORDER BY babies DESC;

/*
J'ai 1 réservations avec 10 bébés et une autre avec 9 bébés, je pense que la première 
et probablement un bébé, mais pour la 2e aucune idée; étant donné que 
je ne peux poser la question je vais changer 10 pour 1 et laisser 9
*/

UPDATE city_hotel SET babies = 1 WHERE babies = 10

SELECT
COUNT(*) AS total_lignes,
COUNT(children) AS valeurs_renseignees,
COUNT(*) - COUNT(children) AS nb_nulls,
MIN(children) AS minimum,
MAX(children) AS maximum,
ROUND(AVG(children), 2) AS moyenne,
ROUND(STDEV(children), 2) AS ecart_type
FROM city_hotel;

SELECT
COUNT(*) AS total_lignes,
COUNT(adults) AS valeurs_renseignees,
COUNT(*) - COUNT(adults) AS nb_nulls,
MIN(adults) AS minimum,
MAX(adults) AS maximum,
ROUND(AVG(adults), 2) AS moyenne,
ROUND(STDEV(adults), 2) AS ecart_type
FROM city_hotel;


-- Nombre de nuits
SELECT
COUNT(*) AS total_lignes,
COUNT(nb_of_weekend_nights) AS valeurs_renseignees,
COUNT(*) - COUNT(nb_of_weekend_nights) AS nb_nulls,
MIN(nb_of_weekend_nights) AS minimum,
MAX(nb_of_weekend_nights) AS maximum,
ROUND(AVG(nb_of_weekend_nights), 2) AS moyenne,
ROUND(STDEV(nb_of_weekend_nights), 2) AS ecart_type
FROM city_hotel;

SELECT *
FROM city_hotel
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
FROM city_hotel;

SELECT *
FROM city_hotel
ORDER BY lead_time_in_days;

/*
Il y a énormément d l'annulation avec des raisins qui ont été faites longtemps à l'avance
Il semble que plus on réserve tôt et plus on a tendance à annuler.

Un peut être intéressant de segmenter cette colonne afin de les regrouper.
*/

ALTER TABLE city_hotel
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
