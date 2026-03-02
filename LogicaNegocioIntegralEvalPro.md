# EvalPro - Logica De Negocio Integral (Version Objetivo)
Fecha: 2026-03-02  
Base analizada: Backend (NestJS + Prisma), Frontend (Next.js), Movil (Flutter), Compartido (tipos/enums).
## 1) Objetivo Del Documento
Definir una logica de negocio completa, consistente y sin ambiguedades para:
1. Jerarquia de roles: `SUPERADMINISTRADOR -> ADMINISTRADOR -> DOCENTE -> ESTUDIANTE`.
2. Gobierno academico por grupos (salones) con relacion explicita docente-estudiante.
3. Ciclo completo: usuarios, grupos, evaluaciones, sesiones, intentos, respuestas, calificacion, reportes y fraude.
4. Reglas unificadas para Backend, Frontend y Movil.
## 2) Diagnostico Del Repositorio Actual (Hallazgos)
1. No existe el rol `SUPERADMINISTRADOR` en enums ni en Prisma.
2. No existen entidades de `Grupo/Salon`, ni asignaciones docentes-estudiantes por grupo.
3. Un estudiante puede iniciar intento en cualquier sesion activa (sin control por pertenencia a grupo).
4. El flujo WebSocket del panel no envia JWT en handshake (el gateway actual exige autenticacion).
5. La app movil consume `semillaGrupo` en sesion, pero `/sesiones/buscar/:codigo` no la expone.
6. No hay multi-tenant formal (`institucion`/`organizacion`) para aislar datos por administrador.
7. No hay matriz de permisos completa por recurso + estado + propiedad + alcance institucional.
## 3) Modelo Organizacional Objetivo
### 3.1 Entidades Organizativas
1. `Institucion`: unidad de aislamiento de datos.
2. `PeriodoAcademico`: anio/semestre con vigencia.
3. `GrupoAcademico` (salon): pertenece a `Institucion` y a un `PeriodoAcademico`.
4. `GrupoDocente`: relacion N:M entre `GrupoAcademico` y `Docente`.
5. `GrupoEstudiante`: relacion N:M entre `GrupoAcademico` y `Estudiante`.
### 3.2 Jerarquia De Roles
1. `SUPERADMINISTRADOR`
   - Crea `ADMINISTRADOR`, `DOCENTE`, `ESTUDIANTE` globalmente.
   - Crea/activa/bloquea instituciones y administradores.
   - Puede auditar todo, pero no responde examenes.
2. `ADMINISTRADOR`
   - Solo opera dentro de su `Institucion`.
   - Crea/gestiona `DOCENTE` y `ESTUDIANTE` de su institucion.
   - Crea y gestiona `GrupoAcademico`.
   - Asigna docentes y estudiantes a grupos.
3. `DOCENTE`
   - Crea evaluaciones propias.
   - Publica evaluaciones y crea sesiones.
   - Solo puede operar sobre grupos donde este asignado.
4. `ESTUDIANTE`
   - Solo responde sesiones para grupos en los que esta inscrito.
   - No puede acceder al panel administrativo.
## 4) Reglas Globales De Autorizacion (Orden Obligatorio)
Toda operacion se valida en este orden:
1. `Autenticacion` (JWT valido).
2. `Estado usuario` (`activo=true`, no bloqueado).
3. `Rol`.
4. `Alcance institucional` (`idInstitucion` del recurso == `idInstitucion` del usuario, excepto superadmin).
5. `Propiedad o asignacion` (dueno del recurso o miembro del grupo).
6. `Estado del dominio` (ej: `BORRADOR`, `ACTIVA`, `EN_PROGRESO`).
Si una capa falla, se rechaza la operacion.
## 5) Matriz De Permisos Clave
1. Crear administradores: solo `SUPERADMINISTRADOR`.
2. Crear docentes/estudiantes:
   - `SUPERADMINISTRADOR`: cualquier institucion.
   - `ADMINISTRADOR`: solo su institucion.
