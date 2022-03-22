1) 
SELECT * INTO #clientes FROM customer

2)
INSERT INTO #clientes (Customer_num, Fname, Lname, Company, State, City)
VALUES (144, Agustin, Creevy, Jaguares SA, CA, Los Angeles) //Faltan comillas para strings

3)
SELECT * 
INTO #clientesCalifornia       //Crea nueva tabla temporal
FROM customer
WHERE state='CA'

4)
INSERT INTO #clientes (Customer_num, Fname, Lname, Company, State, City) 
SELECT (155, Fname, Lname, Company, State, City)                         //El resultado del select se inserta en la tabla ya creada
FROM customer  
WHERE Customer_num = 103

SELECT * FROM #clientes
WHERE customer_num = 155

5)
SELECT * FROM #clientes
WHERE zipcode BETWEEN(94000,94050)
AND ciudad LIKE 'M%'

DELETE FROM #clientes
WHERE zipcode BETWEEN(94000,94050)
AND ciudad LIKE 'M%'

6)
SELECT * FROM #clientes
WHERE customer_num NOT IN (SELECT customer_num FROM orders) //Solo de un valor

7)
SELECT * FROM #clientes 
WHERE state = 'CO'

UPDATE #clientes
SET state = 'AK', adress = 'Barrio Las Heras'
WHERE state = 'CO'

8)
UPDATE #clientes
SET CONCAT('1',phone) // o tambien SET '1' + phone;


















