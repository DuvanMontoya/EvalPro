/**
 * @archivo   page.tsx
 * @descripcion Permite registrar un nuevo estudiante con validación de formulario.
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
import { esquemaCrearEstudiante, CrearEstudianteFormulario } from '@/Lib/validaciones';
import { useAutenticacion } from '@/Hooks/useAutenticacion';
import { useEstudiantes } from '@/Hooks/useEstudiantes';
import { RUTAS } from '@/Constantes/Rutas.constantes';
import { EstadoVacio } from '@/Componentes/Comunes/EstadoVacio';
import { Tarjeta, TarjetaContenido, TarjetaEncabezado, TarjetaTitulo } from '@/Componentes/Ui/Tarjeta';
import { Etiqueta } from '@/Componentes/Ui/Etiqueta';
import { Entrada } from '@/Componentes/Ui/Entrada';
import { Boton } from '@/Componentes/Ui/Boton';
import { obtenerMensajeError } from '@/Lib/ErroresApi';
import { rolPuedeCrearEstudiantes } from '@/Lib/Permisos';

/**
 * Renderiza formulario de alta de estudiante.
 */
export default function PaginaNuevoEstudiante() {
  const router = useRouter();
  const { usuario } = useAutenticacion();
  const { mutacionCrearEstudiante } = useEstudiantes();

  const formulario = useForm<CrearEstudianteFormulario>({
    resolver: zodResolver(esquemaCrearEstudiante),
    defaultValues: {
      nombre: '',
      apellidos: '',
      correo: '',
      contrasena: '',
      rol: RolUsuario.ESTUDIANTE,
    },
  });

  const enviar = async (datos: CrearEstudianteFormulario) => {
    try {
      await mutacionCrearEstudiante.mutateAsync(datos);
      toast.success('Estudiante creado correctamente.');
      router.push(RUTAS.ESTUDIANTES);
    } catch (error) {
      toast.error(obtenerMensajeError(error, 'No se pudo crear el estudiante.'));
    }
  };

  if (!rolPuedeCrearEstudiantes(usuario?.rol)) {
    return (
      <EstadoVacio
        titulo="Acción no permitida"
        descripcion="Solo un administrador puede crear estudiantes."
        etiquetaAccion="Volver a estudiantes"
        hrefAccion={RUTAS.ESTUDIANTES}
      />
    );
  }

  return (
    <Tarjeta>
      <TarjetaEncabezado>
        <TarjetaTitulo>Nuevo estudiante</TarjetaTitulo>
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
          </div>
          <div className="space-y-2 md:col-span-2">
            <Etiqueta>Contraseña temporal</Etiqueta>
            <Entrada type="password" {...formulario.register('contrasena')} />
          </div>
          <div className="md:col-span-2">
            <Boton type="submit" disabled={formulario.formState.isSubmitting || mutacionCrearEstudiante.isPending}>
              {formulario.formState.isSubmitting || mutacionCrearEstudiante.isPending ? 'Guardando...' : 'Crear estudiante'}
            </Boton>
          </div>
        </form>
      </TarjetaContenido>
    </Tarjeta>
  );
}
