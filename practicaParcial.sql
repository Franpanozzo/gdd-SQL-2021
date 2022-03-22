---------PROCEDURE------------ 

1)
CREATE TABLE dbo.Novedades (
fechaAlta DATE,
manu_code CHAR(3),
stock_num SMALLINT,
descTipoProducto varchar(15),
unit_price decimal,
unit_code SMALLINT
)
GO

CREATE PROCEDURE dbo.actualizaPrecios @fecha DATE
AS
BEGIN
	DECLARE @fechaAlta DATE, @manu_code CHAR(3), @stock_num SMALLINT, @descTipoProducto varchar(15),
	@unit_price decimal, @unit_code SMALLINT

	DECLARE novedadesCursor CURSOR FOR
	SELECT *
	FROM dbo.Novedades
	WHERE @fechaAlta > fechaAlta

	OPEN novedadesCursor
	FETCH novedadesCursor INTO @fechaAlta, @manu_code, @stock_num, @descTipoProducto,
	@unit_price, @unit_code

	WHILE(@@FETCH_STATUS = 0)
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION
			
				IF(NOT EXISTS(SELECT 1 FROM manufact WHERE manu_code = @manu_code))
					THROW 50000, 'Fabricante inexistente' ,1
					/* Ni si quiera la borra la novedad de la tabla paso a la siguiente
					porque hay un catch abajo dentro del while */
					
				IF(NOT EXISTS(SELECT 1 FROM products WHERE stock_num = @stock_num))
				BEGIN
					INSERT INTO product_types (stock_num, description)
					VALUES(@stock_num, @descTipoProducto)

					INSERT INTO products
					VALUES(@stock_num,@manu_code,@unit_price, @unit_code)
				END
				ELSE
				BEGIN
					UPDATE products
					SET unit_price = @unit_price
					WHERE @stock_num = @stock_num
					AND @manu_code = manu_code
				END

			COMMIT TRANSACTION

		END TRY

		BEGIN CATCH
			ROLLBACK TRANSACTION;
			DECLARE @errorDescripcion VARCHAR(255)
			SELECT @errorDescripcion = ERROR_MESSAGE();
			THROW 50000, @errorDescripcion, 1
		END CATCH

		FETCH NEXT FROM novedadesCursor INTO  @fechaAlta, @manu_code, @stock_num, @descTipoProducto,
		@unit_price, @unit_code

	END;
	CLOSE novedadesCursor
	DEALLOCATE novedadesCursor
END

2)
CREATE PROCEDURE stock @fecha datetime
AS
BEGIN
  BEGIN TRY
    BEGIN TRANSACTION 

		DECLARE @cadenaFecha varchar(6)
		SET @cadenaFecha = cast(year(@fecha)*100+month(@fecha) AS varchar(6)) 
		
		INSERT INTO ventasXmes
		SELECT @cadenaFecha,  i.stock_num, i.manu_code,
		    (CASE WHEN p.unit_code = 1 THEN quantity
				  WHEN p.unit_code = 2 THEN quantity *2
				  WHEN p.unit_code = 3 THEN quantity *12
			END) as cantidad,
			sum(quantity*i.unit_price)
		FROM orders o
		JOIN items i ON o.order_num = i.order_num
		JOIN products p ON p.manu_code = i.manu_code
		AND p.stock_num = i.stock_num
		WHERE YEAR(order_date) = YEAR(@fecha) 
		AND MONTH(order_date) = MONTH(@fecha)
		GROUP BY i.manu_code, i.stock_num;

		commit;
  END try

		begin catch
			rollback;
		end catch
END

