# Frontend/AGENTS.md — EvalPro Mobile: Diseño UI/UX Premium Nativo Definitivo
> **Versión:** 1.0.0 — 2026-03-03
> **Stack:** Flutter 3.x · Material 3 · Riverpod · GoRouter
> **Propósito:** Especificación exacta de diseño, estructura de componentes, posiciones,
> estilos y UX para cada pantalla. El agente debe leer este archivo COMPLETO antes de
> escribir una sola línea de código. No existe decisión de diseño fuera de este documento.

---

## 🧠 FILOSOFÍA DE DISEÑO — LEER ANTES DE EMPEZAR

EvalPro Mobile **NO es una app de estudiantes genérica**. Es una herramienta profesional
de evaluación académica. El diseño debe transmitir:

- **Confianza institucional**: como una app bancaria o de salud — seria, precisa, segura.
- **Claridad absoluta**: en el examen, el estudiante no debe dudar qué hacer nunca.
- **Natividad total**: cada gesto, transición, componente debe sentirse como si Apple o
  Google lo hubieran diseñado. Cero sensación de WebView.
- **Elegancia sin exageración**: limpio, moderno, fresco. No gamificado, no infantil,
  no corporativo rígido. El punto medio entre Linear.app y la app de Salud de iOS.

**Referentes visuales:**
- Estructura: Apple Health App, Linear.app, Notion Mobile
- Tipografía y espacio: Craft App, Bear Notes
- Cards y elevación: iOS nativo 17+
- Color: Monochromatic base + 1 accent vibrante

---

## 1. SISTEMA DE DISEÑO GLOBAL

### 1.1 Paleta de Colores — Implementar en `app_colors.dart`

```dart
// REGLA: Nunca hardcodear un color en un widget.
// Siempre usar AppColors.xxx o Theme.of(context).colorScheme.xxx

class AppColors {
  // ── PRIMARIO ──────────────────────────────────────────────
  // Azul índigo profundo — transmite confianza, seriedad, institución
  static const primary = Color(0xFF2563EB);       // blue-600
  static const primaryLight = Color(0xFF3B82F6);  // blue-500
  static const primaryDark = Color(0xFF1D4ED8);   // blue-700
  static const primarySurface = Color(0xFFEFF6FF); // blue-50
  static const primaryBorder = Color(0xFFBFDBFE);  // blue-200

  // ── NEUTROS BASE ─────────────────────────────────────────
  // Slate (no gray puro — más vivo y moderno)
  static const slate50  = Color(0xFFF8FAFC);
  static const slate100 = Color(0xFFF1F5F9);
  static const slate200 = Color(0xFFE2E8F0);
  static const slate300 = Color(0xFFCBD5E1);
  static const slate400 = Color(0xFF94A3B8);
  static const slate500 = Color(0xFF64748B);
  static const slate600 = Color(0xFF475569);
  static const slate700 = Color(0xFF334155);
  static const slate800 = Color(0xFF1E293B);
  static const slate900 = Color(0xFF0F172A);

  // ── SEMÁNTICOS ───────────────────────────────────────────
  static const success = Color(0xFF16A34A);       // green-600
  static const successSurface = Color(0xFFF0FDF4);
  static const successBorder = Color(0xFFBBF7D0);

  static const warning = Color(0xFFD97706);       // amber-600
  static const warningSurface = Color(0xFFFFFBEB);
  static const warningBorder = Color(0xFFFDE68A);

  static const error = Color(0xFFDC2626);         // red-600
  static const errorSurface = Color(0xFFFEF2F2);
  static const errorBorder = Color(0xFFFECACA);

  static const info = Color(0xFF0891B2);          // cyan-600
  static const infoSurface = Color(0xFFECFEFF);

  // ── MODO EXAMEN (Especial) ────────────────────────────────
  // Cuando el estudiante está EN un examen, la UI cambia a este sistema
  static const examPrimary = Color(0xFF1E293B);   // slate-800 — fondo de examen
  static const examSurface = Color(0xFF0F172A);   // slate-900
  static const examAccent = Color(0xFF3B82F6);    // blue-500
  static const examCard = Color(0xFF1E293B);
  static const examText = Color(0xFFF8FAFC);
  static const examTextSecondary = Color(0xFF94A3B8);
  static const examSelected = Color(0xFF1D4ED8);
  static const examSelectedBorder = Color(0xFF3B82F6);
  static const examCorrect = Color(0xFF16A34A);
  static const examIncorrect = Color(0xFFDC2626);

  // ── LIGHT THEME ──────────────────────────────────────────
  static const background = slate50;              // Fondo general app
  static const surface = Color(0xFFFFFFFF);       // Cards, sheets
  static const surfaceVariant = slate100;         // Chips, badges, alt cards
  static const onSurface = slate900;
  static const onSurfaceVariant = slate500;
  static const divider = slate200;
  static const border = slate200;
  static const borderFocused = primary;

  // ── DARK THEME ───────────────────────────────────────────
  static const darkBackground = Color(0xFF09090B);  // zinc-950
  static const darkSurface = Color(0xFF18181B);     // zinc-900
  static const darkSurfaceVariant = Color(0xFF27272A); // zinc-800
  static const darkOnSurface = Color(0xFFFAFAFA);
  static const darkBorder = Color(0xFF3F3F46);      // zinc-700
}
```

### 1.2 Tipografía — Implementar en `app_typography.dart`

```dart
// FUENTE ELEGIDA: Plus Jakarta Sans
// - Moderna, geométrica, muy legible en pantallas pequeñas
// - Excelente en pesos ligeros y bold — da personalidad sin ser llamativa
// - Se siente premium e institucional simultáneamente
// Importar via google_fonts: GoogleFonts.plusJakartaSans()

class AppTypography {
  static TextTheme get textTheme => TextTheme(
    // DISPLAY — Solo para splash y números grandes de resultados
    displayLarge: GoogleFonts.plusJakartaSans(
      fontSize: 48, fontWeight: FontWeight.w700,
      letterSpacing: -1.5, height: 1.1, color: AppColors.slate900,
    ),
    displayMedium: GoogleFonts.plusJakartaSans(
      fontSize: 36, fontWeight: FontWeight.w700,
      letterSpacing: -1.0, height: 1.15, color: AppColors.slate900,
    ),
    displaySmall: GoogleFonts.plusJakartaSans(
      fontSize: 28, fontWeight: FontWeight.w700,
      letterSpacing: -0.5, height: 1.2, color: AppColors.slate900,
    ),

    // HEADLINE — Títulos de sección y pantallas
    headlineLarge: GoogleFonts.plusJakartaSans(
      fontSize: 24, fontWeight: FontWeight.w700,
      letterSpacing: -0.5, height: 1.25, color: AppColors.slate900,
    ),
    headlineMedium: GoogleFonts.plusJakartaSans(
      fontSize: 20, fontWeight: FontWeight.w600,
      letterSpacing: -0.3, height: 1.3, color: AppColors.slate900,
    ),
    headlineSmall: GoogleFonts.plusJakartaSans(
      fontSize: 18, fontWeight: FontWeight.w600,
      letterSpacing: -0.2, height: 1.3, color: AppColors.slate900,
    ),

    // TITLE — Headers de cards y list items
    titleLarge: GoogleFonts.plusJakartaSans(
      fontSize: 16, fontWeight: FontWeight.w600,
      letterSpacing: -0.1, height: 1.4, color: AppColors.slate900,
    ),
    titleMedium: GoogleFonts.plusJakartaSans(
      fontSize: 15, fontWeight: FontWeight.w500,
      letterSpacing: 0, height: 1.4, color: AppColors.slate900,
    ),
    titleSmall: GoogleFonts.plusJakartaSans(
      fontSize: 13, fontWeight: FontWeight.w600,
      letterSpacing: 0.1, height: 1.4, color: AppColors.slate600,
    ),

    // BODY — Contenido principal y enunciados de preguntas
    bodyLarge: GoogleFonts.plusJakartaSans(
      fontSize: 16, fontWeight: FontWeight.w400,
      letterSpacing: 0, height: 1.6, color: AppColors.slate800,
    ),
    bodyMedium: GoogleFonts.plusJakartaSans(
      fontSize: 14, fontWeight: FontWeight.w400,
      letterSpacing: 0, height: 1.5, color: AppColors.slate700,
    ),
    bodySmall: GoogleFonts.plusJakartaSans(
      fontSize: 12, fontWeight: FontWeight.w400,
      letterSpacing: 0, height: 1.5, color: AppColors.slate500,
    ),

    // LABEL — Botones, chips, captions, badges
    labelLarge: GoogleFonts.plusJakartaSans(
      fontSize: 15, fontWeight: FontWeight.w600,
      letterSpacing: 0, height: 1.2, color: AppColors.slate900,
    ),
    labelMedium: GoogleFonts.plusJakartaSans(
      fontSize: 12, fontWeight: FontWeight.w600,
      letterSpacing: 0.3, height: 1.2, color: AppColors.slate600,
    ),
    labelSmall: GoogleFonts.plusJakartaSans(
      fontSize: 11, fontWeight: FontWeight.w500,
      letterSpacing: 0.5, height: 1.2, color: AppColors.slate500,
    ),
  );
}
```

