1)
CREATE TRIGGER Products_historia_precios
ON products
AFTER UPDATE
AS
BEGIN
	INSERT INTO products_historia_precios
	(stock_num, manu_code, fechaHora, usuario, unit_price_old, unit_price_new, estado)
	SELECT
		i.stock_num,
		i.manu_code,
		GETDATE(),
		USER_NAME(),
		d.unit_price,
		i.unit_price
	FROM inserted i JOIN deleted d on (i.stock_num = d.stock_num and i.manu_code = d.manu_code) //MATCHEAS POR PK
	WHERE i.unit_price != d.unit_price;
END

2)

CREATE TRIGGER deleteField
ON products_historia_precios
INSTEAD OF DELETE
AS
BEGIN
	UPDATE products_historia_precios 
	set estado = 'I' 
	where stock_historia_id in (select stock_historia_id from deleted)
END

3)

CREATE TRIGGER check_horario
ON Products
AFTER INSERT
AS
BEGIN 
	IF(DATEPART(HOUR,GETDATE()) NOT BETWEEN(8,20))
	BEGIN
		ROLLBACK
		THROW_ERROR 50003, 'NO SE PUEDEN INGRESAR DATOS EN ESE HORARIO' , 2
	END
END
				
4)

CREATE TRIGGER borrado_cascade
ON orders
INSTEAD OF DELETE
AS
BEGIN
	DECLARE @oder_num smallint

	IF((SELECT COUNT(*) FROM deleted) > 1)
	BEGIN
		THROW_ERROR 5004, 'NO SE PUEDE BORRAR MAS DE UNA' , 2
	END
	ELSE
	BEGIN 
		SELECT @order_num = order_num FROM deleted;
		DELETE FROM items WHERE order_num = @order_num
		DELETE FROM orders WHERE order_num = @order_num
	END
END;

5)
































