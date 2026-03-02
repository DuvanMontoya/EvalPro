/**
 * @archivo   InsigniaEstado.tsx
 * @descripcion Mapea el estado del examen a una insignia visual consistente dentro de tablas y tarjetas.
 * @modulo    ComponentesExamenes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { EstadoExamen } from '@/Tipos';
import { Insignia } from '@/Componentes/Ui/Insignia';

interface PropiedadesInsigniaEstado {
  estado: EstadoExamen;
}

/**
 * Renderiza una insignia acorde al estado actual del examen.
 */
export function InsigniaEstado({ estado }: PropiedadesInsigniaEstado) {
  if (estado === EstadoExamen.PUBLICADO) {
    return <Insignia variante="exito">Publicado</Insignia>;
  }

  if (estado === EstadoExamen.ARCHIVADO) {
    return <Insignia variante="alerta">Archivado</Insignia>;
  }

  return <Insignia variante="neutro">Borrador</Insignia>;
}