4)
CREATE PROCEDURE actualizarClientesOnline
AS
BEGIN 
	DECLARE @customer_num SMALLINT, @lname VARCHAR(15), @fname VARCHAR(15), @company VARCHAR(20),
	@address1 VARCHAR(20), @city VARCHAR(15), @state CHAR(2), @modif VARCHAR(10)

	DECLARE onlineCur CURSOR FOR
	SELECT customer_num, lname, fname, company, address1, city, state
	FROM clientesAltaOnline

	OPEN onlineCur
	FETCH onlineCur INTO @customer_num, @lname, @fname , @company ,
	@address1, @city, @state 

	WHILE(@@FETCH_STATUS = 0)
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION
				IF(EXISTS (SELECT 1 FROM customer WHERE customer_num = @customer_num))
				BEGIN
					UPDATE customer
					SET fname = @fname, lname = @lname, company = @company,
					address1 = @address1, city = @city, state = @state
					WHERE customer_num = @customer_num

					SET @modif = 'modificado'
				END
				ELSE
				BEGIN
					INSERT INTO customer (customer_num, fname, lname, company, address1, city, state)
					VALUES(@customer_num, @fname, @lname, @company, @address1, @address1, @state)

					SET @modif = 'insert'
				END

				INSERT INTO auditoria (operacion, customer_num, fname, lname, company, address1, city, state)
				VALUES(@modif, @customer_num, @fname, @lname, @company, @address1, @address1, @state)

			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
		END CATCH

		FETCH NEXT FROM onlineCur INTO @customer_num, @lname, @fname , @company ,
		@address1, @city, @state 

	END

	CLOSE onlineCur
	DEALLOCATE onlineCur
END

5) 
CREATE PROCEDURE procBorraOC @order_num SMALLINT
AS
BEGIN 
	BEGIN TRY
		BEGIN TRANSACTION

			INSERT INTO auditOC (order_num, order_date, customer_num, cantidad_items,
								totalOrden, cant_productos_comprado)
			SELECT o.order_num, order_date, customer_num, COUNT(item_num), SUM(quantity * unit_price), SUM(quantity)
			FROM orders o JOIN items i ON(o.order_num = i.order_num)
			WHERE o.order_num = @order_num
			GROUP BY o.order_num, order_date, customer_num

			DELETE FROM orders
			WHERE order_num = @order_num

			DELETE FROM items
			WHERE order_num = @order_num

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH 
		ROLLBACK TRANSACTION

		INSERT INTO erroresOC
		SELECT order_num, order_date, customer_num, ERROR_MESSAGE()
		FROM orders
		WHERE order_num = @orden_num
	END CATCH
END

----------QUERIES COMPLEJOS--------------- 

1)
'Obtener los Tipos de Productos, monto total comprado por cliente y por sus referidos. 
Mostrar:
descripción del Tipo de Producto, Nombre y apellido del cliente, monto total comprado de ese
tipo de producto, Nombre y apellido de su cliente referido y el monto total comprado de su
referido. Ordenado por Descripción, Apellido y Nombre del cliente (Referente).
Nota: Si el Cliente no tiene referidos o sus referidos no compraron el mismo producto, 
mostrar -- ́ como nombre y apellido del referido y 0 (cero) en la cantidad vendida.'

SELECT pt.description, c.fname + ',' + c.lname nombreApellido, SUM(i.quantity *  i.unit_price) cliComprado,
				COALESCE(cli2.fname + ','+ cli2.lname,'--') nombreApellidoRef, COALESCE(cli2.totalCompra, 0) refComprado
FROM customer c JOIN orders o ON(o.customer_num = c.customer_num)
				JOIN items i ON(i.order_num = o.order_num)
				JOIN product_types pt ON(pt.stock_num = i.stock_num)
				LEFT JOIN (SELECT c2.fname, c2.lname, c2.customer_num, i2.stock_num, SUM(i2.quantity * i2.unit_price) totalCompra
						FROM customer c2 JOIN orders o2 ON(c2.customer_num = o2.order_num)
										 JOIN items i2 ON(i2.order_num = o2.order_num)
						GROUP BY c2.fname, c2.lname, c2.customer_num, i2.stock_num) cli2 ON(cli2.customer_num = c.customer_num_referedBy AND cli2.stock_num = i.stock_num)
