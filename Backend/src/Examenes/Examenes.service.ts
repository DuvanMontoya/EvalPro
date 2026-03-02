/**
 * @archivo   Examenes.service.ts
 * @descripcion Gestiona creación, edición, publicación y consulta de exámenes.
 * @modulo    Examenes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
  UnprocessableEntityException,
} from '@nestjs/common';
import { EstadoExamen, RolUsuario, TipoPregunta } from '@prisma/client';
import { PrismaService } from '../Configuracion/BaseDatos.config';
import { CODIGOS_ERROR } from '../Comun/Constantes/Mensajes.constantes';
import { CrearExamenDto } from './Dto/CrearExamen.dto';
import { ActualizarExamenDto } from './Dto/ActualizarExamen.dto';

const LIMITE_SEMILLA_ALEATORIZACION = 999999;

@Injectable()
export class ExamenesService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Crea un examen para el docente autenticado generando semilla de aleatorización.
   * @param dto - Datos del examen.
   * @param idDocente - UUID del docente creador.
   * @returns Examen creado en base de datos.
   */
  async crear(dto: CrearExamenDto, idDocente: string, idInstitucion: string | null) {
    const semillaAleatorizacion = Math.floor(Math.random() * LIMITE_SEMILLA_ALEATORIZACION) + 1;
    return this.prisma.examen.create({
      data: {
        ...dto,
        creadoPorId: idDocente,
        idInstitucion,
        semillaAleatorizacion,
      },
    });
  }

  /**
   * Lista exámenes según rol del usuario autenticado.
   * @param rol - Rol del usuario actual.
   * @param idUsuario - UUID del usuario autenticado.
   * @returns Exámenes visibles para el rol.
   */
  async listar(rol: RolUsuario, idUsuario: string, idInstitucion: string | null) {
    const where: Record<string, unknown> = {};
    if (rol !== RolUsuario.SUPERADMINISTRADOR) {
      where.idInstitucion = idInstitucion;
    }
    if (rol === RolUsuario.DOCENTE) {
      where.creadoPorId = idUsuario;
    }
    return this.prisma.examen.findMany({ where, orderBy: { fechaCreacion: 'desc' } });
  }

  /**
   * Obtiene un examen validando propiedad para roles docentes.
   * @param idExamen - UUID del examen.
   * @param rol - Rol del usuario autenticado.
   * @param idUsuario - UUID del usuario autenticado.
   */
  async obtenerPorId(idExamen: string, rol: RolUsuario, idUsuario: string, idInstitucion: string | null) {
    const examen = await this.prisma.examen.findUnique({ where: { id: idExamen }, include: { preguntas: true } });
    if (!examen) {
      throw new NotFoundException('Examen no encontrado');
    }

    if (rol !== RolUsuario.SUPERADMINISTRADOR && examen.idInstitucion !== idInstitucion) {
      throw new ForbiddenException('No puede consultar recursos de otra institución');
    }

    if (rol === RolUsuario.DOCENTE && examen.creadoPorId !== idUsuario) {
      throw new ForbiddenException('No tiene permisos sobre este examen');
    }

    return examen;
  }

  /**
   * Actualiza examen en estado BORRADOR y propiedad del docente.
   * @param idExamen - UUID del examen.
   * @param dto - Datos parciales de actualización.
   * @param idDocente - UUID del docente.
   */
  async actualizar(idExamen: string, dto: ActualizarExamenDto, idDocente: string, idInstitucion: string | null) {
    const examen = await this.prisma.examen.findUnique({ where: { id: idExamen } });
    if (!examen) {
      throw new NotFoundException('Examen no encontrado');
    }

    if (examen.idInstitucion !== idInstitucion) {
      throw new ForbiddenException('No puede actualizar exámenes fuera de su institución');
    }

    if (examen.creadoPorId !== idDocente) {
      throw new ForbiddenException('No tiene permisos sobre este examen');
    }

    if (examen.estado !== EstadoExamen.BORRADOR) {
      throw new BadRequestException('Solo se pueden editar exámenes en borrador');
    }

    return this.prisma.examen.update({ where: { id: idExamen }, data: dto });
  }

  /**
   * Archiva un examen del docente sin eliminarlo físicamente.
   * @param idExamen - UUID del examen.
   * @param idDocente - UUID del docente.
   */
  async archivar(idExamen: string, idDocente: string, idInstitucion: string | null) {
    await this.obtenerPorId(idExamen, RolUsuario.DOCENTE, idDocente, idInstitucion);
    return this.prisma.examen.update({ where: { id: idExamen }, data: { estado: EstadoExamen.ARCHIVADO } });
  }

  /**
   * Publica un examen siguiendo validaciones exactas de estado, propiedad y preguntas.
   * @param idExamen - UUID del examen.
   * @param idDocente - UUID del docente.
   */
  async publicar(idExamen: string, idDocente: string, idInstitucion: string | null) {
    const examen = await this.prisma.examen.findUnique({
      where: { id: idExamen },
      include: { preguntas: { include: { opciones: true }, orderBy: { orden: 'asc' } } },
    });
    if (!examen) {
      throw new NotFoundException('Examen no encontrado');
    }

    if (examen.idInstitucion !== idInstitucion) {
      throw new ForbiddenException('No puede publicar exámenes fuera de su institución');
    }

    if (examen.creadoPorId !== idDocente) {
      throw new ForbiddenException('No tiene permisos sobre este examen');
    }

    if (examen.estado !== EstadoExamen.BORRADOR) {
      throw new BadRequestException('El examen no está en estado borrador');
    }

    const preguntasActivas = examen.preguntas.filter((pregunta) => pregunta.activo);
    if (preguntasActivas.length === 0) {
      throw new UnprocessableEntityException({
        mensaje: 'No se puede publicar un examen sin preguntas',
        codigoError: CODIGOS_ERROR.EXAMEN_SIN_PREGUNTAS,
      });
    }

    for (const pregunta of preguntasActivas) {
      const tipo = pregunta.tipo;
      const opciones = pregunta.opciones;
      const cantidadCorrectas = opciones.filter((opcion) => opcion.esCorrecta).length;

      if (tipo === TipoPregunta.ABIERTA || tipo === TipoPregunta.RESPUESTA_ABIERTA) {
        if (opciones.length > 0) {
          throw new UnprocessableEntityException('Las preguntas abiertas no pueden contener opciones de respuesta');
        }
        continue;
      }

      if (opciones.length < 2) {
        throw new UnprocessableEntityException('Cada pregunta cerrada debe tener al menos dos opciones');
      }

      if (tipo === TipoPregunta.OPCION_MULTIPLE && cantidadCorrectas !== 1) {
        throw new UnprocessableEntityException('La pregunta de opción múltiple debe tener exactamente una opción correcta');
      }

      if (tipo === TipoPregunta.VERDADERO_FALSO && (opciones.length !== 2 || cantidadCorrectas !== 1)) {
        throw new UnprocessableEntityException(
          'La pregunta verdadero/falso debe tener exactamente dos opciones y una correcta',
        );
      }

      if (tipo === TipoPregunta.SELECCION_MULTIPLE && cantidadCorrectas < 1) {
        throw new UnprocessableEntityException('La pregunta de selección múltiple debe tener al menos una opción correcta');
      }
    }

    const puntajeMaximo = preguntasActivas.reduce((suma, pregunta) => suma + pregunta.puntaje, 0);
    return this.prisma.examen.update({
      where: { id: idExamen },
      data: {
        estado: EstadoExamen.PUBLICADO,
        puntajeMaximo,
        puntajeMaximoDefinido: puntajeMaximo,
        totalPreguntas: preguntasActivas.length,
      },
    });
  }

  /**
   * Obtiene examen para estudiante ocultando el campo esCorrecta en opciones.
   * @param idExamen - UUID del examen.
   * @returns Examen con preguntas y opciones sanitizadas.
   */
  async obtenerParaEstudiante(idExamen: string) {
    const examen = await this.prisma.examen.findUnique({
      where: { id: idExamen },
      include: { preguntas: { include: { opciones: true }, orderBy: { orden: 'asc' } } },
    });

    if (!examen) {
      throw new NotFoundException('Examen no encontrado');
    }

    return {
      ...examen,
      preguntas: examen.preguntas.map((pregunta) => ({
        ...pregunta,
        opciones: pregunta.opciones.map(({ esCorrecta: _esCorrecta, ...opcion }) => opcion),
      })),
    };
  }
}
