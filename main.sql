WITH all_hotel AS (
    SELECT *
    FROM city_hotel

    UNION ALL

    SELECT *
    FROM resort_hotel
)

SELECT *
FROM all_hotel;


SELECT 
    reservation_status,
    country_of_origin,
    COUNT(booking_id) AS total_bookings
FROM resort_hotel
GROUP BY GROUPING SETS ((reservation_status), (country_of_origin))

SELECT 
    country_of_origin,
    reservation_status,
    COUNT(booking_id) AS total_bookings
FROM resort_hotel
WHERE reservation_status != 'Check-Out'
GROUP BY country_of_origin, reservation_status
ORDER BY total_bookings DESC