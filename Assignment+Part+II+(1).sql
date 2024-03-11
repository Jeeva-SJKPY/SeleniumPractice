use supply_db ;

/*  Question: Month-wise NIKE sales

	Description:
		Find the combined month-wise sales and quantities sold for all the Nike products. 
        The months should be formatted as ‘YYYY-MM’ (for example, ‘2019-01’ for January 2019). 
        Sort the output based on the month column (from the oldest to newest). The output should have following columns :
			-Month
			-Quantities_sold
			-Sales
		HINT:
			Use orders, ordered_items, and product_info tables from the Supply chain dataset.
*/		
SELECT 
    DATE_FORMAT(o.Order_Date, '%Y-%m') AS Month,
    SUM(oi.Quantity) AS Quantities_Sold,
    SUM(oi.Sales) AS Sales
FROM
    orders o
        LEFT JOIN
    ordered_items oi ON o.Order_Id = oi.Order_Id
        LEFT JOIN
    product_info p ON oi.Item_Id = p.Product_Id
WHERE
    LOWER(Product_Name) LIKE '%nike%'
GROUP BY Month
ORDER BY Month;




/*

Question : Costliest products

Description: What are the top five costliest products in the catalogue? Provide the following information/details:
-Product_Id
-Product_Name
-Category_Name
-Department_Name
-Product_Price

Sort the result in the descending order of the Product_Price.

HINT:
Use product_info, category, and department tables from the Supply chain dataset.


*/

SELECT 
    p.product_id,
    p.product_name,
    c.name AS category_name,
    d.name AS department_name,
    p.product_price
FROM
    product_info p
        JOIN
    category c ON p.category_id = c.id
        JOIN
    department d ON p.department_id = d.id
ORDER BY product_price DESC
LIMIT 5;

/*

Question : Cash customers

Description: Identify the top 10 most ordered items based on sales from all the ‘CASH’ type orders. 
Provide the Product Name, Sales, and Distinct Order count for these items. Sort the table in descending
 order of Order counts and for the cases where the order count is the same, sort based on sales (highest to
 lowest) within that group.
 
HINT: Use orders, ordered_items, and product_info tables from the Supply chain dataset.


*/
SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
SELECT 
    p.product_name , oi.sales*oi.quantity as sales, count(distinct(o.order_id)) as distinct_order_count
FROM
    product_info p
        JOIN
    ordered_items oi ON p.product_id = oi.item_id
        JOIN
    orders o ON o.order_id = oi.order_id
WHERE
    o.type = 'cash'
group by 1
ORDER BY 3,2 desc
LIMIT 10;


/*
Question : Customers from texas

Obtain all the details from the Orders table (all columns) for customer orders in the state of Texas (TX),
whose street address contains the word ‘Plaza’ but not the word ‘Mountain’. The output should be sorted by the Order_Id.

HINT: Use orders and customer_info tables from the Supply chain dataset.

*/
SELECT 
    o.Order_Id,o.Type,o.Real_Shipping_Days,o.Scheduled_Shipping_Days,o.Customer_Id,
    o.Order_City,o.Order_Date,o.Order_Region,o.Order_State,o.Order_Status,o.Shipping_Mode

FROM
    orders o
        JOIN
    customer_info c ON c.id = o.customer_id
WHERE
    c.state = 'TX'
        AND c.street LIKE '%Plaza%'
        AND c.street NOT LIKE '%Mountain%'
ORDER BY o.Order_Id;



/*
 
Question: Home office

For all the orders of the customers belonging to “Home Office” Segment and have ordered items belonging to
“Apparel” or “Outdoors” departments. Compute the total count of such orders. The final output should contain the 
following columns:
-Order_Count

*/
SELECT 
    COUNT(o.order_id) as Order_count
  
FROM
    orders o
        JOIN
    customer_info ci ON o.customer_id = ci.id
        JOIN
    ordered_items oi ON o.order_id = oi.order_id
        JOIN
    product_info pi ON oi.item_id = pi.product_id
        JOIN
    department d ON pi.Department_id = d.id
WHERE
    ci.segment = 'Home Office'
        AND (d.Name = 'Apparel'
        OR d.name = 'Outdoors');
 
 
/*
Question : Within state ranking
 
For all the orders of the customers belonging to “Home Office” Segment and have ordered items belonging
to “Apparel” or “Outdoors” departments. Compute the count of orders for all combinations of Order_State and Order_City. 
Rank each Order_City within each Order State based on the descending order of their order count (use dense_rank). 
The states should be ordered alphabetically, and Order_Cities within each state should be ordered based on their rank. 
If there is a clash in the city ranking, in such cases, it must be ordered alphabetically based on the city name. 
The final output should contain the following columns:
-Order_State
-Order_City
-Order_Count
-City_rank

HINT: Use orders, ordered_items, product_info, customer_info, and department tables from the Supply chain dataset.

*/
SELECT 
    o.order_state,o.order_city,
    COUNT(o.order_id) as Order_count,
    DENSE_RANK() OVER (
      ORDER BY  COUNT(o.order_id)  DESC ) city_rank
FROM
    orders o
        JOIN
    customer_info ci ON o.customer_id = ci.id
        JOIN
    ordered_items oi ON o.order_id = oi.order_id
        JOIN
    product_info pi ON oi.item_id = pi.product_id
        JOIN
    department d ON pi.Department_id = d.id
WHERE
    ci.segment = 'Home Office'
        AND (d.Name = 'Apparel'
        OR d.name = 'Outdoors')
group by  o.order_state,o.order_city
Order by o.order_state,city_rank,o.order_city;



/*
Question : Underestimated orders

Rank (using row_number so that irrespective of the duplicates, so you obtain a unique ranking) the 
shipping mode for each year, based on the number of orders when the shipping days were underestimated 
(i.e., Scheduled_Shipping_Days < Real_Shipping_Days). The shipping mode with the highest orders that meet 
the required criteria should appear first. Consider only ‘COMPLETE’ and ‘CLOSED’ orders and those belonging to 
the customer segment: ‘Consumer’. The final output should contain the following columns:
-Shipping_Mode,
-Shipping_Underestimated_Order_Count,
-Shipping_Mode_Rank


HINT: Use orders and customer_info tables from the Supply chain dataset.


*/
select o.Shipping_Mode,
        count(o.order_id) as Shipping_Underestimated_Order_Count,
        row_number() over(order by count(o.order_id) desc) Shipping_Mode_Rank
from orders o join customer_info ci on o.customer_id=ci.id
where ci.segment="Consumer" and (o.order_status="COMPLETE" or o.order_status="CLOSED") and Scheduled_Shipping_Days < Real_Shipping_Days
group by o.Shipping_Mode
order by Shipping_Mode_Rank;
