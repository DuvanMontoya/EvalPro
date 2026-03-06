/**
 * @archivo   MonitorTiempoReal.tsx
 * @descripcion Visualiza progreso en vivo por estudiante y controla cierre masivo de sesión.
 * @modulo    ComponentesSesiones
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { useEffect, useMemo, useState } from 'react';
import { toast } from 'sonner';
import { useRouter } from 'next/navigation';
import { EstadoIntento, EstadoSesion } from '@/Tipos';
import { RUTAS } from '@/Constantes/Rutas.constantes';
import { useAutenticacion } from '@/Hooks/useAutenticacion';
import { useMonitorTiempoReal } from '@/Hooks/useMonitorTiempoReal';
import { useSesiones } from '@/Hooks/useSesiones';
import { Boton } from '@/Componentes/Ui/Boton';
import { ModalConfirmacion } from '@/Componentes/Comunes/ModalConfirmacion';
import { EstadoVacio } from '@/Componentes/Comunes/EstadoVacio';
import { TarjetaEstudianteMonitor } from '@/Componentes/Sesiones/TarjetaEstudianteMonitor';
import { AlertaFraude } from '@/Componentes/Sesiones/AlertaFraude';
import { obtenerMensajeError } from '@/Lib/ErroresApi';
import { puedeFinalizarSesion } from '@/Lib/Permisos';

interface PropiedadesMonitorTiempoReal {
  idSesion: string;
  totalPreguntas: number;
  intentosRegistrados?: number;
  estudiantesReporte?: {
    idIntento?: string;
    idEstudiante?: string;
    nombre: string;
    apellidos: string;
    estado: EstadoIntento;
    ultimaSincronizacion?: string | null;
    fechaInicio?: string;
    preguntasRespondidas?: number;
    preguntasRespondidasIndices?: number[];
  }[];
}

const UMBRAL_PULSO_CONECTADO_MS = 45_000;

function esEstadoIntentoActivo(estado: string): boolean {
  return estado === EstadoIntento.EN_PROGRESO || estado === EstadoIntento.SINCRONIZACION_PENDIENTE;
}

const MAPA_EVENTOS: Record<string, string> = {
  APLICACION_EN_SEGUNDO_PLANO: 'Aplicación en segundo plano',
  PANTALLA_ABANDONADA: 'Pantalla abandonada',
  FORZAR_CIERRE: 'Cierre forzado del dispositivo',
  CAMBIO_RED: 'Cambio de red detectado',
  SYNC_ANOMALA: 'Reconexiones de red anómalas',
  CAPTURA_PANTALLA_DETECTADA: 'Captura de pantalla detectada',
  MULTIPLES_DISPOSITIVOS: 'Múltiples dispositivos',
};

/**
 * Renderiza tablero de monitoreo WebSocket para una sesión activa.
 */
