# AGENTS-final.md - EvalPro Backend (Especificacion Operativa Completa)
> Documento de cierre funcional para backend NestJS + Prisma.
> Este archivo complementa `AGENTS.md` (raiz) y `Backend/AGENTS.md`.
> Si hay conflicto, prevalecen primero `AGENTS.md` raiz y luego `Backend/AGENTS.md`.
> Fecha de referencia: 2026-03-02.

---

## 1) Objetivo del documento

Definir la logica completa y detallada del backend para que:

1. La autenticacion quede cerrada de punta a punta.
2. La autorizacion por rol + propiedad del recurso sea estricta.
3. El ciclo de vida de examenes, sesiones, intentos, respuestas y telemetria sea consistente.
4. Queden reglas de implementacion, pruebas y criterios de aceptacion verificables.

Este documento es la referencia operativa para pasar de una base funcional minima a una plataforma robusta en produccion.

---

## 2) Modelo de autorizacion (obligatorio)

Toda operacion debe validar SIEMPRE estas 5 capas, en este orden:

1. `Autenticacion`: token valido, no expirado, firma valida.
2. `Rol`: `ADMINISTRADOR`, `DOCENTE`, `ESTUDIANTE`.
3. `Estado de usuario`: `activo = true`.
4. `Propiedad del recurso`: quien creo el examen/sesion o quien es dueno del intento.
5. `Estado del dominio`: BORRADOR/PUBLICADO/ACTIVA/EN_PROGRESO, etc.

Si falla una sola capa, la operacion se rechaza.

---

## 3) Matriz global de roles y permisos

| Recurso / accion | ADMINISTRADOR | DOCENTE | ESTUDIANTE | Validacion adicional obligatoria |
|---|---|---|---|---|
| Gestion de usuarios | Si (total) | No | No | Nunca exponer `contrasena` ni `tokenRefresh` |
| Crear examenes | No (API actual) | Si | No | Creador queda en `creadoPorId` |
| Editar examenes | No (API actual) | Si (solo propios) | No | Solo si `estado = BORRADOR` |
| Publicar examenes | No (API actual) | Si (solo propios) | No | Minimo 1 pregunta valida |
| Archivar examenes | No (API actual) | Si (solo propios) | No | No eliminar fisico |
| Gestion de preguntas | No (API actual) | Si (solo examen propio) | No | Examen en BORRADOR |
| Crear sesiones | No (API actual) | Si (solo examen propio) | No | Examen PUBLICADO |
| Activar/finalizar/cancelar sesion | No (API actual) | Si (solo propia) | No | Transicion de estado valida |
| Buscar sesion por codigo | Si | Si | Si | Respuesta sin datos sensibles |
| Iniciar intento | No | No | Si (propio) | Sesion ACTIVA + no duplicado |
| Obtener examen del intento | No | No | Si (propio) | Nunca enviar `esCorrecta` |
| Sincronizar respuestas | No | No | Si (propio) | `upsert`, idempotente |
| Finalizar intento | No | No | Si (propio) | Intento `EN_PROGRESO` |
| Registrar telemetria | No | No | Si (propio) | Intento debe pertenecer al estudiante |
| Ver telemetria | Si | Si (solo sesiones propias) | No | Solo lectura |
| Reporte por sesion | Si | Si (solo sesiones propias) | No | Agregados sin datos sensibles |
| Reporte por estudiante | Si | Si (solo estudiantes de sus sesiones) | Si (solo propio) | Validar alcance por recurso |

---

## 4) Estados de dominio y transiciones permitidas

### 4.1 Examen (`EstadoExamen`)

| Estado actual | Accion | Estado nuevo | Quien puede |
|---|---|---|---|
| BORRADOR | Publicar | PUBLICADO | DOCENTE dueno |
| BORRADOR | Archivar | ARCHIVADO | DOCENTE dueno |
| PUBLICADO | Archivar | ARCHIVADO | DOCENTE dueno |

Reglas:
- En `PUBLICADO` y `ARCHIVADO` no se edita contenido.
- Publicar exige `totalPreguntas > 0` y consistencia de puntaje maximo.

### 4.2 Sesion (`EstadoSesion`)

| Estado actual | Accion | Estado nuevo | Quien puede |
|---|---|---|---|
| PENDIENTE | Activar | ACTIVA | DOCENTE dueno |
| PENDIENTE | Cancelar | CANCELADA | DOCENTE dueno |
| ACTIVA | Finalizar | FINALIZADA | DOCENTE dueno |
| ACTIVA | Cancelar (emergencia) | CANCELADA | DOCENTE dueno |

Reglas:
- Solo `ACTIVA` permite iniciar intentos.
- `FINALIZADA` y `CANCELADA` son estados terminales.

