# AGENTS.md — EvalPro · Backend (NestJS + Prisma + PostgreSQL)
> Complementa `/AGENTS.md` raíz. Lee primero el raíz, luego este.
> Aplica a todos los archivos dentro de `Backend/`.

---

## ESTRUCTURA DE DIRECTORIOS EXACTA

```
Backend/
├── src/
│   ├── main.ts
│   ├── App.module.ts
│   ├── App.controller.ts
│   ├── Comun/
│   │   ├── Constantes/
│   │   │   ├── Roles.constantes.ts
│   │   │   ├── Eventos.constantes.ts
│   │   │   └── Mensajes.constantes.ts
│   │   ├── Decoradores/
│   │   │   ├── Roles.decorador.ts
│   │   │   └── UsuarioActual.decorador.ts
│   │   ├── Filtros/
│   │   │   └── ExcepcionGlobal.filtro.ts
│   │   ├── Guards/
│   │   │   ├── JwtAutenticacion.guard.ts
│   │   │   └── Roles.guard.ts
│   │   ├── Interceptores/
│   │   │   ├── TransformRespuesta.interceptor.ts
│   │   │   └── RegistroActividad.interceptor.ts
│   │   ├── Pipes/
│   │   │   └── ValidacionGlobal.pipe.ts
│   │   └── Utilidades/
│   │       ├── AleatorizadorPreguntas.util.ts
│   │       ├── CalculadorPuntaje.util.ts
│   │       ├── GeneradorCodigo.util.ts
│   │       └── ValidadorTelemetria.util.ts
│   ├── Configuracion/
│   │   ├── Configuracion.module.ts
│   │   ├── BaseDatos.config.ts
│   │   ├── Jwt.config.ts
│   │   └── Cors.config.ts
│   ├── Autenticacion/
│   │   ├── Autenticacion.module.ts
│   │   ├── Autenticacion.controller.ts
│   │   ├── Autenticacion.service.ts
│   │   ├── Estrategias/
│   │   │   ├── JwtAcceso.estrategia.ts
│   │   │   └── JwtRefresh.estrategia.ts
│   │   └── Dto/
│   │       ├── IniciarSesion.dto.ts
│   │       ├── RegistrarUsuario.dto.ts
│   │       └── RefrescarToken.dto.ts
│   ├── Usuarios/
│   │   ├── Usuarios.module.ts
│   │   ├── Usuarios.controller.ts
│   │   ├── Usuarios.service.ts
│   │   └── Dto/
│   │       ├── CrearUsuario.dto.ts
│   │       ├── ActualizarUsuario.dto.ts
│   │       └── RespuestaUsuario.dto.ts
│   ├── Examenes/
│   │   ├── Examenes.module.ts
│   │   ├── Examenes.controller.ts
│   │   ├── Examenes.service.ts
│   │   └── Dto/
│   │       ├── CrearExamen.dto.ts
│   │       ├── ActualizarExamen.dto.ts
│   │       └── RespuestaExamen.dto.ts
│   ├── Preguntas/
│   │   ├── Preguntas.module.ts
│   │   ├── Preguntas.controller.ts
│   │   ├── Preguntas.service.ts
│   │   └── Dto/
│   │       ├── CrearPregunta.dto.ts
│   │       ├── CrearOpcion.dto.ts
│   │       ├── ActualizarPregunta.dto.ts
│   │       └── ReordenarPreguntas.dto.ts
│   ├── SesionesExamen/
│   │   ├── SesionesExamen.module.ts
│   │   ├── SesionesExamen.controller.ts
│   │   ├── SesionesExamen.service.ts
│   │   ├── SesionesExamen.gateway.ts
│   │   └── Dto/
│   │       ├── CrearSesion.dto.ts
│   │       └── RespuestaSesion.dto.ts
│   ├── Intentos/
│   │   ├── Intentos.module.ts
│   │   ├── Intentos.controller.ts
│   │   ├── Intentos.service.ts
│   │   └── Dto/
│   │       ├── IniciarIntento.dto.ts
│   │       └── RespuestaIntento.dto.ts
│   ├── Respuestas/
│   │   ├── Respuestas.module.ts
│   │   ├── Respuestas.controller.ts
│   │   ├── Respuestas.service.ts
│   │   └── Dto/
│   │       ├── SincronizarRespuestas.dto.ts
│   │       ├── EntradaRespuesta.dto.ts
│   │       └── ResultadoFinal.dto.ts
│   ├── Telemetria/
│   │   ├── Telemetria.module.ts
│   │   ├── Telemetria.controller.ts
│   │   ├── Telemetria.service.ts
│   │   └── Dto/
│   │       └── RegistrarEvento.dto.ts
│   └── Reportes/
│       ├── Reportes.module.ts
│       ├── Reportes.controller.ts
│       ├── Reportes.service.ts
│       └── Dto/
│           ├── ReporteSesion.dto.ts
│           └── ReporteEstudiante.dto.ts
├── prisma/
│   ├── schema.prisma
│   ├── migrations/
│   └── Semillas/
│       └── Semilla.ts
├── test/
│   ├── Autenticacion.e2e-spec.ts
│   ├── Examenes.e2e-spec.ts
│   └── Respuestas.e2e-spec.ts
├── .env
├── .env.ejemplo
├── package.json
├── tsconfig.json
└── nest-cli.json
```

