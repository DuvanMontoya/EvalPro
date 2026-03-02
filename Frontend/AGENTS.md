# AGENTS.md — EvalPro · Frontend Admin (Next.js 16 + shadcn/ui)
> Complementa `/AGENTS.md` raíz. Lee primero el raíz, luego este.
> Aplica a todos los archivos dentro de `Frontend/`.

---

## ESTRUCTURA DE DIRECTORIOS EXACTA

```
Frontend/
├── src/
│   ├── app/
│   │   ├── layout.tsx                         ← Layout raíz (fuentes, providers globales)
│   │   ├── page.tsx                           ← Redirige inmediatamente a /Tablero
│   │   ├── (autenticacion)/                   ← Grupo sin layout admin
│   │   │   ├── layout.tsx                     ← Layout centrado para login
│   │   │   └── IniciarSesion/
│   │   │       └── page.tsx
│   │   └── (admin)/                           ← Grupo con layout admin completo
│   │       ├── layout.tsx                     ← Sidebar + Header + ProviderQuery
│   │       ├── Tablero/
│   │       │   └── page.tsx
│   │       ├── Examenes/
│   │       │   ├── page.tsx                   ← Lista de exámenes
│   │       │   ├── Nuevo/
│   │       │   │   └── page.tsx
│   │       │   └── [idExamen]/
│   │       │       ├── page.tsx               ← Detalle + editor de preguntas
│   │       │       └── Editar/
│   │       │           └── page.tsx
│   │       ├── Sesiones/
│   │       │   ├── page.tsx
│   │       │   ├── Nueva/
│   │       │   │   └── page.tsx
│   │       │   └── [idSesion]/
│   │       │       ├── page.tsx               ← Monitor en tiempo real WebSocket
│   │       │       └── Resultados/
│   │       │           └── page.tsx
│   │       ├── Estudiantes/
│   │       │   ├── page.tsx
│   │       │   ├── Nuevo/
│   │       │   │   └── page.tsx
│   │       │   └── [idEstudiante]/
│   │       │       └── page.tsx
│   │       ├── Reportes/
│   │       │   └── page.tsx
│   │       └── Configuracion/
│   │           └── page.tsx
│   ├── Componentes/
│   │   ├── Comunes/
│   │   │   ├── Cargando.tsx
│   │   │   ├── EstadoVacio.tsx
│   │   │   ├── ErrorLimite.tsx
│   │   │   ├── ModalConfirmacion.tsx
│   │   │   └── BreadcrumbNavegacion.tsx
│   │   ├── Examenes/
│   │   │   ├── TablaExamenes.tsx
│   │   │   ├── FormularioExamen.tsx
│   │   │   ├── EditorPreguntas.tsx            ← Componente más complejo
│   │   │   ├── TarjetaPregunta.tsx
│   │   │   ├── FormularioPregunta.tsx
│   │   │   ├── ListaOpciones.tsx
│   │   │   └── InsigniaEstado.tsx
│   │   ├── Sesiones/
│   │   │   ├── TablaSesiones.tsx
│   │   │   ├── MonitorTiempoReal.tsx
│   │   │   ├── TarjetaEstudianteMonitor.tsx
│   │   │   ├── AlertaFraude.tsx
│   │   │   └── PanelCodigoAcceso.tsx
│   │   ├── Reportes/
│   │   │   ├── GraficaDistribucion.tsx
│   │   │   ├── GraficaDificultadPreguntas.tsx
│   │   │   └── TablaResultadosDetallada.tsx
│   │   └── Layout/
│   │       ├── BarraLateral.tsx
│   │       ├── EncabezadoAdmin.tsx
│   │       └── MenuUsuario.tsx
│   ├── Hooks/
│   │   ├── useAutenticacion.ts
│   │   ├── useExamenes.ts
│   │   ├── useSesiones.ts
│   │   ├── useMonitorTiempoReal.ts
│   │   ├── useEstudiantes.ts
│   │   └── useReportes.ts
│   ├── Servicios/
│   │   ├── ApiCliente.ts
│   │   ├── Autenticacion.servicio.ts
│   │   ├── Examenes.servicio.ts
│   │   ├── Preguntas.servicio.ts
│   │   ├── Sesiones.servicio.ts
│   │   ├── Intentos.servicio.ts
│   │   ├── Respuestas.servicio.ts
│   │   └── Reportes.servicio.ts
│   ├── Almacen/
│   │   ├── AutenticacionAlmacen.ts
│   │   ├── SesionAlmacen.ts
│   │   └── UiAlmacen.ts
│   ├── Tipos/
│   │   └── index.ts                           ← Re-exporta desde Compartido/
│   ├── Constantes/
│   │   ├── Rutas.constantes.ts
│   │   └── Api.constantes.ts
│   └── Lib/
│       ├── utils.ts
│       └── validaciones.ts
├── public/
├── .env.local
├── .env.local.ejemplo
├── next.config.js
├── tailwind.config.ts
├── components.json                            ← Config shadcn/ui
├── tsconfig.json
└── package.json
```

