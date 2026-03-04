# Auditoria Funcional Gestion Movil
Fecha: 2026-03-04
Alcance: `Movil/lib/Pantallas/Gestion/*`, `Movil/lib/Servicios/*Gestion*`, backend `api/v1`

## 1. Metodologia

Se ejecuto validacion funcional real contra backend levantado en `http://localhost:3001/api/v1`:

1. Login por rol (`SUPERADMINISTRADOR`, `ADMINISTRADOR`).
2. Pruebas de lectura por pantalla: instituciones, usuarios, periodos, grupos, sesiones, examenes, reclamos y calificacion manual.
3. Pruebas de escritura criticas:
   - crear institucion
   - crear periodo
   - crear docente/estudiante
   - crear grupo
   - asignar docente e inscribir estudiante
   - cambiar estado de grupo
   - desactivar usuario
   - cambiar estado de institucion
4. Cruce de contratos movil vs controladores/DTO backend.

## 2. Hallazgos funcionales

### H-01 Superadmin sin acceso visible a sesiones/examenes desde inicio
- Estado previo: el bloque "Operacion global" no incluia accesos a `gestion/sesiones` ni `gestion/examenes`.
- Impacto: percepcion de que superadmin "no puede hacer nada" en gestion academica global.
- Correccion aplicada:
  - `Movil/lib/Pantallas/Inicio/InicioPantalla.dart`
  - Se agregaron acciones para `Gestionar Sesiones` y `Gestionar Examenes` en el bloque superadmin.

### H-02 Riesgo de regresion en permisos de superadmin sobre usuarios
- Estado previo: no existia prueba e2e dedicada para actualizar usuarios como superadmin.
- Impacto: el fallo podia reaparecer sin deteccion temprana.
- Correccion aplicada:
  - `Backend/test/Usuarios.e2e-spec.ts`
  - Se agrego prueba: `permite a superadministrador actualizar usuarios de cualquier institucion`.
  - Se elimino dependencia fragil de credenciales sembradas para login de superadmin en pruebas e2e.

## 3. Resultado de validacion posterior

- Backend e2e (usuarios): `PASS` (6/6).
- Movil:
  - se mantiene arquitectura unica sin legacy.
  - rutas de gestion para superadmin visibles desde inicio.

## 4. Nota operativa

Si en un entorno local superadmin recibe `SIN_PERMISOS` en edicion de usuarios pese al codigo actualizado:

```bash
docker compose -f docker-compose.dev.yml up --build backend
```

Esto fuerza recompilacion del backend en el entorno local.