GROUP BY i.stock_num, pt.description, c.fname, c.lname, cli2.fname, cli2.lname, cli2.totalCompra
ORDER BY 1, 4 DESC

2)
'se requiere crear una vista "comprasFabricanteLider" en la qu se oculten los nombres de 
campos reales y que detalle  : nombre del fabricante, apellido y nombre del cleinte, descripcion 
del tipo de producto, la sumatoria del monto total (p x q) y la sumatoria del campo quantity
ese informe debera mostrar solo los productos cuyo nombre contenga el substring "ball" y 
que el fabricante sea el lider en ventas(osea, al cual le haya comprado mas productos en pesos)
ademas, solo se deberan mostrar aquellos registros que el promedio en pesos de productos vendidos 
a cada cliente sea mayor a 150 pesos por unidad.'

CREATE VIEW comprasFabricanteLider (nombreFab, apeYNomCli, descripProduct, montoTotal, cantidadTotal)
AS
SELECT manu_name, fname + ', ' + lname, pt.description, SUM(i.unit_price * i.quantity), SUM(quantity)
FROM customer c JOIN orders o ON(c.customer_num = o.customer_num)
				JOIN items i ON(i.order_num = o.order_num)
				JOIN product_types pt ON(pt.stock_num = i.stock_num)
				JOIN manufact m ON(m.manu_code = i.manu_code)
WHERE pt.description LIKE '%ball%'
AND m.manu_code IN (
	SELECT TOP 1 manu_code
	FROM items i2
	GROUP BY manu_code
	ORDER BY SUM(i2.quantity * i2.unit_price))
GROUP BY manu_name, fname, lname, pt.description
HAVING SUM(i.unit_price * i.quantity) / SUM(i.quantity) > 150

3)
'_____________________________________________________________________________________________________'
'crear una consulta que devuelva:'
'Apellido, nombre AS CLIENTE,
suma de todo lo comprado por el cliente as totalCompra
apellido,nombre as ClienteReferido ,
suma de todo lo comprado por el referido * 0.05 AS totalComision'

SELECT c.lname + ', ' + c.fname AS CLIENTE, SUM(i.quantity * i.unit_price) totalCompra,
		cliRef.lname + ',' + cliRef.fname ClienteReferido, cliRef.totalCompra * 0.05 AS totalComision
FROM customer c JOIN orders o ON(o.customer_num = c.customer_num)
				JOIN items i ON(i.order_num = o.order_num)
				JOIN (SELECT c.customer_num, fname, lname, SUM(quantity * unit_price) totalCompra
					 FROM customer c JOIN orders o ON(o.customer_num = c.customer_num)
									JOIN items i ON(i.order_num = o.order_num)
					 GROUP BY fname, lname, c.customer_num) cliRef ON(cliRef.customer_num_referedBy = c.customer_num) 
GROUP BY c.lname, c.fname, cliRef.lname, cliRef.fname, cliRef.totalCompra

/* Al reves (de como lo hacia siempre, asi esta bien) el match del join si busco a quienes refirio, osea los referidos */
4)
'_____________________________________________________________________________________________________'
'vista que muestre las tres primeras provincias que tengan la mayor cantidad de compras ,
mostrar nombre y apellido del cliente con mayor total de compra para esa provincia, 
total comprado y nombre de la provincia.'

CREATE VIEW provinciasMasCotizadas (state, apellYNombre, totalComprado)
AS
SELECT stateMay.sname, c.lname + ',' + c.fname, SUM(quantity * unit_price) 
FROM customer c JOIN (SELECT TOP 3 c3.state, s.sname
					  FROM customer c3 JOIN orders o3 ON(o3.customer_num = c3.customer_num)
									   JOIN items i3 ON(o3.order_num = i3.order_num)
									   JOIN state s ON(c3.state = s.state)
					  GROUP BY c3.state, s.sname
					  ORDER BY SUM(quantity * unit_price) DESC) stateMay ON(stateMay.state = c.state)
				JOIN orders o ON(c.customer_num = o.customer_num)
				JOIN items i ON(i.order_num = o.order_num)
