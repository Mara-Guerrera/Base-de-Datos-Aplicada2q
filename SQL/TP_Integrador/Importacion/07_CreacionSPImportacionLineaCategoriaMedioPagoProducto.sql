/*
		BASE DE DATOS APLICADA
		GRUPO: 05
		COMISION: 02-5600
		INTEGRANTES:
			María del Pilar Bourdieu 45289653
			Abigail Karina Peñafiel Huayta	41913506
			Federico Pucci 41106855
			Mara Verónica Guerrera 40538513

		FECHA DE ENTREGA: 29/11/2024

ENTREGA 4:

Se proveen los archivos en el TP_integrador_Archivos.zip
Ver archivo “Datasets para importar” en Miel.
Se requiere que importe toda la información antes mencionada a la base de datos:
• Genere los objetos necesarios (store procedures, funciones, etc.) para importar los
archivos antes mencionados. Tenga en cuenta que cada mes se recibirán archivos de
novedades con la misma estructura, pero datos nuevos para agregar a cada maestro.
• Considere este comportamiento al generar el código. Debe admitir la importación de
novedades periódicamente.
• Cada maestro debe importarse con un SP distinto. No se aceptarán scripts que
realicen tareas por fuera de un SP.
• La estructura/esquema de las tablas a generar será decisión suya. Puede que deba
realizar procesos de transformación sobre los maestros recibidos para adaptarlos a la
estructura requerida.
• Los archivos CSV/JSON no deben modificarse. En caso de que haya datos mal
cargados, incompletos, erróneos, etc., deberá contemplarlo y realizar las correcciones
en el fuente SQL. (Sería una excepción si el archivo está malformado y no es posible
interpretarlo como JSON o CSV).
*/

-- ============================ STORED PROCEDURES IMPORTACION ============================

/*sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO*/

USE Com5600G05
GO
-- ============================ SP IMPORTACION TIPO PRODUCTO Y CATEGORIA ============================

CREATE OR ALTER PROCEDURE gestion_producto.Importar_TipoProducto_Categoria
	@Ruta NVARCHAR(400)
AS
BEGIN
	
	DECLARE @Dinamico NVARCHAR(MAX);
	CREATE TABLE #TempImport
	(
		tipo_producto VARCHAR(40),
		categoria VARCHAR(50)
	)
	SET @Dinamico = N'
	INSERT INTO #TempImport (tipo_producto,categoria)
	SELECT 
		[Línea de producto] AS tipo_producto,
		[Producto] AS categoria
	FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'', 
					''Excel 12.0;Database=' + @Ruta + N';HDR=YES'',
					''SELECT [Línea de producto],[Producto] FROM [Clasificacion Productos$B:C]'');'
	EXEC sp_executesql @Dinamico;

	--Verificación de Duplicados en Tipo de producto
	INSERT INTO gestion_producto.TipoProducto (nombre)
	SELECT DISTINCT tipo_producto
	FROM #TempImport te
	WHERE tipo_producto IS NOT NULL
	AND NOT EXISTS (
          SELECT 1
          FROM gestion_producto.TipoProducto p
          WHERE p.nombre = te.tipo_producto
     );

	--Proceso para insertar las categorías obviando los duplicados.
	INSERT INTO gestion_producto.Categoria (nombre, id_tipoProducto)
	SELECT 
		te.categoria,
		tp.id
	FROM #TempImport te JOIN gestion_producto.TipoProducto tp
	ON te.tipo_producto = tp.nombre 
	WHERE 
    	te.categoria IS NOT NULL AND NOT EXISTS (
          SELECT 1
          FROM gestion_producto.Categoria c
          WHERE c.nombre = te.categoria
     	);
	DROP TABLE #TempImport
END
GO
-- ============================ SP IMPORTACION MEDIOS DE PAGO ============================

CREATE OR ALTER PROCEDURE gestion_venta.Importar_Medios_de_Pago
    @RutaArchivo NVARCHAR(255)