---

## ESQUEMA PRISMA COMPLETO

**Archivo:** `prisma/schema.prisma`
**Este es el esquema FINAL. Créalo exactamente así, sin modificaciones.**

```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

enum RolUsuario {
  ADMINISTRADOR
  DOCENTE
  ESTUDIANTE
}

enum TipoPregunta {
  OPCION_MULTIPLE
  SELECCION_MULTIPLE
  RESPUESTA_ABIERTA
  VERDADERO_FALSO
}

enum ModalidadExamen {
  DIGITAL_COMPLETO
  HOJA_RESPUESTAS
}

enum EstadoExamen {
  BORRADOR
  PUBLICADO
  ARCHIVADO
}

enum EstadoSesion {
  PENDIENTE
  ACTIVA
  FINALIZADA
  CANCELADA
}

enum EstadoIntento {
  EN_PROGRESO
  ENVIADO
  ANULADO
  SINCRONIZACION_PENDIENTE
}

enum TipoEventoTelemetria {
  INICIO_EXAMEN
  CAMBIO_PREGUNTA
  RESPUESTA_GUARDADA
  APLICACION_EN_SEGUNDO_PLANO
  PANTALLA_ABANDONADA
  CAPTURA_BLOQUEADA
  FORZAR_CIERRE
  SESION_INVALIDA
  EXAMEN_ENVIADO
  SINCRONIZACION_COMPLETADA
}

model Usuario {
  id                 String         @id @default(uuid())
  nombre             String         @db.VarChar(100)
  apellidos          String         @db.VarChar(100)
  correo             String         @unique @db.VarChar(255)
  contrasena         String         @db.VarChar(255)
  rol                RolUsuario
  activo             Boolean        @default(true)
  tokenRefresh       String?        @db.Text
  fechaCreacion      DateTime       @default(now())
  fechaActualizacion DateTime       @updatedAt
  examenesCreados    Examen[]       @relation("ExamenCreadoPor")
  sesionesCreadas    SesionExamen[] @relation("SesionCreadaPor")
  intentos           IntentoExamen[]
  @@map("usuarios")
}

model Examen {
  id                   String          @id @default(uuid())
  titulo               String          @db.VarChar(200)
  descripcion          String?         @db.Text
  instrucciones        String?         @db.Text
  modalidad            ModalidadExamen
  estado               EstadoExamen    @default(BORRADOR)
  duracionMinutos      Int             @default(60)
  totalPreguntas       Int             @default(0)
  puntajeMaximo        Float           @default(0.0)
  semillaAleatorizacion Int
  permitirNavegacion   Boolean         @default(true)
  mostrarPuntaje       Boolean         @default(false)
  fechaCreacion        DateTime        @default(now())
  fechaActualizacion   DateTime        @updatedAt
  creadoPorId          String
  creadoPor            Usuario         @relation("ExamenCreadoPor", fields: [creadoPorId], references: [id])
  preguntas            Pregunta[]
  sesiones             SesionExamen[]
  @@map("examenes")
}

model Pregunta {
  id                 String           @id @default(uuid())
  enunciado          String           @db.Text
  tipo               TipoPregunta
  orden              Int
  puntaje            Float            @default(1.0)
  tiempoSugerido     Int?
  imagenUrl          String?          @db.VarChar(500)
  fechaCreacion      DateTime         @default(now())
  fechaActualizacion DateTime         @updatedAt
  examenId           String
  examen             Examen           @relation(fields: [examenId], references: [id], onDelete: Cascade)
  opciones           OpcionRespuesta[]
  respuestas         Respuesta[]
  @@map("preguntas")
}

model OpcionRespuesta {
  id         String   @id @default(uuid())
  letra      String   @db.VarChar(1)
  contenido  String   @db.Text
  esCorrecta Boolean  @default(false)
  orden      Int
  preguntaId String
  pregunta   Pregunta @relation(fields: [preguntaId], references: [id], onDelete: Cascade)
  @@map("opciones_respuesta")
}

model SesionExamen {
  id                 String          @id @default(uuid())
  codigoAcceso       String          @unique @db.VarChar(8)
  estado             EstadoSesion    @default(PENDIENTE)
  fechaInicio        DateTime?
  fechaFin           DateTime?
  duracionReal       Int?
  descripcion        String?         @db.VarChar(255)
  semillaGrupo       Int
  fechaCreacion      DateTime        @default(now())
  fechaActualizacion DateTime        @updatedAt
  examenId           String
  examen             Examen          @relation(fields: [examenId], references: [id])
  creadaPorId        String
  creadaPor          Usuario         @relation("SesionCreadaPor", fields: [creadaPorId], references: [id])
  intentos           IntentoExamen[]
  @@map("sesiones_examen")
}

model IntentoExamen {
  id                String               @id @default(uuid())
  estado            EstadoIntento        @default(EN_PROGRESO)
  semillaPersonal   Int
  puntajeObtenido   Float?
  porcentaje        Float?
  fechaInicio       DateTime             @default(now())
  fechaEnvio        DateTime?
  ipDispositivo     String?              @db.VarChar(50)
  modeloDispositivo String?              @db.VarChar(100)
  sistemaOperativo  String?              @db.VarChar(50)
  versionApp        String?              @db.VarChar(20)
  esSospechoso      Boolean              @default(false)
  razonSospecha     String?              @db.Text
  estudianteId      String
  estudiante        Usuario              @relation(fields: [estudianteId], references: [id])
  sesionId          String
  sesion            SesionExamen         @relation(fields: [sesionId], references: [id])
  respuestas        Respuesta[]
  eventosTelemetria EventoTelemetria[]
  @@unique([estudianteId, sesionId])
  @@map("intentos_examen")
}

model Respuesta {
  id                   String        @id @default(uuid())
  valorTexto           String?       @db.Text
  opcionesSeleccionadas String[]
  esCorrecta           Boolean?
  puntajeObtenido      Float?
  tiempoRespuesta      Int?
  fechaRespuesta       DateTime      @default(now())
  esSincronizada       Boolean       @default(true)
  intentoId            String
  intento              IntentoExamen @relation(fields: [intentoId], references: [id], onDelete: Cascade)
  preguntaId           String
  pregunta             Pregunta      @relation(fields: [preguntaId], references: [id])
  @@unique([intentoId, preguntaId])
  @@map("respuestas")
}

model EventoTelemetria {
  id                String               @id @default(uuid())
  tipo              TipoEventoTelemetria
  descripcion       String?              @db.VarChar(500)
  metadatos         Json?
  numeroPregunta    Int?
  tiempoTranscurrido Int?
  fechaEvento       DateTime             @default(now())
  intentoId         String
  intento           IntentoExamen        @relation(fields: [intentoId], references: [id], onDelete: Cascade)
  @@map("eventos_telemetria")
}
```

