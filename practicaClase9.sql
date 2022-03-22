1)
CREATE TABLE dbo.CustomerStatstics (
customer_num INT,
ordersQty INT,
maxDate DATE,
productsQty INT,
PRIMARY KEY (customer_num))
 
CREATE PROCEDURE CustomerStatisticsUpdate @FECHA_DES date
AS
BEGIN
	DECLARE @customer_num INT, @ordersqty INT, @maxdate DATETIME,
    @productsQty INT;
 
	DECLARE CustomerCursor CURSOR FOR
    SELECT customer_num FROM customer 
 
	OPEN CustomerCursor
	FETCH CustomerCursor INTO @customer_num
 
	WHILE(@@FETCH_STATUS = 0)
	BEGIN
 
		SELECT @ordersqty=count(*) , @maxDate=max(order_date)
		FROM orders
		WHERE customer_num = @customer_num
        AND order_date > @FECHA_DES;

		SELECT @productsQty=count(*)
		FROM (SELECT DISTINCT i.stock_num, i.manu_code 
                FROM orders o JOIN items i ON i.order_num = o.order_num WHERE o.customer_num = @customer_num);
 
		IF NOT EXISTS( SELECT 1 FROM CustomerStatistics
		WHERE customer_num = @customer_num)
		BEGIN
			insert into CustomerStatistics
			values (@customer_num,@ordersQty, @maxDate,@productsQty);
		END
		ELSE
		BEGIN
			update CustomerStatistics
			SET ordersQty=@ordersQty,maxDate=@maxDate,
			productsQty= @productsQty
			WHERE customer_num = @customer_num;
		END
		FETCH NEXT FROM CustomerCursor INTO @customer_num
	END;
	CLOSE CustomerCursor;
	DEALLOCATE CustomerCursor;
END

2) 
CREATE TABLE dbo.informeStock (
fechaInforme DATE,
stock_num SMALLINT,
manu_code CHAR(3),
cantOrdenes INT,
UltCompra DATE,
cantClientes INT,
totalVentas DECIMAL,
PRIMARY KEY (fechaInforme, stock_num, manu_code))

CREATE PROCEDURE generarInformeGerencial @FECHA_INFORME DATE
AS
BEGIN
	IF(EXISTS(SELECT 1 FROM informeStock WHERE fechaInforme = @FECHA_INFORME) )
		THROW 50000, 'Mes ya procesado', 1

	DECLARE @stock_num SMALLINT, @manu_code CHAR(3), @cantOrdenes INT,
	@ultCompra DATE, @cantClientes INT, @totalVentas DECIMAL

	DECLARE ProdcutsCursor CURSOR FOR
	SELECT stock_num, manu_code FROM products

	OPEN ProdcutsCursor
	FETCH ProdcutsCursor INTO @stock_num, @manu_code
 
	WHILE(@@FETCH_STATUS = 0)
	BEGIN

		/*SELECT @cantOrdenes = COUNT(*), 
		FROM (SELECT DISTINCT o.order_num
			FROM orders o JOIN items i ON(o.order_num = i.order_num)
			WHERE i.stock_num = @stock_num)

		SELECT @ultCompra = max(order_date)
		FROM orders o JOIN items i ON(o.order_num = i.order_num)
		WHERE i.stock_num = @stock_num;--*/

		SELECT @cantClientes = COUNT(DISTINCT c.customer_num), @ultCompra = max(o.order_date),
		@cantOrdenes = COUNT(DISTINCT o.order_num), @totalVentas = SUM(unit_price * quantity)
		FROM orders o RIGHT JOIN customer c ON(c.customer_num = o.customer_num)
						JOIN items i ON(i.order_num = o.order_num)
		WHERE i.stock_num = @stock_num
		AND i.manu_code = @manu_code;

		INSERT INTO informeStock
		VALUES (@FECHA_INFORME, @stock_num, @manu_code, @cantOrdenes, @ultCompra, @cantClientes, @totalVentas)

		FETCH NEXT FROM ProdcutsCursor INTO @stock_num, @manu_code

	END;

	CLOSE ProductsCursor
	DEALLOCATE ProductsCursor

END

3)
CREATE TABLE dbo.informeVentas (
fechaInforme DATE,
stateCode CHAR(2),
customer_num SMALLINT,
cantOrdenes INT,
primerVenta DATE,
cantProductos INT,
totalVentas DECIMAL,
PRIMARY KEY (fechaInforme, stateCode, customer_num))

CREATE PROCEDURE generarInformeVentas @FECHA_INFORME DATE, @STATE_CODE CHAR(2)
AS
BEGIN
	IF(EXISTS (SELECT 1 FROM informeVentas 
				WHERE fechaInforme = @FECHA_INFORME AND stateCode = @STATE_CODE))
			THROW 5000, 'Informe para fehca y mes ya procesado', 1
	
	DECLARE @customer_num SMALLINT, @cantOrdenes INT, @ultVenta DATE,
	@primerVenta DATE, @cantProductos INT, @totalVentas DECIMAL

	DECLARE Customers CURSOR FOR
	SELECT customer_num FROM customer WHERE state = @STATE_CODE

	OPEN Customers
	FETCH Customers INTO @customer_num

	WHILE(@@FETCH_STATUS = 0)
	BEGIN

	SELECT @cantProductos = COUNT(DISTINCT i.stock_num), @cantOrdenes = COUNT(DISTINCT o.order_num),
		@primerVenta = MIN(o.order_date), @totalVentas = SUM(quantity * unit_price)
    FROM orders o JOIN items i ON(o.order_num = i.order_num)
    WHERE o.customer_num = @customer_num
	GROUP BY o.customer_num

	INSERT INTO informeVentas (fechaInforme, stateCode,customer_num, cantOrdenes, primerVenta, cantProductos, totalVentas)
	VALUES(@FECHA_INFORME, @STATE_CODE, @customer_num, @cantOrdenes, @primerVenta, @cantProductos, @totalVentas)

	FETCH Customers INTO @customer_num
	END

	CLOSE Customers
	DEALLOCATE Customers

END

   
declare @fecha datetime
set @fecha = getDate()
EXEC generarInformeVentas @fecha, 'CA'

select * from informeVENTAS


