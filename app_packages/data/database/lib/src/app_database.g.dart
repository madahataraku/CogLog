// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ExerciseHistoriesTable extends ExerciseHistories
    with TableInfo<$ExerciseHistoriesTable, ExerciseHistoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseHistoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savedAtMeta = const VerificationMeta(
    'savedAt',
  );
  @override
  late final GeneratedColumn<String> savedAt = GeneratedColumn<String>(
    'saved_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creationStartedAtMeta = const VerificationMeta(
    'creationStartedAt',
  );
  @override
  late final GeneratedColumn<String> creationStartedAt =
      GeneratedColumn<String>(
        'creation_started_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<String> capturedAt = GeneratedColumn<String>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<String> recordedAt = GeneratedColumn<String>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordedAtManuallySetMeta =
      const VerificationMeta('recordedAtManuallySet');
  @override
  late final GeneratedColumn<bool> recordedAtManuallySet =
      GeneratedColumn<bool>(
        'recorded_at_manually_set',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("recorded_at_manually_set" IN (0, 1))',
        ),
      );
  static const VerificationMeta _distanceKmMeta = const VerificationMeta(
    'distanceKm',
  );
  @override
  late final GeneratedColumn<double> distanceKm = GeneratedColumn<double>(
    'distance_km',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caloriesKcalMeta = const VerificationMeta(
    'caloriesKcal',
  );
  @override
  late final GeneratedColumn<double> caloriesKcal = GeneratedColumn<double>(
    'calories_kcal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _averageSpeedKmhMeta = const VerificationMeta(
    'averageSpeedKmh',
  );
  @override
  late final GeneratedColumn<double> averageSpeedKmh = GeneratedColumn<double>(
    'average_speed_kmh',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoRelativePathMeta = const VerificationMeta(
    'photoRelativePath',
  );
  @override
  late final GeneratedColumn<String> photoRelativePath =
      GeneratedColumn<String>(
        'photo_relative_path',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _healthWorkoutIdMeta = const VerificationMeta(
    'healthWorkoutId',
  );
  @override
  late final GeneratedColumn<String> healthWorkoutId = GeneratedColumn<String>(
    'health_workout_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    savedAt,
    creationStartedAt,
    capturedAt,
    recordedAt,
    recordedAtManuallySet,
    distanceKm,
    durationMs,
    caloriesKcal,
    averageSpeedKmh,
    photoRelativePath,
    healthWorkoutId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_histories';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseHistoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('saved_at')) {
      context.handle(
        _savedAtMeta,
        savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_savedAtMeta);
    }
    if (data.containsKey('creation_started_at')) {
      context.handle(
        _creationStartedAtMeta,
        creationStartedAt.isAcceptableOrUnknown(
          data['creation_started_at']!,
          _creationStartedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_creationStartedAtMeta);
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('recorded_at_manually_set')) {
      context.handle(
        _recordedAtManuallySetMeta,
        recordedAtManuallySet.isAcceptableOrUnknown(
          data['recorded_at_manually_set']!,
          _recordedAtManuallySetMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordedAtManuallySetMeta);
    }
    if (data.containsKey('distance_km')) {
      context.handle(
        _distanceKmMeta,
        distanceKm.isAcceptableOrUnknown(data['distance_km']!, _distanceKmMeta),
      );
    } else if (isInserting) {
      context.missing(_distanceKmMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('calories_kcal')) {
      context.handle(
        _caloriesKcalMeta,
        caloriesKcal.isAcceptableOrUnknown(
          data['calories_kcal']!,
          _caloriesKcalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_caloriesKcalMeta);
    }
    if (data.containsKey('average_speed_kmh')) {
      context.handle(
        _averageSpeedKmhMeta,
        averageSpeedKmh.isAcceptableOrUnknown(
          data['average_speed_kmh']!,
          _averageSpeedKmhMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_averageSpeedKmhMeta);
    }
    if (data.containsKey('photo_relative_path')) {
      context.handle(
        _photoRelativePathMeta,
        photoRelativePath.isAcceptableOrUnknown(
          data['photo_relative_path']!,
          _photoRelativePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_photoRelativePathMeta);
    }
    if (data.containsKey('health_workout_id')) {
      context.handle(
        _healthWorkoutIdMeta,
        healthWorkoutId.isAcceptableOrUnknown(
          data['health_workout_id']!,
          _healthWorkoutIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExerciseHistoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseHistoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      savedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}saved_at'],
      )!,
      creationStartedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}creation_started_at'],
      )!,
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}captured_at'],
      )!,
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recorded_at'],
      )!,
      recordedAtManuallySet: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}recorded_at_manually_set'],
      )!,
      distanceKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_km'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      caloriesKcal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories_kcal'],
      )!,
      averageSpeedKmh: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_speed_kmh'],
      )!,
      photoRelativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_relative_path'],
      )!,
      healthWorkoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}health_workout_id'],
      ),
    );
  }

  @override
  $ExerciseHistoriesTable createAlias(String alias) {
    return $ExerciseHistoriesTable(attachedDatabase, alias);
  }
}

