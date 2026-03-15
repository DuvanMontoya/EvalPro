# AGENTS.md — Especificación Normativa de EvalPro

**Versión:** 2.0  
**Fecha de revisión:** 2025  
**Audiencia:** Codex / agentes de IA que trabajen sobre este repositorio  
**Documento complementario:** `README.md` (instrucciones de puesta en marcha), `.cursor/rules/Nomenclatura.mdc` (convenciones de código)

---

## 1. Misión y alcance

EvalPro es una plataforma integral para la **creación, administración y rendición de evaluaciones académicas** con foco en:

- **Seguridad y anti‑fraude** (telemetría avanzada, índice de riesgo, anulación auditada).
- **Multi‑tenant** por institución (aislamiento estricto entre instituciones).
- **Dos modos de evaluación de primera clase**: contenido completo y solo respuestas.
- **Offline‑first** con reconciliación auditada contra el servidor.
- **Analítica pedagógica** por estudiante, grupo, área y competencia.

### 1.1. Lo que ya existe (no reescribir sin evidencia)

El repositorio ya contiene:

- **`Backend/`**: API REST y WebSocket en NestJS + Prisma + PostgreSQL 15.
- **`Frontend/`**: Panel administrativo web en Next.js (roles: SUPERADMINISTRADOR, ADMINISTRADOR, DOCENTE).
- **`Movil/`**: App Flutter con flujo de estudiante y módulos de gestión multirol.
- **`Compartido/`** _(si existe)_: Tipos e interfaces TypeScript compartidos.
- Flujos, módulos, pantallas, endpoints, modelos y reglas de negocio que ya existen pero están **incompletos, desalineados o faltantes**.

**Regla absoluta:** el trabajo del agente no es rehacer el producto desde cero. Es auditar, completar, corregir y blindar lo existente.

### 1.2. Lo que no está permitido sin autorización explícita

- Reescribir módulos funcionales sin documentar qué falla y por qué es necesario.
- Agregar roles, entidades o flujos que no estén en este documento.
- Cambiar contratos de API sin migrar todos los clientes afectados.
- Renombrar campos de base de datos sin migración.
- Exponer respuestas correctas de exámenes antes de que el intento esté en estado `ENVIADO`.
- Guardar o transmitir contraseñas en texto plano.
- Hardcodear secretos o credenciales en código fuente.

---

## 2. Principios no negociables

Estos principios gobiernan **toda** decisión de diseño, implementación y resolución de conflictos.

### 2.1. El backend es la fuente de verdad

El cliente puede:

- Trabajar offline.
- Guardar respuestas localmente.
- Capturar eventos localmente.

El backend **siempre** decide:

- Validez del intento.
- Tiempo oficial (nunca el reloj del dispositivo del estudiante).
- Incidentes acumulados y su severidad.
- Permiso de reingreso.
- Suspensión automática.
- Validez final del examen.
- Publicación de resultados.

### 2.2. No confiar en el cliente

- No confiar en tiempos locales como verdad oficial.
- No confiar en validaciones de seguridad hechas solo en el cliente.
- No confiar en "finalizaciones" no reconciliadas con el backend.
- No confiar en estados terminales sin confirmación del servidor.
- El hecho de que el cliente reporte algo no lo hace cierto; el backend valida y decide.

### 2.3. Offline‑first con autoridad del servidor

- La app funciona con mala señal o sin internet.
- El estudiante no debe perder respuestas por conectividad.
- Un intento terminado offline queda en estado **PROVISIONAL** hasta reconciliación con el backend.
- Apagar Wi‑Fi, datos o poner modo avión **no** permite evadir controles. El examen puede continuar capturando localmente, pero la validez final depende del backend.

### 2.4. Limitaciones BYOD son reales

- El celular es del estudiante.
- No asumir dispositivos dedicados.
- No asumir MDM total ni control absoluto del sistema operativo.
- Diseñar para el **máximo endurecimiento posible en BYOD**, sin inventar control que no existe.
- Compensar con incidentes, bloqueo local, reingreso por docente, telemetría y reconciliación.

### 2.5. Cambios pequeños y seguros primero

- Preferir mejoras incrementales, reversibles y verificables.
- Preferir máquinas de estado explícitas sobre booleanos dispersos.
- Preferir flujos auditables sobre magia implícita.
- Preferir migraciones pequeñas y reversibles sobre cambios de esquema riesgosos.
- Preferir implementaciones completas sobre placeholders visuales.

### 2.6. Multi‑tenant estricto

- Ningún usuario, salvo el rol `SUPERADMINISTRADOR`, puede leer, crear, modificar ni eliminar recursos de una institución diferente a la propia.
- Esta regla se aplica en el backend como primera verificación, no solo en el frontend.

---

## 3. Stack tecnológico real

| Capa         | Tecnología                                         |
| ------------ | -------------------------------------------------- |
| Backend      | NestJS (Node.js 20.x) + Prisma ORM + PostgreSQL 15 |
| Frontend web | Next.js 16 + TypeScript                            |
| App móvil    | Flutter SDK ≥ 3.4.0 < 4.0.0                        |
| Shared types | TypeScript (carpeta `Compartido/` si existe)       |
| Contenedores | Docker + Docker Compose                            |