3. Crear grupos: `ADMINISTRADOR` (su institucion), `SUPERADMINISTRADOR` (cualquier institucion).
4. Asignar docente a grupo: `ADMINISTRADOR` o `SUPERADMINISTRADOR`.
5. Asignar estudiante a grupo: `ADMINISTRADOR` o `SUPERADMINISTRADOR`.
6. Crear examen: `DOCENTE` (solo si pertenece a >=1 grupo activo).
7. Asignar examen a grupos/estudiantes: `DOCENTE` dueno del examen, limitado a sus grupos.
8. Crear/activar/finalizar sesion: `DOCENTE` dueno, sobre examen asignado al grupo objetivo.
9. Anular intento: `DOCENTE` dueno de la sesion, `ADMINISTRADOR` de la institucion, `SUPERADMINISTRADOR`.
10. Ver reportes:
   - Docente: solo sesiones propias.
   - Administrador: todo su tenant.
   - Superadmin: global.
   - Estudiante: solo su propio historial.
## 6) Flujo De Usuarios Y Grupos
### 6.1 Alta De Usuarios
1. Usuario se crea con `estadoCuenta=PENDIENTE_ACTIVACION` y `activo=true`.
2. Se genera credencial temporal y vencimiento.
3. Primer login obliga cambio de contrasena.
4. Cambio de rol solo hacia abajo por `ADMINISTRADOR`; hacia `ADMINISTRADOR` solo por `SUPERADMINISTRADOR`.
### 6.2 Ciclo De Grupo Academico
Estados: `BORRADOR`, `ACTIVO`, `CERRADO`, `ARCHIVADO`.
1. En `BORRADOR` se pueden asignar docentes y estudiantes.
2. Solo `ACTIVO` permite sesiones.
3. `CERRADO` bloquea nuevas sesiones, conserva historico.
4. `ARCHIVADO` solo lectura.
## 7) Flujo De Evaluaciones
Estados de examen: `BORRADOR`, `PUBLICADO`, `ARCHIVADO`.
1. El docente crea examen en `BORRADOR`.
2. Agrega preguntas y reglas de puntaje.
3. Publicar exige:
   - minimo 1 pregunta valida,
   - consistencia de puntaje maximo,
   - al menos un grupo objetivo habilitado.
4. Examen publicado solo admite cambios no sustantivos (metadatos).
5. Clonar examen crea nueva version en `BORRADOR`.
## 8) Asignacion De Examenes
Nueva entidad: `AsignacionExamen`.
1. Puede apuntar a `GrupoAcademico` o `Estudiante` individual.
2. Debe tener ventana temporal (`fechaInicio`, `fechaFin`).
3. Puede tener intentos maximos por estudiante.
4. Regla de elegibilidad: estudiante solo ve sesiones de asignaciones donde es miembro efectivo.
## 9) Flujo De Sesiones
Estados de sesion: `PENDIENTE`, `ACTIVA`, `FINALIZADA`, `CANCELADA`.
1. Sesion se crea sobre una `AsignacionExamen`.
2. `ACTIVAR` solo si grupo activo y ventana vigente.
3. `FINALIZAR` cierra ingreso y dispara cierre/calificacion de intentos en progreso.
4. `CANCELAR` invalida resultados oficiales de la sesion.
## 10) Flujo De Intentos, Respuestas Y Calificacion
Estados de intento: `EN_PROGRESO`, `ENVIADO`, `ANULADO`, `SINCRONIZACION_PENDIENTE`.
1. Inicio de intento valida:
   - sesion `ACTIVA`,
   - estudiante elegible por grupo/asignacion,
   - unicidad por `estudianteId + sesionId`.
2. Respuestas en lote con `upsert` idempotente.
3. Calificacion automatica:
   - opcion multiple / VF: exact match.
   - seleccion multiple: igualdad de conjuntos.
   - abierta: pendiente manual.
