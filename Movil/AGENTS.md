# AGENTS.md — EvalPro · App Móvil (Flutter 3.x + Riverpod + Drift)
> Complementa `/AGENTS.md` raíz. Lee primero el raíz, luego este.
> Aplica a todos los archivos dentro de `Movil/`.

---

## ESTRUCTURA DE DIRECTORIOS EXACTA

```
Movil/
├── lib/
│   ├── main.dart                              ← Punto de entrada Flutter
│   ├── Aplicacion.dart                        ← ProviderScope + MaterialApp.router
│   ├── Constantes/
│   │   ├── Colores.dart
│   │   ├── Dimensiones.dart
│   │   ├── Textos.dart
│   │   ├── Rutas.dart
│   │   └── ApiEndpoints.dart
│   ├── Configuracion/
│   │   ├── Tema.dart
│   │   └── Entorno.dart
│   ├── Modelos/
│   │   ├── Enums/
│   │   │   ├── RolUsuario.dart
│   │   │   ├── TipoPregunta.dart
│   │   │   ├── ModalidadExamen.dart
│   │   │   ├── EstadoSesion.dart
│   │   │   ├── EstadoIntento.dart
│   │   │   └── TipoEventoTelemetria.dart
│   │   ├── Usuario.dart
│   │   ├── Examen.dart
│   │   ├── Pregunta.dart
│   │   ├── OpcionRespuesta.dart
│   │   ├── SesionExamen.dart
│   │   ├── IntentoExamen.dart
│   │   ├── RespuestaLocal.dart
│   │   └── EventoTelemetria.dart
│   ├── Servicios/
│   │   ├── ApiServicio.dart                   ← Dio configurado
│   │   ├── AutenticacionServicio.dart
│   │   ├── ExamenServicio.dart
│   │   ├── SesionServicio.dart
│   │   ├── IntentoServicio.dart
│   │   ├── RespuestaServicio.dart
│   │   ├── SincronizacionServicio.dart
│   │   ├── TelemetriaServicio.dart
│   │   └── SocketServicio.dart
│   ├── BaseDatosLocal/
│   │   ├── BaseDatosLocal.dart                ← @DriftDatabase
│   │   ├── Tablas/
│   │   │   ├── ExamenesLocalTabla.dart
│   │   │   ├── RespuestasLocalTabla.dart
│   │   │   └── TelemetriaLocalTabla.dart
│   │   └── Daos/
│   │       ├── ExamenDao.dart
│   │       ├── RespuestaDao.dart
│   │       └── TelemetriaDao.dart
│   ├── Providers/
│   │   ├── AutenticacionProvider.dart
│   │   ├── ExamenProvider.dart
│   │   ├── SesionProvider.dart
│   │   ├── RespuestaProvider.dart
│   │   └── ConectividadProvider.dart
│   ├── Pantallas/
│   │   ├── Autenticacion/
│   │   │   ├── IniciarSesionPantalla.dart
│   │   │   └── Widgets/
│   │   │       └── FormularioLogin.dart
│   │   ├── Inicio/
│   │   │   ├── InicioPantalla.dart
│   │   │   └── Widgets/
│   │   │       └── TarjetaSesionDisponible.dart
│   │   ├── Examen/
│   │   │   ├── UnirseASesionPantalla.dart
│   │   │   ├── ExamenActivoPantalla.dart
│   │   │   ├── HojaRespuestasPantalla.dart
│   │   │   ├── ResumenExamenPantalla.dart
│   │   │   ├── ExamenEnviadoPantalla.dart
│   │   │   └── Widgets/
│   │   │       ├── TarjetaPregunta.dart
│   │   │       ├── OpcionSeleccionable.dart
│   │   │       ├── CampoPreguntaAbierta.dart
│   │   │       ├── NavegadorPreguntas.dart
│   │   │       ├── MapaProgreso.dart
│   │   │       ├── CuadriculaOMR.dart
│   │   │       ├── BotonRespuestaOMR.dart
│   │   │       ├── TemporizadorExamen.dart
│   │   │       └── IndicadorConexion.dart
│   │   └── Error/
│   │       ├── SinConexionPantalla.dart
│   │       └── SesionInvalidadaPantalla.dart
│   ├── ModoExamen/
│   │   ├── ModoExamenServicio.dart
│   │   ├── Android/
│   │   │   └── ModoKioscoAndroid.dart
│   │   └── iOS/
│   │       └── ModoKioscoIOS.dart
│   └── Utilidades/
│       ├── AleatorizadorLocal.dart
│       ├── FormateadorFecha.dart
│       └── ValidadorConectividad.dart
├── android/
│   └── app/src/main/kotlin/com/evalPro/movil/
│       ├── MainActivity.kt
│       └── ModoKiosco/
│           └── ModoKioscoPlugin.kt
├── ios/
│   └── Runner/
│       ├── AppDelegate.swift
│       └── ModoKiosco/
│           └── ModoKioscoPlugin.swift
├── test/
├── pubspec.yaml
└── pubspec.lock
```

