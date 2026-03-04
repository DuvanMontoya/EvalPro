# Auditoria Movil EvalPro
Fecha: 2026-03-03
Alcance: `Movil/lib`

## 1. Hallazgos Criticos

1. Router activo con logica mock
- Archivo: `lib/router/app_router.dart`
- Hallazgo: autenticacion falsa (`resolveAuth => false`) y login por texto del correo.
- Riesgo: cualquier credencial puede entrar sin backend real.

2. Duplicidad de arquitectura
- Directorios: `lib/Pantallas/*` y `lib/presentation/*`
- Hallazgo: dos sistemas de UI/rutas paralelos, uno real (API) y otro de plantilla.
- Riesgo: mantenimiento caotico, rutas inconsistentes y regresiones.

3. Datos hardcodeados y acciones vacias
- Archivos:
  - `lib/presentation/pages/student/home/home_student_page.dart`
  - `lib/presentation/pages/student/assignments/my_exams_page.dart`
  - `lib/presentation/pages/teacher/home/home_teacher_page.dart`
  - `lib/presentation/pages/teacher/sessions/session_panel_page.dart`
  - `lib/presentation/pages/auth/change_password_page.dart`
- Hallazgo: `_mockData`, `_mockItems`, `Future.delayed` simulando API y `onPressed: () {}`.
- Riesgo: UX engañosa, acciones sin efecto real.

## 2. Remediacion Aplicada

1. Entrada principal migrada a flujo real
- Archivo modificado: `lib/app.dart`
- Cambio: `EvalProApp` ahora renderiza `Aplicacion.dart`.
- Resultado: se usa autenticacion, permisos y navegacion reales con backend.

2. Rediseño visual base (estilo movil nativo)
- Archivo modificado: `lib/Configuracion/Tema.dart`
- Cambios: menos bordes duros, cards limpias, inputs mas nativos y mejor jerarquia visual.

3. Pantallas clave mejoradas
- Archivos modificados:
  - `lib/Pantallas/Autenticacion/IniciarSesionPantalla.dart`
  - `lib/Pantallas/Inicio/InicioPantalla.dart`
  - `lib/Pantallas/Examen/UnirseASesionPantalla.dart`
  - `lib/Pantallas/Inicio/Widgets/TarjetaSesionDisponible.dart`
  - `lib/Pantallas/Examen/ResumenExamenPantalla.dart`
  - `lib/Pantallas/Examen/ExamenEnviadoPantalla.dart`
- Resultado: flujo visual profesional, botones accionables y sin pantallas "muertas" en el camino principal.

## 3. Estado de Verificacion

- Comando ejecutado: `flutter analyze`
- Resultado: sin errores ni warnings.

## 4. Deuda Tecnica Residual

1. Codigo legacy no activo
- El arbol `lib/presentation/*` y `lib/router/app_router.dart` permanece en repositorio como legado.
- No esta en el flujo de ejecucion actual.

2. Recomendacion de siguiente fase
- Eliminar o mover `lib/presentation/*` a un modulo `legacy/` fuera de `lib` para evitar duplicidad futura.
- Mantener una sola arquitectura de UI y routing.
