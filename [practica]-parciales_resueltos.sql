'------------------------------------TEORIA ------------------------------------------------'
------------------------------------------------------------------------------------
------------------------------------------------------------------------
'DELETE': DELETE FROM stores7new_parciales.dbo.orders 
          WHERE order_num = 123
obs: esto elimina todos los campos de la fila donde se cumpla eso 


'SUBQUERYS': se pueden usar como columna(si y solo si , retornas un solo campo 'SELECT TOP 1')
o como "conjunto de valores"

ej : productos que no estuviero nunca en una orden de comprado
SELECT * from products p
WHERE p.id NOT IN (SELECT product_id FROM orders)


'JOIN AUTO-REFERENCIADO': el customer_num_referedby nos inidica quien fue el cliente que nos refirio

ejemplo
SELECT c2.lname, c2.fname, c1.lname, c1.fname 
FROM customer c1 JOIN customer c2
ON c1.customer_num_referedby = c2.customer_num

------------------------------------------------------------------------------------
'INNER JOIN': cuando hacemos un inner join, vamos a necesitar dos tablas que se van a cruzaer
de cierta forma, que van a presentar una columna en comun, que es el punto de comparacion entre
ambas tablas.
El inner join lo que hace es comparar estas dos columnas y encontrar coincidencias.
Si no se encuentra una coincidencia, entonces esa fila no se muestra.
--ejemplo: se puede escribir como JOIN normalmente tambien

SELECT * FROM empleados e 
JOIN departamentos d
ON e.departamentoID = d.id

------------------------------------------------------------------------------------

'LEFT JOIN': se muestran todos los elementos de la primera tabla, en este caso se parte
de todos los elementos que tiene la tabla A y se comparan con la tabla B, es decir, siempre
aparecen todos los datos de la tabla A como datos, pero no aparecen los de la tabla B
si no hacen match.
la tabla departamentos en el ejemplo seria la dominante

--ejemplo:
SELECT * FROM empleados e
LEFT JOIN departamentos d
ON e.departamenID = d.id

de todas maneras aca aparecen todos los empleados, tengan un departamento asignado o no
pero si departamento en la tabla B (departamentos) no esta asociado a ningun empleado, esa fila
no aparece.

y bueno el 'RIGHT JOIN' es lo mismo pero al reves.
despues el 'FULL JOIN' hace que ambas tablas sean dominantes
------------------------------------------------------------------------------------
'UNION': une dos tablas en una, teniendo las mismas columnas


------------------------------------------------------------------------------------
'STORED PROCEDURES': procedimientos almacenados
es un method como en un lenguaje, puede recibir parametros como no
 ej:
CREATE procedure un_procedure @nombre nvarchar(20), @telefono int
as
begin
select * from unatabla where nombre = @nombre and telefono = @telefono
end

para ejecutarlos, usas:
exec un_procedure "guido", 2325685061


CREATE TABLE ventasXmes (
	[anioMes] varchar(6),
	[stock_num] smallint,
	[manu_code] char(3),
	[cantidad] int,
	[monto] decimal(10,2)
)


------------------------------------------------------------------------------------
'TRIGGER: Disparador' -> se dispara cuando se genera una accion en otra tabla

create trigger trigger_persona_insert -- el insert hace referencia a que se dispara cuando se hace un insert
on persona --nombre de la tabla a actuar
'for | after | instead of insert | update | delete -- tenes que escoger uno de cada grupo'
for insert 
as
print 'hubo un cambio en la tabla persona'

obs: el for insert es para que se dispare antes de hacer el insert

•

create trigger trigger_persona_insert 
on persona 
'for | after | instead of insert | update | delete -- tenes que escoger uno de cada grupo'
after insert 
as
print 'hubo un cambio en la tabla persona'

obs: el aftewwr insert es para que se dispare despues de hacer el insert
•

create trigger trigger_persona_insert 
on persona 
'for | after | instead of insert | update | delete -- tenes que escoger uno de cada grupo'
instead of insert 
as
print 'hubo un cambio en la tabla persona'

obs: el instead of insert es para que NO SE HAGA el insert (o la operaicon que sea)
	 y se haga lo que esta dentro del trigger


------------------------------------------------------------------------
'CURSORES': es una estructura que se carga en la ram con el resultado de una consulta
permitiendonos recorrer fila x fila de esa estructura, dejandonos leer la informacion 
y eventualmente modificar dicho conjunto de datos. para modificar un cursor de manera facil
podemos hacer lo siguiente


--declarando el cursor
Declare UnCursor Cursor
	for select * from dbo.customer

--abrimos el cursor y navegamos
open UnCursor 
FETCH next from Cursor1 --fetch es usado para navegar linea x linea
						-- cada vez que ejecutas esto te devuelve una fila
close UnCursor --cerras el cursor, pero sigue en memoria ram
deallocate UnCursor -- lo sacas de la memoria ram 


