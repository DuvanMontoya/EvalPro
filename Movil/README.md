# EvalPro Movil

Aplicación Flutter del ecosistema EvalPro.

Incluye:
- Flujo de estudiante para unirse a sesión, responder examen y enviar intento.
- Flujo de estudiante para consultar resultados y presentar reclamos.
- Módulos móviles de gestión para docente, administrador y superadministrador:
  instituciones, usuarios, grupos, periodos, sesiones, exámenes, reclamos y
  calificación manual.

---

## 1. Entornos y variables (`--dart-define-from-file`)

Los archivos de entorno están en `Movil/Entornos/`:

- `dev.json`
- `stage.json`
- `prod.json`

Cada archivo define al menos:

- `API_URL` → por ejemplo `http://localhost:3001/api/v1`
- `WEBSOCKET_URL` → por ejemplo `http://localhost:3001`
- `DIAS_RETENCION_TELEMETRIA`
- `VERSION_APP`

`dev.json` viene preparado con `localhost:3001` para desarrollo local.
En dispositivo físico usa IP LAN o `dev.adb.json` con `adb reverse`.

La app intenta cargar `Entornos/dev.json` automáticamente al iniciar.
Si pasas `--dart-define-from-file`, ese valor tiene prioridad.

> **Regla:** Para desarrollo de escritorio es recomendable que `API_URL` y `WEBSOCKET_URL`
> apunten a `localhost` (o a la IP donde tengas levantado el backend).

---

## 1.1 Credenciales iniciales de login (desarrollo)

Las credenciales iniciales ya no se documentan ni se fijan en el repositorio.
Despues de ejecutar semillas del backend:

```bash
cd Backend
npm run prisma:sembrar
```

inicia sesion con los valores que hayas configurado previamente en el `.env`
raiz para estos pares obligatorios:

- `SUPERADMIN_CORREO_INICIAL` y `SUPERADMIN_CONTRASENA_INICIAL`
- `ADMIN_CORREO_INICIAL` y `ADMIN_CONTRASENA_INICIAL`
- `DOCENTE_CORREO_INICIAL` y `DOCENTE_CONTRASENA_INICIAL`
- `ESTUDIANTE_CORREO_INICIAL` y `ESTUDIANTE_CONTRASENA_INICIAL`

Nota:
- Para usuarios recien creados por gestion, el backend puede exigir cambio de contrasena en primer login.
  La app movil ya soporta ese flujo y mostrara el formulario de cambio automaticamente.
- Si actualizas las credenciales del `.env`, vuelve a ejecutar `npm run prisma:sembrar` en `Backend/`
  para regenerar las cuentas iniciales de desarrollo con los nuevos valores.

Si la app se ve vacía o sin datos de gestión:

```bash
docker compose -f docker-compose.dev.yml down -v
docker compose -f docker-compose.dev.yml up --build
```

Si `SUPERADMINISTRADOR` recibe `SIN_PERMISOS` al editar usuarios:

```bash
docker compose -f docker-compose.dev.yml up --build backend
```

Eso fuerza recompilación del backend con las reglas actuales de autorización.

Ese reinicio recrea la base de datos del stack Docker y vuelve a ejecutar semillas.

---

## 2. Flujo recomendado de desarrollo con Flutter Desktop (Windows)

### 2.1. Preparar entorno de backend y frontend

1. Desde la raíz del proyecto (`EvalPro/`), levanta el stack de desarrollo:

   ```bash
   docker compose -f docker-compose.dev.yml up --build
   ```

2. Verifica:
   - Frontend: `http://localhost:3000`
   - Backend: `http://localhost:3001/api/v1/salud`

### 2.2. Habilitar Flutter Desktop (una sola vez en tu máquina)

En tu terminal (fuera de Docker):

```bash
flutter config --enable-windows-desktop
flutter doctor
```

Confirma que en la salida de `flutter doctor` aparezca **Windows** como plataforma habilitada.

### 2.3. Preparar el proyecto Movil para escritorio (una sola vez)

```bash
cd Movil
flutter pub get
flutter create --platforms=windows .
```

Esto crea la carpeta `windows/` y archivos necesarios para ejecutar como app de escritorio, sin tocar el código Dart existente.

### 2.4. Ejecutar en escritorio con entorno `dev.json`

1. Asegúrate de que `Movil/Entornos/dev.json` tenga:

   ```json
   {
     "API_URL": "http://localhost:3001/api/v1",
     "WEBSOCKET_URL": "http://localhost:3001",
     "DIAS_RETENCION_TELEMETRIA": 7,
     "VERSION_APP": "1.0.0"
   }
   ```

2. Ejecuta la aplicación de escritorio:

   ```bash
   cd Movil
   flutter run -d windows --dart-define-from-file=Entornos/dev.json
   ```

