/// @archivo   FormularioLogin.dart
/// @descripcion Implementa el formulario de inicio de sesion con validaciones basicas.
/// @modulo    Pantallas/Autenticacion/Widgets
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../Constantes/Textos.dart';
import '../../../Providers/AutenticacionProvider.dart';

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

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
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
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _correo,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: Textos.correo),
            validator: (valor) {
              if (valor == null || valor.trim().isEmpty)
                return 'Ingresa un correo';
              if (!valor.contains('@')) return 'Correo invalido';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _contrasena,
            obscureText: true,
            decoration: const InputDecoration(labelText: Textos.contrasena),
            validator: (valor) {
              if (valor == null || valor.length < 8)
                return 'Minimo 8 caracteres';
              return null;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _cargando ? null : _enviar,
            child: _cargando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(Textos.iniciarSesion),
          ),
        ],
      ),
    );
  }
}