class ExerciseHistoryRow extends DataClass
    implements Insertable<ExerciseHistoryRow> {
  /// 運動履歴 ID（UUID）。
  final String id;

  /// 保存日時（UTC ISO-8601）。
  final String savedAt;

  /// 作成開始日時（UTC ISO-8601）。
  final String creationStartedAt;

  /// 撮影日時（UTC ISO-8601）。
  final String capturedAt;

  /// 記録日時（UTC ISO-8601）。
  final String recordedAt;

  /// 記録日時の手変更。
  final bool recordedAtManuallySet;

  /// 走行距離（km）。
  final double distanceKm;

  /// 運動時間（ミリ秒）。
  final int durationMs;

  /// 消費カロリー（kcal）。
  final double caloriesKcal;

  /// 平均速度（km/h）。
  final double averageSpeedKmh;

  /// Documents からの写真相対パス。
  final String photoRelativePath;

  /// ヘルスサービス上のサイクリング外部 ID。未対応・失敗時は null。
  final String? healthWorkoutId;
  const ExerciseHistoryRow({
    required this.id,
    required this.savedAt,
    required this.creationStartedAt,
    required this.capturedAt,
    required this.recordedAt,
    required this.recordedAtManuallySet,
    required this.distanceKm,
    required this.durationMs,
    required this.caloriesKcal,
    required this.averageSpeedKmh,
    required this.photoRelativePath,
    this.healthWorkoutId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['saved_at'] = Variable<String>(savedAt);
    map['creation_started_at'] = Variable<String>(creationStartedAt);
    map['captured_at'] = Variable<String>(capturedAt);
    map['recorded_at'] = Variable<String>(recordedAt);
    map['recorded_at_manually_set'] = Variable<bool>(recordedAtManuallySet);
    map['distance_km'] = Variable<double>(distanceKm);
    map['duration_ms'] = Variable<int>(durationMs);
    map['calories_kcal'] = Variable<double>(caloriesKcal);
    map['average_speed_kmh'] = Variable<double>(averageSpeedKmh);
    map['photo_relative_path'] = Variable<String>(photoRelativePath);
    if (!nullToAbsent || healthWorkoutId != null) {
      map['health_workout_id'] = Variable<String>(healthWorkoutId);
    }
    return map;
  }

  ExerciseHistoriesCompanion toCompanion(bool nullToAbsent) {
    return ExerciseHistoriesCompanion(
      id: Value(id),
      savedAt: Value(savedAt),
      creationStartedAt: Value(creationStartedAt),
      capturedAt: Value(capturedAt),
      recordedAt: Value(recordedAt),
      recordedAtManuallySet: Value(recordedAtManuallySet),
      distanceKm: Value(distanceKm),
      durationMs: Value(durationMs),
      caloriesKcal: Value(caloriesKcal),
      averageSpeedKmh: Value(averageSpeedKmh),
      photoRelativePath: Value(photoRelativePath),
      healthWorkoutId: healthWorkoutId == null && nullToAbsent
          ? const Value.absent()
          : Value(healthWorkoutId),
    );
  }

  factory ExerciseHistoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseHistoryRow(
      id: serializer.fromJson<String>(json['id']),
      savedAt: serializer.fromJson<String>(json['savedAt']),
      creationStartedAt: serializer.fromJson<String>(json['creationStartedAt']),
      capturedAt: serializer.fromJson<String>(json['capturedAt']),
      recordedAt: serializer.fromJson<String>(json['recordedAt']),
      recordedAtManuallySet: serializer.fromJson<bool>(
        json['recordedAtManuallySet'],
      ),
      distanceKm: serializer.fromJson<double>(json['distanceKm']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      caloriesKcal: serializer.fromJson<double>(json['caloriesKcal']),
      averageSpeedKmh: serializer.fromJson<double>(json['averageSpeedKmh']),
      photoRelativePath: serializer.fromJson<String>(json['photoRelativePath']),
      healthWorkoutId: serializer.fromJson<String?>(json['healthWorkoutId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'savedAt': serializer.toJson<String>(savedAt),
      'creationStartedAt': serializer.toJson<String>(creationStartedAt),
      'capturedAt': serializer.toJson<String>(capturedAt),
      'recordedAt': serializer.toJson<String>(recordedAt),
      'recordedAtManuallySet': serializer.toJson<bool>(recordedAtManuallySet),
      'distanceKm': serializer.toJson<double>(distanceKm),
      'durationMs': serializer.toJson<int>(durationMs),
      'caloriesKcal': serializer.toJson<double>(caloriesKcal),
      'averageSpeedKmh': serializer.toJson<double>(averageSpeedKmh),
      'photoRelativePath': serializer.toJson<String>(photoRelativePath),
      'healthWorkoutId': serializer.toJson<String?>(healthWorkoutId),
    };
  }

  ExerciseHistoryRow copyWith({
    String? id,
    String? savedAt,
    String? creationStartedAt,
    String? capturedAt,
    String? recordedAt,
    bool? recordedAtManuallySet,
    double? distanceKm,
    int? durationMs,
    double? caloriesKcal,
    double? averageSpeedKmh,
    String? photoRelativePath,
    Value<String?> healthWorkoutId = const Value.absent(),
  }) => ExerciseHistoryRow(
    id: id ?? this.id,
    savedAt: savedAt ?? this.savedAt,
    creationStartedAt: creationStartedAt ?? this.creationStartedAt,
    capturedAt: capturedAt ?? this.capturedAt,
    recordedAt: recordedAt ?? this.recordedAt,
    recordedAtManuallySet: recordedAtManuallySet ?? this.recordedAtManuallySet,
    distanceKm: distanceKm ?? this.distanceKm,
    durationMs: durationMs ?? this.durationMs,
    caloriesKcal: caloriesKcal ?? this.caloriesKcal,
    averageSpeedKmh: averageSpeedKmh ?? this.averageSpeedKmh,
    photoRelativePath: photoRelativePath ?? this.photoRelativePath,
    healthWorkoutId: healthWorkoutId.present
        ? healthWorkoutId.value
        : this.healthWorkoutId,
  );
  ExerciseHistoryRow copyWithCompanion(ExerciseHistoriesCompanion data) {
    return ExerciseHistoryRow(
      id: data.id.present ? data.id.value : this.id,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
      creationStartedAt: data.creationStartedAt.present
          ? data.creationStartedAt.value
          : this.creationStartedAt,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      recordedAtManuallySet: data.recordedAtManuallySet.present
          ? data.recordedAtManuallySet.value
          : this.recordedAtManuallySet,
      distanceKm: data.distanceKm.present
          ? data.distanceKm.value
          : this.distanceKm,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      caloriesKcal: data.caloriesKcal.present
          ? data.caloriesKcal.value
          : this.caloriesKcal,
      averageSpeedKmh: data.averageSpeedKmh.present
          ? data.averageSpeedKmh.value
          : this.averageSpeedKmh,
      photoRelativePath: data.photoRelativePath.present
          ? data.photoRelativePath.value
          : this.photoRelativePath,
      healthWorkoutId: data.healthWorkoutId.present
          ? data.healthWorkoutId.value
          : this.healthWorkoutId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseHistoryRow(')
          ..write('id: $id, ')
          ..write('savedAt: $savedAt, ')
          ..write('creationStartedAt: $creationStartedAt, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('recordedAtManuallySet: $recordedAtManuallySet, ')
          ..write('distanceKm: $distanceKm, ')
          ..write('durationMs: $durationMs, ')
          ..write('caloriesKcal: $caloriesKcal, ')
          ..write('averageSpeedKmh: $averageSpeedKmh, ')
          ..write('photoRelativePath: $photoRelativePath, ')
          ..write('healthWorkoutId: $healthWorkoutId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    savedAt,
    creationStartedAt,
    capturedAt,
    recordedAt,
    recordedAtManuallySet,
    distanceKm,
    durationMs,
    caloriesKcal,
    averageSpeedKmh,
    photoRelativePath,
    healthWorkoutId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseHistoryRow &&
          other.id == this.id &&
          other.savedAt == this.savedAt &&
          other.creationStartedAt == this.creationStartedAt &&
          other.capturedAt == this.capturedAt &&
          other.recordedAt == this.recordedAt &&
          other.recordedAtManuallySet == this.recordedAtManuallySet &&
          other.distanceKm == this.distanceKm &&
          other.durationMs == this.durationMs &&
          other.caloriesKcal == this.caloriesKcal &&
          other.averageSpeedKmh == this.averageSpeedKmh &&
          other.photoRelativePath == this.photoRelativePath &&
          other.healthWorkoutId == this.healthWorkoutId);
}

class ExerciseHistoriesCompanion extends UpdateCompanion<ExerciseHistoryRow> {
  final Value<String> id;
  final Value<String> savedAt;
  final Value<String> creationStartedAt;
  final Value<String> capturedAt;
  final Value<String> recordedAt;
  final Value<bool> recordedAtManuallySet;
  final Value<double> distanceKm;
  final Value<int> durationMs;
  final Value<double> caloriesKcal;
  final Value<double> averageSpeedKmh;
  final Value<String> photoRelativePath;
  final Value<String?> healthWorkoutId;
  final Value<int> rowid;
  const ExerciseHistoriesCompanion({
    this.id = const Value.absent(),
    this.savedAt = const Value.absent(),
    this.creationStartedAt = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.recordedAtManuallySet = const Value.absent(),
    this.distanceKm = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.caloriesKcal = const Value.absent(),
    this.averageSpeedKmh = const Value.absent(),
    this.photoRelativePath = const Value.absent(),
    this.healthWorkoutId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseHistoriesCompanion.insert({
    required String id,
    required String savedAt,
    required String creationStartedAt,
    required String capturedAt,
    required String recordedAt,
    required bool recordedAtManuallySet,
    required double distanceKm,
    required int durationMs,
    required double caloriesKcal,
    required double averageSpeedKmh,
    required String photoRelativePath,
    this.healthWorkoutId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       savedAt = Value(savedAt),
       creationStartedAt = Value(creationStartedAt),
       capturedAt = Value(capturedAt),
       recordedAt = Value(recordedAt),
       recordedAtManuallySet = Value(recordedAtManuallySet),
       distanceKm = Value(distanceKm),
       durationMs = Value(durationMs),
       caloriesKcal = Value(caloriesKcal),
       averageSpeedKmh = Value(averageSpeedKmh),
       photoRelativePath = Value(photoRelativePath);
  static Insertable<ExerciseHistoryRow> custom({
    Expression<String>? id,
    Expression<String>? savedAt,
    Expression<String>? creationStartedAt,
    Expression<String>? capturedAt,
    Expression<String>? recordedAt,
    Expression<bool>? recordedAtManuallySet,
    Expression<double>? distanceKm,
    Expression<int>? durationMs,
    Expression<double>? caloriesKcal,
    Expression<double>? averageSpeedKmh,
    Expression<String>? photoRelativePath,
    Expression<String>? healthWorkoutId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (savedAt != null) 'saved_at': savedAt,
      if (creationStartedAt != null) 'creation_started_at': creationStartedAt,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (recordedAtManuallySet != null)
        'recorded_at_manually_set': recordedAtManuallySet,
      if (distanceKm != null) 'distance_km': distanceKm,
      if (durationMs != null) 'duration_ms': durationMs,
      if (caloriesKcal != null) 'calories_kcal': caloriesKcal,
      if (averageSpeedKmh != null) 'average_speed_kmh': averageSpeedKmh,
      if (photoRelativePath != null) 'photo_relative_path': photoRelativePath,
      if (healthWorkoutId != null) 'health_workout_id': healthWorkoutId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseHistoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? savedAt,
    Value<String>? creationStartedAt,
    Value<String>? capturedAt,
    Value<String>? recordedAt,
    Value<bool>? recordedAtManuallySet,
    Value<double>? distanceKm,
    Value<int>? durationMs,
    Value<double>? caloriesKcal,
    Value<double>? averageSpeedKmh,
    Value<String>? photoRelativePath,
    Value<String?>? healthWorkoutId,
    Value<int>? rowid,
  }) {
    return ExerciseHistoriesCompanion(
      id: id ?? this.id,
      savedAt: savedAt ?? this.savedAt,
      creationStartedAt: creationStartedAt ?? this.creationStartedAt,
      capturedAt: capturedAt ?? this.capturedAt,
      recordedAt: recordedAt ?? this.recordedAt,
      recordedAtManuallySet:
          recordedAtManuallySet ?? this.recordedAtManuallySet,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMs: durationMs ?? this.durationMs,
      caloriesKcal: caloriesKcal ?? this.caloriesKcal,
      averageSpeedKmh: averageSpeedKmh ?? this.averageSpeedKmh,
      photoRelativePath: photoRelativePath ?? this.photoRelativePath,
      healthWorkoutId: healthWorkoutId ?? this.healthWorkoutId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<String>(savedAt.value);
    }
    if (creationStartedAt.present) {
      map['creation_started_at'] = Variable<String>(creationStartedAt.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<String>(capturedAt.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<String>(recordedAt.value);
    }
    if (recordedAtManuallySet.present) {
      map['recorded_at_manually_set'] = Variable<bool>(
        recordedAtManuallySet.value,
      );
    }
    if (distanceKm.present) {
      map['distance_km'] = Variable<double>(distanceKm.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (caloriesKcal.present) {
      map['calories_kcal'] = Variable<double>(caloriesKcal.value);
    }
    if (averageSpeedKmh.present) {
      map['average_speed_kmh'] = Variable<double>(averageSpeedKmh.value);
    }
    if (photoRelativePath.present) {
      map['photo_relative_path'] = Variable<String>(photoRelativePath.value);
    }
    if (healthWorkoutId.present) {
      map['health_workout_id'] = Variable<String>(healthWorkoutId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseHistoriesCompanion(')
          ..write('id: $id, ')
          ..write('savedAt: $savedAt, ')
          ..write('creationStartedAt: $creationStartedAt, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('recordedAtManuallySet: $recordedAtManuallySet, ')
          ..write('distanceKm: $distanceKm, ')
          ..write('durationMs: $durationMs, ')
          ..write('caloriesKcal: $caloriesKcal, ')
          ..write('averageSpeedKmh: $averageSpeedKmh, ')
          ..write('photoRelativePath: $photoRelativePath, ')
          ..write('healthWorkoutId: $healthWorkoutId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ExerciseHistoriesTable exerciseHistories =
      $ExerciseHistoriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [exerciseHistories];
}

typedef $$ExerciseHistoriesTableCreateCompanionBuilder =
    ExerciseHistoriesCompanion Function({
      required String id,
      required String savedAt,
      required String creationStartedAt,
      required String capturedAt,
      required String recordedAt,
      required bool recordedAtManuallySet,
      required double distanceKm,
      required int durationMs,
      required double caloriesKcal,
      required double averageSpeedKmh,
      required String photoRelativePath,
      Value<String?> healthWorkoutId,
      Value<int> rowid,
    });
typedef $$ExerciseHistoriesTableUpdateCompanionBuilder =
    ExerciseHistoriesCompanion Function({
      Value<String> id,
      Value<String> savedAt,
      Value<String> creationStartedAt,
      Value<String> capturedAt,
      Value<String> recordedAt,
      Value<bool> recordedAtManuallySet,
      Value<double> distanceKm,
      Value<int> durationMs,
      Value<double> caloriesKcal,
      Value<double> averageSpeedKmh,
      Value<String> photoRelativePath,
      Value<String?> healthWorkoutId,
      Value<int> rowid,
    });

class $$ExerciseHistoriesTableFilterComposer
    extends Composer<_$AppDatabase, $ExerciseHistoriesTable> {
  $$ExerciseHistoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get creationStartedAt => $composableBuilder(
    column: $table.creationStartedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get recordedAtManuallySet => $composableBuilder(
    column: $table.recordedAtManuallySet,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceKm => $composableBuilder(
    column: $table.distanceKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get caloriesKcal => $composableBuilder(
    column: $table.caloriesKcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get averageSpeedKmh => $composableBuilder(
    column: $table.averageSpeedKmh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoRelativePath => $composableBuilder(
    column: $table.photoRelativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get healthWorkoutId => $composableBuilder(
    column: $table.healthWorkoutId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExerciseHistoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseHistoriesTable> {
  $$ExerciseHistoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get creationStartedAt => $composableBuilder(
    column: $table.creationStartedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get recordedAtManuallySet => $composableBuilder(
    column: $table.recordedAtManuallySet,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceKm => $composableBuilder(
    column: $table.distanceKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get caloriesKcal => $composableBuilder(
    column: $table.caloriesKcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get averageSpeedKmh => $composableBuilder(
    column: $table.averageSpeedKmh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoRelativePath => $composableBuilder(
    column: $table.photoRelativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get healthWorkoutId => $composableBuilder(
    column: $table.healthWorkoutId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExerciseHistoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseHistoriesTable> {
  $$ExerciseHistoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);

  GeneratedColumn<String> get creationStartedAt => $composableBuilder(
    column: $table.creationStartedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get recordedAtManuallySet => $composableBuilder(
    column: $table.recordedAtManuallySet,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceKm => $composableBuilder(
    column: $table.distanceKm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<double> get caloriesKcal => $composableBuilder(
    column: $table.caloriesKcal,
    builder: (column) => column,
  );

  GeneratedColumn<double> get averageSpeedKmh => $composableBuilder(
    column: $table.averageSpeedKmh,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoRelativePath => $composableBuilder(
    column: $table.photoRelativePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get healthWorkoutId => $composableBuilder(
    column: $table.healthWorkoutId,
    builder: (column) => column,
  );
}

class $$ExerciseHistoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExerciseHistoriesTable,
          ExerciseHistoryRow,
          $$ExerciseHistoriesTableFilterComposer,
          $$ExerciseHistoriesTableOrderingComposer,
          $$ExerciseHistoriesTableAnnotationComposer,
          $$ExerciseHistoriesTableCreateCompanionBuilder,
          $$ExerciseHistoriesTableUpdateCompanionBuilder,
          (
            ExerciseHistoryRow,
            BaseReferences<
              _$AppDatabase,
              $ExerciseHistoriesTable,
              ExerciseHistoryRow
            >,
          ),
          ExerciseHistoryRow,
          PrefetchHooks Function()
        > {
  $$ExerciseHistoriesTableTableManager(
    _$AppDatabase db,
    $ExerciseHistoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseHistoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseHistoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseHistoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> savedAt = const Value.absent(),
                Value<String> creationStartedAt = const Value.absent(),
                Value<String> capturedAt = const Value.absent(),
                Value<String> recordedAt = const Value.absent(),
                Value<bool> recordedAtManuallySet = const Value.absent(),
                Value<double> distanceKm = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<double> caloriesKcal = const Value.absent(),
                Value<double> averageSpeedKmh = const Value.absent(),
                Value<String> photoRelativePath = const Value.absent(),
                Value<String?> healthWorkoutId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseHistoriesCompanion(
                id: id,
                savedAt: savedAt,
                creationStartedAt: creationStartedAt,
                capturedAt: capturedAt,
                recordedAt: recordedAt,
                recordedAtManuallySet: recordedAtManuallySet,
                distanceKm: distanceKm,
                durationMs: durationMs,
                caloriesKcal: caloriesKcal,
                averageSpeedKmh: averageSpeedKmh,
                photoRelativePath: photoRelativePath,
                healthWorkoutId: healthWorkoutId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String savedAt,
                required String creationStartedAt,
                required String capturedAt,
                required String recordedAt,
                required bool recordedAtManuallySet,
                required double distanceKm,
                required int durationMs,
                required double caloriesKcal,
                required double averageSpeedKmh,
                required String photoRelativePath,
                Value<String?> healthWorkoutId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseHistoriesCompanion.insert(
                id: id,
                savedAt: savedAt,
                creationStartedAt: creationStartedAt,
                capturedAt: capturedAt,
                recordedAt: recordedAt,
                recordedAtManuallySet: recordedAtManuallySet,
                distanceKm: distanceKm,
                durationMs: durationMs,
                caloriesKcal: caloriesKcal,
                averageSpeedKmh: averageSpeedKmh,
                photoRelativePath: photoRelativePath,
                healthWorkoutId: healthWorkoutId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExerciseHistoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExerciseHistoriesTable,
      ExerciseHistoryRow,
      $$ExerciseHistoriesTableFilterComposer,
      $$ExerciseHistoriesTableOrderingComposer,
      $$ExerciseHistoriesTableAnnotationComposer,
      $$ExerciseHistoriesTableCreateCompanionBuilder,
      $$ExerciseHistoriesTableUpdateCompanionBuilder,
      (
        ExerciseHistoryRow,
        BaseReferences<
          _$AppDatabase,
          $ExerciseHistoriesTable,
          ExerciseHistoryRow
        >,
      ),
      ExerciseHistoryRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ExerciseHistoriesTableTableManager get exerciseHistories =>
      $$ExerciseHistoriesTableTableManager(_db, _db.exerciseHistories);
}
