/*Cuando un cliente reclama la devolución de un producto se genera una nota de crédito por el
valor del producto o un producto del mismo tipo.
En el caso de que el cliente solicite la nota de crédito, solo los Supervisores tienen el permiso
para generarla.
Tener en cuenta que la nota de crédito debe estar asociada a una Factura con estado pagada.
Asigne los roles correspondientes para poder cumplir con este requisito.
Por otra parte, se requiere que los datos de los empleados se encuentren encriptados, dado
que los mismos contienen información personal.*/

USE Com5600G05

ALTER TABLE gestion_sucursal.Empleado
DROP CONSTRAINT UC_Legajo_Sucursal;
GO
--Agregación de campos VARBINARY--
ALTER TABLE gestion_sucursal.Empleado
ALTER COLUMN legajo VARBINARY(MAX);

ALTER TABLE gestion_sucursal.Empleado
ADD nombre_ VARBINARY(MAX);
ALTER TABLE gestion_sucursal.Empleado
ADD direccion_ VARBINARY(MAX);

ALTER TABLE gestion_sucursal.Empleado
ADD apellido_ VARBINARY(MAX);

ALTER TABLE gestion_sucursal.Empleado
ADD dni_ VARBINARY(MAX);

ALTER TABLE gestion_sucursal.Empleado
ADD cuil_ VARBINARY(MAX);

ALTER TABLE gestion_sucursal.Empleado
ADD email_ VARBINARY(MAX);

ALTER TABLE gestion_sucursal.Empleado
ADD email_empresa_ VARBINARY(MAX);

--Definición de clave--
DECLARE @Clave VARCHAR(40)
SET @Clave = 'cisco_1234'
--Encriptación de datos--
UPDATE gestion_sucursal.Empleado
SET 
    legajo =  EncryptByPassPhrase(@Clave, legajo),
    nombre_ = EncryptByPassPhrase(@Clave, nombre),
    apellido_ = EncryptByPassPhrase(@Clave, apellido),
    direccion_ = EncryptByPassPhrase(@Clave, direccion),
    dni_ = EncryptByPassPhrase(@Clave, dni),
    cuil_ = EncryptByPassPhrase(@Clave, cuil),
    email_ = EncryptByPassPhrase(@Clave, email),
    email_empresa_ = EncryptByPassPhrase(@Clave, email_empresa);
--Consulta con datos desencriptados--
SELECT 
    CONVERT(INT, DecryptByPassPhrase(@Clave, legajo)) AS legajo_desencriptado,
    CONVERT(VARCHAR(MAX), DecryptByPassPhrase(@Clave, nombre_)) AS nombre_desencriptado,
    CONVERT(VARCHAR(MAX), DecryptByPassPhrase(@Clave, apellido_)) AS apellido_desencriptado,
    CONVERT(VARCHAR(MAX), DecryptByPassPhrase(@Clave, direccion_)) AS direccion_desencriptada,
    CONVERT(VARCHAR(MAX), DecryptByPassPhrase(@Clave, dni_)) AS dni_desencriptado,
    CONVERT(VARCHAR(MAX), DecryptByPassPhrase(@Clave, cuil_)) AS cuil_desencriptado,
    CONVERT(VARCHAR(MAX), DecryptByPassPhrase(@Clave, email_)) AS email_desencriptado,
    CONVERT(VARCHAR(MAX), DecryptByPassPhrase(@Clave, email_empresa_)) AS email_empresa_desencriptado
FROM gestion_sucursal.Empleado;
--Ponemos en NULL los datos de las columnas originales--
UPDATE gestion_sucursal.Empleado
SET 
nombre = NULL,
apellido =NULL, 
direccion=NULL,
dni=NULL,
cuil=NULL,
email=NULL, 
email_empresa=NULL