AS
BEGIN
	
    DECLARE @Dinamico NVARCHAR(MAX);
	IF OBJECT_ID('tempdb..#TempMedios') IS NOT NULL
    BEGIN
        DROP TABLE #TempMedios;
    END
	CREATE TABLE #TempMedios
	(
		nombre VARCHAR(20),
		descripcion VARCHAR(30)
	)
	SET @Dinamico = N'
	INSERT INTO #TempMedios
	SELECT F1 AS Nombre, F2 AS Descripcion
	FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
					''Excel 12.0;Database=' + @RutaArchivo + N';HDR=YES'',
					''SELECT F1, F2 FROM [medios de pago$B2:C100]'');';
	
    EXEC sp_executesql @Dinamico;
	
    INSERT INTO gestion_venta.MedioDePago (nombre, descripcion)
    SELECT nombre, descripcion FROM #TempMedios
	WHERE NOT EXISTS (SELECT 1 FROM gestion_venta.MedioDePago m INNER JOIN #TempMedios t ON m.nombre = t.nombre)
	--Cambiar lo del INNER JOIN (no es necesario)--
    DROP TABLE #TempMedios;
END;
GO
-- ============================ SP IMPORTACION PRODUCTOS ============================

CREATE OR ALTER PROCEDURE gestion_producto.Importar_Productos_Importados
	@RutaArchivo NVARCHAR(255)
AS
BEGIN

	DECLARE @Dinamico NVARCHAR(MAX);
	IF OBJECT_ID('tempdb..#TempImportados') IS NOT NULL
    BEGIN
        DROP TABLE #TempImportados;
    END
	CREATE TABLE #TempImportados
	(
		id INT,         
		NombreProducto VARCHAR(50),
		Proveedor VARCHAR(100),
		Categoria VARCHAR(50),
		CantidadPorUnidad VARCHAR(50),
		PrecioUnidad VARCHAR(10),
	);
	SET @Dinamico = N'
	INSERT INTO #TempImportados
	SELECT *
	FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
					''Excel 12.0;Database=' + @RutaArchivo + N';HDR=YES'',
					''SELECT * FROM [Listado de productos$]'');';


	EXEC sp_executesql @Dinamico;

	--Inserción de categorías que no estén cargadas previamente en la base de datos--
	INSERT INTO gestion_producto.Categoria(nombre)
	SELECT DISTINCT ti.Categoria
	FROM #TempImportados ti
	WHERE ti.Categoria IS NOT NULL
	AND NOT EXISTS (
		SELECT 1
		FROM gestion_producto.Categoria c
		WHERE ti.Categoria LIKE '%' + c.nombre + '%'
	);
	--Inserción de proveedores que no estén cargados previamente en la base de datos--
	INSERT INTO gestion_producto.Proveedor(nombre)
	SELECT DISTINCT ti.Proveedor
	FROM #TempImportados ti
	WHERE ti.Proveedor IS NOT NULL
	AND NOT EXISTS (
		SELECT 1
		FROM gestion_producto.Proveedor p
		WHERE ti.Proveedor = p.nombre
	);
	--Manejo de duplicados (productos ya existentes) pero con precios nuevos--
	WITH Duplicados_a_Actualizar AS
	(
		SELECT p.id id_producto, ti.PrecioUnidad precio_nuevo
		FROM gestion_producto.Producto p INNER JOIN #TempImportados ti 
		ON p.descripcion = ti.NombreProducto
		INNER JOIN gestion_producto.Categoria c ON p.id_categoria = c.id
		WHERE p.precio <> ti.PrecioUnidad AND c.nombre = ti.Categoria
	)
	UPDATE p
	SET p.precio = d.precio_nuevo
	FROM gestion_producto.Producto p
	INNER JOIN Duplicados_a_Actualizar d ON p.id = d.id_producto;

	--Inserción de productos--
	INSERT INTO gestion_producto.Producto(descripcion, precio, cant_por_unidad, id_categoria,id_proveedor)
	SELECT 
	ti.NombreProducto, 
	CAST(ti.PrecioUnidad AS DECIMAL(7,2)) PrecioUnidad,
	ti.CantidadPorUnidad,
	( 
	SELECT TOP 1 c.id
	FROM gestion_producto.Categoria c
	WHERE ti.Categoria LIKE '%' + c.nombre + '%'
	ORDER BY c.id
	) AS id_categoria,
	CAST(pv.id AS INT) id_proveedor
	FROM #TempImportados ti
	JOIN gestion_producto.Proveedor pv ON pv.nombre = ti.Proveedor
	WHERE NOT EXISTS (
		SELECT 1 
		FROM gestion_producto.Producto p 
		WHERE p.descripcion = ti.NombreProducto
	)
	DROP TABLE #TempImportados
END
GO

CREATE OR ALTER PROCEDURE gestion_producto.Importar_catalogo_csv
	@RutaArchivo NVARCHAR(400)
