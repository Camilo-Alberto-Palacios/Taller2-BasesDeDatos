-- seed.sql (MySQL 8.0+)

-- Docentes (CREATE)
CALL sp_docente_crear('CC1001', 'Ana Gómez', 'MSc. Ing. Sistemas', 6, 'Cra 10 # 5-55', 'Tiempo completo');
CALL sp_docente_crear('CC1002', 'Carlos Ruiz', 'Ing. Informático', 3, 'Cll 20 # 4-10', 'Cátedra');

-- Obtener IDs
SET @id_ana    := (SELECT docente_id FROM docente WHERE numero_documento='CC1001');
SET @id_carlos := (SELECT docente_id FROM docente WHERE numero_documento='CC1002');

-- Proyectos (CREATE)
CALL sp_proyecto_crear('Plataforma Académica', 'Módulos de matrícula', '2025-01-01', NULL, 25000000, 800, @id_ana);
CALL sp_proyecto_crear('Chat Soporte TI', 'Chat universitario', '2025-02-01', '2025-06-30', 12000000, 450, @id_carlos);

-- UPDATE para disparar trigger de ACTUALIZADOS
CALL sp_docente_actualizar(@id_carlos, 'CC1002', 'Carlos A. Ruiz', 'Esp. Base de Datos', 4, 'Cll 20 # 4-10', 'Cátedra');

-- Eliminar la docente Ana: primero sus proyectos (por FK), luego docente (dispara DELETE)
DELETE FROM proyecto WHERE docente_id_jefe = @id_ana;
CALL sp_docente_eliminar(@id_ana);