---

## DEPENDENCIAS EXACTAS DEL `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0
  dio: ^5.4.0
  drift: ^2.17.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.1.0
  path: ^1.9.0
  flutter_secure_storage: ^9.0.0
  connectivity_plus: ^6.0.0
  socket_io_client: ^2.0.3+1
  go_router: ^13.0.0
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.0
  drift_dev: ^2.17.0
  riverpod_generator: ^2.4.0
```

---

## MODELOS DART — PATRÓN EXACTO

Todos los modelos usan `fromJson` / `toJson` para serialización. No usar `json_serializable`
generado — escribir los métodos manualmente para control total.

```dart
/// @archivo   Examen.dart
/// @descripcion Modelo de datos para un examen descargado del backend.
/// @modulo    Modelos
/// @autor     EvalPro
/// @fecha     YYYY-MM-DD

class Examen {
  final String id;
  final String titulo;
  final String? descripcion;
  final String? instrucciones;
  final ModalidadExamen modalidad;
  final int duracionMinutos;
  final int totalPreguntas;
  final bool permitirNavegacion;
  final bool mostrarPuntaje;
  final List<Pregunta> preguntas;

  const Examen({
    required this.id,
    required this.titulo,
    this.descripcion,
    this.instrucciones,
    required this.modalidad,
    required this.duracionMinutos,
    required this.totalPreguntas,
    required this.permitirNavegacion,
    required this.mostrarPuntaje,
    required this.preguntas,
  });

