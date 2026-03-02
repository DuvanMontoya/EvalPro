/**
 * @archivo   page.tsx
 * @descripcion Gestiona grupos académicos, periodos y membresías.
 * @modulo    Grupos
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { useEffect, useMemo, useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { toast } from 'sonner';
import { RolUsuario } from '@/Tipos';
import { EncabezadoPagina } from '@/Componentes/Comunes/EncabezadoPagina';
import { Cargando } from '@/Componentes/Comunes/Cargando';
import { EstadoVacio } from '@/Componentes/Comunes/EstadoVacio';
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
import { useAutenticacion } from '@/Hooks/useAutenticacion';
import { useEstudiantes } from '@/Hooks/useEstudiantes';
import { useGrupos, usePeriodos } from '@/Hooks/useGrupos';
import { useInstituciones } from '@/Hooks/useInstituciones';
import { EstadoGrupo } from '@/Servicios/Grupos.servicio';
import { RUTAS } from '@/Constantes/Rutas.constantes';
import { obtenerMensajeError } from '@/Lib/ErroresApi';
import {
  esquemaCrearGrupo,
  esquemaCrearPeriodoAcademico,
  CrearGrupoFormulario,
  CrearPeriodoAcademicoFormulario,
} from '@/Lib/validaciones';
import { rolPuedeGestionarGrupos } from '@/Lib/Permisos';

const ESTADOS_GRUPO: EstadoGrupo[] = ['BORRADOR', 'ACTIVO', 'CERRADO', 'ARCHIVADO'];

function varianteEstadoGrupo(estado: EstadoGrupo): 'neutro' | 'primario' | 'alerta' | 'peligro' {
  if (estado === 'BORRADOR') {
    return 'neutro';
  }
  if (estado === 'ACTIVO') {
    return 'primario';
  }
  if (estado === 'CERRADO') {
    return 'alerta';
  }
  return 'peligro';
}

/**
 * Renderiza módulo de grupos académicos.
 */
