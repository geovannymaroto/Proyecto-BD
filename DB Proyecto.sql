--****INICIO PARTE 1****

--CREAR NUEVO USUARIO:
--1. Comandos en CMD:
--2. sqlplus / as sysdba
--3. ALTER SESSION SET"_ORACLE_SCRIPT" = TRUE;
--4. CREATE USER DBAPROY IDENTIFIED BY dba24680;
--5. GRANT DBA TO DBAPROY;

--CREAR DATABASE Proyecto_BD:
--1. En "Connections", crear nueva BD
--2. Nombrar nueva BD como "Proyecto_BD"
--3. Username = DBAPROY
--4. Password = dba24680
--5. SID = orcl
--6. Boton Test = Success
--7. Connect
        
DROP TABLE materiales CASCADE CONSTRAINTS; --Eliminar tablas con constraints

CREATE TABLE USUARIOS(
    ced VARCHAR2(100) PRIMARY KEY,
    contrasenha VARCHAR2(100) NOT NULL);

INSERT INTO USUARIOS(ced,contrasenha) VALUES('123456','contra');
COMMIT;

SELECT * FROM USUARIOS;

CREATE TABLE MATERIALES(
    sku_producto VARCHAR2(30) PRIMARY KEY,
    descripcion VARCHAR2(50) NOT NULL,
    es_combo VARCHAR2(1) DEFAULT 'N',
    precio_unidad NUMBER NOT NULL,
    cantidad NUMBER NOT NULL,
    fecha_registro_producto DATE DEFAULT SYSDATE,
    descontinuado VARCHAR2(1) DEFAULT 'N'); --Valores: Y/N

INSERT INTO MATERIALES(sku_producto,descripcion,precio_unidad) VALUES('DFT34X','Tinta negra',6780);
INSERT INTO MATERIALES(sku_producto,descripcion,precio_unidad) VALUES('DFT35X','Tinta magenta',5480);
INSERT INTO MATERIALES(sku_producto,descripcion,precio_unidad) VALUES('DFT36X','Tinta amarilla',5500);
INSERT INTO MATERIALES(sku_producto,descripcion,precio_unidad) VALUES('DFT37X','Tinta cyan',5950);
INSERT INTO MATERIALES(sku_producto,descripcion,precio_unidad) VALUES('GWN09B','Toner negro',52975);
INSERT INTO MATERIALES(sku_producto,descripcion,precio_unidad) VALUES('GWN10B','Toner cyan',41950);
INSERT INTO MATERIALES(sku_producto,descripcion,precio_unidad) VALUES('GWN11B','Toner magenta',41500);
INSERT INTO MATERIALES(sku_producto,descripcion,precio_unidad) VALUES('GWN12B','Toner amarillo',41500);
INSERT INTO MATERIALES(sku_producto,descripcion,precio_unidad) VALUES('XYF33A','Rodillo papel Kraft 100 mts',45000);

SELECT * FROM MATERIALES;
    
CREATE TABLE PROVEEDORES(
    ced_proveedor NUMBER PRIMARY KEY,
    tipo_ced VARCHAR2(25),
    nombre_proveedor VARCHAR2(50) NOT NULL,
    fecha_ingreso DATE DEFAULT SYSDATE,
    telefono VARCHAR2(15) NOT NULL,
    email VARCHAR2(100) NOT NULL,
    direccion VARCHAR2(100) NOT NULL,
    distrito VARCHAR2(20) NOT NULL,
    canton VARCHAR2(20) NOT NULL,
    provincia VARCHAR2(20) NOT NULL,
    fecha_registro DATE DEFAULT SYSDATE);

INSERT INTO PROVEEDORES(ced_proveedor,nombre_proveedor,telefono,email,direccion,distrito,canton,provincia) VALUES('123','Pepe Carrillo','6780','correo@mail.com','ZF Coyol','Industrial','Coyol','Alajuela');
INSERT INTO PROVEEDORES(ced_proveedor,nombre_proveedor,telefono,email,direccion,distrito,canton,provincia) VALUES('456','Ronny Blanco','9874','otro@correo.com','ZF Lima','Industrial','Lima','Cartago');
COMMIT;

SELECT * FROM PROVEEDORES;

CREATE TABLE CLIENTES(
    ced_cliente NUMBER PRIMARY KEY,
    nombre_cliente VARCHAR2(50) NOT NULL,
    fecha_nacimiento DATE,
    telefono VARCHAR2(15) NOT NULL,
    email VARCHAR2(100) NOT NULL,
    direccion VARCHAR2(100),
    distrito VARCHAR2(20),
    canton VARCHAR2(20),
    provincia VARCHAR2(20),
    fecha_registro DATE DEFAULT SYSDATE);

--Se cargará solo a través del trigger "materiales_inventario_trg"
CREATE TABLE INVENTARIO(
    sku_producto VARCHAR2(30) PRIMARY KEY,
    unidades_disponibles NUMBER NOT NULL,
    fecha_ultima_modificacion DATE DEFAULT SYSDATE,
    
    CONSTRAINT sku_inventario_fk FOREIGN KEY(sku_producto)
        REFERENCES MATERIALES(sku_producto)
);

SELECT * FROM INVENTARIO;
    
CREATE TABLE COTIZACIONES(
    id_cotizacion NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ced_proveedor NUMBER NOT NULL,
    sku_producto VARCHAR2(30) NOT NULL,
    fecha_cotizacion DATE DEFAULT SYSDATE,
    fecha_vencimiento DATE NOT NULL,
    dias_para_vencimiento NUMBER AS(fecha_vencimiento - fecha_cotizacion),
    estado_cotizacion VARCHAR2(15) DEFAULT 'Pendiente',
    fecha_recibido DATE,
    estado_producto VARCHAR2(20) DEFAULT 'No recibido',
    
    CONSTRAINT proveedor_cotiza_fk FOREIGN KEY(ced_proveedor)
        REFERENCES PROVEEDORES(ced_proveedor),
    
    CONSTRAINT sku_cotiza_fk FOREIGN KEY(sku_producto)
        REFERENCES MATERIALES(sku_producto)
);

CREATE TABLE FACTURACION(
    num_factura NUMBER NOT NULL,
    ced_cliente NUMBER NOT NULL,
    sku_producto VARCHAR2(30) NOT NULL,
    fecha_venta DATE DEFAULT SYSDATE,
    precio_venta NUMBER NOT NULL,
    unidades NUMBER NOT NULL,
    
    CONSTRAINT factura_pk PRIMARY KEY(num_factura,ced_cliente,sku_producto),
    
    CONSTRAINT factura_cliente_fk FOREIGN KEY(ced_cliente)
        REFERENCES CLIENTES(ced_cliente),
    
    CONSTRAINT sku_factura_fk FOREIGN KEY(sku_producto)
        REFERENCES MATERIALES(sku_producto)
);

--ALTER TABLE FACTURACION DROP CONSTRAINT factura_pk;

