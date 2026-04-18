import 'dart:async';
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;

class Query$GetStashBoxes {
  Query$GetStashBoxes({
    required this.configuration,
    this.$__typename = 'Query',
  });

  factory Query$GetStashBoxes.fromJson(Map<String, dynamic> json) {
    final l$configuration = json['configuration'];
    final l$$__typename = json['__typename'];
    return Query$GetStashBoxes(
      configuration: Query$GetStashBoxes$configuration.fromJson(
        (l$configuration as Map<String, dynamic>),
      ),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$GetStashBoxes$configuration configuration;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$configuration = configuration;
    _resultData['configuration'] = l$configuration.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$configuration = configuration;
    final l$$__typename = $__typename;
    return Object.hashAll([l$configuration, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetStashBoxes || runtimeType != other.runtimeType) {
      return false;
    }
    final l$configuration = configuration;
    final lOther$configuration = other.configuration;
    if (l$configuration != lOther$configuration) {
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

extension UtilityExtension$Query$GetStashBoxes on Query$GetStashBoxes {
  CopyWith$Query$GetStashBoxes<Query$GetStashBoxes> get copyWith =>
      CopyWith$Query$GetStashBoxes(this, (i) => i);
}

abstract class CopyWith$Query$GetStashBoxes<TRes> {
  factory CopyWith$Query$GetStashBoxes(
    Query$GetStashBoxes instance,
    TRes Function(Query$GetStashBoxes) then,
  ) = _CopyWithImpl$Query$GetStashBoxes;

  factory CopyWith$Query$GetStashBoxes.stub(TRes res) =
      _CopyWithStubImpl$Query$GetStashBoxes;

  TRes call({
    Query$GetStashBoxes$configuration? configuration,
    String? $__typename,
  });
  CopyWith$Query$GetStashBoxes$configuration<TRes> get configuration;
}

class _CopyWithImpl$Query$GetStashBoxes<TRes>
    implements CopyWith$Query$GetStashBoxes<TRes> {
  _CopyWithImpl$Query$GetStashBoxes(this._instance, this._then);

  final Query$GetStashBoxes _instance;

  final TRes Function(Query$GetStashBoxes) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? configuration = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$GetStashBoxes(
      configuration: configuration == _undefined || configuration == null
          ? _instance.configuration
          : (configuration as Query$GetStashBoxes$configuration),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  CopyWith$Query$GetStashBoxes$configuration<TRes> get configuration {
    final local$configuration = _instance.configuration;
    return CopyWith$Query$GetStashBoxes$configuration(
      local$configuration,
      (e) => call(configuration: e),
    );
  }
}

class _CopyWithStubImpl$Query$GetStashBoxes<TRes>
    implements CopyWith$Query$GetStashBoxes<TRes> {
  _CopyWithStubImpl$Query$GetStashBoxes(this._res);

  TRes _res;

  call({
    Query$GetStashBoxes$configuration? configuration,
    String? $__typename,
  }) => _res;

  CopyWith$Query$GetStashBoxes$configuration<TRes> get configuration =>
      CopyWith$Query$GetStashBoxes$configuration.stub(_res);
}

const documentNodeQueryGetStashBoxes = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.query,
      name: NameNode(value: 'GetStashBoxes'),
      variableDefinitions: [],
      directives: [],
      selectionSet: SelectionSetNode(
        selections: [
          FieldNode(
            name: NameNode(value: 'configuration'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(
              selections: [
                FieldNode(
                  name: NameNode(value: 'general'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: SelectionSetNode(
                    selections: [
                      FieldNode(
                        name: NameNode(value: 'stashBoxes'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: SelectionSetNode(
                          selections: [
                            FieldNode(
                              name: NameNode(value: 'name'),
                              alias: null,
                              arguments: [],
                              directives: [],
                              selectionSet: null,
                            ),
                            FieldNode(
                              name: NameNode(value: 'endpoint'),
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
  ],
);
Query$GetStashBoxes _parserFn$Query$GetStashBoxes(Map<String, dynamic> data) =>
    Query$GetStashBoxes.fromJson(data);
typedef OnQueryComplete$Query$GetStashBoxes =
    FutureOr<void> Function(Map<String, dynamic>?, Query$GetStashBoxes?);

class Options$Query$GetStashBoxes
    extends graphql.QueryOptions<Query$GetStashBoxes> {
  Options$Query$GetStashBoxes({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetStashBoxes? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$GetStashBoxes? onComplete,
    graphql.OnQueryError? onError,
  }) : onCompleteWithParsed = onComplete,
       super(
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
                 data == null ? null : _parserFn$Query$GetStashBoxes(data),
               ),
         onError: onError,
         document: documentNodeQueryGetStashBoxes,
         parserFn: _parserFn$Query$GetStashBoxes,
       );

  final OnQueryComplete$Query$GetStashBoxes? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
    ...super.onComplete == null
        ? super.properties
        : super.properties.where((property) => property != onComplete),
    onCompleteWithParsed,
  ];
}

class WatchOptions$Query$GetStashBoxes
    extends graphql.WatchQueryOptions<Query$GetStashBoxes> {
  WatchOptions$Query$GetStashBoxes({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetStashBoxes? typedOptimisticResult,
    graphql.Context? context,
    Duration? pollInterval,
    bool? eagerlyFetchResults,
    bool carryForwardDataOnException = true,
    bool fetchResults = false,
  }) : super(
         operationName: operationName,
         fetchPolicy: fetchPolicy,
         errorPolicy: errorPolicy,
         cacheRereadPolicy: cacheRereadPolicy,
         optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
         context: context,
         document: documentNodeQueryGetStashBoxes,
         pollInterval: pollInterval,
         eagerlyFetchResults: eagerlyFetchResults,
         carryForwardDataOnException: carryForwardDataOnException,
         fetchResults: fetchResults,
         parserFn: _parserFn$Query$GetStashBoxes,
       );
}

class FetchMoreOptions$Query$GetStashBoxes extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$GetStashBoxes({
    required graphql.UpdateQuery updateQuery,
  }) : super(
         updateQuery: updateQuery,
         document: documentNodeQueryGetStashBoxes,
       );
}

extension ClientExtension$Query$GetStashBoxes on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$GetStashBoxes>> query$GetStashBoxes([
    Options$Query$GetStashBoxes? options,
  ]) async => await this.query(options ?? Options$Query$GetStashBoxes());

  graphql.ObservableQuery<Query$GetStashBoxes> watchQuery$GetStashBoxes([
    WatchOptions$Query$GetStashBoxes? options,
  ]) => this.watchQuery(options ?? WatchOptions$Query$GetStashBoxes());

  void writeQuery$GetStashBoxes({
    required Query$GetStashBoxes data,
    bool broadcast = true,
  }) => this.writeQuery(
    graphql.Request(
      operation: graphql.Operation(document: documentNodeQueryGetStashBoxes),
    ),
    data: data.toJson(),
    broadcast: broadcast,
  );

  Query$GetStashBoxes? readQuery$GetStashBoxes({bool optimistic = true}) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(document: documentNodeQueryGetStashBoxes),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$GetStashBoxes.fromJson(result);
  }
}

class Query$GetStashBoxes$configuration {
  Query$GetStashBoxes$configuration({
    required this.general,
    this.$__typename = 'ConfigResult',
  });

  factory Query$GetStashBoxes$configuration.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$general = json['general'];
    final l$$__typename = json['__typename'];
    return Query$GetStashBoxes$configuration(
      general: Query$GetStashBoxes$configuration$general.fromJson(
        (l$general as Map<String, dynamic>),
      ),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$GetStashBoxes$configuration$general general;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$general = general;
    _resultData['general'] = l$general.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$general = general;
    final l$$__typename = $__typename;
    return Object.hashAll([l$general, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetStashBoxes$configuration ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$general = general;
    final lOther$general = other.general;
    if (l$general != lOther$general) {
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

extension UtilityExtension$Query$GetStashBoxes$configuration
    on Query$GetStashBoxes$configuration {
  CopyWith$Query$GetStashBoxes$configuration<Query$GetStashBoxes$configuration>
  get copyWith => CopyWith$Query$GetStashBoxes$configuration(this, (i) => i);
}

abstract class CopyWith$Query$GetStashBoxes$configuration<TRes> {
  factory CopyWith$Query$GetStashBoxes$configuration(
    Query$GetStashBoxes$configuration instance,
    TRes Function(Query$GetStashBoxes$configuration) then,
  ) = _CopyWithImpl$Query$GetStashBoxes$configuration;

  factory CopyWith$Query$GetStashBoxes$configuration.stub(TRes res) =
      _CopyWithStubImpl$Query$GetStashBoxes$configuration;

  TRes call({
    Query$GetStashBoxes$configuration$general? general,
    String? $__typename,
  });
  CopyWith$Query$GetStashBoxes$configuration$general<TRes> get general;
}

class _CopyWithImpl$Query$GetStashBoxes$configuration<TRes>
    implements CopyWith$Query$GetStashBoxes$configuration<TRes> {
  _CopyWithImpl$Query$GetStashBoxes$configuration(this._instance, this._then);

  final Query$GetStashBoxes$configuration _instance;

  final TRes Function(Query$GetStashBoxes$configuration) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? general = _undefined, Object? $__typename = _undefined}) =>
      _then(
        Query$GetStashBoxes$configuration(
          general: general == _undefined || general == null
              ? _instance.general
              : (general as Query$GetStashBoxes$configuration$general),
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String),
        ),
      );

  CopyWith$Query$GetStashBoxes$configuration$general<TRes> get general {
    final local$general = _instance.general;
    return CopyWith$Query$GetStashBoxes$configuration$general(
      local$general,
      (e) => call(general: e),
    );
  }
}

class _CopyWithStubImpl$Query$GetStashBoxes$configuration<TRes>
    implements CopyWith$Query$GetStashBoxes$configuration<TRes> {
  _CopyWithStubImpl$Query$GetStashBoxes$configuration(this._res);

  TRes _res;

  call({
    Query$GetStashBoxes$configuration$general? general,
    String? $__typename,
  }) => _res;

  CopyWith$Query$GetStashBoxes$configuration$general<TRes> get general =>
      CopyWith$Query$GetStashBoxes$configuration$general.stub(_res);
}

class Query$GetStashBoxes$configuration$general {
  Query$GetStashBoxes$configuration$general({
    required this.stashBoxes,
    this.$__typename = 'ConfigGeneralResult',
  });

  factory Query$GetStashBoxes$configuration$general.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$stashBoxes = json['stashBoxes'];
    final l$$__typename = json['__typename'];
    return Query$GetStashBoxes$configuration$general(
      stashBoxes: (l$stashBoxes as List<dynamic>)
          .map(
            (e) =>
                Query$GetStashBoxes$configuration$general$stashBoxes.fromJson(
                  (e as Map<String, dynamic>),
                ),
          )
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Query$GetStashBoxes$configuration$general$stashBoxes> stashBoxes;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$stashBoxes = stashBoxes;
    _resultData['stashBoxes'] = l$stashBoxes.map((e) => e.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$stashBoxes = stashBoxes;
    final l$$__typename = $__typename;
    return Object.hashAll([
      Object.hashAll(l$stashBoxes.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetStashBoxes$configuration$general ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$stashBoxes = stashBoxes;
    final lOther$stashBoxes = other.stashBoxes;
    if (l$stashBoxes.length != lOther$stashBoxes.length) {
      return false;
    }
    for (int i = 0; i < l$stashBoxes.length; i++) {
      final l$stashBoxes$entry = l$stashBoxes[i];
      final lOther$stashBoxes$entry = lOther$stashBoxes[i];
      if (l$stashBoxes$entry != lOther$stashBoxes$entry) {
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

extension UtilityExtension$Query$GetStashBoxes$configuration$general
    on Query$GetStashBoxes$configuration$general {
  CopyWith$Query$GetStashBoxes$configuration$general<
    Query$GetStashBoxes$configuration$general
  >
  get copyWith =>
      CopyWith$Query$GetStashBoxes$configuration$general(this, (i) => i);
}

abstract class CopyWith$Query$GetStashBoxes$configuration$general<TRes> {
  factory CopyWith$Query$GetStashBoxes$configuration$general(
    Query$GetStashBoxes$configuration$general instance,
    TRes Function(Query$GetStashBoxes$configuration$general) then,
  ) = _CopyWithImpl$Query$GetStashBoxes$configuration$general;

  factory CopyWith$Query$GetStashBoxes$configuration$general.stub(TRes res) =
      _CopyWithStubImpl$Query$GetStashBoxes$configuration$general;

  TRes call({
    List<Query$GetStashBoxes$configuration$general$stashBoxes>? stashBoxes,
    String? $__typename,
  });
  TRes stashBoxes(
    Iterable<Query$GetStashBoxes$configuration$general$stashBoxes> Function(
      Iterable<
        CopyWith$Query$GetStashBoxes$configuration$general$stashBoxes<
          Query$GetStashBoxes$configuration$general$stashBoxes
        >
      >,
    )
    _fn,
  );
}

class _CopyWithImpl$Query$GetStashBoxes$configuration$general<TRes>
    implements CopyWith$Query$GetStashBoxes$configuration$general<TRes> {
  _CopyWithImpl$Query$GetStashBoxes$configuration$general(
    this._instance,
    this._then,
  );

  final Query$GetStashBoxes$configuration$general _instance;

  final TRes Function(Query$GetStashBoxes$configuration$general) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? stashBoxes = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$GetStashBoxes$configuration$general(
      stashBoxes: stashBoxes == _undefined || stashBoxes == null
          ? _instance.stashBoxes
          : (stashBoxes
                as List<Query$GetStashBoxes$configuration$general$stashBoxes>),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  TRes stashBoxes(
    Iterable<Query$GetStashBoxes$configuration$general$stashBoxes> Function(
      Iterable<
        CopyWith$Query$GetStashBoxes$configuration$general$stashBoxes<
          Query$GetStashBoxes$configuration$general$stashBoxes
        >
      >,
    )
    _fn,
  ) => call(
    stashBoxes: _fn(
      _instance.stashBoxes.map(
        (e) => CopyWith$Query$GetStashBoxes$configuration$general$stashBoxes(
          e,
          (i) => i,
        ),
      ),
    ).toList(),
  );
}

class _CopyWithStubImpl$Query$GetStashBoxes$configuration$general<TRes>
    implements CopyWith$Query$GetStashBoxes$configuration$general<TRes> {
  _CopyWithStubImpl$Query$GetStashBoxes$configuration$general(this._res);

  TRes _res;

  call({
    List<Query$GetStashBoxes$configuration$general$stashBoxes>? stashBoxes,
    String? $__typename,
  }) => _res;

  stashBoxes(_fn) => _res;
}

class Query$GetStashBoxes$configuration$general$stashBoxes {
  Query$GetStashBoxes$configuration$general$stashBoxes({
    required this.name,
    required this.endpoint,
    this.$__typename = 'StashBox',
  });

  factory Query$GetStashBoxes$configuration$general$stashBoxes.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$name = json['name'];
    final l$endpoint = json['endpoint'];
    final l$$__typename = json['__typename'];
    return Query$GetStashBoxes$configuration$general$stashBoxes(
      name: (l$name as String),
      endpoint: (l$endpoint as String),
      $__typename: (l$$__typename as String),
    );
  }

  final String name;

  final String endpoint;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$name = name;
    _resultData['name'] = l$name;
    final l$endpoint = endpoint;
    _resultData['endpoint'] = l$endpoint;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$name = name;
    final l$endpoint = endpoint;
    final l$$__typename = $__typename;
    return Object.hashAll([l$name, l$endpoint, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetStashBoxes$configuration$general$stashBoxes ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    final l$endpoint = endpoint;
    final lOther$endpoint = other.endpoint;
    if (l$endpoint != lOther$endpoint) {
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

extension UtilityExtension$Query$GetStashBoxes$configuration$general$stashBoxes
    on Query$GetStashBoxes$configuration$general$stashBoxes {
  CopyWith$Query$GetStashBoxes$configuration$general$stashBoxes<
    Query$GetStashBoxes$configuration$general$stashBoxes
  >
  get copyWith => CopyWith$Query$GetStashBoxes$configuration$general$stashBoxes(
    this,
    (i) => i,
  );
}

abstract class CopyWith$Query$GetStashBoxes$configuration$general$stashBoxes<
  TRes
> {
  factory CopyWith$Query$GetStashBoxes$configuration$general$stashBoxes(
    Query$GetStashBoxes$configuration$general$stashBoxes instance,
    TRes Function(Query$GetStashBoxes$configuration$general$stashBoxes) then,
  ) = _CopyWithImpl$Query$GetStashBoxes$configuration$general$stashBoxes;

  factory CopyWith$Query$GetStashBoxes$configuration$general$stashBoxes.stub(
    TRes res,
  ) = _CopyWithStubImpl$Query$GetStashBoxes$configuration$general$stashBoxes;

  TRes call({String? name, String? endpoint, String? $__typename});
}

class _CopyWithImpl$Query$GetStashBoxes$configuration$general$stashBoxes<TRes>
    implements
        CopyWith$Query$GetStashBoxes$configuration$general$stashBoxes<TRes> {
  _CopyWithImpl$Query$GetStashBoxes$configuration$general$stashBoxes(
    this._instance,
    this._then,
  );

  final Query$GetStashBoxes$configuration$general$stashBoxes _instance;

  final TRes Function(Query$GetStashBoxes$configuration$general$stashBoxes)
  _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? name = _undefined,
    Object? endpoint = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$GetStashBoxes$configuration$general$stashBoxes(
      name: name == _undefined || name == null
          ? _instance.name
          : (name as String),
      endpoint: endpoint == _undefined || endpoint == null
          ? _instance.endpoint
          : (endpoint as String),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Query$GetStashBoxes$configuration$general$stashBoxes<
  TRes
>
    implements
        CopyWith$Query$GetStashBoxes$configuration$general$stashBoxes<TRes> {
  _CopyWithStubImpl$Query$GetStashBoxes$configuration$general$stashBoxes(
    this._res,
  );

  TRes _res;

  call({String? name, String? endpoint, String? $__typename}) => _res;
}
