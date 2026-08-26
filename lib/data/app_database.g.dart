// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LibraryEntriesTable extends LibraryEntries
    with TableInfo<$LibraryEntriesTable, LibraryEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibraryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _mediaIdMeta = const VerificationMeta(
    'mediaId',
  );
  @override
  late final GeneratedColumn<String> mediaId = GeneratedColumn<String>(
    'media_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaTypeMeta = const VerificationMeta(
    'mediaType',
  );
  @override
  late final GeneratedColumn<String> mediaType = GeneratedColumn<String>(
    'media_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    mediaId,
    mediaType,
    status,
    isFavorite,
    addedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'library_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<LibraryEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('media_id')) {
      context.handle(
        _mediaIdMeta,
        mediaId.isAcceptableOrUnknown(data['media_id']!, _mediaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mediaIdMeta);
    }
    if (data.containsKey('media_type')) {
      context.handle(
        _mediaTypeMeta,
        mediaType.isAcceptableOrUnknown(data['media_type']!, _mediaTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mediaTypeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {mediaId};
  @override
  LibraryEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryEntryRow(
      mediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_id'],
      )!,
      mediaType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $LibraryEntriesTable createAlias(String alias) {
    return $LibraryEntriesTable(attachedDatabase, alias);
  }
}

class LibraryEntryRow extends DataClass implements Insertable<LibraryEntryRow> {
  final String mediaId;
  final String mediaType;
  final String status;
  final bool isFavorite;
  final DateTime addedAt;
  const LibraryEntryRow({
    required this.mediaId,
    required this.mediaType,
    required this.status,
    required this.isFavorite,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['media_id'] = Variable<String>(mediaId);
    map['media_type'] = Variable<String>(mediaType);
    map['status'] = Variable<String>(status);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  LibraryEntriesCompanion toCompanion(bool nullToAbsent) {
    return LibraryEntriesCompanion(
      mediaId: Value(mediaId),
      mediaType: Value(mediaType),
      status: Value(status),
      isFavorite: Value(isFavorite),
      addedAt: Value(addedAt),
    );
  }

  factory LibraryEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryEntryRow(
      mediaId: serializer.fromJson<String>(json['mediaId']),
      mediaType: serializer.fromJson<String>(json['mediaType']),
      status: serializer.fromJson<String>(json['status']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mediaId': serializer.toJson<String>(mediaId),
      'mediaType': serializer.toJson<String>(mediaType),
      'status': serializer.toJson<String>(status),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  LibraryEntryRow copyWith({
    String? mediaId,
    String? mediaType,
    String? status,
    bool? isFavorite,
    DateTime? addedAt,
  }) => LibraryEntryRow(
    mediaId: mediaId ?? this.mediaId,
    mediaType: mediaType ?? this.mediaType,
    status: status ?? this.status,
    isFavorite: isFavorite ?? this.isFavorite,
    addedAt: addedAt ?? this.addedAt,
  );
  LibraryEntryRow copyWithCompanion(LibraryEntriesCompanion data) {
    return LibraryEntryRow(
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      status: data.status.present ? data.status.value : this.status,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryEntryRow(')
          ..write('mediaId: $mediaId, ')
          ..write('mediaType: $mediaType, ')
          ..write('status: $status, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(mediaId, mediaType, status, isFavorite, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryEntryRow &&
          other.mediaId == this.mediaId &&
          other.mediaType == this.mediaType &&
          other.status == this.status &&
          other.isFavorite == this.isFavorite &&
          other.addedAt == this.addedAt);
}

class LibraryEntriesCompanion extends UpdateCompanion<LibraryEntryRow> {
  final Value<String> mediaId;
  final Value<String> mediaType;
  final Value<String> status;
  final Value<bool> isFavorite;
  final Value<DateTime> addedAt;
  final Value<int> rowid;
  const LibraryEntriesCompanion({
    this.mediaId = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.status = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LibraryEntriesCompanion.insert({
    required String mediaId,
    required String mediaType,
    required String status,
    this.isFavorite = const Value.absent(),
    required DateTime addedAt,
    this.rowid = const Value.absent(),
  }) : mediaId = Value(mediaId),
       mediaType = Value(mediaType),
       status = Value(status),
       addedAt = Value(addedAt);
  static Insertable<LibraryEntryRow> custom({
    Expression<String>? mediaId,
    Expression<String>? mediaType,
    Expression<String>? status,
    Expression<bool>? isFavorite,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (mediaId != null) 'media_id': mediaId,
      if (mediaType != null) 'media_type': mediaType,
      if (status != null) 'status': status,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LibraryEntriesCompanion copyWith({
    Value<String>? mediaId,
    Value<String>? mediaType,
    Value<String>? status,
    Value<bool>? isFavorite,
    Value<DateTime>? addedAt,
    Value<int>? rowid,
  }) {
    return LibraryEntriesCompanion(
      mediaId: mediaId ?? this.mediaId,
      mediaType: mediaType ?? this.mediaType,
      status: status ?? this.status,
      isFavorite: isFavorite ?? this.isFavorite,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (mediaId.present) {
      map['media_id'] = Variable<String>(mediaId.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<String>(mediaType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LibraryEntriesCompanion(')
          ..write('mediaId: $mediaId, ')
          ..write('mediaType: $mediaType, ')
          ..write('status: $status, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MangaProgressEntriesTable extends MangaProgressEntries
    with TableInfo<$MangaProgressEntriesTable, MangaProgressEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MangaProgressEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _mediaIdMeta = const VerificationMeta(
    'mediaId',
  );
  @override
  late final GeneratedColumn<String> mediaId = GeneratedColumn<String>(
    'media_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageMeta = const VerificationMeta('page');
  @override
  late final GeneratedColumn<int> page = GeneratedColumn<int>(
    'page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [mediaId, chapterId, page, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'manga_progress_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<MangaProgressEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('media_id')) {
      context.handle(
        _mediaIdMeta,
        mediaId.isAcceptableOrUnknown(data['media_id']!, _mediaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mediaIdMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('page')) {
      context.handle(
        _pageMeta,
        page.isAcceptableOrUnknown(data['page']!, _pageMeta),
      );
    } else if (isInserting) {
      context.missing(_pageMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {mediaId};
  @override
  MangaProgressEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MangaProgressEntry(
      mediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_id'],
      )!,
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_id'],
      )!,
      page: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MangaProgressEntriesTable createAlias(String alias) {
    return $MangaProgressEntriesTable(attachedDatabase, alias);
  }
}

class MangaProgressEntry extends DataClass
    implements Insertable<MangaProgressEntry> {
  final String mediaId;
  final String chapterId;
  final int page;
  final DateTime updatedAt;
  const MangaProgressEntry({
    required this.mediaId,
    required this.chapterId,
    required this.page,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['media_id'] = Variable<String>(mediaId);
    map['chapter_id'] = Variable<String>(chapterId);
    map['page'] = Variable<int>(page);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MangaProgressEntriesCompanion toCompanion(bool nullToAbsent) {
    return MangaProgressEntriesCompanion(
      mediaId: Value(mediaId),
      chapterId: Value(chapterId),
      page: Value(page),
      updatedAt: Value(updatedAt),
    );
  }

  factory MangaProgressEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MangaProgressEntry(
      mediaId: serializer.fromJson<String>(json['mediaId']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      page: serializer.fromJson<int>(json['page']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mediaId': serializer.toJson<String>(mediaId),
      'chapterId': serializer.toJson<String>(chapterId),
      'page': serializer.toJson<int>(page),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MangaProgressEntry copyWith({
    String? mediaId,
    String? chapterId,
    int? page,
    DateTime? updatedAt,
  }) => MangaProgressEntry(
    mediaId: mediaId ?? this.mediaId,
    chapterId: chapterId ?? this.chapterId,
    page: page ?? this.page,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MangaProgressEntry copyWithCompanion(MangaProgressEntriesCompanion data) {
    return MangaProgressEntry(
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      page: data.page.present ? data.page.value : this.page,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MangaProgressEntry(')
          ..write('mediaId: $mediaId, ')
          ..write('chapterId: $chapterId, ')
          ..write('page: $page, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(mediaId, chapterId, page, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MangaProgressEntry &&
          other.mediaId == this.mediaId &&
          other.chapterId == this.chapterId &&
          other.page == this.page &&
          other.updatedAt == this.updatedAt);
}

class MangaProgressEntriesCompanion
    extends UpdateCompanion<MangaProgressEntry> {
  final Value<String> mediaId;
  final Value<String> chapterId;
  final Value<int> page;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MangaProgressEntriesCompanion({
    this.mediaId = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.page = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MangaProgressEntriesCompanion.insert({
    required String mediaId,
    required String chapterId,
    required int page,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : mediaId = Value(mediaId),
       chapterId = Value(chapterId),
       page = Value(page),
       updatedAt = Value(updatedAt);
  static Insertable<MangaProgressEntry> custom({
    Expression<String>? mediaId,
    Expression<String>? chapterId,
    Expression<int>? page,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (mediaId != null) 'media_id': mediaId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (page != null) 'page': page,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MangaProgressEntriesCompanion copyWith({
    Value<String>? mediaId,
    Value<String>? chapterId,
    Value<int>? page,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MangaProgressEntriesCompanion(
      mediaId: mediaId ?? this.mediaId,
      chapterId: chapterId ?? this.chapterId,
      page: page ?? this.page,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (mediaId.present) {
      map['media_id'] = Variable<String>(mediaId.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (page.present) {
      map['page'] = Variable<int>(page.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MangaProgressEntriesCompanion(')
          ..write('mediaId: $mediaId, ')
          ..write('chapterId: $chapterId, ')
          ..write('page: $page, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnimeProgressEntriesTable extends AnimeProgressEntries
    with TableInfo<$AnimeProgressEntriesTable, AnimeProgressEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnimeProgressEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _mediaIdMeta = const VerificationMeta(
    'mediaId',
  );
  @override
  late final GeneratedColumn<String> mediaId = GeneratedColumn<String>(
    'media_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _episodeIdMeta = const VerificationMeta(
    'episodeId',
  );
  @override
  late final GeneratedColumn<String> episodeId = GeneratedColumn<String>(
    'episode_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionSecondsMeta = const VerificationMeta(
    'positionSeconds',
  );
  @override
  late final GeneratedColumn<int> positionSeconds = GeneratedColumn<int>(
    'position_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    mediaId,
    episodeId,
    positionSeconds,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'anime_progress_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<AnimeProgressEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('media_id')) {
      context.handle(
        _mediaIdMeta,
        mediaId.isAcceptableOrUnknown(data['media_id']!, _mediaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mediaIdMeta);
    }
    if (data.containsKey('episode_id')) {
      context.handle(
        _episodeIdMeta,
        episodeId.isAcceptableOrUnknown(data['episode_id']!, _episodeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_episodeIdMeta);
    }
    if (data.containsKey('position_seconds')) {
      context.handle(
        _positionSecondsMeta,
        positionSeconds.isAcceptableOrUnknown(
          data['position_seconds']!,
          _positionSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_positionSecondsMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {mediaId};
  @override
  AnimeProgressEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnimeProgressEntry(
      mediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_id'],
      )!,
      episodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}episode_id'],
      )!,
      positionSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_seconds'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AnimeProgressEntriesTable createAlias(String alias) {
    return $AnimeProgressEntriesTable(attachedDatabase, alias);
  }
}

class AnimeProgressEntry extends DataClass
    implements Insertable<AnimeProgressEntry> {
  final String mediaId;
  final String episodeId;
  final int positionSeconds;
  final DateTime updatedAt;
  const AnimeProgressEntry({
    required this.mediaId,
    required this.episodeId,
    required this.positionSeconds,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['media_id'] = Variable<String>(mediaId);
    map['episode_id'] = Variable<String>(episodeId);
    map['position_seconds'] = Variable<int>(positionSeconds);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AnimeProgressEntriesCompanion toCompanion(bool nullToAbsent) {
    return AnimeProgressEntriesCompanion(
      mediaId: Value(mediaId),
      episodeId: Value(episodeId),
      positionSeconds: Value(positionSeconds),
      updatedAt: Value(updatedAt),
    );
  }

  factory AnimeProgressEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnimeProgressEntry(
      mediaId: serializer.fromJson<String>(json['mediaId']),
      episodeId: serializer.fromJson<String>(json['episodeId']),
      positionSeconds: serializer.fromJson<int>(json['positionSeconds']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mediaId': serializer.toJson<String>(mediaId),
      'episodeId': serializer.toJson<String>(episodeId),
      'positionSeconds': serializer.toJson<int>(positionSeconds),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AnimeProgressEntry copyWith({
    String? mediaId,
    String? episodeId,
    int? positionSeconds,
    DateTime? updatedAt,
  }) => AnimeProgressEntry(
    mediaId: mediaId ?? this.mediaId,
    episodeId: episodeId ?? this.episodeId,
    positionSeconds: positionSeconds ?? this.positionSeconds,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AnimeProgressEntry copyWithCompanion(AnimeProgressEntriesCompanion data) {
    return AnimeProgressEntry(
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
      episodeId: data.episodeId.present ? data.episodeId.value : this.episodeId,
      positionSeconds: data.positionSeconds.present
          ? data.positionSeconds.value
          : this.positionSeconds,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnimeProgressEntry(')
          ..write('mediaId: $mediaId, ')
          ..write('episodeId: $episodeId, ')
          ..write('positionSeconds: $positionSeconds, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(mediaId, episodeId, positionSeconds, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnimeProgressEntry &&
          other.mediaId == this.mediaId &&
          other.episodeId == this.episodeId &&
          other.positionSeconds == this.positionSeconds &&
          other.updatedAt == this.updatedAt);
}

class AnimeProgressEntriesCompanion
    extends UpdateCompanion<AnimeProgressEntry> {
  final Value<String> mediaId;
  final Value<String> episodeId;
  final Value<int> positionSeconds;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AnimeProgressEntriesCompanion({
    this.mediaId = const Value.absent(),
    this.episodeId = const Value.absent(),
    this.positionSeconds = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnimeProgressEntriesCompanion.insert({
    required String mediaId,
    required String episodeId,
    required int positionSeconds,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : mediaId = Value(mediaId),
       episodeId = Value(episodeId),
       positionSeconds = Value(positionSeconds),
       updatedAt = Value(updatedAt);
  static Insertable<AnimeProgressEntry> custom({
    Expression<String>? mediaId,
    Expression<String>? episodeId,
    Expression<int>? positionSeconds,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (mediaId != null) 'media_id': mediaId,
      if (episodeId != null) 'episode_id': episodeId,
      if (positionSeconds != null) 'position_seconds': positionSeconds,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnimeProgressEntriesCompanion copyWith({
    Value<String>? mediaId,
    Value<String>? episodeId,
    Value<int>? positionSeconds,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AnimeProgressEntriesCompanion(
      mediaId: mediaId ?? this.mediaId,
      episodeId: episodeId ?? this.episodeId,
      positionSeconds: positionSeconds ?? this.positionSeconds,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (mediaId.present) {
      map['media_id'] = Variable<String>(mediaId.value);
    }
    if (episodeId.present) {
      map['episode_id'] = Variable<String>(episodeId.value);
    }
    if (positionSeconds.present) {
      map['position_seconds'] = Variable<int>(positionSeconds.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnimeProgressEntriesCompanion(')
          ..write('mediaId: $mediaId, ')
          ..write('episodeId: $episodeId, ')
          ..write('positionSeconds: $positionSeconds, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SourceBindingsTable extends SourceBindings
    with TableInfo<$SourceBindingsTable, SourceBindingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SourceBindingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _mediaIdMeta = const VerificationMeta(
    'mediaId',
  );
  @override
  late final GeneratedColumn<String> mediaId = GeneratedColumn<String>(
    'media_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerKeyMeta = const VerificationMeta(
    'providerKey',
  );
  @override
  late final GeneratedColumn<String> providerKey = GeneratedColumn<String>(
    'provider_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerMediaIdMeta = const VerificationMeta(
    'providerMediaId',
  );
  @override
  late final GeneratedColumn<String> providerMediaId = GeneratedColumn<String>(
    'provider_media_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    mediaId,
    providerKey,
    providerMediaId,
    url,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'source_bindings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SourceBindingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('media_id')) {
      context.handle(
        _mediaIdMeta,
        mediaId.isAcceptableOrUnknown(data['media_id']!, _mediaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mediaIdMeta);
    }
    if (data.containsKey('provider_key')) {
      context.handle(
        _providerKeyMeta,
        providerKey.isAcceptableOrUnknown(
          data['provider_key']!,
          _providerKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_providerKeyMeta);
    }
    if (data.containsKey('provider_media_id')) {
      context.handle(
        _providerMediaIdMeta,
        providerMediaId.isAcceptableOrUnknown(
          data['provider_media_id']!,
          _providerMediaIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_providerMediaIdMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {mediaId, providerKey};
  @override
  SourceBindingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SourceBindingRow(
      mediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_id'],
      )!,
      providerKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_key'],
      )!,
      providerMediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_media_id'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      ),
    );
  }

  @override
  $SourceBindingsTable createAlias(String alias) {
    return $SourceBindingsTable(attachedDatabase, alias);
  }
}

class SourceBindingRow extends DataClass
    implements Insertable<SourceBindingRow> {
  final String mediaId;
  final String providerKey;
  final String providerMediaId;
  final String? url;
  const SourceBindingRow({
    required this.mediaId,
    required this.providerKey,
    required this.providerMediaId,
    this.url,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['media_id'] = Variable<String>(mediaId);
    map['provider_key'] = Variable<String>(providerKey);
    map['provider_media_id'] = Variable<String>(providerMediaId);
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    return map;
  }

  SourceBindingsCompanion toCompanion(bool nullToAbsent) {
    return SourceBindingsCompanion(
      mediaId: Value(mediaId),
      providerKey: Value(providerKey),
      providerMediaId: Value(providerMediaId),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
    );
  }

  factory SourceBindingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SourceBindingRow(
      mediaId: serializer.fromJson<String>(json['mediaId']),
      providerKey: serializer.fromJson<String>(json['providerKey']),
      providerMediaId: serializer.fromJson<String>(json['providerMediaId']),
      url: serializer.fromJson<String?>(json['url']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mediaId': serializer.toJson<String>(mediaId),
      'providerKey': serializer.toJson<String>(providerKey),
      'providerMediaId': serializer.toJson<String>(providerMediaId),
      'url': serializer.toJson<String?>(url),
    };
  }

  SourceBindingRow copyWith({
    String? mediaId,
    String? providerKey,
    String? providerMediaId,
    Value<String?> url = const Value.absent(),
  }) => SourceBindingRow(
    mediaId: mediaId ?? this.mediaId,
    providerKey: providerKey ?? this.providerKey,
    providerMediaId: providerMediaId ?? this.providerMediaId,
    url: url.present ? url.value : this.url,
  );
  SourceBindingRow copyWithCompanion(SourceBindingsCompanion data) {
    return SourceBindingRow(
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
      providerKey: data.providerKey.present
          ? data.providerKey.value
          : this.providerKey,
      providerMediaId: data.providerMediaId.present
          ? data.providerMediaId.value
          : this.providerMediaId,
      url: data.url.present ? data.url.value : this.url,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SourceBindingRow(')
          ..write('mediaId: $mediaId, ')
          ..write('providerKey: $providerKey, ')
          ..write('providerMediaId: $providerMediaId, ')
          ..write('url: $url')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(mediaId, providerKey, providerMediaId, url);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SourceBindingRow &&
          other.mediaId == this.mediaId &&
          other.providerKey == this.providerKey &&
          other.providerMediaId == this.providerMediaId &&
          other.url == this.url);
}

class SourceBindingsCompanion extends UpdateCompanion<SourceBindingRow> {
  final Value<String> mediaId;
  final Value<String> providerKey;
  final Value<String> providerMediaId;
  final Value<String?> url;
  final Value<int> rowid;
  const SourceBindingsCompanion({
    this.mediaId = const Value.absent(),
    this.providerKey = const Value.absent(),
    this.providerMediaId = const Value.absent(),
    this.url = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SourceBindingsCompanion.insert({
    required String mediaId,
    required String providerKey,
    required String providerMediaId,
    this.url = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : mediaId = Value(mediaId),
       providerKey = Value(providerKey),
       providerMediaId = Value(providerMediaId);
  static Insertable<SourceBindingRow> custom({
    Expression<String>? mediaId,
    Expression<String>? providerKey,
    Expression<String>? providerMediaId,
    Expression<String>? url,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (mediaId != null) 'media_id': mediaId,
      if (providerKey != null) 'provider_key': providerKey,
      if (providerMediaId != null) 'provider_media_id': providerMediaId,
      if (url != null) 'url': url,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SourceBindingsCompanion copyWith({
    Value<String>? mediaId,
    Value<String>? providerKey,
    Value<String>? providerMediaId,
    Value<String?>? url,
    Value<int>? rowid,
  }) {
    return SourceBindingsCompanion(
      mediaId: mediaId ?? this.mediaId,
      providerKey: providerKey ?? this.providerKey,
      providerMediaId: providerMediaId ?? this.providerMediaId,
      url: url ?? this.url,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (mediaId.present) {
      map['media_id'] = Variable<String>(mediaId.value);
    }
    if (providerKey.present) {
      map['provider_key'] = Variable<String>(providerKey.value);
    }
    if (providerMediaId.present) {
      map['provider_media_id'] = Variable<String>(providerMediaId.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SourceBindingsCompanion(')
          ..write('mediaId: $mediaId, ')
          ..write('providerKey: $providerKey, ')
          ..write('providerMediaId: $providerMediaId, ')
          ..write('url: $url, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LibraryEntriesTable libraryEntries = $LibraryEntriesTable(this);
  late final $MangaProgressEntriesTable mangaProgressEntries =
      $MangaProgressEntriesTable(this);
  late final $AnimeProgressEntriesTable animeProgressEntries =
      $AnimeProgressEntriesTable(this);
  late final $SourceBindingsTable sourceBindings = $SourceBindingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    libraryEntries,
    mangaProgressEntries,
    animeProgressEntries,
    sourceBindings,
  ];
}

typedef $$LibraryEntriesTableCreateCompanionBuilder =
    LibraryEntriesCompanion Function({
      required String mediaId,
      required String mediaType,
      required String status,
      Value<bool> isFavorite,
      required DateTime addedAt,
      Value<int> rowid,
    });
typedef $$LibraryEntriesTableUpdateCompanionBuilder =
    LibraryEntriesCompanion Function({
      Value<String> mediaId,
      Value<String> mediaType,
      Value<String> status,
      Value<bool> isFavorite,
      Value<DateTime> addedAt,
      Value<int> rowid,
    });

class $$LibraryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LibraryEntriesTable> {
  $$LibraryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get mediaId => $composableBuilder(
    column: $table.mediaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LibraryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LibraryEntriesTable> {
  $$LibraryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get mediaId => $composableBuilder(
    column: $table.mediaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LibraryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LibraryEntriesTable> {
  $$LibraryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get mediaId =>
      $composableBuilder(column: $table.mediaId, builder: (column) => column);

  GeneratedColumn<String> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $$LibraryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LibraryEntriesTable,
          LibraryEntryRow,
          $$LibraryEntriesTableFilterComposer,
          $$LibraryEntriesTableOrderingComposer,
          $$LibraryEntriesTableAnnotationComposer,
          $$LibraryEntriesTableCreateCompanionBuilder,
          $$LibraryEntriesTableUpdateCompanionBuilder,
          (
            LibraryEntryRow,
            BaseReferences<
              _$AppDatabase,
              $LibraryEntriesTable,
              LibraryEntryRow
            >,
          ),
          LibraryEntryRow,
          PrefetchHooks Function()
        > {
  $$LibraryEntriesTableTableManager(
    _$AppDatabase db,
    $LibraryEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LibraryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LibraryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LibraryEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> mediaId = const Value.absent(),
                Value<String> mediaType = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryEntriesCompanion(
                mediaId: mediaId,
                mediaType: mediaType,
                status: status,
                isFavorite: isFavorite,
                addedAt: addedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String mediaId,
                required String mediaType,
                required String status,
                Value<bool> isFavorite = const Value.absent(),
                required DateTime addedAt,
                Value<int> rowid = const Value.absent(),
              }) => LibraryEntriesCompanion.insert(
                mediaId: mediaId,
                mediaType: mediaType,
                status: status,
                isFavorite: isFavorite,
                addedAt: addedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LibraryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LibraryEntriesTable,
      LibraryEntryRow,
      $$LibraryEntriesTableFilterComposer,
      $$LibraryEntriesTableOrderingComposer,
      $$LibraryEntriesTableAnnotationComposer,
      $$LibraryEntriesTableCreateCompanionBuilder,
      $$LibraryEntriesTableUpdateCompanionBuilder,
      (
        LibraryEntryRow,
        BaseReferences<_$AppDatabase, $LibraryEntriesTable, LibraryEntryRow>,
      ),
      LibraryEntryRow,
      PrefetchHooks Function()
    >;
typedef $$MangaProgressEntriesTableCreateCompanionBuilder =
    MangaProgressEntriesCompanion Function({
      required String mediaId,
      required String chapterId,
      required int page,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$MangaProgressEntriesTableUpdateCompanionBuilder =
    MangaProgressEntriesCompanion Function({
      Value<String> mediaId,
      Value<String> chapterId,
      Value<int> page,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$MangaProgressEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $MangaProgressEntriesTable> {
  $$MangaProgressEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get mediaId => $composableBuilder(
    column: $table.mediaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MangaProgressEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $MangaProgressEntriesTable> {
  $$MangaProgressEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get mediaId => $composableBuilder(
    column: $table.mediaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MangaProgressEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MangaProgressEntriesTable> {
  $$MangaProgressEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get mediaId =>
      $composableBuilder(column: $table.mediaId, builder: (column) => column);

  GeneratedColumn<String> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<int> get page =>
      $composableBuilder(column: $table.page, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MangaProgressEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MangaProgressEntriesTable,
          MangaProgressEntry,
          $$MangaProgressEntriesTableFilterComposer,
          $$MangaProgressEntriesTableOrderingComposer,
          $$MangaProgressEntriesTableAnnotationComposer,
          $$MangaProgressEntriesTableCreateCompanionBuilder,
          $$MangaProgressEntriesTableUpdateCompanionBuilder,
          (
            MangaProgressEntry,
            BaseReferences<
              _$AppDatabase,
              $MangaProgressEntriesTable,
              MangaProgressEntry
            >,
          ),
          MangaProgressEntry,
          PrefetchHooks Function()
        > {
  $$MangaProgressEntriesTableTableManager(
    _$AppDatabase db,
    $MangaProgressEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MangaProgressEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MangaProgressEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MangaProgressEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> mediaId = const Value.absent(),
                Value<String> chapterId = const Value.absent(),
                Value<int> page = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MangaProgressEntriesCompanion(
                mediaId: mediaId,
                chapterId: chapterId,
                page: page,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String mediaId,
                required String chapterId,
                required int page,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MangaProgressEntriesCompanion.insert(
                mediaId: mediaId,
                chapterId: chapterId,
                page: page,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MangaProgressEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MangaProgressEntriesTable,
      MangaProgressEntry,
      $$MangaProgressEntriesTableFilterComposer,
      $$MangaProgressEntriesTableOrderingComposer,
      $$MangaProgressEntriesTableAnnotationComposer,
      $$MangaProgressEntriesTableCreateCompanionBuilder,
      $$MangaProgressEntriesTableUpdateCompanionBuilder,
      (
        MangaProgressEntry,
        BaseReferences<
          _$AppDatabase,
          $MangaProgressEntriesTable,
          MangaProgressEntry
        >,
      ),
      MangaProgressEntry,
      PrefetchHooks Function()
    >;
typedef $$AnimeProgressEntriesTableCreateCompanionBuilder =
    AnimeProgressEntriesCompanion Function({
      required String mediaId,
      required String episodeId,
      required int positionSeconds,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AnimeProgressEntriesTableUpdateCompanionBuilder =
    AnimeProgressEntriesCompanion Function({
      Value<String> mediaId,
      Value<String> episodeId,
      Value<int> positionSeconds,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AnimeProgressEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $AnimeProgressEntriesTable> {
  $$AnimeProgressEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get mediaId => $composableBuilder(
    column: $table.mediaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get episodeId => $composableBuilder(
    column: $table.episodeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionSeconds => $composableBuilder(
    column: $table.positionSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AnimeProgressEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $AnimeProgressEntriesTable> {
  $$AnimeProgressEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get mediaId => $composableBuilder(
    column: $table.mediaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get episodeId => $composableBuilder(
    column: $table.episodeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionSeconds => $composableBuilder(
    column: $table.positionSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AnimeProgressEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnimeProgressEntriesTable> {
  $$AnimeProgressEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get mediaId =>
      $composableBuilder(column: $table.mediaId, builder: (column) => column);

  GeneratedColumn<String> get episodeId =>
      $composableBuilder(column: $table.episodeId, builder: (column) => column);

  GeneratedColumn<int> get positionSeconds => $composableBuilder(
    column: $table.positionSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AnimeProgressEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AnimeProgressEntriesTable,
          AnimeProgressEntry,
          $$AnimeProgressEntriesTableFilterComposer,
          $$AnimeProgressEntriesTableOrderingComposer,
          $$AnimeProgressEntriesTableAnnotationComposer,
          $$AnimeProgressEntriesTableCreateCompanionBuilder,
          $$AnimeProgressEntriesTableUpdateCompanionBuilder,
          (
            AnimeProgressEntry,
            BaseReferences<
              _$AppDatabase,
              $AnimeProgressEntriesTable,
              AnimeProgressEntry
            >,
          ),
          AnimeProgressEntry,
          PrefetchHooks Function()
        > {
  $$AnimeProgressEntriesTableTableManager(
    _$AppDatabase db,
    $AnimeProgressEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnimeProgressEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnimeProgressEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AnimeProgressEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> mediaId = const Value.absent(),
                Value<String> episodeId = const Value.absent(),
                Value<int> positionSeconds = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AnimeProgressEntriesCompanion(
                mediaId: mediaId,
                episodeId: episodeId,
                positionSeconds: positionSeconds,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String mediaId,
                required String episodeId,
                required int positionSeconds,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AnimeProgressEntriesCompanion.insert(
                mediaId: mediaId,
                episodeId: episodeId,
                positionSeconds: positionSeconds,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AnimeProgressEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AnimeProgressEntriesTable,
      AnimeProgressEntry,
      $$AnimeProgressEntriesTableFilterComposer,
      $$AnimeProgressEntriesTableOrderingComposer,
      $$AnimeProgressEntriesTableAnnotationComposer,
      $$AnimeProgressEntriesTableCreateCompanionBuilder,
      $$AnimeProgressEntriesTableUpdateCompanionBuilder,
      (
        AnimeProgressEntry,
        BaseReferences<
          _$AppDatabase,
          $AnimeProgressEntriesTable,
          AnimeProgressEntry
        >,
      ),
      AnimeProgressEntry,
      PrefetchHooks Function()
    >;
typedef $$SourceBindingsTableCreateCompanionBuilder =
    SourceBindingsCompanion Function({
      required String mediaId,
      required String providerKey,
      required String providerMediaId,
      Value<String?> url,
      Value<int> rowid,
    });
typedef $$SourceBindingsTableUpdateCompanionBuilder =
    SourceBindingsCompanion Function({
      Value<String> mediaId,
      Value<String> providerKey,
      Value<String> providerMediaId,
      Value<String?> url,
      Value<int> rowid,
    });

class $$SourceBindingsTableFilterComposer
    extends Composer<_$AppDatabase, $SourceBindingsTable> {
  $$SourceBindingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get mediaId => $composableBuilder(
    column: $table.mediaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerKey => $composableBuilder(
    column: $table.providerKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerMediaId => $composableBuilder(
    column: $table.providerMediaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SourceBindingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SourceBindingsTable> {
  $$SourceBindingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get mediaId => $composableBuilder(
    column: $table.mediaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerKey => $composableBuilder(
    column: $table.providerKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerMediaId => $composableBuilder(
    column: $table.providerMediaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SourceBindingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SourceBindingsTable> {
  $$SourceBindingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get mediaId =>
      $composableBuilder(column: $table.mediaId, builder: (column) => column);

  GeneratedColumn<String> get providerKey => $composableBuilder(
    column: $table.providerKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerMediaId => $composableBuilder(
    column: $table.providerMediaId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);
}

class $$SourceBindingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SourceBindingsTable,
          SourceBindingRow,
          $$SourceBindingsTableFilterComposer,
          $$SourceBindingsTableOrderingComposer,
          $$SourceBindingsTableAnnotationComposer,
          $$SourceBindingsTableCreateCompanionBuilder,
          $$SourceBindingsTableUpdateCompanionBuilder,
          (
            SourceBindingRow,
            BaseReferences<
              _$AppDatabase,
              $SourceBindingsTable,
              SourceBindingRow
            >,
          ),
          SourceBindingRow,
          PrefetchHooks Function()
        > {
  $$SourceBindingsTableTableManager(
    _$AppDatabase db,
    $SourceBindingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SourceBindingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SourceBindingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SourceBindingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> mediaId = const Value.absent(),
                Value<String> providerKey = const Value.absent(),
                Value<String> providerMediaId = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SourceBindingsCompanion(
                mediaId: mediaId,
                providerKey: providerKey,
                providerMediaId: providerMediaId,
                url: url,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String mediaId,
                required String providerKey,
                required String providerMediaId,
                Value<String?> url = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SourceBindingsCompanion.insert(
                mediaId: mediaId,
                providerKey: providerKey,
                providerMediaId: providerMediaId,
                url: url,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SourceBindingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SourceBindingsTable,
      SourceBindingRow,
      $$SourceBindingsTableFilterComposer,
      $$SourceBindingsTableOrderingComposer,
      $$SourceBindingsTableAnnotationComposer,
      $$SourceBindingsTableCreateCompanionBuilder,
      $$SourceBindingsTableUpdateCompanionBuilder,
      (
        SourceBindingRow,
        BaseReferences<_$AppDatabase, $SourceBindingsTable, SourceBindingRow>,
      ),
      SourceBindingRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LibraryEntriesTableTableManager get libraryEntries =>
      $$LibraryEntriesTableTableManager(_db, _db.libraryEntries);
  $$MangaProgressEntriesTableTableManager get mangaProgressEntries =>
      $$MangaProgressEntriesTableTableManager(_db, _db.mangaProgressEntries);
  $$AnimeProgressEntriesTableTableManager get animeProgressEntries =>
      $$AnimeProgressEntriesTableTableManager(_db, _db.animeProgressEntries);
  $$SourceBindingsTableTableManager get sourceBindings =>
      $$SourceBindingsTableTableManager(_db, _db.sourceBindings);
}
