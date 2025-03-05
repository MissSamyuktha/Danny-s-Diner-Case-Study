WITH ranked_orders_after_membership AS (
    SELECT 
        members.customer_id,
        sales.product_id,
        product_name,
        join_date,
        ROW_NUMBER() OVER (PARTITION BY members.customer_id ORDER BY join_date) AS row_num,
        DENSE_RANK() OVER (PARTITION BY members.customer_id ORDER BY join_date) AS dense_rank
    FROM
        members
    INNER JOIN
        sales ON members.customer_id = sales.customer_id
    LEFT JOIN
        menu ON sales.product_id = menu.product_id
    ORDER BY
        members.customer_id,
        join_date
)

SELECT
    customer_id,
    product_name
FROM
    ranked_orders_after_membership
WHERE
    row_num = 1
    --dense_rank = 1;

/* Expected Output:

- Using DENSE_RANK() to get the first order after membership:
  - Both customers A and B ordered all three menu items.
    - Curry, Sushi, and Ramen

- Using ROW_NUMBER() to get the first order after membership:
  - Customer A: Curry
  - Customer B: Sushi
*/

