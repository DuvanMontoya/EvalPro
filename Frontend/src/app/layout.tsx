/**
 * @archivo   layout.tsx
 * @descripcion Configura estilos globales y elementos base de la aplicación App Router.
 * @modulo    App
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import type { Metadata } from 'next';
import { Toaster } from 'sonner';
import './globals.css';

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
      <body className="antialiased">
        {children}
        <Toaster richColors position="top-right" />
      </body>
    </html>
  );
}
