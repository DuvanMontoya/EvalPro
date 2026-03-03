## EvalPro

### Plataforma integral de evaluaciones seguras (Backend · Frontend · Móvil)

EvalPro es una plataforma completa para la creación, administración y rendición de exámenes con foco en:

- **Seguridad y anti‑fraude** (telemetría avanzada, índice de riesgo, anulación auditada).
- **Multi‑tenant** por institución (aislamiento estricto entre instituciones).
- **Ecosistema completo**:
  - **Backend** NestJS + Prisma + PostgreSQL.
  - **Frontend Web** Next.js (panel administrativo y tablero de docentes/estudiantes).
  - **Aplicación móvil** Flutter (modo kiosco para estudiantes).

Toda la lógica de negocio detallada (roles, máquinas de estado, permisos, flujos, anti‑fraude, etc.) está centralizada en `AGENTS.md`.  
Este `README.md` se enfoca en **cómo poner el sistema en marcha** (local, con y sin Docker) y en **cómo trabajar como desarrollador** dentro del proyecto.

---

## 1. Estructura del repositorio

- **`Backend/`**: API REST y WebSocket en NestJS + Prisma.
- **`Frontend/`**: Aplicación web en Next.js 16 (panel administrativo y vistas de docentes/estudiantes).
- **`Movil/`**: Aplicación Flutter para estudiantes (modo kiosco, telemetría, uso en emulador o dispositivo físico).
- **`Compartido/`** *(si existe)*: Tipos e interfaces TypeScript compartidos entre Frontend y Backend.
- **`AGENTS.md`**: **Documento normativo principal** con toda la lógica de negocio y reglas del dominio EvalPro.
- **`.cursor/rules/Nomenclatura.mdc`**: Reglas de nomenclatura y estilo de código (todo en español).
- **`docker-compose.yml`**: Orquestación **en modo producción local/demo** (PostgreSQL + Backend + Frontend).
- **`docker-compose.dev.yml`**: Orquestación **en modo desarrollo** (hot‑reload para Backend y Frontend).
- **`.env`**: Archivo de entorno raíz (usado por Docker y como base para ejecución local).

Antes de escribir cualquier línea de código nuevo se recomienda leer:

- **`AGENTS.md`** (obligatorio para entender la lógica de negocio).
- **`.cursor/rules/Nomenclatura.mdc`** (obligatorio para respetar la nomenclatura en español).

---

## 2. Requisitos previos

- **Sistema operativo**: Windows, macOS o Linux.
- **Git**: Para clonar el repositorio.
- **Node.js**: Versión **20.x** (el proyecto usa imágenes `node:20-bookworm` en Docker).
- **npm**: Incluido con Node (se usan comandos `npm` y `npm ci`).
- **Docker + Docker Compose**:
  - Docker Desktop (Windows/macOS) o Docker Engine (Linux).
  - Soporte para archivos `docker-compose.yml`.
- **PostgreSQL 15**:
  - Opcional si usas Docker (la base se levanta dentro del `docker-compose`).
  - Necesario localmente si no usas Docker para la base de datos.
- **Flutter SDK**:
  - Versión `>= 3.4.0 < 4.0.0` (según `Movil/pubspec.yaml`).
  - Android Studio / Xcode configurados según tu plataforma para ejecutar la app móvil.
- **Herramientas recomendadas**:
  - **VS Code / Cursor** con extensiones para TypeScript, Flutter y Prisma.
  - Cliente de PostgreSQL (DBeaver, TablePlus, psql, etc.) para inspeccionar la base.

---

## 3. Configuración de variables de entorno

El archivo `.env` en la raíz del proyecto contiene **todas las variables necesarias** para:

- Orquestar **PostgreSQL**.
- Configurar el **Backend** (NestJS + Prisma + JWT).
- Configurar el **Frontend** (Next.js).

> **Importante**:  
> - Usa el `.env` actual como base **solo para desarrollo local**.  
> - En entornos de prueba/producción debes cambiar **todas** las contraseñas y secretos.

### 3.1. Secciones principales del `.env`

- **PostgreSQL (Docker)**  
  Variables usadas por `docker-compose.yml` y `docker-compose.dev.yml` para levantar la base de datos:
  - `POSTGRES_USUARIO`
  - `POSTGRES_CONTRASENA`
  - `POSTGRES_BASE_DATOS`
  - `POSTGRES_PUERTO`