  factory Examen.fromJson(Map<String, dynamic> json) => Examen(
    id: json['id'] as String,
    titulo: json['titulo'] as String,
    descripcion: json['descripcion'] as String?,
    instrucciones: json['instrucciones'] as String?,
    modalidad: ModalidadExamen.values.byName(json['modalidad'] as String),
    duracionMinutos: json['duracionMinutos'] as int,
    totalPreguntas: json['totalPreguntas'] as int,
    permitirNavegacion: json['permitirNavegacion'] as bool,
    mostrarPuntaje: json['mostrarPuntaje'] as bool,
    preguntas: (json['preguntas'] as List<dynamic>)
        .map((p) => Pregunta.fromJson(p as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'descripcion': descripcion,
    'instrucciones': instrucciones,
    'modalidad': modalidad.name,
    'duracionMinutos': duracionMinutos,
    'totalPreguntas': totalPreguntas,
    'permitirNavegacion': permitirNavegacion,
    'mostrarPuntaje': mostrarPuntaje,
    'preguntas': preguntas.map((p) => p.toJson()).toList(),
  };
}
```

---

## BASE DE DATOS LOCAL DRIFT — ESQUEMA EXACTO

### `BaseDatosLocal/Tablas/ExamenesLocalTabla.dart`

```dart
class ExamenesLocalTabla extends Table {
  TextColumn get id => text()();
  TextColumn get contenidoJson => text()();   // JSON.stringify del Examen completo
  TextColumn get idSesion => text()();
  TextColumn get idIntento => text()();
  IntColumn get fechaDescarga => integer()(); // millisecondsSinceEpoch

  @override
  Set<Column> get primaryKey => {id};
}
```

### `BaseDatosLocal/Tablas/RespuestasLocalTabla.dart`

```dart
class RespuestasLocalTabla extends Table {
  TextColumn get id => text()();
  TextColumn get idIntento => text()();
  TextColumn get idPregunta => text()();
  TextColumn get valorTexto => text().nullable()();
  TextColumn get opcionesSeleccionadas => text().nullable()(); // JSON array ['A','C']
  IntColumn get tiempoRespuesta => integer().nullable()();     // segundos
  IntColumn get fechaRespuesta => integer()();                 // millisecondsSinceEpoch
  BoolColumn get esSincronizada => boolean().withDefault(const Constant(false))();
  IntColumn get reintentosSincronizacion => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
```

### `BaseDatosLocal/Tablas/TelemetriaLocalTabla.dart`

```dart
class TelemetriaLocalTabla extends Table {
  TextColumn get id => text()();
  TextColumn get idIntento => text()();
  TextColumn get tipo => text()();              // nombre del enum TipoEventoTelemetria
  TextColumn get metadatos => text().nullable()();
  IntColumn get numeroPregunta => integer().nullable()();
  IntColumn get tiempoTranscurrido => integer().nullable()();
  IntColumn get fechaEvento => integer()();     // millisecondsSinceEpoch
  BoolColumn get esSincronizada => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
```

---

## PROVIDERS RIVERPOD — PATRÓN EXACTO

Todos los providers usan `@riverpod` con generación de código. Ejecutar
`flutter pub run build_runner build` después de crear providers.

### `Providers/ExamenProvider.dart`

Este provider maneja todo el estado del examen activo. Es el más complejo:

```dart
@riverpod
class ExamenActivo extends _$ExamenActivo {
  // Estado inicial: null (sin examen activo)
  @override
  ExamenActivoEstado? build() => null;

  // Inicia el examen: descarga, aleatoriza, guarda en Drift, activa Kiosco
  Future<void> iniciarExamen(SesionExamen sesion) async { ... }

  // Registra la respuesta del estudiante para la pregunta actual
  Future<void> registrarRespuesta(String idPregunta, dynamic valor) async { ... }

  // Avanza a la siguiente pregunta y registra telemetría
  void avanzarPregunta() { ... }

  // Retrocede a la pregunta anterior (si el examen lo permite)
  void retrocederPregunta() { ... }

  // Sincroniza todo y envía el examen al backend
  Future<ResultadoFinalDto?> finalizarYEnviar() async { ... }
}

// Clase de estado inmutable
class ExamenActivoEstado {
  final Examen examen;
  final List<Pregunta> preguntasAleatorizadas;
  final int indicePreguntaActual;
  final Map<String, RespuestaLocal> respuestasLocales;  // clave: idPregunta
  final DateTime tiempoInicioExamen;
  final DateTime tiempoInicioPreguntaActual;
  final bool estaEnviando;
  final String? errorEnvio;
  // ... constructor, copyWith, getters calculados
}
```

**Lógica exacta de `iniciarExamen`:**
1. Llama a `IntentoServicio.iniciar(sesion.id)` para crear el intento en backend.
   Guarda `idIntento` y `semillaPersonal` retornados.
2. Llama a `ExamenServicio.obtenerParaIntento(idIntento)` → recibe el examen sin `esCorrecta`.
3. Calcula `semillaPersonal = sesion.semillaGrupo * idEstudiante.hashCode % 999999`.
4. Usa `AleatorizadorLocal.aleatorizar(preguntas, semillaPersonal)` para reordenar preguntas.
5. Para cada pregunta, usa `AleatorizadorLocal.aleatorizar(opciones, semillaPersonal + orden)`
   para reordenar las opciones.
6. Serializa el examen aleatorizado a JSON y guarda en Drift `ExamenesLocalTabla`.
7. Llama a `ModoExamenServicio.activarModoKiosco()`.
8. Registra evento de telemetría `INICIO_EXAMEN`.
9. Actualiza el estado del provider.

**Lógica exacta de `registrarRespuesta`:**
1. Crea `RespuestaLocal` con los datos + `esSincronizada = false`.
2. Guarda en Drift `RespuestasLocalTabla` con `upsert` (conflicto por idPregunta+idIntento).
3. Actualiza `respuestasLocales` en el estado del provider.
4. Registra evento de telemetría `RESPUESTA_GUARDADA`.
5. Si hay conexión disponible (`ConectividadProvider`): sincroniza inmediatamente con backend.
   Si no hay conexión: encola (la sincronización ocurrirá al recuperar conexión).
6. Calcula tiempo invertido en esta pregunta para el campo `tiempoRespuesta`.

**Lógica exacta de `finalizarYEnviar`:**
1. Sincroniza todas las respuestas pendientes.
2. Llama a `POST /intentos/:idIntento/finalizar`.
3. Desactiva el modo kiosco con `ModoExamenServicio.desactivarModoKiosco()`.
4. Elimina el examen de Drift (ya no se necesita offline).
5. Retorna el `ResultadoFinalDto` si el examen muestra puntaje.

---

## SINCRONIZACIÓN OFFLINE — LÓGICA EXACTA

### `Servicios/SincronizacionServicio.dart`

```
POLÍTICA DE REINTENTOS:
  - Reintento 1: inmediato al recuperar conexión
  - Reintento 2: esperar 30 segundos
  - Reintento 3: esperar 2 minutos
  - Reintento 4+: cada 5 minutos
  - Máximo 10 reintentos
  - Si supera 10: marcar como SINCRONIZACION_PENDIENTE en backend + notificar al docente

FLUJO AL RECUPERAR CONEXIÓN:
  1. ConectividadProvider detecta cambio a 'conectado'
  2. SincronizacionServicio consulta RespuestasLocalTabla WHERE esSincronizada = 0
  3. Si hay respuestas pendientes:
     a. Llama a POST /respuestas/sincronizar-lote con todas juntas en un batch
     b. Backend hace upsert (no duplica aunque ya existan)
     c. Al recibir 200: marcar todas como esSincronizada = 1 en Drift
  4. Consulta TelemetriaLocalTabla WHERE esSincronizada = 0
  5. Sincroniza eventos de telemetría pendientes en lote
```

---

## MODO KIOSCO / ANTI-TRAMPA — IMPLEMENTACIÓN EXACTA

### `ModoExamen/ModoExamenServicio.dart`

Nombre del MethodChannel (EXACTO, debe coincidir en Kotlin y Swift):
```dart
static const _canal = MethodChannel('com.evalPro.movil/modoKiosco');
```

```dart
/// Activa el modo kiosco. Retorna true si se activó exitosamente.
/// Lanza PlatformException si el SO rechaza el bloqueo.
Future<bool> activarModoKiosco() async {
  try {
    final resultado = await _canal.invokeMethod<bool>('activar');
    return resultado ?? false;
  } on PlatformException catch (e) {
    // Registrar el error de telemetría pero NO lanzar excepción
    // El examen continúa aunque el modo kiosco falle (falla suave)
    await _telemetriaServicio.registrarError('MODO_KIOSCO_FALLO', e.message);
    return false;
  }
}

/// Desactiva el modo kiosco. Llamar siempre al enviar o anular el examen.
Future<void> desactivarModoKiosco() async {
  await _canal.invokeMethod<void>('desactivar');
}
```

**Monitoreo del ciclo de vida** — en `ModoExamenServicio.dart`:
```dart
// Implementa WidgetsBindingObserver
void didChangeAppLifecycleState(AppLifecycleState estado) {
  if (estado == AppLifecycleState.paused ||
      estado == AppLifecycleState.inactive) {
    // La app fue enviada al fondo — EVENTO DE FRAUDE
    _telemetriaServicio.registrarEventoSync(
      TipoEventoTelemetria.APLICACION_EN_SEGUNDO_PLANO,
    );
    _socketServicio.emitirAlertaFraude(
      TipoEventoTelemetria.APLICACION_EN_SEGUNDO_PLANO,
    );
  }
}
```

### `android/MainActivity.kt` — Código Kotlin EXACTO

```kotlin
/**
 * @archivo   MainActivity.kt
 * @descripcion Actividad principal Android. Registra el MethodChannel
 *              para el modo kiosco usando startLockTask() y FLAG_SECURE.
 * @modulo    ModoKiosco (Android nativo)
 * @autor     EvalPro
 * @fecha     YYYY-MM-DD
 */
package com.evalPro.movil

import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CANAL_KIOSCO = "com.evalPro.movil/modoKiosco"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CANAL_KIOSCO
        ).setMethodCallHandler { llamada, resultado ->
            when (llamada.method) {
                "activar" -> {
                    // FLAG_SECURE: bloquea capturas de pantalla y grabación
                    window.setFlags(
                        WindowManager.LayoutParams.FLAG_SECURE,
                        WindowManager.LayoutParams.FLAG_SECURE
                    )
                    // startLockTask: inicia el modo kiosco — pide confirmación al usuario
                    startLockTask()
                    resultado.success(true)
                }
                "desactivar" -> {
                    stopLockTask()
                    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    resultado.success(null)
                }
                else -> resultado.notImplemented()
            }
        }
    }
}
```

### `ios/Runner/AppDelegate.swift` — Código Swift EXACTO

```swift
/**
 * @archivo   AppDelegate.swift
 * @descripcion AppDelegate iOS. Registra el MethodChannel para el modo
 *              examen usando AEAssessmentSession de Apple.
 * @modulo    ModoKiosco (iOS nativo)
 * @autor     EvalPro
 * @fecha     YYYY-MM-DD
 */
import UIKit
import Flutter
import AutomaticAssessmentConfiguration

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

