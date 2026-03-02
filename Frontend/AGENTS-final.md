# AGENTS-final.md - EvalPro Frontend Admin (Especificacion Operativa Completa)
> Documento de cierre funcional para `Frontend/` (Next.js 16 App Router).
> Complementa `AGENTS.md` raiz, `Frontend/AGENTS.md` y el AGENTS de diseno del frontend.
> Si hay conflicto: 1) `AGENTS.md` raiz, 2) `Frontend/AGENTS.md`, 3) este archivo.
> Fecha de referencia: 2026-03-02.

---

## 1) Objetivo

Definir con precision como debe funcionar TODO el frontend admin para:

1. Aprovechar completamente la logica del backend.
2. Mantener seguridad real en autenticacion y autorizacion en cliente.
3. Implementar UX consistente para docentes y administradores.
4. Evitar huecos entre servicios, hooks, stores, rutas y componentes.
5. Entregar criterios verificables de calidad y pruebas.

---

## 2) Alcance y usuarios del panel

El panel web admin esta orientado a:

1. `DOCENTE`: flujo operativo principal (examenes, preguntas, sesiones, monitor, reportes de sus sesiones).
2. `ADMINISTRADOR`: gestion transversal (usuarios, supervision y auditoria global).

`ESTUDIANTE` NO usa el panel admin. Si inicia sesion en web, se debe bloquear acceso a rutas `(admin)`.

---

## 3) Arquitectura frontend completa

### 3.1 Capas y responsabilidades

1. `src/app/`: composicion de rutas y layouts.
2. `src/Servicios/`: consumo HTTP, parseo de contrato API, sin logica visual.
3. `src/Hooks/`: orquestacion React Query y estado de modulo.
4. `src/Almacen/`: estado global UI/autenticacion (Zustand).
5. `src/Componentes/`: renderizado UI puro y eventos hacia hooks/servicios.
6. `src/Constantes/`: rutas, endpoints y eventos unificados.
7. `src/Lib/`: validaciones y utilidades compartidas.

Regla obligatoria: la UI NO llama `fetch/axios` directo. Siempre via `Servicios` + hooks.

### 3.2 Mapa operativo por carpeta

| Carpeta | Que debe contener | Que no debe contener |
|---|---|---|
| `app/(autenticacion)` | login y flujo previo a sesion | logica de negocio de examenes |
| `app/(admin)` | paginas protegidas por sesion/rol | llamadas HTTP directas |
| `Servicios` | wrappers endpoint por dominio | estado reactivo de UI |
| `Hooks` | queries/mutations y transformaciones ligeras | JSX pesado de presentacion |
| `Componentes` | UI, formularios y eventos | reglas de permiso de backend |
| `Almacen` | estado global estable (auth/ui) | cache de listas de servidor |

---

## 4) Modelo de autenticacion web (obligatorio)

### 4.1 Tokens y almacenamiento

1. `tokenAcceso`:
   - solo en memoria (`ApiCliente.ts`).
   - nunca en `localStorage`, `sessionStorage` ni cookies JS.
2. `tokenRefresh`:
   - solo en cookie `httpOnly` (`/api/auth/sesion`).
   - renovado por `/api/auth/refrescar`.

### 4.2 Flujo completo de inicio de sesion

1. Usuario envia credenciales en `IniciarSesion`.
2. `Autenticacion.servicio.iniciarSesion()` llama backend.
3. Frontend:
   - guarda refresh en cookie `httpOnly`.
   - guarda access token en memoria.
   - guarda usuario en `AutenticacionAlmacen`.
4. Layout admin ejecuta `verificarSesion()` al montar.
5. Si no hay sesion valida -> redireccion a `RUTAS.INICIO_SESION`.

### 4.3 Flujo de refresco automatico

1. `ApiCliente` detecta `401`.
2. Si la request no fue reintentada:
   - llama `/api/auth/refrescar`.
   - obtiene nuevo access token.
   - reintenta solicitud original.
