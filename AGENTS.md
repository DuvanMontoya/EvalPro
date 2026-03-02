# AGENTS.md — EvalPro · Reglas Globales del Proyecto
> **Leído automáticamente por: Cursor, Codex CLI, Claude Code, Windsurf, Gemini CLI.**
> **Nunca modificar sin revisar impacto en todos los módulos.**
> **Los AGENTS.md de subcarpeta amplían estas reglas. Nunca las contradicen.**

---

## IDENTIDAD DEL PROYECTO

**Nombre del sistema:** EvalPro — Ecosistema de Evaluación Académica Automatizado
**Descripción:** Monorepo con tres capas: API REST + WebSocket (NestJS), Panel Administrativo
Web (Next.js 14), y App Móvil (Flutter). Permite a docentes crear evaluaciones digitales que
estudiantes responden desde sus propios teléfonos con mecanismos de anti-trampa (Modo Kiosco).
**Dos modalidades de examen:**
- `DIGITAL_COMPLETO` → preguntas y respuestas completamente en la app móvil.
- `HOJA_RESPUESTAS` → examen impreso en papel; la app solo captura las letras A/B/C/D/E como
  una cuadrícula OMR/Scantron digital.

---

## LEY #1 — IDIOMA (SIN EXCEPCIONES EN NINGÚN ARCHIVO)

| Elemento | Convención | ✅ Correcto | ❌ Prohibido |
|---|---|---|---|
| Carpetas | PascalCase español | `Autenticacion/` | `auth/`, `Authentication/` |
| Archivos TS/TSX | PascalCase español | `ExamenServicio.ts` | `examService.ts` |
| Archivos Dart | PascalCase español | `SesionExamen.dart` | `sessionExam.dart` |
| Variables | camelCase español | `idExamen`, `fechaCreacion` | `examId`, `createdAt` |
| Funciones/métodos | camelCase español | `obtenerPorId()` | `getById()` |
| Clases / Interfaces | PascalCase español | `SesionExamen` | `ExamSession` |
| Tablas PostgreSQL | snake_case español | `sesion_examen` | `exam_session` |
| Modelos Prisma | PascalCase español | `model SesionExamen {}` | `model ExamSession {}` |
| Enums Prisma | SCREAMING_SNAKE español | `OPCION_MULTIPLE` | `MULTIPLE_CHOICE` |
| Comentarios | Español completo | `// Calcula puntaje` | `// Calculate score` |
| Mensajes de error | Español | `"Examen no encontrado"` | `"Exam not found"` |
| Mensajes UI | Español | `"Iniciar sesión"` | `"Login"` |
| Commits Git | Español | `"Agrega módulo sesiones"` | `"Add sessions module"` |

---

## LEY #2 — ENCABEZADO OBLIGATORIO EN CADA ARCHIVO DE CÓDIGO

**Sin excepción. Primer bloque de cada archivo antes de cualquier import:**

Para TypeScript / TSX:
```typescript
/**
 * @archivo   NombreExactoDelArchivo.ts
 * @descripcion Qué hace este archivo en una oración. No repetir el nombre.
 * @modulo    NombreDelModuloContenedor
 * @autor     EvalPro
 * @fecha     YYYY-MM-DD
 */
```

Para Dart:
```dart
/// @archivo   NombreExactoDelArchivo.dart
/// @descripcion Qué hace este archivo en una oración. No repetir el nombre.
/// @modulo    NombreDelModuloContenedor
/// @autor     EvalPro
/// @fecha     YYYY-MM-DD
```

Para Kotlin / Swift:
```kotlin
/**
 * @archivo   NombreArchivo.kt
 * @descripcion Qué hace este archivo. No repetir el nombre.
 * @modulo    ModoKiosco (Android nativo)
 * @autor     EvalPro
 * @fecha     YYYY-MM-DD
 */
```

---

## LEY #3 — DOCUMENTACIÓN DE FUNCIONES (OBLIGATORIA)

Toda función o método público debe tener JSDoc/DartDoc antes de su firma:

