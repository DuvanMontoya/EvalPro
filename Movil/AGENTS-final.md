# AGENTS-final.md - EvalPro Movil (Especificacion Operativa Completa)
> Documento de cierre funcional para `Movil/` (Flutter + Riverpod + Drift).
> Complementa `AGENTS.md` raiz y `Movil/AGENTS.md`.
> Si hay conflicto: 1) `AGENTS.md` raiz, 2) `Movil/AGENTS.md`, 3) este archivo.
> Fecha de referencia: 2026-03-02.

---

## 1) Objetivo

Definir la logica movil completa para que la app:

1. Ejecute examenes sin huecos de flujo.
2. Sea robusta offline-first con sincronizacion confiable.
3. Refuerce anti-trampa con modo kiosco y telemetria.
4. Mantenga seguridad de tokens y datos locales.
5. Quede totalmente alineada con el backend actual.

---

## 2) Alcance funcional movil

La app movil de EvalPro esta orientada principalmente a `ESTUDIANTE`.

Flujos cubiertos:

1. Iniciar sesion segura.
2. Buscar sesion por codigo.
3. Unirse a sesion activa.
4. Resolver examen en modalidad:
   - `DIGITAL_COMPLETO`
   - `HOJA_RESPUESTAS`
5. Guardar respuestas localmente.
6. Sincronizar online/offline.
7. Enviar examen y mostrar resultado cuando aplique.

---

## 3) Arquitectura movil completa

### 3.1 Capas y responsabilidad

1. `Pantallas/`: presentacion y navegacion.
2. `Providers/`: estado de sesion, examen, conectividad y sincronizacion.
3. `Servicios/`: HTTP, socket, telemetria, negocio de dominio.
4. `BaseDatosLocal/`: persistencia offline (Drift).
5. `ModoExamen/`: integracion nativa anti-trampa.
6. `Modelos/`: contrato tipado de datos backend.
7. `Utilidades/`: aleatorizacion y helpers de validacion.

Regla: `Pantallas` no conocen detalles de red/DB. Todo pasa por providers/servicios.

### 3.2 Mapa operativo por archivo clave

| Archivo | Responsabilidad obligatoria |
|---|---|
| `Aplicacion.dart` | Router global y reglas de redireccion por sesion/intento |
| `ApiServicio.dart` | Dio + interceptores JWT + refresh + parseo de respuesta estandar |
| `AutenticacionServicio.dart` | login/logout y persistencia en secure storage |
| `ExamenProvider.dart` | orquestacion completa del examen activo |
| `SincronizacionServicio.dart` | batch de pendientes y politica de reintentos |
| `TelemetriaServicio.dart` | registro remoto/local de eventos de fraude |
| `SocketServicio.dart` | eventos tiempo real progreso/fraude |
| `ModoExamenServicio.dart` | kiosco + observer ciclo de vida |

---

## 4) Seguridad de sesion y tokens

### 4.1 Almacenamiento de credenciales

1. `tokenAcceso` en `flutter_secure_storage`.
2. `tokenRefresh` en `flutter_secure_storage`.
3. Usuario autenticado serializado en almacenamiento seguro.
4. Nunca persistir tokens en `SharedPreferences`.

### 4.2 Flujo auth movil completo

1. Login -> `POST /autenticacion/iniciar-sesion`.
2. Guardar tokens + usuario.
3. Interceptor agrega bearer token en cada request.
4. Si `401`:
   - usar refresh token en `/autenticacion/refrescar-tokens`
   - actualizar tokens
   - reintentar request original una sola vez
5. Si refresh falla:
   - limpiar secure storage
   - reset de estado auth
   - volver a login.

### 4.3 Reglas no negociables

1. No imprimir tokens en logs.
2. No continuar examen con sesion invalida.
3. Logout limpia SIEMPRE almacenamiento local, aunque backend falle.

---

## 5) Contrato backend consumido por movil

### 5.1 Endpoints obligatorios

Autenticacion:
1. `POST /autenticacion/iniciar-sesion`
2. `POST /autenticacion/refrescar-tokens`
3. `POST /autenticacion/cerrar-sesion`

Sesion/intento:
1. `GET /sesiones/buscar/:codigo`
2. `POST /intentos`
3. `GET /intentos/:idIntento/examen`

Respuestas y telemetria:
1. `POST /respuestas/sincronizar-lote`
2. `POST /intentos/:idIntento/finalizar`
3. `POST /telemetria`

### 5.2 Formato de respuesta estandar

Todos los servicios deben mapear:

```json
{
  "exito": true,
  "datos": {},
  "mensaje": "Operacion completada exitosamente",
  "marcaTiempo": "2026-03-02T00:00:00.000Z"
}
```

Si `exito=false` o `datos=null`, lanzar error de dominio controlado.

---