### 1.3 Espaciado y Radios — Implementar en `app_spacing.dart`

```dart
class AppSpacing {
  // Grid base: 4px
  static const xs   = 4.0;
  static const sm   = 8.0;
  static const md   = 12.0;
  static const base = 16.0;
  static const lg   = 20.0;
  static const xl   = 24.0;
  static const xl2  = 32.0;
  static const xl3  = 40.0;
  static const xl4  = 48.0;
  static const xl5  = 64.0;

  // Padding de pantallas
  static const screenH = 16.0;  // horizontal
  static const screenV = 20.0;  // vertical

  // Radios de borde
  static const radiusXs  = 6.0;
  static const radiusSm  = 10.0;
  static const radiusMd  = 14.0;
  static const radiusLg  = 18.0;
  static const radiusXl  = 24.0;
  static const radiusFull = 999.0;

  // Elevación / sombras
  static List<BoxShadow> get shadowSm => [
    BoxShadow(color: AppColors.slate900.withOpacity(0.04), blurRadius: 4, offset: Offset(0, 1)),
    BoxShadow(color: AppColors.slate900.withOpacity(0.03), blurRadius: 2, offset: Offset(0, 0)),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(color: AppColors.slate900.withOpacity(0.08), blurRadius: 12, offset: Offset(0, 4)),
    BoxShadow(color: AppColors.slate900.withOpacity(0.04), blurRadius: 4, offset: Offset(0, 1)),
  ];

  static List<BoxShadow> get shadowLg => [
    BoxShadow(color: AppColors.slate900.withOpacity(0.12), blurRadius: 24, offset: Offset(0, 8)),
    BoxShadow(color: AppColors.slate900.withOpacity(0.06), blurRadius: 8, offset: Offset(0, 2)),
  ];

  static List<BoxShadow> get shadowXl => [
    BoxShadow(color: AppColors.slate900.withOpacity(0.16), blurRadius: 48, offset: Offset(0, 16)),
    BoxShadow(color: AppColors.slate900.withOpacity(0.08), blurRadius: 12, offset: Offset(0, 4)),
  ];

  // Sombra azul para botones primarios
  static List<BoxShadow> get shadowPrimary => [
    BoxShadow(color: AppColors.primary.withOpacity(0.30), blurRadius: 16, offset: Offset(0, 6)),
    BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 4, offset: Offset(0, 1)),
  ];
}
```

### 1.4 ThemeData Completo — `app_theme.dart`

```dart
ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primarySurface,
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.slate700,
    onSecondary: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.slate900,
    surfaceContainerHighest: AppColors.slate100,
    onSurfaceVariant: AppColors.slate500,
    outline: AppColors.slate200,
    outlineVariant: AppColors.slate100,
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: AppColors.errorSurface,
    shadow: AppColors.slate900.withOpacity(0.08),
    scrim: AppColors.slate900.withOpacity(0.40),
  ),
  scaffoldBackgroundColor: AppColors.background,
  textTheme: AppTypography.textTheme,
  
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.background,
    foregroundColor: AppColors.slate900,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    titleTextStyle: GoogleFonts.plusJakartaSans(
      fontSize: 17, fontWeight: FontWeight.w700,
      color: AppColors.slate900, letterSpacing: -0.3,
    ),
    iconTheme: IconThemeData(color: AppColors.slate700, size: 22),
    actionsIconTheme: IconThemeData(color: AppColors.slate700, size: 22),
    systemOverlayStyle: SystemUiOverlayStyle.dark,
  ),

  cardTheme: CardTheme(
    color: AppColors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      side: BorderSide(color: AppColors.slate200, width: 1),
    ),
    margin: EdgeInsets.zero,
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      borderSide: BorderSide(color: AppColors.slate200, width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      borderSide: BorderSide(color: AppColors.slate200, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      borderSide: BorderSide(color: AppColors.error, width: 1.5),
    ),
    labelStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.slate500),
    hintStyle: GoogleFonts.plusJakartaSans(fontSize: 15, color: AppColors.slate400),
    errorStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.error),
    floatingLabelBehavior: FloatingLabelBehavior.auto,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
      textStyle: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600),
      minimumSize: Size(double.infinity, 52),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: BorderSide(color: AppColors.slate200, width: 1.5),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
      textStyle: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600),
      minimumSize: Size(double.infinity, 52),
    ),
  ),

  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: AppColors.surface,
    indicatorColor: AppColors.primarySurface,
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected))
        return IconThemeData(color: AppColors.primary, size: 22);
      return IconThemeData(color: AppColors.slate400, size: 22);
    }),
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected))
        return GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary);
      return GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.slate400);
    }),
    height: 72,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    shadowColor: AppColors.slate900.withOpacity(0.08),
  ),

  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
    ),
    elevation: 0,
    showDragHandle: true,
    dragHandleColor: AppColors.slate300,
    dragHandleSize: Size(36, 4),
  ),

  chipTheme: ChipThemeData(
    backgroundColor: AppColors.slate100,
    selectedColor: AppColors.primarySurface,
    labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w500),
    side: BorderSide(color: AppColors.slate200),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusFull)),
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  ),

  dividerTheme: DividerThemeData(color: AppColors.slate100, thickness: 1, space: 0),

  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: AppColors.slate900,
    contentTextStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.white),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
    insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
);
```

---

## 2. COMPONENTES COMUNES — LIBRERÍA COMPLETA

### 2.1 `EvalButton` — Reemplaza TODOS los botones

