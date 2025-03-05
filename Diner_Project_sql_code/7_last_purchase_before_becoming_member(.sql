WITH last_purchase AS (
    SELECT
        sales.customer_id,
        sales.product_id,
        menu.product_name,
        join_date,
        order_date,
        ROW_NUMBER() OVER(PARTITION BY sales.customer_id ORDER BY order_date DESC) AS row_num,
        DENSE_RANK() OVER(PARTITION BY sales.customer_id ORDER BY order_date DESC) AS dense_rank
    FROM
        sales
    INNER JOIN
        members ON sales.customer_id = members.customer_id
    INNER JOIN
        menu ON sales.product_id = menu.product_id
    WHERE
        order_date < join_date
)

SELECT
    customer_id,
    product_name AS last_product,
    order_date AS last_order_date
FROM
    last_purchase
WHERE
    --row_num = 1
    dense_rank = 1

/* Expected output: last_purchase before becoming member

customer_id | last_product | last_order_date|
A           | sushi, curry | 2021-01-01     |
B           | sushi        | 2021-01-04     |

*/