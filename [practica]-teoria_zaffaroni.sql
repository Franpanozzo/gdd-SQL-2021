'________________________________________________________________________________________________'
'INTRODUCCION - BASE DE DATOS'
'________________________________________________________________________________________________'

LEER TAMBIEN DEL DE vof

'BASE DE DATOS': Edgar Codd define base de datos utilizando estos 3 conceptos.
(estructura- Manipulacion de datos - integridad) # el resto son sub-definiciones  
'Estructura': recopilacion de objetos o relaciones.
segun edgar, una relacion es una estructura bidimensional (una matriz) que tiene 
una cabecera, con un conjunto de nombres de atributos y un cuerpo.
en estecuerpo, hay varias filas con la instanciacion de los atributos de la cabecera,
estos atributos representan la relacion.
el grado de una relacion representa cuantos atributos hay, si hay 4 columnas, grado 4
y la cardinalidad representa la cantidad de filas o isntanciaciones de esos atributos
la relacion segun codd era esto, distinta la relacion en DER.
para codd , la relacion era la entidad.

'Relacion': subconjunto del producto cartesiano de los dominios de valores 
involucrados.
sobre la estructura tambien entra el concepto de dominio, explicado mas abajo.
propiedades de la relacion:
	- no hay filas/tuplas repetidas -> toda relacion tiene una clave primaria
	- las filas/tuplas no estan ordenadas
	- los atributos no estan ordenados
	- los valores de los atributos son atomicos -> la relacion esta normalizada
'Manipulacion de datos': operaciones sobre las relaciones para producir otras

'Integridad': para obtener precicsion y consistencia.
existen dos tipos de claves: que nos permiten definicar las reglas de integridad
	-clave primaria 
	---------------------> definen reglas de integridad
	-clave foranea
si yo digo que un alumno curso 10 materias y tengo esas 10 materias con sus notas
si borro el alumno, quedan esas materias huerfanas con notas de no se quien.
estos son reglas basicas de integridad, que los motores de base de datos las hacen cumplir.
	•'clave primaria': por ejemplo en un alumno, el Nro de Legajo. es elegida segun el contexto
					   para ver cual puede distinguirlo mas, las claves candidatas (como podrian
					   ser dni, cuil, etc) al no ser elegidas se las llaman claves alternas.
	•'clave foraanea': es la clave que permite relacionar entidades, por ejemplo alumnos
					   con una cursada.. la clave foreanea contiene un valor en la cual 
					   tiene que existir ese valor como clave primaria de otra tabla.
					   ej: una cursada tiene una FK cod_materia, que en la tabla 
					   materia, el cod_materia es su PK.
					   no debe ser nula, la FK y la PK estan definidas en el mismo dominio.
					   obs: si la relacion es auto-referencial.. como customer que tiene un
					   atributo 'customer_num_refered_By' ahi si puede aceptar nulos.

'DOMINIO': el dominio es la cantidad de valores posibles que puede tomar un atributo,
segun Edgar Codd.
• conceptualmente es la menor unidad semantica de informacion
• son atomicos (no se pueden descomponer sin perder significado) # ej: la ciudad Buenos Aires
# no se puede descomponer sin perder su sentido, no podrias hacer una ciudad 'Buenos' y otra
# que se llama 'Aires'
• conjunto de valores escalares de igual tipo (no puede haber un array)
• no pueden contener nulos. # un nulo describre un atributo con ausencia de valor
el dominio es algo clave, pero los motores de base datos todavia tienen algunas vueltas 
para implementarlo porque es algo muy conceptual y semantico

'REGLAS DE INTEGRIDAD':
#esta relacionada con la CLAVE PRIMARIA- A.K.A-> primary key
'1': 'Regla de integridad de las entidades': ningun componente(atributo) de la PK de una 
relacion base puede aceptar nulos. si la clave primaria identifica univocamente a una tupla 
de la relacion, yo no puedo permitir que los atributos que tiene esa PK sean nulos, porque 
sino no estaria definiendo nada.. si PK es lo que identifica, no puedo admitir que un alumno
tenga un nro de legajo nulo.

'2': 'Regla de integridad referencial': la base de datos, no debe contener valores no nulos
de clave foranea para los cuales no exista un valor concordante de clave primaria en la 
relacion referenciada.
es decir, si yo tengo un FK que apunta a una PK, la FK si no tiene nulos el valor que tiene 
tiene que existir en la FK.
dada una FK determinada, si esa FK tiene valor.. es valor tiene que existir en la tabla donde tengo la PK.
si yo tengo una cursada y tengo un nro de legajo de un alumno, ese numero de legajo debe 
existir en la tabla de alumnos.


'INDEPENDENCIA DE DATOS'
'• independencia logica': si ustedes estan consultando ciertos datos de una entidad, el orden 
de los datos no necesariamente tiene que ser el que consultamos, es decir, lo consultamos 
el orden en el que queramos. SELECT apellido, fecha, nombre ...
'• independencia fisica': es posible modificar la estructura fisica de las tablas , las tenicas
de acceso, la forma de acceder a los datos , todo sin modificar la aplicacion.


