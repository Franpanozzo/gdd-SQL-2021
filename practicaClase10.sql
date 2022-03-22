1) 
a)
CREATE VIEW view_ejercicio_uno
(codigo, nombre, cant_producto, ultimaCompra)
AS
SELECT m.manu_code, manu_name, COUNT(DISTINCT p.stock_num) cantProductos, MAX(o.order_date) ult_fecha_orden
FROM manufact m LEFT JOIN products p ON(p.manu_code = m.manu_code)
				LEFT JOIN items i ON(i.stock_num = p.stock_num)
				LEFT JOIN orders o ON(o.order_num = i.order_num)
GROUP BY m.manu_code, m.manu_name
HAVING COUNT(DISTINCT p.stock_num) > 2 OR COUNT(DISTINCT p.stock_num) = 0

SELECT * FROM view_ejercicio_uno

b) 
//FUNCION COALESCE, Si el primer elemento es nulo muestra el segundo
SELECT manu_code, manu_name, cant_productos, COALESCE(ultimaCompra as CHAR), 'No posee Productos')
FROM view_ejercicio_uno

2) 

SELECT m.manu_code, manu_name, COUNT(DISTINCT i.order_num) cantOrdenes, SUM(quantity * i.unit_price) montoTotal
FROM manufact m JOIN items i ON(i.manu_code = m.manu_code)
				JOIN product_types pt ON (i.stock_num = pt.stock_num)
WHERE m.manu_code LIKE '[AB]_' AND 
(pt.description LIKE '%tennis%' OR pt.description LIKE '%ball%')
GROUP BY m.manu_code, m.manu_name
HAVING SUM(quantity * i.unit_price) > (
	SELECT SUM(unit_price * quantity)/COUNT(DISTINCT m.manu_code)
    FROM manufact m JOIN items i ON (m.manu_code = i.manu_code)
)
ORDER BY 4 DESC;

3) 
//Chequear con respuesta

CREATE VIEW ordenes_cliente
AS
SELECT c.customer_num, lname, company, COUNT(DISTINCT o.order_num) cantOrdenes, MAX(o.order_num) ultimaOrden, SUM(unit_price * quantity) montoTotal, (SELECT SUM(quantity * unit_price) FROM items i) totalGeneral
FROM customer c LEFT JOIN orders o ON(c.customer_num = o.customer_num)
			    LEFT JOIN items i ON(i.order_num = o.order_num)
WHERE (SELECT COUNT(DISTINCT m.manu_code) FROM manufact m
		JOIN products p ON(p.manu_code = m.manu_code AND p.stock_num = i.stock_num)) > 2
GROUP BY c.customer_num, lname, company
HAVING COUNT(DISTINCT o.order_num) >= 3 OR COUNT(DISTINCT o.order_num) = 0

SELECT * FROM ordenes_cliente
ORDER BY 4 DESC


4)
SELECT top 5 t.description, c.state, SUM(i.quantity)
FROM items i JOIN product_types t ON i.stock_num=t.stock_num
			JOIN orders o ON i.order_num = o.order_num
			JOIN customer c ON o.customer_num = c.customer_num
WHERE i.stock_num =
	(SELECT TOP 1 i1.stock_num
	FROM product_types t1 JOIN items i1 ON i1.stock_num = t1.stock_num
						JOIN orders o1 ON i1.order_num = o1.order_num
						JOIN customer c1 ON o1.customer_num = c1.customer_num
	WHERE c.state = c1.state
	GROUP BY i1.stock_num, c1.state
	ORDER BY SUM(i1.quantity) DESC)
GROUP BY i.stock_num, t.description, c.state
ORDER BY SUM(i.quantity) desc

5)
SELECT customer_num, fname, lname, null paid_date, 0 monto_total
FROM customer
WHERE customer_num not in (SELECT DISTINCT customer_num FROM orders o)
UNION
SELECT c.customer_num, fname, lname, o.paid_date, SUM(i.quantity * i.unit_price) montoTotal
FROM customer c JOIN orders o ON(o.customer_num = c.customer_num)
				JOIN items i ON(i.order_num = O.order_num)
WHERE o.order_num in (
	SELECT TOP 1 o1.order_num
	FROM orders o1
	WHERE o1.customer_num = c.customer_num
	GROUP BY o1.order_num
	ORDER BY MAX(order_date) DESC)
GROUP BY c.customer_num, fname, lname, o.paid_date, o.order_num
HAVING SUM(i.quantity * i.unit_price) > 
	(SELECT SUM(i2.quantity * i2.unit_price)/COUNT(DISTINCT o2.order_num)
	FROM orders o2 JOIN items i2 ON(i2.order_num = o2.order_num)
	WHERE o2.order_num != o.order_num
	AND o2.customer_num = c.customer_num) 
ORDER BY 5 DESC

6)
SELECT p.stock_num, pt.description, p.manu_code, SUM(i.quantity) cantVendida, SUM(i.quantity * i.unit_price) montoTotal
FROM products p JOIN product_types pt ON(p.stock_num = pt.stock_num)
				JOIN items i ON(p.stock_num = i.stock_num and p.manu_code = i.manu_code)
WHERE p.stock_num in (SELECT p1.stock_num FROM products p1 GROUP BY p1.stock_num HAVING COUNT(*) > 1)
GROUP BY p.stock_num, pt.description, p.manu_code
HAVING SUM(i.quantity) > 
	(SELECT TOP 1 SUM(i2.quantity) 
	FROM items i2
	WHERE i2.manu_code != p.manu_code AND i2.stock_num = p.stock_num
	GROUP BY i2.manu_code, i2.stock_num
	ORDER BY 1 DESC)
ORDER BY 1, 4 DESC, 5 DESC