--ALTER TABLE FACTURACION ADD CONSTRAINT factura_pk PRIMARY KEY (sku_producto);

COMMIT;

--****FIN PARTE 1****

--****INICIO PARTE 2****

CREATE TABLE IVA(
    consecutivo NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY,
    num_factura NUMBER NOT NULL,
    sku_producto VARCHAR2(30) NOT NULL,
    iva_total NUMBER NOT NULL,
    fecha_insercion DATE DEFAULT SYSDATE,
    
    CONSTRAINT iva_pk PRIMARY KEY(consecutivo)
);

CREATE TABLE MATERIALES_DESCON(
    sku_producto VARCHAR2(30) PRIMARY KEY,
    descripcion VARCHAR2(50) NOT NULL,
    es_combo VARCHAR2(1),
    precio_unidad NUMBER NOT NULL,
    fecha_ingreso DATE,
    descontinuado VARCHAR(1) DEFAULT 'Y');

COMMIT;

--PROCEDIMIENTOS - Luis

--SP1 - Agrega nuevos valores a tabla IVA
CREATE OR REPLACE PROCEDURE ivaTotal(numFactura IN NUMBER, precio IN NUMBER, sku IN VARCHAR2)
AS
    iva NUMBER := precio*0.13;
    BEGIN
    INSERT INTO IVA(num_factura,sku_producto,iva_total) VALUES(numFactura,sku,iva);
COMMIT;
END;

EXEC ivaTotal(22,3600,'MFG785');

SELECT * FROM IVA;

--SP2 - Agregar un producto nuevo sin combo
CREATE OR REPLACE PROCEDURE nuevoProductoSin(producto IN VARCHAR2, descripcion IN VARCHAR2, precioUnidad IN NUMBER)
AS
BEGIN
    INSERT INTO MATERIALES(sku_producto,descripcion,precio_unidad) VALUES(producto,descripcion,precioUnidad);
COMMIT;
END;

Exec nuevoProductoSin('DFT34X','Tinta negra','6780');

SELECT * FROM MATERIALES;

--SP3 - Agregar un producto nuevo con combo
CREATE OR REPLACE PROCEDURE nuevoProductoCon(producto IN VARCHAR2, descripcion IN VARCHAR2, precioUnidad IN NUMBER)
AS
BEGIN
    INSERT INTO MATERIALES(sku_producto,descripcion,es_combo,precio_unidad) VALUES(producto,descripcion,'Y',precioUnidad);
COMMIT;
END;

Exec nuevoProductoCon('DFT35X','Tinta blanca','6480');

SELECT * FROM MATERIALES;

--SP4 - Actualizacion de contrasenha
CREATE OR REPLACE PROCEDURE actualizarContra(cedula IN NUMBER, contra IN VARCHAR2)
AS
BEGIN
  UPDATE USUARIOS
  SET contrasenha = contra
  WHERE ced = cedula;
  COMMIT;
END;

SELECT * FROM USUARIOS;

INSERT INTO USUARIOS(ced,nombre,apellidos,fecha_nacimiento,contrasenha) VALUES(123,'Luis','Castro','12-may-1994','A123');

EXEC actualizarContra(123,'B456');

--PROCEDIMIENTOS - Maria

--SP5 - Actualizar estado de cotizacion 

CREATE OR REPLACE PROCEDURE ActualizarEstadoCotizacion(
  p_id_cotizacion IN INT,
  p_estado_cotizacion IN VARCHAR2
) AS
BEGIN
  UPDATE Cotizaciones
  SET estado_cotizacion = p_estado_cotizacion
  WHERE id_cotizacion = p_id_cotizacion;
  
  COMMIT;
END;

--SP6 - Obtener cantidad de unidades

CREATE OR REPLACE PROCEDURE ObtenerUnidadesDisponibles(
  p_sku_producto IN INT,
  p_unidades OUT INT
) AS
BEGIN
  SELECT unidades_disponibles INTO p_unidades
  FROM Inventario
  WHERE sku_producto = p_sku_producto;
END;

--SP7 - Registrar un cliente nuevo

CREATE OR REPLACE PROCEDURE RegistrarCliente(
  p_ced_cliente INT,
  --p_tipo_ced VARCHAR2,
  p_nombre_cliente VARCHAR2,
  p_fecha_nacimiento DATE,
  p_telefono VARCHAR2,
  p_email VARCHAR2,
  p_direccion VARCHAR2,
  p_distrito VARCHAR2,
  p_canton VARCHAR2,
  p_provincia VARCHAR2
) AS
BEGIN
  INSERT INTO Clientes (
    ced_cliente,
    --tipo_ced,
    nombre_cliente,
    fecha_nacimiento,
    telefono,
    email,
    direccion,
    distrito,
    canton,
    provincia
  ) VALUES (
    p_ced_cliente,
    --p_tipo_ced,
    p_nombre_cliente,
    p_fecha_nacimiento,
    p_telefono,
    p_email,
    p_direccion,
    p_distrito,
    p_canton,
    p_provincia
  );
  
  COMMIT;
END;
/

--SP8 - Descontinuar un producto

CREATE OR REPLACE PROCEDURE DescontinuarMaterial(
  p_sku_producto IN INT
) AS
BEGIN
  UPDATE Materiales
  SET descontinuado = 'Y'
  WHERE sku_producto = p_sku_producto;
  
COMMIT;
END;

--PROCEDIMIENTOS - Dylan

--SP9 -Actualizar el precio de un material
CREATE OR REPLACE PROCEDURE ActualizarPrecioMaterial(
  p_sku_producto IN VARCHAR2,
  p_nuevo_precio IN NUMBER
)
AS
BEGIN
  UPDATE Materiales
  SET precio_unidad = p_nuevo_precio
  WHERE sku_producto = p_sku_producto;
  
  COMMIT;
END;
/
--SP10 -Registro cotizacion


CREATE OR REPLACE PROCEDURE RegistrarCotizacion(
  p_id_cotizacion IN NUMBER,
  p_ced_proveedor IN NUMBER,
  p_sku_producto IN VARCHAR2,
  p_fecha_vencimiento IN DATE,
  p_fecha_recibido IN DATE DEFAULT NULL
)
AS
BEGIN
  INSERT INTO Cotizaciones (id_cotizacion, ced_proveedor, sku_producto, fecha_cotizacion, fecha_vencimiento, fecha_recibido)
  VALUES (p_id_cotizacion, p_ced_proveedor, p_sku_producto, SYSDATE, p_fecha_vencimiento, p_fecha_recibido);
  
  COMMIT;
END;
/

--SP11 --Obtener proveedores por tipo de cedula
SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE ObtenerProveedoresPorTipoCedula(IN tipo_cedula VARCHAR2)
IS
    tipo_cedula_encontrado NUMBER;