## 6) Flujo end-to-end completo del estudiante

## 6.1 Login y entrada

1. Usuario abre `IniciarSesionPantalla`.
2. `AutenticacionProvider.iniciarSesion()`.
3. `Aplicacion.dart` redirige a `/inicio`.

## 6.2 Busqueda de sesion

1. `UnirseASesionPantalla` recibe codigo.
2. `SesionProvider.buscarPorCodigo(codigo)`.
3. Segun `EstadoSesion`:
   - `PENDIENTE`: informar "espera activacion".
   - `ACTIVA`: habilitar boton "Unirse".
   - `FINALIZADA/CANCELADA`: bloquear union.

## 6.3 Inicio de intento y descarga de examen

Al tocar "Unirse":

1. `IntentoServicio.iniciar(idSesion)`.
2. `ExamenServicio.obtenerParaIntento(idIntento)`.
3. Aleatorizar preguntas/opciones con semilla determinista.
4. Persistir examen en Drift para continuidad offline.
5. Activar modo kiosco.
6. Registrar telemetria `INICIO_EXAMEN`.
7. Navegar a pantalla segun modalidad.

## 6.4 Resolucion de preguntas

Cada respuesta:

1. Se guarda en memoria (`ExamenActivoEstado`).
2. Se guarda en Drift (`RespuestasLocalTabla`).
3. Se registra telemetria `RESPUESTA_GUARDADA`.
4. Si hay conectividad:
   - sincronizar lote incremental.
5. Si no hay conectividad:
   - queda pendiente para sincronizacion posterior.

## 6.5 Finalizacion

1. Sincronizar pendientes.
2. `POST /intentos/:idIntento/finalizar`.
3. Registrar `EXAMEN_ENVIADO`.
4. Desactivar kiosco y detener monitoreo ciclo de vida.
5. Limpiar examen local del intento.
6. Navegar a `ExamenEnviadoPantalla` (o resumen con puntaje si aplica).

---

## 7) Modalidades de examen y comportamiento UI

## 7.1 `DIGITAL_COMPLETO`

1. Una pregunta por pantalla.
2. Soporte a los cuatro tipos de pregunta.
3. Navegacion condicionada por `permitirNavegacion`.
4. Temporizador visible y envio automatico al expirar tiempo.

## 7.2 `HOJA_RESPUESTAS`

1. Cuadricula OMR A/B/C/D/E por pregunta.
2. Respuesta unica por fila.
3. Cambio de opcion permitido hasta envio final.
4. Mapa de progreso visible todo el tiempo.

---

## 8) Offline-first y persistencia local

### 8.1 Drift obligatorio

Tablas:

1. `ExamenesLocalTabla`
2. `RespuestasLocalTabla`
3. `TelemetriaLocalTabla`

### 8.2 Politica de sincronizacion

1. Trigger inmediato al recuperar conectividad.
2. Reintentos:
   - intento 1: inmediato
   - intento 2: 30s
   - intento 3: 2min
   - intento 4+: 5min
3. Maximo 10 reintentos por respuesta.
4. Si supera maximo:
   - registrar evento `SESION_INVALIDA`
   - emitir alerta de fraude al docente.

### 8.3 Idempotencia

1. Backend usa `upsert` por `intentoId + preguntaId`.
2. Movil puede reenviar lote sin riesgo de duplicados.

---

## 9) Modo kiosco y anti-trampa

### 9.1 Activacion

1. Activar al iniciar examen.
2. Si falla activacion:
   - registrar error de telemetria
   - continuar examen (falla suave).

### 9.2 Monitoreo ciclo de vida

Cuando app pasa a `paused/inactive` durante intento activo:

1. registrar `APLICACION_EN_SEGUNDO_PLANO`.
2. emitir alerta socket de fraude.

### 9.3 Desactivacion

1. Desactivar SIEMPRE al enviar examen.
2. Desactivar tambien en abortos o cierres forzados controlados.

---

## 10) Telemetria funcional completa

Eventos minimos:

1. `INICIO_EXAMEN`
2. `CAMBIO_PREGUNTA`
3. `RESPUESTA_GUARDADA`
4. `APLICACION_EN_SEGUNDO_PLANO`
5. `EXAMEN_ENVIADO`
6. `SINCRONIZACION_COMPLETADA` (cuando corresponda)

Reglas:

1. Priorizar envio inmediato.
2. Si falla red, persistir local y sincronizar despues.
3. Incluir metadatos utiles: `numeroPregunta`, `tiempoTranscurrido`, version app.

---

## 11) Socket en movil

### 11.1 Objetivo

1. Emitir progreso del estudiante.
2. Emitir alertas de fraude en tiempo real.

### 11.2 Reglas de conexion

1. Conectar al namespace de sesiones.
2. Unirse a sala con `idSesion` y `rol`.
3. Desconectar al salir del examen o cerrar sesion.

