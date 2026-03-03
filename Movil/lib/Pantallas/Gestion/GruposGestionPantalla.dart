/// @archivo   GruposGestionPantalla.dart
/// @descripcion Gestiona grupos academicos (crear, estado, docentes, estudiantes) en movil.
/// @modulo    Pantallas/Gestion
/// @autor     EvalPro
/// @fecha     2026-03-03

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Constantes/Textos.dart';
import '../../Modelos/Enums/EstadoGrupo.dart';
import '../../Modelos/Enums/RolUsuario.dart';
import '../../Modelos/GrupoGestion.dart';
import '../../Modelos/PeriodoGestion.dart';
import '../../Modelos/UsuarioGestion.dart';
import '../../Providers/AutenticacionProvider.dart';
import '../../Servicios/GrupoGestionServicio.dart';
import '../../Servicios/PeriodoGestionServicio.dart';
import '../../Servicios/UsuarioGestionServicio.dart';
import '../../Utilidades/MapeadorErroresNegocio.dart';

class GruposGestionPantalla extends ConsumerStatefulWidget {
  const GruposGestionPantalla({super.key});

  @override
  ConsumerState<GruposGestionPantalla> createState() =>
      _GruposGestionPantallaState();
}

class _GruposGestionPantallaState extends ConsumerState<GruposGestionPantalla> {
  late GrupoGestionServicio _grupoServicio;
  late UsuarioGestionServicio _usuarioServicio;
  late PeriodoGestionServicio _periodoServicio;
  late Future<List<GrupoGestion>> _futuroGrupos;

  @override
  void initState() {
    super.initState();
    _grupoServicio = GrupoGestionServicio(ref.read(apiServicioProvider));
    _usuarioServicio = UsuarioGestionServicio(ref.read(apiServicioProvider));
    _periodoServicio = PeriodoGestionServicio(ref.read(apiServicioProvider));
    _futuroGrupos = _grupoServicio.listar();
  }

  Future<void> _recargar() async {
    setState(() {
      _futuroGrupos = _grupoServicio.listar();
    });
    await _futuroGrupos;
  }