'REGLAS DE CODD': hace tiempo, empresas sacaban bases de datos y desconocian sobre si era 
relacional o no relacional.. entonces Edgar Codd saca un paper "is your DBMS really relational"?
explicando todo.
Codd plantea una serie de reglas que se llaman las 'reglas de codd' en las cuales planteaba
las caracteristicas que tiene que tener un motor para considerarse relacional
• independencia entre el motor de base de datos y los programas que acceden a los datos
(es posible modificar el motor de base de datos o los componentes de aplicacion en forma 
independiente)
• representar la informacion de la estructura de las tablas y sus relaciones mediante 
un catalogo dinamico basado en el modelo relacional. la metadata de las tablas, es decir
la estructura y las relacioens de las tablas tiene que estar en un catalogo adentro de 
la misma base de datos.
• los datos y los metadatos tiene que estar en tablas dentro del modelo de base de datos,
• las reglas de integridad deben guardarse en el catalogo de la base, no en programas de 
aplicacion. 'ej': 'borra un alumno que tiene cursadas relacionadas', el motor de base de datos
tiene que asegurar que eso no se puede hacer.
• soportar informacion faltante mediante valores nulos
• proveer un lenguaje de programacion para 
	- definir los datos
	- manipular los datos, donde debe haber operaciones de alto nivel para insertar, eliminar
	  ,actualizar o buscar (INSERT ,DELETE, UPDATE, SELECT, -- SQL)
    - definicion de restricciones de seugridad, de integridad , de autorizacion y delimitar
      una transaccion

'________________________________________________________________________________________________'
'MODELO/diseño de datos - normalizacion'
'________________________________________________________________________________________________'

obs: aca varios conceptos conceptuales de Codd cambian para poder ser aplicados realmente 
al lenguaje SQL 

'RELACIONES': aca se denomina entidad
las relaciones representan y son asociaciones entre las entidades, de alguna maneras 
estas entidades estan representadas con tablas y se relacionan entre otras.
generalmente se conectan con un verbo 
ej: empresa -> 'realiza' venta
ej: empleado -> 'trabaja' empresa 
ej: alumno -> 'cursa' materia

el modelo de datos se puede comunicar mediante un DER o 
codigo SQL - DDL Data Definition Language(metadata)

'NORMALIZACION': normalizar una base de datos significa , transformar el conjunto de datos
que tiene la base de datos para poder manipularlos de una manera mas consistente y evitar 
la repeticion de datos.
El objetivo principal de la normalizacion es reducir la redundancia de datos (minimizar 
la repeticion de datos por lo tanto minimizo inconsistencias)
tambien permite facilitar el mantenimiento de datos, puesto que si quiero modificar algo
lo modifico en un solo lugar.
lo que permite tambien la normalizacion es evitar anomalias en la manipulacion de datos
y una amplia reduccion del impacto de los cambios en los datos.
existen varias formas normales, 1FN- 2FN - ... - 5FN
cada forma normal permite reducir las redudancias nombradas arriba, y cada una de ellas 
introduce restricciones nuevas, donde la primera restriccion que aplica es cumplir la 
forma normal anterior.

'TABLA': - entidad 
es la unidad basica de almacenamiento de datos. Los datos se almacenan en filas y columnas,
son de existencia permanente y poseen un nombre indetificario unico por esquema. ej:cliente

'CONSTRAINTS': 
tipos de contraints referenciales

'Ciclic referential Constraint': asegura una relacion de padre-hijo entre tablas. Es el mas
comun. ej : CLIENTE -> FACTURAS

'Self referencing constraint': asegura una relacion de padre -hijo entre la misma tabla
ej: empelados -> empleados 

'multiple path constraint': se refiere a una primary key que tiene multiples foreign keys. 
este caso tambien es muy comun
clientes -> facturas 
clientes -> reclamos 

'integridad semantica': la integridad semantica es la que nos asegura que los datos que 
vamos a almacenar tengan una apropiada configuracion y que respeten las restricciones definidas 
sobre los dominios o los atributos
- DATA TYPE: define el tipo de valor que se puede almacenar en la columna
- DEFAULT: valor insertado en una columna cuando al insertar un registro ningun valor 
fue especificado para dicha columna, el valor default x default es el null 
- UNIQUE: especifica sobre una o mas columnas que la insercion o actualizacion de una fila 
contiene un valor unico en esa columna o conjunto de columnas 
- NOT NULL: asegura que esa columna contenga un valor no nulo ante un insert o un update 
- CHECK

'SECUENCIAS'
Los generadores de secuencias proveen una serie de números
secuenciales, especialmente usados en entornos multiusuarios
para generar una números secuenciales y únicos sin el
overhead de I/O a disco o el lockeo transaccional. 
Debe tener un nombre, debe ser ascendente o
descendente, debe tener definido el intervalo entre números,
tiene definidos métodos para obtener el próximo número ó el
actual


'TABLAS TEMPORALES'

Por qué utilizarlas?

Como almacenamiento intermedio de Consultas Muy Grandes:
Por ejemplo, se tiene una consulta SELECT que realiza “JOINS” con ocho
tablas.
Muchas veces las consultas con varios “JOINS” pueden funcionar de
manera poco performante.
Una técnica para intentar es la de dividir una consulta grande en consultas
más pequeñas. Si usamos tablas temporales, podemos crear tablas con
resultados intermedios basados en consultas de menor tamaño, en lugar
de intentar ejecutar una consulta única que sea demasiado grande y
múltiples “JOINS”.

Para optimizar accesos a una consulta varias veces en una
aplicación:
Por ejemplo, usted está utilizando una consulta que tarda varios segundos
en ejecutarse, pero sólo muestra un conjunto acotado de resultados, el
cual desea utilizar en varias áreas de su procedimiento almacenado, pero
cada vez que se llama se debe volver a ejecutar la consulta general.

Para almacenar resultados intermedios en una aplicación:
Cuando no se quiere actualizar o impactar a tablas reales
de la BD hasta el final del procedimiento. Al llegar al final del
procedimiento, con los datos existentes en la tabla temporal se actualizará
la o las tablas físicas de la BD que corresponda.