3. Si falla refresco:
   - limpia cookie refresh.
   - limpia token de memoria.
   - redirige a login.

### 4.4 Reglas de seguridad frontend auth

1. Nunca exponer refresh token en estado React.
2. Nunca imprimir tokens en consola.
3. Toda ruta `(admin)` requiere sesion valida y rol permitido.
4. En cierre de sesion:
   - llamar backend `cerrar-sesion`.
   - limpiar cookie refresh.
   - limpiar store y cache.

---

## 5) Matriz de permisos en UI (rutas y acciones)

> Esta matriz es de UX/autorizacion de interfaz. Backend sigue siendo autoridad final.

| Ruta / accion UI | ADMINISTRADOR | DOCENTE | ESTUDIANTE |
|---|---|---|---|
| `/(admin)/Tablero` | Si | Si | No |
| `/(admin)/Examenes` listar | Si | Si | No |
| Crear examen | No (API actual) | Si | No |
| Editar/publicar/archivar examen | No (API actual) | Si (propio) | No |
| Gestion de preguntas | No (API actual) | Si (examen propio) | No |
| `/(admin)/Sesiones` listar | Si | Si | No |
| Crear/activar/finalizar sesion | No (API actual) | Si (propia) | No |
| Monitor tiempo real | Si (lectura) | Si (control sesion propia) | No |
| `/(admin)/Estudiantes` | Si | Si (solo consulta autorizada) | No |
| `/(admin)/Reportes` | Si | Si (alcance propio) | No |
| `/(admin)/Configuracion` | Si | Si | No |

Reglas UI obligatorias:

1. Ocultar acciones no permitidas por rol.
2. Deshabilitar botones segun estado de dominio.
3. Si backend responde `403`, mostrar mensaje y no romper pantalla.

---

## 6) Contrato API usado por frontend (fuente unica)

### 6.1 Endpoints activos obligatorios

Autenticacion:
1. `POST /autenticacion/iniciar-sesion`
2. `POST /autenticacion/refrescar-tokens`
3. `POST /autenticacion/cerrar-sesion`

Examenes:
1. `GET /examenes`
2. `POST /examenes`
3. `GET /examenes/:id`
4. `PATCH /examenes/:id`
5. `DELETE /examenes/:id`
6. `POST /examenes/:id/publicar`

Preguntas:
1. `GET /examenes/:idExamen/preguntas`
2. `POST /examenes/:idExamen/preguntas`
3. `PUT /examenes/:idExamen/preguntas/:id`
4. `DELETE /examenes/:idExamen/preguntas/:id`
5. `PATCH /examenes/:idExamen/preguntas/reordenar`

Sesiones:
1. `GET /sesiones`
2. `POST /sesiones`
3. `GET /sesiones/:id`
4. `POST /sesiones/:id/activar`
5. `POST /sesiones/:id/finalizar`
6. `GET /sesiones/buscar/:codigo`

Reportes:
1. `GET /reportes/sesion/:idSesion`
2. `GET /reportes/estudiante/:idEstudiante`

### 6.2 Contrato de respuesta estandar

Toda llamada de `Servicios/` debe parsear:

```json
{
  "exito": true,
  "datos": {},
  "mensaje": "Operacion completada exitosamente",
  "marcaTiempo": "2026-03-02T00:00:00.000Z"
}
```

Si `exito = false` o `datos = null`, servicio lanza error controlado.

---

## 7) Estado y cache (Zustand + React Query)

### 7.1 Que va en Zustand

1. `AutenticacionAlmacen`: usuario, sesion local, acciones de login/logout/verify.
2. `UiAlmacen`: estado UI global (sidebar, modales globales, preferencias).
3. `SesionAlmacen`: estado efimero de monitor si no es dato persistible.

### 7.2 Que va en React Query

1. Listas y detalles de examenes/sesiones/reportes.
2. Mutaciones de crear/editar/publicar/finalizar.
3. Invalidaciones por dominio tras cada mutacion.

Query keys obligatorias:

