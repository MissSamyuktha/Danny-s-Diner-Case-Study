/*Q) If each $1 spent equates to 10 points and 
sushi has a 2x points multiplier - 
how many points would each customer have?
*/

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