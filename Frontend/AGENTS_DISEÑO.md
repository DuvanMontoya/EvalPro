# AGENTS.md — EvalPro · Sistema de Diseño & UI/UX
> **Lee este archivo ANTES de tocar cualquier componente visual.**
> Complementa el `AGENTS.md` raíz y el de `Frontend/`.
> Este archivo define el diseño con precisión quirúrgica. Sin excepción, sin improvisación.

---

## 1. IDENTIDAD VISUAL — CONCEPTO DIRECTOR

**Concepto:** "Sala de control académico"
Un panel de administración que se siente como el cockpit de un sistema profesional de alto valor.
No es una app educativa colorida. Es una herramienta de poder para docentes exigentes.

**Inspiración de referencia:** Linear.app + Vercel Dashboard + Raycast — pero con personalidad propia.

**La promesa visual:** Cada pantalla debe sentirse como si costara $200,000 USD hacerla.
Oscura, densa de información, precisa, sin ruido, con detalles que sorprenden al segundo vistazo.

**Tono:** Luxury-utilitarian. Dark-first. Información densa pero perfectamente legible.
No es juguetón. No es corporativo aburrido. Es serio, veloz y premium.

---

## 2. SISTEMA DE COLOR (CSS VARIABLES — FUENTE ÚNICA DE VERDAD)

### Paleta Base — Dark Theme (por defecto)

```css
:root {
  /* === FONDOS === */
  --fondo-raiz:         #080C10;  /* Negro azulado profundo — body */
  --fondo-elevado-1:    #0D1117;  /* Sidebar, panels primarios */
  --fondo-elevado-2:    #161B22;  /* Cards, modales */
  --fondo-elevado-3:    #1C2230;  /* Hover states, inputs */
  --fondo-elevado-4:    #242B38;  /* Active states, seleccionados */

  /* === BORDES === */
  --borde-sutil:        rgba(255,255,255,0.06);
  --borde-default:      rgba(255,255,255,0.10);
  --borde-fuerte:       rgba(255,255,255,0.18);
  --borde-interactivo:  rgba(255,255,255,0.28);  /* focus, hover */

  /* === TIPOGRAFÍA === */
  --texto-primario:     #F0F4F8;
  --texto-secundario:   #8B949E;
  --texto-terciario:    #4A5568;
  --texto-deshabilitado:#2D3748;
  --texto-invertido:    #080C10;

  /* === ACENTO PRIMARIO — Azul eléctrico === */
  --acento-primario:         #3B82F6;  /* brand blue */
  --acento-primario-hover:   #60A5FA;
  --acento-primario-sutil:   rgba(59,130,246,0.12);
  --acento-primario-borde:   rgba(59,130,246,0.35);
  --acento-primario-glow:    rgba(59,130,246,0.20);

  /* === ACENTO SECUNDARIO — Cyan para datos === */
  --acento-cyan:        #22D3EE;
  --acento-cyan-sutil:  rgba(34,211,238,0.10);

  /* === ESTADOS SEMÁNTICOS === */
  --estado-exito:       #10B981;
  --estado-exito-sutil: rgba(16,185,129,0.12);
  --estado-exito-borde: rgba(16,185,129,0.30);

  --estado-advertencia:       #F59E0B;
  --estado-advertencia-sutil: rgba(245,158,11,0.12);
  --estado-advertencia-borde: rgba(245,158,11,0.30);

  --estado-peligro:       #EF4444;
  --estado-peligro-sutil: rgba(239,68,68,0.12);
  --estado-peligro-borde: rgba(239,68,68,0.30);

  --estado-info:       #8B5CF6;
  --estado-info-sutil: rgba(139,92,246,0.12);

  --estado-neutro:       #6B7280;
  --estado-neutro-sutil: rgba(107,114,128,0.12);

  /* === GRADIENTES === */
  --gradiente-primario:     linear-gradient(135deg, #3B82F6 0%, #1D4ED8 100%);
  --gradiente-peligro:      linear-gradient(135deg, #EF4444 0%, #DC2626 100%);
  --gradiente-exito:        linear-gradient(135deg, #10B981 0%, #059669 100%);
  --gradiente-sutil-fondo:  linear-gradient(180deg, rgba(59,130,246,0.04) 0%, transparent 60%);
  --gradiente-barra-lateral: linear-gradient(180deg, #0D1117 0%, #080C10 100%);

  /* === SOMBRAS === */
  --sombra-xs:   0 1px 2px rgba(0,0,0,0.4);
  --sombra-sm:   0 2px 8px rgba(0,0,0,0.5);
  --sombra-md:   0 4px 20px rgba(0,0,0,0.6), 0 1px 3px rgba(0,0,0,0.4);
  --sombra-lg:   0 8px 40px rgba(0,0,0,0.7), 0 2px 8px rgba(0,0,0,0.5);
  --sombra-xl:   0 20px 60px rgba(0,0,0,0.8);
  --sombra-azul: 0 0 20px rgba(59,130,246,0.25), 0 4px 12px rgba(0,0,0,0.5);
  --sombra-glow-primario: 0 0 0 3px rgba(59,130,246,0.20);

  /* === TRANSICIONES === */
  --transicion-rapida:  all 0.12s cubic-bezier(0.4, 0, 0.2, 1);
  --transicion-normal:  all 0.20s cubic-bezier(0.4, 0, 0.2, 1);
  --transicion-lenta:   all 0.35s cubic-bezier(0.4, 0, 0.2, 1);
  --transicion-rebote:  all 0.40s cubic-bezier(0.34, 1.56, 0.64, 1);

  /* === RADIOS === */
  --radio-xs:   4px;
  --radio-sm:   6px;
  --radio-md:   8px;
  --radio-lg:   12px;
  --radio-xl:   16px;
  --radio-2xl:  20px;
  --radio-full: 9999px;
}
```