  Future<void> _mostrarCrearGrupo(RolUsuario? rolActor) async {
    final nombreControlador = TextEditingController();
    final descripcionControlador = TextEditingController();
    List<PeriodoGestion> periodos = <PeriodoGestion>[];
    try {
      periodos = await _periodoServicio.listar();
    } catch (error) {
      _mostrarError(MapeadorErroresNegocio.mapear(
        error,
        mensajePorDefecto: Textos.errorGestion,
      ));
      return;
    }

    if (periodos.isEmpty) {
      _mostrarError('No hay periodos disponibles para crear grupos.');
      return;
    }

    PeriodoGestion periodoSeleccionado = periodos.first;
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (contexto) {
        return StatefulBuilder(
          builder: (contexto, setEstado) {
            return AlertDialog(
              title: const Text('Crear grupo'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: nombreControlador,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                    ),
                    TextField(
                      controller: descripcionControlador,
                      decoration:
                          const InputDecoration(labelText: 'Descripcion'),
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: periodoSeleccionado.id,
                      items: periodos
                          .map(
                            (periodo) => DropdownMenuItem<String>(
                              value: periodo.id,
                              child: Text(periodo.nombre),
                            ),
                          )
                          .toList(),
                      onChanged: (valor) {
                        if (valor == null) {
                          return;
                        }
                        final nuevo = periodos.firstWhere(
                          (periodo) => periodo.id == valor,
                          orElse: () => periodoSeleccionado,
                        );
                        setEstado(() {
                          periodoSeleccionado = nuevo;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Periodo'),
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
          },
        );
      },
    );

    if (confirmado != true) {
      return;
    }
    if (nombreControlador.text.trim().isEmpty) {
      _mostrarError(Textos.errorFormularioInvalido);
      return;
    }

    try {
      await _grupoServicio.crear(
        nombre: nombreControlador.text,
        descripcion: descripcionControlador.text,
        idPeriodo: periodoSeleccionado.id,
        idInstitucion: rolActor == RolUsuario.SUPERADMINISTRADOR
            ? periodoSeleccionado.idInstitucion
            : null,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Grupo creado correctamente.')),
      );
      await _recargar();
    } catch (error) {
      _mostrarError(MapeadorErroresNegocio.mapear(
        error,
        mensajePorDefecto: Textos.errorGestion,
      ));
    }
  }

  Future<void> _mostrarAsignarDocente(GrupoGestion grupo) async {
    List<UsuarioGestion> usuarios = <UsuarioGestion>[];
    try {
      usuarios = await _usuarioServicio.listar();
    } catch (error) {
      _mostrarError(MapeadorErroresNegocio.mapear(
        error,
        mensajePorDefecto: Textos.errorGestion,
      ));
      return;
    }
    final docentes = usuarios
        .where((usuario) =>
            usuario.rol == RolUsuario.DOCENTE &&
            usuario.activo &&
            (usuario.idInstitucion == grupo.idInstitucion ||
                usuario.idInstitucion == null))
        .toList();

    if (docentes.isEmpty) {
      _mostrarError('No hay docentes activos para asignar.');
      return;
    }

    UsuarioGestion docenteSeleccionado = docentes.first;
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (contexto) {
        return StatefulBuilder(
          builder: (contexto, setEstado) {
            return AlertDialog(
              title: const Text('Asignar docente'),
              content: DropdownButtonFormField<String>(
                initialValue: docenteSeleccionado.id,
                items: docentes
                    .map(
                      (docente) => DropdownMenuItem<String>(
                        value: docente.id,
                        child: Text('${docente.nombre} ${docente.apellidos}'),
                      ),
                    )
                    .toList(),
                onChanged: (valor) {
                  if (valor == null) {
                    return;
                  }
                  final seleccionado = docentes.firstWhere(
                    (docente) => docente.id == valor,
                    orElse: () => docenteSeleccionado,
                  );
                  setEstado(() {
                    docenteSeleccionado = seleccionado;
                  });
                },
                decoration: const InputDecoration(labelText: 'Docente'),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(contexto).pop(false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(contexto).pop(true),
                  child: const Text('Asignar'),
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
      await _grupoServicio.asignarDocente(
        idGrupo: grupo.id,
        idDocente: docenteSeleccionado.id,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Docente asignado correctamente.')),
      );
      await _recargar();
    } catch (error) {
      _mostrarError(MapeadorErroresNegocio.mapear(
        error,
        mensajePorDefecto: Textos.errorGestion,
      ));
    }
  }

  Future<void> _mostrarInscribirEstudiante(GrupoGestion grupo) async {
    List<UsuarioGestion> usuarios = <UsuarioGestion>[];
    try {
      usuarios = await _usuarioServicio.listar();
    } catch (error) {
      _mostrarError(MapeadorErroresNegocio.mapear(
        error,
        mensajePorDefecto: Textos.errorGestion,
      ));
      return;
    }
    final estudiantes = usuarios
        .where((usuario) =>
            usuario.rol == RolUsuario.ESTUDIANTE &&
            usuario.activo &&
            (usuario.idInstitucion == grupo.idInstitucion ||
                usuario.idInstitucion == null))
        .toList();

    if (estudiantes.isEmpty) {
      _mostrarError('No hay estudiantes activos para inscribir.');
      return;
    }

    UsuarioGestion estudianteSeleccionado = estudiantes.first;
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (contexto) {
        return StatefulBuilder(
          builder: (contexto, setEstado) {
            return AlertDialog(
              title: const Text('Inscribir estudiante'),
              content: DropdownButtonFormField<String>(
                initialValue: estudianteSeleccionado.id,
                items: estudiantes
                    .map(
                      (estudiante) => DropdownMenuItem<String>(
                        value: estudiante.id,
                        child: Text(
                            '${estudiante.nombre} ${estudiante.apellidos}'),
                      ),
                    )
                    .toList(),
                onChanged: (valor) {
                  if (valor == null) {
                    return;
                  }
                  final seleccionado = estudiantes.firstWhere(
                    (estudiante) => estudiante.id == valor,
                    orElse: () => estudianteSeleccionado,
                  );
                  setEstado(() {
                    estudianteSeleccionado = seleccionado;
                  });
                },
                decoration: const InputDecoration(labelText: 'Estudiante'),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(contexto).pop(false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(contexto).pop(true),
                  child: const Text('Inscribir'),
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
      await _grupoServicio.inscribirEstudiante(
        idGrupo: grupo.id,
        idEstudiante: estudianteSeleccionado.id,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estudiante inscrito correctamente.')),
      );
      await _recargar();
    } catch (error) {
      _mostrarError(MapeadorErroresNegocio.mapear(
        error,
        mensajePorDefecto: Textos.errorGestion,
      ));
    }
  }

  Future<void> _mostrarCambiarEstado(GrupoGestion grupo) async {
    EstadoGrupo estadoSeleccionado = grupo.estado;
    final razonControlador = TextEditingController();

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (contexto) {
        return StatefulBuilder(
          builder: (contexto, setEstado) {
            return AlertDialog(
              title: const Text('Cambiar estado de grupo'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    DropdownButtonFormField<EstadoGrupo>(
                      initialValue: estadoSeleccionado,
                      items: EstadoGrupo.values
                          .map(
                            (estado) => DropdownMenuItem<EstadoGrupo>(
                              value: estado,
                              child: Text(estado.name),
                            ),
                          )
                          .toList(),
                      onChanged: (valor) {
                        if (valor != null) {
                          setEstado(() {
                            estadoSeleccionado = valor;
                          });
                        }
                      },
                      decoration: const InputDecoration(labelText: 'Estado'),
                    ),
                    TextField(
                      controller: razonControlador,
                      maxLines: 3,
                      decoration:
                          const InputDecoration(labelText: 'Razon (opcional)'),
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

    if (confirmado != true || estadoSeleccionado == grupo.estado) {
      return;
    }

    try {
      await _grupoServicio.cambiarEstado(
        idGrupo: grupo.id,
        estado: estadoSeleccionado,
        razon: razonControlador.text,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estado de grupo actualizado.')),
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
    final rol = ref.watch(autenticacionEstadoProvider).usuario?.rol;
    final puedeGestionar =
        rol == RolUsuario.ADMINISTRADOR || rol == RolUsuario.SUPERADMINISTRADOR;

    return Scaffold(
      appBar: AppBar(
        title: const Text(Textos.gestionarGrupos),
        actions: <Widget>[
          IconButton(
            onPressed: _recargar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: puedeGestionar
          ? FloatingActionButton.extended(
              onPressed: () => _mostrarCrearGrupo(rol),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo'),
            )
          : null,
      body: FutureBuilder<List<GrupoGestion>>(
        future: _futuroGrupos,
        builder: (contexto, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  MapeadorErroresNegocio.mapear(
                    snapshot.error!,
                    mensajePorDefecto: Textos.errorGestion,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final grupos = snapshot.data ?? <GrupoGestion>[];
          if (grupos.isEmpty) {
            return const Center(child: Text(Textos.sinDatos));
          }

          return RefreshIndicator(
            onRefresh: _recargar,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: grupos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (contexto, indice) {
                final grupo = grupos[indice];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          grupo.nombre,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text('Estado: ${grupo.estado.name}'),
                        Text('Codigo: ${grupo.codigoAcceso}'),
                        Text(
                            'Periodo: ${grupo.nombrePeriodo ?? grupo.idPeriodo}'),
                        Text('Docentes: ${grupo.docentes.length}'),
                        Text('Estudiantes: ${grupo.estudiantes.length}'),
                        if (grupo.descripcion != null &&
                            grupo.descripcion!.trim().isNotEmpty)
                          Text('Descripcion: ${grupo.descripcion}'),
                        if (puedeGestionar) ...<Widget>[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: <Widget>[
                              OutlinedButton(
                                onPressed: () => _mostrarAsignarDocente(grupo),
                                child: const Text('Asignar docente'),
                              ),
                              OutlinedButton(
                                onPressed: () =>
                                    _mostrarInscribirEstudiante(grupo),
                                child: const Text('Inscribir estudiante'),
                              ),
                              OutlinedButton(
                                onPressed: () => _mostrarCambiarEstado(grupo),
                                child: const Text('Cambiar estado'),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