'ejemplo':
declare @codigo varchar(5), -- declaro las variables para guardar cuando barra con el cursor
@compania varchar(200),
@contacto varchar(150),
@pais varchar(100)

DECLARE un_cursor CURSOR FOR
	select customerid, compannyname, contactname, country
	from customers

OPEN un_cursor
FETCH un_cursor INTO @codigo, @compania, @contacto, @pais
WHILE(@@FETCH_STATUS = 0) -- esta funcion devuelve 0 si se ejecuto correctamente, -1 si no se ejecuto correctamente, -2 si hubo un error en la fila recuperada
	BEGIN                 -- por eso es mejor correr el fetch antes del while
	print @codigo + ' ' + @compania + ' '+ @contacto + ' ' + @pais -- un ejemplo de que hacer
	fetch un_cursor into @codigo, @compania, @contacto, @pais
END
CLOSE un_cursor
DEALLOCATE un_cursor


'ejemplo agregar parametros':
declare otro_cursor cursor GLOBAL -- o tambien podes usar LOCAL: q funciona dentro del procedimiento o trigger que lo creo
								  --aunque global, local y todos esos no los vamos a usar
obs: si usas PRIOR en vez de NEXT podes ir para atras, pero claro tenes que avanzar antes


'ejemplo actualizar datos (update)':
declare otro_cursor cursor GLOBAL
	for select customerid, companyname, contactname, country
	FROM customers FOR UPDATE -- este for update hace que puedas actualizar datos
open otro_cursor
fetch otro_cursor into @codigo, @compania, @contacto...
while (@FETCH_STATUS =0)
begin
	update customers
		set companyname = @compania + 'modificado'
		where current of un-cursor


---------------------------------------------------------------------------------------------------
'VIEWS': super resumido, es un honeypot para un query

SQL Server provides a better way to save this query in the database catalog through a
view.

A view is a named query stored in the database catalog that allows you to refer to it 
later.

So the query above can be stored as a view using the CREATE VIEW statement as follows:

CREATE VIEW sales.product_info
AS
SELECT
    product_name, 
    brand_name, 
    list_price
FROM
    production.products p
INNER JOIN production.brands b 
        ON b.brand_id = p.brand_id;

Later, you can reference to the view in the SELECT statement like a table as follows:

SELECT * FROM sales.product_info;




---------------------------------------------------------------------------------------------------
'TRANSACTIONS': conjunto de sentencias sql q se ejecutan o no se ejecutan.

'ejemplo':

BEGIN TRANSACTION
INSERT INTO unatabla values (...)
set @importe = calcularImporte(@factura)

IF @importe > 0 THEN
	insert into facturas(facturas,imp_total) values (@factura, @importe)
	COMMIT TRANSACTION
else
	PRINT 'error: importe no valido'
	ROLLBACK TRANSACTION --deshace todo lo q se hizo arriba y arranca desde begin transaction
end


obs:
begin transaction
insert 12 facturasi
insert 12312 afsd -- si esta falla , automaticamente el motor de db hace un rollback
insert ...

commit transaction


---------------------------------------------------------------------------------------------------------
'------------------------------------PARCIALES RESUELTOS ------------------------------------------------'
---------------------------------------------------------------------------------------------------------
'___________________________________________STORED_PROCEDURES_________________________________________'

'Crear un procedimiento actualizaPrecios que reciba como parámetro una fecha a partir de 
la cual procesar los registros de una tabla Novedades que contiene los nuevos precios de 
Productos con la siguiente estructura/información.

FechaAlta, Manu_code, Stock_num, descTipoProducto, Unit_price, Unit_code

Por cada fila de la tabla Novedades 
     Si no existe el Fabricante, devolver un error de Fabricante inexistente y descartar la     
      novedad.

     Si no existe el stock_num (pero existe el Manu_code) darlo de alta en la tabla     
        Product_types e insertar el nuevo par (stock_num, manu_code) en la tabla Products.

     Si existe el Producto actualizar su precio 
     Si no existe, Insertarlo en la tabla de productos.

Nota: Manejar una transaccion por novedad y errores no contemplados.'
#obs procedure con cursor
CREATE PROCEDURE ActualizaPrecios @fechaProceso date as
BEGIN
    -- declaro variables y cursor
    DECLARE @stock_num smallint,
            @Manu_code char(3),
            @descTipoProducto varchar(15),
            @unit_price decimal(6,2),
            @unit_code  smallint
                --
    DECLARE cNovedades CURSOR FOR
	        SELECT stock_num, Manu_code, descTipoProducto, unit_price
            FROM ##Novedades
          	WHERE fechaAlta > @fechaProceso;
    --
    OPEN  cNovedades;
    fetch NEXT from cNovedades into @stock_num, @Manu_code, @descTipoProducto,
                                    @unit_price, @unit_code;
    WHILE @@FETCH_STATUS = 0
    Begin
    Begin try
        Begin TRAN
        if not exists (select 1 from manufact where manu_code = @Manu_code)
	      throw 50000, 'Fabricante erroneo', 2

        if not exists (select 1 from product_types where stock_num = @stock_num)
            insert into product_types values (@stock_num, @descTipoProducto);
        
        if not exists (select 1 from products where stock_num = @stock_num and
		                                       manu_code = @Manu_code)
		insert into products values (@stock_num, @Manu_code, @unit_price, @unit_code);
        else 
		update products set unit_price = @unit_price
		 where stock_num = @stock_num and manu_code = @Manu_code;
        
        commit;
    end try
    begin catch
        rollback
    end catch
    fetch NEXT from cNovedades into @stock_num, @Manu_code, @descTipoProducto,
                                    @unit_price, @unit_code;
    End
    --
    close cNovedades
    Deallocate cNovedades
    --
