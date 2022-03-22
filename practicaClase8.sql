FUNCIONES:
1)
CREATE FUNCTION dbo.DIASEM(@FECHA DATETIME, @STATE CHAR(2)) //El dbo. es por el esquema en el que esta en la BD
RETURNS VARCHAR(10) AS
BEGIN
    DECLARE @DIANUM INT
    DECLARE @DIASTR VARCHAR(10)
 
    SET @DIANUM = DATEPART(WEEKDAY, @FECHA) //WEEKDAY es del sistema
    IF (@STATE='CA')
    BEGIN
        SET @DIASTR = CASE  WHEN @DIANUM=1 THEN 'MONDAY'
                            WHEN @DIANUM=2 THEN 'TUESDAY'
                            WHEN @DIANUM=3 THEN 'WEDNESDAY'
                            WHEN @DIANUM=4 THEN 'THURSDAY'
                            WHEN @DIANUM=5 THEN 'FRIDAY'
                            WHEN @DIANUM=6 THEN 'SATURDAY'
                            WHEN @DIANUM=7 THEN 'SUNDAY'
                        END
    END
    ELSE
    BEGIN
        SET @DIASTR = CASE  WHEN @DIANUM=1 THEN 'LUNES'
                            WHEN @DIANUM=2 THEN 'MARTES'
                            WHEN @DIANUM=3 THEN 'MIERCOLES'
                            WHEN @DIANUM=4 THEN 'JUEVES'
                            WHEN @DIANUM=5 THEN 'VIERNES'
                            WHEN @DIANUM=6 THEN 'SABADO'
                            WHEN @DIANUM=7 THEN 'DOMINGO'
                        END
    END
    RETURN @DIASTR
END;
 
--
 
SELECT order_num, order_date, dbo.DIASEM(order_date, c.state) dia_semana
FROM orders o JOIN customer c ON (o.customer_num = c.customer_num)
WHERE paid_date IS NULL

2)


3)
CREATE FUNCTION dbo.fabricantesPipe(@STOCK_NUM INT)
RETURNS varchar(50) 
AS
BEGIN
	DECLARE @fabricante_name varchar(15)
	DECLARE @fab_pipeados varchar2(150)

	DECLARE fabricantes CURSOR FOR
	SELECT m.manu_code
	FROM manufact m JOIN products p ON (m.manu_code = p.manu_code)
    WHERE p.stock_num = @STOCK_NUM

	OPEN fabricantes
 	FETCH fabricantes INTO @fabricante_name

	WHILE(@@FETCH_STATUS == 0)
    BEGIN
		SET @fab_pipeados = @fab_pipeados + @fabricante_name + '|'
        FETCH fabricantes INTO @fabricante_name
 	END

	CLOSE fabricante
	DEALLOCATE fabricantes

	RETURN SUBSTRING(@fab_pipeados,0,LEN(@fab_pipeados))
END


SELECT stock_num, fabricantesPipe(stock_num) Fabricantes
FROM products
GROUP BY stock_num

STORED PROCEDURES:
1)
create table CustomerStatistics
(customer_num integer primary key,
ordersqty integer, maxdate
datetime, uniqueManufact integer)

CREATE PROCEDURE actualizaEstadisticas
@customer_numDES INT , @customer_numHAS INT
AS
BEGIN

    DECLARE CustomerCursor CURSOR FOR
    SELECT customer_num from customer WHERE customer_num
    BETWEEN @customer_numDES AND @customer_numHAS

    DECLARE @customer_num INT, @ordersqty INT, @maxdate DATETIME,
    @uniqueManufact INT;

    OPEN CustomerCursor;
    FETCH NEXT FROM CustomerCursor INTO @customer_num

    WHILE @@FETCH_STATUS = 0
    BEGIN
            SELECT @ordersqty=count(*) , @maxDate=max(order_date)
            FROM orders
            WHERE customer_num = @customer_num;

            SELECT @uniqueManufact=count(distinct stock_num)
            FROM items i, orders o
            WHERE o.customer_num = @customer_num
            AND o.order_num = i.order_num;

            IF NOT EXISTS( SELECT 1 FROM CustomerStatistics WHERE customer_num = @customer_num)
                BEGIN
                    insert into customerStatistics
                    values (@customer_num,@ordersQty, @maxDate,@uniqueManufact);
                END
            ELSE
                BEGIN
                    update customerStatistics
                    SET ordersQty=@ordersQty,maxDate=@maxDate,
                    uniqueManufact= @uniqueManufact
                    WHERE customer_num = @customer_num;
                END
            FETCH NEXT FROM CustomerCursor INTO @customer_num
    END;
CLOSE CustomerCursor;
DEALLOCATE CustomerCursor;
END

SELECT * FROM CustomerStatistics
execute actualizaEstadisticas 101,110


3)
CREATE TABLE [dbo].[listaPrecioMayor](
[stock_num] [smallint] NOT NULL,
[manu_code] [char](3) NOT NULL,
[unit_price] [decimal](6, 2) NULL,
[unit_code] smallint
);

CREATE TABLE [dbo].[listaPrecioMenor](
[stock_num] [smallint] NOT NULL,
[manu_code] [char](3) NOT NULL,
[unit_price] [decimal](6, 2) NULL,
[unit_code] smallint
);

ALTER TABLE products ADD status char(1);

ALTER PROCEDURE actualizaPrecios @manu_codeDES CHAR(3), @manu_codeHAS CHAR(3), @porcActualizacion decimal (5,3)
AS
BEGIN
    DECLARE @stock_num INT, @manu_code CHAR(3), @unit_price DECIMAL(6,2),
    @unit_code smallint, @manu_codeAux CHAR(3)

    DECLARE StockCursor CURSOR FOR
    SELECT p.stock_num, manu_code, unit_price, unit_code
    from products p
    WHERE manu_code BETWEEN @manu_codeDES AND @manu_codeHAS
    ORDER BY manu_code, p.stock_num

    OPEN StockCursor;
    FETCH NEXT FROM StockCursor INTO @stock_num, @manu_code,
    @unit_price,@unit_code

    set @manu_codeAux = @manu_code

    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
        BEGIN TRANSACTION

        IF ( SELECT sum(quantity) FROM items
        WHERE manu_code = @manu_code AND stock_num=@stock_num) >= 500
        BEGIN
            insert into listaPrecioMayor
            values (@stock_num, @manu_code,
            @unit_price * (1 + @porcActualizacion * 0.80), @unit_code);
        END
        ELSE
        BEGIN
            insert into listaPrecioMenor
            values (@stock_num,@manu_code,
            @unit_price * (1 + @porcActualizacion), @unit_code);
            
            UPDATE products SET status= 'A'
            WHERE manu_code= @manu_code AND stock_num= @stock_num;
        END

        FETCH NEXT FROM StockCursor INTO @stock_num, @manu_code, @unit_price, @unit_code

        IF @manu_code != @manu_codeAux
        BEGIN
            COMMIT TRANSACTION
            SET @manu_codeAux = @manu_code
        END
        END TRY
        BEGIN CATCH
            ROLLBACK TRANSACTION
            DECLARE @errorDescripcion VARCHAR(100)
            SELECT @errorDescripcion = 'Error en Fabricante '+@manu_code
            RAISERROR(@errorDescripcion,14,1)
        END CATCH
    END;
    CLOSE StockCursor
    DEALLOCATE StockCursor
END;