BEGIN
    SELECT COUNT(*) INTO tipo_cedula_encontrado FROM PROVEEDORES WHERE tipo_ced = tipo_cedula;
    
    IF tipo_cedula_encontrado > 0 THEN
        FOR proveedor IN (SELECT ced_proveedor AS "CÃ©dula Proveedor",
                                 nombre_proveedor AS "Nombre Proveedor",
                                 telefono AS "TelÃ©fono Proveedor",
                                 email AS "Correo Proveedor"
                          FROM PROVEEDORES
                          WHERE tipo_ced = tipo_cedula)
        LOOP
            DBMS_OUTPUT.PUT_LINE('CÃ©dula Proveedor: ' || proveedor."CÃ©dula Proveedor" ||
                                 ', Nombre Proveedor: ' || proveedor."Nombre Proveedor" ||
                                 ', TelÃ©fono Proveedor: ' || proveedor."TelÃ©fono Proveedor" ||
                                 ', Correo Proveedor: ' || proveedor."Correo Proveedor");
        END LOOP;
    ELSE
        DBMS_OUTPUT.PUT_LINE('No se encontraron proveedores con este tipo de cÃ©dula.');
    END IF;
END;
/


--Un ejemplo de la busqueda del procedimiento 
BEGIN
    ObtenerProveedoresPorTipoCedula('JURIDICA');
END;
/

--SP12 --Obtener proveedores por distrito
SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE ObtenerProveedoresPorDistrito(IN distrito_buscar VARCHAR2)
IS
BEGIN
    DECLARE distrito_encontrado NUMBER;
    BEGIN
        SELECT COUNT(*) INTO distrito_encontrado FROM PROVEEDORES WHERE distrito = distrito_buscar;
        
        IF distrito_encontrado > 0 THEN
            FOR proveedor IN (SELECT ced_proveedor, nombre_proveedor, telefono, email FROM PROVEEDORES WHERE distrito = distrito_buscar)
            LOOP
                DBMS_OUTPUT.PUT_LINE('CÃ©dula Proveedor: ' || proveedor.ced_proveedor || ', Nombre Proveedor: ' || proveedor.nombre_proveedor || ', TelÃ©fono Proveedor: ' || proveedor.telefono || ', Correo Proveedor: ' || proveedor.email);
            END LOOP;
        ELSE
            DBMS_OUTPUT.PUT_LINE('No se encontraron proveedores en el distrito especificado.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    END;
END;



--VISTAS - Luis

--Vista1 - Ver materiales en combo
CREATE OR REPLACE VIEW materialEnCombo
AS
    SELECT * FROM MATERIALES WHERE es_combo = 'Y' AND descontinuado = 'N';

SELECT * FROM materialEnCombo;

SELECT * FROM MATERIALES;

--Vista2 - Ver materiales sin combo
CREATE OR REPLACE VIEW materialSinCombo
AS
    SELECT * FROM MATERIALES WHERE es_combo = 'N' AND descontinuado = 'N';

SELECT * FROM materialSinCombo;

--Vista3 - Ver materiales descontinuados
CREATE OR REPLACE VIEW materialDescontinuado
AS
    SELECT * FROM MATERIALES WHERE descontinuado = 'Y';

SELECT * FROM materialDescontinuado;

--VISTAS - Maria
--Vista4
CREATE OR REPLACE VIEW CotizacionesPendientes AS
SELECT c.id_cotizacion, c.ced_proveedor, c.sku_producto, c.fecha_cotizacion, c.fecha_vencimiento,
       c.dias_para_vencimiento, c.estado_cotizacion, c.fecha_recibido, c.estado_producto,
       p.nombre_proveedor, m.descripcion
FROM Cotizaciones c
JOIN Proveedores p ON c.ced_proveedor = p.ced_proveedor
JOIN Materiales m ON c.sku_producto = m.sku_producto
WHERE c.fecha_recibido IS NULL;

--Vista5 - Inventario insuficiente

CREATE OR REPLACE VIEW InventarioInsuficiente AS
SELECT I.sku_producto, M.descripcion, I.unidades_disponibles
FROM Inventario I
JOIN Materiales M ON I.sku_producto = M.sku_producto
WHERE I.unidades_disponibles < 10; -- Umbral de unidades disponibles ajustable

-- VISTAS -Dylan

--Vista6 - ventas por cliente y mes
CREATE OR REPLACE VIEW VentasPorClienteMes AS
SELECT c.ced_cliente, c.nombre_cliente, EXTRACT(MONTH FROM f.fecha_venta) AS mes, SUM(f.precio_venta) AS total_ventas
FROM CLIENTES c
JOIN FACTURACION f ON c.ced_cliente = f.ced_cliente
GROUP BY c.ced_cliente, c.nombre_cliente, EXTRACT(MONTH FROM f.fecha_venta);

--Vista7 - Productos mas vendidos 
CREATE OR REPLACE VIEW ProductosMasVendidos AS
SELECT m.sku_producto, m.descripcion, SUM(f.unidades) AS total_vendido
FROM MATERIALES m
JOIN FACTURACION f ON m.sku_producto = f.sku_producto
GROUP BY m.sku_producto, m.descripcion
ORDER BY SUM(f.unidades) DESC;

--Vista8 - Clientes con compras frecuentes 
CREATE OR REPLACE VIEW ClientesComprasFrecuentes AS
SELECT c.*
FROM CLIENTES c
WHERE EXISTS (SELECT 1 FROM FACTURACION f WHERE f.ced_cliente = c.ced_cliente GROUP BY f.ced_cliente HAVING COUNT(*) > 5);

--Vista9 - Ventas del dia
CREATE OR REPLACE VIEW VentasPorDiaSemana AS
SELECT TO_CHAR(fecha_venta, 'DAY') AS dia_semana, SUM(precio_venta) AS total_ventas
FROM FACTURACION
GROUP BY TO_CHAR(fecha_venta, 'DAY')
ORDER BY TO_CHAR(fecha_venta, 'DAY');

--Vista10 - Antiguedad de clientes 
CREATE OR REPLACE VIEW ProveedoresMasAntiguos AS
SELECT *
FROM PROVEEDORES
ORDER BY fecha_ingreso ASC;

-- Vista11 -Factura de cliente 
CREATE OR REPLACE VIEW FacturasCliente AS
SELECT ced_cliente, COUNT(*) AS num_facturas_emitidas
FROM Facturacion
GROUP BY ced_cliente;

--FUNCIONES - Luis

--Funcion1 - Compras realizadas en un especifico mes por un cliente en especifico
CREATE OR REPLACE FUNCTION clienteMasCompra(mes INTEGER, cedula INTEGER, anho INTEGER)
RETURN NUMBER
IS
    compras_mes NUMBER;
BEGIN
    SELECT SUM(precio_venta) INTO compras_mes
        FROM CLIENTES
        INNER JOIN FACTURACION USING(ced_cliente)
        WHERE ced_cliente = cedula AND EXTRACT(MONTH FROM fecha_venta) = mes AND EXTRACT(YEAR FROM fecha_venta) = anho;
        RETURN compras_mes;
END;

--Funcion2 - Total IVA recolectado en mes especifico
CREATE OR REPLACE FUNCTION iva_total(mes INTEGER, anho INTEGER)
RETURN NUMBER
IS
    totalIva NUMBER;
BEGIN
    SELECT SUM(iva_total) INTO totalIva
        FROM IVA
        WHERE EXTRACT(MONTH FROM fecha_insercion) = mes AND EXTRACT(YEAR FROM fecha_insercion) = anho;
        RETURN totalIva;
END;

--FUNCIONES - Maria 

--Funcion3

CREATE OR REPLACE FUNCTION ObtenerEdad(
  fecha_nacimiento IN DATE
) RETURN NUMBER AS
  edad NUMBER;
BEGIN
  SELECT TRUNC(MONTHS_BETWEEN(SYSDATE, fecha_nacimiento) / 12) INTO edad FROM DUAL;
  RETURN edad;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
END ObtenerEdad;
/

--Funcion4 - Calcular total de una factura

CREATE OR REPLACE FUNCTION CalcularPrecioTotalFactura(p_num_factura INT) RETURN DECIMAL AS
  precio_total DECIMAL(10, 2);
BEGIN
  SELECT SUM(precio_venta * unidades) INTO precio_total
  FROM Facturacion
  WHERE num_factura = p_num_factura;
  
  RETURN precio_total;
END;
/

--Funcion5 - Fecha mas reciente para cotizar con un proveedor 

CREATE OR REPLACE FUNCTION ObtenerFechaRecienteCotizacionProveedor(p_ced_proveedor IN INT) RETURN DATE AS
  fecha_reciente DATE;
BEGIN
  SELECT MAX(fecha_cotizacion) INTO fecha_reciente
  FROM Cotizaciones
  WHERE ced_proveedor = p_ced_proveedor;
  
  RETURN fecha_reciente;
END;

COMMIT;

--FUNCIONES - Dylan

--Funcion6 -Total de compras de un cliente 
CREATE OR REPLACE FUNCTION TotalComprasCliente(
  p_ced_cliente IN NUMBER
) RETURN NUMBER
IS
  total_compras NUMBER;
BEGIN
  SELECT COUNT(*) INTO total_compras
  FROM Facturacion
  WHERE ced_cliente = p_ced_cliente;
  
  RETURN total_compras;
END;

--Funcion7 - Promedio de los precios de los materiales
CREATE OR REPLACE FUNCTION PromedioPreciosMateriales RETURN NUMBER
IS
  promedio_precios NUMBER;
BEGIN
  SELECT AVG(precio_unidad) INTO promedio_precios
  FROM Materiales;
  
  RETURN promedio_precios;
END;

--Funcion8 - Edad de los clientes 
CREATE OR REPLACE FUNCTION CalcularEdadCliente(
  p_ced_cliente IN NUMBER
) RETURN NUMBER
IS
  edad NUMBER;
BEGIN
  SELECT EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM fecha_nacimiento) INTO edad
  FROM Clientes
  WHERE ced_cliente = p_ced_cliente;
  
  RETURN edad;
