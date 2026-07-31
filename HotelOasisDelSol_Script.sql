CREATE DATABASE HotelOasisDelSol;
GO
USE HotelOasisDelSol;
GO

--Tabla Supertipo
CREATE TABLE persona (
    idpersona INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(20) NOT NULL,
    apaterno VARCHAR(20) NOT NULL,
    amaterno VARCHAR(20) NOT NULL,
    tipo_documento VARCHAR(20) NOT NULL,
    num_documento VARCHAR(20) UNIQUE NOT NULL,
    direccion VARCHAR(100),
    telefono VARCHAR(12),
    email VARCHAR(25)
);

--Tabla Subtipo: trabajador 
CREATE TABLE trabajador (
    idpersona INT PRIMARY KEY,
    sueldo DECIMAL(7,2) NOT NULL CHECK (sueldo > 0),
    acceso VARCHAR(15) NOT NULL,
    login VARCHAR(15) UNIQUE NOT NULL,
    password VARCHAR(20) NOT NULL,
    estado VARCHAR(1) DEFAULT 'A',
    CONSTRAINT FK_trabajador_persona FOREIGN KEY (idpersona) REFERENCES persona(idpersona)
);

-- Tabla Subtipo: cliente 
CREATE TABLE cliente (
    idpersona INT PRIMARY KEY,
    codigo_cliente VARCHAR(10) UNIQUE NOT NULL,
    CONSTRAINT FK_cliente_persona FOREIGN KEY (idpersona) REFERENCES persona(idpersona)
);

-- Tabla: habitacion
CREATE TABLE habitacion (
    idhabitacion INT PRIMARY KEY IDENTITY(1,1),
    numero VARCHAR(4) NOT NULL,
    piso VARCHAR(2) NOT NULL,
    descripcion VARCHAR(255),
    caracteristicas VARCHAR(255),
    precio_diario DECIMAL(7,2) NOT NULL,
    estado VARCHAR(15) DEFAULT 'Disponible', -- Disponible, Ocupado, Mantenimiento
    tipo_habitacion VARCHAR(20) NOT NULL
);

-- Tabla: producto
CREATE TABLE producto (
    idproducto INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(45) NOT NULL,
    descripcion VARCHAR(255),
    unidad_medida VARCHAR(20),
    precio_venta DECIMAL(7,2) NOT NULL
);

-- Tabla: reserva
CREATE TABLE reserva (
    idreserva INT PRIMARY KEY IDENTITY(1,1),
    idhabitacion INT NOT NULL,
    idcliente INT NOT NULL,
    idtrabajador INT NOT NULL,
    tipo_reserva VARCHAR(20) NOT NULL,
    fecha_reserva DATE DEFAULT GETDATE(),
    fecha_ingresa DATE NOT NULL,
    fecha_salida DATE NOT NULL,
    costo_alojamiento DECIMAL(7,2) NOT NULL,
    estado VARCHAR(15), -- Pagada, Anulada, Pendiente
    CONSTRAINT FK_reserva_habitacion FOREIGN KEY (idhabitacion) REFERENCES habitacion(idhabitacion),
    CONSTRAINT FK_reserva_cliente FOREIGN KEY (idcliente) REFERENCES cliente(idpersona),
    CONSTRAINT FK_reserva_trabajador FOREIGN KEY (idtrabajador) REFERENCES trabajador(idpersona)
);

-- Tabla: consumo 
CREATE TABLE consumo (
    idconsumo INT PRIMARY KEY IDENTITY(1,1),
    idreserva INT NOT NULL,
    idproducto INT NOT NULL,
    cantidad DECIMAL(7,2) NOT NULL,
    precio_venta DECIMAL(7,2) NOT NULL,
    estado VARCHAR(15),
    CONSTRAINT FK_consumo_reserva FOREIGN KEY (idreserva) REFERENCES reserva(idreserva),
    CONSTRAINT FK_consumo_producto FOREIGN KEY (idproducto) REFERENCES producto(idproducto)
);

-- Tabla: pago
CREATE TABLE pago (
    idpago INT PRIMARY KEY IDENTITY(1,1),
    idreserva INT NOT NULL,
    tipo_comprobante VARCHAR(20) NOT NULL,
    num_comprobante VARCHAR(20) NOT NULL,
    igv DECIMAL(4,2) NOT NULL,
    total_pago DECIMAL(7,2) NOT NULL,
    fecha_emision DATE DEFAULT GETDATE(),
    fecha_pago DATE,
    CONSTRAINT FK_pago_reserva FOREIGN KEY (idreserva) REFERENCES reserva(idreserva)
);
GO

