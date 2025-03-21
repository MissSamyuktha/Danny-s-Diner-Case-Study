/*ranking customer products keeping null ranking values for non-member purchases
for the records when customers are not yet part of the loyalty program.
*/

WITH member_diner AS (
    SELECT *,
        DENSE_RANK() OVER(
                    PARTITION BY customer_id 
                    ORDER BY order_date, price DESC)
            AS ranking
    FROM diner
    WHERE
        member = 'Y'
)



SELECT *,
    NULL AS ranking
FROM diner
WHERE
    member = 'N'
UNION ALL
SELECT *
FROM member_diner
ORDER BY customer_id, order_date, price DESC
;

/* Expected output:
| customer_id | order_date  | product_name | price | member | ranking |
|------------|------------|--------------|-------|--------|---------|
| A          | 2021-01-01 | curry        | 15    | N      | NULL    |
| A          | 2021-01-01 | sushi        | 10    | N      | NULL    |
| A          | 2021-01-07 | curry        | 15    | Y      | 1       |
| A          | 2021-01-10 | ramen        | 12    | Y      | 2       |
| A          | 2021-01-11 | ramen        | 12    | Y      | 3       |
| A          | 2021-01-11 | ramen        | 12    | Y      | 3       |
| B          | 2021-01-01 | curry        | 15    | N      | NULL    |
| B          | 2021-01-02 | curry        | 15    | N      | NULL    |
| B          | 2021-01-04 | sushi        | 10    | N      | NULL    |
| B          | 2021-01-11 | sushi        | 10    | Y      | 1       |
| B          | 2021-01-16 | ramen        | 12    | Y      | 2       |
| B          | 2021-02-01 | ramen        | 12    | Y      | 3       |
| C          | 2021-01-01 | ramen        | 12    | N      | NULL    |
| C          | 2021-01-01 | ramen        | 12    | N      | NULL    |
| C          | 2021-01-07 | ramen        | 12    | N      | NULL    |
*/