### 4.3 Intento (`EstadoIntento`)

| Estado actual | Evento | Estado nuevo | Quien lo dispara |
|---|---|---|---|
| EN_PROGRESO | Envio normal | ENVIADO | ESTUDIANTE (propio) |
| EN_PROGRESO | Envio offline sin ACK | SINCRONIZACION_PENDIENTE | ESTUDIANTE (cliente movil) |
| SINCRONIZACION_PENDIENTE | Confirmacion servidor | ENVIADO | Backend |
| EN_PROGRESO / ENVIADO | Invalidacion | ANULADO | DOCENTE dueno |

Reglas:
- `ANULADO` invalida calificacion para reportes oficiales.
- Cualquier cambio de estado debe registrarse con marca de tiempo y actor.

---

## 5) Autenticacion completa (cierre obligatorio)

## 5.1 Inicio de sesion

1. Buscar usuario por correo.
2. Rechazar si no existe o `activo = false`.
3. Comparar hash de contrasena con `bcrypt.compare`.
4. Emitir `tokenAcceso` (15m) y `tokenRefresh` (7d).
5. Guardar SOLO hash del refresh token en DB.
6. Devolver usuario saneado (sin `contrasena`, sin `tokenRefresh`).

## 5.2 Refresh token robusto

1. Validar firma del refresh token con estrategia dedicada (`jwt-refresh`).
2. Extraer `sub` del token, no confiar en `idUsuario` enviado por body.
3. Comparar token recibido contra hash persistido.
4. Rotar ambos tokens y reemplazar hash anterior.
5. Revocar cualquier refresh previo.

## 5.3 Cierre de sesion y revocacion

1. `cerrar-sesion`: pone `tokenRefresh = null`.
2. `cerrar-todas-las-sesiones` (recomendado): invalida refresh actual y de dispositivos asociados.
3. Si hay refresh revocado o inexistente: `403`.

## 5.4 Reglas de seguridad auth

1. Throttling en auth: max 10 intentos/15m por IP + correo.
2. Nunca loguear contrasenas ni tokens completos.
3. Cambios de contrasena obligan revocacion de refresh.
4. JWT con `iss`, `aud`, `iat`, `exp` y clock skew controlado.

---

## 6) Permisos por modulo (detalle operativo)

## 6.1 Usuarios

Reglas:
1. Solo `ADMINISTRADOR` crea/desactiva usuarios.
2. Usuario no admin solo puede ver/editar su propio perfil.
3. Cambio de rol solo por `ADMINISTRADOR`.
4. Cambio de correo exige unicidad y confirmacion (si aplica).

Controles:
1. `GET /usuarios/:id`: admin o mismo usuario.
2. `PATCH /usuarios/:id`: admin o mismo usuario, pero rol solo admin.
3. `DELETE /usuarios/:id`: desactivacion logica, no borrado fisico.

## 6.2 Examenes

Reglas:
1. `DOCENTE` opera solo examenes propios.
2. Examen editable solo en BORRADOR.
3. Publicacion valida estructura y puntajes.
4. Estudiante nunca recibe claves de respuestas.

Controles:
1. `GET /examenes`: admin todo, docente solo propios.
2. `PATCH /examenes/:id`: verificar propiedad + estado BORRADOR.
3. `POST /examenes/:id/publicar`: validar `totalPreguntas > 0`.

## 6.3 Preguntas

Reglas:
1. Crear/editar/eliminar solo para docente dueno del examen.
2. Examen debe estar en BORRADOR.
3. Validar opciones por `TipoPregunta`.
4. Recalcular `totalPreguntas` y `puntajeMaximo` en cada mutacion.

Controles:
1. `listar`: no exponer preguntas de examenes ajenos.
2. `crear`: validar propiedad del examen antes de insertar.
3. `reordenar`: transaccion con verificacion de pertenencia completa.

## 6.4 SesionesExamen

Reglas:
1. Solo examen PUBLICADO puede crear sesiones.
2. Codigo unico `AAAA-1234`, max 5 intentos.
3. Activar/finalizar/cancelar valida estado y propiedad.
4. Al finalizar: emitir evento websocket y calificar intentos pendientes.

Controles:
1. `buscar por codigo`: respuesta minima, sin datos de correccion.
2. `activar`: solo desde PENDIENTE.
3. `finalizar`: solo desde ACTIVA.

## 6.5 Intentos

Reglas:
1. Solo estudiante inicia su propio intento.
2. Un intento por estudiante por sesion (`@@unique`).
3. Inicio solo con sesion ACTIVA.
4. Examen entregado al intento sin campo `esCorrecta`.