AS
BEGIN

	DECLARE @Dinamico NVARCHAR(max)
	IF OBJECT_ID('tempdb..#TempCatalogo') IS NOT NULL
    BEGIN
        DROP TABLE #TempCatalogo;
    END
	CREATE TABLE #TempCatalogo
	(
		id INT,         
		category VARCHAR(50),
		name VARCHAR(100),
		price VARCHAR(20),
		reference_price VARCHAR(20),
		reference_unit VARCHAR(10),
		fecha VARCHAR(20)
	)
	SET @Dinamico = 'BULK INSERT #TempCatalogo
	FROM ''' + @RutaArchivo + ''' WITH
	(
		FORMAT = ''CSV'',
		FIELDTERMINATOR = '','', 
		ROWTERMINATOR = ''0x0a'', 
		CODEPAGE = ''65001'', 
		FIRSTROW = 2
	);'
	exec sp_executesql @Dinamico; 
	--Registros detectados con errores de interpretación que no se corrigen con el CODEPAGE-

	UPDATE #TempCatalogo
	SET name = REPLACE(REPLACE(name, 'a?ojo', 'añojo'), 'aå˜ojo', 'añojo')
	WHERE name LIKE '%a?ojo%' 
	OR name LIKE '%aå˜ojo%';

	UPDATE #TempCatalogo
	SET name = REPLACE(name, 'traslÃºcido', 'traslúcido')
	WHERE name LIKE '%traslÃºcido%';

	--Código para evitar duplicados: coincidencia de nombre de producto y categoría pero diferencia en precio--
	WITH Duplicados AS (
	SELECT
	te.name, 
	te.id,
        te.category,
        te.price,
        te.reference_price,
        ROW_NUMBER() OVER (PARTITION BY te.name, te.category  ORDER BY te.id) AS RowNum,
	COUNT(1) OVER (PARTITION BY te.name, te.category ORDER BY (SELECT NULL)) AS cant
	FROM #TempCatalogo te
	)
	DELETE FROM #TempCatalogo
	WHERE id IN (
	SELECT d.id
	FROM Duplicados d
	WHERE d.cant > 1 
	AND d.RowNum < d.cant
	);
	--Inserción de productos en tabla gestion_producto.Producto--
	WITH CTE AS (
		SELECT 
			te.name,
			te.price,
			c.id id_categoria,
			te.reference_price,
			te.reference_unit
		FROM #TempCatalogo te
		INNER JOIN gestion_producto.Categoria c ON c.nombre = te.category 
	)
	INSERT INTO gestion_producto.Producto(descripcion, precio, id_categoria, precio_ref, unidad_ref)
	SELECT 
    name,
    CAST(price AS DECIMAL(7,2)) price,
    id_categoria,
    CAST(reference_price AS DECIMAL(7,2)) reference_price,
    CAST(reference_unit AS CHAR(3)) reference_unit
	FROM CTE c
	WHERE NOT EXISTS (
		SELECT 1 
		FROM gestion_producto.Producto p 
		WHERE p.descripcion = c.name
	);
	DROP TABLE #TempCatalogo;
END
GO

CREATE OR ALTER PROCEDURE gestion_producto.Importar_Electronicos
	@RutaArchivo NVARCHAR(400)
AS
BEGIN

	DECLARE @Dinamico NVARCHAR(max)
	IF OBJECT_ID('tempdb..#TempElectronico') IS NOT NULL
    BEGIN
        DROP TABLE #TempElectronico;
    END
	CREATE TABLE #TempElectronico
	(
		id INT IDENTITY(1,1),
		Nombre_Producto VARCHAR(100),
		Precio_Unitario DECIMAL(7,2)
	)
	SET @Dinamico = N'
	INSERT INTO #TempElectronico
	SELECT *
	FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
					''Excel 12.0;Database=' + @RutaArchivo + N';HDR=YES'',
					''SELECT [Product],[Precio Unitario en dolares] FROM [Sheet1$]'');';

	EXEC sp_executesql @Dinamico;
	--Búsqueda de Duplicados dentro del mismo archivo--
	WITH Duplicados AS
	(	SELECT 
		id,
		ROW_NUMBER() OVER (PARTITION BY te.Nombre_Producto ORDER BY (SELECT NULL)) AS RowNum
		FROM #TempElectronico te
	)
	DELETE FROM #TempElectronico 
	WHERE id IN (
	SELECT d.id
	FROM Duplicados d
	WHERE RowNum > 1
	)
	--Inserción en tabla gestion_producto.Producto--
	INSERT INTO gestion_producto.Producto(descripcion,precio)
	SELECT Nombre_Producto,Precio_Unitario FROM #TempElectronico te
	WHERE NOT EXISTS (
	SELECT 1
	FROM gestion_producto.Producto p WHERE p.descripcion = te.Nombre_Producto
	)
END
GO

--Consultas y borrados--
/*
SELECT * FROM gestion_producto.Categoria
SELECT * FROM gestion_producto.TipoProducto
SELECT * FROM gestion_producto.Producto
SELECT * FROM gestion_venta.MedioDePago
SELECT * FROM #TempImport
DELETE FROM gestion_venta.DetalleVenta
DELETE FROM gestion_producto.Producto
DELETE FROM gestion_producto.Categoria
DELETE FROM gestion_producto.TipoProducto
DELETE FROM gestion_venta.MedioDePago
DBCC CHECKIDENT ('gestion_producto.Categoria', RESEED, 0);
DBCC CHECKIDENT ('gestion_producto.Producto', RESEED, 0);
DBCC CHECKIDENT ('gestion_producto.TipoProducto', RESEED, 0);
DBCC CHECKIDENT ('gestion_venta.MedioDePago', RESEED, 0);*/