3. A partir de aquí:
   - Cada vez que guardes un archivo (`Ctrl+S`), Flutter aplicará **Hot Reload**.
   - Solo detén y relanza cuando cambies cosas muy profundas (por ejemplo, firmas de `main` o cambios en `Entorno.validar()`), donde podrías necesitar **Hot Restart**.

---

## 3. Android: emulador y dispositivo físico

### 3.1. Emulador Android (desarrollo local)

```bash
cd Movil
.\scripts\run_android_emulador.ps1
```

Este script profesional:

- Arranca el emulador si aún no está activo.
- Usa `10.0.2.2` para backend local (requerido en emulador Android).
- Ejecuta `flutter run` con `API_URL` y `WEBSOCKET_URL` correctos sin editar JSON.

### 3.2. Dispositivo físico (misma red local)

1. Reemplaza en `Entornos/dev.json` la URL por tu IP local si usas teléfono real (ejemplo: `http://192.168.20.21:3001`).
2. Ejecuta (recomendado):

```bash
cd Movil
flutter run -d <id-dispositivo> --dart-define-from-file=Entornos/dev.json
```

Comando exacto (obteniendo ID primero):

```bash
cd Movil
flutter devices
flutter run -d R58N123ABC --dart-define-from-file=Entornos/dev.json
```

3. También funciona sin `--dart-define` porque se usa `Entornos/dev.json` como fallback:

```bash
cd Movil
flutter run -d <id-dispositivo>
```

> `10.0.2.2` solo funciona en emulador Android. En dispositivo físico siempre usa IP LAN del host.

### 3.3. Dispositivo físico con `adb reverse` (cuando la LAN bloquea acceso al PC)

Si el teléfono no puede llegar a `http://<IP-PC>:3001` por firewall o aislamiento de red WiFi, usa este flujo:

1. Configura el túnel:

```bash
adb -s <id-dispositivo> reverse tcp:3001 tcp:3001
```

2. Ejecuta con el entorno preparado para `127.0.0.1`:

```bash
cd Movil
flutter run -d <id-dispositivo> --dart-define-from-file=Entornos/dev.adb.json
```

3. Alternativa PowerShell (automatiza ambos pasos):

```powershell
cd Movil
.\scripts\run_android_adb_reverse.ps1
```

Si quieres forzar un dispositivo específico:

```powershell
.\scripts\run_android_adb_reverse.ps1 -DeviceId <id-dispositivo>
```

4. Script profesional directo (sin editar JSON manualmente):

```powershell
cd Movil
.\scripts\run_android_fisico.ps1 -DeviceId <id-dispositivo>
```

Ejemplo directo con IP LAN:

```powershell
.\scripts\run_android_fisico.ps1 -DeviceId R58N123ABC -ApiHost 192.168.20.21
```

Forzando modo `adb reverse`:

```powershell
.\scripts\run_android_fisico.ps1 -DeviceId <id-dispositivo> -UseAdbReverse
```

---

## 4. Stage / Producción

```bash
cd Movil
flutter run --dart-define-from-file=Entornos/stage.json
flutter run --release --dart-define-from-file=Entornos/prod.json
```

---

## 5. Validación rápida del módulo Movil

```bash
cd Movil
flutter pub get
flutter analyze
flutter test
```

Con este flujo:

- Usas **Docker** para Backend + Frontend.
- Usas **Flutter Desktop** para un ciclo de desarrollo muy rápido.
- Mantienes la misma configuración de entorno (`Entornos/*.json`) para móvil y escritorio.

---

## 6. Pruebas de integración (flujos reales de tap y navegación)

Archivo principal:

- `integration_test/FlujosAplicacion_test.dart`

Incluye:

- Login exitoso de estudiante y redirección al inicio.
- Login fallido con visualización de banner de error.
- Navegación de administrador a gestión de usuarios.

### 6.1 Ejecutar en dispositivo físico Android

```bash
cd Movil
flutter test integration_test/FlujosAplicacion_test.dart -d <id-dispositivo> --dart-define-from-file=Entornos/dev.json
```

### 6.2 Ejecutar en emulador

```bash
cd Movil
flutter test integration_test/FlujosAplicacion_test.dart -d emulator-5554 --dart-define-from-file=Entornos/dev.json
```

---

## 7. Golden tests (regresión visual)

Archivo principal:

- `test/Golden/PantallasPrincipalesGolden_test.dart`

Cobertura visual:

- Login base.
- Login con estado de error.
- Inicio con rol administrador.

### 7.1 Generar o actualizar snapshots golden

```bash
cd Movil
flutter test test/Golden/PantallasPrincipalesGolden_test.dart --update-goldens
```

### 7.2 Validar que no haya regresiones visuales

```bash
cd Movil
flutter test test/Golden/PantallasPrincipalesGolden_test.dart
```
