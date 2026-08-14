// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $FundsTable extends Funds with TableInfo<$FundsTable, FundData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FundsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetMinorUnitsMeta = const VerificationMeta(
    'targetMinorUnits',
  );
  @override
  late final GeneratedColumn<int> targetMinorUnits = GeneratedColumn<int>(
    'target_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetDateMeta = const VerificationMeta(
    'targetDate',
  );
  @override
  late final GeneratedColumn<String> targetDate = GeneratedColumn<String>(
    'target_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contributionFrequencyMeta =
      const VerificationMeta('contributionFrequency');
  @override
  late final GeneratedColumn<int> contributionFrequency = GeneratedColumn<int>(
    'contribution_frequency',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    targetMinorUnits,
    currencyCode,
    startDate,
    targetDate,
    contributionFrequency,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'funds';
  @override
  VerificationContext validateIntegrity(
    Insertable<FundData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('target_minor_units')) {
      context.handle(
        _targetMinorUnitsMeta,
        targetMinorUnits.isAcceptableOrUnknown(
          data['target_minor_units']!,
          _targetMinorUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetMinorUnitsMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('target_date')) {
      context.handle(
        _targetDateMeta,
        targetDate.isAcceptableOrUnknown(data['target_date']!, _targetDateMeta),
      );
    } else if (isInserting) {
      context.missing(_targetDateMeta);
    }
    if (data.containsKey('contribution_frequency')) {
      context.handle(
        _contributionFrequencyMeta,
        contributionFrequency.isAcceptableOrUnknown(
          data['contribution_frequency']!,
          _contributionFrequencyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contributionFrequencyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FundData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FundData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      targetMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_minor_units'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_date'],
      )!,
      targetDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_date'],
      )!,
      contributionFrequency: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}contribution_frequency'],
      )!,
    );
  }

  @override
  $FundsTable createAlias(String alias) {
    return $FundsTable(attachedDatabase, alias);
  }
}