**Regla:** Si el stack real difiere de cualquier suposición anterior, seguir el stack del repositorio. No proponer cambios de tecnología sin autorización explícita.

---

## 4. Convenciones de código obligatorias

- Todo el código debe estar en **español**: nombres de archivos, variables, funciones, clases, comentarios, mensajes de error visibles al usuario.
- Respetar las reglas de PascalCase / camelCase / snake_case según el tipo de símbolo definido en `.cursor/rules/Nomenclatura.mdc`.
- Cada archivo de código debe incluir el encabezado obligatorio definido en `.cursor/rules/Nomenclatura.mdc`.
- No mezclar inglés y español dentro del mismo bloque de código.

### 4.1. Formato de respuesta de API (contrato inmutable)

Todas las respuestas del backend deben seguir este envelope:

**Éxito:**

```json
{
  "exito": true,
  "datos": {},
  "mensaje": "Descripción legible",
  "marcaTiempo": "ISO 8601"
}
```

**Error:**

```json
{
  "exito": false,
  "datos": null,
  "mensaje": "Descripción legible del error",
  "codigoError": "CODIGO_EN_MAYUSCULAS",
  "marcaTiempo": "ISO 8601"
}
```

- Nunca devolver stacks de error internos al cliente en producción.
- El campo `codigoError` debe ser una constante manejable por el cliente, no un mensaje libre.

---

## 5. Roles del sistema

EvalPro define exactamente cuatro roles. No agregar roles sin actualizar este documento y todas las capas del sistema.

| Rol                  | Alcance                              | Descripción                                                                                                                 |
| -------------------- | ------------------------------------ | --------------------------------------------------------------------------------------------------------------------------- |
| `SUPERADMINISTRADOR` | Global (todas las instituciones)     | Gestión de instituciones, usuarios globales, configuración del sistema. Único rol que puede cruzar la barrera multi‑tenant. |
| `ADMINISTRADOR`      | Institución propia                   | Gestión de usuarios, grupos, periodos, evaluaciones y configuración institucional. No puede acceder a otras instituciones.  |
| `DOCENTE`            | Institución propia, grupos asignados | Creación y gestión de evaluaciones, supervisión de sesiones en vivo, gestión de reclamos y calificación manual.             |
| `ESTUDIANTE`         | Institución propia, grupos asignados | Rendición de evaluaciones, consulta de resultados y envío de reclamos.                                                      |

### 5.1. Reglas de autorización

- Todas las rutas protegidas deben validar rol **en el backend**, no solo en el cliente.
- `ADMINISTRADOR` y `DOCENTE` no pueden ver ni modificar datos de usuarios de otra institución.
- `DOCENTE` solo puede ver y gestionar los grupos que le han sido asignados explícitamente.
- `ESTUDIANTE` solo puede ver sus propios intentos, resultados y reclamos.
- La autorización se evalúa **antes** de cualquier lógica de negocio.
- Un usuario sin rol válido recibe `403 SIN_PERMISOS`, no `404`.

---

## 6. Modelo de dominio

Las siguientes entidades son el mínimo obligatorio. No eliminar ni renombrar sin migración documentada.

### 6.1. Entidades estructurales

- **Institución**: unidad multi‑tenant raíz. Cada recurso del sistema pertenece a una institución.
- **Sede** _(si aplica)_: subdivisión de la institución.
- **PeriodoAcademico**: periodo de evaluación vigente (ej. bimestre, trimestre, semestre).
- **Grado / Nivel**: clasificación curricular.
- **Grupo**: salón o sección de estudiantes. Tiene docente(s) asignado(s).
- **MembresíaGrupo**: relación entre usuario (estudiante o docente) y grupo.

### 6.2. Entidades de usuarios

- **Usuario**: entidad base con rol, correo, contraseña hasheada (bcrypt), estado activo/inactivo y referencia a institución.
- Los roles se mapean a la entidad `Usuario` mediante el campo `rol` de tipo enumeración.

### 6.3. Entidades de contenido académico

- **Área / Asignatura**: agrupación curricular.
- **Competencia**: capacidad evaluable asociada a un área.
- **SubCompetencia**: desglose fino de competencia.
- **BancoPregunta**: colección de preguntas reutilizables.
- **Pregunta**: enunciado, multimedia (si existe), tipo (selección única, etc.).
- **OpcionRespuesta**: texto de la opción, indicador de si es correcta.
- **ClaveCorrecta**: mapa pregunta → opción correcta para una versión de evaluación.

### 6.4. Entidades de evaluación

- **Evaluacion**: definición de una evaluación (título, área, modo, configuración de tiempo, política de incidentes, política de retroalimentación, etc.).
- **VersionEvaluacion**: snapshot inmutable de una evaluación con sus preguntas y clave correcta en un momento dado. Permite evaluar consistencia aunque la evaluación madre cambie.
- **ModoEvaluacion**: enumeración `CONTENIDO_COMPLETO` | `SOLO_RESPUESTAS`.
- **Sesion**: instancia de una evaluación para un grupo en una fecha/ventana de tiempo específica.