### Paleta Light Theme (modo claro — opcional, no por defecto)

```css
[data-tema="claro"] {
  --fondo-raiz:         #F8FAFC;
  --fondo-elevado-1:    #FFFFFF;
  --fondo-elevado-2:    #F1F5F9;
  --fondo-elevado-3:    #E2E8F0;
  --fondo-elevado-4:    #CBD5E1;
  --borde-sutil:        rgba(0,0,0,0.05);
  --borde-default:      rgba(0,0,0,0.09);
  --borde-fuerte:       rgba(0,0,0,0.15);
  --texto-primario:     #0F172A;
  --texto-secundario:   #475569;
  --texto-terciario:    #94A3B8;
}
```

---

## 3. TIPOGRAFÍA

### Fuentes (importar en `layout.tsx` via `next/font/google`)

```typescript
// Fuente Display: para títulos de página, métricas grandes, encabezados de sección
import { Syne } from 'next/font/google';
const fuenteDisplay = Syne({ subsets: ['latin'], weight: ['700', '800'] });

// Fuente UI: para todo el body, labels, botones, navegación
import { DM_Sans } from 'next/font/google';
const fuenteUI = DM_Sans({ subsets: ['latin'], weight: ['300', '400', '500', '600'] });

// Fuente Mono: para códigos de acceso, IDs, timestamps, valores numéricos
import { JetBrains_Mono } from 'next/font/google';
const fuenteMono = JetBrains_Mono({ subsets: ['latin'], weight: ['400', '500', '600'] });
```

### Escala Tipográfica

```css
/* Display — títulos de página */
.texto-display-xl { font-family: Syne; font-size: 2.25rem; font-weight: 800; letter-spacing: -0.03em; line-height: 1.1; }
.texto-display-lg { font-family: Syne; font-size: 1.75rem; font-weight: 700; letter-spacing: -0.025em; line-height: 1.15; }
.texto-display-md { font-family: Syne; font-size: 1.375rem; font-weight: 700; letter-spacing: -0.02em; line-height: 1.2; }

/* UI — navegación, labels, texto general */
.texto-lg  { font-size: 1rem;    font-weight: 500; line-height: 1.5; }
.texto-md  { font-size: 0.9rem;  font-weight: 400; line-height: 1.55; }
.texto-sm  { font-size: 0.8rem;  font-weight: 400; line-height: 1.5; }
.texto-xs  { font-size: 0.72rem; font-weight: 500; line-height: 1.4; letter-spacing: 0.02em; }

/* Mono — datos técnicos */
.texto-mono-lg { font-family: JetBrains Mono; font-size: 1rem;   font-weight: 500; }
.texto-mono-sm { font-family: JetBrains Mono; font-size: 0.78rem; font-weight: 400; }
```

---

## 4. LAYOUT GLOBAL — ESTRUCTURA EXACTA

