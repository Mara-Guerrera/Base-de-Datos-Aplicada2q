USE Com5600G05
GO
--Funciones correspondientes al esquema gestion_validacion--
CREATE OR ALTER FUNCTION gestion_validacion.Validar_Telefono
    (@telefono VARCHAR(15))
	RETURNS BIT
AS
BEGIN
    IF (PATINDEX('%[^ 0-9-]%', @telefono) > 0)
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