```typescript
/**
 * Calcula el puntaje total de un intento sumando respuestas correctas.
 * @param idIntento - UUID del intento a calificar
 * @returns Objeto con puntajeObtenido (float) y porcentaje (float 0-100)
 * @throws NotFoundException si el intento no existe en la base de datos
 * @throws BadRequestException si el intento ya fue calificado previamente
 */
async calcularPuntaje(idIntento: string): Promise<ResultadoPuntajeDto> {
```

---

## LEY #4 — MODULARIDAD Y TAMAÑO

- **Máximo 200 líneas por archivo.** Si se supera, dividir en sub-módulos.
- **Una sola responsabilidad por archivo** (SRP — Principio de Responsabilidad Única).
- **Sin código duplicado.** Si una lógica aparece en dos lugares, extraerla a utilidad.
- **Sin magic strings.** Toda constante de texto va en `*.constantes.ts` o `Constantes.dart`.
- **Sin magic numbers.** Todo número con significado va en constantes nombradas.
- **Sin datos hardcodeados.** Todo viene de `.env`, base de datos, o parámetros de función.
- **Sin tipos `any` en TypeScript.** Usar tipos explícitos o genéricos siempre.

---

## ARQUITECTURA GENERAL DEL SISTEMA

```
EvalPro/
├── AGENTS.md                    ← Este archivo
├── Backend/                     ← NestJS + Prisma + PostgreSQL (Puerto 3001)
│   └── AGENTS.md
├── Frontend/                    ← Next.js 14 App Router (Puerto 3000)
│   └── AGENTS.md
├── Movil/                       ← Flutter 3.x — iOS + Android (BYOD)
│   └── AGENTS.md
├── Compartido/                  ← Tipos TypeScript compartidos BE↔FE
│   └── src/
│       ├── Tipos/
│       ├── Enums/
│       └── index.ts
├── docker-compose.yml
├── docker-compose.dev.yml
├── .env.ejemplo
└── .gitignore
```

---

## STACK COMPLETO Y VERSIONES MÍNIMAS

| Capa | Tecnología | Versión |
|---|---|---|
| Backend | NestJS | 10.x |
| ORM | Prisma | 5.x |
| Base de datos | PostgreSQL | 15.x |
| Auth | @nestjs/jwt + Passport | última |
| Validación | class-validator + class-transformer | última |
| Hash passwords | bcrypt | última |
| Tiempo real | @nestjs/websockets + socket.io | última |
| Docs API | @nestjs/swagger | última |
| Frontend | Next.js | 14.x (App Router) |
| UI | shadcn/ui + Tailwind CSS | última |
| Estado FE | Zustand | última |
| HTTP FE | axios + TanStack React Query | última |
| Formularios FE | react-hook-form + zod | última |
| Tablas FE | @tanstack/react-table | última |
| Gráficas FE | Recharts | última |
| DnD FE | @dnd-kit/core | última |
| Socket FE | socket.io-client | última |
| App móvil | Flutter | 3.x |
| Estado móvil | Riverpod | 2.x |
| HTTP móvil | Dio | última |
| DB local | Drift (SQLite) | última |
| Tokens seguros | flutter_secure_storage | última |
| Socket móvil | socket_io_client (Dart) | última |
| Conectividad | connectivity_plus | última |

---

## ENUMERACIONES — FUENTE ÚNICA DE VERDAD

Definidas en `Compartido/src/Enums/` y replicadas idénticas en `Movil/lib/Modelos/Enums/`.
**Nunca crear enumeraciones propias por módulo. Siempre usar estas.**

### `RolUsuario`
```
ADMINISTRADOR  → Gestión total del sistema
DOCENTE        → Crea exámenes, gestiona sesiones, ve reportes
ESTUDIANTE     → Solo responde exámenes desde la app móvil
```

### `TipoPregunta`
```
OPCION_MULTIPLE    → Una respuesta correcta. Opciones: mínimo 2, máximo 5.
SELECCION_MULTIPLE → Varias respuestas correctas. El estudiante selecciona todas.
RESPUESTA_ABIERTA  → Campo de texto libre. Calificación manual por el docente.
VERDADERO_FALSO    → Exactamente dos opciones: "Verdadero" y "Falso".
```

### `ModalidadExamen`
```
DIGITAL_COMPLETO  → Preguntas visibles en la app. Una pregunta por pantalla.
HOJA_RESPUESTAS   → Solo cuadrícula A/B/C/D/E. El examen físico está en papel.
```

