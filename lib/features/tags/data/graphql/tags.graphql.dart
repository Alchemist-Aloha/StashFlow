import '../../../../core/data/graphql/schema.graphql.dart';
import 'dart:async';
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;

class Fragment$TagData {
  Fragment$TagData({
    required this.id,
    required this.name,
    this.description,
    this.image_path,
    required this.scene_count,
    required this.image_count,
    required this.gallery_count,
    required this.performer_count,
    required this.favorite,
    this.$__typename = 'Tag',
  });

  factory Fragment$TagData.fromJson(Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$name = json['name'];
    final l$description = json['description'];
    final l$image_path = json['image_path'];
    final l$scene_count = json['scene_count'];
    final l$image_count = json['image_count'];
    final l$gallery_count = json['gallery_count'];
    final l$performer_count = json['performer_count'];
    final l$favorite = json['favorite'];
    final l$$__typename = json['__typename'];
    return Fragment$TagData(
      id: (l$id as String),
      name: (l$name as String),
      description: (l$description as String?),
      image_path: (l$image_path as String?),
      scene_count: (l$scene_count as int),
      image_count: (l$image_count as int),
      gallery_count: (l$gallery_count as int),
      performer_count: (l$performer_count as int),
      favorite: (l$favorite as bool),
      $__typename: (l$$__typename as String),
    );
  }

  final String id;

  final String name;

  final String? description;

  final String? image_path;

  final int scene_count;

  final int image_count;

  final int gallery_count;

  final int performer_count;

