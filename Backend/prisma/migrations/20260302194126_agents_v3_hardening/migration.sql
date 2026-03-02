-- CreateEnum
CREATE TYPE "EstadoCuenta" AS ENUM ('PENDIENTE_ACTIVACION', 'ACTIVO', 'BLOQUEADO', 'SUSPENDIDO');

-- CreateEnum
CREATE TYPE "EstadoInstitucion" AS ENUM ('ACTIVA', 'SUSPENDIDA', 'ARCHIVADA');

-- CreateEnum
CREATE TYPE "EstadoGrupo" AS ENUM ('BORRADOR', 'ACTIVO', 'CERRADO', 'ARCHIVADO');

-- CreateEnum
CREATE TYPE "EstadoResultado" AS ENUM ('PRELIMINAR', 'OFICIAL', 'EN_RECLAMO', 'RECTIFICADO');

-- CreateEnum
CREATE TYPE "EstadoReclamo" AS ENUM ('PRESENTADO', 'EN_REVISION', 'RESUELTO', 'RECHAZADO');

-- CreateEnum
CREATE TYPE "SeveridadEvento" AS ENUM ('INFO', 'ADVERTENCIA', 'SOSPECHOSO', 'CRITICO');

-- AlterEnum
ALTER TYPE "RolUsuario" ADD VALUE 'SUPERADMINISTRADOR';

-- AlterEnum
-- This migration adds more than one value to an enum.
-- With PostgreSQL versions 11 and earlier, this is not possible
-- in a single migration. This can be worked around by creating
-- multiple migrations, each migration adding only one value to
-- the enum.


ALTER TYPE "TipoEventoTelemetria" ADD VALUE 'SEGUNDO_PLANO';
ALTER TYPE "TipoEventoTelemetria" ADD VALUE 'FOCO_RECUPERADO';
ALTER TYPE "TipoEventoTelemetria" ADD VALUE 'ABANDONO_PANTALLA';
ALTER TYPE "TipoEventoTelemetria" ADD VALUE 'CIERRE_FORZADO';
ALTER TYPE "TipoEventoTelemetria" ADD VALUE 'TIEMPO_ANOMALO';
ALTER TYPE "TipoEventoTelemetria" ADD VALUE 'SYNC_ANOMALA';
ALTER TYPE "TipoEventoTelemetria" ADD VALUE 'CAMBIO_RED';
ALTER TYPE "TipoEventoTelemetria" ADD VALUE 'CAPTURA_PANTALLA_DETECTADA';
ALTER TYPE "TipoEventoTelemetria" ADD VALUE 'MULTIPLES_DISPOSITIVOS';

-- AlterEnum
-- This migration adds more than one value to an enum.
-- With PostgreSQL versions 11 and earlier, this is not possible
-- in a single migration. This can be worked around by creating
-- multiple migrations, each migration adding only one value to
-- the enum.


ALTER TYPE "TipoPregunta" ADD VALUE 'ABIERTA';
ALTER TYPE "TipoPregunta" ADD VALUE 'EMPAREJAMIENTO';

-- DropIndex
DROP INDEX "intentos_examen_estudianteId_sesionId_key";

-- AlterTable
ALTER TABLE "eventos_telemetria" ADD COLUMN     "duracionMs" INTEGER,
ADD COLUMN     "severidad" "SeveridadEvento" NOT NULL DEFAULT 'INFO';

-- AlterTable
ALTER TABLE "examenes" ADD COLUMN     "aleatorizar" BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN     "idExamenPadre" TEXT,
ADD COLUMN     "idInstitucion" TEXT,
ADD COLUMN     "permitirNavegacionLibre" BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN     "puntajeMaximoDefinido" DOUBLE PRECISION NOT NULL DEFAULT 0.0,
ADD COLUMN     "version" INTEGER NOT NULL DEFAULT 1;

-- AlterTable
ALTER TABLE "intentos_examen" ADD COLUMN     "anuladoEn" TIMESTAMP(3),
ADD COLUMN     "anuladoPorId" TEXT,
ADD COLUMN     "idInstitucion" TEXT,
ADD COLUMN     "indiceRiesgoFraude" DOUBLE PRECISION NOT NULL DEFAULT 0,
ADD COLUMN     "ordenPreguntasAplicado" JSONB,
ADD COLUMN     "plataforma" VARCHAR(20),
ADD COLUMN     "razonAnulacion" TEXT,
ADD COLUMN     "requiereRevision" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "ultimaSincronizacion" TIMESTAMP(3);

-- AlterTable
ALTER TABLE "opciones_respuesta" ADD COLUMN     "puntajeParcial" DOUBLE PRECISION;