END;

--PAQUETES - Luis

--Paquete1 - Actualizar inventario por SKU y ver inventario por SKU de producto
CREATE OR REPLACE PACKAGE disponibilidadSKU AS

    PROCEDURE actualizarUnidades(numSKU VARCHAR2, unidades NUMBER);
    
    FUNCTION inventarioSKU(numSKU VARCHAR2)
    RETURN NUMBER;
    
END disponibilidadSKU;

CREATE OR REPLACE PACKAGE BODY disponibilidadSKU AS

PROCEDURE actualizarUnidades(numSKU VARCHAR2, unidades NUMBER)
AS
BEGIN
    UPDATE INVENTARIO
    SET unidades_disponibles = unidades
    WHERE sku_producto = numSKU;
COMMIT;
END actualizarUnidades;

FUNCTION inventarioSKU(numSKU VARCHAR2)
RETURN NUMBER 
IS
    unidadesSKU NUMBER;
BEGIN
    SELECT unidades_disponibles INTO unidadesSKU FROM INVENTARIO
        WHERE sku_producto = numSKU;
    RETURN unidadesSKU;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END inventarioSKU;

END disponibilidadSKU;

COMMIT;

--Paquete2 - Actualizar cotizacion a recibido/cancelado y ver cotizacion por id_cotizacion
CREATE OR REPLACE PACKAGE condicionCotizacion AS

PROCEDURE cancelaCotizacion(idCotizacion NUMBER);

PROCEDURE recibeCotizacion(idCotizacion NUMBER);

CURSOR verCotizacion(idCotizacion NUMBER) IS
    SELECT id_cotizacion,nombre_proveedor,sku_producto,fecha_cotizacion,estado_cotizacion,estado_producto
    FROM COTIZACIONES
    INNER JOIN PROVEEDORES USING (ced_proveedor)
    WHERE id_cotizacion = idCotizacion;
    
END condicionCotizacion;

CREATE OR REPLACE PACKAGE BODY condicionCotizacion AS

PROCEDURE cancelaCotizacion(idCotizacion NUMBER)
AS
BEGIN
    UPDATE COTIZACIONES
    SET estado_cotizacion = 'Cancelado',
    fecha_recibido = SYSDATE
    WHERE id_cotizacion = idCotizacion;
COMMIT;
END cancelaCotizacion;

PROCEDURE recibeCotizacion(idCotizacion NUMBER)
AS
BEGIN
    UPDATE COTIZACIONES
    SET estado_cotizacion = 'Completado',
    fecha_recibido = SYSDATE,
    estado_producto = 'Recibido sin defectos'
    WHERE id_cotizacion = idCotizacion;
COMMIT;
END recibeCotizacion;

END condicionCotizacion;

COMMIT;

--PAQUETES - Dylan

--Paquete3 - Gestion de clientes y facturacion.
CREATE OR REPLACE PACKAGE Clientes_Facturas_Package IS
  -- Registrar un nuevo cliente y su factura
  PROCEDURE RegistrarClienteConFactura(
    p_ced_cliente NUMBER,
    p_nombre_cliente VARCHAR2,
    p_fecha_nacimiento DATE,
    p_telefono VARCHAR2,
    p_email VARCHAR2,
    p_direccion VARCHAR2,
    p_distrito VARCHAR2,
    p_canton VARCHAR2,
    p_provincia VARCHAR2,
    p_sku_producto VARCHAR2,
    p_precio_venta NUMBER,
    p_unidades NUMBER
  );

  -- Obtener detalles de una factura con el nombre del cliente
  FUNCTION ObtenerDetallesFacturaCliente(
    p_num_factura NUMBER
  ) RETURN SYS_REFCURSOR;
  
  -- Obtener total de ventas por cliente en un rango de fechas
  FUNCTION ObtenerTotalVentasCliente(
    p_ced_cliente NUMBER,
    p_fecha_inicio DATE,
    p_fecha_fin DATE
  ) RETURN NUMBER;
  
  -- Obtener clientes con mayor monto de compras
  FUNCTION ObtenerClientesMayoresCompras(
    p_cantidad_clientes NUMBER
  ) RETURN SYS_REFCURSOR;
  
