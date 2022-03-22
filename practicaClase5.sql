1)
SELECT c.customer_num, company, order_num
FROM customer c JOIN orders o ON(c.customer_num = o.customer_num)
ORDER BY c.customer_num

2)
select order_num, item_num, description, manu_code, quantity, (unit_price * quantity) precioTotal
from items i inner join product_types p on (i.stock_num = p.stock_num)
where order_num=1004
           
3)
select order_num, item_num, description, i.manu_code, quantity, (unit_price * quantity) precioTotal, manu_name
from items i inner join product_types p on (i.stock_num = p.stock_num)
inner join manufact m on (m.manu_code = i.manu_code)
where order_num=1004 

4)
SELECT o.order_num, c.customer_num, fname, lname, company
FROM customer c JOIN order o ON (c.customer_num = o.customer_num)

5)
SELECT DISTINCT c.customer_num, fname, lname, company
FROM customer c JOIN order o ON (c.customer_num = o.customer_num)

6)
SELECT manu_name, p.stock_num, pt.description, u.unit, unit_price, (unit_price*1.2) precio_junio
FROM products p JOIN manufact m ON (p.manu_code = m.manu_code)
		JOIN product_types pt ON (p.stock_num = pt.stock_num)
		JOIN units u ON (p.unit_code = u.unit_code)

7)
SELECT item_num, pt.description, quantity, (unit_price*quantity) precio_total
FROM items i JOIN product_types pt ON (i.stock_num = pt.stock_num)
WHERE order_num = 1004

8)
SELECT manu_name, lead_time
FROM items i 	JOIN orders o ON (i.order_num = o.order_num)
		JOIN customer c ON (c.customer_num = o.customer_num)
		JOIN manufact m ON (i.manu_code = m.manu_code)
WHERE customer_num = 104

9)
select o.order_num, order_date, item_num, description, quantity, (unit_price * quantity) precioTotal
from orders o join items i on o.order_num = i.order_num   
join product_types pt on pt.stock_num = i.stock_num

10)
select lname+ ', ' +fname, '(' + SUBSTRING(phone, 1, 3) + ') ' + SUBSTRING(phone, 5, 8)
from customer c
order by lname, fname

11)
SELECT ship_date, lname+', '+fname,COUNT(order_num)
FROM orders o JOIN customer c ON (o.customer_num=c.customer_num)
JOIN state s ON (c.state = s.state)
WHERE zipcode BETWEEN 94000 AND 94100
AND sname='California'
GROUP BY ship_date, lname, fname
ORDER BY ship_date, lname, fname

12)
SELECT manu_name, description, SUM(quantity) cantidadVendida,
SUM(quantity* unit_price) totalVendido
FROM manufact m JOIN items i ON (m.manu_code=i.manu_code)
				JOIN product_types p ON (i.stock_num = p.stock_num)
				JOIN orders o ON (i.order_num=o.order_num)
WHERE m.manu_code IN ('ANZ', 'HRO', 'HSK', 'SMT')
AND order_date BETWEEN '2015-05-01' AND '2015-06-30'
GROUP BY manu_name, description
ORDER BY 4 DESC

13)
SELECT CAST(YEAR(order_date) AS VARCHAR)+'/'
+CAST(MONTH(order_date) AS VARCHAR) AnioMes,
SUM(quantity) Cantidad, SUM(unit_price*quantity) Total
FROM orders O JOIN items i ON (o.order_num=i.order_num)
GROUP BY CAST(YEAR(order_date) AS VARCHAR)+'/'
+CAST(MONTH(order_date) AS VARCHAR)
ORDER BY 3 DESC







