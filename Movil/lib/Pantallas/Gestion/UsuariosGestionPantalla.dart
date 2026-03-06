/// @archivo   UsuariosGestionPantalla.dart
/// @descripcion Gestiona usuarios (crear, actualizar y desactivar) desde app movil.
/// @modulo    Pantallas/Gestion
/// @autor     EvalPro
/// @fecha     2026-03-03

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Constantes/Dimensiones.dart';
import '../../Constantes/Textos.dart';
import '../../Modelos/Enums/RolUsuario.dart';
import '../../Modelos/Enums/EstadoInstitucion.dart';
import '../../Modelos/InstitucionGestion.dart';
import '../../Modelos/UsuarioGestion.dart';
import '../../Providers/AutenticacionProvider.dart';
import '../../Servicios/InstitucionServicio.dart';
import '../../Servicios/UsuarioGestionServicio.dart';
import '../../Utilidades/MapeadorErroresNegocio.dart';
import '../../core/widgets/common/eval_badge.dart';
import '../../core/widgets/common/eval_empty_state.dart';
import '../../core/widgets/common/eval_error_state.dart';
import '../../core/widgets/common/eval_surface.dart';

class UsuariosGestionPantalla extends ConsumerStatefulWidget {
  const UsuariosGestionPantalla({super.key});

  @override
  ConsumerState<UsuariosGestionPantalla> createState() =>
      _UsuariosGestionPantallaState();
}

