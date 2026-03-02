/**
 * @archivo   tailwind.config.ts
 * @descripcion Declara extensiones de Tailwind para el sistema de diseno y tokens globales.
 * @modulo    Configuracion
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import type { Config } from 'tailwindcss';

const configuracion: Config = {
  darkMode: ['class'],
  content: [
    './src/app/**/*.{ts,tsx}',
    './src/Componentes/**/*.{ts,tsx}',
    './src/Hooks/**/*.{ts,tsx}',
    './src/Servicios/**/*.{ts,tsx}',
  ],
  theme: {
    container: {
      center: true,
      padding: '1rem',
      screens: {
        '2xl': '1400px',
      },
    },
    extend: {
      colors: {
        'fondo-raiz': 'var(--fondo-raiz)',
        'fondo-elevado-1': 'var(--fondo-elevado-1)',
        'fondo-elevado-2': 'var(--fondo-elevado-2)',
        'fondo-elevado-3': 'var(--fondo-elevado-3)',
        'fondo-elevado-4': 'var(--fondo-elevado-4)',
        'texto-primario': 'var(--texto-primario)',
        'texto-secundario': 'var(--texto-secundario)',
        'texto-terciario': 'var(--texto-terciario)',
        'acento-primario': 'var(--acento-primario)',
        'acento-primario-hover': 'var(--acento-primario-hover)',
        'acento-cyan': 'var(--acento-cyan)',
        'estado-exito': 'var(--estado-exito)',
        'estado-advertencia': 'var(--estado-advertencia)',
        'estado-peligro': 'var(--estado-peligro)',
        'estado-neutro': 'var(--estado-neutro)',
        borde: 'hsl(var(--borde))',
        fondo: 'hsl(var(--fondo))',
        frente: 'hsl(var(--frente))',
        tarjeta: 'hsl(var(--tarjeta))',
        primario: {
          DEFAULT: 'var(--acento-primario)',
          frente: 'var(--texto-invertido)',
        },
        secundario: {
          DEFAULT: 'var(--fondo-elevado-3)',
          frente: 'var(--texto-primario)',
        },
        peligro: {
          DEFAULT: 'var(--estado-peligro)',
          frente: 'var(--texto-invertido)',
        },
        exito: {
          DEFAULT: 'var(--estado-exito)',
          frente: 'var(--texto-invertido)',
        },
      },
      fontFamily: {
        display: ['var(--fuente-display)', 'sans-serif'],
        ui: ['var(--fuente-ui)', 'sans-serif'],
        mono: ['var(--fuente-mono)', 'monospace'],
      },
      borderRadius: {
        xs: 'var(--radio-xs)',
        sm: 'var(--radio-sm)',
        md: 'var(--radio-md)',
        lg: 'var(--radio-lg)',
        xl: 'var(--radio-xl)',
        '2xl': 'var(--radio-2xl)',
        full: 'var(--radio-full)',
      },
      boxShadow: {
        'sombra-xs': 'var(--sombra-xs)',
        'sombra-sm': 'var(--sombra-sm)',
        'sombra-md': 'var(--sombra-md)',
        'sombra-lg': 'var(--sombra-lg)',
        'sombra-xl': 'var(--sombra-xl)',
        'sombra-azul': 'var(--sombra-azul)',
        'sombra-glow-primario': 'var(--sombra-glow-primario)',
      },
      keyframes: {
        'pagina-entrada': {
          from: { opacity: '0', transform: 'translateY(6px)' },
          to: { opacity: '1', transform: 'translateY(0)' },
        },
      },
      animation: {
        'pagina-entrada': 'pagina-entrada 0.25s ease forwards',
      },
    },
  },
  plugins: [],
};

export default configuracion;
