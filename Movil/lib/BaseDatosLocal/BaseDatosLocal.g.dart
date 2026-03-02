// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'BaseDatosLocal.dart';

// ignore_for_file: type=lint
class $ExamenesLocalTablaTable extends ExamenesLocalTabla
    with TableInfo<$ExamenesLocalTablaTable, ExamenesLocalTablaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExamenesLocalTablaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contenidoJsonMeta =
      const VerificationMeta('contenidoJson');
  @override
  late final GeneratedColumn<String> contenidoJson = GeneratedColumn<String>(
      'contenido_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _idSesionMeta =
      const VerificationMeta('idSesion');
  @override
  late final GeneratedColumn<String> idSesion = GeneratedColumn<String>(
      'id_sesion', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _idIntentoMeta =
      const VerificationMeta('idIntento');
  @override
  late final GeneratedColumn<String> idIntento = GeneratedColumn<String>(
      'id_intento', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fechaDescargaMeta =
      const VerificationMeta('fechaDescarga');
  @override
  late final GeneratedColumn<int> fechaDescarga = GeneratedColumn<int>(
      'fecha_descarga', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, contenidoJson, idSesion, idIntento, fechaDescarga];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'examenes_local_tabla';
  @override
  VerificationContext validateIntegrity(
      Insertable<ExamenesLocalTablaData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('contenido_json')) {
      context.handle(
          _contenidoJsonMeta,
          contenidoJson.isAcceptableOrUnknown(
              data['contenido_json']!, _contenidoJsonMeta));
    } else if (isInserting) {
      context.missing(_contenidoJsonMeta);
    }
    if (data.containsKey('id_sesion')) {
      context.handle(_idSesionMeta,
          idSesion.isAcceptableOrUnknown(data['id_sesion']!, _idSesionMeta));
    } else if (isInserting) {
      context.missing(_idSesionMeta);
    }
    if (data.containsKey('id_intento')) {
      context.handle(_idIntentoMeta,
          idIntento.isAcceptableOrUnknown(data['id_intento']!, _idIntentoMeta));
    } else if (isInserting) {
      context.missing(_idIntentoMeta);
    }
    if (data.containsKey('fecha_descarga')) {
      context.handle(
          _fechaDescargaMeta,
          fechaDescarga.isAcceptableOrUnknown(
              data['fecha_descarga']!, _fechaDescargaMeta));
    } else if (isInserting) {
      context.missing(_fechaDescargaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExamenesLocalTablaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExamenesLocalTablaData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      contenidoJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contenido_json'])!,
      idSesion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id_sesion'])!,
      idIntento: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id_intento'])!,
      fechaDescarga: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}fecha_descarga'])!,
    );
  }

  @override
  $ExamenesLocalTablaTable createAlias(String alias) {
    return $ExamenesLocalTablaTable(attachedDatabase, alias);
  }
}

class ExamenesLocalTablaData extends DataClass
    implements Insertable<ExamenesLocalTablaData> {
  final String id;
  final String contenidoJson;
  final String idSesion;
  final String idIntento;
  final int fechaDescarga;
  const ExamenesLocalTablaData(
      {required this.id,
      required this.contenidoJson,
      required this.idSesion,
      required this.idIntento,
      required this.fechaDescarga});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['contenido_json'] = Variable<String>(contenidoJson);
    map['id_sesion'] = Variable<String>(idSesion);
    map['id_intento'] = Variable<String>(idIntento);
    map['fecha_descarga'] = Variable<int>(fechaDescarga);
    return map;
  }

  ExamenesLocalTablaCompanion toCompanion(bool nullToAbsent) {
    return ExamenesLocalTablaCompanion(
      id: Value(id),
      contenidoJson: Value(contenidoJson),
      idSesion: Value(idSesion),
      idIntento: Value(idIntento),
      fechaDescarga: Value(fechaDescarga),
    );
  }

  factory ExamenesLocalTablaData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExamenesLocalTablaData(
      id: serializer.fromJson<String>(json['id']),
      contenidoJson: serializer.fromJson<String>(json['contenidoJson']),
      idSesion: serializer.fromJson<String>(json['idSesion']),
      idIntento: serializer.fromJson<String>(json['idIntento']),
      fechaDescarga: serializer.fromJson<int>(json['fechaDescarga']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'contenidoJson': serializer.toJson<String>(contenidoJson),
      'idSesion': serializer.toJson<String>(idSesion),
      'idIntento': serializer.toJson<String>(idIntento),
      'fechaDescarga': serializer.toJson<int>(fechaDescarga),
    };
  }

  ExamenesLocalTablaData copyWith(
          {String? id,
          String? contenidoJson,
          String? idSesion,
          String? idIntento,
          int? fechaDescarga}) =>
      ExamenesLocalTablaData(
        id: id ?? this.id,
        contenidoJson: contenidoJson ?? this.contenidoJson,
        idSesion: idSesion ?? this.idSesion,
        idIntento: idIntento ?? this.idIntento,
        fechaDescarga: fechaDescarga ?? this.fechaDescarga,
      );
  ExamenesLocalTablaData copyWithCompanion(ExamenesLocalTablaCompanion data) {
    return ExamenesLocalTablaData(
      id: data.id.present ? data.id.value : this.id,
      contenidoJson: data.contenidoJson.present
          ? data.contenidoJson.value
          : this.contenidoJson,
      idSesion: data.idSesion.present ? data.idSesion.value : this.idSesion,
      idIntento: data.idIntento.present ? data.idIntento.value : this.idIntento,
      fechaDescarga: data.fechaDescarga.present
          ? data.fechaDescarga.value
          : this.fechaDescarga,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExamenesLocalTablaData(')
          ..write('id: $id, ')
          ..write('contenidoJson: $contenidoJson, ')
          ..write('idSesion: $idSesion, ')
          ..write('idIntento: $idIntento, ')
          ..write('fechaDescarga: $fechaDescarga')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, contenidoJson, idSesion, idIntento, fechaDescarga);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExamenesLocalTablaData &&
          other.id == this.id &&
          other.contenidoJson == this.contenidoJson &&
          other.idSesion == this.idSesion &&
          other.idIntento == this.idIntento &&
          other.fechaDescarga == this.fechaDescarga);
}

class ExamenesLocalTablaCompanion
    extends UpdateCompanion<ExamenesLocalTablaData> {
  final Value<String> id;
  final Value<String> contenidoJson;
  final Value<String> idSesion;
  final Value<String> idIntento;
  final Value<int> fechaDescarga;
  final Value<int> rowid;
  const ExamenesLocalTablaCompanion({
    this.id = const Value.absent(),
    this.contenidoJson = const Value.absent(),
    this.idSesion = const Value.absent(),
    this.idIntento = const Value.absent(),
    this.fechaDescarga = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExamenesLocalTablaCompanion.insert({
    required String id,
    required String contenidoJson,
    required String idSesion,
    required String idIntento,
    required int fechaDescarga,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        contenidoJson = Value(contenidoJson),
        idSesion = Value(idSesion),
        idIntento = Value(idIntento),
        fechaDescarga = Value(fechaDescarga);
  static Insertable<ExamenesLocalTablaData> custom({
    Expression<String>? id,
    Expression<String>? contenidoJson,
    Expression<String>? idSesion,
    Expression<String>? idIntento,
    Expression<int>? fechaDescarga,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contenidoJson != null) 'contenido_json': contenidoJson,
      if (idSesion != null) 'id_sesion': idSesion,
      if (idIntento != null) 'id_intento': idIntento,
      if (fechaDescarga != null) 'fecha_descarga': fechaDescarga,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExamenesLocalTablaCompanion copyWith(
      {Value<String>? id,
      Value<String>? contenidoJson,
      Value<String>? idSesion,
      Value<String>? idIntento,
      Value<int>? fechaDescarga,
      Value<int>? rowid}) {
    return ExamenesLocalTablaCompanion(
      id: id ?? this.id,
      contenidoJson: contenidoJson ?? this.contenidoJson,
      idSesion: idSesion ?? this.idSesion,
      idIntento: idIntento ?? this.idIntento,
      fechaDescarga: fechaDescarga ?? this.fechaDescarga,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (contenidoJson.present) {
      map['contenido_json'] = Variable<String>(contenidoJson.value);
    }
    if (idSesion.present) {
      map['id_sesion'] = Variable<String>(idSesion.value);
    }
    if (idIntento.present) {
      map['id_intento'] = Variable<String>(idIntento.value);
    }
    if (fechaDescarga.present) {
      map['fecha_descarga'] = Variable<int>(fechaDescarga.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExamenesLocalTablaCompanion(')
          ..write('id: $id, ')
          ..write('contenidoJson: $contenidoJson, ')
          ..write('idSesion: $idSesion, ')
          ..write('idIntento: $idIntento, ')
          ..write('fechaDescarga: $fechaDescarga, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RespuestasLocalTablaTable extends RespuestasLocalTabla
    with TableInfo<$RespuestasLocalTablaTable, RespuestasLocalTablaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RespuestasLocalTablaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _idIntentoMeta =
      const VerificationMeta('idIntento');
  @override
  late final GeneratedColumn<String> idIntento = GeneratedColumn<String>(
      'id_intento', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _idPreguntaMeta =
      const VerificationMeta('idPregunta');
  @override
  late final GeneratedColumn<String> idPregunta = GeneratedColumn<String>(
      'id_pregunta', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valorTextoMeta =
      const VerificationMeta('valorTexto');
  @override
  late final GeneratedColumn<String> valorTexto = GeneratedColumn<String>(
      'valor_texto', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _opcionesSeleccionadasMeta =
      const VerificationMeta('opcionesSeleccionadas');
  @override
  late final GeneratedColumn<String> opcionesSeleccionadas =
      GeneratedColumn<String>('opciones_seleccionadas', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tiempoRespuestaMeta =
      const VerificationMeta('tiempoRespuesta');
  @override
  late final GeneratedColumn<int> tiempoRespuesta = GeneratedColumn<int>(
      'tiempo_respuesta', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _fechaRespuestaMeta =
      const VerificationMeta('fechaRespuesta');
  @override
  late final GeneratedColumn<int> fechaRespuesta = GeneratedColumn<int>(
      'fecha_respuesta', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _esSincronizadaMeta =
      const VerificationMeta('esSincronizada');
  @override
  late final GeneratedColumn<bool> esSincronizada = GeneratedColumn<bool>(
      'es_sincronizada', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("es_sincronizada" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _reintentosSincronizacionMeta =
      const VerificationMeta('reintentosSincronizacion');
  @override
  late final GeneratedColumn<int> reintentosSincronizacion =
      GeneratedColumn<int>('reintentos_sincronizacion', aliasedName, false,
          type: DriftSqlType.int,
          requiredDuringInsert: false,
          defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        idIntento,
        idPregunta,
        valorTexto,
        opcionesSeleccionadas,
        tiempoRespuesta,
        fechaRespuesta,
        esSincronizada,
        reintentosSincronizacion
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'respuestas_local_tabla';
  @override
  VerificationContext validateIntegrity(
      Insertable<RespuestasLocalTablaData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('id_intento')) {
      context.handle(_idIntentoMeta,
          idIntento.isAcceptableOrUnknown(data['id_intento']!, _idIntentoMeta));
    } else if (isInserting) {
      context.missing(_idIntentoMeta);
    }
    if (data.containsKey('id_pregunta')) {
      context.handle(
          _idPreguntaMeta,
          idPregunta.isAcceptableOrUnknown(
              data['id_pregunta']!, _idPreguntaMeta));
    } else if (isInserting) {
      context.missing(_idPreguntaMeta);
    }
    if (data.containsKey('valor_texto')) {
      context.handle(
          _valorTextoMeta,
          valorTexto.isAcceptableOrUnknown(
              data['valor_texto']!, _valorTextoMeta));
    }
    if (data.containsKey('opciones_seleccionadas')) {
      context.handle(
          _opcionesSeleccionadasMeta,
          opcionesSeleccionadas.isAcceptableOrUnknown(
              data['opciones_seleccionadas']!, _opcionesSeleccionadasMeta));
    }
    if (data.containsKey('tiempo_respuesta')) {
      context.handle(
          _tiempoRespuestaMeta,
          tiempoRespuesta.isAcceptableOrUnknown(
              data['tiempo_respuesta']!, _tiempoRespuestaMeta));
    }
    if (data.containsKey('fecha_respuesta')) {
      context.handle(
          _fechaRespuestaMeta,
          fechaRespuesta.isAcceptableOrUnknown(
              data['fecha_respuesta']!, _fechaRespuestaMeta));
    } else if (isInserting) {
      context.missing(_fechaRespuestaMeta);
    }
    if (data.containsKey('es_sincronizada')) {
      context.handle(
          _esSincronizadaMeta,
          esSincronizada.isAcceptableOrUnknown(
              data['es_sincronizada']!, _esSincronizadaMeta));
    }
    if (data.containsKey('reintentos_sincronizacion')) {
      context.handle(
          _reintentosSincronizacionMeta,
          reintentosSincronizacion.isAcceptableOrUnknown(
              data['reintentos_sincronizacion']!,
              _reintentosSincronizacionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RespuestasLocalTablaData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RespuestasLocalTablaData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      idIntento: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id_intento'])!,
      idPregunta: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id_pregunta'])!,
      valorTexto: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}valor_texto']),
      opcionesSeleccionadas: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}opciones_seleccionadas']),
      tiempoRespuesta: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tiempo_respuesta']),
      fechaRespuesta: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}fecha_respuesta'])!,
      esSincronizada: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}es_sincronizada'])!,
      reintentosSincronizacion: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}reintentos_sincronizacion'])!,
    );
  }

  @override
  $RespuestasLocalTablaTable createAlias(String alias) {
    return $RespuestasLocalTablaTable(attachedDatabase, alias);
  }
}

class RespuestasLocalTablaData extends DataClass
    implements Insertable<RespuestasLocalTablaData> {
  final String id;
  final String idIntento;
  final String idPregunta;
  final String? valorTexto;
  final String? opcionesSeleccionadas;
  final int? tiempoRespuesta;
  final int fechaRespuesta;
  final bool esSincronizada;
  final int reintentosSincronizacion;
  const RespuestasLocalTablaData(
      {required this.id,
      required this.idIntento,
      required this.idPregunta,
      this.valorTexto,
      this.opcionesSeleccionadas,
      this.tiempoRespuesta,
      required this.fechaRespuesta,
      required this.esSincronizada,
      required this.reintentosSincronizacion});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['id_intento'] = Variable<String>(idIntento);
    map['id_pregunta'] = Variable<String>(idPregunta);
    if (!nullToAbsent || valorTexto != null) {
      map['valor_texto'] = Variable<String>(valorTexto);
    }
    if (!nullToAbsent || opcionesSeleccionadas != null) {
      map['opciones_seleccionadas'] = Variable<String>(opcionesSeleccionadas);
    }
    if (!nullToAbsent || tiempoRespuesta != null) {
      map['tiempo_respuesta'] = Variable<int>(tiempoRespuesta);
    }
    map['fecha_respuesta'] = Variable<int>(fechaRespuesta);
    map['es_sincronizada'] = Variable<bool>(esSincronizada);
    map['reintentos_sincronizacion'] = Variable<int>(reintentosSincronizacion);
    return map;
  }

  RespuestasLocalTablaCompanion toCompanion(bool nullToAbsent) {
    return RespuestasLocalTablaCompanion(
      id: Value(id),
      idIntento: Value(idIntento),
      idPregunta: Value(idPregunta),
      valorTexto: valorTexto == null && nullToAbsent
          ? const Value.absent()
          : Value(valorTexto),
      opcionesSeleccionadas: opcionesSeleccionadas == null && nullToAbsent
          ? const Value.absent()
          : Value(opcionesSeleccionadas),
      tiempoRespuesta: tiempoRespuesta == null && nullToAbsent
          ? const Value.absent()
          : Value(tiempoRespuesta),
      fechaRespuesta: Value(fechaRespuesta),
      esSincronizada: Value(esSincronizada),
      reintentosSincronizacion: Value(reintentosSincronizacion),
    );
  }

  factory RespuestasLocalTablaData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RespuestasLocalTablaData(
      id: serializer.fromJson<String>(json['id']),
      idIntento: serializer.fromJson<String>(json['idIntento']),
      idPregunta: serializer.fromJson<String>(json['idPregunta']),
      valorTexto: serializer.fromJson<String?>(json['valorTexto']),
      opcionesSeleccionadas:
          serializer.fromJson<String?>(json['opcionesSeleccionadas']),
      tiempoRespuesta: serializer.fromJson<int?>(json['tiempoRespuesta']),
      fechaRespuesta: serializer.fromJson<int>(json['fechaRespuesta']),
      esSincronizada: serializer.fromJson<bool>(json['esSincronizada']),
      reintentosSincronizacion:
          serializer.fromJson<int>(json['reintentosSincronizacion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'idIntento': serializer.toJson<String>(idIntento),
      'idPregunta': serializer.toJson<String>(idPregunta),
      'valorTexto': serializer.toJson<String?>(valorTexto),
      'opcionesSeleccionadas':
          serializer.toJson<String?>(opcionesSeleccionadas),
      'tiempoRespuesta': serializer.toJson<int?>(tiempoRespuesta),
      'fechaRespuesta': serializer.toJson<int>(fechaRespuesta),
      'esSincronizada': serializer.toJson<bool>(esSincronizada),
      'reintentosSincronizacion':
          serializer.toJson<int>(reintentosSincronizacion),
    };
  }

  RespuestasLocalTablaData copyWith(
          {String? id,
          String? idIntento,
          String? idPregunta,
          Value<String?> valorTexto = const Value.absent(),
          Value<String?> opcionesSeleccionadas = const Value.absent(),
          Value<int?> tiempoRespuesta = const Value.absent(),
          int? fechaRespuesta,
          bool? esSincronizada,
          int? reintentosSincronizacion}) =>
      RespuestasLocalTablaData(
        id: id ?? this.id,
        idIntento: idIntento ?? this.idIntento,
        idPregunta: idPregunta ?? this.idPregunta,
        valorTexto: valorTexto.present ? valorTexto.value : this.valorTexto,
        opcionesSeleccionadas: opcionesSeleccionadas.present
            ? opcionesSeleccionadas.value
            : this.opcionesSeleccionadas,
        tiempoRespuesta: tiempoRespuesta.present
            ? tiempoRespuesta.value
            : this.tiempoRespuesta,
        fechaRespuesta: fechaRespuesta ?? this.fechaRespuesta,
        esSincronizada: esSincronizada ?? this.esSincronizada,
        reintentosSincronizacion:
            reintentosSincronizacion ?? this.reintentosSincronizacion,
      );
  RespuestasLocalTablaData copyWithCompanion(
      RespuestasLocalTablaCompanion data) {
    return RespuestasLocalTablaData(
      id: data.id.present ? data.id.value : this.id,
      idIntento: data.idIntento.present ? data.idIntento.value : this.idIntento,
      idPregunta:
          data.idPregunta.present ? data.idPregunta.value : this.idPregunta,
      valorTexto:
          data.valorTexto.present ? data.valorTexto.value : this.valorTexto,
      opcionesSeleccionadas: data.opcionesSeleccionadas.present
          ? data.opcionesSeleccionadas.value
          : this.opcionesSeleccionadas,
      tiempoRespuesta: data.tiempoRespuesta.present
          ? data.tiempoRespuesta.value
          : this.tiempoRespuesta,
      fechaRespuesta: data.fechaRespuesta.present
          ? data.fechaRespuesta.value
          : this.fechaRespuesta,
      esSincronizada: data.esSincronizada.present
          ? data.esSincronizada.value
          : this.esSincronizada,
      reintentosSincronizacion: data.reintentosSincronizacion.present
          ? data.reintentosSincronizacion.value
          : this.reintentosSincronizacion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RespuestasLocalTablaData(')
          ..write('id: $id, ')
          ..write('idIntento: $idIntento, ')
          ..write('idPregunta: $idPregunta, ')
          ..write('valorTexto: $valorTexto, ')
          ..write('opcionesSeleccionadas: $opcionesSeleccionadas, ')
          ..write('tiempoRespuesta: $tiempoRespuesta, ')
          ..write('fechaRespuesta: $fechaRespuesta, ')
          ..write('esSincronizada: $esSincronizada, ')
          ..write('reintentosSincronizacion: $reintentosSincronizacion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      idIntento,
      idPregunta,
      valorTexto,
      opcionesSeleccionadas,
      tiempoRespuesta,
      fechaRespuesta,
      esSincronizada,
      reintentosSincronizacion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RespuestasLocalTablaData &&
          other.id == this.id &&
          other.idIntento == this.idIntento &&
          other.idPregunta == this.idPregunta &&
          other.valorTexto == this.valorTexto &&
          other.opcionesSeleccionadas == this.opcionesSeleccionadas &&
          other.tiempoRespuesta == this.tiempoRespuesta &&
          other.fechaRespuesta == this.fechaRespuesta &&
          other.esSincronizada == this.esSincronizada &&
          other.reintentosSincronizacion == this.reintentosSincronizacion);
}

class RespuestasLocalTablaCompanion
    extends UpdateCompanion<RespuestasLocalTablaData> {
  final Value<String> id;
  final Value<String> idIntento;
  final Value<String> idPregunta;
  final Value<String?> valorTexto;
  final Value<String?> opcionesSeleccionadas;
  final Value<int?> tiempoRespuesta;
  final Value<int> fechaRespuesta;
  final Value<bool> esSincronizada;
  final Value<int> reintentosSincronizacion;
  final Value<int> rowid;
  const RespuestasLocalTablaCompanion({
    this.id = const Value.absent(),
    this.idIntento = const Value.absent(),
    this.idPregunta = const Value.absent(),
    this.valorTexto = const Value.absent(),
    this.opcionesSeleccionadas = const Value.absent(),
    this.tiempoRespuesta = const Value.absent(),
    this.fechaRespuesta = const Value.absent(),
    this.esSincronizada = const Value.absent(),
    this.reintentosSincronizacion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RespuestasLocalTablaCompanion.insert({
    required String id,
    required String idIntento,
    required String idPregunta,
    this.valorTexto = const Value.absent(),
    this.opcionesSeleccionadas = const Value.absent(),
    this.tiempoRespuesta = const Value.absent(),
    required int fechaRespuesta,
    this.esSincronizada = const Value.absent(),
    this.reintentosSincronizacion = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        idIntento = Value(idIntento),
        idPregunta = Value(idPregunta),
        fechaRespuesta = Value(fechaRespuesta);
  static Insertable<RespuestasLocalTablaData> custom({
    Expression<String>? id,
    Expression<String>? idIntento,
    Expression<String>? idPregunta,
    Expression<String>? valorTexto,
    Expression<String>? opcionesSeleccionadas,
    Expression<int>? tiempoRespuesta,
    Expression<int>? fechaRespuesta,
    Expression<bool>? esSincronizada,
    Expression<int>? reintentosSincronizacion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (idIntento != null) 'id_intento': idIntento,
      if (idPregunta != null) 'id_pregunta': idPregunta,
      if (valorTexto != null) 'valor_texto': valorTexto,
      if (opcionesSeleccionadas != null)
        'opciones_seleccionadas': opcionesSeleccionadas,
      if (tiempoRespuesta != null) 'tiempo_respuesta': tiempoRespuesta,
      if (fechaRespuesta != null) 'fecha_respuesta': fechaRespuesta,
      if (esSincronizada != null) 'es_sincronizada': esSincronizada,
      if (reintentosSincronizacion != null)
        'reintentos_sincronizacion': reintentosSincronizacion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RespuestasLocalTablaCompanion copyWith(
      {Value<String>? id,
      Value<String>? idIntento,
      Value<String>? idPregunta,
      Value<String?>? valorTexto,
      Value<String?>? opcionesSeleccionadas,
      Value<int?>? tiempoRespuesta,
      Value<int>? fechaRespuesta,
      Value<bool>? esSincronizada,
      Value<int>? reintentosSincronizacion,
      Value<int>? rowid}) {
    return RespuestasLocalTablaCompanion(
      id: id ?? this.id,
      idIntento: idIntento ?? this.idIntento,
      idPregunta: idPregunta ?? this.idPregunta,
      valorTexto: valorTexto ?? this.valorTexto,
      opcionesSeleccionadas:
          opcionesSeleccionadas ?? this.opcionesSeleccionadas,
      tiempoRespuesta: tiempoRespuesta ?? this.tiempoRespuesta,
      fechaRespuesta: fechaRespuesta ?? this.fechaRespuesta,
      esSincronizada: esSincronizada ?? this.esSincronizada,
      reintentosSincronizacion:
          reintentosSincronizacion ?? this.reintentosSincronizacion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (idIntento.present) {
      map['id_intento'] = Variable<String>(idIntento.value);
    }
    if (idPregunta.present) {
      map['id_pregunta'] = Variable<String>(idPregunta.value);
    }
    if (valorTexto.present) {
      map['valor_texto'] = Variable<String>(valorTexto.value);
    }
    if (opcionesSeleccionadas.present) {
      map['opciones_seleccionadas'] =
          Variable<String>(opcionesSeleccionadas.value);
    }
    if (tiempoRespuesta.present) {
      map['tiempo_respuesta'] = Variable<int>(tiempoRespuesta.value);
    }
    if (fechaRespuesta.present) {
      map['fecha_respuesta'] = Variable<int>(fechaRespuesta.value);
    }
    if (esSincronizada.present) {
      map['es_sincronizada'] = Variable<bool>(esSincronizada.value);
    }
    if (reintentosSincronizacion.present) {
      map['reintentos_sincronizacion'] =
          Variable<int>(reintentosSincronizacion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RespuestasLocalTablaCompanion(')
          ..write('id: $id, ')
          ..write('idIntento: $idIntento, ')
          ..write('idPregunta: $idPregunta, ')
          ..write('valorTexto: $valorTexto, ')
          ..write('opcionesSeleccionadas: $opcionesSeleccionadas, ')
          ..write('tiempoRespuesta: $tiempoRespuesta, ')
          ..write('fechaRespuesta: $fechaRespuesta, ')
          ..write('esSincronizada: $esSincronizada, ')
          ..write('reintentosSincronizacion: $reintentosSincronizacion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TelemetriaLocalTablaTable extends TelemetriaLocalTabla
    with TableInfo<$TelemetriaLocalTablaTable, TelemetriaLocalTablaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TelemetriaLocalTablaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _idIntentoMeta =
      const VerificationMeta('idIntento');
  @override
  late final GeneratedColumn<String> idIntento = GeneratedColumn<String>(
      'id_intento', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
      'tipo', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _metadatosMeta =
      const VerificationMeta('metadatos');
  @override
  late final GeneratedColumn<String> metadatos = GeneratedColumn<String>(
      'metadatos', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _numeroPreguntaMeta =
      const VerificationMeta('numeroPregunta');
  @override
  late final GeneratedColumn<int> numeroPregunta = GeneratedColumn<int>(
      'numero_pregunta', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _tiempoTranscurridoMeta =
      const VerificationMeta('tiempoTranscurrido');
  @override
  late final GeneratedColumn<int> tiempoTranscurrido = GeneratedColumn<int>(
      'tiempo_transcurrido', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _fechaEventoMeta =
      const VerificationMeta('fechaEvento');
  @override
  late final GeneratedColumn<int> fechaEvento = GeneratedColumn<int>(
      'fecha_evento', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _esSincronizadaMeta =
      const VerificationMeta('esSincronizada');
  @override
  late final GeneratedColumn<bool> esSincronizada = GeneratedColumn<bool>(
      'es_sincronizada', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("es_sincronizada" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        idIntento,
        tipo,
        metadatos,
        numeroPregunta,
        tiempoTranscurrido,
        fechaEvento,
        esSincronizada
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'telemetria_local_tabla';
  @override
  VerificationContext validateIntegrity(
      Insertable<TelemetriaLocalTablaData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('id_intento')) {
      context.handle(_idIntentoMeta,
          idIntento.isAcceptableOrUnknown(data['id_intento']!, _idIntentoMeta));
    } else if (isInserting) {
      context.missing(_idIntentoMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
          _tipoMeta, tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta));
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('metadatos')) {
      context.handle(_metadatosMeta,
          metadatos.isAcceptableOrUnknown(data['metadatos']!, _metadatosMeta));
    }
    if (data.containsKey('numero_pregunta')) {
      context.handle(
          _numeroPreguntaMeta,
          numeroPregunta.isAcceptableOrUnknown(
              data['numero_pregunta']!, _numeroPreguntaMeta));
    }
    if (data.containsKey('tiempo_transcurrido')) {
      context.handle(
          _tiempoTranscurridoMeta,
          tiempoTranscurrido.isAcceptableOrUnknown(
              data['tiempo_transcurrido']!, _tiempoTranscurridoMeta));
    }
    if (data.containsKey('fecha_evento')) {
      context.handle(
          _fechaEventoMeta,
          fechaEvento.isAcceptableOrUnknown(
              data['fecha_evento']!, _fechaEventoMeta));
    } else if (isInserting) {
      context.missing(_fechaEventoMeta);
    }
    if (data.containsKey('es_sincronizada')) {
      context.handle(
          _esSincronizadaMeta,
          esSincronizada.isAcceptableOrUnknown(
              data['es_sincronizada']!, _esSincronizadaMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TelemetriaLocalTablaData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TelemetriaLocalTablaData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      idIntento: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id_intento'])!,
      tipo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tipo'])!,
      metadatos: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadatos']),
      numeroPregunta: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}numero_pregunta']),
      tiempoTranscurrido: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}tiempo_transcurrido']),
      fechaEvento: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}fecha_evento'])!,
      esSincronizada: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}es_sincronizada'])!,
    );
  }

  @override
  $TelemetriaLocalTablaTable createAlias(String alias) {
    return $TelemetriaLocalTablaTable(attachedDatabase, alias);
  }
}

class TelemetriaLocalTablaData extends DataClass
    implements Insertable<TelemetriaLocalTablaData> {
  final String id;
  final String idIntento;
  final String tipo;
  final String? metadatos;
  final int? numeroPregunta;
  final int? tiempoTranscurrido;
  final int fechaEvento;
  final bool esSincronizada;
  const TelemetriaLocalTablaData(
      {required this.id,
      required this.idIntento,
      required this.tipo,
      this.metadatos,
      this.numeroPregunta,
      this.tiempoTranscurrido,
      required this.fechaEvento,
      required this.esSincronizada});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['id_intento'] = Variable<String>(idIntento);
    map['tipo'] = Variable<String>(tipo);
    if (!nullToAbsent || metadatos != null) {
      map['metadatos'] = Variable<String>(metadatos);
    }
    if (!nullToAbsent || numeroPregunta != null) {
      map['numero_pregunta'] = Variable<int>(numeroPregunta);
    }
    if (!nullToAbsent || tiempoTranscurrido != null) {
      map['tiempo_transcurrido'] = Variable<int>(tiempoTranscurrido);
    }
    map['fecha_evento'] = Variable<int>(fechaEvento);
    map['es_sincronizada'] = Variable<bool>(esSincronizada);
    return map;
  }

  TelemetriaLocalTablaCompanion toCompanion(bool nullToAbsent) {
    return TelemetriaLocalTablaCompanion(
      id: Value(id),
      idIntento: Value(idIntento),
      tipo: Value(tipo),
      metadatos: metadatos == null && nullToAbsent
          ? const Value.absent()
          : Value(metadatos),
      numeroPregunta: numeroPregunta == null && nullToAbsent
          ? const Value.absent()
          : Value(numeroPregunta),
      tiempoTranscurrido: tiempoTranscurrido == null && nullToAbsent
          ? const Value.absent()
          : Value(tiempoTranscurrido),
      fechaEvento: Value(fechaEvento),
      esSincronizada: Value(esSincronizada),
    );
  }

  factory TelemetriaLocalTablaData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TelemetriaLocalTablaData(
      id: serializer.fromJson<String>(json['id']),
      idIntento: serializer.fromJson<String>(json['idIntento']),
      tipo: serializer.fromJson<String>(json['tipo']),
      metadatos: serializer.fromJson<String?>(json['metadatos']),
      numeroPregunta: serializer.fromJson<int?>(json['numeroPregunta']),
      tiempoTranscurrido: serializer.fromJson<int?>(json['tiempoTranscurrido']),
      fechaEvento: serializer.fromJson<int>(json['fechaEvento']),
      esSincronizada: serializer.fromJson<bool>(json['esSincronizada']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'idIntento': serializer.toJson<String>(idIntento),
      'tipo': serializer.toJson<String>(tipo),
      'metadatos': serializer.toJson<String?>(metadatos),
      'numeroPregunta': serializer.toJson<int?>(numeroPregunta),
      'tiempoTranscurrido': serializer.toJson<int?>(tiempoTranscurrido),
      'fechaEvento': serializer.toJson<int>(fechaEvento),
      'esSincronizada': serializer.toJson<bool>(esSincronizada),
    };
  }

  TelemetriaLocalTablaData copyWith(
          {String? id,
          String? idIntento,
          String? tipo,
          Value<String?> metadatos = const Value.absent(),
          Value<int?> numeroPregunta = const Value.absent(),
          Value<int?> tiempoTranscurrido = const Value.absent(),
          int? fechaEvento,
          bool? esSincronizada}) =>
      TelemetriaLocalTablaData(
        id: id ?? this.id,
        idIntento: idIntento ?? this.idIntento,
        tipo: tipo ?? this.tipo,
        metadatos: metadatos.present ? metadatos.value : this.metadatos,
        numeroPregunta:
            numeroPregunta.present ? numeroPregunta.value : this.numeroPregunta,
        tiempoTranscurrido: tiempoTranscurrido.present
            ? tiempoTranscurrido.value
            : this.tiempoTranscurrido,
        fechaEvento: fechaEvento ?? this.fechaEvento,
        esSincronizada: esSincronizada ?? this.esSincronizada,
      );
  TelemetriaLocalTablaData copyWithCompanion(
      TelemetriaLocalTablaCompanion data) {
    return TelemetriaLocalTablaData(
      id: data.id.present ? data.id.value : this.id,
      idIntento: data.idIntento.present ? data.idIntento.value : this.idIntento,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      metadatos: data.metadatos.present ? data.metadatos.value : this.metadatos,
      numeroPregunta: data.numeroPregunta.present
          ? data.numeroPregunta.value
          : this.numeroPregunta,
      tiempoTranscurrido: data.tiempoTranscurrido.present
          ? data.tiempoTranscurrido.value
          : this.tiempoTranscurrido,
      fechaEvento:
          data.fechaEvento.present ? data.fechaEvento.value : this.fechaEvento,
      esSincronizada: data.esSincronizada.present
          ? data.esSincronizada.value
          : this.esSincronizada,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TelemetriaLocalTablaData(')
          ..write('id: $id, ')
          ..write('idIntento: $idIntento, ')
          ..write('tipo: $tipo, ')
          ..write('metadatos: $metadatos, ')
          ..write('numeroPregunta: $numeroPregunta, ')
          ..write('tiempoTranscurrido: $tiempoTranscurrido, ')
          ..write('fechaEvento: $fechaEvento, ')
          ..write('esSincronizada: $esSincronizada')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, idIntento, tipo, metadatos,
      numeroPregunta, tiempoTranscurrido, fechaEvento, esSincronizada);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TelemetriaLocalTablaData &&
          other.id == this.id &&
          other.idIntento == this.idIntento &&
          other.tipo == this.tipo &&
          other.metadatos == this.metadatos &&
          other.numeroPregunta == this.numeroPregunta &&
          other.tiempoTranscurrido == this.tiempoTranscurrido &&
          other.fechaEvento == this.fechaEvento &&
          other.esSincronizada == this.esSincronizada);
}

class TelemetriaLocalTablaCompanion
    extends UpdateCompanion<TelemetriaLocalTablaData> {
  final Value<String> id;
  final Value<String> idIntento;
  final Value<String> tipo;
  final Value<String?> metadatos;
  final Value<int?> numeroPregunta;
  final Value<int?> tiempoTranscurrido;
  final Value<int> fechaEvento;
  final Value<bool> esSincronizada;
  final Value<int> rowid;
  const TelemetriaLocalTablaCompanion({
    this.id = const Value.absent(),
    this.idIntento = const Value.absent(),
    this.tipo = const Value.absent(),
    this.metadatos = const Value.absent(),
    this.numeroPregunta = const Value.absent(),
    this.tiempoTranscurrido = const Value.absent(),
    this.fechaEvento = const Value.absent(),
    this.esSincronizada = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TelemetriaLocalTablaCompanion.insert({
    required String id,
    required String idIntento,
    required String tipo,
    this.metadatos = const Value.absent(),
    this.numeroPregunta = const Value.absent(),
    this.tiempoTranscurrido = const Value.absent(),
    required int fechaEvento,
    this.esSincronizada = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        idIntento = Value(idIntento),
        tipo = Value(tipo),
        fechaEvento = Value(fechaEvento);
  static Insertable<TelemetriaLocalTablaData> custom({
    Expression<String>? id,
    Expression<String>? idIntento,
    Expression<String>? tipo,
    Expression<String>? metadatos,
    Expression<int>? numeroPregunta,
    Expression<int>? tiempoTranscurrido,
    Expression<int>? fechaEvento,
    Expression<bool>? esSincronizada,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (idIntento != null) 'id_intento': idIntento,
      if (tipo != null) 'tipo': tipo,
      if (metadatos != null) 'metadatos': metadatos,
      if (numeroPregunta != null) 'numero_pregunta': numeroPregunta,
      if (tiempoTranscurrido != null) 'tiempo_transcurrido': tiempoTranscurrido,
      if (fechaEvento != null) 'fecha_evento': fechaEvento,
      if (esSincronizada != null) 'es_sincronizada': esSincronizada,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TelemetriaLocalTablaCompanion copyWith(
      {Value<String>? id,
      Value<String>? idIntento,
      Value<String>? tipo,
      Value<String?>? metadatos,
      Value<int?>? numeroPregunta,
      Value<int?>? tiempoTranscurrido,
      Value<int>? fechaEvento,
      Value<bool>? esSincronizada,
      Value<int>? rowid}) {
    return TelemetriaLocalTablaCompanion(
      id: id ?? this.id,
      idIntento: idIntento ?? this.idIntento,
      tipo: tipo ?? this.tipo,
      metadatos: metadatos ?? this.metadatos,
      numeroPregunta: numeroPregunta ?? this.numeroPregunta,
      tiempoTranscurrido: tiempoTranscurrido ?? this.tiempoTranscurrido,
      fechaEvento: fechaEvento ?? this.fechaEvento,
      esSincronizada: esSincronizada ?? this.esSincronizada,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (idIntento.present) {
      map['id_intento'] = Variable<String>(idIntento.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (metadatos.present) {
      map['metadatos'] = Variable<String>(metadatos.value);
    }
    if (numeroPregunta.present) {
      map['numero_pregunta'] = Variable<int>(numeroPregunta.value);
    }
    if (tiempoTranscurrido.present) {
      map['tiempo_transcurrido'] = Variable<int>(tiempoTranscurrido.value);
    }
    if (fechaEvento.present) {
      map['fecha_evento'] = Variable<int>(fechaEvento.value);
    }
    if (esSincronizada.present) {
      map['es_sincronizada'] = Variable<bool>(esSincronizada.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TelemetriaLocalTablaCompanion(')
          ..write('id: $id, ')
          ..write('idIntento: $idIntento, ')
          ..write('tipo: $tipo, ')
          ..write('metadatos: $metadatos, ')
          ..write('numeroPregunta: $numeroPregunta, ')
          ..write('tiempoTranscurrido: $tiempoTranscurrido, ')
          ..write('fechaEvento: $fechaEvento, ')
          ..write('esSincronizada: $esSincronizada, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$BaseDatosLocal extends GeneratedDatabase {
  _$BaseDatosLocal(QueryExecutor e) : super(e);
  $BaseDatosLocalManager get managers => $BaseDatosLocalManager(this);
  late final $ExamenesLocalTablaTable examenesLocalTabla =
      $ExamenesLocalTablaTable(this);
  late final $RespuestasLocalTablaTable respuestasLocalTabla =
      $RespuestasLocalTablaTable(this);
  late final $TelemetriaLocalTablaTable telemetriaLocalTabla =
      $TelemetriaLocalTablaTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [examenesLocalTabla, respuestasLocalTabla, telemetriaLocalTabla];
}

typedef $$ExamenesLocalTablaTableCreateCompanionBuilder
    = ExamenesLocalTablaCompanion Function({
  required String id,
  required String contenidoJson,
  required String idSesion,
  required String idIntento,
  required int fechaDescarga,
  Value<int> rowid,
});
typedef $$ExamenesLocalTablaTableUpdateCompanionBuilder
    = ExamenesLocalTablaCompanion Function({
  Value<String> id,
  Value<String> contenidoJson,
  Value<String> idSesion,
  Value<String> idIntento,
  Value<int> fechaDescarga,
  Value<int> rowid,
});

class $$ExamenesLocalTablaTableFilterComposer
    extends Composer<_$BaseDatosLocal, $ExamenesLocalTablaTable> {
  $$ExamenesLocalTablaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contenidoJson => $composableBuilder(
      column: $table.contenidoJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get idSesion => $composableBuilder(
      column: $table.idSesion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get idIntento => $composableBuilder(
      column: $table.idIntento, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fechaDescarga => $composableBuilder(
      column: $table.fechaDescarga, builder: (column) => ColumnFilters(column));
}

class $$ExamenesLocalTablaTableOrderingComposer
    extends Composer<_$BaseDatosLocal, $ExamenesLocalTablaTable> {
  $$ExamenesLocalTablaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contenidoJson => $composableBuilder(
      column: $table.contenidoJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get idSesion => $composableBuilder(
      column: $table.idSesion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get idIntento => $composableBuilder(
      column: $table.idIntento, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fechaDescarga => $composableBuilder(
      column: $table.fechaDescarga,
      builder: (column) => ColumnOrderings(column));
}

class $$ExamenesLocalTablaTableAnnotationComposer
    extends Composer<_$BaseDatosLocal, $ExamenesLocalTablaTable> {
  $$ExamenesLocalTablaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get contenidoJson => $composableBuilder(
      column: $table.contenidoJson, builder: (column) => column);

  GeneratedColumn<String> get idSesion =>
      $composableBuilder(column: $table.idSesion, builder: (column) => column);

  GeneratedColumn<String> get idIntento =>
      $composableBuilder(column: $table.idIntento, builder: (column) => column);

  GeneratedColumn<int> get fechaDescarga => $composableBuilder(
      column: $table.fechaDescarga, builder: (column) => column);
}

class $$ExamenesLocalTablaTableTableManager extends RootTableManager<
    _$BaseDatosLocal,
    $ExamenesLocalTablaTable,
    ExamenesLocalTablaData,
    $$ExamenesLocalTablaTableFilterComposer,
    $$ExamenesLocalTablaTableOrderingComposer,
    $$ExamenesLocalTablaTableAnnotationComposer,
    $$ExamenesLocalTablaTableCreateCompanionBuilder,
    $$ExamenesLocalTablaTableUpdateCompanionBuilder,
    (
      ExamenesLocalTablaData,
      BaseReferences<_$BaseDatosLocal, $ExamenesLocalTablaTable,
          ExamenesLocalTablaData>
    ),
    ExamenesLocalTablaData,
    PrefetchHooks Function()> {
  $$ExamenesLocalTablaTableTableManager(
      _$BaseDatosLocal db, $ExamenesLocalTablaTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExamenesLocalTablaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExamenesLocalTablaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExamenesLocalTablaTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> contenidoJson = const Value.absent(),
            Value<String> idSesion = const Value.absent(),
            Value<String> idIntento = const Value.absent(),
            Value<int> fechaDescarga = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExamenesLocalTablaCompanion(
            id: id,
            contenidoJson: contenidoJson,
            idSesion: idSesion,
            idIntento: idIntento,
            fechaDescarga: fechaDescarga,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String contenidoJson,
            required String idSesion,
            required String idIntento,
            required int fechaDescarga,
            Value<int> rowid = const Value.absent(),
          }) =>
              ExamenesLocalTablaCompanion.insert(
            id: id,
            contenidoJson: contenidoJson,
            idSesion: idSesion,
            idIntento: idIntento,
            fechaDescarga: fechaDescarga,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ExamenesLocalTablaTableProcessedTableManager = ProcessedTableManager<
    _$BaseDatosLocal,
    $ExamenesLocalTablaTable,
    ExamenesLocalTablaData,
    $$ExamenesLocalTablaTableFilterComposer,
    $$ExamenesLocalTablaTableOrderingComposer,
    $$ExamenesLocalTablaTableAnnotationComposer,
    $$ExamenesLocalTablaTableCreateCompanionBuilder,
    $$ExamenesLocalTablaTableUpdateCompanionBuilder,
    (
      ExamenesLocalTablaData,
      BaseReferences<_$BaseDatosLocal, $ExamenesLocalTablaTable,
          ExamenesLocalTablaData>
    ),
    ExamenesLocalTablaData,
    PrefetchHooks Function()>;
typedef $$RespuestasLocalTablaTableCreateCompanionBuilder
    = RespuestasLocalTablaCompanion Function({
  required String id,
  required String idIntento,
  required String idPregunta,
  Value<String?> valorTexto,
  Value<String?> opcionesSeleccionadas,
  Value<int?> tiempoRespuesta,
  required int fechaRespuesta,
  Value<bool> esSincronizada,
  Value<int> reintentosSincronizacion,
  Value<int> rowid,
});
typedef $$RespuestasLocalTablaTableUpdateCompanionBuilder
    = RespuestasLocalTablaCompanion Function({
  Value<String> id,
  Value<String> idIntento,
  Value<String> idPregunta,
  Value<String?> valorTexto,
  Value<String?> opcionesSeleccionadas,
  Value<int?> tiempoRespuesta,
  Value<int> fechaRespuesta,
  Value<bool> esSincronizada,
  Value<int> reintentosSincronizacion,
  Value<int> rowid,
});

class $$RespuestasLocalTablaTableFilterComposer
    extends Composer<_$BaseDatosLocal, $RespuestasLocalTablaTable> {
  $$RespuestasLocalTablaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get idIntento => $composableBuilder(
      column: $table.idIntento, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get idPregunta => $composableBuilder(
      column: $table.idPregunta, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get valorTexto => $composableBuilder(
      column: $table.valorTexto, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get opcionesSeleccionadas => $composableBuilder(
      column: $table.opcionesSeleccionadas,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tiempoRespuesta => $composableBuilder(
      column: $table.tiempoRespuesta,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fechaRespuesta => $composableBuilder(
      column: $table.fechaRespuesta,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get esSincronizada => $composableBuilder(
      column: $table.esSincronizada,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reintentosSincronizacion => $composableBuilder(
      column: $table.reintentosSincronizacion,
      builder: (column) => ColumnFilters(column));
}

class $$RespuestasLocalTablaTableOrderingComposer
    extends Composer<_$BaseDatosLocal, $RespuestasLocalTablaTable> {
  $$RespuestasLocalTablaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get idIntento => $composableBuilder(
      column: $table.idIntento, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get idPregunta => $composableBuilder(
      column: $table.idPregunta, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get valorTexto => $composableBuilder(
      column: $table.valorTexto, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get opcionesSeleccionadas => $composableBuilder(
      column: $table.opcionesSeleccionadas,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tiempoRespuesta => $composableBuilder(
      column: $table.tiempoRespuesta,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fechaRespuesta => $composableBuilder(
      column: $table.fechaRespuesta,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get esSincronizada => $composableBuilder(
      column: $table.esSincronizada,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reintentosSincronizacion => $composableBuilder(
      column: $table.reintentosSincronizacion,
      builder: (column) => ColumnOrderings(column));
}

class $$RespuestasLocalTablaTableAnnotationComposer
    extends Composer<_$BaseDatosLocal, $RespuestasLocalTablaTable> {
  $$RespuestasLocalTablaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get idIntento =>
      $composableBuilder(column: $table.idIntento, builder: (column) => column);

  GeneratedColumn<String> get idPregunta => $composableBuilder(
      column: $table.idPregunta, builder: (column) => column);

  GeneratedColumn<String> get valorTexto => $composableBuilder(
      column: $table.valorTexto, builder: (column) => column);

  GeneratedColumn<String> get opcionesSeleccionadas => $composableBuilder(
      column: $table.opcionesSeleccionadas, builder: (column) => column);

  GeneratedColumn<int> get tiempoRespuesta => $composableBuilder(
      column: $table.tiempoRespuesta, builder: (column) => column);

  GeneratedColumn<int> get fechaRespuesta => $composableBuilder(
      column: $table.fechaRespuesta, builder: (column) => column);

  GeneratedColumn<bool> get esSincronizada => $composableBuilder(
      column: $table.esSincronizada, builder: (column) => column);

  GeneratedColumn<int> get reintentosSincronizacion => $composableBuilder(
      column: $table.reintentosSincronizacion, builder: (column) => column);
}

class $$RespuestasLocalTablaTableTableManager extends RootTableManager<
    _$BaseDatosLocal,
    $RespuestasLocalTablaTable,
    RespuestasLocalTablaData,
    $$RespuestasLocalTablaTableFilterComposer,
    $$RespuestasLocalTablaTableOrderingComposer,
    $$RespuestasLocalTablaTableAnnotationComposer,
    $$RespuestasLocalTablaTableCreateCompanionBuilder,
    $$RespuestasLocalTablaTableUpdateCompanionBuilder,
    (
      RespuestasLocalTablaData,
      BaseReferences<_$BaseDatosLocal, $RespuestasLocalTablaTable,
          RespuestasLocalTablaData>
    ),
    RespuestasLocalTablaData,
    PrefetchHooks Function()> {
  $$RespuestasLocalTablaTableTableManager(
      _$BaseDatosLocal db, $RespuestasLocalTablaTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RespuestasLocalTablaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RespuestasLocalTablaTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RespuestasLocalTablaTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> idIntento = const Value.absent(),
            Value<String> idPregunta = const Value.absent(),
            Value<String?> valorTexto = const Value.absent(),
            Value<String?> opcionesSeleccionadas = const Value.absent(),
            Value<int?> tiempoRespuesta = const Value.absent(),
            Value<int> fechaRespuesta = const Value.absent(),
            Value<bool> esSincronizada = const Value.absent(),
            Value<int> reintentosSincronizacion = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RespuestasLocalTablaCompanion(
            id: id,
            idIntento: idIntento,
            idPregunta: idPregunta,
            valorTexto: valorTexto,
            opcionesSeleccionadas: opcionesSeleccionadas,
            tiempoRespuesta: tiempoRespuesta,
            fechaRespuesta: fechaRespuesta,
            esSincronizada: esSincronizada,
            reintentosSincronizacion: reintentosSincronizacion,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String idIntento,
            required String idPregunta,
            Value<String?> valorTexto = const Value.absent(),
            Value<String?> opcionesSeleccionadas = const Value.absent(),
            Value<int?> tiempoRespuesta = const Value.absent(),
            required int fechaRespuesta,
            Value<bool> esSincronizada = const Value.absent(),
            Value<int> reintentosSincronizacion = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RespuestasLocalTablaCompanion.insert(
            id: id,
            idIntento: idIntento,
            idPregunta: idPregunta,
            valorTexto: valorTexto,
            opcionesSeleccionadas: opcionesSeleccionadas,
            tiempoRespuesta: tiempoRespuesta,
            fechaRespuesta: fechaRespuesta,
            esSincronizada: esSincronizada,
            reintentosSincronizacion: reintentosSincronizacion,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RespuestasLocalTablaTableProcessedTableManager
    = ProcessedTableManager<
        _$BaseDatosLocal,
        $RespuestasLocalTablaTable,
        RespuestasLocalTablaData,
        $$RespuestasLocalTablaTableFilterComposer,
        $$RespuestasLocalTablaTableOrderingComposer,
        $$RespuestasLocalTablaTableAnnotationComposer,
        $$RespuestasLocalTablaTableCreateCompanionBuilder,
        $$RespuestasLocalTablaTableUpdateCompanionBuilder,
        (
          RespuestasLocalTablaData,
          BaseReferences<_$BaseDatosLocal, $RespuestasLocalTablaTable,
              RespuestasLocalTablaData>
        ),
        RespuestasLocalTablaData,
        PrefetchHooks Function()>;
typedef $$TelemetriaLocalTablaTableCreateCompanionBuilder
    = TelemetriaLocalTablaCompanion Function({
  required String id,
  required String idIntento,
  required String tipo,
  Value<String?> metadatos,
  Value<int?> numeroPregunta,
  Value<int?> tiempoTranscurrido,
  required int fechaEvento,
  Value<bool> esSincronizada,
  Value<int> rowid,
});
typedef $$TelemetriaLocalTablaTableUpdateCompanionBuilder
    = TelemetriaLocalTablaCompanion Function({
  Value<String> id,
  Value<String> idIntento,
  Value<String> tipo,
  Value<String?> metadatos,
  Value<int?> numeroPregunta,
  Value<int?> tiempoTranscurrido,
  Value<int> fechaEvento,
  Value<bool> esSincronizada,
  Value<int> rowid,
});

class $$TelemetriaLocalTablaTableFilterComposer
    extends Composer<_$BaseDatosLocal, $TelemetriaLocalTablaTable> {
  $$TelemetriaLocalTablaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get idIntento => $composableBuilder(
      column: $table.idIntento, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tipo => $composableBuilder(
      column: $table.tipo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadatos => $composableBuilder(
      column: $table.metadatos, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get numeroPregunta => $composableBuilder(
      column: $table.numeroPregunta,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tiempoTranscurrido => $composableBuilder(
      column: $table.tiempoTranscurrido,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fechaEvento => $composableBuilder(
      column: $table.fechaEvento, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get esSincronizada => $composableBuilder(
      column: $table.esSincronizada,
      builder: (column) => ColumnFilters(column));
}

class $$TelemetriaLocalTablaTableOrderingComposer
    extends Composer<_$BaseDatosLocal, $TelemetriaLocalTablaTable> {
  $$TelemetriaLocalTablaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get idIntento => $composableBuilder(
      column: $table.idIntento, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tipo => $composableBuilder(
      column: $table.tipo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadatos => $composableBuilder(
      column: $table.metadatos, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get numeroPregunta => $composableBuilder(
      column: $table.numeroPregunta,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tiempoTranscurrido => $composableBuilder(
      column: $table.tiempoTranscurrido,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fechaEvento => $composableBuilder(
      column: $table.fechaEvento, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get esSincronizada => $composableBuilder(
      column: $table.esSincronizada,
      builder: (column) => ColumnOrderings(column));
}

class $$TelemetriaLocalTablaTableAnnotationComposer
    extends Composer<_$BaseDatosLocal, $TelemetriaLocalTablaTable> {
  $$TelemetriaLocalTablaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get idIntento =>
      $composableBuilder(column: $table.idIntento, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get metadatos =>
      $composableBuilder(column: $table.metadatos, builder: (column) => column);

  GeneratedColumn<int> get numeroPregunta => $composableBuilder(
      column: $table.numeroPregunta, builder: (column) => column);

  GeneratedColumn<int> get tiempoTranscurrido => $composableBuilder(
      column: $table.tiempoTranscurrido, builder: (column) => column);

  GeneratedColumn<int> get fechaEvento => $composableBuilder(
      column: $table.fechaEvento, builder: (column) => column);

  GeneratedColumn<bool> get esSincronizada => $composableBuilder(
      column: $table.esSincronizada, builder: (column) => column);
}

class $$TelemetriaLocalTablaTableTableManager extends RootTableManager<
    _$BaseDatosLocal,
    $TelemetriaLocalTablaTable,
    TelemetriaLocalTablaData,
    $$TelemetriaLocalTablaTableFilterComposer,
    $$TelemetriaLocalTablaTableOrderingComposer,
    $$TelemetriaLocalTablaTableAnnotationComposer,
    $$TelemetriaLocalTablaTableCreateCompanionBuilder,
    $$TelemetriaLocalTablaTableUpdateCompanionBuilder,
    (
      TelemetriaLocalTablaData,
      BaseReferences<_$BaseDatosLocal, $TelemetriaLocalTablaTable,
          TelemetriaLocalTablaData>
    ),
    TelemetriaLocalTablaData,
    PrefetchHooks Function()> {
  $$TelemetriaLocalTablaTableTableManager(
      _$BaseDatosLocal db, $TelemetriaLocalTablaTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TelemetriaLocalTablaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TelemetriaLocalTablaTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TelemetriaLocalTablaTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> idIntento = const Value.absent(),
            Value<String> tipo = const Value.absent(),
            Value<String?> metadatos = const Value.absent(),
            Value<int?> numeroPregunta = const Value.absent(),
            Value<int?> tiempoTranscurrido = const Value.absent(),
            Value<int> fechaEvento = const Value.absent(),
            Value<bool> esSincronizada = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TelemetriaLocalTablaCompanion(
            id: id,
            idIntento: idIntento,
            tipo: tipo,
            metadatos: metadatos,
            numeroPregunta: numeroPregunta,
            tiempoTranscurrido: tiempoTranscurrido,
            fechaEvento: fechaEvento,
            esSincronizada: esSincronizada,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String idIntento,
            required String tipo,
            Value<String?> metadatos = const Value.absent(),
            Value<int?> numeroPregunta = const Value.absent(),
            Value<int?> tiempoTranscurrido = const Value.absent(),
            required int fechaEvento,
            Value<bool> esSincronizada = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TelemetriaLocalTablaCompanion.insert(
            id: id,
            idIntento: idIntento,
            tipo: tipo,
            metadatos: metadatos,
            numeroPregunta: numeroPregunta,
            tiempoTranscurrido: tiempoTranscurrido,
            fechaEvento: fechaEvento,
            esSincronizada: esSincronizada,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TelemetriaLocalTablaTableProcessedTableManager
    = ProcessedTableManager<
        _$BaseDatosLocal,
        $TelemetriaLocalTablaTable,
        TelemetriaLocalTablaData,
        $$TelemetriaLocalTablaTableFilterComposer,
        $$TelemetriaLocalTablaTableOrderingComposer,
        $$TelemetriaLocalTablaTableAnnotationComposer,
        $$TelemetriaLocalTablaTableCreateCompanionBuilder,
        $$TelemetriaLocalTablaTableUpdateCompanionBuilder,
        (
          TelemetriaLocalTablaData,
          BaseReferences<_$BaseDatosLocal, $TelemetriaLocalTablaTable,
              TelemetriaLocalTablaData>
        ),
        TelemetriaLocalTablaData,
        PrefetchHooks Function()>;

class $BaseDatosLocalManager {
  final _$BaseDatosLocal _db;
  $BaseDatosLocalManager(this._db);
  $$ExamenesLocalTablaTableTableManager get examenesLocalTabla =>
      $$ExamenesLocalTablaTableTableManager(_db, _db.examenesLocalTabla);
  $$RespuestasLocalTablaTableTableManager get respuestasLocalTabla =>
      $$RespuestasLocalTablaTableTableManager(_db, _db.respuestasLocalTabla);
  $$TelemetriaLocalTablaTableTableManager get telemetriaLocalTabla =>
      $$TelemetriaLocalTablaTableTableManager(_db, _db.telemetriaLocalTabla);
}
