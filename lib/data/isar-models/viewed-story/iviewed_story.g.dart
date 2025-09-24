// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'iviewed_story.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIviewedStoryCollection on Isar {
  IsarCollection<IviewedStory> get iviewedStorys => this.collection();
}

const IviewedStorySchema = CollectionSchema(
  name: r'IviewedStory',
  id: 1113704919893367866,
  properties: {
    r'storyId': PropertySchema(
      id: 0,
      name: r'storyId',
      type: IsarType.string,
    )
  },
  estimateSize: _iviewedStoryEstimateSize,
  serialize: _iviewedStorySerialize,
  deserialize: _iviewedStoryDeserialize,
  deserializeProp: _iviewedStoryDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _iviewedStoryGetId,
  getLinks: _iviewedStoryGetLinks,
  attach: _iviewedStoryAttach,
  version: '3.1.0+1',
);

int _iviewedStoryEstimateSize(
  IviewedStory object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.storyId.length * 3;
  return bytesCount;
}

void _iviewedStorySerialize(
  IviewedStory object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.storyId);
}

IviewedStory _iviewedStoryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IviewedStory(
    storyId: reader.readString(offsets[0]),
  );
  object.id = id;
  return object;
}

P _iviewedStoryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _iviewedStoryGetId(IviewedStory object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _iviewedStoryGetLinks(IviewedStory object) {
  return [];
}

void _iviewedStoryAttach(
    IsarCollection<dynamic> col, Id id, IviewedStory object) {
  object.id = id;
}

extension IviewedStoryQueryWhereSort
    on QueryBuilder<IviewedStory, IviewedStory, QWhere> {
  QueryBuilder<IviewedStory, IviewedStory, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IviewedStoryQueryWhere
    on QueryBuilder<IviewedStory, IviewedStory, QWhereClause> {
  QueryBuilder<IviewedStory, IviewedStory, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IviewedStory, IviewedStory, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<IviewedStory, IviewedStory, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IviewedStory, IviewedStory, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IviewedStory, IviewedStory, QAfterWhereClause> idBetween(
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

extension IviewedStoryQueryFilter
    on QueryBuilder<IviewedStory, IviewedStory, QFilterCondition> {
  QueryBuilder<IviewedStory, IviewedStory, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IviewedStory, IviewedStory, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<IviewedStory, IviewedStory, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<IviewedStory, IviewedStory, QAfterFilterCondition> idBetween(
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

  QueryBuilder<IviewedStory, IviewedStory, QAfterFilterCondition>
      storyIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'storyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IviewedStory, IviewedStory, QAfterFilterCondition>
      storyIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'storyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IviewedStory, IviewedStory, QAfterFilterCondition>
      storyIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'storyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IviewedStory, IviewedStory, QAfterFilterCondition>
      storyIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'storyId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IviewedStory, IviewedStory, QAfterFilterCondition>
      storyIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'storyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IviewedStory, IviewedStory, QAfterFilterCondition>
      storyIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'storyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IviewedStory, IviewedStory, QAfterFilterCondition>
      storyIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'storyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IviewedStory, IviewedStory, QAfterFilterCondition>
      storyIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'storyId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IviewedStory, IviewedStory, QAfterFilterCondition>
      storyIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'storyId',
        value: '',
      ));
    });
  }

  QueryBuilder<IviewedStory, IviewedStory, QAfterFilterCondition>
      storyIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'storyId',
        value: '',
      ));
    });
  }
}

extension IviewedStoryQueryObject
    on QueryBuilder<IviewedStory, IviewedStory, QFilterCondition> {}

extension IviewedStoryQueryLinks
    on QueryBuilder<IviewedStory, IviewedStory, QFilterCondition> {}

extension IviewedStoryQuerySortBy
    on QueryBuilder<IviewedStory, IviewedStory, QSortBy> {
  QueryBuilder<IviewedStory, IviewedStory, QAfterSortBy> sortByStoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storyId', Sort.asc);
    });
  }

  QueryBuilder<IviewedStory, IviewedStory, QAfterSortBy> sortByStoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storyId', Sort.desc);
    });
  }
}

extension IviewedStoryQuerySortThenBy
    on QueryBuilder<IviewedStory, IviewedStory, QSortThenBy> {
  QueryBuilder<IviewedStory, IviewedStory, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IviewedStory, IviewedStory, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IviewedStory, IviewedStory, QAfterSortBy> thenByStoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storyId', Sort.asc);
    });
  }

  QueryBuilder<IviewedStory, IviewedStory, QAfterSortBy> thenByStoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storyId', Sort.desc);
    });
  }
}

extension IviewedStoryQueryWhereDistinct
    on QueryBuilder<IviewedStory, IviewedStory, QDistinct> {
  QueryBuilder<IviewedStory, IviewedStory, QDistinct> distinctByStoryId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'storyId', caseSensitive: caseSensitive);
    });
  }
}

extension IviewedStoryQueryProperty
    on QueryBuilder<IviewedStory, IviewedStory, QQueryProperty> {
  QueryBuilder<IviewedStory, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IviewedStory, String, QQueryOperations> storyIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'storyId');
    });
  }
}
