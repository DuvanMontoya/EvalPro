-- EvalPro
-- Migracion: dominio-canonico
-- Objetivo: alinear estados, modos y eventos del dominio anterior con el canon de AGENTS.md

-- CreateEnum
CREATE TYPE "TipoEventoIntento" AS ENUM (
  'EVALUACION_ABIERTA',
  'INTENTO_INICIADO',
  'RESPUESTA_SELECCIONADA',
  'RESPUESTA_CAMBIADA',
  'RESPUESTA_LIMPIADA',
  'APP_EN_BACKGROUND',
  'APP_EN_FOREGROUND',
  'INCIDENTE_REGISTRADO',
  'REINGRESO_AUTORIZADO',
  'TOKEN_REINGRESO_CONSUMIDO',
  'ENVIO_SOLICITADO',
  'FINALIZACION_PROVISIONAL',
  'RECONCILIACION_EXITOSA',
  'RECONCILIACION_FALLIDA',
  'RESULTADO_PUBLICADO',
  'ANULACION'
);

-- CreateEnum
CREATE TYPE "TipoIncidente" AS ENUM (
  'APP_EN_BACKGROUND',
  'PERDIDA_DE_FOCO',
  'NAVEGACION_NO_AUTORIZADA',
  'OVERLAY_DETECTADO',
  'VERIFICACION_INTEGRIDAD_FALLIDA',
  'INCONSISTENCIA_SINCRONIZACION',
  'COMPORTAMIENTO_DUPLICADO_SOSPECHOSO',
  'TOKEN_REINGRESO_INVALIDO',
  'TIEMPO_EXCEDIDO',
  'RECONCILIACION_INCONSISTENTE'
);

-- CreateEnum
CREATE TYPE "MetodoReingreso" AS ENUM ('QR', 'PIN');

-- AlterTable
ALTER TABLE "examenes"
ADD COLUMN "permitirCambioRespuesta" BOOLEAN NOT NULL DEFAULT true;

-- AlterTable
ALTER TABLE "intentos_examen"
ADD COLUMN "altoRiesgo" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN "fechaBloqueo" TIMESTAMP(3),
ADD COLUMN "fechaFinalizacionProv" TIMESTAMP(3),
ADD COLUMN "fechaReanudacion" TIMESTAMP(3),
ADD COLUMN "incidentesAcumulados" INTEGER NOT NULL DEFAULT 0;

UPDATE "intentos_examen"
SET "fechaFinalizacionProv" = COALESCE("ultimaSincronizacion", "fechaEnvio")
WHERE "estado" = 'SINCRONIZACION_PENDIENTE';

-- AlterEnum
BEGIN;
CREATE TYPE "ModalidadExamen_new" AS ENUM ('CONTENIDO_COMPLETO', 'SOLO_RESPUESTAS');
ALTER TABLE "examenes"
ALTER COLUMN "modalidad" TYPE "ModalidadExamen_new"
USING (
  CASE "modalidad"::text
    WHEN 'DIGITAL_COMPLETO' THEN 'CONTENIDO_COMPLETO'
    WHEN 'HOJA_RESPUESTAS' THEN 'SOLO_RESPUESTAS'
    ELSE 'CONTENIDO_COMPLETO'
  END
)::"ModalidadExamen_new";
ALTER TYPE "ModalidadExamen" RENAME TO "ModalidadExamen_old";
ALTER TYPE "ModalidadExamen_new" RENAME TO "ModalidadExamen";
DROP TYPE "ModalidadExamen_old";
COMMIT;

