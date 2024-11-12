/*sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO*/
USE Com5600G05
GO
CREATE OR ALTER PROCEDURE Importar_ventas_csv
@RutaArchivo NVARCHAR(400)
AS
BEGIN

	--DECLARE @RutaArchivo NVARCHAR(255)
	--SET @RutaArchivo = N'C:\Users\Public\Downloads\TP_integrador_Archivos\Ventas_registradas.csv'
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

	--SELECT * FROM #TempVentas
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
			te.id_factura, 
			te.cantidad, 
			precio_unitario, 
			producto.id id_producto,
			(precio_unitario * cantidad) AS subtotal
		FROM 
			#TempVentas te 
		JOIN 
			gestion_producto.Producto producto 
		ON 
			producto.descripcion = te.producto
		WHERE NOT EXISTS (
		SELECT 1
		FROM gestion_venta.DetalleVenta dv
		WHERE dv.id_factura = te.id_factura
		  AND dv.id_producto = producto.id
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

DECLARE @RutaArchivo NVARCHAR(255);
SET @RutaArchivo = N'C:\Users\Public\Downloads\TP_integrador_Archivos\Ventas_registradas.csv'
EXEC Importar_ventas_csv @RutaArchivo



/*SELECT * from #TempVentas;
SELECT dv.id,p.descripcion
FROM gestion_venta.DetalleVenta dv INNER JOIN gestion_producto.Producto p ON p.id = dv.id_producto 
ORDER BY id_factura
DELETE FROM gestion_venta.DetalleVenta
SELECT * from gestion_venta.Factura
SELECT dv.id_factura, dv.id_producto, p.descripcion, dv.cantidad, dv.subtotal, dv.precio_unitario from gestion_venta.DetalleVenta dv
JOIN gestion_producto.Producto p ON dv.id_producto = p.id
ORDER BY dv.id_factura
DELETE FROM gestion_venta.Factura
DELETE FROM gestion_venta.DetalleVenta
DBCC CHECKIDENT ('gestion_venta.Factura', RESEED, 0);
DBCC CHECKIDENT ('gestion_venta.DetalleVenta', RESEED, 0);*/