- **Backend (NestJS + Prisma)**  
  Variables mínimas:
  - `DATABASE_URL` → cadena de conexión PostgreSQL (incluye usuario, contraseña, host, puerto y base).
  - `JWT_SECRETO_ACCESO`, `JWT_EXPIRACION_ACCESO`
  - `JWT_SECRETO_REFRESH`, `JWT_EXPIRACION_REFRESH`
  - `JWT_EMISOR`, `JWT_AUDIENCIA`
  - `PUERTO_APP` (por defecto 3001)
  - `CORS_ORIGENES_PERMITIDOS` (ej. `http://localhost:3000`)
  - `ENTORNO` (ej. `desarrollo`)
  - `BCRYPT_RONDAS_HASH`
  - `ADMIN_CORREO_INICIAL`, `ADMIN_CONTRASENA_INICIAL`
  - `SUPERADMIN_CORREO_INICIAL`, `SUPERADMIN_CONTRASENA_INICIAL`
  - Variables de telemetría (por ejemplo `TELEMETRIA_SEGUNDOS_MINIMOS_POR_PREGUNTA`, etc.).

- **Frontend (Next.js)**  
  Variables mínimas:
  - `PUERTO_FRONTEND` (por defecto 3000)
  - `NEXT_PUBLIC_API_URL` (ej. `http://localhost:3001/api/v1`)
  - `NEXT_PUBLIC_WEBSOCKET_URL` (ej. `http://localhost:3001`)
  - `NEXT_PUBLIC_VERSION_APP`
  - `API_BASE_INTERNA` (para llamadas internas desde contenedores a Backend).

### 3.2. Pasos para preparar el `.env`

1. Asegúrate de tener un archivo `.env` en la raíz del proyecto:
   - Si ya existe, **revísalo y ajusta solo lo necesario** (sobre todo contraseñas y secretos).
   - Si no existe (en otro entorno/clon nuevo), copia desde un archivo de ejemplo que mantengas de forma segura o crea uno nuevo siguiendo las variables de arriba.
2. Verifica que:
   - `DATABASE_URL` apunte al host correcto (`localhost` si corres Postgres fuera de Docker, `postgres` si usas Docker Compose).
   - Los puertos `PUERTO_APP` y `PUERTO_FRONTEND` no estén ocupados.
   - Para el Frontend, `NEXT_PUBLIC_API_URL` y `NEXT_PUBLIC_WEBSOCKET_URL` apunten al Backend correcto.

---

## 4. Ejecución recomendada: todo el stack con Docker (desarrollo)

La forma más sencilla de levantar **PostgreSQL + Backend + Frontend** en modo desarrollo es usando `docker-compose.dev.yml`.

### 4.1. Levantar entorno completo de desarrollo (hot‑reload)

Desde la raíz del proyecto:

```bash
docker compose -f docker-compose.dev.yml up --build
```

Esto hará lo siguiente:

- Levanta **PostgreSQL 15** con los parámetros de tu `.env`.
- Levanta el **Backend** (`Backend/`) en modo desarrollo:
  - Instala dependencias (`npm ci`).
  - Ejecuta `npx prisma generate`.
  - Ejecuta **migraciones** (`npx prisma db push`) y **semillas** (`npx prisma db seed`).
  - Inicia `npm run start:dev` en el puerto configurado (`PUERTO_APP`, por defecto 3001).
- Levanta el **Frontend** (`Frontend/`) en modo desarrollo:
  - Instala dependencias (`npm ci`).
  - Inicia `npm run dev` en el puerto configurado (`PUERTO_FRONTEND`, por defecto 3000).

#### 4.1.1. URLs clave en desarrollo

- **Frontend**: `http://localhost:3000`
- **Backend (salud)**: `http://localhost:3001/api/v1/salud`  
  (la ruta de salud se usa en los healthchecks del `docker-compose`).

#### 4.1.2. Detener el entorno

En la misma carpeta raíz:

```bash
docker compose -f docker-compose.dev.yml down
```

Si quieres limpiar volúmenes de datos (base de datos incluida, **se pierde toda la información**):

```bash
docker compose -f docker-compose.dev.yml down -v
```

---

## 5. Ejecución con Docker en modo producción local/demo

El archivo `docker-compose.yml` está orientado a levantar el stack en modo **producción local** (útil para demos o pruebas más cercanas al entorno real).

Desde la raíz del proyecto:

```bash
docker compose up --build -d
```

Este comando:

- Levanta Postgres + Backend + Frontend.
- En el servicio `backend`:
  - Ejecuta `npm ci`.
  - Ejecuta `npx prisma generate`.
  - Ejecuta `npx prisma db push` y `npx prisma db seed`.
  - Ejecuta `npm run build` y luego `npm run start:prod`.
