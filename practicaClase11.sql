1)
SELECT c.customer_num, fname, lname, SUM(unit_price * quantity) totalComprado, COUNT(DISTINCT o.order_num) cantOrdenes, (SELECT COUNT(*) FROM orders) CantTotalOC
FROM customer c JOIN orders o ON(c.customer_num = o.customer_num)
                JOIN items i ON(o.order_num = i.order_num)
WHERE zipcode LIKE '94&'
GROUP BY c.customer_num, fname, lname
HAVING COUNT(DISTINCT o.order_num) >= 2   //VA DISTINCT ACA EN EL COUNT PQ PUEDE TRAER MUCHAS OC IGUALES YA QUE JOINEA CON ITEMS
AND SUM(unit_price*quantity)/COUNT(DISTINCT o.order_num) > (
    SELECT SUM(i2.unit_price*i2.quantity)/COUNT(DISTINCT i2.order_num) FROM items i2
)

2)
SELECT i.stock_num, i.manu_code, pt.description, manu_name, 
SUM(i.quantity * i.unit_price) totalPedidoEn$, SUM(i.quantity) cantPedido
INTO #ABD_PRODUCTOS
FROM items i JOIN product_types pt ON(pt.stock_num = i.stock_num)
			 JOIN manufact m ON(i.manu_code = m.manu_code)
WHERE i.manu_code IN 
(SELECT p.manu_code
FROM products p
GROUP BY p.manu_code
HAVING COUNT(*) > 10)
GROUP BY i.stock_num, i.manu_code, pt.description, manu_name

3)
SELECT pt.description, MONTH(o.order_date), c.lname + ', ' + c.fname, COUNT(DISTINCT o.order_num) AS 'Cant OC por mes', 
SUM(i.quantity) AS 'Unid Producto por mes', SUM(i.quantity * i.unit_price) AS 'u$ Producto por mes'
FROM #ABD_PRODUCTOS ab JOIN items i ON(ab.stock_num = i.stock_num AND ab.manu_code = i.manu_code)
					   JOIN orders o ON(o.order_num = i.order_num)
					   JOIN customer c ON(c.customer_num = o.customer_num)
					   JOIN product_types pt ON(ab.stock_num = pt.stock_num)
WHERE c.state = (                   //TIENE QUE MATCHEAR CON LO QUE ME DA EL SELECT
SELECT TOP 1 s.state 
FROM state s JOIN customer c1 ON(c1.state = s.state)
GROUP BY s.state                    //PODRIA HABER AGARRADO SOLO CUSTOMER Y AGRUPAR POR STATE
ORDER BY COUNT(customer_num) DESC)
GROUP BY pt.description, MONTH(o.order_date), c.lname, c.fname
ORDER BY 1,2 ASC, 5 DESC  //POR DEFECTO ES ASC

//Chequear 

4)

SELECT DISTINCT i1.stock_num, i1.manu_code, c1.customer_num, c1.lname, sub2.customer_num, sub2.lname
FROM items i1 JOIN orders o1 ON (o1.order_num = i1.order_num)
				JOIN customer c1 ON (o1.customer_num = c1.customer_num)
				JOIN (SELECT SUM(quantity) sumaC2, i2.stock_num, c2.customer_num, c2.lname
					FROM items i2 JOIN orders o2 ON (i2.order_num=o2.order_num)
					              JOIN customer c2 ON(c2.customer_num = o2.customer_num)
		            GROUP BY i2.stock_num, c2.customer_num, c2.lname) sub2 ON(sub2.stock_num = i1.stock_num AND sub2.customer_num != c1.customer_num)
WHERE i1.stock_num IN (5,6,9)
AND i1.manu_code='ANZ'
GROUP BY i1.stock_num, i1.manu_code, c1.customer_num, c1.lname, sub2.customer_num, sub2.lname, sub2.sumaC2
HAVING SUM(i1.quantity) > sub2.sumaC2
Order by i1.stock_num, i1.manu_code;


//PROBAR USANDO YA LOS JOINS CALCULADOS ARRIBA HACIENDO EL SUM EN EL HAVING Y NO TENER QUE OTRA VEZ HACER UN SELECT EN EL WHERE.
//LISTO

5)
SELECT MAX(cantOrd) maxCantOrd, MAX(sumPrecio) maxSumPrecio,MAX(cantItem) maxCantItem,
MIN(cantOrd) minCantOrd, MIN(sumPrecio) minSumPrecio, MIN(cantItem) minCantItem
FROM (SELECT o1.customer_num,
	COUNT(DISTINCT i1.order_num) cantOrd,
	SUM(i1.unit_price * i1.quantity) sumPrecio,
	sum(i1.quantity) cantItem
	FROM orders o1 JOIN items i1 ON (o1.order_num = i1.order_num)
	GROUP BY o1.customer_num) subt

 6)
SELECT c.customer_num, o.order_num, SUM(i.quantity * i.unit_price) montoTotalOrden
FROM customer c JOIN orders o ON(o.customer_num = c.customer_num)
				LEFT JOIN items i ON(o.order_num = i.order_num)
WHERE c.state = 'CA' 
AND c.customer_num IN (
	SELECT customer_num
	FROM orders
	WHERE YEAR(order_date) = 2015
	GROUP BY customer_num
	HAVING COUNT(order_num) >= 4 )
GROUP BY c.customer_num, o.order_num
HAVING COUNT(i.item_num) > (
	SELECT TOP 1 COUNT(i2.item_num)
	FROM items i2 JOIN orders o2 ON(i2.order_num = o2.order_num)
	              JOIN customer c2 ON(c2.customer_num = o2.customer_num)
	WHERE c2.state = 'AZ'
	AND YEAR(o2.order_date) = 2015
	GROUP BY o.order_num
	ORDER BY 1 DESC)

7)
SELECT TOP 1 s.state, sname, c1.lname+', '+c1.fname, c2.lname+', '+c2.fname,
totcli1 + totcli2 'Total'
FROM state s JOIN customer c1 ON (s.state = c1.state)
				JOIN customer c2 ON (s.state = c2.state)
				JOIN (SELECT o1.customer_num, SUM(unit_price*quantity) totcli1
				FROM orders o1 JOIN items i1 ON (o1.order_num = i1.order_num)
				GROUP BY o1.customer_num) totc1 ON (c1.customer_num = totc1.customer_num)
				JOIN (SELECT o2.customer_num, SUM(unit_price*quantity) totcli2
				FROM orders o2 JOIN items i2 ON (o2.order_num = i2.order_num)
				GROUP BY customer_num) totc2 ON (c2.customer_num = totc2.customer_num)
WHERE c1.customer_num > c2.customer_num AND s.state ='CA'
ORDER BY 5 DESC

9)
SELECT c.customer_num, c.fname, c.lname, c.state, COUNT(DISTINCT o.order_num) cantOC, SUM(i.quantity * i.unit_price) montoTotal
FROM customer c JOIN orders o ON(c.customer_num = o.customer_num)
				JOIN items i ON(i.order_num = o.order_num)
WHERE c.state != 'WI'
GROUP BY c.customer_num, c.fname, c.lname, c.state
HAVING SUM(i.quantity * i.unit_price) > (
	SELECT SUM(quantity * unit_price)/COUNT(DISTINCT order_num)
	FROM items)

