SELECT
    customer_id,
    COUNT(DISTINCT(order_date)) AS day_count
FROM
    sales
GROUP BY
    customer_id;

/* Expected results:
| Customer ID | Day Count |
|------------|----------|
| A          | 4        |
| B          | 6        |
| C          | 2        |
*/


-- code for most visited day of the week by all customers
SELECT
    TO_CHAR(order_date, 'DAY') AS day_name,
    count(TO_CHAR(order_date, 'DAY')) AS day_count
FROM
    sales
GROUP BY
    day_name
ORDER BY
    day_count DESC;

/* Expected results:
Mondays and Fridays are popular among customers to visit the restaurent.
*/


-- code for most visited day of the week by each customer
WITH ranked_visits AS (
    SELECT
        customer_id,
        EXTRACT(DOW FROM order_date) AS day_of_week,
        TO_CHAR(order_date, 'DAY') AS day_name,
        count(TO_CHAR(order_date, 'DAY')) AS day_count,
        ROW_NUMBER() OVER(PARTITION BY customer_id 
            ORDER BY customer_id, count(TO_CHAR(order_date, 'DAY')) DESC)
            AS row_num
    FROM
        sales
    GROUP BY
        customer_id, day_of_week, day_name
    ORDER BY
        customer_id,
        day_count DESC
)
SELECT
    customer_id,
    day_name,
    day_count
FROM
    ranked_visits
WHERE
    row_num = 1;

/* Expected results: Most visited day of the week by each customer
| Customer ID | Day Name | Day Count |
|------------|---------|----------| 
| A          | MONDAY  | 2        |
| B          | FRIDAY  | 3        |
| C          | MONDAY  | 1        |
*/