export function MonitorTiempoReal({
  idSesion,
  totalPreguntas,
  intentosRegistrados = 0,
  estudiantesReporte = [],
}: PropiedadesMonitorTiempoReal) {
  const router = useRouter();
  const [modalFinalizarAbierto, setModalFinalizarAbierto] = useState(false);
  const { mutacionFinalizarSesion } = useSesiones();
  const { usuario } = useAutenticacion();
  const { listaEstudiantes, alertasFraude, sesionFinalizada, conexionActiva } = useMonitorTiempoReal(idSesion);
  const puedeFinalizar = puedeFinalizarSesion(usuario?.rol, EstadoSesion.ACTIVA);

  useEffect(() => {
    if (sesionFinalizada) {
      router.push(RUTAS.SESION_RESULTADOS(idSesion));
    }
  }, [idSesion, router, sesionFinalizada]);

  useEffect(() => {
    if (alertasFraude.length === 0) {
      return;
    }

    const ultima = alertasFraude[0]!;
    const tipoLegible = MAPA_EVENTOS[ultima.tipoEvento] ?? ultima.tipoEvento;
    const hora = new Date(ultima.fecha).toLocaleTimeString();
    toast.error(`${ultima.nombreEstudiante}: ${tipoLegible} (${hora})`);
  }, [alertasFraude]);

  const estudiantesNormalizados = useMemo(
    () => {
      const porEstudiante = new Map<
        string,
        {
          idIntento: string;
          idEstudiante: string;
          preguntasRespondidas: number;
          preguntasRespondidasIndices: number[];
          indicePreguntaActual?: number;
          totalPreguntas: number;
          nombreCompleto: string;
          modoKioscoActivo: boolean;
          eventosFraude: number;
          estadoIntento: string;
          marcaActividadMs: number;
        }
      >();

      for (const estudiante of listaEstudiantes) {
        if (!esEstadoIntentoActivo(estudiante.estadoIntento)) {
          continue;
        }

        const claveEstudiante = estudiante.idEstudiante?.trim() || `socket-${estudiante.idIntento}`;
        const existente = porEstudiante.get(claveEstudiante);
        if (existente && existente.marcaActividadMs >= estudiante.ultimaActualizacionMs) {
          continue;
        }

        porEstudiante.set(claveEstudiante, {
          ...estudiante,
          idEstudiante: estudiante.idEstudiante?.trim() || claveEstudiante,
          totalPreguntas,
          marcaActividadMs: estudiante.ultimaActualizacionMs,
        });
      }

      for (const [indice, estudiante] of estudiantesReporte.entries()) {
        const esActivo = esEstadoIntentoActivo(estudiante.estado);

        const ultimaSincronizacion = estudiante.ultimaSincronizacion ? new Date(estudiante.ultimaSincronizacion) : null;
        const tienePulsoReciente =
          ultimaSincronizacion instanceof Date &&
          !Number.isNaN(ultimaSincronizacion.getTime()) &&
          Date.now() - ultimaSincronizacion.getTime() <= UMBRAL_PULSO_CONECTADO_MS;

        const idIntento = estudiante.idIntento?.trim() || `reporte-${indice}-${estudiante.nombre}-${estudiante.apellidos}`;
        const marcaActividadMs = ultimaSincronizacion?.getTime() ?? 0;
        const claveEstudiante =
          estudiante.idEstudiante?.trim() ||
          `${estudiante.nombre.trim().toLowerCase()}-${estudiante.apellidos.trim().toLowerCase()}` ||
          `reporte-${indice}`;

        if (!esActivo || !tienePulsoReciente) {
          continue;
        }

        const existente = porEstudiante.get(claveEstudiante);
        if (existente && existente.marcaActividadMs >= marcaActividadMs) {
          continue;
        }

        porEstudiante.set(claveEstudiante, {
          idIntento,
          idEstudiante: estudiante.idEstudiante?.trim() || claveEstudiante,
          preguntasRespondidas: estudiante.preguntasRespondidas ?? estudiante.preguntasRespondidasIndices?.length ?? 0,
          preguntasRespondidasIndices: estudiante.preguntasRespondidasIndices ?? [],
          totalPreguntas,
          nombreCompleto: `${estudiante.nombre} ${estudiante.apellidos}`.trim(),
          modoKioscoActivo: true,
          eventosFraude: 0,
          estadoIntento: estudiante.estado,
          marcaActividadMs,
        });
      }

      return Array.from(porEstudiante.values())
        .sort((a, b) => b.marcaActividadMs - a.marcaActividadMs)
        .map(({ marcaActividadMs: _marcaActividadMs, ...estudiante }) => estudiante);
    },
    [estudiantesReporte, listaEstudiantes, totalPreguntas],
  );

  return (
    <section className="space-y-6">
      <div className="flex items-center justify-between">
        <h2 className="text-xl font-semibold">Monitor en tiempo real</h2>
        <p className="texto-muted text-sm">
          Conectados en vivo: {estudiantesNormalizados.length} · Intentos históricos: {intentosRegistrados}
        </p>
        {puedeFinalizar ? (
          <Boton variante="peligro" onClick={() => setModalFinalizarAbierto(true)}>
            Finalizar Sesión para Todos
          </Boton>
        ) : null}
      </div>

      {!conexionActiva ? (
        <div className="rounded-md border border-[var(--estado-advertencia-borde)] bg-[var(--estado-advertencia-sutil)] px-4 py-3 text-sm text-[var(--estado-advertencia)]">
          Conexión en tiempo real interrumpida. Reintentando reconexión automáticamente.
        </div>
      ) : null}

      {estudiantesNormalizados.length === 0 ? (
        <EstadoVacio
          titulo="Sin estudiantes conectados"
          descripcion={
            intentosRegistrados > 0
              ? `No hay conexiones activas en este momento. Hay ${intentosRegistrados} intento(s) registrado(s) en la sesión.`
              : 'Cuando los estudiantes se unan a la sesión aparecerán aquí.'
          }
        />
      ) : (
        <div className="grid gap-4 lg:grid-cols-2">
          {estudiantesNormalizados.map((estudiante) => (
            <TarjetaEstudianteMonitor
              key={`${estudiante.idEstudiante}-${estudiante.idIntento}`}
              nombreCompleto={estudiante.nombreCompleto}
              preguntasRespondidas={estudiante.preguntasRespondidas}
              totalPreguntas={estudiante.totalPreguntas}
              modoKioscoActivo={estudiante.modoKioscoActivo}
              eventosFraude={estudiante.eventosFraude}
              estadoIntento={estudiante.estadoIntento as EstadoIntento}
              preguntasRespondidasIndices={estudiante.preguntasRespondidasIndices}
              indicePreguntaActual={estudiante.indicePreguntaActual}
            />
          ))}
        </div>
      )}

      <div className="space-y-2">
        <h3 className="text-lg font-semibold">Alertas de fraude</h3>
        {alertasFraude.length === 0 ? (
          <p className="texto-muted">No hay alertas registradas.</p>
        ) : (
          <div className="space-y-2">
            {alertasFraude.map((alerta) => (
              <AlertaFraude
                key={alerta.id}
                nombreEstudiante={alerta.nombreEstudiante}
                tipoEvento={MAPA_EVENTOS[alerta.tipoEvento] ?? alerta.tipoEvento}
                fecha={alerta.fecha}
              />
            ))}
          </div>
        )}
      </div>

      {puedeFinalizar ? (
        <ModalConfirmacion
          abierto={modalFinalizarAbierto}
          onCambiarAbierto={setModalFinalizarAbierto}
          titulo="Finalizar sesión"
          descripcion="Esta acción enviará cierre para todos los estudiantes conectados."
          textoConfirmar="Finalizar ahora"
          cargando={mutacionFinalizarSesion.isPending}
          onConfirmar={async () => {
            try {
              await mutacionFinalizarSesion.mutateAsync(idSesion);
              setModalFinalizarAbierto(false);
              router.push(RUTAS.SESION_RESULTADOS(idSesion));
            } catch (error) {
              toast.error(obtenerMensajeError(error, 'No se pudo finalizar la sesión.'));
            }
          }}
        />
      ) : null}
    </section>
  );
}
