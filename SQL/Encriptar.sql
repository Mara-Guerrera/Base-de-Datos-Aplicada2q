ALTER TABLE gestion_sucursal.Empleado
DROP CONSTRAINT Ck_EmpleadoDni;

ALTER TABLE gestion_sucursal.Empleado
DROP CONSTRAINT Ck_EmpleadoCuil;

/*ALTER TABLE gestion_sucursal.Empleado
DROP CONSTRAINT UQ__Empleado__D87608A7E1047B03;

ALTER TABLE gestion_sucursal.Empleado
DROP CONSTRAINT UQ__Empleado__2CDD98AF68A33D53;

ALTER TABLE gestion_sucursal.Empleado
DROP CONSTRAINT UQ__Empleado__AB6E616446DB599A;

ALTER TABLE gestion_sucursal.Empleado
DROP CONSTRAINT UQ__Empleado__EFC2C9F7C4690505;*/

ALTER TABLE gestion_sucursal.Empleado
DROP COLUMN legajo, nombre, apellido, dni, direccion, cuil, email, email_empresa;

EXEC sp_rename 'gestion_sucursal.Empleado.legajo_temp', 'legajo', 'COLUMN';
EXEC sp_rename 'gestion_sucursal.Empleado.nombre_temp', 'nombre', 'COLUMN';
EXEC sp_rename 'gestion_sucursal.Empleado.apellido_temp', 'apellido', 'COLUMN';
EXEC sp_rename 'gestion_sucursal.Empleado.dni_temp', 'dni', 'COLUMN';
EXEC sp_rename 'gestion_sucursal.Empleado.direccion_temp', 'direccion', 'COLUMN';
EXEC sp_rename 'gestion_sucursal.Empleado.cuil_temp', 'cuil', 'COLUMN';
EXEC sp_rename 'gestion_sucursal.Empleado.email_temp', 'email', 'COLUMN';
EXEC sp_rename 'gestion_sucursal.Empleado.email_empresa_temp', 'email_empresa', 'COLUMN';


UPDATE gestion_sucursal.Empleado
SET
    legajo = EncryptByPassPhrase('clave-secreta', CAST(legajo AS NVARCHAR(MAX))),
    nombre = EncryptByPassPhrase('clave-secreta', CAST(nombre AS NVARCHAR(MAX))),
    apellido = EncryptByPassPhrase('clave-secreta', CAST(apellido AS NVARCHAR(MAX))),
    dni = EncryptByPassPhrase('clave-secreta', CAST(dni AS NVARCHAR(MAX))),
    direccion = EncryptByPassPhrase('clave-secreta', CAST(direccion AS NVARCHAR(MAX))),
    cuil = EncryptByPassPhrase('clave-secreta', CAST(cuil AS NVARCHAR(MAX))),
    email = EncryptByPassPhrase('clave-secreta', CAST(email AS NVARCHAR(MAX))),
    email_empresa = EncryptByPassPhrase('clave-secreta', CAST(email_empresa AS NVARCHAR(MAX))),
    id_cargo = EncryptByPassPhrase('clave-secreta', CAST(id_cargo AS NVARCHAR(MAX))),
    id_sucursal = EncryptByPassPhrase('clave-secreta', CAST(id_sucursal AS NVARCHAR(MAX))),
    id_turno = EncryptByPassPhrase('clave-secreta', CAST(id_turno AS NVARCHAR(MAX))),
    activo = EncryptByPassPhrase('clave-secreta', CAST(activo AS NVARCHAR(MAX)));

--HACER EL INSERT DSP DE HABER IMPORTADO LOS ARCHIVOS PARA PROBAR ESTO
INSERT INTO gestion_sucursal.Empleado (legajo, nombre, apellido, dni, direccion, cuil, email, email_empresa, id_cargo, id_sucursal, id_turno, activo)
VALUES 
(1001, 'Juan', 'Pérez', '12345678', 'Calle Falsa 123', '20-12345678-9', 'juan.perez@gmail.com', 'jperez@empresa.com', 1, 1, 1, 1),
(1002, 'María', 'González', '87654321', 'Avenida Siempre Viva 456', '27-87654321-8', 'maria.gonzalez@hotmail.com', 'mgonzalez@empresa.com', 2, 1, 2, 1),
(1003, 'Carlos', 'López', '23456789', 'Boulevard Central 789', '23-23456789-7', 'carlos.lopez@yahoo.com', 'clopez@empresa.com', 3, 2, 1, 1),
(1004, 'Ana', 'Martínez', '34567890', 'Ruta Nacional 14', '24-34567890-6', 'ana.martinez@gmail.com', 'amartinez@empresa.com', 1, 2, 3, 1),
(1005, 'Pedro', 'García', '45678901', 'Camino Real 500', '20-45678901-5', 'pedro.garcia@gmail.com', 'pgarcia@empresa.com', 4, 3, 2, 0),
(1006, 'Laura', 'Fernández', '56789012', 'Plaza Mayor 101', '27-56789012-4', 'laura.fernandez@gmail.com', 'lfernandez@empresa.com', 2, 3, 1, 1),
(1007, 'Jorge', 'Sánchez', '67890123', 'Paseo del Prado 202', '23-67890123-3', 'jorge.sanchez@gmail.com', 'jsanchez@empresa.com', 3, 1, 3, 1),
(1008, 'Marta', 'Díaz', '78901234', 'Avenida del Libertador 303', '24-78901234-2', 'marta.diaz@hotmail.com', 'mdiaz@empresa.com', 4, 2, 2, 0),
(1009, 'Sofía', 'Ramírez', '89012345', 'Camino de los Inmigrantes 404', '20-89012345-1', 'sofia.ramirez@yahoo.com', 'sramirez@empresa.com', 1, 3, 1, 1),
(1010, 'Diego', 'Alvarez', '90123456', 'Calle del Comercio 505', '27-90123456-0', 'diego.alvarez@gmail.com', 'dalvarez@empresa.com', 2, 1, 2, 1);