- En el servicio `frontend`:
  - Ejecuta `npm ci`.
  - Ejecuta `npm run build` y luego `npm run start` en modo producción.

Para ver los logs:

```bash
docker compose logs -f backend
docker compose logs -f frontend
```

Para detener el entorno:

```bash
docker compose down
```

---

## 6. Ejecución manual sin Docker (desarrollo local)

Si prefieres ejecutar cada servicio directamente en tu máquina (fuera de Docker), estos son los pasos recomendados.

### 6.1. Paso 1: Clonar el repositorio

```bash
git clone <url-del-repo>
cd EvalPro
```

Asegúrate de que tu archivo `.env` esté correctamente configurado como se describió en la sección 3.

### 6.2. Paso 2: Levantar PostgreSQL

Tienes dos opciones:

- **Opción A: PostgreSQL nativo** (instalado en tu sistema):
  - Crea una base de datos con el nombre definido en `POSTGRES_BASE_DATOS`.
  - Configura usuario y contraseña según `POSTGRES_USUARIO` y `POSTGRES_CONTRASENA`.
  - Asegúrate de que `DATABASE_URL` apunte a `localhost` y al puerto correcto.

- **Opción B: PostgreSQL con Docker únicamente**:

  ```bash
  docker compose -f docker-compose.dev.yml up postgres -d
  ```

  Esto levanta solo el contenedor de Postgres.  
  Asegúrate de que `DATABASE_URL` use como host `localhost` o `127.0.0.1` (fuera de Docker).

### 6.3. Paso 3: Backend (NestJS + Prisma)

Desde la raíz del proyecto:

```bash
cd Backend
npm install
```

#### 6.3.1. Generar cliente Prisma y aplicar migraciones

```bash
npx prisma generate
npm run prisma:migrar      # primera vez (crea migración "inicio" y aplica)
npm run prisma:sembrar     # ejecuta semillas iniciales
```

Si ya existen migraciones definidas y solo quieres sincronizar el esquema sin crear nuevas, puedes usar:

```bash
npx prisma db push
```

#### 6.3.2. Ejecutar el backend en modo desarrollo

```bash
npm run start:dev
```

Esto levantará la API en el puerto definido por `PUERTO_APP` (por defecto 3001).

Puedes verificar el estado con:

```text
GET http://localhost:3001/api/v1/salud
```

### 6.4. Paso 4: Frontend (Next.js)

En otra terminal, desde la raíz del proyecto:

```bash
cd Frontend
npm install
```

Para que el Frontend tenga las URLs correctas del Backend tienes dos opciones:

- **Opción A: Variables de entorno en el sistema**  
  Exporta las variables antes de ejecutar `npm run dev` (en Windows PowerShell sería con `setx` o `$env:NOMBRE="valor"`).

- **Opción B: Archivo `Frontend/.env.local`**  
  Crea un archivo `Frontend/.env.local` con al menos:

  ```bash
  NEXT_PUBLIC_API_URL=http://localhost:3001/api/v1
  NEXT_PUBLIC_WEBSOCKET_URL=http://localhost:3001
  NEXT_PUBLIC_VERSION_APP=1.0.0
  ```

Luego ejecuta el servidor de desarrollo:

```bash
npm run dev
```

El Frontend quedará disponible en:

```text
http://localhost:3000
```

### 6.5. Paso 5: Aplicación móvil (Flutter)

La carpeta `Movil/` ya incluye un `README.md` con instrucciones específicas.  
A continuación se resumen los pasos principales para desarrollo.

#### 6.5.1. Dependencias y análisis rápido

```bash
cd Movil
flutter pub get
flutter analyze
flutter test
```

#### 6.5.2. Archivos de entorno móvil

Los entornos se configuran con archivos JSON en `Movil/Entornos/`:

- `dev.json`
- `stage.json`
- `prod.json`

Cada archivo define las URLs del Backend y otras configuraciones para la app móvil.  
Asegúrate de que el valor de la URL apunte al backend correcto (IP/puerto accesibles desde el emulador o dispositivo físico).

#### 6.5.3. Ejecutar en emulador Android (desarrollo local)

```bash
cd Movil
flutter run -d emulator-5554 --dart-define-from-file=Entornos/dev.json
```

Reemplaza `emulator-5554` por el ID de tu emulador.

#### 6.5.4. Ejecutar en dispositivo físico (misma red local)