```
VARIANTES VISUALES EXACTAS:

┌─ filled (primario CTA) ──────────────────────────────────┐
│  Fondo: primary (#2563EB)                                │
│  Texto: blanco, 15px, w600                               │
│  Sombra: shadowPrimary (azul difuminado debajo)          │
│  Borde: ninguno                                          │
│  Height: 52px, width: 100%                               │
│  Radius: 10px                                            │
│  Press: scale 0.97 + reduce sombra (100ms)               │
│  Loading: SizedBox(16x16) CircularProgressIndicator      │
│           strokeWidth 2, color blanco                    │
│  Disabled: opacity 0.45, sin sombra                      │
└──────────────────────────────────────────────────────────┘

┌─ outlined (secundario) ──────────────────────────────────┐
│  Fondo: transparente / blanco                            │
│  Borde: 1.5px slate-200                                  │
│  Texto: primary, 15px, w600                              │
│  Height: 52px                                            │
│  Press: scale 0.97 + fondo slate-50 (80ms)               │
└──────────────────────────────────────────────────────────┘

┌─ ghost (terciario) ──────────────────────────────────────┐
│  Fondo: transparente                                     │
│  Texto: primary, 15px, w600                              │
│  Sin borde ni sombra                                     │
│  Press: fondo primarySurface (80ms)                      │
└──────────────────────────────────────────────────────────┘

┌─ destructive (peligro) ──────────────────────────────────┐
│  Fondo: errorSurface (#FEF2F2)                           │
│  Texto: error (#DC2626), 15px, w600                      │
│  Borde: 1.5px errorBorder                                │
│  Press: fondo error + texto blanco (150ms)               │
└──────────────────────────────────────────────────────────┘

┌─ small (acción compacta) ────────────────────────────────┐
│  Height: 36px, padding horizontal: 16px                  │
│  Texto: 13px, w600                                       │
│  Radius: 8px                                             │
└──────────────────────────────────────────────────────────┘

HAPTIC: HapticFeedback.lightImpact() en cada tap.
```

### 2.2 `EvalTextField` — Todos los inputs

```
ESTADO NORMAL:
┌────────────────────────────────────────────────┐
│  Label: 14px, slate-500, flota al focus        │
│  Input text: 15px, slate-900                   │
│  Borde: 1.5px slate-200, radius 10             │
│  Fondo: blanco                                 │
└────────────────────────────────────────────────┘

ESTADO FOCUS:
┌────────────────────────────────────────────────┐
│  Borde: 2px primary (#2563EB)                  │
│  Label: sube y toma color primary              │
│  Transición: 200ms ease                        │
└────────────────────────────────────────────────┘

ESTADO ERROR:
┌────────────────────────────────────────────────┐
│  Borde: 1.5px error                            │
│  Label: color error                            │
│  Error msg: slide-down + fade, 12px, error     │
│  Icono ⚠ en suffix                             │
└────────────────────────────────────────────────┘

ESTADO DISABLED:
  Fondo: slate-50, borde slate-100, texto slate-300

PASSWORD FIELD:
  Suffix: IconButton ojo (visibility/visibility_off)
  Animación: CrossFade entre iconos (150ms)
```

### 2.3 `EvalCard` — Contenedor estándar

```
┌────────────────────────────────────────────┐
│  Fondo: blanco                              │
│  Borde: 1px slate-200                       │
│  Radius: 14px                               │
│  Sombra: shadowSm (muy sutil)               │
│  Padding interno: 16px                      │
│  Con onTap:                                 │
│    - InkWell con splash primarySurface      │
│    - Press: scale 0.99 (100ms)             │
│    - Hover: borde primaryBorder             │
└────────────────────────────────────────────┘
```

### 2.4 `EvalBadge` — Estado y contadores

```
Variantes:
- primary:  fondo primarySurface, texto primary, borde primaryBorder
- success:  fondo successSurface, texto success
- warning:  fondo warningSurface, texto warning
- error:    fondo errorSurface, texto error
- neutral:  fondo slate-100, texto slate-600

Tamaño: padding 6x12, radius full, texto 11px w600 uppercase
```

### 2.5 `EvalShimmer` — Skeleton loading

```
Base: LinearGradient animado slate-200 → slate-100 → slate-200
Duración ciclo: 1.2s, curva: Curves.easeInOut
Shapes:
  ShimmerLine(width, height): rect redondeado radius 4
  ShimmerCircle(size): círculo
  ShimmerCard(height): card completa
```

### 2.6 `EvalEmptyState` — Pantalla sin datos

```
┌─────────────────────────────────────────┐
│           [Ícono 64x64]                 │
│           slate-300                     │
│                                         │
│         Título 18px w600                │
│         slate-700                       │
│                                         │
│     Subtítulo 14px slate-500            │
│     máx 2 líneas, centrado              │
│                                         │
│     [EvalButton ghost si aplica]        │
└─────────────────────────────────────────┘

Animación de entrada: FadeIn + TranslateY(+16→0) 400ms
```

### 2.7 `EvalErrorState` — Error de red/servidor

```
┌─────────────────────────────────────────┐
│      Ícono ⚡ o 📡 — errorSurface       │
│      56x56, circulo                     │
│                                         │
│      "Algo salió mal" 18px w600         │
│      Descripción error 14px slate-500   │
│                                         │
│      [Reintentar] — EvalButton outlined │
└─────────────────────────────────────────┘
```

### 2.8 `EvalAvatar`

```
Size: sm=32, md=40, lg=56, xl=72
Fondo si sin imagen: initiales sobre gradient (primary → primaryDark)
Border: 2px blanco + sombra shadowSm
Status dot: 8px, verde=activo, gris=offline — posición bottomRight
```

### 2.9 `ConnectivityBanner` — Estado sin internet

```
Posición: Top del Scaffold, bajo AppBar
Altura: 36px
Fondo: error
Texto: "Sin conexión · Reconectando..." 12px blanco w600
Ícono: wifi_off 14px blanco
Animación: slide-down desde -36px (300ms) / slide-up al recuperar (250ms)
```

---

## 3. NAVEGACIÓN Y ESTRUCTURA

### 3.1 Bottom Navigation — Solo para ESTUDIANTE

```
NavigationBar (Material 3) — 4 tabs:

┌─────────────────────────────────────────────────────┐
│                                                     │
│  [🏠 Inicio] [📋 Mis Exámenes] [📊 Resultados] [👤 Perfil] │
│                                                     │
└─────────────────────────────────────────────────────┘

- Fondo: blanco con top border 1px slate-200
- Indicador activo: pill shape 58x28, fondo primarySurface
- Ícono activo: primary color
- Ícono inactivo: slate-400
- Label siempre visible, 11px
- Haptic: selectionClick() en cada switch
- Borde superior: Divider 1px slate-200 (no shadow)
```

### 3.2 Sidebar/Drawer — Para DOCENTE y ADMINISTRADOR

```
Drawer (desde izquierda, 300px ancho):

HEADER (160px):
┌──────────────────────────────────────────┐
│  Fondo: gradient primary → primaryDark   │
│  Avatar 56px (top: 40px, left: 20px)    │
│  Nombre: 18px w700 blanco               │
│  Rol badge: 12px blanco/70%             │
│  Institución: 13px blanco/60%           │
└──────────────────────────────────────────┘

MENÚ ITEMS (56px cada uno):
  Ícono 22px slate-600 + Label 15px w500 slate-800
  Activo: fondo primarySurface, ícono primary, texto primary w600
  Radius: 10px, margin horizontal 8px
  
ITEMS DOCENTE:
  📋 Mis Exámenes
  📅 Sesiones
  👥 Mis Grupos
  📊 Reportes
  ─ divider ─
  ⚙️ Configuración

ITEMS ADMINISTRADOR:
  🏛 Dashboard
  👤 Usuarios
  👥 Grupos
  📋 Exámenes
  📊 Reportes
  ─ divider ─
  ⚙️ Configuración

FOOTER (absoluto bottom 32px):
  Avatar pequeño + nombre + "Cerrar sesión" ghost rojo
```

### 3.3 Page Transitions — Obligatorio en GoRouter

