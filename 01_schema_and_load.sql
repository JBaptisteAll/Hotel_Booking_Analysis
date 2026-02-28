/* 
Set up du language en anglais à cause des mois "july" ... etc
pour les caster dans la table plus tard
*/
SET LANGUAGE English;

SELECT *
FROM hotel_bookings;


SELECT DISTINCT is_repeated_guest
FROM hotel_bookings;

/*
Voir les colonnes existantes et des infos sur les données
*/
EXEC sp_help 'hotel_bookings';

-- DROP TABLE resort_hotel

/*
Creation de la table 'resort_hotel' pour différencier Resort Hotel et City Hotel
également pour typer les colonnes aux bon format,
création du colonne 'booking_id' auto incrémenté en cas de besoin par la suite,
J'ai décidé de regrouper la colonne de la date d'arrivé en 1 colonne de DATE
*/
CREATE TABLE resort_hotel (
    booking_id INT IDENTITY(0,1),
    hotel VARCHAR(20),
    is_canceled BIT,
    lead_time_in_days INT,
    arrival_date DATE,
    arrival_week_nb INT,
    nb_of_weekend_nights INT,
    nb_of_week_nights INT,
    adults INT,
    children INT,
    babies INT,
    meal VARCHAR(10),
    country_of_origin VARCHAR(5),
    market_segment VARCHAR(20),
    distribution_channel VARCHAR(20),
    repeated_guest BIT,
    nb_of_booking_cancelled INT,
    nb_of_booking_not_cancelled INT,
    reserved_room_type VARCHAR(1),
    assigned_romm_type VARCHAR(1),
    nb_of_changes_into_the_booking INT,
    deposit_type VARCHAR(10),
    travel_agency_id INT,
    company_id INT,
    days_in_waiting_list INT,
    customer_type VARCHAR(20),
    average_daily_rate DECIMAL(18, 2),
    nb_of_carpark_required INT,
    nb_of_special_requests INT,
    reservation_status VARCHAR(15),
    reservation_status_date DATETIME
);

/*
Création de contraintes de CHECK pour certaines colonnes afin controler le type
d'entrée.
*/
ALTER TABLE resort_hotel ADD CONSTRAINT ck_hotel CHECK (hotel = 'Resort Hotel');
ALTER TABLE resort_hotel ADD CONSTRAINT ck_meal CHECK (meal IN ('FB', 'HB', 'SC', 'BB', 'Undefined'));
ALTER TABLE resort_hotel ADD CONSTRAINT ck_distrib_channel CHECK (distribution_channel IN ('Corporate', 'TA/TO', 'Direct', 'Undefined', 'GDS'));
ALTER TABLE resort_hotel ADD CONSTRAINT ck_deposit CHECK (deposit_type IN ('No Deposit', 'Refundable', 'Non Refund'));
ALTER TABLE resort_hotel ADD CONSTRAINT ck_customer_type CHECK (customer_type IN ('Group', 'Contract', 'Transient', 'Transient-Party'));
ALTER TABLE resort_hotel ADD CONSTRAINT ck_resa_status CHECK (reservation_status IN ('Check-Out', 'No-Show', 'Canceled'));

/*
Insertion de la donnée à partir de la table principale,
Voici ou est important de setup en anglais pour cast la colonne des mois 
afin de reconnaitre les nom de mois en anglais.
*/
INSERT INTO resort_hotel (
    hotel, is_canceled, lead_time_in_days, arrival_date, arrival_week_nb, nb_of_weekend_nights, 
    nb_of_week_nights, adults, children, babies, meal, country_of_origin, market_segment, 
    distribution_channel, repeated_guest, nb_of_booking_cancelled, nb_of_booking_not_cancelled, 
    reserved_room_type, assigned_romm_type, nb_of_changes_into_the_booking, deposit_type,
    travel_agency_id, company_id, days_in_waiting_list, customer_type, average_daily_rate,
    nb_of_carpark_required, nb_of_special_requests, reservation_status, reservation_status_date
)
SELECT 
    hotel, 
    is_canceled, 
    lead_time,
    DATEFROMPARTS(arrival_date_year,
        MONTH(CAST('01 ' + arrival_date_month + ' 2000' AS DATE)),
        arrival_date_day_of_month),
    arrival_date_week_number,
    stays_in_weekend_nights,
    stays_in_week_nights,
    adults,
    children,
    babies,
    meal,
    country,
    market_segment,
    distribution_channel,
    is_repeated_guest,
    previous_cancellations,
    previous_bookings_not_canceled,
    reserved_room_type,
    assigned_room_type,
    booking_changes,
    deposit_type,
    TRY_CAST(agent AS INT),
    TRY_CAST(company AS INT),
    days_in_waiting_list,
    customer_type,
    adr,
    required_car_parking_spaces,
    total_of_special_requests,
    reservation_status,
    reservation_status_date