### `EstadoExamen`
```
BORRADOR   → En edición. No disponible para sesiones ni estudiantes.
PUBLICADO  → Disponible para crear sesiones.
ARCHIVADO  → Solo lectura. No se puede usar en nuevas sesiones.
```

### `EstadoSesion`
```
PENDIENTE  → Código generado. Esperando que el docente active.
ACTIVA     → Estudiantes pueden unirse y responder.
FINALIZADA → Docente la cerró. Puntajes calculados.
CANCELADA  → Anulada. Ningún intento es válido.
```

### `EstadoIntento`
```
EN_PROGRESO              → El estudiante está respondiendo ahora.
ENVIADO                  → Entregado correctamente. Puntaje calculado.
ANULADO                  → Invalidado (fraude grave o fallo técnico crítico).
SINCRONIZACION_PENDIENTE → Enviado offline. Esperando confirmación del servidor.
```

### `TipoEventoTelemetria`
```
INICIO_EXAMEN
CAMBIO_PREGUNTA
RESPUESTA_GUARDADA
APLICACION_EN_SEGUNDO_PLANO  → FRAUDE: app perdió foco del SO
PANTALLA_ABANDONADA          → FRAUDE: pantalla de examen abandonada
CAPTURA_BLOQUEADA            → Screenshot bloqueado por FLAG_SECURE (Android)
FORZAR_CIERRE                → Reinicio o cierre forzado del dispositivo
SESION_INVALIDA              → Sesión marcada inválida tras evento de fraude
EXAMEN_ENVIADO
SINCRONIZACION_COMPLETADA
```

---

## FORMATO ESTÁNDAR DE RESPUESTA API

El interceptor `TransformRespuesta.interceptor.ts` aplica este formato a **todas** las respuestas.

**Éxito:**
```json
{
  "exito": true,
  "datos": {},
  "mensaje": "Operación completada exitosamente",
  "marcaTiempo": "2024-01-01T10:00:00.000Z"
}
```

**Error:**
```json
{
  "exito": false,
  "datos": null,
  "mensaje": "Descripción del error en español claro",
  "codigoError": "CODIGO_EN_MAYUSCULAS",
  "marcaTiempo": "2024-01-01T10:00:00.000Z"
}
```

**Códigos de error estándar:**
| Código | HTTP | Cuándo |
|---|---|---|
| `CREDENCIALES_INVALIDAS` | 401 | Email o contraseña incorrectos |
| `TOKEN_EXPIRADO` | 401 | JWT vencido |
| `TOKEN_INVALIDO` | 401 | JWT malformado o firma inválida |
| `SIN_PERMISOS` | 403 | Rol insuficiente para la operación |
| `RECURSO_NO_ENCONTRADO` | 404 | Entidad no existe en DB |
| `VALIDACION_FALLIDA` | 400 | DTO no cumple las validaciones |
| `SESION_NO_ACTIVA` | 409 | Operación requiere sesión activa |
| `INTENTO_DUPLICADO` | 409 | Estudiante ya tiene intento en esta sesión |
| `EXAMEN_SIN_PREGUNTAS` | 422 | No se puede publicar un examen vacío |
| `ERROR_INTERNO` | 500 | Error no controlado del servidor |

---

## VARIABLES DE ENTORNO REQUERIDAS

### Backend `.env`
```bash
DATABASE_URL="postgresql://USUARIO:CONTRASENA@localhost:5432/evalPro_db?schema=public"
JWT_SECRETO_ACCESO="minimo_64_caracteres_completamente_aleatorios_acceso"
JWT_EXPIRACION_ACCESO="15m"
JWT_SECRETO_REFRESH="minimo_64_caracteres_completamente_aleatorios_refresh"
JWT_EXPIRACION_REFRESH="7d"
PUERTO_APP=3001
CORS_ORIGENES_PERMITIDOS="http://localhost:3000"
ENTORNO="desarrollo"
BCRYPT_RONDAS_HASH=12
ADMIN_CORREO_INICIAL="admin@evalPro.com"
ADMIN_CONTRASENA_INICIAL="CambiarInmediatamente123!"
TELEMETRIA_SEGUNDOS_MINIMOS_POR_PREGUNTA=3
TELEMETRIA_MAX_EVENTOS_SEGUNDO_PLANO=0
```

