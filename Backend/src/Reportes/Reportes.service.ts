/**
 * @archivo   Reportes.service.ts
 * @descripcion Construye reportes agregados por sesión y por estudiante para análisis docente.
 * @modulo    Reportes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { EstadoIntento, RolUsuario } from '@prisma/client';
import { PrismaService } from '../Configuracion/BaseDatos.config';

@Injectable()
export class ReportesService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Obtiene el reporte completo de una sesión con métricas de rendimiento y riesgo.
   * @param idSesion - UUID de la sesión.
   * @param rol - Rol del solicitante.
   * @param idUsuario - UUID del solicitante.
   */
  async obtenerReporteSesion(idSesion: string, rol: RolUsuario, idUsuario: string) {
    const sesion = await this.prisma.sesionExamen.findUnique({
      where: { id: idSesion },
      include: {
        examen: { include: { preguntas: true } },
        intentos: {
          include: {
            estudiante: true,
            respuestas: true,
          },
        },
      },
    });

    if (!sesion) {
      throw new NotFoundException('Sesión no encontrada');
    }

    if (rol === RolUsuario.DOCENTE && sesion.creadaPorId !== idUsuario) {
      throw new ForbiddenException('No tiene permisos sobre esta sesión');
    }

    const totalEstudiantes = sesion.intentos.length;
    const intentosEnviados = sesion.intentos.filter((intento) => intento.estado === EstadoIntento.ENVIADO);
    const estudiantesQueEnviaron = intentosEnviados.length;
    const estudiantesSospechosos = sesion.intentos.filter((intento) => intento.esSospechoso).length;

    const puntajes = intentosEnviados
      .map((intento) => intento.porcentaje)
      .filter((valor): valor is number => typeof valor === 'number');

    const puntajePromedio = puntajes.length > 0 ? Number((puntajes.reduce((a, b) => a + b, 0) / puntajes.length).toFixed(2)) : null;
    const puntajeMaximo = puntajes.length > 0 ? Math.max(...puntajes) : null;
    const puntajeMinimo = puntajes.length > 0 ? Math.min(...puntajes) : null;

    const distribucionPuntajes = this.calcularDistribucion(puntajes);
    const dificultadPorPregunta = this.calcularDificultad(sesion.examen.preguntas, intentosEnviados);

    return {
      sesion: {
        id: sesion.id,
        codigoAcceso: sesion.codigoAcceso,
        estado: sesion.estado,
        fechaInicio: sesion.fechaInicio,
        fechaFin: sesion.fechaFin,
      },
      totalEstudiantes,
      estudiantesQueEnviaron,
      estudiantesSospechosos,
      puntajePromedio,
      puntajeMaximo,
      puntajeMinimo,
      distribucionPuntajes,
      dificultadPorPregunta,
      listaEstudiantes: sesion.intentos.map((intento) => ({
        nombre: intento.estudiante.nombre,
        apellidos: intento.estudiante.apellidos,
        puntaje: intento.puntajeObtenido,
        porcentaje: intento.porcentaje,
        estado: intento.estado,
        esSospechoso: intento.esSospechoso,
      })),
    };
  }

  /**
   * Retorna historial consolidado de intentos para un estudiante.
   * @param idEstudiante - UUID del estudiante objetivo.
   * @param rol - Rol del solicitante.
   * @param idUsuario - UUID del solicitante.
   */
  async obtenerReporteEstudiante(idEstudiante: string, rol: RolUsuario, idUsuario: string) {
    if (rol === RolUsuario.ESTUDIANTE && idEstudiante !== idUsuario) {
      throw new ForbiddenException('No tiene permisos para consultar este reporte');
    }

    const estudiante = await this.prisma.usuario.findUnique({
      where: { id: idEstudiante },
      include: {
        intentos: {
          include: { sesion: { include: { examen: true } } },
          orderBy: { fechaInicio: 'desc' },
        },
      },
    });

    if (!estudiante) {
      throw new NotFoundException('Estudiante no encontrado');
    }

    const intentosFiltrados =
      rol === RolUsuario.DOCENTE
        ? estudiante.intentos.filter((intento) => intento.sesion.creadaPorId === idUsuario)
        : estudiante.intentos;

    if (rol === RolUsuario.DOCENTE && intentosFiltrados.length === 0) {
      throw new ForbiddenException('No tiene permisos para consultar este estudiante');
    }

    return {
      idEstudiante: estudiante.id,
      nombreCompleto: `${estudiante.nombre} ${estudiante.apellidos}`,
      intentos: intentosFiltrados.map((intento) => ({
        idSesion: intento.sesionId,
        codigoAcceso: intento.sesion.codigoAcceso,
        tituloExamen: intento.sesion.examen.titulo,
        estado: intento.estado,
        puntajeObtenido: intento.puntajeObtenido,
        porcentaje: intento.porcentaje,
        esSospechoso: intento.esSospechoso,
      })),
    };
  }

  /**
   * Calcula distribución de puntajes por rangos porcentuales.
   * @param puntajes - Lista de porcentajes enviados.
   */
  private calcularDistribucion(puntajes: number[]): { rango: string; cantidad: number }[] {
    const rangos = [
      { rango: '0-20', minimo: 0, maximo: 20, cantidad: 0 },
      { rango: '21-40', minimo: 21, maximo: 40, cantidad: 0 },
      { rango: '41-60', minimo: 41, maximo: 60, cantidad: 0 },
      { rango: '61-80', minimo: 61, maximo: 80, cantidad: 0 },
      { rango: '81-100', minimo: 81, maximo: 100, cantidad: 0 },
    ];

    for (const puntaje of puntajes) {
      const rango = rangos.find((item) => puntaje >= item.minimo && puntaje <= item.maximo);
      if (rango) {
        rango.cantidad += 1;
      }
    }

    return rangos.map(({ rango, cantidad }) => ({ rango, cantidad }));
  }

  /**
   * Calcula porcentaje de acierto por pregunta con base en intentos enviados.
   * @param preguntas - Preguntas del examen.
   * @param intentos - Intentos enviados de la sesión.
   */
  private calcularDificultad(
    preguntas: { id: string; enunciado: string }[],
    intentos: { respuestas: { preguntaId: string; esCorrecta: boolean | null }[] }[],
  ) {
    const total = intentos.length;

    return preguntas.map((pregunta) => {
      const aciertos = intentos.filter((intento) =>
        intento.respuestas.some((respuesta) => respuesta.preguntaId === pregunta.id && respuesta.esCorrecta === true),
      ).length;

      return {
        idPregunta: pregunta.id,
        enunciado: pregunta.enunciado.slice(0, 80),
        porcentajeAcierto: total > 0 ? Number(((aciertos / total) * 100).toFixed(2)) : 0,
      };
    });
  }
}
