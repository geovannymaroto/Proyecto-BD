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
        
--DROP TABLE MATERIALES CASCADE CONSTRAINTS; --Eliminar con constraints

CREATE TABLE USUARIOS(
    ced NUMBER PRIMARY KEY,
    nombre VARCHAR2(25) NOT NULL,
    apellidos VARCHAR2(50) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    contrasenha VARCHAR2(100) NOT NULL);
    
CREATE TABLE MATERIALES(
    sku_producto VARCHAR2(30) PRIMARY KEY,
    descripcion VARCHAR2(50) NOT NULL,
    es_combo VARCHAR2(1) DEFAULT 'N',
    precio_unidad NUMBER NOT NULL,
    fecha_ultima_modificacion DATE DEFAULT SYSDATE,
    descontinuado VARCHAR2(1) DEFAULT 'N');

--INSERT INTO MATERIALES(sku_producto,descripcion,precio_unidad) VALUES('ABC123','Comida',148.32);

--SELECT * FROM MATERIALES;
    
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

CREATE TABLE CLIENTES(
    ced_cliente NUMBER PRIMARY KEY,
    nombre_proveedor VARCHAR2(50) NOT NULL,
    fecha_nacimiento DATE,
    telefono VARCHAR2(15) NOT NULL,
    email VARCHAR2(100) NOT NULL,
    direccion VARCHAR2(100),
    distrito VARCHAR2(20),
    canton VARCHAR2(20),
    provincia VARCHAR2(20),
    fecha_registro DATE DEFAULT SYSDATE);
    
CREATE TABLE INVENTARIO(
    sku_producto VARCHAR2(30) PRIMARY KEY,
    unidades_disponibles NUMBER NOT NULL,
    fecha_ultima_modificacion DATE DEFAULT SYSDATE,
    
    CONSTRAINT sku_inventario_fk FOREIGN KEY(sku_producto)
        REFERENCES MATERIALES(sku_producto) ON DELETE CASCADE
);
    
CREATE TABLE COTIZACIONES(
    id_cotizacion NUMBER NOT NULL,
    ced_proveedor NUMBER NOT NULL,
    sku_producto VARCHAR2(30) NOT NULL,
    fecha_cotizacion DATE DEFAULT SYSDATE,
    fecha_vencimiento DATE NOT NULL,
    dias_para_vencimiento NUMBER AS(fecha_vencimiento - fecha_cotizacion),
    estado_cotizacion VARCHAR2(15) DEFAULT 'Pendiente',
    fecha_recibido DATE,
    estado_producto VARCHAR2(20) DEFAULT 'No recibido',
    
    CONSTRAINT cotiza_pk PRIMARY KEY(id_cotizacion,ced_proveedor,sku_producto),
    
    CONSTRAINT proveedor_cotiza_fk FOREIGN KEY(ced_proveedor)
        REFERENCES PROVEEDORES(ced_proveedor) ON DELETE CASCADE,
    
    CONSTRAINT sku_cotiza_fk FOREIGN KEY(sku_producto)
        REFERENCES MATERIALES(sku_producto) ON DELETE CASCADE
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
        REFERENCES CLIENTES(ced_cliente) ON DELETE CASCADE,
    
    CONSTRAINT sku_factura_fk FOREIGN KEY(sku_producto)
        REFERENCES MATERIALES(sku_producto) ON DELETE CASCADE
);

COMMIT;