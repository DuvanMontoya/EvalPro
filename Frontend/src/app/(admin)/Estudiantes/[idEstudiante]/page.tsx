/**
 * @archivo   page.tsx
 * @descripcion Muestra detalle de un estudiante junto con su historial de intentos reportado.
 * @modulo    Estudiantes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { useParams } from 'next/navigation';
import { useReporteEstudiante } from '@/Hooks/useReportes';
import { Cargando } from '@/Componentes/Comunes/Cargando';
import { EstadoVacio } from '@/Componentes/Comunes/EstadoVacio';
import { Tarjeta, TarjetaContenido, TarjetaEncabezado, TarjetaTitulo } from '@/Componentes/Ui/Tarjeta';
import { obtenerMensajeError } from '@/Lib/ErroresApi';

/**
 * Renderiza página de detalle de estudiante.
 */
export default function PaginaDetalleEstudiante() {
  const parametros = useParams<{ idEstudiante: string }>();
  const idEstudiante = parametros.idEstudiante;
  const reporte = useReporteEstudiante(idEstudiante);

  if (reporte.isLoading) {
    return <Cargando mensaje="Cargando historial..." />;
  }

  if (reporte.isError) {
    return (
      <EstadoVacio
        titulo="No fue posible cargar el historial"
        descripcion={obtenerMensajeError(reporte.error, 'Intenta nuevamente en unos segundos.')}
      />
    );
  }

  if (!reporte.data) {
    return (
      <EstadoVacio
        titulo="Sin datos del estudiante"
        descripcion="No existe información disponible para este estudiante."
      />
    );
  }

  return (
    <section className="space-y-4">
      <Tarjeta>
        <TarjetaEncabezado>
          <TarjetaTitulo>{reporte.data.nombreCompleto}</TarjetaTitulo>
        </TarjetaEncabezado>
        <TarjetaContenido>
          <p className="texto-muted">
            ID: <span className="font-mono">{reporte.data.idEstudiante}</span>
          </p>
        </TarjetaContenido>
      </Tarjeta>

      <Tarjeta>
        <TarjetaEncabezado>
          <TarjetaTitulo>Historial de intentos</TarjetaTitulo>
        </TarjetaEncabezado>
        <TarjetaContenido>
          {reporte.data.intentos.length === 0 ? (
            <EstadoVacio
              titulo="Sin intentos registrados"
              descripcion="El estudiante todavía no tiene participaciones en sesiones."
            />
          ) : (
            <ul className="space-y-2">
              {reporte.data.intentos.map((intento) => (
                <li
                  key={`${intento.idSesion}-${intento.codigoAcceso}`}
                  className="rounded-md border border-[var(--borde-sutil)] bg-fondo-elevado-3 p-3"
                >
                  <p className="font-medium">{intento.tituloExamen}</p>
                  <p className="texto-muted">
                    Código: <span className="font-mono">{intento.codigoAcceso}</span> | Estado: {intento.estado}
                  </p>
                  <p className="texto-muted">
                    Porcentaje: <span className="font-mono">{intento.porcentaje ?? 'N/A'}%</span>
                  </p>
                </li>
              ))}
            </ul>
          )}
        </TarjetaContenido>
      </Tarjeta>
    </section>
  );
}