TIPOS:
De Sesión (locales)
Son visibles sólo para sus creadores durante la misma sesión
(conexión) a una instancia del motor de BD.
Las tablas temporales locales se eliminan cuando el usuario se
desconecta o cuando decide eliminar la tabla durante la
sesión.

Globales
Las tablas temporales globales están visibles para cualquier
usuario y sesión una vez creadas. Su eliminación depende del
motor de base de datos que se utilice.

'________________________________________________________________________________________________'
'VISTAS - SNAPSHOTS - INNER JOIN - OUTER JOIN - TRANSACTONS'
'________________________________________________________________________________________________'
----------------------------------------------------------------------------------------
#vista: 1 carrilla
'VISTA': una vista es un conjunto de columnas, reales o virtuales de una misma tabla o no
con algun filtro determinado o no.
de esta forma, es una presentacion adaptada de los datos contenidos en una o mas tablas.
una vista toma la salida resultante de una consulta y la trata como una tabla, se pueden
usar vistas en la mayoria de las situaciones que se pueden usar tablas
es como un 'SELECT' al que el pongo un nombre.
en realidad, la vista no existe.. simplemente es un select con un nombre.
• tiene un nombre especifico
• no aloca espacio de almacenamiento (lo unico q aloja es la metada)
• no contiene datos almacenados
• esta definida por una consulta que consulta datos de una/varias tablas

che bueno.. pero para que sirve entonces?
una vista sirve para:
1. suministrar un nivel adicional de seguridad restringiendo el acceso a un conjunto
   predeterminado de filas o columnas de una tabla.. puedo otorgarle el acceso a un 
   usuario a la vista, sin que tenga acceso a las tablas reales.. y no saben realmente
   que es lo que estan consultado. es una especie de HoneyPot.
2. oculta la complejidad de los datos
3. simplifica la sentencias al usuario, porque por ejemplo en una vista podes estar calculando
   algo que el usuario nunca va a ver, o no tendria que tirar en el select
4. presenta los datos desde una perspectiva diferente
5. aisla a las aplicaciones de los cambios en la tabla base

las vistas tienen varias restricciones, que dependen segun el motor de la DB, algunas de 
ellas son :
- no se pueden crear indices en las vistas
- una vista depende de las tablas a las que se haga referencia en ella, si se elimina una 
  tabla, todas las views que dependen de ella se borraran o se pasara a estado invalido, 
  dependiendo del motor. lo mismo para el caso de borrar una view de la cual depende de otra
- algunas tiene restringidos los inserts, deletes, updates  
	cuando:
		-> tienen joins
		-> tienen una funcion agregada 
		-> trigger instead of 
- al crear la vista el usuario tiene que tener permisoss de select a las columnas de las
  tablas a las cuales le va a pegar 
- no es posible un order by y un union (depende del motor igual )
- si en la tabla existen campos que no permiten nulos y en la vista no aparecen, los inserts fallan
- si en la view no aparece la PK los inserts podrian fallar
- se puede borrar filas desde una view que tenga una columna virtual 
- con la opcion WITH CHECK OPTION , se puede actualizar siempre y cuando el checkeo de la 
  opcion en el where sea verdadero.

la vista tiene un pequeño ruido en terminos de integridad, puesto que podrias insertar datos 
a una tabla original a travez de tu vista.. cuyos datos la vista no puede mostrar
ej: una vista muestra los clientes de california, pero vos podes insertar clientes de new york
para que esto no pase, existe una clausula 'WITH CHECK OPTION' que realiza un chequeo de integridad 
de los datos a insertar o modificar, los cuales deben cumplir con las condiciones del WHERE 
de la vista.
#obs: el WITH CHECK OPTION se agrega al final de la vista.

----------------------------------------------------------------------------------------
'SNAPSHOTS/MATERIALIZED VIEWS / SUMMARIZED TABLES': es una vista, pero que tiene datos.
es una vista que en el momento de crearla, como que le saca una foto a las tablas.
son objetos del esquema de una DB que pueden ser usados para sumarizar, preocumputar, 
ditribuir o replicar datos. Se utiliza sobre todo en DataWareohuse, para sistemas de 
soporte de toma de decision y para computacion movil y/o distribuida.
una diferencia es que estas si consumen espacio de almacenamiento en disco.
deben ser recalculadas o refrescadas cuando los datos de las tablas master cambian.
pueden ser refrescadas en forma manual o a intervalos de tiempo definidos dependiendo el DBMS

#integridad vs consistencia
'INTEGRIDAD VS CONSISTENCIA'
'TRANSACTIONS': los motores de db tienen varios mecanismos para asegurarse la consistencia 
de los datos.. en realidad, consistencia es un concepto muy parecido al de integridad, 
una busqueda en google nos diria que son lo mismo.. pero aca se puede hacer una divison 
, porque la integridad al nivel del mundo relacional esta definida por codd por dos reglas 
regla integridad entidades y regla integridad referencial pero la consistencia la podemos 
plantear como que los datos de nuestra base de datos tienen que estar correctos en funcion 
a un determinado caso de negocio, que no tiene nada que ver con la integridad tradicional.
ej: si grabo en el sistema una ticket (cabecera, nroticket, cliente, hora, consumidor final,
el detalle: caramelo, bombon etc, etc) cuando esto se graba, quiero que se grabe una fila 
por cada cosa : cabecera, nro ticket, cliente, y demas datos/operaciones como calcular el stock.
todos estos movimientos se tienen que hacer como una unidad atomica de ejecucion, es decir, 
se tienen que ejecutar juntos.. si el sistema no graba todo eso, el dato me queda inconsistente
si tu ticket tiene 10 renglones , en el detalle tiene que haber 10 movimientos de stock digamos
esto, es consistencia.
con este ejemplo podemos ver que la integridad, esta mas atado a las reglas de integridad de Edgar Codd 
y consistencia se ata mas al negocio porque la base de datos por si sola peude asegurar la integridad de 
las datos, gracias a las reglas de integridad que yo creo.. como los constraints , que se chequean todo
el tiempo. ahora la consistencia, no depende de las reglas de integridad.
la transaccion, es el concepto mas importante que hace referencia a la consistencia de los datos 
ejemplo en el BEGINS TRANS , COMMIT , ENDT RANS

