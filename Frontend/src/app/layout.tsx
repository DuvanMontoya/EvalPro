/**
 * @archivo   layout.tsx
 * @descripcion Configura fuentes del sistema, layout global y notificaciones base del frontend.
 * @modulo    App
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import type { Metadata } from 'next';
import { DM_Sans, JetBrains_Mono, Syne } from 'next/font/google';
import { Toaster } from 'sonner';
import './globals.css';

const fuenteDisplay = Syne({
  subsets: ['latin'],
  weight: ['700', '800'],
  variable: '--fuente-display',
});

const fuenteUi = DM_Sans({
  subsets: ['latin'],
  weight: ['300', '400', '500', '600'],
  variable: '--fuente-ui',
});

const fuenteMono = JetBrains_Mono({
  subsets: ['latin'],
  weight: ['400', '500', '600'],
  variable: '--fuente-mono',
});

export const metadata: Metadata = {
  title: 'EvalPro Admin',
  description: 'Panel administrativo del ecosistema EvalPro',
};

interface PropiedadesLayoutRaiz {
  children: React.ReactNode;
}

/**
 * Renderiza el layout raíz con estilos y toaster global.
 * @param children - Árbol de rutas hijas.
 * @returns Estructura HTML principal de la app.
 */
export default function RootLayout({ children }: PropiedadesLayoutRaiz) {
  return (
    <html lang="es">
      <body className={`${fuenteDisplay.variable} ${fuenteUi.variable} ${fuenteMono.variable} font-ui antialiased`}>
        {children}
        <Toaster
          richColors
          position="bottom-right"
          toastOptions={{
            style: {
              background: 'var(--fondo-elevado-3)',
              border: '1px solid var(--borde-fuerte)',
              color: 'var(--texto-primario)',
              borderRadius: 'var(--radio-lg)',
            },
          }}
        />
      </body>
    </html>
  );
}
