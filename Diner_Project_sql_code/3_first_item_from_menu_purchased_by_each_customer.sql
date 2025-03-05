WITH ranked_orders AS (
    SELECT
        customer_id,
        order_date,
        sales.product_id,
        product_name,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS row_num,
        DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY order_date) AS dense_rank_num
    FROM
        sales
    LEFT JOIN
        menu ON sales.product_id = menu.product_id
    ORDER BY
        customer_id,
        order_date
)

SELECT
    customer_id,
    product_name,
    row_num,
    dense_rank_num
FROM
    ranked_orders
WHERE
    dense_rank_num = 1

/* Expected output:
| Customer ID | Product Name | Row Number | Dense Rank Number |
|------------|-------------|------------|------------------|
| A          | Curry       | 1          | 1                |
| A          | Sushi       | 2          | 1                |
| B          | Curry       | 1          | 1                |
| C          | Ramen       | 1          | 1                |
| C          | Ramen       | 2          | 1                |

A has ordered Curry and Sushi,
B has ordered Curry, and
C has ordered Ramen twice.
*/