-- AlterEnum
BEGIN;
CREATE TYPE "EstadoIntento_new" AS ENUM (
  'INICIADO',
  'BLOQUEADO',
  'REANUDADO',
  'SUSPENDIDO',
  'FINALIZADO_PROVISIONAL',
  'ENVIADO',
  'ANULADO'
);
ALTER TABLE "intentos_examen" ALTER COLUMN "estado" DROP DEFAULT;
ALTER TABLE "intentos_examen"
ALTER COLUMN "estado" TYPE "EstadoIntento_new"
USING (
  CASE "estado"::text
    WHEN 'EN_PROGRESO' THEN 'INICIADO'
    WHEN 'SINCRONIZACION_PENDIENTE' THEN 'FINALIZADO_PROVISIONAL'
    WHEN 'ENVIADO' THEN 'ENVIADO'
    WHEN 'ANULADO' THEN 'ANULADO'
    ELSE 'INICIADO'
  END
)::"EstadoIntento_new";
ALTER TYPE "EstadoIntento" RENAME TO "EstadoIntento_old";
ALTER TYPE "EstadoIntento_new" RENAME TO "EstadoIntento";
DROP TYPE "EstadoIntento_old";
ALTER TABLE "intentos_examen" ALTER COLUMN "estado" SET DEFAULT 'INICIADO';
COMMIT;

-- Consolidacion EventoTelemetria -> EventoIntento
ALTER TABLE "eventos_telemetria"
ADD COLUMN "tipoNuevo" "TipoEventoIntento",
ADD COLUMN "numeroSecuencia" INTEGER,
ADD COLUMN "revisado" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN "ignorado" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN "motivoRevision" VARCHAR(500);

UPDATE "eventos_telemetria"
SET
  "metadatos" = COALESCE("metadatos", '{}'::jsonb) || jsonb_build_object(
    'tipoLegacy', "tipo"::text,
    'modeloOrigen', 'EventoTelemetria'
  ),
  "tipoNuevo" = (
    CASE "tipo"::text
      WHEN 'INICIO_EXAMEN' THEN 'INTENTO_INICIADO'
      WHEN 'CAMBIO_PREGUNTA' THEN 'EVALUACION_ABIERTA'
      WHEN 'RESPUESTA_GUARDADA' THEN 'RESPUESTA_SELECCIONADA'
      WHEN 'APLICACION_EN_SEGUNDO_PLANO' THEN 'APP_EN_BACKGROUND'
      WHEN 'PANTALLA_ABANDONADA' THEN 'INCIDENTE_REGISTRADO'
      WHEN 'CAPTURA_BLOQUEADA' THEN 'INCIDENTE_REGISTRADO'
      WHEN 'FORZAR_CIERRE' THEN 'INCIDENTE_REGISTRADO'
      WHEN 'SESION_INVALIDA' THEN 'RECONCILIACION_FALLIDA'
      WHEN 'EXAMEN_ENVIADO' THEN 'ENVIO_SOLICITADO'
      WHEN 'SINCRONIZACION_COMPLETADA' THEN 'RECONCILIACION_EXITOSA'
      WHEN 'SEGUNDO_PLANO' THEN 'APP_EN_BACKGROUND'
      WHEN 'FOCO_RECUPERADO' THEN 'APP_EN_FOREGROUND'
      WHEN 'ABANDONO_PANTALLA' THEN 'INCIDENTE_REGISTRADO'
      WHEN 'CIERRE_FORZADO' THEN 'INCIDENTE_REGISTRADO'
      WHEN 'TIEMPO_ANOMALO' THEN 'INCIDENTE_REGISTRADO'
      WHEN 'SYNC_ANOMALA' THEN 'RECONCILIACION_FALLIDA'
      WHEN 'CAMBIO_RED' THEN 'INCIDENTE_REGISTRADO'
      WHEN 'CAPTURA_PANTALLA_DETECTADA' THEN 'INCIDENTE_REGISTRADO'
      WHEN 'MULTIPLES_DISPOSITIVOS' THEN 'INCIDENTE_REGISTRADO'
      ELSE 'INCIDENTE_REGISTRADO'
    END
  )::"TipoEventoIntento";

ALTER TABLE "eventos_telemetria" DROP COLUMN "tipo";
ALTER TABLE "eventos_telemetria" RENAME COLUMN "tipoNuevo" TO "tipo";

WITH "eventosOrdenados" AS (
  SELECT
    "id",
    ROW_NUMBER() OVER (PARTITION BY "intentoId" ORDER BY "fechaEvento", "id") AS "numero"
  FROM "eventos_telemetria"
)
UPDATE "eventos_telemetria" AS "evento"
SET "numeroSecuencia" = "eventosOrdenados"."numero"
FROM "eventosOrdenados"
WHERE "evento"."id" = "eventosOrdenados"."id";

