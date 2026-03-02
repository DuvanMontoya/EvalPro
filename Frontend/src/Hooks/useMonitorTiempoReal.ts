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

/**
 * Conecta al gateway de sesiones y escucha progreso/fraude en tiempo real.
 * @param idSesion - UUID de la sesión en monitoreo.
 */
export function useMonitorTiempoReal(idSesion: string) {
  const [socket, setSocket] = useState<Socket | null>(null);
  const [progresoEstudiantes, setProgresoEstudiantes] = useState<Record<string, ProgresoEstudiante>>({});
  const [alertasFraude, setAlertasFraude] = useState<AlertaFraude[]>([]);
  const [sesionFinalizada, setSesionFinalizada] = useState(false);

  useEffect(() => {
    if (!idSesion) {
      return;
    }

    const socketSesion = io(`${API.WEBSOCKET}${API.EVENTOS_SOCKET.ESPACIO_SESIONES}`, {
      transports: ['websocket'],
    });

    socketSesion.emit(API.EVENTOS_SOCKET.UNIRSE_SALA, { idSesion, rol: RolUsuario.DOCENTE });

    socketSesion.on(API.EVENTOS_SOCKET.ESTUDIANTE_PROGRESO, (payload: { idIntento: string; preguntasRespondidas: number }) => {
      setProgresoEstudiantes((previo) => {
        const actual = previo[payload.idIntento];
        return {
          ...previo,
          [payload.idIntento]: {
            idIntento: payload.idIntento,
            preguntasRespondidas: payload.preguntasRespondidas,
            totalPreguntas: actual?.totalPreguntas ?? 0,
            nombreCompleto: actual?.nombreCompleto ?? 'Estudiante',
            modoKioscoActivo: actual?.modoKioscoActivo ?? true,
            eventosFraude: actual?.eventosFraude ?? 0,
            estadoIntento: actual?.estadoIntento ?? 'EN_PROGRESO',
          },
        };
      });
    });

    socketSesion.on(API.EVENTOS_SOCKET.ESTUDIANTE_FRAUDE, (payload: { idIntento: string; tipoEvento: TipoEventoTelemetria }) => {
      const alerta: AlertaFraude = {
        id: crypto.randomUUID(),
        idIntento: payload.idIntento,
        tipoEvento: payload.tipoEvento,
        fecha: new Date().toISOString(),
        nombreEstudiante: 'Estudiante',
      };
      setAlertasFraude((previo) => [alerta, ...previo]);

      setProgresoEstudiantes((previo) => {
        const actual = previo[payload.idIntento];
        if (!actual) {
          return previo;
        }

        return {
          ...previo,
          [payload.idIntento]: {
            ...actual,
            eventosFraude: actual.eventosFraude + 1,
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
    };
  }, [idSesion]);

  const listaEstudiantes = useMemo(() => Object.values(progresoEstudiantes), [progresoEstudiantes]);

  return {
    socket,
    listaEstudiantes,
    alertasFraude,
    sesionFinalizada,
  };
}