### 6.5. Entidades de intento

- **Intento**: un estudiante en una sesión. Ver máquina de estados en sección 8.
- **RespuestaIntento**: selección de opción por pregunta dentro de un intento. Es idempotente (upsert por intento + pregunta).
- **EventoIntento**: log de eventos del ciclo de vida del intento (ver sección 11).
- **Incidente**: evento de seguridad registrado contra un intento (ver sección 9).
- **TokenReingreso**: token de un solo uso, de vida corta, vinculado a intento + estudiante, emitido por docente.

### 6.6. Entidades de resultado

- **ResultadoProvisional**: calculado al momento del envío, antes de reconciliación final.
- **ResultadoConsolidado**: resultado oficial publicado, después de reconciliación y validación docente/admin.
- **Retroalimentacion**: comentario o recurso vinculado a evaluación, área, competencia o pregunta específica.
- **Recomendacion / PlanRemedial**: recurso de refuerzo vinculado a debilidades detectadas.
- **Reclamo**: solicitud de revisión de un intento o resultado presentada por el estudiante.

---

## 7. Modos de evaluación

Los dos modos son **obligatorios y de primera clase**. No tratar el modo solo respuestas como parche.

### 7.1. Modo CONTENIDO_COMPLETO

La app o web muestra:

- Enunciado completo de la pregunta.
- Opciones de respuesta con texto.
- Navegación entre preguntas.
- Temporizador oficial (sincronizado con el backend).
- Estado de sincronización.
- Flujo digital normal de examen.

### 7.2. Modo SOLO_RESPUESTAS

El estudiante tiene un **cuadernillo físico**. La app muestra **únicamente**:

- Número de pregunta.
- Opciones A / B / C / D y una quinta opción "No lo sé".
- Progreso numérico (ej. "12 de 40 respondidas").
- Temporizador oficial.
- Estado de sincronización.
- Versión del cuadernillo / identificador de la evaluación.

**Restricciones absolutas del modo SOLO_RESPUESTAS:**

- La app **no debe mostrar** el enunciado de la pregunta bajo ninguna circunstancia.
- La app **no debe mostrar** explicaciones ni retroalimentación durante el intento.
- El backend debe validar que las respuestas recibidas corresponden a la versión correcta del cuadernillo antes de calcular resultados.

### 7.3. Regla de cambio de respuesta

La política de si se permite cambiar una respuesta ya enviada es configurable por evaluación. El backend aplica la política; el cliente no puede eludirla. Si la política prohíbe cambio, el backend rechaza la actualización con `403 CAMBIO_RESPUESTA_NO_PERMITIDO`.

---

## 8. Máquina de estados del intento

Esta máquina es central y no debe romperse. Toda transición debe ser validada en el **backend**.

### 8.1. Estados

| Estado                   | Descripción                                                                                          |
| ------------------------ | ---------------------------------------------------------------------------------------------------- |
| `INICIADO`               | El intento fue creado y el estudiante está activo.                                                   |
| `BLOQUEADO`              | El intento fue suspendido por incidente. Requiere reingreso autorizado.                              |
| `REANUDADO`              | El intento fue desbloqueado mediante token de reingreso válido.                                      |
| `SUSPENDIDO`             | El intento fue terminado por política de incidentes. No puede reanudarse.                            |
| `FINALIZADO_PROVISIONAL` | El estudiante envió el intento offline. Pendiente de reconciliación.                                 |
| `ENVIADO`                | El intento fue reconciliado y confirmado por el backend. Estado terminal positivo.                   |
| `ANULADO`                | El intento fue invalidado por administrador o docente con motivo auditado. Estado terminal negativo. |

### 8.2. Transiciones permitidas

```
INICIADO        → BLOQUEADO             (incidente que supera umbral)
INICIADO        → FINALIZADO_PROVISIONAL (envío offline)
INICIADO        → ENVIADO               (envío online exitoso)
INICIADO        → SUSPENDIDO            (3er incidente o política automática)
INICIADO        → ANULADO               (anulación manual con auditoría)

BLOQUEADO       → REANUDADO             (token de reingreso válido consumido)
BLOQUEADO       → SUSPENDIDO            (2do o 3er incidente acumulado, o expiración sin reingreso)
BLOQUEADO       → ANULADO               (anulación manual con auditoría)

REANUDADO       → BLOQUEADO             (nuevo incidente)
REANUDADO       → FINALIZADO_PROVISIONAL (envío offline)
REANUDADO       → ENVIADO               (envío online exitoso)
REANUDADO       → SUSPENDIDO            (política automática)
REANUDADO       → ANULADO               (anulación manual con auditoría)

FINALIZADO_PROVISIONAL → ENVIADO        (reconciliación exitosa)
FINALIZADO_PROVISIONAL → ANULADO        (reconciliación fallida o anulación manual)

ENVIADO         → ANULADO               (anulación posterior con auditoría; excepcional)
```

