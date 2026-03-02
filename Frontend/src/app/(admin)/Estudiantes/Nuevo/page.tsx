/**
 * @archivo   page.tsx
 * @descripcion Permite registrar usuarios académicos nuevos con rol docente o estudiante.
 * @modulo    Estudiantes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { useRouter } from 'next/navigation';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { toast } from 'sonner';
import { RolUsuario } from '@/Tipos';
import { esquemaCrearUsuarioAcademico, CrearUsuarioAcademicoFormulario } from '@/Lib/validaciones';
import { useAutenticacion } from '@/Hooks/useAutenticacion';
import { useEstudiantes } from '@/Hooks/useEstudiantes';
import { RUTAS } from '@/Constantes/Rutas.constantes';
import { EstadoVacio } from '@/Componentes/Comunes/EstadoVacio';
import { Tarjeta, TarjetaContenido, TarjetaEncabezado, TarjetaTitulo } from '@/Componentes/Ui/Tarjeta';
import { Etiqueta } from '@/Componentes/Ui/Etiqueta';
import { Entrada } from '@/Componentes/Ui/Entrada';
import { Boton } from '@/Componentes/Ui/Boton';
import {
  Seleccion,
  SeleccionContenido,
  SeleccionDisparador,
  SeleccionItem,
  SeleccionValor,
} from '@/Componentes/Ui/Seleccion';
import { obtenerMensajeError } from '@/Lib/ErroresApi';
import { rolPuedeCrearEstudiantes } from '@/Lib/Permisos';

/**
 * Renderiza formulario de alta de estudiante.
 */
export default function PaginaNuevoEstudiante() {
  const router = useRouter();
  const { usuario } = useAutenticacion();
  const { mutacionCrearUsuarioAcademico } = useEstudiantes();

  const formulario = useForm<CrearUsuarioAcademicoFormulario>({
    resolver: zodResolver(esquemaCrearUsuarioAcademico),
    defaultValues: {
      nombre: '',
      apellidos: '',
      correo: '',
      contrasena: '',
      rol: RolUsuario.ESTUDIANTE,
    },
  });

  const enviar = async (datos: CrearUsuarioAcademicoFormulario) => {
    try {
      await mutacionCrearUsuarioAcademico.mutateAsync(datos);
      toast.success(
        datos.rol === RolUsuario.DOCENTE
          ? 'Docente creado correctamente.'
          : 'Estudiante creado correctamente.',
      );
      router.push(RUTAS.ESTUDIANTES);
    } catch (error) {
      toast.error(obtenerMensajeError(error, 'No se pudo crear el usuario.'));
    }
  };

  if (!rolPuedeCrearEstudiantes(usuario?.rol)) {
    return (
      <EstadoVacio
        titulo="Acción no permitida"
        descripcion="Solo un administrador puede crear usuarios académicos."
        etiquetaAccion="Volver a estudiantes"
        hrefAccion={RUTAS.ESTUDIANTES}
      />
    );
  }

  return (
    <Tarjeta>
      <TarjetaEncabezado>
        <TarjetaTitulo>Nuevo usuario académico</TarjetaTitulo>
      </TarjetaEncabezado>
      <TarjetaContenido>
        <form className="grid gap-4 md:grid-cols-2" onSubmit={formulario.handleSubmit(enviar)}>
          <div className="space-y-2">
            <Etiqueta>Nombre</Etiqueta>
            <Entrada {...formulario.register('nombre')} />
          </div>
          <div className="space-y-2">
            <Etiqueta>Apellidos</Etiqueta>
            <Entrada {...formulario.register('apellidos')} />
          </div>
          <div className="space-y-2 md:col-span-2">
            <Etiqueta>Correo</Etiqueta>
            <Entrada type="email" {...formulario.register('correo')} />
            {formulario.formState.errors.correo ? (
              <p className="text-sm text-[var(--estado-peligro)]">{formulario.formState.errors.correo.message}</p>
            ) : null}
          </div>
          <div className="space-y-2 md:col-span-2">
            <Etiqueta>Contraseña temporal</Etiqueta>
            <Entrada type="password" {...formulario.register('contrasena')} />
            {formulario.formState.errors.contrasena ? (
              <p className="text-sm text-[var(--estado-peligro)]">{formulario.formState.errors.contrasena.message}</p>
            ) : null}
          </div>
          <div className="space-y-2 md:col-span-2">
            <Etiqueta>Rol</Etiqueta>
            <Seleccion
              value={formulario.watch('rol')}
              onValueChange={(valor) => formulario.setValue('rol', valor as RolUsuario.DOCENTE | RolUsuario.ESTUDIANTE)}
            >
              <SeleccionDisparador>
                <SeleccionValor placeholder="Selecciona un rol" />
              </SeleccionDisparador>
              <SeleccionContenido>
                <SeleccionItem value={RolUsuario.ESTUDIANTE}>Estudiante</SeleccionItem>
                <SeleccionItem value={RolUsuario.DOCENTE}>Docente</SeleccionItem>
              </SeleccionContenido>
            </Seleccion>
            {formulario.formState.errors.rol ? (
              <p className="text-sm text-[var(--estado-peligro)]">{formulario.formState.errors.rol.message}</p>
            ) : null}
          </div>
          <div className="md:col-span-2">
            <Boton
              type="submit"
              disabled={formulario.formState.isSubmitting || mutacionCrearUsuarioAcademico.isPending}
            >
              {formulario.formState.isSubmitting || mutacionCrearUsuarioAcademico.isPending
                ? 'Guardando...'
                : 'Crear usuario'}
            </Boton>
          </div>
        </form>
      </TarjetaContenido>
    </Tarjeta>
  );
}
