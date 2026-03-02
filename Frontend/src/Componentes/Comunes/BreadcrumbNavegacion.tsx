/**
 * @archivo   BreadcrumbNavegacion.tsx
 * @descripcion Muestra migas de navegación para mantener contexto dentro del panel admin.
 * @modulo    ComponentesComunes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import Link from 'next/link';

interface ElementoMiga {
  etiqueta: string;
  href?: string;
}

interface PropiedadesBreadcrumb {
  elementos: ElementoMiga[];
}

/**
 * Renderiza una ruta jerárquica en formato breadcrumb.
 */
export function BreadcrumbNavegacion({ elementos }: PropiedadesBreadcrumb) {
  return (
    <nav aria-label="Breadcrumb">
      <ol className="flex flex-wrap items-center gap-2 text-sm text-slate-600">
        {elementos.map((elemento, indice) => {
          const esUltimo = indice === elementos.length - 1;
          return (
            <li key={`${elemento.etiqueta}-${indice}`} className="flex items-center gap-2">
              {esUltimo || !elemento.href ? (
                <span className="font-medium text-slate-900">{elemento.etiqueta}</span>
              ) : (
                <Link href={elemento.href} className="hover:text-primario">
                  {elemento.etiqueta}
                </Link>
              )}
              {!esUltimo ? <span>/</span> : null}
            </li>
          );
        })}
      </ol>
    </nav>
  );
}