WHERE c.customer_num IN (
	SELECT TOP 1 c2.customer_num
	FROM customer c2 JOIN orders o2 ON(c2.customer_num = o2.customer_num)
					JOIN items i2 ON(i2.order_num = o2.order_num)
	WHERE c2.state = c.state
	GROUP BY c2.customer_num
	ORDER BY SUM(i2.quantity * i2.unit_price) DESC)
GROUP BY stateMay.sname, c.lname, c.fname
GO


5)
'seleccionar codigo de fabricante, nombre fabricante, cantidad de ordenes del fabricante,
cantidad total vendida del fabricante, promedio de las cantidades vendidas de todos los 
fabricantes cuyas ventas totales sean mayores al promedio de las ventas de todos los 
fabricantes '
'mostrar el resultado ordenado por cantidad total vendida en forma descendente'

SELECT m.manu_code, manu_name, COUNT(DISTINCT order_num), SUM(quantity) totalVendido, (SELECT SUM(quantity) / COUNT(distinct manu_code) FROM items i) as promedioTodosLosFabricantes
FROM manufact m JOIN items i ON(i.manu_code = m.manu_code)
GROUP BY m.manu_code, manu_name
HAVING SUM(quantity) > (
	SELECT SUM(quantity) / COUNT(DISTINCT i2.manu_code)
	FROM items i2 )
ORDER BY 4 DESC

6)
'1. Listar Número de Cliente, apellido y nombre, Total Comprado por el cliente ‘Total delCliente’,
Cantidad de Órdenes de Compra del cliente ‘OCs del Cliente’ y la Cant. de Órdenes de Compra
solicitadas por todos los clientes ‘Cant. Total OC’, de todos aquellos clientes cuyo promedio de compra
por Orden supere al promedio de órdenes de compra general, tengan al menos 2 órdenes y cuyo
zipcode comience con 94.'

SELECT c.customer_num, fname, lname, SUM(quantity *unit_price) totalComprado, COUNT(DISTINCT o.order_num) OCcliente,
(SELECT COUNT(order_num) FROM orders) 'Cant. Total OC'
FROM customer c JOIN orders o ON(c.customer_num = o.customer_num)
				JOIN items i ON(i.order_num = o.order_num)
WHERE zipcode LIKE '94%'
GROUP BY c.customer_num, fname, lname
HAVING COUNT(DISTINCT o.order_num) >= 2
AND SUM(quantity *unit_price) / COUNT(DISTINCT o.order_num) > (
	SELECT SUM(i2.quantity *i2.unit_price) / COUNT(DISTINCT i2.order_num) FROM items i2)

7)
'9. Listar el numero, nombre, apellido, estado, cantidad de ordenes y monto total comprado de los
clientes que no sean del estado de Wisconsin y cuyo monto total comprado sea mayor que el monto
total promedio de órdenes de compra.'

SELECT c.customer_num, fname, lname, state, COUNT(DISTINCT o.order_num) cantOrdenes, SUM(quantity * unit_price) totalComprado
FROM customer c JOIN orders o ON(o.customer_num = c.customer_num)
				JOIN items i ON(i.order_num = o.order_num)
WHERE state NOT LIKE 'WI'
GROUP BY c.customer_num, fname, lname, state
HAVING SUM(quantity * unit_price) > (
	SELECT SUM(i2.quantity * i2.unit_price) / COUNT(DISTINCT i2.order_num) FROM items i2)


--------------TRIGGERS-----------------

1)
'Se desea llevar en tiempo real la cantidad de llamadas/reclamos (Cust_calls) de los
Clientes (Customers) que se producen por cada mes del año y por cada tipo (Call_code).