---

## CONVENCIONES ESPECÍFICAS DE NESTJS

### Estructura de un módulo (patrón exacto)

Cada módulo sigue este patrón. No inventar variaciones:

```typescript
// 1. El módulo importa todo lo que necesita
@Module({
  imports: [PrismaModule, ConfigModule],
  controllers: [NombreController],
  providers: [NombreService],
  exports: [NombreService],   // Solo si otros módulos lo necesitan
})
export class NombreModule {}
```

### Inyección de Prisma

Usar `PrismaService` inyectado — nunca instanciar `PrismaClient` directamente:
```typescript
constructor(private readonly prisma: PrismaService) {}
```

`PrismaService` se define en `Configuracion/BaseDatos.config.ts` y extiende `PrismaClient`.
Se exporta desde `Configuracion.module.ts` como global (`@Global()`).

### DTOs — Reglas exactas

- Todo DTO usa decoradores de `class-validator`.
- Toda propiedad tiene `@ApiProperty()` de Swagger con `description` en español.
- Para crear: `CrearNombreEntidad.dto.ts`.
- Para actualizar: `ActualizarNombreEntidad.dto.ts` extiende el de crear con `PartialType`.
- Para respuestas al cliente: `RespuestaNombreEntidad.dto.ts` — **nunca incluir `contrasena`
  ni `tokenRefresh` en DTOs de respuesta**.

