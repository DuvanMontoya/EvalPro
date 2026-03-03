# Cierre Gap-by-Gap AGENTS.md (Backend + Frontend Operativo)
Fecha: 2026-03-02
Referencia: `AGENTS.md` v3.0.0

## 1) Invariantes Criticos (Seccion 1)

| ID | Estado | Evidencia |
|---|---|---|
| INV-01 (tenant isolation) | CERRADO | Validaciones por tenant en servicios de `Instituciones`, `Grupos`, `Examenes`, `Sesiones`, `Intentos`, `Telemetria`, `Reportes`. |
| INV-02 (elegibilidad estudiante) | CERRADO | `IntentosService.validarElegibilidadAsignacion` + chequeo membresia activa. |
| INV-03 (no exponer respuestas correctas antes de envio) | CERRADO | Sanitizacion de `esCorrecta` en `SesionesExamenService.buscarPorCodigo` e `IntentosService.obtenerExamen`. |
| INV-04 (auditoria inmutable de acciones sensibles) | CERRADO | `RegistroActividadInterceptor` ahora espera persistencia de auditoria (fail-closed) y registra `snapshotAntes/snapshotDespues`, `ip`, `userAgent`, actor. |
| INV-05 (transiciones invalidas rechazadas) | CERRADO | Validaciones de estado en `GruposService`, `ExamenesService`, `SesionesExamenService`, `IntentosService`. |
| INV-06 (anulacion intento requiere actor humano) | CERRADO | `IntentosService.anular` exige rol autorizado y setea `anuladoPorId/anuladoEn/razonAnulacion`. |
| INV-07 (JWT obligatorio) | CERRADO | Guards JWT aplicados por controlador y estrategia valida claims/estado. |
| INV-08 (bcrypt >= 12) | CERRADO | Hash con rondas minimas 12 en autenticacion y usuarios. |
| INV-09 (un intento activo por sesion) | CERRADO | `IntentosService.iniciar` rechaza duplicado con `409`. |
| INV-10 (puntaje nunca del cliente) | CERRADO | Calculo de puntajes en backend (`Respuestas/Calificacion`). |

## 2) Brechas Corregidas En Este Paso

1. `GET /periodos` para `SUPERADMINISTRADOR` sin `idInstitucion`:
   - Antes: `400`.
   - Ahora: listado global permitido, filtro opcional por `idInstitucion`.
   - Archivo: `Backend/src/PeriodosAcademicos/PeriodosAcademicos.service.ts`.

2. Lectura de telemetria por `SUPERADMINISTRADOR`:
   - Antes: controlador no incluia rol superadmin.
   - Ahora: `@Roles(DOCENTE, ADMINISTRADOR, SUPERADMINISTRADOR)`.
   - Archivo: `Backend/src/Telemetria/Telemetria.controller.ts`.

3. Creacion de usuarios por superadmin (matriz de permisos):
   - Antes: solo `ADMINISTRADOR` podia crear por rutas `/usuarios`, `/usuarios/docentes`, `/usuarios/estudiantes`.
   - Ahora: `SUPERADMINISTRADOR` habilitado con `idInstitucion` objetivo (obligatorio salvo rol destino `SUPERADMINISTRADOR`).
   - Archivos:
     - `Backend/src/Usuarios/Usuarios.controller.ts`
     - `Backend/src/Usuarios/Usuarios.service.ts`
     - `Backend/src/Usuarios/Dto/CrearUsuario.dto.ts`
     - `Backend/src/Usuarios/Dto/CrearUsuarioRol.dto.ts`
   - Cobertura: nuevo test e2e en `Backend/test/Usuarios.e2e-spec.ts`.

4. Auditoria fail-closed en operaciones mutables:
   - Antes: auditoria asyncrona ignoraba fallos (`catch(() => undefined)`).
   - Ahora: persistencia de auditoria es bloqueante en mutaciones HTTP.
   - Archivo: `Backend/src/Comun/Interceptores/RegistroActividad.interceptor.ts`.

5. Limpieza de datos QA:
   - Nuevo script con dry-run por defecto y apply explicito.
   - Archivos:
     - `Backend/scripts/limpiar-datos-qa.ts`
     - `Backend/package.json` scripts:
       - `datos:limpiar:qa:dry`
       - `datos:limpiar:qa`

## 3) Ejecucion De Limpieza QA

Comando ejecutado (contenedor backend):

```bash
npm run datos:limpiar:qa
```

Resultado aplicado:
- `eventosTelemetria`: 13
- `respuestas`: 39
- `resultados`: 15
- `intentos`: 65
- `gruposDocentes`: 3
- `gruposEstudiantes`: 3
- `sesiones`: 71
- `opciones`: 142
- `preguntas`: 103
- `examenes`: 132
- `grupos`: 1
- `periodos`: 1 (`periodosOmitidos`: 1 por FK activa fuera de scope QA)
- `auditoria`: 587
- `usuarios`: 389
- `instituciones`: 2

Segunda pasada post-validaciones:
- `eventosTelemetria`: 1
- `respuestas`: 3
- `resultados`: 2
- `intentos`: 5
- `sesiones`: 5
- `opciones`: 8
- `preguntas`: 6
- `examenes`: 7
- `auditoria`: 74
- `usuarios`: 28
- `instituciones`: 1

Estado final dry-run:
- Pendiente solo `1` periodo (`periodosOmitidos`) por dependencia FK fuera del scope QA.

## 4) Validacion Final

Backend:
- `npm run build` -> OK
- `npm run pruebas:e2e` (en contenedor backend) -> OK (19/19)

Frontend:
- `npm run build` -> OK
- `npm run test:run` -> OK (11/11)

Smoke API post-limpieza:
- `/instituciones`, `/grupos`, `/periodos`, `/examenes`, `/sesiones` responden correctamente para `ADMINISTRADOR` y `SUPERADMINISTRADOR`.

## 5) Nota Operativa De Entorno

En este host, ejecutar Prisma/e2e directamente fuera de contenedor puede apuntar a un PostgreSQL distinto y fallar con `P1010`.  
Para consistencia del entorno EvalPro, usar comandos de DB/e2e dentro de `evalpro_backend_dev`.
