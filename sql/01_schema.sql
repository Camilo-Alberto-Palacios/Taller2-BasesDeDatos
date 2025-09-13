-- schema.sql (MySQL 8.0+)

-- Limpieza
DROP TRIGGER IF EXISTS tr_docente_after_update;
DROP TRIGGER IF EXISTS tr_docente_after_delete;

DROP TABLE IF EXISTS copia_eliminados_docente;
DROP TABLE IF EXISTS copia_actualizados_docente;
DROP TABLE IF EXISTS proyecto;
DROP TABLE IF EXISTS docente;

-- Tablas base
CREATE TABLE docente (
  docente_id        INT AUTO_INCREMENT PRIMARY KEY,
  numero_documento  VARCHAR(20)  NOT NULL,
  nombres           VARCHAR(120) NOT NULL,
  titulo            VARCHAR(120),
  anios_experiencia INT          NOT NULL DEFAULT 0,
  direccion         VARCHAR(180),
  tipo_docente      VARCHAR(40),
  CONSTRAINT uq_docente_documento UNIQUE (numero_documento),
  CONSTRAINT ck_docente_anios CHECK (anios_experiencia >= 0)
) ENGINE=InnoDB;

CREATE TABLE proyecto (
  proyecto_id      INT AUTO_INCREMENT PRIMARY KEY,
  nombre           VARCHAR(120) NOT NULL,
  descripcion      VARCHAR(400),
  fecha_inicial    DATE NOT NULL,
  fecha_final      DATE,
  presupuesto      DECIMAL(12,2) NOT NULL DEFAULT 0,
  horas            INT           NOT NULL DEFAULT 0,
  docente_id_jefe  INT NOT NULL,
  CONSTRAINT ck_proyecto_horas CHECK (horas >= 0),
  CONSTRAINT ck_proyecto_pres CHECK (presupuesto >= 0),
  CONSTRAINT ck_proyecto_fechas CHECK (fecha_final IS NULL OR fecha_final >= fecha_inicial),
  CONSTRAINT fk_proyecto_docente FOREIGN KEY (docente_id_jefe) REFERENCES docente(docente_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Auditoría
CREATE TABLE copia_actualizados_docente (
  auditoria_id       INT AUTO_INCREMENT PRIMARY KEY,
  docente_id         INT NOT NULL,
  numero_documento   VARCHAR(20)  NOT NULL,
  nombres            VARCHAR(120) NOT NULL,
  titulo             VARCHAR(120),
  anios_experiencia  INT          NOT NULL,
  direccion          VARCHAR(180),
  tipo_docente       VARCHAR(40),
  accion_fecha       DATETIME     NOT NULL DEFAULT (UTC_TIMESTAMP()),
  usuario_sql        VARCHAR(128) NOT NULL DEFAULT (CURRENT_USER())
) ENGINE=InnoDB;

CREATE TABLE copia_eliminados_docente (
  auditoria_id       INT AUTO_INCREMENT PRIMARY KEY,
  docente_id         INT NOT NULL,
  numero_documento   VARCHAR(20)  NOT NULL,
  nombres            VARCHAR(120) NOT NULL,
  titulo             VARCHAR(120),
  anios_experiencia  INT          NOT NULL,
  direccion          VARCHAR(180),
  tipo_docente       VARCHAR(40),
  accion_fecha       DATETIME     NOT NULL DEFAULT (UTC_TIMESTAMP()),
  usuario_sql        VARCHAR(128) NOT NULL DEFAULT (CURRENT_USER())
) ENGINE=InnoDB;

-- Procedimientos DOCENTE
DROP PROCEDURE IF EXISTS sp_docente_crear;
DROP PROCEDURE IF EXISTS sp_docente_leer;
DROP PROCEDURE IF EXISTS sp_docente_actualizar;
DROP PROCEDURE IF EXISTS sp_docente_eliminar;

DELIMITER $$
--Procedimiento: sp_docente_crear
--Descripción: Inserta un nuevo docente en la tabla docente
--Parametros de entrada: p_numero_documento,  p_nombres, p_titulo, p_anios_experiencia, p_direccion, p_tipo_docente)
-- Retorna: El id del docente creado (docente_id_creado)
CREATE PROCEDURE sp_docente_crear(
  IN p_numero_documento VARCHAR(20),-- número de documento del docente
  IN p_nombres          VARCHAR(120),-- nombres completos del docente
  IN p_titulo           VARCHAR(120),-- titulo academico del docente
  IN p_anios_experiencia INT,-- años de experiencia del docente
  IN p_direccion        VARCHAR(180),-- dirección de residencia
  IN p_tipo_docente     VARCHAR(40)-- tipo docente ej tiempo completo, catedra...
)
BEGIN
  INSERT INTO docente (numero_documento, nombres, titulo, anios_experiencia, direccion, tipo_docente)
  VALUES (p_numero_documento, p_nombres, p_titulo, IFNULL(p_anios_experiencia,0), p_direccion, p_tipo_docente);
  SELECT LAST_INSERT_ID() AS docente_id_creado;
END$$

--Procedimiento: sp_docente_leer
--Descripción: consulta todos los datos de un docente especifico , a partir de un identificador, en este caso p_docente_id 
--Parametros de entrada: p_docente_id
--Retorna: fila con toda la info del docente
CREATE PROCEDURE sp_docente_leer(IN p_docente_id INT)
BEGIN
  SELECT * FROM docente WHERE docente_id = p_docente_id;
END$$

--Procedimiento: sp_docente_actualizar
--Descripcion: Actualiza los datos de un docente existente
--Parametros de entrada: p_docente_id, p_numero_documento, p_nombres, p_titulo, p_anios_experiencia, p_direccion, p_tipo_docente
--Retorna: Todos los datos del docente luego de actualizar
CREATE PROCEDURE sp_docente_actualizar(
  IN p_docente_id       INT,
  IN p_numero_documento VARCHAR(20),
  IN p_nombres          VARCHAR(120),
  IN p_titulo           VARCHAR(120),
  IN p_anios_experiencia INT,
  IN p_direccion        VARCHAR(180),
  IN p_tipo_docente     VARCHAR(40)
)
BEGIN
  UPDATE docente
     SET numero_documento = p_numero_documento,
         nombres = p_nombres,
         titulo = p_titulo,
         anios_experiencia = IFNULL(p_anios_experiencia,0),
         direccion = p_direccion,
         tipo_docente = p_tipo_docente
   WHERE docente_id = p_docente_id;
  SELECT * FROM docente WHERE docente_id = p_docente_id;
END$$
--Procedimiento: sp_docente_eliminar
--Descripcion: Elimina un docente de la base de datos a partir del id que recibe p_docente_id
-- parametro de entrada: p_docente_id
-- retorna: no retorna nada, el docente es eliminado
CREATE PROCEDURE sp_docente_eliminar(IN p_docente_id INT)
BEGIN
  DELETE FROM docente WHERE docente_id = p_docente_id;
END$$

-- Procedimientos PROYECTO
DROP PROCEDURE IF EXISTS sp_proyecto_crear;
DROP PROCEDURE IF EXISTS sp_proyecto_leer;
DROP PROCEDURE IF EXISTS sp_proyecto_actualizar;
DROP PROCEDURE IF EXISTS sp_proyecto_eliminar;

CREATE PROCEDURE sp_proyecto_crear(
  IN p_nombre           VARCHAR(120),
  IN p_descripcion      VARCHAR(400),
  IN p_fecha_inicial    DATE,
  IN p_fecha_final      DATE,
  IN p_presupuesto      DECIMAL(12,2),
  IN p_horas            INT,
  IN p_docente_id_jefe  INT
)
BEGIN
  INSERT INTO proyecto (nombre, descripcion, fecha_inicial, fecha_final, presupuesto, horas, docente_id_jefe)
  VALUES (p_nombre, p_descripcion, p_fecha_inicial, p_fecha_final, IFNULL(p_presupuesto,0), IFNULL(p_horas,0), p_docente_id_jefe);
  SELECT LAST_INSERT_ID() AS proyecto_id_creado;
END$$

CREATE PROCEDURE sp_proyecto_leer(IN p_proyecto_id INT)
BEGIN
  SELECT p.*, d.nombres AS nombre_docente_jefe
  FROM proyecto p
  JOIN docente d ON d.docente_id = p.docente_id_jefe
  WHERE p.proyecto_id = p_proyecto_id;
END$$

CREATE PROCEDURE sp_proyecto_actualizar(
  IN p_proyecto_id      INT,
  IN p_nombre           VARCHAR(120),
  IN p_descripcion      VARCHAR(400),
  IN p_fecha_inicial    DATE,
  IN p_fecha_final      DATE,
  IN p_presupuesto      DECIMAL(12,2),
  IN p_horas            INT,
  IN p_docente_id_jefe  INT
)
BEGIN
  UPDATE proyecto
     SET nombre = p_nombre,
         descripcion = p_descripcion,
         fecha_inicial = p_fecha_inicial,
         fecha_final = p_fecha_final,
         presupuesto = IFNULL(p_presupuesto,0),
         horas = IFNULL(p_horas,0),
         docente_id_jefe = p_docente_id_jefe
   WHERE proyecto_id = p_proyecto_id;
  CALL sp_proyecto_leer(p_proyecto_id);
END$$

CREATE PROCEDURE sp_proyecto_eliminar(IN p_proyecto_id INT)
BEGIN
  DELETE FROM proyecto WHERE proyecto_id = p_proyecto_id;
END$$

-- UDF
DROP FUNCTION IF EXISTS fn_promedio_presupuesto_por_docente;
CREATE FUNCTION fn_promedio_presupuesto_por_docente(p_docente_id INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
  DECLARE v_prom DECIMAL(12,2);
  SELECT IFNULL(AVG(presupuesto),0) INTO v_prom
  FROM proyecto
  WHERE docente_id_jefe = p_docente_id;
  RETURN IFNULL(v_prom,0);
END$$

-- Triggers
CREATE TRIGGER tr_docente_after_update
AFTER UPDATE ON docente
FOR EACH ROW
BEGIN
  INSERT INTO copia_actualizados_docente
    (docente_id, numero_documento, nombres, titulo, anios_experiencia, direccion, tipo_docente)
  VALUES
    (NEW.docente_id, NEW.numero_documento, NEW.nombres, NEW.titulo, NEW.anios_experiencia, NEW.direccion, NEW.tipo_docente);
END$$

CREATE TRIGGER tr_docente_after_delete
AFTER DELETE ON docente
FOR EACH ROW
BEGIN
  INSERT INTO copia_eliminados_docente
    (docente_id, numero_documento, nombres, titulo, anios_experiencia, direccion, tipo_docente)
  VALUES
    (OLD.docente_id, OLD.numero_documento, OLD.nombres, OLD.titulo, OLD.anios_experiencia, OLD.direccion, OLD.tipo_docente);
END$$

DELIMITER ;

-- Índices
CREATE INDEX ix_proyecto_docente ON proyecto(docente_id_jefe);
CREATE INDEX ix_docente_documento ON docente(numero_documento);