1. `['examenes']`
2. `['examenes', idExamen]`
3. `['preguntas', idExamen]`
4. `['sesiones']`
5. `['sesiones', idSesion]`
6. `['reportes', 'sesion', idSesion]`
7. `['reportes', 'estudiante', idEstudiante]`

### 7.3 Que NO va en React Query

Eventos tiempo real de socket (progreso/fraude). Eso va en estado local del monitor.

---

## 8) Flujo funcional completo por modulo

## 8.1 Examenes

Flujo base docente:

1. Crear examen en BORRADOR.
2. Agregar/editar/reordenar preguntas.
3. Publicar examen.
4. Archivar cuando no se usara.

Reglas UI:

1. Si estado != BORRADOR, bloquear edicion de contenido.
2. Boton publicar visible solo en BORRADOR.
3. Si backend responde `EXAMEN_SIN_PREGUNTAS`, mostrar mensaje explicito.
4. Drag and drop reordena y persiste de inmediato.

## 8.2 Sesiones

Flujo base docente:

1. Crear sesion sobre examen PUBLICADO.
2. Activar sesion (PENDIENTE -> ACTIVA).
3. Monitorear progreso/fraude.
4. Finalizar sesion (ACTIVA -> FINALIZADA).
5. Ir a resultados.

Reglas UI:

1. Activar solo cuando estado `PENDIENTE`.
2. Finalizar solo cuando estado `ACTIVA`.
3. Mostrar codigo de acceso con accion copiar.
4. Actualizar estado en UI post accion sin recargar pagina completa.

## 8.3 Monitor en tiempo real

Flujo tecnico:

1. Conectar `socket.io-client` a namespace `/sesiones`.
2. Emitir `unirse_sala_sesion` con `{ idSesion, rol }`.
3. Escuchar:
   - `estudiante:progreso`
   - `estudiante:fraude_detectado`
   - `sesion:finalizada`
4. Al desmontar: `socket.disconnect()`.

Reglas:

1. Si llega fraude, toast rojo + registrar en historial local.
2. Si llega `sesion:finalizada`, redirigir automaticamente a resultados.
3. Boton "Finalizar sesion para todos" exige confirmacion.

## 8.4 Reportes

Sesion:
1. Mostrar metricas agregadas (`promedio`, `maximo`, `minimo`, sospechosos).
2. Graficas:
   - distribucion de puntajes
   - dificultad por pregunta
3. Tabla detallada por estudiante.

Estudiante:
1. Historial de intentos.
2. Estado y porcentaje por sesion.
3. Marcacion de sospecha cuando aplique.

---

## 9) Formularios y validacion

Reglas obligatorias:

1. `react-hook-form` + `zod` para todo formulario.
2. Esquemas en `Lib/validaciones.ts`.
3. Mensajes de error en espanol.
4. Submit bloqueado durante mutacion.
5. Toaster:
   - exito: feedback positivo breve
   - error: mensaje backend o fallback seguro

Casos criticos:

1. Formulario pregunta valida consistencia de opciones por `TipoPregunta`.
2. Formulario sesion valida `idExamen` existente.
3. Login valida correo/contrasena no vacios.

---

## 10) Reglas de interfaz por estado de dominio

### 10.1 Examen

| Estado | Acciones habilitadas UI |
|---|---|
| BORRADOR | editar, preguntas, publicar, archivar |
| PUBLICADO | crear sesiones, archivar, ver detalle |
| ARCHIVADO | solo lectura |

### 10.2 Sesion

| Estado | Acciones habilitadas UI |
|---|---|
| PENDIENTE | activar, ver detalle |
| ACTIVA | monitor, finalizar |
| FINALIZADA | resultados, reportes |
| CANCELADA | solo lectura |

### 10.3 Intento (vista monitor/reporte)

| Estado | Significado UI |
|---|---|
| EN_PROGRESO | estudiante activo |
| ENVIADO | entregado |
| ANULADO | invalidado por decision docente |
| SINCRONIZACION_PENDIENTE | enviado offline pendiente confirmacion |

---

## 11) Seguridad frontend no negociable