**Estados terminales:** `ENVIADO`, `SUSPENDIDO`, `ANULADO`. Ningún estado terminal puede ser alterado por el cliente. Solo `ADMINISTRADOR` o `DOCENTE` con permisos explícitos pueden iniciar una anulación, y queda registrada en auditoría.

### 8.3. Reglas de validación de transición (backend)

- El backend **rechaza** cualquier operación sobre un intento en estado terminal.
- El backend **rechaza** transiciones no listadas en 8.2.
- El backend **rechaza** tokens de reingreso ya consumidos, expirados o que no corresponden al intento + estudiante exactos.
- El backend **rechaza** envíos de respuestas para preguntas que no pertenecen a la versión de evaluación del intento.

---

## 9. Modelo de incidentes

Un **incidente** es cualquier evento que amenace la integridad del examen o la consistencia del flujo.

### 9.1. Tipos de incidente soportados

| Tipo                                  | Descripción                                                               |
| ------------------------------------- | ------------------------------------------------------------------------- |
| `APP_EN_BACKGROUND`                   | La app fue enviada al segundo plano.                                      |
| `PERDIDA_DE_FOCO`                     | La app perdió el foco sin ir completamente a background.                  |
| `NAVEGACION_NO_AUTORIZADA`            | Se intentó navegar fuera del flujo de examen.                             |
| `OVERLAY_DETECTADO`                   | Otra ventana cubrió la vista del examen.                                  |
| `VERIFICACION_INTEGRIDAD_FALLIDA`     | La verificación de integridad de app o dispositivo falló.                 |
| `INCONSISTENCIA_SINCRONIZACION`       | El estado local y el estado del servidor difieren de forma inconsistente. |
| `COMPORTAMIENTO_DUPLICADO_SOSPECHOSO` | Se detectaron respuestas o eventos con características de replay.         |
| `TOKEN_REINGRESO_INVALIDO`            | Se intentó usar un token inválido, expirado o ya consumido.               |
| `TIEMPO_EXCEDIDO`                     | El tiempo oficial del backend expiró.                                     |
| `RECONCILIACION_INCONSISTENTE`        | La reconciliación final detectó discrepancias irresolubles.               |

### 9.2. Política de incidentes (por defecto)

Esta política aplica salvo que la `Evaluacion` tenga una política personalizada configurada.

| Incidente acumulado | Acción automática del backend                                  | Acción requerida para continuar                       |
| ------------------- | -------------------------------------------------------------- | ----------------------------------------------------- |
| 1.°                 | Bloquear intento (`→ BLOQUEADO`)                               | Autorización del docente (token de reingreso)         |
| 2.°                 | Bloquear intento (`→ BLOQUEADO`) + marcar `alto_riesgo = true` | Autorización del docente (token de reingreso)         |
| 3.°                 | Suspender intento (`→ SUSPENDIDO`)                             | No puede reanudarse. Queda para revisión obligatoria. |

- El contador de incidentes es **acumulativo** durante todo el intento, no se reinicia tras un reingreso.
- Un intento marcado `alto_riesgo` debe ser visible de forma destacada en el panel docente.
- La suspensión en el 3.° incidente es **automática e irrevocable** desde el cliente. Solo `ADMINISTRADOR` puede anular manualmente con auditoría.

### 9.3. Comportamiento local ante incidente (sin internet)

La app debe, incluso sin conectividad:

1. Guardar todas las respuestas actuales localmente de forma inmediata.
2. Congelar el intento (impedir seguir respondiendo).
3. Mostrar pantalla de bloqueo con mensaje claro.
4. Registrar el evento de incidente en el log local.
5. No permitir continuar sin autorización de reingreso.
6. Al reconectar, sincronizar el incidente con el backend antes de intentar cualquier reingreso.

### 9.4. Comportamiento del backend ante incidente

Al recibir un evento de incidente (online o en reconciliación):

1. Persistir el `Incidente` con tipo, marcaTiempo y contexto.
2. Incrementar el contador de incidentes del intento.
3. Recalcular el estado de riesgo (`alto_riesgo`).
4. Evaluar si debe aplicar la política de bloqueo o suspensión.
5. Actualizar el estado del intento según la máquina de estados.
6. Emitir evento WebSocket al panel docente si hay sesión activa.

---

## 10. Reingreso controlado

El sistema soporta reingreso **exclusivamente autorizado por docente**. El estudiante no puede reanudar un intento bloqueado por sí solo.

### 10.1. Mecanismos de autorización

| Mecanismo | Uso                                                                     |
| --------- | ----------------------------------------------------------------------- |
| QR        | Mecanismo principal. El docente genera el QR; el estudiante lo escanea. |
| PIN       | Mecanismo de respaldo si QR no es viable.                               |

### 10.2. Requisitos del token de reingreso

- Vinculado a: intento específico + estudiante específico.
- Ventana de validez: corta (el valor exacto es configurable; no hardcodear).
- Un solo uso: una vez consumido, queda marcado como `usado` y el backend rechaza cualquier reuso.
- El reingreso queda auditado: quién lo autorizó, cuándo, desde qué dispositivo (si disponible), y a qué intento.
- El backend valida el token **antes** de transicionar el intento a `REANUDADO`.