    private var sesionEvaluacion: AEAssessmentSession?
    private let CANAL_KIOSCO = "com.evalPro.movil/modoKiosco"

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        let controlador = window?.rootViewController as! FlutterViewController
        let canal = FlutterMethodChannel(
            name: CANAL_KIOSCO,
            binaryMessenger: controlador.binaryMessenger
        )

        canal.setMethodCallHandler { [weak self] (llamada, resultado) in
            guard let self = self else { return }
            switch llamada.method {
            case "activar":
                let configuracion = AEAssessmentConfiguration()
                // AEAssessmentSession deshabilita automáticamente:
                // capturas, grabación, autocompletar, diccionarios, notificaciones
                let sesion = AEAssessmentSession(configuration: configuracion)
                sesion.delegate = self
                sesion.begin()
                self.sesionEvaluacion = sesion
                resultado(true)
            case "desactivar":
                self.sesionEvaluacion?.end()
                self.sesionEvaluacion = nil
                resultado(nil)
            default:
                resultado(FlutterMethodNotImplemented)
            }
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

extension AppDelegate: AEAssessmentSessionDelegate {
    // El estudiante intentó forzar el cierre o hubo interrupción
    func assessmentSession(
        _ session: AEAssessmentSession,
        wasInterruptedWithError error: Error
    ) {
        // Notificar a Flutter via EventChannel (implementar si se requiere canal de eventos)
        // El ModoExamenServicio detectará esto via AppLifecycleState
        sesionEvaluacion = nil
    }

    func assessmentSession(
        _ session: AEAssessmentSession,
        failedToBeginWithError error: Error
    ) {
        // El SO rechazó iniciar la sesión de evaluación
        sesionEvaluacion = nil
    }
}
```

---

## ALEATORIZACIÓN DETERMINISTA — `AleatorizadorLocal.dart`

Implementar exactamente este algoritmo Linear Congruential Generator (LCG).
**No usar `Random()` de Dart — es no determinista entre sesiones.**

```dart
/// @archivo   AleatorizadorLocal.dart
/// @descripcion Implementa Fisher-Yates shuffle con LCG determinista.
///              Garantiza que la misma semilla produce siempre el mismo orden.
///              Estudiantes con diferente semilla personal tendrán orden distinto.
/// @modulo    Utilidades
/// @autor     EvalPro
/// @fecha     YYYY-MM-DD

class AleatorizadorLocal {
  // Parámetros estándar del LCG (Numerical Recipes)
  static const int _a = 1664525;
  static const int _c = 1013904223;
  static const int _m = 0xFFFFFFFF; // 2^32 - 1

  int _semillaActual;

  AleatorizadorLocal(int semilla) : _semillaActual = semilla;

  /// Genera el siguiente entero pseudoaleatorio en el rango [0, maximo)
  int siguienteEntero(int maximo) {
    _semillaActual = (_a * _semillaActual + _c) & _m;
    return _semillaActual % maximo;
  }

  /// Aplica Fisher-Yates shuffle a la lista usando esta semilla.
  /// Retorna una nueva lista. No modifica la original.
  List<T> aleatorizar<T>(List<T> lista) {
    final resultado = List<T>.from(lista);
    for (int i = resultado.length - 1; i > 0; i--) {
      final j = siguienteEntero(i + 1);
      final temp = resultado[i];
      resultado[i] = resultado[j];
      resultado[j] = temp;
    }
    return resultado;
  }
}

/// Calcula la semilla personal de un estudiante para una sesión.
/// Garantiza unicidad por estudiante pero reproducibilidad.
int calcularSemillaPersonal(int semillaGrupo, String idEstudiante) {
  return ((semillaGrupo * idEstudiante.hashCode) % 999999).abs() + 1;
}
```

---

## PANTALLAS — COMPORTAMIENTO EXACTO

### `UnirseASesionPantalla.dart`

1. Campo de texto: código de acceso (máximo 8 caracteres, mayúsculas automáticas, guión permitido).
2. Botón "Buscar Sesión" → llama a `GET /sesiones/buscar/:codigo`.
3. Si la sesión está `PENDIENTE`: muestra mensaje "La sesión aún no ha iniciado. Espera al docente."
4. Si está `ACTIVA`: muestra tarjeta con nombre del examen, docente y duración. Botón "Unirse".
5. Si está `FINALIZADA` o `CANCELADA`: muestra mensaje descriptivo. No permite unirse.
6. Al tocar "Unirse": llama a `iniciarExamen()` del `ExamenActivoProvider`.
7. Navega según la modalidad: `DIGITAL_COMPLETO` → `ExamenActivoPantalla`, `HOJA_RESPUESTAS` → `HojaRespuestasPantalla`.

### `ExamenActivoPantalla.dart`

1. **Bloquea el botón de retroceso del SO** con `PopScope(canPop: false)`.
2. Muestra `TemporizadorExamen.dart` en el AppBar.
3. Muestra `MapaProgreso.dart` debajo del AppBar.
4. Muestra `TarjetaPregunta.dart` que renderiza según `TipoPregunta`:
   - `OPCION_MULTIPLE`: Radio buttons → letras A, B, C, D, E.
   - `SELECCION_MULTIPLE`: Checkboxes → letras A, B, C, D, E.
   - `RESPUESTA_ABIERTA`: TextField multilínea. Copiar/pegar deshabilitado:
     ```dart
     TextField(
       contextMenuBuilder: (_, __) => const SizedBox.shrink(),
       enableInteractiveSelection: false,
     )
     ```
   - `VERDADERO_FALSO`: Dos botones grandes: "Verdadero" / "Falso".
5. Botón "Siguiente" → `avanzarPregunta()`. En la última pregunta: "Revisar y Enviar".
6. Botón "Anterior" → `retrocederPregunta()`. Solo visible si `examen.permitirNavegacion = true`.
7. Si el tiempo se acaba: llama automáticamente a `finalizarYEnviar()`.

### `HojaRespuestasPantalla.dart`

1. **Bloquea retroceso del SO** con `PopScope(canPop: false)`.
2. Muestra `MapaProgreso.dart` en la parte superior (fijo, no hace scroll).
3. Cuerpo: `ListView.builder` con las filas de la cuadrícula OMR.
4. Cada fila: número de pregunta + `BotonRespuestaOMR.dart` por cada letra (A/B/C/D/E).
5. `BotonRespuestaOMR.dart`: tamaño mínimo 44x44px. Color seleccionado: azul primario del tema.
6. Al tocar: registra la respuesta. Al tocar de nuevo la misma: deselecciona (permite cambiar).
7. Botón flotante "Enviar" → navega a `ResumenExamenPantalla.dart`.

### `TemporizadorExamen.dart`

- Cuenta regresiva desde `examen.duracionMinutos` hasta 00:00.
- Formato: `MM:SS`.
- Color: verde → amarillo (cuando quedan menos del 20% del tiempo) → rojo (menos del 10%).
- Vibración suave cuando quedan 5 minutos y cuando queda 1 minuto.
- Al llegar a 00:00: envía el examen automáticamente sin confirmación del usuario.

### `MapaProgreso.dart`

- Fila horizontal de círculos numerados con scroll horizontal.
- Círculo azul sólido = pregunta actual.
- Círculo verde = pregunta respondida.
- Círculo gris = pregunta sin responder.
- Tocar un círculo = navegar a esa pregunta (solo si `permitirNavegacion = true`).

---

## GESTIÓN DE TOKENS — `ApiServicio.dart`

```dart
// Interceptor de peticiones (DioInterceptor):
// 1. Obtener tokenAcceso de flutter_secure_storage
// 2. Agregar header: 'Authorization': 'Bearer $tokenAcceso'

// Interceptor de errores (401):
// 1. Si el endpoint no es /autenticacion/refrescar-tokens:
//    a. Leer tokenRefresh de flutter_secure_storage
//    b. Llamar a POST /autenticacion/refrescar-tokens
//    c. Guardar nuevo tokenAcceso en flutter_secure_storage
//    d. Reintentar petición original con nuevo token
// 2. Si el refresh también falla:
//    a. Eliminar todos los tokens de flutter_secure_storage
//    b. Navegar a IniciarSesionPantalla (rompiendo toda la pila de navegación)
```

---

## `IndicadorConexion.dart`

Widget siempre visible durante el examen (en el AppBar o como banner):
- Ícono verde con "En línea" cuando hay conexión.
- Ícono amarillo con "Sin conexión — respuestas guardadas localmente" cuando no hay red.
- Transición suave entre estados. No bloquea la UI.
- Usa `ConectividadProvider` (Riverpod) que escucha `connectivity_plus`.

---

## NAVEGACIÓN — go_router

**Archivo:** `Constantes/Rutas.dart`

```dart
abstract class Rutas {
  static const iniciarSesion = '/iniciar-sesion';
  static const inicio = '/inicio';
  static const unirseExamen = '/examen/unirse';
  static const examenActivo = '/examen/activo';
  static const hojaRespuestas = '/examen/hoja-respuestas';
  static const resumenExamen = '/examen/resumen';
  static const examenEnviado = '/examen/enviado';
  static const sinConexion = '/error/sin-conexion';
  static const sesionInvalidada = '/error/sesion-invalidada';
}
```

El router redirige a `/iniciar-sesion` si no hay token válido en `flutter_secure_storage`.
La ruta `/examen/*` requiere que exista un intento activo en el `ExamenActivoProvider`.