class FundData extends DataClass implements Insertable<FundData> {
  final String id;
  final String name;
  final int targetMinorUnits;
  final String currencyCode;
  final String startDate;
  final String targetDate;
  final int contributionFrequency;
  const FundData({
    required this.id,
    required this.name,
    required this.targetMinorUnits,
    required this.currencyCode,
    required this.startDate,
    required this.targetDate,
    required this.contributionFrequency,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['target_minor_units'] = Variable<int>(targetMinorUnits);
    map['currency_code'] = Variable<String>(currencyCode);
    map['start_date'] = Variable<String>(startDate);
    map['target_date'] = Variable<String>(targetDate);
    map['contribution_frequency'] = Variable<int>(contributionFrequency);
    return map;
  }

  FundsCompanion toCompanion(bool nullToAbsent) {
    return FundsCompanion(
      id: Value(id),
      name: Value(name),
      targetMinorUnits: Value(targetMinorUnits),
      currencyCode: Value(currencyCode),
      startDate: Value(startDate),
      targetDate: Value(targetDate),
      contributionFrequency: Value(contributionFrequency),
    );
  }

  factory FundData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FundData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      targetMinorUnits: serializer.fromJson<int>(json['targetMinorUnits']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      startDate: serializer.fromJson<String>(json['startDate']),
      targetDate: serializer.fromJson<String>(json['targetDate']),
      contributionFrequency: serializer.fromJson<int>(
        json['contributionFrequency'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'targetMinorUnits': serializer.toJson<int>(targetMinorUnits),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'startDate': serializer.toJson<String>(startDate),
      'targetDate': serializer.toJson<String>(targetDate),
      'contributionFrequency': serializer.toJson<int>(contributionFrequency),
    };
  }

  FundData copyWith({
    String? id,
    String? name,
    int? targetMinorUnits,
    String? currencyCode,
    String? startDate,
    String? targetDate,
    int? contributionFrequency,
  }) => FundData(
    id: id ?? this.id,
    name: name ?? this.name,
    targetMinorUnits: targetMinorUnits ?? this.targetMinorUnits,
    currencyCode: currencyCode ?? this.currencyCode,
    startDate: startDate ?? this.startDate,
    targetDate: targetDate ?? this.targetDate,
    contributionFrequency: contributionFrequency ?? this.contributionFrequency,
  );
  FundData copyWithCompanion(FundsCompanion data) {
    return FundData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      targetMinorUnits: data.targetMinorUnits.present
          ? data.targetMinorUnits.value
          : this.targetMinorUnits,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      targetDate: data.targetDate.present
          ? data.targetDate.value
          : this.targetDate,
      contributionFrequency: data.contributionFrequency.present
          ? data.contributionFrequency.value
          : this.contributionFrequency,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FundData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('targetMinorUnits: $targetMinorUnits, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('startDate: $startDate, ')
          ..write('targetDate: $targetDate, ')
          ..write('contributionFrequency: $contributionFrequency')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    targetMinorUnits,
    currencyCode,
    startDate,
    targetDate,
    contributionFrequency,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FundData &&
          other.id == this.id &&
          other.name == this.name &&
          other.targetMinorUnits == this.targetMinorUnits &&
          other.currencyCode == this.currencyCode &&
          other.startDate == this.startDate &&
          other.targetDate == this.targetDate &&
          other.contributionFrequency == this.contributionFrequency);
}

class FundsCompanion extends UpdateCompanion<FundData> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> targetMinorUnits;
  final Value<String> currencyCode;
  final Value<String> startDate;
  final Value<String> targetDate;
  final Value<int> contributionFrequency;
  final Value<int> rowid;
  const FundsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.targetMinorUnits = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.startDate = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.contributionFrequency = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FundsCompanion.insert({
    required String id,
    required String name,
    required int targetMinorUnits,
    required String currencyCode,
    required String startDate,
    required String targetDate,
    required int contributionFrequency,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       targetMinorUnits = Value(targetMinorUnits),
       currencyCode = Value(currencyCode),
       startDate = Value(startDate),
       targetDate = Value(targetDate),
       contributionFrequency = Value(contributionFrequency);
  static Insertable<FundData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? targetMinorUnits,
    Expression<String>? currencyCode,
    Expression<String>? startDate,
    Expression<String>? targetDate,
    Expression<int>? contributionFrequency,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (targetMinorUnits != null) 'target_minor_units': targetMinorUnits,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (startDate != null) 'start_date': startDate,
      if (targetDate != null) 'target_date': targetDate,
      if (contributionFrequency != null)
        'contribution_frequency': contributionFrequency,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FundsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? targetMinorUnits,
    Value<String>? currencyCode,
    Value<String>? startDate,
    Value<String>? targetDate,
    Value<int>? contributionFrequency,
    Value<int>? rowid,
  }) {
    return FundsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      targetMinorUnits: targetMinorUnits ?? this.targetMinorUnits,
      currencyCode: currencyCode ?? this.currencyCode,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      contributionFrequency:
          contributionFrequency ?? this.contributionFrequency,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (targetMinorUnits.present) {
      map['target_minor_units'] = Variable<int>(targetMinorUnits.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<String>(targetDate.value);
    }
    if (contributionFrequency.present) {
      map['contribution_frequency'] = Variable<int>(
        contributionFrequency.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FundsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('targetMinorUnits: $targetMinorUnits, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('startDate: $startDate, ')
          ..write('targetDate: $targetDate, ')
          ..write('contributionFrequency: $contributionFrequency, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, TransactionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fundIdMeta = const VerificationMeta('fundId');
  @override
  late final GeneratedColumn<String> fundId = GeneratedColumn<String>(
    'fund_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES funds (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _amountMinorUnitsMeta = const VerificationMeta(
    'amountMinorUnits',
  );
  @override
  late final GeneratedColumn<int> amountMinorUnits = GeneratedColumn<int>(
    'amount_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fundId,
    amountMinorUnits,
    date,
    type,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('fund_id')) {
      context.handle(
        _fundIdMeta,
        fundId.isAcceptableOrUnknown(data['fund_id']!, _fundIdMeta),
      );
    } else if (isInserting) {
      context.missing(_fundIdMeta);
    }
    if (data.containsKey('amount_minor_units')) {
      context.handle(
        _amountMinorUnitsMeta,
        amountMinorUnits.isAcceptableOrUnknown(
          data['amount_minor_units']!,
          _amountMinorUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorUnitsMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fundId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fund_id'],
      )!,
      amountMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor_units'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class TransactionData extends DataClass implements Insertable<TransactionData> {
  final String id;
  final String fundId;
  final int amountMinorUnits;
  final String date;
  final int type;
  final int createdAt;
  const TransactionData({
    required this.id,
    required this.fundId,
    required this.amountMinorUnits,
    required this.date,
    required this.type,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['fund_id'] = Variable<String>(fundId);
    map['amount_minor_units'] = Variable<int>(amountMinorUnits);
    map['date'] = Variable<String>(date);
    map['type'] = Variable<int>(type);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      fundId: Value(fundId),
      amountMinorUnits: Value(amountMinorUnits),
      date: Value(date),
      type: Value(type),
      createdAt: Value(createdAt),
    );
  }

  factory TransactionData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionData(
      id: serializer.fromJson<String>(json['id']),
      fundId: serializer.fromJson<String>(json['fundId']),
      amountMinorUnits: serializer.fromJson<int>(json['amountMinorUnits']),
      date: serializer.fromJson<String>(json['date']),
      type: serializer.fromJson<int>(json['type']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fundId': serializer.toJson<String>(fundId),
      'amountMinorUnits': serializer.toJson<int>(amountMinorUnits),
      'date': serializer.toJson<String>(date),
      'type': serializer.toJson<int>(type),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  TransactionData copyWith({
    String? id,
    String? fundId,
    int? amountMinorUnits,
    String? date,
    int? type,
    int? createdAt,
  }) => TransactionData(
    id: id ?? this.id,
    fundId: fundId ?? this.fundId,
    amountMinorUnits: amountMinorUnits ?? this.amountMinorUnits,
    date: date ?? this.date,
    type: type ?? this.type,
    createdAt: createdAt ?? this.createdAt,
  );
  TransactionData copyWithCompanion(TransactionsCompanion data) {
    return TransactionData(
      id: data.id.present ? data.id.value : this.id,
      fundId: data.fundId.present ? data.fundId.value : this.fundId,
      amountMinorUnits: data.amountMinorUnits.present
          ? data.amountMinorUnits.value
          : this.amountMinorUnits,
      date: data.date.present ? data.date.value : this.date,
      type: data.type.present ? data.type.value : this.type,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionData(')
          ..write('id: $id, ')
          ..write('fundId: $fundId, ')
          ..write('amountMinorUnits: $amountMinorUnits, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, fundId, amountMinorUnits, date, type, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionData &&
          other.id == this.id &&
          other.fundId == this.fundId &&
          other.amountMinorUnits == this.amountMinorUnits &&
          other.date == this.date &&
          other.type == this.type &&
          other.createdAt == this.createdAt);
}

class TransactionsCompanion extends UpdateCompanion<TransactionData> {
  final Value<String> id;
  final Value<String> fundId;
  final Value<int> amountMinorUnits;
  final Value<String> date;
  final Value<int> type;
  final Value<int> createdAt;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.fundId = const Value.absent(),
    this.amountMinorUnits = const Value.absent(),
    this.date = const Value.absent(),
    this.type = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required String fundId,
    required int amountMinorUnits,
    required String date,
    required int type,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fundId = Value(fundId),
       amountMinorUnits = Value(amountMinorUnits),
       date = Value(date),
       type = Value(type),
       createdAt = Value(createdAt);
  static Insertable<TransactionData> custom({
    Expression<String>? id,
    Expression<String>? fundId,
    Expression<int>? amountMinorUnits,
    Expression<String>? date,
    Expression<int>? type,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fundId != null) 'fund_id': fundId,
      if (amountMinorUnits != null) 'amount_minor_units': amountMinorUnits,
      if (date != null) 'date': date,
      if (type != null) 'type': type,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? fundId,
    Value<int>? amountMinorUnits,
    Value<String>? date,
    Value<int>? type,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      fundId: fundId ?? this.fundId,
      amountMinorUnits: amountMinorUnits ?? this.amountMinorUnits,
      date: date ?? this.date,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fundId.present) {
      map['fund_id'] = Variable<String>(fundId.value);
    }
    if (amountMinorUnits.present) {
      map['amount_minor_units'] = Variable<int>(amountMinorUnits.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('fundId: $fundId, ')
          ..write('amountMinorUnits: $amountMinorUnits, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FundsTable funds = $FundsTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [funds, transactions];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'funds',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transactions', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$FundsTableCreateCompanionBuilder =
    FundsCompanion Function({
      required String id,
      required String name,
      required int targetMinorUnits,
      required String currencyCode,
      required String startDate,
      required String targetDate,
      required int contributionFrequency,
      Value<int> rowid,
    });
typedef $$FundsTableUpdateCompanionBuilder =
    FundsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> targetMinorUnits,
      Value<String> currencyCode,
      Value<String> startDate,
      Value<String> targetDate,
      Value<int> contributionFrequency,
      Value<int> rowid,
    });

final class $$FundsTableReferences
    extends BaseReferences<_$AppDatabase, $FundsTable, FundData> {
  $$FundsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TransactionsTable, List<TransactionData>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: 'funds__id__transactions__fund_id',
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.fundId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FundsTableFilterComposer extends Composer<_$AppDatabase, $FundsTable> {
  $$FundsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetMinorUnits => $composableBuilder(
    column: $table.targetMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get contributionFrequency => $composableBuilder(
    column: $table.contributionFrequency,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.fundId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FundsTableOrderingComposer
    extends Composer<_$AppDatabase, $FundsTable> {
  $$FundsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetMinorUnits => $composableBuilder(
    column: $table.targetMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contributionFrequency => $composableBuilder(
    column: $table.contributionFrequency,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FundsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FundsTable> {
  $$FundsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get targetMinorUnits => $composableBuilder(
    column: $table.targetMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get contributionFrequency => $composableBuilder(
    column: $table.contributionFrequency,
    builder: (column) => column,
  );

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.fundId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FundsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FundsTable,
          FundData,
          $$FundsTableFilterComposer,
          $$FundsTableOrderingComposer,
          $$FundsTableAnnotationComposer,
          $$FundsTableCreateCompanionBuilder,
          $$FundsTableUpdateCompanionBuilder,
          (FundData, $$FundsTableReferences),
          FundData,
          PrefetchHooks Function({bool transactionsRefs})
        > {
  $$FundsTableTableManager(_$AppDatabase db, $FundsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FundsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FundsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FundsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> targetMinorUnits = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> startDate = const Value.absent(),
                Value<String> targetDate = const Value.absent(),
                Value<int> contributionFrequency = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FundsCompanion(
                id: id,
                name: name,
                targetMinorUnits: targetMinorUnits,
                currencyCode: currencyCode,
                startDate: startDate,
                targetDate: targetDate,
                contributionFrequency: contributionFrequency,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int targetMinorUnits,
                required String currencyCode,
                required String startDate,
                required String targetDate,
                required int contributionFrequency,
                Value<int> rowid = const Value.absent(),
              }) => FundsCompanion.insert(
                id: id,
                name: name,
                targetMinorUnits: targetMinorUnits,
                currencyCode: currencyCode,
                startDate: startDate,
                targetDate: targetDate,
                contributionFrequency: contributionFrequency,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$FundsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({transactionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (transactionsRefs) db.transactions],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transactionsRefs)
                    await $_getPrefetchedData<
                      FundData,
                      $FundsTable,
                      TransactionData
                    >(
                      currentTable: table,
                      referencedTable: $$FundsTableReferences
                          ._transactionsRefsTable(db),
                      managerFromTypedResult: (p0) => $$FundsTableReferences(
                        db,
                        table,
                        p0,
                      ).transactionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.fundId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$FundsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FundsTable,
      FundData,
      $$FundsTableFilterComposer,
      $$FundsTableOrderingComposer,
      $$FundsTableAnnotationComposer,
      $$FundsTableCreateCompanionBuilder,
      $$FundsTableUpdateCompanionBuilder,
      (FundData, $$FundsTableReferences),
      FundData,
      PrefetchHooks Function({bool transactionsRefs})
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      required String id,
      required String fundId,
      required int amountMinorUnits,
      required String date,
      required int type,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<String> id,
      Value<String> fundId,
      Value<int> amountMinorUnits,
      Value<String> date,
      Value<int> type,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$TransactionsTableReferences
    extends BaseReferences<_$AppDatabase, $TransactionsTable, TransactionData> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FundsTable _fundIdTable(_$AppDatabase db) =>
      db.funds.createAlias('transactions__fund_id__funds__id');

  $$FundsTableProcessedTableManager get fundId {
    final $_column = $_itemColumn<String>('fund_id')!;

    final manager = $$FundsTableTableManager(
      $_db,
      $_db.funds,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fundIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
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

  ColumnFilters<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FundsTableFilterComposer get fundId {
    final $$FundsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fundId,
      referencedTable: $db.funds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FundsTableFilterComposer(
            $db: $db,
            $table: $db.funds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
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

  ColumnOrderings<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FundsTableOrderingComposer get fundId {
    final $$FundsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fundId,
      referencedTable: $db.funds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FundsTableOrderingComposer(
            $db: $db,
            $table: $db.funds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$FundsTableAnnotationComposer get fundId {
    final $$FundsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fundId,
      referencedTable: $db.funds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FundsTableAnnotationComposer(
            $db: $db,
            $table: $db.funds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          TransactionData,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (TransactionData, $$TransactionsTableReferences),
          TransactionData,
          PrefetchHooks Function({bool fundId})
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> fundId = const Value.absent(),
                Value<int> amountMinorUnits = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<int> type = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                fundId: fundId,
                amountMinorUnits: amountMinorUnits,
                date: date,
                type: type,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String fundId,
                required int amountMinorUnits,
                required String date,
                required int type,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                fundId: fundId,
                amountMinorUnits: amountMinorUnits,
                date: date,
                type: type,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({fundId = false}) {
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
                    if (fundId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.fundId,
                                referencedTable: $$TransactionsTableReferences
                                    ._fundIdTable(db),
                                referencedColumn: $$TransactionsTableReferences
                                    ._fundIdTable(db)
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

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      TransactionData,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (TransactionData, $$TransactionsTableReferences),
      TransactionData,
      PrefetchHooks Function({bool fundId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FundsTableTableManager get funds =>
      $$FundsTableTableManager(_db, _db.funds);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
}