END Clientes_Facturas_Package;
/

--Paquete4 - Permite agregar ,actualizar o obtener detalles con respecto a proveedores 

CREATE OR REPLACE PACKAGE Proveedores_Package IS
  -- Registrar un nuevo proveedor
  PROCEDURE RegistrarProveedor(
    p_ced_proveedor NUMBER,
    p_tipo_ced VARCHAR2,
    p_nombre_proveedor VARCHAR2,
    p_telefono VARCHAR2,
    p_email VARCHAR2,
    p_direccion VARCHAR2,
    p_distrito VARCHAR2,
    p_canton VARCHAR2,
    p_provincia VARCHAR2
  );

  -- Obtener detalles de un proveedor
  FUNCTION ObtenerDetallesProveedor(
    p_ced_proveedor NUMBER
  ) RETURN SYS_REFCURSOR;
  
  -- Actualizar informaciÃÂÃÂ³n de un proveedor
  PROCEDURE ActualizarProveedor(
    p_ced_proveedor NUMBER,
    p_telefono VARCHAR2,
    p_email VARCHAR2,
    p_direccion VARCHAR2
  );
  
  -- Obtener proveedores con mÃÂÃÂ¡s cotizaciones
  FUNCTION ObtenerProveedoresConMasCotizaciones(
    p_cantidad_proveedores NUMBER
  ) RETURN SYS_REFCURSOR;
  
  -- Obtener proveedores por provincia
  FUNCTION ObtenerProveedoresPorProvincia(
    p_provincia VARCHAR2
  ) RETURN SYS_REFCURSOR;
  
END Proveedores_Package;
/

--PAQUETES - Maria

--Paquete5 - Facturacion

CREATE OR REPLACE PACKAGE Facturacion_Package IS
  -- Crear una factura
  PROCEDURE CrearFactura(
    p_num_factura INT,
    p_ced_cliente INT,
    p_sku_producto INT,
    p_fecha_venta DATE,
    p_precio_unidad DECIMAL,
    p_unidades INT
  );
  
  -- Calcular el monto total de una factura
  FUNCTION CalcularMontoTotalFactura(
    p_num_factura INT
  ) RETURN DECIMAL;
  
  -- Todas las facturas de un cliente
  FUNCTION ObtenerFacturasCliente(
    p_ced_cliente INT
  ) RETURN SYS_REFCURSOR;
  
  -- Detalles de una factura
  FUNCTION ObtenerDetallesFactura(
    p_num_factura INT
  ) RETURN SYS_REFCURSOR;
  
END Facturacion_Package;
/

--Paquete6
--Dio error
CREATE OR REPLACE PACKAGE GestionMateriales AS
  --insertar un nuevo material 
  PROCEDURE InsertarMaterial(
    p_sku_producto IN Materiales.sku_producto%TYPE,
    p_descripcion IN Materiales.descripcion%TYPE,
    p_precio_unidad IN Materiales.precio_unidad%TYPE,
    p_descontinuado IN Materiales.descontinuado%TYPE DEFAULT 0
  );

  --actualizar la descripciÃ³n de un material existente
  PROCEDURE ActualizarDescripcionMaterial(
    p_sku_producto IN Materiales.sku_producto%TYPE,
    p_descripcion IN Materiales.descripcion%TYPE
  );
END GestionMateriales;
/

--Body DIO ERROR
CREATE OR REPLACE PACKAGE BODY GestionMateriales AS
  PROCEDURE InsertarMaterial(
    p_sku_producto IN Materiales.sku_producto%TYPE,
    p_descripcion IN Materiales.descripcion%TYPE,
    p_precio_unidad IN Materiales.precio_unidad%TYPE,
    p_descontinuado IN Materiales.descontinuado%TYPE DEFAULT 0
  ) IS
  BEGIN
    INSERT INTO Materiales (sku_producto, descripcion, precio_unidad, descontinuado)
    VALUES (p_sku_producto, p_descripcion, p_precio_unidad, p_descontinuado);

    COMMIT;
  END;
END GestionMateriales;
/

--TRIGGERS - Luis

--Trigger1 - Ejecutar SP ivaTotal (agregar nuevo registro de IVA) cuando se registra una venta en FACTURACION
CREATE OR REPLACE TRIGGER alimentarIVA
AFTER INSERT ON FACTURACION
--REFERENCING NEW AS n  

FOR EACH ROW
DECLARE
   numFacturaN NUMBER;
   precioN NUMBER;
   skuN VARCHAR2(30);
   
BEGIN
    SELECT num_factura, precio_venta, sku_producto INTO numFacturaN, precioN, skuN 
        FROM FACTURACION
        WHERE num_factura = :NEW.num_factura;
    
    --Ejecucion de Store Procedure:
    IVATOTAL(numFacturaN,precioN,skuN);
    
END;

--TRIGGERS - Dylan

--Trigger2 - Actalizar el estado de la cotizacion si se encuentra vencida
CREATE OR REPLACE TRIGGER ActualizarEstadoCotizacion
BEFORE INSERT OR UPDATE ON Cotizaciones
FOR EACH ROW
BEGIN
  IF :NEW.fecha_vencimiento < SYSDATE THEN
    :NEW.estado_cotizacion := 'Vencida';
  END IF;
END;
/
-- Trigger3 - alerta en caso de poco producto
--Dio error
CREATE OR REPLACE TRIGGER ControlStockMinimo
AFTER INSERT ON Facturacion
FOR EACH ROW
DECLARE
  v_sku_producto VARCHAR2(30);
  v_unidades_vendidas NUMBER;
  v_stock_minimo NUMBER;
BEGIN
  v_sku_producto := :NEW.sku_producto;
  v_unidades_vendidas := :NEW.unidades;

  SELECT unidades_disponibles
  INTO v_stock_minimo
  FROM Inventario
  WHERE sku_producto = v_sku_producto;

  IF v_stock_minimo - v_unidades_vendidas < 10 THEN
    -- Enviar una notificaciÃÂÃÂ³n al encargado de inventario sobre el bajo stock
    INSERT INTO NotificacionesInventario (mensaje, fecha_notificacion)
    VALUES ('Bajo stock: SKU ' || v_sku_producto || ' - Unidades disponibles: ' || v_stock_minimo, SYSDATE);
  END IF;
END;
/

--TRIGGER - Maria

--Trigger4 - Actualiza unidades disponibles luego de una venta
CREATE OR REPLACE TRIGGER ActualizarUnidadesDisponibles
AFTER INSERT ON Facturacion
FOR EACH ROW
DECLARE
  v_sku_producto INT;
  v_unidades_vendidas INT;
BEGIN
  v_sku_producto := :NEW.sku_producto;
  v_unidades_vendidas := :NEW.unidades;
  
  UPDATE Inventario
  SET unidades_disponibles = unidades_disponibles - v_unidades_vendidas
  WHERE sku_producto = v_sku_producto;
END;
/

--CURSORES - Luis

