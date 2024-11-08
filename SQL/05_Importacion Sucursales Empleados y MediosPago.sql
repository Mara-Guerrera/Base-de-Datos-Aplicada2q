/*
		BASE DE DATOS APLICADA
		GRUPO: 05
		COMISION: 02-5600
		INTEGRANTES:
			María del Pilar Bourdieu
			Abigail Karina Peñafiel Huayta	41913506
			Federico Pucci
			Mara Verónica Guerrera

		FECHA DE ENTREGA: 08/11/2024

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
sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO
	
-- ============================ SP IMPORTACION SUCURSAL ============================

CREATE OR ALTER PROCEDURE Importar_Sucursales
--    @rutaArchivo VARCHAR(100)
AS
BEGIN
    -- Declaro la tabla temporal: Los campos deben coincidir con los de las columnas del Excel
    CREATE TABLE #TempSucursales (
        Ciudad				VARCHAR(30),
		[Reemplazar por]	VARCHAR(60),
        direccion			VARCHAR(100),
		Horario				VARCHAR(50),
		Telefono			CHAR(9),
    );
	
    INSERT INTO #TempSucursales (Ciudad, [Reemplazar por], direccion, Horario, Telefono)
	SELECT 
		Ciudad, [Reemplazar por], direccion, Horario, Telefono
	FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0', 
	'Excel 12.0;HDR=YES;Database=C:\Users\usuario\Documents\6) BD aplicadas\TP Reporte de Ventas\TP_integrador_Archivos\Informacion_complementaria.xlsx;HDR=NO',
	'SELECT Ciudad, [Reemplazar por], direccion, Horario, Telefono FROM [sucursal$]');
			
	SELECT * FROM #TempSucursales

	INSERT INTO gestion_sucursal.Sucursal (nombre, direccion, horario, telefono)
	SELECT ts.[Reemplazar por], ts.direccion, ts.Horario, ts.Telefono
	FROM #TempSucursales ts
	WHERE nombre = ts.Ciudad

	DROP TABLE #TempMediosPago
	PRINT 'Importación y registro de Sucursales completados exitosamente.';
END
GO
EXEC Importar_Sucursales
GO
-- ============================ SP IMPORTACION EMPLEADOS ============================
	
CREATE OR ALTER PROCEDURE Importar_Empleados
AS
BEGIN
    CREATE TABLE #TempEmpleados (
        [email personal]	VARCHAR(80),
		[email empresa]		VARCHAR(80),
        CUIL				CHAR(13),
		Cargo				VARCHAR(20),
		Sucursal			VARCHAR(20),
		Turno				VARCHAR(20)
    );

	INSERT INTO #TempEmpleados ([email personal], [email empresa], CUIL, Cargo, Sucursal, Turno)
	SELECT 
		 [email personal],
		 [email empresa],
		 CUIL,
		 Cargo,
		 Sucursal,
		 Turno
	FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0', 
					'Excel 12.0;Database=C:\Users\Public\Downloads\TP_integrador_Archivos\Informacion_complementaria.xlsx;HDR=YES',
					'SELECT [email personal], [email empresa], CUIL, Cargo, Sucursal, Turno FROM [Empleados$]');

	INSERT INTO gestion_sucursal.Turno (descripcion)
	SELECT DISTINCT Turno
	FROM #TempEmpleados
	WHERE Turno IS NOT NULL
	
	INSERT INTO gestion_sucursal.Cargo (nombre)
	SELECT DISTINCT Cargo
	FROM #TempEmpleados
	WHERE Cargo IS NOT NULL

	INSERT INTO gestion_sucursal.Sucursal (nombre)
	SELECT DISTINCT Sucursal
	FROM #TempEmpleados
	WHERE Sucursal IS NOT NULL;
	WITH CTE AS
	(
		SELECT 
			te.[email personal],
			te.[email empresa],
			te.CUIL,
			c.id AS id_cargo,  
			s.id AS id_sucursal, 
			t.id AS id_turno
		FROM #TempEmpleados te 
		INNER JOIN gestion_sucursal.Turno t ON t.descripcion = te.turno
		INNER JOIN gestion_sucursal.Cargo c ON c.nombre = te.Cargo
		INNER JOIN gestion_sucursal.Sucursal s ON s.nombre = te.Sucursal
		
		WHERE NOT EXISTS (
            	SELECT 1 
            	FROM gestion_sucursal.Empleado e 
           	WHERE e.email_empresa = te.[email empresa] COLLATE Modern_Spanish_CI_AS
       	 	)
	)
	INSERT INTO gestion_sucursal.Empleado (email, email_empresa, cuil, id_cargo, id_sucursal, id_turno)
	SELECT 
		CTE.[email personal],
		CTE.[email empresa],
		CTE.CUIL,
		CTE.id_cargo,
		CTE.id_sucursal,
		CTE.id_turno
	FROM CTE;

    -- Limpiar la tabla temporal
    DROP TABLE #TempEmpleados;

    -- Confirmar que todo se completó sin errores
    PRINT 'Importación y registro completados exitosamente.';
END;
GO
EXEC ImportarEmpleados
GO
	
-- ============================ SP IMPORTACION MEDIO DE PAGO ============================

CREATE OR ALTER PROCEDURE Importar_MedioDePago
 --   @rutaArchivo VARCHAR(100)
AS
BEGIN
    -- Declaro la tabla temporal: No hay encabezados asi que los campos se llaman como quise
	CREATE TABLE #TempMediosPago(
		Nombre			VARCHAR(11),
		Descripcion		VARCHAR(30)
	);

	INSERT INTO #TempMediosPago (Nombre, Descripcion)
	SELECT *
	FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0', 
    'Excel 12.0;HDR=NO;IMEX=1;Database=C:\Users\usuario\Documents\6) BD aplicadas\TP Reporte de Ventas\TP_integrador_Archivos\Informacion_complementaria.xlsx;',
    'SELECT * FROM [medios de pago$B3:C1000]') -- Aquí especifico la fila de inicio (tercera fila) y el rango de columnas

	SELECT * FROM #TempMediosPago;

	INSERT INTO gestion_venta.MedioDePago (nombre, descripcion)
	SELECT Nombre, Descripcion
	FROM #TempMediosPago
	WHERE Nombre IS NOT NULL AND Descripcion IS NOT NULL

	DROP TABLE #TempMediosPago
	PRINT 'Importación y registro de Medios de Pago: Se completaron exitosamente.';
END
GO


/*
-- ============================ SP IMPORTACION EMPLEADOS ============================

CREATE OR ALTER PROCEDURE ImportarEmpleados
    @rutaArchivo VARCHAR(100)
AS
BEGIN
    -- Declaro la tabla temporal: Los campos deben coincidir con los de las columnas del Excel
    CREATE TABLE #TempEmpleados (
        [email personal]	VARCHAR(60),
		[email empresa]		VARCHAR(60),
        CUIL				CHAR(13),
		Cargo				VARCHAR(20),
		Sucursal			VARCHAR(20),
		Turno				VARCHAR(20)
    );

-- Uso OPENROWSET para importar datos del archivo Excel a la tabla temporal
-- LTRIM RTRIM borran los espacios al inicio y al final de la celda
-- NULLIF(NULLIF(columna, ''), ' ') asegura que los valores vacíos y los que contienen solo espacios se reemplacen por NULL
    INSERT INTO #TempEmpleados ([email personal], [email empresa], CUIL, Cargo, Sucursal, Turno)
	SELECT 
		NULLIF(NULLIF(LTRIM(RTRIM([email personal])), ''), ' ') AS [email personal],
		NULLIF(NULLIF(LTRIM(RTRIM([email empresa])), ''), ' ') AS [email empresa],
		NULLIF(NULLIF(LTRIM(RTRIM(CUIL)), ''), ' ') AS CUIL,
		NULLIF(NULLIF(LTRIM(RTRIM(Cargo)), ''), ' ') AS Cargo,
		NULLIF(NULLIF(LTRIM(RTRIM(Sucursal)), ''), ' ') AS Sucursal,
		NULLIF(NULLIF(LTRIM(RTRIM(Turno)), ''), ' ') AS Turno
	FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0', 
                'Excel 12.0;HDR=YES;Database=' + @rutaArchivo + -- Uso el nombre correcto de la hoja
                'SELECT [email personal], [email empresa], CUIL, Cargo, Sucursal, Turno FROM [Empleados$]');
				

	-- Variable para manejar el índice del registro
    DECLARE @ind INT = 1
    DECLARE @cantRegistros INT

    -- Obtengo la cantidad de registros de la tabla temporal
    SELECT @cantRegistros = COUNT(*) FROM #TempEmpleados;

	DECLARE @empleadoID INT
	DECLARE @emailPersonal VARCHAR(60)
	DECLARE @emailEmpresa VARCHAR(60)
	DECLARE @empleadoCuil CHAR(13)
	DECLARE @cargoID INT
	DECLARE @sucursalID INT
	DECLARE @turnoID INT
    
    WHILE @ind <= @cantRegistros -- Recorro cada registro
	BEGIN
			-- Asigno mis campos
		SELECT @empleadoCuil = te.CUIL, @emailPersonal = te.[email personal], @emailEmpresa = te.[email empresa] 
		FROM gestion_sucursal.Empleado e JOIN #TempEmpleados te ON te.[email empresa] = e.email_empresa

		SELECT @cargoID = c.id
		FROM gestion_sucursal.Cargo c JOIN #TempEmpleados te ON te.Cargo = c.nombre

		SELECT @sucursalID = s.id
		FROM gestion_sucursal.Sucursal s JOIN #TempEmpleados te ON te.Sucursal = s.nombre

		SELECT @turnoID = s.id
		FROM gestion_sucursal.Turno t JOIN #TempEmpleados te ON te.Turno = t.descripcion
		
		SELECT @empleadoID = c.id
		FROM gestion_sucursal.Empleado e JOIN #TempEmpleados te ON te.[email empresa] = e.email_empresa

		-- Si el empleado ya existe
		IF EXISTS (SELECT 1 FROM gestion_sucursal.Empleado WHERE id = @empleadoID)
		BEGIN
			UPDATE gestion_sucursal.Empleado
			SET
				cuil = ISNULL(@empleadoCuil, cuil),
				email = ISNULL(@emailPersonal, email),
				email_empresa = ISNULL(@emailEmpresa, email_empresa),
				id_cargo = ISNULL(@cargoID, id_cargo),
				id_sucursal = ISNULL(@sucursalID, id_sucursal),
				id_turno = ISNULL(@turnoID, id_turno)
			WHERE id = @empleadoID
			--PRINT 'Empleado modificado'
		END
		ELSE
		BEGIN
			INSERT INTO gestion_sucursal.Empleado(cuil, email, email_empresa, id_cargo, id_sucursal, id_turno)
			VALUES (@empleadoCuil, @emailPersonal, @emailEmpresa, @cargoID, @sucursalID, @turnoID)
			--PRINT 'Nuevo empleado insertado'
		END
	END
	
    -- Limpiar la tabla temporal
    DROP TABLE #TempEmpleados;

    -- Confirmar que todo se completó sin errores
    PRINT 'Importación y registro completados exitosamente.';
END;
GO
*/