```
┌─────────────────────────────────────────────────────────────┐
│  BarraLateral (240px fija, colapsable a 60px)               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Logo (24px alto)                            [≡]      │   │
│  │ ─────────────────────────────────────────────────    │   │
│  │ PRINCIPAL                                            │   │
│  │   📊 Tablero          (siempre visible)              │   │
│  │   📝 Exámenes         (siempre visible)              │   │
│  │   🎯 Sesiones         (siempre visible)              │   │
│  │   👥 Estudiantes      (siempre visible)              │   │
│  │   📈 Reportes         (siempre visible)              │   │
│  │ ─────────────────────────────────────────────────    │   │
│  │ SISTEMA                                              │   │
│  │   ⚙️  Configuración                                  │   │
│  │ ─────────────────────────────────────────────────    │   │
│  │ [Avatar] Nombre Docente      ↕ versión               │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                             │
│  Área Principal                                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ EncabezadoAdmin (56px alto, sticky)                  │   │
│  │  [Breadcrumb]              [Notif][Búsqueda][Avatar] │   │
│  ├──────────────────────────────────────────────────────┤   │
│  │                                                      │   │
│  │  Contenido de la página (padding: 24px 32px)         │   │
│  │                                                      │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### `BarraLateral.tsx` — Especificación Exacta

**Dimensiones:**
- Expandida: `240px` de ancho, `100vh` de alto, `position: fixed`
- Colapsada: `60px` de ancho (solo iconos, tooltip on hover)
- Transición: `width 0.25s cubic-bezier(0.4, 0, 0.2, 1)`

**Fondo:**
```css
background: var(--gradiente-barra-lateral);
border-right: 1px solid var(--borde-sutil);
```

**Logo:**
- Zona logo: `padding: 20px 16px 16px`
- Texto "EvalPro" en `Syne 800`, `18px`, color `var(--texto-primario)`
- Punto de acento: círculo `6px` color `var(--acento-primario)` antes del texto
- Versión: tag pequeño `v1.0` en `JetBrains Mono`, `10px`, `var(--texto-terciario)`

**Ítem de navegación — Estado Normal:**
```css
display: flex; align-items: center; gap: 10px;
padding: 8px 12px; border-radius: var(--radio-sm);
color: var(--texto-secundario);
font-size: 0.875rem; font-weight: 500;
transition: var(--transicion-rapida);
cursor: pointer; text-decoration: none;
```

**Ítem de navegación — Estado Hover:**
```css
background: var(--fondo-elevado-3);
color: var(--texto-primario);
```

**Ítem de navegación — Estado Activo (ruta actual):**
```css
background: var(--acento-primario-sutil);
color: var(--acento-primario-hover);
border: 1px solid var(--acento-primario-borde);
/* Ícono se torna azul */
```

**Separadores de sección:**
```css
margin: 16px 12px 8px;
font-size: 0.65rem; font-weight: 600;
letter-spacing: 0.08em; text-transform: uppercase;
color: var(--texto-terciario);
```

**Área de usuario (bottom):**
```css
position: absolute; bottom: 0; left: 0; right: 0;
padding: 12px 16px;
border-top: 1px solid var(--borde-sutil);
background: rgba(8,12,16,0.5); backdrop-filter: blur(10px);
```
- Avatar: `32px × 32px`, `border-radius: 50%`, gradiente generado con iniciales
- Nombre: `14px`, `500 weight`
- Rol: `11px`, `var(--texto-terciario)`

**Badge de notificación en ítem:**
- Pequeño badge redondeado `18px` alto, color `var(--estado-peligro)` con número

### `EncabezadoAdmin.tsx` — Especificación Exacta

```css
height: 56px;
background: rgba(8,12,16,0.75);
backdrop-filter: blur(20px) saturate(180%);
border-bottom: 1px solid var(--borde-sutil);
position: sticky; top: 0; z-index: 40;
padding: 0 32px;
display: flex; align-items: center; justify-content: space-between;
```

**Lado izquierdo:** `BreadcrumbNavegacion` — separadores con `/` en color `var(--texto-terciario)`

**Lado derecho (acciones globales):**
1. Botón buscar — ícono `Cmd+K`, abre command palette
2. Botón notificaciones — ícono campana con badge rojo si hay alertas
3. Divider vertical `1px` gris
4. Avatar del usuario — abre `MenuUsuario` dropdown

---

## 5. SISTEMA DE COMPONENTES BASE

### Botones

#### Variante Primary
```css
background: var(--gradiente-primario);
color: white; font-weight: 600; font-size: 0.875rem;
padding: 8px 16px; border-radius: var(--radio-md);
border: none; box-shadow: var(--sombra-azul);
transition: var(--transicion-rapida);
/* hover */ filter: brightness(1.1); transform: translateY(-1px);
/* active */ transform: translateY(0); filter: brightness(0.95);
/* disabled */ opacity: 0.4; cursor: not-allowed; transform: none;
```

#### Variante Secondary
```css
background: var(--fondo-elevado-3);
border: 1px solid var(--borde-default);
color: var(--texto-primario); font-weight: 500; font-size: 0.875rem;
padding: 8px 16px; border-radius: var(--radio-md);
/* hover */ background: var(--fondo-elevado-4); border-color: var(--borde-fuerte);
```

#### Variante Ghost
```css
background: transparent;
color: var(--texto-secundario); font-size: 0.875rem;
padding: 8px 12px; border-radius: var(--radio-sm);
border: none;
/* hover */ background: var(--fondo-elevado-3); color: var(--texto-primario);
```

#### Variante Danger
```css
background: var(--estado-peligro-sutil);
border: 1px solid var(--estado-peligro-borde);
color: var(--estado-peligro); font-weight: 600;
/* hover */ background: var(--estado-peligro); color: white;
```

#### Tamaños
- `sm`: `padding: 6px 12px; font-size: 0.8rem;`
- `md`: `padding: 8px 16px; font-size: 0.875rem;` (default)
- `lg`: `padding: 10px 20px; font-size: 1rem;`
- `icon`: `width: 36px; height: 36px; padding: 0;`

#### Estado cargando: spinner SVG animado (18px) a la izquierda del texto, texto atenuado

### Inputs y Formularios

```css
/* Input base */
background: var(--fondo-elevado-2);
border: 1px solid var(--borde-default);
border-radius: var(--radio-md);
color: var(--texto-primario);
font-size: 0.875rem; padding: 9px 12px;
width: 100%;
transition: var(--transicion-rapida);
outline: none;

/* focus */
border-color: var(--acento-primario);
box-shadow: var(--sombra-glow-primario);
background: var(--fondo-elevado-3);

/* error */
border-color: var(--estado-peligro);
box-shadow: 0 0 0 3px rgba(239,68,68,0.15);

/* placeholder */
color: var(--texto-terciario);

/* disabled */
opacity: 0.5; cursor: not-allowed; background: var(--fondo-elevado-1);
```

**Label sobre el input:**
```css
font-size: 0.78rem; font-weight: 500; 
color: var(--texto-secundario);
margin-bottom: 6px; display: block;
letter-spacing: 0.01em;
```

**Mensaje de error (inline, debajo):**
```css
font-size: 0.75rem; color: var(--estado-peligro);
margin-top: 5px; display: flex; align-items: center; gap: 4px;
/* ícono de alerta pequeño (12px) a la izquierda */
```

### Cards

```css
/* Card base */
background: var(--fondo-elevado-2);
border: 1px solid var(--borde-sutil);
border-radius: var(--radio-xl);
padding: 20px;
transition: var(--transicion-normal);