-- AlterTable
ALTER TABLE "preguntas" ADD COLUMN     "activo" BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN     "metadatos" JSONB,
ADD COLUMN     "obligatoria" BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN     "retroalimentacion" TEXT;

-- AlterTable
ALTER TABLE "respuestas" ADD COLUMN     "calificadaAutomaticamente" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "calificadaManualmente" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "calificadaManualmenteEn" TIMESTAMP(3),
ADD COLUMN     "calificadaManualmentePor" TEXT,
ADD COLUMN     "comentarioCalificador" VARCHAR(500),
ADD COLUMN     "guardadoEn" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "version" INTEGER NOT NULL DEFAULT 1;

-- AlterTable
ALTER TABLE "sesiones_examen" ADD COLUMN     "configuracionAntifraude" JSONB,
ADD COLUMN     "duracionEfectivaMinutos" INTEGER,
ADD COLUMN     "idAsignacion" TEXT,
ADD COLUMN     "idInstitucion" TEXT,
ALTER COLUMN "codigoAcceso" DROP NOT NULL;

-- AlterTable
ALTER TABLE "usuarios" ADD COLUMN     "bloqueadoHasta" TIMESTAMP(3),
ADD COLUMN     "credencialTemporal" VARCHAR(255),
ADD COLUMN     "credencialTemporalVence" TIMESTAMP(3),
ADD COLUMN     "estadoCuenta" "EstadoCuenta" NOT NULL DEFAULT 'PENDIENTE_ACTIVACION',
ADD COLUMN     "idInstitucion" TEXT,
ADD COLUMN     "intentosFallidosLogin" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "perfil" JSONB,
ADD COLUMN     "primerLogin" BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN     "ultimoLogin" TIMESTAMP(3);

