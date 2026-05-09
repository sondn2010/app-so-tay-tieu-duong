// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blood_sugar_entry.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBloodSugarEntryCollection on Isar {
  IsarCollection<BloodSugarEntry> get bloodSugarEntrys => this.collection();
}

const BloodSugarEntrySchema = CollectionSchema(
  name: r'BloodSugarEntry',
  id: -6448220837917693848,
  properties: {
    r'mealContext': PropertySchema(
      id: 0,
      name: r'mealContext',
      type: IsarType.string,
    ),
    r'measuredAt': PropertySchema(
      id: 1,
      name: r'measuredAt',
      type: IsarType.dateTime,
    ),
    r'note': PropertySchema(
      id: 2,
      name: r'note',
      type: IsarType.string,
    ),
    r'value': PropertySchema(
      id: 3,
      name: r'value',
      type: IsarType.double,
    )
  },
  estimateSize: _bloodSugarEntryEstimateSize,
  serialize: _bloodSugarEntrySerialize,
  deserialize: _bloodSugarEntryDeserialize,
  deserializeProp: _bloodSugarEntryDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _bloodSugarEntryGetId,
  getLinks: _bloodSugarEntryGetLinks,
  attach: _bloodSugarEntryAttach,
  version: '3.1.0+1',
);

int _bloodSugarEntryEstimateSize(
  BloodSugarEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.mealContext.length * 3;
  {
    final value = object.note;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _bloodSugarEntrySerialize(
  BloodSugarEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.mealContext);
  writer.writeDateTime(offsets[1], object.measuredAt);
  writer.writeString(offsets[2], object.note);
  writer.writeDouble(offsets[3], object.value);
}

BloodSugarEntry _bloodSugarEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BloodSugarEntry();
  object.id = id;
  object.mealContext = reader.readString(offsets[0]);
  object.measuredAt = reader.readDateTime(offsets[1]);
  object.note = reader.readStringOrNull(offsets[2]);
  object.value = reader.readDouble(offsets[3]);
  return object;
}

P _bloodSugarEntryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _bloodSugarEntryGetId(BloodSugarEntry object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _bloodSugarEntryGetLinks(BloodSugarEntry object) {
  return [];
}

void _bloodSugarEntryAttach(
    IsarCollection<dynamic> col, Id id, BloodSugarEntry object) {
  object.id = id;
}

extension BloodSugarEntryQueryWhereSort
    on QueryBuilder<BloodSugarEntry, BloodSugarEntry, QWhere> {
  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BloodSugarEntryQueryWhere
    on QueryBuilder<BloodSugarEntry, BloodSugarEntry, QWhereClause> {
  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterWhereClause> idBetween(
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

extension BloodSugarEntryQueryFilter
    on QueryBuilder<BloodSugarEntry, BloodSugarEntry, QFilterCondition> {
  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterFilterCondition>
      mealContextEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mealContext',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterFilterCondition>
      mealContextGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mealContext',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterFilterCondition>
      mealContextLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mealContext',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterFilterCondition>
      mealContextBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mealContext',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterFilterCondition>
      mealContextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mealContext',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterFilterCondition>
      mealContextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mealContext',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterFilterCondition>
      mealContextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mealContext',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterFilterCondition>
      mealContextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mealContext',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterFilterCondition>
      mealContextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mealContext',
        value: '',
      ));
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterFilterCondition>
      mealContextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mealContext',
        value: '',
      ));
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterFilterCondition>
      measuredAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'measuredAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterFilterCondition>
      measuredAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'measuredAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterFilterCondition>
      measuredAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'measuredAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterFilterCondition>
      measuredAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'measuredAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterFilterCondition>
      noteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterFilterCondition>
      noteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterFilterCondition>
      noteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterFilterCondition>
      noteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterFilterCondition>
      noteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterFilterCondition>
      noteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'note',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterFilterCondition>
      noteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterFilterCondition>
      noteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterFilterCondition>
      noteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterFilterCondition>
      noteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'note',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterFilterCondition>
      noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterFilterCondition>
      noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterFilterCondition>
      valueEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'value',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterFilterCondition>
      valueGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'value',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterFilterCondition>
      valueLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'value',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterFilterCondition>
      valueBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'value',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension BloodSugarEntryQueryObject
    on QueryBuilder<BloodSugarEntry, BloodSugarEntry, QFilterCondition> {}

extension BloodSugarEntryQueryLinks
    on QueryBuilder<BloodSugarEntry, BloodSugarEntry, QFilterCondition> {}

extension BloodSugarEntryQuerySortBy
    on QueryBuilder<BloodSugarEntry, BloodSugarEntry, QSortBy> {
  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterSortBy>
      sortByMealContext() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealContext', Sort.asc);
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterSortBy>
      sortByMealContextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealContext', Sort.desc);
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterSortBy>
      sortByMeasuredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'measuredAt', Sort.asc);
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterSortBy>
      sortByMeasuredAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'measuredAt', Sort.desc);
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterSortBy> sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterSortBy>
      sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterSortBy> sortByValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.asc);
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterSortBy>
      sortByValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.desc);
    });
  }
}

extension BloodSugarEntryQuerySortThenBy
    on QueryBuilder<BloodSugarEntry, BloodSugarEntry, QSortThenBy> {
  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterSortBy>
      thenByMealContext() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealContext', Sort.asc);
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterSortBy>
      thenByMealContextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealContext', Sort.desc);
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterSortBy>
      thenByMeasuredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'measuredAt', Sort.asc);
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterSortBy>
      thenByMeasuredAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'measuredAt', Sort.desc);
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterSortBy> thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterSortBy>
      thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterSortBy> thenByValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.asc);
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QAfterSortBy>
      thenByValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'value', Sort.desc);
    });
  }
}

extension BloodSugarEntryQueryWhereDistinct
    on QueryBuilder<BloodSugarEntry, BloodSugarEntry, QDistinct> {
  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QDistinct>
      distinctByMealContext({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mealContext', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QDistinct>
      distinctByMeasuredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'measuredAt');
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QDistinct> distinctByNote(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BloodSugarEntry, BloodSugarEntry, QDistinct> distinctByValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'value');
    });
  }
}

extension BloodSugarEntryQueryProperty
    on QueryBuilder<BloodSugarEntry, BloodSugarEntry, QQueryProperty> {
  QueryBuilder<BloodSugarEntry, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BloodSugarEntry, String, QQueryOperations>
      mealContextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mealContext');
    });
  }

  QueryBuilder<BloodSugarEntry, DateTime, QQueryOperations>
      measuredAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'measuredAt');
    });
  }

  QueryBuilder<BloodSugarEntry, String?, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<BloodSugarEntry, double, QQueryOperations> valueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'value');
    });
  }
}