una transaction es un conjunto de sentencias SQL que se ejecutan atomicamente en una unidad 
logica de trabajo. Partiendo de que una transaccion lleva la bas de datos de un estado consistente 
a otro estado consistente, el motor posee mecanismos de manera de garantizar que la operacion 
completa se ejecute o falle, no permitiendo que queden datos inconsistentes.
cada sentencia de alteracion de datos como insert, update o delete es una transaccion en si 
misma que es llamada singleton transaction.

#ACA SE ASUME Q LA BASE DE DATOS ESTA CONSSITENTE
BEGIN TRANS;
	insert 123
	update abcd 
	insert 321 
committ;
#ACA SE ASUME Q LA BASE DE DATOS ESTA CONSSITENTE

'logs transaccionales': registro donde el motor almacena la informacion de cada operacion
llevada a cabo con los datos 
'recovery': metodo de recuperacion antre caidas

ejemplo de transaction para mantener la consistencia

BEGIN transaction
	insert 1 cliente
	insert 1 fila cabecera de orders
	-------------> si falla, automatic rollback
	insert 1 producto
	insert 2 items
	CONTROL STOCK -----------> STOCK NEGATIVO -> ROLLBACK MANUAL
	COMMIT TRANSACTION

ejemplo2:
CREATE TABLE #numeros
BEGIN TRANSACTION
INSERT INTO #NUMEROS values(2)
SAVE TRAN N2 -- guardo la transaction actual
	BEGIN TRANSACTION 
		INSERT INTO #numeros values(3)
	ROLLBACK TRANSACTRION N2 -- DESHAGO LA TRANSACTION ACTUAL HASTA N2
INSDERT INTO #NUMEROS values(4)
COMMIT TRANS

'FOCO DE EJECUCION DE TRANSACTIONS'
'• A': Atomicidad -> se ejecuta completa o no se ejecuta
'• C': Consitencia -> la base de datos parte de un estado consistente y cuando termine, tiene que quedar consistente, mantiendose la integridad de la base de datos, cumpliendose las reglas de negocio
'• I': Isolation (aislamiento) -> las transactions por separado no se pueden chocar, se tiene que poder ejecutar concurrentemente controladas por los distintos niveles de aislamiento
'• D': Durabilidad -> cuando yo hago un commit, el dato dura eternamente hasta que yo le diga DELETE. Los datos persisten


'________________________________________________________________________________________________'
'INDICES' https://www.youtube.com/watch?v=MCTYlMHDkIk&list=PLe5sv7dROOZ1alqLI7UHzkfEzS9DAoQ-E&index=9
'________________________________________________________________________________________________'
#1 carilla
los indices son estructuras opcionales asociadas a una tabla.
la funcion de los indices es la de permitir un acceso mas rapido a los datos de una tabla, 
se pueden crear distintos tipos de indices sobre uno o mas campos.
los indices son logica y fisicamente independientes de los datos en la tabla asociada.
se puede crear o borrar un indice en cualquier momento sin afectar a las tablas base 
o a otros indices.
desde el punto de vista de la integridad, los indices permiten asegurar la unicidad de los 
datos.
tipos de indices hay varios 
'Btree Index': estructura de indice estandar y mas utilizada, es independiente de la tabla
			   y el indice esta ordenado pero la tabla no.
			   la forma de buscar es parecida a como lo viste en operativos, donde tenes 
			   varias tablas y partis de un numero por ejemplo, y vas buscando como dividiendo
			   segun si el numero es menor o mayor y cuando llegas al ultimo bloque, buscas 
			   secuencialmente hasta encontrarlo.
			   esto asegura que cualquier busqueda que hagas , van a tardar todas lo mismo
			   los motores usan un Btree +(plus), donde los bloques estan conectados como 
			   si fueran hermanos, para evitar volver para el bloque anterior.
'Btree cluster index': es un tipo de indice especial , donde solo puede haber 1 por tabla 
				       cuando uno lo crea la tabla se ordena igual que el indice y queda 
				       ordenada igual que el indice.
'Bitmap index': es un indice de Oracle que esta pensado para almacenar pocas claves con muchas 
				repeticiones, por ej un indice sobre estado civil. este indice arma un Bitmap
				binario, cada bit en el bitmap corresponde a una fila, si el bit esta ON significa
				que la fila con el correspondiente rowid tiene el valor de la clave
'Hash index': este indice esta implementado en tablas de hash y se basan en otros indices 
  			  Btree existentes para una tabla.
'Functional Index': indices cuya clave deriva del resultado de una funcion 
'Reverse key index': invierte los bytes de la clave a indexar, esto sirve para los indices cuyas 
					 claves son una serie constantae, por ejemplo un crecimiento ascendete.

'CARACTERISTICAS DIFERENCIADORAS PARA LOS INDICES':
'unique': indice de clave unica, solo admite una fila por clave.. esto son usados por ejemplo 
          en las primary key, porque nos asegura unicidad 	
'duplicado': permite duplicar filas
'simple': la clave tiene una sola columna 
'compuesto': la clave compone de varias columnas, apellido, nombre y sexo por ej


