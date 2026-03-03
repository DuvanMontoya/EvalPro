/**
 * @archivo   page.tsx
 * @descripcion Permite registrar usuarios nuevos (administrador, docente o estudiante).
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
import { useInstituciones } from '@/Hooks/useInstituciones';
import { RUTAS } from '@/Constantes/Rutas.constantes';
import { EncabezadoPagina } from '@/Componentes/Comunes/EncabezadoPagina';
import { Cargando } from '@/Componentes/Comunes/Cargando';
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
 * Renderiza formulario de alta de usuario.
 */
export default function PaginaNuevoEstudiante() {
  const router = useRouter();
  const { usuario } = useAutenticacion();
  const { mutacionCrearUsuarioAcademico } = useEstudiantes();
  const { consultaInstituciones } = useInstituciones();
  const esSuperadmin = usuario?.rol === RolUsuario.SUPERADMINISTRADOR;

  const formulario = useForm<CrearUsuarioAcademicoFormulario>({
    resolver: zodResolver(esquemaCrearUsuarioAcademico),
    defaultValues: {
      nombre: '',
      apellidos: '',
      correo: '',
      contrasena: '',
      rol: RolUsuario.ESTUDIANTE,
      idInstitucion: '',
    },
  });

  const enviar = async (datos: CrearUsuarioAcademicoFormulario) => {
    if (esSuperadmin && !datos.idInstitucion) {
      formulario.setError('idInstitucion', {
        type: 'manual',
        message: 'Selecciona la institución del usuario.',
      });
      return;
    }

    try {
      const usuarioCreado = await mutacionCrearUsuarioAcademico.mutateAsync({
        nombre: datos.nombre,
        apellidos: datos.apellidos,
        correo: datos.correo,
        contrasena: datos.contrasena,
        rol: datos.rol,
        idInstitucion: esSuperadmin ? datos.idInstitucion || undefined : undefined,
      });
      toast.success(
        datos.rol === RolUsuario.ADMINISTRADOR
          ? 'Administrador creado correctamente.'
          : datos.rol === RolUsuario.DOCENTE
            ? 'Docente creado correctamente.'
            : 'Estudiante creado correctamente.',
      );
      if (usuarioCreado.credencialTemporalPlano) {
        toast.info(`Credencial temporal: ${usuarioCreado.credencialTemporalPlano}`);
      }
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

  if (esSuperadmin && consultaInstituciones.isLoading) {
    return <Cargando mensaje="Cargando instituciones..." />;
  }

  if (esSuperadmin && consultaInstituciones.isError) {
    return (
      <EstadoVacio
        titulo="No fue posible cargar instituciones"
        descripcion={obtenerMensajeError(consultaInstituciones.error, 'Intenta nuevamente en unos segundos.')}
      />
    );
  }

  const instituciones = consultaInstituciones.data ?? [];
  if (esSuperadmin && instituciones.length === 0) {
    return (
      <EstadoVacio
        titulo="No hay instituciones disponibles"
        descripcion="Debes crear una institución antes de registrar administradores, docentes o estudiantes."
        etiquetaAccion="Ir a instituciones"
        hrefAccion={RUTAS.INSTITUCIONES}
      />
    );
  }

  return (
    <section className="space-y-4">
      <EncabezadoPagina
        etiqueta="Alta de usuarios"
        titulo="Nuevo usuario"
        descripcion="Registra administradores, docentes o estudiantes con credencial temporal de acceso inicial."
      />
      <Tarjeta>
        <TarjetaEncabezado>
          <TarjetaTitulo>Información base</TarjetaTitulo>
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
              onValueChange={(valor) =>
                formulario.setValue('rol', valor as RolUsuario.ADMINISTRADOR | RolUsuario.DOCENTE | RolUsuario.ESTUDIANTE)
              }
            >
              <SeleccionDisparador>
                <SeleccionValor placeholder="Selecciona un rol" />
              </SeleccionDisparador>
              <SeleccionContenido>
                {esSuperadmin ? (
                  <SeleccionItem value={RolUsuario.ADMINISTRADOR}>Administrador</SeleccionItem>
                ) : null}
                <SeleccionItem value={RolUsuario.ESTUDIANTE}>Estudiante</SeleccionItem>
                <SeleccionItem value={RolUsuario.DOCENTE}>Docente</SeleccionItem>
              </SeleccionContenido>
            </Seleccion>
            {formulario.formState.errors.rol ? (
              <p className="text-sm text-[var(--estado-peligro)]">{formulario.formState.errors.rol.message}</p>
            ) : null}
          </div>
          {esSuperadmin ? (
            <div className="space-y-2 md:col-span-2">
              <Etiqueta>Institución</Etiqueta>
              <Seleccion
                value={formulario.watch('idInstitucion') || ''}
                onValueChange={(valor) => formulario.setValue('idInstitucion', valor)}
              >
                <SeleccionDisparador>
                  <SeleccionValor placeholder="Selecciona institución" />
                </SeleccionDisparador>
                <SeleccionContenido>
                  {instituciones.map((institucion) => (
                    <SeleccionItem key={institucion.id} value={institucion.id}>
                      {institucion.nombre}
                    </SeleccionItem>
                  ))}
                </SeleccionContenido>
              </Seleccion>
              {formulario.formState.errors.idInstitucion ? (
                <p className="text-sm text-[var(--estado-peligro)]">{formulario.formState.errors.idInstitucion.message}</p>
              ) : null}
            </div>
          ) : null}
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
    </section>
  );
}
