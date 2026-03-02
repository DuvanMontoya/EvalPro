/**
 * @archivo   Permisos.prueba.ts
 * @descripcion Valida la matriz de permisos por rol y estados de examen/sesión.
 * @modulo    Lib
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { describe, expect, it } from 'vitest';
import { EstadoExamen, EstadoSesion, RolUsuario } from '@/Tipos';
import {
  puedeActivarSesion,
  puedeArchivarExamen,
  puedeEditarContenidoExamen,
  puedeFinalizarSesion,
  puedePublicarExamen,
  rolPuedeAccederPanel,
  rolPuedeCrearEstudiantes,
  rolPuedeGestionarExamenes,
  rolPuedeGestionarSesiones,
} from '@/Lib/Permisos';

describe('Permisos de panel', () => {
  it('permite acceso solo a docente y administrador', () => {
    expect(rolPuedeAccederPanel(RolUsuario.ADMINISTRADOR)).toBe(true);
    expect(rolPuedeAccederPanel(RolUsuario.DOCENTE)).toBe(true);
    expect(rolPuedeAccederPanel(RolUsuario.ESTUDIANTE)).toBe(false);
  });

  it('restringe gestión de exámenes y sesiones a docente', () => {
    expect(rolPuedeGestionarExamenes(RolUsuario.DOCENTE)).toBe(true);
    expect(rolPuedeGestionarExamenes(RolUsuario.ADMINISTRADOR)).toBe(false);
    expect(rolPuedeGestionarSesiones(RolUsuario.DOCENTE)).toBe(true);
    expect(rolPuedeGestionarSesiones(RolUsuario.ADMINISTRADOR)).toBe(false);
  });

  it('permite crear estudiantes solo a administrador', () => {
    expect(rolPuedeCrearEstudiantes(RolUsuario.ADMINISTRADOR)).toBe(true);
    expect(rolPuedeCrearEstudiantes(RolUsuario.DOCENTE)).toBe(false);
  });

  it('habilita edición/publicación solo en examen borrador', () => {
    expect(puedeEditarContenidoExamen(RolUsuario.DOCENTE, EstadoExamen.BORRADOR)).toBe(true);
    expect(puedeEditarContenidoExamen(RolUsuario.DOCENTE, EstadoExamen.PUBLICADO)).toBe(false);
    expect(puedePublicarExamen(RolUsuario.DOCENTE, EstadoExamen.BORRADOR)).toBe(true);
    expect(puedePublicarExamen(RolUsuario.DOCENTE, EstadoExamen.ARCHIVADO)).toBe(false);
    expect(puedeArchivarExamen(RolUsuario.DOCENTE, EstadoExamen.PUBLICADO)).toBe(true);
    expect(puedeArchivarExamen(RolUsuario.DOCENTE, EstadoExamen.ARCHIVADO)).toBe(false);
  });

  it('activa/finaliza sesiones solo en estados válidos', () => {
    expect(puedeActivarSesion(RolUsuario.DOCENTE, EstadoSesion.PENDIENTE)).toBe(true);
    expect(puedeActivarSesion(RolUsuario.DOCENTE, EstadoSesion.ACTIVA)).toBe(false);
    expect(puedeFinalizarSesion(RolUsuario.DOCENTE, EstadoSesion.ACTIVA)).toBe(true);
    expect(puedeFinalizarSesion(RolUsuario.DOCENTE, EstadoSesion.FINALIZADA)).toBe(false);
  });
});