```dart
// Todas las rutas usan CustomTransitionPage:

// Drill-down (lista → detalle):
SharedAxisTransition(animation: animation, fillColor: Colors.white,
  transitionType: SharedAxisTransitionType.horizontal)

// Modales y bottom-up:
SharedAxisTransition(transitionType: SharedAxisTransitionType.vertical)

// Tab switching:
FadeThroughTransition(animation: animation, fillColor: AppColors.background)

// NUNCA usar el default PageRoute que hace slide-over total
```

---

## 4. PANTALLAS — ESPECIFICACIÓN EXACTA

---

### 4.1 SPLASH SCREEN

```
Duración total: 2.0s máx
Fondo: blanco

SECUENCIA DE ANIMACIÓN (timeline):
  0ms:    Pantalla completamente blanca
  100ms:  Logo aparece — scale(0.6→1.0) + fade(0→1), 600ms, Curves.elasticOut
  700ms:  Nombre app aparece — fade(0→1) + translateY(8→0), 400ms
  900ms:  Tagline aparece — fade(0→1), 300ms, color slate-400
  1200ms: INICIO de verificación de auth en background
  1800ms: Si auth listo: begin exit fade(1→0) 200ms → navigate
          Si auth demora: spinner subtle 20px primary bajo el logo

LAYOUT:
  Centro absoluto de pantalla:
  ┌─────────────────────────────┐
  │                             │
  │       [LOGO 80x80]          │
  │                             │
  │    EvalPro   (24px w700)    │
  │   Tu plataforma de         │
  │   evaluación académica      │
  │   (14px slate-400)          │
  │                             │
  │   [spinner si demora]       │
  │                             │
  └─────────────────────────────┘

  BOTTOM (fijo): "v1.0.0" — 12px slate-400, center
```

---

### 4.2 LOGIN SCREEN

```
Fondo: background (slate-50)
SafeArea + SingleChildScrollView + KeyboardAwareScrollView

LAYOUT (top → bottom):

1. AppBar transparente, sin título, botón atrás solo si aplica

2. HEADER SECTION (paddingTop: 48px, paddingH: 24px):
   ┌─────────────────────────────────────────┐
   │  Logo 48x48 (izquierda)                 │
   │  EvalPro — 28px w700 slate-900          │
   │  "Ingresa a tu cuenta" — 16px slate-500 │
   └─────────────────────────────────────────┘

3. FORM CARD (margin: 24px, padding: 24px, EvalCard):
   ┌─────────────────────────────────────────┐
   │  [EvalTextField: Correo electrónico]    │
   │  spacing: 16px                          │
   │  [EvalTextField: Contraseña (password)] │
   │  spacing: 12px                          │
   │  "¿Olvidaste tu contraseña?"           │
   │  → ghost button, derecha, 13px primary  │
   │  spacing: 24px                          │
   │  [EvalButton filled: "Iniciar sesión"]  │
   └─────────────────────────────────────────┘

4. ERROR MESSAGE (aparece sobre el botón si error server):
   EvalCard color errorSurface, borde errorBorder:
   ⚠ "Correo o contraseña incorrectos" — 14px error

5. FOOTER (bottom: 32px, center):
   "¿Primer acceso?" → "Usa tu credencial temporal"
   12px slate-500 → primary (tap para tooltip explicativo)

COMPORTAMIENTO:
- Keyboard: Scaffold.resizeToAvoidBottomInset=true
- Al hacer focus en contraseña: scroll para que el botón quede visible
- Submit on keyboard action "Listo" del último campo
- Shake animation en el card si error (translateX -8→+8→0, 300ms)
```

---

### 4.3 CAMBIO DE CONTRASEÑA (Primer Login)

```
LAYOUT:
1. AppBar: "Configura tu contraseña" — sin botón atrás (flujo obligatorio)

2. BANNER INFO (primarySurface, borde primaryBorder, radius 12, margin 24):
   ℹ️ "Por seguridad, debes establecer una contraseña personal."
   14px slate-700

3. FORM (padding 24px):
   [EvalTextField: Nueva contraseña] — con requisitos inline
   spacing 12px
   REQUISITOS (aparecen al focus):
   ┌────────────────────────────────────┐
   │ ✓ Mínimo 8 caracteres (verde si ok)│
   │ ✓ Una mayúscula                    │
   │ ✓ Un número                        │
   │ ✓ Un carácter especial             │
   └────────────────────────────────────┘
   Cada requisito: 12px, slate-300 → success (transición 150ms)
   spacing 16px
   [EvalTextField: Confirmar contraseña]
   spacing 32px
   [EvalButton: "Establecer contraseña"]
```

---

### 4.4 HOME — ESTUDIANTE

```
Estructura: CustomScrollView con Slivers

SLIVER APP BAR (expandedHeight: 160px):
┌─────────────────────────────────────────────────────┐
│  [collapsed: "EvalPro" + avatar icono] ← AppBar std │
│                                                     │
│  [expanded]:                                        │
│  Buenos días, [Nombre] 👋  — 22px w700             │
│  Institución · Periodo — 13px slate-500             │
│                                                     │
│  EvalAvatar xl derecha (absolute positioned)        │
└─────────────────────────────────────────────────────┘

SLIVER BODY (padding 16px):

SECCIÓN: "Sesión activa" (si existe):
  ┌─ EvalCard DESTACADA ───────────────────────────────┐
  │  Fondo: gradient(primary → primaryDark)            │
  │  Borde: ninguno                                    │
  │  BADGE: "● EN CURSO" — 11px w700 blanco/80%        │
  │  Título examen — 18px w700 blanco                  │
  │  Grupo · Docente — 13px blanco/70%                 │
  │  ──────────────────                                │
  │  ⏱ Tiempo restante: 00:45:23 (mono font, 24px)    │
  │  EvalButton small: "Continuar examen →" (blanco)   │
  └────────────────────────────────────────────────────┘
  Pulso suave en el badge: scale 1→1.1→1, 1.5s loop

SECCIÓN: "Próximas evaluaciones":
  Header: "Próximas evaluaciones" 16px w600 + "Ver todas →"
  Lista vertical de AsignacionCards (3 máx, luego "Ver todas"):

  AsignacionCard:
  ┌────────────────────────────────────────────────────┐
  │  [Ícono 40x40 redondeado, color según estado]     │
  │  Título examen — 15px w600                         │
  │  Grupo · Docente — 13px slate-500                 │
  │               ← spacer →    EvalBadge estado      │
  │  📅 "Abre en 2h" ó "Hasta las 15:30" — 12px       │
  └────────────────────────────────────────────────────┘
  Animación de entrada: staggered, delay 50ms/item

SECCIÓN: "Últimos resultados":
  Header: "Resultados recientes" 16px w600
  Lista horizontal scroll (ResultadoMiniCard):

  ResultadoMiniCard (160x100, EvalCard):
  ┌────────────────────────────────────────┐
  │  "Cálculo I" — 13px w600 (1 línea)    │
  │  ──────────────────────               │
  │  85%  (32px w700 primary)             │
  │  ──────────────────────               │
  │  EvalBadge estado resultado            │
  └────────────────────────────────────────┘
```

---

### 4.5 MIS EXÁMENES — ESTUDIANTE