Ante este requerimiento, se solicita realizar un trigger que cada vez que se produzca un 
Alta o Modificación en la tabla Cust_calls, se actualice una tabla donde se lleva la cuenta 
por Año, Mes y Tipo de llamada.

Ejemplo. Si se da de alta una llamada, se debe sumar 1 a la cuenta de ese Año, Mes y Tipo de 
llamada. En caso de ser una modificación y se modifica el tipo de llamada (por ejemplo por 
una mala clasificación del operador), se deberá restar 1 al tipo anterior y sumarle 1 al 
tipo nuevo. Si no se modifica el tipo de llamada no se deberá hacer nada.

Tabla ResumenLLamadas
Anio   decimal(4) PK,
Mes    decimal(2) PK,
Call_code char(1) PK,
Cantidad   int 

Nota: No se modifica la PK de la tabla de llamadas. Tener en cuenta altas y modificaciones múltiples.'

create trigger custCallsTr ON Cust_calls
AFTER Insert, update as
begin
  -- 
  declare @anio decimal(4)
  declare @mes  decimal(2)
  declare @tipo char(1)
  --
  declare curIns CURSOR FOR 
          select year(call_time), month(call_time), call_code
            from inserted

  declare curDel CURSOR FOR  
          select year(call_time), month(call_time), call_code
            from deleted

    open curIns
    FETCH NEXT FROM curIns into @anio, @mes, @tipo
    while @@FETCH NEXT FROM_status = 0
    begin
       update resumenLlamadas 
          set cantidad += 1
        where anio = @anio 
          and mes = @mes
          and call_code = @tipo
       --
       FETCH NEXT FROM curIns into @anio, @mes, @tipo
    end 
    close curIns
    Deallocate  curIns


    open curDel
    FETCH NEXT FROM curDel into @anio, @mes, @tipo
    while @@FETCH NEXT FROM_status = 0
    begin
       update resumenLlamadas 
          set cantidad = cantidad - 1
        where anio = @anio 
          and mes = @mes
          and call_code = @tipo
       --
       FETCH NEXT FROM curDel into @anio, @mes, @tipo
    end 
    close curDel
    Deallocate  curDel
    --
    COMMIT
 --
end


2)
'_____________________________________________________________________________________________________'
'dada la tabla custoemr y customer_audit'
'ante deletes y updates de los campos lname, fname, state o customer_num_refered de la 
tabla customer, auditar los cambios colocando en los campos NEW los valores nuevos y guardar 
en los campos OLD los valores que tenian antes de su borrado/modificacion'.
'en los campos apeyNom se deben guardar los nombres y apellidos concatenados respectivos
en el campo update_date guardar la fecha y hora ctual y en update_user el usuario que realiza 
el update.
verificar en las modificaiones la validez de las claves foraneas ingresdas y en caso de error 
informarlo y deshacer la operacion'
'nota'; 'asumir que ya existe la tabla de auditoria, las modificaciones pueden ser masivas 
y en caso de error solo se debe deshacer la operacion actual'

//MIRAR RESULETO LEYENDO ACLARACION EN CARPETA TAMBIEN