export default function PaginaGrupos() {
  const { usuario } = useAutenticacion();
  const { consultaUsuariosAcademicos } = useEstudiantes();
  const { consultaInstituciones } = useInstituciones();
  const esSuperadmin = usuario?.rol === RolUsuario.SUPERADMINISTRADOR;
  const [idInstitucionSeleccionada, setIdInstitucionSeleccionada] = useState<string>('');
  const [idGrupoSeleccionado, setIdGrupoSeleccionado] = useState<string>('');
  const [idDocenteSeleccionado, setIdDocenteSeleccionado] = useState<string>('');
  const [idEstudianteSeleccionado, setIdEstudianteSeleccionado] = useState<string>('');
  const [estadoDestinoGrupo, setEstadoDestinoGrupo] = useState<EstadoGrupo>('ACTIVO');

  const contextoInstitucionListo = !esSuperadmin || Boolean(idInstitucionSeleccionada);
  const { consultaGrupos, mutacionCrearGrupo, mutacionAsignarDocente, mutacionInscribirEstudiante, mutacionCambiarEstado } =
    useGrupos(idInstitucionSeleccionada || undefined, contextoInstitucionListo);
  const { consultaPeriodos, mutacionCrearPeriodo } = usePeriodos(
    idInstitucionSeleccionada || undefined,
    contextoInstitucionListo,
  );

  useEffect(() => {
    if (!consultaInstituciones.data || consultaInstituciones.data.length === 0) {
      return;
    }
    if (!idInstitucionSeleccionada) {
      setIdInstitucionSeleccionada(consultaInstituciones.data[0]!.id);
    }
  }, [consultaInstituciones.data, idInstitucionSeleccionada]);

  useEffect(() => {
    if (!consultaGrupos.data || consultaGrupos.data.length === 0) {
      setIdGrupoSeleccionado('');
      return;
    }
    if (!idGrupoSeleccionado) {
      setIdGrupoSeleccionado(consultaGrupos.data[0]!.id);
    }
  }, [consultaGrupos.data, idGrupoSeleccionado]);

  const formularioPeriodo = useForm<CrearPeriodoAcademicoFormulario>({
    resolver: zodResolver(esquemaCrearPeriodoAcademico),
    defaultValues: { nombre: '', fechaInicio: '', fechaFin: '' },
  });

  const formularioGrupo = useForm<CrearGrupoFormulario>({
    resolver: zodResolver(esquemaCrearGrupo),
    defaultValues: { nombre: '', descripcion: '', idPeriodo: '' },
  });

  const usuariosTenant = useMemo(() => {
    const usuarios = consultaUsuariosAcademicos.data ?? [];
    if (!idInstitucionSeleccionada) {
      return usuarios;
    }
    return usuarios.filter((usuarioAcademico) => usuarioAcademico.idInstitucion === idInstitucionSeleccionada);
  }, [consultaUsuariosAcademicos.data, idInstitucionSeleccionada]);

  const docentes = useMemo(
    () => usuariosTenant.filter((usuarioAcademico) => usuarioAcademico.rol === RolUsuario.DOCENTE),
    [usuariosTenant],
  );
  const estudiantes = useMemo(
    () => usuariosTenant.filter((usuarioAcademico) => usuarioAcademico.rol === RolUsuario.ESTUDIANTE),
    [usuariosTenant],
  );

  if (!rolPuedeGestionarGrupos(usuario?.rol)) {
    return (
      <EstadoVacio
        titulo="Acceso restringido"
        descripcion="Solo ADMINISTRADOR o SUPERADMINISTRADOR pueden gestionar grupos."
        etiquetaAccion="Volver al tablero"
        hrefAccion={RUTAS.TABLERO}
      />
    );
  }

  if (consultaInstituciones.isLoading || consultaUsuariosAcademicos.isLoading) {
    return <Cargando mensaje="Cargando contexto de grupos..." />;
  }

  if (consultaInstituciones.isError || consultaUsuariosAcademicos.isError) {
    return (
      <EstadoVacio
        titulo="No fue posible cargar la información base"
        descripcion={obtenerMensajeError(
          consultaInstituciones.error ?? consultaUsuariosAcademicos.error,
          'Intenta nuevamente en unos segundos.',
        )}
      />
    );
  }

  const instituciones = consultaInstituciones.data ?? [];
  if (esSuperadmin && instituciones.length === 0) {
    return (
      <EstadoVacio
        titulo="No hay instituciones disponibles"
        descripcion="Primero crea una institución para poder registrar periodos y grupos."
        etiquetaAccion="Ir a instituciones"
        hrefAccion={RUTAS.INSTITUCIONES}
      />
    );
  }

  const grupos = consultaGrupos.data ?? [];
  const periodos = consultaPeriodos.data ?? [];

  return (
    <section className="space-y-6">
      <EncabezadoPagina
        etiqueta="Gestión académica"
        titulo="Grupos"
        descripcion="Crea periodos, registra grupos y administra docentes/estudiantes por grupo."
      />

      <Tarjeta>
        <TarjetaEncabezado>
          <TarjetaTitulo>Contexto institucional</TarjetaTitulo>
        </TarjetaEncabezado>
        <TarjetaContenido className="grid gap-4 md:grid-cols-2">
          <div className="space-y-2">
            <Etiqueta>Institución objetivo</Etiqueta>
            <Seleccion value={idInstitucionSeleccionada} onValueChange={setIdInstitucionSeleccionada}>
              <SeleccionDisparador>
                <SeleccionValor placeholder="Selecciona una institución" />
              </SeleccionDisparador>
              <SeleccionContenido>
                {instituciones.map((institucion) => (
                  <SeleccionItem key={institucion.id} value={institucion.id}>
                    {institucion.nombre}
                  </SeleccionItem>
                ))}
              </SeleccionContenido>
            </Seleccion>
          </div>
          <div className="rounded-xl border border-[var(--borde-default)] bg-fondo-elevado-3 p-4 text-sm text-[var(--texto-secundario)]">
            <p className="font-semibold text-[var(--texto-primario)]">Resumen</p>
            <p className="mt-1">Periodos: {periodos.length}</p>
            <p>Grupos: {grupos.length}</p>
            <p>Docentes disponibles: {docentes.length}</p>
            <p>Estudiantes disponibles: {estudiantes.length}</p>
          </div>
        </TarjetaContenido>
      </Tarjeta>

      <div className="grid gap-4 xl:grid-cols-2">
        <Tarjeta>
          <TarjetaEncabezado>
            <TarjetaTitulo>Crear periodo académico</TarjetaTitulo>
          </TarjetaEncabezado>
          <TarjetaContenido>
            <form
              className="space-y-3"
              onSubmit={formularioPeriodo.handleSubmit(async (valores) => {
                try {
                  await mutacionCrearPeriodo.mutateAsync({
                    ...valores,
                    idInstitucion: esSuperadmin ? idInstitucionSeleccionada : undefined,
                    activo: true,
                  });
                  toast.success('Periodo académico creado correctamente.');
                  formularioPeriodo.reset();
                } catch (error) {
                  toast.error(obtenerMensajeError(error, 'No se pudo crear el periodo.'));
                }
              })}
            >
              <div className="space-y-2">
                <Etiqueta>Nombre</Etiqueta>
                <Entrada {...formularioPeriodo.register('nombre')} placeholder="2026-1" />
              </div>
              <div className="grid gap-3 md:grid-cols-2">
                <div className="space-y-2">
                  <Etiqueta>Fecha inicio</Etiqueta>
                  <Entrada type="date" {...formularioPeriodo.register('fechaInicio')} />
                </div>
                <div className="space-y-2">
                  <Etiqueta>Fecha fin</Etiqueta>
                  <Entrada type="date" {...formularioPeriodo.register('fechaFin')} />
                </div>
              </div>
              <Boton
                type="submit"
                disabled={
                  !contextoInstitucionListo || formularioPeriodo.formState.isSubmitting || mutacionCrearPeriodo.isPending
                }
              >
                {formularioPeriodo.formState.isSubmitting || mutacionCrearPeriodo.isPending
                  ? 'Creando...'
                  : 'Crear periodo'}
              </Boton>
            </form>
          </TarjetaContenido>
        </Tarjeta>

        <Tarjeta>
          <TarjetaEncabezado>
            <TarjetaTitulo>Crear grupo</TarjetaTitulo>
          </TarjetaEncabezado>
          <TarjetaContenido>
            <form
              className="space-y-3"
              onSubmit={formularioGrupo.handleSubmit(async (valores) => {
                try {
                  await mutacionCrearGrupo.mutateAsync({
                    ...valores,
                    idInstitucion: esSuperadmin ? idInstitucionSeleccionada : undefined,
                    descripcion: valores.descripcion || undefined,
                  });
                  toast.success('Grupo creado correctamente.');
                  formularioGrupo.reset({ nombre: '', descripcion: '', idPeriodo: '' });
                } catch (error) {
                  toast.error(obtenerMensajeError(error, 'No se pudo crear el grupo.'));
                }
              })}
            >
              <div className="space-y-2">
                <Etiqueta>Nombre</Etiqueta>
                <Entrada {...formularioGrupo.register('nombre')} placeholder="Matemáticas 10A" />
              </div>
              <div className="space-y-2">
                <Etiqueta>Descripción</Etiqueta>
                <Entrada {...formularioGrupo.register('descripcion')} placeholder="Opcional" />
              </div>
              <div className="space-y-2">
                <Etiqueta>Periodo</Etiqueta>
                <Seleccion
                  value={formularioGrupo.watch('idPeriodo')}
                  onValueChange={(valor) => formularioGrupo.setValue('idPeriodo', valor)}
                  disabled={!contextoInstitucionListo}
                >
                  <SeleccionDisparador>
                    <SeleccionValor placeholder="Selecciona un periodo" />
                  </SeleccionDisparador>
                  <SeleccionContenido>
                    {periodos.map((periodo) => (
                      <SeleccionItem key={periodo.id} value={periodo.id}>
                        {periodo.nombre} {periodo.activo ? '(Activo)' : ''}
                      </SeleccionItem>
                    ))}
                  </SeleccionContenido>
                </Seleccion>
              </div>
              <Boton
                type="submit"
                disabled={!contextoInstitucionListo || formularioGrupo.formState.isSubmitting || mutacionCrearGrupo.isPending}
              >
                {formularioGrupo.formState.isSubmitting || mutacionCrearGrupo.isPending ? 'Creando...' : 'Crear grupo'}
              </Boton>
            </form>
          </TarjetaContenido>
        </Tarjeta>
      </div>

      <Tarjeta>
        <TarjetaEncabezado>
          <TarjetaTitulo>Asignaciones y estado del grupo</TarjetaTitulo>
        </TarjetaEncabezado>
        <TarjetaContenido className="grid gap-4 xl:grid-cols-4">
          <div className="space-y-2 xl:col-span-4">
            <Etiqueta>Grupo objetivo</Etiqueta>
            <Seleccion value={idGrupoSeleccionado} onValueChange={setIdGrupoSeleccionado} disabled={!contextoInstitucionListo}>
              <SeleccionDisparador>
                <SeleccionValor placeholder="Selecciona un grupo" />
              </SeleccionDisparador>
              <SeleccionContenido>
                {grupos.map((grupo) => (
                  <SeleccionItem key={grupo.id} value={grupo.id}>
                    {grupo.nombre} ({grupo.estado})
                  </SeleccionItem>
                ))}
              </SeleccionContenido>
            </Seleccion>
          </div>

          <div className="space-y-2">
            <Etiqueta>Docente</Etiqueta>
            <Seleccion value={idDocenteSeleccionado} onValueChange={setIdDocenteSeleccionado} disabled={!contextoInstitucionListo}>
              <SeleccionDisparador>
                <SeleccionValor placeholder="Selecciona docente" />
              </SeleccionDisparador>
              <SeleccionContenido>
                {docentes.map((docente) => (
                  <SeleccionItem key={docente.id} value={docente.id}>
                    {docente.nombre} {docente.apellidos}
                  </SeleccionItem>
                ))}
              </SeleccionContenido>
            </Seleccion>
            <Boton
              variante="contorno"
              disabled={
                !contextoInstitucionListo ||
                !idGrupoSeleccionado ||
                !idDocenteSeleccionado ||
                mutacionAsignarDocente.isPending
              }
              onClick={async () => {
                try {
                  await mutacionAsignarDocente.mutateAsync({
                    idGrupo: idGrupoSeleccionado,
                    idDocente: idDocenteSeleccionado,
                  });
                  toast.success('Docente asignado correctamente.');
                } catch (error) {
                  toast.error(obtenerMensajeError(error, 'No se pudo asignar el docente.'));
                }
              }}
            >
              Asignar docente
            </Boton>
          </div>

          <div className="space-y-2">
            <Etiqueta>Estudiante</Etiqueta>
            <Seleccion
              value={idEstudianteSeleccionado}
              onValueChange={setIdEstudianteSeleccionado}
              disabled={!contextoInstitucionListo}
            >
              <SeleccionDisparador>
                <SeleccionValor placeholder="Selecciona estudiante" />
              </SeleccionDisparador>
              <SeleccionContenido>
                {estudiantes.map((estudiante) => (
                  <SeleccionItem key={estudiante.id} value={estudiante.id}>
                    {estudiante.nombre} {estudiante.apellidos}
                  </SeleccionItem>
                ))}
              </SeleccionContenido>
            </Seleccion>
            <Boton
              variante="contorno"
              disabled={
                !contextoInstitucionListo ||
                !idGrupoSeleccionado ||
                !idEstudianteSeleccionado ||
                mutacionInscribirEstudiante.isPending
              }
              onClick={async () => {
                try {
                  await mutacionInscribirEstudiante.mutateAsync({
                    idGrupo: idGrupoSeleccionado,
                    idEstudiante: idEstudianteSeleccionado,
                  });
                  toast.success('Estudiante inscrito correctamente.');
                } catch (error) {
                  toast.error(obtenerMensajeError(error, 'No se pudo inscribir el estudiante.'));
                }
              }}
            >
              Inscribir estudiante
            </Boton>
          </div>

          <div className="space-y-2">
            <Etiqueta>Nuevo estado</Etiqueta>
            <Seleccion
              value={estadoDestinoGrupo}
              onValueChange={(valor) => setEstadoDestinoGrupo(valor as EstadoGrupo)}
              disabled={!contextoInstitucionListo}
            >
              <SeleccionDisparador>
                <SeleccionValor placeholder="Selecciona estado" />
              </SeleccionDisparador>
              <SeleccionContenido>
                {ESTADOS_GRUPO.map((estado) => (
                  <SeleccionItem key={estado} value={estado}>
                    {estado}
                  </SeleccionItem>
                ))}
              </SeleccionContenido>
            </Seleccion>
            <Boton
              variante="peligro"
              disabled={!contextoInstitucionListo || !idGrupoSeleccionado || mutacionCambiarEstado.isPending}
              onClick={async () => {
                try {
                  await mutacionCambiarEstado.mutateAsync({
                    idGrupo: idGrupoSeleccionado,
                    estado: estadoDestinoGrupo,
                  });
                  toast.success('Estado de grupo actualizado.');
                } catch (error) {
                  toast.error(obtenerMensajeError(error, 'No se pudo cambiar el estado del grupo.'));
                }
              }}
            >
              Cambiar estado
            </Boton>
          </div>

          <div className="rounded-xl border border-[var(--borde-default)] bg-fondo-elevado-3 p-4 text-sm text-[var(--texto-secundario)] xl:col-span-1">
            <p className="font-semibold text-[var(--texto-primario)]">Reglas clave</p>
            <p className="mt-2">Para activar un grupo necesitas al menos 1 docente y 1 estudiante activos.</p>
            <p className="mt-2">Si cierras un grupo, se finalizan sesiones activas asociadas.</p>
          </div>
        </TarjetaContenido>
      </Tarjeta>

      <Tarjeta>
        <TarjetaEncabezado>
          <TarjetaTitulo>Listado de grupos</TarjetaTitulo>
        </TarjetaEncabezado>
        <TarjetaContenido>
          {!contextoInstitucionListo ? (
            <div className="mb-4 rounded-lg border border-[var(--estado-advertencia-borde)] bg-[var(--estado-advertencia-sutil)] px-4 py-3 text-sm text-[var(--estado-advertencia)]">
              Selecciona una institución para cargar periodos y grupos.
            </div>
          ) : null}
          {consultaGrupos.isLoading ? (
            <Cargando mensaje="Cargando grupos..." />
          ) : consultaGrupos.isError ? (
            <EstadoVacio
              titulo="No fue posible cargar grupos"
              descripcion={obtenerMensajeError(consultaGrupos.error, 'Intenta nuevamente en unos segundos.')}
            />
          ) : grupos.length === 0 ? (
            <EstadoVacio
              titulo="Sin grupos registrados"
              descripcion="Crea tu primer grupo para iniciar la operación académica."
            />
          ) : (
            <Tabla>
              <TablaEncabezado>
                <TablaFila>
                  <TablaCabeza>Nombre</TablaCabeza>
                  <TablaCabeza>Periodo</TablaCabeza>
                  <TablaCabeza>Estado</TablaCabeza>
                  <TablaCabeza>Docentes</TablaCabeza>
                  <TablaCabeza>Estudiantes</TablaCabeza>
                  <TablaCabeza>Código</TablaCabeza>
                </TablaFila>
              </TablaEncabezado>
              <TablaCuerpo>
                {grupos.map((grupo) => (
                  <TablaFila key={grupo.id}>
                    <TablaCelda>{grupo.nombre}</TablaCelda>
                    <TablaCelda>{grupo.periodo?.nombre ?? '—'}</TablaCelda>
                    <TablaCelda>
                      <Insignia variante={varianteEstadoGrupo(grupo.estado)}>{grupo.estado}</Insignia>
                    </TablaCelda>
                    <TablaCelda>{grupo.docentes.length}</TablaCelda>
                    <TablaCelda>{grupo.estudiantes.length}</TablaCelda>
                    <TablaCelda>
                      <span className="font-mono">{grupo.codigoAcceso}</span>
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