--Cursor1 - Tomar los materiales descontinuados y trasladarlos a una tabla de auditoria de este tipo de materiales
DECLARE
    sku VARCHAR2(30);
    descripcion VARCHAR2(50);
    combo VARCHAR2(1);
    precio NUMBER;
    fecha DATE;
    
    CURSOR c_descont IS
    SELECT sku_producto, descripcion, es_combo, precio_unidad, fecha_registro_producto FROM MATERIALES WHERE descontinuado = 'Y';
    r_descont c_descont%ROWTYPE;
BEGIN
    OPEN c_descont;
    
    LOOP
        FETCH c_descont into r_descont;
        EXIT WHEN c_descont%NOTFOUND;
        
        IF sku IS NOT NULL THEN
            INSERT INTO MATERIALES_DESCON(sku_producto,descripcion,es_combo,precio_unidad,fecha_ingreso) VALUES(sku,descripcion,combo,precio,fecha);
            ELSE
            EXIT;
        END IF;
    END LOOP;
    
    CLOSE c_descont;
END;

SELECT * FROM MATERIALES_DESCON;

--Cursor2 - Tomar las cotizaciones a vencer en los proximos 10 dias a vencer y cargarlo en una tabla destinada a eso
SET  SERVEROUTPUT ON;

DECLARE
    vence10 SYS_REFCURSOR;
    
    idCotizacion COTIZACIONES.id_cotizacion%TYPE;
    cedProveedor COTIZACIONES.ced_proveedor%TYPE;
    sku COTIZACIONES.sku_producto%TYPE;
    fecha_vence COTIZACIONES.fecha_vencimiento%TYPE;
    dias_para_vencer COTIZACIONES.dias_para_vencimiento%TYPE;
BEGIN
    OPEN vence10 FOR SELECT id_cotizacion, ced_proveedor, sku_producto, fecha_vencimiento, dias_para_vencimiento
        FROM COTIZACIONES
        WHERE dias_para_vencimiento BETWEEN 1 AND 10;
    
    FETCH vence10 INTO idCotizacion, cedProveedor, sku, fecha_vence, dias_para_vencer;
    
    CLOSE vence10;
    
    DBMS_OUTPUT.PUT_LINE('ID Cotizacion: ' || idCotizacion || '. Ced Proveedor: ' || 
    cedProveedor || '. Producto: ' || sku || '. Vence el: ' || fecha_vence || '. Dias para vencer: ' || dias_para_vencer);
END;

--CURSORES - Dylan

--Cursor3 -Clientes sin compras
DECLARE
  CURSOR clientes_sin_compras_cursor IS
    SELECT *
    FROM Clientes c
    WHERE NOT EXISTS (
      SELECT 1
      FROM Facturacion f
      WHERE c.ced_cliente = f.ced_cliente
    );
  
  cliente_sin_compras Clientes%ROWTYPE;
BEGIN
  OPEN clientes_sin_compras_cursor;
  
  LOOP
    FETCH clientes_sin_compras_cursor INTO cliente_sin_compras;
    EXIT WHEN clientes_sin_compras_cursor%NOTFOUND;
    
    DBMS_OUTPUT.PUT_LINE('Cliente sin Compras:');
    DBMS_OUTPUT.PUT_LINE('CÃÂÃÂ©dula: ' || cliente_sin_compras.ced_cliente);
    DBMS_OUTPUT.PUT_LINE('Nombre: ' || cliente_sin_compras.nombre_cliente);
    
  END LOOP;
  
  CLOSE clientes_sin_compras_cursor;
END;
/

--Cursor4 -Facturas emitidas en el ultimo mes
DECLARE
  CURSOR facturas_ultimo_mes_cursor IS
    SELECT *
    FROM Facturacion
    WHERE fecha_venta >= ADD_MONTHS(TRUNC(SYSDATE, 'MONTH'), -1);
  
  factura_ultimo_mes Facturacion%ROWTYPE;
BEGIN
  OPEN facturas_ultimo_mes_cursor;
  
  LOOP
    FETCH facturas_ultimo_mes_cursor INTO factura_ultimo_mes;
    EXIT WHEN facturas_ultimo_mes_cursor%NOTFOUND;

    DBMS_OUTPUT.PUT_LINE('Factura Emitida en el ultimo Mes:');
    DBMS_OUTPUT.PUT_LINE('Numero: ' || factura_ultimo_mes.num_factura);
    DBMS_OUTPUT.PUT_LINE('CÃÂÃÂ©dula Cliente: ' || factura_ultimo_mes.ced_cliente);
    
  END LOOP;
  
  CLOSE facturas_ultimo_mes_cursor;
END;
/
--Cursor5 -Materiales mas vendidos
ALTER SESSION SET NLS_NCHAR_CHARACTERSET = 'AL32UTF8';

DECLARE
  CURSOR materiales_mas_vendidos_cursor IS
    SELECT m.sku_producto, m.descripcion, SUM(f.cantidad) AS total_vendido
    FROM Materiales m
    JOIN Facturacion f ON m.sku_producto = f.sku_producto
    GROUP BY m.sku_producto, m.descripcion
    ORDER BY total_vendido DESC;
  material_mas_vendido materiales_mas_vendidos_cursor%ROWTYPE;
BEGIN
  OPEN materiales_mas_vendidos_cursor;
  LOOP
    FETCH materiales_mas_vendidos_cursor INTO material_mas_vendido;
    EXIT WHEN materiales_mas_vendidos_cursor%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('Material mas vendido - SKU: ' || material_mas_vendido.sku_producto || ', Descripcion: ' || material_mas_vendido.descripcion || ', Total Vendido: ' || material_mas_vendido.total_vendido);
  END LOOP;

  CLOSE materiales_mas_vendidos_cursor;
END;
/


--CURSORES - Maria

--Cursor6 - Cotizacion vencida

DECLARE
  CURSOR cotizaciones_cursor IS
    SELECT *
    FROM Cotizaciones
    WHERE fecha_vencimiento < SYSDATE;
  
  cotizacion Cotizaciones%ROWTYPE;
BEGIN
  OPEN cotizaciones_cursor;
  
  LOOP
    FETCH cotizaciones_cursor INTO cotizacion;
    EXIT WHEN cotizaciones_cursor%NOTFOUND;

    --Imprimir la informaciÃÂ³n de la cotizaciÃÂ³n
    DBMS_OUTPUT.PUT_LINE('CotizaciÃÂ³n Vencida:');
    DBMS_OUTPUT.PUT_LINE('ID: ' || cotizacion.id_cotizacion);
  
  END LOOP;
  
  CLOSE cotizaciones_cursor;
END;
/

--Cursor7

CREATE OR REPLACE PROCEDURE MostrarDetallesClientes AS
  -- DeclaraciÃ³n
  CURSOR c_clientes IS
    SELECT ced_cliente, nombre_cliente, telefono, email, fecha_registro
    FROM Clientes;
    
  -- Variables
  v_ced_cliente Clientes.ced_cliente%TYPE;
  v_nombre_cliente Clientes.nombre_cliente%TYPE;
  v_telefono Clientes.telefono%TYPE;
  v_email Clientes.email%TYPE;
  v_fecha_registro Clientes.fecha_registro%TYPE;
