/**
 * @archivo   TablaSesiones.tsx
 * @descripcion Lista sesiones con acciones de ver, activar y finalizar para docentes.
 * @modulo    ComponentesSesiones
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import Link from 'next/link';
import { ColumnDef, flexRender, getCoreRowModel, useReactTable } from '@tanstack/react-table';
import { EstadoSesion, SesionExamen } from '@/Tipos';
import { RUTAS } from '@/Constantes/Rutas.constantes';
import { Boton } from '@/Componentes/Ui/Boton';
import { Insignia } from '@/Componentes/Ui/Insignia';
import {
  Tabla,
  TablaCabeza,
  TablaCelda,
  TablaCuerpo,
  TablaEncabezado,
  TablaFila,
} from '@/Componentes/Ui/Tabla';

interface PropiedadesTablaSesiones {
  sesiones: SesionExamen[];
  onActivar: (idSesion: string) => void;
  onFinalizar: (idSesion: string) => void;
}

function renderEstado(estado: EstadoSesion) {
  if (estado === EstadoSesion.ACTIVA) {
    return <Insignia variante="exito">Activa</Insignia>;
  }
  if (estado === EstadoSesion.FINALIZADA) {
    return <Insignia variante="primario">Finalizada</Insignia>;
  }
  if (estado === EstadoSesion.CANCELADA) {
    return <Insignia variante="peligro">Cancelada</Insignia>;
  }
  return <Insignia variante="alerta">Pendiente</Insignia>;
}

/**
 * Renderiza tabla de sesiones con acciones según estado.
 */
export function TablaSesiones({ sesiones, onActivar, onFinalizar }: PropiedadesTablaSesiones) {
  const columnas: ColumnDef<SesionExamen>[] = [
    { accessorKey: 'codigoAcceso', header: 'Código' },
    {
      accessorKey: 'estado',
      header: 'Estado',
      cell: ({ row }) => renderEstado(row.original.estado),
    },
    { accessorKey: 'fechaCreacion', header: 'Creada' },
    {
      id: 'acciones',
      header: 'Acciones',
      cell: ({ row }) => {
        const sesion = row.original;
        return (
          <div className="flex flex-wrap gap-2">
            <Boton comoHijo tamano="pequeno" variante="contorno">
              <Link href={RUTAS.SESION_DETALLE(sesion.id)}>Ver</Link>
            </Boton>
            {sesion.estado === EstadoSesion.PENDIENTE ? (
              <Boton tamano="pequeno" onClick={() => onActivar(sesion.id)}>
                Activar
              </Boton>
            ) : null}
            {sesion.estado === EstadoSesion.ACTIVA ? (
              <Boton tamano="pequeno" variante="peligro" onClick={() => onFinalizar(sesion.id)}>
                Finalizar
              </Boton>
            ) : null}
          </div>
        );
      },
    },
  ];

  const tabla = useReactTable({ data: sesiones, columns: columnas, getCoreRowModel: getCoreRowModel() });

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
