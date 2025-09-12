-- Inserciones directas opcionales (sin SP)

INSERT INTO docente (numero_documento, nombres, titulo, anios_experiencia, direccion, tipo_docente)
VALUES ('CC3001','Jorge Torres','MSc. Ing. Software',8,'Cra 45 # 12-34','Tiempo completo');

INSERT INTO proyecto (nombre, descripcion, fecha_inicial, fecha_final, presupuesto, horas, docente_id_jefe)
VALUES ('Sistema Nómina','Módulo RRHH','2025-04-01',NULL, 15000000, 500,
        (SELECT docente_id FROM docente WHERE numero_documento='CC3001'));