### 10.3. Reingreso en escenario offline

- La app puede bloquearse localmente sin confirmación del backend.
- El docente puede emitir autorización offline mediante un mecanismo verificable (implementación específica según el stack actual).
- La validez definitiva del reingreso offline depende de la reconciliación posterior con el backend.
- Si el backend rechaza el reingreso offline durante la reconciliación, el intento queda en `SUSPENDIDO` y se registra en auditoría.

---

## 11. Auditoría e integridad de datos

Toda acción crítica del examen debe quedar persistida. Los logs no dependen solo de la memoria del cliente.

### 11.1. Eventos obligatorios de auditoría

Los siguientes eventos deben registrarse como `EventoIntento`:

- `EVALUACION_ABIERTA`
- `INTENTO_INICIADO`
- `RESPUESTA_SELECCIONADA` (con número de pregunta, opción seleccionada y marcaTiempo)
- `RESPUESTA_CAMBIADA` (si la política lo permite; incluye valor anterior)
- `RESPUESTA_LIMPIADA` (si aplica)
- `APP_EN_BACKGROUND` (ver tipos de incidente)
- `APP_EN_FOREGROUND`
- `INCIDENTE_REGISTRADO` (con referencia al `Incidente`)
- `REINGRESO_AUTORIZADO`
- `TOKEN_REINGRESO_CONSUMIDO`
- `ENVIO_SOLICITADO`
- `FINALIZACION_PROVISIONAL`
- `RECONCILIACION_EXITOSA`
- `RECONCILIACION_FALLIDA`
- `RESULTADO_PUBLICADO`
- `ANULACION` (con motivo y usuario que anuló)

### 11.2. Reglas de integridad

- Los eventos tienen números de secuencia crecientes por intento para detectar reordenamiento o pérdida.
- El servidor procesa eventos de forma **idempotente**: recibir el mismo evento dos veces no debe generar duplicados ni cambios de estado incorrectos.
- Los eventos no pueden eliminarse; solo pueden marcarse como `revisado` o `ignorado` con motivo auditado.

---

## 12. Reglas offline‑first y sincronización

### 12.1. Comportamiento obligatorio offline (app del estudiante)

- Capturar y persistir respuestas localmente de forma **inmediata** tras cada selección.
- Persistir eventos del intento localmente.
- Mantener estado del intento localmente entre reinicios de la app.
- Distinguir claramente entre:
  - Estado local no sincronizado (indicador visual).
  - Estado sincronizado y confirmado.
  - Finalización provisional.

### 12.2. Protocolo de sincronización

El protocolo debe ser **determinista y seguro**:

- Cada evento y respuesta tiene número de secuencia creciente.
- El servidor procesa de forma idempotente (misma secuencia = mismo resultado).
- Los reintentos son seguros (no crean duplicados).
- Al reconectar, el cliente envía la cola completa de eventos y respuestas pendientes.
- El servidor responde con el estado canónico del intento tras procesar la cola.
- Si el estado del servidor contradice el estado local, el estado del **servidor prevalece**.

### 12.3. Regla de finalización offline

- Un intento finalizado offline queda en estado `FINALIZADO_PROVISIONAL`.
- No se trata como oficialmente válido hasta reconciliación.
- Al reconectar, el cliente envía: respuestas finales + log de eventos + incidentes + evidencias de integridad si existen.
- El backend reconcilia y transiciona a `ENVIADO` o `ANULADO` según corresponda.

---

## 13. Seguridad BYOD en la app móvil

### 13.1. Requisitos obligatorios del cliente móvil

1. **Pantallas seguras**: activar protección contra capturas de pantalla donde la plataforma lo permita.
2. **Modo inmersivo**: experiencia fullscreen durante el examen.
3. **Control de ciclo de vida**: detectar background / pérdida de foco y tratar como incidente inmediatamente.
4. **Bloqueo local ante incidente**: no permitir continuar silenciosamente; mostrar pantalla de bloqueo.
5. **Protección contra overlays**: rechazar o bloquear interacción cuando otra ventana cubra la vista del examen.
6. **Verificación de integridad**: integrar verificación de integridad de app/dispositivo en transiciones críticas si el stack lo soporta.
7. **Almacenamiento local seguro**: usar mecanismos seguros de plataforma para tokens; no almacenar secretos en texto claro.
8. **Builds de release endurecidos**: minimizar secretos expuestos; dejar reglas críticas en el backend.

### 13.2. Lo que no se puede garantizar en BYOD

- No afirmar control absoluto del dispositivo.
- No afirmar que las capturas de pantalla son imposibles en todos los dispositivos.
- Compensar limitaciones BYOD con: telemetría, incidentes, bloqueo local, reingreso por docente y reconciliación.

---

## 14. Resultados y analítica

### 14.1. Vista del estudiante

El estudiante debe poder consultar (cuando los resultados estén publicados):

