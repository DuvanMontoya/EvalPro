/**
 * @archivo   layout.tsx
 * @descripcion Define layout centrado para pantallas del flujo de autenticación.
 * @modulo    Autenticacion
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
interface PropiedadesLayoutAutenticacion {
  children: React.ReactNode;
}

/**
 * Renderiza estructura visual para formularios de acceso.
 */
export default function LayoutAutenticacion({ children }: PropiedadesLayoutAutenticacion) {
  return (
    <main className="flex min-h-screen items-center justify-center p-4">
      <section className="w-full max-w-md rounded-xl border border-borde bg-white p-8 shadow-lg">
        {children}
      </section>
    </main>
  );
}
