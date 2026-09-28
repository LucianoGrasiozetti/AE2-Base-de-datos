DROP DATABASE IF EXISTS taller_reparaciones;
CREATE DATABASE taller_reparaciones;
USE taller_reparaciones;

-- CLIENTE
CREATE TABLE cliente (
    cuil BIGINT UNSIGNED PRIMARY KEY,
    nombre_completo VARCHAR(60) NOT NULL,
    telefono VARCHAR(30) NOT NULL,
    correo_electronico VARCHAR(50),
    direccion VARCHAR(100)
);

-- EMPLEADO
CREATE TABLE empleado (
    cuil BIGINT UNSIGNED PRIMARY KEY,
    nombre_completo VARCHAR(60) NOT NULL,
    telefono VARCHAR(30) NOT NULL,
    rol VARCHAR(50) NOT NULL,
    fecha_ingreso DATE NOT NULL
);

-- EQUIPO
CREATE TABLE equipo (
    nro_serie VARCHAR(50) PRIMARY KEY,
    modelo VARCHAR(50) NOT NULL,
    marca VARCHAR(50) NOT NULL,
    tipo VARCHAR(50) NOT NULL
);

-- SERVICIO
CREATE TABLE servicio (
    id_servicio INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(60) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    precio DECIMAL(10,2) NOT NULL CHECK (precio >= 0),
    tiempo_estimado INT CHECK (tiempo_estimado IS NULL OR tiempo_estimado > 0)
);

-- ORDEN DE SERVICIO
CREATE TABLE orden_servicio (
    nro_orden INT PRIMARY KEY AUTO_INCREMENT,
    cuil_empleado BIGINT UNSIGNED NOT NULL,
    cuil_cliente BIGINT UNSIGNED NOT NULL,
    FOREIGN KEY (cuil_empleado) REFERENCES empleado(cuil),
    FOREIGN KEY (cuil_cliente) REFERENCES cliente(cuil)
);

-- EQUIPO - ORDEN
CREATE TABLE equipo_orden (
    id_equipo_orden INT PRIMARY KEY AUTO_INCREMENT,
    falla_reportada VARCHAR(255),
    fecha_ingreso DATE NOT NULL,
    fecha_entrega DATE,
    nro_orden INT NOT NULL,
    nro_serie VARCHAR(50) NOT NULL,
    UNIQUE (nro_orden, nro_serie),
    FOREIGN KEY (nro_orden) REFERENCES orden_servicio(nro_orden),
    FOREIGN KEY (nro_serie) REFERENCES equipo(nro_serie),
    CHECK (fecha_entrega IS NULL OR fecha_entrega >= fecha_ingreso)
);

-- DETALLE DE SERVICIO
CREATE TABLE detalle_servicio (
    id_detalle INT PRIMARY KEY AUTO_INCREMENT,
    estado VARCHAR(20) NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_aplicado DECIMAL(10,2) NOT NULL CHECK (precio_aplicado >= 0),
    nro_orden INT NOT NULL,
    id_servicio INT NOT NULL,
    cuil_empleado BIGINT UNSIGNED NOT NULL,
    FOREIGN KEY (nro_orden) REFERENCES orden_servicio(nro_orden),
    FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio),
    FOREIGN KEY (cuil_empleado) REFERENCES empleado(cuil),
    CHECK (estado IN ('pendiente','en_progreso','finalizado'))
);

-- DIAGNOSTICO
CREATE TABLE diagnostico (
    id_diagnostico INT PRIMARY KEY AUTO_INCREMENT,
    falla_detectada VARCHAR(255) NOT NULL,
    fecha_diagnostico DATE NOT NULL,
    observaciones VARCHAR(255),
    cuil_empleado BIGINT UNSIGNED NOT NULL,
    nro_serie VARCHAR(50) NOT NULL,
    FOREIGN KEY (cuil_empleado) REFERENCES empleado(cuil),
    FOREIGN KEY (nro_serie) REFERENCES equipo(nro_serie)
);

-- PAGO
CREATE TABLE pago (
    id_pago INT PRIMARY KEY AUTO_INCREMENT,
    medio_pago VARCHAR(50) NOT NULL,
    fecha_pago DATE NOT NULL,
    nro_orden INT NOT NULL UNIQUE,
    FOREIGN KEY (nro_orden) REFERENCES orden_servicio(nro_orden)
);

-- HISTORIAL DE ESTADOS
CREATE TABLE historial_estado_orden (
    id_historial INT PRIMARY KEY AUTO_INCREMENT,
    estado VARCHAR(50) NOT NULL,
    fecha_cambio DATETIME NOT NULL,
    observacion VARCHAR(255),
    nro_orden INT NOT NULL,
    cuil_empleado BIGINT UNSIGNED NOT NULL,
    FOREIGN KEY (nro_orden) REFERENCES orden_servicio(nro_orden),
    FOREIGN KEY (cuil_empleado) REFERENCES empleado(cuil),
    CHECK (estado IN (
        'recibido',
        'en_diagnostico',
        'esperando_aprobacion',
        'en_reparacion',
        'finalizado',
        'entregado'
    ))
);