end;

'_____________________________________________________________________________________________________'
'crear un stored procedure que reciba una fecha como parametro.
este debera guardar en la tabla ventasXmes el monto total y la cantidad total de 
productos vendidos para el año y mes (yyyymm) de la fecha ingresada con la siguiente 
particularidad':
'existen 3 tipos de unidades de productos y las cantidades deberan ser "ajustadas" segun 
su tipo':
'1 unid -> queda igual'
'2 par -> multiplicar por 2'
'3 doc -> multiplicar por 12'
'el procedimiento debe manejar todo el proceso en una transaccion y dshacer todo en caso 
de error'


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

'_____________________________________________________________________________________________________'
'desarrolar un stored procedure que maneje la insercion o modificacion de un producto determinado
si eixste el producto en la tabla products, actualizar los at ributos que no pertenecen a la clave primaria
si no existe el producto en products, insertarfila en tabla previamente validad lo siguiente:
  - existencia de manu_code en tabla MANUFACT - informado error por fabricante inexistente
  - existencia de stock-num en tabla product_types - si no existe insertar registro en la tabla 
    stock_num , si existe realizar update del atributo "description" 
  - existencia del atibuto unit_code en la tabla units- informando por error codigo unidad inexistente'

CREATE PROCEDURE Manejo_Insercion @stock_num int,
                                  @manu_code varchar(3), 
								  @unit_price float,
								  @unit_code int,
								  @description varchar(50)																															
AS BEGIN	

	IF exists (select 1 from stores7new_parciales.dbo.products p
				where p.stock_num = @stock_num
				and p.manu_code = @manu_code) -- ojo, hay varios st ocks pero con dif manu code
	BEGIN
		UPDATE products 
		SET unit_code =@unit_code,
		    unit_price = @unit_code
		WHERE products.stock_num = @stock_num AND products.manu_code = @manu_code
	END
	ELSE
	BEGIN
		IF not exists(select 1 from stores7new_parciales.dbo.manufact m
					  where m.manu_code = @manu_code)
		THROW 50001, 'Error por fabricante inexistente',1;

		IF not exists(select 1 from stores7new_parciales.dbo.product_types pt
					  where pt.stock_num= @stock_num)
			INSERT INTO stores7new_parciales.dbo.product_types(stock_num, description)
			VALUES (@stock_num, @description)
		ELSE
			UPDATE product_types 
			SET description = @description
			WHERE product_types.stock_num = @stock_num

		IF not exists(select 1 from stores7new_parciales.dbo.units u
					  where u.unit_code = @unit_code)
		THROW 50003, 'Codigo unidad inexistente',1;

		INSERT INTO products (stock_num , manu_code, unit_code, unit_price)
		VALUES (@stock_num, @manu_code, @unit_code, @unit_price)
	END
END



'_____________________________________________________________________________________________________'
'crear un procedure actualiza cliente el cual tomara de una tabla "clientesAltaOnline" 
previamente cargada por otro proceso, la siguiente info:'
'customer_num, lname, fnmae, company, addres1, city, state' 
'por cada fila de la tabla clientesAltaOnline se debera evaluar '
• 'si el cliente existe en customer, modificar dicho cliente en la tabla custoemr con los 
datos leidos de la tabla clientesAltaOnline'
• 'si el cliente no existe en customer, se debera insertar el cliente en al tabla custoemr 
con los datos leidos de la tabla clientesAltaOnline'
'el procedimiento debera almacenar por cada operacion realizada una fila en al tabla auditoria 
con los siguientes atributos':
'idauditoria(identity), operacion(insert o modificado), custome_num, lname, fname, addres, city, state'
'manejar una transaccion por cada cliente'