```
AppBar: "Mis Evaluaciones" (Large title que colapsa)
Subheader sticky: Chips de filtro horizontal scroll:
  [Todas] [Pendientes] [En curso] [Completadas] [Próximas]
  Chip activo: primarySurface + borde primary + texto primary w600

LISTA (separación 8px entre items):

AsignacionListItem (EvalCard full-width):
┌──────────────────────────────────────────────────────┐
│  [Leading: ícono 44x44 redondeado gradient]          │
│                                                      │
│  Título examen — 16px w600 slate-900                 │
│  [Grupo] · [Docente] — 13px slate-500                │
│                                                      │
│  ──────────── fila inferior ──────────────           │
│  📅 fecha/hora apertura    [EvalBadge estado]        │
│  ⏱ Duración: 60 min       [chevron_right]           │
└──────────────────────────────────────────────────────┘

ESTADOS DE BADGE:
  PENDIENTE: neutral "Próximamente"
  ACTIVA con sesión abierta: success pulsante "Disponible"
  EN_PROGRESO: warning "En curso"
  ENVIADA: primary "Completada"
  SIN_SESION: neutral "Sin activar"

EMPTY STATE (si no hay evaluaciones):
  Ícono: clipboard_text 64px slate-200
  "No tienes evaluaciones asignadas"
  "Cuando tu docente asigne una evaluación, aparecerá aquí."

PULL TO REFRESH: RefreshIndicator color primary
```

---

### 4.6 DETALLE DE ASIGNACIÓN (Pre-examen)

```
AppBar: título del examen (truncado 1 línea), botón atrás

BODY (SingleChildScrollView, padding 20px):

CARD PRINCIPAL (EvalCard, padding 20px):
  ┌──────────────────────────────────────────────────┐
  │  BADGE estado (top right)                        │
  │                                                  │
  │  [Título examen] — 22px w700                    │
  │  [Materia/Grupo] — 14px slate-500               │
  │                                                  │
  │  DIVIDER                                         │
  │                                                  │
  │  GRID 2x2 INFO:                                  │
  │  ┌──────────────┬──────────────┐                 │
  │  │ ⏱ Duración  │ 📝 Preguntas │                 │
  │  │ 60 minutos  │ 20 preguntas │                 │
  │  ├──────────────┼──────────────┤                 │
  │  │ 🔄 Intentos  │ 📅 Cierra   │                 │
  │  │ 1 de 1      │ Hoy 18:00   │                 │
  │  └──────────────┴──────────────┘                 │
  │  Cada celda: label 11px slate-400 / valor 15px w600│
  └──────────────────────────────────────────────────┘

CARD INSTRUCCIONES (EvalCard, si existen):
  ┌──────────────────────────────────────────────────┐
  │  📋 "Instrucciones"  — 14px w600 slate-600       │
  │  [Texto instrucciones] — 15px bodyMedium         │
  └──────────────────────────────────────────────────┘

CARD MODO EXAMEN (EvalCard, fondo warningSurface):
  ┌──────────────────────────────────────────────────┐
  │  ⚠️ "Modo de protección activo"                  │
  │  Durante el examen:                              │
  │  • La app entrará en pantalla completa           │
  │  • No podrás cambiar de aplicación               │
  │  • Las capturas de pantalla quedarán bloqueadas  │
  │  • Salir contará como evento de riesgo           │
  └──────────────────────────────────────────────────┘

INPUT CÓDIGO SESIÓN:
  Label: "Código de sesión"
  EvalTextField — 6 chars, autoCapitalization, textAlign center
  Texto: 24px w700 letterSpacing 8px (tipo PIN)
  Placeholder: "------"
  Al completar 6 chars: auto-buscar sesión (feedback visual)

RESULTADO DE BÚSQUEDA:
  Si ok: EvalCard successSurface:
    ✅ "Sesión activa encontrada"
    Docente: [nombre] · [hora activación]
  Si error: EvalCard errorSurface:
    ❌ "Código inválido o sesión inactiva"

BOTTOM FIXED (SafeArea, padding 20px):
  [EvalButton filled: "Comenzar examen →"]
  Deshabilitado si: no hay código válido / ya se usaron intentos / fuera de ventana
  
  BAJO EL BOTÓN: texto legal pequeño
  "Al iniciar, aceptas las condiciones de evaluación de tu institución."
  11px slate-400, center
```

---

### 4.7 🔒 MODO EXAMEN — LA PANTALLA MÁS IMPORTANTE

