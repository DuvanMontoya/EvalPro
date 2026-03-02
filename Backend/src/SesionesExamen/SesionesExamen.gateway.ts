/**
 * @archivo   SesionesExamen.gateway.ts
 * @descripcion Gestiona comunicación WebSocket en tiempo real para sesiones de examen.
 * @modulo    SesionesExamen
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import {
  ConnectedSocket,
  MessageBody,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Injectable } from '@nestjs/common';
import { PrismaService } from '../Configuracion/BaseDatos.config';
import {
  ESPACIO_NOMBRES_SESIONES,
  EVENTO_ALERTA_FRAUDE,
  EVENTO_ESTUDIANTE_FRAUDE,
  EVENTO_ESTUDIANTE_PROGRESO,
  EVENTO_PROGRESO_ACTUALIZADO,
  EVENTO_SESION_ACTIVADA,
  EVENTO_SESION_FINALIZADA,
  EVENTO_UNIRSE_SALA,
} from '../Comun/Constantes/Eventos.constantes';

interface UnionSalaPayload {
  idSesion: string;
  rol: string;
}

interface ProgresoPayload {
  idIntento: string;
  preguntasRespondidas: number;
}

interface FraudePayload {
  idIntento: string;
  tipoEvento: string;
}

@Injectable()
@WebSocketGateway({ namespace: ESPACIO_NOMBRES_SESIONES, cors: { origin: '*' } })
export class SesionesExamenGateway {
  @WebSocketServer()
  servidor!: Server;

  constructor(private readonly prisma: PrismaService) {}

  /**
   * Une un socket a la sala de la sesión indicada.
   * @param payload - Datos con id de sesión y rol.
   * @param cliente - Socket del cliente conectado.
   */
  @SubscribeMessage(EVENTO_UNIRSE_SALA)
  async manejarUnionSala(@MessageBody() payload: UnionSalaPayload, @ConnectedSocket() cliente: Socket): Promise<void> {
    await cliente.join(this.obtenerNombreSala(payload.idSesion));
  }

  /**
   * Redistribuye progreso de un intento hacia la sala de la sesión correspondiente.
   * @param payload - ID del intento y conteo de respuestas.
   */
  @SubscribeMessage(EVENTO_PROGRESO_ACTUALIZADO)
  async manejarProgreso(@MessageBody() payload: ProgresoPayload): Promise<void> {
    const intento = await this.prisma.intentoExamen.findUnique({ where: { id: payload.idIntento } });
    if (!intento) {
      return;
    }

    this.servidor.to(this.obtenerNombreSala(intento.sesionId)).emit(EVENTO_ESTUDIANTE_PROGRESO, payload);
  }

  /**
   * Redistribuye alertas de fraude de un intento hacia su sala.
   * @param payload - Datos del intento y tipo de evento.
   */
  @SubscribeMessage(EVENTO_ALERTA_FRAUDE)
  async manejarAlertaFraude(@MessageBody() payload: FraudePayload): Promise<void> {
    const intento = await this.prisma.intentoExamen.findUnique({ where: { id: payload.idIntento } });
    if (!intento) {
      return;
    }

    this.servidor.to(this.obtenerNombreSala(intento.sesionId)).emit(EVENTO_ESTUDIANTE_FRAUDE, payload);
  }

  /**
   * Emite que una sesión fue activada a todos los clientes de su sala.
   * @param idSesion - UUID de la sesión.
   */
  emitirSesionActivada(idSesion: string): void {
    this.servidor.to(this.obtenerNombreSala(idSesion)).emit(EVENTO_SESION_ACTIVADA, { idSesion });
  }

  /**
   * Emite que una sesión fue finalizada a todos los clientes de su sala.
   * @param idSesion - UUID de la sesión.
   */
  emitirSesionFinalizada(idSesion: string): void {
    this.servidor.to(this.obtenerNombreSala(idSesion)).emit(EVENTO_SESION_FINALIZADA, { idSesion });
  }

  /**
   * Emite un evento de fraude para una sala de sesión.
   * @param idSesion - UUID de sesión destino.
   * @param payload - Datos de fraude a notificar.
   */
  emitirFraude(idSesion: string, payload: FraudePayload): void {
    this.servidor.to(this.obtenerNombreSala(idSesion)).emit(EVENTO_ESTUDIANTE_FRAUDE, payload);
  }

  /**
   * Construye el nombre de sala para una sesión específica.
   * @param idSesion - UUID de sesión.
   */
  private obtenerNombreSala(idSesion: string): string {
    return `sesion_${idSesion}`;
  }
}
