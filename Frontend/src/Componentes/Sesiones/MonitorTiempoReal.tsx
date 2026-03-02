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
}

const MAPA_EVENTOS: Record<string, string> = {
  APLICACION_EN_SEGUNDO_PLANO: 'Aplicación en segundo plano',
  PANTALLA_ABANDONADA: 'Pantalla abandonada',
  FORZAR_CIERRE: 'Cierre forzado del dispositivo',
};

/**
 * Renderiza tablero de monitoreo WebSocket para una sesión activa.
 */
export function MonitorTiempoReal({ idSesion, totalPreguntas }: PropiedadesMonitorTiempoReal) {
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
    () =>
      listaEstudiantes.map((estudiante) => ({
        ...estudiante,
        totalPreguntas,
      })),
    [listaEstudiantes, totalPreguntas],
  );

  return (
    <section className="space-y-6">
      <div className="flex items-center justify-between">
        <h2 className="text-xl font-semibold">Monitor en tiempo real</h2>
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
          descripcion="Cuando los estudiantes se unan a la sesión aparecerán aquí."
        />
      ) : (
        <div className="grid gap-4 lg:grid-cols-2">
          {estudiantesNormalizados.map((estudiante) => (
            <TarjetaEstudianteMonitor
              key={estudiante.idIntento}
              nombreCompleto={estudiante.nombreCompleto}
              preguntasRespondidas={estudiante.preguntasRespondidas}
              totalPreguntas={estudiante.totalPreguntas}
              modoKioscoActivo={estudiante.modoKioscoActivo}
              eventosFraude={estudiante.eventosFraude}
              estadoIntento={estudiante.estadoIntento as EstadoIntento}
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
