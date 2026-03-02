# GUÍA DE USO — Archivos AGENTS.md de EvalPro

## Qué archivo hace qué

| Archivo | Quién lo lee | Cuándo se activa |
|---|---|---|
| `/AGENTS.md` | Todos los agentes | Siempre, en cualquier archivo del repo |
| `/Backend/AGENTS.md` | Agentes en `Backend/` | Al trabajar en NestJS, Prisma, DTOs |
| `/Frontend/AGENTS.md` | Agentes en `Frontend/` | Al trabajar en Next.js, componentes, hooks |
| `/Movil/AGENTS.md` | Agentes en `Movil/` | Al trabajar en Flutter, Dart, Kotlin, Swift |
| `.cursor/rules/Nomenclatura.mdc` | Cursor (siempre) | En cualquier archivo de código |
| `.cursor/rules/Arquitectura.mdc` | Cursor (siempre) | En cualquier archivo del proyecto |
| `.cursor/rules/Backend.mdc` | Cursor | Solo en `Backend/**/*.ts` |
| `.cursor/rules/Frontend.mdc` | Cursor | Solo en `Frontend/**/*.ts, .tsx` |
| `.cursor/rules/Flutter.mdc` | Cursor | Solo en `Movil/**/*.dart, .kt, .swift` |
| `.windsurf/rules/global_rules.md` | Windsurf | Siempre |

## Cómo usar con Cursor

### Inicio de cada fase (OBLIGATORIO)
Antes de pedir al agente que construya algo, usar **Plan Mode** (`Shift+Tab`):

```
[Plan Mode]
"Construye el módulo de Autenticación del Backend.
Lee primero /Backend/AGENTS.md completo antes de escribir código."
```

El agente genera un plan con archivos a crear. Revisarlo. Si algo no coincide con
los AGENTS.md, corregir el PLAN (no el código después).

### Prompt por módulo (copiar y adaptar)
```
"Siguiendo estrictamente /AGENTS.md y /Backend/AGENTS.md:
Construye el módulo [NOMBRE] del Backend.
Archivos a crear según la estructura de directorios de Backend/AGENTS.md:
- [lista los archivos del módulo]
No inventes lógica que no esté descrita en los AGENTS.md."
```

## Cómo usar con Codex CLI

```bash
# Instalar
npm i -g @openai/codex

# Por módulo — modo interactivo (recomendado para módulos complejos)
codex "Construye el módulo de Autenticación NestJS según /Backend/AGENTS.md. Crea exactamente los archivos listados en la sección de estructura de directorios."

# Modo automático (para módulos simples o bien definidos)
codex --full-auto "Crea el schema.prisma completo según el esquema de /Backend/AGENTS.md"
```

## Cómo usar con Claude Code

```bash
# Instalar
npm install -g @anthropic-ai/claude-code
claude

# Dentro de la sesión
> Lee /Backend/AGENTS.md y construye el módulo de SesionesExamen completo incluyendo el Gateway WebSocket
```

## Regla de oro para prompts al agente

❌ **MALO:** "Crea el backend de la app de evaluación"
→ El agente inventa todo

✅ **BUENO:** "Lee /Backend/AGENTS.md. Construye el módulo Respuestas.
Crea exactamente estos archivos: Respuestas.module.ts, Respuestas.controller.ts,
Respuestas.service.ts, Dto/SincronizarRespuestas.dto.ts, Dto/ResultadoFinal.dto.ts.
La lógica de cada método está descrita en la sección 'Lógica de cada servicio' del AGENTS.md."

## Checkpoint Git por fase

```bash
git add .
git commit -m "[2.3] Implementa módulo de autenticación con JWT y refresh tokens"
```

Crear tag por fase completa:
```bash
git tag fase-2-backend-completo
```