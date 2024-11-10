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

--DROP TABLE #TempImport
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
		FROM #TempImport te JOIN gestion_producto.TipoProducto tp ON te.tipo_producto = tp.nombre
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
	JOIN gestion_producto.Categoria c ON te.categoria = c.nombre 
	JOIN gestion_producto.TipoProducto tp ON te.tipo_producto = tp.nombre --Busco el id tipo_producto del archivo.
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
	JOIN gestion_producto.Categoria c ON te.categoria = c.nombre
	)
	INSERT INTO gestion_producto.Categoria (nombre, id_tipoProducto)
	SELECT 
		te.categoria,
		tp.id
	FROM #TempImport te JOIN gestion_producto.TipoProducto tp
	ON te.tipo_producto = tp.nombre 
	WHERE 
    	te.categoria IS NOT NULL AND NOT EXISTS (
          SELECT 1
          FROM Duplicados_Categoria c
          WHERE c.categoria = te.categoria
     	);
	DROP TABLE #TempImport
END


SELECT * INTO #TempMedios
FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0', 
                'Excel 12.0;Database=C:\Users\Public\Downloads\TP_integrador_Archivos\Informacion_complementaria.xlsx; HDR=YES', 
                'SELECT [Medio de pago] FROM [medios de pago$]');


INSERT INTO gestion_venta.MedioDePago(descripcion)
SELECT [Medio de pago]
FROM #TempMedios
DROP TABLE #TempMedios;


CREATE TABLE #TempCatalogo
(
    id INT,         
    category VARCHAR(50),
	name NVARCHAR(100),
	price VARCHAR(50),
	reference_price VARCHAR(50),
	reference_unit VARCHAR(50),
	fecha VARCHAR(50)
);
BULK INSERT #TempCatalogo
FROM 'C:\Users\Public\Downloads\TP_integrador_Archivos\Productos\catalogo.csv'
WITH
(
	FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  
    CODEPAGE = '65001',
    ROWTERMINATOR = '0x0a'   
);
SELECT * 
FROM #TempCatalogo

/*WITH CTE AS (
	SELECT *
	FROM #TempCatalogo te
	INNER JOIN gestion_producto.TipoProducto tp ON tp.nombre 
)*/

DROP TABLE #TempCatalogo
--Consultas y borrados--
SELECT * FROM gestion_producto.Categoria
SELECT * FROM gestion_producto.TipoProducto 
SELECT * FROM gestion_venta.MedioDePago 
SELECT * FROM #TempImport
DELETE FROM gestion_venta.MedioDePago
DELETE FROM gestion_producto.Categoria
DELETE FROM gestion_producto.TipoProducto 
DBCC CHECKIDENT ('gestion_producto.Categoria', RESEED, 0);
DBCC CHECKIDENT ('gestion_producto.TipoProducto', RESEED, 0);
DBCC CHECKIDENT ('gestion_venta.MedioDePago', RESEED, 0);
