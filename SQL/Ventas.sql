
--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


CREATE OR ALTER PROCEDURE Importar_ventas_csv
@RutaArchivo NVARCHAR(400)
AS
BEGIN
	DECLARE @Dinamico NVARCHAR(max)
	IF OBJECT_ID('tempdb..##TempVentas') IS NOT NULL
    BEGIN
        DROP TABLE ##TempVentas;
    END

	CREATE TABLE ##TempVentas
    (
        id_factura NVARCHAR(20),
        tipo_factura VARCHAR(5),
        ciudad VARCHAR(50),
        tipo_cliente VARCHAR(20),
        genero VARCHAR(10),
        producto NVARCHAR(100),
        precio_unitario DECIMAL(10, 2),
        cantidad INT,
        fecha DATE,
        hora TIME(7),
        medio_pago VARCHAR(20),
        empleado INT,
        identificador_pago VARCHAR(50)
    );

	SET @Dinamico = 'BULK INSERT ##TempVentas
	FROM ''' + @RutaArchivo + ''' WITH
	(
		FORMAT = ''CSV'',
		FIELDTERMINATOR = '';'', 
		ROWTERMINATOR = ''0x0a'', 
		CODEPAGE = ''65001'', 
		FIRSTROW = 2
	);'

	exec sp_executesql @Dinamico; 

	INSERT INTO gestion_venta.Factura(id, fecha, hora, id_medioDePago)
		SELECT 
		v.id_factura AS id,
		v.fecha AS fecha,
		v.hora AS hora,
		m.id AS id_medioDePago
		FROM ##TempVentas AS v
		inner join gestion_venta.MedioDePago AS m on m.nombre = v.medio_pago  COLLATE MODERN_SPANISH_CI_AS;

	INSERT INTO gestion_venta.DetalleVenta(id_factura, cantidad, subtotal, precio_unitario)
		SELECT 
		v.id_factura AS id_factura,
		v.cantidad AS cantidad,
		(v.precio_unitario * v.cantidad) as subtotal,
		v.precio_unitario as precio_unitario
		FROM ##TempVentas AS v

	--DROP TABLE ##TempVentas;
END
GO

DECLARE @RutaArchivo NVARCHAR(255);
SET @RutaArchivo = N'C:\Users\Public\Downloads\TP_integrador_Archivos\Ventas_registradas.csv'
EXEC Importar_ventas_csv @RutaArchivo



--select * from ##TempVentas;
select * from gestion_venta.DetalleVenta
--DELETE FROM gestion_venta.DetalleVenta
select * from gestion_venta.Factura
--DELETE FROM gestion_venta.Factura