class _UsuariosGestionPantallaState
    extends ConsumerState<UsuariosGestionPantalla> {
  late UsuarioGestionServicio _servicio;
  late Future<List<UsuarioGestion>> _futuroUsuarios;

  @override
  void initState() {
    super.initState();
    _servicio = UsuarioGestionServicio(ref.read(apiServicioProvider));
    _futuroUsuarios = _servicio.listar();
  }

  Future<void> _recargar() async {
    setState(() {
      _futuroUsuarios = _servicio.listar();
    });
    await _futuroUsuarios;
  }

  List<RolUsuario> _rolesCreacion(RolUsuario? rolActor) {
    if (rolActor == RolUsuario.SUPERADMINISTRADOR) {
      return RolUsuario.values;
    }
    return const <RolUsuario>[
      RolUsuario.DOCENTE,
      RolUsuario.ESTUDIANTE,
    ];
  }

  List<RolUsuario> _rolesEdicion(RolUsuario? rolActor) {
    if (rolActor == RolUsuario.SUPERADMINISTRADOR) {
      return RolUsuario.values;
    }
    return const <RolUsuario>[
      RolUsuario.DOCENTE,
      RolUsuario.ESTUDIANTE,
    ];
  }

  Future<void> _mostrarCrearUsuario(RolUsuario? rolActor) async {
    final nombreControlador = TextEditingController();
    final apellidosControlador = TextEditingController();
    final correoControlador = TextEditingController();
    final contrasenaControlador = TextEditingController();
    List<InstitucionGestion> instituciones = <InstitucionGestion>[];
    if (rolActor == RolUsuario.SUPERADMINISTRADOR) {
      try {
        instituciones =
            await InstitucionServicio(ref.read(apiServicioProvider)).listar();
        instituciones = instituciones
            .where(
                (institucion) => institucion.estado == EstadoInstitucion.ACTIVA)
            .toList();
      } catch (error) {
        _mostrarError(
          MapeadorErroresNegocio.mapear(
            error,
            mensajePorDefecto: Textos.errorGestion,
          ),
        );
        return;
      }
    }
    final roles = _rolesCreacion(rolActor);
    RolUsuario rolSeleccionado = roles.first;
    InstitucionGestion? institucionSeleccionada =
        instituciones.isNotEmpty ? instituciones.first : null;

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (contexto) {
        return StatefulBuilder(builder: (contexto, setEstado) {
          return AlertDialog(
            title: const Text('Crear usuario'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: nombreControlador,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  TextField(
                    controller: apellidosControlador,
                    decoration: const InputDecoration(labelText: 'Apellidos'),
                  ),
                  TextField(
                    controller: correoControlador,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: Textos.correo),
                  ),
                  TextField(
                    controller: contrasenaControlador,
                    decoration:
                        const InputDecoration(labelText: Textos.contrasena),
                  ),
                  DropdownButtonFormField<RolUsuario>(
                    initialValue: rolSeleccionado,
                    items: roles
                        .map(
                          (rol) => DropdownMenuItem<RolUsuario>(
                            value: rol,
                            child: Text(rol.name),
                          ),
                        )
                        .toList(),
                    onChanged: (valor) {
                      if (valor != null) {
                        setEstado(() {
                          rolSeleccionado = valor;
                        });
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Rol'),
                  ),
                  if (rolActor == RolUsuario.SUPERADMINISTRADOR &&
                      rolSeleccionado != RolUsuario.SUPERADMINISTRADOR)
                    DropdownButtonFormField<String>(
                      initialValue: institucionSeleccionada?.id,
                      items: instituciones
                          .map(
                            (institucion) => DropdownMenuItem<String>(
                              value: institucion.id,
                              child: Text(institucion.nombre),
                            ),
                          )
                          .toList(),
                      onChanged: (valor) {
                        final seleccion = instituciones.firstWhere(
                          (institucion) => institucion.id == valor,
                          orElse: () =>
                              institucionSeleccionada ?? instituciones.first,
                        );
                        setEstado(() {
                          institucionSeleccionada = seleccion;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Institucion destino',
                      ),
                    ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(contexto).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(contexto).pop(true),
                child: const Text('Crear'),
              ),
            ],
          );
        });
      },
    );

    if (confirmado != true) {
      return;
    }

    final requiereInstitucion = rolActor == RolUsuario.SUPERADMINISTRADOR &&
        rolSeleccionado != RolUsuario.SUPERADMINISTRADOR;
    if (nombreControlador.text.trim().isEmpty ||
        apellidosControlador.text.trim().isEmpty ||
        correoControlador.text.trim().isEmpty ||
        contrasenaControlador.text.isEmpty ||
        (requiereInstitucion && institucionSeleccionada == null)) {
      _mostrarError(Textos.errorFormularioInvalido);
      return;
    }

    try {
      final creado = await _servicio.crear(
        nombre: nombreControlador.text,
        apellidos: apellidosControlador.text,
        correo: correoControlador.text,
        contrasena: contrasenaControlador.text,
        rol: rolSeleccionado,
        idInstitucion: requiereInstitucion ? institucionSeleccionada?.id : null,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            creado.credencialTemporalPlano == null
                ? 'Usuario creado correctamente.'
                : 'Usuario creado. Credencial temporal: ${creado.credencialTemporalPlano}',
          ),
        ),
      );
      await _recargar();
    } catch (error) {
      _mostrarError(MapeadorErroresNegocio.mapear(
        error,
        mensajePorDefecto: Textos.errorGestion,
      ));
    }
  }

  Future<void> _mostrarEditarUsuario(
    UsuarioGestion usuario,
    RolUsuario? rolActor,
  ) async {
    final nombreControlador = TextEditingController(text: usuario.nombre);
    final apellidosControlador = TextEditingController(text: usuario.apellidos);
    final correoControlador = TextEditingController(text: usuario.correo);
    final contrasenaControlador = TextEditingController();
    final roles = _rolesEdicion(rolActor);
    RolUsuario rolSeleccionado =
        roles.contains(usuario.rol) ? usuario.rol : roles.first;

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (contexto) {
        return StatefulBuilder(
          builder: (contexto, setEstado) {
            return AlertDialog(
              title: const Text('Editar usuario'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: nombreControlador,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                    ),
                    TextField(
                      controller: apellidosControlador,
                      decoration: const InputDecoration(labelText: 'Apellidos'),
                    ),
                    TextField(
                      controller: correoControlador,
                      keyboardType: TextInputType.emailAddress,
                      decoration:
                          const InputDecoration(labelText: Textos.correo),
                    ),
                    TextField(
                      controller: contrasenaControlador,
                      decoration: const InputDecoration(
                        labelText: 'Nueva contrasena (opcional)',
                      ),
                    ),
                    DropdownButtonFormField<RolUsuario>(
                      initialValue: rolSeleccionado,
                      items: roles
                          .map(
                            (rol) => DropdownMenuItem<RolUsuario>(
                              value: rol,
                              child: Text(rol.name),
                            ),
                          )
                          .toList(),
                      onChanged: (valor) {
                        if (valor != null) {
                          setEstado(() {
                            rolSeleccionado = valor;
                          });
                        }
                      },
                      decoration: const InputDecoration(labelText: 'Rol'),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(contexto).pop(false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(contexto).pop(true),
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmado != true) {
      return;
    }

    try {
      await _servicio.actualizar(
        idUsuario: usuario.id,
        nombre: nombreControlador.text,
        apellidos: apellidosControlador.text,
        correo: correoControlador.text,
        rol: rolSeleccionado,
        contrasena: contrasenaControlador.text,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario actualizado correctamente.')),
      );
      await _recargar();
    } catch (error) {
      _mostrarError(MapeadorErroresNegocio.mapear(
        error,
        mensajePorDefecto: Textos.errorGestion,
      ));
    }
  }

  Future<void> _desactivarUsuario(UsuarioGestion usuario) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (contexto) {
        return AlertDialog(
          title: const Text('Desactivar usuario'),
          content:
              Text('Se desactivara a ${usuario.nombre} ${usuario.apellidos}.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(contexto).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(contexto).pop(true),
              child: const Text('Desactivar'),
            ),
          ],
        );
      },
    );
    if (confirmar != true) {
      return;
    }

    try {
      await _servicio.desactivar(usuario.id);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario desactivado correctamente.')),
      );
      await _recargar();
    } catch (error) {
      _mostrarError(MapeadorErroresNegocio.mapear(
        error,
        mensajePorDefecto: Textos.errorGestion,
      ));
    }
  }

  void _mostrarError(String mensaje) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    final rolActor = ref.watch(autenticacionEstadoProvider).usuario?.rol;
    final puedeGestionar = rolActor == RolUsuario.ADMINISTRADOR ||
        rolActor == RolUsuario.SUPERADMINISTRADOR;

    return Scaffold(
      appBar: AppBar(
        title: const Text(Textos.gestionarUsuarios),
        actions: <Widget>[
          IconButton(
            onPressed: _recargar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: puedeGestionar
          ? FloatingActionButton.extended(
              onPressed: () => _mostrarCrearUsuario(rolActor),
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Nuevo'),
            )
          : null,
      body: EvalPageBackground(
        child: FutureBuilder<List<UsuarioGestion>>(
          future: _futuroUsuarios,
          builder: (contexto, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return EvalErrorState(
                message: MapeadorErroresNegocio.mapear(
                  snapshot.error!,
                  mensajePorDefecto: Textos.errorGestion,
                ),
                onRetry: _recargar,
              );
            }

            final usuarios = snapshot.data ?? <UsuarioGestion>[];
            if (usuarios.isEmpty) {
              return EvalEmptyState(
                icon: Icons.manage_accounts_outlined,
                title: Textos.sinDatos,
                subtitle:
                    'Crea o sincroniza usuarios para administrarlos desde esta vista.',
                actionLabel: 'Actualizar',
                onAction: _recargar,
              );
            }

            return RefreshIndicator(
              onRefresh: _recargar,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  Dimensiones.espaciadoLg,
                  Dimensiones.espaciadoSm,
                  Dimensiones.espaciadoLg,
                  Dimensiones.espaciado2xl,
                ),
                children: <Widget>[
                  const EvalPageHeader(
                    eyebrow: 'Identidad y acceso',
                    title: 'Usuarios',
                    subtitle:
                        'Administra perfiles, roles y estado operativo desde una vista mas clara y priorizada.',
                  ),
                  const SizedBox(height: Dimensiones.espaciadoLg),
                  ...usuarios.map((usuario) {
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: Dimensiones.espaciadoLg),
                      child: EvalSectionCard(
                        title: '${usuario.nombre} ${usuario.apellidos}'.trim(),
                        subtitle: usuario.correo,
                        trailing: EvalBadge(
                          usuario.rol.name,
                          variant: usuario.activo
                              ? EvalBadgeVariant.primary
                              : EvalBadgeVariant.error,
                        ),
                        child: Column(
                          children: <Widget>[
                            EvalInfoRow(
                              label: 'Estado cuenta',
                              value: usuario.estadoCuenta,
                              icon: Icons.verified_user_outlined,
                            ),
                            EvalInfoRow(
                              label: 'Activo',
                              value: usuario.activo ? 'SI' : 'NO',
                              icon: Icons.toggle_on_outlined,
                            ),
                            if (usuario.idInstitucion != null)
                              EvalInfoRow(
                                label: 'Institucion',
                                value: usuario.idInstitucion!,
                                icon: Icons.apartment_outlined,
                                compact: true,
                              ),
                            const SizedBox(height: Dimensiones.espaciadoSm),
                            if (puedeGestionar)
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: <Widget>[
                                  OutlinedButton.icon(
                                    onPressed: () =>
                                        _mostrarEditarUsuario(usuario, rolActor),
                                    icon: const Icon(Icons.edit_outlined),
                                    label: const Text('Editar'),
                                  ),
                                  if (usuario.activo)
                                    OutlinedButton.icon(
                                      onPressed: () =>
                                          _desactivarUsuario(usuario),
                                      icon: const Icon(
                                        Icons.person_off_outlined,
                                      ),
                                      label: const Text('Desactivar'),
                                    ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
