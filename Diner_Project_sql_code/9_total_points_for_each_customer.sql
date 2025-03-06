/*Q) If each $1 spent equates to 10 points and 
sushi has a 2x points multiplier - 
how many points would each customer have?
*/
-- Had the customer joined the loyalty program before making the purchases, 
--total points that each customer would have accrued:

SELECT
    customer_id,
    SUM(CASE
        WHEN product_name <> 'sushi' THEN price * 10
        ELSE price * 20
    END) AS total_points
FROM
    sales
LEFT JOIN
    menu ON sales.product_id = menu.product_id
GROUP BY
    customer_id
ORDER BY
    total_points DESC;

/* Expected output:
+-------------+--------------+
| customer_id | total_points |
+-------------+--------------+
| B           | 940          |
| A           | 860          |
| C           | 360          |
+-------------+--------------+
*/

--Total points that each customer has accrued after taking a membership
SELECT
    sales.customer_id,
    SUM(CASE
        WHEN product_name <> 'sushi' THEN price * 10
        ELSE price * 20
    END) AS total_points
FROM
    sales
LEFT JOIN
    menu ON sales.product_id = menu.product_id
INNER JOIN
    members ON sales.customer_id = members.customer_id
WHERE order_date >= join_date
GROUP BY 
    sales.customer_id
ORDER BY
    total_points DESC;

/* Expected output:
| customer_id | total_points |
| ----------- | --------------- |
| A           | 510             |
| B           | 440             |