```
═══════════════════════════════════════════════════════════════════════
PROTECCIÓN MÁXIMA — IMPLEMENTACIÓN OBLIGATORIA Y COMPLETA
═══════════════════════════════════════════════════════════════════════

ACTIVAR AL ENTRAR AL EXAMEN (en initState / onInit):

1. BLOQUEO DE SISTEMA:
   SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky)
   // Oculta status bar + navigation bar. Solo reaparece con deslizamiento.
   // Al reaparecer: re-ocultar automáticamente en 1s.

2. BLOQUEO DE CAPTURAS DE PANTALLA:
   FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE)
   // FLAG_SECURE en Android: bloquea screenshots + screen recording
   // iOS: usar isProtectedDataAvailable + SecureTextField trick
   // Paquete recomendado: flutter_windowmanager (Android) + 
   //                      screenshot_callback (detector)

3. BLOQUEO DE ORIENTACIÓN:
   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])

4. DETECCIÓN DE CAMBIO DE APP (AppLifecycleListener):
   AppLifecycleState.paused → ENVIAR EVENTO TELEMETRÍA: SEGUNDO_PLANO
   AppLifecycleState.resumed → ENVIAR EVENTO: FOCO_RECUPERADO
   Al detectar paused:
     - Mostrar overlay de advertencia al volver
     - Incrementar contador de salidas
     - Si contador >= 3: mostrar alerta crítica al estudiante

5. INTERCEPTAR BOTÓN ATRÁS:
   PopScope(canPop: false, onPopInvokedWithResult: (didPop, result) {
     if (!didPop) mostrarDialogConfirmarSalida();
   })
   // En Android 12+: PopScope maneja el gesto de back
   // NavigatorObserver adicional para seguridad

6. BLOQUEO MULTITAREA (Android):
   // Con FlutterWindowManager o método platform channel:
   // FLAG_SECURE también previene aparición en recent apps

7. KEEPSCREEN ON:
   wakelock_plus: WakelockPlus.enable()
   // Pantalla siempre encendida durante el examen

RESTAURAR AL SALIR DEL EXAMEN (en dispose):
   SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge)
   SystemChrome.setPreferredOrientations([]) // restaurar
   FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE)
   WakelockPlus.disable()

═══════════════════════════════════════════════════════════════════════
DISEÑO UI DEL EXAMEN — OSCURO, SERIO, ENFOCADO
═══════════════════════════════════════════════════════════════════════

TEMA DEL MODO EXAMEN:
  Fondo general: examSurface (#0F172A — negro azulado profundo)
  Fondo cards: examCard (#1E293B)
  Texto primario: examText (#F8FAFC)
  Texto secundario: examTextSecondary (#94A3B8)
  Accent: examAccent (#3B82F6)
  
  // El contraste oscuro reduce fatiga visual y da seriedad total
  // El estudiante entiende inmediatamente que está en "modo especial"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
LAYOUT COMPLETO PANTALLA EXAMEN:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

┌──────────────────────────────────────────────────────┐ ← top 0
│  EXAM HEADER (fijo, 60px, fondo examCard)            │
│  ┌──────────────────────────────────────────────┐   │
│  │ [←] Pregunta 3/20  ···  ⏱ 00:42:15 [!menu] │   │
│  └──────────────────────────────────────────────┘   │
│  ──────────────────────────── progress bar ──────── │
│  [████████░░░░░░░░░░░░░░░░░░░░░░░░] 15% primary     │
├──────────────────────────────────────────────────────┤
│                                                      │
│  QUESTION AREA (scrolleable, padding 20px):          │
│                                                      │
│  BADGE PREGUNTA:                                     │
│  [Pregunta 3 · Opción múltiple · 5 pts]              │
│  → EvalBadge neutral, 11px w600                     │
│                                                      │
│  ENUNCIADO:                                          │
│  Texto pregunta — 17px w500 examText                │
│  height: 1.65, selectable: false                    │
│  spacing: 28px                                       │
│                                                      │
│  OPCIONES (vertical list, spacing 10px):             │
│                                                      │
│  ┌─ OPCIÓN NO SELECCIONADA ───────────────────────┐  │
│  │  Fondo: examCard                               │  │
│  │  Borde: 1.5px slate-700                        │  │
│  │  Radius: 12px                                  │  │
│  │  Padding: 16px                                 │  │
│  │  ROW: [A] · Texto opción (15px examTextSecond)│  │
│  │  [A] = circle 28px, fondo slate-700, letra    │  │
│  │        12px w700 slate-400                     │  │
│  └────────────────────────────────────────────────┘  │
│                                                      │
│  ┌─ OPCIÓN SELECCIONADA ──────────────────────────┐  │
│  │  Fondo: examSelected (blue-800 oscuro)         │  │
│  │  Borde: 2px examSelectedBorder (blue-500)      │  │
│  │  [A] = circle fondo examAccent, letra blanca   │  │
│  │  Texto: examText (blanco)                      │  │
│  │  Animación: scale 0.97→1.0 + fade borde 150ms  │  │
│  └────────────────────────────────────────────────┘  │
│                                                      │
│  HapticFeedback.selectionClick() al seleccionar     │
│                                                      │
├──────────────────────────────────────────────────────┤
│  EXAM FOOTER (fijo, SafeArea, fondo examSurface)     │
│  ┌──────────────────────────────────────────────┐   │
│  │  [← Anterior]          [Siguiente →]         │   │
│  │  ghost exam / outlined  filled exam           │   │
│  │                                              │   │
│  │  EN ÚLTIMA PREGUNTA:                         │   │
│  │  [← Anterior]     [Enviar examen ✓]          │   │
│  │                   → color success            │   │
│  └──────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
NAVEGADOR DE PREGUNTAS (sheet inferior):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Activado por ícono "menú" en header.
DraggableScrollableSheet (initial: 0.55, max: 0.85):

Fondo: examCard, radius top 24px

GRID 5 columnas de QuestionDots:
  Respondida: fondo examAccent, número blanco
  Sin responder: fondo slate-700, número slate-400
  Actual: borde 2px examAccent, fondo examSelected
  Size: 44x44, radius 10px

BOTÓN INFERIOR: "Ir a la pregunta" — cuando tap en dot
BOTÓN "Enviar examen" — si todas respondidas, success color

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TIMER — COMPORTAMIENTO CRÍTICO:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  > 10 min restantes: texto examTextSecondary, normal
  5-10 min: texto warning (amber)
  1-5 min: texto error, leve pulso cada 60s
  < 1 min: texto error BOLD, pulso cada 10s
           HapticFeedback.mediumImpact() cada 30s
  00:00: auto-enviar intento + feedback visual

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OVERLAY DE ADVERTENCIA (al volver de otra app):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Aparece encima de todo cuando AppLifecycleState.resumed:
BackdropFilter blur(10) + fondo negro/70%

┌───────────────────────────────────────────────────┐
│              ⚠️ Salida detectada                   │
│                                                   │
│   Saliste de la aplicación durante el examen.     │
│   Esta acción ha sido registrada.                 │
│                                                   │
│   Salidas registradas: 1 de 3 permitidas          │
│   Al superar el límite, tu intento será           │
│   marcado para revisión.                          │
│                                                   │
│         [Entendido — Continuar examen]            │
└───────────────────────────────────────────────────┘
Fondo: examCard, radio 20, sombra xl
Botón: EvalButton filled examAccent
El timer SIGUE CORRIENDO durante este overlay.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DIALOG CONFIRMAR ENVÍO FINAL:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
BottomSheet (no Dialog para iOS nativo):
  Fondo: examCard, drag handle slate-600

  "¿Enviar examen?"
  "Respondiste 18 de 20 preguntas"
  "2 preguntas sin responder"

  LISTA sin responder (scroll si muchas):
  · Pregunta 5
  · Pregunta 12

  [Revisar preguntas] — outlined
  [Enviar de todas formas] — success filled

  Timer visible en el sheet también.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DIALOG CONFIRMAR SALIDA (back button):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
AlertDialog oscuro (fondo examCard):
  "¿Salir del examen?"
  "Tu progreso se guardará pero esta salida quedará registrada."
  
  [Cancelar] ghost / [Salir] destructive

  NUNCA permitir salida sin confirmación explícita.
```

---

### 4.8 RESULTADO POST-EXAMEN

```
Aparece inmediatamente si mostrarPuntajeInmediato=true,
o pantalla de espera si está pendiente calificación manual.

ANIMACIÓN DE ENTRADA (secuencia):
  0ms: fade in fondo blanco
  200ms: número del puntaje con count-up animation (0→85%)
         2.5s duración, ease-out
  700ms: elementos de detalle aparecen en stagger

LAYOUT:

HEADER RESULTADO (sin AppBar, fullscreen):
  Fondo: gradient según resultado:
    ≥ 70%: gradient(successSurface → blanco)
    40-69%: gradient(warningSurface → blanco)
    < 40%: gradient(errorSurface → blanco)

  ┌──────────────────────────────────────────────┐
  │  Ícono grande animado (checkmark/warning/X)  │
  │  Lottie animation, 80x80                     │
  │                                              │
  │  [PUNTAJE TOTAL]  CountUpText                │
  │  85%   — displayMedium 56px w700             │
  │  "de 100 puntos posibles"  — 14px slate-500  │
  │                                              │
  │  EvalBadge grande (APROBADO/REVISAR/REPROBADO)│
  └──────────────────────────────────────────────┘

CARDS DE DETALLE (scroll):

  Card Resumen (EvalCard):
  ┌──────────────────────────────────────────────┐
  │  Correctas   Incorrectas   Sin responder      │
  │    16/20        3/20           1/20           │
  │  success     error           neutral         │
  └──────────────────────────────────────────────┘

  Card Examen:
  Nombre examen, docente, grupo, fecha de envío, duración real

  Card Respuestas (si mostrarRespuestasCorrectas=true):
  Lista colapsable de cada pregunta:
  ✅ Pregunta correcta: borde success-200, badge "Correcto"
  ❌ Pregunta incorrecta: borde error-200, badge "Incorrecto"
    → Muestra tu respuesta + respuesta correcta

BOTTOM:
  [Volver al inicio] — EvalButton outlined
  [Presentar reclamo] — ghost, solo si dentro del plazo
```

---

### 4.9 PERFIL — ESTUDIANTE

```
CustomScrollView:

SLIVER HEADER (200px expandedHeight):
┌──────────────────────────────────────────────────┐
│  Fondo: gradient(primary → primaryDark)          │
│                                                  │
│  EvalAvatar xl (80px) — centrado                 │
│  [Nombre Apellido] — 20px w700 blanco            │
│  [Estudiante · Institución] — 13px blanco/70%    │
│  [badge: ACTIVO success-light]                   │
└──────────────────────────────────────────────────┘

STATS ROW (EvalCard bajo el header, margin 16px):
┌──────────────────────────────────────────────────┐
│  Exámenes  │  Promedio   │  Mejor nota            │
│    12      │    78%      │    95%                 │
│  CountUp   │  CountUp    │  CountUp               │
└──────────────────────────────────────────────────┘

SECCIONES:
"Mi cuenta"
  ListTile: Editar perfil →
  ListTile: Cambiar contraseña →
  ListTile: Notificaciones →

"Mi institución"
  ListTile: [nombre institución] (solo lectura)
  ListTile: Grupos inscritos (N) →
  ListTile: Período académico actual →

"Privacidad"
  ListTile: Políticas de evaluación →
  ListTile: Mis datos →

DIVIDER

"Cerrar sesión"
  ListTile: ícono rojo, texto error, sin chevron
  → BottomSheet de confirmación (no Alert)
```