'BENEFICIOS DEL USO DE INDICES'
el beneficio principal es la mejora de la performance, le da una mejora en acceso a los datos
que tiene una complejidad algoritmica log(n) , donde n es la cantidad de claves que tiene un nodo
tambien asegura un mejor ordenamiento de las filas, osea la performance en el order by
tambien asegura valores unicos, por ejemplo para buscar la primary key 
ademas, cuando las columnas que interviene en un JOIN tienen indices se le da mejor performance 
si el sistema logra recuperar los datos a traves de ellas 
y por ultimo, asegura el cumplimiento de constraints y reglas de negocio, es decir, asegura
la integridad referencial por un tema de velocidad en la busqueda

'DESVENTAJA DE LOS INDICES':
el espacio ocupado y el procesamiento: el indice ocupa espacio en disco y si hay una tabla que ocupa 100mb
generado por campos que pesan X bytes , ahora si queres crear un indice por clave primaria 
y el indice ocupa 4bytes por ejemplo, vas a tener mucho mas espacio ocupado de indices 
que de datos y ademas, vas a tener un costo esta en lo que es procesamiento.
Contrarresta un poco en la performance en el sentido de que si se tienen que ingrsar nuevas filas, se tienen que cargar los datos donde estan los indices tambien


'cuando se deberia indexar?':
- indexar columnas que intervienen en joins 
- indexar las columnas donde frecuentemente se realizan filtros 
- indexar columnas que son frecuentemente usadas en orders by 
- evitar duplicacion de indices sobre todo en columnas con pocos valores distintos, ej 'sexo'
- verificar que el tamaño de indice deberia ser pequeño comparado con la fila 
  - tratar sobre todo en crear indices sobre columnas cuya longitud de atributo sea pequeña 
  - no crear indices sobre tablas con poca cantidad de filas
- tratar de usar indices compuestos para incrementar los valores unicos, que quiere decir esto?
  que no se podria buscar por indice de ´SEXO´ por ejemplo, porque si tenes 2 millones de personas 
  va a ser un 0.5 para ambos.. lo que si se podria hacer , es usar indices compuestos pero 
  con mas columnas
  //Conviene aplicarlos en PK, FK, columnas donde frecuentemente se usen en order by o group by o where o que intervengan en un JOIN 


'construccion de indices en paralelo': los motores los hacen en paralelo, agarran los datos
de la tabla, los ordenan, los dividen en pedazos y levantan hilos para juntarlos y hacer el arbol 
completo.

indice unico simple : CREATE UNIQUE INDEX ix1_ordenes ON ordenes(n_orden);
indice duplicado y compuesto : CREATE INDEX ix2_ordenes ON ordenes(n_cliente, f_orden);
indice clustered : CREATE CLUSTERED INDEX ix3_ordenes ON ordenes(n_orden);


'________________________________________________________________________________________________'
'SUBQUERYS' https://youtu.be/MCTYlMHDkIk?list=PLe5sv7dROOZ1alqLI7UHzkfEzS9DAoQ-E&t=2000
'________________________________________________________________________________________________'

ejemplo de uso de subquery para traernos otra tabla 
DELETE FROM customer 
WHERE customer_num NOT IN (select distinct customer_num from cust_calls)
AND customer_num NOT IN (select distinct customer_num from orders)
AND custoemr_num NOT IN (select distinct customer_num_refered_By FROM customer c2
                         where customer_num_refered_By is NOT NULL)

'________________________________________________________________________________________________'
'ANSY / SPARC' https://www.youtube.com/watch?v=Bs-Ywj5XnSk&list=PLe5sv7dROOZ1alqLI7UHzkfEzS9DAoQ-E&index=18
'________________________________________________________________________________________________'

'ANSY / SPARC': es una arquitectura teorioca para ver la base de datos de otra manera, en la 
cual vemos la base de datos dividida en 3 niveles, este modelo se ajusta bastante bien a la 
mayoria de los sitemas de DB.
cuenta con 3 niveles
• Nivel Externo: es un nivel de vistas, que es a lo cuales acceden los usuarios y es la 
                 percepcion que un usuario tiene en una base de datos. Un select devuelve 
                 un data set que este resulset es la vista que vemos acerca de esos datos.
                 es un nivel de vistas individuales, donde cada usuario tiene una percepcion 
                 de la base de datos diferente, segun el rol que tenga y los permisos que se le otorgaron.
• Nivel Conceptual : tambien llamado intermedio, es el nivel en el cual se tiene la vista 
                     comun de la base de datos, en general el usuario que accede a este nivel 
                     es un DBA , un developer, un analista y es en definitiva donde se define 
                     el DDL (data definition language).
                     aca se ve que la base de datos tiene tales tablas, los indices, las columnas 
                     es decir, vemos la estructura de la base de datos. Se describen los datos que estan almacenados y como estos se relacionan
• Nivel Interno: aca se tiene una percepcion de los datos de forma fisica, ej separados en 
                 paginas de 4k, se ven los bloques de indices para el acceso, es decir, 
                 se define como se almacenan los datos en disco, es como si fuera el "bajo nivel"


cada nivel tiene una capa de transformacion que simplemente lo que hace es transformar 
los datos de los distintos niveles para poder tener una percepcion diferente.

'FUNCIONES DEL MOTOR DE BASE DE DATOS Y DEL DBMS':
1.• administracion del diccionario de datos: el motor tiene un diccionario de datos que 
internamente lo guarda en tablas en el cual tenemos la definicion de todos los objetos 
que se creen, modifiquen o borren de la base de datos.
un CREATE TABLE se guarda en un diciconario de datos internos a la base de datos, estos 
'metadatos' estan guardados en la misma base de datos en tablas.

