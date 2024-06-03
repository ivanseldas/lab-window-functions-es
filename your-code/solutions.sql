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
SELECT 
	customer.customer_id,
    FIRST_VALUE(rental.rental_date) OVER (PARTITION BY customer.customer_id) AS first_rental_date,
    LAST_VALUE(rental.rental_date) OVER (PARTITION BY customer.customer_id) AS last_rental_date
FROM
	customer
INNER JOIN
	rental ON customer.customer_id = rental.customer_id;

-- 6. Calcular el rango de los clientes basado en el número de sus alquileres:
WITH rental_counts AS (
	SELECT 
		customer.customer_id,
		COUNT(rental.rental_id) AS count
	FROM
		customer
	INNER JOIN
		rental ON customer.customer_id = rental.customer_id
	GROUP BY
		customer.customer_id
)
SELECT 
	customer_id,
    count,
    RANK() OVER (ORDER BY count DESC) AS ranking
FROM
	rental_counts;

-- 7. Calcular el total acumulado de ingresos por día para la categoría de películas 'Familiar':
WITH time_table AS(
	SELECT
		film.title,
        rental.rental_id,
		EXTRACT(DAY FROM payment.payment_date) AS day,
        EXTRACT(MONTH FROM payment.payment_date) AS month,
        EXTRACT(YEAR FROM payment.payment_date) AS year,
        payment.amount
	FROM
		payment
	INNER JOIN
		rental ON payment.rental_id = rental.rental_id
	INNER JOIN
		inventory ON rental.inventory_id = inventory.inventory_id
	INNER JOIN 
		film ON film.film_id = inventory.film_id
	INNER JOIN
		film_category ON film.film_id = film_category.film_id
	INNER JOIN
		category ON film_category.category_id = category.category_id
	WHERE category.name = 'Family'
)
SELECT
	rental_id,
	title,
    amount,
    day,
    month,
    year,
    SUM(amount) OVER (PARTITION BY day) AS total_accumulated
FROM
	time_table
ORDER BY
	year,
    month,
    day;