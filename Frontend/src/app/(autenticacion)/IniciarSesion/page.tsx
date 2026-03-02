/**
 * @archivo   page.tsx
 * @descripcion Muestra formulario de inicio de sesión con validación y redirección al tablero.
 * @modulo    Autenticacion
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { toast } from 'sonner';
import { esquemaIniciarSesion, IniciarSesionFormulario } from '@/Lib/validaciones';
import { useAutenticacion } from '@/Hooks/useAutenticacion';
import { RUTAS } from '@/Constantes/Rutas.constantes';
import { Entrada } from '@/Componentes/Ui/Entrada';
import { Etiqueta } from '@/Componentes/Ui/Etiqueta';
import { Boton } from '@/Componentes/Ui/Boton';

/**
 * Renderiza la página de acceso del panel administrativo.
 */
export default function PaginaIniciarSesion() {
  const router = useRouter();
  const { iniciarSesion, estaAutenticado, cargando } = useAutenticacion();

  const formulario = useForm<IniciarSesionFormulario>({
    resolver: zodResolver(esquemaIniciarSesion),
    defaultValues: { correo: '', contrasena: '' },
  });

  useEffect(() => {
    if (estaAutenticado) {
      router.replace(RUTAS.TABLERO);
    }
  }, [estaAutenticado, router]);

  const enviar = async (valores: IniciarSesionFormulario) => {
    try {
      await iniciarSesion(valores);
      toast.success('Sesión iniciada correctamente.');
      router.push(RUTAS.TABLERO);
    } catch {
      toast.error('Credenciales inválidas. Verifica tu correo y contraseña.');
    }
  };

  return (
    <div className="space-y-6">
      <div className="space-y-1 text-center">
        <h1 className="text-2xl font-bold">Iniciar sesión</h1>
        <p className="texto-muted">Accede al panel administrativo de EvalPro.</p>
      </div>

      <form className="space-y-4" onSubmit={formulario.handleSubmit(enviar)}>
        <div className="space-y-2">
          <Etiqueta htmlFor="correo">Correo</Etiqueta>
          <Entrada id="correo" type="email" {...formulario.register('correo')} />
          {formulario.formState.errors.correo ? (
            <p className="text-sm text-peligro">{formulario.formState.errors.correo.message}</p>
          ) : null}
        </div>

        <div className="space-y-2">
          <Etiqueta htmlFor="contrasena">Contraseña</Etiqueta>
          <Entrada id="contrasena" type="password" {...formulario.register('contrasena')} />
          {formulario.formState.errors.contrasena ? (
            <p className="text-sm text-peligro">{formulario.formState.errors.contrasena.message}</p>
          ) : null}
        </div>

        <Boton className="w-full" type="submit" disabled={cargando || formulario.formState.isSubmitting}>
          {cargando || formulario.formState.isSubmitting ? 'Ingresando...' : 'Ingresar'}
        </Boton>
      </form>
    </div>
  );
}