### 11.3 Eventos movil -> servidor

1. `unirse_sala_sesion`
2. `progreso_actualizado`
3. `alerta_fraude`

---

## 12) Reglas de providers Riverpod

## 12.1 `AutenticacionProvider`

1. Fuente de verdad de sesion.
2. `build()` carga sesion persistida al iniciar app.
3. `cerrarSesion()` resetea estado global.

## 12.2 `ExamenProvider`

1. Fuente de verdad de examen activo.
2. Maneja:
   - inicio de intento
   - respuesta local/remota
   - avance/retroceso
   - envio final
3. Estado inmutable via `ExamenActivoEstado`.

## 12.3 `ConectividadProvider`

1. Escucha cambios de red.
2. Cuando vuelve internet, dispara sincronizacion.

## 12.4 `RespuestaProvider`

1. Permite sincronizacion manual/forzada por intento.
2. Exponer conteo de pendientes para UI.

---

## 13) Navegacion y guardas de rutas

Reglas `go_router`:

1. Sin sesion -> solo `/iniciar-sesion`.
2. Con sesion -> bloquear retorno a login.
3. Ruta `/examen/*` exige intento/examen activo (excepto `unirse`).
4. Si intento desaparece o sesion invalida -> redirigir a ruta de error.

---

## 14) Manejo de errores y recuperacion

### 14.1 Errores de red

1. Mostrar `IndicadorConexion`.
2. Mantener captura local de respuestas.
3. No bloquear avance por falta de internet.

### 14.2 Errores de dominio

1. `SESION_NO_ACTIVA`: volver a pantalla de union con mensaje.
2. `INTENTO_DUPLICADO`: recuperar intento existente o informar bloqueo.
3. `TOKEN_INVALIDO/TOKEN_EXPIRADO`: limpiar sesion y volver a login.

### 14.3 Errores fatales

1. Si no se puede recuperar estado de intento local -> `SesionInvalidadaPantalla`.
2. Garantizar desactivacion de kiosco en teardown.

---

## 15) Seguridad de datos locales

1. No almacenar respuestas en texto plano fuera de Drift.
2. Limpiar datos del intento al finalizar envio.
3. Evitar retencion indefinida de telemetria vieja.
4. En logout:
   - limpiar secure storage
   - limpiar cache temporal no enviada cuando aplique politicas del negocio.

---

## 16) Matriz minima de pruebas movil

### 16.1 Autenticacion

1. Login exitoso persiste credenciales.
2. Refresh en 401 reintenta request.
3. Refresh fallido limpia sesion.

### 16.2 Flujo de examen

1. Iniciar intento y descargar examen.
2. Guardar respuesta local por cada tipo de pregunta.
3. Envio final cambia estado y limpia local.

### 16.3 Offline/sync

1. Sin red: respuestas quedan pendientes.
2. Recuperar red: sincroniza y marca `esSincronizada`.
3. Reintentos aplican politica de espera correcta.

### 16.4 Anti-trampa

1. Pausar app registra evento de fraude.
2. Modo kiosco activa/desactiva segun ciclo.
3. Telemetria pendiente se sincroniza luego.

---

## 17) Brechas detectadas en base movil actual (a cerrar)

1. `SocketServicio` debe asegurar conexion al namespace `/sesiones` del backend.
2. Falta verificacion explicita de rol `ESTUDIANTE` post login para bloquear otros roles.
3. Falta cobertura de pruebas automatizadas en providers criticos.
4. Falta politica formal de limpieza historica de telemetria local sincronizada.
5. Falta estandar de mensajes de error de negocio en algunas pantallas.

---

## 18) Plan de implementacion recomendado

Fase A - Seguridad y conexion:
1. asegurar namespace websocket correcto y autenticacion de handshake.
2. validar rol estudiante en inicio de sesion.
3. robustecer limpieza de sesion y teardown de kiosco.

Fase B - Offline y dominio:
1. endurecer reintentos y observabilidad de sincronizacion.
2. agregar estado UI claro para pendientes por intento.
3. reforzar recuperacion de intento tras reinicio de app.

Fase C - Calidad:
1. pruebas unitarias servicios/provides.
2. pruebas de widget para pantallas de examen.
3. pruebas de integracion de flujo completo.

---

## 19) Definition of Done movil

La app movil se considera lista cuando:

1. Flujo estudiante funciona completo online y offline.
2. No hay perdida de respuestas ante reconexion o cierre inesperado.
3. Kiosco/telemetria reportan eventos de fraude correctamente.
4. Tokens se manejan con seguridad y refresh estable.
5. Navegacion no permite rutas inconsistentes de estado.
6. Sincronizacion y envio final quedan trazables y reproducibles.
7. Pruebas criticas pasan en CI.

