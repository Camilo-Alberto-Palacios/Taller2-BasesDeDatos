-- seed.sql (MySQL 8.0+)
--================================================================================================================
--                               Archivo: 02_seed.sql
--                               Descripcion: se agregan los primeros datos a las tablas
--================================================================================================================
-- Docentes (CREATE)
CALL sp_docente_crear('CC1001', 'Ana Gómez', 'MSc. Ing. Sistemas', 6, 'Cra 10 # 5-55', 'Tiempo completo');
-- se llama al procedmiento almacenado "sp_docente_crear" y se insertan los valores del parentesis en orden
CALL sp_docente_crear('CC1002', 'Carlos Ruiz', 'Ing. Informático', 3, 'Cll 20 # 4-10', 'Cátedra');
-- se llama al procedmiento almacenado "sp_docente_crear" y se insertan los valores del parentesis en orden en la siguiente fila


-- Obtener IDs
SET @id_ana    := (SELECT docente_id FROM docente WHERE numero_documento='CC1001');
-- asigna la variable "id_ana" busca en la tabla docente "docente_id" y guarda el valor en la variable 
SET @id_carlos := (SELECT docente_id FROM docente WHERE numero_documento='CC1002');
-- asigna la variable "id_carlos" busca en la tabla docente "docente_id" y guarda el valor en la variable 

-- Proyectos (CREATE)
CALL sp_proyecto_crear('Plataforma Académica', 'Módulos de matrícula', '2025-01-01', NULL, 25000000, 800, @id_ana);
-- se llama al procedmiento almacenado "sp_proyecto_crear" y se insertan los valores del parentesis en orden
CALL sp_proyecto_crear('Chat Soporte TI', 'Chat universitario', '2025-02-01', '2025-06-30', 12000000, 450, @id_carlos);
-- se llama al procedmiento almacenado "sp_proyecto_crear" y se insertan los valores del parentesis en orden en la siguiente fila


-- UPDATE para disparar trigger de ACTUALIZADOS
CALL sp_docente_actualizar(@id_carlos, 'CC1002', 'Carlos A. Ruiz', 'Esp. Base de Datos', 4, 'Cll 20 # 4-10', 'Cátedra');
-- llama al proceso almacenado "sp_docente_actualizar" utilizando como identificador "@id_carlos"

-- Eliminar la docente Ana: primero sus proyectos (por FK), luego docente (dispara DELETE)
DELETE FROM proyecto WHERE docente_id_jefe = @id_ana;
-- elimina todas las filas donde el identificador sea "id_ana" en proyecto
CALL sp_docente_eliminar(@id_ana);
-- llama al proceso almacenado "sp_docente_eliminar" utilizando como identificador "@id_ana"