---

## CONVENCIONES ESPECÍFICAS DE NEXT.JS 16 APP ROUTER

### Páginas vs Componentes

- Las **páginas** (`page.tsx`) son Server Components por defecto. Solo añadir `'use client'`
  si la página necesita estado, efectos o interactividad directa.
- Los **componentes** en `Componentes/` que usen hooks React o eventos del DOM deben tener
  `'use client'` como primera línea.
- Las llamadas a la API desde Server Components se hacen directamente con `fetch` de Next.js
  (con las opciones de caché de Next.js). Desde Client Components, usar los hooks de React Query.

### Sistema de Autenticación

**`src/Almacen/AutenticacionAlmacen.ts`** — Zustand store:

```typescript
interface EstadoAutenticacion {
  usuario: RespuestaUsuarioDto | null;
  estaAutenticado: boolean;
  cargando: boolean;
  iniciarSesion: (credenciales: IniciarSesionDto) => Promise<void>;
  cerrarSesion: () => Promise<void>;
  verificarSesion: () => Promise<void>;
}
```

- `iniciarSesion`: Llama a `Autenticacion.servicio.ts`. Guarda `tokenAcceso` en
  memory store (variable de módulo). Guarda `tokenRefresh` en cookie httpOnly
  mediante el endpoint interno de Next.js `/api/auth/sesion`.
- `verificarSesion`: Se llama en el layout `(admin)/layout.tsx` al montar. Si falla, redirige.
- `cerrarSesion`: Llama al backend, limpia el store, elimina la cookie.

**`src/app/api/auth/sesion/route.ts`** — Endpoint interno de Next.js para gestionar cookies httpOnly:
- `POST`: recibe `{ tokenRefresh }` y lo guarda como cookie httpOnly.
- `DELETE`: elimina la cookie.

### `src/Servicios/ApiCliente.ts` — Axios con interceptores

```typescript
// Instancia configurada con baseURL desde NEXT_PUBLIC_API_URL
// Interceptor REQUEST: agrega 'Authorization: Bearer {tokenAcceso}' del store Zustand
// Interceptor RESPONSE (401):
//   1. Si el error es 401 y no es el endpoint de refresh:
//      a. Llama a POST /autenticacion/refrescar-tokens con el tokenRefresh de la cookie
//      b. Actualiza el tokenAcceso en el store Zustand
//      c. Reintenta la petición original con el nuevo token
//   2. Si el refresh también falla:
//      a. Llama a cerrarSesion() del store
//      b. Redirige a /IniciarSesion
```

### React Query — Convenciones

- Todas las queries usan llaves (query keys) en español estructuradas:
  ```typescript
  ['examenes']                    // lista
  ['examenes', idExamen]          // individual
  ['sesiones']
  ['sesiones', idSesion]
  ['reportes', 'sesion', idSesion]
  ```
- `staleTime` por defecto: 2 minutos para datos que cambian poco.
- `refetchOnWindowFocus: false` para datos de exámenes (evitar peticiones innecesarias).
- Datos del monitor en tiempo real NO usar React Query — usar el WebSocket directamente.

---

## DETALLE DE COMPONENTES CRÍTICOS

