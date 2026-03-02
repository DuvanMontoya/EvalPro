/**
 * @archivo   page.tsx
 * @descripcion Lista usuarios académicos visibles y permite acceder a su detalle.
 * @modulo    Estudiantes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import Link from 'next/link';
import { useMemo, useState } from 'react';
import { RolUsuario } from '@/Tipos';
import { RUTAS } from '@/Constantes/Rutas.constantes';
import { useAutenticacion } from '@/Hooks/useAutenticacion';
import { useEstudiantes } from '@/Hooks/useEstudiantes';
import { Cargando } from '@/Componentes/Comunes/Cargando';
import { EncabezadoPagina } from '@/Componentes/Comunes/EncabezadoPagina';
import { EstadoVacio } from '@/Componentes/Comunes/EstadoVacio';
import { Boton } from '@/Componentes/Ui/Boton';
import {
  Seleccion,
  SeleccionContenido,
  SeleccionDisparador,
  SeleccionItem,
  SeleccionValor,
} from '@/Componentes/Ui/Seleccion';
import {
  Tabla,
  TablaCabeza,
  TablaCelda,
  TablaCuerpo,
  TablaEncabezado,
  TablaFila,
} from '@/Componentes/Ui/Tabla';
import { obtenerMensajeError } from '@/Lib/ErroresApi';
import { rolPuedeCrearEstudiantes } from '@/Lib/Permisos';

/**
 * Renderiza tabla de estudiantes.
 */
export default function PaginaEstudiantes() {
  const [filtroRol, setFiltroRol] = useState<'TODOS' | RolUsuario.ESTUDIANTE | RolUsuario.DOCENTE>('TODOS');
  const { consultaUsuariosAcademicos } = useEstudiantes();
  const { usuario } = useAutenticacion();
  const puedeCrear = rolPuedeCrearEstudiantes(usuario?.rol);
  const usuariosAcademicos = consultaUsuariosAcademicos.data ?? [];
  const usuariosFiltrados = useMemo(() => {
    if (filtroRol === 'TODOS') {
      return usuariosAcademicos;
    }
    return usuariosAcademicos.filter((usuarioAcademico) => usuarioAcademico.rol === filtroRol);
  }, [filtroRol, usuariosAcademicos]);

  if (consultaUsuariosAcademicos.isLoading) {
    return <Cargando mensaje="Cargando usuarios académicos..." />;
  }

  if (consultaUsuariosAcademicos.isError) {
    return (
      <EstadoVacio
        titulo="No fue posible cargar usuarios"
        descripcion={obtenerMensajeError(consultaUsuariosAcademicos.error, 'Intenta nuevamente en unos segundos.')}
      />
    );
  }

  if (usuariosFiltrados.length === 0) {
    return (
      <EstadoVacio
        titulo="No hay usuarios académicos"
        descripcion="Registra docentes y estudiantes para habilitar la operación del sistema."
        etiquetaAccion={puedeCrear ? 'Nuevo usuario' : undefined}
        hrefAccion={puedeCrear ? RUTAS.ESTUDIANTE_NUEVO : undefined}
      />
    );
  }

  return (
    <section className="space-y-4">
      <EncabezadoPagina
        etiqueta="Comunidad académica"
        titulo="Usuarios académicos"
        descripcion="Consulta docentes y estudiantes, con acceso rápido a historial y detalles."
        acciones={puedeCrear ? (
          <Boton comoHijo>
            <Link href={RUTAS.ESTUDIANTE_NUEVO}>Nuevo usuario</Link>
          </Boton>
        ) : undefined}
      />

      <div className="max-w-xs">
        <Seleccion value={filtroRol} onValueChange={(valor) => setFiltroRol(valor as typeof filtroRol)}>
          <SeleccionDisparador>
            <SeleccionValor placeholder="Filtrar por rol" />
          </SeleccionDisparador>
          <SeleccionContenido>
            <SeleccionItem value="TODOS">Todos</SeleccionItem>
            <SeleccionItem value={RolUsuario.DOCENTE}>Docentes</SeleccionItem>
            <SeleccionItem value={RolUsuario.ESTUDIANTE}>Estudiantes</SeleccionItem>
          </SeleccionContenido>
        </Seleccion>
      </div>

      <Tabla>
        <TablaEncabezado>
          <TablaFila>
            <TablaCabeza>Nombre</TablaCabeza>
            <TablaCabeza>Rol</TablaCabeza>
            <TablaCabeza>Correo</TablaCabeza>
            <TablaCabeza>Estado</TablaCabeza>
            <TablaCabeza>Acciones</TablaCabeza>
          </TablaFila>
        </TablaEncabezado>
        <TablaCuerpo>
          {usuariosFiltrados.map((usuarioAcademico) => (
            <TablaFila key={usuarioAcademico.id}>
              <TablaCelda>{usuarioAcademico.nombre} {usuarioAcademico.apellidos}</TablaCelda>
              <TablaCelda>{usuarioAcademico.rol === RolUsuario.DOCENTE ? 'Docente' : 'Estudiante'}</TablaCelda>
              <TablaCelda>{usuarioAcademico.correo}</TablaCelda>
              <TablaCelda>{usuarioAcademico.activo ? 'Activo' : 'Inactivo'}</TablaCelda>
              <TablaCelda>
                <Boton comoHijo tamano="pequeno" variante="contorno">
                  <Link href={RUTAS.ESTUDIANTE_DETALLE(usuarioAcademico.id)}>Ver detalle</Link>
                </Boton>
              </TablaCelda>
            </TablaFila>
          ))}
        </TablaCuerpo>
      </Tabla>
    </section>
  );
}