FROM hotel_bookings
WHERE hotel = 'Resort Hotel';


SELECT *
FROM resort_hotel;


/*
Creation de la table 'city_hotel' pour différencier Resort Hotel et City Hotel
également pour typer les colonnes aux bon format,
création du colonne 'booking_id' auto incrémenté en cas de besoin par la suite,
J'ai décidé de regrouper la colonne de la date d'arrivé en 1 colonne de DATE
*/
CREATE TABLE city_hotel (
    booking_id INT IDENTITY(0,1),
    hotel VARCHAR(20),
    is_canceled BIT,
    lead_time_in_days INT,
    arrival_date DATE,
    arrival_week_nb INT,
    nb_of_weekend_nights INT,
    nb_of_week_nights INT,
    adults INT,
    children INT,
    babies INT,
    meal VARCHAR(10),
    country_of_origin VARCHAR(5),
    market_segment VARCHAR(20),
    distribution_channel VARCHAR(20),
    repeated_guest BIT,
    nb_of_booking_cancelled INT,
    nb_of_booking_not_cancelled INT,
    reserved_room_type VARCHAR(1),
    assigned_romm_type VARCHAR(1),
    nb_of_changes_into_the_booking INT,
    deposit_type VARCHAR(10),
    travel_agency_id INT,
    company_id INT,
    days_in_waiting_list INT,
    customer_type VARCHAR(20),
    average_daily_rate DECIMAL(18, 2),
    nb_of_carpark_required INT,
    nb_of_special_requests INT,
    reservation_status VARCHAR(15),
    reservation_status_date DATETIME
);

/*
Création de contraintes de CHECK pour certaines colonnes afin controler le type
d'entrée.
*/
ALTER TABLE city_hotel ADD CONSTRAINT ck_hotel_city_hotel CHECK (hotel = 'City Hotel');
ALTER TABLE city_hotel ADD CONSTRAINT ck_meal_city_hotel CHECK (meal IN ('FB', 'HB', 'SC', 'BB', 'Undefined'));
ALTER TABLE city_hotel ADD CONSTRAINT ck_distrib_channel_city_hotel CHECK (distribution_channel IN ('Corporate', 'TA/TO', 'Direct', 'Undefined', 'GDS'));
ALTER TABLE city_hotel ADD CONSTRAINT ck_deposit_city_hotel CHECK (deposit_type IN ('No Deposit', 'Refundable', 'Non Refund'));
ALTER TABLE city_hotel ADD CONSTRAINT ck_customer_type_city_hotel CHECK (customer_type IN ('Group', 'Contract', 'Transient', 'Transient-Party'));
ALTER TABLE city_hotel ADD CONSTRAINT ck_resa_status_city_hotel CHECK (reservation_status IN ('Check-Out', 'No-Show', 'Canceled'));


/*
Insertion de la donnée à partir de la table principale,
Voici ou est important de setup en anglais pour cast la colonne des mois 
afin de reconnaitre les nom de mois en anglais.
*/
INSERT INTO city_hotel (
    hotel, is_canceled, lead_time_in_days, arrival_date, arrival_week_nb, nb_of_weekend_nights, 
    nb_of_week_nights, adults, children, babies, meal, country_of_origin, market_segment, 
    distribution_channel, repeated_guest, nb_of_booking_cancelled, nb_of_booking_not_cancelled, 
    reserved_room_type, assigned_romm_type, nb_of_changes_into_the_booking, deposit_type,
    travel_agency_id, company_id, days_in_waiting_list, customer_type, average_daily_rate,
    nb_of_carpark_required, nb_of_special_requests, reservation_status, reservation_status_date
)
SELECT 
    hotel, 
    is_canceled, 
    lead_time,
    DATEFROMPARTS(arrival_date_year,
        MONTH(CAST('01 ' + arrival_date_month + ' 2000' AS DATE)),
        arrival_date_day_of_month),
    arrival_date_week_number,
    stays_in_weekend_nights,
    stays_in_week_nights,
    adults,
    TRY_CAST(children AS INT),
    babies,
    meal,
    country,
    market_segment,
    distribution_channel,
    is_repeated_guest,
    previous_cancellations,
    previous_bookings_not_canceled,
    reserved_room_type,
    assigned_room_type,
    booking_changes,
    deposit_type,
    TRY_CAST(agent AS INT),
    TRY_CAST(company AS INT),
    days_in_waiting_list,
    customer_type,
    adr,
    required_car_parking_spaces,
    total_of_special_requests,
    reservation_status,
    reservation_status_date
FROM hotel_bookings
WHERE hotel = 'City Hotel';


SELECT *
FROM city_hotel;