BEGIN
  
  OPEN c_clientes;

  -- Recorrer los datos
  LOOP
    FETCH c_clientes INTO v_ced_cliente, v_nombre_cliente, v_telefono, v_email, v_fecha_registro;
    EXIT WHEN c_clientes%NOTFOUND; -- Salir del bucle cuando no hay mÃ¡s datos

    --detalles del cliente
    DBMS_OUTPUT.PUT_LINE('CÃ©dula: ' || v_ced_cliente);
    DBMS_OUTPUT.PUT_LINE('Nombre: ' || v_nombre_cliente);
    DBMS_OUTPUT.PUT_LINE('TelÃ©fono: ' || v_telefono);
    DBMS_OUTPUT.PUT_LINE('Email: ' || v_email);
    DBMS_OUTPUT.PUT_LINE('Fecha de registro: ' || v_fecha_registro);

  END LOOP;

  
  CLOSE c_clientes;
END;
/

--Cursor 8 - Material no disponible

DECLARE
  CURSOR materiales_cursor IS
    SELECT *
    FROM Materiales
    WHERE descontinuado = 'S';
  
  material Materiales%ROWTYPE;
BEGIN
  OPEN materiales_cursor;
  
  LOOP
    FETCH materiales_cursor INTO material;
    EXIT WHEN materiales_cursor%NOTFOUND;
    
    -- Imprimir la información del material
    DBMS_OUTPUT.PUT_LINE('Material Descontinuado:');
    DBMS_OUTPUT.PUT_LINE('SKU: ' || material.sku_producto);
    DBMS_OUTPUT.PUT_LINE('DescripciÃÂ³n: ' || material.descripcion);
    
  END LOOP;
  
  CLOSE materiales_cursor;
END;
/

COMMIT;

--*************************************************************
--*************************************************************
--*************************************************************
--*************************************************************
--*************************************************************
--*************************************************************
--*************************************************************
--*************************************************************
--*************************************************************
--*************************************************************

--*2 VISTAS PARA Inventario y Facturacion (SELECTs) PARA VISTA WEB: ESTADO_GENERAL.HTML (LUIS)*
--VISTA 1 - INVENTARIO
CREATE OR REPLACE VIEW inventarioEG
AS
    SELECT A.SKU_PRODUCTO, B.DESCRIPCION, B.ES_COMBO, A.UNIDADES_DISPONIBLES, (A.UNIDADES_DISPONIBLES*B.PRECIO_UNIDAD) AS VALOR_TOTAL
        FROM INVENTARIO A
        INNER JOIN MATERIALES B ON A.SKU_PRODUCTO = B.SKU_PRODUCTO
        WHERE B.DESCONTINUADO = 'N'
        ORDER BY A.SKU_PRODUCTO;
COMMIT;

SELECT * FROM MATERIALES;
SELECT * FROM INVENTARIO;
SELECT * FROM inventarioEG;

--*************************************************************

--VISTA 2 - COTIZACIONES
CREATE OR REPLACE VIEW cotizaEG
AS
    SELECT A.id_cotizacion, A.ced_proveedor, B.nombre_proveedor, A.sku_producto, C.descripcion,
        A.fecha_cotizacion, A.fecha_vencimiento, A.dias_para_vencimiento
        FROM cotizaciones A
        INNER JOIN proveedores B ON A.ced_proveedor = B.ced_proveedor
        INNER JOIN materiales C ON A.sku_producto = C.sku_producto
        WHERE A.estado_cotizacion = 'Pendiente' AND A.estado_producto = 'No recibido'
        ORDER BY A.id_cotizacion;

COMMIT;

SELECT * FROM cotizaEG;

--*************************************************************
--*************************************************************

--*1 TRIGGER (registra DELETEs o UPDATEs en cuaquiera de las 3 sub-vistas) PARA VISTA WEB: ESTADO_GENERAL.HTML (LUIS)* COMPLETO

--Despues que se realiza un INSERT en tabla MATERIALES, se llevara el SKU a INVENTARIO automaticamente
SELECT * FROM inventario;

CREATE OR REPLACE TRIGGER materiales_inventario_trg
AFTER INSERT ON materiales
REFERENCING NEW AS NEW
FOR EACH ROW

BEGIN
    --insertar en la tabla de inventario
    INSERT INTO inventario(SKU_PRODUCTO,UNIDADES_DISPONIBLES)
        VALUES(:NEW.SKU_PRODUCTO,0);
END;

COMMIT;

--*************************************************************
--*************************************************************

--*2 PAQUETES (1 para el 3er DELETE y el otro para una funcion MARCADOR que muestre los SKU con menos de 10 unidades en inventario) PARA VISTA WEB: ESTADO_GENERAL.HTML (LUIS)* COUNT: 1
--1. PAQUETE 1 - Para el inventario
CREATE OR REPLACE PACKAGE mostrarInventario
AS
--Trae info a tabla
PROCEDURE mostrarInventarioVista(
    recorreInventario OUT SYS_REFCURSOR
);

--Trae info de unidades
FUNCTION obtenerInvFiltrado(
    sku IN VARCHAR2)
RETURN NUMBER;

--Actualiza
PROCEDURE actualizaInventario(
    sku IN VARCHAR2,
    unidades IN NUMBER
);

--Eliminar
PROCEDURE eliminaInventario(
    sku IN VARCHAR2
);
END mostrarInventario;

CREATE OR REPLACE PACKAGE BODY mostrarInventario 
AS
PROCEDURE mostrarInventarioVista(
recorreInventario OUT SYS_REFCURSOR
)
IS
BEGIN 
    OPEN recorreInventario FOR SELECT SKU_PRODUCTO, DESCRIPCION, ES_COMBO, UNIDADES_DISPONIBLES, VALOR_TOTAL
        FROM inventarioEG;
END mostrarInventarioVista;

FUNCTION obtenerInvFiltrado(
    sku IN VARCHAR2)
RETURN NUMBER
IS
unidades NUMBER;
BEGIN 
    SELECT UNIDADES_DISPONIBLES INTO unidades
        FROM inventarioEG WHERE SKU_PRODUCTO = sku;
    RETURN unidades;
END obtenerInvFiltrado;

PROCEDURE actualizaInventario(
    sku IN VARCHAR2,
    unidades IN NUMBER
)
IS
BEGIN
    UPDATE inventario SET unidades_disponibles=unidades WHERE sku_producto=sku;
END actualizaInventario;

PROCEDURE eliminaInventario(
    sku IN VARCHAR2
)
IS
BEGIN
    DELETE FROM inventario WHERE sku_producto=sku;
END eliminaInventario;
END mostrarInventario;

COMMIT;

--*******************************************************