```typescript
export class CrearUsuarioDto {
  @ApiProperty({ description: 'Nombre del usuario', example: 'Juan' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  nombre: string;
}

export class ActualizarUsuarioDto extends PartialType(CrearUsuarioDto) {}
```

### Guards y Decoradores

Aplicar en este orden en los controladores:
```typescript
@UseGuards(JwtAutenticacionGuard, RolesGuard)
@Roles(RolUsuario.DOCENTE, RolUsuario.ADMINISTRADOR)
@Get(':id')
async obtenerPorId(@Param('id') id: string, @UsuarioActual() usuario: Usuario) {
```

---

## LÓGICA DE CADA SERVICIO — DETALLE EXACTO

### `Autenticacion.service.ts`

**`validarCredenciales(correo, contrasena)`**
1. `prisma.usuario.findUnique({ where: { correo } })` — si no existe → retorna `null`.
2. `bcrypt.compare(contrasena, usuario.contrasena)` — si falla → retorna `null`.
3. Retorna usuario sin la propiedad `contrasena` (desestructurar y omitir).

**`iniciarSesion(usuario)`**
1. Payload JWT: `{ sub: usuario.id, correo: usuario.correo, rol: usuario.rol }`.
2. `tokenAcceso`: firma con `JWT_SECRETO_ACCESO`, expira en `JWT_EXPIRACION_ACCESO`.
3. `tokenRefresh`: firma con `JWT_SECRETO_REFRESH`, expira en `JWT_EXPIRACION_REFRESH`.
4. Hashea `tokenRefresh` con `bcrypt.hash(tokenRefresh, 12)`.
5. Guarda hash en `usuario.tokenRefresh` en la DB con `prisma.usuario.update`.
6. Retorna `{ tokenAcceso, tokenRefresh, usuario: RespuestaUsuarioDto }`.

**`refrescarTokens(idUsuario, tokenRefreshRecibido)`**
1. Busca usuario por `idUsuario`. Si no existe → `ForbiddenException`.
2. Si `usuario.tokenRefresh` es null → `ForbiddenException` (ya cerró sesión).
3. `bcrypt.compare(tokenRefreshRecibido, usuario.tokenRefresh)` — si falla → `ForbiddenException`.
4. Genera nuevos tokens. Actualiza hash. Retorna nuevos tokens.

**`cerrarSesion(idUsuario)`**
1. `prisma.usuario.update({ where: { id: idUsuario }, data: { tokenRefresh: null } })`.

---

### `Examenes.service.ts`

**`crear(dto, idDocente)`**
1. Genera `semillaAleatorizacion = Math.floor(Math.random() * 999999) + 1`.
2. Crea con `prisma.examen.create({ data: { ...dto, creadoPorId: idDocente, semillaAleatorizacion } })`.
3. Retorna el examen creado.

**`publicar(idExamen, idDocente)`**
1. Busca el examen. Si no existe → `NotFoundException`.
2. Si `creadoPorId !== idDocente` → `ForbiddenException`.
3. Si `estado !== EstadoExamen.BORRADOR` → `BadRequestException`.
4. Si `totalPreguntas === 0` → `UnprocessableEntityException` con código `EXAMEN_SIN_PREGUNTAS`.
5. Actualiza `estado = EstadoExamen.PUBLICADO`.

