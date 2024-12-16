use music;
select * from music_rec;

-- Queries 

-- Who is the senior most employee based on job title?
SELECT *
FROM employee
ORDER BY levels DESC
LIMIT 1;

-- Which country has the most invoices?
SELECT billing_country, COUNT(*) AS num_of_invoices
FROM invoice
GROUP BY billing_country
ORDER BY num_of_invoices DESC

-- What are top 3 values of total invoices?

SELECT ROUND(total, 2) AS rounded_total, 
       COUNT(*) AS num_of_invoices 
FROM invoice
GROUP BY ROUND(total, 2)
ORDER BY rounded_total DESC
LIMIT 3;

-- Which city has the best customers? We would like to throw a promotional Music Festival in the city we the most money. 
-- Write a query that returns one city that has the highest sum of invoice totals. 
-- Return both city name and sum of all invoice totals

SELECT 
	billing_city,
	SUM(total) total
FROM invoice
GROUP BY billing_city
ORDER BY total DESC
LIMIT 1;

-- Who is the best customer? The customer who spent the most money will be declared the best customer. 
-- Write a query that returns the person who spent the most money.

SELECT 
	c.customer_id,
	c.first_name,
	c.last_name,
	SUM(i.total) AS invoice_total
FROM 
	customer c
		JOIN
	invoice i ON i.customer_id = c.customer_id
GROUP BY
	c.customer_id,
	c.first_name,
	c.last_name
ORDER BY invoice_total DESC
LIMIT 1;

-- Write a query to return email, first name, last name, and Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email.

SELECT DISTINCT
	c.first_name,
	c.last_name,
	c.email,
	g.name
FROM 
	genre g
		JOIN
	track t ON g.genre_id = t.genre_id
		JOIN
	invoice_line il ON il.track_id = t.track_id
		JOIN
	invoice i ON i.invoice_id = il.invoice_id
		JOIN
	customer c ON c.customer_id = i.customer_id
WHERE g.name LIKE 'Rock'
ORDER BY c.email;

-- Let's invite the artists who have written the most rock music in our dataset. 
-- Write a query that returns the artist name, and total track count of top 10 rock bands.

LOAD DATA LOCAL INFILE "C:\Users\91628\Downloads\album.csv"
INTO TABLE artist
FIELDS TERMINATED BY ','
ENCLOSED BY '\"'
LINES TERMINATED BY '\n'
IGNORE 1 rows;

-- We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. 
-- Write a query that returns each country along with the top genre. For countries where the maximum number of purchases is shared, return all genres.

SELECT
    country,
    genre,
    num_of_purchases,
    ranks
FROM (
    SELECT 
        i.billing_country AS country,
        g.name AS genre,
        COUNT(il.quantity) AS num_of_purchases,
        DENSE_RANK() OVER (
            PARTITION BY i.billing_country 
            ORDER BY COUNT(il.quantity) DESC
        ) AS ranks
    FROM invoice i 
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    JOIN track t ON t.track_id = il.track_id
    JOIN genre g ON g.genre_id = t.genre_id
    GROUP BY i.billing_country, g.name
) AS rank_table
WHERE ranks = 1;

-- Write a query to determine the customer that has spent the most on music for each country. Write as query that returns the country along with the top customer and how much they spent.
-- For countries where the top amount spent is shared, provide all customers who spent this amount.

SELECT
	country,
	customer_id,
	first_name,
	last_name,
	amt_spent
FROM
	(SELECT 
		c.customer_id AS customer_id,
		c.first_name AS first_name,
		c.last_name AS last_name,
		i.billing_country AS country,
		SUM(i.total) AS amt_spent,
		DENSE_RANK() OVER (PARTITION BY i.billing_country ORDER BY SUM(i.total) DESC) AS ranks
	FROM customer c 
	JOIN invoice i on c.customer_id = i.customer_id
	GROUP BY
		c.customer_id,
		c.first_name,
		c.last_name,
		i.billing_country) AS rank_table
WHERE ranks = 1

------------------------------------END---------------------------------------------------
