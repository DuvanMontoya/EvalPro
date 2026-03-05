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
  OnGatewayConnection,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
  WsException,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Injectable, Logger } from '@nestjs/common';
import { RolUsuario } from '@prisma/client';
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
import { AutorizacionSocketSesionesService, UsuarioSocket } from './AutorizacionSocketSesiones.service';

const ORIGENES_SOCKET = (process.env.CORS_ORIGENES_PERMITIDOS ?? 'http://localhost:3000')
  .split(',')
  .map((origen) => origen.trim())
  .filter((origen) => origen.length > 0);

interface UnionSalaPayload {
  idSesion: string;
}

interface ProgresoPayload {
  idIntento: string;
  preguntasRespondidas: number;
  totalPreguntas?: number;
  nombreCompleto?: string;
  modoKioscoActivo?: boolean;
  eventosFraude?: number;
  estadoIntento?: string;
}

interface FraudePayload {
  idIntento: string;
  tipoEvento: string;
}

interface SocketAutenticado extends Socket {
  data: {
    usuario?: UsuarioSocket;
  };
}

@Injectable()
@WebSocketGateway({
  namespace: ESPACIO_NOMBRES_SESIONES,
  cors: { origin: ORIGENES_SOCKET, credentials: true },
})
export class SesionesExamenGateway implements OnGatewayConnection {
  private readonly logger = new Logger(SesionesExamenGateway.name);

  @WebSocketServer()
  servidor!: Server;

  constructor(private readonly autorizacionSocketService: AutorizacionSocketSesionesService) {}

  /**
   * Autentica el socket por JWT de acceso durante el handshake inicial.
   * @param cliente - Socket recién conectado.
   */
  async handleConnection(cliente: SocketAutenticado): Promise<void> {
    const usuario = await this.autorizacionSocketService.autenticarCliente(cliente);
    if (!usuario) {
      cliente.disconnect(true);
      return;
    }

    cliente.data.usuario = usuario;
  }

  /**
   * Une un socket a la sala de la sesión indicada.
   * @param payload - Datos con id de sesión y rol.
   * @param cliente - Socket del cliente conectado.
   */
  @SubscribeMessage(EVENTO_UNIRSE_SALA)
  async manejarUnionSala(
    @MessageBody() payload: UnionSalaPayload,
    @ConnectedSocket() cliente: SocketAutenticado,
  ): Promise<void> {
    const usuario = await this.obtenerUsuarioSocket(cliente);
    const permitido = await this.autorizacionSocketService.puedeUnirseASesion(payload.idSesion, usuario);
    if (!permitido) {
      throw new WsException('No tiene permisos para unirse a esta sesión');
    }
    await cliente.join(this.obtenerNombreSala(payload.idSesion));

    // Bootstrap de presencia para que el monitor docente vea al estudiante desde el ingreso.
    if (usuario.rol === RolUsuario.ESTUDIANTE) {
      const intentoActivo = await this.autorizacionSocketService.obtenerIntentoActivoSesionEstudiante(
        payload.idSesion,
        usuario.id,
      );
      if (intentoActivo) {
        this.servidor.to(this.obtenerNombreSala(payload.idSesion)).emit(EVENTO_ESTUDIANTE_PROGRESO, {
          idIntento: intentoActivo.idIntento,
          preguntasRespondidas: 0,
          totalPreguntas: 0,
          nombreCompleto: intentoActivo.nombreCompleto,
          modoKioscoActivo: true,
          eventosFraude: 0,
          estadoIntento: 'EN_PROGRESO',
        });
      } else {
        this.logger.warn(
          `Estudiante ${usuario.id} se unió a sesión ${payload.idSesion} sin intento activo para bootstrap.`,
        );
      }
    }
  }

  /**
   * Redistribuye progreso de un intento hacia la sala de la sesión correspondiente.
   * @param payload - ID del intento y conteo de respuestas.
   */
  @SubscribeMessage(EVENTO_PROGRESO_ACTUALIZADO)
  async manejarProgreso(
    @MessageBody() payload: ProgresoPayload,
    @ConnectedSocket() cliente: SocketAutenticado,
  ): Promise<void> {
    const usuario = await this.obtenerUsuarioSocket(cliente);
    const idSesion = await this.autorizacionSocketService.obtenerSesionAutorizadaPorIntento(payload.idIntento, usuario);
    if (!idSesion) {
      throw new WsException('No tiene permisos sobre este intento');
    }
    this.servidor.to(this.obtenerNombreSala(idSesion)).emit(EVENTO_ESTUDIANTE_PROGRESO, payload);
  }

  /**
   * Redistribuye alertas de fraude de un intento hacia su sala.
   * @param payload - Datos del intento y tipo de evento.
   */
  @SubscribeMessage(EVENTO_ALERTA_FRAUDE)
  async manejarAlertaFraude(
    @MessageBody() payload: FraudePayload,
    @ConnectedSocket() cliente: SocketAutenticado,
  ): Promise<void> {
    const usuario = await this.obtenerUsuarioSocket(cliente);
    const idSesion = await this.autorizacionSocketService.obtenerSesionAutorizadaPorIntento(payload.idIntento, usuario);
    if (!idSesion) {
      throw new WsException('No tiene permisos sobre este intento');
    }
    this.servidor.to(this.obtenerNombreSala(idSesion)).emit(EVENTO_ESTUDIANTE_FRAUDE, payload);
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
   * Emite progreso de intento hacia la sala de la sesión indicada.
   * @param idSesion - UUID de sesión destino.
   * @param payload - Datos de progreso del intento.
   */
  emitirProgreso(idSesion: string, payload: ProgresoPayload): void {
    this.servidor.to(this.obtenerNombreSala(idSesion)).emit(EVENTO_ESTUDIANTE_PROGRESO, payload);
  }

  /**
   * Construye el nombre de sala para una sesión específica.
   * @param idSesion - UUID de sesión.
   */
  private obtenerNombreSala(idSesion: string): string {
    return `sesion_${idSesion}`;
  }

  private async obtenerUsuarioSocket(cliente: SocketAutenticado): Promise<UsuarioSocket> {
    if (cliente.data.usuario) {
      return cliente.data.usuario;
    }

    const usuario = await this.autorizacionSocketService.autenticarCliente(cliente);
    if (!usuario) {
      throw new WsException('Socket no autenticado');
    }

    cliente.data.usuario = usuario;
    return usuario;
  }
}