**`obtenerParaEstudiante(idExamen)`**
⚠️ **CRÍTICO:** Al retornar el examen al estudiante, NUNCA incluir `esCorrecta: true` en opciones.
Filtrar o mapear el resultado para omitir ese campo antes de retornar.

---

### `Preguntas.service.ts`

**`crear(idExamen, dto)`**
Dentro de una transacción Prisma (`prisma.$transaction`):
1. Verifica que el examen existe y está en `BORRADOR`.
2. Calcula el `orden` como el número actual de preguntas + 1.
3. Crea la pregunta con `prisma.pregunta.create`.
4. Si `tipo !== RESPUESTA_ABIERTA`: crea las opciones con `prisma.opcionRespuesta.createMany`.
   - Validar: `OPCION_MULTIPLE` y `VERDADERO_FALSO` → exactamente 1 opción con `esCorrecta = true`.
   - Validar: `SELECCION_MULTIPLE` → al menos 1 opción con `esCorrecta = true`.
5. Actualiza `totalPreguntas` y `puntajeMaximo` en el examen padre.
6. Retorna la pregunta con sus opciones.

---

### `SesionesExamen.service.ts`

**`crear(dto, idDocente)`**
1. Genera código de acceso con `GeneradorCodigo.util.ts`:
   - Formato: 4 letras mayúsculas + guión + 4 dígitos. Ej: `MATE-7823`.
   - Si el código ya existe en DB, regenerar (máximo 5 intentos, luego error).
2. Genera `semillaGrupo = Math.floor(Math.random() * 999999) + 1`.
3. Crea con `estado: EstadoSesion.PENDIENTE`.

**`activar(idSesion, idDocente)`**
1. Verifica existencia y propiedad del docente.
2. Verifica que `estado === PENDIENTE` — si no, `BadRequestException`.
3. Actualiza: `estado = ACTIVA`, `fechaInicio = new Date()`.
4. Emite evento WebSocket `sesion:activada` al room `sesion_${idSesion}`.

**`finalizar(idSesion, idDocente)`**
1. Verifica existencia, propiedad y que `estado === ACTIVA`.
2. Actualiza: `estado = FINALIZADA`, `fechaFin = new Date()`.
3. Emite evento WebSocket `sesion:finalizada` al room `sesion_${idSesion}`.
4. Llama a `RespuestasService.calcularPuntajesTodosIntentos(idSesion)`.

---

### `SesionesExamen.gateway.ts` — WebSocket

Nombre del namespace: `/sesiones` (raíz del WebSocket server).

**Eventos cliente → servidor:**
| Evento | Payload | Acción del servidor |
|---|---|---|
| `unirse_sala_sesion` | `{ idSesion: string, rol: RolUsuario }` | Hace `socket.join('sesion_' + idSesion)` |
| `progreso_actualizado` | `{ idIntento: string, preguntasRespondidas: number }` | Emite a sala del docente |
| `alerta_fraude` | `{ idIntento: string, tipoEvento: TipoEventoTelemetria }` | Emite alerta inmediata a sala |

**Eventos servidor → cliente:**
| Evento | Sala destino | Cuándo |
|---|---|---|
| `sesion:activada` | `sesion_${idSesion}` | Docente activa sesión |
| `sesion:finalizada` | `sesion_${idSesion}` | Docente finaliza sesión |
| `estudiante:progreso` | `sesion_${idSesion}` | Estudiante responde pregunta |
| `estudiante:fraude_detectado` | `sesion_${idSesion}` | App detecta evento de fraude |
| `comando:finalizar_examen` | `sesion_${idSesion}` | Docente ordena finalizar a todos |

---

### `Respuestas.service.ts`

**`sincronizarLote(dto, idEstudiante)`**
1. Verifica que el `idIntento` pertenezca al `idEstudiante`.
2. Para cada respuesta en `dto.respuestas`:
   - Usar `prisma.respuesta.upsert({ where: { intentoId_preguntaId }, create: {...}, update: {...} })`.
   - Marcar `esSincronizada = true`.
3. Esto permite reconexiones sin duplicados.

