Query)

CREATE VIEW provinciasMasCotizadas (nombreProvincia, cantClientes, totalComprado, nomYApe)
AS
SELECT TOP 3 s.sname, COUNT(DISTINCT c.customer_num), SUM(i.quantity * i.unit_price),
      (SELECT TOP 1 c1.fname + ', ' + c1.lname 
        FROM customer c1 
		JOIN orders o1 ON (c1.customer_num = o1.customer_num) 
        JOIN items i1 ON (o1.order_num = i1.order_num) 
        WHERE c1.state = s.state 
        GROUP BY c1.fname, c1.lname, c1.state
        ORDER BY SUM(i1.quantity * i1.unit_price) DESC) 
FROM state s JOIN customer c ON (s.state = c.state)
			 JOIN orders o ON (c.customer_num = o.customer_num)
			 JOIN items i ON (o.order_num = i.order_num)
GROUP BY s.sname, s.state
ORDER BY 3 DESC


Stored Proedure)

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


Trigger)

CREATE TRIGGER fabricantesVCheck
ON fabricantesV
INSTEAD OF INSERT, DELETE
AS
BEGIN
	DECLARE @manu_code CHAR(3), @manu_name VARCHAR(15), @lead_time SMALLINT, @state CHAR(2), @sname VARCHAR(15)

	--COALESCE solo en el campo del manu_code ya que en el chequeo del DELETED solo necesito ese campo
	DECLARE manuCur CURSOR FOR
	SELECT COALESCE(i.manu_code, d.manu_code), i.manu_name, i.lead_time, i.state, i.sname
	FROM inserted i FULL JOIN deleted d ON(i.manu_code = d.manu_code)

	OPEN manuCur
	FETCH manuCur INTO @manu_code, @manu_name, @lead_time, @state, @sname

	WHILE(@@FETCH_STATUS = 0)
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION
				IF( EXISTS( SELECT 1 FROM inserted WHERE manu_code = @manu_code))
				BEGIN

					IF(NOT EXISTS( SELECT 1 FROM state WHERE state = @state))
					BEGIN
						INSERT INTO state (state, sname)
						VALUES(@state, @sname)
					END

					IF( @lead_time > 20)
						THROW 50000, 'Fabricante no aprobado por Lento', 1

					INSERT INTO manufact (manu_code, manu_name, lead_time, state)
					VALUES (@manu_code, @manu_name, @lead_time, @state)

				END
				ELSE  --Delete
				BEGIN
					
					IF( EXISTS (SELECT 1 FROM products WHERE manu_code = @manu_code))
						THROW 50000, 'No se puede borrar pq tiene PRODUCTOS', 1

					DELETE FROM manufact
					WHERE manu_code = @manu_code

				END
			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
			DECLARE @error VARCHAR(255)
			SET @error = ERROR_MESSAGE()
			RAISERROR(@error, 16, 1)
		END CATCH

		FETCH NEXT FROM manuCur INTO @manu_code, @manu_name, @lead_time, @state, @sname
	END

	CLOSE manuCur
	DEALLOCATE manuCur

END