1. Edita `Movil/Entornos/dev.json` y reemplaza la URL del backend por tu **IP local** (ej. `http://192.168.0.10:3001`).
2. Ejecuta:

```bash
cd Movil
flutter run -d <id-dispositivo> --dart-define-from-file=Entornos/dev.json
```

#### 6.5.5. Stage / Producción (móvil)

```bash
cd Movil
flutter run --dart-define-from-file=Entornos/stage.json
flutter run --release --dart-define-from-file=Entornos/prod.json
```

---

## 7. Comandos útiles por módulo

### 7.1. Backend (`Backend/package.json`)

- **Desarrollo**:

  ```bash
  npm run start:dev
  ```

- **Construir y ejecutar en producción**:

  ```bash
  npm run build
  npm run start:prod
  ```

- **Pruebas end‑to‑end (E2E)**:

  ```bash
  npm run pruebas:e2e
  npm run pruebas:e2e:ci
  ```

- **Prisma**:

  ```bash
  npm run prisma:generar   # npx prisma generate
  npm run prisma:migrar    # prisma migrate dev --name inicio
  npm run prisma:sembrar   # prisma db seed
  ```

- **Limpieza de datos QA**:

  ```bash
  npm run datos:limpiar:qa:dry   # vista previa (sin aplicar cambios)
  npm run datos:limpiar:qa       # aplica limpieza en entorno QA
  ```

### 7.2. Frontend (`Frontend/package.json`)

- **Desarrollo**:

  ```bash
  npm run dev
  ```

- **Construcción y arranque en producción**:

  ```bash
  npm run build
  npm start
  ```

- **Pruebas (Vitest)**:

  ```bash
  npm test       # modo interactivo
  npm run test:run
  ```

### 7.3. Móvil (`Movil/pubspec.yaml` y `Movil/README.md`)

- **Instalar dependencias**:

  ```bash
  flutter pub get
  ```

- **Análisis estático**:

  ```bash
  flutter analyze
  ```

- **Pruebas**:

  ```bash
  flutter test
  ```

---

## 8. Flujo recomendado para un desarrollador nuevo

- **Paso 1**: Leer `AGENTS.md` completo para entender:
  - Modelo de datos canónico.
  - Roles, permisos y máquinas de estado.
  - Flujos de autenticación, exámenes, sesiones, intentos, telemetría y reclamos.
- **Paso 2**: Leer `.cursor/rules/Nomenclatura.mdc` y respetar:
  - Nombres de archivos, variables, funciones y clases en **español**.
  - Convenciones de PascalCase/camelCase/snack_case según tipo.
  - Encabezado obligatorio en cada archivo de código.
- **Paso 3**: Configurar `.env` para desarrollo local.
- **Paso 4**: Levantar el stack con `docker-compose.dev.yml`:
  - Verificar que el flujo básico funcione (login, creación de institución, etc.).
- **Paso 5**: Para tareas específicas de Backend/Frontend/Móvil:
  - Trabajar localmente en el módulo correspondiente (`Backend/`, `Frontend/`, `Movil/`).
  - Ejecutar siempre los comandos de pruebas y análisis antes de subir cambios.

---

## 9. Buenas prácticas y notas importantes

- **Formato de respuestas de API**:  
  Todas las respuestas deben seguir el contrato definido en `AGENTS.md`:
  - Éxito: `{"exito": true, "datos": {}, "mensaje": "...", "marcaTiempo": "..."}`  
  - Error: `{"exito": false, "datos": null, "mensaje": "...", "codigoError": "...", "marcaTiempo": "..."}`

- **Sin datos hardcodeados**:
  - Toda configuración debe ir en variables de entorno (`.env` o equivalentes).
  - Todo texto de UI configurable debe ir en constantes.

- **Seguridad**:
  - Nunca exponer respuestas correctas de exámenes antes de que el intento esté en estado `ENVIADO`.
  - Nunca guardar ni enviar contraseñas en texto plano.
  - Respetar siempre el pipeline de autorización descrito en `AGENTS.md`.

- **Multi‑tenant**:
  - Ningún usuario (salvo `SUPERADMINISTRADOR`) puede operar sobre recursos de otra institución.

Si sigues este documento paso a paso, deberías poder:

- Levantar **Backend + Frontend + PostgreSQL** con un solo comando usando Docker.
- Ejecutar el entorno completo en modo desarrollo con **hot‑reload**.
- Levantar y depurar la **aplicación móvil Flutter** apuntando a tu backend local.
- Entender dónde están las reglas de negocio y cómo contribuir respetando la arquitectura de EvalPro.