**`finalizar(idIntento, idEstudiante)`**
1. Verifica que el intento exista, pertenezca al estudiante y esté `EN_PROGRESO`.
2. Carga respuestas del intento y preguntas del examen con opciones correctas.
3. Califica cada respuesta:
   - `OPCION_MULTIPLE`: `opcionesSeleccionadas[0]` === letra de la opción con `esCorrecta=true`.
   - `SELECCION_MULTIPLE`: El conjunto de `opcionesSeleccionadas` es igual (sin importar orden) al
     conjunto de letras con `esCorrecta=true`.
   - `VERDADERO_FALSO`: igual que `OPCION_MULTIPLE`.
   - `RESPUESTA_ABIERTA`: `esCorrecta = null` (calificación manual pendiente).
4. Calcula `puntajeObtenido = suma de puntaje de preguntas con esCorrecta=true`.
5. Calcula `porcentaje = (puntajeObtenido / puntajeMaximoExamen) * 100`.
6. Actualiza el `IntentoExamen` con `estado=ENVIADO`, `fechaEnvio`, `puntajeObtenido`, `porcentaje`.
7. Llama a `TelemetriaService.detectarAnomalias(idIntento)`.
8. Retorna `ResultadoFinalDto` con el puntaje (si el examen tiene `mostrarPuntaje=true`).

---

### `Telemetria.service.ts`

**`registrar(dto, idIntento)`**
1. Guarda el evento en `prisma.eventoTelemetria.create`.
2. Si `tipo` es uno de `[APLICACION_EN_SEGUNDO_PLANO, PANTALLA_ABANDONADA, FORZAR_CIERRE]`:
   a. Emite evento WebSocket `estudiante:fraude_detectado` al room de la sesión correspondiente.
   b. Actualiza el intento: `esSospechoso = true`.
   c. Agrega la descripción del evento a `razonSospecha` (concatenar si ya tiene valor).

**`detectarAnomalias(idIntento)`**
1. Carga todos los eventos de telemetría del intento.
2. Cuenta eventos de `APLICACION_EN_SEGUNDO_PLANO` y `PANTALLA_ABANDONADA`.
3. Si el conteo supera `process.env.TELEMETRIA_MAX_EVENTOS_SEGUNDO_PLANO` → marca sospechoso.
4. Calcula el tiempo total del examen en segundos.
5. Si `tiempoTotalSegundos < (totalPreguntas * TELEMETRIA_SEGUNDOS_MINIMOS_POR_PREGUNTA)` → sospechoso.
6. Actualiza `IntentoExamen.esSospechoso` y `razonSospecha` en DB.

---

### `Reportes.service.ts`

**`obtenerReporteSesion(idSesion)`**

Debe retornar:
```typescript
{
  sesion: RespuestaSesionDto,
  totalEstudiantes: number,
  estudiantesQueEnviaron: number,
  estudiantesSospechosos: number,
  puntajePromedio: number,      // null si nadie envió
  puntajeMaximo: number,        // null si nadie envió
  puntajeMinimo: number,        // null si nadie envió
  distribucionPuntajes: { rango: string, cantidad: number }[],
  dificultadPorPregunta: {      // % de estudiantes que acertaron cada pregunta
    idPregunta: string,
    enunciado: string,          // primeros 80 chars
    porcentajeAcierto: number
  }[],
  listaEstudiantes: {
    nombre: string,
    apellidos: string,
    puntaje: number | null,
    porcentaje: number | null,
    estado: EstadoIntento,
    esSospechoso: boolean
  }[]
}
```

---

## ENDPOINTS COMPLETOS DEL BACKEND

Prefijo global: `/api/v1`

### Autenticación
```
POST   /autenticacion/iniciar-sesion          → Sin auth → IniciarSesionDto
POST   /autenticacion/refrescar-tokens        → Refresh Token → RefrescarTokenDto
POST   /autenticacion/cerrar-sesion           → JWT Access Token
```

### Usuarios
```
GET    /usuarios                              → ADMIN
POST   /usuarios                              → ADMIN → CrearUsuarioDto
GET    /usuarios/:id                          → ADMIN o usuario propio
PATCH  /usuarios/:id                          → ADMIN o usuario propio → ActualizarUsuarioDto
DELETE /usuarios/:id                          → ADMIN (desactiva, no elimina)
```

