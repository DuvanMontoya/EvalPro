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
    await ref.read(autenticacionEstadoProvider.notifier).iniciarSesion(
          correo: _correo.text.trim(),
          contrasena: _contrasena.text,
        );
    if (mounted) {
      setState(() => _cargando = false);
    }
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
