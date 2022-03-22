PRACTICA CLASE 3:

1) 
SELECT customer_num, adress1, adress2
FROM customer

2)
SELECT customer_num, adress1, adress2
FROM customer
WHERE state = 'CA'

3)
SELECT DISTINCT city
FROM customer
WHERE state = 'CA'

4) 
SELECT DISTINCT city
FROM customer
WHERE state = 'CA'
ORDER BY 1

5)
SELECT address1
FROM customer
WHERE customer_num = 103

6)
SELECT stock_num, unit_code
FROM products 
WHERE manu_code = 'ANZ'
ORDER BY unit_code

7)
SELECT DISTINCT manu_code
FROM items
ORDER BY manu_code

8)
SELECT order_num, order_date, customer_num, ship_date
FROM orders
WHERE paid_date IS NULL
AND YEAR(ship_date) = 2015
AND MONTH(ship_date) BETWEEN 1 AND 6

9) 
SELECT customer_num, company
FROM customer
WHERE company LIKE "%town%"

10)
SELECT
MAX(ship_charge) precio_max,
MIN(ship_charge) precio_min,
AVG(ship_charge) precio_prom
FROM orders

11)
SELECT order_num, order_date, ship_date
FROM orders
WHERE MONTH(ship_date)=MONTH(order_date)

12)
SELECT customer_num, ship_date, COUNT(*), SUM(ship_charge) costo_total
FROM orders
GROUP BY customer_num, ship_date
ORDER BY 2 DESC

13)
SELECT ship_date, sum(ship_weight) pesoTotal
FROM orders
GROUP BY ship_date
HAVING sum(ship_weight) >= 30
ORDER BY pesoTotal DESC