  final bool favorite;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$name = name;
    _resultData['name'] = l$name;
    final l$description = description;
    _resultData['description'] = l$description;
    final l$image_path = image_path;
    _resultData['image_path'] = l$image_path;
    final l$scene_count = scene_count;
    _resultData['scene_count'] = l$scene_count;
    final l$image_count = image_count;
    _resultData['image_count'] = l$image_count;
    final l$gallery_count = gallery_count;
    _resultData['gallery_count'] = l$gallery_count;
    final l$performer_count = performer_count;
    _resultData['performer_count'] = l$performer_count;
    final l$favorite = favorite;
    _resultData['favorite'] = l$favorite;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$name = name;
    final l$description = description;
    final l$image_path = image_path;
    final l$scene_count = scene_count;
    final l$image_count = image_count;
    final l$gallery_count = gallery_count;
    final l$performer_count = performer_count;
    final l$favorite = favorite;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$name,
      l$description,
      l$image_path,
      l$scene_count,
      l$image_count,
      l$gallery_count,
      l$performer_count,
      l$favorite,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$TagData || runtimeType != other.runtimeType) {
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
    final l$description = description;
    final lOther$description = other.description;
    if (l$description != lOther$description) {
      return false;
    }
    final l$image_path = image_path;
    final lOther$image_path = other.image_path;
    if (l$image_path != lOther$image_path) {
      return false;
    }
    final l$scene_count = scene_count;
    final lOther$scene_count = other.scene_count;
    if (l$scene_count != lOther$scene_count) {
      return false;
    }
    final l$image_count = image_count;
    final lOther$image_count = other.image_count;
    if (l$image_count != lOther$image_count) {
      return false;
    }
    final l$gallery_count = gallery_count;
    final lOther$gallery_count = other.gallery_count;
    if (l$gallery_count != lOther$gallery_count) {
      return false;
    }
    final l$performer_count = performer_count;
    final lOther$performer_count = other.performer_count;
    if (l$performer_count != lOther$performer_count) {
      return false;
    }
    final l$favorite = favorite;
    final lOther$favorite = other.favorite;
    if (l$favorite != lOther$favorite) {
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

extension UtilityExtension$Fragment$TagData on Fragment$TagData {
  CopyWith$Fragment$TagData<Fragment$TagData> get copyWith =>
      CopyWith$Fragment$TagData(this, (i) => i);
}

abstract class CopyWith$Fragment$TagData<TRes> {
  factory CopyWith$Fragment$TagData(
    Fragment$TagData instance,
    TRes Function(Fragment$TagData) then,
  ) = _CopyWithImpl$Fragment$TagData;

  factory CopyWith$Fragment$TagData.stub(TRes res) =
      _CopyWithStubImpl$Fragment$TagData;

  TRes call({
    String? id,
    String? name,
    String? description,
    String? image_path,
    int? scene_count,
    int? image_count,
    int? gallery_count,
    int? performer_count,
    bool? favorite,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$TagData<TRes>
    implements CopyWith$Fragment$TagData<TRes> {
  _CopyWithImpl$Fragment$TagData(this._instance, this._then);

  final Fragment$TagData _instance;

  final TRes Function(Fragment$TagData) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? name = _undefined,
    Object? description = _undefined,
    Object? image_path = _undefined,
    Object? scene_count = _undefined,
    Object? image_count = _undefined,
    Object? gallery_count = _undefined,
    Object? performer_count = _undefined,
    Object? favorite = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Fragment$TagData(
      id: id == _undefined || id == null ? _instance.id : (id as String),
      name: name == _undefined || name == null
          ? _instance.name
          : (name as String),
      description: description == _undefined
          ? _instance.description
          : (description as String?),
      image_path: image_path == _undefined
          ? _instance.image_path
          : (image_path as String?),
      scene_count: scene_count == _undefined || scene_count == null
          ? _instance.scene_count
          : (scene_count as int),
      image_count: image_count == _undefined || image_count == null
          ? _instance.image_count
          : (image_count as int),
      gallery_count: gallery_count == _undefined || gallery_count == null
          ? _instance.gallery_count
          : (gallery_count as int),
      performer_count: performer_count == _undefined || performer_count == null
          ? _instance.performer_count
          : (performer_count as int),
      favorite: favorite == _undefined || favorite == null
          ? _instance.favorite
          : (favorite as bool),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Fragment$TagData<TRes>
    implements CopyWith$Fragment$TagData<TRes> {
  _CopyWithStubImpl$Fragment$TagData(this._res);

  TRes _res;

  call({
    String? id,
    String? name,
    String? description,
    String? image_path,
    int? scene_count,
    int? image_count,
    int? gallery_count,
    int? performer_count,
    bool? favorite,
    String? $__typename,
  }) => _res;
}

const fragmentDefinitionTagData = FragmentDefinitionNode(
  name: NameNode(value: 'TagData'),
  typeCondition: TypeConditionNode(
    on: NamedTypeNode(name: NameNode(value: 'Tag'), isNonNull: false),
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
        name: NameNode(value: 'description'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'image_path'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'scene_count'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'image_count'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'gallery_count'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'performer_count'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'favorite'),
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
const documentNodeFragmentTagData = DocumentNode(
  definitions: [fragmentDefinitionTagData],
);

extension ClientExtension$Fragment$TagData on graphql.GraphQLClient {
  void writeFragment$TagData({
    required Fragment$TagData data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) => this.writeFragment(
    graphql.FragmentRequest(
      idFields: idFields,
      fragment: const graphql.Fragment(
        fragmentName: 'TagData',
        document: documentNodeFragmentTagData,
      ),
    ),
    data: data.toJson(),
    broadcast: broadcast,
  );

  Fragment$TagData? readFragment$TagData({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'TagData',
          document: documentNodeFragmentTagData,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$TagData.fromJson(result);
  }
}

class Variables$Query$FindTags {
  factory Variables$Query$FindTags({
    Input$FindFilterType? filter,
    Input$TagFilterType? tag_filter,
  }) => Variables$Query$FindTags._({
    if (filter != null) r'filter': filter,
    if (tag_filter != null) r'tag_filter': tag_filter,
  });

  Variables$Query$FindTags._(this._$data);

  factory Variables$Query$FindTags.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('filter')) {
      final l$filter = data['filter'];
      result$data['filter'] = l$filter == null
          ? null
          : Input$FindFilterType.fromJson((l$filter as Map<String, dynamic>));
    }
    if (data.containsKey('tag_filter')) {
      final l$tag_filter = data['tag_filter'];
      result$data['tag_filter'] = l$tag_filter == null
          ? null
          : Input$TagFilterType.fromJson(
              (l$tag_filter as Map<String, dynamic>),
            );
    }
    return Variables$Query$FindTags._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$FindFilterType? get filter =>
      (_$data['filter'] as Input$FindFilterType?);

  Input$TagFilterType? get tag_filter =>
      (_$data['tag_filter'] as Input$TagFilterType?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('filter')) {
      final l$filter = filter;
      result$data['filter'] = l$filter?.toJson();
    }
    if (_$data.containsKey('tag_filter')) {
      final l$tag_filter = tag_filter;
      result$data['tag_filter'] = l$tag_filter?.toJson();
    }
    return result$data;
  }

  CopyWith$Variables$Query$FindTags<Variables$Query$FindTags> get copyWith =>
      CopyWith$Variables$Query$FindTags(this, (i) => i);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$FindTags ||
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
    final l$tag_filter = tag_filter;
    final lOther$tag_filter = other.tag_filter;
    if (_$data.containsKey('tag_filter') !=
        other._$data.containsKey('tag_filter')) {
      return false;
    }
    if (l$tag_filter != lOther$tag_filter) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$filter = filter;
    final l$tag_filter = tag_filter;
    return Object.hashAll([
      _$data.containsKey('filter') ? l$filter : const {},
      _$data.containsKey('tag_filter') ? l$tag_filter : const {},
    ]);
  }
}

abstract class CopyWith$Variables$Query$FindTags<TRes> {
  factory CopyWith$Variables$Query$FindTags(
    Variables$Query$FindTags instance,
    TRes Function(Variables$Query$FindTags) then,
  ) = _CopyWithImpl$Variables$Query$FindTags;

  factory CopyWith$Variables$Query$FindTags.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$FindTags;

  TRes call({Input$FindFilterType? filter, Input$TagFilterType? tag_filter});
}

class _CopyWithImpl$Variables$Query$FindTags<TRes>
    implements CopyWith$Variables$Query$FindTags<TRes> {
  _CopyWithImpl$Variables$Query$FindTags(this._instance, this._then);

  final Variables$Query$FindTags _instance;

  final TRes Function(Variables$Query$FindTags) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? filter = _undefined, Object? tag_filter = _undefined}) =>
      _then(
        Variables$Query$FindTags._({
          ..._instance._$data,
          if (filter != _undefined) 'filter': (filter as Input$FindFilterType?),
          if (tag_filter != _undefined)
            'tag_filter': (tag_filter as Input$TagFilterType?),
        }),
      );
}

class _CopyWithStubImpl$Variables$Query$FindTags<TRes>
    implements CopyWith$Variables$Query$FindTags<TRes> {
  _CopyWithStubImpl$Variables$Query$FindTags(this._res);

  TRes _res;

  call({Input$FindFilterType? filter, Input$TagFilterType? tag_filter}) => _res;
}

class Query$FindTags {
  Query$FindTags({required this.findTags, this.$__typename = 'Query'});

  factory Query$FindTags.fromJson(Map<String, dynamic> json) {
    final l$findTags = json['findTags'];
    final l$$__typename = json['__typename'];
    return Query$FindTags(
      findTags: Query$FindTags$findTags.fromJson(
        (l$findTags as Map<String, dynamic>),
      ),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$FindTags$findTags findTags;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$findTags = findTags;
    _resultData['findTags'] = l$findTags.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$findTags = findTags;
    final l$$__typename = $__typename;
    return Object.hashAll([l$findTags, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$FindTags || runtimeType != other.runtimeType) {
      return false;
    }
    final l$findTags = findTags;
    final lOther$findTags = other.findTags;
    if (l$findTags != lOther$findTags) {
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

extension UtilityExtension$Query$FindTags on Query$FindTags {
  CopyWith$Query$FindTags<Query$FindTags> get copyWith =>
      CopyWith$Query$FindTags(this, (i) => i);
}

abstract class CopyWith$Query$FindTags<TRes> {
  factory CopyWith$Query$FindTags(
    Query$FindTags instance,
    TRes Function(Query$FindTags) then,
  ) = _CopyWithImpl$Query$FindTags;

  factory CopyWith$Query$FindTags.stub(TRes res) =
      _CopyWithStubImpl$Query$FindTags;

  TRes call({Query$FindTags$findTags? findTags, String? $__typename});
  CopyWith$Query$FindTags$findTags<TRes> get findTags;
}

class _CopyWithImpl$Query$FindTags<TRes>
    implements CopyWith$Query$FindTags<TRes> {
  _CopyWithImpl$Query$FindTags(this._instance, this._then);

  final Query$FindTags _instance;

  final TRes Function(Query$FindTags) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? findTags = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$FindTags(
      findTags: findTags == _undefined || findTags == null
          ? _instance.findTags
          : (findTags as Query$FindTags$findTags),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  CopyWith$Query$FindTags$findTags<TRes> get findTags {
    final local$findTags = _instance.findTags;
    return CopyWith$Query$FindTags$findTags(
      local$findTags,
      (e) => call(findTags: e),
    );
  }
}

class _CopyWithStubImpl$Query$FindTags<TRes>
    implements CopyWith$Query$FindTags<TRes> {
  _CopyWithStubImpl$Query$FindTags(this._res);

  TRes _res;

  call({Query$FindTags$findTags? findTags, String? $__typename}) => _res;

  CopyWith$Query$FindTags$findTags<TRes> get findTags =>
      CopyWith$Query$FindTags$findTags.stub(_res);
}

const documentNodeQueryFindTags = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.query,
      name: NameNode(value: 'FindTags'),
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
          variable: VariableNode(name: NameNode(value: 'tag_filter')),
          type: NamedTypeNode(
            name: NameNode(value: 'TagFilterType'),
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
            name: NameNode(value: 'findTags'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'filter'),
                value: VariableNode(name: NameNode(value: 'filter')),
              ),
              ArgumentNode(
                name: NameNode(value: 'tag_filter'),
                value: VariableNode(name: NameNode(value: 'tag_filter')),
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
                  name: NameNode(value: 'tags'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: SelectionSetNode(
                    selections: [
                      FragmentSpreadNode(
                        name: NameNode(value: 'TagData'),
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
    fragmentDefinitionTagData,
  ],
);
Query$FindTags _parserFn$Query$FindTags(Map<String, dynamic> data) =>
    Query$FindTags.fromJson(data);
typedef OnQueryComplete$Query$FindTags =
    FutureOr<void> Function(Map<String, dynamic>?, Query$FindTags?);

class Options$Query$FindTags extends graphql.QueryOptions<Query$FindTags> {
  Options$Query$FindTags({
    String? operationName,
    Variables$Query$FindTags? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$FindTags? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$FindTags? onComplete,
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
                 data == null ? null : _parserFn$Query$FindTags(data),
               ),
         onError: onError,
         document: documentNodeQueryFindTags,
         parserFn: _parserFn$Query$FindTags,
       );

  final OnQueryComplete$Query$FindTags? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
    ...super.onComplete == null
        ? super.properties
        : super.properties.where((property) => property != onComplete),
    onCompleteWithParsed,
  ];
}

class WatchOptions$Query$FindTags
    extends graphql.WatchQueryOptions<Query$FindTags> {
  WatchOptions$Query$FindTags({
    String? operationName,
    Variables$Query$FindTags? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$FindTags? typedOptimisticResult,
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
         document: documentNodeQueryFindTags,
         pollInterval: pollInterval,
         eagerlyFetchResults: eagerlyFetchResults,
         carryForwardDataOnException: carryForwardDataOnException,
         fetchResults: fetchResults,
         parserFn: _parserFn$Query$FindTags,
       );
}

class FetchMoreOptions$Query$FindTags extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$FindTags({
    required graphql.UpdateQuery updateQuery,
    Variables$Query$FindTags? variables,
  }) : super(
         updateQuery: updateQuery,
         variables: variables?.toJson() ?? {},
         document: documentNodeQueryFindTags,
       );
}

extension ClientExtension$Query$FindTags on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$FindTags>> query$FindTags([
    Options$Query$FindTags? options,
  ]) async => await this.query(options ?? Options$Query$FindTags());

  graphql.ObservableQuery<Query$FindTags> watchQuery$FindTags([
    WatchOptions$Query$FindTags? options,
  ]) => this.watchQuery(options ?? WatchOptions$Query$FindTags());

  void writeQuery$FindTags({
    required Query$FindTags data,
    Variables$Query$FindTags? variables,
    bool broadcast = true,
  }) => this.writeQuery(
    graphql.Request(
      operation: graphql.Operation(document: documentNodeQueryFindTags),
      variables: variables?.toJson() ?? const {},
    ),
    data: data.toJson(),
    broadcast: broadcast,
  );

  Query$FindTags? readQuery$FindTags({
    Variables$Query$FindTags? variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(document: documentNodeQueryFindTags),
        variables: variables?.toJson() ?? const {},
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$FindTags.fromJson(result);
  }
}

class Query$FindTags$findTags {
  Query$FindTags$findTags({
    required this.count,
    required this.tags,
    this.$__typename = 'FindTagsResultType',
  });

  factory Query$FindTags$findTags.fromJson(Map<String, dynamic> json) {
    final l$count = json['count'];
    final l$tags = json['tags'];
    final l$$__typename = json['__typename'];
    return Query$FindTags$findTags(
      count: (l$count as int),
      tags: (l$tags as List<dynamic>)
          .map((e) => Fragment$TagData.fromJson((e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final int count;

  final List<Fragment$TagData> tags;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$count = count;
    _resultData['count'] = l$count;
    final l$tags = tags;
    _resultData['tags'] = l$tags.map((e) => e.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$count = count;
    final l$tags = tags;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$count,
      Object.hashAll(l$tags.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$FindTags$findTags || runtimeType != other.runtimeType) {
      return false;
    }
    final l$count = count;
    final lOther$count = other.count;
    if (l$count != lOther$count) {
      return false;
    }
    final l$tags = tags;
    final lOther$tags = other.tags;
    if (l$tags.length != lOther$tags.length) {
      return false;
    }
    for (int i = 0; i < l$tags.length; i++) {
      final l$tags$entry = l$tags[i];
      final lOther$tags$entry = lOther$tags[i];
      if (l$tags$entry != lOther$tags$entry) {
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

extension UtilityExtension$Query$FindTags$findTags on Query$FindTags$findTags {
  CopyWith$Query$FindTags$findTags<Query$FindTags$findTags> get copyWith =>
      CopyWith$Query$FindTags$findTags(this, (i) => i);
}

abstract class CopyWith$Query$FindTags$findTags<TRes> {
  factory CopyWith$Query$FindTags$findTags(
    Query$FindTags$findTags instance,
    TRes Function(Query$FindTags$findTags) then,
  ) = _CopyWithImpl$Query$FindTags$findTags;

  factory CopyWith$Query$FindTags$findTags.stub(TRes res) =
      _CopyWithStubImpl$Query$FindTags$findTags;

  TRes call({int? count, List<Fragment$TagData>? tags, String? $__typename});
  TRes tags(
    Iterable<Fragment$TagData> Function(
      Iterable<CopyWith$Fragment$TagData<Fragment$TagData>>,
    )
    _fn,
  );
}

class _CopyWithImpl$Query$FindTags$findTags<TRes>
    implements CopyWith$Query$FindTags$findTags<TRes> {
  _CopyWithImpl$Query$FindTags$findTags(this._instance, this._then);

  final Query$FindTags$findTags _instance;

  final TRes Function(Query$FindTags$findTags) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? count = _undefined,
    Object? tags = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$FindTags$findTags(
      count: count == _undefined || count == null
          ? _instance.count
          : (count as int),
      tags: tags == _undefined || tags == null
          ? _instance.tags
          : (tags as List<Fragment$TagData>),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  TRes tags(
    Iterable<Fragment$TagData> Function(
      Iterable<CopyWith$Fragment$TagData<Fragment$TagData>>,
    )
    _fn,
  ) => call(
    tags: _fn(
      _instance.tags.map((e) => CopyWith$Fragment$TagData(e, (i) => i)),
    ).toList(),
  );
}

class _CopyWithStubImpl$Query$FindTags$findTags<TRes>
    implements CopyWith$Query$FindTags$findTags<TRes> {
  _CopyWithStubImpl$Query$FindTags$findTags(this._res);

  TRes _res;

  call({int? count, List<Fragment$TagData>? tags, String? $__typename}) => _res;

  tags(_fn) => _res;
}

class Variables$Query$FindTag {
  factory Variables$Query$FindTag({required String id}) =>
      Variables$Query$FindTag._({r'id': id});

  Variables$Query$FindTag._(this._$data);

  factory Variables$Query$FindTag.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$id = data['id'];
    result$data['id'] = (l$id as String);
    return Variables$Query$FindTag._(result$data);
  }

  Map<String, dynamic> _$data;

  String get id => (_$data['id'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$id = id;
    result$data['id'] = l$id;
    return result$data;
  }

  CopyWith$Variables$Query$FindTag<Variables$Query$FindTag> get copyWith =>
      CopyWith$Variables$Query$FindTag(this, (i) => i);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$FindTag || runtimeType != other.runtimeType) {
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

abstract class CopyWith$Variables$Query$FindTag<TRes> {
  factory CopyWith$Variables$Query$FindTag(
    Variables$Query$FindTag instance,
    TRes Function(Variables$Query$FindTag) then,
  ) = _CopyWithImpl$Variables$Query$FindTag;

  factory CopyWith$Variables$Query$FindTag.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$FindTag;

  TRes call({String? id});
}

class _CopyWithImpl$Variables$Query$FindTag<TRes>
    implements CopyWith$Variables$Query$FindTag<TRes> {
  _CopyWithImpl$Variables$Query$FindTag(this._instance, this._then);

  final Variables$Query$FindTag _instance;

  final TRes Function(Variables$Query$FindTag) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? id = _undefined}) => _then(
    Variables$Query$FindTag._({
      ..._instance._$data,
      if (id != _undefined && id != null) 'id': (id as String),
    }),
  );
}

class _CopyWithStubImpl$Variables$Query$FindTag<TRes>
    implements CopyWith$Variables$Query$FindTag<TRes> {
  _CopyWithStubImpl$Variables$Query$FindTag(this._res);

  TRes _res;

  call({String? id}) => _res;
}

class Query$FindTag {
  Query$FindTag({this.findTag, this.$__typename = 'Query'});

  factory Query$FindTag.fromJson(Map<String, dynamic> json) {
    final l$findTag = json['findTag'];
    final l$$__typename = json['__typename'];
    return Query$FindTag(
      findTag: l$findTag == null
          ? null
          : Fragment$TagData.fromJson((l$findTag as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Fragment$TagData? findTag;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$findTag = findTag;
    _resultData['findTag'] = l$findTag?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$findTag = findTag;
    final l$$__typename = $__typename;
    return Object.hashAll([l$findTag, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$FindTag || runtimeType != other.runtimeType) {
      return false;
    }
    final l$findTag = findTag;
    final lOther$findTag = other.findTag;
    if (l$findTag != lOther$findTag) {
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

extension UtilityExtension$Query$FindTag on Query$FindTag {
  CopyWith$Query$FindTag<Query$FindTag> get copyWith =>
      CopyWith$Query$FindTag(this, (i) => i);
}

abstract class CopyWith$Query$FindTag<TRes> {
  factory CopyWith$Query$FindTag(
    Query$FindTag instance,
    TRes Function(Query$FindTag) then,
  ) = _CopyWithImpl$Query$FindTag;

  factory CopyWith$Query$FindTag.stub(TRes res) =
      _CopyWithStubImpl$Query$FindTag;

  TRes call({Fragment$TagData? findTag, String? $__typename});
  CopyWith$Fragment$TagData<TRes> get findTag;
}

class _CopyWithImpl$Query$FindTag<TRes>
    implements CopyWith$Query$FindTag<TRes> {
  _CopyWithImpl$Query$FindTag(this._instance, this._then);

  final Query$FindTag _instance;

  final TRes Function(Query$FindTag) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? findTag = _undefined, Object? $__typename = _undefined}) =>
      _then(
        Query$FindTag(
          findTag: findTag == _undefined
              ? _instance.findTag
              : (findTag as Fragment$TagData?),
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String),
        ),
      );

  CopyWith$Fragment$TagData<TRes> get findTag {
    final local$findTag = _instance.findTag;
    return local$findTag == null
        ? CopyWith$Fragment$TagData.stub(_then(_instance))
        : CopyWith$Fragment$TagData(local$findTag, (e) => call(findTag: e));
  }
}

class _CopyWithStubImpl$Query$FindTag<TRes>
    implements CopyWith$Query$FindTag<TRes> {
  _CopyWithStubImpl$Query$FindTag(this._res);

  TRes _res;

  call({Fragment$TagData? findTag, String? $__typename}) => _res;

  CopyWith$Fragment$TagData<TRes> get findTag =>
      CopyWith$Fragment$TagData.stub(_res);
}

const documentNodeQueryFindTag = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.query,
      name: NameNode(value: 'FindTag'),
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
            name: NameNode(value: 'findTag'),
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
                  name: NameNode(value: 'TagData'),
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
    fragmentDefinitionTagData,
  ],
);
Query$FindTag _parserFn$Query$FindTag(Map<String, dynamic> data) =>
    Query$FindTag.fromJson(data);
typedef OnQueryComplete$Query$FindTag =
    FutureOr<void> Function(Map<String, dynamic>?, Query$FindTag?);

class Options$Query$FindTag extends graphql.QueryOptions<Query$FindTag> {
  Options$Query$FindTag({
    String? operationName,
    required Variables$Query$FindTag variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$FindTag? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$FindTag? onComplete,
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
                 data == null ? null : _parserFn$Query$FindTag(data),
               ),
         onError: onError,
         document: documentNodeQueryFindTag,
         parserFn: _parserFn$Query$FindTag,
       );

  final OnQueryComplete$Query$FindTag? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
    ...super.onComplete == null
        ? super.properties
        : super.properties.where((property) => property != onComplete),
    onCompleteWithParsed,
  ];
}

class WatchOptions$Query$FindTag
    extends graphql.WatchQueryOptions<Query$FindTag> {
  WatchOptions$Query$FindTag({
    String? operationName,
    required Variables$Query$FindTag variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$FindTag? typedOptimisticResult,
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
         document: documentNodeQueryFindTag,
         pollInterval: pollInterval,
         eagerlyFetchResults: eagerlyFetchResults,
         carryForwardDataOnException: carryForwardDataOnException,
         fetchResults: fetchResults,
         parserFn: _parserFn$Query$FindTag,
       );
}

class FetchMoreOptions$Query$FindTag extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$FindTag({
    required graphql.UpdateQuery updateQuery,
    required Variables$Query$FindTag variables,
  }) : super(
         updateQuery: updateQuery,
         variables: variables.toJson(),
         document: documentNodeQueryFindTag,
       );
}

extension ClientExtension$Query$FindTag on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$FindTag>> query$FindTag(
    Options$Query$FindTag options,
  ) async => await this.query(options);

  graphql.ObservableQuery<Query$FindTag> watchQuery$FindTag(
    WatchOptions$Query$FindTag options,
  ) => this.watchQuery(options);

  void writeQuery$FindTag({
    required Query$FindTag data,
    required Variables$Query$FindTag variables,
    bool broadcast = true,
  }) => this.writeQuery(
    graphql.Request(
      operation: graphql.Operation(document: documentNodeQueryFindTag),
      variables: variables.toJson(),
    ),
    data: data.toJson(),
    broadcast: broadcast,
  );

  Query$FindTag? readQuery$FindTag({
    required Variables$Query$FindTag variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(document: documentNodeQueryFindTag),
        variables: variables.toJson(),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$FindTag.fromJson(result);
  }
}

class Variables$Mutation$UpdateTagFavorite {
  factory Variables$Mutation$UpdateTagFavorite({
    required String id,
    required bool favorite,
  }) => Variables$Mutation$UpdateTagFavorite._({
    r'id': id,
    r'favorite': favorite,
  });

  Variables$Mutation$UpdateTagFavorite._(this._$data);

  factory Variables$Mutation$UpdateTagFavorite.fromJson(
    Map<String, dynamic> data,
  ) {
    final result$data = <String, dynamic>{};
    final l$id = data['id'];
    result$data['id'] = (l$id as String);
    final l$favorite = data['favorite'];
    result$data['favorite'] = (l$favorite as bool);
    return Variables$Mutation$UpdateTagFavorite._(result$data);
  }

  Map<String, dynamic> _$data;

  String get id => (_$data['id'] as String);

  bool get favorite => (_$data['favorite'] as bool);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$id = id;
    result$data['id'] = l$id;
    final l$favorite = favorite;
    result$data['favorite'] = l$favorite;
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdateTagFavorite<
    Variables$Mutation$UpdateTagFavorite
  >
  get copyWith => CopyWith$Variables$Mutation$UpdateTagFavorite(this, (i) => i);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdateTagFavorite ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$favorite = favorite;
    final lOther$favorite = other.favorite;
    if (l$favorite != lOther$favorite) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$favorite = favorite;
    return Object.hashAll([l$id, l$favorite]);
  }
}

abstract class CopyWith$Variables$Mutation$UpdateTagFavorite<TRes> {
  factory CopyWith$Variables$Mutation$UpdateTagFavorite(
    Variables$Mutation$UpdateTagFavorite instance,
    TRes Function(Variables$Mutation$UpdateTagFavorite) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateTagFavorite;

  factory CopyWith$Variables$Mutation$UpdateTagFavorite.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateTagFavorite;

  TRes call({String? id, bool? favorite});
}

class _CopyWithImpl$Variables$Mutation$UpdateTagFavorite<TRes>
    implements CopyWith$Variables$Mutation$UpdateTagFavorite<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateTagFavorite(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateTagFavorite _instance;

  final TRes Function(Variables$Mutation$UpdateTagFavorite) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? id = _undefined, Object? favorite = _undefined}) => _then(
    Variables$Mutation$UpdateTagFavorite._({
      ..._instance._$data,
      if (id != _undefined && id != null) 'id': (id as String),
      if (favorite != _undefined && favorite != null)
        'favorite': (favorite as bool),
    }),
  );
}

class _CopyWithStubImpl$Variables$Mutation$UpdateTagFavorite<TRes>
    implements CopyWith$Variables$Mutation$UpdateTagFavorite<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateTagFavorite(this._res);

  TRes _res;

  call({String? id, bool? favorite}) => _res;
}

class Mutation$UpdateTagFavorite {
  Mutation$UpdateTagFavorite({this.tagUpdate, this.$__typename = 'Mutation'});

  factory Mutation$UpdateTagFavorite.fromJson(Map<String, dynamic> json) {
    final l$tagUpdate = json['tagUpdate'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateTagFavorite(
      tagUpdate: l$tagUpdate == null
          ? null
          : Mutation$UpdateTagFavorite$tagUpdate.fromJson(
              (l$tagUpdate as Map<String, dynamic>),
            ),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateTagFavorite$tagUpdate? tagUpdate;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$tagUpdate = tagUpdate;
    _resultData['tagUpdate'] = l$tagUpdate?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$tagUpdate = tagUpdate;
    final l$$__typename = $__typename;
    return Object.hashAll([l$tagUpdate, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdateTagFavorite ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$tagUpdate = tagUpdate;
    final lOther$tagUpdate = other.tagUpdate;
    if (l$tagUpdate != lOther$tagUpdate) {
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

extension UtilityExtension$Mutation$UpdateTagFavorite
    on Mutation$UpdateTagFavorite {
  CopyWith$Mutation$UpdateTagFavorite<Mutation$UpdateTagFavorite>
  get copyWith => CopyWith$Mutation$UpdateTagFavorite(this, (i) => i);
}

abstract class CopyWith$Mutation$UpdateTagFavorite<TRes> {
  factory CopyWith$Mutation$UpdateTagFavorite(
    Mutation$UpdateTagFavorite instance,
    TRes Function(Mutation$UpdateTagFavorite) then,
  ) = _CopyWithImpl$Mutation$UpdateTagFavorite;

  factory CopyWith$Mutation$UpdateTagFavorite.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateTagFavorite;

  TRes call({
    Mutation$UpdateTagFavorite$tagUpdate? tagUpdate,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateTagFavorite$tagUpdate<TRes> get tagUpdate;
}

class _CopyWithImpl$Mutation$UpdateTagFavorite<TRes>
    implements CopyWith$Mutation$UpdateTagFavorite<TRes> {
  _CopyWithImpl$Mutation$UpdateTagFavorite(this._instance, this._then);

  final Mutation$UpdateTagFavorite _instance;

  final TRes Function(Mutation$UpdateTagFavorite) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? tagUpdate = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Mutation$UpdateTagFavorite(
      tagUpdate: tagUpdate == _undefined
          ? _instance.tagUpdate
          : (tagUpdate as Mutation$UpdateTagFavorite$tagUpdate?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  CopyWith$Mutation$UpdateTagFavorite$tagUpdate<TRes> get tagUpdate {
    final local$tagUpdate = _instance.tagUpdate;
    return local$tagUpdate == null
        ? CopyWith$Mutation$UpdateTagFavorite$tagUpdate.stub(_then(_instance))
        : CopyWith$Mutation$UpdateTagFavorite$tagUpdate(
            local$tagUpdate,
            (e) => call(tagUpdate: e),
          );
  }
}

class _CopyWithStubImpl$Mutation$UpdateTagFavorite<TRes>
    implements CopyWith$Mutation$UpdateTagFavorite<TRes> {
  _CopyWithStubImpl$Mutation$UpdateTagFavorite(this._res);

  TRes _res;

  call({
    Mutation$UpdateTagFavorite$tagUpdate? tagUpdate,
    String? $__typename,
  }) => _res;

  CopyWith$Mutation$UpdateTagFavorite$tagUpdate<TRes> get tagUpdate =>
      CopyWith$Mutation$UpdateTagFavorite$tagUpdate.stub(_res);
}

const documentNodeMutationUpdateTagFavorite = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.mutation,
      name: NameNode(value: 'UpdateTagFavorite'),
      variableDefinitions: [
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'id')),
          type: NamedTypeNode(name: NameNode(value: 'ID'), isNonNull: true),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'favorite')),
          type: NamedTypeNode(
            name: NameNode(value: 'Boolean'),
            isNonNull: true,
          ),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
      ],
      directives: [],
      selectionSet: SelectionSetNode(
        selections: [
          FieldNode(
            name: NameNode(value: 'tagUpdate'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'input'),
                value: ObjectValueNode(
                  fields: [
                    ObjectFieldNode(
                      name: NameNode(value: 'id'),
                      value: VariableNode(name: NameNode(value: 'id')),
                    ),
                    ObjectFieldNode(
                      name: NameNode(value: 'favorite'),
                      value: VariableNode(name: NameNode(value: 'favorite')),
                    ),
                  ],
                ),
              ),
            ],
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
                  name: NameNode(value: 'favorite'),
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
Mutation$UpdateTagFavorite _parserFn$Mutation$UpdateTagFavorite(
  Map<String, dynamic> data,
) => Mutation$UpdateTagFavorite.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateTagFavorite =
    FutureOr<void> Function(Map<String, dynamic>?, Mutation$UpdateTagFavorite?);

class Options$Mutation$UpdateTagFavorite
    extends graphql.MutationOptions<Mutation$UpdateTagFavorite> {
  Options$Mutation$UpdateTagFavorite({
    String? operationName,
    required Variables$Mutation$UpdateTagFavorite variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateTagFavorite? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateTagFavorite? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateTagFavorite>? update,
    graphql.OnError? onError,
  }) : onCompletedWithParsed = onCompleted,
       super(
         variables: variables.toJson(),
         operationName: operationName,
         fetchPolicy: fetchPolicy,
         errorPolicy: errorPolicy,
         cacheRereadPolicy: cacheRereadPolicy,
         optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
         context: context,
         onCompleted: onCompleted == null
             ? null
             : (data) => onCompleted(
                 data,
                 data == null
                     ? null
                     : _parserFn$Mutation$UpdateTagFavorite(data),
               ),
         update: update,
         onError: onError,
         document: documentNodeMutationUpdateTagFavorite,
         parserFn: _parserFn$Mutation$UpdateTagFavorite,
       );

  final OnMutationCompleted$Mutation$UpdateTagFavorite? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
    ...super.onCompleted == null
        ? super.properties
        : super.properties.where((property) => property != onCompleted),
    onCompletedWithParsed,
  ];
}

class WatchOptions$Mutation$UpdateTagFavorite
    extends graphql.WatchQueryOptions<Mutation$UpdateTagFavorite> {
  WatchOptions$Mutation$UpdateTagFavorite({
    String? operationName,
    required Variables$Mutation$UpdateTagFavorite variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateTagFavorite? typedOptimisticResult,
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
         document: documentNodeMutationUpdateTagFavorite,
         pollInterval: pollInterval,
         eagerlyFetchResults: eagerlyFetchResults,
         carryForwardDataOnException: carryForwardDataOnException,
         fetchResults: fetchResults,
         parserFn: _parserFn$Mutation$UpdateTagFavorite,
       );
}

extension ClientExtension$Mutation$UpdateTagFavorite on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateTagFavorite>>
  mutate$UpdateTagFavorite(Options$Mutation$UpdateTagFavorite options) async =>
      await this.mutate(options);

  graphql.ObservableQuery<Mutation$UpdateTagFavorite>
  watchMutation$UpdateTagFavorite(
    WatchOptions$Mutation$UpdateTagFavorite options,
  ) => this.watchMutation(options);
}

class Mutation$UpdateTagFavorite$tagUpdate {
  Mutation$UpdateTagFavorite$tagUpdate({
    required this.id,
    required this.favorite,
    this.$__typename = 'Tag',
  });

  factory Mutation$UpdateTagFavorite$tagUpdate.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$id = json['id'];
    final l$favorite = json['favorite'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateTagFavorite$tagUpdate(
      id: (l$id as String),
      favorite: (l$favorite as bool),
      $__typename: (l$$__typename as String),
    );
  }

  final String id;

  final bool favorite;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$favorite = favorite;
    _resultData['favorite'] = l$favorite;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$favorite = favorite;
    final l$$__typename = $__typename;
    return Object.hashAll([l$id, l$favorite, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdateTagFavorite$tagUpdate ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$favorite = favorite;
    final lOther$favorite = other.favorite;
    if (l$favorite != lOther$favorite) {
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

extension UtilityExtension$Mutation$UpdateTagFavorite$tagUpdate
    on Mutation$UpdateTagFavorite$tagUpdate {
  CopyWith$Mutation$UpdateTagFavorite$tagUpdate<
    Mutation$UpdateTagFavorite$tagUpdate
  >
  get copyWith => CopyWith$Mutation$UpdateTagFavorite$tagUpdate(this, (i) => i);
}

abstract class CopyWith$Mutation$UpdateTagFavorite$tagUpdate<TRes> {
  factory CopyWith$Mutation$UpdateTagFavorite$tagUpdate(
    Mutation$UpdateTagFavorite$tagUpdate instance,
    TRes Function(Mutation$UpdateTagFavorite$tagUpdate) then,
  ) = _CopyWithImpl$Mutation$UpdateTagFavorite$tagUpdate;

  factory CopyWith$Mutation$UpdateTagFavorite$tagUpdate.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateTagFavorite$tagUpdate;

  TRes call({String? id, bool? favorite, String? $__typename});
}

class _CopyWithImpl$Mutation$UpdateTagFavorite$tagUpdate<TRes>
    implements CopyWith$Mutation$UpdateTagFavorite$tagUpdate<TRes> {
  _CopyWithImpl$Mutation$UpdateTagFavorite$tagUpdate(
    this._instance,
    this._then,
  );

  final Mutation$UpdateTagFavorite$tagUpdate _instance;

  final TRes Function(Mutation$UpdateTagFavorite$tagUpdate) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? favorite = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Mutation$UpdateTagFavorite$tagUpdate(
      id: id == _undefined || id == null ? _instance.id : (id as String),
      favorite: favorite == _undefined || favorite == null
          ? _instance.favorite
          : (favorite as bool),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Mutation$UpdateTagFavorite$tagUpdate<TRes>
    implements CopyWith$Mutation$UpdateTagFavorite$tagUpdate<TRes> {
  _CopyWithStubImpl$Mutation$UpdateTagFavorite$tagUpdate(this._res);

  TRes _res;

  call({String? id, bool? favorite, String? $__typename}) => _res;
}

class Variables$Mutation$CreateTag {
  factory Variables$Mutation$CreateTag({required Input$TagCreateInput input}) =>
      Variables$Mutation$CreateTag._({r'input': input});

  Variables$Mutation$CreateTag._(this._$data);

  factory Variables$Mutation$CreateTag.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$input = data['input'];
    result$data['input'] = Input$TagCreateInput.fromJson(
      (l$input as Map<String, dynamic>),
    );
    return Variables$Mutation$CreateTag._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$TagCreateInput get input => (_$data['input'] as Input$TagCreateInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$input = input;
    result$data['input'] = l$input.toJson();
    return result$data;
  }

  CopyWith$Variables$Mutation$CreateTag<Variables$Mutation$CreateTag>
  get copyWith => CopyWith$Variables$Mutation$CreateTag(this, (i) => i);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$CreateTag ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$input = input;
    final lOther$input = other.input;
    if (l$input != lOther$input) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$input = input;
    return Object.hashAll([l$input]);
  }
}

abstract class CopyWith$Variables$Mutation$CreateTag<TRes> {
  factory CopyWith$Variables$Mutation$CreateTag(
    Variables$Mutation$CreateTag instance,
    TRes Function(Variables$Mutation$CreateTag) then,
  ) = _CopyWithImpl$Variables$Mutation$CreateTag;

  factory CopyWith$Variables$Mutation$CreateTag.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$CreateTag;

  TRes call({Input$TagCreateInput? input});
}

class _CopyWithImpl$Variables$Mutation$CreateTag<TRes>
    implements CopyWith$Variables$Mutation$CreateTag<TRes> {
  _CopyWithImpl$Variables$Mutation$CreateTag(this._instance, this._then);

  final Variables$Mutation$CreateTag _instance;

  final TRes Function(Variables$Mutation$CreateTag) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? input = _undefined}) => _then(
    Variables$Mutation$CreateTag._({
      ..._instance._$data,
      if (input != _undefined && input != null)
        'input': (input as Input$TagCreateInput),
    }),
  );
}

class _CopyWithStubImpl$Variables$Mutation$CreateTag<TRes>
    implements CopyWith$Variables$Mutation$CreateTag<TRes> {
  _CopyWithStubImpl$Variables$Mutation$CreateTag(this._res);

  TRes _res;

  call({Input$TagCreateInput? input}) => _res;
}

class Mutation$CreateTag {
  Mutation$CreateTag({this.tagCreate, this.$__typename = 'Mutation'});

  factory Mutation$CreateTag.fromJson(Map<String, dynamic> json) {
    final l$tagCreate = json['tagCreate'];
    final l$$__typename = json['__typename'];
    return Mutation$CreateTag(
      tagCreate: l$tagCreate == null
          ? null
          : Mutation$CreateTag$tagCreate.fromJson(
              (l$tagCreate as Map<String, dynamic>),
            ),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$CreateTag$tagCreate? tagCreate;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$tagCreate = tagCreate;
    _resultData['tagCreate'] = l$tagCreate?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$tagCreate = tagCreate;
    final l$$__typename = $__typename;
    return Object.hashAll([l$tagCreate, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$CreateTag || runtimeType != other.runtimeType) {
      return false;
    }
    final l$tagCreate = tagCreate;
    final lOther$tagCreate = other.tagCreate;
    if (l$tagCreate != lOther$tagCreate) {
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

extension UtilityExtension$Mutation$CreateTag on Mutation$CreateTag {
  CopyWith$Mutation$CreateTag<Mutation$CreateTag> get copyWith =>
      CopyWith$Mutation$CreateTag(this, (i) => i);
}

abstract class CopyWith$Mutation$CreateTag<TRes> {
  factory CopyWith$Mutation$CreateTag(
    Mutation$CreateTag instance,
    TRes Function(Mutation$CreateTag) then,
  ) = _CopyWithImpl$Mutation$CreateTag;

  factory CopyWith$Mutation$CreateTag.stub(TRes res) =
      _CopyWithStubImpl$Mutation$CreateTag;

  TRes call({Mutation$CreateTag$tagCreate? tagCreate, String? $__typename});
  CopyWith$Mutation$CreateTag$tagCreate<TRes> get tagCreate;
}

class _CopyWithImpl$Mutation$CreateTag<TRes>
    implements CopyWith$Mutation$CreateTag<TRes> {
  _CopyWithImpl$Mutation$CreateTag(this._instance, this._then);

  final Mutation$CreateTag _instance;

  final TRes Function(Mutation$CreateTag) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? tagCreate = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Mutation$CreateTag(
      tagCreate: tagCreate == _undefined
          ? _instance.tagCreate
          : (tagCreate as Mutation$CreateTag$tagCreate?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  CopyWith$Mutation$CreateTag$tagCreate<TRes> get tagCreate {
    final local$tagCreate = _instance.tagCreate;
    return local$tagCreate == null
        ? CopyWith$Mutation$CreateTag$tagCreate.stub(_then(_instance))
        : CopyWith$Mutation$CreateTag$tagCreate(
            local$tagCreate,
            (e) => call(tagCreate: e),
          );
  }
}

class _CopyWithStubImpl$Mutation$CreateTag<TRes>
    implements CopyWith$Mutation$CreateTag<TRes> {
  _CopyWithStubImpl$Mutation$CreateTag(this._res);

  TRes _res;

  call({Mutation$CreateTag$tagCreate? tagCreate, String? $__typename}) => _res;

  CopyWith$Mutation$CreateTag$tagCreate<TRes> get tagCreate =>
      CopyWith$Mutation$CreateTag$tagCreate.stub(_res);
}

const documentNodeMutationCreateTag = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.mutation,
      name: NameNode(value: 'CreateTag'),
      variableDefinitions: [
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'input')),
          type: NamedTypeNode(
            name: NameNode(value: 'TagCreateInput'),
            isNonNull: true,
          ),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
      ],
      directives: [],
      selectionSet: SelectionSetNode(
        selections: [
          FieldNode(
            name: NameNode(value: 'tagCreate'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'input'),
                value: VariableNode(name: NameNode(value: 'input')),
              ),
            ],
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
Mutation$CreateTag _parserFn$Mutation$CreateTag(Map<String, dynamic> data) =>
    Mutation$CreateTag.fromJson(data);
typedef OnMutationCompleted$Mutation$CreateTag =
    FutureOr<void> Function(Map<String, dynamic>?, Mutation$CreateTag?);

class Options$Mutation$CreateTag
    extends graphql.MutationOptions<Mutation$CreateTag> {
  Options$Mutation$CreateTag({
    String? operationName,
    required Variables$Mutation$CreateTag variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$CreateTag? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$CreateTag? onCompleted,
    graphql.OnMutationUpdate<Mutation$CreateTag>? update,
    graphql.OnError? onError,
  }) : onCompletedWithParsed = onCompleted,
       super(
         variables: variables.toJson(),
         operationName: operationName,
         fetchPolicy: fetchPolicy,
         errorPolicy: errorPolicy,
         cacheRereadPolicy: cacheRereadPolicy,
         optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
         context: context,
         onCompleted: onCompleted == null
             ? null
             : (data) => onCompleted(
                 data,
                 data == null ? null : _parserFn$Mutation$CreateTag(data),
               ),
         update: update,
         onError: onError,
         document: documentNodeMutationCreateTag,
         parserFn: _parserFn$Mutation$CreateTag,
       );

  final OnMutationCompleted$Mutation$CreateTag? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
    ...super.onCompleted == null
        ? super.properties
        : super.properties.where((property) => property != onCompleted),
    onCompletedWithParsed,
  ];
}

class WatchOptions$Mutation$CreateTag
    extends graphql.WatchQueryOptions<Mutation$CreateTag> {
  WatchOptions$Mutation$CreateTag({
    String? operationName,
    required Variables$Mutation$CreateTag variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$CreateTag? typedOptimisticResult,
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
         document: documentNodeMutationCreateTag,
         pollInterval: pollInterval,
         eagerlyFetchResults: eagerlyFetchResults,
         carryForwardDataOnException: carryForwardDataOnException,
         fetchResults: fetchResults,
         parserFn: _parserFn$Mutation$CreateTag,
       );
}

extension ClientExtension$Mutation$CreateTag on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$CreateTag>> mutate$CreateTag(
    Options$Mutation$CreateTag options,
  ) async => await this.mutate(options);

  graphql.ObservableQuery<Mutation$CreateTag> watchMutation$CreateTag(
    WatchOptions$Mutation$CreateTag options,
  ) => this.watchMutation(options);
}

class Mutation$CreateTag$tagCreate {
  Mutation$CreateTag$tagCreate({required this.id, this.$__typename = 'Tag'});

  factory Mutation$CreateTag$tagCreate.fromJson(Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$$__typename = json['__typename'];
    return Mutation$CreateTag$tagCreate(
      id: (l$id as String),
      $__typename: (l$$__typename as String),
    );
  }

  final String id;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$$__typename = $__typename;
    return Object.hashAll([l$id, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$CreateTag$tagCreate ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
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

extension UtilityExtension$Mutation$CreateTag$tagCreate
    on Mutation$CreateTag$tagCreate {
  CopyWith$Mutation$CreateTag$tagCreate<Mutation$CreateTag$tagCreate>
  get copyWith => CopyWith$Mutation$CreateTag$tagCreate(this, (i) => i);
}

abstract class CopyWith$Mutation$CreateTag$tagCreate<TRes> {
  factory CopyWith$Mutation$CreateTag$tagCreate(
    Mutation$CreateTag$tagCreate instance,
    TRes Function(Mutation$CreateTag$tagCreate) then,
  ) = _CopyWithImpl$Mutation$CreateTag$tagCreate;

  factory CopyWith$Mutation$CreateTag$tagCreate.stub(TRes res) =
      _CopyWithStubImpl$Mutation$CreateTag$tagCreate;

  TRes call({String? id, String? $__typename});
}

class _CopyWithImpl$Mutation$CreateTag$tagCreate<TRes>
    implements CopyWith$Mutation$CreateTag$tagCreate<TRes> {
  _CopyWithImpl$Mutation$CreateTag$tagCreate(this._instance, this._then);

  final Mutation$CreateTag$tagCreate _instance;

  final TRes Function(Mutation$CreateTag$tagCreate) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? id = _undefined, Object? $__typename = _undefined}) =>
      _then(
        Mutation$CreateTag$tagCreate(
          id: id == _undefined || id == null ? _instance.id : (id as String),
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String),
        ),
      );
}

class _CopyWithStubImpl$Mutation$CreateTag$tagCreate<TRes>
    implements CopyWith$Mutation$CreateTag$tagCreate<TRes> {
  _CopyWithStubImpl$Mutation$CreateTag$tagCreate(this._res);

  TRes _res;

  call({String? id, String? $__typename}) => _res;
}