2.• control de seguridad: la seguridad involucra la autenticacion, asegurar que el usuario
existe y su clave es correcta permitiendo el acceso a la DB y la autorizacion, determinar 
los permisos que tiene el usuario para ejecutar acciones en diferentes objetos de la DB.
los DataBase Management System (DBMS) poseen lo que se llama el catalogo, que el mismo 
esta formado por entidades e interrelaciones (en una esquema relacional son tablas)
el catalogo tiene informacion de usuarios, de roles y perfiles, entre otras cosas.
un rol o un perfil no es mas ni menos que una categoria de usuario, donde yo digo 
este rol tiene determinados permisos y los usuarios que pertenecen al rol, heredan sus permisos.
a su vez, el catalogo guarda las acciones disponibles a realizar sobre los objetos 
por ej, un usuario en el rol marketing solo puede consultar la tabla de ventas.
'sentencias sql relacionadas con la seguridad':
	= GRANT - para otorgar permisos 
	= REVOKE - para revocar permisos previamente otorgados, por default no tenes ningun permiso 
'objetos relacionados con la seguridad':
• vistas : porque es el honeypot, no se ve el query asociado a la vista, sino todo lo que tiene 
• trigger : se podria implementar un trigger en el que cuando se inserte en una tabla , pregunte 
            si se cumple algun permiso para realizar otra accion 
• stored procedures: lo mismo que con triggers 
• sinonimos 
• funciones 

3.• mecanismos para garantizar la integridad de datos: el DBMS cuenta con mecanismos                //RESPUESTA PERFECTA A LA INTEGRIDAD, CAPAZ DEFNICION DE INTEGRIDAD ARRIBA
para controlar la integridad de los datos en la base de datos. 
aca tambien esta bueno hacer la diferencia de integridad vs consistencia, donde para edgar codd 
las reglas de integridad son unicamente 3 (integridad entidades, integridad referencial, integridad semantica)
un dato integro segun codd es un objeto que cumple con estas 3

algunos de estos mecanismos o objetos son:
. constraints 
	- primary key : atributo o conjunto de atributos que definian univocamente a cada fila de la tabla
	                de la tabla y no podian ser nulos y debian ser unicos. esta intimamente ligada 
	                con la regla de entidad de Codd
	- foreign key : una clave foranea no nula , tiene uqe tener un valor en la clave primaria 
	                que referencia.	               
	- unique, not null, check , default , primary key, foreign key 
. triggers : ->Los triggers pueden validar en una tabla que esta en otra base de datos que se cumpla la integridad referencial (que la foreign key existan en esa tabla de otra BD)
 				Ejemplo: estoy cargando una factura para un cliente de cordoba y no tengo en mi tabla 
				entonces hago un trigger que dispara una consulta a la base de datos de cordoba 
				y se fija si ese cliente existe, aca el trigger nos garantiza la integridad
. indices (unicos) :-> cuando se crea una clave primaria o un UNIQUE el motor nos crea un indice 
                       unico, porque es la forma mas rapida de chequear si el dato existe o no