1. No usar `dangerouslySetInnerHTML` con datos de usuario.
2. No mostrar campos sensibles en UI/logs.
3. Manejar `401`, `403`, `404`, `409`, `422`, `500` de forma diferenciada.
4. Limpiar estado local al expirar sesion.
5. No depender de checks de cliente para seguridad real (backend siempre valida).
6. Evitar filtrado de informacion interna en mensajes de error.

---

## 12) Manejo de errores y resiliencia

Politica por codigo:

1. `401`: refrescar token o redirigir login.
2. `403`: toast "No tienes permisos".
3. `404`: estado vacio con CTA de regreso.
4. `409`: conflicto de estado (sesion no activa, intento duplicado, etc).
5. `422`: validacion de negocio (ej. examen sin preguntas).
6. `500`: mensaje generico y log de observabilidad.

Fallbacks:

1. Si websocket cae, mostrar banner "conexion en tiempo real interrumpida".
2. Si reconecta, re-unirse automaticamente a la sala.

---

## 13) Integracion con AGENTS de diseno

Este archivo define logica funcional. El diseno visual debe cumplir ademas:

1. Variables CSS y tipografias oficiales.
2. Sistema de componentes UI especificado.
3. Accesibilidad/focus/contraste obligatorios.
4. Responsive definido para admin desktop-first.

Regla: no sacrificar logica por diseno ni diseno por atajos de logica.

---

## 14) Matriz minima de pruebas frontend

### 14.1 Autenticacion

1. Login exitoso guarda estado y cookie.
2. Interceptor refresca token tras 401 y reintenta request.
3. Fallo de refresh fuerza logout limpio.

### 14.2 Permisos UI

1. Acciones de docente visibles/ocultas segun rol.
2. Estudiante no accede a rutas admin.
3. Estados de examen/sesion bloquean botones invalidos.

### 14.3 Flujos de negocio

1. Crear examen -> agregar preguntas -> publicar.
2. Crear sesion -> activar -> monitor -> finalizar.
3. Reporte sesion renderiza graficas y tabla con datos backend.

### 14.4 Tiempo real

1. Socket une sala correcta.
2. Evento fraude genera alerta visible.
3. Evento sesion finalizada redirige a resultados.

---

## 15) Brechas detectadas en base frontend actual (a cerrar)

1. Servicios de tablero consumen rutas de reportes no implementadas en backend actual.
2. Monitor tiempo real usa placeholders de nombre estudiante cuando falta payload enriquecido.
3. Falta gate explicito por rol en algunas pantallas del grupo admin.
4. Falta politica uniforme de invalidaciones React Query tras mutaciones complejas.
5. Falta suite de pruebas automatizadas de auth/interceptor/socket.

---

## 16) Plan de implementacion recomendado

Fase A - Seguridad y sesion:
1. endurecer guard de rutas `(admin)` por rol real.
2. estandarizar cierre de sesion en todo fallo terminal de auth.
3. revisar rutas internas `/api/auth/*` para evitar drift con backend.

Fase B - Dominio:
1. alinear tablero a endpoints existentes o implementar agregados backend faltantes.
2. completar UX por estados de examen/sesion.
3. reforzar monitor tiempo real con identificacion de estudiantes.

Fase C - Calidad:
1. pruebas unitarias de servicios/hook de auth.
2. pruebas de integracion de flujos criticos.
3. pruebas de componentes clave (editor preguntas, monitor, reportes).

---

## 17) Definition of Done frontend

El frontend se considera cerrado cuando:

1. Todas las rutas/admin acciones obedecen matriz de permisos.
2. Flujo auth + refresh funciona sin fugas de token.
3. Examenes/sesiones/reportes operan end-to-end con backend real.
4. Websocket monitoriza progreso y fraude sin fugas de conexion.
5. Errores de red/permiso/estado se gestionan con UX consistente.
6. Pruebas de regresion de flujos criticos estan en verde.
7. Cumple la guia visual definida en el AGENTS de diseno del frontend.
