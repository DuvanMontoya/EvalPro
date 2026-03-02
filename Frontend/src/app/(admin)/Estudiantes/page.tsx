/**
 * @archivo   page.tsx
 * @descripcion Lista estudiantes registrados y permite acceder a su detalle.
 * @modulo    Estudiantes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import Link from 'next/link';
import { RUTAS } from '@/Constantes/Rutas.constantes';
import { useEstudiantes } from '@/Hooks/useEstudiantes';
import { Cargando } from '@/Componentes/Comunes/Cargando';
import { EstadoVacio } from '@/Componentes/Comunes/EstadoVacio';
import { Boton } from '@/Componentes/Ui/Boton';
import {
  Tabla,
  TablaCabeza,
  TablaCelda,
  TablaCuerpo,
  TablaEncabezado,
  TablaFila,
} from '@/Componentes/Ui/Tabla';

/**
 * Renderiza tabla de estudiantes.
 */
export default function PaginaEstudiantes() {
  const { consultaEstudiantes } = useEstudiantes();

  if (consultaEstudiantes.isLoading) {
    return <Cargando mensaje="Cargando estudiantes..." />;
  }

  const estudiantes = consultaEstudiantes.data ?? [];

  if (estudiantes.length === 0) {
    return (
      <EstadoVacio
        titulo="No hay estudiantes"
        descripcion="Registra estudiantes para habilitar participación en sesiones."
        etiquetaAccion="Nuevo estudiante"
        hrefAccion={RUTAS.ESTUDIANTE_NUEVO}
      />
    );
  }

  return (
    <section className="space-y-4">
      <div className="flex justify-end">
        <Boton comoHijo>
          <Link href={RUTAS.ESTUDIANTE_NUEVO}>Nuevo estudiante</Link>
        </Boton>
      </div>

      <Tabla>
        <TablaEncabezado>
          <TablaFila>
            <TablaCabeza>Nombre</TablaCabeza>
            <TablaCabeza>Correo</TablaCabeza>
            <TablaCabeza>Estado</TablaCabeza>
            <TablaCabeza>Acciones</TablaCabeza>
          </TablaFila>
        </TablaEncabezado>
        <TablaCuerpo>
          {estudiantes.map((estudiante) => (
            <TablaFila key={estudiante.id}>
              <TablaCelda>{estudiante.nombre} {estudiante.apellidos}</TablaCelda>
              <TablaCelda>{estudiante.correo}</TablaCelda>
              <TablaCelda>{estudiante.activo ? 'Activo' : 'Inactivo'}</TablaCelda>
              <TablaCelda>
                <Boton comoHijo tamano="pequeno" variante="contorno">
                  <Link href={`/Estudiantes/${estudiante.id}`}>Ver detalle</Link>
                </Boton>
              </TablaCelda>
            </TablaFila>
          ))}
        </TablaCuerpo>
      </Tabla>
    </section>
  );
}