-- CreateTable
CREATE TABLE "instituciones" (
    "id" TEXT NOT NULL,
    "nombre" VARCHAR(150) NOT NULL,
    "dominio" VARCHAR(255),
    "estado" "EstadoInstitucion" NOT NULL DEFAULT 'ACTIVA',
    "configuracion" JSONB,
    "fechaCreacion" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "fechaActualizacion" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "instituciones_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "periodos_academicos" (
    "id" TEXT NOT NULL,
    "idInstitucion" TEXT NOT NULL,
    "nombre" VARCHAR(120) NOT NULL,
    "fechaInicio" TIMESTAMP(3) NOT NULL,
    "fechaFin" TIMESTAMP(3) NOT NULL,
    "activo" BOOLEAN NOT NULL DEFAULT true,
    "fechaCreacion" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "fechaActualizacion" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "periodos_academicos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "grupos_academicos" (
    "id" TEXT NOT NULL,
    "idInstitucion" TEXT NOT NULL,
    "idPeriodo" TEXT NOT NULL,
    "nombre" VARCHAR(150) NOT NULL,
    "descripcion" TEXT,
    "estado" "EstadoGrupo" NOT NULL DEFAULT 'BORRADOR',
    "codigoAcceso" VARCHAR(8) NOT NULL,
    "fechaCreacion" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "fechaActualizacion" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "grupos_academicos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "grupos_docentes" (
    "id" TEXT NOT NULL,
    "idGrupo" TEXT NOT NULL,
    "idDocente" TEXT NOT NULL,
    "asignadoPor" TEXT NOT NULL,
    "asignadoEn" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "activo" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "grupos_docentes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "grupos_estudiantes" (
    "id" TEXT NOT NULL,
    "idGrupo" TEXT NOT NULL,
    "idEstudiante" TEXT NOT NULL,
    "inscritoPor" TEXT NOT NULL,
    "inscritoEn" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "activo" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "grupos_estudiantes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "asignaciones_examen" (
    "id" TEXT NOT NULL,
    "idInstitucion" TEXT NOT NULL,
    "idExamen" TEXT NOT NULL,
    "idGrupo" TEXT,
    "idEstudiante" TEXT,
    "fechaInicio" TIMESTAMP(3) NOT NULL,
    "fechaFin" TIMESTAMP(3) NOT NULL,
    "intentosMaximos" INTEGER NOT NULL DEFAULT 1,
    "mostrarPuntajeInmediato" BOOLEAN NOT NULL DEFAULT false,
    "mostrarRespuestasCorrectas" BOOLEAN NOT NULL DEFAULT false,
    "publicarResultadosEn" TIMESTAMP(3),
    "creadoPor" TEXT NOT NULL,
    "fechaCreacion" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "asignaciones_examen_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "resultados_intento" (
    "id" TEXT NOT NULL,
    "intentoId" TEXT NOT NULL,
    "puntajeTotal" DOUBLE PRECISION NOT NULL,
    "puntajeMaximoPosible" DOUBLE PRECISION NOT NULL,
    "porcentaje" DOUBLE PRECISION NOT NULL,
    "estado" "EstadoResultado" NOT NULL DEFAULT 'PRELIMINAR',
    "pendienteCalificacionManual" BOOLEAN NOT NULL DEFAULT false,
    "publicadoEn" TIMESTAMP(3),
    "version" INTEGER NOT NULL DEFAULT 1,
    "calculadoEn" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "resultados_intento_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "reclamos_calificacion" (
    "id" TEXT NOT NULL,
    "resultadoId" TEXT NOT NULL,
    "idEstudiante" TEXT NOT NULL,
    "idPregunta" TEXT,
    "motivo" TEXT NOT NULL,
    "estado" "EstadoReclamo" NOT NULL DEFAULT 'PRESENTADO',
    "presentadoEn" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "resueltoPorId" TEXT,
    "resolverEn" TIMESTAMP(3),
    "resolucion" TEXT,
    "puntajeAnterior" DOUBLE PRECISION,
    "puntajeNuevo" DOUBLE PRECISION,
    "versionAnterior" INTEGER,

    CONSTRAINT "reclamos_calificacion_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "auditoria_acciones" (
    "id" TEXT NOT NULL,
    "idInstitucion" TEXT,
    "idActor" TEXT,
    "rolActor" "RolUsuario",
    "accion" VARCHAR(120) NOT NULL,
    "recurso" VARCHAR(120) NOT NULL,
    "idRecurso" VARCHAR(60),
    "snapshotAntes" JSONB,
    "snapshotDespues" JSONB,
    "ip" VARCHAR(50),
    "userAgent" VARCHAR(500),
    "timestamp" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "resultado" VARCHAR(20) NOT NULL DEFAULT 'EXITO',
    "razonFallo" TEXT,

    CONSTRAINT "auditoria_acciones_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "instituciones_nombre_key" ON "instituciones"("nombre");

-- CreateIndex
CREATE UNIQUE INDEX "instituciones_dominio_key" ON "instituciones"("dominio");

-- CreateIndex
CREATE UNIQUE INDEX "grupos_academicos_codigoAcceso_key" ON "grupos_academicos"("codigoAcceso");

-- CreateIndex
CREATE INDEX "grupos_academicos_idInstitucion_idx" ON "grupos_academicos"("idInstitucion");

-- CreateIndex
CREATE UNIQUE INDEX "grupos_docentes_idGrupo_idDocente_key" ON "grupos_docentes"("idGrupo", "idDocente");

-- CreateIndex
CREATE UNIQUE INDEX "grupos_estudiantes_idGrupo_idEstudiante_key" ON "grupos_estudiantes"("idGrupo", "idEstudiante");

-- CreateIndex
CREATE INDEX "asignaciones_examen_idInstitucion_idx" ON "asignaciones_examen"("idInstitucion");

-- CreateIndex
CREATE INDEX "asignaciones_examen_idExamen_idx" ON "asignaciones_examen"("idExamen");

-- CreateIndex
CREATE INDEX "asignaciones_examen_idGrupo_idx" ON "asignaciones_examen"("idGrupo");

-- CreateIndex
CREATE INDEX "asignaciones_examen_idEstudiante_idx" ON "asignaciones_examen"("idEstudiante");

-- CreateIndex
CREATE UNIQUE INDEX "resultados_intento_intentoId_key" ON "resultados_intento"("intentoId");

-- CreateIndex
CREATE INDEX "reclamos_calificacion_resultadoId_idx" ON "reclamos_calificacion"("resultadoId");

-- CreateIndex
CREATE INDEX "auditoria_acciones_idInstitucion_idx" ON "auditoria_acciones"("idInstitucion");

-- CreateIndex
CREATE INDEX "auditoria_acciones_idActor_idx" ON "auditoria_acciones"("idActor");

-- CreateIndex
CREATE INDEX "examenes_idInstitucion_idx" ON "examenes"("idInstitucion");

-- CreateIndex
CREATE INDEX "intentos_examen_idInstitucion_idx" ON "intentos_examen"("idInstitucion");

-- CreateIndex
CREATE INDEX "intentos_examen_sesionId_estudianteId_idx" ON "intentos_examen"("sesionId", "estudianteId");

-- CreateIndex
CREATE INDEX "sesiones_examen_idInstitucion_idx" ON "sesiones_examen"("idInstitucion");

-- CreateIndex
CREATE INDEX "usuarios_idInstitucion_idx" ON "usuarios"("idInstitucion");

-- AddForeignKey
ALTER TABLE "periodos_academicos" ADD CONSTRAINT "periodos_academicos_idInstitucion_fkey" FOREIGN KEY ("idInstitucion") REFERENCES "instituciones"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "usuarios" ADD CONSTRAINT "usuarios_idInstitucion_fkey" FOREIGN KEY ("idInstitucion") REFERENCES "instituciones"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "grupos_academicos" ADD CONSTRAINT "grupos_academicos_idInstitucion_fkey" FOREIGN KEY ("idInstitucion") REFERENCES "instituciones"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "grupos_academicos" ADD CONSTRAINT "grupos_academicos_idPeriodo_fkey" FOREIGN KEY ("idPeriodo") REFERENCES "periodos_academicos"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "grupos_docentes" ADD CONSTRAINT "grupos_docentes_idGrupo_fkey" FOREIGN KEY ("idGrupo") REFERENCES "grupos_academicos"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "grupos_docentes" ADD CONSTRAINT "grupos_docentes_idDocente_fkey" FOREIGN KEY ("idDocente") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "grupos_docentes" ADD CONSTRAINT "grupos_docentes_asignadoPor_fkey" FOREIGN KEY ("asignadoPor") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "grupos_estudiantes" ADD CONSTRAINT "grupos_estudiantes_idGrupo_fkey" FOREIGN KEY ("idGrupo") REFERENCES "grupos_academicos"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "grupos_estudiantes" ADD CONSTRAINT "grupos_estudiantes_idEstudiante_fkey" FOREIGN KEY ("idEstudiante") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "grupos_estudiantes" ADD CONSTRAINT "grupos_estudiantes_inscritoPor_fkey" FOREIGN KEY ("inscritoPor") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "examenes" ADD CONSTRAINT "examenes_idInstitucion_fkey" FOREIGN KEY ("idInstitucion") REFERENCES "instituciones"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "asignaciones_examen" ADD CONSTRAINT "asignaciones_examen_idInstitucion_fkey" FOREIGN KEY ("idInstitucion") REFERENCES "instituciones"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "asignaciones_examen" ADD CONSTRAINT "asignaciones_examen_idExamen_fkey" FOREIGN KEY ("idExamen") REFERENCES "examenes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "asignaciones_examen" ADD CONSTRAINT "asignaciones_examen_idGrupo_fkey" FOREIGN KEY ("idGrupo") REFERENCES "grupos_academicos"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "asignaciones_examen" ADD CONSTRAINT "asignaciones_examen_idEstudiante_fkey" FOREIGN KEY ("idEstudiante") REFERENCES "usuarios"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "asignaciones_examen" ADD CONSTRAINT "asignaciones_examen_creadoPor_fkey" FOREIGN KEY ("creadoPor") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sesiones_examen" ADD CONSTRAINT "sesiones_examen_idAsignacion_fkey" FOREIGN KEY ("idAsignacion") REFERENCES "asignaciones_examen"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sesiones_examen" ADD CONSTRAINT "sesiones_examen_idInstitucion_fkey" FOREIGN KEY ("idInstitucion") REFERENCES "instituciones"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "intentos_examen" ADD CONSTRAINT "intentos_examen_idInstitucion_fkey" FOREIGN KEY ("idInstitucion") REFERENCES "instituciones"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "intentos_examen" ADD CONSTRAINT "intentos_examen_anuladoPorId_fkey" FOREIGN KEY ("anuladoPorId") REFERENCES "usuarios"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "respuestas" ADD CONSTRAINT "respuestas_calificadaManualmentePor_fkey" FOREIGN KEY ("calificadaManualmentePor") REFERENCES "usuarios"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "resultados_intento" ADD CONSTRAINT "resultados_intento_intentoId_fkey" FOREIGN KEY ("intentoId") REFERENCES "intentos_examen"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reclamos_calificacion" ADD CONSTRAINT "reclamos_calificacion_resultadoId_fkey" FOREIGN KEY ("resultadoId") REFERENCES "resultados_intento"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reclamos_calificacion" ADD CONSTRAINT "reclamos_calificacion_idEstudiante_fkey" FOREIGN KEY ("idEstudiante") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reclamos_calificacion" ADD CONSTRAINT "reclamos_calificacion_resueltoPorId_fkey" FOREIGN KEY ("resueltoPorId") REFERENCES "usuarios"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "auditoria_acciones" ADD CONSTRAINT "auditoria_acciones_idInstitucion_fkey" FOREIGN KEY ("idInstitucion") REFERENCES "instituciones"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "auditoria_acciones" ADD CONSTRAINT "auditoria_acciones_idActor_fkey" FOREIGN KEY ("idActor") REFERENCES "usuarios"("id") ON DELETE SET NULL ON UPDATE CASCADE;