---

### 4.10 HOME — DOCENTE

```
DrawerScaffold (sidebar izquierda)

AppBar: "EvalPro" + hamburger izquierda + avatar icono derecha

FAB extendido (derecha inferior):
  [+ Nueva sesión] → expanded
  Al scroll down: colapsa a FAB circular con "+"

BODY CustomScrollView:

STATS STRIP (horizontal scroll, 3 cards 140x90):
  Sesiones hoy | Estudiantes activos | Pendientes calificar
  Número 28px w700 primary + label 12px slate-500

SECCIÓN "Sesiones activas":
  Si hay:
    Lista SesionCard activa (verde pulsante):
    ┌────────────────────────────────────────────┐
    │  ● ACTIVA                  [código: AB3X9F] │
    │  [Examen] — 16px w600                      │
    │  [Grupo] · [N] estudiantes conectados       │
    │  ⏱ Iniciada hace 23 min   [Finalizar →]    │
    └────────────────────────────────────────────┘
  Si no hay:
    EvalCard neutral: "No hay sesiones activas"
    [+ Activar sesión]

SECCIÓN "Mis exámenes recientes":
  Header + "Ver todos →"
  ExamenCard (3 máx):
  ┌────────────────────────────────────────────┐
  │  [badge estado]              [•••]         │
  │  Título examen — 16px w600                │
  │  N preguntas · N pts · N min               │
  │  Modificado: hace 2 días                   │
  └────────────────────────────────────────────┘
```

---

### 4.11 GESTIÓN DE EXÁMENES — DOCENTE

```
AppBar: "Mis Exámenes"
FAB: [+ Crear examen]
Chips: [Todos] [Borrador] [Publicado] [Archivado]
Sort bottom: Por fecha / Por nombre / Por uso

ExamenListItem (EvalCard):
┌──────────────────────────────────────────────────┐
│  [badge] Publicado             [•••] popup menu  │
│  Cálculo Diferencial e Integral — 16px w600      │
│  20 preguntas · 100 pts · 60 min                 │
│  ─────────────────────────────────────────────   │
│  Creado: 15 ene · 3 sesiones realizadas          │
└──────────────────────────────────────────────────┘

Popup menu (•••):
  Ver / Editar / Publicar / Clonar / Archivar / Eliminar
  (según estado del examen)

PANTALLA CREACIÓN/EDICIÓN EXAMEN:
  AppBar: "Nuevo examen" / "Editar examen" + [Guardar]
  Tabs (2): [Configuración] [Preguntas]

  TAB CONFIGURACIÓN:
    [EvalTextField: Título]
    [EvalTextField multiline: Descripción]
    [EvalTextField multiline: Instrucciones]
    Switches (SwitchListTile):
      Aleatorizar preguntas y opciones
      Permitir navegación libre
    Slider: Duración (0=sin límite, steps de 5min)
      Visual: "60 minutos" o "Sin límite de tiempo"

  TAB PREGUNTAS:
    Lista de preguntas (ReorderableListView):
      PreguntaItem (drag handle + contenido colapsable)
      [+ Agregar pregunta] botón al final
    
    CREAR/EDITAR PREGUNTA (BottomSheet expandible):
      Selector tipo: chips horizontales
        [Opción múltiple] [V/F] [Selec. múltiple] [Abierta]
      [EvalTextField: Enunciado] multiline
      [EvalTextField: Puntaje] numérico
      OPCIONES (si aplica):
        Lista editable de opciones
        Radio/checkbox para marcar correcta(s)
        [+ Agregar opción]
```

---

### 4.12 PANEL DE SESIÓN EN TIEMPO REAL — DOCENTE

```
AppBar oscuro (fondo primary):
  "Sesión activa" + CÓDIGO EN CHIPS: [AB3X9F]
  Botón: [Finalizar sesión] (destructive ghost blanco)

STATS STRIP (fondo primaryDark, padding 16px):
┌────────────────────────────────────────────────────┐
│  Conectados: 23    Enviados: 8    En curso: 15      │
│  Con alerta: 2     Tiempo restante: 00:38:44        │
└────────────────────────────────────────────────────┘

LISTA ESTUDIANTES (actualización en tiempo real WebSocket):

EstudianteSessionTile:
┌──────────────────────────────────────────────────────┐
│  [EvalAvatar sm] Nombre Apellido                     │
│                  ← spacer →    [badge estado]        │
│  Progress: ████████░░░░  8/20 preguntas              │
│  Riesgo:  🟡 Moderado (si R≥30)                     │
└──────────────────────────────────────────────────────┘

BADGES ESTADO INTENTO:
  EN_PROGRESO: primary "En curso"
  ENVIADO: success "Enviado"
  SIN_INICIAR: neutral "Esperando"
  RIESGO_ALTO: error pulsante "⚠ Revisar"

Tap en estudiante → BottomSheet detalle:
  Progreso detallado
  Eventos de telemetría
  Índice de riesgo con desglose
  Botón: "Anular intento" (destructive, requiere confirmación)
```

---

## 5. ANIMACIONES Y MICRO-INTERACCIONES

### 5.1 Transiciones de página — GoRouter

```dart
// Registrar en GoRouter con CustomTransitionPage para CADA ruta:

Page<void> _buildPageWithTransition(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SharedAxisTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: SharedAxisTransitionType.horizontal,
        fillColor: AppColors.background,
        child: child,
      );
    },
  );
}

// Para modales (bottom sheets de código): SharedAxisTransitionType.vertical
// Para tabs: FadeThroughTransition
```

### 5.2 Staggered List Animation

```dart
// Aplicar en TODA lista que carga items:
class StaggeredList extends StatelessWidget {
  // Cada item: FadeTransition + SlideTransition
  // Delay: index * 50ms
  // Duración: 350ms
  // Curva: Curves.easeOutCubic
  // Offset inicial: Offset(0, 0.15) → Offset.zero
}
```

### 5.3 Micro-interacciones obligatorias

```
BOTÓN PRESS:
  GestureDetector onTapDown: scale 0.97
  onTapUp/Cancel: scale 1.0
  Duración: 100ms, curva: Curves.easeOut

OPCIÓN EXAMEN SELECT:
  AnimatedContainer: color, borde, scale 0.98→1.0
  Duración: 150ms
  HapticFeedback.selectionClick()

CARD TAP:
  InkWell splash + scale 0.99→1.0 50ms

SWITCH/TOGGLE:
  HapticFeedback.lightImpact()

PULL TO REFRESH:
  RefreshIndicator strokeWidth: 2.5, color: primary
  HapticFeedback.mediumImpact() al activar

BADGE PULSANTE (sesión activa):
  Opacity 1.0 ↔ 0.5, 1000ms loop, Curves.easeInOut

TIMER CRÍTICO:
  Scale 1.0 → 1.08 → 1.0, 800ms loop cuando < 5min

COUNT-UP TEXT (resultados/stats):
  TweenAnimationBuilder<double> 0→valor
  Duración: 1500ms, curva: Curves.easeOut
  Formato: "85%" con interpolación de double

EMPTY STATE ENTRY:
  FadeTransition + SlideTransition Offset(0, 0.1→0)
  Duración: 400ms, delay: 100ms
```

---

## 6. MANEJO DE ESTADOS POR PANTALLA

### 6.1 Template obligatorio para cada pantalla con datos

