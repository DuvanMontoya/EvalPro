-- EvalPro - Reparacion de acceso y permisos PostgreSQL para Prisma/seed.
-- Ejecutar con superusuario postgres:
-- psql -h localhost -p 5432 -U postgres -f Backend/prisma/sql/RepararAccesoEvalPro.sql

DO
$$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'evalpro_usuario') THEN
    CREATE ROLE evalpro_usuario LOGIN PASSWORD 'evalpro_contrasena_segura';
  END IF;
END
$$;

ALTER ROLE evalpro_usuario WITH LOGIN PASSWORD 'evalpro_contrasena_segura';

SELECT
  'CREATE DATABASE "evalPro_db" OWNER evalpro_usuario'
WHERE
  NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = 'evalPro_db')
\gexec

\connect evalPro_db

ALTER DATABASE "evalPro_db" OWNER TO evalpro_usuario;
GRANT ALL PRIVILEGES ON DATABASE "evalPro_db" TO evalpro_usuario;

ALTER SCHEMA public OWNER TO evalpro_usuario;
GRANT USAGE, CREATE ON SCHEMA public TO evalpro_usuario;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO evalpro_usuario;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO evalpro_usuario;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO evalpro_usuario;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL PRIVILEGES ON TABLES TO evalpro_usuario;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL PRIVILEGES ON SEQUENCES TO evalpro_usuario;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL PRIVILEGES ON FUNCTIONS TO evalpro_usuario;