- Puntaje global del intento.
- Puntaje por área.
- Puntaje por competencia.
- Puntaje por subcompetencia (si existe en la evaluación).
- Fortalezas identificadas.
- Debilidades identificadas.
- Historial de evaluaciones anteriores.
- Posición relativa o percentil, **solo si la política institucional lo permite**.
- Revisión por pregunta, **solo si la política de la evaluación lo permite**.
- Recomendaciones o plan de refuerzo vinculado a debilidades.

**Restricción:** el estudiante no puede ver las respuestas correctas de una evaluación mientras haya intentos activos de otros estudiantes en esa sesión.

### 14.2. Vista del docente / administrador

Debe soportar vistas de analítica por:

- Institución / colegio.
- Sede (si aplica).
- Grupo.
- Evaluación.
- Versión de evaluación.
- Estudiante individual.
- Área.
- Competencia.
- Pregunta (análisis de distractor).
- Perfil de incidentes.
- Evolución temporal (comparativo entre periodos).

### 14.3. Agrupación pedagógica

El sistema debe soportar clasificación más allá de la nota total. Como mínimo:

- Banda de desempeño total (ej. bajo, básico, alto, superior).
- Debilidad por área.
- Debilidad por competencia.
- Patrón de omitidas ("No lo sé" en modo SOLO_RESPUESTAS).
- Incidentes frecuentes.

---

## 15. Retroalimentación y remediación

### 15.1. Niveles de retroalimentación

- Nivel evaluación global.
- Nivel área.
- Nivel competencia.
- Nivel pregunta.
- Nivel recomendación / plan remedial.

### 15.2. Vinculación de recursos

La retroalimentación puede vincularse con:

- Videos.
- Diapositivas / presentaciones.
- Módulos remediales.
- Actividades sugeridas.

**Regla:** Si ya existe un modelo de contenido en el repositorio, extenderlo. No reemplazarlo sin justificación técnica documentada.

---

## 16. Dashboard docente en vivo

### 16.1. Vista de sesión activa

El panel docente debe soportar en tiempo real (WebSocket si el stack lo soporta):

- Lista de estudiantes del grupo en sesión.
- Estado de cada estudiante: `INICIADO` / `BLOQUEADO` / `REANUDADO` / `SUSPENDIDO` / `ENVIADO`.
- Progreso (preguntas respondidas / total).
- Indicador de conectividad del estudiante (si disponible).
- Cantidad de incidentes por estudiante.
- Indicador visual destacado para intentos marcados `alto_riesgo`.
- Acción rápida: generar token de reingreso (QR o PIN).
- Estado de envío final de cada estudiante.

### 16.2. Restricciones del panel docente

- El docente solo ve los grupos que le han sido asignados.
- No puede ver datos de grupos de otros docentes.
- No puede ver el contenido de las respuestas durante el examen (solo progreso y estado).

---

## 17. Dashboard administrador

El panel del administrador debe soportar:

- Visibilidad por institución (solo la propia, salvo `SUPERADMINISTRADOR`).
- Comparativos por cohorte.
- Analítica agregada por evaluación.
- Analítica de incidentes.
- Trazabilidad de intentos.
- Monitoreo operativo de sesiones en curso.
- Gestión de usuarios, grupos, periodos y evaluaciones institucionales.

---

## 18. Contratos de API requeridos

Todos los endpoints deben seguir el envelope de respuesta definido en sección 4.1.

### 18.1. Endpoints mínimos requeridos

| Recurso      | Operación              | Descripción                                                  |
| ------------ | ---------------------- | ------------------------------------------------------------ |
| Evaluaciones | Listar                 | Evaluaciones disponibles para el estudiante autenticado      |
| Evaluaciones | Obtener                | Metadata y modo de evaluación (sin revelar clave correcta)   |
| Intentos     | Iniciar                | Crear intento para una sesión activa                         |
| Intentos     | Enviar respuesta       | Upsert idempotente de respuesta (por intento + pregunta)     |
| Intentos     | Bloquear               | Registrar incidente y aplicar política                       |
| Intentos     | Autorizar reingreso    | Docente genera token de reingreso                            |
| Intentos     | Reanudar               | Consumir token de reingreso válido                           |
| Intentos     | Finalizar provisional  | Marcar intento como finalizado offline                       |
| Intentos     | Reconciliar            | Subir log completo y confirmar envío                         |
| Resultados   | Obtener por estudiante | Resultados publicados del estudiante autenticado             |
| Dashboard    | Panel docente en vivo  | Estado en tiempo real de la sesión                           |
| Analítica    | Panel administrador    | Analítica agregada institucional                             |
| Incidentes   | Listar por intento     | Historial de incidentes de un intento                        |
| Auditoría    | Listar eventos         | Log de eventos de un intento (solo admin/docente autorizado) |

### 18.2. Reglas de diseño de API

- Usar los patrones de ruta, validación y documentación existentes en el repositorio.
- Validar todos los parámetros de entrada en el backend.
- Tipar todas las respuestas.
- Documentar cada endpoint según la convención del repositorio.
- No exponer campos internos o sensibles innecesariamente.
- Las rutas de administración deben requerir autenticación + autorización de rol explícita.

