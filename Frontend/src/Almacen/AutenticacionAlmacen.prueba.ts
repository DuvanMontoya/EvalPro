/**
 * @archivo   AutenticacionAlmacen.prueba.ts
 * @descripcion Comprueba login, refresh y cierre de sesión del store de autenticación.
 * @modulo    Almacen
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { RolUsuario, Usuario } from '@/Tipos';
import { useAutenticacionAlmacen } from '@/Almacen/AutenticacionAlmacen';
import * as AutenticacionServicio from '@/Servicios/Autenticacion.servicio';
import * as ApiCliente from '@/Servicios/ApiCliente';

vi.mock('@/Servicios/Autenticacion.servicio', async () => {
  return {
    iniciarSesion: vi.fn(),
    guardarRefreshEnCookie: vi.fn(),
    refrescarDesdeCookie: vi.fn(),
    cerrarSesion: vi.fn(),
    eliminarRefreshDeCookie: vi.fn(),
  };
});

vi.mock('@/Servicios/ApiCliente', async () => {
  let tokenActual: string | null = null;
  return {
    establecerTokenAcceso: vi.fn((token: string | null) => {
      tokenActual = token;
    }),
    obtenerTokenAcceso: vi.fn(() => tokenActual),
  };
});

const usuarioDocente: Usuario = {
  id: 'u-docente',
  nombre: 'Ana',
  apellidos: 'Docente',
  correo: 'ana@evalpro.com',
  rol: RolUsuario.DOCENTE,
  activo: true,
  fechaCreacion: '2026-03-02T00:00:00.000Z',
  fechaActualizacion: '2026-03-02T00:00:00.000Z',
};

const usuarioEstudiante: Usuario = {
  ...usuarioDocente,
  id: 'u-estudiante',
  correo: 'estudiante@evalpro.com',
  rol: RolUsuario.ESTUDIANTE,
};

describe('AutenticacionAlmacen', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    useAutenticacionAlmacen.setState({
      usuario: null,
      estaAutenticado: false,
      cargando: false,
    });
  });

  it('inicia sesión y guarda usuario para rol permitido', async () => {
    vi.mocked(AutenticacionServicio.iniciarSesion).mockResolvedValue({
      tokenAcceso: 'token-acceso',
      tokenRefresh: 'token-refresh',
      usuario: usuarioDocente,
    });

    await useAutenticacionAlmacen.getState().iniciarSesion({
      correo: 'ana@evalpro.com',
      contrasena: 'ContrasenaSegura123!',
    });

    const estado = useAutenticacionAlmacen.getState();
    expect(estado.estaAutenticado).toBe(true);
    expect(estado.usuario?.rol).toBe(RolUsuario.DOCENTE);
    expect(vi.mocked(AutenticacionServicio.guardarRefreshEnCookie)).toHaveBeenCalledWith('token-refresh');
    expect(vi.mocked(ApiCliente.establecerTokenAcceso)).toHaveBeenCalledWith('token-acceso');
  });

  it('bloquea sesión de estudiante para el panel web', async () => {
    vi.mocked(AutenticacionServicio.iniciarSesion).mockResolvedValue({
      tokenAcceso: 'token-estudiante',
      tokenRefresh: 'refresh-estudiante',
      usuario: usuarioEstudiante,
    });

    await expect(
      useAutenticacionAlmacen.getState().iniciarSesion({
        correo: 'estudiante@evalpro.com',
        contrasena: 'ContrasenaSegura123!',
      }),
    ).rejects.toThrow('El rol estudiante no puede acceder al panel administrativo.');

    const estado = useAutenticacionAlmacen.getState();
    expect(estado.estaAutenticado).toBe(false);
    expect(estado.usuario).toBeNull();
  });

  it('refresca sesión desde cookie cuando no hay token en memoria', async () => {
    vi.mocked(AutenticacionServicio.refrescarDesdeCookie).mockResolvedValue({
      tokenAcceso: 'token-nuevo',
      usuario: usuarioDocente,
    });

    await useAutenticacionAlmacen.getState().verificarSesion();

    expect(vi.mocked(ApiCliente.establecerTokenAcceso)).toHaveBeenCalledWith('token-nuevo');
    expect(useAutenticacionAlmacen.getState().estaAutenticado).toBe(true);
  });
});
