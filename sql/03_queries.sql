-- queries.sql (MySQL 8.0+)
-- Este archivo contiene consultas de validación y ejemplos
-- que permiten comprobar el correcto funcionamiento de la base de datos, sus procedimientos, funciones y triggers.

-- Q0: Crear y usar la base de datos
CREATE DATABASE IF NOT EXISTS proyectos_informaticos;
USE proyectos_informaticos;

-- Q1: Proyectos y su docente jefe
-- Consulta de control que muestra cada proyecto registrado junto con el nombre
-- del docente que actúa como jefe del proyecto.

SELECT p.proyecto_id, p.nombre AS proyecto, d.nombres AS docente_jefe
FROM proyecto p
JOIN docente d ON d.docente_id = p.docente_id_jefe;

-- Q2: Promedio de presupuesto por docente (UDF)
-- Utiliza la función definida por el usuario (fn_promedio_presupuesto_por_docente)
-- para calcular cuánto presupuesto promedio maneja cada docente en sus proyectos.
SELECT d.docente_id, d.nombres,
       fn_promedio_presupuesto_por_docente(d.docente_id) AS promedio_presupuesto
FROM docente d;

-- Q3: Verificar trigger UPDATE (auditoría)
-- Lista los últimos registros en la tabla de auditoría de actualizaciones de docentes.
-- Permite comprobar que el trigger "tr_docente_after_update" se dispara al hacer cambios
-- y que se está almacenando el histórico de modificaciones.
SELECT * FROM copia_actualizados_docente
ORDER BY auditoria_id DESC
LIMIT 10;

-- Q4: Verificar trigger DELETE (auditoría)
-- Lista los últimos registros en la tabla de auditoría de eliminaciones de docentes.
-- Permite comprobar que el trigger "tr_docente_after_delete" se ejecuta correctamente
-- al eliminar docentes y que se conserva la información eliminada como respaldo.
SELECT * FROM copia_eliminados_docente
ORDER BY auditoria_id DESC
LIMIT 10;

-- Q5: Validar CHECKs
-- Muestra los proyectos que cumplen con las restricciones de integridad definidas:
-- fecha_final mayor o igual a fecha_inicial, presupuesto no negativo, horas no negativas.
SELECT proyecto_id, nombre, fecha_inicial, fecha_final, presupuesto, horas
FROM proyecto
WHERE (fecha_final IS NULL OR fecha_final >= fecha_inicial)
  AND presupuesto >= 0
  AND horas >= 0;

-- Q6: Docentes con sus proyectos
-- Lista todos los docentes junto con los proyectos que lideran.
-- Se usa LEFT JOIN para incluir también a los docentes sin proyectos, con el fin de obtener una visión global de asignaciones.
SELECT d.docente_id, d.nombres, p.proyecto_id, p.nombre
FROM docente d
LEFT JOIN proyecto p ON d.docente_id = p.docente_id_jefe
ORDER BY d.docente_id;

-- Q7: Total de horas por docente
-- Muestra la suma de horas de trabajo asociadas a los proyectos de cada docente.
SELECT d.docente_id, d.nombres, SUM(p.horas) AS total_horas
FROM docente d
LEFT JOIN proyecto p ON d.docente_id = p.docente_id_jefe
GROUP BY d.docente_id, d.nombres;

-- Q8: Inserciones vía procedimientos
-- Inserta datos de ejemplo (docentes y proyectos) usando los procedimientos almacenados.
-- Esto permite validar que los SP "sp_docente_crear" y "sp_proyecto_crear"
-- funcionan correctamente y respetan las reglas del modelo.
-- Nota: se comentaron los siguientes llamados a creacion de docentes ya que se habian creado anteriormente
-- en el archivo seed.sql.
-- CALL sp_docente_crear('CC1001', 'Ana Gómez', 'MSc. Ing. Sistemas', 6, 'Cra 10 # 5-55', 'Tiempo completo');
-- CALL sp_docente_crear('CC1002', 'Carlos Ruiz', 'Ing. Informático', 3, 'Cll 20 # 4-10', 'Cátedra');
SET @id_ana    := (SELECT docente_id FROM docente WHERE numero_documento='CC1001');
SET @id_carlos := (SELECT docente_id FROM docente WHERE numero_documento='CC1002');
CALL sp_proyecto_crear('Plataforma Académica', 'Módulos de matrícula', '2025-01-01', NULL, 25000000, 800, @id_ana);
CALL sp_proyecto_crear('Chat Soporte TI', 'Chat universitario', '2025-02-01', '2025-06-30', 12000000, 450, @id_carlos);

-- Q9: Inserciones directas (opcional)
-- Inserta registros de ejemplo directamente en las tablas (sin procedimientos).
-- Sirve para verificar que los constraints y FKs funcionan también en inserciones manuales y no solo a través de los SP.
INSERT INTO docente (numero_documento, nombres, titulo, anios_experiencia, direccion, tipo_docente)
VALUES ('CC2001','María López','Esp. Gestión de Proyectos',7,'Av. Siempre Viva 742','Cátedra');
INSERT INTO proyecto (nombre, descripcion, fecha_inicial, fecha_final, presupuesto, horas, docente_id_jefe)
VALUES ('App Biblioteca','App móvil de préstamos','2025-03-01',NULL, 9000000, 320,
        (SELECT docente_id FROM docente WHERE numero_documento='CC2001'));
