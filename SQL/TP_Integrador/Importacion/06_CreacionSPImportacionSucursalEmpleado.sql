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

-- Habilitar Ad Hoc Distributed Queries (si no está habilitado)
/*sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO*/
USE Com5600G05
GO
-- ============================ SP IMPORTACION SUCURSALES ============================

CREATE OR ALTER PROCEDURE gestion_sucursal.Importar_Sucursales
	@Ruta NVARCHAR(400)
AS
BEGIN

	DECLARE @Dinamico NVARCHAR(MAX);
	IF OBJECT_ID('tempdb..#TempSucursales') IS NOT NULL
    BEGIN
        DROP TABLE #TempSucursales;
    END
	CREATE TABLE #TempSucursales
	(
		Nombre VARCHAR(30),
		Direccion VARCHAR(150),
		Horario VARCHAR(50),
		Telefono CHAR(9),
		id_empresa INT
	)
	
	SET @Dinamico = N'
	INSERT INTO #TempSucursales (Nombre, Direccion, Horario, Telefono,id_empresa)
	SELECT 
		 [Reemplazar por] as Nombre,
		 [direccion] as Direccion,
		 [Horario],
		 [Telefono],
		 1 AS id_empresa
	FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'', 
					''Excel 12.0;Database=' + @Ruta + N';HDR=YES'',
					''SELECT [Reemplazar por],[direccion],[Horario],[Telefono] FROM [sucursal$]'');'

	EXEC sp_executesql @Dinamico;
	INSERT INTO gestion_sucursal.Sucursal(nombre,direccion,horario,telefono,id_empresa)
	SELECT *
	FROM #TempSucursales te
	WHERE NOT EXISTS (
		SELECT 1
		FROM gestion_sucursal.Sucursal s WHERE s.nombre = te.Nombre 
	)

	DROP TABLE #TempSucursales
END
GO

-- ============================ SP IMPORTACION EMPLEADOS ============================

CREATE OR ALTER PROCEDURE gestion_sucursal.Importar_Empleados
	@Ruta NVARCHAR(400)
AS
BEGIN

	DECLARE @Dinamico NVARCHAR(MAX);
	IF OBJECT_ID('tempdb..#TempEmpleados') IS NOT NULL
    BEGIN
        DROP TABLE #TempEmpleados;
    END
    CREATE TABLE #TempEmpleados (
		Legajo				INT,
		Nombre				VARCHAR(40),
		Apellido			VARCHAR(40),
		DNI					BIGINT,
		Direccion			VARCHAR(160),
        email_personal		VARCHAR(80),
		email_empresa		VARCHAR(80),
        CUIL				CHAR(13),
		Cargo				VARCHAR(20),
		Sucursal			VARCHAR(20),
		Turno				VARCHAR(20)
    );
	SET @Dinamico = N'
	INSERT INTO #TempEmpleados (legajo, nombre, apellido, dni, direccion, email_personal, email_empresa, CUIL, Cargo, Sucursal, Turno)
	SELECT 
		 [Legajo/ID] Legajo,
		 Nombre,
		 Apellido,
		 DNI,
		 Direccion,
		 [email personal] email_personal,
		 [email empresa] email_empresa,
		 CUIL,
		 Cargo,
		 Sucursal,
		 Turno
	FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'', 
					''Excel 12.0;Database=' + @Ruta + N';HDR=YES'',
					''SELECT [Legajo/ID], Nombre, Apellido, DNI, Direccion, [email personal], [email empresa], CUIL, Cargo, Sucursal, Turno FROM [Empleados$]'');'


	EXEC sp_executesql @Dinamico;
	INSERT INTO gestion_sucursal.Turno (descripcion)
	SELECT DISTINCT Turno
	FROM #TempEmpleados te
	WHERE Turno IS NOT NULL 
	AND NOT EXISTS (
        SELECT 1 
        FROM gestion_sucursal.Turno tu
        WHERE tu.descripcion = te.Turno
    );
	
	INSERT INTO gestion_sucursal.Cargo (nombre)
	SELECT DISTINCT Cargo
	FROM #TempEmpleados te
	WHERE Cargo IS NOT NULL
	AND NOT EXISTS (
        SELECT 1 
        FROM gestion_sucursal.Cargo c
        WHERE c.nombre = te.Cargo
    );

	WITH CTE AS
	(
		SELECT 
		te.Legajo,
		te.Nombre,
		te.Apellido,
		te.DNI,
		te.Direccion,
		email_personal,
		email_empresa,
		CUIL,
		tu.id id_turno,
		c.id id_cargo,
		s.id id_sucursal
		FROM #TempEmpleados te 
		INNER JOIN gestion_sucursal.Turno tu ON tu.descripcion = te.turno
		INNER JOIN gestion_sucursal.Cargo c ON c.nombre = te.Cargo
		INNER JOIN gestion_sucursal.Sucursal s ON s.nombre = te.Sucursal
		
		WHERE te.Legajo IS NOT NULL AND NOT EXISTS (
            	SELECT 1 
            	FROM gestion_sucursal.Empleado e 
				WHERE e.legajo = te.Legajo
       	 	)
	)
	INSERT INTO gestion_sucursal.Empleado (legajo, nombre, apellido, dni, direccion, email, email_empresa, cuil, id_turno, id_cargo, id_sucursal)
	SELECT *
	FROM CTE cte
	WHERE NOT EXISTS (SELECT 1 FROM gestion_sucursal.Empleado e INNER JOIN cte ON e.legajo = cte.legajo);

    -- Limpiar la tabla temporal
    DROP TABLE #TempEmpleados;

    -- Confirmar que todo se completó sin errores
    PRINT 'Importación y registro completados exitosamente.';
END;
GO

/*
--Consultas--
SELECT * FROM gestion_sucursal.Cargo
SELECT * FROM gestion_sucursal.Sucursal
SELECT * FROM gestion_sucursal.Empleado
ORDER BY dni
SELECT * FROM gestion_sucursal.Turno
--Borrados--
DELETE FROM gestion_sucursal.Empleado
DELETE FROM gestion_sucursal.Cargo
DELETE FROM gestion_sucursal.Sucursal
DELETE FROM gestion_sucursal.Turno
--Reinicio contador id incremental--
DBCC CHECKIDENT ('gestion_sucursal.Cargo', RESEED, 0);
DBCC CHECKIDENT ('gestion_sucursal.Turno', RESEED, 0);
DBCC CHECKIDENT ('gestion_sucursal.Sucursal', RESEED, 0);
DBCC CHECKIDENT ('gestion_sucursal.Empleado', RESEED, 0);
*/
