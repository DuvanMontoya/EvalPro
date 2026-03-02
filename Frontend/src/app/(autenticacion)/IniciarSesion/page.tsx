/**
 * @archivo   page.tsx
 * @descripcion Muestra formulario de inicio de sesión con validación y flujo de primer login.
 * @modulo    Autenticacion
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { LockKeyhole, ShieldCheck } from 'lucide-react';
import { toast } from 'sonner';
import {
  esquemaIniciarSesion,
  IniciarSesionFormulario,
  esquemaCambiarContrasenaPrimerLogin,
  CambiarContrasenaPrimerLoginFormulario,
} from '@/Lib/validaciones';
import { useAutenticacion } from '@/Hooks/useAutenticacion';
import { RUTAS } from '@/Constantes/Rutas.constantes';
import { Entrada } from '@/Componentes/Ui/Entrada';
import { Etiqueta } from '@/Componentes/Ui/Etiqueta';
import { Boton } from '@/Componentes/Ui/Boton';
import { obtenerMensajeError } from '@/Lib/ErroresApi';

/**
 * Renderiza la página de acceso del panel administrativo.
 */
export default function PaginaIniciarSesion() {
  const router = useRouter();
  const {
    iniciarSesion,
    completarPrimerLogin,
    cerrarSesion,
    requiereCambioContrasena,
    estaAutenticado,
    cargando,
  } = useAutenticacion();

  const formularioLogin = useForm<IniciarSesionFormulario>({
    resolver: zodResolver(esquemaIniciarSesion),
    defaultValues: { correo: '', contrasena: '' },
  });

  const formularioCambio = useForm<CambiarContrasenaPrimerLoginFormulario>({
    resolver: zodResolver(esquemaCambiarContrasenaPrimerLogin),
    defaultValues: { nuevaContrasena: '', confirmarContrasena: '' },
  });

  useEffect(() => {
    if (estaAutenticado) {
      router.replace(RUTAS.TABLERO);
    }
  }, [estaAutenticado, router]);

  const enviarLogin = async (valores: IniciarSesionFormulario) => {
    try {
      const resultado = await iniciarSesion(valores);
      if (resultado === 'PRIMER_LOGIN') {
        toast.info('Debes cambiar la contraseña temporal para continuar.');
        formularioCambio.reset();
        return;
      }

      toast.success('Sesión iniciada correctamente.');
      router.push(RUTAS.TABLERO);
    } catch (error) {
      toast.error(
        obtenerMensajeError(error, 'Credenciales inválidas. Verifica tu correo y contraseña.'),
      );
    }
  };

  const enviarCambioContrasena = async (valores: CambiarContrasenaPrimerLoginFormulario) => {
    try {
      await completarPrimerLogin(valores.nuevaContrasena);
      toast.success('Contraseña actualizada y sesión iniciada.');
      router.push(RUTAS.TABLERO);
    } catch (error) {
      toast.error(
        obtenerMensajeError(
          error,
          'No fue posible completar la activación. Inicia sesión de nuevo e inténtalo otra vez.',
        ),
      );
    }
  };

  if (requiereCambioContrasena) {
    return (
      <div className="space-y-6">
        <div className="space-y-2 text-center">
          <div className="mx-auto flex h-11 w-11 items-center justify-center rounded-full border border-[var(--acento-primario-borde)] bg-[var(--acento-primario-sutil)]">
            <LockKeyhole className="h-5 w-5 text-[var(--acento-primario-hover)]" strokeWidth={1.8} />
          </div>
          <h1 className="text-2xl font-bold">Activar cuenta</h1>
          <p className="texto-muted">
            Detectamos inicio con credencial temporal. Define una contraseña definitiva.
          </p>
        </div>

        <form className="space-y-4" onSubmit={formularioCambio.handleSubmit(enviarCambioContrasena)}>
          <div className="space-y-2">
            <Etiqueta htmlFor="nuevaContrasena">Nueva contraseña</Etiqueta>
            <Entrada id="nuevaContrasena" type="password" {...formularioCambio.register('nuevaContrasena')} />
            {formularioCambio.formState.errors.nuevaContrasena ? (
              <p className="text-sm text-[var(--estado-peligro)]">
                {formularioCambio.formState.errors.nuevaContrasena.message}
              </p>
            ) : (
              <p className="text-xs text-[var(--texto-secundario)]">
                Mínimo 8 caracteres con mayúscula, minúscula, número y símbolo.
              </p>
            )}
          </div>

          <div className="space-y-2">
            <Etiqueta htmlFor="confirmarContrasena">Confirmar contraseña</Etiqueta>
            <Entrada
              id="confirmarContrasena"
              type="password"
              {...formularioCambio.register('confirmarContrasena')}
            />
            {formularioCambio.formState.errors.confirmarContrasena ? (
              <p className="text-sm text-[var(--estado-peligro)]">
                {formularioCambio.formState.errors.confirmarContrasena.message}
              </p>
            ) : null}
          </div>

          <div className="grid grid-cols-1 gap-2 sm:grid-cols-2">
            <Boton
              className="w-full"
              type="submit"
              disabled={cargando || formularioCambio.formState.isSubmitting}
            >
              {cargando || formularioCambio.formState.isSubmitting ? 'Activando...' : 'Guardar y continuar'}
            </Boton>
            <Boton
              className="w-full"
              type="button"
              variante="contorno"
              onClick={() => {
                cerrarSesion().catch(() => undefined);
                formularioLogin.reset();
                formularioCambio.reset();
              }}
            >
              Cancelar
            </Boton>
          </div>
        </form>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="space-y-2 text-center">
        <div className="mx-auto flex h-11 w-11 items-center justify-center rounded-full border border-[var(--estado-exito-borde)] bg-[var(--estado-exito-sutil)]">
          <ShieldCheck className="h-5 w-5 text-[var(--estado-exito)]" strokeWidth={1.8} />
        </div>
        <h1 className="text-2xl font-bold">Iniciar sesión</h1>
        <p className="texto-muted">Accede al panel administrativo de EvalPro.</p>
      </div>

      <form className="space-y-4" onSubmit={formularioLogin.handleSubmit(enviarLogin)}>
        <div className="space-y-2">
          <Etiqueta htmlFor="correo">Correo</Etiqueta>
          <Entrada id="correo" type="email" {...formularioLogin.register('correo')} />
          {formularioLogin.formState.errors.correo ? (
            <p className="text-sm text-[var(--estado-peligro)]">
              {formularioLogin.formState.errors.correo.message}
            </p>
          ) : null}
        </div>

        <div className="space-y-2">
          <Etiqueta htmlFor="contrasena">Contraseña</Etiqueta>
          <Entrada id="contrasena" type="password" {...formularioLogin.register('contrasena')} />
          {formularioLogin.formState.errors.contrasena ? (
            <p className="text-sm text-[var(--estado-peligro)]">
              {formularioLogin.formState.errors.contrasena.message}
            </p>
          ) : null}
        </div>

        <Boton className="w-full" type="submit" disabled={cargando || formularioLogin.formState.isSubmitting}>
          {cargando || formularioLogin.formState.isSubmitting ? 'Ingresando...' : 'Ingresar'}
        </Boton>
      </form>
    </div>
  );
}