### Frontend `.env.local`
```bash
NEXT_PUBLIC_API_URL="http://localhost:3001/api/v1"
NEXT_PUBLIC_WEBSOCKET_URL="http://localhost:3001"
NEXT_PUBLIC_VERSION_APP="1.0.0"
```

---

## ORDEN DE CONSTRUCCIÓN GLOBAL (OBLIGATORIO — NO SALTAR PASOS)

```
FASE 1 — Fundación compartida
  1.1  Compartido/ → tipos TypeScript e interfaces compartidas
  1.2  Backend/prisma/schema.prisma → esquema completo con todos los modelos
  1.3  Ejecutar: npx prisma migrate dev --name inicio
  1.4  Backend/prisma/Semillas/Semilla.ts → solo el usuario administrador inicial

FASE 2 — Backend NestJS (en este orden exacto)
  2.1  Configuracion/ + App.module.ts + main.ts
  2.2  Comun/ → filtros globales, guards, interceptores, pipes, utilidades
  2.3  Autenticacion/ → JWT access + refresh tokens + Passport strategies
  2.4  Usuarios/ → CRUD completo con guards de roles
  2.5  Examenes/ → CRUD + publicación
  2.6  Preguntas/ → CRUD dentro de exámenes + reordenamiento
  2.7  SesionesExamen/ → ciclo de vida + WebSocket Gateway
  2.8  Respuestas/ → sincronización offline batch + calificación automática
  2.9  Telemetria/ → registro de eventos + detección de anomalías
  2.10 Reportes/ → estadísticas de sesión y estudiante

FASE 3 — Frontend Next.js Admin (en este orden)
  3.1  Sistema de auth + layout + Zustand stores + ApiCliente axios
  3.2  Tablero/ → métricas con datos reales
  3.3  Examenes/ → CRUD + EditorPreguntas con drag-and-drop
  3.4  Sesiones/ → CRUD + MonitorTiempoReal con WebSocket
  3.5  Estudiantes/ → CRUD
  3.6  Reportes/ → gráficas con Recharts

FASE 4 — App Móvil Flutter (en este orden)
  4.1  Configuracion/ + Modelos/ + Enums/ + Constantes/
  4.2  BaseDatosLocal/ → Drift: definición de tablas y DAOs
  4.3  Servicios/ → ApiServicio (Dio) + todos los servicios de negocio
  4.4  Providers/ → Riverpod providers para cada dominio
  4.5  ModoExamen/ → ModoExamenServicio + código nativo Android + iOS
  4.6  Pantallas/Autenticacion/
  4.7  Pantallas/Inicio/
  4.8  Pantallas/Examen/ → flujo completo (unirse → examen → enviar)
  4.9  Widgets/ → todos los widgets reutilizables
```

---

## PROHIBICIONES ABSOLUTAS (aplican a todo el proyecto)

1. ❌ Palabras en inglés para nombres de variables, funciones, clases, archivos o carpetas.
2. ❌ Hardcodear URLs, IDs, credenciales, textos de UI o cualquier valor configurable.
3. ❌ Crear archivo sin el bloque de encabezado de documentación.
4. ❌ Archivos de más de 200 líneas sin refactorizar en sub-módulos.
5. ❌ Retornar contraseñas, tokens completos o datos sensibles en respuestas API.
6. ❌ Usar `any` en TypeScript. Siempre tipos explícitos o genéricos.
7. ❌ Hacer peticiones HTTP directamente desde componentes UI. Siempre mediante servicios.
8. ❌ Guardar JWT en `localStorage`. Cookies httpOnly en web, `flutter_secure_storage` en móvil.
9. ❌ Omitir validación de DTOs en endpoints del backend.
10. ❌ Crear lógica no descrita en los AGENTS.md sin consultar al usuario primero.
11. ❌ Usar `console.log` en producción. Solo usar el logger de NestJS o `debugPrint` en Flutter.
12. ❌ Commit sin que el módulo respectivo compile y pase sus validaciones.