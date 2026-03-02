/**
 * @archivo   ConfiguracionPruebasE2e.cjs
 * @descripcion Define la configuración Jest para ejecutar pruebas end-to-end en TypeScript.
 * @modulo    test
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
module.exports = {
  rootDir: '..',
  testEnvironment: 'node',
  testRegex: '.*\\.e2e-spec\\.ts$',
  moduleFileExtensions: ['ts', 'js', 'json'],
  transform: {
    '^.+\\.(t|j)s$': ['ts-jest', { tsconfig: 'test/TsconfigPruebasE2e.json' }],
  },
};
