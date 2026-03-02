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
import { Tarjeta, TarjetaContenido, TarjetaEncabezado, TarjetaTitulo } from '@/Componentes/Ui/Tarjeta';

/**
 * Renderiza página de detalle de estudiante.
 */
export default function PaginaDetalleEstudiante() {
  const parametros = useParams<{ idEstudiante: string }>();
  const idEstudiante = parametros.idEstudiante;
  const reporte = useReporteEstudiante(idEstudiante);

  if (reporte.isLoading || !reporte.data) {
    return <Cargando mensaje="Cargando historial..." />;
  }

  return (
    <section className="space-y-4">
      <Tarjeta>
        <TarjetaEncabezado>
          <TarjetaTitulo>{reporte.data.nombreCompleto}</TarjetaTitulo>
        </TarjetaEncabezado>
        <TarjetaContenido>
          <p className="texto-muted">ID: {reporte.data.idEstudiante}</p>
        </TarjetaContenido>
      </Tarjeta>

      <Tarjeta>
        <TarjetaEncabezado>
          <TarjetaTitulo>Historial de intentos</TarjetaTitulo>
        </TarjetaEncabezado>
        <TarjetaContenido>
          <ul className="space-y-2">
            {reporte.data.intentos.map((intento) => (
              <li key={`${intento.idSesion}-${intento.codigoAcceso}`} className="rounded-md border border-borde p-3">
                <p className="font-medium">{intento.tituloExamen}</p>
                <p className="texto-muted">Código: {intento.codigoAcceso} | Estado: {intento.estado}</p>
                <p className="texto-muted">Porcentaje: {intento.porcentaje ?? 'N/A'}%</p>
              </li>
            ))}
          </ul>
        </TarjetaContenido>
      </Tarjeta>
    </section>
  );
}
