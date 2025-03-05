/* Q) In the first week after a customer joins the program (including their join date) 
they earn 2x points on all items, not just sushi - 
how many points do customer A and B have at the end of January?
*/

SELECT
    sales.customer_id,
    SUM(CASE
        WHEN order_date >= join_date AND 
            order_date < (join_date + INTERVAL '7 days') 
            THEN 20*price
        WHEN product_name = 'sushi' THEN 20*price
        ELSE 10*price
    END) AS total_points
FROM
    sales
LEFT JOIN
    menu ON sales.product_id = menu.product_id
INNER JOIN
    members ON sales.customer_id = members.customer_id
WHERE
    EXTRACT(MONTH FROM order_date) = 1
GROUP BY
    sales.customer_id
ORDER BY
    total_points DESC;

/* Expected output:
+-------------+--------------+
| customer_id | total_points |
+-------------+--------------+
| A           | 1370          |
| B           | 820          |
+-------------+--------------+
*/