. views (with check option) :-> de alguna manera, el check option me asegura cierto nivel de integridad
								sobre la vista, no permitiendome cargar datos que la vista no puede 
								mostrar. (#WHERE CLIENTE.STATE = 'CA')
. stored procedures:-> podria hacer un chequeo con un stored procedure que le una tabla ordenes 
					   donde no hay customers nums
. funciones //mmmmm

4.Mecanismos para garantizar la consistencia de datos

El DBMS cuenta con distintos mecanismos para poder asegurar la consistencia de los datos que existentes en la/s Base/s de Datos.

Conceptos relacionados con la consistencia de datos
• TRANSACCIONES
•Es un conjunto de sentencias SQL que se ejecutan atómicamente en una unidad
lógica de trabajo. Partiendo de que una transacción lleva la base de datos de un
estado correcto a otro estado correcto, el motor posee mecanismos de manera
de garantizar que la operación completa se ejecute o falle, no permitiendo que
queden datos inconsistentes.
•Cada sentencia de alteración de datos (insert, update o delete) es una
transacción en sí misma (singleton transaction).
•LOGS TRANSACCIONALES: Es un registro donde el motor almacena la
información de cada operación llevada a cabo con los datos
•RECOVERY: Método de recuperación ante caidas.

5.Mecanismos de recuperación
Recovery: es un mecanismo provisto por los motores de base de datos que se ejecuta en cada inicio del motor de forma automática como 
dispositivo de tolerancia de fallas. Sus objetivos son , retornar el el motor al punto consistente más reciente y utilizar logs transaccionales 
para retornar al motor a un estado lógico consistente.

6. Mecanismos de resguardo y restauración
(BACKUP y RESTORE)
Los motores de Bd cuentan con distintas herramientas que permiten realizar estas
acciones las cuáles son utilizadas generalmente en empresas medianas y chicas.
Existen herramientas de terceras partes especializadas en el tema las cuáles son
muy utilizadas sobre todo en grandes empresas. (Por ej. Veritas, IBM Tivoli)

Backup: es la copia total o parcial de la información de una base de datos la cual
debe ser guardada en algún otro sistema de almacenamiento masivo.  ///TIPOS DE BACKUP SLIDE 26 CLASE 12
Esta el backup acumulativo y el incremental

Restore: es la acción de tomar un Back Up ya realizado y restaurar la 
estructura y datos sobre una base dada.

7.Facilidades de auditoría.
A los DBMS se les puede activar la opción de guardar en un log un registro del uso de los
recursos de la base para auditar posteriormente.

8.Logs del sistema
Mediante este tipo de logs, el DBA puede llegar a determinar cual fue, por ejemplo, el
problema que produjo una caída del sistema.

9.Acomodarse a los cambios, crecimientos, modificaciones del esquema.
El motor permite realizar cambios a las tablas constantemente, casi en el mismo momento en
que la tabla está siendo consultada. 

mas abajo

'________________________________________________________________________________________________'
'BACKUP- RESTORE ' https://youtu.be/Bs-Ywj5XnSk?list=PLe5sv7dROOZ1alqLI7UHzkfEzS9DAoQ-E&t=1961
'________________________________________________________________________________________________'

'________________________________________________________________________________________________'
'CONTROL DE CONCURRENCIA  ' https://youtu.be/Bs-Ywj5XnSk?list=PLe5sv7dROOZ1alqLI7UHzkfEzS9DAoQ-E&t=2502
'________________________________________________________________________________________________'
'CONTROL DE CONCURRENCIA': la concurrencia es otra funcionalidad que tienen los motores DB
los motores DB hacen que se cumplan con dos cosas 
1. LOQUEOS: un lock es una llave/candado a un recurso (parecido al lock de files )
•granularidad de loqueos 
	-nivel de base de datos
	-nivel de tabla
	-nivel de pagina 
	-nivel de fila 
	-nivel de clave de indice 
•tipos de loqueos 
	-compartido(shared)
	-exclusivo (exclusive)
	-promovible (promotable - update)

2. NIVELES DE AISLAMIENTO: 
'read uncommited': no chequea lockeos por select en las tablas a consultar, lo que mejora 
el rendimiento pero afecta la integridad e ncuanto a que existen lecturas sucias (datos 
actualizados en una transaccion que luego se deshacen por un rollback) y no existen 
lecturas repetibles (en la misma transaccion poder hacer dos veces la misma consulta asegurando
siempre el mismo resultado)
pueden existir lecturas sucias y fantasmas (filas que aparecen durante la 
transaccion que fueron insertadas en otra transaccion concurrente)

ejemplo USER 1
		CRATE TABLE ##nums
		INSERT INTO ##nums VALUES (1)

		USER2
		SET TRANSACTION ISOLATION  LEVEL READ UNCOMMITED




-------------------------------------------

'Explique y desarrolle los diferentes niveles de aislamiento de una base de datos relacional.'
Niveles de aislamiento:
Read uncommitted: no asegura lockeos por select, lo que mejora el rendimiento pero afecta la 
integridad porque hay lecturas sucias, lecturas no repetibles y lecturas fantasmas.
no lockeos por select => mejor rendimiento
	si lecturas sucias
	si lectura no repetibles 
	si lectura fantasma fantasmas
Read committed: asegura que no exista lecturas sucias pero no asegura lecturas repetibles, 
ya que una vez que leyó los datos, libera el lockeo. En una misma transacción puede tener dos llamados 
a un mismo select y este arrojar resultados distintos.
	no lecturas sucias
	si lecturas no repetibles
	si lectura fantasma
lee los datos y libera el lockeo
dos llamados en una misma transacción puede tener resultados distintos
Repeatable read: asegura que no existan lecturas sucias y que las lecturas puedan ser repetibles, 
pero no evita lecturas fantasmas.
	no lecturas sucias
	no lectura no repetible
	si lectura fantasma
Serializable read: asegura que no existan lecturas sucias, lecturas fantasmas y que las lecturas puedan 
ser repetibles. El problema es que se implementa un nivel de bloqueo que puede afectar a los demás usuarios.
Lockea las claves del indice y sus adyacentes en el caso de haber utilizado un indice para la primer consulta 
y sino lockea toda la tabla, por lo que no permite que una 2da transaccion concurrente commiteada realice un insert, no perimitendo las lecturas fantasmas
	no lectura sucia
	no lectura no repetible
	no lectura fantasma
	tantos bloqueos pueden afectar a los demás usuarios	

'Defina el concepto de lectura sucia, repetible y fantasma.'
Lectura sucia: ocurre cuando se le permite a una transacción hacer una lectura de una fila que ha sido modificada 
por otra transacción concurrente, pero aún no ha sido confirmada (commiteada).
Lectura repetible: ocurre cuando en el curso de la transacción se lee una fila dos veces, y los valores coinciden.
Lectura no repetible: ocurre cuando en el curso de la transacción se lee una fila dos veces, y los valores no coinciden.
Lectura fantasma: es un registro o varios que aparecen y que fueron insertados por una transacción concurrente commiteada.

'Desarrollarel concepto de JOIN, enumere y explique cada uno de los tipos. Ejemplifique'
INNER JOIN solo muestra las filas  que coincidan, 
OUTER JOIN  mostrara todas las filas de la tabla dominante matcheen o no con los datos de la otra tabla
Puede ser left, rigth o full

'Mencionar que funcionalidades se pueden usar en un stored procedures y que no se pueden hacer en una función.'
En una funcion no se pueden invocar procedimientos
Dentro de una funcion se puede llamar a otra funcion
Se pueden usar funciones dentro de un stored procedure

'Mencione dos objetos que tengan que ver con la seguridad, descríbalos e indique de qué modo puede utilizarlos para dicha funcionalidad.'
Objetos relacionados con la seguridad:
	Vistas: es una consulta que se presenta como una tabla (virtual). Se puede por ej, para algunos usuarios 
	crear una vista de una tabla donde obtenga solo parte de las cantidad real de columnas que tiene la tabla.
	Triggers: son objetos que se relacionan a tablas, y permiten administrar mejor la BD. Se puede por ej, crear 
	un trigger en una tabla que ante un delete de n filas, no haga caso al delete, o escriba un histórico.
	Stores procedures: es un conjunto de instrucciones que se almacenan y ejecutan en la BD. Se puede por ej, 
	crear un SP para obtener un listado de los usuarios que accedieron a determinadas tablas, horarios, etc.


'Beneficios brinda la aplicacion de la normalizacion a diseño de un modelo de base de datos'
Una de las principales ventajas de la normalizacion es que evita todo tipo de redundancias,
a su vez, evita problemas de actualizacion de los datos en la tabla y protege la integridad 
de los mismos.. de esta manera, se dejan los datos precisos, unicos y relevantes segun 
las necesidades del sistema. al disminuir el volumen de los datos, facilita y agiliza 
considerablemente el acceso y las consultas a los mismos.

'Detallar el objeto BD Constraint y su relacion con integridad'
Integridad de Entidad
La integridad de entidades es usada para asegurar que los datos pertenecientes a 
una misma tabla tienen una única manera de identificarse, es decir que cada fila de cada tabla tenga una primary key capaz de identificar 
unívocamente una fila y esa no puede ser nula
PRIMARY KEY CONSTRAINT: Puede estar compuesta por una o más columnas, y deberá representar unívocamente a cada fila de la tabla. 
No debe permitir valores nulos (depende del motor de base de datos).
Integridad Referencial
La integridad referencial es usada para asegurar la coherencia entre datos de dos tablas.
FOREIGN KEY CONSTRAINT:Puede estar compuesta por una o más columnas, y estará referenciando a la PRIMARY KEY de otra tabla.
Los constraints referenciales permiten a los usuarios especificar claves primarias y foráneas para asegurar una relación PADRE-HIJO 
(MAESTRO-DETALLE).

Integridad Semántica
La integridad semántica es la que nos asegura que los datos que vamos a almacenar tengan una apropiada configuración y que 
respeten las restricciones definidas sobre los dominios o sobre los atributos.
•DATA TYPE 
•DEFAULT
•UNIQUE
•NOT NULL
•CHECK

Integridad Semántica (explicada mejor arriba)
DATA TYPE: Este define el tipo de valor que se puede almacenar en una columna. 
DEFAULT CONSTRAINT: Es el valor insertado en una columna cuando al insertar un registro ningún valor fue especificado para dicha columna. El valor default por default es el NULL. 
Se aplica a columnas no listadas en una sentencia INSERT.
El valor por default puede ser un valor literal o una función SQL (USER, TODAY, etc.)
Aplicado sólo durante un INSERT (NO UPDATE).
UNIQUE CONSTRAINT: Especifica sobre una o más columnas que la inserción o actualización de una fila contiene un valor único en esa columna o conjunto de columnas.
NOT NULL CONSTRAINT:Asegura que una columna contenga un valor durante una operación de INSERT o UPDATE. Se considera el NULL como la ausencia de valor.

CHECK CONSTRAINT: Especifica condiciones para la inserción o modificación en una columna. Cada fila insertada en una tabla debe cumplir con dichas condiciones. 
Actúa tanto en el INSERT, como en el UPDATE.
Es una expresión que devuelve un valor booleano de TRUE o FALSE.
Son aplicados para cada fila que es INSERTADA o MODIFICADA.
Todas las columnas a las que referencia deben ser de la misma tabla (la corriente). 
No puede contener subconsultas, secuencias, funciones (de fecha, usuario) ni pseudocolumnas.
Todas las filas existentes en una tabla deben pasar un nuevo constraint creado para dicha tabla. En el caso de que alguna de las filas no cumpla, no se podrá crear dicho constraint o se creará en estado deshabilitado.

'Cómo implementaría la integridad referencial entre dos tablas de dos bases de datos en diferentes servidores.'
Con un trigger con el ejemplo de arriba

'Diferencias entre Store procedure, Función y Trigger.'
Los SPs son procedimientos almacenados en una BD, los cuales son ejecutados por un usuario o por otro proceso,
y pueden realizar operaciones varias como altas, bajas y modificaciones de tablas. En cambio las Funciones no pueden hacer 
modificaciones de tablas, solo hacer consultas y retornar un valor. Los trigger se ejecutan automáticamente ante 
eventos (insert, delete, update) en las tablas y al igual que en los SPs, puede hacerce operaciones varias.

'Desarrolle el concepto de trigger en cuanto a ejecución, instancias y funcionalidad.'
Ejecución: un trigger es un procedimiento que se ejecuta ante un acontecimiento (INSERT, UPDATE, DELETE) sobre una tabla determinada.
Tipos: se puede aplicar a la fila que disparó el trigger o a todas las filas.
Before, After & Instead of (en lugar del evento que lo invocó).
Atomicidad: si un error ocurre cuando un trigger se está ejecutando, la operación que disparó el trigger falla, 
o sea que no se modifica la tabla.
Uso: se usan triggers cuando la integridad referencial y los constraints son insuficientes; reglas de consistencia 
(no provistas por el modelo relacional); replicación de datos; auditoría; acciones en cascada; autorización de seguridad; 
los triggers constituyen la herramienta más potente para el mantenimiento de la integridad de la base de datos, ya que 
pueden llevar a cabo cualquier acción que sea necesaria para mantener dicha integridad; un trigger puede modificar filas 
de una tabla que un usuario no puede modificar directamente; pueden llamar procedimientos y disparar otros triggers, pero no 
pueden llevar parámetros.
Ventaja: la principal ventaja es que permiten a los usuarios crear y mantener un conjunto de código más manejable para 
su empleo por todas las aplicaciones asociadas con las base de datos existentes y futuras.
Tablas virtuales: tiene acceso a tablas virtuales de sólo lectura INSERTED y DELETED.
Recursividad: un trigger puede disparar una acción que a su vez, lance otro trigger y así sucesivamente.