### `EditorPreguntas.tsx`

Este es el componente más complejo. Su comportamiento exacto:

1. **Lista de preguntas con drag-and-drop** usando `@dnd-kit/core` y `@dnd-kit/sortable`.
   - Al soltar, llama inmediatamente a `PATCH /examenes/:id/preguntas/reordenar`.
2. **Botón "Agregar Pregunta"** abre un `Dialog` de shadcn/ui con `FormularioPregunta.tsx`.
3. **`FormularioPregunta.tsx`** usa `react-hook-form` + `zod`:
   - Campo: tipo de pregunta (select).
   - Campo: enunciado (textarea).
   - Campo: puntaje (number input, min 0.1).
   - Campo: tiempo sugerido en segundos (opcional, number input).
   - Sección dinámica de opciones (solo si tipo !== `RESPUESTA_ABIERTA`):
     - Lista de campos `[letra, contenido, esCorrecta]`.
     - Botón "Agregar opción" (máximo 5).
     - Botón "Eliminar" por opción.
     - Checkbox "Correcta" — para `OPCION_MULTIPLE` y `VERDADERO_FALSO`, es radio button
       (solo uno seleccionable). Para `SELECCION_MULTIPLE`, es checkbox normal.
4. Al guardar el formulario, llama a `POST /examenes/:idExamen/preguntas`.
5. Si la llamada tiene éxito, cierra el Dialog e invalida el query `['examenes', idExamen]`.
6. Muestra estado de carga durante la mutación. Muestra toast de error si falla.

### `MonitorTiempoReal.tsx`

1. Al montar, conecta a WebSocket con `socket.io-client` usando `NEXT_PUBLIC_WEBSOCKET_URL`.
2. Emite `unirse_sala_sesion` con `{ idSesion, rol: RolUsuario.DOCENTE }`.
3. Escucha `estudiante:progreso` → actualiza la tarjeta del estudiante en el estado local.
4. Escucha `estudiante:fraude_detectado` → muestra toast rojo prominente con:
   - Nombre del estudiante.
   - Tipo de evento en español legible.
   - Timestamp.
   - Guarda en un array local `alertasFraude` para mostrar historial en la sesión.
5. Escucha `sesion:finalizada` → redirige automáticamente a `/Sesiones/[idSesion]/Resultados`.
6. Al desmontar el componente, desconectar el socket (`socket.disconnect()`).
7. Botón "Finalizar Sesión para Todos" → abre `ModalConfirmacion.tsx` → si confirma,
   llama a `POST /sesiones/:id/finalizar`.

### `TarjetaEstudianteMonitor.tsx`

Muestra por cada estudiante conectado:
- Nombre completo.
- Avatar con iniciales (no imagen externa — generado con CSS).
- Barra de progreso: `preguntasRespondidas / totalPreguntas * 100`.
- Ícono de escudo: verde si modo kiosco activo, rojo con alerta si fue desactivado.
- Contador de eventos de fraude (badge rojo si > 0).
- Estado del intento: chip de color según `EstadoIntento`.

---

## GESTIÓN DE ESTADO — REGLAS

### Cuándo usar qué

| Tipo de dato | Herramienta |
|---|---|
| Estado de autenticación (usuario, token) | Zustand `AutenticacionAlmacen` |
| Estado global de UI (sidebar abierto, tema) | Zustand `UiAlmacen` |
| Datos del servidor (exámenes, sesiones, etc.) | React Query |
| Estado local de un formulario | `react-hook-form` |
| Estado local de un componente (modal abierto/cerrado) | `useState` de React |
| Datos en tiempo real del WebSocket | `useState` local en el componente monitor |

### Zustand — Patrón de store

```typescript
// Siempre usar el patrón con immer para updates complejos
// Siempre tipar el estado completamente
// Nunca guardar datos del servidor en Zustand — para eso está React Query
```

---

## FORMULARIOS — REGLAS

