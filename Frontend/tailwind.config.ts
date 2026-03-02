/**
 * @archivo   tailwind.config.ts
 * @descripcion Define tokens de tema y rutas de escaneo para estilos utilitarios del panel.
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
        fondo: 'hsl(var(--fondo))',
        frente: 'hsl(var(--frente))',
        tarjeta: 'hsl(var(--tarjeta))',
        borde: 'hsl(var(--borde))',
        primario: {
          DEFAULT: 'hsl(var(--primario))',
          frente: 'hsl(var(--primario-frente))',
        },
        secundario: {
          DEFAULT: 'hsl(var(--secundario))',
          frente: 'hsl(var(--secundario-frente))',
        },
        peligro: {
          DEFAULT: 'hsl(var(--peligro))',
          frente: 'hsl(var(--peligro-frente))',
        },
        exito: {
          DEFAULT: 'hsl(var(--exito))',
          frente: 'hsl(var(--exito-frente))',
        },
      },
      borderRadius: {
        lg: 'var(--radio-lg)',
        md: 'calc(var(--radio-lg) - 2px)',
        sm: 'calc(var(--radio-lg) - 4px)',
      },
    },
  },
  plugins: [],
};

export default configuracion;