/* hover (si es interactiva) */
border-color: var(--borde-default);
background: var(--fondo-elevado-3);
transform: translateY(-1px);
box-shadow: var(--sombra-md);
```

**Card Header:**
```css
display: flex; align-items: center; justify-content: space-between;
margin-bottom: 16px; padding-bottom: 14px;
border-bottom: 1px solid var(--borde-sutil);
```

### Badges / Chips de Estado

Tamaño: `padding: 3px 9px; border-radius: var(--radio-full); font-size: 0.7rem; font-weight: 600; letter-spacing: 0.04em;`

| Estado | Fondo | Borde | Texto |
|---|---|---|---|
| BORRADOR | `--estado-neutro-sutil` | `--estado-neutro-borde` | `--texto-secundario` |
| PUBLICADO | `--estado-exito-sutil` | `--estado-exito-borde` | `--estado-exito` |
| ARCHIVADO | `--fondo-elevado-3` | `--borde-sutil` | `--texto-terciario` |
| PENDIENTE | `--estado-advertencia-sutil` | `--estado-advertencia-borde` | `--estado-advertencia` |
| ACTIVA | `--estado-exito-sutil` | `--estado-exito-borde` | `--estado-exito` |
| FINALIZADA | `--fondo-elevado-3` | `--borde-default` | `--texto-secundario` |
| CANCELADA | `--estado-peligro-sutil` | `--estado-peligro-borde` | `--estado-peligro` |
| EN_PROGRESO | `--acento-primario-sutil` | `--acento-primario-borde` | `--acento-primario-hover` |
| ENVIADO | `--estado-exito-sutil` | `--estado-exito-borde` | `--estado-exito` |
| ANULADO | `--estado-peligro-sutil` | `--estado-peligro-borde` | `--estado-peligro` |

**Dot indicador animado (solo para ACTIVA):**
```css
/* Punto parpadeante antes del texto */
width: 6px; height: 6px; background: var(--estado-exito);
border-radius: 50%; animation: pulso 2s ease-in-out infinite;
@keyframes pulso { 0%,100% { opacity:1; transform: scale(1); } 50% { opacity:0.5; transform: scale(0.85); } }
```

### Tablas

```css
/* Tabla contenedor */
width: 100%; border-collapse: collapse;

/* Header row */
background: var(--fondo-elevado-1);
th {
  padding: 10px 16px;
  text-align: left;
  font-size: 0.72rem; font-weight: 600;
  color: var(--texto-terciario);
  letter-spacing: 0.06em; text-transform: uppercase;
  border-bottom: 1px solid var(--borde-default);
}

/* Body row */
td {
  padding: 13px 16px;
  font-size: 0.875rem;
  color: var(--texto-secundario);
  border-bottom: 1px solid var(--borde-sutil);
  vertical-align: middle;
}

/* Row hover */
tr:hover td {
  background: var(--fondo-elevado-3);
  color: var(--texto-primario);
  cursor: pointer;
}

/* Última fila: sin borde inferior */
tr:last-child td { border-bottom: none; }
```

**Columna de acciones (última columna):**
```css
text-align: right;
/* Botones ghost de 32px con iconos — visibles solo en hover del row */
opacity: 0; /* row hover → opacity: 1, transition: 0.15s */
```

### Modales y Dialogs

```css
/* Overlay */
background: rgba(0,0,0,0.75);
backdrop-filter: blur(6px);
animation: fadeIn 0.15s ease;

/* Dialog panel */
background: var(--fondo-elevado-2);
border: 1px solid var(--borde-default);
border-radius: var(--radio-2xl);
box-shadow: var(--sombra-xl);
padding: 24px;
min-width: 480px; max-width: 680px;
animation: scaleIn 0.2s cubic-bezier(0.34, 1.56, 0.64, 1);