ALTER TABLE "eventos_telemetria" ALTER COLUMN "numeroSecuencia" SET NOT NULL;
ALTER TABLE "eventos_telemetria" RENAME TO "eventos_intento";
DROP TYPE "TipoEventoTelemetria";

-- CreateTable
CREATE TABLE "incidentes" (
  "id" TEXT NOT NULL,
  "tipo" "TipoIncidente" NOT NULL,
  "severidad" "SeveridadEvento" NOT NULL DEFAULT 'ADVERTENCIA',
  "descripcion" VARCHAR(500),
  "contexto" JSONB,
  "contadorAcumulado" INTEGER NOT NULL,
  "altoRiesgo" BOOLEAN NOT NULL DEFAULT false,
  "fechaRegistro" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "intentoId" TEXT NOT NULL,
  "eventoId" TEXT,

  CONSTRAINT "incidentes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tokens_reingreso" (
  "id" TEXT NOT NULL,
  "intentoId" TEXT NOT NULL,
  "estudianteId" TEXT NOT NULL,
  "autorizadoPorId" TEXT NOT NULL,
  "metodo" "MetodoReingreso" NOT NULL DEFAULT 'PIN',
  "codigoHash" VARCHAR(255) NOT NULL,
  "codigoVisible" VARCHAR(12) NOT NULL,
  "expiraEn" TIMESTAMP(3) NOT NULL,
  "usado" BOOLEAN NOT NULL DEFAULT false,
  "usadoEn" TIMESTAMP(3),
  "dispositivoAutoriza" VARCHAR(120),
  "fechaCreacion" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "tokens_reingreso_pkey" PRIMARY KEY ("id")
);

WITH "eventosIncidente" AS (
  SELECT
    "id",
    "intentoId",
    "fechaEvento",
    "descripcion",
    "severidad",
    "metadatos",
    ROW_NUMBER() OVER (PARTITION BY "intentoId" ORDER BY "fechaEvento", "id") AS "contador"
  FROM "eventos_intento"
  WHERE COALESCE("metadatos"->>'tipoLegacy', '') IN (
    'APLICACION_EN_SEGUNDO_PLANO',
    'PANTALLA_ABANDONADA',
    'CAPTURA_BLOQUEADA',
    'FORZAR_CIERRE',
    'SESION_INVALIDA',
    'SEGUNDO_PLANO',
    'ABANDONO_PANTALLA',
    'CIERRE_FORZADO',
    'TIEMPO_ANOMALO',
    'SYNC_ANOMALA',
    'CAMBIO_RED',
    'CAPTURA_PANTALLA_DETECTADA',
    'MULTIPLES_DISPOSITIVOS'
  )
)
INSERT INTO "incidentes" (
  "id",
  "tipo",
  "severidad",
  "descripcion",
  "contexto",
  "contadorAcumulado",
  "altoRiesgo",
  "fechaRegistro",
  "intentoId",
  "eventoId"
)
SELECT
  'inc_' || md5("id"),
  (
    CASE COALESCE("metadatos"->>'tipoLegacy', '')
      WHEN 'APLICACION_EN_SEGUNDO_PLANO' THEN 'APP_EN_BACKGROUND'
      WHEN 'SEGUNDO_PLANO' THEN 'APP_EN_BACKGROUND'
      WHEN 'PANTALLA_ABANDONADA' THEN 'PERDIDA_DE_FOCO'
      WHEN 'ABANDONO_PANTALLA' THEN 'PERDIDA_DE_FOCO'
      WHEN 'CAPTURA_BLOQUEADA' THEN 'OVERLAY_DETECTADO'
      WHEN 'FORZAR_CIERRE' THEN 'NAVEGACION_NO_AUTORIZADA'
      WHEN 'CIERRE_FORZADO' THEN 'NAVEGACION_NO_AUTORIZADA'
      WHEN 'SESION_INVALIDA' THEN 'RECONCILIACION_INCONSISTENTE'
      WHEN 'TIEMPO_ANOMALO' THEN 'TIEMPO_EXCEDIDO'
      WHEN 'SYNC_ANOMALA' THEN 'INCONSISTENCIA_SINCRONIZACION'
      WHEN 'CAMBIO_RED' THEN 'INCONSISTENCIA_SINCRONIZACION'
      WHEN 'CAPTURA_PANTALLA_DETECTADA' THEN 'OVERLAY_DETECTADO'
      WHEN 'MULTIPLES_DISPOSITIVOS' THEN 'COMPORTAMIENTO_DUPLICADO_SOSPECHOSO'
      ELSE 'INCONSISTENCIA_SINCRONIZACION'
    END
  )::"TipoIncidente",
  COALESCE("severidad", 'ADVERTENCIA'::"SeveridadEvento"),
  COALESCE("descripcion", 'INCIDENTE_MIGRADO_DESDE_EVENTO_TELEMETRIA'),
  "metadatos",
  "contador",
  ("contador" >= 2),
  "fechaEvento",
  "intentoId",
  "id"
FROM "eventosIncidente";

UPDATE "intentos_examen" AS "intento"
SET
  "incidentesAcumulados" = "conteo"."cantidad",
  "altoRiesgo" = ("conteo"."cantidad" >= 2),
  "requiereRevision" = ("conteo"."cantidad" > 0) OR "intento"."requiereRevision",
  "esSospechoso" = ("conteo"."cantidad" > 0) OR "intento"."esSospechoso",
  "indiceRiesgoFraude" = GREATEST(COALESCE("intento"."indiceRiesgoFraude", 0), LEAST("conteo"."cantidad" * 15, 100)),
  "estado" = CASE
    WHEN "intento"."estado" IN ('ENVIADO', 'ANULADO', 'FINALIZADO_PROVISIONAL', 'SUSPENDIDO') THEN "intento"."estado"
    WHEN "conteo"."cantidad" >= 3 THEN 'SUSPENDIDO'::"EstadoIntento"
    WHEN "conteo"."cantidad" >= 1 THEN 'BLOQUEADO'::"EstadoIntento"
    ELSE "intento"."estado"
  END,
  "fechaBloqueo" = CASE
    WHEN "conteo"."cantidad" >= 1 THEN COALESCE("intento"."fechaBloqueo", "conteo"."ultimaFecha")
    ELSE "intento"."fechaBloqueo"
  END
FROM (
  SELECT
    "intentoId",
    COUNT(*)::INTEGER AS "cantidad",
    MAX("fechaRegistro") AS "ultimaFecha"
  FROM "incidentes"
  GROUP BY "intentoId"
) AS "conteo"
WHERE "intento"."id" = "conteo"."intentoId";

-- CreateIndex
CREATE UNIQUE INDEX "eventos_intento_intentoId_numeroSecuencia_key"
ON "eventos_intento"("intentoId", "numeroSecuencia");

-- CreateIndex
CREATE UNIQUE INDEX "incidentes_eventoId_key"
ON "incidentes"("eventoId");

-- CreateIndex
CREATE INDEX "incidentes_intentoId_fechaRegistro_idx"
ON "incidentes"("intentoId", "fechaRegistro");

-- CreateIndex
CREATE INDEX "tokens_reingreso_intentoId_estudianteId_expiraEn_idx"
ON "tokens_reingreso"("intentoId", "estudianteId", "expiraEn");

-- AddForeignKey
ALTER TABLE "incidentes"
ADD CONSTRAINT "incidentes_intentoId_fkey"
FOREIGN KEY ("intentoId") REFERENCES "intentos_examen"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "incidentes"
ADD CONSTRAINT "incidentes_eventoId_fkey"
FOREIGN KEY ("eventoId") REFERENCES "eventos_intento"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tokens_reingreso"
ADD CONSTRAINT "tokens_reingreso_intentoId_fkey"
FOREIGN KEY ("intentoId") REFERENCES "intentos_examen"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tokens_reingreso"
ADD CONSTRAINT "tokens_reingreso_estudianteId_fkey"
FOREIGN KEY ("estudianteId") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tokens_reingreso"
ADD CONSTRAINT "tokens_reingreso_autorizadoPorId_fkey"
FOREIGN KEY ("autorizadoPorId") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
