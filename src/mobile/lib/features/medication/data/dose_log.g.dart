// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dose_log.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDoseLogCollection on Isar {
  IsarCollection<DoseLog> get doseLogs => this.collection();
}

const DoseLogSchema = CollectionSchema(
  name: r'DoseLog',
  id: -6875638677250359335,
  properties: {
    r'medicationId': PropertySchema(
      id: 0,
      name: r'medicationId',
      type: IsarType.long,
    ),
    r'slot': PropertySchema(
      id: 1,
      name: r'slot',
      type: IsarType.string,
    ),
    r'taken': PropertySchema(
      id: 2,
      name: r'taken',
      type: IsarType.bool,
    ),
    r'takenAt': PropertySchema(
      id: 3,
      name: r'takenAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _doseLogEstimateSize,
  serialize: _doseLogSerialize,
  deserialize: _doseLogDeserialize,
  deserializeProp: _doseLogDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _doseLogGetId,
  getLinks: _doseLogGetLinks,
  attach: _doseLogAttach,
  version: '3.1.0+1',
);

int _doseLogEstimateSize(
  DoseLog object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.slot.length * 3;
  return bytesCount;
}

void _doseLogSerialize(
  DoseLog object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.medicationId);
  writer.writeString(offsets[1], object.slot);
  writer.writeBool(offsets[2], object.taken);
  writer.writeDateTime(offsets[3], object.takenAt);
}

DoseLog _doseLogDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DoseLog();
  object.id = id;
  object.medicationId = reader.readLong(offsets[0]);
  object.slot = reader.readString(offsets[1]);
  object.taken = reader.readBool(offsets[2]);
  object.takenAt = reader.readDateTime(offsets[3]);
  return object;
}

P _doseLogDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _doseLogGetId(DoseLog object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _doseLogGetLinks(DoseLog object) {
  return [];
}

void _doseLogAttach(IsarCollection<dynamic> col, Id id, DoseLog object) {
  object.id = id;
}

extension DoseLogQueryWhereSort on QueryBuilder<DoseLog, DoseLog, QWhere> {
  QueryBuilder<DoseLog, DoseLog, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DoseLogQueryWhere on QueryBuilder<DoseLog, DoseLog, QWhereClause> {
  QueryBuilder<DoseLog, DoseLog, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DoseLogQueryFilter
    on QueryBuilder<DoseLog, DoseLog, QFilterCondition> {
  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> medicationIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'medicationId',
        value: value,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> medicationIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'medicationId',
        value: value,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> medicationIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'medicationId',
        value: value,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> medicationIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'medicationId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> slotEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'slot',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> slotGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'slot',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> slotLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'slot',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> slotBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'slot',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> slotStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'slot',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> slotEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'slot',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> slotContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'slot',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> slotMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'slot',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> slotIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'slot',
        value: '',
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> slotIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'slot',
        value: '',
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> takenEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'taken',
        value: value,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> takenAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'takenAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> takenAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'takenAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> takenAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'takenAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterFilterCondition> takenAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'takenAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DoseLogQueryObject
    on QueryBuilder<DoseLog, DoseLog, QFilterCondition> {}

extension DoseLogQueryLinks
    on QueryBuilder<DoseLog, DoseLog, QFilterCondition> {}

extension DoseLogQuerySortBy on QueryBuilder<DoseLog, DoseLog, QSortBy> {
  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> sortByMedicationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'medicationId', Sort.asc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> sortByMedicationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'medicationId', Sort.desc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> sortBySlot() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slot', Sort.asc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> sortBySlotDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slot', Sort.desc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> sortByTaken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taken', Sort.asc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> sortByTakenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taken', Sort.desc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> sortByTakenAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'takenAt', Sort.asc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> sortByTakenAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'takenAt', Sort.desc);
    });
  }
}

extension DoseLogQuerySortThenBy
    on QueryBuilder<DoseLog, DoseLog, QSortThenBy> {
  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> thenByMedicationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'medicationId', Sort.asc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> thenByMedicationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'medicationId', Sort.desc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> thenBySlot() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slot', Sort.asc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> thenBySlotDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slot', Sort.desc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> thenByTaken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taken', Sort.asc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> thenByTakenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taken', Sort.desc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> thenByTakenAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'takenAt', Sort.asc);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QAfterSortBy> thenByTakenAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'takenAt', Sort.desc);
    });
  }
}

extension DoseLogQueryWhereDistinct
    on QueryBuilder<DoseLog, DoseLog, QDistinct> {
  QueryBuilder<DoseLog, DoseLog, QDistinct> distinctByMedicationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'medicationId');
    });
  }

  QueryBuilder<DoseLog, DoseLog, QDistinct> distinctBySlot(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'slot', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DoseLog, DoseLog, QDistinct> distinctByTaken() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'taken');
    });
  }

  QueryBuilder<DoseLog, DoseLog, QDistinct> distinctByTakenAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'takenAt');
    });
  }
}

extension DoseLogQueryProperty
    on QueryBuilder<DoseLog, DoseLog, QQueryProperty> {
  QueryBuilder<DoseLog, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DoseLog, int, QQueryOperations> medicationIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'medicationId');
    });
  }

  QueryBuilder<DoseLog, String, QQueryOperations> slotProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'slot');
    });
  }

  QueryBuilder<DoseLog, bool, QQueryOperations> takenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'taken');
    });
  }

  QueryBuilder<DoseLog, DateTime, QQueryOperations> takenAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'takenAt');
    });
  }
}