CREATE PROCEDURE actualizaCiente 
AS BEGIN
    -- declaro variables y cursor
    DECLARE @customer_num smallint,
            @lname varchar(15),
            @fname varchar(15),
            @company varchar(15),
            @addres varchar(15),
			@city varchar(15),
			@state char(2),
			@operacion varchar(9)
                --
    DECLARE cur CURSOR FOR
	        SELECT customer_num, lname, fname, company, addres, city, state
            FROM ##clientesAltaOnline
          	
    OPEN cur;
    FETCH NEXT from cur into @customer_num, @lname, @fnmame, @company, @addres, @city
    						 @state
                             
    WHILE @@FETCH_STATUS = 0
    BEGIN
    	BEGIN TRY
        	BEGIN TRANSACTION
        	
        	IF EXISTS(select 1 from customer c
        		      where c.customer_num = @customer_num)
        	BEGIN
        		set @operacion = 'modificado'
	        	UPDATE customer 
	        	SET lname = @lname, fname = @fname, company = @company, addres = @addres....
	        	WHERE customer_num = @customer_num
	        END ELSE 
	        BEGIN
	        	set @operacion = 'insertado'
	        	INSERT INTO customer(customer_num, lname, fname, company, addres, city, state)
	        	VALUES(@customer_num, @lname, @fname, @company, @addres, @city, @state)
	        END

	        INSERT INTO auditoria(id, operacion, customer_num, lname, fname, addres1, city, state)
	        VALUES(id, @operacion, @customer_num, @lname, @fname, @addres1, @city1, @state)
        
        	commit;

    	END TRY

    	BEGIN CATCH
       		rollback
    	END CATCH

    FETCH NEXT from cur into @customer_num, @lname, @fnmame, @company, 
    						 @addres, @city, @state
    						 
    END
    --
    CLOSE cur
    DEALLOCATE cur
    --
end;

'_____________________________________________________________________________________________________'

'Crear un procedimiento procBorraOC que reciba un número de orden de compra por parámetro y realice la
eliminación de la misma y sus ítems.
Deberá manejar una transacción y deberá manejar excepciones ante algún error que ocurra.
El procedimiento deberá guardar en una tabla de auditoria auditOC los siguientes datos order_num,
order_date, customer_num, cantidad_items, total_orden (SUM(total_price)), cant_productos_comprados
(SUM(quantity)), cantidad de ítems.
Ante un error deberá almacenar en una tablas erroresOC, order_num, order_date, customer_num,
error_ocurrido VARCHAR(50)'


CREATE PROCEDURE procBorraOC @orden_compra_num INT
AS
BEGIN
  BEGIN TRY
    BEGIN TRANSACTION 
    INSERT INTO auditOC(order_num, order_date, customer_num, cant_items, total_orden,
                cant_productos_comprados, cantidad_de_items)
    VALUES (
        (SELECT o.order_num, order_date, customer_num, COUNT(i.item_num),
                SUM(i.unit_price * i.quantity), SUM(i.quantity)
         FROM orders o
         JOIN items i ON o.order_num = i.order_num
         WHERE o.order_num = @orden_compra_num
         GROUP BY o.order_num, order_date, customer_num)
        )

    DELETE FROM orders 
    WHERE order_num = @orden_compra_num

    DELETE FROM items 
    WHERE order_num = @orden_compra_num
    commit;
  END try

  begin catch
    rollback;
  INSERT INTO eroresOC(order_num, order_date, customer_num, error_ocurrido)
    VALUES (
        (
        SELECT o.order_num, order_date, customer_num, ERROR_MESSAGE() as ErrorMessage
        FROM orders o
        JOIN items i ON o.order_num = i.order_num
        WHERE o.order_num = @orden_compra_num
        )
         )
  end catch
END



'_____________________________________________________________________________________________________'
'---------------------------------------TRIGGERS---'
'--------'



CREATE TRIGGER itemsTR ON items
AFTER INSERT, UPDATE, DELETE
AS BEGIN
--
   DECLARE @stock_num smallint, @manu_code char(3), @quantityI smallint, @quantityD smallint
   DECLARE Actualizados CURSOR FOR
                        SELECT COALESCE(i.stock_num, d.stock_num) stock_num,
                        COALESCE(i.manu_code, d.manu_code) manu_code,
                        i.quantity, d.quantity
                        FROM inserted i 
                        FULL JOIN deleted d ON (i.order_num = d.order_num AND i.item_num = d.item_num)
   OPEN Actualizados
   FETCH Actualizados
   INTO @stock_num, @manu_code, @quantityI, @quantityD

   WHILE @@FETCH_STATUS=0
   BEGIN
      IF NOT EXISTS (SELECT 1 FROM CURRENT_STOCK p WHERE p.manu_code = @manu_code AND p.stock_num = @stock_num)
      INSERT INTO CURRENT_STOCK (stock_num, manu_code, Current_Amount, created_date, updated_date)
      VALUES (@stock_num, @manu_code, 0, GETDATE(), GETDATE());
   --
      UPDATE CURRENT_STOCK
      SET Current_Amount = Current_Amount - COALESCE(@quantityI, 0) + COALESCE(@quantityD, 0),
       updated_date = getdate()
      WHERE stock_num = @stock_num AND manu_code = @manu_code;

      FETCH Actualizados
      INTO @stock_num, @manu_code, @quantityI, @quantityD;
   END
   CLOSE Actualizados
   DEALLOCATE Actualizados
