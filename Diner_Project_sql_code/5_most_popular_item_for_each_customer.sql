WITH ranked_sales AS (
    SELECT
        sales.customer_id,
        menu.product_name,
        COUNT(sales.product_id) AS product_count,
        ROW_NUMBER() OVER (PARTITION BY sales.customer_id 
            ORDER BY COUNT(sales.product_id) DESC) AS row_num
    FROM
        sales
    LEFT JOIN
        menu ON sales.product_id = menu.product_id
    GROUP BY
        customer_id,
        menu.product_name
)

SELECT
    customer_id,
    product_name,
    product_count
FROM
    ranked_sales
WHERE
    row_num = 1;

/* Expected output
| Customer ID | Product Name | Product Count |
|------------|-------------|--------------|
| A          | Ramen       | 3            |
| B          | Sushi       | 2            |
| C          | Ramen       | 3            |
*/