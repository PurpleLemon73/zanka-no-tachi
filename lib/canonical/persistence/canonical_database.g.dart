// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'canonical_database.dart';

// ignore_for_file: type=lint
class $CanonicalMediaRecordsTable extends CanonicalMediaRecords
    with TableInfo<$CanonicalMediaRecordsTable, CanonicalMediaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CanonicalMediaRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleProviderIdMeta = const VerificationMeta(
    'titleProviderId',
  );
  @override
  late final GeneratedColumn<String> titleProviderId = GeneratedColumn<String>(
    'title_provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleRawValueMeta = const VerificationMeta(
    'titleRawValue',
  );
  @override
  late final GeneratedColumn<String> titleRawValue = GeneratedColumn<String>(
    'title_raw_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _alternateTitlesJsonMeta =
      const VerificationMeta('alternateTitlesJson');
  @override
  late final GeneratedColumn<String> alternateTitlesJson =
      GeneratedColumn<String>(
        'alternate_titles_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionProviderIdMeta =
      const VerificationMeta('descriptionProviderId');
  @override
  late final GeneratedColumn<String> descriptionProviderId =
      GeneratedColumn<String>(
        'description_provider_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _descriptionRawValueMeta =
      const VerificationMeta('descriptionRawValue');
  @override
  late final GeneratedColumn<String> descriptionRawValue =
      GeneratedColumn<String>(
        'description_raw_value',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
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
  static const VerificationMeta _genresJsonMeta = const VerificationMeta(
    'genresJson',
  );
  @override
  late final GeneratedColumn<String> genresJson = GeneratedColumn<String>(
    'genres_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _coverLocatorMeta = const VerificationMeta(
    'coverLocator',
  );
  @override
  late final GeneratedColumn<String> coverLocator = GeneratedColumn<String>(
    'cover_locator',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _animeFormatMeta = const VerificationMeta(
    'animeFormat',
  );
  @override
  late final GeneratedColumn<String> animeFormat = GeneratedColumn<String>(
    'anime_format',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _airingSeasonMeta = const VerificationMeta(
    'airingSeason',
  );
  @override
  late final GeneratedColumn<String> airingSeason = GeneratedColumn<String>(
    'airing_season',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _airingYearMeta = const VerificationMeta(
    'airingYear',
  );
  @override
  late final GeneratedColumn<int> airingYear = GeneratedColumn<int>(
    'airing_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _airingRawLabelMeta = const VerificationMeta(
    'airingRawLabel',
  );
  @override
  late final GeneratedColumn<String> airingRawLabel = GeneratedColumn<String>(
    'airing_raw_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _narrativeSeasonMeta = const VerificationMeta(
    'narrativeSeason',
  );
  @override
  late final GeneratedColumn<int> narrativeSeason = GeneratedColumn<int>(
    'narrative_season',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _knownEpisodeTotalMeta = const VerificationMeta(
    'knownEpisodeTotal',
  );
  @override
  late final GeneratedColumn<int> knownEpisodeTotal = GeneratedColumn<int>(
    'known_episode_total',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawEpisodeTotalMeta = const VerificationMeta(
    'rawEpisodeTotal',
  );
  @override
  late final GeneratedColumn<String> rawEpisodeTotal = GeneratedColumn<String>(
    'raw_episode_total',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    title,
    titleProviderId,
    titleRawValue,
    alternateTitlesJson,
    description,
    descriptionProviderId,
    descriptionRawValue,
    status,
    genresJson,
    coverLocator,
    animeFormat,
    airingSeason,
    airingYear,
    airingRawLabel,
    narrativeSeason,
    knownEpisodeTotal,
    rawEpisodeTotal,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'canonical_media_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<CanonicalMediaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('title_provider_id')) {
      context.handle(
        _titleProviderIdMeta,
        titleProviderId.isAcceptableOrUnknown(
          data['title_provider_id']!,
          _titleProviderIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_titleProviderIdMeta);
    }
    if (data.containsKey('title_raw_value')) {
      context.handle(
        _titleRawValueMeta,
        titleRawValue.isAcceptableOrUnknown(
          data['title_raw_value']!,
          _titleRawValueMeta,
        ),
      );
    }
    if (data.containsKey('alternate_titles_json')) {
      context.handle(
        _alternateTitlesJsonMeta,
        alternateTitlesJson.isAcceptableOrUnknown(
          data['alternate_titles_json']!,
          _alternateTitlesJsonMeta,
        ),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('description_provider_id')) {
      context.handle(
        _descriptionProviderIdMeta,
        descriptionProviderId.isAcceptableOrUnknown(
          data['description_provider_id']!,
          _descriptionProviderIdMeta,
        ),
      );
    }
    if (data.containsKey('description_raw_value')) {
      context.handle(
        _descriptionRawValueMeta,
        descriptionRawValue.isAcceptableOrUnknown(
          data['description_raw_value']!,
          _descriptionRawValueMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('genres_json')) {
      context.handle(
        _genresJsonMeta,
        genresJson.isAcceptableOrUnknown(data['genres_json']!, _genresJsonMeta),
      );
    }
    if (data.containsKey('cover_locator')) {
      context.handle(
        _coverLocatorMeta,
        coverLocator.isAcceptableOrUnknown(
          data['cover_locator']!,
          _coverLocatorMeta,
        ),
      );
    }
    if (data.containsKey('anime_format')) {
      context.handle(
        _animeFormatMeta,
        animeFormat.isAcceptableOrUnknown(
          data['anime_format']!,
          _animeFormatMeta,
        ),
      );
    }
    if (data.containsKey('airing_season')) {
      context.handle(
        _airingSeasonMeta,
        airingSeason.isAcceptableOrUnknown(
          data['airing_season']!,
          _airingSeasonMeta,
        ),
      );
    }
    if (data.containsKey('airing_year')) {
      context.handle(
        _airingYearMeta,
        airingYear.isAcceptableOrUnknown(data['airing_year']!, _airingYearMeta),
      );
    }
    if (data.containsKey('airing_raw_label')) {
      context.handle(
        _airingRawLabelMeta,
        airingRawLabel.isAcceptableOrUnknown(
          data['airing_raw_label']!,
          _airingRawLabelMeta,
        ),
      );
    }
    if (data.containsKey('narrative_season')) {
      context.handle(
        _narrativeSeasonMeta,
        narrativeSeason.isAcceptableOrUnknown(
          data['narrative_season']!,
          _narrativeSeasonMeta,
        ),
      );
    }
    if (data.containsKey('known_episode_total')) {
      context.handle(
        _knownEpisodeTotalMeta,
        knownEpisodeTotal.isAcceptableOrUnknown(
          data['known_episode_total']!,
          _knownEpisodeTotalMeta,
        ),
      );
    }
    if (data.containsKey('raw_episode_total')) {
      context.handle(
        _rawEpisodeTotalMeta,
        rawEpisodeTotal.isAcceptableOrUnknown(
          data['raw_episode_total']!,
          _rawEpisodeTotalMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CanonicalMediaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CanonicalMediaRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      titleProviderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_provider_id'],
      )!,
      titleRawValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_raw_value'],
      ),
      alternateTitlesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alternate_titles_json'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      descriptionProviderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description_provider_id'],
      ),
      descriptionRawValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description_raw_value'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      genresJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genres_json'],
      )!,
      coverLocator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_locator'],
      ),
      animeFormat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}anime_format'],
      ),
      airingSeason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}airing_season'],
      ),
      airingYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}airing_year'],
      ),
      airingRawLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}airing_raw_label'],
      ),
      narrativeSeason: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}narrative_season'],
      ),
      knownEpisodeTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}known_episode_total'],
      ),
      rawEpisodeTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_episode_total'],
      ),
    );
  }

  @override
  $CanonicalMediaRecordsTable createAlias(String alias) {
    return $CanonicalMediaRecordsTable(attachedDatabase, alias);
  }
}

class CanonicalMediaRow extends DataClass
    implements Insertable<CanonicalMediaRow> {
  final String id;
  final String kind;
  final String title;
  final String titleProviderId;
  final String? titleRawValue;
  final String alternateTitlesJson;
  final String? description;
  final String? descriptionProviderId;
  final String? descriptionRawValue;
  final String status;
  final String genresJson;
  final String? coverLocator;
  final String? animeFormat;
  final String? airingSeason;
  final int? airingYear;
  final String? airingRawLabel;
  final int? narrativeSeason;
  final int? knownEpisodeTotal;
  final String? rawEpisodeTotal;
  const CanonicalMediaRow({
    required this.id,
    required this.kind,
    required this.title,
    required this.titleProviderId,
    this.titleRawValue,
    required this.alternateTitlesJson,
    this.description,
    this.descriptionProviderId,
    this.descriptionRawValue,
    required this.status,
    required this.genresJson,
    this.coverLocator,
    this.animeFormat,
    this.airingSeason,
    this.airingYear,
    this.airingRawLabel,
    this.narrativeSeason,
    this.knownEpisodeTotal,
    this.rawEpisodeTotal,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    map['title'] = Variable<String>(title);
    map['title_provider_id'] = Variable<String>(titleProviderId);
    if (!nullToAbsent || titleRawValue != null) {
      map['title_raw_value'] = Variable<String>(titleRawValue);
    }
    map['alternate_titles_json'] = Variable<String>(alternateTitlesJson);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || descriptionProviderId != null) {
      map['description_provider_id'] = Variable<String>(descriptionProviderId);
    }
    if (!nullToAbsent || descriptionRawValue != null) {
      map['description_raw_value'] = Variable<String>(descriptionRawValue);
    }
    map['status'] = Variable<String>(status);
    map['genres_json'] = Variable<String>(genresJson);
    if (!nullToAbsent || coverLocator != null) {
      map['cover_locator'] = Variable<String>(coverLocator);
    }
    if (!nullToAbsent || animeFormat != null) {
      map['anime_format'] = Variable<String>(animeFormat);
    }
    if (!nullToAbsent || airingSeason != null) {
      map['airing_season'] = Variable<String>(airingSeason);
    }
    if (!nullToAbsent || airingYear != null) {
      map['airing_year'] = Variable<int>(airingYear);
    }
    if (!nullToAbsent || airingRawLabel != null) {
      map['airing_raw_label'] = Variable<String>(airingRawLabel);
    }
    if (!nullToAbsent || narrativeSeason != null) {
      map['narrative_season'] = Variable<int>(narrativeSeason);
    }
    if (!nullToAbsent || knownEpisodeTotal != null) {
      map['known_episode_total'] = Variable<int>(knownEpisodeTotal);
    }
    if (!nullToAbsent || rawEpisodeTotal != null) {
      map['raw_episode_total'] = Variable<String>(rawEpisodeTotal);
    }
    return map;
  }

  CanonicalMediaRecordsCompanion toCompanion(bool nullToAbsent) {
    return CanonicalMediaRecordsCompanion(
      id: Value(id),
      kind: Value(kind),
      title: Value(title),
      titleProviderId: Value(titleProviderId),
      titleRawValue: titleRawValue == null && nullToAbsent
          ? const Value.absent()
          : Value(titleRawValue),
      alternateTitlesJson: Value(alternateTitlesJson),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      descriptionProviderId: descriptionProviderId == null && nullToAbsent
          ? const Value.absent()
          : Value(descriptionProviderId),
      descriptionRawValue: descriptionRawValue == null && nullToAbsent
          ? const Value.absent()
          : Value(descriptionRawValue),
      status: Value(status),
      genresJson: Value(genresJson),
      coverLocator: coverLocator == null && nullToAbsent
          ? const Value.absent()
          : Value(coverLocator),
      animeFormat: animeFormat == null && nullToAbsent
          ? const Value.absent()
          : Value(animeFormat),
      airingSeason: airingSeason == null && nullToAbsent
          ? const Value.absent()
          : Value(airingSeason),
      airingYear: airingYear == null && nullToAbsent
          ? const Value.absent()
          : Value(airingYear),
      airingRawLabel: airingRawLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(airingRawLabel),
      narrativeSeason: narrativeSeason == null && nullToAbsent
          ? const Value.absent()
          : Value(narrativeSeason),
      knownEpisodeTotal: knownEpisodeTotal == null && nullToAbsent
          ? const Value.absent()
          : Value(knownEpisodeTotal),
      rawEpisodeTotal: rawEpisodeTotal == null && nullToAbsent
          ? const Value.absent()
          : Value(rawEpisodeTotal),
    );
  }

  factory CanonicalMediaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CanonicalMediaRow(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      title: serializer.fromJson<String>(json['title']),
      titleProviderId: serializer.fromJson<String>(json['titleProviderId']),
      titleRawValue: serializer.fromJson<String?>(json['titleRawValue']),
      alternateTitlesJson: serializer.fromJson<String>(
        json['alternateTitlesJson'],
      ),
      description: serializer.fromJson<String?>(json['description']),
      descriptionProviderId: serializer.fromJson<String?>(
        json['descriptionProviderId'],
      ),
      descriptionRawValue: serializer.fromJson<String?>(
        json['descriptionRawValue'],
      ),
      status: serializer.fromJson<String>(json['status']),
      genresJson: serializer.fromJson<String>(json['genresJson']),
      coverLocator: serializer.fromJson<String?>(json['coverLocator']),
      animeFormat: serializer.fromJson<String?>(json['animeFormat']),
      airingSeason: serializer.fromJson<String?>(json['airingSeason']),
      airingYear: serializer.fromJson<int?>(json['airingYear']),
      airingRawLabel: serializer.fromJson<String?>(json['airingRawLabel']),
      narrativeSeason: serializer.fromJson<int?>(json['narrativeSeason']),
      knownEpisodeTotal: serializer.fromJson<int?>(json['knownEpisodeTotal']),
      rawEpisodeTotal: serializer.fromJson<String?>(json['rawEpisodeTotal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'title': serializer.toJson<String>(title),
      'titleProviderId': serializer.toJson<String>(titleProviderId),
      'titleRawValue': serializer.toJson<String?>(titleRawValue),
      'alternateTitlesJson': serializer.toJson<String>(alternateTitlesJson),
      'description': serializer.toJson<String?>(description),
      'descriptionProviderId': serializer.toJson<String?>(
        descriptionProviderId,
      ),
      'descriptionRawValue': serializer.toJson<String?>(descriptionRawValue),
      'status': serializer.toJson<String>(status),
      'genresJson': serializer.toJson<String>(genresJson),
      'coverLocator': serializer.toJson<String?>(coverLocator),
      'animeFormat': serializer.toJson<String?>(animeFormat),
      'airingSeason': serializer.toJson<String?>(airingSeason),
      'airingYear': serializer.toJson<int?>(airingYear),
      'airingRawLabel': serializer.toJson<String?>(airingRawLabel),
      'narrativeSeason': serializer.toJson<int?>(narrativeSeason),
      'knownEpisodeTotal': serializer.toJson<int?>(knownEpisodeTotal),
      'rawEpisodeTotal': serializer.toJson<String?>(rawEpisodeTotal),
    };
  }

  CanonicalMediaRow copyWith({
    String? id,
    String? kind,
    String? title,
    String? titleProviderId,
    Value<String?> titleRawValue = const Value.absent(),
    String? alternateTitlesJson,
    Value<String?> description = const Value.absent(),
    Value<String?> descriptionProviderId = const Value.absent(),
    Value<String?> descriptionRawValue = const Value.absent(),
    String? status,
    String? genresJson,
    Value<String?> coverLocator = const Value.absent(),
    Value<String?> animeFormat = const Value.absent(),
    Value<String?> airingSeason = const Value.absent(),
    Value<int?> airingYear = const Value.absent(),
    Value<String?> airingRawLabel = const Value.absent(),
    Value<int?> narrativeSeason = const Value.absent(),
    Value<int?> knownEpisodeTotal = const Value.absent(),
    Value<String?> rawEpisodeTotal = const Value.absent(),
  }) => CanonicalMediaRow(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    title: title ?? this.title,
    titleProviderId: titleProviderId ?? this.titleProviderId,
    titleRawValue: titleRawValue.present
        ? titleRawValue.value
        : this.titleRawValue,
    alternateTitlesJson: alternateTitlesJson ?? this.alternateTitlesJson,
    description: description.present ? description.value : this.description,
    descriptionProviderId: descriptionProviderId.present
        ? descriptionProviderId.value
        : this.descriptionProviderId,
    descriptionRawValue: descriptionRawValue.present
        ? descriptionRawValue.value
        : this.descriptionRawValue,
    status: status ?? this.status,
    genresJson: genresJson ?? this.genresJson,
    coverLocator: coverLocator.present ? coverLocator.value : this.coverLocator,
    animeFormat: animeFormat.present ? animeFormat.value : this.animeFormat,
    airingSeason: airingSeason.present ? airingSeason.value : this.airingSeason,
    airingYear: airingYear.present ? airingYear.value : this.airingYear,
    airingRawLabel: airingRawLabel.present
        ? airingRawLabel.value
        : this.airingRawLabel,
    narrativeSeason: narrativeSeason.present
        ? narrativeSeason.value
        : this.narrativeSeason,
    knownEpisodeTotal: knownEpisodeTotal.present
        ? knownEpisodeTotal.value
        : this.knownEpisodeTotal,
    rawEpisodeTotal: rawEpisodeTotal.present
        ? rawEpisodeTotal.value
        : this.rawEpisodeTotal,
  );
  CanonicalMediaRow copyWithCompanion(CanonicalMediaRecordsCompanion data) {
    return CanonicalMediaRow(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      title: data.title.present ? data.title.value : this.title,
      titleProviderId: data.titleProviderId.present
          ? data.titleProviderId.value
          : this.titleProviderId,
      titleRawValue: data.titleRawValue.present
          ? data.titleRawValue.value
          : this.titleRawValue,
      alternateTitlesJson: data.alternateTitlesJson.present
          ? data.alternateTitlesJson.value
          : this.alternateTitlesJson,
      description: data.description.present
          ? data.description.value
          : this.description,
      descriptionProviderId: data.descriptionProviderId.present
          ? data.descriptionProviderId.value
          : this.descriptionProviderId,
      descriptionRawValue: data.descriptionRawValue.present
          ? data.descriptionRawValue.value
          : this.descriptionRawValue,
      status: data.status.present ? data.status.value : this.status,
      genresJson: data.genresJson.present
          ? data.genresJson.value
          : this.genresJson,
      coverLocator: data.coverLocator.present
          ? data.coverLocator.value
          : this.coverLocator,
      animeFormat: data.animeFormat.present
          ? data.animeFormat.value
          : this.animeFormat,
      airingSeason: data.airingSeason.present
          ? data.airingSeason.value
          : this.airingSeason,
      airingYear: data.airingYear.present
          ? data.airingYear.value
          : this.airingYear,
      airingRawLabel: data.airingRawLabel.present
          ? data.airingRawLabel.value
          : this.airingRawLabel,
      narrativeSeason: data.narrativeSeason.present
          ? data.narrativeSeason.value
          : this.narrativeSeason,
      knownEpisodeTotal: data.knownEpisodeTotal.present
          ? data.knownEpisodeTotal.value
          : this.knownEpisodeTotal,
      rawEpisodeTotal: data.rawEpisodeTotal.present
          ? data.rawEpisodeTotal.value
          : this.rawEpisodeTotal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CanonicalMediaRow(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('titleProviderId: $titleProviderId, ')
          ..write('titleRawValue: $titleRawValue, ')
          ..write('alternateTitlesJson: $alternateTitlesJson, ')
          ..write('description: $description, ')
          ..write('descriptionProviderId: $descriptionProviderId, ')
          ..write('descriptionRawValue: $descriptionRawValue, ')
          ..write('status: $status, ')
          ..write('genresJson: $genresJson, ')
          ..write('coverLocator: $coverLocator, ')
          ..write('animeFormat: $animeFormat, ')
          ..write('airingSeason: $airingSeason, ')
          ..write('airingYear: $airingYear, ')
          ..write('airingRawLabel: $airingRawLabel, ')
          ..write('narrativeSeason: $narrativeSeason, ')
          ..write('knownEpisodeTotal: $knownEpisodeTotal, ')
          ..write('rawEpisodeTotal: $rawEpisodeTotal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    title,
    titleProviderId,
    titleRawValue,
    alternateTitlesJson,
    description,
    descriptionProviderId,
    descriptionRawValue,
    status,
    genresJson,
    coverLocator,
    animeFormat,
    airingSeason,
    airingYear,
    airingRawLabel,
    narrativeSeason,
    knownEpisodeTotal,
    rawEpisodeTotal,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CanonicalMediaRow &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.title == this.title &&
          other.titleProviderId == this.titleProviderId &&
          other.titleRawValue == this.titleRawValue &&
          other.alternateTitlesJson == this.alternateTitlesJson &&
          other.description == this.description &&
          other.descriptionProviderId == this.descriptionProviderId &&
          other.descriptionRawValue == this.descriptionRawValue &&
          other.status == this.status &&
          other.genresJson == this.genresJson &&
          other.coverLocator == this.coverLocator &&
          other.animeFormat == this.animeFormat &&
          other.airingSeason == this.airingSeason &&
          other.airingYear == this.airingYear &&
          other.airingRawLabel == this.airingRawLabel &&
          other.narrativeSeason == this.narrativeSeason &&
          other.knownEpisodeTotal == this.knownEpisodeTotal &&
          other.rawEpisodeTotal == this.rawEpisodeTotal);
}

class CanonicalMediaRecordsCompanion
    extends UpdateCompanion<CanonicalMediaRow> {
  final Value<String> id;
  final Value<String> kind;
  final Value<String> title;
  final Value<String> titleProviderId;
  final Value<String?> titleRawValue;
  final Value<String> alternateTitlesJson;
  final Value<String?> description;
  final Value<String?> descriptionProviderId;
  final Value<String?> descriptionRawValue;
  final Value<String> status;
  final Value<String> genresJson;
  final Value<String?> coverLocator;
  final Value<String?> animeFormat;
  final Value<String?> airingSeason;
  final Value<int?> airingYear;
  final Value<String?> airingRawLabel;
  final Value<int?> narrativeSeason;
  final Value<int?> knownEpisodeTotal;
  final Value<String?> rawEpisodeTotal;
  final Value<int> rowid;
  const CanonicalMediaRecordsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.title = const Value.absent(),
    this.titleProviderId = const Value.absent(),
    this.titleRawValue = const Value.absent(),
    this.alternateTitlesJson = const Value.absent(),
    this.description = const Value.absent(),
    this.descriptionProviderId = const Value.absent(),
    this.descriptionRawValue = const Value.absent(),
    this.status = const Value.absent(),
    this.genresJson = const Value.absent(),
    this.coverLocator = const Value.absent(),
    this.animeFormat = const Value.absent(),
    this.airingSeason = const Value.absent(),
    this.airingYear = const Value.absent(),
    this.airingRawLabel = const Value.absent(),
    this.narrativeSeason = const Value.absent(),
    this.knownEpisodeTotal = const Value.absent(),
    this.rawEpisodeTotal = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CanonicalMediaRecordsCompanion.insert({
    required String id,
    required String kind,
    required String title,
    required String titleProviderId,
    this.titleRawValue = const Value.absent(),
    this.alternateTitlesJson = const Value.absent(),
    this.description = const Value.absent(),
    this.descriptionProviderId = const Value.absent(),
    this.descriptionRawValue = const Value.absent(),
    required String status,
    this.genresJson = const Value.absent(),
    this.coverLocator = const Value.absent(),
    this.animeFormat = const Value.absent(),
    this.airingSeason = const Value.absent(),
    this.airingYear = const Value.absent(),
    this.airingRawLabel = const Value.absent(),
    this.narrativeSeason = const Value.absent(),
    this.knownEpisodeTotal = const Value.absent(),
    this.rawEpisodeTotal = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       title = Value(title),
       titleProviderId = Value(titleProviderId),
       status = Value(status);
  static Insertable<CanonicalMediaRow> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? title,
    Expression<String>? titleProviderId,
    Expression<String>? titleRawValue,
    Expression<String>? alternateTitlesJson,
    Expression<String>? description,
    Expression<String>? descriptionProviderId,
    Expression<String>? descriptionRawValue,
    Expression<String>? status,
    Expression<String>? genresJson,
    Expression<String>? coverLocator,
    Expression<String>? animeFormat,
    Expression<String>? airingSeason,
    Expression<int>? airingYear,
    Expression<String>? airingRawLabel,
    Expression<int>? narrativeSeason,
    Expression<int>? knownEpisodeTotal,
    Expression<String>? rawEpisodeTotal,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (title != null) 'title': title,
      if (titleProviderId != null) 'title_provider_id': titleProviderId,
      if (titleRawValue != null) 'title_raw_value': titleRawValue,
      if (alternateTitlesJson != null)
        'alternate_titles_json': alternateTitlesJson,
      if (description != null) 'description': description,
      if (descriptionProviderId != null)
        'description_provider_id': descriptionProviderId,
      if (descriptionRawValue != null)
        'description_raw_value': descriptionRawValue,
      if (status != null) 'status': status,
      if (genresJson != null) 'genres_json': genresJson,
      if (coverLocator != null) 'cover_locator': coverLocator,
      if (animeFormat != null) 'anime_format': animeFormat,
      if (airingSeason != null) 'airing_season': airingSeason,
      if (airingYear != null) 'airing_year': airingYear,
      if (airingRawLabel != null) 'airing_raw_label': airingRawLabel,
      if (narrativeSeason != null) 'narrative_season': narrativeSeason,
      if (knownEpisodeTotal != null) 'known_episode_total': knownEpisodeTotal,
      if (rawEpisodeTotal != null) 'raw_episode_total': rawEpisodeTotal,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CanonicalMediaRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? kind,
    Value<String>? title,
    Value<String>? titleProviderId,
    Value<String?>? titleRawValue,
    Value<String>? alternateTitlesJson,
    Value<String?>? description,
    Value<String?>? descriptionProviderId,
    Value<String?>? descriptionRawValue,
    Value<String>? status,
    Value<String>? genresJson,
    Value<String?>? coverLocator,
    Value<String?>? animeFormat,
    Value<String?>? airingSeason,
    Value<int?>? airingYear,
    Value<String?>? airingRawLabel,
    Value<int?>? narrativeSeason,
    Value<int?>? knownEpisodeTotal,
    Value<String?>? rawEpisodeTotal,
    Value<int>? rowid,
  }) {
    return CanonicalMediaRecordsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      titleProviderId: titleProviderId ?? this.titleProviderId,
      titleRawValue: titleRawValue ?? this.titleRawValue,
      alternateTitlesJson: alternateTitlesJson ?? this.alternateTitlesJson,
      description: description ?? this.description,
      descriptionProviderId:
          descriptionProviderId ?? this.descriptionProviderId,
      descriptionRawValue: descriptionRawValue ?? this.descriptionRawValue,
      status: status ?? this.status,
      genresJson: genresJson ?? this.genresJson,
      coverLocator: coverLocator ?? this.coverLocator,
      animeFormat: animeFormat ?? this.animeFormat,
      airingSeason: airingSeason ?? this.airingSeason,
      airingYear: airingYear ?? this.airingYear,
      airingRawLabel: airingRawLabel ?? this.airingRawLabel,
      narrativeSeason: narrativeSeason ?? this.narrativeSeason,
      knownEpisodeTotal: knownEpisodeTotal ?? this.knownEpisodeTotal,
      rawEpisodeTotal: rawEpisodeTotal ?? this.rawEpisodeTotal,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (titleProviderId.present) {
      map['title_provider_id'] = Variable<String>(titleProviderId.value);
    }
    if (titleRawValue.present) {
      map['title_raw_value'] = Variable<String>(titleRawValue.value);
    }
    if (alternateTitlesJson.present) {
      map['alternate_titles_json'] = Variable<String>(
        alternateTitlesJson.value,
      );
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (descriptionProviderId.present) {
      map['description_provider_id'] = Variable<String>(
        descriptionProviderId.value,
      );
    }
    if (descriptionRawValue.present) {
      map['description_raw_value'] = Variable<String>(
        descriptionRawValue.value,
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (genresJson.present) {
      map['genres_json'] = Variable<String>(genresJson.value);
    }
    if (coverLocator.present) {
      map['cover_locator'] = Variable<String>(coverLocator.value);
    }
    if (animeFormat.present) {
      map['anime_format'] = Variable<String>(animeFormat.value);
    }
    if (airingSeason.present) {
      map['airing_season'] = Variable<String>(airingSeason.value);
    }
    if (airingYear.present) {
      map['airing_year'] = Variable<int>(airingYear.value);
    }
    if (airingRawLabel.present) {
      map['airing_raw_label'] = Variable<String>(airingRawLabel.value);
    }
    if (narrativeSeason.present) {
      map['narrative_season'] = Variable<int>(narrativeSeason.value);
    }
    if (knownEpisodeTotal.present) {
      map['known_episode_total'] = Variable<int>(knownEpisodeTotal.value);
    }
    if (rawEpisodeTotal.present) {
      map['raw_episode_total'] = Variable<String>(rawEpisodeTotal.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CanonicalMediaRecordsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('titleProviderId: $titleProviderId, ')
          ..write('titleRawValue: $titleRawValue, ')
          ..write('alternateTitlesJson: $alternateTitlesJson, ')
          ..write('description: $description, ')
          ..write('descriptionProviderId: $descriptionProviderId, ')
          ..write('descriptionRawValue: $descriptionRawValue, ')
          ..write('status: $status, ')
          ..write('genresJson: $genresJson, ')
          ..write('coverLocator: $coverLocator, ')
          ..write('animeFormat: $animeFormat, ')
          ..write('airingSeason: $airingSeason, ')
          ..write('airingYear: $airingYear, ')
          ..write('airingRawLabel: $airingRawLabel, ')
          ..write('narrativeSeason: $narrativeSeason, ')
          ..write('knownEpisodeTotal: $knownEpisodeTotal, ')
          ..write('rawEpisodeTotal: $rawEpisodeTotal, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CanonicalChapterRecordsTable extends CanonicalChapterRecords
    with TableInfo<$CanonicalChapterRecordsTable, CanonicalChapterRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CanonicalChapterRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES canonical_media_records (id)',
    ),
  );
  static const VerificationMeta _rawLabelMeta = const VerificationMeta(
    'rawLabel',
  );
  @override
  late final GeneratedColumn<String> rawLabel = GeneratedColumn<String>(
    'raw_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedNumberMeta = const VerificationMeta(
    'normalizedNumber',
  );
  @override
  late final GeneratedColumn<String> normalizedNumber = GeneratedColumn<String>(
    'normalized_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _volumeLabelMeta = const VerificationMeta(
    'volumeLabel',
  );
  @override
  late final GeneratedColumn<String> volumeLabel = GeneratedColumn<String>(
    'volume_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mediaId,
    rawLabel,
    normalizedNumber,
    title,
    volumeLabel,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'canonical_chapter_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<CanonicalChapterRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('media_id')) {
      context.handle(
        _mediaIdMeta,
        mediaId.isAcceptableOrUnknown(data['media_id']!, _mediaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mediaIdMeta);
    }
    if (data.containsKey('raw_label')) {
      context.handle(
        _rawLabelMeta,
        rawLabel.isAcceptableOrUnknown(data['raw_label']!, _rawLabelMeta),
      );
    } else if (isInserting) {
      context.missing(_rawLabelMeta);
    }
    if (data.containsKey('normalized_number')) {
      context.handle(
        _normalizedNumberMeta,
        normalizedNumber.isAcceptableOrUnknown(
          data['normalized_number']!,
          _normalizedNumberMeta,
        ),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('volume_label')) {
      context.handle(
        _volumeLabelMeta,
        volumeLabel.isAcceptableOrUnknown(
          data['volume_label']!,
          _volumeLabelMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CanonicalChapterRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CanonicalChapterRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      mediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_id'],
      )!,
      rawLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_label'],
      )!,
      normalizedNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_number'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      volumeLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}volume_label'],
      ),
    );
  }

  @override
  $CanonicalChapterRecordsTable createAlias(String alias) {
    return $CanonicalChapterRecordsTable(attachedDatabase, alias);
  }
}

class CanonicalChapterRow extends DataClass
    implements Insertable<CanonicalChapterRow> {
  final String id;
  final String mediaId;
  final String rawLabel;
  final String? normalizedNumber;
  final String? title;
  final String? volumeLabel;
  const CanonicalChapterRow({
    required this.id,
    required this.mediaId,
    required this.rawLabel,
    this.normalizedNumber,
    this.title,
    this.volumeLabel,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['media_id'] = Variable<String>(mediaId);
    map['raw_label'] = Variable<String>(rawLabel);
    if (!nullToAbsent || normalizedNumber != null) {
      map['normalized_number'] = Variable<String>(normalizedNumber);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || volumeLabel != null) {
      map['volume_label'] = Variable<String>(volumeLabel);
    }
    return map;
  }

  CanonicalChapterRecordsCompanion toCompanion(bool nullToAbsent) {
    return CanonicalChapterRecordsCompanion(
      id: Value(id),
      mediaId: Value(mediaId),
      rawLabel: Value(rawLabel),
      normalizedNumber: normalizedNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(normalizedNumber),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      volumeLabel: volumeLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(volumeLabel),
    );
  }

  factory CanonicalChapterRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CanonicalChapterRow(
      id: serializer.fromJson<String>(json['id']),
      mediaId: serializer.fromJson<String>(json['mediaId']),
      rawLabel: serializer.fromJson<String>(json['rawLabel']),
      normalizedNumber: serializer.fromJson<String?>(json['normalizedNumber']),
      title: serializer.fromJson<String?>(json['title']),
      volumeLabel: serializer.fromJson<String?>(json['volumeLabel']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mediaId': serializer.toJson<String>(mediaId),
      'rawLabel': serializer.toJson<String>(rawLabel),
      'normalizedNumber': serializer.toJson<String?>(normalizedNumber),
      'title': serializer.toJson<String?>(title),
      'volumeLabel': serializer.toJson<String?>(volumeLabel),
    };
  }

  CanonicalChapterRow copyWith({
    String? id,
    String? mediaId,
    String? rawLabel,
    Value<String?> normalizedNumber = const Value.absent(),
    Value<String?> title = const Value.absent(),
    Value<String?> volumeLabel = const Value.absent(),
  }) => CanonicalChapterRow(
    id: id ?? this.id,
    mediaId: mediaId ?? this.mediaId,
    rawLabel: rawLabel ?? this.rawLabel,
    normalizedNumber: normalizedNumber.present
        ? normalizedNumber.value
        : this.normalizedNumber,
    title: title.present ? title.value : this.title,
    volumeLabel: volumeLabel.present ? volumeLabel.value : this.volumeLabel,
  );
  CanonicalChapterRow copyWithCompanion(CanonicalChapterRecordsCompanion data) {
    return CanonicalChapterRow(
      id: data.id.present ? data.id.value : this.id,
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
      rawLabel: data.rawLabel.present ? data.rawLabel.value : this.rawLabel,
      normalizedNumber: data.normalizedNumber.present
          ? data.normalizedNumber.value
          : this.normalizedNumber,
      title: data.title.present ? data.title.value : this.title,
      volumeLabel: data.volumeLabel.present
          ? data.volumeLabel.value
          : this.volumeLabel,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CanonicalChapterRow(')
          ..write('id: $id, ')
          ..write('mediaId: $mediaId, ')
          ..write('rawLabel: $rawLabel, ')
          ..write('normalizedNumber: $normalizedNumber, ')
          ..write('title: $title, ')
          ..write('volumeLabel: $volumeLabel')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, mediaId, rawLabel, normalizedNumber, title, volumeLabel);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CanonicalChapterRow &&
          other.id == this.id &&
          other.mediaId == this.mediaId &&
          other.rawLabel == this.rawLabel &&
          other.normalizedNumber == this.normalizedNumber &&
          other.title == this.title &&
          other.volumeLabel == this.volumeLabel);
}

class CanonicalChapterRecordsCompanion
    extends UpdateCompanion<CanonicalChapterRow> {
  final Value<String> id;
  final Value<String> mediaId;
  final Value<String> rawLabel;
  final Value<String?> normalizedNumber;
  final Value<String?> title;
  final Value<String?> volumeLabel;
  final Value<int> rowid;
  const CanonicalChapterRecordsCompanion({
    this.id = const Value.absent(),
    this.mediaId = const Value.absent(),
    this.rawLabel = const Value.absent(),
    this.normalizedNumber = const Value.absent(),
    this.title = const Value.absent(),
    this.volumeLabel = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CanonicalChapterRecordsCompanion.insert({
    required String id,
    required String mediaId,
    required String rawLabel,
    this.normalizedNumber = const Value.absent(),
    this.title = const Value.absent(),
    this.volumeLabel = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       mediaId = Value(mediaId),
       rawLabel = Value(rawLabel);
  static Insertable<CanonicalChapterRow> custom({
    Expression<String>? id,
    Expression<String>? mediaId,
    Expression<String>? rawLabel,
    Expression<String>? normalizedNumber,
    Expression<String>? title,
    Expression<String>? volumeLabel,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mediaId != null) 'media_id': mediaId,
      if (rawLabel != null) 'raw_label': rawLabel,
      if (normalizedNumber != null) 'normalized_number': normalizedNumber,
      if (title != null) 'title': title,
      if (volumeLabel != null) 'volume_label': volumeLabel,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CanonicalChapterRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? mediaId,
    Value<String>? rawLabel,
    Value<String?>? normalizedNumber,
    Value<String?>? title,
    Value<String?>? volumeLabel,
    Value<int>? rowid,
  }) {
    return CanonicalChapterRecordsCompanion(
      id: id ?? this.id,
      mediaId: mediaId ?? this.mediaId,
      rawLabel: rawLabel ?? this.rawLabel,
      normalizedNumber: normalizedNumber ?? this.normalizedNumber,
      title: title ?? this.title,
      volumeLabel: volumeLabel ?? this.volumeLabel,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mediaId.present) {
      map['media_id'] = Variable<String>(mediaId.value);
    }
    if (rawLabel.present) {
      map['raw_label'] = Variable<String>(rawLabel.value);
    }
    if (normalizedNumber.present) {
      map['normalized_number'] = Variable<String>(normalizedNumber.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (volumeLabel.present) {
      map['volume_label'] = Variable<String>(volumeLabel.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CanonicalChapterRecordsCompanion(')
          ..write('id: $id, ')
          ..write('mediaId: $mediaId, ')
          ..write('rawLabel: $rawLabel, ')
          ..write('normalizedNumber: $normalizedNumber, ')
          ..write('title: $title, ')
          ..write('volumeLabel: $volumeLabel, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CanonicalEpisodeRecordsTable extends CanonicalEpisodeRecords
    with TableInfo<$CanonicalEpisodeRecordsTable, CanonicalEpisodeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CanonicalEpisodeRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES canonical_media_records (id)',
    ),
  );
  static const VerificationMeta _rawLabelMeta = const VerificationMeta(
    'rawLabel',
  );
  @override
  late final GeneratedColumn<String> rawLabel = GeneratedColumn<String>(
    'raw_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<double> number = GeneratedColumn<double>(
    'number',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _narrativeSeasonMeta = const VerificationMeta(
    'narrativeSeason',
  );
  @override
  late final GeneratedColumn<int> narrativeSeason = GeneratedColumn<int>(
    'narrative_season',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mediaId,
    rawLabel,
    number,
    title,
    narrativeSeason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'canonical_episode_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<CanonicalEpisodeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('media_id')) {
      context.handle(
        _mediaIdMeta,
        mediaId.isAcceptableOrUnknown(data['media_id']!, _mediaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mediaIdMeta);
    }
    if (data.containsKey('raw_label')) {
      context.handle(
        _rawLabelMeta,
        rawLabel.isAcceptableOrUnknown(data['raw_label']!, _rawLabelMeta),
      );
    } else if (isInserting) {
      context.missing(_rawLabelMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('narrative_season')) {
      context.handle(
        _narrativeSeasonMeta,
        narrativeSeason.isAcceptableOrUnknown(
          data['narrative_season']!,
          _narrativeSeasonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CanonicalEpisodeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CanonicalEpisodeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      mediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_id'],
      )!,
      rawLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_label'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}number'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      narrativeSeason: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}narrative_season'],
      ),
    );
  }

  @override
  $CanonicalEpisodeRecordsTable createAlias(String alias) {
    return $CanonicalEpisodeRecordsTable(attachedDatabase, alias);
  }
}

class CanonicalEpisodeRow extends DataClass
    implements Insertable<CanonicalEpisodeRow> {
  final String id;
  final String mediaId;
  final String rawLabel;
  final double? number;
  final String? title;
  final int? narrativeSeason;
  const CanonicalEpisodeRow({
    required this.id,
    required this.mediaId,
    required this.rawLabel,
    this.number,
    this.title,
    this.narrativeSeason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['media_id'] = Variable<String>(mediaId);
    map['raw_label'] = Variable<String>(rawLabel);
    if (!nullToAbsent || number != null) {
      map['number'] = Variable<double>(number);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || narrativeSeason != null) {
      map['narrative_season'] = Variable<int>(narrativeSeason);
    }
    return map;
  }

  CanonicalEpisodeRecordsCompanion toCompanion(bool nullToAbsent) {
    return CanonicalEpisodeRecordsCompanion(
      id: Value(id),
      mediaId: Value(mediaId),
      rawLabel: Value(rawLabel),
      number: number == null && nullToAbsent
          ? const Value.absent()
          : Value(number),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      narrativeSeason: narrativeSeason == null && nullToAbsent
          ? const Value.absent()
          : Value(narrativeSeason),
    );
  }

  factory CanonicalEpisodeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CanonicalEpisodeRow(
      id: serializer.fromJson<String>(json['id']),
      mediaId: serializer.fromJson<String>(json['mediaId']),
      rawLabel: serializer.fromJson<String>(json['rawLabel']),
      number: serializer.fromJson<double?>(json['number']),
      title: serializer.fromJson<String?>(json['title']),
      narrativeSeason: serializer.fromJson<int?>(json['narrativeSeason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mediaId': serializer.toJson<String>(mediaId),
      'rawLabel': serializer.toJson<String>(rawLabel),
      'number': serializer.toJson<double?>(number),
      'title': serializer.toJson<String?>(title),
      'narrativeSeason': serializer.toJson<int?>(narrativeSeason),
    };
  }

  CanonicalEpisodeRow copyWith({
    String? id,
    String? mediaId,
    String? rawLabel,
    Value<double?> number = const Value.absent(),
    Value<String?> title = const Value.absent(),
    Value<int?> narrativeSeason = const Value.absent(),
  }) => CanonicalEpisodeRow(
    id: id ?? this.id,
    mediaId: mediaId ?? this.mediaId,
    rawLabel: rawLabel ?? this.rawLabel,
    number: number.present ? number.value : this.number,
    title: title.present ? title.value : this.title,
    narrativeSeason: narrativeSeason.present
        ? narrativeSeason.value
        : this.narrativeSeason,
  );
  CanonicalEpisodeRow copyWithCompanion(CanonicalEpisodeRecordsCompanion data) {
    return CanonicalEpisodeRow(
      id: data.id.present ? data.id.value : this.id,
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
      rawLabel: data.rawLabel.present ? data.rawLabel.value : this.rawLabel,
      number: data.number.present ? data.number.value : this.number,
      title: data.title.present ? data.title.value : this.title,
      narrativeSeason: data.narrativeSeason.present
          ? data.narrativeSeason.value
          : this.narrativeSeason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CanonicalEpisodeRow(')
          ..write('id: $id, ')
          ..write('mediaId: $mediaId, ')
          ..write('rawLabel: $rawLabel, ')
          ..write('number: $number, ')
          ..write('title: $title, ')
          ..write('narrativeSeason: $narrativeSeason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, mediaId, rawLabel, number, title, narrativeSeason);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CanonicalEpisodeRow &&
          other.id == this.id &&
          other.mediaId == this.mediaId &&
          other.rawLabel == this.rawLabel &&
          other.number == this.number &&
          other.title == this.title &&
          other.narrativeSeason == this.narrativeSeason);
}

class CanonicalEpisodeRecordsCompanion
    extends UpdateCompanion<CanonicalEpisodeRow> {
  final Value<String> id;
  final Value<String> mediaId;
  final Value<String> rawLabel;
  final Value<double?> number;
  final Value<String?> title;
  final Value<int?> narrativeSeason;
  final Value<int> rowid;
  const CanonicalEpisodeRecordsCompanion({
    this.id = const Value.absent(),
    this.mediaId = const Value.absent(),
    this.rawLabel = const Value.absent(),
    this.number = const Value.absent(),
    this.title = const Value.absent(),
    this.narrativeSeason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CanonicalEpisodeRecordsCompanion.insert({
    required String id,
    required String mediaId,
    required String rawLabel,
    this.number = const Value.absent(),
    this.title = const Value.absent(),
    this.narrativeSeason = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       mediaId = Value(mediaId),
       rawLabel = Value(rawLabel);
  static Insertable<CanonicalEpisodeRow> custom({
    Expression<String>? id,
    Expression<String>? mediaId,
    Expression<String>? rawLabel,
    Expression<double>? number,
    Expression<String>? title,
    Expression<int>? narrativeSeason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mediaId != null) 'media_id': mediaId,
      if (rawLabel != null) 'raw_label': rawLabel,
      if (number != null) 'number': number,
      if (title != null) 'title': title,
      if (narrativeSeason != null) 'narrative_season': narrativeSeason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CanonicalEpisodeRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? mediaId,
    Value<String>? rawLabel,
    Value<double?>? number,
    Value<String?>? title,
    Value<int?>? narrativeSeason,
    Value<int>? rowid,
  }) {
    return CanonicalEpisodeRecordsCompanion(
      id: id ?? this.id,
      mediaId: mediaId ?? this.mediaId,
      rawLabel: rawLabel ?? this.rawLabel,
      number: number ?? this.number,
      title: title ?? this.title,
      narrativeSeason: narrativeSeason ?? this.narrativeSeason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mediaId.present) {
      map['media_id'] = Variable<String>(mediaId.value);
    }
    if (rawLabel.present) {
      map['raw_label'] = Variable<String>(rawLabel.value);
    }
    if (number.present) {
      map['number'] = Variable<double>(number.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (narrativeSeason.present) {
      map['narrative_season'] = Variable<int>(narrativeSeason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CanonicalEpisodeRecordsCompanion(')
          ..write('id: $id, ')
          ..write('mediaId: $mediaId, ')
          ..write('rawLabel: $rawLabel, ')
          ..write('number: $number, ')
          ..write('title: $title, ')
          ..write('narrativeSeason: $narrativeSeason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CanonicalMediaBindingsTable extends CanonicalMediaBindings
    with TableInfo<$CanonicalMediaBindingsTable, MediaBindingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CanonicalMediaBindingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _canonicalIdMeta = const VerificationMeta(
    'canonicalId',
  );
  @override
  late final GeneratedColumn<String> canonicalId = GeneratedColumn<String>(
    'canonical_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES canonical_media_records (id)',
    ),
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _externalIdMeta = const VerificationMeta(
    'externalId',
  );
  @override
  late final GeneratedColumn<String> externalId = GeneratedColumn<String>(
    'external_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relativeLocatorMeta = const VerificationMeta(
    'relativeLocator',
  );
  @override
  late final GeneratedColumn<String> relativeLocator = GeneratedColumn<String>(
    'relative_locator',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawMetadataJsonMeta = const VerificationMeta(
    'rawMetadataJson',
  );
  @override
  late final GeneratedColumn<String> rawMetadataJson = GeneratedColumn<String>(
    'raw_metadata_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    canonicalId,
    providerId,
    externalId,
    relativeLocator,
    rawMetadataJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'canonical_media_bindings';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaBindingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('canonical_id')) {
      context.handle(
        _canonicalIdMeta,
        canonicalId.isAcceptableOrUnknown(
          data['canonical_id']!,
          _canonicalIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_canonicalIdMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('external_id')) {
      context.handle(
        _externalIdMeta,
        externalId.isAcceptableOrUnknown(data['external_id']!, _externalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_externalIdMeta);
    }
    if (data.containsKey('relative_locator')) {
      context.handle(
        _relativeLocatorMeta,
        relativeLocator.isAcceptableOrUnknown(
          data['relative_locator']!,
          _relativeLocatorMeta,
        ),
      );
    }
    if (data.containsKey('raw_metadata_json')) {
      context.handle(
        _rawMetadataJsonMeta,
        rawMetadataJson.isAcceptableOrUnknown(
          data['raw_metadata_json']!,
          _rawMetadataJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {providerId, externalId};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {canonicalId, providerId},
  ];
  @override
  MediaBindingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaBindingRow(
      canonicalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}canonical_id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      externalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_id'],
      )!,
      relativeLocator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_locator'],
      ),
      rawMetadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_metadata_json'],
      )!,
    );
  }

  @override
  $CanonicalMediaBindingsTable createAlias(String alias) {
    return $CanonicalMediaBindingsTable(attachedDatabase, alias);
  }
}

class MediaBindingRow extends DataClass implements Insertable<MediaBindingRow> {
  final String canonicalId;
  final String providerId;
  final String externalId;
  final String? relativeLocator;
  final String rawMetadataJson;
  const MediaBindingRow({
    required this.canonicalId,
    required this.providerId,
    required this.externalId,
    this.relativeLocator,
    required this.rawMetadataJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['canonical_id'] = Variable<String>(canonicalId);
    map['provider_id'] = Variable<String>(providerId);
    map['external_id'] = Variable<String>(externalId);
    if (!nullToAbsent || relativeLocator != null) {
      map['relative_locator'] = Variable<String>(relativeLocator);
    }
    map['raw_metadata_json'] = Variable<String>(rawMetadataJson);
    return map;
  }

  CanonicalMediaBindingsCompanion toCompanion(bool nullToAbsent) {
    return CanonicalMediaBindingsCompanion(
      canonicalId: Value(canonicalId),
      providerId: Value(providerId),
      externalId: Value(externalId),
      relativeLocator: relativeLocator == null && nullToAbsent
          ? const Value.absent()
          : Value(relativeLocator),
      rawMetadataJson: Value(rawMetadataJson),
    );
  }

  factory MediaBindingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaBindingRow(
      canonicalId: serializer.fromJson<String>(json['canonicalId']),
      providerId: serializer.fromJson<String>(json['providerId']),
      externalId: serializer.fromJson<String>(json['externalId']),
      relativeLocator: serializer.fromJson<String?>(json['relativeLocator']),
      rawMetadataJson: serializer.fromJson<String>(json['rawMetadataJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'canonicalId': serializer.toJson<String>(canonicalId),
      'providerId': serializer.toJson<String>(providerId),
      'externalId': serializer.toJson<String>(externalId),
      'relativeLocator': serializer.toJson<String?>(relativeLocator),
      'rawMetadataJson': serializer.toJson<String>(rawMetadataJson),
    };
  }

  MediaBindingRow copyWith({
    String? canonicalId,
    String? providerId,
    String? externalId,
    Value<String?> relativeLocator = const Value.absent(),
    String? rawMetadataJson,
  }) => MediaBindingRow(
    canonicalId: canonicalId ?? this.canonicalId,
    providerId: providerId ?? this.providerId,
    externalId: externalId ?? this.externalId,
    relativeLocator: relativeLocator.present
        ? relativeLocator.value
        : this.relativeLocator,
    rawMetadataJson: rawMetadataJson ?? this.rawMetadataJson,
  );
  MediaBindingRow copyWithCompanion(CanonicalMediaBindingsCompanion data) {
    return MediaBindingRow(
      canonicalId: data.canonicalId.present
          ? data.canonicalId.value
          : this.canonicalId,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      externalId: data.externalId.present
          ? data.externalId.value
          : this.externalId,
      relativeLocator: data.relativeLocator.present
          ? data.relativeLocator.value
          : this.relativeLocator,
      rawMetadataJson: data.rawMetadataJson.present
          ? data.rawMetadataJson.value
          : this.rawMetadataJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaBindingRow(')
          ..write('canonicalId: $canonicalId, ')
          ..write('providerId: $providerId, ')
          ..write('externalId: $externalId, ')
          ..write('relativeLocator: $relativeLocator, ')
          ..write('rawMetadataJson: $rawMetadataJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    canonicalId,
    providerId,
    externalId,
    relativeLocator,
    rawMetadataJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaBindingRow &&
          other.canonicalId == this.canonicalId &&
          other.providerId == this.providerId &&
          other.externalId == this.externalId &&
          other.relativeLocator == this.relativeLocator &&
          other.rawMetadataJson == this.rawMetadataJson);
}

class CanonicalMediaBindingsCompanion extends UpdateCompanion<MediaBindingRow> {
  final Value<String> canonicalId;
  final Value<String> providerId;
  final Value<String> externalId;
  final Value<String?> relativeLocator;
  final Value<String> rawMetadataJson;
  final Value<int> rowid;
  const CanonicalMediaBindingsCompanion({
    this.canonicalId = const Value.absent(),
    this.providerId = const Value.absent(),
    this.externalId = const Value.absent(),
    this.relativeLocator = const Value.absent(),
    this.rawMetadataJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CanonicalMediaBindingsCompanion.insert({
    required String canonicalId,
    required String providerId,
    required String externalId,
    this.relativeLocator = const Value.absent(),
    this.rawMetadataJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : canonicalId = Value(canonicalId),
       providerId = Value(providerId),
       externalId = Value(externalId);
  static Insertable<MediaBindingRow> custom({
    Expression<String>? canonicalId,
    Expression<String>? providerId,
    Expression<String>? externalId,
    Expression<String>? relativeLocator,
    Expression<String>? rawMetadataJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (canonicalId != null) 'canonical_id': canonicalId,
      if (providerId != null) 'provider_id': providerId,
      if (externalId != null) 'external_id': externalId,
      if (relativeLocator != null) 'relative_locator': relativeLocator,
      if (rawMetadataJson != null) 'raw_metadata_json': rawMetadataJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CanonicalMediaBindingsCompanion copyWith({
    Value<String>? canonicalId,
    Value<String>? providerId,
    Value<String>? externalId,
    Value<String?>? relativeLocator,
    Value<String>? rawMetadataJson,
    Value<int>? rowid,
  }) {
    return CanonicalMediaBindingsCompanion(
      canonicalId: canonicalId ?? this.canonicalId,
      providerId: providerId ?? this.providerId,
      externalId: externalId ?? this.externalId,
      relativeLocator: relativeLocator ?? this.relativeLocator,
      rawMetadataJson: rawMetadataJson ?? this.rawMetadataJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (canonicalId.present) {
      map['canonical_id'] = Variable<String>(canonicalId.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (externalId.present) {
      map['external_id'] = Variable<String>(externalId.value);
    }
    if (relativeLocator.present) {
      map['relative_locator'] = Variable<String>(relativeLocator.value);
    }
    if (rawMetadataJson.present) {
      map['raw_metadata_json'] = Variable<String>(rawMetadataJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CanonicalMediaBindingsCompanion(')
          ..write('canonicalId: $canonicalId, ')
          ..write('providerId: $providerId, ')
          ..write('externalId: $externalId, ')
          ..write('relativeLocator: $relativeLocator, ')
          ..write('rawMetadataJson: $rawMetadataJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CanonicalChapterBindingsTable extends CanonicalChapterBindings
    with TableInfo<$CanonicalChapterBindingsTable, ChapterBindingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CanonicalChapterBindingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _canonicalIdMeta = const VerificationMeta(
    'canonicalId',
  );
  @override
  late final GeneratedColumn<String> canonicalId = GeneratedColumn<String>(
    'canonical_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES canonical_chapter_records (id)',
    ),
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _externalIdMeta = const VerificationMeta(
    'externalId',
  );
  @override
  late final GeneratedColumn<String> externalId = GeneratedColumn<String>(
    'external_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relativeLocatorMeta = const VerificationMeta(
    'relativeLocator',
  );
  @override
  late final GeneratedColumn<String> relativeLocator = GeneratedColumn<String>(
    'relative_locator',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawMetadataJsonMeta = const VerificationMeta(
    'rawMetadataJson',
  );
  @override
  late final GeneratedColumn<String> rawMetadataJson = GeneratedColumn<String>(
    'raw_metadata_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    canonicalId,
    providerId,
    externalId,
    relativeLocator,
    rawMetadataJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'canonical_chapter_bindings';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChapterBindingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('canonical_id')) {
      context.handle(
        _canonicalIdMeta,
        canonicalId.isAcceptableOrUnknown(
          data['canonical_id']!,
          _canonicalIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_canonicalIdMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('external_id')) {
      context.handle(
        _externalIdMeta,
        externalId.isAcceptableOrUnknown(data['external_id']!, _externalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_externalIdMeta);
    }
    if (data.containsKey('relative_locator')) {
      context.handle(
        _relativeLocatorMeta,
        relativeLocator.isAcceptableOrUnknown(
          data['relative_locator']!,
          _relativeLocatorMeta,
        ),
      );
    }
    if (data.containsKey('raw_metadata_json')) {
      context.handle(
        _rawMetadataJsonMeta,
        rawMetadataJson.isAcceptableOrUnknown(
          data['raw_metadata_json']!,
          _rawMetadataJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {providerId, externalId};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {canonicalId, providerId},
  ];
  @override
  ChapterBindingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChapterBindingRow(
      canonicalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}canonical_id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      externalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_id'],
      )!,
      relativeLocator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_locator'],
      ),
      rawMetadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_metadata_json'],
      )!,
    );
  }

  @override
  $CanonicalChapterBindingsTable createAlias(String alias) {
    return $CanonicalChapterBindingsTable(attachedDatabase, alias);
  }
}

class ChapterBindingRow extends DataClass
    implements Insertable<ChapterBindingRow> {
  final String canonicalId;
  final String providerId;
  final String externalId;
  final String? relativeLocator;
  final String rawMetadataJson;
  const ChapterBindingRow({
    required this.canonicalId,
    required this.providerId,
    required this.externalId,
    this.relativeLocator,
    required this.rawMetadataJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['canonical_id'] = Variable<String>(canonicalId);
    map['provider_id'] = Variable<String>(providerId);
    map['external_id'] = Variable<String>(externalId);
    if (!nullToAbsent || relativeLocator != null) {
      map['relative_locator'] = Variable<String>(relativeLocator);
    }
    map['raw_metadata_json'] = Variable<String>(rawMetadataJson);
    return map;
  }

  CanonicalChapterBindingsCompanion toCompanion(bool nullToAbsent) {
    return CanonicalChapterBindingsCompanion(
      canonicalId: Value(canonicalId),
      providerId: Value(providerId),
      externalId: Value(externalId),
      relativeLocator: relativeLocator == null && nullToAbsent
          ? const Value.absent()
          : Value(relativeLocator),
      rawMetadataJson: Value(rawMetadataJson),
    );
  }

  factory ChapterBindingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChapterBindingRow(
      canonicalId: serializer.fromJson<String>(json['canonicalId']),
      providerId: serializer.fromJson<String>(json['providerId']),
      externalId: serializer.fromJson<String>(json['externalId']),
      relativeLocator: serializer.fromJson<String?>(json['relativeLocator']),
      rawMetadataJson: serializer.fromJson<String>(json['rawMetadataJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'canonicalId': serializer.toJson<String>(canonicalId),
      'providerId': serializer.toJson<String>(providerId),
      'externalId': serializer.toJson<String>(externalId),
      'relativeLocator': serializer.toJson<String?>(relativeLocator),
      'rawMetadataJson': serializer.toJson<String>(rawMetadataJson),
    };
  }

  ChapterBindingRow copyWith({
    String? canonicalId,
    String? providerId,
    String? externalId,
    Value<String?> relativeLocator = const Value.absent(),
    String? rawMetadataJson,
  }) => ChapterBindingRow(
    canonicalId: canonicalId ?? this.canonicalId,
    providerId: providerId ?? this.providerId,
    externalId: externalId ?? this.externalId,
    relativeLocator: relativeLocator.present
        ? relativeLocator.value
        : this.relativeLocator,
    rawMetadataJson: rawMetadataJson ?? this.rawMetadataJson,
  );
  ChapterBindingRow copyWithCompanion(CanonicalChapterBindingsCompanion data) {
    return ChapterBindingRow(
      canonicalId: data.canonicalId.present
          ? data.canonicalId.value
          : this.canonicalId,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      externalId: data.externalId.present
          ? data.externalId.value
          : this.externalId,
      relativeLocator: data.relativeLocator.present
          ? data.relativeLocator.value
          : this.relativeLocator,
      rawMetadataJson: data.rawMetadataJson.present
          ? data.rawMetadataJson.value
          : this.rawMetadataJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChapterBindingRow(')
          ..write('canonicalId: $canonicalId, ')
          ..write('providerId: $providerId, ')
          ..write('externalId: $externalId, ')
          ..write('relativeLocator: $relativeLocator, ')
          ..write('rawMetadataJson: $rawMetadataJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    canonicalId,
    providerId,
    externalId,
    relativeLocator,
    rawMetadataJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChapterBindingRow &&
          other.canonicalId == this.canonicalId &&
          other.providerId == this.providerId &&
          other.externalId == this.externalId &&
          other.relativeLocator == this.relativeLocator &&
          other.rawMetadataJson == this.rawMetadataJson);
}

class CanonicalChapterBindingsCompanion
    extends UpdateCompanion<ChapterBindingRow> {
  final Value<String> canonicalId;
  final Value<String> providerId;
  final Value<String> externalId;
  final Value<String?> relativeLocator;
  final Value<String> rawMetadataJson;
  final Value<int> rowid;
  const CanonicalChapterBindingsCompanion({
    this.canonicalId = const Value.absent(),
    this.providerId = const Value.absent(),
    this.externalId = const Value.absent(),
    this.relativeLocator = const Value.absent(),
    this.rawMetadataJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CanonicalChapterBindingsCompanion.insert({
    required String canonicalId,
    required String providerId,
    required String externalId,
    this.relativeLocator = const Value.absent(),
    this.rawMetadataJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : canonicalId = Value(canonicalId),
       providerId = Value(providerId),
       externalId = Value(externalId);
  static Insertable<ChapterBindingRow> custom({
    Expression<String>? canonicalId,
    Expression<String>? providerId,
    Expression<String>? externalId,
    Expression<String>? relativeLocator,
    Expression<String>? rawMetadataJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (canonicalId != null) 'canonical_id': canonicalId,
      if (providerId != null) 'provider_id': providerId,
      if (externalId != null) 'external_id': externalId,
      if (relativeLocator != null) 'relative_locator': relativeLocator,
      if (rawMetadataJson != null) 'raw_metadata_json': rawMetadataJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CanonicalChapterBindingsCompanion copyWith({
    Value<String>? canonicalId,
    Value<String>? providerId,
    Value<String>? externalId,
    Value<String?>? relativeLocator,
    Value<String>? rawMetadataJson,
    Value<int>? rowid,
  }) {
    return CanonicalChapterBindingsCompanion(
      canonicalId: canonicalId ?? this.canonicalId,
      providerId: providerId ?? this.providerId,
      externalId: externalId ?? this.externalId,
      relativeLocator: relativeLocator ?? this.relativeLocator,
      rawMetadataJson: rawMetadataJson ?? this.rawMetadataJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (canonicalId.present) {
      map['canonical_id'] = Variable<String>(canonicalId.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (externalId.present) {
      map['external_id'] = Variable<String>(externalId.value);
    }
    if (relativeLocator.present) {
      map['relative_locator'] = Variable<String>(relativeLocator.value);
    }
    if (rawMetadataJson.present) {
      map['raw_metadata_json'] = Variable<String>(rawMetadataJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CanonicalChapterBindingsCompanion(')
          ..write('canonicalId: $canonicalId, ')
          ..write('providerId: $providerId, ')
          ..write('externalId: $externalId, ')
          ..write('relativeLocator: $relativeLocator, ')
          ..write('rawMetadataJson: $rawMetadataJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CanonicalEpisodeBindingsTable extends CanonicalEpisodeBindings
    with TableInfo<$CanonicalEpisodeBindingsTable, EpisodeBindingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CanonicalEpisodeBindingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _canonicalIdMeta = const VerificationMeta(
    'canonicalId',
  );
  @override
  late final GeneratedColumn<String> canonicalId = GeneratedColumn<String>(
    'canonical_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES canonical_episode_records (id)',
    ),
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _externalIdMeta = const VerificationMeta(
    'externalId',
  );
  @override
  late final GeneratedColumn<String> externalId = GeneratedColumn<String>(
    'external_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relativeLocatorMeta = const VerificationMeta(
    'relativeLocator',
  );
  @override
  late final GeneratedColumn<String> relativeLocator = GeneratedColumn<String>(
    'relative_locator',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawMetadataJsonMeta = const VerificationMeta(
    'rawMetadataJson',
  );
  @override
  late final GeneratedColumn<String> rawMetadataJson = GeneratedColumn<String>(
    'raw_metadata_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    canonicalId,
    providerId,
    externalId,
    relativeLocator,
    rawMetadataJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'canonical_episode_bindings';
  @override
  VerificationContext validateIntegrity(
    Insertable<EpisodeBindingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('canonical_id')) {
      context.handle(
        _canonicalIdMeta,
        canonicalId.isAcceptableOrUnknown(
          data['canonical_id']!,
          _canonicalIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_canonicalIdMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('external_id')) {
      context.handle(
        _externalIdMeta,
        externalId.isAcceptableOrUnknown(data['external_id']!, _externalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_externalIdMeta);
    }
    if (data.containsKey('relative_locator')) {
      context.handle(
        _relativeLocatorMeta,
        relativeLocator.isAcceptableOrUnknown(
          data['relative_locator']!,
          _relativeLocatorMeta,
        ),
      );
    }
    if (data.containsKey('raw_metadata_json')) {
      context.handle(
        _rawMetadataJsonMeta,
        rawMetadataJson.isAcceptableOrUnknown(
          data['raw_metadata_json']!,
          _rawMetadataJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {providerId, externalId};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {canonicalId, providerId},
  ];
  @override
  EpisodeBindingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EpisodeBindingRow(
      canonicalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}canonical_id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      externalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_id'],
      )!,
      relativeLocator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_locator'],
      ),
      rawMetadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_metadata_json'],
      )!,
    );
  }

  @override
  $CanonicalEpisodeBindingsTable createAlias(String alias) {
    return $CanonicalEpisodeBindingsTable(attachedDatabase, alias);
  }
}

class EpisodeBindingRow extends DataClass
    implements Insertable<EpisodeBindingRow> {
  final String canonicalId;
  final String providerId;
  final String externalId;
  final String? relativeLocator;
  final String rawMetadataJson;
  const EpisodeBindingRow({
    required this.canonicalId,
    required this.providerId,
    required this.externalId,
    this.relativeLocator,
    required this.rawMetadataJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['canonical_id'] = Variable<String>(canonicalId);
    map['provider_id'] = Variable<String>(providerId);
    map['external_id'] = Variable<String>(externalId);
    if (!nullToAbsent || relativeLocator != null) {
      map['relative_locator'] = Variable<String>(relativeLocator);
    }
    map['raw_metadata_json'] = Variable<String>(rawMetadataJson);
    return map;
  }

  CanonicalEpisodeBindingsCompanion toCompanion(bool nullToAbsent) {
    return CanonicalEpisodeBindingsCompanion(
      canonicalId: Value(canonicalId),
      providerId: Value(providerId),
      externalId: Value(externalId),
      relativeLocator: relativeLocator == null && nullToAbsent
          ? const Value.absent()
          : Value(relativeLocator),
      rawMetadataJson: Value(rawMetadataJson),
    );
  }

  factory EpisodeBindingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EpisodeBindingRow(
      canonicalId: serializer.fromJson<String>(json['canonicalId']),
      providerId: serializer.fromJson<String>(json['providerId']),
      externalId: serializer.fromJson<String>(json['externalId']),
      relativeLocator: serializer.fromJson<String?>(json['relativeLocator']),
      rawMetadataJson: serializer.fromJson<String>(json['rawMetadataJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'canonicalId': serializer.toJson<String>(canonicalId),
      'providerId': serializer.toJson<String>(providerId),
      'externalId': serializer.toJson<String>(externalId),
      'relativeLocator': serializer.toJson<String?>(relativeLocator),
      'rawMetadataJson': serializer.toJson<String>(rawMetadataJson),
    };
  }

  EpisodeBindingRow copyWith({
    String? canonicalId,
    String? providerId,
    String? externalId,
    Value<String?> relativeLocator = const Value.absent(),
    String? rawMetadataJson,
  }) => EpisodeBindingRow(
    canonicalId: canonicalId ?? this.canonicalId,
    providerId: providerId ?? this.providerId,
    externalId: externalId ?? this.externalId,
    relativeLocator: relativeLocator.present
        ? relativeLocator.value
        : this.relativeLocator,
    rawMetadataJson: rawMetadataJson ?? this.rawMetadataJson,
  );
  EpisodeBindingRow copyWithCompanion(CanonicalEpisodeBindingsCompanion data) {
    return EpisodeBindingRow(
      canonicalId: data.canonicalId.present
          ? data.canonicalId.value
          : this.canonicalId,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      externalId: data.externalId.present
          ? data.externalId.value
          : this.externalId,
      relativeLocator: data.relativeLocator.present
          ? data.relativeLocator.value
          : this.relativeLocator,
      rawMetadataJson: data.rawMetadataJson.present
          ? data.rawMetadataJson.value
          : this.rawMetadataJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EpisodeBindingRow(')
          ..write('canonicalId: $canonicalId, ')
          ..write('providerId: $providerId, ')
          ..write('externalId: $externalId, ')
          ..write('relativeLocator: $relativeLocator, ')
          ..write('rawMetadataJson: $rawMetadataJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    canonicalId,
    providerId,
    externalId,
    relativeLocator,
    rawMetadataJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EpisodeBindingRow &&
          other.canonicalId == this.canonicalId &&
          other.providerId == this.providerId &&
          other.externalId == this.externalId &&
          other.relativeLocator == this.relativeLocator &&
          other.rawMetadataJson == this.rawMetadataJson);
}

class CanonicalEpisodeBindingsCompanion
    extends UpdateCompanion<EpisodeBindingRow> {
  final Value<String> canonicalId;
  final Value<String> providerId;
  final Value<String> externalId;
  final Value<String?> relativeLocator;
  final Value<String> rawMetadataJson;
  final Value<int> rowid;
  const CanonicalEpisodeBindingsCompanion({
    this.canonicalId = const Value.absent(),
    this.providerId = const Value.absent(),
    this.externalId = const Value.absent(),
    this.relativeLocator = const Value.absent(),
    this.rawMetadataJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CanonicalEpisodeBindingsCompanion.insert({
    required String canonicalId,
    required String providerId,
    required String externalId,
    this.relativeLocator = const Value.absent(),
    this.rawMetadataJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : canonicalId = Value(canonicalId),
       providerId = Value(providerId),
       externalId = Value(externalId);
  static Insertable<EpisodeBindingRow> custom({
    Expression<String>? canonicalId,
    Expression<String>? providerId,
    Expression<String>? externalId,
    Expression<String>? relativeLocator,
    Expression<String>? rawMetadataJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (canonicalId != null) 'canonical_id': canonicalId,
      if (providerId != null) 'provider_id': providerId,
      if (externalId != null) 'external_id': externalId,
      if (relativeLocator != null) 'relative_locator': relativeLocator,
      if (rawMetadataJson != null) 'raw_metadata_json': rawMetadataJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CanonicalEpisodeBindingsCompanion copyWith({
    Value<String>? canonicalId,
    Value<String>? providerId,
    Value<String>? externalId,
    Value<String?>? relativeLocator,
    Value<String>? rawMetadataJson,
    Value<int>? rowid,
  }) {
    return CanonicalEpisodeBindingsCompanion(
      canonicalId: canonicalId ?? this.canonicalId,
      providerId: providerId ?? this.providerId,
      externalId: externalId ?? this.externalId,
      relativeLocator: relativeLocator ?? this.relativeLocator,
      rawMetadataJson: rawMetadataJson ?? this.rawMetadataJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (canonicalId.present) {
      map['canonical_id'] = Variable<String>(canonicalId.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (externalId.present) {
      map['external_id'] = Variable<String>(externalId.value);
    }
    if (relativeLocator.present) {
      map['relative_locator'] = Variable<String>(relativeLocator.value);
    }
    if (rawMetadataJson.present) {
      map['raw_metadata_json'] = Variable<String>(rawMetadataJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CanonicalEpisodeBindingsCompanion(')
          ..write('canonicalId: $canonicalId, ')
          ..write('providerId: $providerId, ')
          ..write('externalId: $externalId, ')
          ..write('relativeLocator: $relativeLocator, ')
          ..write('rawMetadataJson: $rawMetadataJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CanonicalLibraryRecordsTable extends CanonicalLibraryRecords
    with TableInfo<$CanonicalLibraryRecordsTable, CanonicalLibraryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CanonicalLibraryRecordsTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES canonical_media_records (id)',
    ),
  );
  static const VerificationMeta _isSavedMeta = const VerificationMeta(
    'isSaved',
  );
  @override
  late final GeneratedColumn<bool> isSaved = GeneratedColumn<bool>(
    'is_saved',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_saved" IN (0, 1))',
    ),
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
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
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
    isSaved,
    isFavorite,
    status,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'canonical_library_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<CanonicalLibraryRow> instance, {
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
    if (data.containsKey('is_saved')) {
      context.handle(
        _isSavedMeta,
        isSaved.isAcceptableOrUnknown(data['is_saved']!, _isSavedMeta),
      );
    } else if (isInserting) {
      context.missing(_isSavedMeta);
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    } else if (isInserting) {
      context.missing(_isFavoriteMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
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
  CanonicalLibraryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CanonicalLibraryRow(
      mediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_id'],
      )!,
      isSaved: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_saved'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CanonicalLibraryRecordsTable createAlias(String alias) {
    return $CanonicalLibraryRecordsTable(attachedDatabase, alias);
  }
}

class CanonicalLibraryRow extends DataClass
    implements Insertable<CanonicalLibraryRow> {
  final String mediaId;
  final bool isSaved;
  final bool isFavorite;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CanonicalLibraryRow({
    required this.mediaId,
    required this.isSaved,
    required this.isFavorite,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['media_id'] = Variable<String>(mediaId);
    map['is_saved'] = Variable<bool>(isSaved);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CanonicalLibraryRecordsCompanion toCompanion(bool nullToAbsent) {
    return CanonicalLibraryRecordsCompanion(
      mediaId: Value(mediaId),
      isSaved: Value(isSaved),
      isFavorite: Value(isFavorite),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CanonicalLibraryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CanonicalLibraryRow(
      mediaId: serializer.fromJson<String>(json['mediaId']),
      isSaved: serializer.fromJson<bool>(json['isSaved']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mediaId': serializer.toJson<String>(mediaId),
      'isSaved': serializer.toJson<bool>(isSaved),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CanonicalLibraryRow copyWith({
    String? mediaId,
    bool? isSaved,
    bool? isFavorite,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CanonicalLibraryRow(
    mediaId: mediaId ?? this.mediaId,
    isSaved: isSaved ?? this.isSaved,
    isFavorite: isFavorite ?? this.isFavorite,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CanonicalLibraryRow copyWithCompanion(CanonicalLibraryRecordsCompanion data) {
    return CanonicalLibraryRow(
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
      isSaved: data.isSaved.present ? data.isSaved.value : this.isSaved,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CanonicalLibraryRow(')
          ..write('mediaId: $mediaId, ')
          ..write('isSaved: $isSaved, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(mediaId, isSaved, isFavorite, status, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CanonicalLibraryRow &&
          other.mediaId == this.mediaId &&
          other.isSaved == this.isSaved &&
          other.isFavorite == this.isFavorite &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CanonicalLibraryRecordsCompanion
    extends UpdateCompanion<CanonicalLibraryRow> {
  final Value<String> mediaId;
  final Value<bool> isSaved;
  final Value<bool> isFavorite;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CanonicalLibraryRecordsCompanion({
    this.mediaId = const Value.absent(),
    this.isSaved = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CanonicalLibraryRecordsCompanion.insert({
    required String mediaId,
    required bool isSaved,
    required bool isFavorite,
    required String status,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : mediaId = Value(mediaId),
       isSaved = Value(isSaved),
       isFavorite = Value(isFavorite),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CanonicalLibraryRow> custom({
    Expression<String>? mediaId,
    Expression<bool>? isSaved,
    Expression<bool>? isFavorite,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (mediaId != null) 'media_id': mediaId,
      if (isSaved != null) 'is_saved': isSaved,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CanonicalLibraryRecordsCompanion copyWith({
    Value<String>? mediaId,
    Value<bool>? isSaved,
    Value<bool>? isFavorite,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CanonicalLibraryRecordsCompanion(
      mediaId: mediaId ?? this.mediaId,
      isSaved: isSaved ?? this.isSaved,
      isFavorite: isFavorite ?? this.isFavorite,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
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
    if (isSaved.present) {
      map['is_saved'] = Variable<bool>(isSaved.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('CanonicalLibraryRecordsCompanion(')
          ..write('mediaId: $mediaId, ')
          ..write('isSaved: $isSaved, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CanonicalMangaProgressRecordsTable extends CanonicalMangaProgressRecords
    with
        TableInfo<
          $CanonicalMangaProgressRecordsTable,
          CanonicalMangaProgressRow
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CanonicalMangaProgressRecordsTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES canonical_media_records (id)',
    ),
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES canonical_chapter_records (id)',
    ),
  );
  static const VerificationMeta _pageIndexMeta = const VerificationMeta(
    'pageIndex',
  );
  @override
  late final GeneratedColumn<int> pageIndex = GeneratedColumn<int>(
    'page_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (page_index >= 0)',
  );
  static const VerificationMeta _totalPagesMeta = const VerificationMeta(
    'totalPages',
  );
  @override
  late final GeneratedColumn<int> totalPages = GeneratedColumn<int>(
    'total_pages',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (total_pages IS NULL OR total_pages >= 0)',
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
    chapterId,
    pageIndex,
    totalPages,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'canonical_manga_progress_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<CanonicalMangaProgressRow> instance, {
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
    if (data.containsKey('page_index')) {
      context.handle(
        _pageIndexMeta,
        pageIndex.isAcceptableOrUnknown(data['page_index']!, _pageIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_pageIndexMeta);
    }
    if (data.containsKey('total_pages')) {
      context.handle(
        _totalPagesMeta,
        totalPages.isAcceptableOrUnknown(data['total_pages']!, _totalPagesMeta),
      );
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
  CanonicalMangaProgressRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CanonicalMangaProgressRow(
      mediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_id'],
      )!,
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_id'],
      )!,
      pageIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_index'],
      )!,
      totalPages: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_pages'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CanonicalMangaProgressRecordsTable createAlias(String alias) {
    return $CanonicalMangaProgressRecordsTable(attachedDatabase, alias);
  }
}

class CanonicalMangaProgressRow extends DataClass
    implements Insertable<CanonicalMangaProgressRow> {
  final String mediaId;
  final String chapterId;
  final int pageIndex;
  final int? totalPages;
  final DateTime updatedAt;
  const CanonicalMangaProgressRow({
    required this.mediaId,
    required this.chapterId,
    required this.pageIndex,
    this.totalPages,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['media_id'] = Variable<String>(mediaId);
    map['chapter_id'] = Variable<String>(chapterId);
    map['page_index'] = Variable<int>(pageIndex);
    if (!nullToAbsent || totalPages != null) {
      map['total_pages'] = Variable<int>(totalPages);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CanonicalMangaProgressRecordsCompanion toCompanion(bool nullToAbsent) {
    return CanonicalMangaProgressRecordsCompanion(
      mediaId: Value(mediaId),
      chapterId: Value(chapterId),
      pageIndex: Value(pageIndex),
      totalPages: totalPages == null && nullToAbsent
          ? const Value.absent()
          : Value(totalPages),
      updatedAt: Value(updatedAt),
    );
  }

  factory CanonicalMangaProgressRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CanonicalMangaProgressRow(
      mediaId: serializer.fromJson<String>(json['mediaId']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      pageIndex: serializer.fromJson<int>(json['pageIndex']),
      totalPages: serializer.fromJson<int?>(json['totalPages']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mediaId': serializer.toJson<String>(mediaId),
      'chapterId': serializer.toJson<String>(chapterId),
      'pageIndex': serializer.toJson<int>(pageIndex),
      'totalPages': serializer.toJson<int?>(totalPages),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CanonicalMangaProgressRow copyWith({
    String? mediaId,
    String? chapterId,
    int? pageIndex,
    Value<int?> totalPages = const Value.absent(),
    DateTime? updatedAt,
  }) => CanonicalMangaProgressRow(
    mediaId: mediaId ?? this.mediaId,
    chapterId: chapterId ?? this.chapterId,
    pageIndex: pageIndex ?? this.pageIndex,
    totalPages: totalPages.present ? totalPages.value : this.totalPages,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CanonicalMangaProgressRow copyWithCompanion(
    CanonicalMangaProgressRecordsCompanion data,
  ) {
    return CanonicalMangaProgressRow(
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      pageIndex: data.pageIndex.present ? data.pageIndex.value : this.pageIndex,
      totalPages: data.totalPages.present
          ? data.totalPages.value
          : this.totalPages,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CanonicalMangaProgressRow(')
          ..write('mediaId: $mediaId, ')
          ..write('chapterId: $chapterId, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('totalPages: $totalPages, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(mediaId, chapterId, pageIndex, totalPages, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CanonicalMangaProgressRow &&
          other.mediaId == this.mediaId &&
          other.chapterId == this.chapterId &&
          other.pageIndex == this.pageIndex &&
          other.totalPages == this.totalPages &&
          other.updatedAt == this.updatedAt);
}

class CanonicalMangaProgressRecordsCompanion
    extends UpdateCompanion<CanonicalMangaProgressRow> {
  final Value<String> mediaId;
  final Value<String> chapterId;
  final Value<int> pageIndex;
  final Value<int?> totalPages;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CanonicalMangaProgressRecordsCompanion({
    this.mediaId = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.pageIndex = const Value.absent(),
    this.totalPages = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CanonicalMangaProgressRecordsCompanion.insert({
    required String mediaId,
    required String chapterId,
    required int pageIndex,
    this.totalPages = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : mediaId = Value(mediaId),
       chapterId = Value(chapterId),
       pageIndex = Value(pageIndex),
       updatedAt = Value(updatedAt);
  static Insertable<CanonicalMangaProgressRow> custom({
    Expression<String>? mediaId,
    Expression<String>? chapterId,
    Expression<int>? pageIndex,
    Expression<int>? totalPages,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (mediaId != null) 'media_id': mediaId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (pageIndex != null) 'page_index': pageIndex,
      if (totalPages != null) 'total_pages': totalPages,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CanonicalMangaProgressRecordsCompanion copyWith({
    Value<String>? mediaId,
    Value<String>? chapterId,
    Value<int>? pageIndex,
    Value<int?>? totalPages,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CanonicalMangaProgressRecordsCompanion(
      mediaId: mediaId ?? this.mediaId,
      chapterId: chapterId ?? this.chapterId,
      pageIndex: pageIndex ?? this.pageIndex,
      totalPages: totalPages ?? this.totalPages,
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
    if (pageIndex.present) {
      map['page_index'] = Variable<int>(pageIndex.value);
    }
    if (totalPages.present) {
      map['total_pages'] = Variable<int>(totalPages.value);
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
    return (StringBuffer('CanonicalMangaProgressRecordsCompanion(')
          ..write('mediaId: $mediaId, ')
          ..write('chapterId: $chapterId, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('totalPages: $totalPages, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CanonicalAnimeProgressRecordsTable extends CanonicalAnimeProgressRecords
    with
        TableInfo<
          $CanonicalAnimeProgressRecordsTable,
          CanonicalAnimeProgressRow
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CanonicalAnimeProgressRecordsTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES canonical_media_records (id)',
    ),
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES canonical_episode_records (id)',
    ),
  );
  static const VerificationMeta _positionMillisecondsMeta =
      const VerificationMeta('positionMilliseconds');
  @override
  late final GeneratedColumn<int> positionMilliseconds = GeneratedColumn<int>(
    'position_milliseconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (position_milliseconds >= 0)',
  );
  static const VerificationMeta _durationMillisecondsMeta =
      const VerificationMeta('durationMilliseconds');
  @override
  late final GeneratedColumn<int> durationMilliseconds = GeneratedColumn<int>(
    'duration_milliseconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints:
        'CHECK (duration_milliseconds IS NULL OR duration_milliseconds >= 0)',
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
    positionMilliseconds,
    durationMilliseconds,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'canonical_anime_progress_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<CanonicalAnimeProgressRow> instance, {
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
    if (data.containsKey('position_milliseconds')) {
      context.handle(
        _positionMillisecondsMeta,
        positionMilliseconds.isAcceptableOrUnknown(
          data['position_milliseconds']!,
          _positionMillisecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_positionMillisecondsMeta);
    }
    if (data.containsKey('duration_milliseconds')) {
      context.handle(
        _durationMillisecondsMeta,
        durationMilliseconds.isAcceptableOrUnknown(
          data['duration_milliseconds']!,
          _durationMillisecondsMeta,
        ),
      );
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
  CanonicalAnimeProgressRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CanonicalAnimeProgressRow(
      mediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_id'],
      )!,
      episodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}episode_id'],
      )!,
      positionMilliseconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_milliseconds'],
      )!,
      durationMilliseconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_milliseconds'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CanonicalAnimeProgressRecordsTable createAlias(String alias) {
    return $CanonicalAnimeProgressRecordsTable(attachedDatabase, alias);
  }
}

class CanonicalAnimeProgressRow extends DataClass
    implements Insertable<CanonicalAnimeProgressRow> {
  final String mediaId;
  final String episodeId;
  final int positionMilliseconds;
  final int? durationMilliseconds;
  final DateTime updatedAt;
  const CanonicalAnimeProgressRow({
    required this.mediaId,
    required this.episodeId,
    required this.positionMilliseconds,
    this.durationMilliseconds,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['media_id'] = Variable<String>(mediaId);
    map['episode_id'] = Variable<String>(episodeId);
    map['position_milliseconds'] = Variable<int>(positionMilliseconds);
    if (!nullToAbsent || durationMilliseconds != null) {
      map['duration_milliseconds'] = Variable<int>(durationMilliseconds);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CanonicalAnimeProgressRecordsCompanion toCompanion(bool nullToAbsent) {
    return CanonicalAnimeProgressRecordsCompanion(
      mediaId: Value(mediaId),
      episodeId: Value(episodeId),
      positionMilliseconds: Value(positionMilliseconds),
      durationMilliseconds: durationMilliseconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMilliseconds),
      updatedAt: Value(updatedAt),
    );
  }

  factory CanonicalAnimeProgressRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CanonicalAnimeProgressRow(
      mediaId: serializer.fromJson<String>(json['mediaId']),
      episodeId: serializer.fromJson<String>(json['episodeId']),
      positionMilliseconds: serializer.fromJson<int>(
        json['positionMilliseconds'],
      ),
      durationMilliseconds: serializer.fromJson<int?>(
        json['durationMilliseconds'],
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mediaId': serializer.toJson<String>(mediaId),
      'episodeId': serializer.toJson<String>(episodeId),
      'positionMilliseconds': serializer.toJson<int>(positionMilliseconds),
      'durationMilliseconds': serializer.toJson<int?>(durationMilliseconds),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CanonicalAnimeProgressRow copyWith({
    String? mediaId,
    String? episodeId,
    int? positionMilliseconds,
    Value<int?> durationMilliseconds = const Value.absent(),
    DateTime? updatedAt,
  }) => CanonicalAnimeProgressRow(
    mediaId: mediaId ?? this.mediaId,
    episodeId: episodeId ?? this.episodeId,
    positionMilliseconds: positionMilliseconds ?? this.positionMilliseconds,
    durationMilliseconds: durationMilliseconds.present
        ? durationMilliseconds.value
        : this.durationMilliseconds,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CanonicalAnimeProgressRow copyWithCompanion(
    CanonicalAnimeProgressRecordsCompanion data,
  ) {
    return CanonicalAnimeProgressRow(
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
      episodeId: data.episodeId.present ? data.episodeId.value : this.episodeId,
      positionMilliseconds: data.positionMilliseconds.present
          ? data.positionMilliseconds.value
          : this.positionMilliseconds,
      durationMilliseconds: data.durationMilliseconds.present
          ? data.durationMilliseconds.value
          : this.durationMilliseconds,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CanonicalAnimeProgressRow(')
          ..write('mediaId: $mediaId, ')
          ..write('episodeId: $episodeId, ')
          ..write('positionMilliseconds: $positionMilliseconds, ')
          ..write('durationMilliseconds: $durationMilliseconds, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    mediaId,
    episodeId,
    positionMilliseconds,
    durationMilliseconds,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CanonicalAnimeProgressRow &&
          other.mediaId == this.mediaId &&
          other.episodeId == this.episodeId &&
          other.positionMilliseconds == this.positionMilliseconds &&
          other.durationMilliseconds == this.durationMilliseconds &&
          other.updatedAt == this.updatedAt);
}

class CanonicalAnimeProgressRecordsCompanion
    extends UpdateCompanion<CanonicalAnimeProgressRow> {
  final Value<String> mediaId;
  final Value<String> episodeId;
  final Value<int> positionMilliseconds;
  final Value<int?> durationMilliseconds;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CanonicalAnimeProgressRecordsCompanion({
    this.mediaId = const Value.absent(),
    this.episodeId = const Value.absent(),
    this.positionMilliseconds = const Value.absent(),
    this.durationMilliseconds = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CanonicalAnimeProgressRecordsCompanion.insert({
    required String mediaId,
    required String episodeId,
    required int positionMilliseconds,
    this.durationMilliseconds = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : mediaId = Value(mediaId),
       episodeId = Value(episodeId),
       positionMilliseconds = Value(positionMilliseconds),
       updatedAt = Value(updatedAt);
  static Insertable<CanonicalAnimeProgressRow> custom({
    Expression<String>? mediaId,
    Expression<String>? episodeId,
    Expression<int>? positionMilliseconds,
    Expression<int>? durationMilliseconds,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (mediaId != null) 'media_id': mediaId,
      if (episodeId != null) 'episode_id': episodeId,
      if (positionMilliseconds != null)
        'position_milliseconds': positionMilliseconds,
      if (durationMilliseconds != null)
        'duration_milliseconds': durationMilliseconds,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CanonicalAnimeProgressRecordsCompanion copyWith({
    Value<String>? mediaId,
    Value<String>? episodeId,
    Value<int>? positionMilliseconds,
    Value<int?>? durationMilliseconds,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CanonicalAnimeProgressRecordsCompanion(
      mediaId: mediaId ?? this.mediaId,
      episodeId: episodeId ?? this.episodeId,
      positionMilliseconds: positionMilliseconds ?? this.positionMilliseconds,
      durationMilliseconds: durationMilliseconds ?? this.durationMilliseconds,
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
    if (positionMilliseconds.present) {
      map['position_milliseconds'] = Variable<int>(positionMilliseconds.value);
    }
    if (durationMilliseconds.present) {
      map['duration_milliseconds'] = Variable<int>(durationMilliseconds.value);
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
    return (StringBuffer('CanonicalAnimeProgressRecordsCompanion(')
          ..write('mediaId: $mediaId, ')
          ..write('episodeId: $episodeId, ')
          ..write('positionMilliseconds: $positionMilliseconds, ')
          ..write('durationMilliseconds: $durationMilliseconds, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CanonicalMediaAliasesTable extends CanonicalMediaAliases
    with TableInfo<$CanonicalMediaAliasesTable, CanonicalAliasRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CanonicalMediaAliasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _historicalIdMeta = const VerificationMeta(
    'historicalId',
  );
  @override
  late final GeneratedColumn<String> historicalId = GeneratedColumn<String>(
    'historical_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetIdMeta = const VerificationMeta(
    'targetId',
  );
  @override
  late final GeneratedColumn<String> targetId = GeneratedColumn<String>(
    'target_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mergeAuditIdMeta = const VerificationMeta(
    'mergeAuditId',
  );
  @override
  late final GeneratedColumn<String> mergeAuditId = GeneratedColumn<String>(
    'merge_audit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    historicalId,
    targetId,
    mergeAuditId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'canonical_media_aliases';
  @override
  VerificationContext validateIntegrity(
    Insertable<CanonicalAliasRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('historical_id')) {
      context.handle(
        _historicalIdMeta,
        historicalId.isAcceptableOrUnknown(
          data['historical_id']!,
          _historicalIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_historicalIdMeta);
    }
    if (data.containsKey('target_id')) {
      context.handle(
        _targetIdMeta,
        targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_targetIdMeta);
    }
    if (data.containsKey('merge_audit_id')) {
      context.handle(
        _mergeAuditIdMeta,
        mergeAuditId.isAcceptableOrUnknown(
          data['merge_audit_id']!,
          _mergeAuditIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mergeAuditIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {historicalId};
  @override
  CanonicalAliasRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CanonicalAliasRow(
      historicalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}historical_id'],
      )!,
      targetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_id'],
      )!,
      mergeAuditId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merge_audit_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CanonicalMediaAliasesTable createAlias(String alias) {
    return $CanonicalMediaAliasesTable(attachedDatabase, alias);
  }
}

class CanonicalAliasRow extends DataClass
    implements Insertable<CanonicalAliasRow> {
  final String historicalId;
  final String targetId;
  final String mergeAuditId;
  final DateTime createdAt;
  const CanonicalAliasRow({
    required this.historicalId,
    required this.targetId,
    required this.mergeAuditId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['historical_id'] = Variable<String>(historicalId);
    map['target_id'] = Variable<String>(targetId);
    map['merge_audit_id'] = Variable<String>(mergeAuditId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CanonicalMediaAliasesCompanion toCompanion(bool nullToAbsent) {
    return CanonicalMediaAliasesCompanion(
      historicalId: Value(historicalId),
      targetId: Value(targetId),
      mergeAuditId: Value(mergeAuditId),
      createdAt: Value(createdAt),
    );
  }

  factory CanonicalAliasRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CanonicalAliasRow(
      historicalId: serializer.fromJson<String>(json['historicalId']),
      targetId: serializer.fromJson<String>(json['targetId']),
      mergeAuditId: serializer.fromJson<String>(json['mergeAuditId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'historicalId': serializer.toJson<String>(historicalId),
      'targetId': serializer.toJson<String>(targetId),
      'mergeAuditId': serializer.toJson<String>(mergeAuditId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CanonicalAliasRow copyWith({
    String? historicalId,
    String? targetId,
    String? mergeAuditId,
    DateTime? createdAt,
  }) => CanonicalAliasRow(
    historicalId: historicalId ?? this.historicalId,
    targetId: targetId ?? this.targetId,
    mergeAuditId: mergeAuditId ?? this.mergeAuditId,
    createdAt: createdAt ?? this.createdAt,
  );
  CanonicalAliasRow copyWithCompanion(CanonicalMediaAliasesCompanion data) {
    return CanonicalAliasRow(
      historicalId: data.historicalId.present
          ? data.historicalId.value
          : this.historicalId,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      mergeAuditId: data.mergeAuditId.present
          ? data.mergeAuditId.value
          : this.mergeAuditId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CanonicalAliasRow(')
          ..write('historicalId: $historicalId, ')
          ..write('targetId: $targetId, ')
          ..write('mergeAuditId: $mergeAuditId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(historicalId, targetId, mergeAuditId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CanonicalAliasRow &&
          other.historicalId == this.historicalId &&
          other.targetId == this.targetId &&
          other.mergeAuditId == this.mergeAuditId &&
          other.createdAt == this.createdAt);
}

class CanonicalMediaAliasesCompanion
    extends UpdateCompanion<CanonicalAliasRow> {
  final Value<String> historicalId;
  final Value<String> targetId;
  final Value<String> mergeAuditId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CanonicalMediaAliasesCompanion({
    this.historicalId = const Value.absent(),
    this.targetId = const Value.absent(),
    this.mergeAuditId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CanonicalMediaAliasesCompanion.insert({
    required String historicalId,
    required String targetId,
    required String mergeAuditId,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : historicalId = Value(historicalId),
       targetId = Value(targetId),
       mergeAuditId = Value(mergeAuditId),
       createdAt = Value(createdAt);
  static Insertable<CanonicalAliasRow> custom({
    Expression<String>? historicalId,
    Expression<String>? targetId,
    Expression<String>? mergeAuditId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (historicalId != null) 'historical_id': historicalId,
      if (targetId != null) 'target_id': targetId,
      if (mergeAuditId != null) 'merge_audit_id': mergeAuditId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CanonicalMediaAliasesCompanion copyWith({
    Value<String>? historicalId,
    Value<String>? targetId,
    Value<String>? mergeAuditId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CanonicalMediaAliasesCompanion(
      historicalId: historicalId ?? this.historicalId,
      targetId: targetId ?? this.targetId,
      mergeAuditId: mergeAuditId ?? this.mergeAuditId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (historicalId.present) {
      map['historical_id'] = Variable<String>(historicalId.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<String>(targetId.value);
    }
    if (mergeAuditId.present) {
      map['merge_audit_id'] = Variable<String>(mergeAuditId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CanonicalMediaAliasesCompanion(')
          ..write('historicalId: $historicalId, ')
          ..write('targetId: $targetId, ')
          ..write('mergeAuditId: $mergeAuditId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CanonicalMergeAuditsTable extends CanonicalMergeAudits
    with TableInfo<$CanonicalMergeAuditsTable, MergeAuditRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CanonicalMergeAuditsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetIdMeta = const VerificationMeta(
    'targetId',
  );
  @override
  late final GeneratedColumn<String> targetId = GeneratedColumn<String>(
    'target_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _snapshotJsonMeta = const VerificationMeta(
    'snapshotJson',
  );
  @override
  late final GeneratedColumn<String> snapshotJson = GeneratedColumn<String>(
    'snapshot_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mergedFingerprintMeta = const VerificationMeta(
    'mergedFingerprint',
  );
  @override
  late final GeneratedColumn<String> mergedFingerprint =
      GeneratedColumn<String>(
        'merged_fingerprint',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _conflictsJsonMeta = const VerificationMeta(
    'conflictsJson',
  );
  @override
  late final GeneratedColumn<String> conflictsJson = GeneratedColumn<String>(
    'conflicts_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _undoneAtMeta = const VerificationMeta(
    'undoneAt',
  );
  @override
  late final GeneratedColumn<DateTime> undoneAt = GeneratedColumn<DateTime>(
    'undone_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceId,
    targetId,
    reason,
    snapshotJson,
    mergedFingerprint,
    conflictsJson,
    createdAt,
    undoneAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'canonical_merge_audits';
  @override
  VerificationContext validateIntegrity(
    Insertable<MergeAuditRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('target_id')) {
      context.handle(
        _targetIdMeta,
        targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_targetIdMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('snapshot_json')) {
      context.handle(
        _snapshotJsonMeta,
        snapshotJson.isAcceptableOrUnknown(
          data['snapshot_json']!,
          _snapshotJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_snapshotJsonMeta);
    }
    if (data.containsKey('merged_fingerprint')) {
      context.handle(
        _mergedFingerprintMeta,
        mergedFingerprint.isAcceptableOrUnknown(
          data['merged_fingerprint']!,
          _mergedFingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mergedFingerprintMeta);
    }
    if (data.containsKey('conflicts_json')) {
      context.handle(
        _conflictsJsonMeta,
        conflictsJson.isAcceptableOrUnknown(
          data['conflicts_json']!,
          _conflictsJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('undone_at')) {
      context.handle(
        _undoneAtMeta,
        undoneAt.isAcceptableOrUnknown(data['undone_at']!, _undoneAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MergeAuditRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MergeAuditRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      targetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_id'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      snapshotJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snapshot_json'],
      )!,
      mergedFingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merged_fingerprint'],
      )!,
      conflictsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conflicts_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      undoneAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}undone_at'],
      ),
    );
  }

  @override
  $CanonicalMergeAuditsTable createAlias(String alias) {
    return $CanonicalMergeAuditsTable(attachedDatabase, alias);
  }
}

class MergeAuditRow extends DataClass implements Insertable<MergeAuditRow> {
  final String id;
  final String sourceId;
  final String targetId;
  final String reason;
  final String snapshotJson;
  final String mergedFingerprint;
  final String conflictsJson;
  final DateTime createdAt;
  final DateTime? undoneAt;
  const MergeAuditRow({
    required this.id,
    required this.sourceId,
    required this.targetId,
    required this.reason,
    required this.snapshotJson,
    required this.mergedFingerprint,
    required this.conflictsJson,
    required this.createdAt,
    this.undoneAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source_id'] = Variable<String>(sourceId);
    map['target_id'] = Variable<String>(targetId);
    map['reason'] = Variable<String>(reason);
    map['snapshot_json'] = Variable<String>(snapshotJson);
    map['merged_fingerprint'] = Variable<String>(mergedFingerprint);
    map['conflicts_json'] = Variable<String>(conflictsJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || undoneAt != null) {
      map['undone_at'] = Variable<DateTime>(undoneAt);
    }
    return map;
  }

  CanonicalMergeAuditsCompanion toCompanion(bool nullToAbsent) {
    return CanonicalMergeAuditsCompanion(
      id: Value(id),
      sourceId: Value(sourceId),
      targetId: Value(targetId),
      reason: Value(reason),
      snapshotJson: Value(snapshotJson),
      mergedFingerprint: Value(mergedFingerprint),
      conflictsJson: Value(conflictsJson),
      createdAt: Value(createdAt),
      undoneAt: undoneAt == null && nullToAbsent
          ? const Value.absent()
          : Value(undoneAt),
    );
  }

  factory MergeAuditRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MergeAuditRow(
      id: serializer.fromJson<String>(json['id']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      targetId: serializer.fromJson<String>(json['targetId']),
      reason: serializer.fromJson<String>(json['reason']),
      snapshotJson: serializer.fromJson<String>(json['snapshotJson']),
      mergedFingerprint: serializer.fromJson<String>(json['mergedFingerprint']),
      conflictsJson: serializer.fromJson<String>(json['conflictsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      undoneAt: serializer.fromJson<DateTime?>(json['undoneAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sourceId': serializer.toJson<String>(sourceId),
      'targetId': serializer.toJson<String>(targetId),
      'reason': serializer.toJson<String>(reason),
      'snapshotJson': serializer.toJson<String>(snapshotJson),
      'mergedFingerprint': serializer.toJson<String>(mergedFingerprint),
      'conflictsJson': serializer.toJson<String>(conflictsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'undoneAt': serializer.toJson<DateTime?>(undoneAt),
    };
  }

  MergeAuditRow copyWith({
    String? id,
    String? sourceId,
    String? targetId,
    String? reason,
    String? snapshotJson,
    String? mergedFingerprint,
    String? conflictsJson,
    DateTime? createdAt,
    Value<DateTime?> undoneAt = const Value.absent(),
  }) => MergeAuditRow(
    id: id ?? this.id,
    sourceId: sourceId ?? this.sourceId,
    targetId: targetId ?? this.targetId,
    reason: reason ?? this.reason,
    snapshotJson: snapshotJson ?? this.snapshotJson,
    mergedFingerprint: mergedFingerprint ?? this.mergedFingerprint,
    conflictsJson: conflictsJson ?? this.conflictsJson,
    createdAt: createdAt ?? this.createdAt,
    undoneAt: undoneAt.present ? undoneAt.value : this.undoneAt,
  );
  MergeAuditRow copyWithCompanion(CanonicalMergeAuditsCompanion data) {
    return MergeAuditRow(
      id: data.id.present ? data.id.value : this.id,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      reason: data.reason.present ? data.reason.value : this.reason,
      snapshotJson: data.snapshotJson.present
          ? data.snapshotJson.value
          : this.snapshotJson,
      mergedFingerprint: data.mergedFingerprint.present
          ? data.mergedFingerprint.value
          : this.mergedFingerprint,
      conflictsJson: data.conflictsJson.present
          ? data.conflictsJson.value
          : this.conflictsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      undoneAt: data.undoneAt.present ? data.undoneAt.value : this.undoneAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MergeAuditRow(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('targetId: $targetId, ')
          ..write('reason: $reason, ')
          ..write('snapshotJson: $snapshotJson, ')
          ..write('mergedFingerprint: $mergedFingerprint, ')
          ..write('conflictsJson: $conflictsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('undoneAt: $undoneAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceId,
    targetId,
    reason,
    snapshotJson,
    mergedFingerprint,
    conflictsJson,
    createdAt,
    undoneAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MergeAuditRow &&
          other.id == this.id &&
          other.sourceId == this.sourceId &&
          other.targetId == this.targetId &&
          other.reason == this.reason &&
          other.snapshotJson == this.snapshotJson &&
          other.mergedFingerprint == this.mergedFingerprint &&
          other.conflictsJson == this.conflictsJson &&
          other.createdAt == this.createdAt &&
          other.undoneAt == this.undoneAt);
}

class CanonicalMergeAuditsCompanion extends UpdateCompanion<MergeAuditRow> {
  final Value<String> id;
  final Value<String> sourceId;
  final Value<String> targetId;
  final Value<String> reason;
  final Value<String> snapshotJson;
  final Value<String> mergedFingerprint;
  final Value<String> conflictsJson;
  final Value<DateTime> createdAt;
  final Value<DateTime?> undoneAt;
  final Value<int> rowid;
  const CanonicalMergeAuditsCompanion({
    this.id = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.targetId = const Value.absent(),
    this.reason = const Value.absent(),
    this.snapshotJson = const Value.absent(),
    this.mergedFingerprint = const Value.absent(),
    this.conflictsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.undoneAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CanonicalMergeAuditsCompanion.insert({
    required String id,
    required String sourceId,
    required String targetId,
    required String reason,
    required String snapshotJson,
    required String mergedFingerprint,
    this.conflictsJson = const Value.absent(),
    required DateTime createdAt,
    this.undoneAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sourceId = Value(sourceId),
       targetId = Value(targetId),
       reason = Value(reason),
       snapshotJson = Value(snapshotJson),
       mergedFingerprint = Value(mergedFingerprint),
       createdAt = Value(createdAt);
  static Insertable<MergeAuditRow> custom({
    Expression<String>? id,
    Expression<String>? sourceId,
    Expression<String>? targetId,
    Expression<String>? reason,
    Expression<String>? snapshotJson,
    Expression<String>? mergedFingerprint,
    Expression<String>? conflictsJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? undoneAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceId != null) 'source_id': sourceId,
      if (targetId != null) 'target_id': targetId,
      if (reason != null) 'reason': reason,
      if (snapshotJson != null) 'snapshot_json': snapshotJson,
      if (mergedFingerprint != null) 'merged_fingerprint': mergedFingerprint,
      if (conflictsJson != null) 'conflicts_json': conflictsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (undoneAt != null) 'undone_at': undoneAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CanonicalMergeAuditsCompanion copyWith({
    Value<String>? id,
    Value<String>? sourceId,
    Value<String>? targetId,
    Value<String>? reason,
    Value<String>? snapshotJson,
    Value<String>? mergedFingerprint,
    Value<String>? conflictsJson,
    Value<DateTime>? createdAt,
    Value<DateTime?>? undoneAt,
    Value<int>? rowid,
  }) {
    return CanonicalMergeAuditsCompanion(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      targetId: targetId ?? this.targetId,
      reason: reason ?? this.reason,
      snapshotJson: snapshotJson ?? this.snapshotJson,
      mergedFingerprint: mergedFingerprint ?? this.mergedFingerprint,
      conflictsJson: conflictsJson ?? this.conflictsJson,
      createdAt: createdAt ?? this.createdAt,
      undoneAt: undoneAt ?? this.undoneAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<String>(targetId.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (snapshotJson.present) {
      map['snapshot_json'] = Variable<String>(snapshotJson.value);
    }
    if (mergedFingerprint.present) {
      map['merged_fingerprint'] = Variable<String>(mergedFingerprint.value);
    }
    if (conflictsJson.present) {
      map['conflicts_json'] = Variable<String>(conflictsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (undoneAt.present) {
      map['undone_at'] = Variable<DateTime>(undoneAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CanonicalMergeAuditsCompanion(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('targetId: $targetId, ')
          ..write('reason: $reason, ')
          ..write('snapshotJson: $snapshotJson, ')
          ..write('mergedFingerprint: $mergedFingerprint, ')
          ..write('conflictsJson: $conflictsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('undoneAt: $undoneAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MangaSourcePageResumesTable extends MangaSourcePageResumes
    with TableInfo<$MangaSourcePageResumesTable, MangaSourcePageResumeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MangaSourcePageResumesTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES canonical_media_records (id)',
    ),
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES canonical_chapter_records (id)',
    ),
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterExternalIdMeta = const VerificationMeta(
    'chapterExternalId',
  );
  @override
  late final GeneratedColumn<String> chapterExternalId =
      GeneratedColumn<String>(
        'chapter_external_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _pageIndexMeta = const VerificationMeta(
    'pageIndex',
  );
  @override
  late final GeneratedColumn<int> pageIndex = GeneratedColumn<int>(
    'page_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (page_index >= 0)',
  );
  static const VerificationMeta _totalPagesMeta = const VerificationMeta(
    'totalPages',
  );
  @override
  late final GeneratedColumn<int> totalPages = GeneratedColumn<int>(
    'total_pages',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (total_pages IS NULL OR total_pages >= 0)',
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
    chapterId,
    providerId,
    chapterExternalId,
    pageIndex,
    totalPages,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'manga_source_page_resumes';
  @override
  VerificationContext validateIntegrity(
    Insertable<MangaSourcePageResumeRow> instance, {
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
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('chapter_external_id')) {
      context.handle(
        _chapterExternalIdMeta,
        chapterExternalId.isAcceptableOrUnknown(
          data['chapter_external_id']!,
          _chapterExternalIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chapterExternalIdMeta);
    }
    if (data.containsKey('page_index')) {
      context.handle(
        _pageIndexMeta,
        pageIndex.isAcceptableOrUnknown(data['page_index']!, _pageIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_pageIndexMeta);
    }
    if (data.containsKey('total_pages')) {
      context.handle(
        _totalPagesMeta,
        totalPages.isAcceptableOrUnknown(data['total_pages']!, _totalPagesMeta),
      );
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
  Set<GeneratedColumn> get $primaryKey => {providerId, chapterExternalId};
  @override
  MangaSourcePageResumeRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MangaSourcePageResumeRow(
      mediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_id'],
      )!,
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      chapterExternalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_external_id'],
      )!,
      pageIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_index'],
      )!,
      totalPages: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_pages'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MangaSourcePageResumesTable createAlias(String alias) {
    return $MangaSourcePageResumesTable(attachedDatabase, alias);
  }
}

class MangaSourcePageResumeRow extends DataClass
    implements Insertable<MangaSourcePageResumeRow> {
  final String mediaId;
  final String chapterId;
  final String providerId;
  final String chapterExternalId;
  final int pageIndex;
  final int? totalPages;
  final DateTime updatedAt;
  const MangaSourcePageResumeRow({
    required this.mediaId,
    required this.chapterId,
    required this.providerId,
    required this.chapterExternalId,
    required this.pageIndex,
    this.totalPages,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['media_id'] = Variable<String>(mediaId);
    map['chapter_id'] = Variable<String>(chapterId);
    map['provider_id'] = Variable<String>(providerId);
    map['chapter_external_id'] = Variable<String>(chapterExternalId);
    map['page_index'] = Variable<int>(pageIndex);
    if (!nullToAbsent || totalPages != null) {
      map['total_pages'] = Variable<int>(totalPages);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MangaSourcePageResumesCompanion toCompanion(bool nullToAbsent) {
    return MangaSourcePageResumesCompanion(
      mediaId: Value(mediaId),
      chapterId: Value(chapterId),
      providerId: Value(providerId),
      chapterExternalId: Value(chapterExternalId),
      pageIndex: Value(pageIndex),
      totalPages: totalPages == null && nullToAbsent
          ? const Value.absent()
          : Value(totalPages),
      updatedAt: Value(updatedAt),
    );
  }

  factory MangaSourcePageResumeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MangaSourcePageResumeRow(
      mediaId: serializer.fromJson<String>(json['mediaId']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      providerId: serializer.fromJson<String>(json['providerId']),
      chapterExternalId: serializer.fromJson<String>(json['chapterExternalId']),
      pageIndex: serializer.fromJson<int>(json['pageIndex']),
      totalPages: serializer.fromJson<int?>(json['totalPages']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mediaId': serializer.toJson<String>(mediaId),
      'chapterId': serializer.toJson<String>(chapterId),
      'providerId': serializer.toJson<String>(providerId),
      'chapterExternalId': serializer.toJson<String>(chapterExternalId),
      'pageIndex': serializer.toJson<int>(pageIndex),
      'totalPages': serializer.toJson<int?>(totalPages),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MangaSourcePageResumeRow copyWith({
    String? mediaId,
    String? chapterId,
    String? providerId,
    String? chapterExternalId,
    int? pageIndex,
    Value<int?> totalPages = const Value.absent(),
    DateTime? updatedAt,
  }) => MangaSourcePageResumeRow(
    mediaId: mediaId ?? this.mediaId,
    chapterId: chapterId ?? this.chapterId,
    providerId: providerId ?? this.providerId,
    chapterExternalId: chapterExternalId ?? this.chapterExternalId,
    pageIndex: pageIndex ?? this.pageIndex,
    totalPages: totalPages.present ? totalPages.value : this.totalPages,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MangaSourcePageResumeRow copyWithCompanion(
    MangaSourcePageResumesCompanion data,
  ) {
    return MangaSourcePageResumeRow(
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      chapterExternalId: data.chapterExternalId.present
          ? data.chapterExternalId.value
          : this.chapterExternalId,
      pageIndex: data.pageIndex.present ? data.pageIndex.value : this.pageIndex,
      totalPages: data.totalPages.present
          ? data.totalPages.value
          : this.totalPages,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MangaSourcePageResumeRow(')
          ..write('mediaId: $mediaId, ')
          ..write('chapterId: $chapterId, ')
          ..write('providerId: $providerId, ')
          ..write('chapterExternalId: $chapterExternalId, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('totalPages: $totalPages, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    mediaId,
    chapterId,
    providerId,
    chapterExternalId,
    pageIndex,
    totalPages,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MangaSourcePageResumeRow &&
          other.mediaId == this.mediaId &&
          other.chapterId == this.chapterId &&
          other.providerId == this.providerId &&
          other.chapterExternalId == this.chapterExternalId &&
          other.pageIndex == this.pageIndex &&
          other.totalPages == this.totalPages &&
          other.updatedAt == this.updatedAt);
}

class MangaSourcePageResumesCompanion
    extends UpdateCompanion<MangaSourcePageResumeRow> {
  final Value<String> mediaId;
  final Value<String> chapterId;
  final Value<String> providerId;
  final Value<String> chapterExternalId;
  final Value<int> pageIndex;
  final Value<int?> totalPages;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MangaSourcePageResumesCompanion({
    this.mediaId = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.providerId = const Value.absent(),
    this.chapterExternalId = const Value.absent(),
    this.pageIndex = const Value.absent(),
    this.totalPages = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MangaSourcePageResumesCompanion.insert({
    required String mediaId,
    required String chapterId,
    required String providerId,
    required String chapterExternalId,
    required int pageIndex,
    this.totalPages = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : mediaId = Value(mediaId),
       chapterId = Value(chapterId),
       providerId = Value(providerId),
       chapterExternalId = Value(chapterExternalId),
       pageIndex = Value(pageIndex),
       updatedAt = Value(updatedAt);
  static Insertable<MangaSourcePageResumeRow> custom({
    Expression<String>? mediaId,
    Expression<String>? chapterId,
    Expression<String>? providerId,
    Expression<String>? chapterExternalId,
    Expression<int>? pageIndex,
    Expression<int>? totalPages,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (mediaId != null) 'media_id': mediaId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (providerId != null) 'provider_id': providerId,
      if (chapterExternalId != null) 'chapter_external_id': chapterExternalId,
      if (pageIndex != null) 'page_index': pageIndex,
      if (totalPages != null) 'total_pages': totalPages,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MangaSourcePageResumesCompanion copyWith({
    Value<String>? mediaId,
    Value<String>? chapterId,
    Value<String>? providerId,
    Value<String>? chapterExternalId,
    Value<int>? pageIndex,
    Value<int?>? totalPages,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MangaSourcePageResumesCompanion(
      mediaId: mediaId ?? this.mediaId,
      chapterId: chapterId ?? this.chapterId,
      providerId: providerId ?? this.providerId,
      chapterExternalId: chapterExternalId ?? this.chapterExternalId,
      pageIndex: pageIndex ?? this.pageIndex,
      totalPages: totalPages ?? this.totalPages,
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
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (chapterExternalId.present) {
      map['chapter_external_id'] = Variable<String>(chapterExternalId.value);
    }
    if (pageIndex.present) {
      map['page_index'] = Variable<int>(pageIndex.value);
    }
    if (totalPages.present) {
      map['total_pages'] = Variable<int>(totalPages.value);
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
    return (StringBuffer('MangaSourcePageResumesCompanion(')
          ..write('mediaId: $mediaId, ')
          ..write('chapterId: $chapterId, ')
          ..write('providerId: $providerId, ')
          ..write('chapterExternalId: $chapterExternalId, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('totalPages: $totalPages, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnimeSourcePlaybackResumesTable extends AnimeSourcePlaybackResumes
    with
        TableInfo<
          $AnimeSourcePlaybackResumesTable,
          AnimeSourcePlaybackResumeRow
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnimeSourcePlaybackResumesTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES canonical_media_records (id)',
    ),
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES canonical_episode_records (id)',
    ),
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _episodeExternalIdMeta = const VerificationMeta(
    'episodeExternalId',
  );
  @override
  late final GeneratedColumn<String> episodeExternalId =
      GeneratedColumn<String>(
        'episode_external_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _positionMillisecondsMeta =
      const VerificationMeta('positionMilliseconds');
  @override
  late final GeneratedColumn<int> positionMilliseconds = GeneratedColumn<int>(
    'position_milliseconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (position_milliseconds >= 0)',
  );
  static const VerificationMeta _durationMillisecondsMeta =
      const VerificationMeta('durationMilliseconds');
  @override
  late final GeneratedColumn<int> durationMilliseconds = GeneratedColumn<int>(
    'duration_milliseconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints:
        'CHECK (duration_milliseconds IS NULL OR duration_milliseconds >= 0)',
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
    providerId,
    episodeExternalId,
    positionMilliseconds,
    durationMilliseconds,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'anime_source_playback_resumes';
  @override
  VerificationContext validateIntegrity(
    Insertable<AnimeSourcePlaybackResumeRow> instance, {
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
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('episode_external_id')) {
      context.handle(
        _episodeExternalIdMeta,
        episodeExternalId.isAcceptableOrUnknown(
          data['episode_external_id']!,
          _episodeExternalIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_episodeExternalIdMeta);
    }
    if (data.containsKey('position_milliseconds')) {
      context.handle(
        _positionMillisecondsMeta,
        positionMilliseconds.isAcceptableOrUnknown(
          data['position_milliseconds']!,
          _positionMillisecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_positionMillisecondsMeta);
    }
    if (data.containsKey('duration_milliseconds')) {
      context.handle(
        _durationMillisecondsMeta,
        durationMilliseconds.isAcceptableOrUnknown(
          data['duration_milliseconds']!,
          _durationMillisecondsMeta,
        ),
      );
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
  Set<GeneratedColumn> get $primaryKey => {providerId, episodeExternalId};
  @override
  AnimeSourcePlaybackResumeRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnimeSourcePlaybackResumeRow(
      mediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_id'],
      )!,
      episodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}episode_id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      episodeExternalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}episode_external_id'],
      )!,
      positionMilliseconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_milliseconds'],
      )!,
      durationMilliseconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_milliseconds'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AnimeSourcePlaybackResumesTable createAlias(String alias) {
    return $AnimeSourcePlaybackResumesTable(attachedDatabase, alias);
  }
}

class AnimeSourcePlaybackResumeRow extends DataClass
    implements Insertable<AnimeSourcePlaybackResumeRow> {
  final String mediaId;
  final String episodeId;
  final String providerId;
  final String episodeExternalId;
  final int positionMilliseconds;
  final int? durationMilliseconds;
  final DateTime updatedAt;
  const AnimeSourcePlaybackResumeRow({
    required this.mediaId,
    required this.episodeId,
    required this.providerId,
    required this.episodeExternalId,
    required this.positionMilliseconds,
    this.durationMilliseconds,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['media_id'] = Variable<String>(mediaId);
    map['episode_id'] = Variable<String>(episodeId);
    map['provider_id'] = Variable<String>(providerId);
    map['episode_external_id'] = Variable<String>(episodeExternalId);
    map['position_milliseconds'] = Variable<int>(positionMilliseconds);
    if (!nullToAbsent || durationMilliseconds != null) {
      map['duration_milliseconds'] = Variable<int>(durationMilliseconds);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AnimeSourcePlaybackResumesCompanion toCompanion(bool nullToAbsent) {
    return AnimeSourcePlaybackResumesCompanion(
      mediaId: Value(mediaId),
      episodeId: Value(episodeId),
      providerId: Value(providerId),
      episodeExternalId: Value(episodeExternalId),
      positionMilliseconds: Value(positionMilliseconds),
      durationMilliseconds: durationMilliseconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMilliseconds),
      updatedAt: Value(updatedAt),
    );
  }

  factory AnimeSourcePlaybackResumeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnimeSourcePlaybackResumeRow(
      mediaId: serializer.fromJson<String>(json['mediaId']),
      episodeId: serializer.fromJson<String>(json['episodeId']),
      providerId: serializer.fromJson<String>(json['providerId']),
      episodeExternalId: serializer.fromJson<String>(json['episodeExternalId']),
      positionMilliseconds: serializer.fromJson<int>(
        json['positionMilliseconds'],
      ),
      durationMilliseconds: serializer.fromJson<int?>(
        json['durationMilliseconds'],
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mediaId': serializer.toJson<String>(mediaId),
      'episodeId': serializer.toJson<String>(episodeId),
      'providerId': serializer.toJson<String>(providerId),
      'episodeExternalId': serializer.toJson<String>(episodeExternalId),
      'positionMilliseconds': serializer.toJson<int>(positionMilliseconds),
      'durationMilliseconds': serializer.toJson<int?>(durationMilliseconds),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AnimeSourcePlaybackResumeRow copyWith({
    String? mediaId,
    String? episodeId,
    String? providerId,
    String? episodeExternalId,
    int? positionMilliseconds,
    Value<int?> durationMilliseconds = const Value.absent(),
    DateTime? updatedAt,
  }) => AnimeSourcePlaybackResumeRow(
    mediaId: mediaId ?? this.mediaId,
    episodeId: episodeId ?? this.episodeId,
    providerId: providerId ?? this.providerId,
    episodeExternalId: episodeExternalId ?? this.episodeExternalId,
    positionMilliseconds: positionMilliseconds ?? this.positionMilliseconds,
    durationMilliseconds: durationMilliseconds.present
        ? durationMilliseconds.value
        : this.durationMilliseconds,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AnimeSourcePlaybackResumeRow copyWithCompanion(
    AnimeSourcePlaybackResumesCompanion data,
  ) {
    return AnimeSourcePlaybackResumeRow(
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
      episodeId: data.episodeId.present ? data.episodeId.value : this.episodeId,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      episodeExternalId: data.episodeExternalId.present
          ? data.episodeExternalId.value
          : this.episodeExternalId,
      positionMilliseconds: data.positionMilliseconds.present
          ? data.positionMilliseconds.value
          : this.positionMilliseconds,
      durationMilliseconds: data.durationMilliseconds.present
          ? data.durationMilliseconds.value
          : this.durationMilliseconds,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnimeSourcePlaybackResumeRow(')
          ..write('mediaId: $mediaId, ')
          ..write('episodeId: $episodeId, ')
          ..write('providerId: $providerId, ')
          ..write('episodeExternalId: $episodeExternalId, ')
          ..write('positionMilliseconds: $positionMilliseconds, ')
          ..write('durationMilliseconds: $durationMilliseconds, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    mediaId,
    episodeId,
    providerId,
    episodeExternalId,
    positionMilliseconds,
    durationMilliseconds,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnimeSourcePlaybackResumeRow &&
          other.mediaId == this.mediaId &&
          other.episodeId == this.episodeId &&
          other.providerId == this.providerId &&
          other.episodeExternalId == this.episodeExternalId &&
          other.positionMilliseconds == this.positionMilliseconds &&
          other.durationMilliseconds == this.durationMilliseconds &&
          other.updatedAt == this.updatedAt);
}

class AnimeSourcePlaybackResumesCompanion
    extends UpdateCompanion<AnimeSourcePlaybackResumeRow> {
  final Value<String> mediaId;
  final Value<String> episodeId;
  final Value<String> providerId;
  final Value<String> episodeExternalId;
  final Value<int> positionMilliseconds;
  final Value<int?> durationMilliseconds;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AnimeSourcePlaybackResumesCompanion({
    this.mediaId = const Value.absent(),
    this.episodeId = const Value.absent(),
    this.providerId = const Value.absent(),
    this.episodeExternalId = const Value.absent(),
    this.positionMilliseconds = const Value.absent(),
    this.durationMilliseconds = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnimeSourcePlaybackResumesCompanion.insert({
    required String mediaId,
    required String episodeId,
    required String providerId,
    required String episodeExternalId,
    required int positionMilliseconds,
    this.durationMilliseconds = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : mediaId = Value(mediaId),
       episodeId = Value(episodeId),
       providerId = Value(providerId),
       episodeExternalId = Value(episodeExternalId),
       positionMilliseconds = Value(positionMilliseconds),
       updatedAt = Value(updatedAt);
  static Insertable<AnimeSourcePlaybackResumeRow> custom({
    Expression<String>? mediaId,
    Expression<String>? episodeId,
    Expression<String>? providerId,
    Expression<String>? episodeExternalId,
    Expression<int>? positionMilliseconds,
    Expression<int>? durationMilliseconds,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (mediaId != null) 'media_id': mediaId,
      if (episodeId != null) 'episode_id': episodeId,
      if (providerId != null) 'provider_id': providerId,
      if (episodeExternalId != null) 'episode_external_id': episodeExternalId,
      if (positionMilliseconds != null)
        'position_milliseconds': positionMilliseconds,
      if (durationMilliseconds != null)
        'duration_milliseconds': durationMilliseconds,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnimeSourcePlaybackResumesCompanion copyWith({
    Value<String>? mediaId,
    Value<String>? episodeId,
    Value<String>? providerId,
    Value<String>? episodeExternalId,
    Value<int>? positionMilliseconds,
    Value<int?>? durationMilliseconds,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AnimeSourcePlaybackResumesCompanion(
      mediaId: mediaId ?? this.mediaId,
      episodeId: episodeId ?? this.episodeId,
      providerId: providerId ?? this.providerId,
      episodeExternalId: episodeExternalId ?? this.episodeExternalId,
      positionMilliseconds: positionMilliseconds ?? this.positionMilliseconds,
      durationMilliseconds: durationMilliseconds ?? this.durationMilliseconds,
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
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (episodeExternalId.present) {
      map['episode_external_id'] = Variable<String>(episodeExternalId.value);
    }
    if (positionMilliseconds.present) {
      map['position_milliseconds'] = Variable<int>(positionMilliseconds.value);
    }
    if (durationMilliseconds.present) {
      map['duration_milliseconds'] = Variable<int>(durationMilliseconds.value);
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
    return (StringBuffer('AnimeSourcePlaybackResumesCompanion(')
          ..write('mediaId: $mediaId, ')
          ..write('episodeId: $episodeId, ')
          ..write('providerId: $providerId, ')
          ..write('episodeExternalId: $episodeExternalId, ')
          ..write('positionMilliseconds: $positionMilliseconds, ')
          ..write('durationMilliseconds: $durationMilliseconds, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PreferredMediaSourcesTable extends PreferredMediaSources
    with TableInfo<$PreferredMediaSourcesTable, PreferredMediaSourceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreferredMediaSourcesTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES canonical_media_records (id)',
    ),
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [mediaId, providerId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'preferred_media_sources';
  @override
  VerificationContext validateIntegrity(
    Insertable<PreferredMediaSourceRow> instance, {
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
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {mediaId};
  @override
  PreferredMediaSourceRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PreferredMediaSourceRow(
      mediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
    );
  }

  @override
  $PreferredMediaSourcesTable createAlias(String alias) {
    return $PreferredMediaSourcesTable(attachedDatabase, alias);
  }
}

class PreferredMediaSourceRow extends DataClass
    implements Insertable<PreferredMediaSourceRow> {
  final String mediaId;
  final String providerId;
  const PreferredMediaSourceRow({
    required this.mediaId,
    required this.providerId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['media_id'] = Variable<String>(mediaId);
    map['provider_id'] = Variable<String>(providerId);
    return map;
  }

  PreferredMediaSourcesCompanion toCompanion(bool nullToAbsent) {
    return PreferredMediaSourcesCompanion(
      mediaId: Value(mediaId),
      providerId: Value(providerId),
    );
  }

  factory PreferredMediaSourceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PreferredMediaSourceRow(
      mediaId: serializer.fromJson<String>(json['mediaId']),
      providerId: serializer.fromJson<String>(json['providerId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mediaId': serializer.toJson<String>(mediaId),
      'providerId': serializer.toJson<String>(providerId),
    };
  }

  PreferredMediaSourceRow copyWith({String? mediaId, String? providerId}) =>
      PreferredMediaSourceRow(
        mediaId: mediaId ?? this.mediaId,
        providerId: providerId ?? this.providerId,
      );
  PreferredMediaSourceRow copyWithCompanion(
    PreferredMediaSourcesCompanion data,
  ) {
    return PreferredMediaSourceRow(
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PreferredMediaSourceRow(')
          ..write('mediaId: $mediaId, ')
          ..write('providerId: $providerId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(mediaId, providerId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PreferredMediaSourceRow &&
          other.mediaId == this.mediaId &&
          other.providerId == this.providerId);
}

class PreferredMediaSourcesCompanion
    extends UpdateCompanion<PreferredMediaSourceRow> {
  final Value<String> mediaId;
  final Value<String> providerId;
  final Value<int> rowid;
  const PreferredMediaSourcesCompanion({
    this.mediaId = const Value.absent(),
    this.providerId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PreferredMediaSourcesCompanion.insert({
    required String mediaId,
    required String providerId,
    this.rowid = const Value.absent(),
  }) : mediaId = Value(mediaId),
       providerId = Value(providerId);
  static Insertable<PreferredMediaSourceRow> custom({
    Expression<String>? mediaId,
    Expression<String>? providerId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (mediaId != null) 'media_id': mediaId,
      if (providerId != null) 'provider_id': providerId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PreferredMediaSourcesCompanion copyWith({
    Value<String>? mediaId,
    Value<String>? providerId,
    Value<int>? rowid,
  }) {
    return PreferredMediaSourcesCompanion(
      mediaId: mediaId ?? this.mediaId,
      providerId: providerId ?? this.providerId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (mediaId.present) {
      map['media_id'] = Variable<String>(mediaId.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreferredMediaSourcesCompanion(')
          ..write('mediaId: $mediaId, ')
          ..write('providerId: $providerId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAssetRecordsTable extends LocalAssetRecords
    with TableInfo<$LocalAssetRecordsTable, LocalAssetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAssetRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownershipMeta = const VerificationMeta(
    'ownership',
  );
  @override
  late final GeneratedColumn<String> ownership = GeneratedColumn<String>(
    'ownership',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bindingExternalIdMeta = const VerificationMeta(
    'bindingExternalId',
  );
  @override
  late final GeneratedColumn<String> bindingExternalId =
      GeneratedColumn<String>(
        'binding_external_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES canonical_media_records (id)',
    ),
  );
  static const VerificationMeta _installmentIdMeta = const VerificationMeta(
    'installmentId',
  );
  @override
  late final GeneratedColumn<String> installmentId = GeneratedColumn<String>(
    'installment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalNameMeta = const VerificationMeta(
    'originalName',
  );
  @override
  late final GeneratedColumn<String> originalName = GeneratedColumn<String>(
    'original_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _managedRelativePathMeta =
      const VerificationMeta('managedRelativePath');
  @override
  late final GeneratedColumn<String> managedRelativePath =
      GeneratedColumn<String>(
        'managed_relative_path',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
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
    id,
    kind,
    ownership,
    state,
    providerId,
    bindingExternalId,
    mediaId,
    installmentId,
    originalName,
    managedRelativePath,
    sizeBytes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_asset_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAssetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('ownership')) {
      context.handle(
        _ownershipMeta,
        ownership.isAcceptableOrUnknown(data['ownership']!, _ownershipMeta),
      );
    } else if (isInserting) {
      context.missing(_ownershipMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('binding_external_id')) {
      context.handle(
        _bindingExternalIdMeta,
        bindingExternalId.isAcceptableOrUnknown(
          data['binding_external_id']!,
          _bindingExternalIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bindingExternalIdMeta);
    }
    if (data.containsKey('media_id')) {
      context.handle(
        _mediaIdMeta,
        mediaId.isAcceptableOrUnknown(data['media_id']!, _mediaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mediaIdMeta);
    }
    if (data.containsKey('installment_id')) {
      context.handle(
        _installmentIdMeta,
        installmentId.isAcceptableOrUnknown(
          data['installment_id']!,
          _installmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_installmentIdMeta);
    }
    if (data.containsKey('original_name')) {
      context.handle(
        _originalNameMeta,
        originalName.isAcceptableOrUnknown(
          data['original_name']!,
          _originalNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalNameMeta);
    }
    if (data.containsKey('managed_relative_path')) {
      context.handle(
        _managedRelativePathMeta,
        managedRelativePath.isAcceptableOrUnknown(
          data['managed_relative_path']!,
          _managedRelativePathMeta,
        ),
      );
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {providerId, bindingExternalId},
  ];
  @override
  LocalAssetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAssetRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      ownership: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ownership'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      bindingExternalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}binding_external_id'],
      )!,
      mediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_id'],
      )!,
      installmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}installment_id'],
      )!,
      originalName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_name'],
      )!,
      managedRelativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}managed_relative_path'],
      ),
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalAssetRecordsTable createAlias(String alias) {
    return $LocalAssetRecordsTable(attachedDatabase, alias);
  }
}

class LocalAssetRow extends DataClass implements Insertable<LocalAssetRow> {
  final String id;
  final String kind;
  final String ownership;
  final String state;
  final String providerId;
  final String bindingExternalId;
  final String mediaId;
  final String installmentId;
  final String originalName;
  final String? managedRelativePath;
  final int? sizeBytes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocalAssetRow({
    required this.id,
    required this.kind,
    required this.ownership,
    required this.state,
    required this.providerId,
    required this.bindingExternalId,
    required this.mediaId,
    required this.installmentId,
    required this.originalName,
    this.managedRelativePath,
    this.sizeBytes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    map['ownership'] = Variable<String>(ownership);
    map['state'] = Variable<String>(state);
    map['provider_id'] = Variable<String>(providerId);
    map['binding_external_id'] = Variable<String>(bindingExternalId);
    map['media_id'] = Variable<String>(mediaId);
    map['installment_id'] = Variable<String>(installmentId);
    map['original_name'] = Variable<String>(originalName);
    if (!nullToAbsent || managedRelativePath != null) {
      map['managed_relative_path'] = Variable<String>(managedRelativePath);
    }
    if (!nullToAbsent || sizeBytes != null) {
      map['size_bytes'] = Variable<int>(sizeBytes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalAssetRecordsCompanion toCompanion(bool nullToAbsent) {
    return LocalAssetRecordsCompanion(
      id: Value(id),
      kind: Value(kind),
      ownership: Value(ownership),
      state: Value(state),
      providerId: Value(providerId),
      bindingExternalId: Value(bindingExternalId),
      mediaId: Value(mediaId),
      installmentId: Value(installmentId),
      originalName: Value(originalName),
      managedRelativePath: managedRelativePath == null && nullToAbsent
          ? const Value.absent()
          : Value(managedRelativePath),
      sizeBytes: sizeBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(sizeBytes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalAssetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAssetRow(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      ownership: serializer.fromJson<String>(json['ownership']),
      state: serializer.fromJson<String>(json['state']),
      providerId: serializer.fromJson<String>(json['providerId']),
      bindingExternalId: serializer.fromJson<String>(json['bindingExternalId']),
      mediaId: serializer.fromJson<String>(json['mediaId']),
      installmentId: serializer.fromJson<String>(json['installmentId']),
      originalName: serializer.fromJson<String>(json['originalName']),
      managedRelativePath: serializer.fromJson<String?>(
        json['managedRelativePath'],
      ),
      sizeBytes: serializer.fromJson<int?>(json['sizeBytes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'ownership': serializer.toJson<String>(ownership),
      'state': serializer.toJson<String>(state),
      'providerId': serializer.toJson<String>(providerId),
      'bindingExternalId': serializer.toJson<String>(bindingExternalId),
      'mediaId': serializer.toJson<String>(mediaId),
      'installmentId': serializer.toJson<String>(installmentId),
      'originalName': serializer.toJson<String>(originalName),
      'managedRelativePath': serializer.toJson<String?>(managedRelativePath),
      'sizeBytes': serializer.toJson<int?>(sizeBytes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalAssetRow copyWith({
    String? id,
    String? kind,
    String? ownership,
    String? state,
    String? providerId,
    String? bindingExternalId,
    String? mediaId,
    String? installmentId,
    String? originalName,
    Value<String?> managedRelativePath = const Value.absent(),
    Value<int?> sizeBytes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LocalAssetRow(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    ownership: ownership ?? this.ownership,
    state: state ?? this.state,
    providerId: providerId ?? this.providerId,
    bindingExternalId: bindingExternalId ?? this.bindingExternalId,
    mediaId: mediaId ?? this.mediaId,
    installmentId: installmentId ?? this.installmentId,
    originalName: originalName ?? this.originalName,
    managedRelativePath: managedRelativePath.present
        ? managedRelativePath.value
        : this.managedRelativePath,
    sizeBytes: sizeBytes.present ? sizeBytes.value : this.sizeBytes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalAssetRow copyWithCompanion(LocalAssetRecordsCompanion data) {
    return LocalAssetRow(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      ownership: data.ownership.present ? data.ownership.value : this.ownership,
      state: data.state.present ? data.state.value : this.state,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      bindingExternalId: data.bindingExternalId.present
          ? data.bindingExternalId.value
          : this.bindingExternalId,
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
      installmentId: data.installmentId.present
          ? data.installmentId.value
          : this.installmentId,
      originalName: data.originalName.present
          ? data.originalName.value
          : this.originalName,
      managedRelativePath: data.managedRelativePath.present
          ? data.managedRelativePath.value
          : this.managedRelativePath,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAssetRow(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('ownership: $ownership, ')
          ..write('state: $state, ')
          ..write('providerId: $providerId, ')
          ..write('bindingExternalId: $bindingExternalId, ')
          ..write('mediaId: $mediaId, ')
          ..write('installmentId: $installmentId, ')
          ..write('originalName: $originalName, ')
          ..write('managedRelativePath: $managedRelativePath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    ownership,
    state,
    providerId,
    bindingExternalId,
    mediaId,
    installmentId,
    originalName,
    managedRelativePath,
    sizeBytes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAssetRow &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.ownership == this.ownership &&
          other.state == this.state &&
          other.providerId == this.providerId &&
          other.bindingExternalId == this.bindingExternalId &&
          other.mediaId == this.mediaId &&
          other.installmentId == this.installmentId &&
          other.originalName == this.originalName &&
          other.managedRelativePath == this.managedRelativePath &&
          other.sizeBytes == this.sizeBytes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalAssetRecordsCompanion extends UpdateCompanion<LocalAssetRow> {
  final Value<String> id;
  final Value<String> kind;
  final Value<String> ownership;
  final Value<String> state;
  final Value<String> providerId;
  final Value<String> bindingExternalId;
  final Value<String> mediaId;
  final Value<String> installmentId;
  final Value<String> originalName;
  final Value<String?> managedRelativePath;
  final Value<int?> sizeBytes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalAssetRecordsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.ownership = const Value.absent(),
    this.state = const Value.absent(),
    this.providerId = const Value.absent(),
    this.bindingExternalId = const Value.absent(),
    this.mediaId = const Value.absent(),
    this.installmentId = const Value.absent(),
    this.originalName = const Value.absent(),
    this.managedRelativePath = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAssetRecordsCompanion.insert({
    required String id,
    required String kind,
    required String ownership,
    required String state,
    required String providerId,
    required String bindingExternalId,
    required String mediaId,
    required String installmentId,
    required String originalName,
    this.managedRelativePath = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       ownership = Value(ownership),
       state = Value(state),
       providerId = Value(providerId),
       bindingExternalId = Value(bindingExternalId),
       mediaId = Value(mediaId),
       installmentId = Value(installmentId),
       originalName = Value(originalName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalAssetRow> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? ownership,
    Expression<String>? state,
    Expression<String>? providerId,
    Expression<String>? bindingExternalId,
    Expression<String>? mediaId,
    Expression<String>? installmentId,
    Expression<String>? originalName,
    Expression<String>? managedRelativePath,
    Expression<int>? sizeBytes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (ownership != null) 'ownership': ownership,
      if (state != null) 'state': state,
      if (providerId != null) 'provider_id': providerId,
      if (bindingExternalId != null) 'binding_external_id': bindingExternalId,
      if (mediaId != null) 'media_id': mediaId,
      if (installmentId != null) 'installment_id': installmentId,
      if (originalName != null) 'original_name': originalName,
      if (managedRelativePath != null)
        'managed_relative_path': managedRelativePath,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAssetRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? kind,
    Value<String>? ownership,
    Value<String>? state,
    Value<String>? providerId,
    Value<String>? bindingExternalId,
    Value<String>? mediaId,
    Value<String>? installmentId,
    Value<String>? originalName,
    Value<String?>? managedRelativePath,
    Value<int?>? sizeBytes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalAssetRecordsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      ownership: ownership ?? this.ownership,
      state: state ?? this.state,
      providerId: providerId ?? this.providerId,
      bindingExternalId: bindingExternalId ?? this.bindingExternalId,
      mediaId: mediaId ?? this.mediaId,
      installmentId: installmentId ?? this.installmentId,
      originalName: originalName ?? this.originalName,
      managedRelativePath: managedRelativePath ?? this.managedRelativePath,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (ownership.present) {
      map['ownership'] = Variable<String>(ownership.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (bindingExternalId.present) {
      map['binding_external_id'] = Variable<String>(bindingExternalId.value);
    }
    if (mediaId.present) {
      map['media_id'] = Variable<String>(mediaId.value);
    }
    if (installmentId.present) {
      map['installment_id'] = Variable<String>(installmentId.value);
    }
    if (originalName.present) {
      map['original_name'] = Variable<String>(originalName.value);
    }
    if (managedRelativePath.present) {
      map['managed_relative_path'] = Variable<String>(
        managedRelativePath.value,
      );
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('LocalAssetRecordsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('ownership: $ownership, ')
          ..write('state: $state, ')
          ..write('providerId: $providerId, ')
          ..write('bindingExternalId: $bindingExternalId, ')
          ..write('mediaId: $mediaId, ')
          ..write('installmentId: $installmentId, ')
          ..write('originalName: $originalName, ')
          ..write('managedRelativePath: $managedRelativePath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AdapterConfigurationsTable extends AdapterConfigurations
    with TableInfo<$AdapterConfigurationsTable, AdapterConfigurationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AdapterConfigurationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _adapterIdMeta = const VerificationMeta(
    'adapterId',
  );
  @override
  late final GeneratedColumn<String> adapterId = GeneratedColumn<String>(
    'adapter_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
  );
  static const VerificationMeta _baseUrlMeta = const VerificationMeta(
    'baseUrl',
  );
  @override
  late final GeneratedColumn<String> baseUrl = GeneratedColumn<String>(
    'base_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
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
    adapterId,
    enabled,
    baseUrl,
    sortOrder,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'adapter_configurations';
  @override
  VerificationContext validateIntegrity(
    Insertable<AdapterConfigurationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('adapter_id')) {
      context.handle(
        _adapterIdMeta,
        adapterId.isAcceptableOrUnknown(data['adapter_id']!, _adapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_adapterIdMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    } else if (isInserting) {
      context.missing(_enabledMeta);
    }
    if (data.containsKey('base_url')) {
      context.handle(
        _baseUrlMeta,
        baseUrl.isAcceptableOrUnknown(data['base_url']!, _baseUrlMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
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
  Set<GeneratedColumn> get $primaryKey => {adapterId};
  @override
  AdapterConfigurationRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AdapterConfigurationRow(
      adapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}adapter_id'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      baseUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_url'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AdapterConfigurationsTable createAlias(String alias) {
    return $AdapterConfigurationsTable(attachedDatabase, alias);
  }
}

class AdapterConfigurationRow extends DataClass
    implements Insertable<AdapterConfigurationRow> {
  final String adapterId;
  final bool enabled;
  final String? baseUrl;
  final int sortOrder;
  final DateTime updatedAt;
  const AdapterConfigurationRow({
    required this.adapterId,
    required this.enabled,
    this.baseUrl,
    required this.sortOrder,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['adapter_id'] = Variable<String>(adapterId);
    map['enabled'] = Variable<bool>(enabled);
    if (!nullToAbsent || baseUrl != null) {
      map['base_url'] = Variable<String>(baseUrl);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AdapterConfigurationsCompanion toCompanion(bool nullToAbsent) {
    return AdapterConfigurationsCompanion(
      adapterId: Value(adapterId),
      enabled: Value(enabled),
      baseUrl: baseUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(baseUrl),
      sortOrder: Value(sortOrder),
      updatedAt: Value(updatedAt),
    );
  }

  factory AdapterConfigurationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AdapterConfigurationRow(
      adapterId: serializer.fromJson<String>(json['adapterId']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      baseUrl: serializer.fromJson<String?>(json['baseUrl']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'adapterId': serializer.toJson<String>(adapterId),
      'enabled': serializer.toJson<bool>(enabled),
      'baseUrl': serializer.toJson<String?>(baseUrl),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AdapterConfigurationRow copyWith({
    String? adapterId,
    bool? enabled,
    Value<String?> baseUrl = const Value.absent(),
    int? sortOrder,
    DateTime? updatedAt,
  }) => AdapterConfigurationRow(
    adapterId: adapterId ?? this.adapterId,
    enabled: enabled ?? this.enabled,
    baseUrl: baseUrl.present ? baseUrl.value : this.baseUrl,
    sortOrder: sortOrder ?? this.sortOrder,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AdapterConfigurationRow copyWithCompanion(
    AdapterConfigurationsCompanion data,
  ) {
    return AdapterConfigurationRow(
      adapterId: data.adapterId.present ? data.adapterId.value : this.adapterId,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      baseUrl: data.baseUrl.present ? data.baseUrl.value : this.baseUrl,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AdapterConfigurationRow(')
          ..write('adapterId: $adapterId, ')
          ..write('enabled: $enabled, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(adapterId, enabled, baseUrl, sortOrder, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdapterConfigurationRow &&
          other.adapterId == this.adapterId &&
          other.enabled == this.enabled &&
          other.baseUrl == this.baseUrl &&
          other.sortOrder == this.sortOrder &&
          other.updatedAt == this.updatedAt);
}

class AdapterConfigurationsCompanion
    extends UpdateCompanion<AdapterConfigurationRow> {
  final Value<String> adapterId;
  final Value<bool> enabled;
  final Value<String?> baseUrl;
  final Value<int> sortOrder;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AdapterConfigurationsCompanion({
    this.adapterId = const Value.absent(),
    this.enabled = const Value.absent(),
    this.baseUrl = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AdapterConfigurationsCompanion.insert({
    required String adapterId,
    required bool enabled,
    this.baseUrl = const Value.absent(),
    required int sortOrder,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : adapterId = Value(adapterId),
       enabled = Value(enabled),
       sortOrder = Value(sortOrder),
       updatedAt = Value(updatedAt);
  static Insertable<AdapterConfigurationRow> custom({
    Expression<String>? adapterId,
    Expression<bool>? enabled,
    Expression<String>? baseUrl,
    Expression<int>? sortOrder,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (adapterId != null) 'adapter_id': adapterId,
      if (enabled != null) 'enabled': enabled,
      if (baseUrl != null) 'base_url': baseUrl,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AdapterConfigurationsCompanion copyWith({
    Value<String>? adapterId,
    Value<bool>? enabled,
    Value<String?>? baseUrl,
    Value<int>? sortOrder,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AdapterConfigurationsCompanion(
      adapterId: adapterId ?? this.adapterId,
      enabled: enabled ?? this.enabled,
      baseUrl: baseUrl ?? this.baseUrl,
      sortOrder: sortOrder ?? this.sortOrder,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (adapterId.present) {
      map['adapter_id'] = Variable<String>(adapterId.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (baseUrl.present) {
      map['base_url'] = Variable<String>(baseUrl.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
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
    return (StringBuffer('AdapterConfigurationsCompanion(')
          ..write('adapterId: $adapterId, ')
          ..write('enabled: $enabled, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AdapterReliabilityRecordsTable extends AdapterReliabilityRecords
    with TableInfo<$AdapterReliabilityRecordsTable, AdapterReliabilityRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AdapterReliabilityRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _adapterIdMeta = const VerificationMeta(
    'adapterId',
  );
  @override
  late final GeneratedColumn<String> adapterId = GeneratedColumn<String>(
    'adapter_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastCheckedAtMeta = const VerificationMeta(
    'lastCheckedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastCheckedAt =
      GeneratedColumn<DateTime>(
        'last_checked_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastSuccessAtMeta = const VerificationMeta(
    'lastSuccessAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSuccessAt =
      GeneratedColumn<DateTime>(
        'last_success_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastFailureAtMeta = const VerificationMeta(
    'lastFailureAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastFailureAt =
      GeneratedColumn<DateTime>(
        'last_failure_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _consecutiveFailuresMeta =
      const VerificationMeta('consecutiveFailures');
  @override
  late final GeneratedColumn<int> consecutiveFailures = GeneratedColumn<int>(
    'consecutive_failures',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastParserMismatchAtMeta =
      const VerificationMeta('lastParserMismatchAt');
  @override
  late final GeneratedColumn<DateTime> lastParserMismatchAt =
      GeneratedColumn<DateTime>(
        'last_parser_mismatch_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    adapterId,
    lastCheckedAt,
    lastSuccessAt,
    lastFailureAt,
    consecutiveFailures,
    lastParserMismatchAt,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'adapter_reliability_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<AdapterReliabilityRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('adapter_id')) {
      context.handle(
        _adapterIdMeta,
        adapterId.isAcceptableOrUnknown(data['adapter_id']!, _adapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_adapterIdMeta);
    }
    if (data.containsKey('last_checked_at')) {
      context.handle(
        _lastCheckedAtMeta,
        lastCheckedAt.isAcceptableOrUnknown(
          data['last_checked_at']!,
          _lastCheckedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_success_at')) {
      context.handle(
        _lastSuccessAtMeta,
        lastSuccessAt.isAcceptableOrUnknown(
          data['last_success_at']!,
          _lastSuccessAtMeta,
        ),
      );
    }
    if (data.containsKey('last_failure_at')) {
      context.handle(
        _lastFailureAtMeta,
        lastFailureAt.isAcceptableOrUnknown(
          data['last_failure_at']!,
          _lastFailureAtMeta,
        ),
      );
    }
    if (data.containsKey('consecutive_failures')) {
      context.handle(
        _consecutiveFailuresMeta,
        consecutiveFailures.isAcceptableOrUnknown(
          data['consecutive_failures']!,
          _consecutiveFailuresMeta,
        ),
      );
    }
    if (data.containsKey('last_parser_mismatch_at')) {
      context.handle(
        _lastParserMismatchAtMeta,
        lastParserMismatchAt.isAcceptableOrUnknown(
          data['last_parser_mismatch_at']!,
          _lastParserMismatchAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {adapterId};
  @override
  AdapterReliabilityRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AdapterReliabilityRow(
      adapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}adapter_id'],
      )!,
      lastCheckedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_checked_at'],
      ),
      lastSuccessAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_success_at'],
      ),
      lastFailureAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_failure_at'],
      ),
      consecutiveFailures: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}consecutive_failures'],
      )!,
      lastParserMismatchAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_parser_mismatch_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $AdapterReliabilityRecordsTable createAlias(String alias) {
    return $AdapterReliabilityRecordsTable(attachedDatabase, alias);
  }
}

class AdapterReliabilityRow extends DataClass
    implements Insertable<AdapterReliabilityRow> {
  final String adapterId;
  final DateTime? lastCheckedAt;
  final DateTime? lastSuccessAt;
  final DateTime? lastFailureAt;
  final int consecutiveFailures;
  final DateTime? lastParserMismatchAt;
  final String? lastError;
  const AdapterReliabilityRow({
    required this.adapterId,
    this.lastCheckedAt,
    this.lastSuccessAt,
    this.lastFailureAt,
    required this.consecutiveFailures,
    this.lastParserMismatchAt,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['adapter_id'] = Variable<String>(adapterId);
    if (!nullToAbsent || lastCheckedAt != null) {
      map['last_checked_at'] = Variable<DateTime>(lastCheckedAt);
    }
    if (!nullToAbsent || lastSuccessAt != null) {
      map['last_success_at'] = Variable<DateTime>(lastSuccessAt);
    }
    if (!nullToAbsent || lastFailureAt != null) {
      map['last_failure_at'] = Variable<DateTime>(lastFailureAt);
    }
    map['consecutive_failures'] = Variable<int>(consecutiveFailures);
    if (!nullToAbsent || lastParserMismatchAt != null) {
      map['last_parser_mismatch_at'] = Variable<DateTime>(lastParserMismatchAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  AdapterReliabilityRecordsCompanion toCompanion(bool nullToAbsent) {
    return AdapterReliabilityRecordsCompanion(
      adapterId: Value(adapterId),
      lastCheckedAt: lastCheckedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCheckedAt),
      lastSuccessAt: lastSuccessAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSuccessAt),
      lastFailureAt: lastFailureAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastFailureAt),
      consecutiveFailures: Value(consecutiveFailures),
      lastParserMismatchAt: lastParserMismatchAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastParserMismatchAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory AdapterReliabilityRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AdapterReliabilityRow(
      adapterId: serializer.fromJson<String>(json['adapterId']),
      lastCheckedAt: serializer.fromJson<DateTime?>(json['lastCheckedAt']),
      lastSuccessAt: serializer.fromJson<DateTime?>(json['lastSuccessAt']),
      lastFailureAt: serializer.fromJson<DateTime?>(json['lastFailureAt']),
      consecutiveFailures: serializer.fromJson<int>(
        json['consecutiveFailures'],
      ),
      lastParserMismatchAt: serializer.fromJson<DateTime?>(
        json['lastParserMismatchAt'],
      ),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'adapterId': serializer.toJson<String>(adapterId),
      'lastCheckedAt': serializer.toJson<DateTime?>(lastCheckedAt),
      'lastSuccessAt': serializer.toJson<DateTime?>(lastSuccessAt),
      'lastFailureAt': serializer.toJson<DateTime?>(lastFailureAt),
      'consecutiveFailures': serializer.toJson<int>(consecutiveFailures),
      'lastParserMismatchAt': serializer.toJson<DateTime?>(
        lastParserMismatchAt,
      ),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  AdapterReliabilityRow copyWith({
    String? adapterId,
    Value<DateTime?> lastCheckedAt = const Value.absent(),
    Value<DateTime?> lastSuccessAt = const Value.absent(),
    Value<DateTime?> lastFailureAt = const Value.absent(),
    int? consecutiveFailures,
    Value<DateTime?> lastParserMismatchAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
  }) => AdapterReliabilityRow(
    adapterId: adapterId ?? this.adapterId,
    lastCheckedAt: lastCheckedAt.present
        ? lastCheckedAt.value
        : this.lastCheckedAt,
    lastSuccessAt: lastSuccessAt.present
        ? lastSuccessAt.value
        : this.lastSuccessAt,
    lastFailureAt: lastFailureAt.present
        ? lastFailureAt.value
        : this.lastFailureAt,
    consecutiveFailures: consecutiveFailures ?? this.consecutiveFailures,
    lastParserMismatchAt: lastParserMismatchAt.present
        ? lastParserMismatchAt.value
        : this.lastParserMismatchAt,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  AdapterReliabilityRow copyWithCompanion(
    AdapterReliabilityRecordsCompanion data,
  ) {
    return AdapterReliabilityRow(
      adapterId: data.adapterId.present ? data.adapterId.value : this.adapterId,
      lastCheckedAt: data.lastCheckedAt.present
          ? data.lastCheckedAt.value
          : this.lastCheckedAt,
      lastSuccessAt: data.lastSuccessAt.present
          ? data.lastSuccessAt.value
          : this.lastSuccessAt,
      lastFailureAt: data.lastFailureAt.present
          ? data.lastFailureAt.value
          : this.lastFailureAt,
      consecutiveFailures: data.consecutiveFailures.present
          ? data.consecutiveFailures.value
          : this.consecutiveFailures,
      lastParserMismatchAt: data.lastParserMismatchAt.present
          ? data.lastParserMismatchAt.value
          : this.lastParserMismatchAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AdapterReliabilityRow(')
          ..write('adapterId: $adapterId, ')
          ..write('lastCheckedAt: $lastCheckedAt, ')
          ..write('lastSuccessAt: $lastSuccessAt, ')
          ..write('lastFailureAt: $lastFailureAt, ')
          ..write('consecutiveFailures: $consecutiveFailures, ')
          ..write('lastParserMismatchAt: $lastParserMismatchAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    adapterId,
    lastCheckedAt,
    lastSuccessAt,
    lastFailureAt,
    consecutiveFailures,
    lastParserMismatchAt,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdapterReliabilityRow &&
          other.adapterId == this.adapterId &&
          other.lastCheckedAt == this.lastCheckedAt &&
          other.lastSuccessAt == this.lastSuccessAt &&
          other.lastFailureAt == this.lastFailureAt &&
          other.consecutiveFailures == this.consecutiveFailures &&
          other.lastParserMismatchAt == this.lastParserMismatchAt &&
          other.lastError == this.lastError);
}

class AdapterReliabilityRecordsCompanion
    extends UpdateCompanion<AdapterReliabilityRow> {
  final Value<String> adapterId;
  final Value<DateTime?> lastCheckedAt;
  final Value<DateTime?> lastSuccessAt;
  final Value<DateTime?> lastFailureAt;
  final Value<int> consecutiveFailures;
  final Value<DateTime?> lastParserMismatchAt;
  final Value<String?> lastError;
  final Value<int> rowid;
  const AdapterReliabilityRecordsCompanion({
    this.adapterId = const Value.absent(),
    this.lastCheckedAt = const Value.absent(),
    this.lastSuccessAt = const Value.absent(),
    this.lastFailureAt = const Value.absent(),
    this.consecutiveFailures = const Value.absent(),
    this.lastParserMismatchAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AdapterReliabilityRecordsCompanion.insert({
    required String adapterId,
    this.lastCheckedAt = const Value.absent(),
    this.lastSuccessAt = const Value.absent(),
    this.lastFailureAt = const Value.absent(),
    this.consecutiveFailures = const Value.absent(),
    this.lastParserMismatchAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : adapterId = Value(adapterId);
  static Insertable<AdapterReliabilityRow> custom({
    Expression<String>? adapterId,
    Expression<DateTime>? lastCheckedAt,
    Expression<DateTime>? lastSuccessAt,
    Expression<DateTime>? lastFailureAt,
    Expression<int>? consecutiveFailures,
    Expression<DateTime>? lastParserMismatchAt,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (adapterId != null) 'adapter_id': adapterId,
      if (lastCheckedAt != null) 'last_checked_at': lastCheckedAt,
      if (lastSuccessAt != null) 'last_success_at': lastSuccessAt,
      if (lastFailureAt != null) 'last_failure_at': lastFailureAt,
      if (consecutiveFailures != null)
        'consecutive_failures': consecutiveFailures,
      if (lastParserMismatchAt != null)
        'last_parser_mismatch_at': lastParserMismatchAt,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AdapterReliabilityRecordsCompanion copyWith({
    Value<String>? adapterId,
    Value<DateTime?>? lastCheckedAt,
    Value<DateTime?>? lastSuccessAt,
    Value<DateTime?>? lastFailureAt,
    Value<int>? consecutiveFailures,
    Value<DateTime?>? lastParserMismatchAt,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return AdapterReliabilityRecordsCompanion(
      adapterId: adapterId ?? this.adapterId,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      lastSuccessAt: lastSuccessAt ?? this.lastSuccessAt,
      lastFailureAt: lastFailureAt ?? this.lastFailureAt,
      consecutiveFailures: consecutiveFailures ?? this.consecutiveFailures,
      lastParserMismatchAt: lastParserMismatchAt ?? this.lastParserMismatchAt,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (adapterId.present) {
      map['adapter_id'] = Variable<String>(adapterId.value);
    }
    if (lastCheckedAt.present) {
      map['last_checked_at'] = Variable<DateTime>(lastCheckedAt.value);
    }
    if (lastSuccessAt.present) {
      map['last_success_at'] = Variable<DateTime>(lastSuccessAt.value);
    }
    if (lastFailureAt.present) {
      map['last_failure_at'] = Variable<DateTime>(lastFailureAt.value);
    }
    if (consecutiveFailures.present) {
      map['consecutive_failures'] = Variable<int>(consecutiveFailures.value);
    }
    if (lastParserMismatchAt.present) {
      map['last_parser_mismatch_at'] = Variable<DateTime>(
        lastParserMismatchAt.value,
      );
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AdapterReliabilityRecordsCompanion(')
          ..write('adapterId: $adapterId, ')
          ..write('lastCheckedAt: $lastCheckedAt, ')
          ..write('lastSuccessAt: $lastSuccessAt, ')
          ..write('lastFailureAt: $lastFailureAt, ')
          ..write('consecutiveFailures: $consecutiveFailures, ')
          ..write('lastParserMismatchAt: $lastParserMismatchAt, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MetadataEnrichmentRecordsTable extends MetadataEnrichmentRecords
    with TableInfo<$MetadataEnrichmentRecordsTable, MetadataEnrichmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetadataEnrichmentRecordsTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES canonical_media_records (id)',
    ),
  );
  static const VerificationMeta _adapterIdMeta = const VerificationMeta(
    'adapterId',
  );
  @override
  late final GeneratedColumn<String> adapterId = GeneratedColumn<String>(
    'adapter_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _observedAtMeta = const VerificationMeta(
    'observedAt',
  );
  @override
  late final GeneratedColumn<DateTime> observedAt = GeneratedColumn<DateTime>(
    'observed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    mediaId,
    adapterId,
    payloadJson,
    observedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'metadata_enrichment_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetadataEnrichmentRow> instance, {
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
    if (data.containsKey('adapter_id')) {
      context.handle(
        _adapterIdMeta,
        adapterId.isAcceptableOrUnknown(data['adapter_id']!, _adapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_adapterIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('observed_at')) {
      context.handle(
        _observedAtMeta,
        observedAt.isAcceptableOrUnknown(data['observed_at']!, _observedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_observedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {mediaId, adapterId};
  @override
  MetadataEnrichmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetadataEnrichmentRow(
      mediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_id'],
      )!,
      adapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}adapter_id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      observedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}observed_at'],
      )!,
    );
  }

  @override
  $MetadataEnrichmentRecordsTable createAlias(String alias) {
    return $MetadataEnrichmentRecordsTable(attachedDatabase, alias);
  }
}

class MetadataEnrichmentRow extends DataClass
    implements Insertable<MetadataEnrichmentRow> {
  final String mediaId;
  final String adapterId;
  final String payloadJson;
  final DateTime observedAt;
  const MetadataEnrichmentRow({
    required this.mediaId,
    required this.adapterId,
    required this.payloadJson,
    required this.observedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['media_id'] = Variable<String>(mediaId);
    map['adapter_id'] = Variable<String>(adapterId);
    map['payload_json'] = Variable<String>(payloadJson);
    map['observed_at'] = Variable<DateTime>(observedAt);
    return map;
  }

  MetadataEnrichmentRecordsCompanion toCompanion(bool nullToAbsent) {
    return MetadataEnrichmentRecordsCompanion(
      mediaId: Value(mediaId),
      adapterId: Value(adapterId),
      payloadJson: Value(payloadJson),
      observedAt: Value(observedAt),
    );
  }

  factory MetadataEnrichmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetadataEnrichmentRow(
      mediaId: serializer.fromJson<String>(json['mediaId']),
      adapterId: serializer.fromJson<String>(json['adapterId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      observedAt: serializer.fromJson<DateTime>(json['observedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mediaId': serializer.toJson<String>(mediaId),
      'adapterId': serializer.toJson<String>(adapterId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'observedAt': serializer.toJson<DateTime>(observedAt),
    };
  }

  MetadataEnrichmentRow copyWith({
    String? mediaId,
    String? adapterId,
    String? payloadJson,
    DateTime? observedAt,
  }) => MetadataEnrichmentRow(
    mediaId: mediaId ?? this.mediaId,
    adapterId: adapterId ?? this.adapterId,
    payloadJson: payloadJson ?? this.payloadJson,
    observedAt: observedAt ?? this.observedAt,
  );
  MetadataEnrichmentRow copyWithCompanion(
    MetadataEnrichmentRecordsCompanion data,
  ) {
    return MetadataEnrichmentRow(
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
      adapterId: data.adapterId.present ? data.adapterId.value : this.adapterId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      observedAt: data.observedAt.present
          ? data.observedAt.value
          : this.observedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetadataEnrichmentRow(')
          ..write('mediaId: $mediaId, ')
          ..write('adapterId: $adapterId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('observedAt: $observedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(mediaId, adapterId, payloadJson, observedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetadataEnrichmentRow &&
          other.mediaId == this.mediaId &&
          other.adapterId == this.adapterId &&
          other.payloadJson == this.payloadJson &&
          other.observedAt == this.observedAt);
}

class MetadataEnrichmentRecordsCompanion
    extends UpdateCompanion<MetadataEnrichmentRow> {
  final Value<String> mediaId;
  final Value<String> adapterId;
  final Value<String> payloadJson;
  final Value<DateTime> observedAt;
  final Value<int> rowid;
  const MetadataEnrichmentRecordsCompanion({
    this.mediaId = const Value.absent(),
    this.adapterId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.observedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetadataEnrichmentRecordsCompanion.insert({
    required String mediaId,
    required String adapterId,
    required String payloadJson,
    required DateTime observedAt,
    this.rowid = const Value.absent(),
  }) : mediaId = Value(mediaId),
       adapterId = Value(adapterId),
       payloadJson = Value(payloadJson),
       observedAt = Value(observedAt);
  static Insertable<MetadataEnrichmentRow> custom({
    Expression<String>? mediaId,
    Expression<String>? adapterId,
    Expression<String>? payloadJson,
    Expression<DateTime>? observedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (mediaId != null) 'media_id': mediaId,
      if (adapterId != null) 'adapter_id': adapterId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (observedAt != null) 'observed_at': observedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MetadataEnrichmentRecordsCompanion copyWith({
    Value<String>? mediaId,
    Value<String>? adapterId,
    Value<String>? payloadJson,
    Value<DateTime>? observedAt,
    Value<int>? rowid,
  }) {
    return MetadataEnrichmentRecordsCompanion(
      mediaId: mediaId ?? this.mediaId,
      adapterId: adapterId ?? this.adapterId,
      payloadJson: payloadJson ?? this.payloadJson,
      observedAt: observedAt ?? this.observedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (mediaId.present) {
      map['media_id'] = Variable<String>(mediaId.value);
    }
    if (adapterId.present) {
      map['adapter_id'] = Variable<String>(adapterId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (observedAt.present) {
      map['observed_at'] = Variable<DateTime>(observedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetadataEnrichmentRecordsCompanion(')
          ..write('mediaId: $mediaId, ')
          ..write('adapterId: $adapterId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('observedAt: $observedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MetadataOverrideRecordsTable extends MetadataOverrideRecords
    with TableInfo<$MetadataOverrideRecordsTable, MetadataOverrideRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetadataOverrideRecordsTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES canonical_media_records (id)',
    ),
  );
  static const VerificationMeta _displayTitleMeta = const VerificationMeta(
    'displayTitle',
  );
  @override
  late final GeneratedColumn<String> displayTitle = GeneratedColumn<String>(
    'display_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverLocatorMeta = const VerificationMeta(
    'coverLocator',
  );
  @override
  late final GeneratedColumn<String> coverLocator = GeneratedColumn<String>(
    'cover_locator',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _alternateTitlesJsonMeta =
      const VerificationMeta('alternateTitlesJson');
  @override
  late final GeneratedColumn<String> alternateTitlesJson =
      GeneratedColumn<String>(
        'alternate_titles_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _genresJsonMeta = const VerificationMeta(
    'genresJson',
  );
  @override
  late final GeneratedColumn<String> genresJson = GeneratedColumn<String>(
    'genres_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _animeFormatMeta = const VerificationMeta(
    'animeFormat',
  );
  @override
  late final GeneratedColumn<String> animeFormat = GeneratedColumn<String>(
    'anime_format',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creatorOrStudioMeta = const VerificationMeta(
    'creatorOrStudio',
  );
  @override
  late final GeneratedColumn<String> creatorOrStudio = GeneratedColumn<String>(
    'creator_or_studio',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    displayTitle,
    description,
    coverLocator,
    alternateTitlesJson,
    genresJson,
    status,
    animeFormat,
    creatorOrStudio,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'metadata_override_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetadataOverrideRow> instance, {
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
    if (data.containsKey('display_title')) {
      context.handle(
        _displayTitleMeta,
        displayTitle.isAcceptableOrUnknown(
          data['display_title']!,
          _displayTitleMeta,
        ),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('cover_locator')) {
      context.handle(
        _coverLocatorMeta,
        coverLocator.isAcceptableOrUnknown(
          data['cover_locator']!,
          _coverLocatorMeta,
        ),
      );
    }
    if (data.containsKey('alternate_titles_json')) {
      context.handle(
        _alternateTitlesJsonMeta,
        alternateTitlesJson.isAcceptableOrUnknown(
          data['alternate_titles_json']!,
          _alternateTitlesJsonMeta,
        ),
      );
    }
    if (data.containsKey('genres_json')) {
      context.handle(
        _genresJsonMeta,
        genresJson.isAcceptableOrUnknown(data['genres_json']!, _genresJsonMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('anime_format')) {
      context.handle(
        _animeFormatMeta,
        animeFormat.isAcceptableOrUnknown(
          data['anime_format']!,
          _animeFormatMeta,
        ),
      );
    }
    if (data.containsKey('creator_or_studio')) {
      context.handle(
        _creatorOrStudioMeta,
        creatorOrStudio.isAcceptableOrUnknown(
          data['creator_or_studio']!,
          _creatorOrStudioMeta,
        ),
      );
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
  MetadataOverrideRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetadataOverrideRow(
      mediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_id'],
      )!,
      displayTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_title'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      coverLocator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_locator'],
      ),
      alternateTitlesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alternate_titles_json'],
      )!,
      genresJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genres_json'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      ),
      animeFormat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}anime_format'],
      ),
      creatorOrStudio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}creator_or_studio'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MetadataOverrideRecordsTable createAlias(String alias) {
    return $MetadataOverrideRecordsTable(attachedDatabase, alias);
  }
}

class MetadataOverrideRow extends DataClass
    implements Insertable<MetadataOverrideRow> {
  final String mediaId;
  final String? displayTitle;
  final String? description;
  final String? coverLocator;
  final String alternateTitlesJson;
  final String genresJson;
  final String? status;
  final String? animeFormat;
  final String? creatorOrStudio;
  final DateTime updatedAt;
  const MetadataOverrideRow({
    required this.mediaId,
    this.displayTitle,
    this.description,
    this.coverLocator,
    required this.alternateTitlesJson,
    required this.genresJson,
    this.status,
    this.animeFormat,
    this.creatorOrStudio,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['media_id'] = Variable<String>(mediaId);
    if (!nullToAbsent || displayTitle != null) {
      map['display_title'] = Variable<String>(displayTitle);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || coverLocator != null) {
      map['cover_locator'] = Variable<String>(coverLocator);
    }
    map['alternate_titles_json'] = Variable<String>(alternateTitlesJson);
    map['genres_json'] = Variable<String>(genresJson);
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    if (!nullToAbsent || animeFormat != null) {
      map['anime_format'] = Variable<String>(animeFormat);
    }
    if (!nullToAbsent || creatorOrStudio != null) {
      map['creator_or_studio'] = Variable<String>(creatorOrStudio);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MetadataOverrideRecordsCompanion toCompanion(bool nullToAbsent) {
    return MetadataOverrideRecordsCompanion(
      mediaId: Value(mediaId),
      displayTitle: displayTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(displayTitle),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      coverLocator: coverLocator == null && nullToAbsent
          ? const Value.absent()
          : Value(coverLocator),
      alternateTitlesJson: Value(alternateTitlesJson),
      genresJson: Value(genresJson),
      status: status == null && nullToAbsent
          ? const Value.absent()
          : Value(status),
      animeFormat: animeFormat == null && nullToAbsent
          ? const Value.absent()
          : Value(animeFormat),
      creatorOrStudio: creatorOrStudio == null && nullToAbsent
          ? const Value.absent()
          : Value(creatorOrStudio),
      updatedAt: Value(updatedAt),
    );
  }

  factory MetadataOverrideRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetadataOverrideRow(
      mediaId: serializer.fromJson<String>(json['mediaId']),
      displayTitle: serializer.fromJson<String?>(json['displayTitle']),
      description: serializer.fromJson<String?>(json['description']),
      coverLocator: serializer.fromJson<String?>(json['coverLocator']),
      alternateTitlesJson: serializer.fromJson<String>(
        json['alternateTitlesJson'],
      ),
      genresJson: serializer.fromJson<String>(json['genresJson']),
      status: serializer.fromJson<String?>(json['status']),
      animeFormat: serializer.fromJson<String?>(json['animeFormat']),
      creatorOrStudio: serializer.fromJson<String?>(json['creatorOrStudio']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mediaId': serializer.toJson<String>(mediaId),
      'displayTitle': serializer.toJson<String?>(displayTitle),
      'description': serializer.toJson<String?>(description),
      'coverLocator': serializer.toJson<String?>(coverLocator),
      'alternateTitlesJson': serializer.toJson<String>(alternateTitlesJson),
      'genresJson': serializer.toJson<String>(genresJson),
      'status': serializer.toJson<String?>(status),
      'animeFormat': serializer.toJson<String?>(animeFormat),
      'creatorOrStudio': serializer.toJson<String?>(creatorOrStudio),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MetadataOverrideRow copyWith({
    String? mediaId,
    Value<String?> displayTitle = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> coverLocator = const Value.absent(),
    String? alternateTitlesJson,
    String? genresJson,
    Value<String?> status = const Value.absent(),
    Value<String?> animeFormat = const Value.absent(),
    Value<String?> creatorOrStudio = const Value.absent(),
    DateTime? updatedAt,
  }) => MetadataOverrideRow(
    mediaId: mediaId ?? this.mediaId,
    displayTitle: displayTitle.present ? displayTitle.value : this.displayTitle,
    description: description.present ? description.value : this.description,
    coverLocator: coverLocator.present ? coverLocator.value : this.coverLocator,
    alternateTitlesJson: alternateTitlesJson ?? this.alternateTitlesJson,
    genresJson: genresJson ?? this.genresJson,
    status: status.present ? status.value : this.status,
    animeFormat: animeFormat.present ? animeFormat.value : this.animeFormat,
    creatorOrStudio: creatorOrStudio.present
        ? creatorOrStudio.value
        : this.creatorOrStudio,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MetadataOverrideRow copyWithCompanion(MetadataOverrideRecordsCompanion data) {
    return MetadataOverrideRow(
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
      displayTitle: data.displayTitle.present
          ? data.displayTitle.value
          : this.displayTitle,
      description: data.description.present
          ? data.description.value
          : this.description,
      coverLocator: data.coverLocator.present
          ? data.coverLocator.value
          : this.coverLocator,
      alternateTitlesJson: data.alternateTitlesJson.present
          ? data.alternateTitlesJson.value
          : this.alternateTitlesJson,
      genresJson: data.genresJson.present
          ? data.genresJson.value
          : this.genresJson,
      status: data.status.present ? data.status.value : this.status,
      animeFormat: data.animeFormat.present
          ? data.animeFormat.value
          : this.animeFormat,
      creatorOrStudio: data.creatorOrStudio.present
          ? data.creatorOrStudio.value
          : this.creatorOrStudio,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetadataOverrideRow(')
          ..write('mediaId: $mediaId, ')
          ..write('displayTitle: $displayTitle, ')
          ..write('description: $description, ')
          ..write('coverLocator: $coverLocator, ')
          ..write('alternateTitlesJson: $alternateTitlesJson, ')
          ..write('genresJson: $genresJson, ')
          ..write('status: $status, ')
          ..write('animeFormat: $animeFormat, ')
          ..write('creatorOrStudio: $creatorOrStudio, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    mediaId,
    displayTitle,
    description,
    coverLocator,
    alternateTitlesJson,
    genresJson,
    status,
    animeFormat,
    creatorOrStudio,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetadataOverrideRow &&
          other.mediaId == this.mediaId &&
          other.displayTitle == this.displayTitle &&
          other.description == this.description &&
          other.coverLocator == this.coverLocator &&
          other.alternateTitlesJson == this.alternateTitlesJson &&
          other.genresJson == this.genresJson &&
          other.status == this.status &&
          other.animeFormat == this.animeFormat &&
          other.creatorOrStudio == this.creatorOrStudio &&
          other.updatedAt == this.updatedAt);
}

class MetadataOverrideRecordsCompanion
    extends UpdateCompanion<MetadataOverrideRow> {
  final Value<String> mediaId;
  final Value<String?> displayTitle;
  final Value<String?> description;
  final Value<String?> coverLocator;
  final Value<String> alternateTitlesJson;
  final Value<String> genresJson;
  final Value<String?> status;
  final Value<String?> animeFormat;
  final Value<String?> creatorOrStudio;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MetadataOverrideRecordsCompanion({
    this.mediaId = const Value.absent(),
    this.displayTitle = const Value.absent(),
    this.description = const Value.absent(),
    this.coverLocator = const Value.absent(),
    this.alternateTitlesJson = const Value.absent(),
    this.genresJson = const Value.absent(),
    this.status = const Value.absent(),
    this.animeFormat = const Value.absent(),
    this.creatorOrStudio = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetadataOverrideRecordsCompanion.insert({
    required String mediaId,
    this.displayTitle = const Value.absent(),
    this.description = const Value.absent(),
    this.coverLocator = const Value.absent(),
    this.alternateTitlesJson = const Value.absent(),
    this.genresJson = const Value.absent(),
    this.status = const Value.absent(),
    this.animeFormat = const Value.absent(),
    this.creatorOrStudio = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : mediaId = Value(mediaId),
       updatedAt = Value(updatedAt);
  static Insertable<MetadataOverrideRow> custom({
    Expression<String>? mediaId,
    Expression<String>? displayTitle,
    Expression<String>? description,
    Expression<String>? coverLocator,
    Expression<String>? alternateTitlesJson,
    Expression<String>? genresJson,
    Expression<String>? status,
    Expression<String>? animeFormat,
    Expression<String>? creatorOrStudio,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (mediaId != null) 'media_id': mediaId,
      if (displayTitle != null) 'display_title': displayTitle,
      if (description != null) 'description': description,
      if (coverLocator != null) 'cover_locator': coverLocator,
      if (alternateTitlesJson != null)
        'alternate_titles_json': alternateTitlesJson,
      if (genresJson != null) 'genres_json': genresJson,
      if (status != null) 'status': status,
      if (animeFormat != null) 'anime_format': animeFormat,
      if (creatorOrStudio != null) 'creator_or_studio': creatorOrStudio,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MetadataOverrideRecordsCompanion copyWith({
    Value<String>? mediaId,
    Value<String?>? displayTitle,
    Value<String?>? description,
    Value<String?>? coverLocator,
    Value<String>? alternateTitlesJson,
    Value<String>? genresJson,
    Value<String?>? status,
    Value<String?>? animeFormat,
    Value<String?>? creatorOrStudio,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MetadataOverrideRecordsCompanion(
      mediaId: mediaId ?? this.mediaId,
      displayTitle: displayTitle ?? this.displayTitle,
      description: description ?? this.description,
      coverLocator: coverLocator ?? this.coverLocator,
      alternateTitlesJson: alternateTitlesJson ?? this.alternateTitlesJson,
      genresJson: genresJson ?? this.genresJson,
      status: status ?? this.status,
      animeFormat: animeFormat ?? this.animeFormat,
      creatorOrStudio: creatorOrStudio ?? this.creatorOrStudio,
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
    if (displayTitle.present) {
      map['display_title'] = Variable<String>(displayTitle.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (coverLocator.present) {
      map['cover_locator'] = Variable<String>(coverLocator.value);
    }
    if (alternateTitlesJson.present) {
      map['alternate_titles_json'] = Variable<String>(
        alternateTitlesJson.value,
      );
    }
    if (genresJson.present) {
      map['genres_json'] = Variable<String>(genresJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (animeFormat.present) {
      map['anime_format'] = Variable<String>(animeFormat.value);
    }
    if (creatorOrStudio.present) {
      map['creator_or_studio'] = Variable<String>(creatorOrStudio.value);
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
    return (StringBuffer('MetadataOverrideRecordsCompanion(')
          ..write('mediaId: $mediaId, ')
          ..write('displayTitle: $displayTitle, ')
          ..write('description: $description, ')
          ..write('coverLocator: $coverLocator, ')
          ..write('alternateTitlesJson: $alternateTitlesJson, ')
          ..write('genresJson: $genresJson, ')
          ..write('status: $status, ')
          ..write('animeFormat: $animeFormat, ')
          ..write('creatorOrStudio: $creatorOrStudio, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChapterUserEditRecordsTable extends ChapterUserEditRecords
    with TableInfo<$ChapterUserEditRecordsTable, ChapterUserEditRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChapterUserEditRecordsTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES canonical_chapter_records (id)',
    ),
  );
  static const VerificationMeta _rawLabelMeta = const VerificationMeta(
    'rawLabel',
  );
  @override
  late final GeneratedColumn<String> rawLabel = GeneratedColumn<String>(
    'raw_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _volumeLabelMeta = const VerificationMeta(
    'volumeLabel',
  );
  @override
  late final GeneratedColumn<String> volumeLabel = GeneratedColumn<String>(
    'volume_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _explicitOrderMeta = const VerificationMeta(
    'explicitOrder',
  );
  @override
  late final GeneratedColumn<double> explicitOrder = GeneratedColumn<double>(
    'explicit_order',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceDisplayLabelMeta =
      const VerificationMeta('sourceDisplayLabel');
  @override
  late final GeneratedColumn<String> sourceDisplayLabel =
      GeneratedColumn<String>(
        'source_display_label',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
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
    chapterId,
    rawLabel,
    kind,
    volumeLabel,
    explicitOrder,
    sourceDisplayLabel,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chapter_user_edit_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChapterUserEditRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('raw_label')) {
      context.handle(
        _rawLabelMeta,
        rawLabel.isAcceptableOrUnknown(data['raw_label']!, _rawLabelMeta),
      );
    } else if (isInserting) {
      context.missing(_rawLabelMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('volume_label')) {
      context.handle(
        _volumeLabelMeta,
        volumeLabel.isAcceptableOrUnknown(
          data['volume_label']!,
          _volumeLabelMeta,
        ),
      );
    }
    if (data.containsKey('explicit_order')) {
      context.handle(
        _explicitOrderMeta,
        explicitOrder.isAcceptableOrUnknown(
          data['explicit_order']!,
          _explicitOrderMeta,
        ),
      );
    }
    if (data.containsKey('source_display_label')) {
      context.handle(
        _sourceDisplayLabelMeta,
        sourceDisplayLabel.isAcceptableOrUnknown(
          data['source_display_label']!,
          _sourceDisplayLabelMeta,
        ),
      );
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
  Set<GeneratedColumn> get $primaryKey => {chapterId};
  @override
  ChapterUserEditRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChapterUserEditRow(
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_id'],
      )!,
      rawLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_label'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      volumeLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}volume_label'],
      ),
      explicitOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}explicit_order'],
      ),
      sourceDisplayLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_display_label'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ChapterUserEditRecordsTable createAlias(String alias) {
    return $ChapterUserEditRecordsTable(attachedDatabase, alias);
  }
}

class ChapterUserEditRow extends DataClass
    implements Insertable<ChapterUserEditRow> {
  final String chapterId;
  final String rawLabel;
  final String kind;
  final String? volumeLabel;
  final double? explicitOrder;
  final String? sourceDisplayLabel;
  final DateTime updatedAt;
  const ChapterUserEditRow({
    required this.chapterId,
    required this.rawLabel,
    required this.kind,
    this.volumeLabel,
    this.explicitOrder,
    this.sourceDisplayLabel,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chapter_id'] = Variable<String>(chapterId);
    map['raw_label'] = Variable<String>(rawLabel);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || volumeLabel != null) {
      map['volume_label'] = Variable<String>(volumeLabel);
    }
    if (!nullToAbsent || explicitOrder != null) {
      map['explicit_order'] = Variable<double>(explicitOrder);
    }
    if (!nullToAbsent || sourceDisplayLabel != null) {
      map['source_display_label'] = Variable<String>(sourceDisplayLabel);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ChapterUserEditRecordsCompanion toCompanion(bool nullToAbsent) {
    return ChapterUserEditRecordsCompanion(
      chapterId: Value(chapterId),
      rawLabel: Value(rawLabel),
      kind: Value(kind),
      volumeLabel: volumeLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(volumeLabel),
      explicitOrder: explicitOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(explicitOrder),
      sourceDisplayLabel: sourceDisplayLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceDisplayLabel),
      updatedAt: Value(updatedAt),
    );
  }

  factory ChapterUserEditRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChapterUserEditRow(
      chapterId: serializer.fromJson<String>(json['chapterId']),
      rawLabel: serializer.fromJson<String>(json['rawLabel']),
      kind: serializer.fromJson<String>(json['kind']),
      volumeLabel: serializer.fromJson<String?>(json['volumeLabel']),
      explicitOrder: serializer.fromJson<double?>(json['explicitOrder']),
      sourceDisplayLabel: serializer.fromJson<String?>(
        json['sourceDisplayLabel'],
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chapterId': serializer.toJson<String>(chapterId),
      'rawLabel': serializer.toJson<String>(rawLabel),
      'kind': serializer.toJson<String>(kind),
      'volumeLabel': serializer.toJson<String?>(volumeLabel),
      'explicitOrder': serializer.toJson<double?>(explicitOrder),
      'sourceDisplayLabel': serializer.toJson<String?>(sourceDisplayLabel),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ChapterUserEditRow copyWith({
    String? chapterId,
    String? rawLabel,
    String? kind,
    Value<String?> volumeLabel = const Value.absent(),
    Value<double?> explicitOrder = const Value.absent(),
    Value<String?> sourceDisplayLabel = const Value.absent(),
    DateTime? updatedAt,
  }) => ChapterUserEditRow(
    chapterId: chapterId ?? this.chapterId,
    rawLabel: rawLabel ?? this.rawLabel,
    kind: kind ?? this.kind,
    volumeLabel: volumeLabel.present ? volumeLabel.value : this.volumeLabel,
    explicitOrder: explicitOrder.present
        ? explicitOrder.value
        : this.explicitOrder,
    sourceDisplayLabel: sourceDisplayLabel.present
        ? sourceDisplayLabel.value
        : this.sourceDisplayLabel,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ChapterUserEditRow copyWithCompanion(ChapterUserEditRecordsCompanion data) {
    return ChapterUserEditRow(
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      rawLabel: data.rawLabel.present ? data.rawLabel.value : this.rawLabel,
      kind: data.kind.present ? data.kind.value : this.kind,
      volumeLabel: data.volumeLabel.present
          ? data.volumeLabel.value
          : this.volumeLabel,
      explicitOrder: data.explicitOrder.present
          ? data.explicitOrder.value
          : this.explicitOrder,
      sourceDisplayLabel: data.sourceDisplayLabel.present
          ? data.sourceDisplayLabel.value
          : this.sourceDisplayLabel,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChapterUserEditRow(')
          ..write('chapterId: $chapterId, ')
          ..write('rawLabel: $rawLabel, ')
          ..write('kind: $kind, ')
          ..write('volumeLabel: $volumeLabel, ')
          ..write('explicitOrder: $explicitOrder, ')
          ..write('sourceDisplayLabel: $sourceDisplayLabel, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    chapterId,
    rawLabel,
    kind,
    volumeLabel,
    explicitOrder,
    sourceDisplayLabel,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChapterUserEditRow &&
          other.chapterId == this.chapterId &&
          other.rawLabel == this.rawLabel &&
          other.kind == this.kind &&
          other.volumeLabel == this.volumeLabel &&
          other.explicitOrder == this.explicitOrder &&
          other.sourceDisplayLabel == this.sourceDisplayLabel &&
          other.updatedAt == this.updatedAt);
}

class ChapterUserEditRecordsCompanion
    extends UpdateCompanion<ChapterUserEditRow> {
  final Value<String> chapterId;
  final Value<String> rawLabel;
  final Value<String> kind;
  final Value<String?> volumeLabel;
  final Value<double?> explicitOrder;
  final Value<String?> sourceDisplayLabel;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ChapterUserEditRecordsCompanion({
    this.chapterId = const Value.absent(),
    this.rawLabel = const Value.absent(),
    this.kind = const Value.absent(),
    this.volumeLabel = const Value.absent(),
    this.explicitOrder = const Value.absent(),
    this.sourceDisplayLabel = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChapterUserEditRecordsCompanion.insert({
    required String chapterId,
    required String rawLabel,
    required String kind,
    this.volumeLabel = const Value.absent(),
    this.explicitOrder = const Value.absent(),
    this.sourceDisplayLabel = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : chapterId = Value(chapterId),
       rawLabel = Value(rawLabel),
       kind = Value(kind),
       updatedAt = Value(updatedAt);
  static Insertable<ChapterUserEditRow> custom({
    Expression<String>? chapterId,
    Expression<String>? rawLabel,
    Expression<String>? kind,
    Expression<String>? volumeLabel,
    Expression<double>? explicitOrder,
    Expression<String>? sourceDisplayLabel,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chapterId != null) 'chapter_id': chapterId,
      if (rawLabel != null) 'raw_label': rawLabel,
      if (kind != null) 'kind': kind,
      if (volumeLabel != null) 'volume_label': volumeLabel,
      if (explicitOrder != null) 'explicit_order': explicitOrder,
      if (sourceDisplayLabel != null)
        'source_display_label': sourceDisplayLabel,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChapterUserEditRecordsCompanion copyWith({
    Value<String>? chapterId,
    Value<String>? rawLabel,
    Value<String>? kind,
    Value<String?>? volumeLabel,
    Value<double?>? explicitOrder,
    Value<String?>? sourceDisplayLabel,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ChapterUserEditRecordsCompanion(
      chapterId: chapterId ?? this.chapterId,
      rawLabel: rawLabel ?? this.rawLabel,
      kind: kind ?? this.kind,
      volumeLabel: volumeLabel ?? this.volumeLabel,
      explicitOrder: explicitOrder ?? this.explicitOrder,
      sourceDisplayLabel: sourceDisplayLabel ?? this.sourceDisplayLabel,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (rawLabel.present) {
      map['raw_label'] = Variable<String>(rawLabel.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (volumeLabel.present) {
      map['volume_label'] = Variable<String>(volumeLabel.value);
    }
    if (explicitOrder.present) {
      map['explicit_order'] = Variable<double>(explicitOrder.value);
    }
    if (sourceDisplayLabel.present) {
      map['source_display_label'] = Variable<String>(sourceDisplayLabel.value);
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
    return (StringBuffer('ChapterUserEditRecordsCompanion(')
          ..write('chapterId: $chapterId, ')
          ..write('rawLabel: $rawLabel, ')
          ..write('kind: $kind, ')
          ..write('volumeLabel: $volumeLabel, ')
          ..write('explicitOrder: $explicitOrder, ')
          ..write('sourceDisplayLabel: $sourceDisplayLabel, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EpisodeUserEditRecordsTable extends EpisodeUserEditRecords
    with TableInfo<$EpisodeUserEditRecordsTable, EpisodeUserEditRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EpisodeUserEditRecordsTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES canonical_episode_records (id)',
    ),
  );
  static const VerificationMeta _rawLabelMeta = const VerificationMeta(
    'rawLabel',
  );
  @override
  late final GeneratedColumn<String> rawLabel = GeneratedColumn<String>(
    'raw_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<double> number = GeneratedColumn<double>(
    'number',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _narrativeSeasonMeta = const VerificationMeta(
    'narrativeSeason',
  );
  @override
  late final GeneratedColumn<int> narrativeSeason = GeneratedColumn<int>(
    'narrative_season',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _explicitOrderMeta = const VerificationMeta(
    'explicitOrder',
  );
  @override
  late final GeneratedColumn<double> explicitOrder = GeneratedColumn<double>(
    'explicit_order',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceDisplayLabelMeta =
      const VerificationMeta('sourceDisplayLabel');
  @override
  late final GeneratedColumn<String> sourceDisplayLabel =
      GeneratedColumn<String>(
        'source_display_label',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
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
    episodeId,
    rawLabel,
    number,
    kind,
    narrativeSeason,
    explicitOrder,
    sourceDisplayLabel,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'episode_user_edit_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<EpisodeUserEditRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('episode_id')) {
      context.handle(
        _episodeIdMeta,
        episodeId.isAcceptableOrUnknown(data['episode_id']!, _episodeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_episodeIdMeta);
    }
    if (data.containsKey('raw_label')) {
      context.handle(
        _rawLabelMeta,
        rawLabel.isAcceptableOrUnknown(data['raw_label']!, _rawLabelMeta),
      );
    } else if (isInserting) {
      context.missing(_rawLabelMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('narrative_season')) {
      context.handle(
        _narrativeSeasonMeta,
        narrativeSeason.isAcceptableOrUnknown(
          data['narrative_season']!,
          _narrativeSeasonMeta,
        ),
      );
    }
    if (data.containsKey('explicit_order')) {
      context.handle(
        _explicitOrderMeta,
        explicitOrder.isAcceptableOrUnknown(
          data['explicit_order']!,
          _explicitOrderMeta,
        ),
      );
    }
    if (data.containsKey('source_display_label')) {
      context.handle(
        _sourceDisplayLabelMeta,
        sourceDisplayLabel.isAcceptableOrUnknown(
          data['source_display_label']!,
          _sourceDisplayLabelMeta,
        ),
      );
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
  Set<GeneratedColumn> get $primaryKey => {episodeId};
  @override
  EpisodeUserEditRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EpisodeUserEditRow(
      episodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}episode_id'],
      )!,
      rawLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_label'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}number'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      narrativeSeason: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}narrative_season'],
      ),
      explicitOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}explicit_order'],
      ),
      sourceDisplayLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_display_label'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $EpisodeUserEditRecordsTable createAlias(String alias) {
    return $EpisodeUserEditRecordsTable(attachedDatabase, alias);
  }
}

class EpisodeUserEditRow extends DataClass
    implements Insertable<EpisodeUserEditRow> {
  final String episodeId;
  final String rawLabel;
  final double? number;
  final String kind;
  final int? narrativeSeason;
  final double? explicitOrder;
  final String? sourceDisplayLabel;
  final DateTime updatedAt;
  const EpisodeUserEditRow({
    required this.episodeId,
    required this.rawLabel,
    this.number,
    required this.kind,
    this.narrativeSeason,
    this.explicitOrder,
    this.sourceDisplayLabel,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['episode_id'] = Variable<String>(episodeId);
    map['raw_label'] = Variable<String>(rawLabel);
    if (!nullToAbsent || number != null) {
      map['number'] = Variable<double>(number);
    }
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || narrativeSeason != null) {
      map['narrative_season'] = Variable<int>(narrativeSeason);
    }
    if (!nullToAbsent || explicitOrder != null) {
      map['explicit_order'] = Variable<double>(explicitOrder);
    }
    if (!nullToAbsent || sourceDisplayLabel != null) {
      map['source_display_label'] = Variable<String>(sourceDisplayLabel);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  EpisodeUserEditRecordsCompanion toCompanion(bool nullToAbsent) {
    return EpisodeUserEditRecordsCompanion(
      episodeId: Value(episodeId),
      rawLabel: Value(rawLabel),
      number: number == null && nullToAbsent
          ? const Value.absent()
          : Value(number),
      kind: Value(kind),
      narrativeSeason: narrativeSeason == null && nullToAbsent
          ? const Value.absent()
          : Value(narrativeSeason),
      explicitOrder: explicitOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(explicitOrder),
      sourceDisplayLabel: sourceDisplayLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceDisplayLabel),
      updatedAt: Value(updatedAt),
    );
  }

  factory EpisodeUserEditRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EpisodeUserEditRow(
      episodeId: serializer.fromJson<String>(json['episodeId']),
      rawLabel: serializer.fromJson<String>(json['rawLabel']),
      number: serializer.fromJson<double?>(json['number']),
      kind: serializer.fromJson<String>(json['kind']),
      narrativeSeason: serializer.fromJson<int?>(json['narrativeSeason']),
      explicitOrder: serializer.fromJson<double?>(json['explicitOrder']),
      sourceDisplayLabel: serializer.fromJson<String?>(
        json['sourceDisplayLabel'],
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'episodeId': serializer.toJson<String>(episodeId),
      'rawLabel': serializer.toJson<String>(rawLabel),
      'number': serializer.toJson<double?>(number),
      'kind': serializer.toJson<String>(kind),
      'narrativeSeason': serializer.toJson<int?>(narrativeSeason),
      'explicitOrder': serializer.toJson<double?>(explicitOrder),
      'sourceDisplayLabel': serializer.toJson<String?>(sourceDisplayLabel),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  EpisodeUserEditRow copyWith({
    String? episodeId,
    String? rawLabel,
    Value<double?> number = const Value.absent(),
    String? kind,
    Value<int?> narrativeSeason = const Value.absent(),
    Value<double?> explicitOrder = const Value.absent(),
    Value<String?> sourceDisplayLabel = const Value.absent(),
    DateTime? updatedAt,
  }) => EpisodeUserEditRow(
    episodeId: episodeId ?? this.episodeId,
    rawLabel: rawLabel ?? this.rawLabel,
    number: number.present ? number.value : this.number,
    kind: kind ?? this.kind,
    narrativeSeason: narrativeSeason.present
        ? narrativeSeason.value
        : this.narrativeSeason,
    explicitOrder: explicitOrder.present
        ? explicitOrder.value
        : this.explicitOrder,
    sourceDisplayLabel: sourceDisplayLabel.present
        ? sourceDisplayLabel.value
        : this.sourceDisplayLabel,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  EpisodeUserEditRow copyWithCompanion(EpisodeUserEditRecordsCompanion data) {
    return EpisodeUserEditRow(
      episodeId: data.episodeId.present ? data.episodeId.value : this.episodeId,
      rawLabel: data.rawLabel.present ? data.rawLabel.value : this.rawLabel,
      number: data.number.present ? data.number.value : this.number,
      kind: data.kind.present ? data.kind.value : this.kind,
      narrativeSeason: data.narrativeSeason.present
          ? data.narrativeSeason.value
          : this.narrativeSeason,
      explicitOrder: data.explicitOrder.present
          ? data.explicitOrder.value
          : this.explicitOrder,
      sourceDisplayLabel: data.sourceDisplayLabel.present
          ? data.sourceDisplayLabel.value
          : this.sourceDisplayLabel,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EpisodeUserEditRow(')
          ..write('episodeId: $episodeId, ')
          ..write('rawLabel: $rawLabel, ')
          ..write('number: $number, ')
          ..write('kind: $kind, ')
          ..write('narrativeSeason: $narrativeSeason, ')
          ..write('explicitOrder: $explicitOrder, ')
          ..write('sourceDisplayLabel: $sourceDisplayLabel, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    episodeId,
    rawLabel,
    number,
    kind,
    narrativeSeason,
    explicitOrder,
    sourceDisplayLabel,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EpisodeUserEditRow &&
          other.episodeId == this.episodeId &&
          other.rawLabel == this.rawLabel &&
          other.number == this.number &&
          other.kind == this.kind &&
          other.narrativeSeason == this.narrativeSeason &&
          other.explicitOrder == this.explicitOrder &&
          other.sourceDisplayLabel == this.sourceDisplayLabel &&
          other.updatedAt == this.updatedAt);
}

class EpisodeUserEditRecordsCompanion
    extends UpdateCompanion<EpisodeUserEditRow> {
  final Value<String> episodeId;
  final Value<String> rawLabel;
  final Value<double?> number;
  final Value<String> kind;
  final Value<int?> narrativeSeason;
  final Value<double?> explicitOrder;
  final Value<String?> sourceDisplayLabel;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const EpisodeUserEditRecordsCompanion({
    this.episodeId = const Value.absent(),
    this.rawLabel = const Value.absent(),
    this.number = const Value.absent(),
    this.kind = const Value.absent(),
    this.narrativeSeason = const Value.absent(),
    this.explicitOrder = const Value.absent(),
    this.sourceDisplayLabel = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EpisodeUserEditRecordsCompanion.insert({
    required String episodeId,
    required String rawLabel,
    this.number = const Value.absent(),
    required String kind,
    this.narrativeSeason = const Value.absent(),
    this.explicitOrder = const Value.absent(),
    this.sourceDisplayLabel = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : episodeId = Value(episodeId),
       rawLabel = Value(rawLabel),
       kind = Value(kind),
       updatedAt = Value(updatedAt);
  static Insertable<EpisodeUserEditRow> custom({
    Expression<String>? episodeId,
    Expression<String>? rawLabel,
    Expression<double>? number,
    Expression<String>? kind,
    Expression<int>? narrativeSeason,
    Expression<double>? explicitOrder,
    Expression<String>? sourceDisplayLabel,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (episodeId != null) 'episode_id': episodeId,
      if (rawLabel != null) 'raw_label': rawLabel,
      if (number != null) 'number': number,
      if (kind != null) 'kind': kind,
      if (narrativeSeason != null) 'narrative_season': narrativeSeason,
      if (explicitOrder != null) 'explicit_order': explicitOrder,
      if (sourceDisplayLabel != null)
        'source_display_label': sourceDisplayLabel,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EpisodeUserEditRecordsCompanion copyWith({
    Value<String>? episodeId,
    Value<String>? rawLabel,
    Value<double?>? number,
    Value<String>? kind,
    Value<int?>? narrativeSeason,
    Value<double?>? explicitOrder,
    Value<String?>? sourceDisplayLabel,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return EpisodeUserEditRecordsCompanion(
      episodeId: episodeId ?? this.episodeId,
      rawLabel: rawLabel ?? this.rawLabel,
      number: number ?? this.number,
      kind: kind ?? this.kind,
      narrativeSeason: narrativeSeason ?? this.narrativeSeason,
      explicitOrder: explicitOrder ?? this.explicitOrder,
      sourceDisplayLabel: sourceDisplayLabel ?? this.sourceDisplayLabel,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (episodeId.present) {
      map['episode_id'] = Variable<String>(episodeId.value);
    }
    if (rawLabel.present) {
      map['raw_label'] = Variable<String>(rawLabel.value);
    }
    if (number.present) {
      map['number'] = Variable<double>(number.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (narrativeSeason.present) {
      map['narrative_season'] = Variable<int>(narrativeSeason.value);
    }
    if (explicitOrder.present) {
      map['explicit_order'] = Variable<double>(explicitOrder.value);
    }
    if (sourceDisplayLabel.present) {
      map['source_display_label'] = Variable<String>(sourceDisplayLabel.value);
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
    return (StringBuffer('EpisodeUserEditRecordsCompanion(')
          ..write('episodeId: $episodeId, ')
          ..write('rawLabel: $rawLabel, ')
          ..write('number: $number, ')
          ..write('kind: $kind, ')
          ..write('narrativeSeason: $narrativeSeason, ')
          ..write('explicitOrder: $explicitOrder, ')
          ..write('sourceDisplayLabel: $sourceDisplayLabel, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChapterCompletionRecordsTable extends ChapterCompletionRecords
    with TableInfo<$ChapterCompletionRecordsTable, ChapterCompletionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChapterCompletionRecordsTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES canonical_chapter_records (id)',
    ),
  );
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES canonical_media_records (id)',
    ),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    chapterId,
    mediaId,
    completedAt,
    origin,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chapter_completion_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChapterCompletionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('media_id')) {
      context.handle(
        _mediaIdMeta,
        mediaId.isAcceptableOrUnknown(data['media_id']!, _mediaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mediaIdMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    } else if (isInserting) {
      context.missing(_originMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chapterId};
  @override
  ChapterCompletionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChapterCompletionRow(
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_id'],
      )!,
      mediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_id'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
    );
  }

  @override
  $ChapterCompletionRecordsTable createAlias(String alias) {
    return $ChapterCompletionRecordsTable(attachedDatabase, alias);
  }
}

class ChapterCompletionRow extends DataClass
    implements Insertable<ChapterCompletionRow> {
  final String chapterId;
  final String mediaId;
  final DateTime completedAt;
  final String origin;
  const ChapterCompletionRow({
    required this.chapterId,
    required this.mediaId,
    required this.completedAt,
    required this.origin,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chapter_id'] = Variable<String>(chapterId);
    map['media_id'] = Variable<String>(mediaId);
    map['completed_at'] = Variable<DateTime>(completedAt);
    map['origin'] = Variable<String>(origin);
    return map;
  }

  ChapterCompletionRecordsCompanion toCompanion(bool nullToAbsent) {
    return ChapterCompletionRecordsCompanion(
      chapterId: Value(chapterId),
      mediaId: Value(mediaId),
      completedAt: Value(completedAt),
      origin: Value(origin),
    );
  }

  factory ChapterCompletionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChapterCompletionRow(
      chapterId: serializer.fromJson<String>(json['chapterId']),
      mediaId: serializer.fromJson<String>(json['mediaId']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      origin: serializer.fromJson<String>(json['origin']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chapterId': serializer.toJson<String>(chapterId),
      'mediaId': serializer.toJson<String>(mediaId),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'origin': serializer.toJson<String>(origin),
    };
  }

  ChapterCompletionRow copyWith({
    String? chapterId,
    String? mediaId,
    DateTime? completedAt,
    String? origin,
  }) => ChapterCompletionRow(
    chapterId: chapterId ?? this.chapterId,
    mediaId: mediaId ?? this.mediaId,
    completedAt: completedAt ?? this.completedAt,
    origin: origin ?? this.origin,
  );
  ChapterCompletionRow copyWithCompanion(
    ChapterCompletionRecordsCompanion data,
  ) {
    return ChapterCompletionRow(
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      origin: data.origin.present ? data.origin.value : this.origin,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChapterCompletionRow(')
          ..write('chapterId: $chapterId, ')
          ..write('mediaId: $mediaId, ')
          ..write('completedAt: $completedAt, ')
          ..write('origin: $origin')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(chapterId, mediaId, completedAt, origin);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChapterCompletionRow &&
          other.chapterId == this.chapterId &&
          other.mediaId == this.mediaId &&
          other.completedAt == this.completedAt &&
          other.origin == this.origin);
}

class ChapterCompletionRecordsCompanion
    extends UpdateCompanion<ChapterCompletionRow> {
  final Value<String> chapterId;
  final Value<String> mediaId;
  final Value<DateTime> completedAt;
  final Value<String> origin;
  final Value<int> rowid;
  const ChapterCompletionRecordsCompanion({
    this.chapterId = const Value.absent(),
    this.mediaId = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.origin = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChapterCompletionRecordsCompanion.insert({
    required String chapterId,
    required String mediaId,
    required DateTime completedAt,
    required String origin,
    this.rowid = const Value.absent(),
  }) : chapterId = Value(chapterId),
       mediaId = Value(mediaId),
       completedAt = Value(completedAt),
       origin = Value(origin);
  static Insertable<ChapterCompletionRow> custom({
    Expression<String>? chapterId,
    Expression<String>? mediaId,
    Expression<DateTime>? completedAt,
    Expression<String>? origin,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chapterId != null) 'chapter_id': chapterId,
      if (mediaId != null) 'media_id': mediaId,
      if (completedAt != null) 'completed_at': completedAt,
      if (origin != null) 'origin': origin,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChapterCompletionRecordsCompanion copyWith({
    Value<String>? chapterId,
    Value<String>? mediaId,
    Value<DateTime>? completedAt,
    Value<String>? origin,
    Value<int>? rowid,
  }) {
    return ChapterCompletionRecordsCompanion(
      chapterId: chapterId ?? this.chapterId,
      mediaId: mediaId ?? this.mediaId,
      completedAt: completedAt ?? this.completedAt,
      origin: origin ?? this.origin,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (mediaId.present) {
      map['media_id'] = Variable<String>(mediaId.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChapterCompletionRecordsCompanion(')
          ..write('chapterId: $chapterId, ')
          ..write('mediaId: $mediaId, ')
          ..write('completedAt: $completedAt, ')
          ..write('origin: $origin, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EpisodeCompletionRecordsTable extends EpisodeCompletionRecords
    with TableInfo<$EpisodeCompletionRecordsTable, EpisodeCompletionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EpisodeCompletionRecordsTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES canonical_episode_records (id)',
    ),
  );
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES canonical_media_records (id)',
    ),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    episodeId,
    mediaId,
    completedAt,
    origin,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'episode_completion_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<EpisodeCompletionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('episode_id')) {
      context.handle(
        _episodeIdMeta,
        episodeId.isAcceptableOrUnknown(data['episode_id']!, _episodeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_episodeIdMeta);
    }
    if (data.containsKey('media_id')) {
      context.handle(
        _mediaIdMeta,
        mediaId.isAcceptableOrUnknown(data['media_id']!, _mediaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mediaIdMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    } else if (isInserting) {
      context.missing(_originMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {episodeId};
  @override
  EpisodeCompletionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EpisodeCompletionRow(
      episodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}episode_id'],
      )!,
      mediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_id'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
    );
  }

  @override
  $EpisodeCompletionRecordsTable createAlias(String alias) {
    return $EpisodeCompletionRecordsTable(attachedDatabase, alias);
  }
}

class EpisodeCompletionRow extends DataClass
    implements Insertable<EpisodeCompletionRow> {
  final String episodeId;
  final String mediaId;
  final DateTime completedAt;
  final String origin;
  const EpisodeCompletionRow({
    required this.episodeId,
    required this.mediaId,
    required this.completedAt,
    required this.origin,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['episode_id'] = Variable<String>(episodeId);
    map['media_id'] = Variable<String>(mediaId);
    map['completed_at'] = Variable<DateTime>(completedAt);
    map['origin'] = Variable<String>(origin);
    return map;
  }

  EpisodeCompletionRecordsCompanion toCompanion(bool nullToAbsent) {
    return EpisodeCompletionRecordsCompanion(
      episodeId: Value(episodeId),
      mediaId: Value(mediaId),
      completedAt: Value(completedAt),
      origin: Value(origin),
    );
  }

  factory EpisodeCompletionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EpisodeCompletionRow(
      episodeId: serializer.fromJson<String>(json['episodeId']),
      mediaId: serializer.fromJson<String>(json['mediaId']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      origin: serializer.fromJson<String>(json['origin']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'episodeId': serializer.toJson<String>(episodeId),
      'mediaId': serializer.toJson<String>(mediaId),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'origin': serializer.toJson<String>(origin),
    };
  }

  EpisodeCompletionRow copyWith({
    String? episodeId,
    String? mediaId,
    DateTime? completedAt,
    String? origin,
  }) => EpisodeCompletionRow(
    episodeId: episodeId ?? this.episodeId,
    mediaId: mediaId ?? this.mediaId,
    completedAt: completedAt ?? this.completedAt,
    origin: origin ?? this.origin,
  );
  EpisodeCompletionRow copyWithCompanion(
    EpisodeCompletionRecordsCompanion data,
  ) {
    return EpisodeCompletionRow(
      episodeId: data.episodeId.present ? data.episodeId.value : this.episodeId,
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      origin: data.origin.present ? data.origin.value : this.origin,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EpisodeCompletionRow(')
          ..write('episodeId: $episodeId, ')
          ..write('mediaId: $mediaId, ')
          ..write('completedAt: $completedAt, ')
          ..write('origin: $origin')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(episodeId, mediaId, completedAt, origin);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EpisodeCompletionRow &&
          other.episodeId == this.episodeId &&
          other.mediaId == this.mediaId &&
          other.completedAt == this.completedAt &&
          other.origin == this.origin);
}

class EpisodeCompletionRecordsCompanion
    extends UpdateCompanion<EpisodeCompletionRow> {
  final Value<String> episodeId;
  final Value<String> mediaId;
  final Value<DateTime> completedAt;
  final Value<String> origin;
  final Value<int> rowid;
  const EpisodeCompletionRecordsCompanion({
    this.episodeId = const Value.absent(),
    this.mediaId = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.origin = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EpisodeCompletionRecordsCompanion.insert({
    required String episodeId,
    required String mediaId,
    required DateTime completedAt,
    required String origin,
    this.rowid = const Value.absent(),
  }) : episodeId = Value(episodeId),
       mediaId = Value(mediaId),
       completedAt = Value(completedAt),
       origin = Value(origin);
  static Insertable<EpisodeCompletionRow> custom({
    Expression<String>? episodeId,
    Expression<String>? mediaId,
    Expression<DateTime>? completedAt,
    Expression<String>? origin,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (episodeId != null) 'episode_id': episodeId,
      if (mediaId != null) 'media_id': mediaId,
      if (completedAt != null) 'completed_at': completedAt,
      if (origin != null) 'origin': origin,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EpisodeCompletionRecordsCompanion copyWith({
    Value<String>? episodeId,
    Value<String>? mediaId,
    Value<DateTime>? completedAt,
    Value<String>? origin,
    Value<int>? rowid,
  }) {
    return EpisodeCompletionRecordsCompanion(
      episodeId: episodeId ?? this.episodeId,
      mediaId: mediaId ?? this.mediaId,
      completedAt: completedAt ?? this.completedAt,
      origin: origin ?? this.origin,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (episodeId.present) {
      map['episode_id'] = Variable<String>(episodeId.value);
    }
    if (mediaId.present) {
      map['media_id'] = Variable<String>(mediaId.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EpisodeCompletionRecordsCompanion(')
          ..write('episodeId: $episodeId, ')
          ..write('mediaId: $mediaId, ')
          ..write('completedAt: $completedAt, ')
          ..write('origin: $origin, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$CanonicalDatabase extends GeneratedDatabase {
  _$CanonicalDatabase(QueryExecutor e) : super(e);
  $CanonicalDatabaseManager get managers => $CanonicalDatabaseManager(this);
  late final $CanonicalMediaRecordsTable canonicalMediaRecords =
      $CanonicalMediaRecordsTable(this);
  late final $CanonicalChapterRecordsTable canonicalChapterRecords =
      $CanonicalChapterRecordsTable(this);
  late final $CanonicalEpisodeRecordsTable canonicalEpisodeRecords =
      $CanonicalEpisodeRecordsTable(this);
  late final $CanonicalMediaBindingsTable canonicalMediaBindings =
      $CanonicalMediaBindingsTable(this);
  late final $CanonicalChapterBindingsTable canonicalChapterBindings =
      $CanonicalChapterBindingsTable(this);
  late final $CanonicalEpisodeBindingsTable canonicalEpisodeBindings =
      $CanonicalEpisodeBindingsTable(this);
  late final $CanonicalLibraryRecordsTable canonicalLibraryRecords =
      $CanonicalLibraryRecordsTable(this);
  late final $CanonicalMangaProgressRecordsTable canonicalMangaProgressRecords =
      $CanonicalMangaProgressRecordsTable(this);
  late final $CanonicalAnimeProgressRecordsTable canonicalAnimeProgressRecords =
      $CanonicalAnimeProgressRecordsTable(this);
  late final $CanonicalMediaAliasesTable canonicalMediaAliases =
      $CanonicalMediaAliasesTable(this);
  late final $CanonicalMergeAuditsTable canonicalMergeAudits =
      $CanonicalMergeAuditsTable(this);
  late final $MangaSourcePageResumesTable mangaSourcePageResumes =
      $MangaSourcePageResumesTable(this);
  late final $AnimeSourcePlaybackResumesTable animeSourcePlaybackResumes =
      $AnimeSourcePlaybackResumesTable(this);
  late final $PreferredMediaSourcesTable preferredMediaSources =
      $PreferredMediaSourcesTable(this);
  late final $LocalAssetRecordsTable localAssetRecords =
      $LocalAssetRecordsTable(this);
  late final $AdapterConfigurationsTable adapterConfigurations =
      $AdapterConfigurationsTable(this);
  late final $AdapterReliabilityRecordsTable adapterReliabilityRecords =
      $AdapterReliabilityRecordsTable(this);
  late final $MetadataEnrichmentRecordsTable metadataEnrichmentRecords =
      $MetadataEnrichmentRecordsTable(this);
  late final $MetadataOverrideRecordsTable metadataOverrideRecords =
      $MetadataOverrideRecordsTable(this);
  late final $ChapterUserEditRecordsTable chapterUserEditRecords =
      $ChapterUserEditRecordsTable(this);
  late final $EpisodeUserEditRecordsTable episodeUserEditRecords =
      $EpisodeUserEditRecordsTable(this);
  late final $ChapterCompletionRecordsTable chapterCompletionRecords =
      $ChapterCompletionRecordsTable(this);
  late final $EpisodeCompletionRecordsTable episodeCompletionRecords =
      $EpisodeCompletionRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    canonicalMediaRecords,
    canonicalChapterRecords,
    canonicalEpisodeRecords,
    canonicalMediaBindings,
    canonicalChapterBindings,
    canonicalEpisodeBindings,
    canonicalLibraryRecords,
    canonicalMangaProgressRecords,
    canonicalAnimeProgressRecords,
    canonicalMediaAliases,
    canonicalMergeAudits,
    mangaSourcePageResumes,
    animeSourcePlaybackResumes,
    preferredMediaSources,
    localAssetRecords,
    adapterConfigurations,
    adapterReliabilityRecords,
    metadataEnrichmentRecords,
    metadataOverrideRecords,
    chapterUserEditRecords,
    episodeUserEditRecords,
    chapterCompletionRecords,
    episodeCompletionRecords,
  ];
}

typedef $$CanonicalMediaRecordsTableCreateCompanionBuilder =
    CanonicalMediaRecordsCompanion Function({
      required String id,
      required String kind,
      required String title,
      required String titleProviderId,
      Value<String?> titleRawValue,
      Value<String> alternateTitlesJson,
      Value<String?> description,
      Value<String?> descriptionProviderId,
      Value<String?> descriptionRawValue,
      required String status,
      Value<String> genresJson,
      Value<String?> coverLocator,
      Value<String?> animeFormat,
      Value<String?> airingSeason,
      Value<int?> airingYear,
      Value<String?> airingRawLabel,
      Value<int?> narrativeSeason,
      Value<int?> knownEpisodeTotal,
      Value<String?> rawEpisodeTotal,
      Value<int> rowid,
    });
typedef $$CanonicalMediaRecordsTableUpdateCompanionBuilder =
    CanonicalMediaRecordsCompanion Function({
      Value<String> id,
      Value<String> kind,
      Value<String> title,
      Value<String> titleProviderId,
      Value<String?> titleRawValue,
      Value<String> alternateTitlesJson,
      Value<String?> description,
      Value<String?> descriptionProviderId,
      Value<String?> descriptionRawValue,
      Value<String> status,
      Value<String> genresJson,
      Value<String?> coverLocator,
      Value<String?> animeFormat,
      Value<String?> airingSeason,
      Value<int?> airingYear,
      Value<String?> airingRawLabel,
      Value<int?> narrativeSeason,
      Value<int?> knownEpisodeTotal,
      Value<String?> rawEpisodeTotal,
      Value<int> rowid,
    });

final class $$CanonicalMediaRecordsTableReferences
    extends
        BaseReferences<
          _$CanonicalDatabase,
          $CanonicalMediaRecordsTable,
          CanonicalMediaRow
        > {
  $$CanonicalMediaRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $CanonicalChapterRecordsTable,
    List<CanonicalChapterRow>
  >
  _canonicalChapterRecordsRefsTable(_$CanonicalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.canonicalChapterRecords,
        aliasName: $_aliasNameGenerator(
          db.canonicalMediaRecords.id,
          db.canonicalChapterRecords.mediaId,
        ),
      );

  $$CanonicalChapterRecordsTableProcessedTableManager
  get canonicalChapterRecordsRefs {
    final manager = $$CanonicalChapterRecordsTableTableManager(
      $_db,
      $_db.canonicalChapterRecords,
    ).filter((f) => f.mediaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _canonicalChapterRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CanonicalEpisodeRecordsTable,
    List<CanonicalEpisodeRow>
  >
  _canonicalEpisodeRecordsRefsTable(_$CanonicalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.canonicalEpisodeRecords,
        aliasName: $_aliasNameGenerator(
          db.canonicalMediaRecords.id,
          db.canonicalEpisodeRecords.mediaId,
        ),
      );

  $$CanonicalEpisodeRecordsTableProcessedTableManager
  get canonicalEpisodeRecordsRefs {
    final manager = $$CanonicalEpisodeRecordsTableTableManager(
      $_db,
      $_db.canonicalEpisodeRecords,
    ).filter((f) => f.mediaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _canonicalEpisodeRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CanonicalMediaBindingsTable,
    List<MediaBindingRow>
  >
  _canonicalMediaBindingsRefsTable(_$CanonicalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.canonicalMediaBindings,
        aliasName: $_aliasNameGenerator(
          db.canonicalMediaRecords.id,
          db.canonicalMediaBindings.canonicalId,
        ),
      );

  $$CanonicalMediaBindingsTableProcessedTableManager
  get canonicalMediaBindingsRefs {
    final manager = $$CanonicalMediaBindingsTableTableManager(
      $_db,
      $_db.canonicalMediaBindings,
    ).filter((f) => f.canonicalId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _canonicalMediaBindingsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CanonicalLibraryRecordsTable,
    List<CanonicalLibraryRow>
  >
  _canonicalLibraryRecordsRefsTable(_$CanonicalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.canonicalLibraryRecords,
        aliasName: $_aliasNameGenerator(
          db.canonicalMediaRecords.id,
          db.canonicalLibraryRecords.mediaId,
        ),
      );

  $$CanonicalLibraryRecordsTableProcessedTableManager
  get canonicalLibraryRecordsRefs {
    final manager = $$CanonicalLibraryRecordsTableTableManager(
      $_db,
      $_db.canonicalLibraryRecords,
    ).filter((f) => f.mediaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _canonicalLibraryRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CanonicalMangaProgressRecordsTable,
    List<CanonicalMangaProgressRow>
  >
  _canonicalMangaProgressRecordsRefsTable(_$CanonicalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.canonicalMangaProgressRecords,
        aliasName: $_aliasNameGenerator(
          db.canonicalMediaRecords.id,
          db.canonicalMangaProgressRecords.mediaId,
        ),
      );

  $$CanonicalMangaProgressRecordsTableProcessedTableManager
  get canonicalMangaProgressRecordsRefs {
    final manager = $$CanonicalMangaProgressRecordsTableTableManager(
      $_db,
      $_db.canonicalMangaProgressRecords,
    ).filter((f) => f.mediaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _canonicalMangaProgressRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CanonicalAnimeProgressRecordsTable,
    List<CanonicalAnimeProgressRow>
  >
  _canonicalAnimeProgressRecordsRefsTable(_$CanonicalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.canonicalAnimeProgressRecords,
        aliasName: $_aliasNameGenerator(
          db.canonicalMediaRecords.id,
          db.canonicalAnimeProgressRecords.mediaId,
        ),
      );

  $$CanonicalAnimeProgressRecordsTableProcessedTableManager
  get canonicalAnimeProgressRecordsRefs {
    final manager = $$CanonicalAnimeProgressRecordsTableTableManager(
      $_db,
      $_db.canonicalAnimeProgressRecords,
    ).filter((f) => f.mediaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _canonicalAnimeProgressRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $MangaSourcePageResumesTable,
    List<MangaSourcePageResumeRow>
  >
  _mangaSourcePageResumesRefsTable(_$CanonicalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.mangaSourcePageResumes,
        aliasName: $_aliasNameGenerator(
          db.canonicalMediaRecords.id,
          db.mangaSourcePageResumes.mediaId,
        ),
      );

  $$MangaSourcePageResumesTableProcessedTableManager
  get mangaSourcePageResumesRefs {
    final manager = $$MangaSourcePageResumesTableTableManager(
      $_db,
      $_db.mangaSourcePageResumes,
    ).filter((f) => f.mediaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _mangaSourcePageResumesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $AnimeSourcePlaybackResumesTable,
    List<AnimeSourcePlaybackResumeRow>
  >
  _animeSourcePlaybackResumesRefsTable(_$CanonicalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.animeSourcePlaybackResumes,
        aliasName: $_aliasNameGenerator(
          db.canonicalMediaRecords.id,
          db.animeSourcePlaybackResumes.mediaId,
        ),
      );

  $$AnimeSourcePlaybackResumesTableProcessedTableManager
  get animeSourcePlaybackResumesRefs {
    final manager = $$AnimeSourcePlaybackResumesTableTableManager(
      $_db,
      $_db.animeSourcePlaybackResumes,
    ).filter((f) => f.mediaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _animeSourcePlaybackResumesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $PreferredMediaSourcesTable,
    List<PreferredMediaSourceRow>
  >
  _preferredMediaSourcesRefsTable(_$CanonicalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.preferredMediaSources,
        aliasName: $_aliasNameGenerator(
          db.canonicalMediaRecords.id,
          db.preferredMediaSources.mediaId,
        ),
      );

  $$PreferredMediaSourcesTableProcessedTableManager
  get preferredMediaSourcesRefs {
    final manager = $$PreferredMediaSourcesTableTableManager(
      $_db,
      $_db.preferredMediaSources,
    ).filter((f) => f.mediaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _preferredMediaSourcesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LocalAssetRecordsTable, List<LocalAssetRow>>
  _localAssetRecordsRefsTable(_$CanonicalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.localAssetRecords,
        aliasName: $_aliasNameGenerator(
          db.canonicalMediaRecords.id,
          db.localAssetRecords.mediaId,
        ),
      );

  $$LocalAssetRecordsTableProcessedTableManager get localAssetRecordsRefs {
    final manager = $$LocalAssetRecordsTableTableManager(
      $_db,
      $_db.localAssetRecords,
    ).filter((f) => f.mediaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _localAssetRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $MetadataEnrichmentRecordsTable,
    List<MetadataEnrichmentRow>
  >
  _metadataEnrichmentRecordsRefsTable(_$CanonicalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.metadataEnrichmentRecords,
        aliasName: $_aliasNameGenerator(
          db.canonicalMediaRecords.id,
          db.metadataEnrichmentRecords.mediaId,
        ),
      );

  $$MetadataEnrichmentRecordsTableProcessedTableManager
  get metadataEnrichmentRecordsRefs {
    final manager = $$MetadataEnrichmentRecordsTableTableManager(
      $_db,
      $_db.metadataEnrichmentRecords,
    ).filter((f) => f.mediaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _metadataEnrichmentRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $MetadataOverrideRecordsTable,
    List<MetadataOverrideRow>
  >
  _metadataOverrideRecordsRefsTable(_$CanonicalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.metadataOverrideRecords,
        aliasName: $_aliasNameGenerator(
          db.canonicalMediaRecords.id,
          db.metadataOverrideRecords.mediaId,
        ),
      );

  $$MetadataOverrideRecordsTableProcessedTableManager
  get metadataOverrideRecordsRefs {
    final manager = $$MetadataOverrideRecordsTableTableManager(
      $_db,
      $_db.metadataOverrideRecords,
    ).filter((f) => f.mediaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _metadataOverrideRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ChapterCompletionRecordsTable,
    List<ChapterCompletionRow>
  >
  _chapterCompletionRecordsRefsTable(_$CanonicalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.chapterCompletionRecords,
        aliasName: $_aliasNameGenerator(
          db.canonicalMediaRecords.id,
          db.chapterCompletionRecords.mediaId,
        ),
      );

  $$ChapterCompletionRecordsTableProcessedTableManager
  get chapterCompletionRecordsRefs {
    final manager = $$ChapterCompletionRecordsTableTableManager(
      $_db,
      $_db.chapterCompletionRecords,
    ).filter((f) => f.mediaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _chapterCompletionRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $EpisodeCompletionRecordsTable,
    List<EpisodeCompletionRow>
  >
  _episodeCompletionRecordsRefsTable(_$CanonicalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.episodeCompletionRecords,
        aliasName: $_aliasNameGenerator(
          db.canonicalMediaRecords.id,
          db.episodeCompletionRecords.mediaId,
        ),
      );

  $$EpisodeCompletionRecordsTableProcessedTableManager
  get episodeCompletionRecordsRefs {
    final manager = $$EpisodeCompletionRecordsTableTableManager(
      $_db,
      $_db.episodeCompletionRecords,
    ).filter((f) => f.mediaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _episodeCompletionRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CanonicalMediaRecordsTableFilterComposer
    extends Composer<_$CanonicalDatabase, $CanonicalMediaRecordsTable> {
  $$CanonicalMediaRecordsTableFilterComposer({
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

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titleProviderId => $composableBuilder(
    column: $table.titleProviderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titleRawValue => $composableBuilder(
    column: $table.titleRawValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alternateTitlesJson => $composableBuilder(
    column: $table.alternateTitlesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descriptionProviderId => $composableBuilder(
    column: $table.descriptionProviderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descriptionRawValue => $composableBuilder(
    column: $table.descriptionRawValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genresJson => $composableBuilder(
    column: $table.genresJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverLocator => $composableBuilder(
    column: $table.coverLocator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get animeFormat => $composableBuilder(
    column: $table.animeFormat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get airingSeason => $composableBuilder(
    column: $table.airingSeason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get airingYear => $composableBuilder(
    column: $table.airingYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get airingRawLabel => $composableBuilder(
    column: $table.airingRawLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get narrativeSeason => $composableBuilder(
    column: $table.narrativeSeason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get knownEpisodeTotal => $composableBuilder(
    column: $table.knownEpisodeTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawEpisodeTotal => $composableBuilder(
    column: $table.rawEpisodeTotal,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> canonicalChapterRecordsRefs(
    Expression<bool> Function($$CanonicalChapterRecordsTableFilterComposer f) f,
  ) {
    final $$CanonicalChapterRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.canonicalChapterRecords,
          getReferencedColumn: (t) => t.mediaId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalChapterRecordsTableFilterComposer(
                $db: $db,
                $table: $db.canonicalChapterRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> canonicalEpisodeRecordsRefs(
    Expression<bool> Function($$CanonicalEpisodeRecordsTableFilterComposer f) f,
  ) {
    final $$CanonicalEpisodeRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.canonicalEpisodeRecords,
          getReferencedColumn: (t) => t.mediaId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalEpisodeRecordsTableFilterComposer(
                $db: $db,
                $table: $db.canonicalEpisodeRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> canonicalMediaBindingsRefs(
    Expression<bool> Function($$CanonicalMediaBindingsTableFilterComposer f) f,
  ) {
    final $$CanonicalMediaBindingsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.canonicalMediaBindings,
          getReferencedColumn: (t) => t.canonicalId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaBindingsTableFilterComposer(
                $db: $db,
                $table: $db.canonicalMediaBindings,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> canonicalLibraryRecordsRefs(
    Expression<bool> Function($$CanonicalLibraryRecordsTableFilterComposer f) f,
  ) {
    final $$CanonicalLibraryRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.canonicalLibraryRecords,
          getReferencedColumn: (t) => t.mediaId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalLibraryRecordsTableFilterComposer(
                $db: $db,
                $table: $db.canonicalLibraryRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> canonicalMangaProgressRecordsRefs(
    Expression<bool> Function(
      $$CanonicalMangaProgressRecordsTableFilterComposer f,
    )
    f,
  ) {
    final $$CanonicalMangaProgressRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.canonicalMangaProgressRecords,
          getReferencedColumn: (t) => t.mediaId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMangaProgressRecordsTableFilterComposer(
                $db: $db,
                $table: $db.canonicalMangaProgressRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> canonicalAnimeProgressRecordsRefs(
    Expression<bool> Function(
      $$CanonicalAnimeProgressRecordsTableFilterComposer f,
    )
    f,
  ) {
    final $$CanonicalAnimeProgressRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.canonicalAnimeProgressRecords,
          getReferencedColumn: (t) => t.mediaId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalAnimeProgressRecordsTableFilterComposer(
                $db: $db,
                $table: $db.canonicalAnimeProgressRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> mangaSourcePageResumesRefs(
    Expression<bool> Function($$MangaSourcePageResumesTableFilterComposer f) f,
  ) {
    final $$MangaSourcePageResumesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.mangaSourcePageResumes,
          getReferencedColumn: (t) => t.mediaId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MangaSourcePageResumesTableFilterComposer(
                $db: $db,
                $table: $db.mangaSourcePageResumes,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> animeSourcePlaybackResumesRefs(
    Expression<bool> Function($$AnimeSourcePlaybackResumesTableFilterComposer f)
    f,
  ) {
    final $$AnimeSourcePlaybackResumesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.animeSourcePlaybackResumes,
          getReferencedColumn: (t) => t.mediaId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AnimeSourcePlaybackResumesTableFilterComposer(
                $db: $db,
                $table: $db.animeSourcePlaybackResumes,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> preferredMediaSourcesRefs(
    Expression<bool> Function($$PreferredMediaSourcesTableFilterComposer f) f,
  ) {
    final $$PreferredMediaSourcesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.preferredMediaSources,
          getReferencedColumn: (t) => t.mediaId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PreferredMediaSourcesTableFilterComposer(
                $db: $db,
                $table: $db.preferredMediaSources,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> localAssetRecordsRefs(
    Expression<bool> Function($$LocalAssetRecordsTableFilterComposer f) f,
  ) {
    final $$LocalAssetRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localAssetRecords,
      getReferencedColumn: (t) => t.mediaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalAssetRecordsTableFilterComposer(
            $db: $db,
            $table: $db.localAssetRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> metadataEnrichmentRecordsRefs(
    Expression<bool> Function($$MetadataEnrichmentRecordsTableFilterComposer f)
    f,
  ) {
    final $$MetadataEnrichmentRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.metadataEnrichmentRecords,
          getReferencedColumn: (t) => t.mediaId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MetadataEnrichmentRecordsTableFilterComposer(
                $db: $db,
                $table: $db.metadataEnrichmentRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> metadataOverrideRecordsRefs(
    Expression<bool> Function($$MetadataOverrideRecordsTableFilterComposer f) f,
  ) {
    final $$MetadataOverrideRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.metadataOverrideRecords,
          getReferencedColumn: (t) => t.mediaId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MetadataOverrideRecordsTableFilterComposer(
                $db: $db,
                $table: $db.metadataOverrideRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> chapterCompletionRecordsRefs(
    Expression<bool> Function($$ChapterCompletionRecordsTableFilterComposer f)
    f,
  ) {
    final $$ChapterCompletionRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.chapterCompletionRecords,
          getReferencedColumn: (t) => t.mediaId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ChapterCompletionRecordsTableFilterComposer(
                $db: $db,
                $table: $db.chapterCompletionRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> episodeCompletionRecordsRefs(
    Expression<bool> Function($$EpisodeCompletionRecordsTableFilterComposer f)
    f,
  ) {
    final $$EpisodeCompletionRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.episodeCompletionRecords,
          getReferencedColumn: (t) => t.mediaId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EpisodeCompletionRecordsTableFilterComposer(
                $db: $db,
                $table: $db.episodeCompletionRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CanonicalMediaRecordsTableOrderingComposer
    extends Composer<_$CanonicalDatabase, $CanonicalMediaRecordsTable> {
  $$CanonicalMediaRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titleProviderId => $composableBuilder(
    column: $table.titleProviderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titleRawValue => $composableBuilder(
    column: $table.titleRawValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alternateTitlesJson => $composableBuilder(
    column: $table.alternateTitlesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descriptionProviderId => $composableBuilder(
    column: $table.descriptionProviderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descriptionRawValue => $composableBuilder(
    column: $table.descriptionRawValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genresJson => $composableBuilder(
    column: $table.genresJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverLocator => $composableBuilder(
    column: $table.coverLocator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get animeFormat => $composableBuilder(
    column: $table.animeFormat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get airingSeason => $composableBuilder(
    column: $table.airingSeason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get airingYear => $composableBuilder(
    column: $table.airingYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get airingRawLabel => $composableBuilder(
    column: $table.airingRawLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get narrativeSeason => $composableBuilder(
    column: $table.narrativeSeason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get knownEpisodeTotal => $composableBuilder(
    column: $table.knownEpisodeTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawEpisodeTotal => $composableBuilder(
    column: $table.rawEpisodeTotal,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CanonicalMediaRecordsTableAnnotationComposer
    extends Composer<_$CanonicalDatabase, $CanonicalMediaRecordsTable> {
  $$CanonicalMediaRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get titleProviderId => $composableBuilder(
    column: $table.titleProviderId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get titleRawValue => $composableBuilder(
    column: $table.titleRawValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get alternateTitlesJson => $composableBuilder(
    column: $table.alternateTitlesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get descriptionProviderId => $composableBuilder(
    column: $table.descriptionProviderId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get descriptionRawValue => $composableBuilder(
    column: $table.descriptionRawValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get genresJson => $composableBuilder(
    column: $table.genresJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverLocator => $composableBuilder(
    column: $table.coverLocator,
    builder: (column) => column,
  );

  GeneratedColumn<String> get animeFormat => $composableBuilder(
    column: $table.animeFormat,
    builder: (column) => column,
  );

  GeneratedColumn<String> get airingSeason => $composableBuilder(
    column: $table.airingSeason,
    builder: (column) => column,
  );

  GeneratedColumn<int> get airingYear => $composableBuilder(
    column: $table.airingYear,
    builder: (column) => column,
  );

  GeneratedColumn<String> get airingRawLabel => $composableBuilder(
    column: $table.airingRawLabel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get narrativeSeason => $composableBuilder(
    column: $table.narrativeSeason,
    builder: (column) => column,
  );

  GeneratedColumn<int> get knownEpisodeTotal => $composableBuilder(
    column: $table.knownEpisodeTotal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawEpisodeTotal => $composableBuilder(
    column: $table.rawEpisodeTotal,
    builder: (column) => column,
  );

  Expression<T> canonicalChapterRecordsRefs<T extends Object>(
    Expression<T> Function($$CanonicalChapterRecordsTableAnnotationComposer a)
    f,
  ) {
    final $$CanonicalChapterRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.canonicalChapterRecords,
          getReferencedColumn: (t) => t.mediaId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalChapterRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.canonicalChapterRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> canonicalEpisodeRecordsRefs<T extends Object>(
    Expression<T> Function($$CanonicalEpisodeRecordsTableAnnotationComposer a)
    f,
  ) {
    final $$CanonicalEpisodeRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.canonicalEpisodeRecords,
          getReferencedColumn: (t) => t.mediaId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalEpisodeRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.canonicalEpisodeRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> canonicalMediaBindingsRefs<T extends Object>(
    Expression<T> Function($$CanonicalMediaBindingsTableAnnotationComposer a) f,
  ) {
    final $$CanonicalMediaBindingsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.canonicalMediaBindings,
          getReferencedColumn: (t) => t.canonicalId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaBindingsTableAnnotationComposer(
                $db: $db,
                $table: $db.canonicalMediaBindings,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> canonicalLibraryRecordsRefs<T extends Object>(
    Expression<T> Function($$CanonicalLibraryRecordsTableAnnotationComposer a)
    f,
  ) {
    final $$CanonicalLibraryRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.canonicalLibraryRecords,
          getReferencedColumn: (t) => t.mediaId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalLibraryRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.canonicalLibraryRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> canonicalMangaProgressRecordsRefs<T extends Object>(
    Expression<T> Function(
      $$CanonicalMangaProgressRecordsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$CanonicalMangaProgressRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.canonicalMangaProgressRecords,
          getReferencedColumn: (t) => t.mediaId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMangaProgressRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.canonicalMangaProgressRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> canonicalAnimeProgressRecordsRefs<T extends Object>(
    Expression<T> Function(
      $$CanonicalAnimeProgressRecordsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$CanonicalAnimeProgressRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.canonicalAnimeProgressRecords,
          getReferencedColumn: (t) => t.mediaId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalAnimeProgressRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.canonicalAnimeProgressRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> mangaSourcePageResumesRefs<T extends Object>(
    Expression<T> Function($$MangaSourcePageResumesTableAnnotationComposer a) f,
  ) {
    final $$MangaSourcePageResumesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.mangaSourcePageResumes,
          getReferencedColumn: (t) => t.mediaId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MangaSourcePageResumesTableAnnotationComposer(
                $db: $db,
                $table: $db.mangaSourcePageResumes,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> animeSourcePlaybackResumesRefs<T extends Object>(
    Expression<T> Function(
      $$AnimeSourcePlaybackResumesTableAnnotationComposer a,
    )
    f,
  ) {
    final $$AnimeSourcePlaybackResumesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.animeSourcePlaybackResumes,
          getReferencedColumn: (t) => t.mediaId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AnimeSourcePlaybackResumesTableAnnotationComposer(
                $db: $db,
                $table: $db.animeSourcePlaybackResumes,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> preferredMediaSourcesRefs<T extends Object>(
    Expression<T> Function($$PreferredMediaSourcesTableAnnotationComposer a) f,
  ) {
    final $$PreferredMediaSourcesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.preferredMediaSources,
          getReferencedColumn: (t) => t.mediaId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PreferredMediaSourcesTableAnnotationComposer(
                $db: $db,
                $table: $db.preferredMediaSources,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> localAssetRecordsRefs<T extends Object>(
    Expression<T> Function($$LocalAssetRecordsTableAnnotationComposer a) f,
  ) {
    final $$LocalAssetRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.localAssetRecords,
          getReferencedColumn: (t) => t.mediaId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LocalAssetRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.localAssetRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> metadataEnrichmentRecordsRefs<T extends Object>(
    Expression<T> Function($$MetadataEnrichmentRecordsTableAnnotationComposer a)
    f,
  ) {
    final $$MetadataEnrichmentRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.metadataEnrichmentRecords,
          getReferencedColumn: (t) => t.mediaId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MetadataEnrichmentRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.metadataEnrichmentRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> metadataOverrideRecordsRefs<T extends Object>(
    Expression<T> Function($$MetadataOverrideRecordsTableAnnotationComposer a)
    f,
  ) {
    final $$MetadataOverrideRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.metadataOverrideRecords,
          getReferencedColumn: (t) => t.mediaId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MetadataOverrideRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.metadataOverrideRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> chapterCompletionRecordsRefs<T extends Object>(
    Expression<T> Function($$ChapterCompletionRecordsTableAnnotationComposer a)
    f,
  ) {
    final $$ChapterCompletionRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.chapterCompletionRecords,
          getReferencedColumn: (t) => t.mediaId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ChapterCompletionRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.chapterCompletionRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> episodeCompletionRecordsRefs<T extends Object>(
    Expression<T> Function($$EpisodeCompletionRecordsTableAnnotationComposer a)
    f,
  ) {
    final $$EpisodeCompletionRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.episodeCompletionRecords,
          getReferencedColumn: (t) => t.mediaId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EpisodeCompletionRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.episodeCompletionRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CanonicalMediaRecordsTableTableManager
    extends
        RootTableManager<
          _$CanonicalDatabase,
          $CanonicalMediaRecordsTable,
          CanonicalMediaRow,
          $$CanonicalMediaRecordsTableFilterComposer,
          $$CanonicalMediaRecordsTableOrderingComposer,
          $$CanonicalMediaRecordsTableAnnotationComposer,
          $$CanonicalMediaRecordsTableCreateCompanionBuilder,
          $$CanonicalMediaRecordsTableUpdateCompanionBuilder,
          (CanonicalMediaRow, $$CanonicalMediaRecordsTableReferences),
          CanonicalMediaRow,
          PrefetchHooks Function({
            bool canonicalChapterRecordsRefs,
            bool canonicalEpisodeRecordsRefs,
            bool canonicalMediaBindingsRefs,
            bool canonicalLibraryRecordsRefs,
            bool canonicalMangaProgressRecordsRefs,
            bool canonicalAnimeProgressRecordsRefs,
            bool mangaSourcePageResumesRefs,
            bool animeSourcePlaybackResumesRefs,
            bool preferredMediaSourcesRefs,
            bool localAssetRecordsRefs,
            bool metadataEnrichmentRecordsRefs,
            bool metadataOverrideRecordsRefs,
            bool chapterCompletionRecordsRefs,
            bool episodeCompletionRecordsRefs,
          })
        > {
  $$CanonicalMediaRecordsTableTableManager(
    _$CanonicalDatabase db,
    $CanonicalMediaRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CanonicalMediaRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CanonicalMediaRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CanonicalMediaRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> titleProviderId = const Value.absent(),
                Value<String?> titleRawValue = const Value.absent(),
                Value<String> alternateTitlesJson = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> descriptionProviderId = const Value.absent(),
                Value<String?> descriptionRawValue = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> genresJson = const Value.absent(),
                Value<String?> coverLocator = const Value.absent(),
                Value<String?> animeFormat = const Value.absent(),
                Value<String?> airingSeason = const Value.absent(),
                Value<int?> airingYear = const Value.absent(),
                Value<String?> airingRawLabel = const Value.absent(),
                Value<int?> narrativeSeason = const Value.absent(),
                Value<int?> knownEpisodeTotal = const Value.absent(),
                Value<String?> rawEpisodeTotal = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CanonicalMediaRecordsCompanion(
                id: id,
                kind: kind,
                title: title,
                titleProviderId: titleProviderId,
                titleRawValue: titleRawValue,
                alternateTitlesJson: alternateTitlesJson,
                description: description,
                descriptionProviderId: descriptionProviderId,
                descriptionRawValue: descriptionRawValue,
                status: status,
                genresJson: genresJson,
                coverLocator: coverLocator,
                animeFormat: animeFormat,
                airingSeason: airingSeason,
                airingYear: airingYear,
                airingRawLabel: airingRawLabel,
                narrativeSeason: narrativeSeason,
                knownEpisodeTotal: knownEpisodeTotal,
                rawEpisodeTotal: rawEpisodeTotal,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String kind,
                required String title,
                required String titleProviderId,
                Value<String?> titleRawValue = const Value.absent(),
                Value<String> alternateTitlesJson = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> descriptionProviderId = const Value.absent(),
                Value<String?> descriptionRawValue = const Value.absent(),
                required String status,
                Value<String> genresJson = const Value.absent(),
                Value<String?> coverLocator = const Value.absent(),
                Value<String?> animeFormat = const Value.absent(),
                Value<String?> airingSeason = const Value.absent(),
                Value<int?> airingYear = const Value.absent(),
                Value<String?> airingRawLabel = const Value.absent(),
                Value<int?> narrativeSeason = const Value.absent(),
                Value<int?> knownEpisodeTotal = const Value.absent(),
                Value<String?> rawEpisodeTotal = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CanonicalMediaRecordsCompanion.insert(
                id: id,
                kind: kind,
                title: title,
                titleProviderId: titleProviderId,
                titleRawValue: titleRawValue,
                alternateTitlesJson: alternateTitlesJson,
                description: description,
                descriptionProviderId: descriptionProviderId,
                descriptionRawValue: descriptionRawValue,
                status: status,
                genresJson: genresJson,
                coverLocator: coverLocator,
                animeFormat: animeFormat,
                airingSeason: airingSeason,
                airingYear: airingYear,
                airingRawLabel: airingRawLabel,
                narrativeSeason: narrativeSeason,
                knownEpisodeTotal: knownEpisodeTotal,
                rawEpisodeTotal: rawEpisodeTotal,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CanonicalMediaRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                canonicalChapterRecordsRefs = false,
                canonicalEpisodeRecordsRefs = false,
                canonicalMediaBindingsRefs = false,
                canonicalLibraryRecordsRefs = false,
                canonicalMangaProgressRecordsRefs = false,
                canonicalAnimeProgressRecordsRefs = false,
                mangaSourcePageResumesRefs = false,
                animeSourcePlaybackResumesRefs = false,
                preferredMediaSourcesRefs = false,
                localAssetRecordsRefs = false,
                metadataEnrichmentRecordsRefs = false,
                metadataOverrideRecordsRefs = false,
                chapterCompletionRecordsRefs = false,
                episodeCompletionRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (canonicalChapterRecordsRefs) db.canonicalChapterRecords,
                    if (canonicalEpisodeRecordsRefs) db.canonicalEpisodeRecords,
                    if (canonicalMediaBindingsRefs) db.canonicalMediaBindings,
                    if (canonicalLibraryRecordsRefs) db.canonicalLibraryRecords,
                    if (canonicalMangaProgressRecordsRefs)
                      db.canonicalMangaProgressRecords,
                    if (canonicalAnimeProgressRecordsRefs)
                      db.canonicalAnimeProgressRecords,
                    if (mangaSourcePageResumesRefs) db.mangaSourcePageResumes,
                    if (animeSourcePlaybackResumesRefs)
                      db.animeSourcePlaybackResumes,
                    if (preferredMediaSourcesRefs) db.preferredMediaSources,
                    if (localAssetRecordsRefs) db.localAssetRecords,
                    if (metadataEnrichmentRecordsRefs)
                      db.metadataEnrichmentRecords,
                    if (metadataOverrideRecordsRefs) db.metadataOverrideRecords,
                    if (chapterCompletionRecordsRefs)
                      db.chapterCompletionRecords,
                    if (episodeCompletionRecordsRefs)
                      db.episodeCompletionRecords,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (canonicalChapterRecordsRefs)
                        await $_getPrefetchedData<
                          CanonicalMediaRow,
                          $CanonicalMediaRecordsTable,
                          CanonicalChapterRow
                        >(
                          currentTable: table,
                          referencedTable:
                              $$CanonicalMediaRecordsTableReferences
                                  ._canonicalChapterRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CanonicalMediaRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).canonicalChapterRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.mediaId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (canonicalEpisodeRecordsRefs)
                        await $_getPrefetchedData<
                          CanonicalMediaRow,
                          $CanonicalMediaRecordsTable,
                          CanonicalEpisodeRow
                        >(
                          currentTable: table,
                          referencedTable:
                              $$CanonicalMediaRecordsTableReferences
                                  ._canonicalEpisodeRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CanonicalMediaRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).canonicalEpisodeRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.mediaId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (canonicalMediaBindingsRefs)
                        await $_getPrefetchedData<
                          CanonicalMediaRow,
                          $CanonicalMediaRecordsTable,
                          MediaBindingRow
                        >(
                          currentTable: table,
                          referencedTable:
                              $$CanonicalMediaRecordsTableReferences
                                  ._canonicalMediaBindingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CanonicalMediaRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).canonicalMediaBindingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.canonicalId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (canonicalLibraryRecordsRefs)
                        await $_getPrefetchedData<
                          CanonicalMediaRow,
                          $CanonicalMediaRecordsTable,
                          CanonicalLibraryRow
                        >(
                          currentTable: table,
                          referencedTable:
                              $$CanonicalMediaRecordsTableReferences
                                  ._canonicalLibraryRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CanonicalMediaRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).canonicalLibraryRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.mediaId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (canonicalMangaProgressRecordsRefs)
                        await $_getPrefetchedData<
                          CanonicalMediaRow,
                          $CanonicalMediaRecordsTable,
                          CanonicalMangaProgressRow
                        >(
                          currentTable: table,
                          referencedTable:
                              $$CanonicalMediaRecordsTableReferences
                                  ._canonicalMangaProgressRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CanonicalMediaRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).canonicalMangaProgressRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.mediaId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (canonicalAnimeProgressRecordsRefs)
                        await $_getPrefetchedData<
                          CanonicalMediaRow,
                          $CanonicalMediaRecordsTable,
                          CanonicalAnimeProgressRow
                        >(
                          currentTable: table,
                          referencedTable:
                              $$CanonicalMediaRecordsTableReferences
                                  ._canonicalAnimeProgressRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CanonicalMediaRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).canonicalAnimeProgressRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.mediaId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (mangaSourcePageResumesRefs)
                        await $_getPrefetchedData<
                          CanonicalMediaRow,
                          $CanonicalMediaRecordsTable,
                          MangaSourcePageResumeRow
                        >(
                          currentTable: table,
                          referencedTable:
                              $$CanonicalMediaRecordsTableReferences
                                  ._mangaSourcePageResumesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CanonicalMediaRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).mangaSourcePageResumesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.mediaId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (animeSourcePlaybackResumesRefs)
                        await $_getPrefetchedData<
                          CanonicalMediaRow,
                          $CanonicalMediaRecordsTable,
                          AnimeSourcePlaybackResumeRow
                        >(
                          currentTable: table,
                          referencedTable:
                              $$CanonicalMediaRecordsTableReferences
                                  ._animeSourcePlaybackResumesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CanonicalMediaRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).animeSourcePlaybackResumesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.mediaId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (preferredMediaSourcesRefs)
                        await $_getPrefetchedData<
                          CanonicalMediaRow,
                          $CanonicalMediaRecordsTable,
                          PreferredMediaSourceRow
                        >(
                          currentTable: table,
                          referencedTable:
                              $$CanonicalMediaRecordsTableReferences
                                  ._preferredMediaSourcesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CanonicalMediaRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).preferredMediaSourcesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.mediaId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (localAssetRecordsRefs)
                        await $_getPrefetchedData<
                          CanonicalMediaRow,
                          $CanonicalMediaRecordsTable,
                          LocalAssetRow
                        >(
                          currentTable: table,
                          referencedTable:
                              $$CanonicalMediaRecordsTableReferences
                                  ._localAssetRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CanonicalMediaRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).localAssetRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.mediaId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (metadataEnrichmentRecordsRefs)
                        await $_getPrefetchedData<
                          CanonicalMediaRow,
                          $CanonicalMediaRecordsTable,
                          MetadataEnrichmentRow
                        >(
                          currentTable: table,
                          referencedTable:
                              $$CanonicalMediaRecordsTableReferences
                                  ._metadataEnrichmentRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CanonicalMediaRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).metadataEnrichmentRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.mediaId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (metadataOverrideRecordsRefs)
                        await $_getPrefetchedData<
                          CanonicalMediaRow,
                          $CanonicalMediaRecordsTable,
                          MetadataOverrideRow
                        >(
                          currentTable: table,
                          referencedTable:
                              $$CanonicalMediaRecordsTableReferences
                                  ._metadataOverrideRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CanonicalMediaRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).metadataOverrideRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.mediaId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (chapterCompletionRecordsRefs)
                        await $_getPrefetchedData<
                          CanonicalMediaRow,
                          $CanonicalMediaRecordsTable,
                          ChapterCompletionRow
                        >(
                          currentTable: table,
                          referencedTable:
                              $$CanonicalMediaRecordsTableReferences
                                  ._chapterCompletionRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CanonicalMediaRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).chapterCompletionRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.mediaId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (episodeCompletionRecordsRefs)
                        await $_getPrefetchedData<
                          CanonicalMediaRow,
                          $CanonicalMediaRecordsTable,
                          EpisodeCompletionRow
                        >(
                          currentTable: table,
                          referencedTable:
                              $$CanonicalMediaRecordsTableReferences
                                  ._episodeCompletionRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CanonicalMediaRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).episodeCompletionRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.mediaId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CanonicalMediaRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$CanonicalDatabase,
      $CanonicalMediaRecordsTable,
      CanonicalMediaRow,
      $$CanonicalMediaRecordsTableFilterComposer,
      $$CanonicalMediaRecordsTableOrderingComposer,
      $$CanonicalMediaRecordsTableAnnotationComposer,
      $$CanonicalMediaRecordsTableCreateCompanionBuilder,
      $$CanonicalMediaRecordsTableUpdateCompanionBuilder,
      (CanonicalMediaRow, $$CanonicalMediaRecordsTableReferences),
      CanonicalMediaRow,
      PrefetchHooks Function({
        bool canonicalChapterRecordsRefs,
        bool canonicalEpisodeRecordsRefs,
        bool canonicalMediaBindingsRefs,
        bool canonicalLibraryRecordsRefs,
        bool canonicalMangaProgressRecordsRefs,
        bool canonicalAnimeProgressRecordsRefs,
        bool mangaSourcePageResumesRefs,
        bool animeSourcePlaybackResumesRefs,
        bool preferredMediaSourcesRefs,
        bool localAssetRecordsRefs,
        bool metadataEnrichmentRecordsRefs,
        bool metadataOverrideRecordsRefs,
        bool chapterCompletionRecordsRefs,
        bool episodeCompletionRecordsRefs,
      })
    >;
typedef $$CanonicalChapterRecordsTableCreateCompanionBuilder =
    CanonicalChapterRecordsCompanion Function({
      required String id,
      required String mediaId,
      required String rawLabel,
      Value<String?> normalizedNumber,
      Value<String?> title,
      Value<String?> volumeLabel,
      Value<int> rowid,
    });
typedef $$CanonicalChapterRecordsTableUpdateCompanionBuilder =
    CanonicalChapterRecordsCompanion Function({
      Value<String> id,
      Value<String> mediaId,
      Value<String> rawLabel,
      Value<String?> normalizedNumber,
      Value<String?> title,
      Value<String?> volumeLabel,
      Value<int> rowid,
    });

final class $$CanonicalChapterRecordsTableReferences
    extends
        BaseReferences<
          _$CanonicalDatabase,
          $CanonicalChapterRecordsTable,
          CanonicalChapterRow
        > {
  $$CanonicalChapterRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CanonicalMediaRecordsTable _mediaIdTable(_$CanonicalDatabase db) =>
      db.canonicalMediaRecords.createAlias(
        $_aliasNameGenerator(
          db.canonicalChapterRecords.mediaId,
          db.canonicalMediaRecords.id,
        ),
      );

  $$CanonicalMediaRecordsTableProcessedTableManager get mediaId {
    final $_column = $_itemColumn<String>('media_id')!;

    final manager = $$CanonicalMediaRecordsTableTableManager(
      $_db,
      $_db.canonicalMediaRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mediaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $CanonicalChapterBindingsTable,
    List<ChapterBindingRow>
  >
  _canonicalChapterBindingsRefsTable(_$CanonicalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.canonicalChapterBindings,
        aliasName: $_aliasNameGenerator(
          db.canonicalChapterRecords.id,
          db.canonicalChapterBindings.canonicalId,
        ),
      );

  $$CanonicalChapterBindingsTableProcessedTableManager
  get canonicalChapterBindingsRefs {
    final manager = $$CanonicalChapterBindingsTableTableManager(
      $_db,
      $_db.canonicalChapterBindings,
    ).filter((f) => f.canonicalId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _canonicalChapterBindingsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CanonicalMangaProgressRecordsTable,
    List<CanonicalMangaProgressRow>
  >
  _canonicalMangaProgressRecordsRefsTable(_$CanonicalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.canonicalMangaProgressRecords,
        aliasName: $_aliasNameGenerator(
          db.canonicalChapterRecords.id,
          db.canonicalMangaProgressRecords.chapterId,
        ),
      );

  $$CanonicalMangaProgressRecordsTableProcessedTableManager
  get canonicalMangaProgressRecordsRefs {
    final manager = $$CanonicalMangaProgressRecordsTableTableManager(
      $_db,
      $_db.canonicalMangaProgressRecords,
    ).filter((f) => f.chapterId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _canonicalMangaProgressRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $MangaSourcePageResumesTable,
    List<MangaSourcePageResumeRow>
  >
  _mangaSourcePageResumesRefsTable(_$CanonicalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.mangaSourcePageResumes,
        aliasName: $_aliasNameGenerator(
          db.canonicalChapterRecords.id,
          db.mangaSourcePageResumes.chapterId,
        ),
      );

  $$MangaSourcePageResumesTableProcessedTableManager
  get mangaSourcePageResumesRefs {
    final manager = $$MangaSourcePageResumesTableTableManager(
      $_db,
      $_db.mangaSourcePageResumes,
    ).filter((f) => f.chapterId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _mangaSourcePageResumesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ChapterUserEditRecordsTable,
    List<ChapterUserEditRow>
  >
  _chapterUserEditRecordsRefsTable(_$CanonicalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.chapterUserEditRecords,
        aliasName: $_aliasNameGenerator(
          db.canonicalChapterRecords.id,
          db.chapterUserEditRecords.chapterId,
        ),
      );

  $$ChapterUserEditRecordsTableProcessedTableManager
  get chapterUserEditRecordsRefs {
    final manager = $$ChapterUserEditRecordsTableTableManager(
      $_db,
      $_db.chapterUserEditRecords,
    ).filter((f) => f.chapterId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _chapterUserEditRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ChapterCompletionRecordsTable,
    List<ChapterCompletionRow>
  >
  _chapterCompletionRecordsRefsTable(_$CanonicalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.chapterCompletionRecords,
        aliasName: $_aliasNameGenerator(
          db.canonicalChapterRecords.id,
          db.chapterCompletionRecords.chapterId,
        ),
      );

  $$ChapterCompletionRecordsTableProcessedTableManager
  get chapterCompletionRecordsRefs {
    final manager = $$ChapterCompletionRecordsTableTableManager(
      $_db,
      $_db.chapterCompletionRecords,
    ).filter((f) => f.chapterId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _chapterCompletionRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CanonicalChapterRecordsTableFilterComposer
    extends Composer<_$CanonicalDatabase, $CanonicalChapterRecordsTable> {
  $$CanonicalChapterRecordsTableFilterComposer({
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

  ColumnFilters<String> get rawLabel => $composableBuilder(
    column: $table.rawLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedNumber => $composableBuilder(
    column: $table.normalizedNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get volumeLabel => $composableBuilder(
    column: $table.volumeLabel,
    builder: (column) => ColumnFilters(column),
  );

  $$CanonicalMediaRecordsTableFilterComposer get mediaId {
    final $$CanonicalMediaRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mediaId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableFilterComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<bool> canonicalChapterBindingsRefs(
    Expression<bool> Function($$CanonicalChapterBindingsTableFilterComposer f)
    f,
  ) {
    final $$CanonicalChapterBindingsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.canonicalChapterBindings,
          getReferencedColumn: (t) => t.canonicalId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalChapterBindingsTableFilterComposer(
                $db: $db,
                $table: $db.canonicalChapterBindings,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> canonicalMangaProgressRecordsRefs(
    Expression<bool> Function(
      $$CanonicalMangaProgressRecordsTableFilterComposer f,
    )
    f,
  ) {
    final $$CanonicalMangaProgressRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.canonicalMangaProgressRecords,
          getReferencedColumn: (t) => t.chapterId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMangaProgressRecordsTableFilterComposer(
                $db: $db,
                $table: $db.canonicalMangaProgressRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> mangaSourcePageResumesRefs(
    Expression<bool> Function($$MangaSourcePageResumesTableFilterComposer f) f,
  ) {
    final $$MangaSourcePageResumesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.mangaSourcePageResumes,
          getReferencedColumn: (t) => t.chapterId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MangaSourcePageResumesTableFilterComposer(
                $db: $db,
                $table: $db.mangaSourcePageResumes,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> chapterUserEditRecordsRefs(
    Expression<bool> Function($$ChapterUserEditRecordsTableFilterComposer f) f,
  ) {
    final $$ChapterUserEditRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.chapterUserEditRecords,
          getReferencedColumn: (t) => t.chapterId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ChapterUserEditRecordsTableFilterComposer(
                $db: $db,
                $table: $db.chapterUserEditRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> chapterCompletionRecordsRefs(
    Expression<bool> Function($$ChapterCompletionRecordsTableFilterComposer f)
    f,
  ) {
    final $$ChapterCompletionRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.chapterCompletionRecords,
          getReferencedColumn: (t) => t.chapterId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ChapterCompletionRecordsTableFilterComposer(
                $db: $db,
                $table: $db.chapterCompletionRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CanonicalChapterRecordsTableOrderingComposer
    extends Composer<_$CanonicalDatabase, $CanonicalChapterRecordsTable> {
  $$CanonicalChapterRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get rawLabel => $composableBuilder(
    column: $table.rawLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedNumber => $composableBuilder(
    column: $table.normalizedNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get volumeLabel => $composableBuilder(
    column: $table.volumeLabel,
    builder: (column) => ColumnOrderings(column),
  );

  $$CanonicalMediaRecordsTableOrderingComposer get mediaId {
    final $$CanonicalMediaRecordsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mediaId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableOrderingComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CanonicalChapterRecordsTableAnnotationComposer
    extends Composer<_$CanonicalDatabase, $CanonicalChapterRecordsTable> {
  $$CanonicalChapterRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rawLabel =>
      $composableBuilder(column: $table.rawLabel, builder: (column) => column);

  GeneratedColumn<String> get normalizedNumber => $composableBuilder(
    column: $table.normalizedNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get volumeLabel => $composableBuilder(
    column: $table.volumeLabel,
    builder: (column) => column,
  );

  $$CanonicalMediaRecordsTableAnnotationComposer get mediaId {
    final $$CanonicalMediaRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mediaId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> canonicalChapterBindingsRefs<T extends Object>(
    Expression<T> Function($$CanonicalChapterBindingsTableAnnotationComposer a)
    f,
  ) {
    final $$CanonicalChapterBindingsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.canonicalChapterBindings,
          getReferencedColumn: (t) => t.canonicalId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalChapterBindingsTableAnnotationComposer(
                $db: $db,
                $table: $db.canonicalChapterBindings,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> canonicalMangaProgressRecordsRefs<T extends Object>(
    Expression<T> Function(
      $$CanonicalMangaProgressRecordsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$CanonicalMangaProgressRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.canonicalMangaProgressRecords,
          getReferencedColumn: (t) => t.chapterId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMangaProgressRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.canonicalMangaProgressRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> mangaSourcePageResumesRefs<T extends Object>(
    Expression<T> Function($$MangaSourcePageResumesTableAnnotationComposer a) f,
  ) {
    final $$MangaSourcePageResumesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.mangaSourcePageResumes,
          getReferencedColumn: (t) => t.chapterId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MangaSourcePageResumesTableAnnotationComposer(
                $db: $db,
                $table: $db.mangaSourcePageResumes,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> chapterUserEditRecordsRefs<T extends Object>(
    Expression<T> Function($$ChapterUserEditRecordsTableAnnotationComposer a) f,
  ) {
    final $$ChapterUserEditRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.chapterUserEditRecords,
          getReferencedColumn: (t) => t.chapterId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ChapterUserEditRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.chapterUserEditRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> chapterCompletionRecordsRefs<T extends Object>(
    Expression<T> Function($$ChapterCompletionRecordsTableAnnotationComposer a)
    f,
  ) {
    final $$ChapterCompletionRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.chapterCompletionRecords,
          getReferencedColumn: (t) => t.chapterId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ChapterCompletionRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.chapterCompletionRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CanonicalChapterRecordsTableTableManager
    extends
        RootTableManager<
          _$CanonicalDatabase,
          $CanonicalChapterRecordsTable,
          CanonicalChapterRow,
          $$CanonicalChapterRecordsTableFilterComposer,
          $$CanonicalChapterRecordsTableOrderingComposer,
          $$CanonicalChapterRecordsTableAnnotationComposer,
          $$CanonicalChapterRecordsTableCreateCompanionBuilder,
          $$CanonicalChapterRecordsTableUpdateCompanionBuilder,
          (CanonicalChapterRow, $$CanonicalChapterRecordsTableReferences),
          CanonicalChapterRow,
          PrefetchHooks Function({
            bool mediaId,
            bool canonicalChapterBindingsRefs,
            bool canonicalMangaProgressRecordsRefs,
            bool mangaSourcePageResumesRefs,
            bool chapterUserEditRecordsRefs,
            bool chapterCompletionRecordsRefs,
          })
        > {
  $$CanonicalChapterRecordsTableTableManager(
    _$CanonicalDatabase db,
    $CanonicalChapterRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CanonicalChapterRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CanonicalChapterRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CanonicalChapterRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> mediaId = const Value.absent(),
                Value<String> rawLabel = const Value.absent(),
                Value<String?> normalizedNumber = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> volumeLabel = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CanonicalChapterRecordsCompanion(
                id: id,
                mediaId: mediaId,
                rawLabel: rawLabel,
                normalizedNumber: normalizedNumber,
                title: title,
                volumeLabel: volumeLabel,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String mediaId,
                required String rawLabel,
                Value<String?> normalizedNumber = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> volumeLabel = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CanonicalChapterRecordsCompanion.insert(
                id: id,
                mediaId: mediaId,
                rawLabel: rawLabel,
                normalizedNumber: normalizedNumber,
                title: title,
                volumeLabel: volumeLabel,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CanonicalChapterRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                mediaId = false,
                canonicalChapterBindingsRefs = false,
                canonicalMangaProgressRecordsRefs = false,
                mangaSourcePageResumesRefs = false,
                chapterUserEditRecordsRefs = false,
                chapterCompletionRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (canonicalChapterBindingsRefs)
                      db.canonicalChapterBindings,
                    if (canonicalMangaProgressRecordsRefs)
                      db.canonicalMangaProgressRecords,
                    if (mangaSourcePageResumesRefs) db.mangaSourcePageResumes,
                    if (chapterUserEditRecordsRefs) db.chapterUserEditRecords,
                    if (chapterCompletionRecordsRefs)
                      db.chapterCompletionRecords,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (mediaId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.mediaId,
                                    referencedTable:
                                        $$CanonicalChapterRecordsTableReferences
                                            ._mediaIdTable(db),
                                    referencedColumn:
                                        $$CanonicalChapterRecordsTableReferences
                                            ._mediaIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (canonicalChapterBindingsRefs)
                        await $_getPrefetchedData<
                          CanonicalChapterRow,
                          $CanonicalChapterRecordsTable,
                          ChapterBindingRow
                        >(
                          currentTable: table,
                          referencedTable:
                              $$CanonicalChapterRecordsTableReferences
                                  ._canonicalChapterBindingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CanonicalChapterRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).canonicalChapterBindingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.canonicalId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (canonicalMangaProgressRecordsRefs)
                        await $_getPrefetchedData<
                          CanonicalChapterRow,
                          $CanonicalChapterRecordsTable,
                          CanonicalMangaProgressRow
                        >(
                          currentTable: table,
                          referencedTable:
                              $$CanonicalChapterRecordsTableReferences
                                  ._canonicalMangaProgressRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CanonicalChapterRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).canonicalMangaProgressRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.chapterId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (mangaSourcePageResumesRefs)
                        await $_getPrefetchedData<
                          CanonicalChapterRow,
                          $CanonicalChapterRecordsTable,
                          MangaSourcePageResumeRow
                        >(
                          currentTable: table,
                          referencedTable:
                              $$CanonicalChapterRecordsTableReferences
                                  ._mangaSourcePageResumesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CanonicalChapterRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).mangaSourcePageResumesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.chapterId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (chapterUserEditRecordsRefs)
                        await $_getPrefetchedData<
                          CanonicalChapterRow,
                          $CanonicalChapterRecordsTable,
                          ChapterUserEditRow
                        >(
                          currentTable: table,
                          referencedTable:
                              $$CanonicalChapterRecordsTableReferences
                                  ._chapterUserEditRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CanonicalChapterRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).chapterUserEditRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.chapterId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (chapterCompletionRecordsRefs)
                        await $_getPrefetchedData<
                          CanonicalChapterRow,
                          $CanonicalChapterRecordsTable,
                          ChapterCompletionRow
                        >(
                          currentTable: table,
                          referencedTable:
                              $$CanonicalChapterRecordsTableReferences
                                  ._chapterCompletionRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CanonicalChapterRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).chapterCompletionRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.chapterId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CanonicalChapterRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$CanonicalDatabase,
      $CanonicalChapterRecordsTable,
      CanonicalChapterRow,
      $$CanonicalChapterRecordsTableFilterComposer,
      $$CanonicalChapterRecordsTableOrderingComposer,
      $$CanonicalChapterRecordsTableAnnotationComposer,
      $$CanonicalChapterRecordsTableCreateCompanionBuilder,
      $$CanonicalChapterRecordsTableUpdateCompanionBuilder,
      (CanonicalChapterRow, $$CanonicalChapterRecordsTableReferences),
      CanonicalChapterRow,
      PrefetchHooks Function({
        bool mediaId,
        bool canonicalChapterBindingsRefs,
        bool canonicalMangaProgressRecordsRefs,
        bool mangaSourcePageResumesRefs,
        bool chapterUserEditRecordsRefs,
        bool chapterCompletionRecordsRefs,
      })
    >;
typedef $$CanonicalEpisodeRecordsTableCreateCompanionBuilder =
    CanonicalEpisodeRecordsCompanion Function({
      required String id,
      required String mediaId,
      required String rawLabel,
      Value<double?> number,
      Value<String?> title,
      Value<int?> narrativeSeason,
      Value<int> rowid,
    });
typedef $$CanonicalEpisodeRecordsTableUpdateCompanionBuilder =
    CanonicalEpisodeRecordsCompanion Function({
      Value<String> id,
      Value<String> mediaId,
      Value<String> rawLabel,
      Value<double?> number,
      Value<String?> title,
      Value<int?> narrativeSeason,
      Value<int> rowid,
    });

final class $$CanonicalEpisodeRecordsTableReferences
    extends
        BaseReferences<
          _$CanonicalDatabase,
          $CanonicalEpisodeRecordsTable,
          CanonicalEpisodeRow
        > {
  $$CanonicalEpisodeRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CanonicalMediaRecordsTable _mediaIdTable(_$CanonicalDatabase db) =>
      db.canonicalMediaRecords.createAlias(
        $_aliasNameGenerator(
          db.canonicalEpisodeRecords.mediaId,
          db.canonicalMediaRecords.id,
        ),
      );

  $$CanonicalMediaRecordsTableProcessedTableManager get mediaId {
    final $_column = $_itemColumn<String>('media_id')!;

    final manager = $$CanonicalMediaRecordsTableTableManager(
      $_db,
      $_db.canonicalMediaRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mediaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $CanonicalEpisodeBindingsTable,
    List<EpisodeBindingRow>
  >
  _canonicalEpisodeBindingsRefsTable(_$CanonicalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.canonicalEpisodeBindings,
        aliasName: $_aliasNameGenerator(
          db.canonicalEpisodeRecords.id,
          db.canonicalEpisodeBindings.canonicalId,
        ),
      );

  $$CanonicalEpisodeBindingsTableProcessedTableManager
  get canonicalEpisodeBindingsRefs {
    final manager = $$CanonicalEpisodeBindingsTableTableManager(
      $_db,
      $_db.canonicalEpisodeBindings,
    ).filter((f) => f.canonicalId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _canonicalEpisodeBindingsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CanonicalAnimeProgressRecordsTable,
    List<CanonicalAnimeProgressRow>
  >
  _canonicalAnimeProgressRecordsRefsTable(_$CanonicalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.canonicalAnimeProgressRecords,
        aliasName: $_aliasNameGenerator(
          db.canonicalEpisodeRecords.id,
          db.canonicalAnimeProgressRecords.episodeId,
        ),
      );

  $$CanonicalAnimeProgressRecordsTableProcessedTableManager
  get canonicalAnimeProgressRecordsRefs {
    final manager = $$CanonicalAnimeProgressRecordsTableTableManager(
      $_db,
      $_db.canonicalAnimeProgressRecords,
    ).filter((f) => f.episodeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _canonicalAnimeProgressRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $AnimeSourcePlaybackResumesTable,
    List<AnimeSourcePlaybackResumeRow>
  >
  _animeSourcePlaybackResumesRefsTable(_$CanonicalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.animeSourcePlaybackResumes,
        aliasName: $_aliasNameGenerator(
          db.canonicalEpisodeRecords.id,
          db.animeSourcePlaybackResumes.episodeId,
        ),
      );

  $$AnimeSourcePlaybackResumesTableProcessedTableManager
  get animeSourcePlaybackResumesRefs {
    final manager = $$AnimeSourcePlaybackResumesTableTableManager(
      $_db,
      $_db.animeSourcePlaybackResumes,
    ).filter((f) => f.episodeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _animeSourcePlaybackResumesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $EpisodeUserEditRecordsTable,
    List<EpisodeUserEditRow>
  >
  _episodeUserEditRecordsRefsTable(_$CanonicalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.episodeUserEditRecords,
        aliasName: $_aliasNameGenerator(
          db.canonicalEpisodeRecords.id,
          db.episodeUserEditRecords.episodeId,
        ),
      );

  $$EpisodeUserEditRecordsTableProcessedTableManager
  get episodeUserEditRecordsRefs {
    final manager = $$EpisodeUserEditRecordsTableTableManager(
      $_db,
      $_db.episodeUserEditRecords,
    ).filter((f) => f.episodeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _episodeUserEditRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $EpisodeCompletionRecordsTable,
    List<EpisodeCompletionRow>
  >
  _episodeCompletionRecordsRefsTable(_$CanonicalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.episodeCompletionRecords,
        aliasName: $_aliasNameGenerator(
          db.canonicalEpisodeRecords.id,
          db.episodeCompletionRecords.episodeId,
        ),
      );

  $$EpisodeCompletionRecordsTableProcessedTableManager
  get episodeCompletionRecordsRefs {
    final manager = $$EpisodeCompletionRecordsTableTableManager(
      $_db,
      $_db.episodeCompletionRecords,
    ).filter((f) => f.episodeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _episodeCompletionRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CanonicalEpisodeRecordsTableFilterComposer
    extends Composer<_$CanonicalDatabase, $CanonicalEpisodeRecordsTable> {
  $$CanonicalEpisodeRecordsTableFilterComposer({
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

  ColumnFilters<String> get rawLabel => $composableBuilder(
    column: $table.rawLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get narrativeSeason => $composableBuilder(
    column: $table.narrativeSeason,
    builder: (column) => ColumnFilters(column),
  );

  $$CanonicalMediaRecordsTableFilterComposer get mediaId {
    final $$CanonicalMediaRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mediaId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableFilterComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<bool> canonicalEpisodeBindingsRefs(
    Expression<bool> Function($$CanonicalEpisodeBindingsTableFilterComposer f)
    f,
  ) {
    final $$CanonicalEpisodeBindingsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.canonicalEpisodeBindings,
          getReferencedColumn: (t) => t.canonicalId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalEpisodeBindingsTableFilterComposer(
                $db: $db,
                $table: $db.canonicalEpisodeBindings,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> canonicalAnimeProgressRecordsRefs(
    Expression<bool> Function(
      $$CanonicalAnimeProgressRecordsTableFilterComposer f,
    )
    f,
  ) {
    final $$CanonicalAnimeProgressRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.canonicalAnimeProgressRecords,
          getReferencedColumn: (t) => t.episodeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalAnimeProgressRecordsTableFilterComposer(
                $db: $db,
                $table: $db.canonicalAnimeProgressRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> animeSourcePlaybackResumesRefs(
    Expression<bool> Function($$AnimeSourcePlaybackResumesTableFilterComposer f)
    f,
  ) {
    final $$AnimeSourcePlaybackResumesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.animeSourcePlaybackResumes,
          getReferencedColumn: (t) => t.episodeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AnimeSourcePlaybackResumesTableFilterComposer(
                $db: $db,
                $table: $db.animeSourcePlaybackResumes,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> episodeUserEditRecordsRefs(
    Expression<bool> Function($$EpisodeUserEditRecordsTableFilterComposer f) f,
  ) {
    final $$EpisodeUserEditRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.episodeUserEditRecords,
          getReferencedColumn: (t) => t.episodeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EpisodeUserEditRecordsTableFilterComposer(
                $db: $db,
                $table: $db.episodeUserEditRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> episodeCompletionRecordsRefs(
    Expression<bool> Function($$EpisodeCompletionRecordsTableFilterComposer f)
    f,
  ) {
    final $$EpisodeCompletionRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.episodeCompletionRecords,
          getReferencedColumn: (t) => t.episodeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EpisodeCompletionRecordsTableFilterComposer(
                $db: $db,
                $table: $db.episodeCompletionRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CanonicalEpisodeRecordsTableOrderingComposer
    extends Composer<_$CanonicalDatabase, $CanonicalEpisodeRecordsTable> {
  $$CanonicalEpisodeRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get rawLabel => $composableBuilder(
    column: $table.rawLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get narrativeSeason => $composableBuilder(
    column: $table.narrativeSeason,
    builder: (column) => ColumnOrderings(column),
  );

  $$CanonicalMediaRecordsTableOrderingComposer get mediaId {
    final $$CanonicalMediaRecordsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mediaId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableOrderingComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CanonicalEpisodeRecordsTableAnnotationComposer
    extends Composer<_$CanonicalDatabase, $CanonicalEpisodeRecordsTable> {
  $$CanonicalEpisodeRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rawLabel =>
      $composableBuilder(column: $table.rawLabel, builder: (column) => column);

  GeneratedColumn<double> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get narrativeSeason => $composableBuilder(
    column: $table.narrativeSeason,
    builder: (column) => column,
  );

  $$CanonicalMediaRecordsTableAnnotationComposer get mediaId {
    final $$CanonicalMediaRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mediaId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> canonicalEpisodeBindingsRefs<T extends Object>(
    Expression<T> Function($$CanonicalEpisodeBindingsTableAnnotationComposer a)
    f,
  ) {
    final $$CanonicalEpisodeBindingsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.canonicalEpisodeBindings,
          getReferencedColumn: (t) => t.canonicalId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalEpisodeBindingsTableAnnotationComposer(
                $db: $db,
                $table: $db.canonicalEpisodeBindings,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> canonicalAnimeProgressRecordsRefs<T extends Object>(
    Expression<T> Function(
      $$CanonicalAnimeProgressRecordsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$CanonicalAnimeProgressRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.canonicalAnimeProgressRecords,
          getReferencedColumn: (t) => t.episodeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalAnimeProgressRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.canonicalAnimeProgressRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> animeSourcePlaybackResumesRefs<T extends Object>(
    Expression<T> Function(
      $$AnimeSourcePlaybackResumesTableAnnotationComposer a,
    )
    f,
  ) {
    final $$AnimeSourcePlaybackResumesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.animeSourcePlaybackResumes,
          getReferencedColumn: (t) => t.episodeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AnimeSourcePlaybackResumesTableAnnotationComposer(
                $db: $db,
                $table: $db.animeSourcePlaybackResumes,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> episodeUserEditRecordsRefs<T extends Object>(
    Expression<T> Function($$EpisodeUserEditRecordsTableAnnotationComposer a) f,
  ) {
    final $$EpisodeUserEditRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.episodeUserEditRecords,
          getReferencedColumn: (t) => t.episodeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EpisodeUserEditRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.episodeUserEditRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> episodeCompletionRecordsRefs<T extends Object>(
    Expression<T> Function($$EpisodeCompletionRecordsTableAnnotationComposer a)
    f,
  ) {
    final $$EpisodeCompletionRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.episodeCompletionRecords,
          getReferencedColumn: (t) => t.episodeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EpisodeCompletionRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.episodeCompletionRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CanonicalEpisodeRecordsTableTableManager
    extends
        RootTableManager<
          _$CanonicalDatabase,
          $CanonicalEpisodeRecordsTable,
          CanonicalEpisodeRow,
          $$CanonicalEpisodeRecordsTableFilterComposer,
          $$CanonicalEpisodeRecordsTableOrderingComposer,
          $$CanonicalEpisodeRecordsTableAnnotationComposer,
          $$CanonicalEpisodeRecordsTableCreateCompanionBuilder,
          $$CanonicalEpisodeRecordsTableUpdateCompanionBuilder,
          (CanonicalEpisodeRow, $$CanonicalEpisodeRecordsTableReferences),
          CanonicalEpisodeRow,
          PrefetchHooks Function({
            bool mediaId,
            bool canonicalEpisodeBindingsRefs,
            bool canonicalAnimeProgressRecordsRefs,
            bool animeSourcePlaybackResumesRefs,
            bool episodeUserEditRecordsRefs,
            bool episodeCompletionRecordsRefs,
          })
        > {
  $$CanonicalEpisodeRecordsTableTableManager(
    _$CanonicalDatabase db,
    $CanonicalEpisodeRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CanonicalEpisodeRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CanonicalEpisodeRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CanonicalEpisodeRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> mediaId = const Value.absent(),
                Value<String> rawLabel = const Value.absent(),
                Value<double?> number = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<int?> narrativeSeason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CanonicalEpisodeRecordsCompanion(
                id: id,
                mediaId: mediaId,
                rawLabel: rawLabel,
                number: number,
                title: title,
                narrativeSeason: narrativeSeason,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String mediaId,
                required String rawLabel,
                Value<double?> number = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<int?> narrativeSeason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CanonicalEpisodeRecordsCompanion.insert(
                id: id,
                mediaId: mediaId,
                rawLabel: rawLabel,
                number: number,
                title: title,
                narrativeSeason: narrativeSeason,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CanonicalEpisodeRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                mediaId = false,
                canonicalEpisodeBindingsRefs = false,
                canonicalAnimeProgressRecordsRefs = false,
                animeSourcePlaybackResumesRefs = false,
                episodeUserEditRecordsRefs = false,
                episodeCompletionRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (canonicalEpisodeBindingsRefs)
                      db.canonicalEpisodeBindings,
                    if (canonicalAnimeProgressRecordsRefs)
                      db.canonicalAnimeProgressRecords,
                    if (animeSourcePlaybackResumesRefs)
                      db.animeSourcePlaybackResumes,
                    if (episodeUserEditRecordsRefs) db.episodeUserEditRecords,
                    if (episodeCompletionRecordsRefs)
                      db.episodeCompletionRecords,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (mediaId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.mediaId,
                                    referencedTable:
                                        $$CanonicalEpisodeRecordsTableReferences
                                            ._mediaIdTable(db),
                                    referencedColumn:
                                        $$CanonicalEpisodeRecordsTableReferences
                                            ._mediaIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (canonicalEpisodeBindingsRefs)
                        await $_getPrefetchedData<
                          CanonicalEpisodeRow,
                          $CanonicalEpisodeRecordsTable,
                          EpisodeBindingRow
                        >(
                          currentTable: table,
                          referencedTable:
                              $$CanonicalEpisodeRecordsTableReferences
                                  ._canonicalEpisodeBindingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CanonicalEpisodeRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).canonicalEpisodeBindingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.canonicalId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (canonicalAnimeProgressRecordsRefs)
                        await $_getPrefetchedData<
                          CanonicalEpisodeRow,
                          $CanonicalEpisodeRecordsTable,
                          CanonicalAnimeProgressRow
                        >(
                          currentTable: table,
                          referencedTable:
                              $$CanonicalEpisodeRecordsTableReferences
                                  ._canonicalAnimeProgressRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CanonicalEpisodeRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).canonicalAnimeProgressRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.episodeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (animeSourcePlaybackResumesRefs)
                        await $_getPrefetchedData<
                          CanonicalEpisodeRow,
                          $CanonicalEpisodeRecordsTable,
                          AnimeSourcePlaybackResumeRow
                        >(
                          currentTable: table,
                          referencedTable:
                              $$CanonicalEpisodeRecordsTableReferences
                                  ._animeSourcePlaybackResumesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CanonicalEpisodeRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).animeSourcePlaybackResumesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.episodeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (episodeUserEditRecordsRefs)
                        await $_getPrefetchedData<
                          CanonicalEpisodeRow,
                          $CanonicalEpisodeRecordsTable,
                          EpisodeUserEditRow
                        >(
                          currentTable: table,
                          referencedTable:
                              $$CanonicalEpisodeRecordsTableReferences
                                  ._episodeUserEditRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CanonicalEpisodeRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).episodeUserEditRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.episodeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (episodeCompletionRecordsRefs)
                        await $_getPrefetchedData<
                          CanonicalEpisodeRow,
                          $CanonicalEpisodeRecordsTable,
                          EpisodeCompletionRow
                        >(
                          currentTable: table,
                          referencedTable:
                              $$CanonicalEpisodeRecordsTableReferences
                                  ._episodeCompletionRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CanonicalEpisodeRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).episodeCompletionRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.episodeId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CanonicalEpisodeRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$CanonicalDatabase,
      $CanonicalEpisodeRecordsTable,
      CanonicalEpisodeRow,
      $$CanonicalEpisodeRecordsTableFilterComposer,
      $$CanonicalEpisodeRecordsTableOrderingComposer,
      $$CanonicalEpisodeRecordsTableAnnotationComposer,
      $$CanonicalEpisodeRecordsTableCreateCompanionBuilder,
      $$CanonicalEpisodeRecordsTableUpdateCompanionBuilder,
      (CanonicalEpisodeRow, $$CanonicalEpisodeRecordsTableReferences),
      CanonicalEpisodeRow,
      PrefetchHooks Function({
        bool mediaId,
        bool canonicalEpisodeBindingsRefs,
        bool canonicalAnimeProgressRecordsRefs,
        bool animeSourcePlaybackResumesRefs,
        bool episodeUserEditRecordsRefs,
        bool episodeCompletionRecordsRefs,
      })
    >;
typedef $$CanonicalMediaBindingsTableCreateCompanionBuilder =
    CanonicalMediaBindingsCompanion Function({
      required String canonicalId,
      required String providerId,
      required String externalId,
      Value<String?> relativeLocator,
      Value<String> rawMetadataJson,
      Value<int> rowid,
    });
typedef $$CanonicalMediaBindingsTableUpdateCompanionBuilder =
    CanonicalMediaBindingsCompanion Function({
      Value<String> canonicalId,
      Value<String> providerId,
      Value<String> externalId,
      Value<String?> relativeLocator,
      Value<String> rawMetadataJson,
      Value<int> rowid,
    });

final class $$CanonicalMediaBindingsTableReferences
    extends
        BaseReferences<
          _$CanonicalDatabase,
          $CanonicalMediaBindingsTable,
          MediaBindingRow
        > {
  $$CanonicalMediaBindingsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CanonicalMediaRecordsTable _canonicalIdTable(
    _$CanonicalDatabase db,
  ) => db.canonicalMediaRecords.createAlias(
    $_aliasNameGenerator(
      db.canonicalMediaBindings.canonicalId,
      db.canonicalMediaRecords.id,
    ),
  );

  $$CanonicalMediaRecordsTableProcessedTableManager get canonicalId {
    final $_column = $_itemColumn<String>('canonical_id')!;

    final manager = $$CanonicalMediaRecordsTableTableManager(
      $_db,
      $_db.canonicalMediaRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_canonicalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CanonicalMediaBindingsTableFilterComposer
    extends Composer<_$CanonicalDatabase, $CanonicalMediaBindingsTable> {
  $$CanonicalMediaBindingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relativeLocator => $composableBuilder(
    column: $table.relativeLocator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawMetadataJson => $composableBuilder(
    column: $table.rawMetadataJson,
    builder: (column) => ColumnFilters(column),
  );

  $$CanonicalMediaRecordsTableFilterComposer get canonicalId {
    final $$CanonicalMediaRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.canonicalId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableFilterComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CanonicalMediaBindingsTableOrderingComposer
    extends Composer<_$CanonicalDatabase, $CanonicalMediaBindingsTable> {
  $$CanonicalMediaBindingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relativeLocator => $composableBuilder(
    column: $table.relativeLocator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawMetadataJson => $composableBuilder(
    column: $table.rawMetadataJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$CanonicalMediaRecordsTableOrderingComposer get canonicalId {
    final $$CanonicalMediaRecordsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.canonicalId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableOrderingComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CanonicalMediaBindingsTableAnnotationComposer
    extends Composer<_$CanonicalDatabase, $CanonicalMediaBindingsTable> {
  $$CanonicalMediaBindingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get relativeLocator => $composableBuilder(
    column: $table.relativeLocator,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawMetadataJson => $composableBuilder(
    column: $table.rawMetadataJson,
    builder: (column) => column,
  );

  $$CanonicalMediaRecordsTableAnnotationComposer get canonicalId {
    final $$CanonicalMediaRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.canonicalId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CanonicalMediaBindingsTableTableManager
    extends
        RootTableManager<
          _$CanonicalDatabase,
          $CanonicalMediaBindingsTable,
          MediaBindingRow,
          $$CanonicalMediaBindingsTableFilterComposer,
          $$CanonicalMediaBindingsTableOrderingComposer,
          $$CanonicalMediaBindingsTableAnnotationComposer,
          $$CanonicalMediaBindingsTableCreateCompanionBuilder,
          $$CanonicalMediaBindingsTableUpdateCompanionBuilder,
          (MediaBindingRow, $$CanonicalMediaBindingsTableReferences),
          MediaBindingRow,
          PrefetchHooks Function({bool canonicalId})
        > {
  $$CanonicalMediaBindingsTableTableManager(
    _$CanonicalDatabase db,
    $CanonicalMediaBindingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CanonicalMediaBindingsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CanonicalMediaBindingsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CanonicalMediaBindingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> canonicalId = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> externalId = const Value.absent(),
                Value<String?> relativeLocator = const Value.absent(),
                Value<String> rawMetadataJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CanonicalMediaBindingsCompanion(
                canonicalId: canonicalId,
                providerId: providerId,
                externalId: externalId,
                relativeLocator: relativeLocator,
                rawMetadataJson: rawMetadataJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String canonicalId,
                required String providerId,
                required String externalId,
                Value<String?> relativeLocator = const Value.absent(),
                Value<String> rawMetadataJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CanonicalMediaBindingsCompanion.insert(
                canonicalId: canonicalId,
                providerId: providerId,
                externalId: externalId,
                relativeLocator: relativeLocator,
                rawMetadataJson: rawMetadataJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CanonicalMediaBindingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({canonicalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (canonicalId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.canonicalId,
                                referencedTable:
                                    $$CanonicalMediaBindingsTableReferences
                                        ._canonicalIdTable(db),
                                referencedColumn:
                                    $$CanonicalMediaBindingsTableReferences
                                        ._canonicalIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CanonicalMediaBindingsTableProcessedTableManager =
    ProcessedTableManager<
      _$CanonicalDatabase,
      $CanonicalMediaBindingsTable,
      MediaBindingRow,
      $$CanonicalMediaBindingsTableFilterComposer,
      $$CanonicalMediaBindingsTableOrderingComposer,
      $$CanonicalMediaBindingsTableAnnotationComposer,
      $$CanonicalMediaBindingsTableCreateCompanionBuilder,
      $$CanonicalMediaBindingsTableUpdateCompanionBuilder,
      (MediaBindingRow, $$CanonicalMediaBindingsTableReferences),
      MediaBindingRow,
      PrefetchHooks Function({bool canonicalId})
    >;
typedef $$CanonicalChapterBindingsTableCreateCompanionBuilder =
    CanonicalChapterBindingsCompanion Function({
      required String canonicalId,
      required String providerId,
      required String externalId,
      Value<String?> relativeLocator,
      Value<String> rawMetadataJson,
      Value<int> rowid,
    });
typedef $$CanonicalChapterBindingsTableUpdateCompanionBuilder =
    CanonicalChapterBindingsCompanion Function({
      Value<String> canonicalId,
      Value<String> providerId,
      Value<String> externalId,
      Value<String?> relativeLocator,
      Value<String> rawMetadataJson,
      Value<int> rowid,
    });

final class $$CanonicalChapterBindingsTableReferences
    extends
        BaseReferences<
          _$CanonicalDatabase,
          $CanonicalChapterBindingsTable,
          ChapterBindingRow
        > {
  $$CanonicalChapterBindingsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CanonicalChapterRecordsTable _canonicalIdTable(
    _$CanonicalDatabase db,
  ) => db.canonicalChapterRecords.createAlias(
    $_aliasNameGenerator(
      db.canonicalChapterBindings.canonicalId,
      db.canonicalChapterRecords.id,
    ),
  );

  $$CanonicalChapterRecordsTableProcessedTableManager get canonicalId {
    final $_column = $_itemColumn<String>('canonical_id')!;

    final manager = $$CanonicalChapterRecordsTableTableManager(
      $_db,
      $_db.canonicalChapterRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_canonicalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CanonicalChapterBindingsTableFilterComposer
    extends Composer<_$CanonicalDatabase, $CanonicalChapterBindingsTable> {
  $$CanonicalChapterBindingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relativeLocator => $composableBuilder(
    column: $table.relativeLocator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawMetadataJson => $composableBuilder(
    column: $table.rawMetadataJson,
    builder: (column) => ColumnFilters(column),
  );

  $$CanonicalChapterRecordsTableFilterComposer get canonicalId {
    final $$CanonicalChapterRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.canonicalId,
          referencedTable: $db.canonicalChapterRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalChapterRecordsTableFilterComposer(
                $db: $db,
                $table: $db.canonicalChapterRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CanonicalChapterBindingsTableOrderingComposer
    extends Composer<_$CanonicalDatabase, $CanonicalChapterBindingsTable> {
  $$CanonicalChapterBindingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relativeLocator => $composableBuilder(
    column: $table.relativeLocator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawMetadataJson => $composableBuilder(
    column: $table.rawMetadataJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$CanonicalChapterRecordsTableOrderingComposer get canonicalId {
    final $$CanonicalChapterRecordsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.canonicalId,
          referencedTable: $db.canonicalChapterRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalChapterRecordsTableOrderingComposer(
                $db: $db,
                $table: $db.canonicalChapterRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CanonicalChapterBindingsTableAnnotationComposer
    extends Composer<_$CanonicalDatabase, $CanonicalChapterBindingsTable> {
  $$CanonicalChapterBindingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get relativeLocator => $composableBuilder(
    column: $table.relativeLocator,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawMetadataJson => $composableBuilder(
    column: $table.rawMetadataJson,
    builder: (column) => column,
  );

  $$CanonicalChapterRecordsTableAnnotationComposer get canonicalId {
    final $$CanonicalChapterRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.canonicalId,
          referencedTable: $db.canonicalChapterRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalChapterRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.canonicalChapterRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CanonicalChapterBindingsTableTableManager
    extends
        RootTableManager<
          _$CanonicalDatabase,
          $CanonicalChapterBindingsTable,
          ChapterBindingRow,
          $$CanonicalChapterBindingsTableFilterComposer,
          $$CanonicalChapterBindingsTableOrderingComposer,
          $$CanonicalChapterBindingsTableAnnotationComposer,
          $$CanonicalChapterBindingsTableCreateCompanionBuilder,
          $$CanonicalChapterBindingsTableUpdateCompanionBuilder,
          (ChapterBindingRow, $$CanonicalChapterBindingsTableReferences),
          ChapterBindingRow,
          PrefetchHooks Function({bool canonicalId})
        > {
  $$CanonicalChapterBindingsTableTableManager(
    _$CanonicalDatabase db,
    $CanonicalChapterBindingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CanonicalChapterBindingsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CanonicalChapterBindingsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CanonicalChapterBindingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> canonicalId = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> externalId = const Value.absent(),
                Value<String?> relativeLocator = const Value.absent(),
                Value<String> rawMetadataJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CanonicalChapterBindingsCompanion(
                canonicalId: canonicalId,
                providerId: providerId,
                externalId: externalId,
                relativeLocator: relativeLocator,
                rawMetadataJson: rawMetadataJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String canonicalId,
                required String providerId,
                required String externalId,
                Value<String?> relativeLocator = const Value.absent(),
                Value<String> rawMetadataJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CanonicalChapterBindingsCompanion.insert(
                canonicalId: canonicalId,
                providerId: providerId,
                externalId: externalId,
                relativeLocator: relativeLocator,
                rawMetadataJson: rawMetadataJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CanonicalChapterBindingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({canonicalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (canonicalId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.canonicalId,
                                referencedTable:
                                    $$CanonicalChapterBindingsTableReferences
                                        ._canonicalIdTable(db),
                                referencedColumn:
                                    $$CanonicalChapterBindingsTableReferences
                                        ._canonicalIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CanonicalChapterBindingsTableProcessedTableManager =
    ProcessedTableManager<
      _$CanonicalDatabase,
      $CanonicalChapterBindingsTable,
      ChapterBindingRow,
      $$CanonicalChapterBindingsTableFilterComposer,
      $$CanonicalChapterBindingsTableOrderingComposer,
      $$CanonicalChapterBindingsTableAnnotationComposer,
      $$CanonicalChapterBindingsTableCreateCompanionBuilder,
      $$CanonicalChapterBindingsTableUpdateCompanionBuilder,
      (ChapterBindingRow, $$CanonicalChapterBindingsTableReferences),
      ChapterBindingRow,
      PrefetchHooks Function({bool canonicalId})
    >;
typedef $$CanonicalEpisodeBindingsTableCreateCompanionBuilder =
    CanonicalEpisodeBindingsCompanion Function({
      required String canonicalId,
      required String providerId,
      required String externalId,
      Value<String?> relativeLocator,
      Value<String> rawMetadataJson,
      Value<int> rowid,
    });
typedef $$CanonicalEpisodeBindingsTableUpdateCompanionBuilder =
    CanonicalEpisodeBindingsCompanion Function({
      Value<String> canonicalId,
      Value<String> providerId,
      Value<String> externalId,
      Value<String?> relativeLocator,
      Value<String> rawMetadataJson,
      Value<int> rowid,
    });

final class $$CanonicalEpisodeBindingsTableReferences
    extends
        BaseReferences<
          _$CanonicalDatabase,
          $CanonicalEpisodeBindingsTable,
          EpisodeBindingRow
        > {
  $$CanonicalEpisodeBindingsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CanonicalEpisodeRecordsTable _canonicalIdTable(
    _$CanonicalDatabase db,
  ) => db.canonicalEpisodeRecords.createAlias(
    $_aliasNameGenerator(
      db.canonicalEpisodeBindings.canonicalId,
      db.canonicalEpisodeRecords.id,
    ),
  );

  $$CanonicalEpisodeRecordsTableProcessedTableManager get canonicalId {
    final $_column = $_itemColumn<String>('canonical_id')!;

    final manager = $$CanonicalEpisodeRecordsTableTableManager(
      $_db,
      $_db.canonicalEpisodeRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_canonicalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CanonicalEpisodeBindingsTableFilterComposer
    extends Composer<_$CanonicalDatabase, $CanonicalEpisodeBindingsTable> {
  $$CanonicalEpisodeBindingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relativeLocator => $composableBuilder(
    column: $table.relativeLocator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawMetadataJson => $composableBuilder(
    column: $table.rawMetadataJson,
    builder: (column) => ColumnFilters(column),
  );

  $$CanonicalEpisodeRecordsTableFilterComposer get canonicalId {
    final $$CanonicalEpisodeRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.canonicalId,
          referencedTable: $db.canonicalEpisodeRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalEpisodeRecordsTableFilterComposer(
                $db: $db,
                $table: $db.canonicalEpisodeRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CanonicalEpisodeBindingsTableOrderingComposer
    extends Composer<_$CanonicalDatabase, $CanonicalEpisodeBindingsTable> {
  $$CanonicalEpisodeBindingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relativeLocator => $composableBuilder(
    column: $table.relativeLocator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawMetadataJson => $composableBuilder(
    column: $table.rawMetadataJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$CanonicalEpisodeRecordsTableOrderingComposer get canonicalId {
    final $$CanonicalEpisodeRecordsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.canonicalId,
          referencedTable: $db.canonicalEpisodeRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalEpisodeRecordsTableOrderingComposer(
                $db: $db,
                $table: $db.canonicalEpisodeRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CanonicalEpisodeBindingsTableAnnotationComposer
    extends Composer<_$CanonicalDatabase, $CanonicalEpisodeBindingsTable> {
  $$CanonicalEpisodeBindingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get relativeLocator => $composableBuilder(
    column: $table.relativeLocator,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawMetadataJson => $composableBuilder(
    column: $table.rawMetadataJson,
    builder: (column) => column,
  );

  $$CanonicalEpisodeRecordsTableAnnotationComposer get canonicalId {
    final $$CanonicalEpisodeRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.canonicalId,
          referencedTable: $db.canonicalEpisodeRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalEpisodeRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.canonicalEpisodeRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CanonicalEpisodeBindingsTableTableManager
    extends
        RootTableManager<
          _$CanonicalDatabase,
          $CanonicalEpisodeBindingsTable,
          EpisodeBindingRow,
          $$CanonicalEpisodeBindingsTableFilterComposer,
          $$CanonicalEpisodeBindingsTableOrderingComposer,
          $$CanonicalEpisodeBindingsTableAnnotationComposer,
          $$CanonicalEpisodeBindingsTableCreateCompanionBuilder,
          $$CanonicalEpisodeBindingsTableUpdateCompanionBuilder,
          (EpisodeBindingRow, $$CanonicalEpisodeBindingsTableReferences),
          EpisodeBindingRow,
          PrefetchHooks Function({bool canonicalId})
        > {
  $$CanonicalEpisodeBindingsTableTableManager(
    _$CanonicalDatabase db,
    $CanonicalEpisodeBindingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CanonicalEpisodeBindingsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CanonicalEpisodeBindingsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CanonicalEpisodeBindingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> canonicalId = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> externalId = const Value.absent(),
                Value<String?> relativeLocator = const Value.absent(),
                Value<String> rawMetadataJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CanonicalEpisodeBindingsCompanion(
                canonicalId: canonicalId,
                providerId: providerId,
                externalId: externalId,
                relativeLocator: relativeLocator,
                rawMetadataJson: rawMetadataJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String canonicalId,
                required String providerId,
                required String externalId,
                Value<String?> relativeLocator = const Value.absent(),
                Value<String> rawMetadataJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CanonicalEpisodeBindingsCompanion.insert(
                canonicalId: canonicalId,
                providerId: providerId,
                externalId: externalId,
                relativeLocator: relativeLocator,
                rawMetadataJson: rawMetadataJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CanonicalEpisodeBindingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({canonicalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (canonicalId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.canonicalId,
                                referencedTable:
                                    $$CanonicalEpisodeBindingsTableReferences
                                        ._canonicalIdTable(db),
                                referencedColumn:
                                    $$CanonicalEpisodeBindingsTableReferences
                                        ._canonicalIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CanonicalEpisodeBindingsTableProcessedTableManager =
    ProcessedTableManager<
      _$CanonicalDatabase,
      $CanonicalEpisodeBindingsTable,
      EpisodeBindingRow,
      $$CanonicalEpisodeBindingsTableFilterComposer,
      $$CanonicalEpisodeBindingsTableOrderingComposer,
      $$CanonicalEpisodeBindingsTableAnnotationComposer,
      $$CanonicalEpisodeBindingsTableCreateCompanionBuilder,
      $$CanonicalEpisodeBindingsTableUpdateCompanionBuilder,
      (EpisodeBindingRow, $$CanonicalEpisodeBindingsTableReferences),
      EpisodeBindingRow,
      PrefetchHooks Function({bool canonicalId})
    >;
typedef $$CanonicalLibraryRecordsTableCreateCompanionBuilder =
    CanonicalLibraryRecordsCompanion Function({
      required String mediaId,
      required bool isSaved,
      required bool isFavorite,
      required String status,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CanonicalLibraryRecordsTableUpdateCompanionBuilder =
    CanonicalLibraryRecordsCompanion Function({
      Value<String> mediaId,
      Value<bool> isSaved,
      Value<bool> isFavorite,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$CanonicalLibraryRecordsTableReferences
    extends
        BaseReferences<
          _$CanonicalDatabase,
          $CanonicalLibraryRecordsTable,
          CanonicalLibraryRow
        > {
  $$CanonicalLibraryRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CanonicalMediaRecordsTable _mediaIdTable(_$CanonicalDatabase db) =>
      db.canonicalMediaRecords.createAlias(
        $_aliasNameGenerator(
          db.canonicalLibraryRecords.mediaId,
          db.canonicalMediaRecords.id,
        ),
      );

  $$CanonicalMediaRecordsTableProcessedTableManager get mediaId {
    final $_column = $_itemColumn<String>('media_id')!;

    final manager = $$CanonicalMediaRecordsTableTableManager(
      $_db,
      $_db.canonicalMediaRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mediaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CanonicalLibraryRecordsTableFilterComposer
    extends Composer<_$CanonicalDatabase, $CanonicalLibraryRecordsTable> {
  $$CanonicalLibraryRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get isSaved => $composableBuilder(
    column: $table.isSaved,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CanonicalMediaRecordsTableFilterComposer get mediaId {
    final $$CanonicalMediaRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mediaId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableFilterComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CanonicalLibraryRecordsTableOrderingComposer
    extends Composer<_$CanonicalDatabase, $CanonicalLibraryRecordsTable> {
  $$CanonicalLibraryRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get isSaved => $composableBuilder(
    column: $table.isSaved,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CanonicalMediaRecordsTableOrderingComposer get mediaId {
    final $$CanonicalMediaRecordsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mediaId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableOrderingComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CanonicalLibraryRecordsTableAnnotationComposer
    extends Composer<_$CanonicalDatabase, $CanonicalLibraryRecordsTable> {
  $$CanonicalLibraryRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get isSaved =>
      $composableBuilder(column: $table.isSaved, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CanonicalMediaRecordsTableAnnotationComposer get mediaId {
    final $$CanonicalMediaRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mediaId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CanonicalLibraryRecordsTableTableManager
    extends
        RootTableManager<
          _$CanonicalDatabase,
          $CanonicalLibraryRecordsTable,
          CanonicalLibraryRow,
          $$CanonicalLibraryRecordsTableFilterComposer,
          $$CanonicalLibraryRecordsTableOrderingComposer,
          $$CanonicalLibraryRecordsTableAnnotationComposer,
          $$CanonicalLibraryRecordsTableCreateCompanionBuilder,
          $$CanonicalLibraryRecordsTableUpdateCompanionBuilder,
          (CanonicalLibraryRow, $$CanonicalLibraryRecordsTableReferences),
          CanonicalLibraryRow,
          PrefetchHooks Function({bool mediaId})
        > {
  $$CanonicalLibraryRecordsTableTableManager(
    _$CanonicalDatabase db,
    $CanonicalLibraryRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CanonicalLibraryRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CanonicalLibraryRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CanonicalLibraryRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> mediaId = const Value.absent(),
                Value<bool> isSaved = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CanonicalLibraryRecordsCompanion(
                mediaId: mediaId,
                isSaved: isSaved,
                isFavorite: isFavorite,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String mediaId,
                required bool isSaved,
                required bool isFavorite,
                required String status,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CanonicalLibraryRecordsCompanion.insert(
                mediaId: mediaId,
                isSaved: isSaved,
                isFavorite: isFavorite,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CanonicalLibraryRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({mediaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (mediaId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.mediaId,
                                referencedTable:
                                    $$CanonicalLibraryRecordsTableReferences
                                        ._mediaIdTable(db),
                                referencedColumn:
                                    $$CanonicalLibraryRecordsTableReferences
                                        ._mediaIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CanonicalLibraryRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$CanonicalDatabase,
      $CanonicalLibraryRecordsTable,
      CanonicalLibraryRow,
      $$CanonicalLibraryRecordsTableFilterComposer,
      $$CanonicalLibraryRecordsTableOrderingComposer,
      $$CanonicalLibraryRecordsTableAnnotationComposer,
      $$CanonicalLibraryRecordsTableCreateCompanionBuilder,
      $$CanonicalLibraryRecordsTableUpdateCompanionBuilder,
      (CanonicalLibraryRow, $$CanonicalLibraryRecordsTableReferences),
      CanonicalLibraryRow,
      PrefetchHooks Function({bool mediaId})
    >;
typedef $$CanonicalMangaProgressRecordsTableCreateCompanionBuilder =
    CanonicalMangaProgressRecordsCompanion Function({
      required String mediaId,
      required String chapterId,
      required int pageIndex,
      Value<int?> totalPages,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CanonicalMangaProgressRecordsTableUpdateCompanionBuilder =
    CanonicalMangaProgressRecordsCompanion Function({
      Value<String> mediaId,
      Value<String> chapterId,
      Value<int> pageIndex,
      Value<int?> totalPages,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$CanonicalMangaProgressRecordsTableReferences
    extends
        BaseReferences<
          _$CanonicalDatabase,
          $CanonicalMangaProgressRecordsTable,
          CanonicalMangaProgressRow
        > {
  $$CanonicalMangaProgressRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CanonicalMediaRecordsTable _mediaIdTable(_$CanonicalDatabase db) =>
      db.canonicalMediaRecords.createAlias(
        $_aliasNameGenerator(
          db.canonicalMangaProgressRecords.mediaId,
          db.canonicalMediaRecords.id,
        ),
      );

  $$CanonicalMediaRecordsTableProcessedTableManager get mediaId {
    final $_column = $_itemColumn<String>('media_id')!;

    final manager = $$CanonicalMediaRecordsTableTableManager(
      $_db,
      $_db.canonicalMediaRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mediaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CanonicalChapterRecordsTable _chapterIdTable(
    _$CanonicalDatabase db,
  ) => db.canonicalChapterRecords.createAlias(
    $_aliasNameGenerator(
      db.canonicalMangaProgressRecords.chapterId,
      db.canonicalChapterRecords.id,
    ),
  );

  $$CanonicalChapterRecordsTableProcessedTableManager get chapterId {
    final $_column = $_itemColumn<String>('chapter_id')!;

    final manager = $$CanonicalChapterRecordsTableTableManager(
      $_db,
      $_db.canonicalChapterRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chapterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CanonicalMangaProgressRecordsTableFilterComposer
    extends Composer<_$CanonicalDatabase, $CanonicalMangaProgressRecordsTable> {
  $$CanonicalMangaProgressRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get pageIndex => $composableBuilder(
    column: $table.pageIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CanonicalMediaRecordsTableFilterComposer get mediaId {
    final $$CanonicalMediaRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mediaId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableFilterComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CanonicalChapterRecordsTableFilterComposer get chapterId {
    final $$CanonicalChapterRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.chapterId,
          referencedTable: $db.canonicalChapterRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalChapterRecordsTableFilterComposer(
                $db: $db,
                $table: $db.canonicalChapterRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CanonicalMangaProgressRecordsTableOrderingComposer
    extends Composer<_$CanonicalDatabase, $CanonicalMangaProgressRecordsTable> {
  $$CanonicalMangaProgressRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get pageIndex => $composableBuilder(
    column: $table.pageIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CanonicalMediaRecordsTableOrderingComposer get mediaId {
    final $$CanonicalMediaRecordsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mediaId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableOrderingComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CanonicalChapterRecordsTableOrderingComposer get chapterId {
    final $$CanonicalChapterRecordsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.chapterId,
          referencedTable: $db.canonicalChapterRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalChapterRecordsTableOrderingComposer(
                $db: $db,
                $table: $db.canonicalChapterRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CanonicalMangaProgressRecordsTableAnnotationComposer
    extends Composer<_$CanonicalDatabase, $CanonicalMangaProgressRecordsTable> {
  $$CanonicalMangaProgressRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get pageIndex =>
      $composableBuilder(column: $table.pageIndex, builder: (column) => column);

  GeneratedColumn<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CanonicalMediaRecordsTableAnnotationComposer get mediaId {
    final $$CanonicalMediaRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mediaId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CanonicalChapterRecordsTableAnnotationComposer get chapterId {
    final $$CanonicalChapterRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.chapterId,
          referencedTable: $db.canonicalChapterRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalChapterRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.canonicalChapterRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CanonicalMangaProgressRecordsTableTableManager
    extends
        RootTableManager<
          _$CanonicalDatabase,
          $CanonicalMangaProgressRecordsTable,
          CanonicalMangaProgressRow,
          $$CanonicalMangaProgressRecordsTableFilterComposer,
          $$CanonicalMangaProgressRecordsTableOrderingComposer,
          $$CanonicalMangaProgressRecordsTableAnnotationComposer,
          $$CanonicalMangaProgressRecordsTableCreateCompanionBuilder,
          $$CanonicalMangaProgressRecordsTableUpdateCompanionBuilder,
          (
            CanonicalMangaProgressRow,
            $$CanonicalMangaProgressRecordsTableReferences,
          ),
          CanonicalMangaProgressRow,
          PrefetchHooks Function({bool mediaId, bool chapterId})
        > {
  $$CanonicalMangaProgressRecordsTableTableManager(
    _$CanonicalDatabase db,
    $CanonicalMangaProgressRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CanonicalMangaProgressRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CanonicalMangaProgressRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CanonicalMangaProgressRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> mediaId = const Value.absent(),
                Value<String> chapterId = const Value.absent(),
                Value<int> pageIndex = const Value.absent(),
                Value<int?> totalPages = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CanonicalMangaProgressRecordsCompanion(
                mediaId: mediaId,
                chapterId: chapterId,
                pageIndex: pageIndex,
                totalPages: totalPages,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String mediaId,
                required String chapterId,
                required int pageIndex,
                Value<int?> totalPages = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CanonicalMangaProgressRecordsCompanion.insert(
                mediaId: mediaId,
                chapterId: chapterId,
                pageIndex: pageIndex,
                totalPages: totalPages,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CanonicalMangaProgressRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({mediaId = false, chapterId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (mediaId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.mediaId,
                                referencedTable:
                                    $$CanonicalMangaProgressRecordsTableReferences
                                        ._mediaIdTable(db),
                                referencedColumn:
                                    $$CanonicalMangaProgressRecordsTableReferences
                                        ._mediaIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (chapterId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.chapterId,
                                referencedTable:
                                    $$CanonicalMangaProgressRecordsTableReferences
                                        ._chapterIdTable(db),
                                referencedColumn:
                                    $$CanonicalMangaProgressRecordsTableReferences
                                        ._chapterIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CanonicalMangaProgressRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$CanonicalDatabase,
      $CanonicalMangaProgressRecordsTable,
      CanonicalMangaProgressRow,
      $$CanonicalMangaProgressRecordsTableFilterComposer,
      $$CanonicalMangaProgressRecordsTableOrderingComposer,
      $$CanonicalMangaProgressRecordsTableAnnotationComposer,
      $$CanonicalMangaProgressRecordsTableCreateCompanionBuilder,
      $$CanonicalMangaProgressRecordsTableUpdateCompanionBuilder,
      (
        CanonicalMangaProgressRow,
        $$CanonicalMangaProgressRecordsTableReferences,
      ),
      CanonicalMangaProgressRow,
      PrefetchHooks Function({bool mediaId, bool chapterId})
    >;
typedef $$CanonicalAnimeProgressRecordsTableCreateCompanionBuilder =
    CanonicalAnimeProgressRecordsCompanion Function({
      required String mediaId,
      required String episodeId,
      required int positionMilliseconds,
      Value<int?> durationMilliseconds,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CanonicalAnimeProgressRecordsTableUpdateCompanionBuilder =
    CanonicalAnimeProgressRecordsCompanion Function({
      Value<String> mediaId,
      Value<String> episodeId,
      Value<int> positionMilliseconds,
      Value<int?> durationMilliseconds,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$CanonicalAnimeProgressRecordsTableReferences
    extends
        BaseReferences<
          _$CanonicalDatabase,
          $CanonicalAnimeProgressRecordsTable,
          CanonicalAnimeProgressRow
        > {
  $$CanonicalAnimeProgressRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CanonicalMediaRecordsTable _mediaIdTable(_$CanonicalDatabase db) =>
      db.canonicalMediaRecords.createAlias(
        $_aliasNameGenerator(
          db.canonicalAnimeProgressRecords.mediaId,
          db.canonicalMediaRecords.id,
        ),
      );

  $$CanonicalMediaRecordsTableProcessedTableManager get mediaId {
    final $_column = $_itemColumn<String>('media_id')!;

    final manager = $$CanonicalMediaRecordsTableTableManager(
      $_db,
      $_db.canonicalMediaRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mediaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CanonicalEpisodeRecordsTable _episodeIdTable(
    _$CanonicalDatabase db,
  ) => db.canonicalEpisodeRecords.createAlias(
    $_aliasNameGenerator(
      db.canonicalAnimeProgressRecords.episodeId,
      db.canonicalEpisodeRecords.id,
    ),
  );

  $$CanonicalEpisodeRecordsTableProcessedTableManager get episodeId {
    final $_column = $_itemColumn<String>('episode_id')!;

    final manager = $$CanonicalEpisodeRecordsTableTableManager(
      $_db,
      $_db.canonicalEpisodeRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_episodeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CanonicalAnimeProgressRecordsTableFilterComposer
    extends Composer<_$CanonicalDatabase, $CanonicalAnimeProgressRecordsTable> {
  $$CanonicalAnimeProgressRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get positionMilliseconds => $composableBuilder(
    column: $table.positionMilliseconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMilliseconds => $composableBuilder(
    column: $table.durationMilliseconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CanonicalMediaRecordsTableFilterComposer get mediaId {
    final $$CanonicalMediaRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mediaId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableFilterComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CanonicalEpisodeRecordsTableFilterComposer get episodeId {
    final $$CanonicalEpisodeRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.episodeId,
          referencedTable: $db.canonicalEpisodeRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalEpisodeRecordsTableFilterComposer(
                $db: $db,
                $table: $db.canonicalEpisodeRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CanonicalAnimeProgressRecordsTableOrderingComposer
    extends Composer<_$CanonicalDatabase, $CanonicalAnimeProgressRecordsTable> {
  $$CanonicalAnimeProgressRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get positionMilliseconds => $composableBuilder(
    column: $table.positionMilliseconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMilliseconds => $composableBuilder(
    column: $table.durationMilliseconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CanonicalMediaRecordsTableOrderingComposer get mediaId {
    final $$CanonicalMediaRecordsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mediaId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableOrderingComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CanonicalEpisodeRecordsTableOrderingComposer get episodeId {
    final $$CanonicalEpisodeRecordsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.episodeId,
          referencedTable: $db.canonicalEpisodeRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalEpisodeRecordsTableOrderingComposer(
                $db: $db,
                $table: $db.canonicalEpisodeRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CanonicalAnimeProgressRecordsTableAnnotationComposer
    extends Composer<_$CanonicalDatabase, $CanonicalAnimeProgressRecordsTable> {
  $$CanonicalAnimeProgressRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get positionMilliseconds => $composableBuilder(
    column: $table.positionMilliseconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMilliseconds => $composableBuilder(
    column: $table.durationMilliseconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CanonicalMediaRecordsTableAnnotationComposer get mediaId {
    final $$CanonicalMediaRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mediaId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CanonicalEpisodeRecordsTableAnnotationComposer get episodeId {
    final $$CanonicalEpisodeRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.episodeId,
          referencedTable: $db.canonicalEpisodeRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalEpisodeRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.canonicalEpisodeRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CanonicalAnimeProgressRecordsTableTableManager
    extends
        RootTableManager<
          _$CanonicalDatabase,
          $CanonicalAnimeProgressRecordsTable,
          CanonicalAnimeProgressRow,
          $$CanonicalAnimeProgressRecordsTableFilterComposer,
          $$CanonicalAnimeProgressRecordsTableOrderingComposer,
          $$CanonicalAnimeProgressRecordsTableAnnotationComposer,
          $$CanonicalAnimeProgressRecordsTableCreateCompanionBuilder,
          $$CanonicalAnimeProgressRecordsTableUpdateCompanionBuilder,
          (
            CanonicalAnimeProgressRow,
            $$CanonicalAnimeProgressRecordsTableReferences,
          ),
          CanonicalAnimeProgressRow,
          PrefetchHooks Function({bool mediaId, bool episodeId})
        > {
  $$CanonicalAnimeProgressRecordsTableTableManager(
    _$CanonicalDatabase db,
    $CanonicalAnimeProgressRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CanonicalAnimeProgressRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CanonicalAnimeProgressRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CanonicalAnimeProgressRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> mediaId = const Value.absent(),
                Value<String> episodeId = const Value.absent(),
                Value<int> positionMilliseconds = const Value.absent(),
                Value<int?> durationMilliseconds = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CanonicalAnimeProgressRecordsCompanion(
                mediaId: mediaId,
                episodeId: episodeId,
                positionMilliseconds: positionMilliseconds,
                durationMilliseconds: durationMilliseconds,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String mediaId,
                required String episodeId,
                required int positionMilliseconds,
                Value<int?> durationMilliseconds = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CanonicalAnimeProgressRecordsCompanion.insert(
                mediaId: mediaId,
                episodeId: episodeId,
                positionMilliseconds: positionMilliseconds,
                durationMilliseconds: durationMilliseconds,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CanonicalAnimeProgressRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({mediaId = false, episodeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (mediaId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.mediaId,
                                referencedTable:
                                    $$CanonicalAnimeProgressRecordsTableReferences
                                        ._mediaIdTable(db),
                                referencedColumn:
                                    $$CanonicalAnimeProgressRecordsTableReferences
                                        ._mediaIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (episodeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.episodeId,
                                referencedTable:
                                    $$CanonicalAnimeProgressRecordsTableReferences
                                        ._episodeIdTable(db),
                                referencedColumn:
                                    $$CanonicalAnimeProgressRecordsTableReferences
                                        ._episodeIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CanonicalAnimeProgressRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$CanonicalDatabase,
      $CanonicalAnimeProgressRecordsTable,
      CanonicalAnimeProgressRow,
      $$CanonicalAnimeProgressRecordsTableFilterComposer,
      $$CanonicalAnimeProgressRecordsTableOrderingComposer,
      $$CanonicalAnimeProgressRecordsTableAnnotationComposer,
      $$CanonicalAnimeProgressRecordsTableCreateCompanionBuilder,
      $$CanonicalAnimeProgressRecordsTableUpdateCompanionBuilder,
      (
        CanonicalAnimeProgressRow,
        $$CanonicalAnimeProgressRecordsTableReferences,
      ),
      CanonicalAnimeProgressRow,
      PrefetchHooks Function({bool mediaId, bool episodeId})
    >;
typedef $$CanonicalMediaAliasesTableCreateCompanionBuilder =
    CanonicalMediaAliasesCompanion Function({
      required String historicalId,
      required String targetId,
      required String mergeAuditId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CanonicalMediaAliasesTableUpdateCompanionBuilder =
    CanonicalMediaAliasesCompanion Function({
      Value<String> historicalId,
      Value<String> targetId,
      Value<String> mergeAuditId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$CanonicalMediaAliasesTableFilterComposer
    extends Composer<_$CanonicalDatabase, $CanonicalMediaAliasesTable> {
  $$CanonicalMediaAliasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get historicalId => $composableBuilder(
    column: $table.historicalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mergeAuditId => $composableBuilder(
    column: $table.mergeAuditId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CanonicalMediaAliasesTableOrderingComposer
    extends Composer<_$CanonicalDatabase, $CanonicalMediaAliasesTable> {
  $$CanonicalMediaAliasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get historicalId => $composableBuilder(
    column: $table.historicalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mergeAuditId => $composableBuilder(
    column: $table.mergeAuditId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CanonicalMediaAliasesTableAnnotationComposer
    extends Composer<_$CanonicalDatabase, $CanonicalMediaAliasesTable> {
  $$CanonicalMediaAliasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get historicalId => $composableBuilder(
    column: $table.historicalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<String> get mergeAuditId => $composableBuilder(
    column: $table.mergeAuditId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CanonicalMediaAliasesTableTableManager
    extends
        RootTableManager<
          _$CanonicalDatabase,
          $CanonicalMediaAliasesTable,
          CanonicalAliasRow,
          $$CanonicalMediaAliasesTableFilterComposer,
          $$CanonicalMediaAliasesTableOrderingComposer,
          $$CanonicalMediaAliasesTableAnnotationComposer,
          $$CanonicalMediaAliasesTableCreateCompanionBuilder,
          $$CanonicalMediaAliasesTableUpdateCompanionBuilder,
          (
            CanonicalAliasRow,
            BaseReferences<
              _$CanonicalDatabase,
              $CanonicalMediaAliasesTable,
              CanonicalAliasRow
            >,
          ),
          CanonicalAliasRow,
          PrefetchHooks Function()
        > {
  $$CanonicalMediaAliasesTableTableManager(
    _$CanonicalDatabase db,
    $CanonicalMediaAliasesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CanonicalMediaAliasesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CanonicalMediaAliasesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CanonicalMediaAliasesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> historicalId = const Value.absent(),
                Value<String> targetId = const Value.absent(),
                Value<String> mergeAuditId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CanonicalMediaAliasesCompanion(
                historicalId: historicalId,
                targetId: targetId,
                mergeAuditId: mergeAuditId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String historicalId,
                required String targetId,
                required String mergeAuditId,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CanonicalMediaAliasesCompanion.insert(
                historicalId: historicalId,
                targetId: targetId,
                mergeAuditId: mergeAuditId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CanonicalMediaAliasesTableProcessedTableManager =
    ProcessedTableManager<
      _$CanonicalDatabase,
      $CanonicalMediaAliasesTable,
      CanonicalAliasRow,
      $$CanonicalMediaAliasesTableFilterComposer,
      $$CanonicalMediaAliasesTableOrderingComposer,
      $$CanonicalMediaAliasesTableAnnotationComposer,
      $$CanonicalMediaAliasesTableCreateCompanionBuilder,
      $$CanonicalMediaAliasesTableUpdateCompanionBuilder,
      (
        CanonicalAliasRow,
        BaseReferences<
          _$CanonicalDatabase,
          $CanonicalMediaAliasesTable,
          CanonicalAliasRow
        >,
      ),
      CanonicalAliasRow,
      PrefetchHooks Function()
    >;
typedef $$CanonicalMergeAuditsTableCreateCompanionBuilder =
    CanonicalMergeAuditsCompanion Function({
      required String id,
      required String sourceId,
      required String targetId,
      required String reason,
      required String snapshotJson,
      required String mergedFingerprint,
      Value<String> conflictsJson,
      required DateTime createdAt,
      Value<DateTime?> undoneAt,
      Value<int> rowid,
    });
typedef $$CanonicalMergeAuditsTableUpdateCompanionBuilder =
    CanonicalMergeAuditsCompanion Function({
      Value<String> id,
      Value<String> sourceId,
      Value<String> targetId,
      Value<String> reason,
      Value<String> snapshotJson,
      Value<String> mergedFingerprint,
      Value<String> conflictsJson,
      Value<DateTime> createdAt,
      Value<DateTime?> undoneAt,
      Value<int> rowid,
    });

class $$CanonicalMergeAuditsTableFilterComposer
    extends Composer<_$CanonicalDatabase, $CanonicalMergeAuditsTable> {
  $$CanonicalMergeAuditsTableFilterComposer({
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

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get snapshotJson => $composableBuilder(
    column: $table.snapshotJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mergedFingerprint => $composableBuilder(
    column: $table.mergedFingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conflictsJson => $composableBuilder(
    column: $table.conflictsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get undoneAt => $composableBuilder(
    column: $table.undoneAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CanonicalMergeAuditsTableOrderingComposer
    extends Composer<_$CanonicalDatabase, $CanonicalMergeAuditsTable> {
  $$CanonicalMergeAuditsTableOrderingComposer({
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

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snapshotJson => $composableBuilder(
    column: $table.snapshotJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mergedFingerprint => $composableBuilder(
    column: $table.mergedFingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conflictsJson => $composableBuilder(
    column: $table.conflictsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get undoneAt => $composableBuilder(
    column: $table.undoneAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CanonicalMergeAuditsTableAnnotationComposer
    extends Composer<_$CanonicalDatabase, $CanonicalMergeAuditsTable> {
  $$CanonicalMergeAuditsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get snapshotJson => $composableBuilder(
    column: $table.snapshotJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mergedFingerprint => $composableBuilder(
    column: $table.mergedFingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get conflictsJson => $composableBuilder(
    column: $table.conflictsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get undoneAt =>
      $composableBuilder(column: $table.undoneAt, builder: (column) => column);
}

class $$CanonicalMergeAuditsTableTableManager
    extends
        RootTableManager<
          _$CanonicalDatabase,
          $CanonicalMergeAuditsTable,
          MergeAuditRow,
          $$CanonicalMergeAuditsTableFilterComposer,
          $$CanonicalMergeAuditsTableOrderingComposer,
          $$CanonicalMergeAuditsTableAnnotationComposer,
          $$CanonicalMergeAuditsTableCreateCompanionBuilder,
          $$CanonicalMergeAuditsTableUpdateCompanionBuilder,
          (
            MergeAuditRow,
            BaseReferences<
              _$CanonicalDatabase,
              $CanonicalMergeAuditsTable,
              MergeAuditRow
            >,
          ),
          MergeAuditRow,
          PrefetchHooks Function()
        > {
  $$CanonicalMergeAuditsTableTableManager(
    _$CanonicalDatabase db,
    $CanonicalMergeAuditsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CanonicalMergeAuditsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CanonicalMergeAuditsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CanonicalMergeAuditsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String> targetId = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String> snapshotJson = const Value.absent(),
                Value<String> mergedFingerprint = const Value.absent(),
                Value<String> conflictsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> undoneAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CanonicalMergeAuditsCompanion(
                id: id,
                sourceId: sourceId,
                targetId: targetId,
                reason: reason,
                snapshotJson: snapshotJson,
                mergedFingerprint: mergedFingerprint,
                conflictsJson: conflictsJson,
                createdAt: createdAt,
                undoneAt: undoneAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sourceId,
                required String targetId,
                required String reason,
                required String snapshotJson,
                required String mergedFingerprint,
                Value<String> conflictsJson = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> undoneAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CanonicalMergeAuditsCompanion.insert(
                id: id,
                sourceId: sourceId,
                targetId: targetId,
                reason: reason,
                snapshotJson: snapshotJson,
                mergedFingerprint: mergedFingerprint,
                conflictsJson: conflictsJson,
                createdAt: createdAt,
                undoneAt: undoneAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CanonicalMergeAuditsTableProcessedTableManager =
    ProcessedTableManager<
      _$CanonicalDatabase,
      $CanonicalMergeAuditsTable,
      MergeAuditRow,
      $$CanonicalMergeAuditsTableFilterComposer,
      $$CanonicalMergeAuditsTableOrderingComposer,
      $$CanonicalMergeAuditsTableAnnotationComposer,
      $$CanonicalMergeAuditsTableCreateCompanionBuilder,
      $$CanonicalMergeAuditsTableUpdateCompanionBuilder,
      (
        MergeAuditRow,
        BaseReferences<
          _$CanonicalDatabase,
          $CanonicalMergeAuditsTable,
          MergeAuditRow
        >,
      ),
      MergeAuditRow,
      PrefetchHooks Function()
    >;
typedef $$MangaSourcePageResumesTableCreateCompanionBuilder =
    MangaSourcePageResumesCompanion Function({
      required String mediaId,
      required String chapterId,
      required String providerId,
      required String chapterExternalId,
      required int pageIndex,
      Value<int?> totalPages,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$MangaSourcePageResumesTableUpdateCompanionBuilder =
    MangaSourcePageResumesCompanion Function({
      Value<String> mediaId,
      Value<String> chapterId,
      Value<String> providerId,
      Value<String> chapterExternalId,
      Value<int> pageIndex,
      Value<int?> totalPages,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$MangaSourcePageResumesTableReferences
    extends
        BaseReferences<
          _$CanonicalDatabase,
          $MangaSourcePageResumesTable,
          MangaSourcePageResumeRow
        > {
  $$MangaSourcePageResumesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CanonicalMediaRecordsTable _mediaIdTable(_$CanonicalDatabase db) =>
      db.canonicalMediaRecords.createAlias(
        $_aliasNameGenerator(
          db.mangaSourcePageResumes.mediaId,
          db.canonicalMediaRecords.id,
        ),
      );

  $$CanonicalMediaRecordsTableProcessedTableManager get mediaId {
    final $_column = $_itemColumn<String>('media_id')!;

    final manager = $$CanonicalMediaRecordsTableTableManager(
      $_db,
      $_db.canonicalMediaRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mediaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CanonicalChapterRecordsTable _chapterIdTable(
    _$CanonicalDatabase db,
  ) => db.canonicalChapterRecords.createAlias(
    $_aliasNameGenerator(
      db.mangaSourcePageResumes.chapterId,
      db.canonicalChapterRecords.id,
    ),
  );

  $$CanonicalChapterRecordsTableProcessedTableManager get chapterId {
    final $_column = $_itemColumn<String>('chapter_id')!;

    final manager = $$CanonicalChapterRecordsTableTableManager(
      $_db,
      $_db.canonicalChapterRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chapterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MangaSourcePageResumesTableFilterComposer
    extends Composer<_$CanonicalDatabase, $MangaSourcePageResumesTable> {
  $$MangaSourcePageResumesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapterExternalId => $composableBuilder(
    column: $table.chapterExternalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageIndex => $composableBuilder(
    column: $table.pageIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CanonicalMediaRecordsTableFilterComposer get mediaId {
    final $$CanonicalMediaRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mediaId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableFilterComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CanonicalChapterRecordsTableFilterComposer get chapterId {
    final $$CanonicalChapterRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.chapterId,
          referencedTable: $db.canonicalChapterRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalChapterRecordsTableFilterComposer(
                $db: $db,
                $table: $db.canonicalChapterRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$MangaSourcePageResumesTableOrderingComposer
    extends Composer<_$CanonicalDatabase, $MangaSourcePageResumesTable> {
  $$MangaSourcePageResumesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapterExternalId => $composableBuilder(
    column: $table.chapterExternalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageIndex => $composableBuilder(
    column: $table.pageIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CanonicalMediaRecordsTableOrderingComposer get mediaId {
    final $$CanonicalMediaRecordsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mediaId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableOrderingComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CanonicalChapterRecordsTableOrderingComposer get chapterId {
    final $$CanonicalChapterRecordsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.chapterId,
          referencedTable: $db.canonicalChapterRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalChapterRecordsTableOrderingComposer(
                $db: $db,
                $table: $db.canonicalChapterRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$MangaSourcePageResumesTableAnnotationComposer
    extends Composer<_$CanonicalDatabase, $MangaSourcePageResumesTable> {
  $$MangaSourcePageResumesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chapterExternalId => $composableBuilder(
    column: $table.chapterExternalId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pageIndex =>
      $composableBuilder(column: $table.pageIndex, builder: (column) => column);

  GeneratedColumn<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CanonicalMediaRecordsTableAnnotationComposer get mediaId {
    final $$CanonicalMediaRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mediaId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CanonicalChapterRecordsTableAnnotationComposer get chapterId {
    final $$CanonicalChapterRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.chapterId,
          referencedTable: $db.canonicalChapterRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalChapterRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.canonicalChapterRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$MangaSourcePageResumesTableTableManager
    extends
        RootTableManager<
          _$CanonicalDatabase,
          $MangaSourcePageResumesTable,
          MangaSourcePageResumeRow,
          $$MangaSourcePageResumesTableFilterComposer,
          $$MangaSourcePageResumesTableOrderingComposer,
          $$MangaSourcePageResumesTableAnnotationComposer,
          $$MangaSourcePageResumesTableCreateCompanionBuilder,
          $$MangaSourcePageResumesTableUpdateCompanionBuilder,
          (MangaSourcePageResumeRow, $$MangaSourcePageResumesTableReferences),
          MangaSourcePageResumeRow,
          PrefetchHooks Function({bool mediaId, bool chapterId})
        > {
  $$MangaSourcePageResumesTableTableManager(
    _$CanonicalDatabase db,
    $MangaSourcePageResumesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MangaSourcePageResumesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$MangaSourcePageResumesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MangaSourcePageResumesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> mediaId = const Value.absent(),
                Value<String> chapterId = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> chapterExternalId = const Value.absent(),
                Value<int> pageIndex = const Value.absent(),
                Value<int?> totalPages = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MangaSourcePageResumesCompanion(
                mediaId: mediaId,
                chapterId: chapterId,
                providerId: providerId,
                chapterExternalId: chapterExternalId,
                pageIndex: pageIndex,
                totalPages: totalPages,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String mediaId,
                required String chapterId,
                required String providerId,
                required String chapterExternalId,
                required int pageIndex,
                Value<int?> totalPages = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MangaSourcePageResumesCompanion.insert(
                mediaId: mediaId,
                chapterId: chapterId,
                providerId: providerId,
                chapterExternalId: chapterExternalId,
                pageIndex: pageIndex,
                totalPages: totalPages,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MangaSourcePageResumesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({mediaId = false, chapterId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (mediaId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.mediaId,
                                referencedTable:
                                    $$MangaSourcePageResumesTableReferences
                                        ._mediaIdTable(db),
                                referencedColumn:
                                    $$MangaSourcePageResumesTableReferences
                                        ._mediaIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (chapterId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.chapterId,
                                referencedTable:
                                    $$MangaSourcePageResumesTableReferences
                                        ._chapterIdTable(db),
                                referencedColumn:
                                    $$MangaSourcePageResumesTableReferences
                                        ._chapterIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MangaSourcePageResumesTableProcessedTableManager =
    ProcessedTableManager<
      _$CanonicalDatabase,
      $MangaSourcePageResumesTable,
      MangaSourcePageResumeRow,
      $$MangaSourcePageResumesTableFilterComposer,
      $$MangaSourcePageResumesTableOrderingComposer,
      $$MangaSourcePageResumesTableAnnotationComposer,
      $$MangaSourcePageResumesTableCreateCompanionBuilder,
      $$MangaSourcePageResumesTableUpdateCompanionBuilder,
      (MangaSourcePageResumeRow, $$MangaSourcePageResumesTableReferences),
      MangaSourcePageResumeRow,
      PrefetchHooks Function({bool mediaId, bool chapterId})
    >;
typedef $$AnimeSourcePlaybackResumesTableCreateCompanionBuilder =
    AnimeSourcePlaybackResumesCompanion Function({
      required String mediaId,
      required String episodeId,
      required String providerId,
      required String episodeExternalId,
      required int positionMilliseconds,
      Value<int?> durationMilliseconds,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AnimeSourcePlaybackResumesTableUpdateCompanionBuilder =
    AnimeSourcePlaybackResumesCompanion Function({
      Value<String> mediaId,
      Value<String> episodeId,
      Value<String> providerId,
      Value<String> episodeExternalId,
      Value<int> positionMilliseconds,
      Value<int?> durationMilliseconds,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$AnimeSourcePlaybackResumesTableReferences
    extends
        BaseReferences<
          _$CanonicalDatabase,
          $AnimeSourcePlaybackResumesTable,
          AnimeSourcePlaybackResumeRow
        > {
  $$AnimeSourcePlaybackResumesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CanonicalMediaRecordsTable _mediaIdTable(_$CanonicalDatabase db) =>
      db.canonicalMediaRecords.createAlias(
        $_aliasNameGenerator(
          db.animeSourcePlaybackResumes.mediaId,
          db.canonicalMediaRecords.id,
        ),
      );

  $$CanonicalMediaRecordsTableProcessedTableManager get mediaId {
    final $_column = $_itemColumn<String>('media_id')!;

    final manager = $$CanonicalMediaRecordsTableTableManager(
      $_db,
      $_db.canonicalMediaRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mediaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CanonicalEpisodeRecordsTable _episodeIdTable(
    _$CanonicalDatabase db,
  ) => db.canonicalEpisodeRecords.createAlias(
    $_aliasNameGenerator(
      db.animeSourcePlaybackResumes.episodeId,
      db.canonicalEpisodeRecords.id,
    ),
  );

  $$CanonicalEpisodeRecordsTableProcessedTableManager get episodeId {
    final $_column = $_itemColumn<String>('episode_id')!;

    final manager = $$CanonicalEpisodeRecordsTableTableManager(
      $_db,
      $_db.canonicalEpisodeRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_episodeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AnimeSourcePlaybackResumesTableFilterComposer
    extends Composer<_$CanonicalDatabase, $AnimeSourcePlaybackResumesTable> {
  $$AnimeSourcePlaybackResumesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get episodeExternalId => $composableBuilder(
    column: $table.episodeExternalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionMilliseconds => $composableBuilder(
    column: $table.positionMilliseconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMilliseconds => $composableBuilder(
    column: $table.durationMilliseconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CanonicalMediaRecordsTableFilterComposer get mediaId {
    final $$CanonicalMediaRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mediaId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableFilterComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CanonicalEpisodeRecordsTableFilterComposer get episodeId {
    final $$CanonicalEpisodeRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.episodeId,
          referencedTable: $db.canonicalEpisodeRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalEpisodeRecordsTableFilterComposer(
                $db: $db,
                $table: $db.canonicalEpisodeRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$AnimeSourcePlaybackResumesTableOrderingComposer
    extends Composer<_$CanonicalDatabase, $AnimeSourcePlaybackResumesTable> {
  $$AnimeSourcePlaybackResumesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get episodeExternalId => $composableBuilder(
    column: $table.episodeExternalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionMilliseconds => $composableBuilder(
    column: $table.positionMilliseconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMilliseconds => $composableBuilder(
    column: $table.durationMilliseconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CanonicalMediaRecordsTableOrderingComposer get mediaId {
    final $$CanonicalMediaRecordsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mediaId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableOrderingComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CanonicalEpisodeRecordsTableOrderingComposer get episodeId {
    final $$CanonicalEpisodeRecordsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.episodeId,
          referencedTable: $db.canonicalEpisodeRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalEpisodeRecordsTableOrderingComposer(
                $db: $db,
                $table: $db.canonicalEpisodeRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$AnimeSourcePlaybackResumesTableAnnotationComposer
    extends Composer<_$CanonicalDatabase, $AnimeSourcePlaybackResumesTable> {
  $$AnimeSourcePlaybackResumesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get episodeExternalId => $composableBuilder(
    column: $table.episodeExternalId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get positionMilliseconds => $composableBuilder(
    column: $table.positionMilliseconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMilliseconds => $composableBuilder(
    column: $table.durationMilliseconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CanonicalMediaRecordsTableAnnotationComposer get mediaId {
    final $$CanonicalMediaRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mediaId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CanonicalEpisodeRecordsTableAnnotationComposer get episodeId {
    final $$CanonicalEpisodeRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.episodeId,
          referencedTable: $db.canonicalEpisodeRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalEpisodeRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.canonicalEpisodeRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$AnimeSourcePlaybackResumesTableTableManager
    extends
        RootTableManager<
          _$CanonicalDatabase,
          $AnimeSourcePlaybackResumesTable,
          AnimeSourcePlaybackResumeRow,
          $$AnimeSourcePlaybackResumesTableFilterComposer,
          $$AnimeSourcePlaybackResumesTableOrderingComposer,
          $$AnimeSourcePlaybackResumesTableAnnotationComposer,
          $$AnimeSourcePlaybackResumesTableCreateCompanionBuilder,
          $$AnimeSourcePlaybackResumesTableUpdateCompanionBuilder,
          (
            AnimeSourcePlaybackResumeRow,
            $$AnimeSourcePlaybackResumesTableReferences,
          ),
          AnimeSourcePlaybackResumeRow,
          PrefetchHooks Function({bool mediaId, bool episodeId})
        > {
  $$AnimeSourcePlaybackResumesTableTableManager(
    _$CanonicalDatabase db,
    $AnimeSourcePlaybackResumesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnimeSourcePlaybackResumesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$AnimeSourcePlaybackResumesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AnimeSourcePlaybackResumesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> mediaId = const Value.absent(),
                Value<String> episodeId = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> episodeExternalId = const Value.absent(),
                Value<int> positionMilliseconds = const Value.absent(),
                Value<int?> durationMilliseconds = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AnimeSourcePlaybackResumesCompanion(
                mediaId: mediaId,
                episodeId: episodeId,
                providerId: providerId,
                episodeExternalId: episodeExternalId,
                positionMilliseconds: positionMilliseconds,
                durationMilliseconds: durationMilliseconds,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String mediaId,
                required String episodeId,
                required String providerId,
                required String episodeExternalId,
                required int positionMilliseconds,
                Value<int?> durationMilliseconds = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AnimeSourcePlaybackResumesCompanion.insert(
                mediaId: mediaId,
                episodeId: episodeId,
                providerId: providerId,
                episodeExternalId: episodeExternalId,
                positionMilliseconds: positionMilliseconds,
                durationMilliseconds: durationMilliseconds,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AnimeSourcePlaybackResumesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({mediaId = false, episodeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (mediaId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.mediaId,
                                referencedTable:
                                    $$AnimeSourcePlaybackResumesTableReferences
                                        ._mediaIdTable(db),
                                referencedColumn:
                                    $$AnimeSourcePlaybackResumesTableReferences
                                        ._mediaIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (episodeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.episodeId,
                                referencedTable:
                                    $$AnimeSourcePlaybackResumesTableReferences
                                        ._episodeIdTable(db),
                                referencedColumn:
                                    $$AnimeSourcePlaybackResumesTableReferences
                                        ._episodeIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AnimeSourcePlaybackResumesTableProcessedTableManager =
    ProcessedTableManager<
      _$CanonicalDatabase,
      $AnimeSourcePlaybackResumesTable,
      AnimeSourcePlaybackResumeRow,
      $$AnimeSourcePlaybackResumesTableFilterComposer,
      $$AnimeSourcePlaybackResumesTableOrderingComposer,
      $$AnimeSourcePlaybackResumesTableAnnotationComposer,
      $$AnimeSourcePlaybackResumesTableCreateCompanionBuilder,
      $$AnimeSourcePlaybackResumesTableUpdateCompanionBuilder,
      (
        AnimeSourcePlaybackResumeRow,
        $$AnimeSourcePlaybackResumesTableReferences,
      ),
      AnimeSourcePlaybackResumeRow,
      PrefetchHooks Function({bool mediaId, bool episodeId})
    >;
typedef $$PreferredMediaSourcesTableCreateCompanionBuilder =
    PreferredMediaSourcesCompanion Function({
      required String mediaId,
      required String providerId,
      Value<int> rowid,
    });
typedef $$PreferredMediaSourcesTableUpdateCompanionBuilder =
    PreferredMediaSourcesCompanion Function({
      Value<String> mediaId,
      Value<String> providerId,
      Value<int> rowid,
    });

final class $$PreferredMediaSourcesTableReferences
    extends
        BaseReferences<
          _$CanonicalDatabase,
          $PreferredMediaSourcesTable,
          PreferredMediaSourceRow
        > {
  $$PreferredMediaSourcesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CanonicalMediaRecordsTable _mediaIdTable(_$CanonicalDatabase db) =>
      db.canonicalMediaRecords.createAlias(
        $_aliasNameGenerator(
          db.preferredMediaSources.mediaId,
          db.canonicalMediaRecords.id,
        ),
      );

  $$CanonicalMediaRecordsTableProcessedTableManager get mediaId {
    final $_column = $_itemColumn<String>('media_id')!;

    final manager = $$CanonicalMediaRecordsTableTableManager(
      $_db,
      $_db.canonicalMediaRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mediaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PreferredMediaSourcesTableFilterComposer
    extends Composer<_$CanonicalDatabase, $PreferredMediaSourcesTable> {
  $$PreferredMediaSourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  $$CanonicalMediaRecordsTableFilterComposer get mediaId {
    final $$CanonicalMediaRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mediaId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableFilterComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$PreferredMediaSourcesTableOrderingComposer
    extends Composer<_$CanonicalDatabase, $PreferredMediaSourcesTable> {
  $$PreferredMediaSourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  $$CanonicalMediaRecordsTableOrderingComposer get mediaId {
    final $$CanonicalMediaRecordsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mediaId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableOrderingComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$PreferredMediaSourcesTableAnnotationComposer
    extends Composer<_$CanonicalDatabase, $PreferredMediaSourcesTable> {
  $$PreferredMediaSourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  $$CanonicalMediaRecordsTableAnnotationComposer get mediaId {
    final $$CanonicalMediaRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mediaId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$PreferredMediaSourcesTableTableManager
    extends
        RootTableManager<
          _$CanonicalDatabase,
          $PreferredMediaSourcesTable,
          PreferredMediaSourceRow,
          $$PreferredMediaSourcesTableFilterComposer,
          $$PreferredMediaSourcesTableOrderingComposer,
          $$PreferredMediaSourcesTableAnnotationComposer,
          $$PreferredMediaSourcesTableCreateCompanionBuilder,
          $$PreferredMediaSourcesTableUpdateCompanionBuilder,
          (PreferredMediaSourceRow, $$PreferredMediaSourcesTableReferences),
          PreferredMediaSourceRow,
          PrefetchHooks Function({bool mediaId})
        > {
  $$PreferredMediaSourcesTableTableManager(
    _$CanonicalDatabase db,
    $PreferredMediaSourcesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PreferredMediaSourcesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PreferredMediaSourcesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PreferredMediaSourcesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> mediaId = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PreferredMediaSourcesCompanion(
                mediaId: mediaId,
                providerId: providerId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String mediaId,
                required String providerId,
                Value<int> rowid = const Value.absent(),
              }) => PreferredMediaSourcesCompanion.insert(
                mediaId: mediaId,
                providerId: providerId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PreferredMediaSourcesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({mediaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (mediaId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.mediaId,
                                referencedTable:
                                    $$PreferredMediaSourcesTableReferences
                                        ._mediaIdTable(db),
                                referencedColumn:
                                    $$PreferredMediaSourcesTableReferences
                                        ._mediaIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PreferredMediaSourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$CanonicalDatabase,
      $PreferredMediaSourcesTable,
      PreferredMediaSourceRow,
      $$PreferredMediaSourcesTableFilterComposer,
      $$PreferredMediaSourcesTableOrderingComposer,
      $$PreferredMediaSourcesTableAnnotationComposer,
      $$PreferredMediaSourcesTableCreateCompanionBuilder,
      $$PreferredMediaSourcesTableUpdateCompanionBuilder,
      (PreferredMediaSourceRow, $$PreferredMediaSourcesTableReferences),
      PreferredMediaSourceRow,
      PrefetchHooks Function({bool mediaId})
    >;
typedef $$LocalAssetRecordsTableCreateCompanionBuilder =
    LocalAssetRecordsCompanion Function({
      required String id,
      required String kind,
      required String ownership,
      required String state,
      required String providerId,
      required String bindingExternalId,
      required String mediaId,
      required String installmentId,
      required String originalName,
      Value<String?> managedRelativePath,
      Value<int?> sizeBytes,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalAssetRecordsTableUpdateCompanionBuilder =
    LocalAssetRecordsCompanion Function({
      Value<String> id,
      Value<String> kind,
      Value<String> ownership,
      Value<String> state,
      Value<String> providerId,
      Value<String> bindingExternalId,
      Value<String> mediaId,
      Value<String> installmentId,
      Value<String> originalName,
      Value<String?> managedRelativePath,
      Value<int?> sizeBytes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$LocalAssetRecordsTableReferences
    extends
        BaseReferences<
          _$CanonicalDatabase,
          $LocalAssetRecordsTable,
          LocalAssetRow
        > {
  $$LocalAssetRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CanonicalMediaRecordsTable _mediaIdTable(_$CanonicalDatabase db) =>
      db.canonicalMediaRecords.createAlias(
        $_aliasNameGenerator(
          db.localAssetRecords.mediaId,
          db.canonicalMediaRecords.id,
        ),
      );

  $$CanonicalMediaRecordsTableProcessedTableManager get mediaId {
    final $_column = $_itemColumn<String>('media_id')!;

    final manager = $$CanonicalMediaRecordsTableTableManager(
      $_db,
      $_db.canonicalMediaRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mediaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LocalAssetRecordsTableFilterComposer
    extends Composer<_$CanonicalDatabase, $LocalAssetRecordsTable> {
  $$LocalAssetRecordsTableFilterComposer({
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

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownership => $composableBuilder(
    column: $table.ownership,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bindingExternalId => $composableBuilder(
    column: $table.bindingExternalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get installmentId => $composableBuilder(
    column: $table.installmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get managedRelativePath => $composableBuilder(
    column: $table.managedRelativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CanonicalMediaRecordsTableFilterComposer get mediaId {
    final $$CanonicalMediaRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mediaId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableFilterComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$LocalAssetRecordsTableOrderingComposer
    extends Composer<_$CanonicalDatabase, $LocalAssetRecordsTable> {
  $$LocalAssetRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownership => $composableBuilder(
    column: $table.ownership,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bindingExternalId => $composableBuilder(
    column: $table.bindingExternalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get installmentId => $composableBuilder(
    column: $table.installmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get managedRelativePath => $composableBuilder(
    column: $table.managedRelativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CanonicalMediaRecordsTableOrderingComposer get mediaId {
    final $$CanonicalMediaRecordsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mediaId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableOrderingComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$LocalAssetRecordsTableAnnotationComposer
    extends Composer<_$CanonicalDatabase, $LocalAssetRecordsTable> {
  $$LocalAssetRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get ownership =>
      $composableBuilder(column: $table.ownership, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bindingExternalId => $composableBuilder(
    column: $table.bindingExternalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get installmentId => $composableBuilder(
    column: $table.installmentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get managedRelativePath => $composableBuilder(
    column: $table.managedRelativePath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CanonicalMediaRecordsTableAnnotationComposer get mediaId {
    final $$CanonicalMediaRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mediaId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$LocalAssetRecordsTableTableManager
    extends
        RootTableManager<
          _$CanonicalDatabase,
          $LocalAssetRecordsTable,
          LocalAssetRow,
          $$LocalAssetRecordsTableFilterComposer,
          $$LocalAssetRecordsTableOrderingComposer,
          $$LocalAssetRecordsTableAnnotationComposer,
          $$LocalAssetRecordsTableCreateCompanionBuilder,
          $$LocalAssetRecordsTableUpdateCompanionBuilder,
          (LocalAssetRow, $$LocalAssetRecordsTableReferences),
          LocalAssetRow,
          PrefetchHooks Function({bool mediaId})
        > {
  $$LocalAssetRecordsTableTableManager(
    _$CanonicalDatabase db,
    $LocalAssetRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAssetRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAssetRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAssetRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> ownership = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> bindingExternalId = const Value.absent(),
                Value<String> mediaId = const Value.absent(),
                Value<String> installmentId = const Value.absent(),
                Value<String> originalName = const Value.absent(),
                Value<String?> managedRelativePath = const Value.absent(),
                Value<int?> sizeBytes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAssetRecordsCompanion(
                id: id,
                kind: kind,
                ownership: ownership,
                state: state,
                providerId: providerId,
                bindingExternalId: bindingExternalId,
                mediaId: mediaId,
                installmentId: installmentId,
                originalName: originalName,
                managedRelativePath: managedRelativePath,
                sizeBytes: sizeBytes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String kind,
                required String ownership,
                required String state,
                required String providerId,
                required String bindingExternalId,
                required String mediaId,
                required String installmentId,
                required String originalName,
                Value<String?> managedRelativePath = const Value.absent(),
                Value<int?> sizeBytes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalAssetRecordsCompanion.insert(
                id: id,
                kind: kind,
                ownership: ownership,
                state: state,
                providerId: providerId,
                bindingExternalId: bindingExternalId,
                mediaId: mediaId,
                installmentId: installmentId,
                originalName: originalName,
                managedRelativePath: managedRelativePath,
                sizeBytes: sizeBytes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LocalAssetRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({mediaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (mediaId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.mediaId,
                                referencedTable:
                                    $$LocalAssetRecordsTableReferences
                                        ._mediaIdTable(db),
                                referencedColumn:
                                    $$LocalAssetRecordsTableReferences
                                        ._mediaIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LocalAssetRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$CanonicalDatabase,
      $LocalAssetRecordsTable,
      LocalAssetRow,
      $$LocalAssetRecordsTableFilterComposer,
      $$LocalAssetRecordsTableOrderingComposer,
      $$LocalAssetRecordsTableAnnotationComposer,
      $$LocalAssetRecordsTableCreateCompanionBuilder,
      $$LocalAssetRecordsTableUpdateCompanionBuilder,
      (LocalAssetRow, $$LocalAssetRecordsTableReferences),
      LocalAssetRow,
      PrefetchHooks Function({bool mediaId})
    >;
typedef $$AdapterConfigurationsTableCreateCompanionBuilder =
    AdapterConfigurationsCompanion Function({
      required String adapterId,
      required bool enabled,
      Value<String?> baseUrl,
      required int sortOrder,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AdapterConfigurationsTableUpdateCompanionBuilder =
    AdapterConfigurationsCompanion Function({
      Value<String> adapterId,
      Value<bool> enabled,
      Value<String?> baseUrl,
      Value<int> sortOrder,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AdapterConfigurationsTableFilterComposer
    extends Composer<_$CanonicalDatabase, $AdapterConfigurationsTable> {
  $$AdapterConfigurationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get adapterId => $composableBuilder(
    column: $table.adapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseUrl => $composableBuilder(
    column: $table.baseUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AdapterConfigurationsTableOrderingComposer
    extends Composer<_$CanonicalDatabase, $AdapterConfigurationsTable> {
  $$AdapterConfigurationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get adapterId => $composableBuilder(
    column: $table.adapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseUrl => $composableBuilder(
    column: $table.baseUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AdapterConfigurationsTableAnnotationComposer
    extends Composer<_$CanonicalDatabase, $AdapterConfigurationsTable> {
  $$AdapterConfigurationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get adapterId =>
      $composableBuilder(column: $table.adapterId, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<String> get baseUrl =>
      $composableBuilder(column: $table.baseUrl, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AdapterConfigurationsTableTableManager
    extends
        RootTableManager<
          _$CanonicalDatabase,
          $AdapterConfigurationsTable,
          AdapterConfigurationRow,
          $$AdapterConfigurationsTableFilterComposer,
          $$AdapterConfigurationsTableOrderingComposer,
          $$AdapterConfigurationsTableAnnotationComposer,
          $$AdapterConfigurationsTableCreateCompanionBuilder,
          $$AdapterConfigurationsTableUpdateCompanionBuilder,
          (
            AdapterConfigurationRow,
            BaseReferences<
              _$CanonicalDatabase,
              $AdapterConfigurationsTable,
              AdapterConfigurationRow
            >,
          ),
          AdapterConfigurationRow,
          PrefetchHooks Function()
        > {
  $$AdapterConfigurationsTableTableManager(
    _$CanonicalDatabase db,
    $AdapterConfigurationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AdapterConfigurationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$AdapterConfigurationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AdapterConfigurationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> adapterId = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<String?> baseUrl = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AdapterConfigurationsCompanion(
                adapterId: adapterId,
                enabled: enabled,
                baseUrl: baseUrl,
                sortOrder: sortOrder,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String adapterId,
                required bool enabled,
                Value<String?> baseUrl = const Value.absent(),
                required int sortOrder,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AdapterConfigurationsCompanion.insert(
                adapterId: adapterId,
                enabled: enabled,
                baseUrl: baseUrl,
                sortOrder: sortOrder,
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

typedef $$AdapterConfigurationsTableProcessedTableManager =
    ProcessedTableManager<
      _$CanonicalDatabase,
      $AdapterConfigurationsTable,
      AdapterConfigurationRow,
      $$AdapterConfigurationsTableFilterComposer,
      $$AdapterConfigurationsTableOrderingComposer,
      $$AdapterConfigurationsTableAnnotationComposer,
      $$AdapterConfigurationsTableCreateCompanionBuilder,
      $$AdapterConfigurationsTableUpdateCompanionBuilder,
      (
        AdapterConfigurationRow,
        BaseReferences<
          _$CanonicalDatabase,
          $AdapterConfigurationsTable,
          AdapterConfigurationRow
        >,
      ),
      AdapterConfigurationRow,
      PrefetchHooks Function()
    >;
typedef $$AdapterReliabilityRecordsTableCreateCompanionBuilder =
    AdapterReliabilityRecordsCompanion Function({
      required String adapterId,
      Value<DateTime?> lastCheckedAt,
      Value<DateTime?> lastSuccessAt,
      Value<DateTime?> lastFailureAt,
      Value<int> consecutiveFailures,
      Value<DateTime?> lastParserMismatchAt,
      Value<String?> lastError,
      Value<int> rowid,
    });
typedef $$AdapterReliabilityRecordsTableUpdateCompanionBuilder =
    AdapterReliabilityRecordsCompanion Function({
      Value<String> adapterId,
      Value<DateTime?> lastCheckedAt,
      Value<DateTime?> lastSuccessAt,
      Value<DateTime?> lastFailureAt,
      Value<int> consecutiveFailures,
      Value<DateTime?> lastParserMismatchAt,
      Value<String?> lastError,
      Value<int> rowid,
    });

class $$AdapterReliabilityRecordsTableFilterComposer
    extends Composer<_$CanonicalDatabase, $AdapterReliabilityRecordsTable> {
  $$AdapterReliabilityRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get adapterId => $composableBuilder(
    column: $table.adapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastCheckedAt => $composableBuilder(
    column: $table.lastCheckedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSuccessAt => $composableBuilder(
    column: $table.lastSuccessAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastFailureAt => $composableBuilder(
    column: $table.lastFailureAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get consecutiveFailures => $composableBuilder(
    column: $table.consecutiveFailures,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastParserMismatchAt => $composableBuilder(
    column: $table.lastParserMismatchAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AdapterReliabilityRecordsTableOrderingComposer
    extends Composer<_$CanonicalDatabase, $AdapterReliabilityRecordsTable> {
  $$AdapterReliabilityRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get adapterId => $composableBuilder(
    column: $table.adapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastCheckedAt => $composableBuilder(
    column: $table.lastCheckedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSuccessAt => $composableBuilder(
    column: $table.lastSuccessAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastFailureAt => $composableBuilder(
    column: $table.lastFailureAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get consecutiveFailures => $composableBuilder(
    column: $table.consecutiveFailures,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastParserMismatchAt => $composableBuilder(
    column: $table.lastParserMismatchAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AdapterReliabilityRecordsTableAnnotationComposer
    extends Composer<_$CanonicalDatabase, $AdapterReliabilityRecordsTable> {
  $$AdapterReliabilityRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get adapterId =>
      $composableBuilder(column: $table.adapterId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastCheckedAt => $composableBuilder(
    column: $table.lastCheckedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSuccessAt => $composableBuilder(
    column: $table.lastSuccessAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastFailureAt => $composableBuilder(
    column: $table.lastFailureAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get consecutiveFailures => $composableBuilder(
    column: $table.consecutiveFailures,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastParserMismatchAt => $composableBuilder(
    column: $table.lastParserMismatchAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$AdapterReliabilityRecordsTableTableManager
    extends
        RootTableManager<
          _$CanonicalDatabase,
          $AdapterReliabilityRecordsTable,
          AdapterReliabilityRow,
          $$AdapterReliabilityRecordsTableFilterComposer,
          $$AdapterReliabilityRecordsTableOrderingComposer,
          $$AdapterReliabilityRecordsTableAnnotationComposer,
          $$AdapterReliabilityRecordsTableCreateCompanionBuilder,
          $$AdapterReliabilityRecordsTableUpdateCompanionBuilder,
          (
            AdapterReliabilityRow,
            BaseReferences<
              _$CanonicalDatabase,
              $AdapterReliabilityRecordsTable,
              AdapterReliabilityRow
            >,
          ),
          AdapterReliabilityRow,
          PrefetchHooks Function()
        > {
  $$AdapterReliabilityRecordsTableTableManager(
    _$CanonicalDatabase db,
    $AdapterReliabilityRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AdapterReliabilityRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$AdapterReliabilityRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AdapterReliabilityRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> adapterId = const Value.absent(),
                Value<DateTime?> lastCheckedAt = const Value.absent(),
                Value<DateTime?> lastSuccessAt = const Value.absent(),
                Value<DateTime?> lastFailureAt = const Value.absent(),
                Value<int> consecutiveFailures = const Value.absent(),
                Value<DateTime?> lastParserMismatchAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AdapterReliabilityRecordsCompanion(
                adapterId: adapterId,
                lastCheckedAt: lastCheckedAt,
                lastSuccessAt: lastSuccessAt,
                lastFailureAt: lastFailureAt,
                consecutiveFailures: consecutiveFailures,
                lastParserMismatchAt: lastParserMismatchAt,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String adapterId,
                Value<DateTime?> lastCheckedAt = const Value.absent(),
                Value<DateTime?> lastSuccessAt = const Value.absent(),
                Value<DateTime?> lastFailureAt = const Value.absent(),
                Value<int> consecutiveFailures = const Value.absent(),
                Value<DateTime?> lastParserMismatchAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AdapterReliabilityRecordsCompanion.insert(
                adapterId: adapterId,
                lastCheckedAt: lastCheckedAt,
                lastSuccessAt: lastSuccessAt,
                lastFailureAt: lastFailureAt,
                consecutiveFailures: consecutiveFailures,
                lastParserMismatchAt: lastParserMismatchAt,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AdapterReliabilityRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$CanonicalDatabase,
      $AdapterReliabilityRecordsTable,
      AdapterReliabilityRow,
      $$AdapterReliabilityRecordsTableFilterComposer,
      $$AdapterReliabilityRecordsTableOrderingComposer,
      $$AdapterReliabilityRecordsTableAnnotationComposer,
      $$AdapterReliabilityRecordsTableCreateCompanionBuilder,
      $$AdapterReliabilityRecordsTableUpdateCompanionBuilder,
      (
        AdapterReliabilityRow,
        BaseReferences<
          _$CanonicalDatabase,
          $AdapterReliabilityRecordsTable,
          AdapterReliabilityRow
        >,
      ),
      AdapterReliabilityRow,
      PrefetchHooks Function()
    >;
typedef $$MetadataEnrichmentRecordsTableCreateCompanionBuilder =
    MetadataEnrichmentRecordsCompanion Function({
      required String mediaId,
      required String adapterId,
      required String payloadJson,
      required DateTime observedAt,
      Value<int> rowid,
    });
typedef $$MetadataEnrichmentRecordsTableUpdateCompanionBuilder =
    MetadataEnrichmentRecordsCompanion Function({
      Value<String> mediaId,
      Value<String> adapterId,
      Value<String> payloadJson,
      Value<DateTime> observedAt,
      Value<int> rowid,
    });

final class $$MetadataEnrichmentRecordsTableReferences
    extends
        BaseReferences<
          _$CanonicalDatabase,
          $MetadataEnrichmentRecordsTable,
          MetadataEnrichmentRow
        > {
  $$MetadataEnrichmentRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CanonicalMediaRecordsTable _mediaIdTable(_$CanonicalDatabase db) =>
      db.canonicalMediaRecords.createAlias(
        $_aliasNameGenerator(
          db.metadataEnrichmentRecords.mediaId,
          db.canonicalMediaRecords.id,
        ),
      );

  $$CanonicalMediaRecordsTableProcessedTableManager get mediaId {
    final $_column = $_itemColumn<String>('media_id')!;

    final manager = $$CanonicalMediaRecordsTableTableManager(
      $_db,
      $_db.canonicalMediaRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mediaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MetadataEnrichmentRecordsTableFilterComposer
    extends Composer<_$CanonicalDatabase, $MetadataEnrichmentRecordsTable> {
  $$MetadataEnrichmentRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get adapterId => $composableBuilder(
    column: $table.adapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get observedAt => $composableBuilder(
    column: $table.observedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CanonicalMediaRecordsTableFilterComposer get mediaId {
    final $$CanonicalMediaRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mediaId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableFilterComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$MetadataEnrichmentRecordsTableOrderingComposer
    extends Composer<_$CanonicalDatabase, $MetadataEnrichmentRecordsTable> {
  $$MetadataEnrichmentRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get adapterId => $composableBuilder(
    column: $table.adapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get observedAt => $composableBuilder(
    column: $table.observedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CanonicalMediaRecordsTableOrderingComposer get mediaId {
    final $$CanonicalMediaRecordsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mediaId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableOrderingComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$MetadataEnrichmentRecordsTableAnnotationComposer
    extends Composer<_$CanonicalDatabase, $MetadataEnrichmentRecordsTable> {
  $$MetadataEnrichmentRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get adapterId =>
      $composableBuilder(column: $table.adapterId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get observedAt => $composableBuilder(
    column: $table.observedAt,
    builder: (column) => column,
  );

  $$CanonicalMediaRecordsTableAnnotationComposer get mediaId {
    final $$CanonicalMediaRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mediaId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$MetadataEnrichmentRecordsTableTableManager
    extends
        RootTableManager<
          _$CanonicalDatabase,
          $MetadataEnrichmentRecordsTable,
          MetadataEnrichmentRow,
          $$MetadataEnrichmentRecordsTableFilterComposer,
          $$MetadataEnrichmentRecordsTableOrderingComposer,
          $$MetadataEnrichmentRecordsTableAnnotationComposer,
          $$MetadataEnrichmentRecordsTableCreateCompanionBuilder,
          $$MetadataEnrichmentRecordsTableUpdateCompanionBuilder,
          (MetadataEnrichmentRow, $$MetadataEnrichmentRecordsTableReferences),
          MetadataEnrichmentRow,
          PrefetchHooks Function({bool mediaId})
        > {
  $$MetadataEnrichmentRecordsTableTableManager(
    _$CanonicalDatabase db,
    $MetadataEnrichmentRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetadataEnrichmentRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$MetadataEnrichmentRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MetadataEnrichmentRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> mediaId = const Value.absent(),
                Value<String> adapterId = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> observedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MetadataEnrichmentRecordsCompanion(
                mediaId: mediaId,
                adapterId: adapterId,
                payloadJson: payloadJson,
                observedAt: observedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String mediaId,
                required String adapterId,
                required String payloadJson,
                required DateTime observedAt,
                Value<int> rowid = const Value.absent(),
              }) => MetadataEnrichmentRecordsCompanion.insert(
                mediaId: mediaId,
                adapterId: adapterId,
                payloadJson: payloadJson,
                observedAt: observedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MetadataEnrichmentRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({mediaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (mediaId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.mediaId,
                                referencedTable:
                                    $$MetadataEnrichmentRecordsTableReferences
                                        ._mediaIdTable(db),
                                referencedColumn:
                                    $$MetadataEnrichmentRecordsTableReferences
                                        ._mediaIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MetadataEnrichmentRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$CanonicalDatabase,
      $MetadataEnrichmentRecordsTable,
      MetadataEnrichmentRow,
      $$MetadataEnrichmentRecordsTableFilterComposer,
      $$MetadataEnrichmentRecordsTableOrderingComposer,
      $$MetadataEnrichmentRecordsTableAnnotationComposer,
      $$MetadataEnrichmentRecordsTableCreateCompanionBuilder,
      $$MetadataEnrichmentRecordsTableUpdateCompanionBuilder,
      (MetadataEnrichmentRow, $$MetadataEnrichmentRecordsTableReferences),
      MetadataEnrichmentRow,
      PrefetchHooks Function({bool mediaId})
    >;
typedef $$MetadataOverrideRecordsTableCreateCompanionBuilder =
    MetadataOverrideRecordsCompanion Function({
      required String mediaId,
      Value<String?> displayTitle,
      Value<String?> description,
      Value<String?> coverLocator,
      Value<String> alternateTitlesJson,
      Value<String> genresJson,
      Value<String?> status,
      Value<String?> animeFormat,
      Value<String?> creatorOrStudio,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$MetadataOverrideRecordsTableUpdateCompanionBuilder =
    MetadataOverrideRecordsCompanion Function({
      Value<String> mediaId,
      Value<String?> displayTitle,
      Value<String?> description,
      Value<String?> coverLocator,
      Value<String> alternateTitlesJson,
      Value<String> genresJson,
      Value<String?> status,
      Value<String?> animeFormat,
      Value<String?> creatorOrStudio,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$MetadataOverrideRecordsTableReferences
    extends
        BaseReferences<
          _$CanonicalDatabase,
          $MetadataOverrideRecordsTable,
          MetadataOverrideRow
        > {
  $$MetadataOverrideRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CanonicalMediaRecordsTable _mediaIdTable(_$CanonicalDatabase db) =>
      db.canonicalMediaRecords.createAlias(
        $_aliasNameGenerator(
          db.metadataOverrideRecords.mediaId,
          db.canonicalMediaRecords.id,
        ),
      );

  $$CanonicalMediaRecordsTableProcessedTableManager get mediaId {
    final $_column = $_itemColumn<String>('media_id')!;

    final manager = $$CanonicalMediaRecordsTableTableManager(
      $_db,
      $_db.canonicalMediaRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mediaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MetadataOverrideRecordsTableFilterComposer
    extends Composer<_$CanonicalDatabase, $MetadataOverrideRecordsTable> {
  $$MetadataOverrideRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get displayTitle => $composableBuilder(
    column: $table.displayTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverLocator => $composableBuilder(
    column: $table.coverLocator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alternateTitlesJson => $composableBuilder(
    column: $table.alternateTitlesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genresJson => $composableBuilder(
    column: $table.genresJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get animeFormat => $composableBuilder(
    column: $table.animeFormat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get creatorOrStudio => $composableBuilder(
    column: $table.creatorOrStudio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CanonicalMediaRecordsTableFilterComposer get mediaId {
    final $$CanonicalMediaRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mediaId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableFilterComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$MetadataOverrideRecordsTableOrderingComposer
    extends Composer<_$CanonicalDatabase, $MetadataOverrideRecordsTable> {
  $$MetadataOverrideRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get displayTitle => $composableBuilder(
    column: $table.displayTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverLocator => $composableBuilder(
    column: $table.coverLocator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alternateTitlesJson => $composableBuilder(
    column: $table.alternateTitlesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genresJson => $composableBuilder(
    column: $table.genresJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get animeFormat => $composableBuilder(
    column: $table.animeFormat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get creatorOrStudio => $composableBuilder(
    column: $table.creatorOrStudio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CanonicalMediaRecordsTableOrderingComposer get mediaId {
    final $$CanonicalMediaRecordsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mediaId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableOrderingComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$MetadataOverrideRecordsTableAnnotationComposer
    extends Composer<_$CanonicalDatabase, $MetadataOverrideRecordsTable> {
  $$MetadataOverrideRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get displayTitle => $composableBuilder(
    column: $table.displayTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverLocator => $composableBuilder(
    column: $table.coverLocator,
    builder: (column) => column,
  );

  GeneratedColumn<String> get alternateTitlesJson => $composableBuilder(
    column: $table.alternateTitlesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get genresJson => $composableBuilder(
    column: $table.genresJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get animeFormat => $composableBuilder(
    column: $table.animeFormat,
    builder: (column) => column,
  );

  GeneratedColumn<String> get creatorOrStudio => $composableBuilder(
    column: $table.creatorOrStudio,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CanonicalMediaRecordsTableAnnotationComposer get mediaId {
    final $$CanonicalMediaRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mediaId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$MetadataOverrideRecordsTableTableManager
    extends
        RootTableManager<
          _$CanonicalDatabase,
          $MetadataOverrideRecordsTable,
          MetadataOverrideRow,
          $$MetadataOverrideRecordsTableFilterComposer,
          $$MetadataOverrideRecordsTableOrderingComposer,
          $$MetadataOverrideRecordsTableAnnotationComposer,
          $$MetadataOverrideRecordsTableCreateCompanionBuilder,
          $$MetadataOverrideRecordsTableUpdateCompanionBuilder,
          (MetadataOverrideRow, $$MetadataOverrideRecordsTableReferences),
          MetadataOverrideRow,
          PrefetchHooks Function({bool mediaId})
        > {
  $$MetadataOverrideRecordsTableTableManager(
    _$CanonicalDatabase db,
    $MetadataOverrideRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetadataOverrideRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$MetadataOverrideRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MetadataOverrideRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> mediaId = const Value.absent(),
                Value<String?> displayTitle = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> coverLocator = const Value.absent(),
                Value<String> alternateTitlesJson = const Value.absent(),
                Value<String> genresJson = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<String?> animeFormat = const Value.absent(),
                Value<String?> creatorOrStudio = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MetadataOverrideRecordsCompanion(
                mediaId: mediaId,
                displayTitle: displayTitle,
                description: description,
                coverLocator: coverLocator,
                alternateTitlesJson: alternateTitlesJson,
                genresJson: genresJson,
                status: status,
                animeFormat: animeFormat,
                creatorOrStudio: creatorOrStudio,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String mediaId,
                Value<String?> displayTitle = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> coverLocator = const Value.absent(),
                Value<String> alternateTitlesJson = const Value.absent(),
                Value<String> genresJson = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<String?> animeFormat = const Value.absent(),
                Value<String?> creatorOrStudio = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MetadataOverrideRecordsCompanion.insert(
                mediaId: mediaId,
                displayTitle: displayTitle,
                description: description,
                coverLocator: coverLocator,
                alternateTitlesJson: alternateTitlesJson,
                genresJson: genresJson,
                status: status,
                animeFormat: animeFormat,
                creatorOrStudio: creatorOrStudio,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MetadataOverrideRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({mediaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (mediaId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.mediaId,
                                referencedTable:
                                    $$MetadataOverrideRecordsTableReferences
                                        ._mediaIdTable(db),
                                referencedColumn:
                                    $$MetadataOverrideRecordsTableReferences
                                        ._mediaIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MetadataOverrideRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$CanonicalDatabase,
      $MetadataOverrideRecordsTable,
      MetadataOverrideRow,
      $$MetadataOverrideRecordsTableFilterComposer,
      $$MetadataOverrideRecordsTableOrderingComposer,
      $$MetadataOverrideRecordsTableAnnotationComposer,
      $$MetadataOverrideRecordsTableCreateCompanionBuilder,
      $$MetadataOverrideRecordsTableUpdateCompanionBuilder,
      (MetadataOverrideRow, $$MetadataOverrideRecordsTableReferences),
      MetadataOverrideRow,
      PrefetchHooks Function({bool mediaId})
    >;
typedef $$ChapterUserEditRecordsTableCreateCompanionBuilder =
    ChapterUserEditRecordsCompanion Function({
      required String chapterId,
      required String rawLabel,
      required String kind,
      Value<String?> volumeLabel,
      Value<double?> explicitOrder,
      Value<String?> sourceDisplayLabel,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ChapterUserEditRecordsTableUpdateCompanionBuilder =
    ChapterUserEditRecordsCompanion Function({
      Value<String> chapterId,
      Value<String> rawLabel,
      Value<String> kind,
      Value<String?> volumeLabel,
      Value<double?> explicitOrder,
      Value<String?> sourceDisplayLabel,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ChapterUserEditRecordsTableReferences
    extends
        BaseReferences<
          _$CanonicalDatabase,
          $ChapterUserEditRecordsTable,
          ChapterUserEditRow
        > {
  $$ChapterUserEditRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CanonicalChapterRecordsTable _chapterIdTable(
    _$CanonicalDatabase db,
  ) => db.canonicalChapterRecords.createAlias(
    $_aliasNameGenerator(
      db.chapterUserEditRecords.chapterId,
      db.canonicalChapterRecords.id,
    ),
  );

  $$CanonicalChapterRecordsTableProcessedTableManager get chapterId {
    final $_column = $_itemColumn<String>('chapter_id')!;

    final manager = $$CanonicalChapterRecordsTableTableManager(
      $_db,
      $_db.canonicalChapterRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chapterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ChapterUserEditRecordsTableFilterComposer
    extends Composer<_$CanonicalDatabase, $ChapterUserEditRecordsTable> {
  $$ChapterUserEditRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get rawLabel => $composableBuilder(
    column: $table.rawLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get volumeLabel => $composableBuilder(
    column: $table.volumeLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get explicitOrder => $composableBuilder(
    column: $table.explicitOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceDisplayLabel => $composableBuilder(
    column: $table.sourceDisplayLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CanonicalChapterRecordsTableFilterComposer get chapterId {
    final $$CanonicalChapterRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.chapterId,
          referencedTable: $db.canonicalChapterRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalChapterRecordsTableFilterComposer(
                $db: $db,
                $table: $db.canonicalChapterRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ChapterUserEditRecordsTableOrderingComposer
    extends Composer<_$CanonicalDatabase, $ChapterUserEditRecordsTable> {
  $$ChapterUserEditRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get rawLabel => $composableBuilder(
    column: $table.rawLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get volumeLabel => $composableBuilder(
    column: $table.volumeLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get explicitOrder => $composableBuilder(
    column: $table.explicitOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceDisplayLabel => $composableBuilder(
    column: $table.sourceDisplayLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CanonicalChapterRecordsTableOrderingComposer get chapterId {
    final $$CanonicalChapterRecordsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.chapterId,
          referencedTable: $db.canonicalChapterRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalChapterRecordsTableOrderingComposer(
                $db: $db,
                $table: $db.canonicalChapterRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ChapterUserEditRecordsTableAnnotationComposer
    extends Composer<_$CanonicalDatabase, $ChapterUserEditRecordsTable> {
  $$ChapterUserEditRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get rawLabel =>
      $composableBuilder(column: $table.rawLabel, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get volumeLabel => $composableBuilder(
    column: $table.volumeLabel,
    builder: (column) => column,
  );

  GeneratedColumn<double> get explicitOrder => $composableBuilder(
    column: $table.explicitOrder,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceDisplayLabel => $composableBuilder(
    column: $table.sourceDisplayLabel,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CanonicalChapterRecordsTableAnnotationComposer get chapterId {
    final $$CanonicalChapterRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.chapterId,
          referencedTable: $db.canonicalChapterRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalChapterRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.canonicalChapterRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ChapterUserEditRecordsTableTableManager
    extends
        RootTableManager<
          _$CanonicalDatabase,
          $ChapterUserEditRecordsTable,
          ChapterUserEditRow,
          $$ChapterUserEditRecordsTableFilterComposer,
          $$ChapterUserEditRecordsTableOrderingComposer,
          $$ChapterUserEditRecordsTableAnnotationComposer,
          $$ChapterUserEditRecordsTableCreateCompanionBuilder,
          $$ChapterUserEditRecordsTableUpdateCompanionBuilder,
          (ChapterUserEditRow, $$ChapterUserEditRecordsTableReferences),
          ChapterUserEditRow,
          PrefetchHooks Function({bool chapterId})
        > {
  $$ChapterUserEditRecordsTableTableManager(
    _$CanonicalDatabase db,
    $ChapterUserEditRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChapterUserEditRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ChapterUserEditRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ChapterUserEditRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> chapterId = const Value.absent(),
                Value<String> rawLabel = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> volumeLabel = const Value.absent(),
                Value<double?> explicitOrder = const Value.absent(),
                Value<String?> sourceDisplayLabel = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChapterUserEditRecordsCompanion(
                chapterId: chapterId,
                rawLabel: rawLabel,
                kind: kind,
                volumeLabel: volumeLabel,
                explicitOrder: explicitOrder,
                sourceDisplayLabel: sourceDisplayLabel,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String chapterId,
                required String rawLabel,
                required String kind,
                Value<String?> volumeLabel = const Value.absent(),
                Value<double?> explicitOrder = const Value.absent(),
                Value<String?> sourceDisplayLabel = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ChapterUserEditRecordsCompanion.insert(
                chapterId: chapterId,
                rawLabel: rawLabel,
                kind: kind,
                volumeLabel: volumeLabel,
                explicitOrder: explicitOrder,
                sourceDisplayLabel: sourceDisplayLabel,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChapterUserEditRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({chapterId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (chapterId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.chapterId,
                                referencedTable:
                                    $$ChapterUserEditRecordsTableReferences
                                        ._chapterIdTable(db),
                                referencedColumn:
                                    $$ChapterUserEditRecordsTableReferences
                                        ._chapterIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ChapterUserEditRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$CanonicalDatabase,
      $ChapterUserEditRecordsTable,
      ChapterUserEditRow,
      $$ChapterUserEditRecordsTableFilterComposer,
      $$ChapterUserEditRecordsTableOrderingComposer,
      $$ChapterUserEditRecordsTableAnnotationComposer,
      $$ChapterUserEditRecordsTableCreateCompanionBuilder,
      $$ChapterUserEditRecordsTableUpdateCompanionBuilder,
      (ChapterUserEditRow, $$ChapterUserEditRecordsTableReferences),
      ChapterUserEditRow,
      PrefetchHooks Function({bool chapterId})
    >;
typedef $$EpisodeUserEditRecordsTableCreateCompanionBuilder =
    EpisodeUserEditRecordsCompanion Function({
      required String episodeId,
      required String rawLabel,
      Value<double?> number,
      required String kind,
      Value<int?> narrativeSeason,
      Value<double?> explicitOrder,
      Value<String?> sourceDisplayLabel,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$EpisodeUserEditRecordsTableUpdateCompanionBuilder =
    EpisodeUserEditRecordsCompanion Function({
      Value<String> episodeId,
      Value<String> rawLabel,
      Value<double?> number,
      Value<String> kind,
      Value<int?> narrativeSeason,
      Value<double?> explicitOrder,
      Value<String?> sourceDisplayLabel,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$EpisodeUserEditRecordsTableReferences
    extends
        BaseReferences<
          _$CanonicalDatabase,
          $EpisodeUserEditRecordsTable,
          EpisodeUserEditRow
        > {
  $$EpisodeUserEditRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CanonicalEpisodeRecordsTable _episodeIdTable(
    _$CanonicalDatabase db,
  ) => db.canonicalEpisodeRecords.createAlias(
    $_aliasNameGenerator(
      db.episodeUserEditRecords.episodeId,
      db.canonicalEpisodeRecords.id,
    ),
  );

  $$CanonicalEpisodeRecordsTableProcessedTableManager get episodeId {
    final $_column = $_itemColumn<String>('episode_id')!;

    final manager = $$CanonicalEpisodeRecordsTableTableManager(
      $_db,
      $_db.canonicalEpisodeRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_episodeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EpisodeUserEditRecordsTableFilterComposer
    extends Composer<_$CanonicalDatabase, $EpisodeUserEditRecordsTable> {
  $$EpisodeUserEditRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get rawLabel => $composableBuilder(
    column: $table.rawLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get narrativeSeason => $composableBuilder(
    column: $table.narrativeSeason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get explicitOrder => $composableBuilder(
    column: $table.explicitOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceDisplayLabel => $composableBuilder(
    column: $table.sourceDisplayLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CanonicalEpisodeRecordsTableFilterComposer get episodeId {
    final $$CanonicalEpisodeRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.episodeId,
          referencedTable: $db.canonicalEpisodeRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalEpisodeRecordsTableFilterComposer(
                $db: $db,
                $table: $db.canonicalEpisodeRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$EpisodeUserEditRecordsTableOrderingComposer
    extends Composer<_$CanonicalDatabase, $EpisodeUserEditRecordsTable> {
  $$EpisodeUserEditRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get rawLabel => $composableBuilder(
    column: $table.rawLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get narrativeSeason => $composableBuilder(
    column: $table.narrativeSeason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get explicitOrder => $composableBuilder(
    column: $table.explicitOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceDisplayLabel => $composableBuilder(
    column: $table.sourceDisplayLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CanonicalEpisodeRecordsTableOrderingComposer get episodeId {
    final $$CanonicalEpisodeRecordsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.episodeId,
          referencedTable: $db.canonicalEpisodeRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalEpisodeRecordsTableOrderingComposer(
                $db: $db,
                $table: $db.canonicalEpisodeRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$EpisodeUserEditRecordsTableAnnotationComposer
    extends Composer<_$CanonicalDatabase, $EpisodeUserEditRecordsTable> {
  $$EpisodeUserEditRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get rawLabel =>
      $composableBuilder(column: $table.rawLabel, builder: (column) => column);

  GeneratedColumn<double> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get narrativeSeason => $composableBuilder(
    column: $table.narrativeSeason,
    builder: (column) => column,
  );

  GeneratedColumn<double> get explicitOrder => $composableBuilder(
    column: $table.explicitOrder,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceDisplayLabel => $composableBuilder(
    column: $table.sourceDisplayLabel,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CanonicalEpisodeRecordsTableAnnotationComposer get episodeId {
    final $$CanonicalEpisodeRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.episodeId,
          referencedTable: $db.canonicalEpisodeRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalEpisodeRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.canonicalEpisodeRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$EpisodeUserEditRecordsTableTableManager
    extends
        RootTableManager<
          _$CanonicalDatabase,
          $EpisodeUserEditRecordsTable,
          EpisodeUserEditRow,
          $$EpisodeUserEditRecordsTableFilterComposer,
          $$EpisodeUserEditRecordsTableOrderingComposer,
          $$EpisodeUserEditRecordsTableAnnotationComposer,
          $$EpisodeUserEditRecordsTableCreateCompanionBuilder,
          $$EpisodeUserEditRecordsTableUpdateCompanionBuilder,
          (EpisodeUserEditRow, $$EpisodeUserEditRecordsTableReferences),
          EpisodeUserEditRow,
          PrefetchHooks Function({bool episodeId})
        > {
  $$EpisodeUserEditRecordsTableTableManager(
    _$CanonicalDatabase db,
    $EpisodeUserEditRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EpisodeUserEditRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$EpisodeUserEditRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$EpisodeUserEditRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> episodeId = const Value.absent(),
                Value<String> rawLabel = const Value.absent(),
                Value<double?> number = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int?> narrativeSeason = const Value.absent(),
                Value<double?> explicitOrder = const Value.absent(),
                Value<String?> sourceDisplayLabel = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EpisodeUserEditRecordsCompanion(
                episodeId: episodeId,
                rawLabel: rawLabel,
                number: number,
                kind: kind,
                narrativeSeason: narrativeSeason,
                explicitOrder: explicitOrder,
                sourceDisplayLabel: sourceDisplayLabel,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String episodeId,
                required String rawLabel,
                Value<double?> number = const Value.absent(),
                required String kind,
                Value<int?> narrativeSeason = const Value.absent(),
                Value<double?> explicitOrder = const Value.absent(),
                Value<String?> sourceDisplayLabel = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => EpisodeUserEditRecordsCompanion.insert(
                episodeId: episodeId,
                rawLabel: rawLabel,
                number: number,
                kind: kind,
                narrativeSeason: narrativeSeason,
                explicitOrder: explicitOrder,
                sourceDisplayLabel: sourceDisplayLabel,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EpisodeUserEditRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({episodeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (episodeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.episodeId,
                                referencedTable:
                                    $$EpisodeUserEditRecordsTableReferences
                                        ._episodeIdTable(db),
                                referencedColumn:
                                    $$EpisodeUserEditRecordsTableReferences
                                        ._episodeIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EpisodeUserEditRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$CanonicalDatabase,
      $EpisodeUserEditRecordsTable,
      EpisodeUserEditRow,
      $$EpisodeUserEditRecordsTableFilterComposer,
      $$EpisodeUserEditRecordsTableOrderingComposer,
      $$EpisodeUserEditRecordsTableAnnotationComposer,
      $$EpisodeUserEditRecordsTableCreateCompanionBuilder,
      $$EpisodeUserEditRecordsTableUpdateCompanionBuilder,
      (EpisodeUserEditRow, $$EpisodeUserEditRecordsTableReferences),
      EpisodeUserEditRow,
      PrefetchHooks Function({bool episodeId})
    >;
typedef $$ChapterCompletionRecordsTableCreateCompanionBuilder =
    ChapterCompletionRecordsCompanion Function({
      required String chapterId,
      required String mediaId,
      required DateTime completedAt,
      required String origin,
      Value<int> rowid,
    });
typedef $$ChapterCompletionRecordsTableUpdateCompanionBuilder =
    ChapterCompletionRecordsCompanion Function({
      Value<String> chapterId,
      Value<String> mediaId,
      Value<DateTime> completedAt,
      Value<String> origin,
      Value<int> rowid,
    });

final class $$ChapterCompletionRecordsTableReferences
    extends
        BaseReferences<
          _$CanonicalDatabase,
          $ChapterCompletionRecordsTable,
          ChapterCompletionRow
        > {
  $$ChapterCompletionRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CanonicalChapterRecordsTable _chapterIdTable(
    _$CanonicalDatabase db,
  ) => db.canonicalChapterRecords.createAlias(
    $_aliasNameGenerator(
      db.chapterCompletionRecords.chapterId,
      db.canonicalChapterRecords.id,
    ),
  );

  $$CanonicalChapterRecordsTableProcessedTableManager get chapterId {
    final $_column = $_itemColumn<String>('chapter_id')!;

    final manager = $$CanonicalChapterRecordsTableTableManager(
      $_db,
      $_db.canonicalChapterRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chapterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CanonicalMediaRecordsTable _mediaIdTable(_$CanonicalDatabase db) =>
      db.canonicalMediaRecords.createAlias(
        $_aliasNameGenerator(
          db.chapterCompletionRecords.mediaId,
          db.canonicalMediaRecords.id,
        ),
      );

  $$CanonicalMediaRecordsTableProcessedTableManager get mediaId {
    final $_column = $_itemColumn<String>('media_id')!;

    final manager = $$CanonicalMediaRecordsTableTableManager(
      $_db,
      $_db.canonicalMediaRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mediaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ChapterCompletionRecordsTableFilterComposer
    extends Composer<_$CanonicalDatabase, $ChapterCompletionRecordsTable> {
  $$ChapterCompletionRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  $$CanonicalChapterRecordsTableFilterComposer get chapterId {
    final $$CanonicalChapterRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.chapterId,
          referencedTable: $db.canonicalChapterRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalChapterRecordsTableFilterComposer(
                $db: $db,
                $table: $db.canonicalChapterRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CanonicalMediaRecordsTableFilterComposer get mediaId {
    final $$CanonicalMediaRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mediaId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableFilterComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ChapterCompletionRecordsTableOrderingComposer
    extends Composer<_$CanonicalDatabase, $ChapterCompletionRecordsTable> {
  $$ChapterCompletionRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  $$CanonicalChapterRecordsTableOrderingComposer get chapterId {
    final $$CanonicalChapterRecordsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.chapterId,
          referencedTable: $db.canonicalChapterRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalChapterRecordsTableOrderingComposer(
                $db: $db,
                $table: $db.canonicalChapterRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CanonicalMediaRecordsTableOrderingComposer get mediaId {
    final $$CanonicalMediaRecordsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mediaId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableOrderingComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ChapterCompletionRecordsTableAnnotationComposer
    extends Composer<_$CanonicalDatabase, $ChapterCompletionRecordsTable> {
  $$ChapterCompletionRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  $$CanonicalChapterRecordsTableAnnotationComposer get chapterId {
    final $$CanonicalChapterRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.chapterId,
          referencedTable: $db.canonicalChapterRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalChapterRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.canonicalChapterRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CanonicalMediaRecordsTableAnnotationComposer get mediaId {
    final $$CanonicalMediaRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mediaId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ChapterCompletionRecordsTableTableManager
    extends
        RootTableManager<
          _$CanonicalDatabase,
          $ChapterCompletionRecordsTable,
          ChapterCompletionRow,
          $$ChapterCompletionRecordsTableFilterComposer,
          $$ChapterCompletionRecordsTableOrderingComposer,
          $$ChapterCompletionRecordsTableAnnotationComposer,
          $$ChapterCompletionRecordsTableCreateCompanionBuilder,
          $$ChapterCompletionRecordsTableUpdateCompanionBuilder,
          (ChapterCompletionRow, $$ChapterCompletionRecordsTableReferences),
          ChapterCompletionRow,
          PrefetchHooks Function({bool chapterId, bool mediaId})
        > {
  $$ChapterCompletionRecordsTableTableManager(
    _$CanonicalDatabase db,
    $ChapterCompletionRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChapterCompletionRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ChapterCompletionRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ChapterCompletionRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> chapterId = const Value.absent(),
                Value<String> mediaId = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChapterCompletionRecordsCompanion(
                chapterId: chapterId,
                mediaId: mediaId,
                completedAt: completedAt,
                origin: origin,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String chapterId,
                required String mediaId,
                required DateTime completedAt,
                required String origin,
                Value<int> rowid = const Value.absent(),
              }) => ChapterCompletionRecordsCompanion.insert(
                chapterId: chapterId,
                mediaId: mediaId,
                completedAt: completedAt,
                origin: origin,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChapterCompletionRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({chapterId = false, mediaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (chapterId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.chapterId,
                                referencedTable:
                                    $$ChapterCompletionRecordsTableReferences
                                        ._chapterIdTable(db),
                                referencedColumn:
                                    $$ChapterCompletionRecordsTableReferences
                                        ._chapterIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (mediaId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.mediaId,
                                referencedTable:
                                    $$ChapterCompletionRecordsTableReferences
                                        ._mediaIdTable(db),
                                referencedColumn:
                                    $$ChapterCompletionRecordsTableReferences
                                        ._mediaIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ChapterCompletionRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$CanonicalDatabase,
      $ChapterCompletionRecordsTable,
      ChapterCompletionRow,
      $$ChapterCompletionRecordsTableFilterComposer,
      $$ChapterCompletionRecordsTableOrderingComposer,
      $$ChapterCompletionRecordsTableAnnotationComposer,
      $$ChapterCompletionRecordsTableCreateCompanionBuilder,
      $$ChapterCompletionRecordsTableUpdateCompanionBuilder,
      (ChapterCompletionRow, $$ChapterCompletionRecordsTableReferences),
      ChapterCompletionRow,
      PrefetchHooks Function({bool chapterId, bool mediaId})
    >;
typedef $$EpisodeCompletionRecordsTableCreateCompanionBuilder =
    EpisodeCompletionRecordsCompanion Function({
      required String episodeId,
      required String mediaId,
      required DateTime completedAt,
      required String origin,
      Value<int> rowid,
    });
typedef $$EpisodeCompletionRecordsTableUpdateCompanionBuilder =
    EpisodeCompletionRecordsCompanion Function({
      Value<String> episodeId,
      Value<String> mediaId,
      Value<DateTime> completedAt,
      Value<String> origin,
      Value<int> rowid,
    });

final class $$EpisodeCompletionRecordsTableReferences
    extends
        BaseReferences<
          _$CanonicalDatabase,
          $EpisodeCompletionRecordsTable,
          EpisodeCompletionRow
        > {
  $$EpisodeCompletionRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CanonicalEpisodeRecordsTable _episodeIdTable(
    _$CanonicalDatabase db,
  ) => db.canonicalEpisodeRecords.createAlias(
    $_aliasNameGenerator(
      db.episodeCompletionRecords.episodeId,
      db.canonicalEpisodeRecords.id,
    ),
  );

  $$CanonicalEpisodeRecordsTableProcessedTableManager get episodeId {
    final $_column = $_itemColumn<String>('episode_id')!;

    final manager = $$CanonicalEpisodeRecordsTableTableManager(
      $_db,
      $_db.canonicalEpisodeRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_episodeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CanonicalMediaRecordsTable _mediaIdTable(_$CanonicalDatabase db) =>
      db.canonicalMediaRecords.createAlias(
        $_aliasNameGenerator(
          db.episodeCompletionRecords.mediaId,
          db.canonicalMediaRecords.id,
        ),
      );

  $$CanonicalMediaRecordsTableProcessedTableManager get mediaId {
    final $_column = $_itemColumn<String>('media_id')!;

    final manager = $$CanonicalMediaRecordsTableTableManager(
      $_db,
      $_db.canonicalMediaRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mediaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EpisodeCompletionRecordsTableFilterComposer
    extends Composer<_$CanonicalDatabase, $EpisodeCompletionRecordsTable> {
  $$EpisodeCompletionRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  $$CanonicalEpisodeRecordsTableFilterComposer get episodeId {
    final $$CanonicalEpisodeRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.episodeId,
          referencedTable: $db.canonicalEpisodeRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalEpisodeRecordsTableFilterComposer(
                $db: $db,
                $table: $db.canonicalEpisodeRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CanonicalMediaRecordsTableFilterComposer get mediaId {
    final $$CanonicalMediaRecordsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mediaId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableFilterComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$EpisodeCompletionRecordsTableOrderingComposer
    extends Composer<_$CanonicalDatabase, $EpisodeCompletionRecordsTable> {
  $$EpisodeCompletionRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  $$CanonicalEpisodeRecordsTableOrderingComposer get episodeId {
    final $$CanonicalEpisodeRecordsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.episodeId,
          referencedTable: $db.canonicalEpisodeRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalEpisodeRecordsTableOrderingComposer(
                $db: $db,
                $table: $db.canonicalEpisodeRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CanonicalMediaRecordsTableOrderingComposer get mediaId {
    final $$CanonicalMediaRecordsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mediaId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableOrderingComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$EpisodeCompletionRecordsTableAnnotationComposer
    extends Composer<_$CanonicalDatabase, $EpisodeCompletionRecordsTable> {
  $$EpisodeCompletionRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  $$CanonicalEpisodeRecordsTableAnnotationComposer get episodeId {
    final $$CanonicalEpisodeRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.episodeId,
          referencedTable: $db.canonicalEpisodeRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalEpisodeRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.canonicalEpisodeRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CanonicalMediaRecordsTableAnnotationComposer get mediaId {
    final $$CanonicalMediaRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.mediaId,
          referencedTable: $db.canonicalMediaRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CanonicalMediaRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.canonicalMediaRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$EpisodeCompletionRecordsTableTableManager
    extends
        RootTableManager<
          _$CanonicalDatabase,
          $EpisodeCompletionRecordsTable,
          EpisodeCompletionRow,
          $$EpisodeCompletionRecordsTableFilterComposer,
          $$EpisodeCompletionRecordsTableOrderingComposer,
          $$EpisodeCompletionRecordsTableAnnotationComposer,
          $$EpisodeCompletionRecordsTableCreateCompanionBuilder,
          $$EpisodeCompletionRecordsTableUpdateCompanionBuilder,
          (EpisodeCompletionRow, $$EpisodeCompletionRecordsTableReferences),
          EpisodeCompletionRow,
          PrefetchHooks Function({bool episodeId, bool mediaId})
        > {
  $$EpisodeCompletionRecordsTableTableManager(
    _$CanonicalDatabase db,
    $EpisodeCompletionRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EpisodeCompletionRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$EpisodeCompletionRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$EpisodeCompletionRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> episodeId = const Value.absent(),
                Value<String> mediaId = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EpisodeCompletionRecordsCompanion(
                episodeId: episodeId,
                mediaId: mediaId,
                completedAt: completedAt,
                origin: origin,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String episodeId,
                required String mediaId,
                required DateTime completedAt,
                required String origin,
                Value<int> rowid = const Value.absent(),
              }) => EpisodeCompletionRecordsCompanion.insert(
                episodeId: episodeId,
                mediaId: mediaId,
                completedAt: completedAt,
                origin: origin,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EpisodeCompletionRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({episodeId = false, mediaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (episodeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.episodeId,
                                referencedTable:
                                    $$EpisodeCompletionRecordsTableReferences
                                        ._episodeIdTable(db),
                                referencedColumn:
                                    $$EpisodeCompletionRecordsTableReferences
                                        ._episodeIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (mediaId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.mediaId,
                                referencedTable:
                                    $$EpisodeCompletionRecordsTableReferences
                                        ._mediaIdTable(db),
                                referencedColumn:
                                    $$EpisodeCompletionRecordsTableReferences
                                        ._mediaIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EpisodeCompletionRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$CanonicalDatabase,
      $EpisodeCompletionRecordsTable,
      EpisodeCompletionRow,
      $$EpisodeCompletionRecordsTableFilterComposer,
      $$EpisodeCompletionRecordsTableOrderingComposer,
      $$EpisodeCompletionRecordsTableAnnotationComposer,
      $$EpisodeCompletionRecordsTableCreateCompanionBuilder,
      $$EpisodeCompletionRecordsTableUpdateCompanionBuilder,
      (EpisodeCompletionRow, $$EpisodeCompletionRecordsTableReferences),
      EpisodeCompletionRow,
      PrefetchHooks Function({bool episodeId, bool mediaId})
    >;

class $CanonicalDatabaseManager {
  final _$CanonicalDatabase _db;
  $CanonicalDatabaseManager(this._db);
  $$CanonicalMediaRecordsTableTableManager get canonicalMediaRecords =>
      $$CanonicalMediaRecordsTableTableManager(_db, _db.canonicalMediaRecords);
  $$CanonicalChapterRecordsTableTableManager get canonicalChapterRecords =>
      $$CanonicalChapterRecordsTableTableManager(
        _db,
        _db.canonicalChapterRecords,
      );
  $$CanonicalEpisodeRecordsTableTableManager get canonicalEpisodeRecords =>
      $$CanonicalEpisodeRecordsTableTableManager(
        _db,
        _db.canonicalEpisodeRecords,
      );
  $$CanonicalMediaBindingsTableTableManager get canonicalMediaBindings =>
      $$CanonicalMediaBindingsTableTableManager(
        _db,
        _db.canonicalMediaBindings,
      );
  $$CanonicalChapterBindingsTableTableManager get canonicalChapterBindings =>
      $$CanonicalChapterBindingsTableTableManager(
        _db,
        _db.canonicalChapterBindings,
      );
  $$CanonicalEpisodeBindingsTableTableManager get canonicalEpisodeBindings =>
      $$CanonicalEpisodeBindingsTableTableManager(
        _db,
        _db.canonicalEpisodeBindings,
      );
  $$CanonicalLibraryRecordsTableTableManager get canonicalLibraryRecords =>
      $$CanonicalLibraryRecordsTableTableManager(
        _db,
        _db.canonicalLibraryRecords,
      );
  $$CanonicalMangaProgressRecordsTableTableManager
  get canonicalMangaProgressRecords =>
      $$CanonicalMangaProgressRecordsTableTableManager(
        _db,
        _db.canonicalMangaProgressRecords,
      );
  $$CanonicalAnimeProgressRecordsTableTableManager
  get canonicalAnimeProgressRecords =>
      $$CanonicalAnimeProgressRecordsTableTableManager(
        _db,
        _db.canonicalAnimeProgressRecords,
      );
  $$CanonicalMediaAliasesTableTableManager get canonicalMediaAliases =>
      $$CanonicalMediaAliasesTableTableManager(_db, _db.canonicalMediaAliases);
  $$CanonicalMergeAuditsTableTableManager get canonicalMergeAudits =>
      $$CanonicalMergeAuditsTableTableManager(_db, _db.canonicalMergeAudits);
  $$MangaSourcePageResumesTableTableManager get mangaSourcePageResumes =>
      $$MangaSourcePageResumesTableTableManager(
        _db,
        _db.mangaSourcePageResumes,
      );
  $$AnimeSourcePlaybackResumesTableTableManager
  get animeSourcePlaybackResumes =>
      $$AnimeSourcePlaybackResumesTableTableManager(
        _db,
        _db.animeSourcePlaybackResumes,
      );
  $$PreferredMediaSourcesTableTableManager get preferredMediaSources =>
      $$PreferredMediaSourcesTableTableManager(_db, _db.preferredMediaSources);
  $$LocalAssetRecordsTableTableManager get localAssetRecords =>
      $$LocalAssetRecordsTableTableManager(_db, _db.localAssetRecords);
  $$AdapterConfigurationsTableTableManager get adapterConfigurations =>
      $$AdapterConfigurationsTableTableManager(_db, _db.adapterConfigurations);
  $$AdapterReliabilityRecordsTableTableManager get adapterReliabilityRecords =>
      $$AdapterReliabilityRecordsTableTableManager(
        _db,
        _db.adapterReliabilityRecords,
      );
  $$MetadataEnrichmentRecordsTableTableManager get metadataEnrichmentRecords =>
      $$MetadataEnrichmentRecordsTableTableManager(
        _db,
        _db.metadataEnrichmentRecords,
      );
  $$MetadataOverrideRecordsTableTableManager get metadataOverrideRecords =>
      $$MetadataOverrideRecordsTableTableManager(
        _db,
        _db.metadataOverrideRecords,
      );
  $$ChapterUserEditRecordsTableTableManager get chapterUserEditRecords =>
      $$ChapterUserEditRecordsTableTableManager(
        _db,
        _db.chapterUserEditRecords,
      );
  $$EpisodeUserEditRecordsTableTableManager get episodeUserEditRecords =>
      $$EpisodeUserEditRecordsTableTableManager(
        _db,
        _db.episodeUserEditRecords,
      );
  $$ChapterCompletionRecordsTableTableManager get chapterCompletionRecords =>
      $$ChapterCompletionRecordsTableTableManager(
        _db,
        _db.chapterCompletionRecords,
      );
  $$EpisodeCompletionRecordsTableTableManager get episodeCompletionRecords =>
      $$EpisodeCompletionRecordsTableTableManager(
        _db,
        _db.episodeCompletionRecords,
      );
}
