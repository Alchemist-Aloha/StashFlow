import 'dart:async';
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;

class Query$GetVersion {
  Query$GetVersion({required this.version, this.$__typename = 'Query'});

  factory Query$GetVersion.fromJson(Map<String, dynamic> json) {
    final l$version = json['version'];
    final l$$__typename = json['__typename'];
    return Query$GetVersion(
      version: Query$GetVersion$version.fromJson(
        (l$version as Map<String, dynamic>),
      ),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$GetVersion$version version;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$version = version;
    _resultData['version'] = l$version.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$version = version;
    final l$$__typename = $__typename;
    return Object.hashAll([l$version, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetVersion || runtimeType != other.runtimeType) {
      return false;
    }
    final l$version = version;
    final lOther$version = other.version;
    if (l$version != lOther$version) {
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

extension UtilityExtension$Query$GetVersion on Query$GetVersion {
  CopyWith$Query$GetVersion<Query$GetVersion> get copyWith =>
      CopyWith$Query$GetVersion(this, (i) => i);
}

abstract class CopyWith$Query$GetVersion<TRes> {
  factory CopyWith$Query$GetVersion(
    Query$GetVersion instance,
    TRes Function(Query$GetVersion) then,
  ) = _CopyWithImpl$Query$GetVersion;

  factory CopyWith$Query$GetVersion.stub(TRes res) =
      _CopyWithStubImpl$Query$GetVersion;

  TRes call({Query$GetVersion$version? version, String? $__typename});
  CopyWith$Query$GetVersion$version<TRes> get version;
}

class _CopyWithImpl$Query$GetVersion<TRes>
    implements CopyWith$Query$GetVersion<TRes> {
  _CopyWithImpl$Query$GetVersion(this._instance, this._then);

  final Query$GetVersion _instance;

  final TRes Function(Query$GetVersion) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? version = _undefined, Object? $__typename = _undefined}) =>
      _then(
        Query$GetVersion(
          version: version == _undefined || version == null
              ? _instance.version
              : (version as Query$GetVersion$version),
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String),
        ),
      );

  CopyWith$Query$GetVersion$version<TRes> get version {
    final local$version = _instance.version;
    return CopyWith$Query$GetVersion$version(
      local$version,
      (e) => call(version: e),
    );
  }
}

class _CopyWithStubImpl$Query$GetVersion<TRes>
    implements CopyWith$Query$GetVersion<TRes> {
  _CopyWithStubImpl$Query$GetVersion(this._res);

  TRes _res;

  call({Query$GetVersion$version? version, String? $__typename}) => _res;

  CopyWith$Query$GetVersion$version<TRes> get version =>
      CopyWith$Query$GetVersion$version.stub(_res);
}

const documentNodeQueryGetVersion = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.query,
      name: NameNode(value: 'GetVersion'),
      variableDefinitions: [],
      directives: [],
      selectionSet: SelectionSetNode(
        selections: [
          FieldNode(
            name: NameNode(value: 'version'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(
              selections: [
                FieldNode(
                  name: NameNode(value: 'version'),
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
  ],
);
Query$GetVersion _parserFn$Query$GetVersion(Map<String, dynamic> data) =>
    Query$GetVersion.fromJson(data);
typedef OnQueryComplete$Query$GetVersion =
    FutureOr<void> Function(Map<String, dynamic>?, Query$GetVersion?);

class Options$Query$GetVersion extends graphql.QueryOptions<Query$GetVersion> {
  Options$Query$GetVersion({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetVersion? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$GetVersion? onComplete,
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
                 data == null ? null : _parserFn$Query$GetVersion(data),
               ),
         onError: onError,
         document: documentNodeQueryGetVersion,
         parserFn: _parserFn$Query$GetVersion,
       );

  final OnQueryComplete$Query$GetVersion? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
    ...super.onComplete == null
        ? super.properties
        : super.properties.where((property) => property != onComplete),
    onCompleteWithParsed,
  ];
}

class WatchOptions$Query$GetVersion
    extends graphql.WatchQueryOptions<Query$GetVersion> {
  WatchOptions$Query$GetVersion({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetVersion? typedOptimisticResult,
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
         document: documentNodeQueryGetVersion,
         pollInterval: pollInterval,
         eagerlyFetchResults: eagerlyFetchResults,
         carryForwardDataOnException: carryForwardDataOnException,
         fetchResults: fetchResults,
         parserFn: _parserFn$Query$GetVersion,
       );
}

class FetchMoreOptions$Query$GetVersion extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$GetVersion({required graphql.UpdateQuery updateQuery})
    : super(updateQuery: updateQuery, document: documentNodeQueryGetVersion);
}

extension ClientExtension$Query$GetVersion on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$GetVersion>> query$GetVersion([
    Options$Query$GetVersion? options,
  ]) async => await this.query(options ?? Options$Query$GetVersion());

  graphql.ObservableQuery<Query$GetVersion> watchQuery$GetVersion([
    WatchOptions$Query$GetVersion? options,
  ]) => this.watchQuery(options ?? WatchOptions$Query$GetVersion());

  void writeQuery$GetVersion({
    required Query$GetVersion data,
    bool broadcast = true,
  }) => this.writeQuery(
    graphql.Request(
      operation: graphql.Operation(document: documentNodeQueryGetVersion),
    ),
    data: data.toJson(),
    broadcast: broadcast,
  );

  Query$GetVersion? readQuery$GetVersion({bool optimistic = true}) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(document: documentNodeQueryGetVersion),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$GetVersion.fromJson(result);
  }
}

class Query$GetVersion$version {
  Query$GetVersion$version({this.version, this.$__typename = 'Version'});

  factory Query$GetVersion$version.fromJson(Map<String, dynamic> json) {
    final l$version = json['version'];
    final l$$__typename = json['__typename'];
    return Query$GetVersion$version(
      version: (l$version as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String? version;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$version = version;
    _resultData['version'] = l$version;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$version = version;
    final l$$__typename = $__typename;
    return Object.hashAll([l$version, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetVersion$version ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$version = version;
    final lOther$version = other.version;
    if (l$version != lOther$version) {
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

extension UtilityExtension$Query$GetVersion$version
    on Query$GetVersion$version {
  CopyWith$Query$GetVersion$version<Query$GetVersion$version> get copyWith =>
      CopyWith$Query$GetVersion$version(this, (i) => i);
}

abstract class CopyWith$Query$GetVersion$version<TRes> {
  factory CopyWith$Query$GetVersion$version(
    Query$GetVersion$version instance,
    TRes Function(Query$GetVersion$version) then,
  ) = _CopyWithImpl$Query$GetVersion$version;

  factory CopyWith$Query$GetVersion$version.stub(TRes res) =
      _CopyWithStubImpl$Query$GetVersion$version;

  TRes call({String? version, String? $__typename});
}

class _CopyWithImpl$Query$GetVersion$version<TRes>
    implements CopyWith$Query$GetVersion$version<TRes> {
  _CopyWithImpl$Query$GetVersion$version(this._instance, this._then);

  final Query$GetVersion$version _instance;

  final TRes Function(Query$GetVersion$version) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? version = _undefined, Object? $__typename = _undefined}) =>
      _then(
        Query$GetVersion$version(
          version: version == _undefined
              ? _instance.version
              : (version as String?),
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String),
        ),
      );
}

class _CopyWithStubImpl$Query$GetVersion$version<TRes>
    implements CopyWith$Query$GetVersion$version<TRes> {
  _CopyWithStubImpl$Query$GetVersion$version(this._res);

  TRes _res;

  call({String? version, String? $__typename}) => _res;
}