--2. PAQUETE 2 - Para cotizaciones
CREATE OR REPLACE PACKAGE mostrarCotizacion
AS
--Cargar datos en tabla
PROCEDURE mostrarCotizacionVista(
    recorreCotizacion OUT SYS_REFCURSOR
);

--Trae info de cedula
FUNCTION obtenerCotCed(
    idCot IN NUMBER)
RETURN NUMBER;

--Insertar nuevas cotizaciones
PROCEDURE nuevaCotizacion(idProveedor IN NUMBER, producto IN VARCHAR2, fechaCotiza IN VARCHAR2, fechaVence IN VARCHAR2);

--Actualiza
PROCEDURE actualizaCotiza(
    idCot IN NUMBER,
    idProveedor IN NUMBER, 
    producto IN VARCHAR2, 
    fechaCotiza IN VARCHAR2, 
    fechaVence IN VARCHAR2
);

PROCEDURE eliminaCotiza(
    idCot IN NUMBER
);
END mostrarCotizacion;

CREATE OR REPLACE PACKAGE BODY mostrarCotizacion 
AS
--Tabla
PROCEDURE mostrarCotizacionVista(
recorreCotizacion OUT SYS_REFCURSOR
)
IS
BEGIN 
        OPEN recorreCotizacion FOR SELECT ID_COTIZACION, CED_PROVEEDOR, NOMBRE_PROVEEDOR, SKU_PRODUCTO, DESCRIPCION,
        FECHA_COTIZACION, FECHA_VENCIMIENTO, DIAS_PARA_VENCIMIENTO
        FROM cotizaEG;
END mostrarCotizacionVista;

PROCEDURE nuevaCotizacion(
idProveedor IN NUMBER, 
producto IN VARCHAR2, 
fechaCotiza IN VARCHAR2, 
fechaVence IN VARCHAR2
)
IS
    fechaCotiza1 DATE := TO_DATE(fechaCotiza,'DD-MM-YY');
    fechaVence1 DATE := TO_DATE(fechaVence,'DD-MM-YY');
BEGIN
    INSERT INTO COTIZACIONES(ced_proveedor,sku_producto,fecha_cotizacion,fecha_vencimiento) VALUES(idProveedor,producto,fechaCotiza1,fechaVence1);
    COMMIT;
END nuevaCotizacion;

--Trae info de cedula
FUNCTION obtenerCotCed(
    idCot IN NUMBER)
RETURN NUMBER
IS
cedPro NUMBER;
BEGIN 
    SELECT CED_PROVEEDOR INTO cedPro
        FROM cotizaEG WHERE ID_COTIZACION = idCot;
    RETURN cedPro;
END obtenerCotCed;

PROCEDURE actualizaCotiza(
    idCot IN NUMBER,
    idProveedor IN NUMBER, 
    producto IN VARCHAR2, 
    fechaCotiza IN VARCHAR2, 
    fechaVence IN VARCHAR2
)
IS
    fechaCotiza1 DATE := TO_DATE(fechaCotiza,'DD-MM-YY');
    fechaVence1 DATE := TO_DATE(fechaVence,'DD-MM-YY');
BEGIN
    UPDATE cotizaciones SET ced_proveedor=idProveedor, sku_producto=producto, fecha_cotizacion=fechaCotiza1, fecha_vencimiento=fechaVence1 WHERE id_cotizacion=idCot;
END actualizaCotiza;

PROCEDURE eliminaCotiza(
    idCot IN NUMBER
)
IS
BEGIN
    DELETE FROM cotizaciones WHERE id_cotizacion=idCot;
END eliminaCotiza;

END mostrarCotizacion;

COMMIT;

--************************************************
--************************************************

--Giovanni
create or replace NONEDITIONABLE PROCEDURE SP_BuscarUusuario (
    p_username IN VARCHAR2,
    p_password IN VARCHAR2,
    p_result OUT NUMBER
) AS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM usuarios
    WHERE ced = p_username AND CONTRASENHA = p_password;

    IF v_count > 0 THEN
        p_result := 1; -- Login exitoso
    ELSE
        p_result := 0; -- Login fallido
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_result := 0; -- Login fallido
    WHEN OTHERS THEN
        p_result := -1; -- Error en el procedimiento
END SP_BuscarUusuario;

--************************************************
--************************************************

--Maria
-- Crear o reemplazar el paquete para manejar materiales
CREATE OR REPLACE PACKAGE MostrarMaterial AS
    -- Procedimiento para obtener todos los materiales
    PROCEDURE MostrarMaterialesVista(
        p_cursor OUT SYS_REFCURSOR
    );
    --Busqueda
   -- Procedimiento para Agregar un material
    PROCEDURE AgregarMaterial(
        p_sku_producto IN VARCHAR2,
        p_descripcion IN VARCHAR2,
        p_precio_unidad IN NUMBER
       
    );
    
    -- Procedimiento para actualizar la informaci�n de un material
    PROCEDURE ActualizarMaterial(
        p_sku_producto IN VARCHAR2,
        p_descripcion IN VARCHAR2,
        p_precio_unidad IN NUMBER
       
    );
    
    -- Procedimiento para eliminar un material
    PROCEDURE EliminarMaterial(
        p_sku_producto IN VARCHAR2
    );
END MostrarMaterial;
/

-- Crear o reemplazar el cuerpo del paquete para manejar materiales
CREATE OR REPLACE PACKAGE BODY MostrarMaterial AS
    -- Procedimiento para obtener todos los materiales
    PROCEDURE MostrarMaterialesVista(
        p_cursor OUT SYS_REFCURSOR
    ) AS
    BEGIN
        OPEN p_cursor FOR
            SELECT *
            FROM MATERIALES;
    END MostrarMaterialesVista;
    
    -- Procedimiento para Agregar un material
    PROCEDURE AgregarMaterial(
        p_sku_producto IN VARCHAR2,
        p_descripcion IN VARCHAR2,
        p_precio_unidad IN NUMBER
       
    ) AS
    BEGIN
           INSERT INTO MATERIALES(sku_producto, descripcion, precio_unidad) VALUES (p_sku_producto, p_descripcion, p_precio_unidad);
           commit;
    END AgregarMaterial;
  
   
    
    -- Procedimiento para actualizar la informaci�n de un material
    PROCEDURE ActualizarMaterial(
        p_sku_producto IN VARCHAR2,
        p_descripcion IN VARCHAR2,
        p_precio_unidad IN NUMBER
       
    ) AS
    BEGIN
        UPDATE MATERIALES
        SET descripcion = p_descripcion,
            precio_unidad = p_precio_unidad
        WHERE sku_producto = p_sku_producto;
    END ActualizarMaterial;
  
    -- Procedimiento para eliminar un material
    PROCEDURE EliminarMaterial(
        p_sku_producto IN VARCHAR2
    ) AS
    BEGIN
     DELETE FROM inventario
WHERE sku_producto = p_sku_producto;
        DELETE FROM MATERIALES
        WHERE sku_producto = p_sku_producto;
    END EliminarMaterial;
END MostrarMaterial;