@keyframes scaleIn {
  from { transform: scale(0.94) translateY(8px); opacity: 0; }
  to   { transform: scale(1) translateY(0); opacity: 1; }
}
```

**Header del modal:**
- Título: `Syne 700`, `18px`
- Subtítulo opcional: `14px`, `var(--texto-secundario)`
- Botón X: esquina superior derecha, ghost, ícono `X` 16px

**Footer del modal:** flex, gap 8px, `justify-content: flex-end`

### Tooltips

```css
background: var(--fondo-elevado-4);
border: 1px solid var(--borde-fuerte);
color: var(--texto-primario);
font-size: 0.75rem; font-weight: 500;
padding: 6px 10px; border-radius: var(--radio-sm);
box-shadow: var(--sombra-md);
animation: fadeIn 0.1s ease;
```

---

## 6. PÁGINAS — ESPECIFICACIÓN EXACTA

### 6.1 — Login (`/IniciarSesion`)

**Layout:** Pantalla completa dividida 50/50 en escritorio, solo formulario en móvil.

**Panel izquierdo (50% — solo desktop):**
```css
background: var(--fondo-elevado-1);
/* Patrón de puntos sutiles como fondo */
background-image: radial-gradient(circle, var(--borde-sutil) 1px, transparent 1px);
background-size: 24px 24px;
position: relative; overflow: hidden;
```
- Centered: logo grande EvalPro + tagline "Evaluaciones académicas inteligentes"
- Cita motivacional en italic, `var(--texto-terciario)`
- 3 feature pills flotantes con animación suave (como floating cards):
  - "🔒 Modo Kiosco Anti-trampa"
  - "📊 Reportes en tiempo real"
  - "📱 Desde cualquier dispositivo"

**Panel derecho (50% — formulario):**
```css
background: var(--fondo-raiz);
display: flex; align-items: center; justify-content: center;
```
Contenedor del form: `max-width: 380px; width: 100%;`

- "Bienvenido de vuelta" — `Syne 800`, `28px`
- Subtítulo: "Accede a tu panel de administración" — gris sutil
- Input correo electrónico con ícono de sobre izquierda
- Input contraseña con ícono candado + botón mostrar/ocultar
- Botón "Iniciar sesión" — full width, primary
- Link "¿Olvidaste tu contraseña?" — subtle, centrado
- Footer: versión app en `JetBrains Mono`, `11px`, muy sutil

**Animación:** Los inputs aparecen con `fadeInUp` staggered (0ms, 80ms, 160ms, 240ms).

---

### 6.2 — Tablero (`/Tablero`)

**Encabezado de página:**
```
"Tablero"  [Syne 800, 28px]
"Lunes, 2 de marzo de 2026 · Buenos días, [Nombre]"  [texto-secundario, 14px]
```

**Fila 1 — Métricas principales (4 cards en grid):**

Cada `TarjetaMetrica`:
```css
background: var(--fondo-elevado-2);
border: 1px solid var(--borde-sutil);
border-radius: var(--radio-xl);
padding: 20px 22px;
position: relative; overflow: hidden;
/* Glow sutil en la esquina superior derecha según color */
&::before {
  content: '';
  position: absolute; top: -30px; right: -30px;
  width: 100px; height: 100px;
  border-radius: 50%;
  background: radial-gradient([color-acento], transparent 70%);
  opacity: 0.5;
}
```

Estructura interna:
```
[Ícono 36px en círculo coloreado]     [Variación % con flecha ↑/↓]
[Valor numérico — Syne 800, 32px]
[Label — texto-secundario, 13px]
```

| Métrica | Ícono | Color acento |
|---|---|---|
| Sesiones activas ahora | ⚡ Lightning | `--acento-cyan` |
| Estudiantes conectados | 👥 Users | `--acento-primario` |
| Exámenes publicados | 📝 FileText | `--estado-exito` |
| Sesiones hoy | 📅 Calendar | `--estado-advertencia` |

**Fila 2 — Split layout (60% + 40%):**

**Panel izquierdo — Gráfica actividad semanal (Recharts):**
```css
/* AreaChart con gradiente */
```
- Tipo: `AreaChart` con gradiente bajo la línea (azul → transparente)
- Eje X: últimos 7 días abreviados (Lun, Mar, Mie...)
- Eje Y: número de sesiones
- Tooltips custom con estilo del sistema (dark)
- Sin border en el chart, fondo transparente
- Dos series: "Sesiones" (azul) y "Estudiantes" (cyan) — líneas suaves

**Panel derecho — Últimas 5 sesiones (lista compacta):**
- Título: "Actividad reciente"
- Cada ítem: nombre sesión + badge estado + timestamp relativo (hace 5 min)
- Link "Ver todas las sesiones →" al final

**Fila 3 — Acciones rápidas (3 cards acción):**
```css
/* Tres cards horizontales — hover con elevación y borde azul */
display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px;
```
- "Crear examen" — ícono `PlusCircle`, description breve
- "Nueva sesión" — ícono `Play`, description breve
- "Ver reportes" — ícono `BarChart2`, description breve

---

### 6.3 — Exámenes (`/Examenes`)

**Header de página:**
```
[H1: "Exámenes"] [right: Botón "Nuevo examen" primary con + icon]
[Descripción breve: "Gestiona tu banco de evaluaciones"]
```

**Barra de filtros:**
```
[🔍 Input buscar (placeholder: "Buscar por título...")] [Select: Estado ▾] [Select: Modalidad ▾] [Botón: Limpiar filtros ghost]
```
```css
display: flex; gap: 12px; align-items: center;
padding: 14px; background: var(--fondo-elevado-2);
border: 1px solid var(--borde-sutil); border-radius: var(--radio-lg);
margin-bottom: 20px;
```

**Tabla de exámenes:**

Columnas:
| Col | Contenido | Ancho |
|---|---|---|
| Título | Título + subtexto con descripción truncada | auto |
| Modalidad | Badge: DIGITAL o PAPEL | 140px |
| Preguntas | Número con ícono | 100px |
| Estado | `InsigniaEstado` | 120px |
| Creado | Fecha relativa | 140px |
| Acciones | Iconos: Ver, Editar, Duplicar, Eliminar | 120px |

**Empty state (sin exámenes):**
```
[Ícono grande — FileQuestion 64px, muy sutil]
"Sin exámenes todavía"
"Crea tu primer examen para comenzar a evaluar a tus estudiantes."
[Botón "Crear primer examen" primary]
```

---

### 6.4 — Detalle/Editor de Examen (`/Examenes/[idExamen]`)

**Layout:** Pantalla dividida verticalmente en dos partes

**Parte superior — Info del examen:**
```css
background: var(--fondo-elevado-2);
border: 1px solid var(--borde-sutil);
border-radius: var(--radio-xl);
padding: 24px;
display: flex; justify-content: space-between; align-items: flex-start;
```
- Izquierda: título (Syne 700, 22px) + descripción + row de badges (modalidad, estado, duración)
- Derecha: botones "Editar metadatos" + "Publicar examen" (si es borrador) / "Archivar"

**Parte inferior — `EditorPreguntas`:**

Header del editor:
```
"Preguntas" (14) [Badge con número]        [Botón "Agregar pregunta" primary]
"Arrastra para reordenar"  [texto-terciario, 12px]
```

**`TarjetaPregunta` (cada pregunta en la lista):**
```css
background: var(--fondo-elevado-2);
border: 1px solid var(--borde-sutil);
border-radius: var(--radio-lg);
padding: 16px 18px;
display: flex; align-items: flex-start; gap: 14px;
margin-bottom: 8px;
transition: var(--transicion-rapida);

/* Hover */
border-color: var(--borde-default);
background: var(--fondo-elevado-3);