### Exámenes
```
GET    /examenes                              → DOCENTE (solo los suyos), ADMIN (todos)
POST   /examenes                              → DOCENTE → CrearExamenDto
GET    /examenes/:id                          → DOCENTE (dueño), ADMIN
PATCH  /examenes/:id                          → DOCENTE (dueño) en BORRADOR → ActualizarExamenDto
DELETE /examenes/:id                          → DOCENTE (dueño) → cambia a ARCHIVADO
POST   /examenes/:id/publicar                 → DOCENTE (dueño)
```

### Preguntas
```
GET    /examenes/:idExamen/preguntas          → DOCENTE (dueño)
POST   /examenes/:idExamen/preguntas          → DOCENTE (dueño) → CrearPreguntaDto
PUT    /examenes/:idExamen/preguntas/:id      → DOCENTE (dueño) → ActualizarPreguntaDto
DELETE /examenes/:idExamen/preguntas/:id      → DOCENTE (dueño)
PATCH  /examenes/:idExamen/preguntas/reordenar → DOCENTE (dueño) → ReordenarPreguntasDto
```

### Sesiones
```
GET    /sesiones                              → DOCENTE (solo las suyas), ADMIN (todas)
POST   /sesiones                              → DOCENTE → CrearSesionDto
GET    /sesiones/:id                          → DOCENTE (dueño), ADMIN
POST   /sesiones/:id/activar                  → DOCENTE (dueño)
POST   /sesiones/:id/finalizar                → DOCENTE (dueño)
GET    /sesiones/buscar/:codigo               → ESTUDIANTE → retorna sesión sin datos sensibles
```

### Intentos
```
POST   /intentos                              → ESTUDIANTE → IniciarIntentoDto {idSesion}
GET    /intentos/:id/examen                   → ESTUDIANTE (dueño) → retorna examen SIN esCorrecta
```

### Respuestas
```
POST   /respuestas/sincronizar-lote           → ESTUDIANTE → SincronizarRespuestasDto
POST   /intentos/:idIntento/finalizar         → ESTUDIANTE (dueño)
```

### Telemetría
```
POST   /telemetria                            → ESTUDIANTE → RegistrarEventoDto
GET    /intentos/:idIntento/telemetria        → DOCENTE, ADMIN
```

### Reportes
```
GET    /reportes/sesion/:idSesion             → DOCENTE (dueño), ADMIN
GET    /reportes/estudiante/:idEstudiante     → ADMIN, DOCENTE, propio estudiante
```

---

## REGLAS DE SEGURIDAD DEL BACKEND

1. **Passwords**: Siempre hashear con `bcrypt` usando `BCRYPT_RONDAS_HASH` del `.env`.
   Nunca guardar ni loguear contraseñas en texto plano.

2. **JWT**: El `tokenAcceso` dura 15 minutos. El `tokenRefresh` dura 7 días.
   Guardar solo el HASH del refresh token en DB, nunca el valor original.

3. **Autorización por recurso**: En endpoints de docente, siempre verificar que el recurso
   pertenece al docente autenticado. No confiar solo en el rol.

4. **Datos sensibles en respuestas**: Crear `RespuestaUsuarioDto` que excluya `contrasena`
   y `tokenRefresh`. Nunca retornar esos campos, aunque sea en respuestas internas.

5. **Rate limiting**: Aplicar `@nestjs/throttler` en los endpoints de autenticación:
   máximo 10 intentos por IP cada 15 minutos.

6. **Validación de UUIDs**: Usar `@IsUUID()` en todos los params de ruta que sean IDs.

---

## SEMILLA DE BASE DE DATOS

**Archivo:** `prisma/Semillas/Semilla.ts`

Solo crea un usuario Administrador si no existe ninguno. Lee correo y contraseña
del `.env` (`ADMIN_CORREO_INICIAL`, `ADMIN_CONTRASENA_INICIAL`). Hashea la contraseña
con bcrypt antes de guardar. Imprime el ID generado en consola. Registrar en `package.json`:
```json
"prisma": { "seed": "ts-node prisma/Semillas/Semilla.ts" }
```