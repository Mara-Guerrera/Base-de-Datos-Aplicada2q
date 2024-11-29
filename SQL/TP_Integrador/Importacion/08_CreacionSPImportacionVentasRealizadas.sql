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
-- ============================ SP IMPORTACION VENTAS ============================

CREATE OR ALTER PROCEDURE gestion_venta.Importar_ventas_csv
	@RutaArchivo NVARCHAR(400)
AS
BEGIN

	DECLARE @Dinamico NVARCHAR(max)
	IF OBJECT_ID('tempdb..#TempVentas') IS NOT NULL
    BEGIN
        DROP TABLE #TempVentas;
    END

	CREATE TABLE #TempVentas
    (
        id_factura VARCHAR(20),
        tipo_factura VARCHAR(5),
        ciudad VARCHAR(50),
        tipo_cliente VARCHAR(20),
        genero VARCHAR(10),
        producto VARCHAR(100),
        precio_unitario DECIMAL(10, 2),
        cantidad INT,
        fecha VARCHAR(20),  -- Formato dd/mm/aa
        hora VARCHAR(20),
        medio_pago VARCHAR(20),
        empleado INT,
        identificador_pago VARCHAR(50)
    );

	SET @Dinamico = 'BULK INSERT #TempVentas
	FROM ''' + @RutaArchivo + ''' WITH
	(
		CODEPAGE = ''65001'',
		FIELDTERMINATOR = '';'',
		ROWTERMINATOR = ''0x0a'',
		FIRSTROW = 2
	);'

	exec sp_executesql @Dinamico; 

	--Inserción de tipos de factura-- Revisar si es lo más óptimo (hay 1000 registros)
	INSERT INTO gestion_venta.TipoFactura(nombre)
	SELECT DISTINCT tipo_factura
	FROM #TempVentas AS v
	WHERE NOT EXISTS (
		SELECT 1 
		FROM gestion_venta.TipoFactura AS t
		WHERE t.nombre = v.tipo_factura
	);

	UPDATE #TempVentas
	SET producto = REPLACE(producto, 'Ã¡', 'á')
	WHERE producto LIKE '%Ã¡%';

	UPDATE #TempVentas
	SET producto = REPLACE(producto, 'Ã©', 'é')
	WHERE producto LIKE '%Ã©%';

	UPDATE #TempVentas
	SET producto = REPLACE(producto, 'Ã³', 'ó')
	WHERE producto LIKE '%Ã³%';

	UPDATE #TempVentas
	SET producto = REPLACE(producto, 'Ãº', 'ú')
	WHERE producto LIKE '%Ãº%';

	UPDATE #TempVentas
	SET producto = REPLACE(producto, 'ÃƒÂº', 'ú')
	WHERE producto LIKE '%ÃƒÂº%';

	UPDATE #TempVentas
	SET producto = REPLACE(producto, 'Ã±', 'ñ')
	WHERE producto LIKE '%Ã±%';

	UPDATE #TempVentas
	SET producto = REPLACE(producto, 'Ã‘', 'Ñ')
	WHERE producto LIKE '%Ã‘%';

	UPDATE #TempVentas
	SET producto = REPLACE(producto, 'Ã­' , 'í')
	WHERE producto LIKE '%Ã%';

	UPDATE #TempVentas
	SET producto = REPLACE(producto, 'Ã', 'Á')
	WHERE producto LIKE '%Ã%';

	UPDATE #TempVentas
	SET producto = REPLACE(producto, 'Âº', 'º')
	WHERE producto LIKE '%Âº%';

	UPDATE #TempVentas
	SET producto = REPLACE(producto, 'aå˜ojo', 'añojo')
	WHERE producto LIKE '%aå˜ojo%';
	
	BEGIN TRANSACTION
		BEGIN TRY
		
		INSERT INTO gestion_venta.Factura(id_factura,id_tipoFactura,fecha,hora,id_medioDePago,id_sucursal,id_empleado)
		SELECT
			te.id_factura,
			tf.id id_tipoFactura,
			TRY_CONVERT(DATE, te.fecha, 101) AS fecha,
			CONVERT(TIME(7), te.hora) AS hora_convertida,
			mp.id id_medioDePago,
			s.id id_sucursal,
			e.id id_empleado 
		FROM #TempVentas te 
		JOIN gestion_venta.TipoFactura tf ON tf.nombre = te.tipo_factura
		JOIN gestion_venta.MedioDePago mp ON mp.nombre = te.medio_pago 
		JOIN gestion_sucursal.Sucursal s ON ( 
				(s.nombre = 'San Justo' AND te.ciudad = 'Yangon') OR 
				(s.nombre = 'Ramos mejia' AND te.ciudad = 'Naypyitaw') OR 
				(s.nombre = 'Lomas del mirador' AND te.ciudad = 'Mandalay') OR 
				s.nombre = te.ciudad
			)
		JOIN gestion_sucursal.Empleado e ON e.legajo = te.empleado 
		WHERE NOT EXISTS (
		SELECT 1
		FROM gestion_venta.Factura f
		WHERE f.id_factura = te.id_factura
		);

		INSERT INTO gestion_venta.DetalleVenta(id_factura, cantidad, precio_unitario, id_producto, subtotal)
		SELECT 
			f.id AS id_factura_interno,
			te.cantidad, 
			te.precio_unitario, 
			(SELECT TOP 1 p.id 
			FROM gestion_producto.Producto p 
			WHERE te.producto = p.descripcion) AS id_producto,
			(te.precio_unitario * te.cantidad) AS subtotal
		FROM 
		#TempVentas te 
		JOIN 
			gestion_venta.Factura f 
		ON 
			f.id_factura = te.id_factura
		WHERE 
		NOT EXISTS (
			SELECT 1
			FROM gestion_venta.DetalleVenta dv
			WHERE dv.id_factura = f.id
			  AND dv.id_producto = (SELECT TOP 1 p.id 
									FROM gestion_producto.Producto p 
									WHERE te.producto = p.descripcion)
		);
		COMMIT TRANSACTION;
		END TRY
	BEGIN CATCH
		PRINT ERROR_MESSAGE(); 
		ROLLBACK TRANSACTION;
	END CATCH

	DROP TABLE #TempVentas;
END
GO


/*
SELECT * FROM gestion_venta.DetalleVenta
WHERE id_factura = 10
SELECT * FROM gestion_venta.Factura
SELECT * FROM gestion_venta.TipoFactura
DELETE FROM gestion_venta.DetalleVenta
DELETE FROM gestion_venta.Factura
DELETE FROM gestion_venta.TipoFactura
DBCC CHECKIDENT ('gestion_venta.Factura', RESEED, 0);
DBCC CHECKIDENT ('gestion_venta.DetalleVenta', RESEED, 0);
DBCC CHECKIDENT ('gestion_venta.TipoFactura', RESEED, 0);
*/
