USE MASTER
USE Com5600G05
GO

-- ============================ LOTE DE PRUEBAS SUCURSAL ============================
-- La insercion de la empresa tendra como ID = 1
INSERT INTO gestion_sucursal.Empresa(cuit, razon_social, telefono)
VALUES ('20-41900522-6', 'Aurora S.A.', '4446-2105')
GO
SELECT * FROM gestion_sucursal.Empresa
GO

-- ============================ INSERCION ============================

-- CASO 1: La empresa no existe
EXEC gestion_sucursal.Insertar_Sucursal
    @nombre = 'Sucursal A',
    @direccion = 'Calle Ficticia 123',
    @horario = 'Lunes a Viernes 9:00 - 18:00',
    @telefono = '5234-67894545',
	@id_empresa = 2;
GO

-- CASO 2: El telefono no tiene un formato valido
EXEC gestion_sucursal.Insertar_Sucursal
    @nombre = 'Sucursal A',
    @direccion = 'Calle Falsa 123',
    @horario = 'Lunes a Viernes 9:00 - 18:00',
    @telefono = '0800-151644',
	@id_empresa = 1;
GO

-- CASO 2.2: El telefono no tiene un formato valido
EXEC gestion_sucursal.Insertar_Sucursal
    @nombre = 'Sucursal A',
    @direccion = 'Calle Ishida 9087',
    @horario = 'Lunes a Viernes 9:00 - 18:00',
    @telefono = '11-15-5234-6789',
	@id_empresa = 1;
GO

-- CASO 3: La sucursal se inserta correctamente

EXEC gestion_sucursal.Insertar_Sucursal
    @nombre = 'Sucursal A',
    @direccion = 'Calle Strangford 9087',
    @horario = 'Lunes a Viernes 9:00 - 18:00',
    @telefono = '5234-6789',
	@id_empresa = 1;
GO
EXEC gestion_sucursal.Insertar_Sucursal
    @nombre = 'Sucursal B',
    @direccion = 'Calle Ficticia 123',
    @horario = 'Lunes a Viernes 9:00 - 18:00',
    @telefono = '5289-4545',
	@id_empresa = 1;
GO
EXEC gestion_sucursal.Insertar_Sucursal
    @nombre = 'Sucursal C',
    @direccion = 'Calle Ishida 9087',
    @horario = 'Lunes a Viernes 9:00 - 18:00',
    @telefono = '5234-6789',
	@id_empresa = 1;
GO
EXEC gestion_sucursal.Insertar_Sucursal
    @nombre = 'Sucursal D',
    @direccion = 'Calle Falsa 123',
    @horario = 'Lunes a Viernes 9:00 - 18:00',
    @telefono = '4959-2523',
	@id_empresa = 1;
GO
SELECT * FROM gestion_sucursal.Sucursal
GO

-- CASO 4: La sucursal ya existe (por nombre)
EXEC gestion_sucursal.Insertar_Sucursal
    @nombre = 'Sucursal C',
    @direccion = 'Calle Ishida 9087',
    @horario = 'Lunes a Viernes 9:00 - 18:00',
    @telefono = '5234-6789',
	@id_empresa = 1;
GO

-- CASO 5: La sucursal se dio de alta

SELECT * FROM gestion_sucursal.Sucursal
GO

EXEC gestion_sucursal.Borrar_Sucursal -- Sucursal D fue dada de baja correctamente
	@id_sucursal = 4
GO
SELECT * FROM gestion_sucursal.Sucursal -- Sucursal D -> activo = 0
GO

EXEC gestion_sucursal.Insertar_Sucursal -- Sucursal D se reactiva
    @nombre = 'Sucursal D',
    @direccion = NULL,
    @horario = 'Lunes a Viernes 9:00 - 15:00', -- No se actualiza el Cambio de horario
    @telefono = NULL,
	@id_empresa = 1;
GO

-- ============================ MODIFICACION ============================

-- CASO 1: Se modifica el horario de Sucursal D exitosamente
EXEC gestion_sucursal.Modificar_Sucursal
	@id = 4,
	@nombre = NULL,
    @direccion = NULL,
    @horario = 'Lunes a Viernes 9:00 - 15:00',
    @telefono = NULL,
	@activo = NULL;
GO
SELECT * FROM gestion_sucursal.Sucursal
GO

-- CASO 2: Se reactiva la sucursal y se modifica el telefono

EXEC gestion_sucursal.Borrar_Sucursal -- Sucursal B fue dada de baja correctamente
	@id_sucursal = 2
GO
SELECT * FROM gestion_sucursal.Sucursal -- Sucursal B -> activo = 0
GO

EXEC gestion_sucursal.Modificar_Sucursal 
	@id = 2,
	@nombre = NULL,
    @direccion = NULL,
    @horario = NULL,
    @telefono = '5489-6024',
	@activo = 1;
GO
SELECT * FROM gestion_sucursal.Sucursal
GO

-- CASO 3: El telefono no tiene un formato valido
EXEC gestion_sucursal.Modificar_Sucursal
    @id = 1,
    @telefono = '0800-15AA'
GO

-- CASO 4: No existe la sucursal
EXEC gestion_sucursal.Modificar_Sucursal 
	@id = 10522,
	@nombre = 'Sucursal X',
    @direccion = NULL,
    @horario = NULL,
    @telefono = NULL,
	@activo = 1;
GO
SELECT * FROM gestion_sucursal.Sucursal
GO

-- ============================ BORRADO ============================
-- Ya he probado el borrado exitoso

-- CASO 1: No se existe la sucursal
EXEC gestion_sucursal.Borrar_Sucursal
	@id_sucursal = 10522
GO

-- CASO 2: La sucursal ya fue dada de baja
EXEC gestion_sucursal.Borrar_Sucursal -- Sucursal A se dio de baja correctamente
	@id_sucursal = 1
GO
SELECT * FROM gestion_sucursal.Sucursal
GO
EXEC gestion_sucursal.Borrar_Sucursal
	@id_sucursal = 1
GO

-- ============================ MODIFICACION ============================

-- CASO 5: Se reactiva la sucursal
EXEC gestion_sucursal.Modificar_Sucursal 
	@id = 1,
	@activo = 1;
GO
SELECT * FROM gestion_sucursal.Sucursal
GO

-- VACIAR LA TABLA
DELETE gestion_sucursal.Sucursal WHERE id = 1
GO
DELETE gestion_sucursal.Sucursal WHERE id = 2
GO
DELETE gestion_sucursal.Sucursal WHERE id = 3
GO
DELETE gestion_sucursal.Sucursal WHERE id = 4
GO

SELECT * FROM gestion_sucursal.Sucursal
GO