END

'_____________________________________________________________________________________________________'

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

CREATE TRIGGER tene_cuidado ON customer
AFTER DELETE, UPDATE as
BEGIN
  DECLARE  @customer_num int, 
           @apeynomNew varchar(40),
		   @stateNew char(2),
           @customer_num_refered_byNew int,
           @apeynomOld varchar(40),
		   @stateOld char(2),
           @customer_num_refered_byOld int

  DECLARE auditCur CURSOR FOR --creo el cursor y como que seteo que hacer con los datos
  SELECT d.customer_num,	  -- por ejemplo, concatenar los strings
          i.lname + '' + i.fname, i.state, i.customer_num_referedby,
          d.lname + '' + d.fname, d.state, d.customer_num_referedby
   FROM deleted d  		--CLARO, capaz se deleteo algo y no se remplazo con nada en la inserted, por eso el left join
   LEFT JOIN inserted i -- hago el left join porque quiero todos lso valores de la tabla deleted
   ON i.customer_num = d.customer_num;
  WHERE i.fname != d.fname
	OR i.lname != d.lname
	OR i.state != d.state
	OR i.customer_num_referedBy != d.customer_num_referedBy

  OPEN auditCur
  FETCH NEXT FROM auditCur --entonces, hago el primer fetch para traer datos
  INTO @customer_num,      --y meterlos ya transformados a la tabla
       @apeynomNew, @stateNew, @customer_num_refered_byNew,
       @apeynomOld, @stateOld, @customer_num_refered_byOld;

  WHILE (@@FETCH_STATUS = 0) --recorro todas las filas
  BEGIN -- arranca el while
    BEGIN TRY --intenta ejecutar esto
      BEGIN TRANSACTION --
		IF not exists(select 1 from inserted) -- will return a columns of 1's -- esto significa: si no se inserto nada
		BEGIN-- begin del if				  -- for every row in the table
			insert into customer_audit(customer_num, update_Date, apeynom_OLD,
					    state_Old, customer_num_referedby_OLD, update_user)
			values (@customer_num, getDate(), @apeynomOld, @stateOld,
				    @customer_num_refered_byOld, SYSTEM_USER) -- retrona el usuario
      	END
      ELSE -- si se inserto algo
      	BEGIN --begin del else
        	if not exists(select 1 from customer
                      where customer_num = @customer_num_refered_byNew) -- esto es si quiero insertar un customer num que no existe
          THROW 50001, 'Referente inexistente', 1;
        if not exists (select 1 from state where state = @stateNEW)
          THROW 50002, 'Estado inexistente', 1;
          
        INSERT INTO customer_audit(customer_num, update_Date,
                                    apeynom_NEW, state_NEW, customer_num_referedby_NEW,
                                    apeynom_OLD, state_Old, customer_num_referedby_OLD,         
                                    update_user)
        values (@customer_num, getDate(),
                @apeynomNew, @stateNew, @customer_num_refered_byNew,
                @apeynomOld, @stateOld, @customer_num_refered_byOld, SYSTEM_USER)
      END
      COMMIT transaction
    END TRY
    
    BEGIN catch
      ROLLBACK transaction
    END catch
      
    FETCH NEXT FROM auditCur
    into @customer_num,
         @apeynomNew, @stateNew, @customer_num_refered_byNew,
         @apeynomOld, @stateOld, @customer_num_refered_byOld;
  END
  
  close auditCur
  deallocate auditCur
END;

'_____________________________________________________________________________________________________'
'ante un insert validar la existencia de claves primarias en las tablas relacionadas, fabricante 
unit_code y product_types.
si no existe el fabricante, devolver un mensaje de er ror y deshacer la transaccion para 
ese registro. en caso de no existir en units y product types, insertar el registro correspondiente 
y continuar la operacion '