CREATE TRIGGER customerAuditoria
ON customer
INSTEAD OF UPDATE /*Creo que es un instead of porque se hace un chequeo de integridad referencial, no quiero que se ingresen datos que la rompan*/
AS                
BEGIN
	DECLARE @fnameNEW VARCHAR(15), @fnameOLD VARCHAR(15), @lnameNEW VARCHAR(15), @lnameOLD VARCHAR(15),
	@stateOLD CHAR(2), @stateNEW CHAR(2), @customer_num_referedOLD SMALLINT, @customer_num_referedNEW SMALLINT

	DECLARE auditCur CURSOR FOR
	SELECT i.fname, d.fname, i.lname, d.lname, i.state, d.state, i.customer_num_referedBy, d.customer_num_referedBy
	FROM inserted i JOIN deleted d ON(i.customer_num = d.customer_num)
	WHERE i.fname != d.fname
	OR i.lname != d.lname
	OR i.state != d.state
	OR i.customer_num_referedBy != d.customer_num_referedBy

	OPEN auditCur
	FETCH auditCur INTO @fnameNEW, @fnameOLD, @lnameNEW, @lnameOLD,
	@stateNEW, @stateOLD, @customer_num_referedNEW , @customer_num_referedOLD

	WHILE(@@FETCH_STATUS=0)
	BEGIN
		BEGIN TRY 
			BEGIN TRANSACTION
				IF(NOT EXISTS(SELECT 1 FROM state WHERE state = @stateNEW))
					THROW 50000, 'Estado no existente', 1

				IF(NOT EXISTS(SELECT 1 FROM customer WHERE customer_num = @customer_num_referedNEW))
					THROW 50000, 'Customer no existente', 1


				INSERT INTO customer_audit (fnameNEW, fnameOLD, lnameNEW, lnameOLD, stateNEW, stateOLD, customer_num_referedNEW,
											customer_num_referedOLD, update_date, update_user)
				VALUES(@fnameNEW, @fnameOLD, @lnameNEW, @lnameOLD, @stateNEW, @stateOLD,
						@customer_num_referedNEW, @customer_num_referedOLD, GETDATE(), CURRENT_USER)

			COMMIT TRANSACTION

		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
		END CATCH

		FETCH NEXT FROM auditCur INTO @fnameNEW, @fnameOLD, @lnameNEW, @lnameOLD,
			@stateNEW, @stateOLD, @customer_num_referedNEW , @customer_num_referedOLD
	END

	CLOSE auditCur
	DEALLOCATE auditCur
END

3)
'_____________________________________________________________________________________________________'
'ante un insert validar la existencia de claves primarias en las tablas relacionadas, fabricante 
unit_code y product_types.
si no existe el fabricante, devolver un mensaje de error y deshacer la transaccion para 
ese registro. en caso de no existir en units y product types, insertar el registro correspondiente 
y continuar la operacion '

CREATE TRIGGER validarProducts
ON productsV
INSTEAD OF INSERT
AS
BEGIN
	DECLARE @stock_num SMALLINT, @manu_code CHAR(3), @unit_price DECIMAL, @unit_code SMALLINT

	DECLARE prodCur CURSOR FOR
	SELECT stock_num, manu_code, unit_price, unit_code  FROM inserted

	OPEN prodCur
	FETCH prodCur INTO @stock_num, @manu_code, @unit_price, @unit_code 

	WHILE(@@FETCH_STATUS = 0)
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION
				IF(NOT EXISTS(SELECT 1 FROM manufact WHERE manu_code = @manu_code))
					THROW 50000, 'Fabricante inexistente', 1

				IF(NOT EXISTS(SELECT 1 FROM units WHERE unit_code = @unit_code))
				BEGIN
					INSERT INTO units (unit_code)
					VALUES (@unit_code)
				END
			
				IF(NOT EXISTS(SELECT 1 FROM product_types WHERE stock_num = @stock_num))
				BEGIN
					INSERT INTO product_types (stock_num)
					VALUES (@stock_num)
				END

				INSERT INTO products (stock_num, manu_code, unit_price, unit_code)
				VALUES(@stock_num, @manu_code, @unit_price, @unit_code)

			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
		END CATCH

		FETCH NEXT FROM prodCur INTO @stock_num, @manu_code, @unit_price, @unit_code 
	END

	CLOSE prodCur
	DEALLOCATE prodCur
END



-----------------------------------------------------------------------------------

SIMULACRO)

QUERY COMPLEJA)
SELECT m.manu_code, manu_name, COUNT(DISTINCT i.order_num) cantOrdenes, SUM(quantity * unit_price) montoTotal,
	(SELECT SUM(quantity * unit_price) / COUNT(DISTINCT manu_code) FROM items) promedioFabricantes
