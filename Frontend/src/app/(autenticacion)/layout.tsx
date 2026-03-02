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
    <main className="relative flex min-h-screen items-center justify-center overflow-hidden bg-fondo-raiz p-4 md:p-8">
      <div className="pointer-events-none absolute -top-24 left-1/2 h-72 w-72 -translate-x-1/2 rounded-full bg-[radial-gradient(circle,rgba(59,130,246,0.2),transparent_68%)] md:left-1/3" />
      <div className="pointer-events-none absolute -bottom-28 right-8 h-80 w-80 rounded-full bg-[radial-gradient(circle,rgba(16,185,129,0.16),transparent_70%)]" />
      <section className="relative grid w-full max-w-6xl overflow-hidden rounded-3xl border border-[var(--borde-default)] bg-fondo-elevado-2 shadow-sombra-xl lg:grid-cols-[1.15fr_0.85fr]">
        <aside className="hidden flex-col justify-between bg-[linear-gradient(145deg,rgba(30,64,175,0.45),rgba(8,12,16,0.92)_45%,rgba(15,23,42,0.92))] p-10 lg:flex">
          <div className="space-y-5">
            <span className="inline-flex w-fit items-center rounded-full border border-[var(--acento-primario-borde)] bg-[var(--acento-primario-sutil)] px-3 py-1 text-[0.72rem] font-semibold uppercase tracking-[0.08em] text-[var(--acento-primario-hover)]">
              EvalPro Control Center
            </span>
            <h2 className="max-w-md text-4xl font-extrabold leading-tight text-[var(--texto-primario)]">
              Operación académica con monitoreo en tiempo real.
            </h2>
            <p className="max-w-md text-base text-[var(--texto-secundario)]">
              Gestiona exámenes, sesiones y resultados desde un panel unificado con auditoría y seguridad por diseño.
            </p>
          </div>
          <div className="grid gap-3 text-sm text-[var(--texto-secundario)]">
            <p className="rounded-xl border border-[var(--borde-default)] bg-[rgba(8,12,16,0.4)] px-4 py-3">
              Sesiones activas, alertas de fraude y cierre masivo desde una sola vista.
            </p>
            <p className="rounded-xl border border-[var(--borde-default)] bg-[rgba(8,12,16,0.4)] px-4 py-3">
              Trazabilidad completa de acciones críticas en backend y frontend.
            </p>
          </div>
        </aside>
        <div className="relative p-6 md:p-10">
          <div className="mx-auto w-full max-w-md">{children}</div>
        </div>
      </section>
    </main>
  );
}
