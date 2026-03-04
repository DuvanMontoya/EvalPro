/// @archivo   FormularioLogin.dart
/// @descripcion Implementa el formulario de inicio de sesion con validaciones basicas.
/// @modulo    Pantallas/Autenticacion/Widgets
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../Constantes/Dimensiones.dart';
import '../../../Constantes/Textos.dart';
import '../../../Providers/AutenticacionProvider.dart';
import '../../../Utilidades/ValidadoresAutenticacion.dart';

class FormularioLogin extends ConsumerStatefulWidget {
  const FormularioLogin({super.key});

  @override
  ConsumerState<FormularioLogin> createState() => _FormularioLoginState();
}

class _FormularioLoginState extends ConsumerState<FormularioLogin> {
  static final RegExp _patronContrasenaSegura =
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z\d]).{8,}$');

  final _formulario = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();
  bool _cargando = false;
  bool _ocultarContrasena = true;

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    FocusScope.of(context).unfocus();
    if (!_formulario.currentState!.validate()) {
      return;
    }
    setState(() => _cargando = true);
    final gestorAutenticacion = ref.read(autenticacionEstadoProvider.notifier);
    await gestorAutenticacion.iniciarSesion(
      correo: _correo.text.trim(),
      contrasena: _contrasena.text,
    );
    if (mounted) {
      final estado = gestorAutenticacion.obtenerEstadoActual();
      if (!estado.estaAutenticado &&
          estado.tokenTemporalPrimerLogin != null &&
          estado.tokenTemporalPrimerLogin!.trim().isNotEmpty) {
        await _mostrarCambioContrasenaPrimerLogin(gestorAutenticacion);
      }
      setState(() => _cargando = false);
    }
  }

  Future<void> _mostrarCambioContrasenaPrimerLogin(
    AutenticacionEstado gestorAutenticacion,
  ) async {
    final formularioCambio = GlobalKey<FormState>();
    final nuevaContrasena = TextEditingController();
    final confirmarContrasena = TextEditingController();
    bool ocultarNueva = true;
    bool ocultarConfirmacion = true;
    bool cargandoCambio = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (contexto) {
        return StatefulBuilder(
          builder: (contexto, setEstado) {
            return AlertDialog(
              title: const Text('Cambia tu contrasena'),
              content: Form(
                key: formularioCambio,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      controller: nuevaContrasena,
                      obscureText: ocultarNueva,
                      decoration: InputDecoration(
                        labelText: 'Nueva contrasena',
                        suffixIcon: IconButton(
                          tooltip: ocultarNueva ? 'Mostrar' : 'Ocultar',
                          onPressed: () =>
                              setEstado(() => ocultarNueva = !ocultarNueva),
                          icon: Icon(
                            ocultarNueva
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: _validarContrasenaSegura,
                    ),
                    const SizedBox(height: Dimensiones.espaciadoMd),
                    TextFormField(
                      controller: confirmarContrasena,
                      obscureText: ocultarConfirmacion,
                      decoration: InputDecoration(
                        labelText: 'Confirmar contrasena',
                        suffixIcon: IconButton(
                          tooltip: ocultarConfirmacion ? 'Mostrar' : 'Ocultar',
                          onPressed: () => setEstado(
                              () => ocultarConfirmacion = !ocultarConfirmacion),
                          icon: Icon(
                            ocultarConfirmacion
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (valor) {
                        if ((valor ?? '').isEmpty) {
                          return 'Confirma la contrasena.';
                        }
                        if (valor != nuevaContrasena.text) {
                          return 'Las contrasenas no coinciden.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: cargandoCambio
                      ? null
                      : () {
                          Navigator.of(contexto).pop();
                        },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: cargandoCambio
                      ? null
                      : () async {
                          FocusScope.of(context).unfocus();
                          if (!formularioCambio.currentState!.validate()) {
                            return;
                          }
                          setEstado(() => cargandoCambio = true);
                          await gestorAutenticacion.completarPrimerLogin(
                            nuevaContrasena: nuevaContrasena.text,
                          );
                          final estado =
                              gestorAutenticacion.obtenerEstadoActual();
                          if (!mounted) {
                            return;
                          }
                          if (estado.estaAutenticado) {
                            Navigator.of(contexto).pop();
                            return;
                          }
                          setEstado(() => cargandoCambio = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                estado.error ?? Textos.errorInicioSesion,
                              ),
                            ),
                          );
                        },
                  child: cargandoCambio
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    nuevaContrasena.dispose();
    confirmarContrasena.dispose();
  }

  String? _validarContrasenaSegura(String? valor) {
    final texto = valor ?? '';
    if (texto.isEmpty) {
      return 'Ingresa una contrasena.';
    }
    if (!_patronContrasenaSegura.hasMatch(texto)) {
      return 'Usa 8+ caracteres con mayuscula, minuscula, numero y simbolo.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formulario,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextFormField(
            key: const Key('login_email_field'),
            controller: _correo,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: Textos.correo,
              hintText: 'usuario@institucion.edu',
              prefixIcon: Icon(Icons.alternate_email_rounded),
            ),
            validator: ValidadoresAutenticacion.validarCorreo,
          ),
          const SizedBox(height: Dimensiones.espaciadoLg),
          TextFormField(
            key: const Key('login_password_field'),
            controller: _contrasena,
            obscureText: _ocultarContrasena,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _enviar(),
            decoration: InputDecoration(
              labelText: Textos.contrasena,
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                key: const Key('login_password_toggle'),
                tooltip: _ocultarContrasena
                    ? 'Mostrar contrasena'
                    : 'Ocultar contrasena',
                onPressed: () {
                  setState(() => _ocultarContrasena = !_ocultarContrasena);
                },
                icon: Icon(
                  _ocultarContrasena
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            validator: ValidadoresAutenticacion.validarContrasena,
          ),
          const SizedBox(height: Dimensiones.espaciadoXl),
          ElevatedButton(
            key: const Key('login_submit_button'),
            onPressed: _cargando ? null : _enviar,
            child: _cargando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      key: Key('login_loading_indicator'),
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : const Text(Textos.iniciarSesion),
          ),
        ],
      ),
    );
  }
}
