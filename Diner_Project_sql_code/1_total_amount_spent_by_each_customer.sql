SELECT
    customer_id,
    SUM(price) AS total_amount_spent
FROM
    sales
LEFT JOIN
    menu ON sales.product_id = menu.product_id
GROUP BY
    customer_id
ORDER BY
    total_amount_spent DESC;

/* Query Result:
| Customer ID | Total Amount Spent |
|------------|-------------------|
| A          | 76                |
| B          | 74                |
| C          | 36                |
*/