---

## 19. Telemetría y variables de entorno de seguridad

El sistema incluye variables de telemetría configurables por entorno. Entre ellas (sin ser lista exhaustiva):

- `TELEMETRIA_SEGUNDOS_MINIMOS_POR_PREGUNTA`: tiempo mínimo esperado por pregunta antes de considerar sospechoso el avance.

**Regla:** No hardcodear umbrales de telemetría en el código. Toda variable de comportamiento configurable debe ir en el entorno o en configuración de la evaluación.

---

## 20. Reglas de compatibilidad

1. No romper flujos que ya funcionan.
2. No renombrar ni eliminar contratos de API sin migración documentada.
3. No cambiar semántica de campos de base de datos sin migración de Prisma.
4. Si un contrato cambia:
   - Versionarlo si aplica.
   - Migrar con cuidado.
   - Actualizar todos los clientes afectados (Backend, Frontend, Movil).
   - Documentar el cambio en el commit y en el CHANGELOG si existe.
5. Si una entidad de base de datos cambia de nombre, crear migración explícita; no asumir que Prisma lo resuelve automáticamente sin revisión.

---

## 21. Guía de implementación por capa

### 21.1. Backend (NestJS + Prisma)

- Controladores delgados: solo reciben, validan y delegan.
- Reglas de negocio en servicios / casos de uso, nunca en controladores ni repositorios.
- Transiciones de estado del intento validadas y centralizadas en un único servicio de dominio.
- Usar transacciones Prisma cuando la consistencia lo requiera (ej. registrar incidente + actualizar estado).
- Hacer idempotente el envío de respuestas (upsert por intento + pregunta).
- Modelar claramente `FINALIZADO_PROVISIONAL` vs `ENVIADO`.
- Centralizar evaluación de incidentes; no dispersar reglas por todo el repositorio.
- Logging estructurado en flujos críticos (inicio de intento, incidente, reingreso, envío, reconciliación).

### 21.2. Frontend web (Next.js)

- Reutilizar el sistema visual actual.
- Conectar dashboards a contratos backend reales, no a datos hardcodeados o mocks.
- Exponer estado en vivo donde el stack (WebSocket) lo permita.
- Controles operativos deben ser explícitos y confirmar antes de acciones destructivas:
  - Autorizar reingreso.
  - Anular intento.
  - Publicar resultados.
- Construir analítica progresiva pero conectada a datos reales.
- Respetar restricciones de rol en la UI (aunque la validación definitiva siempre es el backend).

### 21.3. App móvil (Flutter)

- Reutilizar la arquitectura actual (no proponer cambio de arquitectura sin evidencia).
- Respetar la solución de manejo de estado ya adoptada.
- Centralizar el ciclo de vida del examen en un único gestor de estado.
- Separar claramente: estado UI / estado de dominio / estado de sincronización / estado de incidentes.
- Agregar persistencia robusta para intentos en curso (survive to app restart).
- Crear / reutilizar componentes para:
  - Selector de respuestas (modo completo y modo solo respuestas).
  - Temporizador.
  - Indicador de estado de sincronización.
  - Pantalla de bloqueo por incidente.
  - Flujo de reingreso (QR + PIN).
  - Tarjetas de resultados.
  - Widgets de analítica.
- El modo SOLO_RESPUESTAS debe ser **visualmente distinto y mínimo**: no mostrar nada que no esté en la lista de la sección 7.2.
- No crear pantallas gigantes con lógica mezclada.
- Mantener la lógica de negocio fuera de los widgets siempre que sea posible.

---

## 22. Pruebas obligatorias

Una funcionalidad **no está terminada** sin pruebas relevantes.

### 22.1. Cobertura mínima requerida

- Ciclo de vida completo del intento (todas las transiciones de estado).
- Modo CONTENIDO_COMPLETO end‑to‑end.
- Modo SOLO_RESPUESTAS end‑to‑end (verificar que el enunciado no se expone).
- Disparo de incidentes y aplicación de política.
- Generación y consumo de token de reingreso.
- Finalización provisional offline y reconciliación.
- Cálculo de resultados (puntaje global, por área, por competencia).
- Permisos de rol (admin, docente, estudiante) en endpoints críticos.

### 22.2. Pruebas backend

- Unit tests de reglas de dominio (máquina de estados, política de incidentes).
- Integration tests de endpoints de intentos.
- Tests de autorización por rol.
- Tests de idempotencia en envío de respuestas.

### 22.3. Pruebas móvil

- Widget tests de estados del examen.
- Unit tests de servicios / repositorios / controladores locales.
- Tests de persistencia offline (survive to restart).
- Tests de serialización de respuestas y eventos.

### 22.4. Pruebas frontend

Al menos para dashboards y acciones críticas, si ya existe infraestructura de tests.

---

## 23. Performance y confiabilidad

