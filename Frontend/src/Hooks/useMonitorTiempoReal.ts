/**
 * @archivo   useMonitorTiempoReal.ts
 * @descripcion Maneja conexión WebSocket de sesión activa y sincroniza progreso/fraude en UI.
 * @modulo    Hooks
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { useEffect, useMemo, useState } from 'react';
import { io, Socket } from 'socket.io-client';
import { RolUsuario, TipoEventoTelemetria } from '@/Tipos';
import { API } from '@/Constantes/Api.constantes';

interface ProgresoEstudiante {
  idIntento: string;
  preguntasRespondidas: number;
  totalPreguntas: number;
  nombreCompleto: string;
  modoKioscoActivo: boolean;
  eventosFraude: number;
  estadoIntento: string;
}

interface AlertaFraude {
  id: string;
  idIntento: string;
  tipoEvento: TipoEventoTelemetria;
  fecha: string;
  nombreEstudiante: string;
}

interface PayloadProgreso {
  idIntento: string;
  preguntasRespondidas: number;
  totalPreguntas?: number;
  nombreCompleto?: string;
  modoKioscoActivo?: boolean;
  eventosFraude?: number;
  estadoIntento?: string;
}

interface PayloadFraude {
  idIntento: string;
  tipoEvento: TipoEventoTelemetria;
  nombreEstudiante?: string;
  fecha?: string;
}

function obtenerNombreFallback(idIntento: string): string {
  return `Intento ${idIntento.slice(0, 8)}`;
}

/**
 * Conecta al gateway de sesiones y escucha progreso/fraude en tiempo real.
 * @param idSesion - UUID de la sesión en monitoreo.
 */
export function useMonitorTiempoReal(idSesion: string) {
  const [socket, setSocket] = useState<Socket | null>(null);
  const [progresoEstudiantes, setProgresoEstudiantes] = useState<Record<string, ProgresoEstudiante>>({});
  const [alertasFraude, setAlertasFraude] = useState<AlertaFraude[]>([]);
  const [sesionFinalizada, setSesionFinalizada] = useState(false);
  const [conexionActiva, setConexionActiva] = useState(false);

  useEffect(() => {
    if (!idSesion) {
      return;
    }

    const socketSesion = io(`${API.WEBSOCKET}${API.EVENTOS_SOCKET.ESPACIO_SESIONES}`, {
      transports: ['websocket'],
      reconnection: true,
      reconnectionAttempts: 8,
      reconnectionDelay: 1000,
      timeout: 10000,
    });

    socketSesion.on('connect', () => {
      setConexionActiva(true);
      socketSesion.emit(API.EVENTOS_SOCKET.UNIRSE_SALA, { idSesion, rol: RolUsuario.DOCENTE });
    });

    socketSesion.on('disconnect', () => {
      setConexionActiva(false);
    });

    socketSesion.on(API.EVENTOS_SOCKET.ESTUDIANTE_PROGRESO, (payload: PayloadProgreso) => {
      setProgresoEstudiantes((previo) => {
        const actual = previo[payload.idIntento];
        return {
          ...previo,
          [payload.idIntento]: {
            idIntento: payload.idIntento,
            preguntasRespondidas: payload.preguntasRespondidas,
            totalPreguntas: payload.totalPreguntas ?? actual?.totalPreguntas ?? 0,
            nombreCompleto: payload.nombreCompleto ?? actual?.nombreCompleto ?? obtenerNombreFallback(payload.idIntento),
            modoKioscoActivo: payload.modoKioscoActivo ?? actual?.modoKioscoActivo ?? true,
            eventosFraude: payload.eventosFraude ?? actual?.eventosFraude ?? 0,
            estadoIntento: payload.estadoIntento ?? actual?.estadoIntento ?? 'EN_PROGRESO',
          },
        };
      });
    });

    socketSesion.on(API.EVENTOS_SOCKET.ESTUDIANTE_FRAUDE, (payload: PayloadFraude) => {
      const alerta: AlertaFraude = {
        id: crypto.randomUUID(),
        idIntento: payload.idIntento,
        tipoEvento: payload.tipoEvento,
        fecha: payload.fecha ?? new Date().toISOString(),
        nombreEstudiante: payload.nombreEstudiante ?? obtenerNombreFallback(payload.idIntento),
      };
      setAlertasFraude((previo) => [alerta, ...previo]);

      setProgresoEstudiantes((previo) => {
        const actual = previo[payload.idIntento];
        const base = actual ?? {
          idIntento: payload.idIntento,
          preguntasRespondidas: 0,
          totalPreguntas: 0,
          nombreCompleto: payload.nombreEstudiante ?? obtenerNombreFallback(payload.idIntento),
          modoKioscoActivo: false,
          eventosFraude: 0,
          estadoIntento: 'EN_PROGRESO',
        };

        return {
          ...previo,
          [payload.idIntento]: {
            ...base,
            eventosFraude: base.eventosFraude + 1,
            modoKioscoActivo: false,
          },
        };
      });
    });

    socketSesion.on(API.EVENTOS_SOCKET.SESION_FINALIZADA, () => {
      setSesionFinalizada(true);
    });

    setSocket(socketSesion);
    return () => {
      socketSesion.disconnect();
      setSocket(null);
      setConexionActiva(false);
    };
  }, [idSesion]);

  const listaEstudiantes = useMemo(() => Object.values(progresoEstudiantes), [progresoEstudiantes]);

  return {
    socket,
    listaEstudiantes,
    alertasFraude,
    sesionFinalizada,
    conexionActiva,
  };
}