Controles:
1. `POST /intentos`: rechazar duplicado con `INTENTO_DUPLICADO`.
2. `GET /intentos/:id/examen`: validar propietario.

## 6.6 Respuestas

Reglas:
1. Sincronizacion en lote idempotente con `upsert`.
2. Solo estudiante dueno del intento.
3. Solo intentos en EN_PROGRESO aceptan actualizaciones.
4. Finalizacion calcula puntaje segun tipo de pregunta.

Controles:
1. `sincronizar-lote`: validar pertenencia + estado.
2. `finalizar`: cambia estado a ENVIADO, set `fechaEnvio`.
3. Preguntas abiertas quedan `esCorrecta = null` (calificacion manual).

## 6.7 Calificacion manual (obligatoria por RESPUESTA_ABIERTA)

Reglas:
1. Endpoint recomendado: `PATCH /respuestas/:id/calificar-manual`.
2. Solo docente dueno de la sesion o admin.
3. Registrar `puntajeObtenido`, observacion y `fechaCalificacion`.
4. Recalcular puntaje total del intento despues de cada calificacion manual.

## 6.8 Telemetria

Reglas:
1. Solo estudiante dueno del intento puede registrar eventos.
2. Eventos criticos disparan alerta inmediata websocket.
3. Al detectar fraude, marcar `esSospechoso = true` y concatenar razon.
4. Deteccion de anomalias corre al finalizar intento y al cierre de sesion.

Controles:
1. `POST /telemetria`: validar propietario del intento.
2. `GET /intentos/:idIntento/telemetria`: admin o docente dueno de sesion.

## 6.9 Reportes

Reglas:
1. Reporte de sesion solo para docente dueno o admin.
2. Reporte de estudiante:
   - admin: cualquiera
   - estudiante: solo propio
   - docente: solo estudiantes que participaron en sesiones propias
3. Excluir datos sensibles en todo reporte.

---

## 7) WebSocket seguro (obligatorio)

1. Namespace oficial: `/sesiones`.
2. Todo socket debe autenticarse con JWT de acceso en handshake.
3. Al unirse a sala, validar permiso real sobre la sesion:
   - docente/admin: puede monitorear
   - estudiante: solo si tiene intento en la sesion
4. No aceptar `idSesion` sin validacion en DB.
5. CORS websocket no debe quedar `origin: '*'` en produccion.

Eventos cliente -> servidor:
1. `unirse_sala_sesion`
2. `progreso_actualizado`
3. `alerta_fraude`

Eventos servidor -> cliente:
1. `sesion:activada`
2. `sesion:finalizada`
3. `estudiante:progreso`
4. `estudiante:fraude_detectado`
5. `comando:finalizar_examen`

---

## 8) Reglas de integridad de datos

1. Toda operacion compuesta debe usar `prisma.$transaction`.
2. No permitir actualizacion de estado con transiciones invalidas.
3. Validar UUID en params (`ParseUUIDPipe` o DTO con `@IsUUID`).
4. Evitar race conditions:
   - inicio de intento (unico por sesion)
   - generacion codigo sesion
   - publicacion simultanea de examen
5. Mantener `totalPreguntas` y `puntajeMaximo` sincronizados con preguntas reales.
6. Normalizar respuestas de seleccion multiple (sin duplicados, orden estable).

---

## 9) Contrato API y errores

Formato de salida obligatorio:

```json
{
  "exito": true,
  "datos": {},
  "mensaje": "Operacion completada exitosamente",
  "marcaTiempo": "2026-03-02T12:00:00.000Z"
}
```

Formato de error obligatorio:

```json
{
  "exito": false,
  "datos": null,
  "mensaje": "Descripcion en espanol",
  "codigoError": "CODIGO_EN_MAYUSCULAS",
  "marcaTiempo": "2026-03-02T12:00:00.000Z"
}
```

Catalogo minimo:
1. `CREDENCIALES_INVALIDAS`
2. `TOKEN_EXPIRADO`
3. `TOKEN_INVALIDO`
4. `SIN_PERMISOS`
5. `RECURSO_NO_ENCONTRADO`
6. `VALIDACION_FALLIDA`
7. `SESION_NO_ACTIVA`
8. `INTENTO_DUPLICADO`
9. `EXAMEN_SIN_PREGUNTAS`
10. `ERROR_INTERNO`

Recomendados adicionales para robustez:
1. `RECURSO_NO_PROPIO`
2. `ESTADO_INVALIDO`
3. `USUARIO_INACTIVO`
4. `FRAUDE_DETECTADO`

---

## 10) Telemetria y anti-fraude (completo)

Eventos criticos:
1. `APLICACION_EN_SEGUNDO_PLANO`
2. `PANTALLA_ABANDONADA`
3. `FORZAR_CIERRE`
4. `SESION_INVALIDA`