4. Calificacion manual solo por docente de sesion o administracion del tenant.
5. Recalculo inmediato de puntaje total tras cada calificacion manual.
## 11) Resultados, Publicacion Y Reclamos
1. `ResultadoPreliminar`: visible al estudiante si `mostrarPuntaje=true`.
2. `ResultadoOficial`: se emite cuando preguntas abiertas quedan calificadas o al cierre forzado de ventana.
3. Se permite `ReclamoCalificacion` con plazo configurable.
4. Resolucion del reclamo deja traza de auditoria y version de nota.
## 12) Telemetria Y Anti-Fraude (Mecanismo Robusto)
### 12.1 Señales
Eventos minimos: segundo plano, abandono pantalla, cierre forzado, tiempo anomalo, sincronizacion anomala.
### 12.2 Puntaje De Riesgo
Definir `indiceRiesgoFraude` en rango 0-100:
`R = w1*foco + w2*abandono + w3*cierre + w4*tiempo + w5*red + w6*patronRespuesta`
Politica:
1. `R < 30`: normal.
2. `30 <= R < 60`: sospechoso.
3. `R >= 60`: alerta critica (requiere revision docente).
4. `R >= 80`: sugerencia de anulacion (decision humana final).
### 12.3 Regla De No Automatismo Punitivo
El sistema detecta y recomienda; la anulacion oficial la toma un actor humano autorizado.
## 13) Teoria De Juegos Aplicada
### 13.1 Modelo Estrategico
Jugador A: estudiante (`honesto`, `trampa`).  
Jugador B: sistema/docente (`monitoreo bajo`, `monitoreo alto`).
Utilidad esperada de trampa:
`U_trampa = B_ganar - p_detec*C_sancion - p_anulacion*C_repeticion - C_cognitivo`
Diseno objetivo: hacer `U_trampa < U_honesto` para la mayoria de perfiles.
### 13.2 Controles Para Mover El Equilibrio
1. Aleatorizacion determinista por estudiante (preguntas/opciones).
2. Monitoreo mixto no predecible por sesion (muestreo de revision manual).
3. Penalizacion progresiva por reincidencia.
4. Publicacion diferida de claves de correccion.
5. Auditoria trazable para elevar costo esperado de colusion.
## 14) Reglas Especificas Por Capa
### 14.1 Backend
1. Añadir `SUPERADMINISTRADOR` y `idInstitucion` en JWT.
2. Filtro obligatorio por tenant en todos los `findMany/findUnique`.
3. Nuevos modulos: `Instituciones`, `Grupos`, `Asignaciones`.
4. Endpoints de socket deben autenticar siempre por JWT.
### 14.2 Frontend
1. Guardas por rol y por tenant.
2. Monitor WebSocket debe enviar token en handshake.
3. UI debe bloquear acciones por estado y por alcance de grupo.
4. Vistas separadas: superadmin global vs administrador institucional.
### 14.3 Movil
1. Solo `ESTUDIANTE` autenticable.
2. Solo mostrar sesiones elegibles por asignacion.
3. Persistencia offline con reconciliacion idempotente.
4. Antifraude local + envio de evidencia estructurada.
## 15) Invariantes No Negociables
1. Nadie opera recursos fuera de su tenant (excepto superadmin).
2. Ningun estudiante inicia intento sin pertenencia valida a grupo/asignacion.
3. Nunca se exponen respuestas correctas antes del envio.
4. Toda accion sensible deja auditoria (actor, recurso, antes/despues, timestamp).
5. Toda transicion de estado invalida se rechaza.
## 16) Plan De Migracion Recomendado
1. Fase A: esquema (roles, instituciones, grupos, asignaciones, auditoria).
2. Fase B: autorizacion centralizada por tenant/propiedad.
3. Fase C: flujos de evaluacion/sesion/intento con elegibilidad por grupo.
4. Fase D: frontend y movil alineados a nuevos contratos.
5. Fase E: endurecimiento antifraude + pruebas e2e de permisos finos.
## 17) Criterio De Cierre (Definition Of Done)
1. Matriz de permisos completa implementada y probada.
2. Cero acceso cruzado entre instituciones.
3. Cero inicio de intento fuera de grupo/asignacion.
4. Reportes consistentes entre backend, panel y movil.
5. Antifraude operativo con trazabilidad y politicas de decision humana.
6. Suite automatizada (unitarias + e2e + integracion socket) en verde.
