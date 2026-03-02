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
    <main className="flex min-h-screen items-center justify-center bg-fondo-raiz p-4">
      <section className="w-full max-w-md rounded-xl border border-[var(--borde-default)] bg-fondo-elevado-2 p-8 shadow-sombra-lg">
        {children}
      </section>
    </main>
  );
}
