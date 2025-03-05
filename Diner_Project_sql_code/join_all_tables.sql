--join all tables
--WITH diner AS (
CREATE TABLE diner AS
    SELECT
        sales.customer_id,
        order_date,
        product_name,
        price,
        CASE
            WHEN order_date >= join_date AND 
            sales.customer_id = members.customer_id THEN 'Y'
            ELSE 'N'
        END AS member
    FROM
        sales
    LEFT JOIN
        members ON sales.customer_id = members.customer_id
    LEFT JOIN
        menu ON sales.product_id = menu.product_id

/* if CTE   ORDER BY
                sales.customer_id,
                order_date,
                price DESC
*/

/* Expected output:
| Customer ID | Order Date  | Product Name | Price | Member |
|------------|------------|--------------|-------|--------|
| A          | 2021-01-01 | Curry        | 15    | N      |
| A          | 2021-01-01 | Sushi        | 10    | N      |
| A          | 2021-01-07 | Curry        | 15    | Y      |
| A          | 2021-01-10 | Ramen        | 12    | Y      |
| A          | 2021-01-11 | Ramen        | 12    | Y      |
| A          | 2021-01-11 | Ramen        | 12    | Y      |
| B          | 2021-01-01 | Curry        | 15    | N      |
| B          | 2021-01-02 | Curry        | 15    | N      |
| B          | 2021-01-04 | Sushi        | 10    | N      |
| B          | 2021-01-11 | Sushi        | 10    | Y      |
| B          | 2021-01-16 | Ramen        | 12    | Y      |
| B          | 2021-02-01 | Ramen        | 12    | Y      |
| C          | 2021-01-01 | Ramen        | 12    | N      |
| C          | 2021-01-01 | Ramen        | 12    | N      |
| C          | 2021-01-07 | Ramen        | 12    | N      |
*/