-- DATOS DE PRUEBA

INSERT INTO cliente VALUES
(20301234567,'Juan Perez','3764123456','juan@gmail.com','Av. Mitre 123'),
(27203456789,'Maria Gomez','3764987654','maria@gmail.com','Belgrano 456'),
(20304567891,'Pedro Rodriguez','3764556789','pedro@gmail.com','San Martin 789');

INSERT INTO empleado VALUES
(20111222333,'Carlos Rodriguez','3764555555','Tecnico','2020-03-15'),
(20333444555,'Lucas Fernandez','3764666666','Tecnico Senior','2018-08-20'),
(20222333444,'Ana Martinez','3764777777','Tecnico','2022-01-10');

INSERT INTO equipo VALUES
('NB001','Inspiron 15','Dell','Notebook'),
('PC002','ThinkCentre M70','Lenovo','PC'),
('CEL004','Galaxy S23','Samsung','Celular');

INSERT INTO servicio (nombre,categoria,precio,tiempo_estimado) VALUES
('Cambio de disco','Hardware',50000,120),
('Limpieza interna','Mantenimiento',20000,60),
('Instalacion de sistema operativo','Software',30000,90),
('Cambio de pantalla','Hardware',80000,180);

INSERT INTO orden_servicio (cuil_empleado,cuil_cliente) VALUES
(20111222333,20301234567),
(20333444555,27203456789),
(20222333444,20304567891);

INSERT INTO equipo_orden
(falla_reportada,fecha_ingreso,nro_orden,nro_serie) VALUES
('La notebook no enciende','2026-09-20',1,'NB001'),
('La PC funciona lentamente','2026-09-21',2,'PC002'),
('Pantalla dañada','2026-09-22',3,'CEL004');

INSERT INTO detalle_servicio
(estado,cantidad,precio_aplicado,nro_orden,id_servicio,cuil_empleado) VALUES
('en_progreso',1,50000,1,1,20111222333),
('pendiente',1,20000,1,2,20111222333),
('finalizado',1,30000,2,3,20333444555),
('en_progreso',1,80000,3,4,20222333444);

INSERT INTO diagnostico
(falla_detectada,fecha_diagnostico,observaciones,cuil_empleado,nro_serie) VALUES
('Falla en el disco','2026-09-20','Se recomienda reemplazo',20111222333,'NB001'),
('Sistema operativo con problemas','2026-09-21','Se recomienda reinstalacion',20333444555,'PC002'),
('Pantalla rota','2026-09-22','Se requiere reemplazo',20222333444,'CEL004');

INSERT INTO pago (medio_pago,fecha_pago,nro_orden) VALUES
('Transferencia','2026-09-23',1),
('Tarjeta de debito','2026-09-24',2);

INSERT INTO historial_estado_orden
(estado,fecha_cambio,observacion,nro_orden,cuil_empleado) VALUES
('recibido','2026-09-20 09:00:00','Equipo recibido',1,20111222333),
('en_diagnostico','2026-09-20 10:00:00','Diagnostico iniciado',1,20111222333),
('en_reparacion','2026-09-20 14:00:00','Reparacion iniciada',1,20111222333),
('recibido','2026-09-21 09:30:00','Equipo recibido',2,20333444555),
('en_diagnostico','2026-09-21 11:00:00','Diagnostico iniciado',2,20333444555),
('finalizado','2026-09-24 15:00:00','Servicio terminado',2,20333444555),
('recibido','2026-09-22 10:00:00','Equipo recibido',3,20222333444);

-- VISTAS

CREATE VIEW v_empleado_antiguedad AS
SELECT
    cuil,
    nombre_completo,
    fecha_ingreso,
    TIMESTAMPDIFF(YEAR,fecha_ingreso,CURDATE()) AS antiguedad
FROM empleado;

CREATE VIEW v_pago_monto AS
SELECT
    p.id_pago,
    p.nro_orden,
    p.medio_pago,
    p.fecha_pago,
    COALESCE(SUM(d.cantidad * d.precio_aplicado),0) AS monto
FROM pago p
LEFT JOIN detalle_servicio d
ON p.nro_orden = d.nro_orden
GROUP BY p.id_pago,p.nro_orden,p.medio_pago,p.fecha_pago;

-- CONSULTAS DE PRUEBA

SHOW TABLES;

SELECT * FROM cliente;
SELECT * FROM empleado;
SELECT * FROM equipo;
SELECT * FROM servicio;
SELECT * FROM orden_servicio;
SELECT * FROM equipo_orden;
SELECT * FROM detalle_servicio;
SELECT * FROM diagnostico;
SELECT * FROM pago;
SELECT * FROM historial_estado_orden;

SELECT
    o.nro_orden,
    c.nombre_completo AS cliente,
    e.nombre_completo AS empleado
FROM orden_servicio o
JOIN cliente c ON o.cuil_cliente = c.cuil
JOIN empleado e ON o.cuil_empleado = e.cuil;

SELECT *
FROM v_pago_monto;

SELECT *
FROM v_empleado_antiguedad;