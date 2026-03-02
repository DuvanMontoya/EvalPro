# EvalPro Movil

Aplicación Flutter para estudiantes en el ecosistema EvalPro.

## Ejecución por entorno con `--dart-define-from-file`

Los archivos de entorno están en `Movil/Entornos/`:

- `dev.json`
- `stage.json`
- `prod.json`

### Emulador Android (desarrollo local)

```bash
cd Movil
flutter run -d emulator-5554 --dart-define-from-file=Entornos/dev.json
```

### Dispositivo físico (misma red local)

1. Reemplaza en `Entornos/dev.json` la URL por tu IP local si usas teléfono real.
2. Ejecuta:

```bash
cd Movil
flutter run -d <id-dispositivo> --dart-define-from-file=Entornos/dev.json
```

### Stage / Producción

```bash
cd Movil
flutter run --dart-define-from-file=Entornos/stage.json
flutter run --release --dart-define-from-file=Entornos/prod.json
```

## Validación rápida

```bash
cd Movil
flutter pub get
flutter analyze
flutter test
```