--Implementacion de Seguridad
-- Crear Rol
CREATE ROLE Recurso_Recepcion;

-- Asignar permisos de lectura y escritura en tablas clave
GRANT SELECT, INSERT, UPDATE ON reserva TO Recurso_Recepcion;
GRANT SELECT, INSERT, UPDATE ON cliente TO Recurso_Recepcion;
GRANT SELECT ON habitacion TO Recurso_Recepcion;

-- Ejemplo de creación de usuario para un trabajador
-- CREATE LOGIN [Empleado01] WITH PASSWORD = 'UserPassword123';
-- CREATE USER [Empleado01] FOR LOGIN [Empleado01];
-- ALTER ROLE Recurso_Recepcion ADD MEMBER [Empleado01];


--Vistas y Consultas de Reporte
CREATE VIEW vista_habitaciones_libres AS
SELECT numero, piso, precio_diario, tipo_habitacion
FROM habitacion
WHERE estado = 'Disponible';
GO

--Reporte de Ventas con agrupamientp
SELECT 
    tipo_comprobante, 
    SUM(total_pago) AS Total_Recaudado,
    COUNT(idpago) AS Cantidad_Comprobantes
FROM pago
GROUP BY ROLLUP(tipo_comprobante);

--Consulta Compleja
SELECT 
    r.idreserva,
    (p.nombre + ' ' + p.apaterno) AS Cliente,
    h.numero AS Habitacion,
    r.fecha_ingresa,
    r.fecha_salida,
    (SELECT SUM(cantidad * precio_venta) FROM consumo WHERE idreserva = r.idreserva) AS Total_Consumos
FROM reserva r
JOIN cliente c ON r.idcliente = c.idpersona
JOIN persona p ON c.idpersona = p.idpersona
JOIN habitacion h ON r.idhabitacion = h.idhabitacion
ORDER BY r.fecha_ingresa DESC;

--EJEMPLO
-- Insertar una habitación
INSERT INTO habitacion (numero, piso, descripcion, caracteristicas, precio_diario, estado, tipo_habitacion)
VALUES ('101', '1', 'Habitación con vista al jardín', 'Cama King, Wifi, Aire acondicionado', 150.00, 'Disponible', 'Matrimonial');

-- Insertar un producto del minibar
INSERT INTO producto (nombre, descripcion, unidad_medida, precio_venta)
VALUES ('Agua Mineral', 'Botella de 500ml sin gas', 'Unidad', 5.00);

-- Registrar al Recepcionista (Trabajador)
INSERT INTO persona (nombre, apaterno, amaterno, tipo_documento, num_documento, direccion, telefono, email)
VALUES ('Ana', 'García', 'López', 'DNI', '77889900', 'Av. Central 123', '987654321', 'ana.recepcion@hotel.com');

INSERT INTO trabajador (idpersona, sueldo, acceso, login, password, estado)
VALUES (1, 2500.00, 'Recepcionista', 'agarcia', 'admin123', 'A');

-- Registrar a un Huésped (Cliente)
INSERT INTO persona (nombre, apaterno, amaterno, tipo_documento, num_documento, direccion, telefono, email)
VALUES ('Carlos', 'Ruiz', 'Mendoza', 'DNI', '11223344', 'Calle Los Álamos 45', '912345678', 'carlos.ruiz@email.com');

INSERT INTO cliente (idpersona, codigo_cliente)
VALUES (2, 'CLI-001');


-- Crear la reserva
INSERT INTO reserva (idhabitacion, idcliente, idtrabajador, tipo_reserva, fecha_ingresa, fecha_salida, costo_alojamiento, estado)
VALUES (1, 2, 1, 'Online', '2026-05-01', '2026-05-03', 300.00, 'Pendiente');

-- Registrar un consumo adicional (Carlos tomó una botella de agua)
INSERT INTO consumo (idreserva, idproducto, cantidad, precio_venta, estado)
VALUES (1, 1, 1, 5.00, 'Entregado');


-- Registrar el pago total (Alojamiento 300 + Consumo 5)
INSERT INTO pago (idreserva, tipo_comprobante, num_comprobante, igv, total_pago, fecha_pago)
VALUES (1, 'Boleta', 'B001-000524', 0.18, 305.00, GETDATE());

-- Actualizar el estado de la reserva y la habitación
UPDATE reserva SET estado = 'Pagada' WHERE idreserva = 1;
UPDATE habitacion SET estado = 'Disponible' WHERE idhabitacion = 1;

--UTILIZAR CONSULTA COMPLEJA PARA VERIFICAR EL EJEMPLO REALIZADO