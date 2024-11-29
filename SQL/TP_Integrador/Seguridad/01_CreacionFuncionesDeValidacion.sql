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

ENTREGA 3:

Deberá instalar el DMBS y documentar el proceso. No incluya capturas de pantalla. Detalle
las configuraciones aplicadas (ubicación de archivos, memoria asignada, seguridad, puertos,
etc.) en un documento como el que le entregaría al DBA.
Cree la base de datos, entidades y relaciones. Incluya restricciones y claves. Deberá entregar
un archivo .sql con el script completo de creación (debe funcionar si se lo ejecuta “tal cual” es
entregado). Incluya comentarios para indicar qué hace cada módulo de código.
Genere store procedures para manejar la inserción, modificado, borrado (si corresponde,
también debe decidir si determinadas entidades solo admitirán borrado lógico) de cada tabla.
Los nombres de los store procedures NO deben comenzar con “SP”.
Genere esquemas para organizar de forma lógica los componentes del sistema y aplique esto
en la creación de objetos. NO use el esquema “dbo”.
*/
-- ============================ CREACION FUNCIONES DE ESQUEMA GESTION_VALIDACION ============================
USE Com5600G05
GO

CREATE OR ALTER FUNCTION gestion_validacion.Validar_Telefono
    (@telefono VARCHAR(15))
	RETURNS BIT
AS
BEGIN
    IF (PATINDEX('%[^ 0-9-]%', @telefono) > 0) -- Si tiene algun caracter distinto a numeros, guiones o espacios
    BEGIN
        RETURN 0;
    END

    IF 
    (@telefono NOT LIKE '[0-9][0-9] [0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]') -- 4-4
    AND
    (@telefono NOT LIKE '[0-9][0-9][0-9] [0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]') -- 3-4
    AND
    (@telefono NOT LIKE '[0-9][0-9][0-9][0-9] [0-9][0-9]-[0-9][0-9][0-9][0-9]') -- 2-4
	AND
	(@telefono NOT LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]') -- Telefono fijo
    BEGIN
        RETURN 0;
    END

    RETURN 1;
END
GO

CREATE OR ALTER FUNCTION gestion_validacion.Validar_Cuil
    (@cuil VARCHAR(15))
	RETURNS BIT
BEGIN	
	IF @cuil NOT LIKE '[0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9]'
		RETURN 0

	RETURN 1;
END
GO

CREATE OR ALTER FUNCTION gestion_validacion.Validar_Email
    (@email VARCHAR(60))
    RETURNS BIT
AS
BEGIN
    --Verifica que haya solo un arroba--
	IF @email LIKE '%@%@%' OR @email LIKE '%@@%'
        RETURN 0;

    -- Verifica si tiene puntos consecutivos
    IF @email LIKE '%..%' 
        RETURN 0;

    IF @email NOT LIKE '%_@__%.__%'  
    BEGIN
        RETURN 0;  
    END

    IF (PATINDEX('%[^a-zA-Z0-9@._%-]%', @email) > 0) 
    BEGIN
        RETURN 0; 
    END

    RETURN 1;  
END
GO
