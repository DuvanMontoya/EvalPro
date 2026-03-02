Creating comprehensive AGENTS.md with complete business logic
markdown

# AGENTS.md — EvalPro: Lógica de Negocio Integral, Blindada y Definitiva
> **Versión:** 3.0.0 — 2026-03-02  
> **Alcance:** Backend (NestJS + Prisma) · Frontend (Next.js) · Móvil (Flutter) · Contratos compartidos  
> **Propósito:** Documento normativo único para agentes de IA y equipos humanos. Toda implementación debe cumplir **al 100%** cada regla aquí definida. No existe lógica implícita fuera de este archivo.

---

## ÍNDICE

1. [Principios Fundamentales e Invariantes Absolutos](#1-principios-fundamentales-e-invariantes-absolutos)
2. [Modelo de Datos Canónico](#2-modelo-de-datos-canónico)
3. [Jerarquía de Roles y Capacidades](#3-jerarquía-de-roles-y-capacidades)
4. [Máquinas de Estado — Referencia Completa](#4-máquinas-de-estado--referencia-completa)
5. [Reglas Globales de Autorización — Pipeline Obligatorio](#5-reglas-globales-de-autorización--pipeline-obligatorio)
6. [Matriz de Permisos Exhaustiva](#6-matriz-de-permisos-exhaustiva)
7. [Flujo de Identidad y Autenticación](#7-flujo-de-identidad-y-autenticación)
8. [Flujo Organizacional: Instituciones y Grupos](#8-flujo-organizacional-instituciones-y-grupos)
9. [Flujo de Evaluaciones](#9-flujo-de-evaluaciones)
10. [Flujo de Asignaciones de Examen](#10-flujo-de-asignaciones-de-examen)
11. [Flujo de Sesiones](#11-flujo-de-sesiones)
12. [Flujo de Intentos, Respuestas y Calificación](#12-flujo-de-intentos-respuestas-y-calificación)
13. [Resultados, Publicación y Reclamos](#13-resultados-publicación-y-reclamos)
14. [Telemetría y Anti-Fraude — Sistema Completo](#14-telemetría-y-anti-fraude--sistema-completo)
15. [Teoría de Juegos Aplicada — Diseño del Equilibrio](#15-teoría-de-juegos-aplicada--diseño-del-equilibrio)
16. [Contratos de API — Backend (NestJS)](#16-contratos-de-api--backend-nestjs)
17. [Contratos WebSocket — Autenticación y Eventos](#17-contratos-websocket--autenticación-y-eventos)
18. [Reglas Específicas de Frontend (Next.js)](#18-reglas-específicas-de-frontend-nextjs)
19. [Reglas Específicas de Móvil (Flutter)](#19-reglas-específicas-de-móvil-flutter)
20. [Auditoría y Trazabilidad](#20-auditoría-y-trazabilidad)
21. [Plan de Migración por Fases](#21-plan-de-migración-por-fases)
22. [Definition of Done — Criterios de Cierre](#22-definition-of-done--criterios-de-cierre)

---

## 1. Principios Fundamentales e Invariantes Absolutos

Los siguientes invariantes **nunca pueden violarse** bajo ninguna condición, flujo de error, acción administrativa, o edge case. Si una implementación los viola, es un bug crítico bloqueante.

### 1.1 Invariantes de Seguridad

| ID | Invariante | Consecuencia si se viola |
|----|-----------|--------------------------|
| INV-01 | Ningún usuario opera sobre recursos de una `Institución` diferente a la suya, excepto `SUPERADMINISTRADOR`. | Brecha de aislamiento multi-tenant. Severidad: CRÍTICA. |
| INV-02 | Ningún estudiante puede iniciar un intento sin pertenecer activamente al grupo/asignación objetivo en el momento exacto del inicio. | Acceso no autorizado a evaluaciones. Severidad: CRÍTICA. |
| INV-03 | Las respuestas correctas nunca se exponen al cliente antes de que el intento sea enviado (`ENVIADO`). | Trampa sistémica. Severidad: CRÍTICA. |
| INV-04 | Toda acción sensible deja un registro de auditoría inmutable: actor, recurso afectado, snapshot antes/después, timestamp UTC, IP, user-agent. | Imposibilidad de auditoría forense. Severidad: CRÍTICA. |
| INV-05 | Toda transición de estado inválida es rechazada con error descriptivo; nunca se ignora silenciosamente. | Corrupción de datos de dominio. Severidad: ALTA. |
| INV-06 | La anulación de un intento siempre requiere decisión humana explícita de un actor autorizado. El sistema sugiere pero nunca anula automáticamente. | Falso positivo punitivo sin recurso. Severidad: CRÍTICA. |
| INV-07 | El JWT incluye `idInstitucion`, `rol`, `sub` (userId), `iat`, `exp`. Cualquier request sin JWT válido retorna `401`. | Escalada de privilegios. Severidad: CRÍTICA. |
| INV-08 | Las contraseñas nunca viajan en texto plano, ni se almacenan sin hash bcrypt (rounds ≥ 12). | Exposición de credenciales. Severidad: CRÍTICA. |
| INV-09 | Un estudiante solo puede tener **un** intento `EN_PROGRESO` por sesión en cualquier momento. Intentos duplicados son rechazados con `409 Conflict`. | Múltiples sesiones paralelas = trampa. Severidad: CRÍTICA. |
| INV-10 | Los puntajes se recalculan desde cero sobre las respuestas almacenadas; nunca se aceptan puntajes calculados en el cliente. | Manipulación de notas. Severidad: CRÍTICA. |

### 1.2 Principios de Diseño

- **Defense in depth**: Cada capa (Gateway, Guard, Service, DB) valida independientemente. Un fallo en una capa no abre acceso.
- **Fail-closed**: En caso de ambigüedad o error de validación, se deniega el acceso.
- **Idempotencia**: Las operaciones de guardado de respuestas son idempotentes (`upsert`). Reintentos no generan duplicados.
- **Separación de lectura/escritura**: Las consultas de auditoría y reportes usan réplicas de lectura; las escrituras van al nodo primario.
- **Human-in-the-loop para sanciones**: El sistema detecta, clasifica y recomienda. Un humano autorizado aprueba toda consecuencia punitiva.

---

## 2. Modelo de Datos Canónico

### 2.1 Diagrama Relacional (texto estructurado)

```
Institucion (1) ────< PeriodoAcademico (N)
Institucion (1) ────< Usuario (N)
Institucion (1) ────< GrupoAcademico (N)

GrupoAcademico (N) >────< Docente       → GrupoDocente
GrupoAcademico (N) >────< Estudiante    → GrupoEstudiante
GrupoAcademico (N) ────< AsignacionExamen (N)

Examen (1) ────< Pregunta (N)
Pregunta (1) ────< OpcionRespuesta (N)

Examen (1) ────< AsignacionExamen (N)
AsignacionExamen (1) ────< Sesion (N)

Sesion (1) ────< Intento (N)
Intento (1) ────< RespuestaEstudiante (N)
Intento (1) ────< EventoTelemetria (N)
Intento (1) ──── ResultadoIntento (1)

ResultadoIntento (1) ────< ReclamoCalificacion (N)

AuditoriaAccion (log append-only)
```

### 2.2 Entidades y Campos Obligatorios

#### `Institucion`
```typescript
{
  id: UUID (PK)
  nombre: string (unique)
  dominio: string (unique, opcional, para SSO)
  estado: EstadoInstitucion  // ACTIVA | SUSPENDIDA | ARCHIVADA
  configuracion: JSON        // limites, politicas, personalización
  creadoEn: DateTime
  actualizadoEn: DateTime
}
```

#### `PeriodoAcademico`
```typescript
{
  id: UUID (PK)
  idInstitucion: UUID (FK Institucion)
  nombre: string             // "2026-1", "Semestre Primavera 2026"
  fechaInicio: Date
  fechaFin: Date
  activo: boolean
  creadoEn: DateTime
}
```

#### `Usuario`
```typescript
{
  id: UUID (PK)
  idInstitucion: UUID (FK Institucion)
  email: string (unique global)
  hashContrasena: string
  rol: Rol                    // SUPERADMINISTRADOR | ADMINISTRADOR | DOCENTE | ESTUDIANTE
  estadoCuenta: EstadoCuenta  // PENDIENTE_ACTIVACION | ACTIVO | BLOQUEADO | SUSPENDIDO
  activo: boolean             // soft-delete flag
  primerLogin: boolean        // true = debe cambiar contraseña
  credencialTemporal: string? // bcrypt del temporal
  credencialTemporalVence: DateTime?
  ultimoLogin: DateTime?
  intentosFallidosLogin: int (default 0)
  bloqueadoHasta: DateTime?
  perfil: JSON               // nombre, apellido, foto, teléfono
  creadoEn: DateTime
  actualizadoEn: DateTime
}
```

#### `GrupoAcademico`
```typescript
{
  id: UUID (PK)
  idInstitucion: UUID (FK Institucion)
  idPeriodo: UUID (FK PeriodoAcademico)
  nombre: string
  descripcion: string?
  estado: EstadoGrupo         // BORRADOR | ACTIVO | CERRADO | ARCHIVADO
  codigoAcceso: string (unique, 8 chars alfanum, generado automáticamente)
  creadoEn: DateTime
  actualizadoEn: DateTime
}
```

#### `GrupoDocente` (N:M)
```typescript
{
  id: UUID (PK)
  idGrupo: UUID (FK GrupoAcademico)
  idDocente: UUID (FK Usuario where rol=DOCENTE)
  asignadoEn: DateTime
  asignadoPor: UUID (FK Usuario)
  activo: boolean
}
```

#### `GrupoEstudiante` (N:M)
```typescript
{
  id: UUID (PK)
  idGrupo: UUID (FK GrupoAcademico)
  idEstudiante: UUID (FK Usuario where rol=ESTUDIANTE)
  inscritoEn: DateTime
  inscritoPor: UUID (FK Usuario)
  activo: boolean            // permite baja sin borrar historial
}
```

#### `Examen`
```typescript
{
  id: UUID (PK)
  idInstitucion: UUID (FK Institucion)
  idDocente: UUID (FK Usuario where rol=DOCENTE)
  titulo: string
  descripcion: string?
  instrucciones: string?
  estado: EstadoExamen       // BORRADOR | PUBLICADO | ARCHIVADO
  duracionMinutos: int       // 0 = sin límite
  permitirNavegacionLibre: boolean
  aleatorizar: boolean       // preguntas y opciones
  semilla: string?           // semilla determinista de aleatorización
  puntajeMaximoDefinido: decimal  // suma de puntajes de preguntas
  version: int (default 1)
  idExamenPadre: UUID?       // si es clon
  creadoEn: DateTime
  actualizadoEn: DateTime
}
```

#### `Pregunta`
```typescript
{
  id: UUID (PK)
  idExamen: UUID (FK Examen)
  enunciado: string
  tipo: TipoPregunta          // OPCION_MULTIPLE | VERDADERO_FALSO | SELECCION_MULTIPLE | ABIERTA | EMPAREJAMIENTO
  puntaje: decimal
  orden: int
  obligatoria: boolean
  retroalimentacion: string?  // visible al estudiante DESPUÉS del envío si configurado
  metadatos: JSON?            // dificultad, etiquetas, tema
  activo: boolean
  creadoEn: DateTime
}
```

#### `OpcionRespuesta`
```typescript
{
  id: UUID (PK)
  idPregunta: UUID (FK Pregunta)
  texto: string
  esCorrecta: boolean         // NUNCA exponer al cliente hasta después del envío
  orden: int
  puntajeParcial: decimal?    // para selección múltiple con puntaje parcial
}
```

#### `AsignacionExamen`
```typescript
{
  id: UUID (PK)
  idInstitucion: UUID (FK Institucion)
  idExamen: UUID (FK Examen where estado=PUBLICADO)
  idGrupo: UUID? (FK GrupoAcademico)
  idEstudiante: UUID?         // asignación individual (idGrupo O idEstudiante, no ambos)
  fechaInicio: DateTime
  fechaFin: DateTime
  intentosMaximos: int        // 0 = ilimitado
  mostrarPuntajeInmediato: boolean
  mostrarRespuestasCorrectas: boolean (solo después de cierre)
  publicarResultadosEn: DateTime?
  creadoPor: UUID (FK Usuario)
  creadoEn: DateTime
}
// CHECK: (idGrupo IS NULL) != (idEstudiante IS NULL) — exactamente uno debe ser no-nulo
```

#### `Sesion`
```typescript
{
  id: UUID (PK)
  idInstitucion: UUID (FK Institucion)
  idAsignacion: UUID (FK AsignacionExamen)
  idDocente: UUID (FK Usuario where rol=DOCENTE)
  codigoAcceso: string (unique, 6 chars, generado en activación)
  estado: EstadoSesion        // PENDIENTE | ACTIVA | FINALIZADA | CANCELADA
  fechaActivacion: DateTime?
  fechaFinalizacion: DateTime?
  duracionEfectivaMinutos: int?
  configuracionAntifraude: JSON  // umbrales, pesos, política
  creadoEn: DateTime
  actualizadoEn: DateTime
}
```

#### `Intento`
```typescript
{
  id: UUID (PK)
  idInstitucion: UUID (FK Institucion)
  idSesion: UUID (FK Sesion)
  idEstudiante: UUID (FK Usuario where rol=ESTUDIANTE)
  estado: EstadoIntento       // EN_PROGRESO | ENVIADO | ANULADO | SINCRONIZACION_PENDIENTE
  iniciadoEn: DateTime
  enviadoEn: DateTime?
  ultimaSincronizacion: DateTime?
  ipOrigen: string
  userAgent: string
  plataforma: string          // WEB | MOVIL
  ordenPreguntasAplicado: JSON // semilla usada + orden real
  indiceRiesgoFraude: decimal (0-100)
  requiereRevision: boolean
  razonAnulacion: string?
  anuladoPor: UUID?
  anuladoEn: DateTime?
}
// UNIQUE: (idSesion, idEstudiante) WHERE estado != ANULADO
```

#### `RespuestaEstudiante`
```typescript
{
  id: UUID (PK)
  idIntento: UUID (FK Intento)
  idPregunta: UUID (FK Pregunta)
  respuestaTexto: string?     // para ABIERTA
  opcionesSeleccionadas: UUID[] // para OPCION_MULTIPLE, SELECCION_MULTIPLE, VF
  puntajeObtenido: decimal?
  calificadaAutomaticamente: boolean
  calificadaManualmente: boolean
  calificadaManualmentePor: UUID?
  calificadaManualmenteEn: DateTime?
  comentarioCalificador: string?
  version: int (default 1)    // para versionado de recalificación
  guardadoEn: DateTime
  // UNIQUE: (idIntento, idPregunta)
}
```

#### `ResultadoIntento`
```typescript
{
  id: UUID (PK)
  idIntento: UUID (FK Intento, UNIQUE)
  puntajeTotal: decimal
  puntajeMaximoPosible: decimal
  porcentaje: decimal         // calculado: (puntajeTotal/puntajeMaximoPosible)*100
  estado: EstadoResultado     // PRELIMINAR | OFICIAL | EN_RECLAMO | RECTIFICADO
  pendienteCalificacionManual: boolean
  publicadoEn: DateTime?
  version: int
  calculadoEn: DateTime
}
```

#### `EventoTelemetria`
```typescript
{
  id: UUID (PK)
  idIntento: UUID (FK Intento)
  tipo: TipoEvento            // SEGUNDO_PLANO | FOCO_RECUPERADO | ABANDONO_PANTALLA | CIERRE_FORZADO | TIEMPO_ANOMALO | SYNC_ANOMALA | CAMBIO_RED | CAPTURA_PANTALLA_DETECTADA | MULTIPLES_DISPOSITIVOS
  timestamp: DateTime
  duracionMs: int?
  metadatos: JSON             // contexto específico del evento
  severidad: SeveridadEvento  // INFO | ADVERTENCIA | SOSPECHOSO | CRITICO
}
```

#### `ReclamoCalificacion`
```typescript
{
  id: UUID (PK)
  idResultado: UUID (FK ResultadoIntento)
  idEstudiante: UUID (FK Usuario)
  idPregunta: UUID?           // reclamo sobre pregunta específica o todo el intento
  motivo: string
  estado: EstadoReclamo       // PRESENTADO | EN_REVISION | RESUELTO | RECHAZADO
  presentadoEn: DateTime
  resueltoPor: UUID?
  resolverEn: DateTime?       // plazo máximo de resolución
  resolucion: string?
  puntajeAnterior: decimal?
  puntajeNuevo: decimal?
  versionAnterior: int?
}
```

#### `AuditoriaAccion` (append-only, nunca se edita ni borra)
```typescript
{
  id: UUID (PK)
  idInstitucion: UUID?
  idActor: UUID               // quien realizó la acción
  rolActor: Rol
  accion: string              // e.g. "SESION_ACTIVADA", "INTENTO_ANULADO"
  recurso: string             // nombre de entidad
  idRecurso: UUID
  snapshotAntes: JSON?
  snapshotDespues: JSON?
  ip: string
  userAgent: string
  timestamp: DateTime (UTC)
  resultado: string           // EXITO | FALLO
  razonFallo: string?
}
```

---

## 3. Jerarquía de Roles y Capacidades

### 3.1 `SUPERADMINISTRADOR`

**Alcance:** Global (todas las instituciones).

**Capacidades:**
- Crear, suspender, archivar instituciones.
- Crear usuarios de cualquier rol en cualquier institución.
- Promover usuarios a `ADMINISTRADOR`.
- Auditar cualquier entidad del sistema.
- Ver reportes globales agregados.
- Acceder a logs de auditoría completos.
- Configurar parámetros globales del sistema.

**Restricciones:**
- No puede responder examenes (nunca tiene el rol `ESTUDIANTE`).
- No puede modificar registros de auditoría.
- Sus acciones también quedan auditadas.

**JWT Claims:** `{ rol: "SUPERADMINISTRADOR", idInstitucion: null, sub: userId }`

---

### 3.2 `ADMINISTRADOR`

**Alcance:** Su institución (`idInstitucion` del JWT == `idInstitucion` del recurso).

**Capacidades:**
- Crear/gestionar `DOCENTE` y `ESTUDIANTE` en su institución.
- Crear/gestionar `GrupoAcademico` en su institución.
- Crear/gestionar `PeriodoAcademico` en su institución.
- Asignar docentes y estudiantes a grupos.
- Ver todos los reportes de su institución.
- Anular intentos de estudiantes de su institución.
- Gestionar reclamos de calificación de su institución.
- Calificar preguntas abiertas en ausencia del docente.
- Suspender/bloquear docentes y estudiantes de su institución.

**Restricciones:**
- No puede crear otros `ADMINISTRADOR` (solo `SUPERADMINISTRADOR` puede).
- No puede operar fuera de su `idInstitucion`.
- No puede crear examenes directamente.

---

### 3.3 `DOCENTE`

**Alcance:** Su institución + sus grupos asignados.

**Capacidades:**
- Crear, editar, publicar y archivar sus propios examenes.
- Crear `AsignacionExamen` sobre grupos donde está asignado.
- Crear, activar, finalizar y cancelar sesiones propias.
- Ver intentos e informes de sus sesiones.
- Calificar preguntas abiertas de sus sesiones.
- Anular intentos de sus propias sesiones.
- Resolver reclamos de sus sesiones.

**Restricciones:**
- Solo puede crear sesiones sobre examenes publicados propios.
- Solo puede asignar examen a grupos donde esté asignado.
- No puede ver exámenes ni sesiones de otros docentes.
- No puede gestionar grupos (crear/eliminar), solo consultarlos.
- Solo puede operar dentro de su `idInstitucion`.

---

### 3.4 `ESTUDIANTE`

**Alcance:** Su institución + sus grupos activos inscritos.

**Capacidades:**
- Ver sesiones activas de grupos donde está inscrito.
- Iniciar un intento por sesión (si cumple elegibilidad completa).
- Guardar respuestas durante el intento.
- Enviar el intento.
- Ver sus propios resultados (cuando publicados).
- Presentar reclamos (dentro del plazo configurado).
- Ver su historial de intentos propios.

**Restricciones:**
- No puede acceder al panel administrativo.
- No puede ver información de otros estudiantes.
- No puede ver respuestas correctas antes del envío.
- No puede modificar un intento después de `ENVIADO`.
- No puede iniciar intento si ya tiene uno `EN_PROGRESO` en la misma sesión.

---

## 4. Máquinas de Estado — Referencia Completa

### 4.1 Estado de Institución

```
ACTIVA ──────────────────► SUSPENDIDA
  ▲                              │
  │                              ▼
  └──────────────────────── ARCHIVADA (terminal)

Transiciones:
- ACTIVA → SUSPENDIDA: SUPERADMINISTRADOR. Bloquea logins de todos sus usuarios.
- SUSPENDIDA → ACTIVA: SUPERADMINISTRADOR.
- ACTIVA|SUSPENDIDA → ARCHIVADA: SUPERADMINISTRADOR. Estado terminal, solo lectura.
```

### 4.2 Estado de Cuenta de Usuario

```
PENDIENTE_ACTIVACION
        │
        ▼ (primer login + cambio de contraseña)
      ACTIVO ──────────────────► BLOQUEADO
        │                          │
        │                          ▼ (admin desbloquea)
        │                        ACTIVO
        │
        ▼ (acción admin/superadmin)
    SUSPENDIDO ◄────────────────── ACTIVO
        │
        ▼ (reactivación)
      ACTIVO

Estados terminales: ninguno (siempre se puede reactivar, auditado)

Reglas adicionales:
- Tras 5 intentos de login fallidos consecutivos: estado → BLOQUEADO automáticamente, 
  bloqueadoHasta = now + 30min. Auditoría obligatoria.
- BLOQUEADO por tiempo: se libera automáticamente al vencer bloqueadoHasta.
- BLOQUEADO por admin: requiere desbloqueo manual.
- SUSPENDIDO: JWT existentes se invalidan en el próximo request (blacklist o short TTL).
```

### 4.3 Estado de Grupo Académico

```
BORRADOR ──► ACTIVO ──► CERRADO ──► ARCHIVADO (terminal)
    │            │
    │            └──► CERRADO (cierre anticipado)
    │
    └──► ARCHIVADO (borrador sin usar)

Transiciones permitidas:
- BORRADOR → ACTIVO: ADMINISTRADOR o SUPERADMINISTRADOR.
  Precondición: ≥1 docente asignado y ≥1 estudiante inscrito.
- ACTIVO → CERRADO: ADMINISTRADOR, SUPERADMINISTRADOR, o al vencer PeriodoAcademico.
  Efecto: Sesiones activas en grupos de este periodo se finalizan automáticamente.
- CERRADO → ARCHIVADO: ADMINISTRADOR o SUPERADMINISTRADOR.
- BORRADOR → ARCHIVADO: ADMINISTRADOR o SUPERADMINISTRADOR (limpieza).

Semántica:
- BORRADOR: Se pueden asignar/remover docentes y estudiantes. No permite sesiones.
- ACTIVO: Permite sesiones. Asignaciones aún editables.
- CERRADO: No permite nuevas sesiones. Histórico conservado. Solo lectura operativa.
- ARCHIVADO: Solo lectura absoluta. No aparece en listas operativas.
```

### 4.4 Estado de Examen

```
BORRADOR ──► PUBLICADO ──► ARCHIVADO (terminal)
    │
    └──► ARCHIVADO (borrador sin publicar)

Transiciones:
- BORRADOR → PUBLICADO: DOCENTE dueño.
  Precondiciones (todas deben cumplirse):
  1. ≥1 pregunta activa y válida.
  2. Suma de puntajes de preguntas == puntajeMaximoDefinido (o recalcular).
  3. Ninguna pregunta sin opciones (para tipos que las requieren).
  4. ≥1 opción correcta por pregunta de tipo OPCION_MULTIPLE, VF, SELECCION_MULTIPLE.
  5. El docente pertenece a ≥1 grupo ACTIVO en su institución.
- PUBLICADO → ARCHIVADO: DOCENTE dueño o ADMINISTRADOR.
  Precondición: No existen sesiones ACTIVAS sobre este examen.
- BORRADOR → ARCHIVADO: DOCENTE dueño o ADMINISTRADOR.

Restricciones en PUBLICADO:
- No se puede editar enunciado, opciones, ni puntaje de preguntas existentes.
- Se pueden editar: título, descripción, instrucciones (metadatos no sustantivos).
- Para cambios sustantivos: clonar el examen (crea nueva versión en BORRADOR).
```

### 4.5 Estado de Sesión

```
PENDIENTE ──► ACTIVA ──► FINALIZADA (terminal)
    │            │
    └────────────┴──► CANCELADA (terminal)

Transiciones:
- PENDIENTE → ACTIVA: DOCENTE dueño de la sesión.
  Precondiciones:
  1. AsignacionExamen con fechaInicio <= now <= fechaFin.
  2. GrupoAcademico en estado ACTIVO.
  3. Examen en estado PUBLICADO.
  4. No existe otra sesión ACTIVA para la misma AsignacionExamen.
  Efecto: Se genera codigoAcceso único de 6 caracteres. Se registra fechaActivacion.
- ACTIVA → FINALIZADA: DOCENTE dueño, ADMINISTRADOR del tenant, o automáticamente 
  al vencer duracionMinutos desde fechaActivacion (job programado).
  Efecto: Todos los intentos EN_PROGRESO pasan a ENVIADO. Se dispara calificación automática.
- ACTIVA → CANCELADA: DOCENTE dueño o ADMINISTRADOR.
  Efecto: Intentos EN_PROGRESO pasan a ANULADO. Resultados invalidados. Auditoría obligatoria.
- PENDIENTE → CANCELADA: DOCENTE dueño o ADMINISTRADOR.

Nota sobre codigoAcceso:
- Solo se genera al pasar a ACTIVA.
- Expira con la sesión (FINALIZADA o CANCELADA).
- No se reutiliza entre sesiones.
```

### 4.6 Estado de Intento

```
EN_PROGRESO ──► ENVIADO (terminal operativo)
      │              │
      │              ▼
      └──► ANULADO ◄── ENVIADO (por actor humano autorizado)
      │
      └──► SINCRONIZACION_PENDIENTE ──► EN_PROGRESO (reconciliación exitosa)
                                   └──► ENVIADO (reconciliación por timeout)

Transiciones:
- [inicio] → EN_PROGRESO: ESTUDIANTE elegible.
  Precondiciones completas (ver Sección 12.1).
- EN_PROGRESO → ENVIADO: ESTUDIANTE dueño del intento (envío voluntario),
  o automáticamente si la sesión pasa a FINALIZADA.
- EN_PROGRESO → SINCRONIZACION_PENDIENTE: pérdida de conectividad en móvil.
- SINCRONIZACION_PENDIENTE → EN_PROGRESO: reconexión exitosa dentro de ventana.
- SINCRONIZACION_PENDIENTE → ENVIADO: timeout de reconciliación (submits con lo guardado).
- ENVIADO → ANULADO: DOCENTE dueño de sesión, ADMINISTRADOR de institución, SUPERADMINISTRADOR.
  Requiere: razonAnulacion, anuladoPor, anuladoEn.
  Auditoría obligatoria con snapshot completo.
- EN_PROGRESO → ANULADO: igual que ENVIADO → ANULADO (raros casos de fraude flagrante).
```

### 4.7 Estado de Resultado

```
PRELIMINAR ──► OFICIAL
      │            │
      └────────────┴──► EN_RECLAMO ──► RECTIFICADO
                                   └──► OFICIAL (reclamo rechazado, sin cambio)

Transiciones:
- PRELIMINAR: Resultado calculado pero con preguntas abiertas pendientes.
  Visible al estudiante solo si mostrarPuntajeInmediato=true.
- PRELIMINAR → OFICIAL: Al calificarse todas las preguntas pendientes, 
  o al vencer plazo de cierre forzado de la AsignacionExamen.
- OFICIAL → EN_RECLAMO: Estudiante presenta reclamo dentro del plazo.
- EN_RECLAMO → RECTIFICADO: Actor autorizado aprueba reclamo y modifica puntaje.
- EN_RECLAMO → OFICIAL: Actor autorizado rechaza reclamo.
```

---

## 5. Reglas Globales de Autorización — Pipeline Obligatorio

**Toda operación** en cualquier endpoint (REST o WebSocket) pasa por estas capas en este orden. Un fallo en cualquier capa termina el pipeline con el error correspondiente.

```
Request entrante
      │
      ▼
┌─────────────────────────────────────────────────────────────┐
│ CAPA 1: Autenticación                                       │
│ - JWT presente y válido (firma, expiración).                │
│ - Claims mínimos: sub, rol, idInstitucion, iat, exp.        │
│ - Error si falla: 401 Unauthorized                          │
└─────────────────────────────────────────────────────────────┘
      │
      ▼
┌─────────────────────────────────────────────────────────────┐
│ CAPA 2: Estado del Actor                                    │
│ - Usuario existe en DB.                                     │
│ - activo == true.                                           │
│ - estadoCuenta == ACTIVO.                                   │
│ - No está bloqueado (bloqueadoHasta <= now o null).          │
│ - Institución del usuario en estado ACTIVA.                 │
│ - Error si falla: 403 Forbidden (cuenta suspendida/bloqueada)│
└─────────────────────────────────────────────────────────────┘
      │
      ▼
┌─────────────────────────────────────────────────────────────┐
│ CAPA 3: Rol Mínimo Requerido                                │
│ - El rol del JWT tiene permiso para la operación solicitada │
│   según la Matriz de Permisos (Sección 6).                  │
│ - Error si falla: 403 Forbidden (rol insuficiente)          │
└─────────────────────────────────────────────────────────────┘
      │
      ▼
┌─────────────────────────────────────────────────────────────┐
│ CAPA 4: Alcance Institucional (Tenant Check)                │
│ - Si rol != SUPERADMINISTRADOR:                             │
│   idInstitucion(recurso) == idInstitucion(JWT)              │
│ - Si rol == SUPERADMINISTRADOR: pasa siempre.               │
│ - Error si falla: 403 Forbidden (fuera de tenant)           │
└─────────────────────────────────────────────────────────────┘
      │
      ▼
┌─────────────────────────────────────────────────────────────┐
│ CAPA 5: Propiedad o Membresía                               │
│ - DOCENTE: recurso.idDocente == JWT.sub                     │
│   O el docente pertenece al grupo relacionado con el recurso│
│ - ESTUDIANTE: el estudiante es miembro activo del grupo     │
│   de la sesión/asignación objetivo.                         │
│ - ADMINISTRADOR: pasa para cualquier recurso de su tenant.  │
│ - Error si falla: 403 Forbidden (sin propiedad/membresía)   │
└─────────────────────────────────────────────────────────────┘
      │
      ▼
┌─────────────────────────────────────────────────────────────┐
│ CAPA 6: Estado del Dominio                                  │
│ - El estado actual del recurso permite la operación.        │
│   (Ej: no se puede activar sesión sobre examen ARCHIVADO)   │
│ - Ventanas temporales vigentes donde aplica.                │
│ - Error si falla: 409 Conflict o 422 Unprocessable Entity   │
└─────────────────────────────────────────────────────────────┘
      │
      ▼
   Operación ejecutada + Auditoría registrada
```

---

## 6. Matriz de Permisos Exhaustiva

### 6.1 Permisos sobre Instituciones

| Operación | SA | AD | DO | ES | Condiciones adicionales |
|-----------|----|----|----|----|------------------------|
| Crear institución | ✅ | ❌ | ❌ | ❌ | — |
| Leer institución | ✅ | ✅ (propia) | ✅ (propia, solo datos básicos) | ❌ | — |
| Actualizar institución | ✅ | ❌ | ❌ | ❌ | — |
| Suspender institución | ✅ | ❌ | ❌ | ❌ | — |
| Archivar institución | ✅ | ❌ | ❌ | ❌ | — |

### 6.2 Permisos sobre Usuarios

| Operación | SA | AD | DO | ES | Condiciones adicionales |
|-----------|----|----|----|----|------------------------|
| Crear SUPERADMINISTRADOR | ✅ | ❌ | ❌ | ❌ | — |
| Crear ADMINISTRADOR | ✅ | ❌ | ❌ | ❌ | — |
| Crear DOCENTE | ✅ | ✅ | ❌ | ❌ | AD: solo en su institución |
| Crear ESTUDIANTE | ✅ | ✅ | ❌ | ❌ | AD: solo en su institución |
| Leer cualquier usuario | ✅ | ✅ (su tenant) | ✅ (perfiles básicos su tenant) | ✅ (solo su propio perfil) | — |
| Actualizar perfil propio | ✅ | ✅ | ✅ | ✅ | No puede cambiar su propio rol |
| Cambiar contraseña propia | ✅ | ✅ | ✅ | ✅ | Requiere contraseña actual |
| Cambiar rol de usuario | ✅ (cualquier → cualquier) | ✅ (solo bajar: DO→ES; no puede crear AD) | ❌ | ❌ | Auditoría obligatoria |
| Bloquear/desbloquear usuario | ✅ | ✅ (su tenant, no otros AD) | ❌ | ❌ | — |
| Suspender usuario | ✅ | ✅ (su tenant) | ❌ | ❌ | — |
| Eliminar (soft-delete) usuario | ✅ | ✅ (su tenant) | ❌ | ❌ | Precond: sin sesiones activas |

### 6.3 Permisos sobre Grupos

| Operación | SA | AD | DO | ES | Condiciones adicionales |
|-----------|----|----|----|----|------------------------|
| Crear grupo | ✅ | ✅ | ❌ | ❌ | AD: en su institución |
| Leer grupo | ✅ | ✅ (su tenant) | ✅ (sus grupos asignados) | ✅ (sus grupos inscritos, datos básicos) | — |
| Actualizar grupo | ✅ | ✅ (su tenant, si no ARCHIVADO) | ❌ | ❌ | — |
| Cambiar estado de grupo | ✅ | ✅ (su tenant) | ❌ | ❌ | Ver máquina de estado 4.3 |
| Asignar docente a grupo | ✅ | ✅ (su tenant) | ❌ | ❌ | Docente debe ser de la misma institución |
| Remover docente de grupo | ✅ | ✅ (su tenant) | ❌ | ❌ | Precond: sin sesiones activas del docente en grupo |
| Inscribir estudiante a grupo | ✅ | ✅ (su tenant) | ❌ | ❌ | Estudiante debe ser de la misma institución |
| Dar de baja estudiante de grupo | ✅ | ✅ (su tenant) | ❌ | ❌ | Preserva histórico (activo=false) |

### 6.4 Permisos sobre Exámenes

| Operación | SA | AD | DO | ES | Condiciones adicionales |
|-----------|----|----|----|----|------------------------|
| Crear examen | ✅ | ❌ | ✅ | ❌ | DO: debe estar en ≥1 grupo ACTIVO |
| Leer examen (completo) | ✅ | ✅ (su tenant) | ✅ (solo propios) | ❌ | — |
| Leer examen (preguntas sin respuestas correctas) | ✅ | ✅ | ✅ | ✅ (solo durante intento activo) | ES no ve `esCorrecta` |
| Editar examen BORRADOR | ✅ | ❌ | ✅ (dueño) | ❌ | — |
| Editar examen PUBLICADO (metadatos) | ✅ | ✅ | ✅ (dueño) | ❌ | Solo campos no sustantivos |
| Publicar examen | ✅ | ❌ | ✅ (dueño) | ❌ | Ver precondiciones 4.4 |
| Archivar examen | ✅ | ✅ (su tenant) | ✅ (dueño) | ❌ | Sin sesiones ACTIVAS |
| Clonar examen | ✅ | ❌ | ✅ (dueño o acceso) | ❌ | Crea nueva versión BORRADOR |

### 6.5 Permisos sobre Asignaciones de Examen

| Operación | SA | AD | DO | ES | Condiciones adicionales |
|-----------|----|----|----|----|------------------------|
| Crear asignación | ✅ | ❌ | ✅ | ❌ | DO: examen propio publicado + grupo asignado |
| Leer asignación | ✅ | ✅ (su tenant) | ✅ (sus asignaciones) | ✅ (solo sus asignaciones vigentes) | — |
| Actualizar asignación | ✅ | ❌ | ✅ (dueño, si no hay intentos) | ❌ | — |
| Eliminar asignación | ✅ | ✅ (su tenant) | ✅ (dueño, sin sesiones) | ❌ | — |

### 6.6 Permisos sobre Sesiones

| Operación | SA | AD | DO | ES | Condiciones adicionales |
|-----------|----|----|----|----|------------------------|
| Crear sesión | ✅ | ❌ | ✅ | ❌ | DO: sobre asignación propia |
| Activar sesión | ✅ | ❌ | ✅ (dueño) | ❌ | Ver precondiciones 4.5 |
| Finalizar sesión | ✅ | ✅ (su tenant) | ✅ (dueño) | ❌ | — |
| Cancelar sesión | ✅ | ✅ (su tenant) | ✅ (dueño) | ❌ | Auditoría con justificación |
| Buscar sesión por código | — | — | — | ✅ | Código válido, sesión ACTIVA, estudiante elegible |
| Ver panel en tiempo real | ✅ | ✅ (su tenant) | ✅ (dueño) | ❌ | JWT en handshake WebSocket |

### 6.7 Permisos sobre Intentos

| Operación | SA | AD | DO | ES | Condiciones adicionales |
|-----------|----|----|----|----|------------------------|
| Iniciar intento | ❌ | ❌ | ❌ | ✅ | Ver precondiciones completas 12.1 |
| Guardar respuestas | ❌ | ❌ | ❌ | ✅ (dueño, intento EN_PROGRESO) | Upsert idempotente |
| Enviar intento | ❌ | ❌ | ❌ | ✅ (dueño, intento EN_PROGRESO) | — |
| Ver intento completo | ✅ | ✅ (su tenant) | ✅ (sus sesiones) | ✅ (solo propio, después de ENVIADO) | — |
| Anular intento | ✅ | ✅ (su tenant) | ✅ (sus sesiones) | ❌ | Requiere justificación. Auditoría. |
| Ver telemetría de intento | ✅ | ✅ (su tenant) | ✅ (sus sesiones) | ❌ | — |

### 6.8 Permisos sobre Calificación

| Operación | SA | AD | DO | ES | Condiciones adicionales |
|-----------|----|----|----|----|------------------------|
| Ver calificación automática | ✅ | ✅ | ✅ (sus sesiones) | ✅ (propio, si publicado) | — |
| Calificar pregunta abierta | ✅ | ✅ (su tenant) | ✅ (sus sesiones) | ❌ | — |
| Modificar calificación manual | ✅ | ✅ (su tenant) | ✅ (sus sesiones) | ❌ | Versiona la respuesta, auditoría |
| Forzar recálculo puntaje | ✅ | ✅ (su tenant) | ✅ (sus sesiones) | ❌ | — |

### 6.9 Permisos sobre Reportes

| Operación | SA | AD | DO | ES |
|-----------|----|----|----|----|
| Reporte global (todas instituciones) | ✅ | ❌ | ❌ | ❌ |
| Reporte institucional | ✅ | ✅ (su tenant) | ❌ | ❌ |
| Reporte por grupo | ✅ | ✅ (su tenant) | ✅ (sus grupos) | ❌ |
| Reporte por sesión | ✅ | ✅ (su tenant) | ✅ (sus sesiones) | ❌ |
| Historial propio | ✅ | ✅ | ✅ | ✅ |

*SA=SUPERADMINISTRADOR, AD=ADMINISTRADOR, DO=DOCENTE, ES=ESTUDIANTE*

---

## 7. Flujo de Identidad y Autenticación

### 7.1 Creación de Usuario

```
1. Actor autorizado llama POST /usuarios (con datos del nuevo usuario).
2. Sistema genera:
   - id (UUID v4)
   - credencialTemporal (string aleatorio 12 chars)
   - hash bcrypt(credencialTemporal, rounds=12)
   - credencialTemporalVence = now + 48h
   - estadoCuenta = PENDIENTE_ACTIVACION
   - primerLogin = true
   - activo = true
3. Sistema envía email con credencialTemporal en texto plano (una sola vez).
4. credencialTemporal se elimina de la DB tras primer login exitoso.
5. Auditoría: USUARIO_CREADO.
```

### 7.2 Login

```
POST /auth/login { email, contraseña }

1. Buscar usuario por email.
2. Si no existe: 401 (mismo mensaje genérico para no enumerar usuarios).
3. Si activo=false o estadoCuenta=BLOQUEADO y bloqueadoHasta > now: 403.
4. Si estadoCuenta=SUSPENDIDO: 403.
5. Verificar bcrypt(contraseña, hash).
   - Si falla: incrementar intentosFallidosLogin.
     Si intentosFallidosLogin >= 5: estadoCuenta → BLOQUEADO, bloqueadoHasta = now+30min.
     Auditoría: LOGIN_FALLIDO.
     Retornar 401.
   - Si ok: resetear intentosFallidosLogin = 0.
6. Verificar institución: estado ACTIVA.
7. Si primerLogin=true:
   - Verificar que contraseña == credencialTemporal (comparar hash).
   - Si credencialTemporalVence < now: 401 (credencial expirada, solicitar nueva).
   - Retornar 200 con flag: { requiereCambioContrasena: true, tokenTemporal: JWT(exp=15min) }
   - El tokenTemporal solo permite el endpoint POST /auth/cambiar-contrasena.
8. Generar JWT:
   { sub: user.id, rol: user.rol, idInstitucion: user.idInstitucion, 
     iat: now, exp: now+8h }
9. Generar Refresh Token (opaco, guardado en DB con hash, exp: 7 días).
10. Registrar ultimoLogin = now.
11. Auditoría: LOGIN_EXITOSO.
12. Retornar { accessToken, refreshToken, perfil básico }.
```

### 7.3 Cambio Obligatorio de Contraseña (Primer Login)

```
POST /auth/cambiar-contrasena { nuevaContrasena }
Headers: Authorization: Bearer {tokenTemporal}

1. Validar tokenTemporal (solo válido para este endpoint).
2. Validar política de contraseña:
   - Mínimo 8 caracteres.
   - Al menos 1 mayúscula, 1 minúscula, 1 número, 1 carácter especial.
   - No puede ser igual a la credencialTemporal.
3. Hashear nueva contraseña con bcrypt (rounds=12).
4. Actualizar usuario: hashContrasena, primerLogin=false, credencialTemporal=null,
   credencialTemporalVence=null, estadoCuenta=ACTIVO.
5. Emitir JWT completo (misma estructura que login normal).
6. Auditoría: CONTRASENA_CAMBIADA_PRIMER_LOGIN.
```

### 7.4 Refresh Token

```
POST /auth/refresh { refreshToken }

1. Buscar refreshToken en DB (por hash).
2. Verificar expiración y que usuario sigue ACTIVO.
3. Invalidar el refreshToken usado (rotación).
4. Emitir nuevo accessToken + nuevo refreshToken.
5. Auditoría: TOKEN_REFRESCADO.
```

### 7.5 Logout

```
POST /auth/logout
Headers: Authorization: Bearer {accessToken}

1. Invalidar refreshToken activo del usuario.
2. Agregar accessToken a blacklist (TTL hasta su exp natural).
3. Auditoría: LOGOUT.
```

---

## 8. Flujo Organizacional: Instituciones y Grupos

### 8.1 Ciclo de Vida de Institución

```
POST /instituciones (solo SUPERADMINISTRADOR)
Body: { nombre, dominio?, configuracion? }

1. Crear institución con estado=ACTIVA.
2. Auditoría: INSTITUCION_CREADA.

PATCH /instituciones/:id/estado
Body: { estado: SUSPENDIDA | ACTIVA | ARCHIVADA, razon }

1. Validar transición permitida (máquina de estado 4.1).
2. Si SUSPENDIDA: invalidar sessions de todos los usuarios de la institución.
3. Auditoría: INSTITUCION_ESTADO_CAMBIADO.
```

### 8.2 Creación y Gestión de Grupos

```
POST /grupos (ADMINISTRADOR o SUPERADMINISTRADOR)
Body: { nombre, descripcion?, idPeriodo, idInstitucion? }

1. Verificar que el PeriodoAcademico pertenece a la institución y está activo.
2. Crear grupo con estado=BORRADOR.
3. Generar codigoAcceso único (8 caracteres alfanuméricos uppercase).
4. Auditoría: GRUPO_CREADO.

POST /grupos/:id/docentes (ADMINISTRADOR)
Body: { idDocente }

1. Verificar que el docente pertenece a la misma institución.
2. Verificar que el docente tiene rol=DOCENTE y activo=true.
3. Verificar que no existe ya la asignación activa.
4. Crear GrupoDocente { activo: true, asignadoPor: actor.id }.
5. Auditoría: DOCENTE_ASIGNADO_A_GRUPO.

POST /grupos/:id/estudiantes (ADMINISTRADOR)
Body: { idEstudiante }

1. Verificar que el estudiante pertenece a la misma institución.
2. Verificar que el estudiante tiene rol=ESTUDIANTE y activo=true.
3. Verificar que no existe ya inscripción activa.
4. Crear GrupoEstudiante { activo: true, inscritoPor: actor.id }.
5. Auditoría: ESTUDIANTE_INSCRITO_EN_GRUPO.

PATCH /grupos/:id/estado
Body: { estado: ACTIVO | CERRADO | ARCHIVADO, razon? }

1. Validar transición (máquina de estado 4.3).
2. Si ACTIVO: verificar ≥1 docente y ≥1 estudiante activos.
3. Si CERRADO: 
   - Finalizar automáticamente sesiones ACTIVAS del grupo.
   - Auditoría de cada sesión finalizada.
4. Auditoría: GRUPO_ESTADO_CAMBIADO.
```

---

## 9. Flujo de Evaluaciones

### 9.1 Creación y Edición de Examen

```
POST /examenes (DOCENTE)
Body: { titulo, descripcion?, instrucciones?, duracionMinutos, 
        permitirNavegacionLibre, aleatorizar }

1. Verificar que el docente pertenece a ≥1 grupo ACTIVO.
2. Crear examen con estado=BORRADOR, version=1, idDocente=actor.id.
3. Auditoría: EXAMEN_CREADO.

POST /examenes/:id/preguntas (DOCENTE dueño, examen BORRADOR)
Body: { enunciado, tipo, puntaje, orden, opciones?: [{texto, esCorrecta, orden}] }

Validaciones por tipo:
- OPCION_MULTIPLE: exactamente 1 opción con esCorrecta=true, ≥2 opciones total.
- VF: exactamente 2 opciones (Verdadero/Falso), 1 correcta.
- SELECCION_MULTIPLE: ≥1 opción correcta, ≥2 opciones total.
- ABIERTA: sin opciones.
- EMPAREJAMIENTO: pares definidos en metadatos estructurado.

POST /examenes/:id/publicar (DOCENTE dueño)

1. Verificar todas las precondiciones de la máquina de estado 4.4.
2. Recalcular puntajeMaximoDefinido = SUM(preguntas.puntaje where activo=true).
3. Cambiar estado=PUBLICADO.
4. Auditoría: EXAMEN_PUBLICADO.

POST /examenes/:id/clonar (DOCENTE dueño o con acceso)

1. Crear copia completa del examen con estado=BORRADOR, version=1, 
   idExamenPadre=original.id, titulo="[COPIA] "+original.titulo.
2. Clonar todas las preguntas y opciones.
3. Auditoría: EXAMEN_CLONADO.
```

### 9.2 Aleatorización Determinista

```
Cuando aleatorizar=true en el examen:

Al iniciar un intento:
1. Calcular semilla: SHA256(examen.semilla + estudiante.id + sesion.id).
   Si examen.semilla es null: usar examen.id.
2. Usar la semilla para generar orden aleatorio reproducible de preguntas.
3. Para cada pregunta, usar semilla derivada para aleatorizar opciones.
4. Guardar ordenPreguntasAplicado en el intento (JSON con mapeo idPregunta→posición).
5. El mismo estudiante en la misma sesión siempre recibe el mismo orden (reproducible).
6. Diferentes estudiantes en la misma sesión reciben órdenes diferentes.
7. El orden solo se revela después del envío del intento para auditoría.
```

---

## 10. Flujo de Asignaciones de Examen

### 10.1 Crear Asignación

```
POST /asignaciones (DOCENTE)
Body: {
  idExamen,           // debe ser PUBLICADO y propio
  idGrupo?,           // XOR con idEstudiante
  idEstudiante?,      // asignación individual
  fechaInicio,        // UTC
  fechaFin,           // UTC, > fechaInicio
  intentosMaximos,    // 0=ilimitado
  mostrarPuntajeInmediato,
  mostrarRespuestasCorrectas,
  publicarResultadosEn?
}

Validaciones:
1. exactamente uno de (idGrupo, idEstudiante) debe ser no-nulo.
2. Si idGrupo: docente debe estar asignado al grupo.
3. Si idEstudiante: el estudiante debe estar en algún grupo del docente.
4. fechaFin > fechaInicio.
5. fechaInicio >= now (no se puede crear asignación en el pasado).
6. examen.estado == PUBLICADO.
7. examen.idDocente == actor.id.
8. Si idGrupo: grupo.estado == ACTIVO.
9. Auditoría: ASIGNACION_CREADA.
```

### 10.2 Elegibilidad de Estudiante por Asignación

```
Un estudiante ES elegible para iniciar intento en una sesión si y solo si:

1. La sesión está en estado ACTIVA.
2. La AsignacionExamen tiene:
   - fechaInicio <= now <= fechaFin
   - (idGrupo: estudiante pertenece activamente al grupo con activo=true en GrupoEstudiante)
   - O (idEstudiante == estudiante.id)
3. El número de intentos previos del estudiante en esta sesión/asignación 
   es < intentosMaximos (0 = ilimitado).
4. No existe un intento EN_PROGRESO o SINCRONIZACION_PENDIENTE del estudiante en esta sesión.
5. El estudiante está activo (activo=true, estadoCuenta=ACTIVO).

Si cualquiera de estas condiciones falla: 403 con mensaje descriptivo del motivo.
```

---

## 11. Flujo de Sesiones

### 11.1 Crear Sesión

```
POST /sesiones (DOCENTE)
Body: { idAsignacion, configuracionAntifraudeOverride? }

1. Verificar que la asignación existe y el docente es dueño.
2. Verificar que el examen de la asignación está PUBLICADO.
3. Crear sesión con estado=PENDIENTE.
4. configuracionAntifraud: usar override si provisto, si no los defaults del sistema.
5. Auditoría: SESION_CREADA.
```

### 11.2 Activar Sesión

```
PATCH /sesiones/:id/activar (DOCENTE dueño)

1. Verificar todas las precondiciones de la máquina de estado 4.5.
2. Generar codigoAcceso: 6 caracteres alfanuméricos uppercase, único en DB.
   Si colisión: reintentar hasta 5 veces, luego error 500.
3. Registrar fechaActivacion = now.
4. Cambiar estado = ACTIVA.
5. Si duracionMinutos > 0: programar job para FINALIZAR en fechaActivacion + duracionMinutos.
6. Publicar evento WebSocket: SESION_ACTIVADA al canal del grupo.
7. Auditoría: SESION_ACTIVADA.
8. Retornar { codigoAcceso, sesion completa }.
```

### 11.3 Buscar Sesión por Código (Estudiante en Móvil)

```
GET /sesiones/buscar/:codigo (ESTUDIANTE)

1. Buscar sesión por codigoAcceso (case-insensitive, trim).
2. Verificar que sesión.estado == ACTIVA.
3. Verificar que now está dentro de la ventana de la AsignacionExamen.
4. Verificar elegibilidad del estudiante (completa, ver 10.2).
5. Retornar datos de la sesión SIN respuestas correctas:
   {
     idSesion, idExamen, tituloExamen, instrucciones, duracionMinutos,
     fechaActivacion, preguntas: [{ id, enunciado, tipo, puntaje, orden,
       opciones: [{ id, texto, orden }] }],  // sin esCorrecta
     intentosPrevios, intentosMaximos,
     configuracionAntifraud: { ... }
   }
6. Auditoría: SESION_BUSCADA_POR_CODIGO.
```

### 11.4 Finalizar Sesión

```
PATCH /sesiones/:id/finalizar (DOCENTE dueño | ADMINISTRADOR | job automático)

1. Verificar que sesión.estado == ACTIVA.
2. Cambiar estado = FINALIZADA, fechaFinalizacion = now.
3. Para cada intento EN_PROGRESO o SINCRONIZACION_PENDIENTE en la sesión:
   a. Cambiar estado → ENVIADO, enviadoEn = now.
   b. Disparar calificación automática.
4. Publicar evento WebSocket: SESION_FINALIZADA al canal del grupo.
5. Auditoría: SESION_FINALIZADA.
```

---

## 12. Flujo de Intentos, Respuestas y Calificación

### 12.1 Iniciar Intento

```
POST /intentos (ESTUDIANTE)
Body: { idSesion, codigoAcceso }

Precondiciones (en orden, fallo = error descriptivo):
1. sesion.estado == ACTIVA.
2. sesion.codigoAcceso == body.codigoAcceso.
3. Elegibilidad completa del estudiante (ver 10.2).
4. No existe intento { idSesion, idEstudiante } con estado EN_PROGRESO 
   o SINCRONIZACION_PENDIENTE. → 409 si existe.
5. Contar intentos previos ENVIADOS/ANULADOS para la asignación:
   Si asignacion.intentosMaximos > 0 y count >= intentosMaximos → 403.

Proceso:
1. Calcular semilla de aleatorización (si aplica).
2. Generar orden de preguntas/opciones.
3. Crear intento { estado: EN_PROGRESO, iniciadoEn: now, ipOrigen, userAgent, plataforma }.
4. Publicar evento WebSocket al panel del docente: INTENTO_INICIADO.
5. Auditoría: INTENTO_INICIADO.
6. Retornar { idIntento, preguntas ordenadas sin respuestas correctas, 
              tiempoRestanteSegundos? }.
```

### 12.2 Guardar Respuestas (Upsert Idempotente)

```
POST /intentos/:id/respuestas (ESTUDIANTE dueño)
Body: { respuestas: [{ idPregunta, respuestaTexto?, opcionesSeleccionadas? }] }

1. Verificar intento.estado == EN_PROGRESO.
2. Verificar intento.idEstudiante == actor.id.
3. Para cada respuesta en el lote:
   a. Verificar que idPregunta pertenece al examen de la sesión.
   b. Upsert en RespuestaEstudiante por (idIntento, idPregunta).
   c. Actualizar guardadoEn = now.
4. Actualizar intento.ultimaSincronizacion = now.
5. Publicar evento WebSocket al panel: PROGRESO_ACTUALIZADO (solo metadata, sin respuestas).
6. Retornar { guardadas: count, timestamp }.

Nota crítica: NUNCA incluir esCorrecta ni puntaje en la respuesta de este endpoint.
```

### 12.3 Enviar Intento

```
POST /intentos/:id/enviar (ESTUDIANTE dueño)

1. Verificar intento.estado == EN_PROGRESO.
2. Verificar sesion.estado == ACTIVA (puede haberse finalizado mientras tanto).
   Si sesion.estado == FINALIZADA: igual proceder (las respuestas ya guardadas son válidas).
3. Cambiar intento.estado = ENVIADO, enviadoEn = now.
4. Disparar calificación automática (síncrona o asíncrona según configuración).
5. Publicar evento WebSocket al panel: INTENTO_ENVIADO.
6. Auditoría: INTENTO_ENVIADO.
7. Retornar { estado: ENVIADO, mensaje: "Intento enviado correctamente" }.
   NO retornar respuestas correctas aquí (solo si publicarResultadosEn ya pasó).
```

### 12.4 Calificación Automática

```
Trigger: intento pasa a ENVIADO.

Para cada RespuestaEstudiante del intento:
  pregunta = obtener pregunta con opciones correctas.

  switch(pregunta.tipo):
    case OPCION_MULTIPLE:
      opcionCorrecta = opciones.find(esCorrecta=true).id
      puntaje = (respuesta.opcionesSeleccionadas[0] == opcionCorrecta) 
                ? pregunta.puntaje : 0
      calificadaAutomaticamente = true

    case VERDADERO_FALSO:
      opcionCorrecta = opciones.find(esCorrecta=true).id
      puntaje = (respuesta.opcionesSeleccionadas[0] == opcionCorrecta) 
                ? pregunta.puntaje : 0
      calificadaAutomaticamente = true

    case SELECCION_MULTIPLE:
      correctas = Set(opciones.filter(esCorrecta=true).map(id))
      seleccionadas = Set(respuesta.opcionesSeleccionadas)
      if (correctas == seleccionadas):
        puntaje = pregunta.puntaje
      elif (correctas.intersect(seleccionadas).size > 0 && 
            pregunta.puntajeParcial habilitado):
        // Puntaje parcial: proporción de correctas seleccionadas menos penalización por incorrectas
        aciertos = correctas.intersect(seleccionadas).size
        errores = seleccionadas.difference(correctas).size
        puntaje = max(0, (aciertos/correctas.size - errores/incorrectas.size) * pregunta.puntaje)
      else:
        puntaje = 0
      calificadaAutomaticamente = true

    case ABIERTA:
      puntaje = null  // pendiente manual
      calificadaAutomaticamente = false

    case EMPAREJAMIENTO:
      // Puntaje proporcional: aciertos/total_pares * puntaje
      pares_correctos = evaluar_pares(respuesta, pregunta.metadatos)
      puntaje = (pares_correctos / total_pares) * pregunta.puntaje
      calificadaAutomaticamente = true

  Actualizar RespuestaEstudiante con puntajeObtenido.

Calcular ResultadoIntento:
  puntajeTotal = SUM(respuestas.puntajeObtenido where puntaje IS NOT NULL)
  pendienteCalificacionManual = EXISTS(respuestas where calificadaAutomaticamente=false)
  estado = pendienteCalificacionManual ? PRELIMINAR : OFICIAL
  porcentaje = (puntajeTotal / puntajeMaximoPosible) * 100
  
Crear o actualizar ResultadoIntento.
Si mostrarPuntajeInmediato=true Y estado=OFICIAL: publicar resultado al estudiante.
Publicar evento WebSocket: RESULTADO_CALCULADO al panel del docente.
```

### 12.5 Calificación Manual de Preguntas Abiertas

```
PATCH /intentos/:idIntento/respuestas/:idPregunta/calificar
(DOCENTE dueño de sesión | ADMINISTRADOR)
Body: { puntajeOtorgado, comentario? }

1. Verificar permisos.
2. Verificar que respuesta.idIntento está en una sesión del actor autorizado.
3. Verificar que pregunta.tipo == ABIERTA.
4. Verificar 0 <= puntajeOtorgado <= pregunta.puntaje.
5. Versionar: crear snapshot de versión anterior.
6. Actualizar RespuestaEstudiante:
   { puntajeObtenido: puntajeOtorgado, calificadaManualmente: true,
     calificadaManualmentePor: actor.id, calificadaManualmenteEn: now,
     comentarioCalificador: comentario, version: version+1 }
7. Recalcular ResultadoIntento (puntaje total + pendienteCalificacionManual).
8. Si !pendienteCalificacionManual: actualizar estado ResultadoIntento → OFICIAL.
9. Si publicarResultadosEn <= now o no definido: publicar resultado al estudiante.
10. Auditoría: PREGUNTA_CALIFICADA_MANUALMENTE.
```

---

## 13. Resultados, Publicación y Reclamos

### 13.1 Publicación de Resultados

```
Regla de visibilidad de resultados para el ESTUDIANTE:

Resultado visible si:
1. intento.estado == ENVIADO.
2. resultado.estado IN [OFICIAL, RECTIFICADO] 
   O (resultado.estado == PRELIMINAR AND asignacion.mostrarPuntajeInmediato=true).
3. now >= asignacion.publicarResultadosEn (si está definido).

Datos visibles al estudiante:
- puntajeTotal, puntajeMaximoPosible, porcentaje, estado del resultado.
- SI asignacion.mostrarRespuestasCorrectas=true AND sesion.estado=FINALIZADA:
  Opciones correctas de preguntas OPCION_MULTIPLE, VF, SELECCION_MULTIPLE.
  Comentarios de calificación de preguntas ABIERTA.
- NUNCA: respuestas de otros estudiantes, datos de telemetría, índice de riesgo.
```

### 13.2 Flujo de Reclamos

```
POST /reclamos (ESTUDIANTE)
Body: { idResultado, idPregunta?, motivo }

Precondiciones:
1. resultado.estado IN [OFICIAL, RECTIFICADO].
2. intento.idEstudiante == actor.id.
3. now <= (sesion.fechaFinalizacion + asignacion.plazoReclamos) — plazo configurable.
4. No existe reclamo PRESENTADO o EN_REVISION para el mismo resultado+pregunta.

Proceso:
1. Crear ReclamoCalificacion { estado: PRESENTADO, resolverEn: now + plazoReclamos }.
2. Notificar (WebSocket/email) al docente dueño de la sesión.
3. Auditoría: RECLAMO_PRESENTADO.

PATCH /reclamos/:id/resolver (DOCENTE dueño | ADMINISTRADOR)
Body: { decision: APROBADO | RECHAZADO, puntajeNuevo?, resolucion }

1. Verificar permisos.
2. Si APROBADO:
   a. Verificar que 0 <= puntajeNuevo <= pregunta.puntaje.
   b. Actualizar RespuestaEstudiante con nuevo puntaje (versiona).
   c. Recalcular ResultadoIntento.
   d. Actualizar resultado.estado = RECTIFICADO.
   e. Guardar puntajeAnterior y puntajeNuevo en el reclamo.
3. Si RECHAZADO: resultado permanece igual.
4. Actualizar ReclamoCalificacion { estado: RESUELTO | RECHAZADO, resueltoPor, resolverEn: now }.
5. Notificar estudiante.
6. Auditoría: RECLAMO_RESUELTO.
```

---

## 14. Telemetría y Anti-Fraude — Sistema Completo

### 14.1 Eventos de Telemetría a Capturar

| Evento | Plataforma | Severidad base | Metadatos requeridos |
|--------|-----------|---------------|----------------------|
| `SEGUNDO_PLANO` | Móvil | ADVERTENCIA | duracionMs, timestamp |
| `FOCO_RECUPERADO` | Móvil/Web | INFO | duracionAusenciaMs |
| `ABANDONO_PANTALLA` | Web | ADVERTENCIA | duracionMs, url_destino? |
| `CAMBIO_PESTANA` | Web | ADVERTENCIA | timestamp, contadorTotal |
| `CIERRE_FORZADO` | Móvil/Web | CRITICO | timestamp, estadoUltimaSync |
| `TIEMPO_ANOMALO` | Backend | SOSPECHOSO | tiempoEntreRespuestasMs, medianaEsperada |
| `SYNC_ANOMALA` | Backend | SOSPECHOSO | intervaloSyncMs, patronDetectado |
| `CAMBIO_RED` | Móvil | INFO | tipoRedAnterior, tipoRedNuevo |
| `CAPTURA_PANTALLA_DETECTADA` | Móvil | CRITICO | timestamp |
| `MULTIPLES_DISPOSITIVOS` | Backend | CRITICO | ipNueva, ipAnterior, userAgentNuevo |
| `PATRON_RESPUESTA_ANOMALO` | Backend | SOSPECHOSO | descripcionPatron |
| `VELOCIDAD_RESPUESTA_ANOMALA` | Backend | SOSPECHOSO | msPromedioRespuesta, umbralMs |

### 14.2 Cálculo del Índice de Riesgo de Fraude

```
Fórmula base:
R = w1*f_foco + w2*f_abandono + w3*f_cierre + w4*f_tiempo + w5*f_red + w6*f_patron

Donde cada f_x ∈ [0,100] representa la señal normalizada del factor.

Pesos predeterminados (configurables por sesión):
  w1 = 0.20  (pérdidas de foco: cambio pestaña, segundo plano)
  w2 = 0.15  (abandonos de pantalla)
  w3 = 0.25  (cierres forzados / reinicios sospechosos)
  w4 = 0.15  (tiempo anómalo de respuesta)
  w5 = 0.10  (cambios de red / múltiples dispositivos)
  w6 = 0.15  (patrón de respuestas anómalo)
  
  SUM(wi) = 1.00

Cálculo de f_foco:
  count = número de eventos SEGUNDO_PLANO + ABANDONO_PANTALLA + CAMBIO_PESTANA
  f_foco = min(100, count * (100 / umbral_foco))  // umbral_foco default: 5

Cálculo de f_cierre:
  si existe evento CIERRE_FORZADO: f_cierre = 100
  si existe MULTIPLES_DISPOSITIVOS: f_cierre = max(f_cierre, 80)
  si existe CAPTURA_PANTALLA: f_cierre = max(f_cierre, 70)

Cálculo de f_tiempo:
  tiempos = lista de ms entre inicio_intento y cada envío de respuesta
  mediana_esperada = (duracionSesionMs / totalPreguntas)
  anomalias = count(t < mediana_esperada * 0.1 OR t > mediana_esperada * 5)
  f_tiempo = min(100, (anomalias / totalPreguntas) * 100 * factor_sensibilidad)

Cálculo de f_patron:
  Análisis estadístico:
  - Correlación de respuestas con patrones conocidos de trampa (comparación entre estudiantes).
  - Velocidad de respuesta uniformemente constante (bot-like).
  - Selección de opciones en orden siempre igual (sin variación).
  f_patron = 0-100 calculado por modelo estadístico configurable.

Recálculo:
  Se recalcula R tras cada evento de telemetría.
  Se actualiza intento.indiceRiesgoFraude.
  Se actualiza intento.requiereRevision = (R >= 30).
```

### 14.3 Políticas de Riesgo y Acciones

| Rango R | Clasificación | Acción Automática | Acción Sugerida al Docente |
|---------|--------------|-------------------|---------------------------|
| 0 – 29 | NORMAL | Ninguna | Ninguna |
| 30 – 59 | SOSPECHOSO | Marcar requiereRevision=true. Notificación silenciosa al panel. | Revisar telemetría del intento. |
| 60 – 79 | ALERTA_CRITICA | Notificación urgente al panel (WebSocket). Marcar en reporte. | Revisar activamente y considerar anulación. |
| 80 – 100 | FRAUDE_PROBABLE | Notificación crítica al panel. Sugerir anulación con evidencia. | Decidir anulación manual con razon. |

**Regla absoluta: El sistema NUNCA anula automáticamente. Solo un actor humano autorizado puede anular un intento.**

### 14.4 Envío de Telemetría desde el Cliente

```
POST /intentos/:id/telemetria (ESTUDIANTE dueño, intento EN_PROGRESO)
Body: { eventos: [{ tipo, timestamp, duracionMs?, metadatos? }] }

1. Verificar intento EN_PROGRESO.
2. Insertar eventos en lote en EventoTelemetria.
3. Disparar recálculo asíncrono de indiceRiesgoFraude.
4. Si nueva severidad CRITICO o cambio de categoría: publicar WebSocket al docente.
5. Retornar { recibidos: count }.

Frecuencia de envío recomendada (cliente):
- Eventos críticos: enviar inmediatamente.
- Eventos acumulables (foco, tiempo): cada 30 segundos en lote.
- Nunca bloquear UI esperando respuesta de telemetría.
```

---

## 15. Teoría de Juegos Aplicada — Diseño del Equilibrio

### 15.1 Modelo de Utilidad del Estudiante

```
Jugadores:
  A = Estudiante { estrategias: Honesto (H), Trampa (T) }
  B = Sistema/Docente { estrategias: Monitoreo Bajo (MB), Monitoreo Alto (MA) }

Función de utilidad del estudiante para estrategia Trampa:
  U(T, MB) = B_nota_alta - C_cognitivo
  U(T, MA) = B_nota_alta - p_detec(MA) * C_sancion - p_anulacion(MA) * C_repeticion 
             - C_cognitivo - C_riesgo_reputacional

Función de utilidad para estrategia Honesta:
  U(H) = B_nota_merecida - C_esfuerzo_estudio

Objetivo del diseño: U(H) > U(T, MA) para la mayoría de perfiles de estudiantes.

Para lograr U(H) > U(T) se maximizan:
  - p_detec (probabilidad de detección): aumentada por telemetría + anti-fraude.
  - C_sancion (costo de sanción): penalización progresiva + historial permanente.
  - C_repeticion (costo de repetición): exámenes con preguntas aleatorizadas + sin ventana.
  - C_cognitivo (costo cognitivo de trampa): aleatorización hace difícil coordinar respuestas.
  
Y se reducen:
  - C_esfuerzo_estudio: retroalimentación de aprendizaje, materiales accesibles.
  - Incertidumbre sobre U(H): publicar resultados claros y rápido.
```

### 15.2 Controles para Mover el Equilibrio hacia H

**Control 1: Aleatorización Determinista por Estudiante**
- Cada estudiante recibe preguntas en orden diferente, opciones en orden diferente.
- Hace inútil compartir "la respuesta es B" porque la opción B no es la misma para todos.
- Implementación: semilla = SHA256(examenId + estudianteId + sesionId).

**Control 2: Monitoreo Mixto No Predecible (Estrategia Mixta Nash)**
- No todos los intentos son revisados manualmente (costo prohibitivo).
- El sistema aplica *monitoreo por muestreo*: revisión detallada de % aleatorio + 100% de R≥60.
- El estudiante no sabe si su intento será revisado detalladamente → no puede calcular p_detec.
- Esto eleva el p_detec *percibido* sin elevar el costo operativo proporcionalmente.
- Configuración: `porcentajeMuestreoManual` por sesión (default: 20%).

**Control 3: Penalización Progresiva por Reincidencia**
- Primer incidente (R≥60): advertencia formal, registro en historial.
- Segundo incidente: nota máxima del intento reducida al 70%.
- Tercer incidente: inhabilitación temporal para exámenes.
- El historial de incidentes es visible para el administrador y docente, no para otros estudiantes.
- Siempre requiere decisión humana para aplicar consecuencia.

**Control 4: Publicación Diferida de Claves de Corrección**
- Las respuestas correctas NO se revelan hasta que la AsignacionExamen cierra (`fechaFin`).
- Configurable por docente: `mostrarRespuestasCorrectas` solo activo post-cierre.
- Esto elimina el incentivo de compartir respuestas en tiempo real dentro de la sesión.

**Control 5: Detección de Patrones Entre Estudiantes (Análisis Post-Sesión)**
- Comparar distribución de respuestas entre estudiantes de la misma sesión.
- Patrones sospechosos: mismas respuestas incorrectas poco comunes = posible copia.
- Algoritmo: coeficiente de correlación de respuestas + análisis de clustering.
- Resultado: alertas para revisión 
