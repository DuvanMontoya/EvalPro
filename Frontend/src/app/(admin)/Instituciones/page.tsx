/**
 * @archivo   page.tsx
 * @descripcion Gestiona instituciones del sistema para superadministración.
 * @modulo    Instituciones
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { toast } from 'sonner';
import { useAutenticacion } from '@/Hooks/useAutenticacion';
import { useInstituciones } from '@/Hooks/useInstituciones';
import { EstadoVacio } from '@/Componentes/Comunes/EstadoVacio';
import { EncabezadoPagina } from '@/Componentes/Comunes/EncabezadoPagina';
import { Cargando } from '@/Componentes/Comunes/Cargando';
import { Boton } from '@/Componentes/Ui/Boton';
import { Entrada } from '@/Componentes/Ui/Entrada';
import { Etiqueta } from '@/Componentes/Ui/Etiqueta';
import { Tarjeta, TarjetaContenido, TarjetaEncabezado, TarjetaTitulo } from '@/Componentes/Ui/Tarjeta';
import { Insignia } from '@/Componentes/Ui/Insignia';
import {
  Seleccion,
  SeleccionContenido,
  SeleccionDisparador,
  SeleccionItem,
  SeleccionValor,
} from '@/Componentes/Ui/Seleccion';
import { Tabla, TablaCabeza, TablaCelda, TablaCuerpo, TablaEncabezado, TablaFila } from '@/Componentes/Ui/Tabla';
import { RUTAS } from '@/Constantes/Rutas.constantes';
import { obtenerMensajeError } from '@/Lib/ErroresApi';
import { esquemaCrearInstitucion, CrearInstitucionFormulario } from '@/Lib/validaciones';
import { rolPuedeGestionarInstituciones } from '@/Lib/Permisos';
import { EstadoInstitucion } from '@/Servicios/Instituciones.servicio';

const ESTADOS_INSTITUCION: EstadoInstitucion[] = ['ACTIVA', 'SUSPENDIDA', 'ARCHIVADA'];

function varianteEstado(estado: EstadoInstitucion): 'exito' | 'alerta' | 'peligro' {
  if (estado === 'ACTIVA') {
    return 'exito';
  }
  if (estado === 'SUSPENDIDA') {
    return 'alerta';
  }
  return 'peligro';
}

/**
 * Renderiza módulo de administración de instituciones.
 */
