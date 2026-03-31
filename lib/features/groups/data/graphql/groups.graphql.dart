import '../../../../core/data/graphql/schema.graphql.dart';
import 'dart:async';
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;

class Fragment$GroupData {
  Fragment$GroupData({
    required this.id,
    required this.name,
    this.date,
    this.rating100,
    this.director,
    this.synopsis,
    this.$__typename = 'Group',
  });

  factory Fragment$GroupData.fromJson(Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$name = json['name'];
    final l$date = json['date'];
    final l$rating100 = json['rating100'];
    final l$director = json['director'];
    final l$synopsis = json['synopsis'];
    final l$$__typename = json['__typename'];
    return Fragment$GroupData(
      id: (l$id as String),
      name: (l$name as String),
      date: (l$date as String?),
      rating100: (l$rating100 as int?),
      director: (l$director as String?),
      synopsis: (l$synopsis as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String id;

  final String name;

  final String? date;

  final int? rating100;

  final String? director;

  final String? synopsis;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$name = name;
    _resultData['name'] = l$name;
    final l$date = date;
    _resultData['date'] = l$date;
    final l$rating100 = rating100;
    _resultData['rating100'] = l$rating100;
    final l$director = director;
    _resultData['director'] = l$director;
    final l$synopsis = synopsis;
    _resultData['synopsis'] = l$synopsis;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$name = name;
    final l$date = date;
    final l$rating100 = rating100;
    final l$director = director;
    final l$synopsis = synopsis;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$name,
      l$date,
      l$rating100,
      l$director,
      l$synopsis,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$GroupData || runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    final l$date = date;
    final lOther$date = other.date;
    if (l$date != lOther$date) {
      return false;
    }
    final l$rating100 = rating100;
    final lOther$rating100 = other.rating100;
    if (l$rating100 != lOther$rating100) {
      return false;
    }
    final l$director = director;
    final lOther$director = other.director;
    if (l$director != lOther$director) {
      return false;
    }
    final l$synopsis = synopsis;
    final lOther$synopsis = other.synopsis;
    if (l$synopsis != lOther$synopsis) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$GroupData on Fragment$GroupData {
  CopyWith$Fragment$GroupData<Fragment$GroupData> get copyWith =>
      CopyWith$Fragment$GroupData(this, (i) => i);
}

abstract class CopyWith$Fragment$GroupData<TRes> {
  factory CopyWith$Fragment$GroupData(
    Fragment$GroupData instance,
    TRes Function(Fragment$GroupData) then,
  ) = _CopyWithImpl$Fragment$GroupData;

  factory CopyWith$Fragment$GroupData.stub(TRes res) =
      _CopyWithStubImpl$Fragment$GroupData;

  TRes call({
    String? id,
    String? name,
    String? date,
    int? rating100,
    String? director,
    String? synopsis,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$GroupData<TRes>
    implements CopyWith$Fragment$GroupData<TRes> {
  _CopyWithImpl$Fragment$GroupData(this._instance, this._then);

  final Fragment$GroupData _instance;

  final TRes Function(Fragment$GroupData) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? name = _undefined,
    Object? date = _undefined,
    Object? rating100 = _undefined,
    Object? director = _undefined,
    Object? synopsis = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Fragment$GroupData(
      id: id == _undefined || id == null ? _instance.id : (id as String),
      name: name == _undefined || name == null
          ? _instance.name
          : (name as String),
      date: date == _undefined ? _instance.date : (date as String?),
      rating100: rating100 == _undefined
          ? _instance.rating100
          : (rating100 as int?),
      director: director == _undefined
          ? _instance.director
          : (director as String?),
      synopsis: synopsis == _undefined
          ? _instance.synopsis
          : (synopsis as String?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Fragment$GroupData<TRes>
    implements CopyWith$Fragment$GroupData<TRes> {
  _CopyWithStubImpl$Fragment$GroupData(this._res);

  TRes _res;

  call({
    String? id,
    String? name,
    String? date,
    int? rating100,
    String? director,
    String? synopsis,
    String? $__typename,
  }) => _res;
}

const fragmentDefinitionGroupData = FragmentDefinitionNode(
  name: NameNode(value: 'GroupData'),
  typeCondition: TypeConditionNode(
    on: NamedTypeNode(name: NameNode(value: 'Group'), isNonNull: false),
  ),
  directives: [],
  selectionSet: SelectionSetNode(
    selections: [
      FieldNode(
        name: NameNode(value: 'id'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'name'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'date'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'rating100'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'director'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'synopsis'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: '__typename'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
    ],
  ),
);
const documentNodeFragmentGroupData = DocumentNode(
  definitions: [fragmentDefinitionGroupData],
);

extension ClientExtension$Fragment$GroupData on graphql.GraphQLClient {
  void writeFragment$GroupData({
    required Fragment$GroupData data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) => this.writeFragment(
    graphql.FragmentRequest(
      idFields: idFields,
      fragment: const graphql.Fragment(
        fragmentName: 'GroupData',
        document: documentNodeFragmentGroupData,
      ),
    ),
    data: data.toJson(),
    broadcast: broadcast,
  );

  Fragment$GroupData? readFragment$GroupData({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'GroupData',
          document: documentNodeFragmentGroupData,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$GroupData.fromJson(result);
  }
}

class Variables$Query$FindGroups {
  factory Variables$Query$FindGroups({
    Input$FindFilterType? filter,
    Input$GroupFilterType? group_filter,
  }) => Variables$Query$FindGroups._({
    if (filter != null) r'filter': filter,
    if (group_filter != null) r'group_filter': group_filter,
  });

  Variables$Query$FindGroups._(this._$data);

  factory Variables$Query$FindGroups.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('filter')) {
      final l$filter = data['filter'];
      result$data['filter'] = l$filter == null
          ? null
          : Input$FindFilterType.fromJson((l$filter as Map<String, dynamic>));
    }
    if (data.containsKey('group_filter')) {
      final l$group_filter = data['group_filter'];
      result$data['group_filter'] = l$group_filter == null
          ? null
          : Input$GroupFilterType.fromJson(
              (l$group_filter as Map<String, dynamic>),
            );
    }
    return Variables$Query$FindGroups._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$FindFilterType? get filter =>
      (_$data['filter'] as Input$FindFilterType?);

  Input$GroupFilterType? get group_filter =>
      (_$data['group_filter'] as Input$GroupFilterType?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('filter')) {
      final l$filter = filter;
      result$data['filter'] = l$filter?.toJson();
    }
    if (_$data.containsKey('group_filter')) {
      final l$group_filter = group_filter;
      result$data['group_filter'] = l$group_filter?.toJson();
    }
    return result$data;
  }

  CopyWith$Variables$Query$FindGroups<Variables$Query$FindGroups>
  get copyWith => CopyWith$Variables$Query$FindGroups(this, (i) => i);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$FindGroups ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$filter = filter;
    final lOther$filter = other.filter;
    if (_$data.containsKey('filter') != other._$data.containsKey('filter')) {
      return false;
    }
    if (l$filter != lOther$filter) {
      return false;
    }
    final l$group_filter = group_filter;
    final lOther$group_filter = other.group_filter;
    if (_$data.containsKey('group_filter') !=
        other._$data.containsKey('group_filter')) {
      return false;
    }
    if (l$group_filter != lOther$group_filter) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$filter = filter;
    final l$group_filter = group_filter;
    return Object.hashAll([
      _$data.containsKey('filter') ? l$filter : const {},
      _$data.containsKey('group_filter') ? l$group_filter : const {},
    ]);
  }
}

abstract class CopyWith$Variables$Query$FindGroups<TRes> {
  factory CopyWith$Variables$Query$FindGroups(
    Variables$Query$FindGroups instance,
    TRes Function(Variables$Query$FindGroups) then,
  ) = _CopyWithImpl$Variables$Query$FindGroups;

  factory CopyWith$Variables$Query$FindGroups.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$FindGroups;

  TRes call({
    Input$FindFilterType? filter,
    Input$GroupFilterType? group_filter,
  });
}

class _CopyWithImpl$Variables$Query$FindGroups<TRes>
    implements CopyWith$Variables$Query$FindGroups<TRes> {
  _CopyWithImpl$Variables$Query$FindGroups(this._instance, this._then);

  final Variables$Query$FindGroups _instance;

  final TRes Function(Variables$Query$FindGroups) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? filter = _undefined, Object? group_filter = _undefined}) =>
      _then(
        Variables$Query$FindGroups._({
          ..._instance._$data,
          if (filter != _undefined) 'filter': (filter as Input$FindFilterType?),
          if (group_filter != _undefined)
            'group_filter': (group_filter as Input$GroupFilterType?),
        }),
      );
}

class _CopyWithStubImpl$Variables$Query$FindGroups<TRes>
    implements CopyWith$Variables$Query$FindGroups<TRes> {
  _CopyWithStubImpl$Variables$Query$FindGroups(this._res);

  TRes _res;

  call({Input$FindFilterType? filter, Input$GroupFilterType? group_filter}) =>
      _res;
}

class Query$FindGroups {
  Query$FindGroups({required this.findGroups, this.$__typename = 'Query'});

  factory Query$FindGroups.fromJson(Map<String, dynamic> json) {
    final l$findGroups = json['findGroups'];
    final l$$__typename = json['__typename'];
    return Query$FindGroups(
      findGroups: Query$FindGroups$findGroups.fromJson(
        (l$findGroups as Map<String, dynamic>),
      ),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$FindGroups$findGroups findGroups;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$findGroups = findGroups;
    _resultData['findGroups'] = l$findGroups.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$findGroups = findGroups;
    final l$$__typename = $__typename;
    return Object.hashAll([l$findGroups, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$FindGroups || runtimeType != other.runtimeType) {
      return false;
    }
    final l$findGroups = findGroups;
    final lOther$findGroups = other.findGroups;
    if (l$findGroups != lOther$findGroups) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$FindGroups on Query$FindGroups {
  CopyWith$Query$FindGroups<Query$FindGroups> get copyWith =>
      CopyWith$Query$FindGroups(this, (i) => i);
}

abstract class CopyWith$Query$FindGroups<TRes> {
  factory CopyWith$Query$FindGroups(
    Query$FindGroups instance,
    TRes Function(Query$FindGroups) then,
  ) = _CopyWithImpl$Query$FindGroups;

  factory CopyWith$Query$FindGroups.stub(TRes res) =
      _CopyWithStubImpl$Query$FindGroups;

  TRes call({Query$FindGroups$findGroups? findGroups, String? $__typename});
  CopyWith$Query$FindGroups$findGroups<TRes> get findGroups;
}

class _CopyWithImpl$Query$FindGroups<TRes>
    implements CopyWith$Query$FindGroups<TRes> {
  _CopyWithImpl$Query$FindGroups(this._instance, this._then);

  final Query$FindGroups _instance;

  final TRes Function(Query$FindGroups) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? findGroups = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$FindGroups(
      findGroups: findGroups == _undefined || findGroups == null
          ? _instance.findGroups
          : (findGroups as Query$FindGroups$findGroups),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  CopyWith$Query$FindGroups$findGroups<TRes> get findGroups {
    final local$findGroups = _instance.findGroups;
    return CopyWith$Query$FindGroups$findGroups(
      local$findGroups,
      (e) => call(findGroups: e),
    );
  }
}

class _CopyWithStubImpl$Query$FindGroups<TRes>
    implements CopyWith$Query$FindGroups<TRes> {
  _CopyWithStubImpl$Query$FindGroups(this._res);

  TRes _res;

  call({Query$FindGroups$findGroups? findGroups, String? $__typename}) => _res;

  CopyWith$Query$FindGroups$findGroups<TRes> get findGroups =>
      CopyWith$Query$FindGroups$findGroups.stub(_res);
}

const documentNodeQueryFindGroups = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.query,
      name: NameNode(value: 'FindGroups'),
      variableDefinitions: [
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'filter')),
          type: NamedTypeNode(
            name: NameNode(value: 'FindFilterType'),
            isNonNull: false,
          ),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'group_filter')),
          type: NamedTypeNode(
            name: NameNode(value: 'GroupFilterType'),
            isNonNull: false,
          ),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
      ],
      directives: [],
      selectionSet: SelectionSetNode(
        selections: [
          FieldNode(
            name: NameNode(value: 'findGroups'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'filter'),
                value: VariableNode(name: NameNode(value: 'filter')),
              ),
              ArgumentNode(
                name: NameNode(value: 'group_filter'),
                value: VariableNode(name: NameNode(value: 'group_filter')),
              ),
            ],
            directives: [],
            selectionSet: SelectionSetNode(
              selections: [
                FieldNode(
                  name: NameNode(value: 'count'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
                FieldNode(
                  name: NameNode(value: 'groups'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: SelectionSetNode(
                    selections: [
                      FragmentSpreadNode(
                        name: NameNode(value: 'GroupData'),
                        directives: [],
                      ),
                      FieldNode(
                        name: NameNode(value: '__typename'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                    ],
                  ),
                ),
                FieldNode(
                  name: NameNode(value: '__typename'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
              ],
            ),
          ),
          FieldNode(
            name: NameNode(value: '__typename'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
        ],
      ),
    ),
    fragmentDefinitionGroupData,
  ],
);
Query$FindGroups _parserFn$Query$FindGroups(Map<String, dynamic> data) =>
    Query$FindGroups.fromJson(data);
typedef OnQueryComplete$Query$FindGroups =
    FutureOr<void> Function(Map<String, dynamic>?, Query$FindGroups?);

class Options$Query$FindGroups extends graphql.QueryOptions<Query$FindGroups> {
  Options$Query$FindGroups({
    String? operationName,
    Variables$Query$FindGroups? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$FindGroups? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$FindGroups? onComplete,
    graphql.OnQueryError? onError,
  }) : onCompleteWithParsed = onComplete,
       super(
         variables: variables?.toJson() ?? {},
         operationName: operationName,
         fetchPolicy: fetchPolicy,
         errorPolicy: errorPolicy,
         cacheRereadPolicy: cacheRereadPolicy,
         optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
         pollInterval: pollInterval,
         context: context,
         onComplete: onComplete == null
             ? null
             : (data) => onComplete(
                 data,
                 data == null ? null : _parserFn$Query$FindGroups(data),
               ),
         onError: onError,
         document: documentNodeQueryFindGroups,
         parserFn: _parserFn$Query$FindGroups,
       );

  final OnQueryComplete$Query$FindGroups? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
    ...super.onComplete == null
        ? super.properties
        : super.properties.where((property) => property != onComplete),
    onCompleteWithParsed,
  ];
}

class WatchOptions$Query$FindGroups
    extends graphql.WatchQueryOptions<Query$FindGroups> {
  WatchOptions$Query$FindGroups({
    String? operationName,
    Variables$Query$FindGroups? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$FindGroups? typedOptimisticResult,
    graphql.Context? context,
    Duration? pollInterval,
    bool? eagerlyFetchResults,
    bool carryForwardDataOnException = true,
    bool fetchResults = false,
  }) : super(
         variables: variables?.toJson() ?? {},
         operationName: operationName,
         fetchPolicy: fetchPolicy,
         errorPolicy: errorPolicy,
         cacheRereadPolicy: cacheRereadPolicy,
         optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
         context: context,
         document: documentNodeQueryFindGroups,
         pollInterval: pollInterval,
         eagerlyFetchResults: eagerlyFetchResults,
         carryForwardDataOnException: carryForwardDataOnException,
         fetchResults: fetchResults,
         parserFn: _parserFn$Query$FindGroups,
       );
}

class FetchMoreOptions$Query$FindGroups extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$FindGroups({
    required graphql.UpdateQuery updateQuery,
    Variables$Query$FindGroups? variables,
  }) : super(
         updateQuery: updateQuery,
         variables: variables?.toJson() ?? {},
         document: documentNodeQueryFindGroups,
       );
}

extension ClientExtension$Query$FindGroups on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$FindGroups>> query$FindGroups([
    Options$Query$FindGroups? options,
  ]) async => await this.query(options ?? Options$Query$FindGroups());

  graphql.ObservableQuery<Query$FindGroups> watchQuery$FindGroups([
    WatchOptions$Query$FindGroups? options,
  ]) => this.watchQuery(options ?? WatchOptions$Query$FindGroups());

  void writeQuery$FindGroups({
    required Query$FindGroups data,
    Variables$Query$FindGroups? variables,
    bool broadcast = true,
  }) => this.writeQuery(
    graphql.Request(
      operation: graphql.Operation(document: documentNodeQueryFindGroups),
      variables: variables?.toJson() ?? const {},
    ),
    data: data.toJson(),
    broadcast: broadcast,
  );

  Query$FindGroups? readQuery$FindGroups({
    Variables$Query$FindGroups? variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(document: documentNodeQueryFindGroups),
        variables: variables?.toJson() ?? const {},
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$FindGroups.fromJson(result);
  }
}

class Query$FindGroups$findGroups {
  Query$FindGroups$findGroups({
    required this.count,
    required this.groups,
    this.$__typename = 'FindGroupsResultType',
  });

  factory Query$FindGroups$findGroups.fromJson(Map<String, dynamic> json) {
    final l$count = json['count'];
    final l$groups = json['groups'];
    final l$$__typename = json['__typename'];
    return Query$FindGroups$findGroups(
      count: (l$count as int),
      groups: (l$groups as List<dynamic>)
          .map((e) => Fragment$GroupData.fromJson((e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final int count;

  final List<Fragment$GroupData> groups;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$count = count;
    _resultData['count'] = l$count;
    final l$groups = groups;
    _resultData['groups'] = l$groups.map((e) => e.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$count = count;
    final l$groups = groups;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$count,
      Object.hashAll(l$groups.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$FindGroups$findGroups ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$count = count;
    final lOther$count = other.count;
    if (l$count != lOther$count) {
      return false;
    }
    final l$groups = groups;
    final lOther$groups = other.groups;
    if (l$groups.length != lOther$groups.length) {
      return false;
    }
    for (int i = 0; i < l$groups.length; i++) {
      final l$groups$entry = l$groups[i];
      final lOther$groups$entry = lOther$groups[i];
      if (l$groups$entry != lOther$groups$entry) {
        return false;
      }
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$FindGroups$findGroups
    on Query$FindGroups$findGroups {
  CopyWith$Query$FindGroups$findGroups<Query$FindGroups$findGroups>
  get copyWith => CopyWith$Query$FindGroups$findGroups(this, (i) => i);
}

abstract class CopyWith$Query$FindGroups$findGroups<TRes> {
  factory CopyWith$Query$FindGroups$findGroups(
    Query$FindGroups$findGroups instance,
    TRes Function(Query$FindGroups$findGroups) then,
  ) = _CopyWithImpl$Query$FindGroups$findGroups;

  factory CopyWith$Query$FindGroups$findGroups.stub(TRes res) =
      _CopyWithStubImpl$Query$FindGroups$findGroups;

  TRes call({
    int? count,
    List<Fragment$GroupData>? groups,
    String? $__typename,
  });
  TRes groups(
    Iterable<Fragment$GroupData> Function(
      Iterable<CopyWith$Fragment$GroupData<Fragment$GroupData>>,
    )
    _fn,
  );
}

class _CopyWithImpl$Query$FindGroups$findGroups<TRes>
    implements CopyWith$Query$FindGroups$findGroups<TRes> {
  _CopyWithImpl$Query$FindGroups$findGroups(this._instance, this._then);

  final Query$FindGroups$findGroups _instance;

  final TRes Function(Query$FindGroups$findGroups) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? count = _undefined,
    Object? groups = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$FindGroups$findGroups(
      count: count == _undefined || count == null
          ? _instance.count
          : (count as int),
      groups: groups == _undefined || groups == null
          ? _instance.groups
          : (groups as List<Fragment$GroupData>),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  TRes groups(
    Iterable<Fragment$GroupData> Function(
      Iterable<CopyWith$Fragment$GroupData<Fragment$GroupData>>,
    )
    _fn,
  ) => call(
    groups: _fn(
      _instance.groups.map((e) => CopyWith$Fragment$GroupData(e, (i) => i)),
    ).toList(),
  );
}

class _CopyWithStubImpl$Query$FindGroups$findGroups<TRes>
    implements CopyWith$Query$FindGroups$findGroups<TRes> {
  _CopyWithStubImpl$Query$FindGroups$findGroups(this._res);

  TRes _res;

  call({int? count, List<Fragment$GroupData>? groups, String? $__typename}) =>
      _res;

  groups(_fn) => _res;
}

class Variables$Query$FindGroup {
  factory Variables$Query$FindGroup({required String id}) =>
      Variables$Query$FindGroup._({r'id': id});

  Variables$Query$FindGroup._(this._$data);

  factory Variables$Query$FindGroup.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$id = data['id'];
    result$data['id'] = (l$id as String);
    return Variables$Query$FindGroup._(result$data);
  }

  Map<String, dynamic> _$data;

  String get id => (_$data['id'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$id = id;
    result$data['id'] = l$id;
    return result$data;
  }

  CopyWith$Variables$Query$FindGroup<Variables$Query$FindGroup> get copyWith =>
      CopyWith$Variables$Query$FindGroup(this, (i) => i);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$FindGroup ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$id = id;
    return Object.hashAll([l$id]);
  }
}

abstract class CopyWith$Variables$Query$FindGroup<TRes> {
  factory CopyWith$Variables$Query$FindGroup(
    Variables$Query$FindGroup instance,
    TRes Function(Variables$Query$FindGroup) then,
  ) = _CopyWithImpl$Variables$Query$FindGroup;

  factory CopyWith$Variables$Query$FindGroup.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$FindGroup;

  TRes call({String? id});
}

class _CopyWithImpl$Variables$Query$FindGroup<TRes>
    implements CopyWith$Variables$Query$FindGroup<TRes> {
  _CopyWithImpl$Variables$Query$FindGroup(this._instance, this._then);

  final Variables$Query$FindGroup _instance;

  final TRes Function(Variables$Query$FindGroup) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? id = _undefined}) => _then(
    Variables$Query$FindGroup._({
      ..._instance._$data,
      if (id != _undefined && id != null) 'id': (id as String),
    }),
  );
}

class _CopyWithStubImpl$Variables$Query$FindGroup<TRes>
    implements CopyWith$Variables$Query$FindGroup<TRes> {
  _CopyWithStubImpl$Variables$Query$FindGroup(this._res);

  TRes _res;

  call({String? id}) => _res;
}

class Query$FindGroup {
  Query$FindGroup({this.findGroup, this.$__typename = 'Query'});

  factory Query$FindGroup.fromJson(Map<String, dynamic> json) {
    final l$findGroup = json['findGroup'];
    final l$$__typename = json['__typename'];
    return Query$FindGroup(
      findGroup: l$findGroup == null
          ? null
          : Fragment$GroupData.fromJson((l$findGroup as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Fragment$GroupData? findGroup;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$findGroup = findGroup;
    _resultData['findGroup'] = l$findGroup?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$findGroup = findGroup;
    final l$$__typename = $__typename;
    return Object.hashAll([l$findGroup, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$FindGroup || runtimeType != other.runtimeType) {
      return false;
    }
    final l$findGroup = findGroup;
    final lOther$findGroup = other.findGroup;
    if (l$findGroup != lOther$findGroup) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$FindGroup on Query$FindGroup {
  CopyWith$Query$FindGroup<Query$FindGroup> get copyWith =>
      CopyWith$Query$FindGroup(this, (i) => i);
}

abstract class CopyWith$Query$FindGroup<TRes> {
  factory CopyWith$Query$FindGroup(
    Query$FindGroup instance,
    TRes Function(Query$FindGroup) then,
  ) = _CopyWithImpl$Query$FindGroup;

  factory CopyWith$Query$FindGroup.stub(TRes res) =
      _CopyWithStubImpl$Query$FindGroup;

  TRes call({Fragment$GroupData? findGroup, String? $__typename});
  CopyWith$Fragment$GroupData<TRes> get findGroup;
}

class _CopyWithImpl$Query$FindGroup<TRes>
    implements CopyWith$Query$FindGroup<TRes> {
  _CopyWithImpl$Query$FindGroup(this._instance, this._then);

  final Query$FindGroup _instance;

  final TRes Function(Query$FindGroup) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? findGroup = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$FindGroup(
      findGroup: findGroup == _undefined
          ? _instance.findGroup
          : (findGroup as Fragment$GroupData?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  CopyWith$Fragment$GroupData<TRes> get findGroup {
    final local$findGroup = _instance.findGroup;
    return local$findGroup == null
        ? CopyWith$Fragment$GroupData.stub(_then(_instance))
        : CopyWith$Fragment$GroupData(
            local$findGroup,
            (e) => call(findGroup: e),
          );
  }
}

class _CopyWithStubImpl$Query$FindGroup<TRes>
    implements CopyWith$Query$FindGroup<TRes> {
  _CopyWithStubImpl$Query$FindGroup(this._res);

  TRes _res;

  call({Fragment$GroupData? findGroup, String? $__typename}) => _res;

  CopyWith$Fragment$GroupData<TRes> get findGroup =>
      CopyWith$Fragment$GroupData.stub(_res);
}

const documentNodeQueryFindGroup = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.query,
      name: NameNode(value: 'FindGroup'),
      variableDefinitions: [
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'id')),
          type: NamedTypeNode(name: NameNode(value: 'ID'), isNonNull: true),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
      ],
      directives: [],
      selectionSet: SelectionSetNode(
        selections: [
          FieldNode(
            name: NameNode(value: 'findGroup'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'id'),
                value: VariableNode(name: NameNode(value: 'id')),
              ),
            ],
            directives: [],
            selectionSet: SelectionSetNode(
              selections: [
                FragmentSpreadNode(
                  name: NameNode(value: 'GroupData'),
                  directives: [],
                ),
                FieldNode(
                  name: NameNode(value: '__typename'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
              ],
            ),
          ),
          FieldNode(
            name: NameNode(value: '__typename'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
        ],
      ),
    ),
    fragmentDefinitionGroupData,
  ],
);
Query$FindGroup _parserFn$Query$FindGroup(Map<String, dynamic> data) =>
    Query$FindGroup.fromJson(data);
typedef OnQueryComplete$Query$FindGroup =
    FutureOr<void> Function(Map<String, dynamic>?, Query$FindGroup?);

class Options$Query$FindGroup extends graphql.QueryOptions<Query$FindGroup> {
  Options$Query$FindGroup({
    String? operationName,
    required Variables$Query$FindGroup variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$FindGroup? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$FindGroup? onComplete,
    graphql.OnQueryError? onError,
  }) : onCompleteWithParsed = onComplete,
       super(
         variables: variables.toJson(),
         operationName: operationName,
         fetchPolicy: fetchPolicy,
         errorPolicy: errorPolicy,
         cacheRereadPolicy: cacheRereadPolicy,
         optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
         pollInterval: pollInterval,
         context: context,
         onComplete: onComplete == null
             ? null
             : (data) => onComplete(
                 data,
                 data == null ? null : _parserFn$Query$FindGroup(data),
               ),
         onError: onError,
         document: documentNodeQueryFindGroup,
         parserFn: _parserFn$Query$FindGroup,
       );

  final OnQueryComplete$Query$FindGroup? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
    ...super.onComplete == null
        ? super.properties
        : super.properties.where((property) => property != onComplete),
    onCompleteWithParsed,
  ];
}

class WatchOptions$Query$FindGroup
    extends graphql.WatchQueryOptions<Query$FindGroup> {
  WatchOptions$Query$FindGroup({
    String? operationName,
    required Variables$Query$FindGroup variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$FindGroup? typedOptimisticResult,
    graphql.Context? context,
    Duration? pollInterval,
    bool? eagerlyFetchResults,
    bool carryForwardDataOnException = true,
    bool fetchResults = false,
  }) : super(
         variables: variables.toJson(),
         operationName: operationName,
         fetchPolicy: fetchPolicy,
         errorPolicy: errorPolicy,
         cacheRereadPolicy: cacheRereadPolicy,
         optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
         context: context,
         document: documentNodeQueryFindGroup,
         pollInterval: pollInterval,
         eagerlyFetchResults: eagerlyFetchResults,
         carryForwardDataOnException: carryForwardDataOnException,
         fetchResults: fetchResults,
         parserFn: _parserFn$Query$FindGroup,
       );
}

class FetchMoreOptions$Query$FindGroup extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$FindGroup({
    required graphql.UpdateQuery updateQuery,
    required Variables$Query$FindGroup variables,
  }) : super(
         updateQuery: updateQuery,
         variables: variables.toJson(),
         document: documentNodeQueryFindGroup,
       );
}

extension ClientExtension$Query$FindGroup on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$FindGroup>> query$FindGroup(
    Options$Query$FindGroup options,
  ) async => await this.query(options);

  graphql.ObservableQuery<Query$FindGroup> watchQuery$FindGroup(
    WatchOptions$Query$FindGroup options,
  ) => this.watchQuery(options);

  void writeQuery$FindGroup({
    required Query$FindGroup data,
    required Variables$Query$FindGroup variables,
    bool broadcast = true,
  }) => this.writeQuery(
    graphql.Request(
      operation: graphql.Operation(document: documentNodeQueryFindGroup),
      variables: variables.toJson(),
    ),
    data: data.toJson(),
    broadcast: broadcast,
  );

  Query$FindGroup? readQuery$FindGroup({
    required Variables$Query$FindGroup variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(document: documentNodeQueryFindGroup),
        variables: variables.toJson(),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$FindGroup.fromJson(result);
  }
}
