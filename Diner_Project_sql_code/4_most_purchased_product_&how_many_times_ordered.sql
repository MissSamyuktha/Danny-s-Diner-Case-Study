SELECT
    menu.product_id,
    menu.product_name,
    COUNT(sales.product_id) AS order_count
FROM
    menu
LEFT JOIN
    sales ON sales.product_id = menu.product_id
GROUP BY
    menu.product_id, menu.product_name
ORDER BY
    order_count DESC;

/* Query Result:
| Product ID | Product Name| Order Count  |
|------------|-------------|--------------|
| 3          | Ramen       | 8            |
| 2          | Curry       | 4            |
| 1          | Sushi       | 3            |
*/