export default function PaginaInstituciones() {
  const { usuario } = useAutenticacion();
  const { consultaInstituciones, mutacionCrearInstitucion, mutacionCambiarEstadoInstitucion } = useInstituciones();

  const formulario = useForm<CrearInstitucionFormulario>({
    resolver: zodResolver(esquemaCrearInstitucion),
    defaultValues: { nombre: '', dominio: '' },
  });

  if (!rolPuedeGestionarInstituciones(usuario?.rol)) {
    return (
      <EstadoVacio
        titulo="Acceso restringido"
        descripcion="Solo SUPERADMINISTRADOR puede gestionar instituciones."
        etiquetaAccion="Volver al tablero"
        hrefAccion={RUTAS.TABLERO}
      />
    );
  }

  if (consultaInstituciones.isLoading) {
    return <Cargando mensaje="Cargando instituciones..." />;
  }

  if (consultaInstituciones.isError) {
    return (
      <EstadoVacio
        titulo="No fue posible cargar instituciones"
        descripcion={obtenerMensajeError(consultaInstituciones.error, 'Intenta nuevamente en unos segundos.')}
      />
    );
  }

  const instituciones = consultaInstituciones.data ?? [];

  return (
    <section className="space-y-6">
      <EncabezadoPagina
        etiqueta="Superadmin"
        titulo="Instituciones"
        descripcion="Crea instituciones y controla su estado operativo global."
      />

      <Tarjeta>
        <TarjetaEncabezado>
          <TarjetaTitulo>Nueva institución</TarjetaTitulo>
        </TarjetaEncabezado>
        <TarjetaContenido>
          <form
            className="grid gap-4 md:grid-cols-2"
            onSubmit={formulario.handleSubmit(async (valores) => {
              try {
                await mutacionCrearInstitucion.mutateAsync({
                  nombre: valores.nombre,
                  dominio: valores.dominio || undefined,
                });
                toast.success('Institución creada correctamente.');
                formulario.reset();
              } catch (error) {
                toast.error(obtenerMensajeError(error, 'No se pudo crear la institución.'));
              }
            })}
          >
            <div className="space-y-2">
              <Etiqueta>Nombre</Etiqueta>
              <Entrada {...formulario.register('nombre')} />
              {formulario.formState.errors.nombre ? (
                <p className="text-sm text-[var(--estado-peligro)]">{formulario.formState.errors.nombre.message}</p>
              ) : null}
            </div>
            <div className="space-y-2">
              <Etiqueta>Dominio (opcional)</Etiqueta>
              <Entrada placeholder="colegio.edu.co" {...formulario.register('dominio')} />
              {formulario.formState.errors.dominio ? (
                <p className="text-sm text-[var(--estado-peligro)]">{formulario.formState.errors.dominio.message}</p>
              ) : null}
            </div>
            <div className="md:col-span-2">
              <Boton type="submit" disabled={formulario.formState.isSubmitting || mutacionCrearInstitucion.isPending}>
                {formulario.formState.isSubmitting || mutacionCrearInstitucion.isPending
                  ? 'Creando...'
                  : 'Crear institución'}
              </Boton>
            </div>
          </form>
        </TarjetaContenido>
      </Tarjeta>

      <Tarjeta>
        <TarjetaEncabezado>
          <TarjetaTitulo>Instituciones registradas</TarjetaTitulo>
        </TarjetaEncabezado>
        <TarjetaContenido>
          {instituciones.length === 0 ? (
            <EstadoVacio
              titulo="Sin instituciones"
              descripcion="Aún no se han creado instituciones en la plataforma."
            />
          ) : (
            <Tabla>
              <TablaEncabezado>
                <TablaFila>
                  <TablaCabeza>Nombre</TablaCabeza>
                  <TablaCabeza>Dominio</TablaCabeza>
                  <TablaCabeza>Estado</TablaCabeza>
                  <TablaCabeza>Fecha creación</TablaCabeza>
                  <TablaCabeza>Acción</TablaCabeza>
                </TablaFila>
              </TablaEncabezado>
              <TablaCuerpo>
                {instituciones.map((institucion) => (
                  <TablaFila key={institucion.id}>
                    <TablaCelda>{institucion.nombre}</TablaCelda>
                    <TablaCelda>{institucion.dominio ?? '—'}</TablaCelda>
                    <TablaCelda>
                      <Insignia variante={varianteEstado(institucion.estado)}>{institucion.estado}</Insignia>
                    </TablaCelda>
                    <TablaCelda>{new Date(institucion.fechaCreacion).toLocaleString('es-CO')}</TablaCelda>
                    <TablaCelda>
                      <Seleccion
                        onValueChange={async (valor) => {
                          try {
                            await mutacionCambiarEstadoInstitucion.mutateAsync({
                              idInstitucion: institucion.id,
                              dto: { estado: valor as EstadoInstitucion, razon: 'Cambio desde panel web' },
                            });
                            toast.success('Estado de institución actualizado.');
                          } catch (error) {
                            toast.error(obtenerMensajeError(error, 'No se pudo actualizar el estado.'));
                          }
                        }}
                      >
                        <SeleccionDisparador className="w-48">
                          <SeleccionValor placeholder="Cambiar estado" />
                        </SeleccionDisparador>
                        <SeleccionContenido>
                          {ESTADOS_INSTITUCION.map((estado) => (
                            <SeleccionItem key={estado} value={estado}>
                              {estado}
                            </SeleccionItem>
                          ))}
                        </SeleccionContenido>
                      </Seleccion>
                    </TablaCelda>
                  </TablaFila>
                ))}
              </TablaCuerpo>
            </Tabla>
          )}
        </TarjetaContenido>
      </Tarjeta>
    </section>
  );
}

