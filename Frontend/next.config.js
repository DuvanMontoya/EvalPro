/**
 * @archivo   next.config.js
 * @descripcion Configura Next.js para uso con directorios externos y modo estricto de React.
 * @modulo    Configuracion
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
const configuracion = {
  experimental: {
    externalDir: true,
  },
  reactStrictMode: true,
};

module.exports = configuracion;
