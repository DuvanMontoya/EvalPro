/**
 * @archivo   page.tsx
 * @descripcion Muestra ajustes operativos y estado actual de la plataforma.
 * @modulo    Configuracion
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { Shield, ShieldCheck, SlidersHorizontal } from 'lucide-react';
import { EncabezadoPagina } from '@/Componentes/Comunes/EncabezadoPagina';
import { Tarjeta, TarjetaContenido, TarjetaEncabezado, TarjetaTitulo } from '@/Componentes/Ui/Tarjeta';
import { useAutenticacion } from '@/Hooks/useAutenticacion';
import { useTableroReportes } from '@/Hooks/useReportes';

/**
 * Renderiza vista de configuración operativa.
 */
export default function PaginaConfiguracion() {
  const { usuario } = useAutenticacion();
  const { sesionesActivasAhora, estudiantesConectados } = useTableroReportes();

  return (
    <section className="space-y-6">
      <EncabezadoPagina
        etiqueta="Control"
        titulo="Configuración y seguridad"
        descripcion="Resumen de parámetros activos, postura de seguridad y estado operativo del entorno."
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
            <p>Autenticación por JWT con refresh rotativo.</p>
            <p>Auditoría de acciones sensibles con trazabilidad completa.</p>
            <p>Control de roles y aislamiento por institución.</p>
          </TarjetaContenido>
        </Tarjeta>

        <Tarjeta>
          <TarjetaEncabezado>
            <TarjetaTitulo className="flex items-center gap-2 text-lg">
              <SlidersHorizontal className="h-5 w-5 text-[var(--estado-advertencia)]" />
              Próximas acciones
            </TarjetaTitulo>
          </TarjetaEncabezado>
          <TarjetaContenido className="space-y-2 text-sm text-[var(--texto-secundario)]">
            <p>Configurar políticas antifraude por institución.</p>
            <p>Definir ventanas de publicación de resultados.</p>
            <p>Gestionar reglas de retención y exportación de auditoría.</p>
          </TarjetaContenido>
        </Tarjeta>
      </div>
    </section>
  );
}
