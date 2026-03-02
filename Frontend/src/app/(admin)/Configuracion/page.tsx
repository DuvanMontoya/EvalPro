/**
 * @archivo   page.tsx
 * @descripcion Muestra ajustes generales del panel administrativo como placeholder funcional.
 * @modulo    Configuracion
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { Tarjeta, TarjetaContenido, TarjetaEncabezado, TarjetaTitulo } from '@/Componentes/Ui/Tarjeta';

/**
 * Renderiza vista base de configuración.
 */
export default function PaginaConfiguracion() {
  return (
    <Tarjeta>
      <TarjetaEncabezado>
        <TarjetaTitulo>Configuración</TarjetaTitulo>
      </TarjetaEncabezado>
      <TarjetaContenido>
        <p className="texto-muted">
          Este módulo centralizará ajustes de institución, seguridad y preferencias del panel.
        </p>
      </TarjetaContenido>
    </Tarjeta>
  );
}
