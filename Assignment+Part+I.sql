use supply_db ;

/*
Question : Golf related products

List all products in categories related to golf. Display the Product_Id, Product_Name in the output. Sort the output in the order of product id.
Hint: You can identify a Golf category by the name of the category that contains golf.

*/

SELECT 
    p.product_id, p.product_name
FROM
    product_info p
        JOIN
    category c ON p.category_id = c.id
WHERE
    c.name LIKE '%golf%'
order by p.product_id;



/*
Question : Most sold golf products

Find the top 10 most sold products (based on sales) in categories related to golf. Display the Product_Name and Sales column in the output. Sort the output in the descending order of sales.
Hint: You can identify a Golf category by the name of the category that contains golf.

HINT:
Use orders, ordered_items, product_info, and category tables from the Supply chain dataset.




*/

SELECT 
p.product_name, Sum(o.sales) AS Sales 
FROM product_info AS p  JOIN category AS c ON p.category_id = c.id 
	  JOIN ordered_items AS o ON p.product_id = o.item_id 
WHERE
        c.name LIKE '%GOLF%' 
GROUP BY p.product_name 
ORDER BY sales DESC 
LIMIT 10;

/*
Question: Segment wise orders

Find the number of orders by each customer segment for orders. Sort the result from the highest to the lowest 
number of orders.The output table should have the following information:
-Customer_segment
-Orders


*/
SELECT 
    c.segment AS Customer_segment, COUNT(distinct(o.order_id)) AS Orders
FROM
    customer_info c
        JOIN
    orders o ON c.id = o.customer_id
GROUP BY c.segment
ORDER BY Orders desc;


/*
Question : Percentage of order split

Description: Find the percentage of split of orders by each customer segment for orders that took six days 
to ship (based on Real_Shipping_Days). Sort the result from the highest to the lowest percentage of split orders,
rounding off to one decimal place. The output table should have the following information:
-Customer_segment
-Percentage_order_split

HINT:
Use the orders and customer_info tables from the Supply chain dataset.
*/

SELECT 
    c.segment AS Customer_segment, round(100 * COUNT(distinct(o.order_id)) /
    (SELECT COUNT(distinct(order_id)) FROM Orders),1) AS Percentage_order_split
FROM
    customer_info c
        JOIN
    orders o ON c.id = o.customer_id
WHERE o.Real_Shipping_Days=6
GROUP BY c.segment
ORDER BY Percentage_order_split desc;
