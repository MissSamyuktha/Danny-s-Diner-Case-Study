SELECT
    sales.customer_id,
    COUNT(sales.product_id) AS number_of_products,
    SUM(price) AS total_spent
FROM
    sales
LEFT JOIN
    menu ON menu.product_id = sales.product_id
INNER JOIN
    members ON members.customer_id = sales.customer_id
WHERE
    order_date < join_date
GROUP BY
    sales.customer_id
ORDER BY
    total_spent DESC;

/* Expected output:
Total items and amount spent for each member 
before they became a member:

customer_id|number_of_products|total_spent|
B          |3                 |40         |
A          |2                 |25         |

*/