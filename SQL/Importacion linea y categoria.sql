/*Se proveen los archivos en el TP_integrador_Archivos.zip
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
interpretarlo como JSON o CSV).*/

/*sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO*/

CREATE OR ALTER PROCEDURE Importar_TipoProducto
AS
BEGIN
	SELECT 
		[Línea de producto] AS tipo_producto,
		[Producto] AS categoria
	INTO #TempImport
	FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0', 
                'Excel 12.0;Database=C:\Users\Public\Downloads\TP_integrador_Archivos\Informacion_complementaria.xlsx; HDR=YES', 
                'SELECT [Línea de producto], [Producto] FROM [Clasificacion Productos$B:C]');

	--SELECT * FROM #TempImport;
	WITH DuplicadosTipo AS	(
		SELECT DISTINCT te.tipo_producto AS tipo_duplicado
		FROM #TempImport te JOIN gestion_producto.TipoProducto tp ON te.tipo_producto = tp.nombre COLLATE MODERN_SPANISH_CI_AS
	) 
	--Verificación de Duplicados en Tipo de producto
	INSERT INTO gestion_producto.TipoProducto (nombre)
	SELECT DISTINCT tipo_producto
	FROM #TempImport te
	WHERE tipo_producto IS NOT NULL
	AND NOT EXISTS (
          SELECT 1
          FROM DuplicadosTipo d
          WHERE d.tipo_duplicado = te.tipo_producto
     );
	--Verificación de categorías ya existentes pero que cambiaron de tipo de producto en el archivo.
	WITH Duplicados_Modificados AS (
	SELECT 
		c.id AS id_categoria,  
	        tp.id AS id_tipoProducto_nuevo
	FROM #TempImport te
	JOIN gestion_producto.Categoria c ON te.categoria = c.nombre  COLLATE MODERN_SPANISH_CI_AS
	JOIN gestion_producto.TipoProducto tp ON te.tipo_producto = tp.nombre  COLLATE MODERN_SPANISH_CI_AS--Busco el id tipo_producto del archivo.
	WHERE tp.id <> c.id_tipoProducto --Donde coincida la categoría pero no el id_tipo_producto.
	)
	UPDATE c
	SET c.id_tipoProducto = dm.id_tipoProducto_nuevo
	FROM gestion_producto.Categoria c
	JOIN Duplicados_Modificados dm ON c.id = dm.id_categoria
	--Verifico que el id_tipoProducto_nuevo exista.
	WHERE EXISTS (
		SELECT 1
		FROM gestion_producto.TipoProducto tp
		WHERE tp.id = dm.id_tipoProducto_nuevo
	);
	--Proceso para insertar las categorías obviando los duplicados.
	WITH Duplicados_Categoria AS (
	SELECT 
	te.categoria
	FROM #TempImport te 
	JOIN gestion_producto.Categoria c ON te.categoria = c.nombre COLLATE MODERN_SPANISH_CI_AS
	)
	INSERT INTO gestion_producto.Categoria (nombre, id_tipoProducto)
	SELECT 
		te.categoria,
		tp.id
	FROM #TempImport te JOIN gestion_producto.TipoProducto tp
	ON te.tipo_producto = tp.nombre COLLATE MODERN_SPANISH_CI_AS
	WHERE 
    	te.categoria IS NOT NULL AND NOT EXISTS (
          SELECT 1
          FROM Duplicados_Categoria c
          WHERE c.categoria = te.categoria
     	);
	DROP TABLE #TempImport
END


CREATE OR ALTER PROCEDURE Importar_Medios_de_Pago
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

    DROP TABLE #TempMedios;
END;

DECLARE @RutaArchivo NVARCHAR(255);
SET @RutaArchivo = N'C:\Users\Public\Downloads\TP_integrador_Archivos\Informacion_complementaria.xlsx';
EXEC Importar_Medios_de_Pago @RutaArchivo;

CREATE OR ALTER PROCEDURE Importar_Productos_Importados
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
	SELECT * FROM #TempImportados
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
	INSERT INTO gestion_producto.Proveedor(nombre)
	SELECT DISTINCT ti.Proveedor
	FROM #TempImportados ti
	WHERE ti.Proveedor IS NOT NULL
	AND NOT EXISTS (
		SELECT 1
		FROM gestion_producto.Proveedor p
		WHERE ti.Proveedor = p.nombre
	);

	--Inserción de productos--
	INSERT INTO gestion_producto.Producto(descripcion, precio, cant_por_unidad, id_categoria,id_proveedor)
	SELECT 
	ti.NombreProducto, 
	CAST(ti.PrecioUnidad AS DECIMAL(7,2)) PrecioUnidad,
	ti.CantidadPorUnidad, 
	CAST(c.id AS INT) id_catalogo,
	CAST(pv.id AS INT) id_proveedor
	FROM #TempImportados ti
	JOIN gestion_producto.Categoria c 
	ON ti.Categoria LIKE '%' + c.nombre + '%' 
	JOIN gestion_producto.Proveedor pv ON pv.nombre = ti.Proveedor
	WHERE NOT EXISTS (
		SELECT 1 
		FROM gestion_producto.Producto p 
		WHERE p.descripcion = ti.NombreProducto
	);
	
	DROP TABLE #TempImportados

END
GO
DECLARE @RutaArchivo NVARCHAR(255);
SET @RutaArchivo = N'C:\Users\Public\Downloads\TP_integrador_Archivos\Productos\Productos_importados.xlsx'
EXEC Importar_Productos_Importados @RutaArchivo

ALTER TABLE gestion_producto.Producto
ALTER COLUMN descripcion VARCHAR(100)

CREATE OR ALTER PROCEDURE Importar_catalogo_csv
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
DECLARE @RutaArchivo NVARCHAR(255);
SET @RutaArchivo = N'C:\Users\Public\Downloads\TP_integrador_Archivos\Productos\catalogo.csv'
EXEC Importar_catalogo_csv @RutaArchivo
GO
CREATE OR ALTER PROCEDURE Importar_Electronicos
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
	INSERT INTO gestion_producto.Producto(descripcion,precio)
	SELECT * FROM #TempElectronico te
	WHERE NOT EXISTS (
	SELECT 1
	FROM gestion_producto.Producto p WHERE p.descripcion = te.Nombre_Producto
	)
END
GO
DECLARE @RutaArchivo NVARCHAR(255);
SET @RutaArchivo = N'C:\Users\Public\Downloads\TP_integrador_Archivos\Productos\Electronic accessories.xlsx'
EXEC Importar_Electronicos @RutaArchivo


--Consultas y borrados--
SELECT * FROM gestion_producto.Categoria
SELECT * FROM gestion_producto.TipoProducto 
SELECT * FROM gestion_venta.MedioDePago 
SELECT * FROM #TempImport
--DELETE FROM gestion_venta.MedioDePago
--DELETE FROM gestion_producto.Categoria
--DELETE FROM gestion_producto.TipoProducto 
DBCC CHECKIDENT ('gestion_producto.Categoria', RESEED, 0);
DBCC CHECKIDENT ('gestion_producto.TipoProducto', RESEED, 0);
DBCC CHECKIDENT ('gestion_venta.MedioDePago', RESEED, 0);

EXEC Importar_TipoProducto