/* Dragging (dnd-kit) */
box-shadow: var(--sombra-lg);
border-color: var(--acento-primario-borde);
background: var(--fondo-elevado-4);
transform: scale(1.02);
z-index: 99;
```

Layout interno de la tarjeta:
```
[⠿ Drag handle — 20px, gris, cursor: grab]  [Número #1 en mono]
[Tipo badge]  [Enunciado truncado a 2 líneas]
[right: puntaje pts] [right: iconos editar/eliminar]
```

**`FormularioPregunta` (dentro del Dialog):**

Estructura visual del Dialog: `min-width: 580px`

```
Paso indicador (si hay wizard): ─────────────────────
[Select: Tipo de pregunta  ▾ ]
[Textarea: Enunciado de la pregunta]
[Input: Puntaje]  [Input: Tiempo sugerido (s)]

─── Opciones de respuesta ───────────────────────────
  [○] [Input texto] [Trash]    ← opción 1
  [○] [Input texto] [Trash]    ← opción 2
  [+ Agregar opción]

[Cancelar]                      [Guardar pregunta]
```

Radio/checkbox de "correcta": cuando se selecciona, la fila entera se ilumina con `--estado-exito-sutil` y borde verde.

---

### 6.5 — Sesiones (`/Sesiones`)

Misma estructura que Exámenes pero con columnas ajustadas:

| Col | Contenido |
|---|---|
| Nombre sesión | Nombre + examen asociado (subtexto) |
| Código de acceso | `JetBrains Mono` bold, con botón copiar |
| Examen | Nombre del examen vinculado |
| Estado | Badge animado si ACTIVA |
| Estudiantes | X / Y conectados (barra de progreso mini) |
| Inicio | Fecha/hora |
| Acciones | Ver monitor, resultados, cancelar |

---

### 6.6 — Monitor en Tiempo Real (`/Sesiones/[idSesion]`)

Esta es la pantalla más crítica y premium.

**Header sticky:**
```
[← Volver]  "Monitor — [Nombre Sesión]"   [Badge ACTIVA con dot parpadeante]
             [Examen: Nombre del examen]    [Botón "Finalizar para todos" danger]
             
[Stat: 24 conectados]  [Stat: 0 alertas]  [Stat: Tiempo: 00:23:41]  [Stat: Promedio: 67%]
```

Los stats en el header son chips pequeños:
```css
background: var(--fondo-elevado-3);
border: 1px solid var(--borde-default);
border-radius: var(--radio-full);
padding: 6px 14px; font-size: 0.8rem;
```

**Grid de estudiantes:**
```css
display: grid;
grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
gap: 12px;
```

**`TarjetaEstudianteMonitor` — Especificación exacta:**
```css
background: var(--fondo-elevado-2);
border: 1px solid var(--borde-sutil);
border-radius: var(--radio-xl);
padding: 16px;
transition: var(--transicion-normal);
position: relative;

/* Si tiene alertas de fraude: */
border-color: var(--estado-peligro-borde);
background: linear-gradient(135deg, var(--fondo-elevado-2), rgba(239,68,68,0.05));
animation: alertaPulso 2s ease-in-out infinite;

@keyframes alertaPulso {
  0%,100% { box-shadow: 0 0 0 0 rgba(239,68,68,0); }
  50%      { box-shadow: 0 0 0 4px rgba(239,68,68,0.15); }
}
```

Layout interno de la tarjeta de estudiante:
```
Fila 1: [Avatar 40px] [Nombre]  [Badge: EN_PROGRESO/ENVIADO/ANULADO]
Fila 2: Barra de progreso:
         ████████░░░░  8/15 preguntas
         [texto: "8 de 15 respondidas"]
Fila 3: [Ícono escudo: verde (kiosco activo) | rojo (kiosco desactivado)]
         [Badge rojo contador fraudes si > 0]
```

**Avatar generado (sin img externa):**
```css
width: 40px; height: 40px; border-radius: 50%;
background: linear-gradient(135deg, [color basado en nombre], [variante oscura]);
display: flex; align-items: center; justify-content: center;
font-family: 'DM Sans'; font-weight: 600; font-size: 14px;
color: white;
/* colores generados deterministamente desde el nombre */
```

**Barra de progreso:**
```css
width: 100%; height: 5px;
background: var(--fondo-elevado-4);
border-radius: var(--radio-full);
overflow: hidden;
/* fill */
background: var(--gradiente-primario);
width: calc(var(--progreso) * 100%);
transition: width 0.5s ease;
```

**Panel lateral derecho — Historial de alertas (width: 300px):**
```css
background: var(--fondo-elevado-1);
border-left: 1px solid var(--borde-sutil);
height: calc(100vh - 56px);
overflow-y: auto; padding: 16px;
```

Cada `AlertaFraude`:
```css
background: var(--estado-peligro-sutil);
border: 1px solid var(--estado-peligro-borde);
border-radius: var(--radio-md);
padding: 10px 12px;
margin-bottom: 8px;
/* Animación de entrada: slideInRight */
animation: slideInRight 0.25s ease;
```
Contenido: nombre estudiante (bold) + tipo de evento en español + timestamp relativo

---

### 6.7 — Resultados de Sesión (`/Sesiones/[idSesion]/Resultados`)

**Layout de 3 secciones:**

**Sección 1 — Resumen visual:**
```
[Puntaje promedio — número grande Syne 800]  [Rango: distribución A-F visual]
4 stats en cards pequeñas: Promedio | Máximo | Mínimo | Tasa aprobación
```

**Sección 2 — Gráfica distribución (Recharts BarChart):**
- Eje X: rangos de puntaje (0-20, 20-40, 40-60, 60-80, 80-100)
- Eje Y: número de estudiantes
- Barras con gradiente azul

**Sección 3 — Gráfica dificultad por pregunta:**
- Eje X: preguntas (#1, #2, ...)
- Eje Y: % de respuestas correctas
- Línea de referencia al 50% (punteada)
- Barras: verde si >70%, amarillo si 40-70%, rojo si <40%

**Sección 4 — `TablaResultadosDetallada`:**
- Columnas: Estudiante | Puntaje | % | Tiempo | Estado | Alertas | Ver detalle
- Ordenable por cualquier columna (flechas ↑↓ en headers)

---

### 6.8 — Estudiantes (`/Estudiantes`)

Grid de cards en lugar de tabla (opción toggle tabla/grid):

**Vista grid (default):**
```css
display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 16px;
```

Cada card de estudiante:
```
[Avatar grande 56px — centered]
[Nombre completo — bold]
[Correo — texto-terciario, mono]
[Badge: rol]
[Última actividad — fecha relativa]
[Botón "Ver historial" — ghost, full width]
```

---

### 6.9 — Reportes (`/Reportes`)

**Filtros superiores:**
```
[Select: Período ▾]  [Select: Examen ▾]  [Select: Sesión ▾]  [Botón: Exportar PDF] [Botón: Exportar CSV]
```

Gráficas en `GraficaDistribucion`, `GraficaDificultadPreguntas` — mismas reglas que Resultados.

---

### 6.10 — Configuración (`/Configuracion`)

Layout: sidebar secundario interno + contenido

**Secciones:**
- Perfil — foto, nombre, correo, contraseña
- Preferencias — tema claro/oscuro, idioma
- Sistema — datos de la institución
- Seguridad — sesiones activas

---

## 7. ANIMACIONES Y MICRO-INTERACCIONES

### Entrada de página (Page Transitions)
```css
/* Contenedor principal de cada página */
animation: paginaEntrada 0.25s ease forwards;

@keyframes paginaEntrada {
  from { opacity: 0; transform: translateY(6px); }
  to   { opacity: 1; transform: translateY(0); }
}
```

### Listas con stagger (cuando cargan items)
```typescript
// Cada item de lista tiene un delay creciente
style={{ animationDelay: `${index * 0.04}s` }}
// Con animación: fadeInUp 0.2s ease forwards
```

### Skeletons de carga
```css
background: linear-gradient(
  90deg,
  var(--fondo-elevado-2) 25%,
  var(--fondo-elevado-3) 50%,
  var(--fondo-elevado-2) 75%
);
background-size: 200% 100%;
animation: shimmer 1.5s infinite;
border-radius: var(--radio-sm);

@keyframes shimmer {
  0%   { background-position: -200% 0; }
  100% { background-position:  200% 0; }
}
```
Los skeletons replican el layout exacto del contenido (no spinners genéricos).

### Toasts (Sonner)
```css
/* Configuración en layout.tsx */
<Toaster
  position="bottom-right"
  toastOptions={{
    style: {
      background: 'var(--fondo-elevado-3)',
      border: '1px solid var(--borde-fuerte)',
      color: 'var(--texto-primario)',
      borderRadius: 'var(--radio-lg)',
    }
  }}
  richColors  /* activa colores semánticos automáticos */
/>
```

### Drag and Drop (dnd-kit) — Feedback visual
- Handle: `cursor: grab`, cambia a `cursor: grabbing` mientras arrastra
- Overlay del elemento arrastrándose: `opacity: 0.9`, `box-shadow: var(--sombra-xl)`
- Gap de destino: línea azul `2px` animada que aparece donde caerá el elemento

### Command Palette (`Cmd+K`)
```css
/* Overlay */
backdrop-filter: blur(8px);
background: rgba(0,0,0,0.6);

/* Panel */
background: var(--fondo-elevado-2);
border: 1px solid var(--borde-fuerte);
border-radius: var(--radio-2xl);
box-shadow: var(--sombra-xl);
width: 560px; max-height: 480px;
/* Input siempre enfocado, resultados con scroll */
animation: scaleIn 0.18s cubic-bezier(0.34, 1.56, 0.64, 1);
```

---

## 8. ICONOGRAFÍA

**Biblioteca exclusiva:** `lucide-react` — Ningún otro set de iconos.

**Tamaños estándar:**
- Navegación sidebar: `18px`
- Acciones en tabla: `15px`
- Botones con icono: `16px`
- Métricas/display: `24px`
- Empty states: `48px` con `color: var(--texto-terciario)`
- Alertas críticas: `20px`

**Siempre usar `strokeWidth={1.5}`** — el default de Lucide (2) es demasiado grueso para este estilo.

**Iconos por sección:**
```
Tablero:     LayoutDashboard
Exámenes:    FileText
Sesiones:    Play / MonitorPlay
Estudiantes: Users
Reportes:    BarChart2
Configuración: Settings2
Cerrar sesión: LogOut
Alertas:     AlertTriangle (rojo)
Fraude:      ShieldAlert (rojo)
Kiosco activo: ShieldCheck (verde)
Arrastar:    GripVertical
Agregar:     Plus
Editar:      Pencil
Eliminar:    Trash2
Ver:         Eye
Copiar:      Copy
Buscar:      Search
Filtrar:     SlidersHorizontal
Exportar:    Download
```

---

## 9. RESPONSIVE Y BREAKPOINTS

```css
/* Tailwind breakpoints en uso */
sm:  640px   /* Tablets pequeñas — sidebar colapsado por defecto */
md:  768px   /* Tablets */
lg:  1024px  /* Desktop mínimo */
xl:  1280px  /* Desktop estándar */
2xl: 1536px  /* Desktop grande */
```

**Comportamiento responsive:**
- `< 1024px`: sidebar colapsado por defecto, hamburger en header
- `< 768px`: app muestra aviso "Optimizado para desktop" (no soporte móvil en admin)
- Tablas en `< 1024px`: columnas secundarias ocultas con `hidden lg:table-cell`
- Grids: `grid-cols-1` → `grid-cols-2` → `grid-cols-4` según breakpoint
- Monitor de sesión en `< 1280px`: panel de alertas colapsable en drawer

---

## 10. ACCESIBILIDAD — REGLAS NO NEGOCIABLES

- Todo elemento interactivo tiene `focus-visible` con `box-shadow: var(--sombra-glow-primario)`
- Contraste mínimo `4.5:1` para texto normal, `3:1` para texto grande
- Todos los iconos solos tienen `aria-label` o están decorativos con `aria-hidden`
- Modales gestionan `focus trap` correctamente
- Tablas tienen `caption` y `scope` en headers
- Formularios: cada input tiene `id` + `htmlFor` en label
- Animaciones respetan `prefers-reduced-motion`:
```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

## 11. CÓDIGO — REGLAS DE IMPLEMENTACIÓN

### globals.css — Estilos base obligatorios

```css
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
html { font-size: 16px; scroll-behavior: smooth; }
body {
  font-family: 'DM Sans', sans-serif;
  background: var(--fondo-raiz);
  color: var(--texto-primario);
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
::-webkit-scrollbar { width: 6px; height: 6px; }
::-webkit-scrollbar-track { background: transparent; }
::-webkit-scrollbar-thumb { background: var(--borde-fuerte); border-radius: 3px; }
::-webkit-scrollbar-thumb:hover { background: var(--borde-interactivo); }
::selection { background: var(--acento-primario-sutil); color: var(--texto-primario); }
```

### tailwind.config.ts — Extensión requerida

```typescript
// Extender con las variables CSS del sistema de color
// NO hardcodear valores, referenciar siempre var(--...)
// Agregar en theme.extend.colors: todas las variables como referencias CSS
// Agregar en theme.extend.fontFamily: fuenteDisplay, fuenteUI, fuenteMono
// Agregar en theme.extend.animation: todos los keyframes definidos
// Agregar en theme.extend.boxShadow: sombra-azul, sombra-glow-primario
```

### Orden de className en Tailwind

```
1. Layout (flex, grid, block...)
2. Dimensiones (w-, h-, min-w-...)
3. Espaciado (p-, m-, gap-...)
4. Posición (absolute, relative, top-, z-...)
5. Fondo/borde (bg-, border-, rounded-...)
6. Tipografía (text-, font-, tracking-...)
7. Efectos (shadow-, opacity-, backdrop-...)
8. Interactivo (hover:, focus:, cursor-...)
9. Responsive (sm:, md:, lg:...)
```

---

## 12. PATRONES PROHIBIDOS DE DISEÑO

1. ❌ Fondo completamente blanco o completamente negro puro (#000)
2. ❌ Colores primarios brillantes hardcodeados (solo variables CSS)
3. ❌ Gradientes de arcoíris o multi-color no especificados en este doc
4. ❌ Bordes gruesos (>1px) salvo excepciones explícitas
5. ❌ Sombras de color sólido (todas con transparencia rgba)
6. ❌ Texto sin suficiente contraste sobre fondos de color
7. ❌ Animaciones que duren más de 400ms (salvo loaders continuos)
8. ❌ Más de 3 niveles de jerarquía visual en una sola card
9. ❌ Iconos mezclados de diferentes familias (solo lucide-react)
10. ❌ Fuentes no especificadas en este documento
11. ❌ Spinners de carga genéricos (siempre skeletons que repliquen el layout)
12. ❌ Tablas sin estados hover definidos
13. ❌ Botones sin estados focus, hover, active y disabled
14. ❌ Modales sin animación de entrada
15. ❌ Colores semánticos para usos no semánticos (rojo para decoración, etc.)
16. ❌ Espaciados inconsistentes con la escala de 4px (usar múltiplos de 4: 4,8,12,16,20,24...)
17. ❌ Texto en mayúsculas salvo labels de tabla y separadores de sidebar
18. ❌ Más de 2 fuentes en pantalla simultáneamente

---

## 13. CHECKLIST DE CALIDAD — ANTES DE COMMIT

Todo componente debe pasar esta verificación:

- [ ] ¿Usa solo variables CSS del sistema de color? No colores hardcodeados.
- [ ] ¿Tiene estado hover definido (si es interactivo)?
- [ ] ¿Tiene estado focus-visible accesible?
- [ ] ¿Tiene estado disabled si aplica?
- [ ] ¿Tiene skeleton de carga o `Cargando.tsx` mientras espera datos?
- [ ] ¿Tiene `EstadoVacio.tsx` si la lista puede estar vacía?
- [ ] ¿Usa `Syne` para títulos y `DM Sans` para body?
- [ ] ¿Los datos numéricos importantes usan `JetBrains Mono`?
- [ ] ¿Los iconos usan `strokeWidth={1.5}`?
- [ ] ¿Las transiciones usan las variables `--transicion-*`?
- [ ] ¿Los bordes usan las variables `--borde-*`?
- [ ] ¿Los border-radius usan las variables `--radio-*`?
- [ ] ¿Las sombras usan las variables `--sombra-*`?
- [ ] ¿Respeta `prefers-reduced-motion`?
- [ ] ¿Las animaciones tienen duración ≤ 400ms?
- [ ] ¿El componente es legible en viewport `1280px` de ancho?