Reglas:
1. Si evento critico ocurre, marcar intento sospechoso inmediatamente.
2. Umbral configurable por `.env`:
   - `TELEMETRIA_MAX_EVENTOS_SEGUNDO_PLANO`
   - `TELEMETRIA_SEGUNDOS_MINIMOS_POR_PREGUNTA`
3. Si se supera umbral, concatenar razon de sospecha.
4. Persistir metadatos utiles: bateria, red, version app, foco app.
5. Reportes deben incluir conteo y razones de sospecha.

Politica de sancion sugerida:
1. `sospechoso`: bandera preventiva.
2. `anulado`: decision docente/admin con evidencia de telemetria.

---

## 11) Observabilidad y auditoria

1. Logger estructurado por request con `idCorrelacion`.
2. Registrar actor, recurso, accion, resultado y latencia.
3. No usar `console.log` en produccion.
4. Monitorear:
   - tasa de 401/403
   - tiempo de respuesta por endpoint
   - reconexiones websocket
   - porcentaje de intentos sospechosos por sesion

---

## 12) Suite minima de pruebas obligatorias

## 12.1 Autenticacion
1. Login correcto.
2. Login con credenciales invalidas.
3. Refresh token valido.
4. Refresh token revocado.
5. Logout invalida refresh previo.

## 12.2 Autorizacion
1. Docente no puede editar examen ajeno.
2. Estudiante no puede consultar telemetria.
3. Docente no puede ver estudiante fuera de sus sesiones.
4. Usuario inactivo no puede operar.

## 12.3 Dominio
1. Publicar examen sin preguntas -> `EXAMEN_SIN_PREGUNTAS`.
2. Iniciar intento duplicado -> `INTENTO_DUPLICADO`.
3. Finalizar intento recalcula puntaje y porcentaje.
4. Preguntas abiertas quedan pendientes para calificacion manual.

## 12.4 Telemetria/fraude
1. Evento critico marca sospechoso.
2. Umbral de tiempo minimo dispara anomalia.
3. Emision websocket de fraude llega a sala correcta.

## 12.5 Integracion end-to-end
1. Flujo completo docente: crear examen -> publicar -> crear sesion -> activar -> finalizar.
2. Flujo completo estudiante: unirse -> iniciar intento -> sincronizar -> enviar.
3. Reporte final refleja puntajes, estados y sospechas.

---

## 13) Brechas detectadas en la base actual (a cerrar)

1. Validaciones de propiedad incompletas en algunas operaciones de preguntas.
2. Registro de telemetria debe validar pertenencia del intento al estudiante autenticado.
3. Endpoints con params UUID sin validacion tipada sistematica.
4. WebSocket sin autenticacion fuerte en handshake y con CORS abierto.
5. Falta flujo formal de calificacion manual para `RESPUESTA_ABIERTA`.
6. Cobertura e2e aun minima para reglas de negocio y permisos finos.
7. Control de acceso de reportes por estudiante necesita alcance por sesion del docente.

---

## 14) Plan de implementacion recomendado (orden estricto)

Fase A - Seguridad y autorizacion:
1. Endurecer refresh token flow con estrategia `jwt-refresh`.
2. Aplicar validaciones de propiedad faltantes.
3. Bloquear usuarios inactivos en guard global.
4. Cerrar CORS websocket y agregar autenticacion de socket.

Fase B - Dominio y consistencia:
1. Completar transiciones de estado (incluye cancelar sesion y anular intento).
2. Agregar calificacion manual de preguntas abiertas.
3. Reforzar transacciones en operaciones compuestas.
4. Validar UUID en todos los endpoints.

Fase C - Telemetria y reportes:
1. Endurecer deteccion de anomalias con umbrales de `.env`.
2. Registrar evidencia de fraude explotable por docente.
3. Ajustar permisos de reporte por estudiante segun sesiones del docente.

Fase D - Calidad:
1. Ampliar pruebas unitarias + e2e por modulo.
2. Definir fixtures de datos reproducibles.
3. Exigir CI verde para merge.

---

## 15) Definicion de terminado (Definition of Done)

Se considera backend "completo y estable" cuando:

1. Todas las reglas de este documento estan implementadas.
2. Ninguna ruta permite acceso por rol incorrecto ni recurso ajeno.
3. Todos los flujos de estado invalidos son rechazados.
4. El estudiante nunca recibe respuestas correctas antes de enviar.
5. Telemetria identifica y reporta fraude con trazabilidad.
6. Pruebas e2e y unitarias pasan en CI.
7. Swagger refleja contratos reales y ejemplos en espanol.
