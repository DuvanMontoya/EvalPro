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
import { TipoEventoTelemetria } from '@/Tipos';
import { API } from '@/Constantes/Api.constantes';
import { establecerTokenAcceso, obtenerTokenAcceso } from '@/Servicios/ApiCliente';

interface ProgresoEstudiante {
  idIntento: string;
  idEstudiante?: string;
  preguntasRespondidas: number;
  preguntasRespondidasIndices: number[];
  indicePreguntaActual?: number;
  totalPreguntas: number;
  nombreCompleto: string;
  modoKioscoActivo: boolean;
  eventosFraude: number;
  estadoIntento: string;
  ultimaActualizacionMs: number;
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
  idEstudiante?: string;
  preguntasRespondidas: number;
  preguntasRespondidasIndices?: number[];
  indicePreguntaActual?: number;
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

const UMBRAL_INACTIVIDAD_MONITOR_MS = 45_000;

function obtenerNombreFallback(idIntento: string): string {
  return `Intento ${idIntento.slice(0, 8)}`;
}

function normalizarIndices(indices: number[] | undefined, totalPreguntas: number): number[] {
  if (!Array.isArray(indices)) {
    return [];
  }

  const normalizados = indices.filter((indice) => {
    if (!Number.isInteger(indice) || indice <= 0) {
      return false;
    }
    if (totalPreguntas <= 0) {
      return true;
    }
    return indice <= totalPreguntas;
  });
  return [...new Set(normalizados)].sort((a, b) => a - b);
}

async function resolverTokenSocket(): Promise<string | null> {
  const tokenMemoria = obtenerTokenAcceso();
  if (tokenMemoria) {
    return tokenMemoria;
  }

  try {
    const respuesta = await fetch('/api/auth/refrescar', {
      method: 'POST',
      credentials: 'include',
    });
    if (!respuesta.ok) {
      return null;
    }

    const datos = (await respuesta.json()) as { tokenAcceso?: string };
    const token = datos.tokenAcceso?.trim();
    if (!token) {
      return null;
    }

    establecerTokenAcceso(token);
    return token;
  } catch {
    return null;
  }
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

    setProgresoEstudiantes({});
    setAlertasFraude([]);
    setSesionFinalizada(false);

    let cancelado = false;
    let socketSesion: Socket | null = null;

    const iniciar = async () => {
      const tokenAcceso = await resolverTokenSocket();
      if (cancelado) {
        return;
      }

      if (!tokenAcceso) {
        setConexionActiva(false);
        return;
      }

      socketSesion = io(`${API.WEBSOCKET}${API.EVENTOS_SOCKET.ESPACIO_SESIONES}`, {
        transports: ['websocket'],
        reconnection: true,
        reconnectionAttempts: 8,
        reconnectionDelay: 1000,
        timeout: 10000,
        auth: (callback) => {
          const tokenVigente = obtenerTokenAcceso() ?? tokenAcceso;
          callback({ token: tokenVigente, tokenAcceso: tokenVigente });
        },
      });

      const unirSala = () => {
        if (!socketSesion?.connected) {
          return;
        }
        socketSesion.emit(API.EVENTOS_SOCKET.UNIRSE_SALA, { idSesion });
      };

      socketSesion.on('connect', () => {
        setConexionActiva(true);
        // Evita condición de carrera al unir sala cuando el backend termina autenticación del socket.
        globalThis.setTimeout(unirSala, 200);
      });

      socketSesion.on('disconnect', () => {
        setConexionActiva(false);
      });

      socketSesion.on('connect_error', () => {
        setConexionActiva(false);
      });

      socketSesion.on('exception', (payload: { message?: string }) => {
        const mensaje = payload?.message ?? '';
        if (mensaje.includes('Socket no autenticado')) {
          globalThis.setTimeout(unirSala, 400);
        }
      });

      socketSesion.on(API.EVENTOS_SOCKET.ESTUDIANTE_PROGRESO, (payload: PayloadProgreso) => {
        if (payload.estadoIntento === 'ENVIADO' || payload.estadoIntento === 'ANULADO') {
          setProgresoEstudiantes((previo) => {
            if (!previo[payload.idIntento]) {
              return previo;
            }

            const siguiente = { ...previo };
            delete siguiente[payload.idIntento];
            return siguiente;
          });
          return;
        }

        const marcaTiempo = Date.now();
        setProgresoEstudiantes((previo) => {
          const actual = previo[payload.idIntento];
          const totalPreguntas = payload.totalPreguntas ?? actual?.totalPreguntas ?? 0;
          const preguntasRespondidasIndices = payload.preguntasRespondidasIndices
            ? normalizarIndices(payload.preguntasRespondidasIndices, totalPreguntas)
            : (actual?.preguntasRespondidasIndices ?? []);
          return {
            ...previo,
            [payload.idIntento]: {
              idIntento: payload.idIntento,
              idEstudiante: payload.idEstudiante ?? actual?.idEstudiante,
              preguntasRespondidas: payload.preguntasRespondidas,
              preguntasRespondidasIndices,
              indicePreguntaActual: payload.indicePreguntaActual ?? actual?.indicePreguntaActual,
              totalPreguntas,
              nombreCompleto: payload.nombreCompleto ?? actual?.nombreCompleto ?? obtenerNombreFallback(payload.idIntento),
              modoKioscoActivo: payload.modoKioscoActivo ?? actual?.modoKioscoActivo ?? true,
              eventosFraude: payload.eventosFraude ?? actual?.eventosFraude ?? 0,
              estadoIntento: payload.estadoIntento ?? actual?.estadoIntento ?? 'EN_PROGRESO',
              ultimaActualizacionMs: marcaTiempo,
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
            idEstudiante: undefined,
            preguntasRespondidas: 0,
            preguntasRespondidasIndices: [],
            indicePreguntaActual: undefined,
            totalPreguntas: 0,
            nombreCompleto: payload.nombreEstudiante ?? obtenerNombreFallback(payload.idIntento),
            modoKioscoActivo: false,
            eventosFraude: 0,
            estadoIntento: 'EN_PROGRESO',
            ultimaActualizacionMs: Date.now(),
          };

          return {
            ...previo,
            [payload.idIntento]: {
              ...base,
              eventosFraude: base.eventosFraude + 1,
              modoKioscoActivo: false,
              ultimaActualizacionMs: Date.now(),
            },
          };
        });
      });

      socketSesion.on(API.EVENTOS_SOCKET.SESION_FINALIZADA, () => {
        setSesionFinalizada(true);
      });

      setSocket(socketSesion);
    };

    void iniciar();
    return () => {
      cancelado = true;
      socketSesion?.disconnect();
      setSocket(null);
      setConexionActiva(false);
    };
  }, [idSesion]);

  useEffect(() => {
    const temporizador = globalThis.setInterval(() => {
      const ahora = Date.now();
      setProgresoEstudiantes((previo) => {
        const entradas = Object.entries(previo).filter(([, progreso]) => {
          return ahora - progreso.ultimaActualizacionMs <= UMBRAL_INACTIVIDAD_MONITOR_MS;
        });

        if (entradas.length === Object.keys(previo).length) {
          return previo;
        }

        return Object.fromEntries(entradas);
      });
    }, 5000);

    return () => {
      globalThis.clearInterval(temporizador);
    };
  }, []);

  const listaEstudiantes = useMemo(() => Object.values(progresoEstudiantes), [progresoEstudiantes]);

  return {
    socket,
    listaEstudiantes,
    alertasFraude,
    sesionFinalizada,
    conexionActiva,
  };
}