CREATE TRIGGER on productosV
INSTEAD OF INSERT 
AS BEGIN
	 DECLARE @stock_num int, 
           @description varchar(40),
		       @manu_code varchar(40),
           @unit_price float,
		       @unit_code int,
		       @unit_descr varchar(40)
           
	DECLARE productosCur CURSOR FOR
	SELECT stock_num, description, manu_code, unit_price, unit_code 
	       unit_descr
	FROM inserted

	OPEN productosCur
	FETCH NEXT FROM productosCur
	INTO @stock_num, @description, @manu_code, @unit_price, @unit_code
	     @unit_descr;

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		IF not exists(select 1 from manufact m 
						where m.manu_code = @manu_code)
		BEGIN
			THROW 50001, 'No existe el fabricante', 1;
		END ELSE
		BEGIN
			IF (not exists(select 1 from units m where m.unit_code = @unit_code)) 
			BEGIN	
				INSERT INTO units (unit_code, unit_descr)
				VALUES (@unit_code, @unit_descr)
			END

			IF (not exists(select 1 from prodcut_types tp
						   where tp.stock_ num = @stock_nume)
			BEGIN	
				INSERT INTO product_types
				VALUES (...product types)
			END
			
		END

	FETCH NEXT FROM productosCur
	INTO @stock_num, @description, @manu_code, @unit_price, @unit_code
	     @unit_descr;

	END

	CLOSE productosCur
	dealloacte productosCur
END


'_____________________________________________________________________________________________________'
'--------------------------------------QUERYS COMPLEJOS x VISTAS---'
'--------'


 -- tene cuidado con los JOINS, siempre el FROM es sobre la tabla mas relevante
-- en este caso fueron ventas, por eso orders.. despues tenes que relacionar solo las 
-- tablas que necesites, sino te vas a traer cosas que no queres

----------------------------------------------------------------------------------
'Obtener los Tipos de Productos, monto total comprado por cliente y por sus referidos. 
Mostrar:
descripción del Tipo de Producto, Nombre y apellido del cliente, monto total comprado de ese
tipo de producto, Nombre y apellido de su cliente referido y el monto total comprado de su
referido. Ordenado por Descripción, Apellido y Nombre del cliente (Referente).
Nota: Si el Cliente no tiene referidos o sus referidos no compraron el mismo producto, 
mostrar -- ́ como nombre y apellido del referido y 0 (cero) en la cantidad vendida.'

SELECT tp.description, c.lname, c.fname, SUM(i.unit_price*i.quantity) totalPadre
       ,coalesce(r.lname, '--') lNameHijo, coalesce(r.fname, '--') fnamehijo, 
        coalesce(r.totalRef,0) totalHijo
FROM product_types tp
join items i on tp.stock_num = i.stock_num
join orders o on o.order_num = i.order_num
join customer c on o.customer_num = c.customer_num 
left join (select c2.customer_num, c2.customer_num_referedBy,
                  c2.lname, c2.fname, i2.stock_num,
                  sum(i2.unit_price*i2.quantity) totalRef
				  from customer c2 join orders o2 
				  on o2.customer_num = c2.customer_num
				  join items i2 
				  on i2.order_num = o2.order_num
				  GROUP BY c2.customer_num, customer_num_referedBy, lname, fname, stock_num) r
		   ON r.customer_num = c.customer_num_referedBy AND
		   r.stock_num = tp.stock_num
GROUP BY tp.description, c.lname, c.fname, r.lname, r.fname, r.totalRef
order by 1, 2

'_____________________________________________________________________________________________________'
'se requiere crear una vista "comprasFabricanteLider" en la qu se oculten los nombres de 
campos reales y que detalle  : nombre del fabricante, apellido y nombre del cleinte, descripcion 
del tipo de producto, la sumatoria del monto total (p x q) y la sumatoria del campo quantity
ese informe debera mostrar solo los productos cuyo nombre contenga el substring "ball" y 
que el fabricante sea el lider en ventas(osea, al cual le haya comprado mas productos en pesos)
ademas, solo se deberan mostrar aquellos registros que el promedio en pesos de productos vendidos 
a cada cliente sea mayor a 150 pesos por unidad.
'
CREATE VIEW comprasFabricanteLider(nombreFabricante, nombreCliente, producto, 
totalPesos, totalCantidad)
AS 
SELECT m.manu_name, c.fname + ' ' + c.lname, pt.description,
SUM(i.quantity * i.unit_price) monto_total, SUM(i.quantity) cantidad_total
FROM orders o
JOIN items i ON o.order_num = i.order_num
JOIN customer c ON c.customer_num = o.customer_num
JOIN manufact m ON m.manu_code = i.manu_code
JOIN product_types pt ON pt.stock_num = i.stock_num
JOIN (SELECT TOP 1 manu_code, SUM(unit_price * quantity) sumatotal --esto condiciona que el fabricante sea el lider en ventas,
         FROM items                                                -- osea el unico
         GROUP BY manu_code 
         ORDER BY sumatotal DESC) maximo_vend 
ON maximo_vend.manu_code=i.manu_code
WHERE description LIKE '%ball%'
GROUP BY m.manu_name, c.customer_num, c.fname, c.lname, pt.description
HAVING SUM(i.unit_price * i.quantity)/SUM(i.quantity)>150

'_____________________________________________________________________________________________________'
'crear una consulta que devuelva:'
'Apellido, nombre AS CLIENTE,
suma de todo lo comprado por el cliente as totalCompra
apellido,nombre as ClienteReferido ,
suma de todo lo comprado por el referido * 0.05 AS totalComision'

SELECT c1.lname + ',' + c1.fname AS Cliente,
COALESCE(SUM(i1.unit_price*i1.quantity), 0) AS totalCompra, -- es como el max entre 0 Y NULL = 0
ref.lname + ', ' + ref.fname AS Referido,
ref.totalCompraReferido * 0.05 AS totalComision
FROM customer c1
LEFT JOIN orders o1 ON (c1.customer_num=o1.customer_num) -- es xq quiero mostrar si no hay orders
LEFT JOIN items i1 ON (o1.order_num=i1.order_num) -- lo mismo aca
LEFT JOIN ( -- lo mismo para el referido, el left es por "en caso de que cliente no tenga referidos, mostrar al mismo con null en clienteReferido y totalComision"
		  SELECT c2.customer_num, c2.lname, c2.fname,
		  SUM(i2.unit_price * i2.quantity) AS totalCompraReferido,
		  c2.customer_num_referedBy
		  FROM customer c2
		  JOIN orders o2 ON (c2.customer_num = o2.customer_num)
		  JOIN items i2 ON (i2.order_num=o2.order_num)
		  WHERE c2.customer_num_referedBy IS NOT NULL --claro, busco los customers referidos
		  AND i2.stock_num IN (1,4,5,6,9)
		  GROUP BY c2.customer_num,c2.lname,c2.fname, c2.customer_num_referedBy
) Ref ON Ref.customer_num_referedBy=c1.customer_num

GROUP BY c1.customer_num, c1.lname, c1.fname,Ref.customer_num, Ref.lname,
		 Ref.fname,Ref.totalCompraReferido
ORDER BY Cliente

'_____________________________________________________________________________________________________'

'vista que muestre las tres primeras provincias que tengan la mayor cantidad de compras ,
mostrar nombre y apellido del cliente con mayor total de compra para esa provincia, 
total comprado y nombre de la provincia.'

SELECT TOP 3 s.sname, COUNT(DISTINCT c.customer_num) cantClientes,
       SUM(i.quantity * i.unit_price) totalComprado,
       (SELECT TOP 1 c1.fname + ', ' + c1.lname nomYApe 
        FROM customer c1 
		JOIN orders o1 ON c1.customer_num = o1.customer_num -- las traigo para las cuentas
        JOIN items i1 ON o1.order_num = i1.order_num -- tambien, para cuentas
        WHERE c1.state = s.state -- aca, la magia.. busco por estado y solo 1
        GROUP BY c1.fname, c1.lname, c1.state
        ORDER BY SUM(i1.quantity * i1.unit_price) DESC) as apellidoYNombre -- y agrupo por el mayor
		-- esta subquery es el q mas compro en el estado
	    -- obviamente, siempre varia , porque en realidad la query general
		-- es un top 3, entonces buscaria 3.. pero el SUBQUERY este siempre 
		-- me va a traer el que mas compro en ese estado, porque es SELECTOP1
FROM state s
JOIN customer c ON s.state = c.state
JOIN orders o ON c.customer_num = o.customer_num
JOIN items i ON o.order_num = i.order_num
GROUP BY s.sname, s.state
ORDER BY 3 DESC

'_____________________________________________________________________________________________________'

'seleccionar codigo de fabricante, nombre fabricante, cantidad de ordenes del fabricante,
cantidad total vendida del fabricante, promedio de las cantidades vendidas de todos los 
fabricantes cuyas ventas totales sean mayores al promedio de las ventas de todos los 
fabricantes '
'mostrar el resultado ordenado por cantidad total vendida en forma descendente'

SELECT m.manu_code, m.manu_name, COUNT(distinct o.order_num) cantOrdenes, SUM(i.quantity * i.unit_price) totalVendido,
       (SELECT SUM(quantity * unit_price) / COUNT(distinct manu_code)
    FROM items i) as promedioTodosLosFabricantes
FROM orders o
JOIN items i ON o.order_num = i.order_num
JOIN manufact m ON m.manu_code = i.manu_code
GROUP BY m.manu_code, m.manu_name
HAVING SUM(i.quantity * i.unit_price) > (SELECT SUM(quantity * unit_price) / COUNT(distinct manu_code)
    FROM 0 i)
ORDER BY totalVendido DESC

'_____________________________________________________________________________________________________'

'1. Listar Número de Cliente, apellido y nombre, Total Comprado por el cliente ‘Total delCliente’,
Cantidad de Órdenes de Compra del cliente ‘OCs del Cliente’ y la Cant. de Órdenes de Compra
solicitadas por todos los clientes ‘Cant. Total OC’, de todos aquellos clientes cuyo promedio de compra
por Orden supere al promedio de órdenes de compra general, tengan al menos 2 órdenes y cuyo
zipcode comience con 94.
'
    
SELECT c.customer_num, fname, lname, SUM(unit_price*quantity)'Total del Cliente',
     COUNT(DISTINCT i.order_num)'OCs del Cliente', 
     ( SELECT COUNT(o2.order_num) FROM orders o2 ) 'Cant Total OC'
FROM customer c 
JOIN orders o ON (c.customer_num = o.customer_num)
JOIN items i ON (o.order_num = i.order_num)
WHERE zipcode LIKE '94%'
GROUP by c.customer_num, fname, lname
HAVING (SUM(unit_price*quantity)/COUNT(DISTINCT i.order_num))
> (SELECT (SUM(unit_price*quantity)/COUNT(DISTINCT i3.order_num))
FROM items i3) AND COUNT(DISTINCT i.order_num) >=2

'_____________________________________________________________________________________________________'
'9. Listar el numero, nombre, apellido, estado, cantidad de ordenes y monto total comprado de los
clientes que no sean del estado de Wisconsin y cuyo monto total comprado sea mayor que el monto
total promedio de órdenes de compra.'


SELECT c.customer_num, c.fname +', '+ c.lname nomYApe, c.state,
       COUNT(distinct o.order_num) cantOcs, SUM(i.quantity * i.unit_price) montoTotal
FROM customer c
JOIN orders o ON c.customer_num = o.customer_num
JOIN items i ON o.order_num = i.order_num
WHERE c.state != 'WS'
GROUP BY c.customer_num, c.fname, c.lname, c.state
HAVING (SUM(i.quantity * i.unit_price))
    >= (SELECT SUM(quantity * unit_price) / COUNT(distinct order_num)
       FROM items i3)
ORDER BY c.customer_num


'_____________________________________________________________________________________________________'

'5. Trigger
Dada la tabla CURRENT_STOCK
create table CURRENT_STOCK (
stock_num            smallint not null,
manu_code           char(3)  not null,
  Current_Amount     integer  default 0,
created_date          datetime not null,     --  fecha de creación del registro
updated_date         datetime not null,      -- última fecha de actualización del registro
PRIMARY KEY (stock_num, manu_code) );

Realizar un trigger que ante un insert, update o delete de la tabla Items actualice la cantidad CURRENT_AMOUNT de forma tal que siempre contenga el stock actual del par (stock_num, manu_code).
Si la operación es un INSERT se restará la cantidad QUANTITY al CURRENT_AMOUNT.
Si la operación es un DELETE se sumará la cantidad QUANTITY al CURRENT_AMOUNT.
Si la operación es un UPDATE se deberá restar la cantidad QUANTITY nueva y sumar la anterior al CURRENT_AMOUNT.
Si no existe el par (stock_num, manu_code) en la tabla CURRENT_STOCK debe insertarlo en la tabla CURRENT_STOCK con el valor inicial de 0 (cero) mas/menos la operación a realizar.
Tener en cuenta que las operaciones (INSERTs, DELETEs, UPDATEs) pueden ser masivas.

'

CREATE TRIGGER itemsTR ON items
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
--
 DECLARE @stock_num smallint, @manu_code char(3), @quantityI smallint, @quantityD smallint
 DECLARE Actualizados CURSOR FOR
 SELECT COALESCE(i.stock_num, d.stock_num) stock_num,
 COALESCE(i.manu_code, d.manu_code) manu_code,
 i.quantity, d.quantity
 FROM inserted i FULL JOIN deleted d ON (i.order_num = d.order_num AND i.item_num = d.item_num)
 OPEN Actualizados
 FETCH Actualizados
 INTO @stock_num, @manu_code, @quantityI, @quantityD
 WHILE @@FETCH_STATUS=0
 BEGIN
 IF NOT EXISTS (SELECT 1 FROM CURRENT_STOCK p WHERE p.manu_code = @manu_code AND p.stock_num = @stock_num)
 INSERT INTO CURRENT_STOCK (stock_num, manu_code, Current_Amount, created_date, updated_date)
 VALUES (@stock_num, @manu_code, 0, GETDATE(), GETDATE());
 --
UPDATE CURRENT_STOCK
 SET Current_Amount = Current_Amount - COALESCE(@quantityI, 0) + COALESCE(@quantityD, 0),
 updated_date = getdate()
 WHERE stock_num = @stock_num AND manu_code = @manu_code;
 FETCH Actualizados
 INTO @stock_num, @manu_code, @quantityI, @quantityD;
 END
 CLOSE Actualizados
 DEALLOCATE Actualizados
END


CREATE TABLE cuentaCorriente(
  id BIGINT identity(1,1) primary key,
  fechaMovimiento datetime,
  customer_num smallint REFERENCES customer,
  order_num INT references orders,
  importe decimal(12,2)
)

CREATE PROCEDURE procedure_cuenta_corriente AS BEGIN 
  INSERT INTO cuentaCorriente(fechaMovimiento, customer_num, order_num, importe)
    select o.order_date, o.customer_num, o.order_num, 
            sum(quantity * unit_price)
    from orders o
    join items i on o.order_num = i.order_num 
    groupy by o.order_num, o.order_date, o.customer_num
  UNION
    select o.paid_date, o.customer_num, o.order_num,
           sum(quantity * unit_price -1)
    from orders o
    join items i on o.order_num = i.order_num 
    WHERE o.paid_date is NOT NULL 
    GROUP BY o.order_num, o.paid_date, o.customer_num 
END 

