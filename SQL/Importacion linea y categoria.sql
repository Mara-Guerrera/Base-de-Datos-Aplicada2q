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

sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO
--EXEC sp_enum_oledb_providers;
-- Importar los datos del Excel
SELECT * INTO #TempImport
FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0', 
                'Excel 12.0;Database=C:\Users\Public\Downloads\TP_integrador_Archivos\Informacion_complementaria.xlsx; HDR=YES', 
                'SELECT [Línea de producto], [Producto] FROM [Clasificacion Productos$B:C]');


-- Insertar los datos en TipoProducto
INSERT INTO gestion_productos.TipoProducto (nombre)
SELECT DISTINCT [Línea de producto]
FROM #TempImport
WHERE [Línea de producto] IS NOT NULL;

SELECT *
FROM gestion_productos.TipoProducto
-- Ahora, vincular los productos a los tipos
INSERT INTO gestion_productos.Catalogo (nombre_catalogo, id_tipoProducto)
SELECT 
    Tabla.[Producto],
    Linea.id
FROM #TempImport Tabla JOIN gestion_productos.TipoProducto Linea 
ON Tabla.[Línea de producto] = Linea.nombre COLLATE Modern_Spanish_CI_AI
WHERE 
    Tabla.[Producto] IS NOT NULL;

SELECT * FROM gestion_productos.Catalogo
WHERE id_tipoProducto = 11
-- Limpiar la tabla temporal
DROP TABLE #TempImport;