- Siempre usar `react-hook-form` + `zod` para validación.
- Definir el esquema Zod en `src/Lib/validaciones.ts`.
- Errores de validación: mostrar inline bajo cada campo, en español.
- Estado de carga durante submit: deshabilitar botón de submit + mostrar spinner.
- Éxito: mostrar toast verde con mensaje en español + limpiar formulario o redirigir.
- Error del servidor: mostrar toast rojo con el mensaje de error de la API.

---

## RUTAS Y NAVEGACIÓN

**Archivo:** `src/Constantes/Rutas.constantes.ts`

```typescript
// Todas las rutas del sistema en un solo lugar
export const RUTAS = {
  INICIO_SESION: '/IniciarSesion',
  TABLERO: '/Tablero',
  EXAMENES: '/Examenes',
  EXAMEN_NUEVO: '/Examenes/Nuevo',
  EXAMEN_DETALLE: (id: string) => `/Examenes/${id}`,
  EXAMEN_EDITAR: (id: string) => `/Examenes/${id}/Editar`,
  SESIONES: '/Sesiones',
  SESION_NUEVA: '/Sesiones/Nueva',
  SESION_DETALLE: (id: string) => `/Sesiones/${id}`,
  SESION_RESULTADOS: (id: string) => `/Sesiones/${id}/Resultados`,
  ESTUDIANTES: '/Estudiantes',
  ESTUDIANTE_NUEVO: '/Estudiantes/Nuevo',
  REPORTES: '/Reportes',
  CONFIGURACION: '/Configuracion',
} as const;
```

---

## VALIDACIONES ZOD PARA FORMULARIOS

**Archivo:** `src/Lib/validaciones.ts`

Definir los esquemas Zod para cada formulario. Ejemplo del patrón:

```typescript
export const esquemaCrearExamen = z.object({
  titulo: z.string().min(3, 'El título debe tener al menos 3 caracteres').max(200),
  descripcion: z.string().max(1000).optional(),
  instrucciones: z.string().max(2000).optional(),
  modalidad: z.nativeEnum(ModalidadExamen, {
    errorMap: () => ({ message: 'Selecciona una modalidad válida' }),
  }),
  duracionMinutos: z.number().min(5, 'Mínimo 5 minutos').max(480, 'Máximo 8 horas'),
  permitirNavegacion: z.boolean(),
  mostrarPuntaje: z.boolean(),
});
```

---

## COMPONENTES UI — REGLAS DE SHADCN/UI

- Usar **siempre** los componentes de shadcn/ui para elementos UI estándar.
  No crear botones, inputs, selects, dialogs, toasts desde cero.
- Los toasts usan `sonner` (integrado en shadcn/ui).
- Las tablas usan `@tanstack/react-table` + el componente `Table` de shadcn/ui.
- El tema de colores (primario, secundario) se define en `tailwind.config.ts` y `globals.css`.
  No hardcodear colores hexadecimales en componentes. Usar las variables CSS del tema.

---

## MANEJO DE ERRORES EN CLIENTE

- **Error 401 no manejado por el interceptor** (ej: refresh falló): redirigir a login.
- **Error 403**: mostrar mensaje "No tienes permisos para esta acción".
- **Error 404**: mostrar `EstadoVacio.tsx` con mensaje descriptivo y botón para volver.
- **Error 500**: mostrar toast rojo con "Ocurrió un error en el servidor. Intenta de nuevo."
- **Error de red (sin conexión)**: toast amarillo "Sin conexión. Verifica tu internet."
- Implementar `ErrorBoundary` en el layout `(admin)/layout.tsx` para errores no capturados.

---

## TABLERO — DATOS REALES (SIN MOCKS)

El tablero muestra exclusivamente datos reales del backend:

1. `GET /reportes/sesion/activas-hoy` → número de sesiones activas hoy.
2. `GET /sesiones?estado=ACTIVA` → número de sesiones activas ahora.
3. `GET /usuarios?rol=ESTUDIANTE&conectadosAhora=true` → estudiantes conectados (via WS).
4. `GET /sesiones?limite=5&orden=fechaCreacion_desc` → últimas 5 sesiones.
5. `GET /reportes/actividad-semanal` → datos para la gráfica de Recharts (últimos 7 días).

Todos con `refetchInterval: 30000` (refresco cada 30 segundos).