FROM manufact m JOIN items i ON(m.manu_code = i.manu_code)
GROUP BY m.manu_code, manu_name
HAVING SUM(quantity * unit_price) > (
	SELECT SUM(quantity * unit_price) / COUNT(DISTINCT manu_code) FROM items)
ORDER BY 4 DESC

SP)
CREATE PROCEDURE dbo.chequearProducto @stock_num SMALLINT, @manu_code CHAR(3), @unit_price DECIMAL, @unit_code SMALLINT, @description VARCHAR(15)
AS 
BEGIN
	IF( EXISTS(SELECT 1 FROM products WHERE stock_num = @stock_num AND manu_code = @manu_code))
	BEGIN
		UPDATE products
		SET unit_price = @unit_price, unit_code = @unit_code
		WHERE stock_num = @stock_num
		AND manu_code = @manu_code
	END
	ELSE
	BEGIN
		IF(NOT EXISTS(SELECT 1 FROM manufact WHERE manu_code = @manu_code))
			THROW 50000, 'Fabricante inexistente', 1

		IF(NOT EXISTS(SELECT 1 FROM units WHERE unit_code = @unit_code))
			THROW 50000, 'Codigo de unidad inexistente', 1

		IF(EXISTS(SELECT 1 FROM product_types WHERE stock_num = @stock_num))
		BEGIN
			UPDATE product_types
			SET description = @description
			WHERE stock_num = @stock_num
		END
		ELSE 
		BEGIN
			INSERT INTO product_types (stock_num, description)
			VALUES(@stock_num, @description)
		END

		INSERT INTO products (stock_num, manu_code, unit_price, unit_code)
		VALUES(@stock_num, @manu_code, @unit_price, @unit_code)

	END
END

TRIGGER)

CREATE TRIGGER actualizarStock
ON items
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	DECLARE @stock_num SMALLINT, @manu_code CHAR(3), @quantity SMALLINT

	DECLARE curIns CURSOR FOR
	SELECT stock_num, manu_code, quantity FROM inserted

	DECLARE curDel CURSOR FOR
	SELECT stock_num, manu_code, quantity FROM deleted

	OPEN curIns
	FETCH curIns INTO @stock_num, @manu_code, @quantity

	WHILE(@@FETCH_STATUS = 0)
	BEGIN

		IF(NOT EXISTS(SELECT 1 FROM CURRENT_STOCK WHERE stock_num = @stock_num AND manu_code = @manu_code))
		BEGIN
			INSERT INTO CURRENT_STOCK (stock_num, manu_code, created_date, updated_date)
			VALUES(@stock_num, @manu_code, GETDATE(), GETDATE())
		END

		UPDATE CURRENT_STOCK
		SET Current_Amount = Current_Amount - @quantity, updated_date = GETDATE()
		WHERE stock_num = @stock_num
		AND manu_code = @manu_code

		FETCH NEXT FROM curIns INTO @stock_num, @manu_code, @quantity
	END

	CLOSE curIns
	DEALLOCATE curIns

	OPEN curDel
	FETCH curDel INTO @stock_num, @manu_code, @quantity

	WHILE(@@FETCH_STATUS = 0)
	BEGIN
		
		IF(NOT EXISTS(SELECT 1 FROM CURRENT_STOCK WHERE stock_num = @stock_num AND manu_code = @manu_code))
		BEGIN
			INSERT INTO CURRENT_STOCK (stock_num, manu_code, created_date, updated_date)
			VALUES(@stock_num, @manu_code, GETDATE(), GETDATE())
		END

		UPDATE CURRENT_STOCK
		SET Current_Amount = Current_Amount + @quantity, updated_date = GETDATE()
		WHERE stock_num = @stock_num
		AND manu_code = @manu_code

		FETCH NEXT FROM curDel INTO @stock_num, @manu_code, @quantity
	END

	CLOSE curDel
	DEALLOCATE curDel

END





