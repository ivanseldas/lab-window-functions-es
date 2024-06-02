-- 1. Calcular la duración media del alquiler (en días) para cada película:
SELECT * FROM film;
SELECT
	title,
    rental_duration,
    AVG(rental_duration) OVER (PARTITION BY NULL) AS avg_rental_duration
FROM
	film;

-- 2. Calcular el importe medio de los pagos para cada miembro del personal:
SELECT 
	staff_id,
    AVG(amount) OVER (PARTITION BY staff_id) AS avg_payment_amount
FROM 
	payment;
    
-- 3. Calcular los ingresos totales para cada cliente, mostrando el total acumulado dentro del historial de alquileres de cada cliente:
SELECT 
	payment.customer_id,
	payment.rental_id,
	rental.rental_date,
    payment.amount,
    SUM(amount) OVER (PARTITION BY customer_id ORDER BY rental_id) AS RunningTotal
FROM
	payment
INNER JOIN
	rental ON payment.rental_id = rental.rental_id;
    
-- 4. Determinar el cuartil para las tarifas de alquiler de las películas
SELECT
	title,
    rental_rate,
    DENSE_RANK() OVER (ORDER BY rental_rate) AS quartile
FROM
	film;

-- 5. Determinar la primera y última fecha de alquiler para cada cliente: