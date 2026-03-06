/**
 * @archivo   page.tsx
 * @descripcion Gestiona políticas antifraude de red por institución y muestra postura de seguridad.
 * @modulo    Configuracion
 * @autor     EvalPro
 * @fecha     2026-03-05
 */
'use client';

import { useEffect, useMemo, useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { Shield, ShieldCheck, SlidersHorizontal } from 'lucide-react';
import { toast } from 'sonner';
import { RolUsuario } from '@/Tipos';
import { EncabezadoPagina } from '@/Componentes/Comunes/EncabezadoPagina';
import { Cargando } from '@/Componentes/Comunes/Cargando';
import { Boton } from '@/Componentes/Ui/Boton';
import { Entrada } from '@/Componentes/Ui/Entrada';
import { Etiqueta } from '@/Componentes/Ui/Etiqueta';
import { Tarjeta, TarjetaContenido, TarjetaEncabezado, TarjetaTitulo } from '@/Componentes/Ui/Tarjeta';
import {
  Seleccion,
  SeleccionContenido,
  SeleccionDisparador,
  SeleccionItem,
  SeleccionValor,
} from '@/Componentes/Ui/Seleccion';
import { useAutenticacion } from '@/Hooks/useAutenticacion';
import { useInstituciones } from '@/Hooks/useInstituciones';
import { useTableroReportes } from '@/Hooks/useReportes';
import { obtenerMensajeError } from '@/Lib/ErroresApi';
import { rolPuedeGestionarConfiguracionAntifraude } from '@/Lib/Permisos';
import {
  ConfiguracionAntifraudeRed,
  CONFIGURACION_ANTIFRAUDE_RED_POR_DEFECTO,
  obtenerConfiguracionAntifraudeRed,
} from '@/Servicios/Instituciones.servicio';
import { ConfiguracionAntifraudeRedFormulario, esquemaConfiguracionAntifraudeRed } from '@/Lib/validaciones';

interface CampoPolitica {
  clave: keyof ConfiguracionAntifraudeRed;
  etiqueta: string;
  descripcion: string;
  minimo: number;
  maximo: number;
}

const CAMPOS_POLITICA_RED: CampoPolitica[] = [
  {
    clave: 'ventanaSegundos',
    etiqueta: 'Ventana de análisis (segundos)',
    descripcion: 'Periodo de observación para detectar reconexiones anómalas.',
    minimo: 30,
    maximo: 3600,
  },
  {
    clave: 'maxReconexionesVentana',
    etiqueta: 'Máximo reconexiones en ventana',
    descripcion: 'Límite de reconexiones antes de aplicar incremento de riesgo.',
    minimo: 1,
    maximo: 30,
  },
  {
    clave: 'maxCambiosTipoRedVentana',
    etiqueta: 'Máximo cambios de tipo de red',
    descripcion: 'Límite de cambios WIFI/MÓVIL/VPN permitidos por ventana.',
    minimo: 1,
    maximo: 30,
  },
  {
    clave: 'maxTiempoOfflineSegundos',
    etiqueta: 'Desconexión máxima tolerada (segundos)',
    descripcion: 'Tiempo fuera de línea permitido antes de elevar riesgo.',
    minimo: 5,
    maximo: 900,
  },
  {
    clave: 'riesgoPorReconexion',
    etiqueta: 'Riesgo por reconexión anómala',
    descripcion: 'Incremento aplicado por exceso de reconexiones.',
    minimo: 1,
    maximo: 50,
  },
  {
    clave: 'riesgoPorCambioTipoRed',
    etiqueta: 'Riesgo por cambio de red anómalo',
    descripcion: 'Incremento aplicado por exceso de cambios de tipo de red.',
    minimo: 1,
    maximo: 50,
  },
  {
    clave: 'riesgoPorOfflineExtenso',
    etiqueta: 'Riesgo por desconexión extensa',
    descripcion: 'Incremento aplicado por cortes de red prolongados.',
    minimo: 1,
    maximo: 50,
  },
  {
    clave: 'umbralRiesgoSospechoso',
    etiqueta: 'Umbral sospechoso',
    descripcion: 'Desde este puntaje el intento requiere revisión.',
    minimo: 0,
    maximo: 100,
  },
  {
    clave: 'umbralRiesgoCritico',
    etiqueta: 'Umbral crítico',
    descripcion: 'Desde este puntaje la alerta se clasifica como crítica.',
    minimo: 1,
    maximo: 100,
  },
];

/**
 * Renderiza la configuración de seguridad operativa por institución.
 */
export default function PaginaConfiguracion() {
  const { usuario } = useAutenticacion();
  const { sesionesActivasAhora, estudiantesConectados } = useTableroReportes();
  const { consultaInstituciones, mutacionActualizarConfiguracionAntifraude } = useInstituciones();
  const puedeGestionar = rolPuedeGestionarConfiguracionAntifraude(usuario?.rol);

  const institucionesVisibles = useMemo(() => {
    const instituciones = consultaInstituciones.data ?? [];
    if (usuario?.rol === RolUsuario.SUPERADMINISTRADOR) {
      return instituciones;
    }
    if (!usuario?.idInstitucion) {
      return [];
    }
    return instituciones.filter((institucion) => institucion.id === usuario.idInstitucion);
  }, [consultaInstituciones.data, usuario?.idInstitucion, usuario?.rol]);

  const [idInstitucionObjetivo, setIdInstitucionObjetivo] = useState<string>('');
  const institucionObjetivo = useMemo(
    () => institucionesVisibles.find((institucion) => institucion.id === idInstitucionObjetivo) ?? null,
    [idInstitucionObjetivo, institucionesVisibles],
  );

  const politicaActual = useMemo(() => {
    if (!institucionObjetivo) {
      return CONFIGURACION_ANTIFRAUDE_RED_POR_DEFECTO;
    }
    return obtenerConfiguracionAntifraudeRed(institucionObjetivo.configuracion);
  }, [institucionObjetivo]);

  const formulario = useForm<ConfiguracionAntifraudeRedFormulario>({
    resolver: zodResolver(esquemaConfiguracionAntifraudeRed),
    defaultValues: politicaActual,
  });

  useEffect(() => {
    if (institucionesVisibles.length === 0) {
      setIdInstitucionObjetivo('');
      return;
    }

    if (!idInstitucionObjetivo || !institucionesVisibles.some((institucion) => institucion.id === idInstitucionObjetivo)) {
      if (usuario?.rol === RolUsuario.ADMINISTRADOR && usuario.idInstitucion) {
        setIdInstitucionObjetivo(usuario.idInstitucion);
        return;
      }
      setIdInstitucionObjetivo(institucionesVisibles[0]!.id);
    }
  }, [idInstitucionObjetivo, institucionesVisibles, usuario?.idInstitucion, usuario?.rol]);

  useEffect(() => {
    formulario.reset(politicaActual);
  }, [formulario, politicaActual]);

  return (
    <section className="space-y-6">
      <EncabezadoPagina
        etiqueta="Control"
        titulo="Configuración y seguridad"
        descripcion="Define umbrales antifraude de red por institución y vigila la postura operativa en tiempo real."
      />

      <div className="grid gap-4 lg:grid-cols-3">
        <Tarjeta>
          <TarjetaEncabezado>
            <TarjetaTitulo className="flex items-center gap-2 text-lg">
              <ShieldCheck className="h-5 w-5 text-[var(--estado-exito)]" />
              Estado de sesión
            </TarjetaTitulo>
          </TarjetaEncabezado>
          <TarjetaContenido className="space-y-2 text-sm text-[var(--texto-secundario)]">
            <p>
              Rol actual: <span className="font-semibold text-[var(--texto-primario)]">{usuario?.rol ?? 'N/D'}</span>
            </p>
            <p>
              Sesiones activas ahora:{' '}
              <span className="font-semibold text-[var(--texto-primario)]">{sesionesActivasAhora.data ?? 0}</span>
            </p>
            <p>
              Estudiantes conectados:{' '}
              <span className="font-semibold text-[var(--texto-primario)]">{estudiantesConectados.data ?? 0}</span>
            </p>
          </TarjetaContenido>
        </Tarjeta>

        <Tarjeta>
          <TarjetaEncabezado>
            <TarjetaTitulo className="flex items-center gap-2 text-lg">
              <Shield className="h-5 w-5 text-[var(--acento-primario-hover)]" />
              Seguridad activa
            </TarjetaTitulo>
          </TarjetaEncabezado>
          <TarjetaContenido className="space-y-2 text-sm text-[var(--texto-secundario)]">
            <p>Autenticación JWT con refresh rotativo.</p>
            <p>Detección activa de reconexiones y cambios de red anómalos.</p>
            <p>Umbrales antifraude configurables por institución.</p>
          </TarjetaContenido>
        </Tarjeta>

        <Tarjeta>
          <TarjetaEncabezado>
            <TarjetaTitulo className="flex items-center gap-2 text-lg">
              <SlidersHorizontal className="h-5 w-5 text-[var(--estado-advertencia)]" />
              Cobertura operativa
            </TarjetaTitulo>
          </TarjetaEncabezado>
          <TarjetaContenido className="space-y-2 text-sm text-[var(--texto-secundario)]">
            <p>Riesgo incremental por reconexiones, cambios de red y cortes extensos.</p>
            <p>Escalamiento automático a sospechoso/crítico según política vigente.</p>
            <p>Notificación en monitor docente al cruzar umbrales de riesgo.</p>
          </TarjetaContenido>
        </Tarjeta>
      </div>

      {!puedeGestionar ? (
        <Tarjeta>
          <TarjetaEncabezado>
            <TarjetaTitulo>Configuración antifraude de red</TarjetaTitulo>
          </TarjetaEncabezado>
          <TarjetaContenido className="text-sm text-[var(--texto-secundario)]">
            Solo ADMINISTRADOR y SUPERADMINISTRADOR pueden editar esta configuración.
          </TarjetaContenido>
        </Tarjeta>
      ) : consultaInstituciones.isLoading ? (
        <Cargando mensaje="Cargando instituciones y políticas antifraude..." />
      ) : consultaInstituciones.isError ? (
        <Tarjeta>
          <TarjetaEncabezado>
            <TarjetaTitulo>Configuración antifraude de red</TarjetaTitulo>
          </TarjetaEncabezado>
          <TarjetaContenido className="text-sm text-[var(--estado-peligro)]">
            {obtenerMensajeError(consultaInstituciones.error, 'No fue posible cargar la configuración.')}
          </TarjetaContenido>
        </Tarjeta>
      ) : (
        <Tarjeta>
          <TarjetaEncabezado>
            <TarjetaTitulo>Política antifraude de red por institución</TarjetaTitulo>
          </TarjetaEncabezado>
          <TarjetaContenido className="space-y-5">
            {usuario?.rol === RolUsuario.SUPERADMINISTRADOR ? (
              <div className="space-y-2">
                <Etiqueta>Institución objetivo</Etiqueta>
                <Seleccion value={idInstitucionObjetivo} onValueChange={setIdInstitucionObjetivo}>
                  <SeleccionDisparador className="w-full md:w-[460px]">
                    <SeleccionValor placeholder="Selecciona una institución" />
                  </SeleccionDisparador>
                  <SeleccionContenido>
                    {institucionesVisibles.map((institucion) => (
                      <SeleccionItem key={institucion.id} value={institucion.id}>
                        {institucion.nombre}
                      </SeleccionItem>
                    ))}
                  </SeleccionContenido>
                </Seleccion>
              </div>
            ) : (
              <div className="rounded-md border border-[var(--borde-default)] bg-fondo-elevado-2 px-3 py-2 text-sm text-[var(--texto-secundario)]">
                Institución: <span className="font-semibold text-[var(--texto-primario)]">{institucionObjetivo?.nombre ?? 'N/D'}</span>
              </div>
            )}

            {!institucionObjetivo ? (
              <div className="rounded-md border border-[var(--estado-advertencia-borde)] bg-[var(--estado-advertencia-sutil)] px-4 py-3 text-sm text-[var(--estado-advertencia)]">
                No hay instituciones disponibles para configurar.
              </div>
            ) : (
              <form
                className="space-y-4"
                onSubmit={formulario.handleSubmit(async (valores) => {
                  try {
                    await mutacionActualizarConfiguracionAntifraude.mutateAsync({
                      idInstitucion: institucionObjetivo.id,
                      dto: { red: valores },
                    });
                    toast.success(`Política antifraude actualizada para ${institucionObjetivo.nombre}.`);
                  } catch (error) {
                    toast.error(obtenerMensajeError(error, 'No se pudo actualizar la política antifraude.'));
                  }
                })}
              >
                <div className="grid gap-4 md:grid-cols-2">
                  {CAMPOS_POLITICA_RED.map((campo) => (
                    <div key={campo.clave} className="space-y-2">
                      <Etiqueta>{campo.etiqueta}</Etiqueta>
                      <Entrada
                        type="number"
                        min={campo.minimo}
                        max={campo.maximo}
                        step={1}
                        {...formulario.register(campo.clave, { valueAsNumber: true })}
                      />
                      <p className="text-xs text-[var(--texto-terciario)]">{campo.descripcion}</p>
                      {formulario.formState.errors[campo.clave] ? (
                        <p className="text-sm text-[var(--estado-peligro)]">
                          {String(formulario.formState.errors[campo.clave]?.message ?? 'Valor inválido')}
                        </p>
                      ) : null}
                    </div>
                  ))}
                </div>
                <div className="flex flex-wrap gap-3">
                  <Boton
                    type="submit"
                    disabled={
                      formulario.formState.isSubmitting ||
                      mutacionActualizarConfiguracionAntifraude.isPending ||
                      !formulario.formState.isDirty
                    }
                  >
                    {formulario.formState.isSubmitting || mutacionActualizarConfiguracionAntifraude.isPending
                      ? 'Guardando política...'
                      : 'Guardar política antifraude'}
                  </Boton>
                  <Boton
                    type="button"
                    variante="secundario"
                    onClick={() => formulario.reset(CONFIGURACION_ANTIFRAUDE_RED_POR_DEFECTO)}
                  >
                    Restablecer valores sugeridos
                  </Boton>
                </div>
              </form>
            )}
          </TarjetaContenido>
        </Tarjeta>
      )}
    </section>
  );
}
