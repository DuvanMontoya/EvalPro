/**
 * @archivo   TablaExamenes.tsx
 * @descripcion Presenta el listado de exámenes con acciones de publicación, edición y archivado.
 * @modulo    ComponentesExamenes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import Link from 'next/link';
import { ColumnDef, flexRender, getCoreRowModel, useReactTable } from '@tanstack/react-table';
import { Examen, EstadoExamen } from '@/Tipos';
import { RUTAS } from '@/Constantes/Rutas.constantes';
import { Boton } from '@/Componentes/Ui/Boton';
import { InsigniaEstado } from '@/Componentes/Examenes/InsigniaEstado';
import {
  Tabla,
  TablaCabeza,
  TablaCelda,
  TablaCuerpo,
  TablaEncabezado,
  TablaFila,
} from '@/Componentes/Ui/Tabla';

interface PropiedadesTablaExamenes {
  examenes: Examen[];
  onPublicar: (idExamen: string) => void;
  onArchivar: (idExamen: string) => void;
}

/**
 * Renderiza tabla interactiva de exámenes con acciones rápidas.
 */
export function TablaExamenes({ examenes, onPublicar, onArchivar }: PropiedadesTablaExamenes) {
  const columnas: ColumnDef<Examen>[] = [
    { accessorKey: 'titulo', header: 'Título' },
    { accessorKey: 'modalidad', header: 'Modalidad' },
    {
      accessorKey: 'estado',
      header: 'Estado',
      cell: ({ row }) => <InsigniaEstado estado={row.original.estado} />,
    },
    {
      accessorKey: 'totalPreguntas',
      header: 'Preguntas',
      cell: ({ row }) => <span className="font-mono">{row.original.totalPreguntas}</span>,
    },
    {
      id: 'acciones',
      header: 'Acciones',
      cell: ({ row }) => {
        const examen = row.original;
        const puedePublicar = examen.estado === EstadoExamen.BORRADOR;
        const puedeArchivar = examen.estado !== EstadoExamen.ARCHIVADO;

        return (
          <div className="flex flex-wrap gap-2">
            <Boton comoHijo tamano="pequeno" variante="contorno">
              <Link href={RUTAS.EXAMEN_DETALLE(examen.id)}>Ver</Link>
            </Boton>
            <Boton comoHijo tamano="pequeno" variante="contorno">
              <Link href={RUTAS.EXAMEN_EDITAR(examen.id)}>Editar</Link>
            </Boton>
            {puedePublicar ? (
              <Boton tamano="pequeno" onClick={() => onPublicar(examen.id)}>
                Publicar
              </Boton>
            ) : null}
            {puedeArchivar ? (
              <Boton tamano="pequeno" variante="peligro" onClick={() => onArchivar(examen.id)}>
                Archivar
              </Boton>
            ) : null}
          </div>
        );
      },
    },
  ];

  const tabla = useReactTable({
    data: examenes,
    columns: columnas,
    getCoreRowModel: getCoreRowModel(),
  });

  return (
    <Tabla>
      <TablaEncabezado>
        {tabla.getHeaderGroups().map((grupo) => (
          <TablaFila key={grupo.id}>
            {grupo.headers.map((header) => (
              <TablaCabeza key={header.id}>
                {header.isPlaceholder ? null : flexRender(header.column.columnDef.header, header.getContext())}
              </TablaCabeza>
            ))}
          </TablaFila>
        ))}
      </TablaEncabezado>
      <TablaCuerpo>
        {tabla.getRowModel().rows.map((fila) => (
          <TablaFila key={fila.id}>
            {fila.getVisibleCells().map((celda) => (
              <TablaCelda key={celda.id}>{flexRender(celda.column.columnDef.cell, celda.getContext())}</TablaCelda>
            ))}
          </TablaFila>
        ))}
      </TablaCuerpo>
    </Tabla>
  );
}