- Envío de respuestas: soportar envío en lotes si el volumen lo requiere.
- Reintentos: implementar backoff con límite de intentos.
- Cola de sincronización: dreno completo al reconectar.
- Panel en vivo: evitar polling agresivo; preferir WebSocket.
- Generación de resultados: no bloquear el hilo principal; procesar de forma asíncrona si el volumen es alto.
- Resiliencia a requests duplicadas: idempotencia en todos los endpoints de escritura críticos.

---

## 24. Observabilidad

Implementar o preservar logging / métricas para:

- Transiciones de estado de intentos.
- Incidentes registrados.
- Fallas de sincronización.
- Reingresos autorizados y consumidos.
- Fallas de reconciliación.
- Errores en generación de resultados.
- Latencias en operaciones críticas (iniciar intento, enviar respuesta, reconciliar).

Seguir las convenciones de logging estructurado existentes en el repositorio.

---

## 25. Gestión de secretos y configuración

1. Nunca hardcodear secretos, contraseñas, tokens ni URLs en el código fuente.
2. Nunca commitear credenciales reales al repositorio.
3. Respetar el sistema de variables de entorno definido en el `.env` raíz (ver README sección 3).
4. Si se agrega nueva configuración:
   - Documentarla en README sección 3.
   - Validarla al arrancar la aplicación.
   - Proveer valores default seguros donde aplique.
5. Distinguir configuración pública de la app móvil (puede estar en archivos JSON de entorno bajo `Movil/Entornos/`) de secretos privados del backend (deben estar solo en variables de entorno del servidor).

---

## 26. Flujo obligatorio de trabajo para tareas medianas o grandes

Antes de modificar código en tareas no triviales:

### Paso 1 — Mapear el repositorio

Identificar los puntos de entrada de:

- App móvil
- Backend (API REST y WebSocket)
- Frontend web
- Autenticación
- Exámenes e intentos
- Resultados y analítica
- Panel admin / docente
- ORM / esquema / migraciones Prisma
- Tests / scripts / CI

### Paso 2 — Inventario de lo existente

Clasificar como:

- Implementado y funcional
- Parcialmente implementado
- Faltante
- Duplicado
- Código muerto
- Deuda técnica probable
- Flujo roto o inconsistente

### Paso 3 — Respetar el stack real

- Si el repositorio usa Flutter, seguir con Flutter.
- Si usa NestJS, seguir con NestJS.
- Si usa Next.js, seguir con Next.js.
- Si el stack real difiere de cualquier suposición, seguir el stack del repositorio.

### Paso 4 — Reutilizar convenciones existentes

- Nombres y estructura de carpetas.
- Manejo de estado.
- Envelopes de request/response (ver sección 4.1).
- Theming y diseño.
- Servicios / repositorios / casos de uso.
- Middlewares / guards.
- Logging y manejo de errores.

### Paso 5 — Planificar antes de editar mucho

Dividir el trabajo en:

- Esquema / migraciones Prisma
- Contratos backend
- Cambios app móvil
- Cambios frontend/admin
- Sincronización / colas
- Pruebas
- Documentación

### Paso 6 — Validar después de cada cambio

Ejecutar según disponibilidad:

- Lint
- Formato de código
- Análisis estático
- Tests unitarios
- Build
- Pruebas de integración si existen

### Paso 7 — Resumir exactamente qué cambió

Incluir en el resumen:

- Archivos modificados
- Migraciones agregadas
- Endpoints añadidos o modificados
- Pantallas o flujos cambiados
- Riesgos identificados
- Pendientes
- Supuestos no confirmados

---

## 27. Definición de terminado

Una funcionalidad **no está terminada** hasta que:

1. Está integrada a la arquitectura existente (no es código flotante).
2. Funciona en flujo real, no solo en mocks o demos.
3. Está conectada end‑to‑end cuando aplica (backend ↔ cliente).
4. Tiene validaciones críticas en el backend.
5. Tiene pruebas relevantes (ver sección 22).
6. Las migraciones de base de datos son seguras y reversibles.
7. No rompe flujos existentes (verificado con tests o inspección).
8. El comportamiento visible está resumido claramente en el commit o en documentación.

---

## 28. Comportamiento esperado del agente

Cuando trabajes en este repositorio:

- **Primero entiende, luego edita.** Nunca editar sin auditar primero.
- **Prefiere extender antes que reemplazar.** Solo reemplazar con justificación técnica documentada.
- **Prefiere máquinas de estado explícitas** antes que booleanos dispersos.
- **Prefiere flujos auditables** antes que magia implícita.
- **Prefiere autoridad del servidor** antes que confianza en el cliente.
- **Prefiere resiliencia offline** antes que suposiciones de conectividad perfecta.
- **Prefiere migraciones pequeñas y reversibles** antes que cambios de esquema riesgosos.
- **Prefiere implementaciones completas** antes que placeholders visuales.
- **Si algo está incompleto, duplicado, roto o contradictorio: señálalo claramente** y corrígelo con el cambio más pequeño y confiable posible.
- **Si algo no está claro en este documento o en el repositorio:** no inventes. Señala la ambigüedad, propón la interpretación más conservadora y espera confirmación si el impacto es alto.

---

_Fin de AGENTS.md v2.0_
