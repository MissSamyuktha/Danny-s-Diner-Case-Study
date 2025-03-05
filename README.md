# :ramen: :curry: :sushi: Case Study #1: Danny's Diner

## Objective:
To leverage SQL analysis to understand customer behavior and improve Danny's Diner's customer loyalty program.

## Problem Statement:
Danny’s Diner needs insights into customer spending habits, favorite menu items, and the effectiveness of the loyalty program. By analyzing the provided data, we aim to uncover patterns and actionable insights to enhance customer experience and boost business performance.

## Tools Used:
- Postgresql
- pgadmin
- Visual Studio Code

## Case Study Questions

1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
10. What is the total items and amount spent for each member before they became a member?
11. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
12. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
***

###  1. What is the total amount each customer spent at the restaurant?

```sql
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
``` 
	
#### Result set:
| Customer ID | Total Amount Spent |
|------------ |------------------- |
| A           | 76                 |
| B           | 74                 |
| C           | 36                 |

***

###  2. How many days has each customer visited the restaurant?

```sql
SELECT
    customer_id,
    COUNT(DISTINCT(order_date)) AS day_count
FROM
    sales
GROUP BY
    customer_id;
``` 
	
#### Result set:
| Customer ID | Day Count |
|------------ |---------- |
| A           | 4         |
| B           | 6         |
| C           | 2         |

***

###  3. What was the first item from the menu purchased by each customer?

```sql
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
    dense_rank_num = 1;
``` 
	
#### Result set:
| Customer ID | Product Name | Row Number | Dense Rank Number |
|------------ |------------- |------------|------------------ |
| A           | Curry        | 1          | 1                 |
| A           | Sushi        | 2          | 1                 |
| B           | Curry        | 1          | 1                 |
| C           | Ramen        | 1          | 1                 |
| C           | Ramen        | 2          | 1                 |

A has ordered both Curry and Sushi,    
B has ordered Curry, and  
C has ordered Ramen twice.  

***

###  4. What is the most purchased item on the menu and how many times was it purchased by all customers?

```sql
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
    order_count DESC
limit 1;
``` 
	
#### Result set:
| Product ID | Product Name| Order Count  |
|------------|-------------|--------------|
| 3          | Ramen       | 8            |

***

###  5. Which item was the most popular for each customer?

```sql
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
``` 
	
#### Result set:
| Customer ID | Product Name | Product Count |
|------------ |------------- |-------------- |
| A           | Ramen        | 3             |
| B           | Sushi        | 2             |
| C           | Ramen        | 3             |

***

###  6. Which item was purchased first by the customer after they became a member?

```sql
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
``` 
	
#### Result set:
| customer_id | product_name | 
| ----------- | ------------ | 
| A           | curry        | 
| B           | sushi        | 

***

###  7. Which item was purchased just before the customer became a member?

```sql
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
``` 
	
#### Result set:
| customer_id | last_product  | last_order_date |
|------------ |-------------- |-----------------|
| A           | sushi, curry  | 2021-01-01      |
| B           | sushi         | 2021-01-04      |

***

###  8. What is the total items and amount spent for each member before they became a member?

```sql
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
``` 
	
#### Result set:
| customer_id | number_of_products | total_spent |
| ----------- | ----------- | ------------ |
| B           | 3           | 40          |
| A           | 2           | 25          |

***

###  9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

#### Had the customer joined the loyalty program before making the purchases, total points that each customer would have accrued
```sql
SELECT
    customer_id,
    SUM(CASE
        WHEN product_name <> 'sushi' THEN price * 10
        ELSE price * 20
    END) AS total_points
FROM
    sales
LEFT JOIN
    menu ON sales.product_id = menu.product_id
GROUP BY
    customer_id
ORDER BY
    total_points DESC;
``` 
	
#### Result set:
| customer_id | total_points |
| ----------- | --------------- |
| B           | 940             |
| A           | 860             |
| C           | 360             |

#### Total points that each customer has accrued after taking a membership
```sql
SELECT
    sales.customer_id,
    SUM(CASE
        WHEN product_name <> 'sushi' THEN price * 10
        ELSE price * 20
    END) AS total_points
FROM
    sales
LEFT JOIN
    menu ON sales.product_id = menu.product_id
INNER JOIN
    members ON sales.customer_id = members.customer_id
WHERE order_date >= join_date
GROUP BY 
    sales.customer_id
ORDER BY
    total_points DESC;
``` 
	
#### Result set:
| customer_id | total_points |
| ----------- | --------------- |
| A           | 510             |
| B           | 440             |

***

###  10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January

```sql
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
```

#### Result set:
| customer_id | total_points |
| ----------- | --------------- |
| A           | 1370            |
| B           | 820             |

***

###  Bonus Questions

#### Join All The Things
Create basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL. Fill Member column as 'N' if the purchase was made before becoming a member and 'Y' if the after is amde after joining the membership.

```sql
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
``` 
	
#### Result set:
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

***

#### Rank All The Things
Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.
#### Steps
Create a member_diner table using the diner table created in above queries with rankings where customer is member.   
Select * and null as rankings from diner table where customer is not member.   
UNION ALL to combine tables.   

```sql
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
``` 

#### Result set:
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


***

## Insights:

Customer Visits: Customer B visited the restaurant the most.   
Popular Dish: Ramen is the favorite among customers.   
Pre-Membership Favorite: Sushi was the common choice before membership.   
Points Leader: Customer B had the most points before membership; Customer A led in January post-membership.   
Total Expenditure: Customers collectively spent $186.   


## Recommendations:

Enhance Loyalty Program: Focus on popular items like ramen to drive engagement.   
Personalized Offers: Target frequent visitors like Customer B with special deals.   
Membership Benefits: Promote the benefits of membership using data on points accumulation.   
These findings will help Danny improve customer experience and loyalty programs.   
*** 

Click [here](https://github.com/MissSamyuktha/Danny-s-Diner-Case-Study/tree/main/Diner_Project_sql_code) to check out project files!


 
