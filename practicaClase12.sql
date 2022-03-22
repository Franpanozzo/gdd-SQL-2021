1)
SELECT c.customer_num, fname, lname, state, COUNT(DISTINCT o.order_num) cantOrdenes, SUM(i.quantity * i.unit_price) totalComprado
FROM customer c JOIN orders o ON(c.customer_num = o.customer_num)
				JOIN items i ON(o.order_num = i.order_num)
WHERE YEAR(o.order_date) = 2015
AND c.state != 'FL'
GROUP BY c.customer_num, fname, lname, state
HAVING SUM(i.quantity * i.unit_price) > (
	SELECT SUM(i2.quantity * i2.unit_price) / COUNT(DISTINCT o2.customer_num)
	FROM items i2 JOIN orders o2 ON(o2.order_num = i2.order_num)
				 JOIN customer c2 ON(c2.customer_num = o2.customer_num)
	WHERE c2.state != 'FL')
ORDER BY 6 DESC

2)
SELECT c.customer_num, c.fname, c.lname, SUM(i.quantity * i.unit_price) montoTotal, c2.customer_num, c2.fname, c2.lname, c2.sumaTotal
FROM customer c JOIN orders o ON(c.customer_num = o.customer_num)
				JOIN items i ON(o.order_num = i.order_num)
				LEFT JOIN (SELECT SUM(i2.quantity * i2.unit_price) sumaTotal, c2.customer_num, c2.fname, c2.lname
							FROM customer c2 LEFT JOIN orders o2 ON(c2.customer_num = o2.customer_num)
											LEFT JOIN items i2 ON(o2.order_num = i2.order_num)
											WHERE YEAR(o2.order_date)= 2015
											GROUP BY  c2.customer_num, c2.fname, c2.lname) c2 ON(c2.customer_num = c.customer_num_referedBy)
WHERE YEAR(o.order_date) = 2015
GROUP BY c.customer_num, c.fname, c.lname,  c2.customer_num, c2.fname, c2.lname, c2.sumaTotal
HAVING SUM(i.quantity * i.unit_price) >  COALESCE(c2.sumaTotal,0)
ORDER BY 4 DESC
