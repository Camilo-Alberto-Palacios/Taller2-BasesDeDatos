--==============================================================================
--                      Archivo: 00_create_database.sql
--                  Descripcion: crea la base de datos proyectos_informaticos, 
--                               si existe omite y toma por defecto la tabla
--============================================================================== 
CREATE DATABASE IF NOT EXISTS proyectos_informaticos;  -- se crea la base de datos proyecto informaticos, si ya esta creada lo omite
USE proyectos_informaticos;                            -- le inidica al editor que use esta base de datos
