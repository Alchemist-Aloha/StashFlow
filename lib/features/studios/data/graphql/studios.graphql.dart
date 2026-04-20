import '../../../../core/data/graphql/schema.graphql.dart';
import 'dart:async';
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;

class Fragment$StudioData {
  Fragment$StudioData({
    required this.id,
    required this.name,
    this.url,
    this.image_path,
    this.details,
    this.rating100,
    required this.scene_count,
    required this.image_count,
    required this.gallery_count,
    required this.performer_count,
    required this.favorite,
    this.$__typename = 'Studio',
  });

  factory Fragment$StudioData.fromJson(Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$name = json['name'];
    final l$url = json['url'];
    final l$image_path = json['image_path'];
    final l$details = json['details'];
    final l$rating100 = json['rating100'];
    final l$scene_count = json['scene_count'];
    final l$image_count = json['image_count'];
    final l$gallery_count = json['gallery_count'];
    final l$performer_count = json['performer_count'];
    final l$favorite = json['favorite'];
    final l$$__typename = json['__typename'];
    return Fragment$StudioData(
      id: (l$id as String),
      name: (l$name as String),
      url: (l$url as String?),
      image_path: (l$image_path as String?),
      details: (l$details as String?),
      rating100: (l$rating100 as int?),
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

  @Deprecated('Use urls')
  final String? url;

  final String? image_path;

  final String? details;

  final int? rating100;

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
    final l$url = url;
    _resultData['url'] = l$url;
    final l$image_path = image_path;
    _resultData['image_path'] = l$image_path;
    final l$details = details;
    _resultData['details'] = l$details;
    final l$rating100 = rating100;
    _resultData['rating100'] = l$rating100;
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
    final l$url = url;
    final l$image_path = image_path;
    final l$details = details;
    final l$rating100 = rating100;
    final l$scene_count = scene_count;
    final l$image_count = image_count;
    final l$gallery_count = gallery_count;
    final l$performer_count = performer_count;
    final l$favorite = favorite;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$name,
      l$url,
      l$image_path,
      l$details,
      l$rating100,
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
    if (other is! Fragment$StudioData || runtimeType != other.runtimeType) {
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
    final l$url = url;
    final lOther$url = other.url;
    if (l$url != lOther$url) {
      return false;
    }
    final l$image_path = image_path;
    final lOther$image_path = other.image_path;
    if (l$image_path != lOther$image_path) {
      return false;
    }
    final l$details = details;
    final lOther$details = other.details;
    if (l$details != lOther$details) {
      return false;
    }
    final l$rating100 = rating100;
    final lOther$rating100 = other.rating100;
    if (l$rating100 != lOther$rating100) {
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

extension UtilityExtension$Fragment$StudioData on Fragment$StudioData {
  CopyWith$Fragment$StudioData<Fragment$StudioData> get copyWith =>
      CopyWith$Fragment$StudioData(this, (i) => i);
}

abstract class CopyWith$Fragment$StudioData<TRes> {
  factory CopyWith$Fragment$StudioData(
    Fragment$StudioData instance,
    TRes Function(Fragment$StudioData) then,
  ) = _CopyWithImpl$Fragment$StudioData;

  factory CopyWith$Fragment$StudioData.stub(TRes res) =
      _CopyWithStubImpl$Fragment$StudioData;

  TRes call({
    String? id,
    String? name,
    String? url,
    String? image_path,
    String? details,
    int? rating100,
    int? scene_count,
    int? image_count,
    int? gallery_count,
    int? performer_count,
    bool? favorite,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$StudioData<TRes>
    implements CopyWith$Fragment$StudioData<TRes> {
  _CopyWithImpl$Fragment$StudioData(this._instance, this._then);

  final Fragment$StudioData _instance;

  final TRes Function(Fragment$StudioData) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? name = _undefined,
    Object? url = _undefined,
    Object? image_path = _undefined,
    Object? details = _undefined,
    Object? rating100 = _undefined,
    Object? scene_count = _undefined,
    Object? image_count = _undefined,
    Object? gallery_count = _undefined,
    Object? performer_count = _undefined,
    Object? favorite = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Fragment$StudioData(
      id: id == _undefined || id == null ? _instance.id : (id as String),
      name: name == _undefined || name == null
          ? _instance.name
          : (name as String),
      url: url == _undefined ? _instance.url : (url as String?),
      image_path: image_path == _undefined
          ? _instance.image_path
          : (image_path as String?),
      details: details == _undefined ? _instance.details : (details as String?),
      rating100: rating100 == _undefined
          ? _instance.rating100
          : (rating100 as int?),
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

class _CopyWithStubImpl$Fragment$StudioData<TRes>
    implements CopyWith$Fragment$StudioData<TRes> {
  _CopyWithStubImpl$Fragment$StudioData(this._res);

  TRes _res;

  call({
    String? id,
    String? name,
    String? url,
    String? image_path,
    String? details,
    int? rating100,
    int? scene_count,
    int? image_count,
    int? gallery_count,
    int? performer_count,
    bool? favorite,
    String? $__typename,
  }) => _res;
}

const fragmentDefinitionStudioData = FragmentDefinitionNode(
  name: NameNode(value: 'StudioData'),
  typeCondition: TypeConditionNode(
    on: NamedTypeNode(name: NameNode(value: 'Studio'), isNonNull: false),
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
        name: NameNode(value: 'url'),
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
        name: NameNode(value: 'details'),
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
const documentNodeFragmentStudioData = DocumentNode(
  definitions: [fragmentDefinitionStudioData],
);

extension ClientExtension$Fragment$StudioData on graphql.GraphQLClient {
  void writeFragment$StudioData({
    required Fragment$StudioData data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) => this.writeFragment(
    graphql.FragmentRequest(
      idFields: idFields,
      fragment: const graphql.Fragment(
        fragmentName: 'StudioData',
        document: documentNodeFragmentStudioData,
      ),
    ),
    data: data.toJson(),
    broadcast: broadcast,
  );

  Fragment$StudioData? readFragment$StudioData({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'StudioData',
          document: documentNodeFragmentStudioData,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$StudioData.fromJson(result);
  }
}

class Variables$Query$FindStudios {
  factory Variables$Query$FindStudios({
    Input$FindFilterType? filter,
    Input$StudioFilterType? studio_filter,
  }) => Variables$Query$FindStudios._({
    if (filter != null) r'filter': filter,
    if (studio_filter != null) r'studio_filter': studio_filter,
  });

  Variables$Query$FindStudios._(this._$data);

  factory Variables$Query$FindStudios.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('filter')) {
      final l$filter = data['filter'];
      result$data['filter'] = l$filter == null
          ? null
          : Input$FindFilterType.fromJson((l$filter as Map<String, dynamic>));
    }
    if (data.containsKey('studio_filter')) {
      final l$studio_filter = data['studio_filter'];
      result$data['studio_filter'] = l$studio_filter == null
          ? null
          : Input$StudioFilterType.fromJson(
              (l$studio_filter as Map<String, dynamic>),
            );
    }
    return Variables$Query$FindStudios._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$FindFilterType? get filter =>
      (_$data['filter'] as Input$FindFilterType?);

  Input$StudioFilterType? get studio_filter =>
      (_$data['studio_filter'] as Input$StudioFilterType?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('filter')) {
      final l$filter = filter;
      result$data['filter'] = l$filter?.toJson();
    }
    if (_$data.containsKey('studio_filter')) {
      final l$studio_filter = studio_filter;
      result$data['studio_filter'] = l$studio_filter?.toJson();
    }
    return result$data;
  }

  CopyWith$Variables$Query$FindStudios<Variables$Query$FindStudios>
  get copyWith => CopyWith$Variables$Query$FindStudios(this, (i) => i);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$FindStudios ||
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
    final l$studio_filter = studio_filter;
    final lOther$studio_filter = other.studio_filter;
    if (_$data.containsKey('studio_filter') !=
        other._$data.containsKey('studio_filter')) {
      return false;
    }
    if (l$studio_filter != lOther$studio_filter) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$filter = filter;
    final l$studio_filter = studio_filter;
    return Object.hashAll([
      _$data.containsKey('filter') ? l$filter : const {},
      _$data.containsKey('studio_filter') ? l$studio_filter : const {},
    ]);
  }
}

abstract class CopyWith$Variables$Query$FindStudios<TRes> {
  factory CopyWith$Variables$Query$FindStudios(
    Variables$Query$FindStudios instance,
    TRes Function(Variables$Query$FindStudios) then,
  ) = _CopyWithImpl$Variables$Query$FindStudios;

  factory CopyWith$Variables$Query$FindStudios.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$FindStudios;

  TRes call({
    Input$FindFilterType? filter,
    Input$StudioFilterType? studio_filter,
  });
}

class _CopyWithImpl$Variables$Query$FindStudios<TRes>
    implements CopyWith$Variables$Query$FindStudios<TRes> {
  _CopyWithImpl$Variables$Query$FindStudios(this._instance, this._then);

  final Variables$Query$FindStudios _instance;

  final TRes Function(Variables$Query$FindStudios) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? filter = _undefined,
    Object? studio_filter = _undefined,
  }) => _then(
    Variables$Query$FindStudios._({
      ..._instance._$data,
      if (filter != _undefined) 'filter': (filter as Input$FindFilterType?),
      if (studio_filter != _undefined)
        'studio_filter': (studio_filter as Input$StudioFilterType?),
    }),
  );
}

class _CopyWithStubImpl$Variables$Query$FindStudios<TRes>
    implements CopyWith$Variables$Query$FindStudios<TRes> {
  _CopyWithStubImpl$Variables$Query$FindStudios(this._res);

  TRes _res;

  call({Input$FindFilterType? filter, Input$StudioFilterType? studio_filter}) =>
      _res;
}

class Query$FindStudios {
  Query$FindStudios({required this.findStudios, this.$__typename = 'Query'});

  factory Query$FindStudios.fromJson(Map<String, dynamic> json) {
    final l$findStudios = json['findStudios'];
    final l$$__typename = json['__typename'];
    return Query$FindStudios(
      findStudios: Query$FindStudios$findStudios.fromJson(
        (l$findStudios as Map<String, dynamic>),
      ),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$FindStudios$findStudios findStudios;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$findStudios = findStudios;
    _resultData['findStudios'] = l$findStudios.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$findStudios = findStudios;
    final l$$__typename = $__typename;
    return Object.hashAll([l$findStudios, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$FindStudios || runtimeType != other.runtimeType) {
      return false;
    }
    final l$findStudios = findStudios;
    final lOther$findStudios = other.findStudios;
    if (l$findStudios != lOther$findStudios) {
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

extension UtilityExtension$Query$FindStudios on Query$FindStudios {
  CopyWith$Query$FindStudios<Query$FindStudios> get copyWith =>
      CopyWith$Query$FindStudios(this, (i) => i);
}

abstract class CopyWith$Query$FindStudios<TRes> {
  factory CopyWith$Query$FindStudios(
    Query$FindStudios instance,
    TRes Function(Query$FindStudios) then,
  ) = _CopyWithImpl$Query$FindStudios;

  factory CopyWith$Query$FindStudios.stub(TRes res) =
      _CopyWithStubImpl$Query$FindStudios;

  TRes call({Query$FindStudios$findStudios? findStudios, String? $__typename});
  CopyWith$Query$FindStudios$findStudios<TRes> get findStudios;
}

class _CopyWithImpl$Query$FindStudios<TRes>
    implements CopyWith$Query$FindStudios<TRes> {
  _CopyWithImpl$Query$FindStudios(this._instance, this._then);

  final Query$FindStudios _instance;

  final TRes Function(Query$FindStudios) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? findStudios = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$FindStudios(
      findStudios: findStudios == _undefined || findStudios == null
          ? _instance.findStudios
          : (findStudios as Query$FindStudios$findStudios),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  CopyWith$Query$FindStudios$findStudios<TRes> get findStudios {
    final local$findStudios = _instance.findStudios;
    return CopyWith$Query$FindStudios$findStudios(
      local$findStudios,
      (e) => call(findStudios: e),
    );
  }
}

class _CopyWithStubImpl$Query$FindStudios<TRes>
    implements CopyWith$Query$FindStudios<TRes> {
  _CopyWithStubImpl$Query$FindStudios(this._res);

  TRes _res;

  call({Query$FindStudios$findStudios? findStudios, String? $__typename}) =>
      _res;

  CopyWith$Query$FindStudios$findStudios<TRes> get findStudios =>
      CopyWith$Query$FindStudios$findStudios.stub(_res);
}

const documentNodeQueryFindStudios = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.query,
      name: NameNode(value: 'FindStudios'),
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
          variable: VariableNode(name: NameNode(value: 'studio_filter')),
          type: NamedTypeNode(
            name: NameNode(value: 'StudioFilterType'),
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
            name: NameNode(value: 'findStudios'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'filter'),
                value: VariableNode(name: NameNode(value: 'filter')),
              ),
              ArgumentNode(
                name: NameNode(value: 'studio_filter'),
                value: VariableNode(name: NameNode(value: 'studio_filter')),
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
                  name: NameNode(value: 'studios'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: SelectionSetNode(
                    selections: [
                      FragmentSpreadNode(
                        name: NameNode(value: 'StudioData'),
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
    fragmentDefinitionStudioData,
  ],
);
Query$FindStudios _parserFn$Query$FindStudios(Map<String, dynamic> data) =>
    Query$FindStudios.fromJson(data);
typedef OnQueryComplete$Query$FindStudios =
    FutureOr<void> Function(Map<String, dynamic>?, Query$FindStudios?);

class Options$Query$FindStudios
    extends graphql.QueryOptions<Query$FindStudios> {
  Options$Query$FindStudios({
    String? operationName,
    Variables$Query$FindStudios? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$FindStudios? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$FindStudios? onComplete,
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
                 data == null ? null : _parserFn$Query$FindStudios(data),
               ),
         onError: onError,
         document: documentNodeQueryFindStudios,
         parserFn: _parserFn$Query$FindStudios,
       );

  final OnQueryComplete$Query$FindStudios? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
    ...super.onComplete == null
        ? super.properties
        : super.properties.where((property) => property != onComplete),
    onCompleteWithParsed,
  ];
}

class WatchOptions$Query$FindStudios
    extends graphql.WatchQueryOptions<Query$FindStudios> {
  WatchOptions$Query$FindStudios({
    String? operationName,
    Variables$Query$FindStudios? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$FindStudios? typedOptimisticResult,
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
         document: documentNodeQueryFindStudios,
         pollInterval: pollInterval,
         eagerlyFetchResults: eagerlyFetchResults,
         carryForwardDataOnException: carryForwardDataOnException,
         fetchResults: fetchResults,
         parserFn: _parserFn$Query$FindStudios,
       );
}

class FetchMoreOptions$Query$FindStudios extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$FindStudios({
    required graphql.UpdateQuery updateQuery,
    Variables$Query$FindStudios? variables,
  }) : super(
         updateQuery: updateQuery,
         variables: variables?.toJson() ?? {},
         document: documentNodeQueryFindStudios,
       );
}

extension ClientExtension$Query$FindStudios on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$FindStudios>> query$FindStudios([
    Options$Query$FindStudios? options,
  ]) async => await this.query(options ?? Options$Query$FindStudios());

  graphql.ObservableQuery<Query$FindStudios> watchQuery$FindStudios([
    WatchOptions$Query$FindStudios? options,
  ]) => this.watchQuery(options ?? WatchOptions$Query$FindStudios());

  void writeQuery$FindStudios({
    required Query$FindStudios data,
    Variables$Query$FindStudios? variables,
    bool broadcast = true,
  }) => this.writeQuery(
    graphql.Request(
      operation: graphql.Operation(document: documentNodeQueryFindStudios),
      variables: variables?.toJson() ?? const {},
    ),
    data: data.toJson(),
    broadcast: broadcast,
  );

  Query$FindStudios? readQuery$FindStudios({
    Variables$Query$FindStudios? variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(document: documentNodeQueryFindStudios),
        variables: variables?.toJson() ?? const {},
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$FindStudios.fromJson(result);
  }
}

class Query$FindStudios$findStudios {
  Query$FindStudios$findStudios({
    required this.count,
    required this.studios,
    this.$__typename = 'FindStudiosResultType',
  });

  factory Query$FindStudios$findStudios.fromJson(Map<String, dynamic> json) {
    final l$count = json['count'];
    final l$studios = json['studios'];
    final l$$__typename = json['__typename'];
    return Query$FindStudios$findStudios(
      count: (l$count as int),
      studios: (l$studios as List<dynamic>)
          .map((e) => Fragment$StudioData.fromJson((e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final int count;

  final List<Fragment$StudioData> studios;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$count = count;
    _resultData['count'] = l$count;
    final l$studios = studios;
    _resultData['studios'] = l$studios.map((e) => e.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$count = count;
    final l$studios = studios;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$count,
      Object.hashAll(l$studios.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$FindStudios$findStudios ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$count = count;
    final lOther$count = other.count;
    if (l$count != lOther$count) {
      return false;
    }
    final l$studios = studios;
    final lOther$studios = other.studios;
    if (l$studios.length != lOther$studios.length) {
      return false;
    }
    for (int i = 0; i < l$studios.length; i++) {
      final l$studios$entry = l$studios[i];
      final lOther$studios$entry = lOther$studios[i];
      if (l$studios$entry != lOther$studios$entry) {
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

extension UtilityExtension$Query$FindStudios$findStudios
    on Query$FindStudios$findStudios {
  CopyWith$Query$FindStudios$findStudios<Query$FindStudios$findStudios>
  get copyWith => CopyWith$Query$FindStudios$findStudios(this, (i) => i);
}

abstract class CopyWith$Query$FindStudios$findStudios<TRes> {
  factory CopyWith$Query$FindStudios$findStudios(
    Query$FindStudios$findStudios instance,
    TRes Function(Query$FindStudios$findStudios) then,
  ) = _CopyWithImpl$Query$FindStudios$findStudios;

  factory CopyWith$Query$FindStudios$findStudios.stub(TRes res) =
      _CopyWithStubImpl$Query$FindStudios$findStudios;

  TRes call({
    int? count,
    List<Fragment$StudioData>? studios,
    String? $__typename,
  });
  TRes studios(
    Iterable<Fragment$StudioData> Function(
      Iterable<CopyWith$Fragment$StudioData<Fragment$StudioData>>,
    )
    _fn,
  );
}

class _CopyWithImpl$Query$FindStudios$findStudios<TRes>
    implements CopyWith$Query$FindStudios$findStudios<TRes> {
  _CopyWithImpl$Query$FindStudios$findStudios(this._instance, this._then);

  final Query$FindStudios$findStudios _instance;

  final TRes Function(Query$FindStudios$findStudios) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? count = _undefined,
    Object? studios = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$FindStudios$findStudios(
      count: count == _undefined || count == null
          ? _instance.count
          : (count as int),
      studios: studios == _undefined || studios == null
          ? _instance.studios
          : (studios as List<Fragment$StudioData>),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  TRes studios(
    Iterable<Fragment$StudioData> Function(
      Iterable<CopyWith$Fragment$StudioData<Fragment$StudioData>>,
    )
    _fn,
  ) => call(
    studios: _fn(
      _instance.studios.map((e) => CopyWith$Fragment$StudioData(e, (i) => i)),
    ).toList(),
  );
}

class _CopyWithStubImpl$Query$FindStudios$findStudios<TRes>
    implements CopyWith$Query$FindStudios$findStudios<TRes> {
  _CopyWithStubImpl$Query$FindStudios$findStudios(this._res);

  TRes _res;

  call({int? count, List<Fragment$StudioData>? studios, String? $__typename}) =>
      _res;

  studios(_fn) => _res;
}

class Variables$Query$FindStudio {
  factory Variables$Query$FindStudio({required String id}) =>
      Variables$Query$FindStudio._({r'id': id});

  Variables$Query$FindStudio._(this._$data);

  factory Variables$Query$FindStudio.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$id = data['id'];
    result$data['id'] = (l$id as String);
    return Variables$Query$FindStudio._(result$data);
  }

  Map<String, dynamic> _$data;

  String get id => (_$data['id'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$id = id;
    result$data['id'] = l$id;
    return result$data;
  }

  CopyWith$Variables$Query$FindStudio<Variables$Query$FindStudio>
  get copyWith => CopyWith$Variables$Query$FindStudio(this, (i) => i);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$FindStudio ||
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

abstract class CopyWith$Variables$Query$FindStudio<TRes> {
  factory CopyWith$Variables$Query$FindStudio(
    Variables$Query$FindStudio instance,
    TRes Function(Variables$Query$FindStudio) then,
  ) = _CopyWithImpl$Variables$Query$FindStudio;

  factory CopyWith$Variables$Query$FindStudio.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$FindStudio;

  TRes call({String? id});
}

class _CopyWithImpl$Variables$Query$FindStudio<TRes>
    implements CopyWith$Variables$Query$FindStudio<TRes> {
  _CopyWithImpl$Variables$Query$FindStudio(this._instance, this._then);

  final Variables$Query$FindStudio _instance;

  final TRes Function(Variables$Query$FindStudio) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? id = _undefined}) => _then(
    Variables$Query$FindStudio._({
      ..._instance._$data,
      if (id != _undefined && id != null) 'id': (id as String),
    }),
  );
}

class _CopyWithStubImpl$Variables$Query$FindStudio<TRes>
    implements CopyWith$Variables$Query$FindStudio<TRes> {
  _CopyWithStubImpl$Variables$Query$FindStudio(this._res);

  TRes _res;

  call({String? id}) => _res;
}

class Query$FindStudio {
  Query$FindStudio({this.findStudio, this.$__typename = 'Query'});

  factory Query$FindStudio.fromJson(Map<String, dynamic> json) {
    final l$findStudio = json['findStudio'];
    final l$$__typename = json['__typename'];
    return Query$FindStudio(
      findStudio: l$findStudio == null
          ? null
          : Fragment$StudioData.fromJson(
              (l$findStudio as Map<String, dynamic>),
            ),
      $__typename: (l$$__typename as String),
    );
  }

  final Fragment$StudioData? findStudio;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$findStudio = findStudio;
    _resultData['findStudio'] = l$findStudio?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$findStudio = findStudio;
    final l$$__typename = $__typename;
    return Object.hashAll([l$findStudio, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$FindStudio || runtimeType != other.runtimeType) {
      return false;
    }
    final l$findStudio = findStudio;
    final lOther$findStudio = other.findStudio;
    if (l$findStudio != lOther$findStudio) {
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

extension UtilityExtension$Query$FindStudio on Query$FindStudio {
  CopyWith$Query$FindStudio<Query$FindStudio> get copyWith =>
      CopyWith$Query$FindStudio(this, (i) => i);
}

abstract class CopyWith$Query$FindStudio<TRes> {
  factory CopyWith$Query$FindStudio(
    Query$FindStudio instance,
    TRes Function(Query$FindStudio) then,
  ) = _CopyWithImpl$Query$FindStudio;

  factory CopyWith$Query$FindStudio.stub(TRes res) =
      _CopyWithStubImpl$Query$FindStudio;

  TRes call({Fragment$StudioData? findStudio, String? $__typename});
  CopyWith$Fragment$StudioData<TRes> get findStudio;
}

class _CopyWithImpl$Query$FindStudio<TRes>
    implements CopyWith$Query$FindStudio<TRes> {
  _CopyWithImpl$Query$FindStudio(this._instance, this._then);

  final Query$FindStudio _instance;

  final TRes Function(Query$FindStudio) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? findStudio = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$FindStudio(
      findStudio: findStudio == _undefined
          ? _instance.findStudio
          : (findStudio as Fragment$StudioData?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  CopyWith$Fragment$StudioData<TRes> get findStudio {
    final local$findStudio = _instance.findStudio;
    return local$findStudio == null
        ? CopyWith$Fragment$StudioData.stub(_then(_instance))
        : CopyWith$Fragment$StudioData(
            local$findStudio,
            (e) => call(findStudio: e),
          );
  }
}

class _CopyWithStubImpl$Query$FindStudio<TRes>
    implements CopyWith$Query$FindStudio<TRes> {
  _CopyWithStubImpl$Query$FindStudio(this._res);

  TRes _res;

  call({Fragment$StudioData? findStudio, String? $__typename}) => _res;

  CopyWith$Fragment$StudioData<TRes> get findStudio =>
      CopyWith$Fragment$StudioData.stub(_res);
}

const documentNodeQueryFindStudio = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.query,
      name: NameNode(value: 'FindStudio'),
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
            name: NameNode(value: 'findStudio'),
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
                  name: NameNode(value: 'StudioData'),
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
    fragmentDefinitionStudioData,
  ],
);
Query$FindStudio _parserFn$Query$FindStudio(Map<String, dynamic> data) =>
    Query$FindStudio.fromJson(data);
typedef OnQueryComplete$Query$FindStudio =
    FutureOr<void> Function(Map<String, dynamic>?, Query$FindStudio?);

class Options$Query$FindStudio extends graphql.QueryOptions<Query$FindStudio> {
  Options$Query$FindStudio({
    String? operationName,
    required Variables$Query$FindStudio variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$FindStudio? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$FindStudio? onComplete,
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
                 data == null ? null : _parserFn$Query$FindStudio(data),
               ),
         onError: onError,
         document: documentNodeQueryFindStudio,
         parserFn: _parserFn$Query$FindStudio,
       );

  final OnQueryComplete$Query$FindStudio? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
    ...super.onComplete == null
        ? super.properties
        : super.properties.where((property) => property != onComplete),
    onCompleteWithParsed,
  ];
}

class WatchOptions$Query$FindStudio
    extends graphql.WatchQueryOptions<Query$FindStudio> {
  WatchOptions$Query$FindStudio({
    String? operationName,
    required Variables$Query$FindStudio variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$FindStudio? typedOptimisticResult,
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
         document: documentNodeQueryFindStudio,
         pollInterval: pollInterval,
         eagerlyFetchResults: eagerlyFetchResults,
         carryForwardDataOnException: carryForwardDataOnException,
         fetchResults: fetchResults,
         parserFn: _parserFn$Query$FindStudio,
       );
}

class FetchMoreOptions$Query$FindStudio extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$FindStudio({
    required graphql.UpdateQuery updateQuery,
    required Variables$Query$FindStudio variables,
  }) : super(
         updateQuery: updateQuery,
         variables: variables.toJson(),
         document: documentNodeQueryFindStudio,
       );
}

extension ClientExtension$Query$FindStudio on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$FindStudio>> query$FindStudio(
    Options$Query$FindStudio options,
  ) async => await this.query(options);

  graphql.ObservableQuery<Query$FindStudio> watchQuery$FindStudio(
    WatchOptions$Query$FindStudio options,
  ) => this.watchQuery(options);

  void writeQuery$FindStudio({
    required Query$FindStudio data,
    required Variables$Query$FindStudio variables,
    bool broadcast = true,
  }) => this.writeQuery(
    graphql.Request(
      operation: graphql.Operation(document: documentNodeQueryFindStudio),
      variables: variables.toJson(),
    ),
    data: data.toJson(),
    broadcast: broadcast,
  );

  Query$FindStudio? readQuery$FindStudio({
    required Variables$Query$FindStudio variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(document: documentNodeQueryFindStudio),
        variables: variables.toJson(),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$FindStudio.fromJson(result);
  }
}

class Variables$Mutation$UpdateStudioFavorite {
  factory Variables$Mutation$UpdateStudioFavorite({
    required String id,
    required bool favorite,
  }) => Variables$Mutation$UpdateStudioFavorite._({
    r'id': id,
    r'favorite': favorite,
  });

  Variables$Mutation$UpdateStudioFavorite._(this._$data);

  factory Variables$Mutation$UpdateStudioFavorite.fromJson(
    Map<String, dynamic> data,
  ) {
    final result$data = <String, dynamic>{};
    final l$id = data['id'];
    result$data['id'] = (l$id as String);
    final l$favorite = data['favorite'];
    result$data['favorite'] = (l$favorite as bool);
    return Variables$Mutation$UpdateStudioFavorite._(result$data);
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

  CopyWith$Variables$Mutation$UpdateStudioFavorite<
    Variables$Mutation$UpdateStudioFavorite
  >
  get copyWith =>
      CopyWith$Variables$Mutation$UpdateStudioFavorite(this, (i) => i);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdateStudioFavorite ||
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

abstract class CopyWith$Variables$Mutation$UpdateStudioFavorite<TRes> {
  factory CopyWith$Variables$Mutation$UpdateStudioFavorite(
    Variables$Mutation$UpdateStudioFavorite instance,
    TRes Function(Variables$Mutation$UpdateStudioFavorite) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateStudioFavorite;

  factory CopyWith$Variables$Mutation$UpdateStudioFavorite.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateStudioFavorite;

  TRes call({String? id, bool? favorite});
}

class _CopyWithImpl$Variables$Mutation$UpdateStudioFavorite<TRes>
    implements CopyWith$Variables$Mutation$UpdateStudioFavorite<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateStudioFavorite(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateStudioFavorite _instance;

  final TRes Function(Variables$Mutation$UpdateStudioFavorite) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? id = _undefined, Object? favorite = _undefined}) => _then(
    Variables$Mutation$UpdateStudioFavorite._({
      ..._instance._$data,
      if (id != _undefined && id != null) 'id': (id as String),
      if (favorite != _undefined && favorite != null)
        'favorite': (favorite as bool),
    }),
  );
}

class _CopyWithStubImpl$Variables$Mutation$UpdateStudioFavorite<TRes>
    implements CopyWith$Variables$Mutation$UpdateStudioFavorite<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateStudioFavorite(this._res);

  TRes _res;

  call({String? id, bool? favorite}) => _res;
}

class Mutation$UpdateStudioFavorite {
  Mutation$UpdateStudioFavorite({
    this.studioUpdate,
    this.$__typename = 'Mutation',
  });

  factory Mutation$UpdateStudioFavorite.fromJson(Map<String, dynamic> json) {
    final l$studioUpdate = json['studioUpdate'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateStudioFavorite(
      studioUpdate: l$studioUpdate == null
          ? null
          : Mutation$UpdateStudioFavorite$studioUpdate.fromJson(
              (l$studioUpdate as Map<String, dynamic>),
            ),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateStudioFavorite$studioUpdate? studioUpdate;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$studioUpdate = studioUpdate;
    _resultData['studioUpdate'] = l$studioUpdate?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$studioUpdate = studioUpdate;
    final l$$__typename = $__typename;
    return Object.hashAll([l$studioUpdate, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdateStudioFavorite ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$studioUpdate = studioUpdate;
    final lOther$studioUpdate = other.studioUpdate;
    if (l$studioUpdate != lOther$studioUpdate) {
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

extension UtilityExtension$Mutation$UpdateStudioFavorite
    on Mutation$UpdateStudioFavorite {
  CopyWith$Mutation$UpdateStudioFavorite<Mutation$UpdateStudioFavorite>
  get copyWith => CopyWith$Mutation$UpdateStudioFavorite(this, (i) => i);
}

abstract class CopyWith$Mutation$UpdateStudioFavorite<TRes> {
  factory CopyWith$Mutation$UpdateStudioFavorite(
    Mutation$UpdateStudioFavorite instance,
    TRes Function(Mutation$UpdateStudioFavorite) then,
  ) = _CopyWithImpl$Mutation$UpdateStudioFavorite;

  factory CopyWith$Mutation$UpdateStudioFavorite.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateStudioFavorite;

  TRes call({
    Mutation$UpdateStudioFavorite$studioUpdate? studioUpdate,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateStudioFavorite$studioUpdate<TRes> get studioUpdate;
}

class _CopyWithImpl$Mutation$UpdateStudioFavorite<TRes>
    implements CopyWith$Mutation$UpdateStudioFavorite<TRes> {
  _CopyWithImpl$Mutation$UpdateStudioFavorite(this._instance, this._then);

  final Mutation$UpdateStudioFavorite _instance;

  final TRes Function(Mutation$UpdateStudioFavorite) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? studioUpdate = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Mutation$UpdateStudioFavorite(
      studioUpdate: studioUpdate == _undefined
          ? _instance.studioUpdate
          : (studioUpdate as Mutation$UpdateStudioFavorite$studioUpdate?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  CopyWith$Mutation$UpdateStudioFavorite$studioUpdate<TRes> get studioUpdate {
    final local$studioUpdate = _instance.studioUpdate;
    return local$studioUpdate == null
        ? CopyWith$Mutation$UpdateStudioFavorite$studioUpdate.stub(
            _then(_instance),
          )
        : CopyWith$Mutation$UpdateStudioFavorite$studioUpdate(
            local$studioUpdate,
            (e) => call(studioUpdate: e),
          );
  }
}

class _CopyWithStubImpl$Mutation$UpdateStudioFavorite<TRes>
    implements CopyWith$Mutation$UpdateStudioFavorite<TRes> {
  _CopyWithStubImpl$Mutation$UpdateStudioFavorite(this._res);

  TRes _res;

  call({
    Mutation$UpdateStudioFavorite$studioUpdate? studioUpdate,
    String? $__typename,
  }) => _res;

  CopyWith$Mutation$UpdateStudioFavorite$studioUpdate<TRes> get studioUpdate =>
      CopyWith$Mutation$UpdateStudioFavorite$studioUpdate.stub(_res);
}

const documentNodeMutationUpdateStudioFavorite = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.mutation,
      name: NameNode(value: 'UpdateStudioFavorite'),
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
            name: NameNode(value: 'studioUpdate'),
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
Mutation$UpdateStudioFavorite _parserFn$Mutation$UpdateStudioFavorite(
  Map<String, dynamic> data,
) => Mutation$UpdateStudioFavorite.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateStudioFavorite =
    FutureOr<void> Function(
      Map<String, dynamic>?,
      Mutation$UpdateStudioFavorite?,
    );

class Options$Mutation$UpdateStudioFavorite
    extends graphql.MutationOptions<Mutation$UpdateStudioFavorite> {
  Options$Mutation$UpdateStudioFavorite({
    String? operationName,
    required Variables$Mutation$UpdateStudioFavorite variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateStudioFavorite? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateStudioFavorite? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateStudioFavorite>? update,
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
                     : _parserFn$Mutation$UpdateStudioFavorite(data),
               ),
         update: update,
         onError: onError,
         document: documentNodeMutationUpdateStudioFavorite,
         parserFn: _parserFn$Mutation$UpdateStudioFavorite,
       );

  final OnMutationCompleted$Mutation$UpdateStudioFavorite?
  onCompletedWithParsed;

  @override
  List<Object?> get properties => [
    ...super.onCompleted == null
        ? super.properties
        : super.properties.where((property) => property != onCompleted),
    onCompletedWithParsed,
  ];
}

class WatchOptions$Mutation$UpdateStudioFavorite
    extends graphql.WatchQueryOptions<Mutation$UpdateStudioFavorite> {
  WatchOptions$Mutation$UpdateStudioFavorite({
    String? operationName,
    required Variables$Mutation$UpdateStudioFavorite variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateStudioFavorite? typedOptimisticResult,
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
         document: documentNodeMutationUpdateStudioFavorite,
         pollInterval: pollInterval,
         eagerlyFetchResults: eagerlyFetchResults,
         carryForwardDataOnException: carryForwardDataOnException,
         fetchResults: fetchResults,
         parserFn: _parserFn$Mutation$UpdateStudioFavorite,
       );
}

extension ClientExtension$Mutation$UpdateStudioFavorite
    on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateStudioFavorite>>
  mutate$UpdateStudioFavorite(
    Options$Mutation$UpdateStudioFavorite options,
  ) async => await this.mutate(options);

  graphql.ObservableQuery<Mutation$UpdateStudioFavorite>
  watchMutation$UpdateStudioFavorite(
    WatchOptions$Mutation$UpdateStudioFavorite options,
  ) => this.watchMutation(options);
}

class Mutation$UpdateStudioFavorite$studioUpdate {
  Mutation$UpdateStudioFavorite$studioUpdate({
    required this.id,
    required this.favorite,
    this.$__typename = 'Studio',
  });

  factory Mutation$UpdateStudioFavorite$studioUpdate.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$id = json['id'];
    final l$favorite = json['favorite'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateStudioFavorite$studioUpdate(
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
    if (other is! Mutation$UpdateStudioFavorite$studioUpdate ||
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

extension UtilityExtension$Mutation$UpdateStudioFavorite$studioUpdate
    on Mutation$UpdateStudioFavorite$studioUpdate {
  CopyWith$Mutation$UpdateStudioFavorite$studioUpdate<
    Mutation$UpdateStudioFavorite$studioUpdate
  >
  get copyWith =>
      CopyWith$Mutation$UpdateStudioFavorite$studioUpdate(this, (i) => i);
}

abstract class CopyWith$Mutation$UpdateStudioFavorite$studioUpdate<TRes> {
  factory CopyWith$Mutation$UpdateStudioFavorite$studioUpdate(
    Mutation$UpdateStudioFavorite$studioUpdate instance,
    TRes Function(Mutation$UpdateStudioFavorite$studioUpdate) then,
  ) = _CopyWithImpl$Mutation$UpdateStudioFavorite$studioUpdate;

  factory CopyWith$Mutation$UpdateStudioFavorite$studioUpdate.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateStudioFavorite$studioUpdate;

  TRes call({String? id, bool? favorite, String? $__typename});
}

class _CopyWithImpl$Mutation$UpdateStudioFavorite$studioUpdate<TRes>
    implements CopyWith$Mutation$UpdateStudioFavorite$studioUpdate<TRes> {
  _CopyWithImpl$Mutation$UpdateStudioFavorite$studioUpdate(
    this._instance,
    this._then,
  );

  final Mutation$UpdateStudioFavorite$studioUpdate _instance;

  final TRes Function(Mutation$UpdateStudioFavorite$studioUpdate) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? favorite = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Mutation$UpdateStudioFavorite$studioUpdate(
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

class _CopyWithStubImpl$Mutation$UpdateStudioFavorite$studioUpdate<TRes>
    implements CopyWith$Mutation$UpdateStudioFavorite$studioUpdate<TRes> {
  _CopyWithStubImpl$Mutation$UpdateStudioFavorite$studioUpdate(this._res);

  TRes _res;

  call({String? id, bool? favorite, String? $__typename}) => _res;
}

class Variables$Mutation$StudioUpdate {
  factory Variables$Mutation$StudioUpdate({
    required Input$StudioUpdateInput input,
  }) => Variables$Mutation$StudioUpdate._({r'input': input});

  Variables$Mutation$StudioUpdate._(this._$data);

  factory Variables$Mutation$StudioUpdate.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$input = data['input'];
    result$data['input'] = Input$StudioUpdateInput.fromJson(
      (l$input as Map<String, dynamic>),
    );
    return Variables$Mutation$StudioUpdate._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$StudioUpdateInput get input =>
      (_$data['input'] as Input$StudioUpdateInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$input = input;
    result$data['input'] = l$input.toJson();
    return result$data;
  }

  CopyWith$Variables$Mutation$StudioUpdate<Variables$Mutation$StudioUpdate>
  get copyWith => CopyWith$Variables$Mutation$StudioUpdate(this, (i) => i);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$StudioUpdate ||
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

abstract class CopyWith$Variables$Mutation$StudioUpdate<TRes> {
  factory CopyWith$Variables$Mutation$StudioUpdate(
    Variables$Mutation$StudioUpdate instance,
    TRes Function(Variables$Mutation$StudioUpdate) then,
  ) = _CopyWithImpl$Variables$Mutation$StudioUpdate;

  factory CopyWith$Variables$Mutation$StudioUpdate.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$StudioUpdate;

  TRes call({Input$StudioUpdateInput? input});
}

class _CopyWithImpl$Variables$Mutation$StudioUpdate<TRes>
    implements CopyWith$Variables$Mutation$StudioUpdate<TRes> {
  _CopyWithImpl$Variables$Mutation$StudioUpdate(this._instance, this._then);

  final Variables$Mutation$StudioUpdate _instance;

  final TRes Function(Variables$Mutation$StudioUpdate) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? input = _undefined}) => _then(
    Variables$Mutation$StudioUpdate._({
      ..._instance._$data,
      if (input != _undefined && input != null)
        'input': (input as Input$StudioUpdateInput),
    }),
  );
}

class _CopyWithStubImpl$Variables$Mutation$StudioUpdate<TRes>
    implements CopyWith$Variables$Mutation$StudioUpdate<TRes> {
  _CopyWithStubImpl$Variables$Mutation$StudioUpdate(this._res);

  TRes _res;

  call({Input$StudioUpdateInput? input}) => _res;
}

class Mutation$StudioUpdate {
  Mutation$StudioUpdate({this.studioUpdate, this.$__typename = 'Mutation'});

  factory Mutation$StudioUpdate.fromJson(Map<String, dynamic> json) {
    final l$studioUpdate = json['studioUpdate'];
    final l$$__typename = json['__typename'];
    return Mutation$StudioUpdate(
      studioUpdate: l$studioUpdate == null
          ? null
          : Mutation$StudioUpdate$studioUpdate.fromJson(
              (l$studioUpdate as Map<String, dynamic>),
            ),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$StudioUpdate$studioUpdate? studioUpdate;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$studioUpdate = studioUpdate;
    _resultData['studioUpdate'] = l$studioUpdate?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$studioUpdate = studioUpdate;
    final l$$__typename = $__typename;
    return Object.hashAll([l$studioUpdate, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$StudioUpdate || runtimeType != other.runtimeType) {
      return false;
    }
    final l$studioUpdate = studioUpdate;
    final lOther$studioUpdate = other.studioUpdate;
    if (l$studioUpdate != lOther$studioUpdate) {
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

extension UtilityExtension$Mutation$StudioUpdate on Mutation$StudioUpdate {
  CopyWith$Mutation$StudioUpdate<Mutation$StudioUpdate> get copyWith =>
      CopyWith$Mutation$StudioUpdate(this, (i) => i);
}

abstract class CopyWith$Mutation$StudioUpdate<TRes> {
  factory CopyWith$Mutation$StudioUpdate(
    Mutation$StudioUpdate instance,
    TRes Function(Mutation$StudioUpdate) then,
  ) = _CopyWithImpl$Mutation$StudioUpdate;

  factory CopyWith$Mutation$StudioUpdate.stub(TRes res) =
      _CopyWithStubImpl$Mutation$StudioUpdate;

  TRes call({
    Mutation$StudioUpdate$studioUpdate? studioUpdate,
    String? $__typename,
  });
  CopyWith$Mutation$StudioUpdate$studioUpdate<TRes> get studioUpdate;
}

class _CopyWithImpl$Mutation$StudioUpdate<TRes>
    implements CopyWith$Mutation$StudioUpdate<TRes> {
  _CopyWithImpl$Mutation$StudioUpdate(this._instance, this._then);

  final Mutation$StudioUpdate _instance;

  final TRes Function(Mutation$StudioUpdate) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? studioUpdate = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Mutation$StudioUpdate(
      studioUpdate: studioUpdate == _undefined
          ? _instance.studioUpdate
          : (studioUpdate as Mutation$StudioUpdate$studioUpdate?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  CopyWith$Mutation$StudioUpdate$studioUpdate<TRes> get studioUpdate {
    final local$studioUpdate = _instance.studioUpdate;
    return local$studioUpdate == null
        ? CopyWith$Mutation$StudioUpdate$studioUpdate.stub(_then(_instance))
        : CopyWith$Mutation$StudioUpdate$studioUpdate(
            local$studioUpdate,
            (e) => call(studioUpdate: e),
          );
  }
}

class _CopyWithStubImpl$Mutation$StudioUpdate<TRes>
    implements CopyWith$Mutation$StudioUpdate<TRes> {
  _CopyWithStubImpl$Mutation$StudioUpdate(this._res);

  TRes _res;

  call({
    Mutation$StudioUpdate$studioUpdate? studioUpdate,
    String? $__typename,
  }) => _res;

  CopyWith$Mutation$StudioUpdate$studioUpdate<TRes> get studioUpdate =>
      CopyWith$Mutation$StudioUpdate$studioUpdate.stub(_res);
}

const documentNodeMutationStudioUpdate = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.mutation,
      name: NameNode(value: 'StudioUpdate'),
      variableDefinitions: [
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'input')),
          type: NamedTypeNode(
            name: NameNode(value: 'StudioUpdateInput'),
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
            name: NameNode(value: 'studioUpdate'),
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
Mutation$StudioUpdate _parserFn$Mutation$StudioUpdate(
  Map<String, dynamic> data,
) => Mutation$StudioUpdate.fromJson(data);
typedef OnMutationCompleted$Mutation$StudioUpdate =
    FutureOr<void> Function(Map<String, dynamic>?, Mutation$StudioUpdate?);

class Options$Mutation$StudioUpdate
    extends graphql.MutationOptions<Mutation$StudioUpdate> {
  Options$Mutation$StudioUpdate({
    String? operationName,
    required Variables$Mutation$StudioUpdate variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$StudioUpdate? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$StudioUpdate? onCompleted,
    graphql.OnMutationUpdate<Mutation$StudioUpdate>? update,
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
                 data == null ? null : _parserFn$Mutation$StudioUpdate(data),
               ),
         update: update,
         onError: onError,
         document: documentNodeMutationStudioUpdate,
         parserFn: _parserFn$Mutation$StudioUpdate,
       );

  final OnMutationCompleted$Mutation$StudioUpdate? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
    ...super.onCompleted == null
        ? super.properties
        : super.properties.where((property) => property != onCompleted),
    onCompletedWithParsed,
  ];
}

class WatchOptions$Mutation$StudioUpdate
    extends graphql.WatchQueryOptions<Mutation$StudioUpdate> {
  WatchOptions$Mutation$StudioUpdate({
    String? operationName,
    required Variables$Mutation$StudioUpdate variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$StudioUpdate? typedOptimisticResult,
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
         document: documentNodeMutationStudioUpdate,
         pollInterval: pollInterval,
         eagerlyFetchResults: eagerlyFetchResults,
         carryForwardDataOnException: carryForwardDataOnException,
         fetchResults: fetchResults,
         parserFn: _parserFn$Mutation$StudioUpdate,
       );
}

extension ClientExtension$Mutation$StudioUpdate on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$StudioUpdate>> mutate$StudioUpdate(
    Options$Mutation$StudioUpdate options,
  ) async => await this.mutate(options);

  graphql.ObservableQuery<Mutation$StudioUpdate> watchMutation$StudioUpdate(
    WatchOptions$Mutation$StudioUpdate options,
  ) => this.watchMutation(options);
}

class Mutation$StudioUpdate$studioUpdate {
  Mutation$StudioUpdate$studioUpdate({
    required this.id,
    this.$__typename = 'Studio',
  });

  factory Mutation$StudioUpdate$studioUpdate.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$id = json['id'];
    final l$$__typename = json['__typename'];
    return Mutation$StudioUpdate$studioUpdate(
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
    if (other is! Mutation$StudioUpdate$studioUpdate ||
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

extension UtilityExtension$Mutation$StudioUpdate$studioUpdate
    on Mutation$StudioUpdate$studioUpdate {
  CopyWith$Mutation$StudioUpdate$studioUpdate<
    Mutation$StudioUpdate$studioUpdate
  >
  get copyWith => CopyWith$Mutation$StudioUpdate$studioUpdate(this, (i) => i);
}

abstract class CopyWith$Mutation$StudioUpdate$studioUpdate<TRes> {
  factory CopyWith$Mutation$StudioUpdate$studioUpdate(
    Mutation$StudioUpdate$studioUpdate instance,
    TRes Function(Mutation$StudioUpdate$studioUpdate) then,
  ) = _CopyWithImpl$Mutation$StudioUpdate$studioUpdate;

  factory CopyWith$Mutation$StudioUpdate$studioUpdate.stub(TRes res) =
      _CopyWithStubImpl$Mutation$StudioUpdate$studioUpdate;

  TRes call({String? id, String? $__typename});
}

class _CopyWithImpl$Mutation$StudioUpdate$studioUpdate<TRes>
    implements CopyWith$Mutation$StudioUpdate$studioUpdate<TRes> {
  _CopyWithImpl$Mutation$StudioUpdate$studioUpdate(this._instance, this._then);

  final Mutation$StudioUpdate$studioUpdate _instance;

  final TRes Function(Mutation$StudioUpdate$studioUpdate) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? id = _undefined, Object? $__typename = _undefined}) =>
      _then(
        Mutation$StudioUpdate$studioUpdate(
          id: id == _undefined || id == null ? _instance.id : (id as String),
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String),
        ),
      );
}

class _CopyWithStubImpl$Mutation$StudioUpdate$studioUpdate<TRes>
    implements CopyWith$Mutation$StudioUpdate$studioUpdate<TRes> {
  _CopyWithStubImpl$Mutation$StudioUpdate$studioUpdate(this._res);

  TRes _res;

  call({String? id, String? $__typename}) => _res;
}

class Variables$Query$ScrapeSingleStudio {
  factory Variables$Query$ScrapeSingleStudio({
    required Input$ScraperSourceInput source,
    required Input$ScrapeSingleStudioInput input,
  }) => Variables$Query$ScrapeSingleStudio._({
    r'source': source,
    r'input': input,
  });

  Variables$Query$ScrapeSingleStudio._(this._$data);

  factory Variables$Query$ScrapeSingleStudio.fromJson(
    Map<String, dynamic> data,
  ) {
    final result$data = <String, dynamic>{};
    final l$source = data['source'];
    result$data['source'] = Input$ScraperSourceInput.fromJson(
      (l$source as Map<String, dynamic>),
    );
    final l$input = data['input'];
    result$data['input'] = Input$ScrapeSingleStudioInput.fromJson(
      (l$input as Map<String, dynamic>),
    );
    return Variables$Query$ScrapeSingleStudio._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$ScraperSourceInput get source =>
      (_$data['source'] as Input$ScraperSourceInput);

  Input$ScrapeSingleStudioInput get input =>
      (_$data['input'] as Input$ScrapeSingleStudioInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$source = source;
    result$data['source'] = l$source.toJson();
    final l$input = input;
    result$data['input'] = l$input.toJson();
    return result$data;
  }

  CopyWith$Variables$Query$ScrapeSingleStudio<
    Variables$Query$ScrapeSingleStudio
  >
  get copyWith => CopyWith$Variables$Query$ScrapeSingleStudio(this, (i) => i);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$ScrapeSingleStudio ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$source = source;
    final lOther$source = other.source;
    if (l$source != lOther$source) {
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
    final l$source = source;
    final l$input = input;
    return Object.hashAll([l$source, l$input]);
  }
}

abstract class CopyWith$Variables$Query$ScrapeSingleStudio<TRes> {
  factory CopyWith$Variables$Query$ScrapeSingleStudio(
    Variables$Query$ScrapeSingleStudio instance,
    TRes Function(Variables$Query$ScrapeSingleStudio) then,
  ) = _CopyWithImpl$Variables$Query$ScrapeSingleStudio;

  factory CopyWith$Variables$Query$ScrapeSingleStudio.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$ScrapeSingleStudio;

  TRes call({
    Input$ScraperSourceInput? source,
    Input$ScrapeSingleStudioInput? input,
  });
}

class _CopyWithImpl$Variables$Query$ScrapeSingleStudio<TRes>
    implements CopyWith$Variables$Query$ScrapeSingleStudio<TRes> {
  _CopyWithImpl$Variables$Query$ScrapeSingleStudio(this._instance, this._then);

  final Variables$Query$ScrapeSingleStudio _instance;

  final TRes Function(Variables$Query$ScrapeSingleStudio) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? source = _undefined, Object? input = _undefined}) => _then(
    Variables$Query$ScrapeSingleStudio._({
      ..._instance._$data,
      if (source != _undefined && source != null)
        'source': (source as Input$ScraperSourceInput),
      if (input != _undefined && input != null)
        'input': (input as Input$ScrapeSingleStudioInput),
    }),
  );
}

class _CopyWithStubImpl$Variables$Query$ScrapeSingleStudio<TRes>
    implements CopyWith$Variables$Query$ScrapeSingleStudio<TRes> {
  _CopyWithStubImpl$Variables$Query$ScrapeSingleStudio(this._res);

  TRes _res;

  call({
    Input$ScraperSourceInput? source,
    Input$ScrapeSingleStudioInput? input,
  }) => _res;
}

class Query$ScrapeSingleStudio {
  Query$ScrapeSingleStudio({
    required this.scrapeSingleStudio,
    this.$__typename = 'Query',
  });

  factory Query$ScrapeSingleStudio.fromJson(Map<String, dynamic> json) {
    final l$scrapeSingleStudio = json['scrapeSingleStudio'];
    final l$$__typename = json['__typename'];
    return Query$ScrapeSingleStudio(
      scrapeSingleStudio: (l$scrapeSingleStudio as List<dynamic>)
          .map(
            (e) => Query$ScrapeSingleStudio$scrapeSingleStudio.fromJson(
              (e as Map<String, dynamic>),
            ),
          )
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Query$ScrapeSingleStudio$scrapeSingleStudio> scrapeSingleStudio;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$scrapeSingleStudio = scrapeSingleStudio;
    _resultData['scrapeSingleStudio'] = l$scrapeSingleStudio
        .map((e) => e.toJson())
        .toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$scrapeSingleStudio = scrapeSingleStudio;
    final l$$__typename = $__typename;
    return Object.hashAll([
      Object.hashAll(l$scrapeSingleStudio.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$ScrapeSingleStudio ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$scrapeSingleStudio = scrapeSingleStudio;
    final lOther$scrapeSingleStudio = other.scrapeSingleStudio;
    if (l$scrapeSingleStudio.length != lOther$scrapeSingleStudio.length) {
      return false;
    }
    for (int i = 0; i < l$scrapeSingleStudio.length; i++) {
      final l$scrapeSingleStudio$entry = l$scrapeSingleStudio[i];
      final lOther$scrapeSingleStudio$entry = lOther$scrapeSingleStudio[i];
      if (l$scrapeSingleStudio$entry != lOther$scrapeSingleStudio$entry) {
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

extension UtilityExtension$Query$ScrapeSingleStudio
    on Query$ScrapeSingleStudio {
  CopyWith$Query$ScrapeSingleStudio<Query$ScrapeSingleStudio> get copyWith =>
      CopyWith$Query$ScrapeSingleStudio(this, (i) => i);
}

abstract class CopyWith$Query$ScrapeSingleStudio<TRes> {
  factory CopyWith$Query$ScrapeSingleStudio(
    Query$ScrapeSingleStudio instance,
    TRes Function(Query$ScrapeSingleStudio) then,
  ) = _CopyWithImpl$Query$ScrapeSingleStudio;

  factory CopyWith$Query$ScrapeSingleStudio.stub(TRes res) =
      _CopyWithStubImpl$Query$ScrapeSingleStudio;

  TRes call({
    List<Query$ScrapeSingleStudio$scrapeSingleStudio>? scrapeSingleStudio,
    String? $__typename,
  });
  TRes scrapeSingleStudio(
    Iterable<Query$ScrapeSingleStudio$scrapeSingleStudio> Function(
      Iterable<
        CopyWith$Query$ScrapeSingleStudio$scrapeSingleStudio<
          Query$ScrapeSingleStudio$scrapeSingleStudio
        >
      >,
    )
    _fn,
  );
}

class _CopyWithImpl$Query$ScrapeSingleStudio<TRes>
    implements CopyWith$Query$ScrapeSingleStudio<TRes> {
  _CopyWithImpl$Query$ScrapeSingleStudio(this._instance, this._then);

  final Query$ScrapeSingleStudio _instance;

  final TRes Function(Query$ScrapeSingleStudio) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? scrapeSingleStudio = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$ScrapeSingleStudio(
      scrapeSingleStudio:
          scrapeSingleStudio == _undefined || scrapeSingleStudio == null
          ? _instance.scrapeSingleStudio
          : (scrapeSingleStudio
                as List<Query$ScrapeSingleStudio$scrapeSingleStudio>),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  TRes scrapeSingleStudio(
    Iterable<Query$ScrapeSingleStudio$scrapeSingleStudio> Function(
      Iterable<
        CopyWith$Query$ScrapeSingleStudio$scrapeSingleStudio<
          Query$ScrapeSingleStudio$scrapeSingleStudio
        >
      >,
    )
    _fn,
  ) => call(
    scrapeSingleStudio: _fn(
      _instance.scrapeSingleStudio.map(
        (e) =>
            CopyWith$Query$ScrapeSingleStudio$scrapeSingleStudio(e, (i) => i),
      ),
    ).toList(),
  );
}

class _CopyWithStubImpl$Query$ScrapeSingleStudio<TRes>
    implements CopyWith$Query$ScrapeSingleStudio<TRes> {
  _CopyWithStubImpl$Query$ScrapeSingleStudio(this._res);

  TRes _res;

  call({
    List<Query$ScrapeSingleStudio$scrapeSingleStudio>? scrapeSingleStudio,
    String? $__typename,
  }) => _res;

  scrapeSingleStudio(_fn) => _res;
}

const documentNodeQueryScrapeSingleStudio = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.query,
      name: NameNode(value: 'ScrapeSingleStudio'),
      variableDefinitions: [
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'source')),
          type: NamedTypeNode(
            name: NameNode(value: 'ScraperSourceInput'),
            isNonNull: true,
          ),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'input')),
          type: NamedTypeNode(
            name: NameNode(value: 'ScrapeSingleStudioInput'),
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
            name: NameNode(value: 'scrapeSingleStudio'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'source'),
                value: VariableNode(name: NameNode(value: 'source')),
              ),
              ArgumentNode(
                name: NameNode(value: 'input'),
                value: VariableNode(name: NameNode(value: 'input')),
              ),
            ],
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
                  name: NameNode(value: 'url'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
                FieldNode(
                  name: NameNode(value: 'image'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
                FieldNode(
                  name: NameNode(value: 'remote_site_id'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
                FieldNode(
                  name: NameNode(value: 'details'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
                FieldNode(
                  name: NameNode(value: 'stored_id'),
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
Query$ScrapeSingleStudio _parserFn$Query$ScrapeSingleStudio(
  Map<String, dynamic> data,
) => Query$ScrapeSingleStudio.fromJson(data);
typedef OnQueryComplete$Query$ScrapeSingleStudio =
    FutureOr<void> Function(Map<String, dynamic>?, Query$ScrapeSingleStudio?);

class Options$Query$ScrapeSingleStudio
    extends graphql.QueryOptions<Query$ScrapeSingleStudio> {
  Options$Query$ScrapeSingleStudio({
    String? operationName,
    required Variables$Query$ScrapeSingleStudio variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$ScrapeSingleStudio? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$ScrapeSingleStudio? onComplete,
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
                 data == null ? null : _parserFn$Query$ScrapeSingleStudio(data),
               ),
         onError: onError,
         document: documentNodeQueryScrapeSingleStudio,
         parserFn: _parserFn$Query$ScrapeSingleStudio,
       );

  final OnQueryComplete$Query$ScrapeSingleStudio? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
    ...super.onComplete == null
        ? super.properties
        : super.properties.where((property) => property != onComplete),
    onCompleteWithParsed,
  ];
}

class WatchOptions$Query$ScrapeSingleStudio
    extends graphql.WatchQueryOptions<Query$ScrapeSingleStudio> {
  WatchOptions$Query$ScrapeSingleStudio({
    String? operationName,
    required Variables$Query$ScrapeSingleStudio variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$ScrapeSingleStudio? typedOptimisticResult,
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
         document: documentNodeQueryScrapeSingleStudio,
         pollInterval: pollInterval,
         eagerlyFetchResults: eagerlyFetchResults,
         carryForwardDataOnException: carryForwardDataOnException,
         fetchResults: fetchResults,
         parserFn: _parserFn$Query$ScrapeSingleStudio,
       );
}

class FetchMoreOptions$Query$ScrapeSingleStudio
    extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$ScrapeSingleStudio({
    required graphql.UpdateQuery updateQuery,
    required Variables$Query$ScrapeSingleStudio variables,
  }) : super(
         updateQuery: updateQuery,
         variables: variables.toJson(),
         document: documentNodeQueryScrapeSingleStudio,
       );
}

extension ClientExtension$Query$ScrapeSingleStudio on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$ScrapeSingleStudio>>
  query$ScrapeSingleStudio(Options$Query$ScrapeSingleStudio options) async =>
      await this.query(options);

  graphql.ObservableQuery<Query$ScrapeSingleStudio>
  watchQuery$ScrapeSingleStudio(
    WatchOptions$Query$ScrapeSingleStudio options,
  ) => this.watchQuery(options);

  void writeQuery$ScrapeSingleStudio({
    required Query$ScrapeSingleStudio data,
    required Variables$Query$ScrapeSingleStudio variables,
    bool broadcast = true,
  }) => this.writeQuery(
    graphql.Request(
      operation: graphql.Operation(
        document: documentNodeQueryScrapeSingleStudio,
      ),
      variables: variables.toJson(),
    ),
    data: data.toJson(),
    broadcast: broadcast,
  );

  Query$ScrapeSingleStudio? readQuery$ScrapeSingleStudio({
    required Variables$Query$ScrapeSingleStudio variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(
          document: documentNodeQueryScrapeSingleStudio,
        ),
        variables: variables.toJson(),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$ScrapeSingleStudio.fromJson(result);
  }
}

class Query$ScrapeSingleStudio$scrapeSingleStudio {
  Query$ScrapeSingleStudio$scrapeSingleStudio({
    required this.name,
    this.url,
    this.image,
    this.remote_site_id,
    this.details,
    this.stored_id,
    this.$__typename = 'ScrapedStudio',
  });

  factory Query$ScrapeSingleStudio$scrapeSingleStudio.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$name = json['name'];
    final l$url = json['url'];
    final l$image = json['image'];
    final l$remote_site_id = json['remote_site_id'];
    final l$details = json['details'];
    final l$stored_id = json['stored_id'];
    final l$$__typename = json['__typename'];
    return Query$ScrapeSingleStudio$scrapeSingleStudio(
      name: (l$name as String),
      url: (l$url as String?),
      image: (l$image as String?),
      remote_site_id: (l$remote_site_id as String?),
      details: (l$details as String?),
      stored_id: (l$stored_id as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String name;

  @Deprecated('use urls')
  final String? url;

  final String? image;

  final String? remote_site_id;

  final String? details;

  final String? stored_id;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$name = name;
    _resultData['name'] = l$name;
    final l$url = url;
    _resultData['url'] = l$url;
    final l$image = image;
    _resultData['image'] = l$image;
    final l$remote_site_id = remote_site_id;
    _resultData['remote_site_id'] = l$remote_site_id;
    final l$details = details;
    _resultData['details'] = l$details;
    final l$stored_id = stored_id;
    _resultData['stored_id'] = l$stored_id;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$name = name;
    final l$url = url;
    final l$image = image;
    final l$remote_site_id = remote_site_id;
    final l$details = details;
    final l$stored_id = stored_id;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$name,
      l$url,
      l$image,
      l$remote_site_id,
      l$details,
      l$stored_id,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$ScrapeSingleStudio$scrapeSingleStudio ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    final l$url = url;
    final lOther$url = other.url;
    if (l$url != lOther$url) {
      return false;
    }
    final l$image = image;
    final lOther$image = other.image;
    if (l$image != lOther$image) {
      return false;
    }
    final l$remote_site_id = remote_site_id;
    final lOther$remote_site_id = other.remote_site_id;
    if (l$remote_site_id != lOther$remote_site_id) {
      return false;
    }
    final l$details = details;
    final lOther$details = other.details;
    if (l$details != lOther$details) {
      return false;
    }
    final l$stored_id = stored_id;
    final lOther$stored_id = other.stored_id;
    if (l$stored_id != lOther$stored_id) {
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

extension UtilityExtension$Query$ScrapeSingleStudio$scrapeSingleStudio
    on Query$ScrapeSingleStudio$scrapeSingleStudio {
  CopyWith$Query$ScrapeSingleStudio$scrapeSingleStudio<
    Query$ScrapeSingleStudio$scrapeSingleStudio
  >
  get copyWith =>
      CopyWith$Query$ScrapeSingleStudio$scrapeSingleStudio(this, (i) => i);
}

abstract class CopyWith$Query$ScrapeSingleStudio$scrapeSingleStudio<TRes> {
  factory CopyWith$Query$ScrapeSingleStudio$scrapeSingleStudio(
    Query$ScrapeSingleStudio$scrapeSingleStudio instance,
    TRes Function(Query$ScrapeSingleStudio$scrapeSingleStudio) then,
  ) = _CopyWithImpl$Query$ScrapeSingleStudio$scrapeSingleStudio;

  factory CopyWith$Query$ScrapeSingleStudio$scrapeSingleStudio.stub(TRes res) =
      _CopyWithStubImpl$Query$ScrapeSingleStudio$scrapeSingleStudio;

  TRes call({
    String? name,
    String? url,
    String? image,
    String? remote_site_id,
    String? details,
    String? stored_id,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$ScrapeSingleStudio$scrapeSingleStudio<TRes>
    implements CopyWith$Query$ScrapeSingleStudio$scrapeSingleStudio<TRes> {
  _CopyWithImpl$Query$ScrapeSingleStudio$scrapeSingleStudio(
    this._instance,
    this._then,
  );

  final Query$ScrapeSingleStudio$scrapeSingleStudio _instance;

  final TRes Function(Query$ScrapeSingleStudio$scrapeSingleStudio) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? name = _undefined,
    Object? url = _undefined,
    Object? image = _undefined,
    Object? remote_site_id = _undefined,
    Object? details = _undefined,
    Object? stored_id = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$ScrapeSingleStudio$scrapeSingleStudio(
      name: name == _undefined || name == null
          ? _instance.name
          : (name as String),
      url: url == _undefined ? _instance.url : (url as String?),
      image: image == _undefined ? _instance.image : (image as String?),
      remote_site_id: remote_site_id == _undefined
          ? _instance.remote_site_id
          : (remote_site_id as String?),
      details: details == _undefined ? _instance.details : (details as String?),
      stored_id: stored_id == _undefined
          ? _instance.stored_id
          : (stored_id as String?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Query$ScrapeSingleStudio$scrapeSingleStudio<TRes>
    implements CopyWith$Query$ScrapeSingleStudio$scrapeSingleStudio<TRes> {
  _CopyWithStubImpl$Query$ScrapeSingleStudio$scrapeSingleStudio(this._res);

  TRes _res;

  call({
    String? name,
    String? url,
    String? image,
    String? remote_site_id,
    String? details,
    String? stored_id,
    String? $__typename,
  }) => _res;
}