```dart
// NUNCA mostrar pantalla en blanco.
// SIEMPRE implementar los 4 estados:

Widget build(BuildContext context) {
  final state = ref.watch(someProvider);
  
  return state.when(
    loading: () => _buildSkeleton(),      // Shimmer apropiado
    error: (e, s) => EvalErrorState(      // Error con retry
      message: e.userFriendlyMessage,
      onRetry: () => ref.refresh(someProvider),
    ),
    data: (data) => data.isEmpty
      ? EvalEmptyState(...)               // Empty con CTA
      : _buildContent(data),             // Contenido real
  );
}

// AnimatedSwitcher wrapping el body:
AnimatedSwitcher(
  duration: Duration(milliseconds: 300),
  switchInCurve: Curves.easeOut,
  switchOutCurve: Curves.easeIn,
  child: _buildCurrentState(),
)
```

### 6.2 Skeleton Loaders específicos

```
HOME SHIMMER:
  ShimmerCard(height: 180)  ← card sesión activa
  Row de 3 ShimmerCard(160x90) ← stats
  ShimmerLine(width: 140, height: 20) ← header sección
  3x ShimmerCard(height: 80) ← lista evaluaciones

EXAMEN LIST SHIMMER:
  5x AsignacionCard shimmer:
    ShimmerCircle(44) + columna 2 ShimmerLine

SESIÓN PANEL SHIMMER:
  Stats strip shimmer
  5x EstudianteItem shimmer
```

---

## 7. DEPENDENCIAS — pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # ── NAVEGACIÓN ─────────────────────────────────────
  go_router: ^14.6.0
  
  # ── ESTADO ─────────────────────────────────────────
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  
  # ── RED ────────────────────────────────────────────
  dio: ^5.7.0
  connectivity_plus: ^6.1.0
  
  # ── STORAGE ────────────────────────────────────────
  flutter_secure_storage: ^9.2.2
  hive_flutter: ^1.1.0
  
  # ── UI Y ANIMACIONES ───────────────────────────────
  animations: ^2.0.11           # SharedAxisTransition, FadeThrough
  shimmer: ^3.0.0               # Skeleton loading
  lottie: ^3.3.0                # Animaciones estados vacío/resultado
  cached_network_image: ^3.4.1  # Imágenes con cache
  
  # ── TIPOGRAFÍA ─────────────────────────────────────
  google_fonts: ^6.2.1          # Plus Jakarta Sans
  
  # ── MODO EXAMEN / SEGURIDAD ─────────────────────────
  flutter_windowmanager: ^0.3.0 # FLAG_SECURE Android
  wakelock_plus: ^1.2.10        # Pantalla siempre encendida
  screenshot_callback: ^3.0.0   # Detección capturas iOS
  
  # ── MODELOS ────────────────────────────────────────
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0
  
  # ── UTILS ──────────────────────────────────────────
  logger: ^2.5.0
  intl: ^0.19.0
  equatable: ^2.0.7
  dartz: ^0.10.1               # Either<Failure, Success>

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.13
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  riverpod_generator: ^2.6.1
  custom_lint: ^0.7.5
  riverpod_lint: ^2.6.1
  flutter_lints: ^5.0.0
```

---

## 8. ESTRUCTURA DE ARCHIVOS FINAL

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   └── app_spacing.dart
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── api_constants.dart
│   ├── extensions/
│   │   ├── context_ext.dart
│   │   ├── string_ext.dart
│   │   └── datetime_ext.dart
│   ├── errors/
│   │   ├── failures.dart
│   │   └── app_exceptions.dart
│   ├── network/
│   │   ├── api_client.dart
│   │   ├── auth_interceptor.dart
│   │   └── connectivity_service.dart
│   ├── security/
│   │   └── exam_protection_service.dart  ← CRÍTICO
│   └── utils/
│       ├── validators.dart
│       └── haptics.dart
├── data/
│   ├── models/
│   ├── repositories/
│   └── datasources/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── providers/
│   ├── pages/
│   │   ├── splash/
│   │   ├── auth/
│   │   │   ├── login_page.dart
│   │   │   └── change_password_page.dart
│   │   ├── student/
│   │   │   ├── home/
│   │   │   ├── assignments/
│   │   │   ├── exam/
│   │   │   │   ├── pre_exam_page.dart
│   │   │   │   ├── exam_page.dart        ← CORAZÓN DE LA APP
│   │   │   │   └── result_page.dart
│   │   │   ├── results/
│   │   │   └── profile/
│   │   ├── teacher/
│   │   │   ├── home/
│   │   │   ├── exams/
│   │   │   ├── sessions/
│   │   │   │   └── session_panel_page.dart
│   │   │   └── groups/
│   │   └── admin/
│   │       ├── dashboard/
│   │       ├── users/
│   │       └── groups/
│   └── widgets/
│       ├── common/
│       │   ├── eval_button.dart
│       │   ├── eval_text_field.dart
│       │   ├── eval_card.dart
│       │   ├── eval_badge.dart
│       │   ├── eval_avatar.dart
│       │   ├── eval_shimmer.dart
│       │   ├── eval_empty_state.dart
│       │   ├── eval_error_state.dart
│       │   └── connectivity_banner.dart
│       └── animated/
│           ├── staggered_list.dart
│           ├── count_up_text.dart
│           └── animated_progress_bar.dart
└── router/
    └── app_router.dart
```

---

## 9. CHECKLIST FINAL — CRITERIOS DE ACEPTACIÓN UI/UX

```
DISEÑO NATIVO:
[ ] Ningún widget tiene color hardcodeado (solo AppColors.xxx)
[ ] Ningún widget tiene TextStyle inline (solo Theme.of(context).textTheme.xxx)
[ ] Todos los bordes usan AppSpacing.radiusXxx
[ ] Todos los shadows usan AppSpacing.shadowXxx
[ ] La tipografía es Plus Jakarta Sans en todos los textos
[ ] El tema oscuro funciona perfectamente en todas las pantallas

MODO EXAMEN:
[ ] FLAG_SECURE activo al entrar al examen (Android)
[ ] Screenshots bloqueados al entrar al examen (iOS)
[ ] SystemUiMode.immersiveSticky activo durante examen
[ ] WakelockPlus.enable() activo durante examen
[ ] PopScope previene salida sin confirmación
[ ] AppLifecycle.paused genera evento de telemetría
[ ] Overlay de advertencia aparece al volver a la app
[ ] Todo se restaura al finalizar/salir del examen
[ ] Timer funciona correctamente con estados de color
[ ] Auto-envío al llegar a 00:00

ANIMACIONES:
[ ] SharedAxisTransition en todas las rutas
[ ] Staggered animation en todas las listas
[ ] AnimatedSwitcher en todos los estados (loading/empty/error/data)
[ ] Count-up en todos los números de resultados/stats
[ ] Haptic feedback en todas las interacciones importantes

RENDIMIENTO:
[ ] No hay const faltantes donde sea posible
[ ] ListView.builder en todas las listas (no .children)
[ ] Imágenes con CachedNetworkImage
[ ] No hay rebuilds innecesarios visibles
[ ] 60fps estable en Pixel 6 / iPhone 13

ACCESIBILIDAD:
[ ] Todos los widgets interactivos tienen Semantics label
[ ] Contraste mínimo 4.5:1 en todo texto
[ ] Tap targets mínimo 44x44px en todos los botones
[ ] El examen es completamente operable sin ver la UI (labels semánticos)
```

---

*Este documento es la fuente de verdad absoluta de diseño para EvalPro Flutter.
Cualquier decisión visual no contemplada aquí debe resolverse siguiendo el sistema
de diseño definido en la Sección 1, priorizando siempre natividad, limpieza y claridad.*