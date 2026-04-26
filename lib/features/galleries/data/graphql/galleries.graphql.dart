import '../../../../core/data/graphql/schema.graphql.dart';
import 'dart:async';
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;

class Fragment$GalleryData {
  Fragment$GalleryData({
    required this.id,
    this.title,
    this.date,
    this.rating100,
    required this.image_count,
    this.details,
    required this.files,
    required this.paths,
    this.cover,
    this.$__typename = 'Gallery',
  });

  factory Fragment$GalleryData.fromJson(Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$title = json['title'];
    final l$date = json['date'];
    final l$rating100 = json['rating100'];
    final l$image_count = json['image_count'];
    final l$details = json['details'];
    final l$files = json['files'];
    final l$paths = json['paths'];
    final l$cover = json['cover'];
    final l$$__typename = json['__typename'];
    return Fragment$GalleryData(
      id: (l$id as String),
      title: (l$title as String?),
      date: (l$date as String?),
      rating100: (l$rating100 as int?),
      image_count: (l$image_count as int),
      details: (l$details as String?),
      files: (l$files as List<dynamic>)
          .map(
            (e) => Fragment$GalleryData$files.fromJson(
              (e as Map<String, dynamic>),
            ),
          )
          .toList(),
      paths: Fragment$GalleryData$paths.fromJson(
        (l$paths as Map<String, dynamic>),
      ),
      cover: l$cover == null
          ? null
          : Fragment$GalleryData$cover.fromJson(
              (l$cover as Map<String, dynamic>),
            ),
      $__typename: (l$$__typename as String),
    );
  }

  final String id;

  final String? title;

  final String? date;

  final int? rating100;

  final int image_count;

  final String? details;

  final List<Fragment$GalleryData$files> files;

  final Fragment$GalleryData$paths paths;

  final Fragment$GalleryData$cover? cover;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$title = title;
    _resultData['title'] = l$title;
    final l$date = date;
    _resultData['date'] = l$date;
    final l$rating100 = rating100;
    _resultData['rating100'] = l$rating100;
    final l$image_count = image_count;
    _resultData['image_count'] = l$image_count;
    final l$details = details;
    _resultData['details'] = l$details;
    final l$files = files;
    _resultData['files'] = l$files.map((e) => e.toJson()).toList();
    final l$paths = paths;
    _resultData['paths'] = l$paths.toJson();
    final l$cover = cover;
    _resultData['cover'] = l$cover?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$title = title;
    final l$date = date;
    final l$rating100 = rating100;
    final l$image_count = image_count;
    final l$details = details;
    final l$files = files;
    final l$paths = paths;
    final l$cover = cover;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$title,
      l$date,
      l$rating100,
      l$image_count,
      l$details,
      Object.hashAll(l$files.map((v) => v)),
      l$paths,
      l$cover,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$GalleryData || runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$title = title;
    final lOther$title = other.title;
    if (l$title != lOther$title) {
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
    final l$image_count = image_count;
    final lOther$image_count = other.image_count;
    if (l$image_count != lOther$image_count) {
      return false;
    }
    final l$details = details;
    final lOther$details = other.details;
    if (l$details != lOther$details) {
      return false;
    }
    final l$files = files;
    final lOther$files = other.files;
    if (l$files.length != lOther$files.length) {
      return false;
    }
    for (int i = 0; i < l$files.length; i++) {
      final l$files$entry = l$files[i];
      final lOther$files$entry = lOther$files[i];
      if (l$files$entry != lOther$files$entry) {
        return false;
      }
    }
    final l$paths = paths;
    final lOther$paths = other.paths;
    if (l$paths != lOther$paths) {
      return false;
    }
    final l$cover = cover;
    final lOther$cover = other.cover;
    if (l$cover != lOther$cover) {
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

extension UtilityExtension$Fragment$GalleryData on Fragment$GalleryData {
  CopyWith$Fragment$GalleryData<Fragment$GalleryData> get copyWith =>
      CopyWith$Fragment$GalleryData(this, (i) => i);
}

abstract class CopyWith$Fragment$GalleryData<TRes> {
  factory CopyWith$Fragment$GalleryData(
    Fragment$GalleryData instance,
    TRes Function(Fragment$GalleryData) then,
  ) = _CopyWithImpl$Fragment$GalleryData;

  factory CopyWith$Fragment$GalleryData.stub(TRes res) =
      _CopyWithStubImpl$Fragment$GalleryData;

  TRes call({
    String? id,
    String? title,
    String? date,
    int? rating100,
    int? image_count,
    String? details,
    List<Fragment$GalleryData$files>? files,
    Fragment$GalleryData$paths? paths,
    Fragment$GalleryData$cover? cover,
    String? $__typename,
  });
  TRes files(
    Iterable<Fragment$GalleryData$files> Function(
      Iterable<CopyWith$Fragment$GalleryData$files<Fragment$GalleryData$files>>,
    )
    _fn,
  );
  CopyWith$Fragment$GalleryData$paths<TRes> get paths;
  CopyWith$Fragment$GalleryData$cover<TRes> get cover;
}

class _CopyWithImpl$Fragment$GalleryData<TRes>
    implements CopyWith$Fragment$GalleryData<TRes> {
  _CopyWithImpl$Fragment$GalleryData(this._instance, this._then);

  final Fragment$GalleryData _instance;

  final TRes Function(Fragment$GalleryData) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? title = _undefined,
    Object? date = _undefined,
    Object? rating100 = _undefined,
    Object? image_count = _undefined,
    Object? details = _undefined,
    Object? files = _undefined,
    Object? paths = _undefined,
    Object? cover = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Fragment$GalleryData(
      id: id == _undefined || id == null ? _instance.id : (id as String),
      title: title == _undefined ? _instance.title : (title as String?),
      date: date == _undefined ? _instance.date : (date as String?),
      rating100: rating100 == _undefined
          ? _instance.rating100
          : (rating100 as int?),
      image_count: image_count == _undefined || image_count == null
          ? _instance.image_count
          : (image_count as int),
      details: details == _undefined ? _instance.details : (details as String?),
      files: files == _undefined || files == null
          ? _instance.files
          : (files as List<Fragment$GalleryData$files>),
      paths: paths == _undefined || paths == null
          ? _instance.paths
          : (paths as Fragment$GalleryData$paths),
      cover: cover == _undefined
          ? _instance.cover
          : (cover as Fragment$GalleryData$cover?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  TRes files(
    Iterable<Fragment$GalleryData$files> Function(
      Iterable<CopyWith$Fragment$GalleryData$files<Fragment$GalleryData$files>>,
    )
    _fn,
  ) => call(
    files: _fn(
      _instance.files.map(
        (e) => CopyWith$Fragment$GalleryData$files(e, (i) => i),
      ),
    ).toList(),
  );

  CopyWith$Fragment$GalleryData$paths<TRes> get paths {
    final local$paths = _instance.paths;
    return CopyWith$Fragment$GalleryData$paths(
      local$paths,
      (e) => call(paths: e),
    );
  }

  CopyWith$Fragment$GalleryData$cover<TRes> get cover {
    final local$cover = _instance.cover;
    return local$cover == null
        ? CopyWith$Fragment$GalleryData$cover.stub(_then(_instance))
        : CopyWith$Fragment$GalleryData$cover(
            local$cover,
            (e) => call(cover: e),
          );
  }
}

class _CopyWithStubImpl$Fragment$GalleryData<TRes>
    implements CopyWith$Fragment$GalleryData<TRes> {
  _CopyWithStubImpl$Fragment$GalleryData(this._res);

  TRes _res;

  call({
    String? id,
    String? title,
    String? date,
    int? rating100,
    int? image_count,
    String? details,
    List<Fragment$GalleryData$files>? files,
    Fragment$GalleryData$paths? paths,
    Fragment$GalleryData$cover? cover,
    String? $__typename,
  }) => _res;

  files(_fn) => _res;

  CopyWith$Fragment$GalleryData$paths<TRes> get paths =>
      CopyWith$Fragment$GalleryData$paths.stub(_res);

  CopyWith$Fragment$GalleryData$cover<TRes> get cover =>
      CopyWith$Fragment$GalleryData$cover.stub(_res);
}

const fragmentDefinitionGalleryData = FragmentDefinitionNode(
  name: NameNode(value: 'GalleryData'),
  typeCondition: TypeConditionNode(
    on: NamedTypeNode(name: NameNode(value: 'Gallery'), isNonNull: false),
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
        name: NameNode(value: 'title'),
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
        name: NameNode(value: 'image_count'),
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
        name: NameNode(value: 'files'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: SelectionSetNode(
          selections: [
            FieldNode(
              name: NameNode(value: 'path'),
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
        name: NameNode(value: 'paths'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: SelectionSetNode(
          selections: [
            FieldNode(
              name: NameNode(value: 'cover'),
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
        name: NameNode(value: 'cover'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: SelectionSetNode(
          selections: [
            FieldNode(
              name: NameNode(value: 'visual_files'),
              alias: null,
              arguments: [],
              directives: [],
              selectionSet: SelectionSetNode(
                selections: [
                  InlineFragmentNode(
                    typeCondition: TypeConditionNode(
                      on: NamedTypeNode(
                        name: NameNode(value: 'ImageFile'),
                        isNonNull: false,
                      ),
                    ),
                    directives: [],
                    selectionSet: SelectionSetNode(
                      selections: [
                        FieldNode(
                          name: NameNode(value: 'width'),
                          alias: null,
                          arguments: [],
                          directives: [],
                          selectionSet: null,
                        ),
                        FieldNode(
                          name: NameNode(value: 'height'),
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
                  InlineFragmentNode(
                    typeCondition: TypeConditionNode(
                      on: NamedTypeNode(
                        name: NameNode(value: 'VideoFile'),
                        isNonNull: false,
                      ),
                    ),
                    directives: [],
                    selectionSet: SelectionSetNode(
                      selections: [
                        FieldNode(
                          name: NameNode(value: 'width'),
                          alias: null,
                          arguments: [],
                          directives: [],
                          selectionSet: null,
                        ),
                        FieldNode(
                          name: NameNode(value: 'height'),
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
);
const documentNodeFragmentGalleryData = DocumentNode(
  definitions: [fragmentDefinitionGalleryData],
);

extension ClientExtension$Fragment$GalleryData on graphql.GraphQLClient {
  void writeFragment$GalleryData({
    required Fragment$GalleryData data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) => this.writeFragment(
    graphql.FragmentRequest(
      idFields: idFields,
      fragment: const graphql.Fragment(
        fragmentName: 'GalleryData',
        document: documentNodeFragmentGalleryData,
      ),
    ),
    data: data.toJson(),
    broadcast: broadcast,
  );

  Fragment$GalleryData? readFragment$GalleryData({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'GalleryData',
          document: documentNodeFragmentGalleryData,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$GalleryData.fromJson(result);
  }
}

class Fragment$GalleryData$files {
  Fragment$GalleryData$files({
    required this.path,
    this.$__typename = 'GalleryFile',
  });

  factory Fragment$GalleryData$files.fromJson(Map<String, dynamic> json) {
    final l$path = json['path'];
    final l$$__typename = json['__typename'];
    return Fragment$GalleryData$files(
      path: (l$path as String),
      $__typename: (l$$__typename as String),
    );
  }

  final String path;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$path = path;
    _resultData['path'] = l$path;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$path = path;
    final l$$__typename = $__typename;
    return Object.hashAll([l$path, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$GalleryData$files ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$path = path;
    final lOther$path = other.path;
    if (l$path != lOther$path) {
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

extension UtilityExtension$Fragment$GalleryData$files
    on Fragment$GalleryData$files {
  CopyWith$Fragment$GalleryData$files<Fragment$GalleryData$files>
  get copyWith => CopyWith$Fragment$GalleryData$files(this, (i) => i);
}

abstract class CopyWith$Fragment$GalleryData$files<TRes> {
  factory CopyWith$Fragment$GalleryData$files(
    Fragment$GalleryData$files instance,
    TRes Function(Fragment$GalleryData$files) then,
  ) = _CopyWithImpl$Fragment$GalleryData$files;

  factory CopyWith$Fragment$GalleryData$files.stub(TRes res) =
      _CopyWithStubImpl$Fragment$GalleryData$files;

  TRes call({String? path, String? $__typename});
}

class _CopyWithImpl$Fragment$GalleryData$files<TRes>
    implements CopyWith$Fragment$GalleryData$files<TRes> {
  _CopyWithImpl$Fragment$GalleryData$files(this._instance, this._then);

  final Fragment$GalleryData$files _instance;

  final TRes Function(Fragment$GalleryData$files) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? path = _undefined, Object? $__typename = _undefined}) =>
      _then(
        Fragment$GalleryData$files(
          path: path == _undefined || path == null
              ? _instance.path
              : (path as String),
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String),
        ),
      );
}

class _CopyWithStubImpl$Fragment$GalleryData$files<TRes>
    implements CopyWith$Fragment$GalleryData$files<TRes> {
  _CopyWithStubImpl$Fragment$GalleryData$files(this._res);

  TRes _res;

  call({String? path, String? $__typename}) => _res;
}

class Fragment$GalleryData$paths {
  Fragment$GalleryData$paths({
    required this.cover,
    this.$__typename = 'GalleryPathsType',
  });

  factory Fragment$GalleryData$paths.fromJson(Map<String, dynamic> json) {
    final l$cover = json['cover'];
    final l$$__typename = json['__typename'];
    return Fragment$GalleryData$paths(
      cover: (l$cover as String),
      $__typename: (l$$__typename as String),
    );
  }

  final String cover;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$cover = cover;
    _resultData['cover'] = l$cover;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$cover = cover;
    final l$$__typename = $__typename;
    return Object.hashAll([l$cover, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$GalleryData$paths ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$cover = cover;
    final lOther$cover = other.cover;
    if (l$cover != lOther$cover) {
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

extension UtilityExtension$Fragment$GalleryData$paths
    on Fragment$GalleryData$paths {
  CopyWith$Fragment$GalleryData$paths<Fragment$GalleryData$paths>
  get copyWith => CopyWith$Fragment$GalleryData$paths(this, (i) => i);
}

abstract class CopyWith$Fragment$GalleryData$paths<TRes> {
  factory CopyWith$Fragment$GalleryData$paths(
    Fragment$GalleryData$paths instance,
    TRes Function(Fragment$GalleryData$paths) then,
  ) = _CopyWithImpl$Fragment$GalleryData$paths;

  factory CopyWith$Fragment$GalleryData$paths.stub(TRes res) =
      _CopyWithStubImpl$Fragment$GalleryData$paths;

  TRes call({String? cover, String? $__typename});
}

class _CopyWithImpl$Fragment$GalleryData$paths<TRes>
    implements CopyWith$Fragment$GalleryData$paths<TRes> {
  _CopyWithImpl$Fragment$GalleryData$paths(this._instance, this._then);

  final Fragment$GalleryData$paths _instance;

  final TRes Function(Fragment$GalleryData$paths) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? cover = _undefined, Object? $__typename = _undefined}) =>
      _then(
        Fragment$GalleryData$paths(
          cover: cover == _undefined || cover == null
              ? _instance.cover
              : (cover as String),
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String),
        ),
      );
}

class _CopyWithStubImpl$Fragment$GalleryData$paths<TRes>
    implements CopyWith$Fragment$GalleryData$paths<TRes> {
  _CopyWithStubImpl$Fragment$GalleryData$paths(this._res);

  TRes _res;

  call({String? cover, String? $__typename}) => _res;
}

class Fragment$GalleryData$cover {
  Fragment$GalleryData$cover({
    required this.visual_files,
    this.$__typename = 'Image',
  });

  factory Fragment$GalleryData$cover.fromJson(Map<String, dynamic> json) {
    final l$visual_files = json['visual_files'];
    final l$$__typename = json['__typename'];
    return Fragment$GalleryData$cover(
      visual_files: (l$visual_files as List<dynamic>)
          .map(
            (e) => Fragment$GalleryData$cover$visual_files.fromJson(
              (e as Map<String, dynamic>),
            ),
          )
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Fragment$GalleryData$cover$visual_files> visual_files;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$visual_files = visual_files;
    _resultData['visual_files'] = l$visual_files
        .map((e) => e.toJson())
        .toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$visual_files = visual_files;
    final l$$__typename = $__typename;
    return Object.hashAll([
      Object.hashAll(l$visual_files.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$GalleryData$cover ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$visual_files = visual_files;
    final lOther$visual_files = other.visual_files;
    if (l$visual_files.length != lOther$visual_files.length) {
      return false;
    }
    for (int i = 0; i < l$visual_files.length; i++) {
      final l$visual_files$entry = l$visual_files[i];
      final lOther$visual_files$entry = lOther$visual_files[i];
      if (l$visual_files$entry != lOther$visual_files$entry) {
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

extension UtilityExtension$Fragment$GalleryData$cover
    on Fragment$GalleryData$cover {
  CopyWith$Fragment$GalleryData$cover<Fragment$GalleryData$cover>
  get copyWith => CopyWith$Fragment$GalleryData$cover(this, (i) => i);
}

abstract class CopyWith$Fragment$GalleryData$cover<TRes> {
  factory CopyWith$Fragment$GalleryData$cover(
    Fragment$GalleryData$cover instance,
    TRes Function(Fragment$GalleryData$cover) then,
  ) = _CopyWithImpl$Fragment$GalleryData$cover;

  factory CopyWith$Fragment$GalleryData$cover.stub(TRes res) =
      _CopyWithStubImpl$Fragment$GalleryData$cover;

  TRes call({
    List<Fragment$GalleryData$cover$visual_files>? visual_files,
    String? $__typename,
  });
  TRes visual_files(
    Iterable<Fragment$GalleryData$cover$visual_files> Function(
      Iterable<
        CopyWith$Fragment$GalleryData$cover$visual_files<
          Fragment$GalleryData$cover$visual_files
        >
      >,
    )
    _fn,
  );
}

class _CopyWithImpl$Fragment$GalleryData$cover<TRes>
    implements CopyWith$Fragment$GalleryData$cover<TRes> {
  _CopyWithImpl$Fragment$GalleryData$cover(this._instance, this._then);

  final Fragment$GalleryData$cover _instance;

  final TRes Function(Fragment$GalleryData$cover) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? visual_files = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Fragment$GalleryData$cover(
      visual_files: visual_files == _undefined || visual_files == null
          ? _instance.visual_files
          : (visual_files as List<Fragment$GalleryData$cover$visual_files>),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  TRes visual_files(
    Iterable<Fragment$GalleryData$cover$visual_files> Function(
      Iterable<
        CopyWith$Fragment$GalleryData$cover$visual_files<
          Fragment$GalleryData$cover$visual_files
        >
      >,
    )
    _fn,
  ) => call(
    visual_files: _fn(
      _instance.visual_files.map(
        (e) => CopyWith$Fragment$GalleryData$cover$visual_files(e, (i) => i),
      ),
    ).toList(),
  );
}

class _CopyWithStubImpl$Fragment$GalleryData$cover<TRes>
    implements CopyWith$Fragment$GalleryData$cover<TRes> {
  _CopyWithStubImpl$Fragment$GalleryData$cover(this._res);

  TRes _res;

  call({
    List<Fragment$GalleryData$cover$visual_files>? visual_files,
    String? $__typename,
  }) => _res;

  visual_files(_fn) => _res;
}

class Fragment$GalleryData$cover$visual_files {
  Fragment$GalleryData$cover$visual_files({required this.$__typename});

  factory Fragment$GalleryData$cover$visual_files.fromJson(
    Map<String, dynamic> json,
  ) {
    switch (json["__typename"] as String) {
      case "ImageFile":
        return Fragment$GalleryData$cover$visual_files$$ImageFile.fromJson(
          json,
        );

      case "VideoFile":
        return Fragment$GalleryData$cover$visual_files$$VideoFile.fromJson(
          json,
        );

      default:
        final l$$__typename = json['__typename'];
        return Fragment$GalleryData$cover$visual_files(
          $__typename: (l$$__typename as String),
        );
    }
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$GalleryData$cover$visual_files ||
        runtimeType != other.runtimeType) {
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

extension UtilityExtension$Fragment$GalleryData$cover$visual_files
    on Fragment$GalleryData$cover$visual_files {
  CopyWith$Fragment$GalleryData$cover$visual_files<
    Fragment$GalleryData$cover$visual_files
  >
  get copyWith =>
      CopyWith$Fragment$GalleryData$cover$visual_files(this, (i) => i);

  _T when<_T>({
    required _T Function(Fragment$GalleryData$cover$visual_files$$ImageFile)
    imageFile,
    required _T Function(Fragment$GalleryData$cover$visual_files$$VideoFile)
    videoFile,
    required _T Function() orElse,
  }) {
    switch ($__typename) {
      case "ImageFile":
        return imageFile(
          this as Fragment$GalleryData$cover$visual_files$$ImageFile,
        );

      case "VideoFile":
        return videoFile(
          this as Fragment$GalleryData$cover$visual_files$$VideoFile,
        );

      default:
        return orElse();
    }
  }

  _T maybeWhen<_T>({
    _T Function(Fragment$GalleryData$cover$visual_files$$ImageFile)? imageFile,
    _T Function(Fragment$GalleryData$cover$visual_files$$VideoFile)? videoFile,
    required _T Function() orElse,
  }) {
    switch ($__typename) {
      case "ImageFile":
        if (imageFile != null) {
          return imageFile(
            this as Fragment$GalleryData$cover$visual_files$$ImageFile,
          );
        } else {
          return orElse();
        }

      case "VideoFile":
        if (videoFile != null) {
          return videoFile(
            this as Fragment$GalleryData$cover$visual_files$$VideoFile,
          );
        } else {
          return orElse();
        }

      default:
        return orElse();
    }
  }
}

abstract class CopyWith$Fragment$GalleryData$cover$visual_files<TRes> {
  factory CopyWith$Fragment$GalleryData$cover$visual_files(
    Fragment$GalleryData$cover$visual_files instance,
    TRes Function(Fragment$GalleryData$cover$visual_files) then,
  ) = _CopyWithImpl$Fragment$GalleryData$cover$visual_files;

  factory CopyWith$Fragment$GalleryData$cover$visual_files.stub(TRes res) =
      _CopyWithStubImpl$Fragment$GalleryData$cover$visual_files;

  TRes call({String? $__typename});
}

class _CopyWithImpl$Fragment$GalleryData$cover$visual_files<TRes>
    implements CopyWith$Fragment$GalleryData$cover$visual_files<TRes> {
  _CopyWithImpl$Fragment$GalleryData$cover$visual_files(
    this._instance,
    this._then,
  );

  final Fragment$GalleryData$cover$visual_files _instance;

  final TRes Function(Fragment$GalleryData$cover$visual_files) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? $__typename = _undefined}) => _then(
    Fragment$GalleryData$cover$visual_files(
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Fragment$GalleryData$cover$visual_files<TRes>
    implements CopyWith$Fragment$GalleryData$cover$visual_files<TRes> {
  _CopyWithStubImpl$Fragment$GalleryData$cover$visual_files(this._res);

  TRes _res;

  call({String? $__typename}) => _res;
}

class Fragment$GalleryData$cover$visual_files$$ImageFile
    implements Fragment$GalleryData$cover$visual_files {
  Fragment$GalleryData$cover$visual_files$$ImageFile({
    required this.width,
    required this.height,
    this.$__typename = 'ImageFile',
  });

  factory Fragment$GalleryData$cover$visual_files$$ImageFile.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$width = json['width'];
    final l$height = json['height'];
    final l$$__typename = json['__typename'];
    return Fragment$GalleryData$cover$visual_files$$ImageFile(
      width: (l$width as int),
      height: (l$height as int),
      $__typename: (l$$__typename as String),
    );
  }

  final int width;

  final int height;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$width = width;
    _resultData['width'] = l$width;
    final l$height = height;
    _resultData['height'] = l$height;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$width = width;
    final l$height = height;
    final l$$__typename = $__typename;
    return Object.hashAll([l$width, l$height, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$GalleryData$cover$visual_files$$ImageFile ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$width = width;
    final lOther$width = other.width;
    if (l$width != lOther$width) {
      return false;
    }
    final l$height = height;
    final lOther$height = other.height;
    if (l$height != lOther$height) {
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

extension UtilityExtension$Fragment$GalleryData$cover$visual_files$$ImageFile
    on Fragment$GalleryData$cover$visual_files$$ImageFile {
  CopyWith$Fragment$GalleryData$cover$visual_files$$ImageFile<
    Fragment$GalleryData$cover$visual_files$$ImageFile
  >
  get copyWith => CopyWith$Fragment$GalleryData$cover$visual_files$$ImageFile(
    this,
    (i) => i,
  );
}

abstract class CopyWith$Fragment$GalleryData$cover$visual_files$$ImageFile<
  TRes
> {
  factory CopyWith$Fragment$GalleryData$cover$visual_files$$ImageFile(
    Fragment$GalleryData$cover$visual_files$$ImageFile instance,
    TRes Function(Fragment$GalleryData$cover$visual_files$$ImageFile) then,
  ) = _CopyWithImpl$Fragment$GalleryData$cover$visual_files$$ImageFile;

  factory CopyWith$Fragment$GalleryData$cover$visual_files$$ImageFile.stub(
    TRes res,
  ) = _CopyWithStubImpl$Fragment$GalleryData$cover$visual_files$$ImageFile;

  TRes call({int? width, int? height, String? $__typename});
}

class _CopyWithImpl$Fragment$GalleryData$cover$visual_files$$ImageFile<TRes>
    implements
        CopyWith$Fragment$GalleryData$cover$visual_files$$ImageFile<TRes> {
  _CopyWithImpl$Fragment$GalleryData$cover$visual_files$$ImageFile(
    this._instance,
    this._then,
  );

  final Fragment$GalleryData$cover$visual_files$$ImageFile _instance;

  final TRes Function(Fragment$GalleryData$cover$visual_files$$ImageFile) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? width = _undefined,
    Object? height = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Fragment$GalleryData$cover$visual_files$$ImageFile(
      width: width == _undefined || width == null
          ? _instance.width
          : (width as int),
      height: height == _undefined || height == null
          ? _instance.height
          : (height as int),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Fragment$GalleryData$cover$visual_files$$ImageFile<TRes>
    implements
        CopyWith$Fragment$GalleryData$cover$visual_files$$ImageFile<TRes> {
  _CopyWithStubImpl$Fragment$GalleryData$cover$visual_files$$ImageFile(
    this._res,
  );

  TRes _res;

  call({int? width, int? height, String? $__typename}) => _res;
}

class Fragment$GalleryData$cover$visual_files$$VideoFile
    implements Fragment$GalleryData$cover$visual_files {
  Fragment$GalleryData$cover$visual_files$$VideoFile({
    required this.width,
    required this.height,
    this.$__typename = 'VideoFile',
  });

  factory Fragment$GalleryData$cover$visual_files$$VideoFile.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$width = json['width'];
    final l$height = json['height'];
    final l$$__typename = json['__typename'];
    return Fragment$GalleryData$cover$visual_files$$VideoFile(
      width: (l$width as int),
      height: (l$height as int),
      $__typename: (l$$__typename as String),
    );
  }

  final int width;

  final int height;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$width = width;
    _resultData['width'] = l$width;
    final l$height = height;
    _resultData['height'] = l$height;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$width = width;
    final l$height = height;
    final l$$__typename = $__typename;
    return Object.hashAll([l$width, l$height, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$GalleryData$cover$visual_files$$VideoFile ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$width = width;
    final lOther$width = other.width;
    if (l$width != lOther$width) {
      return false;
    }
    final l$height = height;
    final lOther$height = other.height;
    if (l$height != lOther$height) {
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

extension UtilityExtension$Fragment$GalleryData$cover$visual_files$$VideoFile
    on Fragment$GalleryData$cover$visual_files$$VideoFile {
  CopyWith$Fragment$GalleryData$cover$visual_files$$VideoFile<
    Fragment$GalleryData$cover$visual_files$$VideoFile
  >
  get copyWith => CopyWith$Fragment$GalleryData$cover$visual_files$$VideoFile(
    this,
    (i) => i,
  );
}

abstract class CopyWith$Fragment$GalleryData$cover$visual_files$$VideoFile<
  TRes
> {
  factory CopyWith$Fragment$GalleryData$cover$visual_files$$VideoFile(
    Fragment$GalleryData$cover$visual_files$$VideoFile instance,
    TRes Function(Fragment$GalleryData$cover$visual_files$$VideoFile) then,
  ) = _CopyWithImpl$Fragment$GalleryData$cover$visual_files$$VideoFile;

  factory CopyWith$Fragment$GalleryData$cover$visual_files$$VideoFile.stub(
    TRes res,
  ) = _CopyWithStubImpl$Fragment$GalleryData$cover$visual_files$$VideoFile;

  TRes call({int? width, int? height, String? $__typename});
}

class _CopyWithImpl$Fragment$GalleryData$cover$visual_files$$VideoFile<TRes>
    implements
        CopyWith$Fragment$GalleryData$cover$visual_files$$VideoFile<TRes> {
  _CopyWithImpl$Fragment$GalleryData$cover$visual_files$$VideoFile(
    this._instance,
    this._then,
  );

  final Fragment$GalleryData$cover$visual_files$$VideoFile _instance;

  final TRes Function(Fragment$GalleryData$cover$visual_files$$VideoFile) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? width = _undefined,
    Object? height = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Fragment$GalleryData$cover$visual_files$$VideoFile(
      width: width == _undefined || width == null
          ? _instance.width
          : (width as int),
      height: height == _undefined || height == null
          ? _instance.height
          : (height as int),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Fragment$GalleryData$cover$visual_files$$VideoFile<TRes>
    implements
        CopyWith$Fragment$GalleryData$cover$visual_files$$VideoFile<TRes> {
  _CopyWithStubImpl$Fragment$GalleryData$cover$visual_files$$VideoFile(
    this._res,
  );

  TRes _res;

  call({int? width, int? height, String? $__typename}) => _res;
}

class Variables$Query$FindGalleries {
  factory Variables$Query$FindGalleries({
    Input$FindFilterType? filter,
    Input$GalleryFilterType? gallery_filter,
  }) => Variables$Query$FindGalleries._({
    if (filter != null) r'filter': filter,
    if (gallery_filter != null) r'gallery_filter': gallery_filter,
  });

  Variables$Query$FindGalleries._(this._$data);

  factory Variables$Query$FindGalleries.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('filter')) {
      final l$filter = data['filter'];
      result$data['filter'] = l$filter == null
          ? null
          : Input$FindFilterType.fromJson((l$filter as Map<String, dynamic>));
    }
    if (data.containsKey('gallery_filter')) {
      final l$gallery_filter = data['gallery_filter'];
      result$data['gallery_filter'] = l$gallery_filter == null
          ? null
          : Input$GalleryFilterType.fromJson(
              (l$gallery_filter as Map<String, dynamic>),
            );
    }
    return Variables$Query$FindGalleries._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$FindFilterType? get filter =>
      (_$data['filter'] as Input$FindFilterType?);

  Input$GalleryFilterType? get gallery_filter =>
      (_$data['gallery_filter'] as Input$GalleryFilterType?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('filter')) {
      final l$filter = filter;
      result$data['filter'] = l$filter?.toJson();
    }
    if (_$data.containsKey('gallery_filter')) {
      final l$gallery_filter = gallery_filter;
      result$data['gallery_filter'] = l$gallery_filter?.toJson();
    }
    return result$data;
  }

  CopyWith$Variables$Query$FindGalleries<Variables$Query$FindGalleries>
  get copyWith => CopyWith$Variables$Query$FindGalleries(this, (i) => i);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$FindGalleries ||
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
    final l$gallery_filter = gallery_filter;
    final lOther$gallery_filter = other.gallery_filter;
    if (_$data.containsKey('gallery_filter') !=
        other._$data.containsKey('gallery_filter')) {
      return false;
    }
    if (l$gallery_filter != lOther$gallery_filter) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$filter = filter;
    final l$gallery_filter = gallery_filter;
    return Object.hashAll([
      _$data.containsKey('filter') ? l$filter : const {},
      _$data.containsKey('gallery_filter') ? l$gallery_filter : const {},
    ]);
  }
}

abstract class CopyWith$Variables$Query$FindGalleries<TRes> {
  factory CopyWith$Variables$Query$FindGalleries(
    Variables$Query$FindGalleries instance,
    TRes Function(Variables$Query$FindGalleries) then,
  ) = _CopyWithImpl$Variables$Query$FindGalleries;

  factory CopyWith$Variables$Query$FindGalleries.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$FindGalleries;

  TRes call({
    Input$FindFilterType? filter,
    Input$GalleryFilterType? gallery_filter,
  });
}

class _CopyWithImpl$Variables$Query$FindGalleries<TRes>
    implements CopyWith$Variables$Query$FindGalleries<TRes> {
  _CopyWithImpl$Variables$Query$FindGalleries(this._instance, this._then);

  final Variables$Query$FindGalleries _instance;

  final TRes Function(Variables$Query$FindGalleries) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? filter = _undefined,
    Object? gallery_filter = _undefined,
  }) => _then(
    Variables$Query$FindGalleries._({
      ..._instance._$data,
      if (filter != _undefined) 'filter': (filter as Input$FindFilterType?),
      if (gallery_filter != _undefined)
        'gallery_filter': (gallery_filter as Input$GalleryFilterType?),
    }),
  );
}

class _CopyWithStubImpl$Variables$Query$FindGalleries<TRes>
    implements CopyWith$Variables$Query$FindGalleries<TRes> {
  _CopyWithStubImpl$Variables$Query$FindGalleries(this._res);

  TRes _res;

  call({
    Input$FindFilterType? filter,
    Input$GalleryFilterType? gallery_filter,
  }) => _res;
}

class Query$FindGalleries {
  Query$FindGalleries({
    required this.findGalleries,
    this.$__typename = 'Query',
  });

  factory Query$FindGalleries.fromJson(Map<String, dynamic> json) {
    final l$findGalleries = json['findGalleries'];
    final l$$__typename = json['__typename'];
    return Query$FindGalleries(
      findGalleries: Query$FindGalleries$findGalleries.fromJson(
        (l$findGalleries as Map<String, dynamic>),
      ),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$FindGalleries$findGalleries findGalleries;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$findGalleries = findGalleries;
    _resultData['findGalleries'] = l$findGalleries.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$findGalleries = findGalleries;
    final l$$__typename = $__typename;
    return Object.hashAll([l$findGalleries, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$FindGalleries || runtimeType != other.runtimeType) {
      return false;
    }
    final l$findGalleries = findGalleries;
    final lOther$findGalleries = other.findGalleries;
    if (l$findGalleries != lOther$findGalleries) {
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

extension UtilityExtension$Query$FindGalleries on Query$FindGalleries {
  CopyWith$Query$FindGalleries<Query$FindGalleries> get copyWith =>
      CopyWith$Query$FindGalleries(this, (i) => i);
}

abstract class CopyWith$Query$FindGalleries<TRes> {
  factory CopyWith$Query$FindGalleries(
    Query$FindGalleries instance,
    TRes Function(Query$FindGalleries) then,
  ) = _CopyWithImpl$Query$FindGalleries;

  factory CopyWith$Query$FindGalleries.stub(TRes res) =
      _CopyWithStubImpl$Query$FindGalleries;

  TRes call({
    Query$FindGalleries$findGalleries? findGalleries,
    String? $__typename,
  });
  CopyWith$Query$FindGalleries$findGalleries<TRes> get findGalleries;
}

class _CopyWithImpl$Query$FindGalleries<TRes>
    implements CopyWith$Query$FindGalleries<TRes> {
  _CopyWithImpl$Query$FindGalleries(this._instance, this._then);

  final Query$FindGalleries _instance;

  final TRes Function(Query$FindGalleries) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? findGalleries = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$FindGalleries(
      findGalleries: findGalleries == _undefined || findGalleries == null
          ? _instance.findGalleries
          : (findGalleries as Query$FindGalleries$findGalleries),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  CopyWith$Query$FindGalleries$findGalleries<TRes> get findGalleries {
    final local$findGalleries = _instance.findGalleries;
    return CopyWith$Query$FindGalleries$findGalleries(
      local$findGalleries,
      (e) => call(findGalleries: e),
    );
  }
}

class _CopyWithStubImpl$Query$FindGalleries<TRes>
    implements CopyWith$Query$FindGalleries<TRes> {
  _CopyWithStubImpl$Query$FindGalleries(this._res);

  TRes _res;

  call({
    Query$FindGalleries$findGalleries? findGalleries,
    String? $__typename,
  }) => _res;

  CopyWith$Query$FindGalleries$findGalleries<TRes> get findGalleries =>
      CopyWith$Query$FindGalleries$findGalleries.stub(_res);
}

const documentNodeQueryFindGalleries = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.query,
      name: NameNode(value: 'FindGalleries'),
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
          variable: VariableNode(name: NameNode(value: 'gallery_filter')),
          type: NamedTypeNode(
            name: NameNode(value: 'GalleryFilterType'),
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
            name: NameNode(value: 'findGalleries'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'filter'),
                value: VariableNode(name: NameNode(value: 'filter')),
              ),
              ArgumentNode(
                name: NameNode(value: 'gallery_filter'),
                value: VariableNode(name: NameNode(value: 'gallery_filter')),
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
                  name: NameNode(value: 'galleries'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: SelectionSetNode(
                    selections: [
                      FragmentSpreadNode(
                        name: NameNode(value: 'GalleryData'),
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
    fragmentDefinitionGalleryData,
  ],
);
Query$FindGalleries _parserFn$Query$FindGalleries(Map<String, dynamic> data) =>
    Query$FindGalleries.fromJson(data);
typedef OnQueryComplete$Query$FindGalleries =
    FutureOr<void> Function(Map<String, dynamic>?, Query$FindGalleries?);

class Options$Query$FindGalleries
    extends graphql.QueryOptions<Query$FindGalleries> {
  Options$Query$FindGalleries({
    String? operationName,
    Variables$Query$FindGalleries? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$FindGalleries? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$FindGalleries? onComplete,
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
                 data == null ? null : _parserFn$Query$FindGalleries(data),
               ),
         onError: onError,
         document: documentNodeQueryFindGalleries,
         parserFn: _parserFn$Query$FindGalleries,
       );

  final OnQueryComplete$Query$FindGalleries? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
    ...super.onComplete == null
        ? super.properties
        : super.properties.where((property) => property != onComplete),
    onCompleteWithParsed,
  ];
}

class WatchOptions$Query$FindGalleries
    extends graphql.WatchQueryOptions<Query$FindGalleries> {
  WatchOptions$Query$FindGalleries({
    String? operationName,
    Variables$Query$FindGalleries? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$FindGalleries? typedOptimisticResult,
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
         document: documentNodeQueryFindGalleries,
         pollInterval: pollInterval,
         eagerlyFetchResults: eagerlyFetchResults,
         carryForwardDataOnException: carryForwardDataOnException,
         fetchResults: fetchResults,
         parserFn: _parserFn$Query$FindGalleries,
       );
}

class FetchMoreOptions$Query$FindGalleries extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$FindGalleries({
    required graphql.UpdateQuery updateQuery,
    Variables$Query$FindGalleries? variables,
  }) : super(
         updateQuery: updateQuery,
         variables: variables?.toJson() ?? {},
         document: documentNodeQueryFindGalleries,
       );
}

extension ClientExtension$Query$FindGalleries on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$FindGalleries>> query$FindGalleries([
    Options$Query$FindGalleries? options,
  ]) async => await this.query(options ?? Options$Query$FindGalleries());

  graphql.ObservableQuery<Query$FindGalleries> watchQuery$FindGalleries([
    WatchOptions$Query$FindGalleries? options,
  ]) => this.watchQuery(options ?? WatchOptions$Query$FindGalleries());

  void writeQuery$FindGalleries({
    required Query$FindGalleries data,
    Variables$Query$FindGalleries? variables,
    bool broadcast = true,
  }) => this.writeQuery(
    graphql.Request(
      operation: graphql.Operation(document: documentNodeQueryFindGalleries),
      variables: variables?.toJson() ?? const {},
    ),
    data: data.toJson(),
    broadcast: broadcast,
  );

  Query$FindGalleries? readQuery$FindGalleries({
    Variables$Query$FindGalleries? variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(document: documentNodeQueryFindGalleries),
        variables: variables?.toJson() ?? const {},
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$FindGalleries.fromJson(result);
  }
}

class Query$FindGalleries$findGalleries {
  Query$FindGalleries$findGalleries({
    required this.count,
    required this.galleries,
    this.$__typename = 'FindGalleriesResultType',
  });

  factory Query$FindGalleries$findGalleries.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$count = json['count'];
    final l$galleries = json['galleries'];
    final l$$__typename = json['__typename'];
    return Query$FindGalleries$findGalleries(
      count: (l$count as int),
      galleries: (l$galleries as List<dynamic>)
          .map(
            (e) => Fragment$GalleryData.fromJson((e as Map<String, dynamic>)),
          )
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final int count;

  final List<Fragment$GalleryData> galleries;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$count = count;
    _resultData['count'] = l$count;
    final l$galleries = galleries;
    _resultData['galleries'] = l$galleries.map((e) => e.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$count = count;
    final l$galleries = galleries;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$count,
      Object.hashAll(l$galleries.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$FindGalleries$findGalleries ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$count = count;
    final lOther$count = other.count;
    if (l$count != lOther$count) {
      return false;
    }
    final l$galleries = galleries;
    final lOther$galleries = other.galleries;
    if (l$galleries.length != lOther$galleries.length) {
      return false;
    }
    for (int i = 0; i < l$galleries.length; i++) {
      final l$galleries$entry = l$galleries[i];
      final lOther$galleries$entry = lOther$galleries[i];
      if (l$galleries$entry != lOther$galleries$entry) {
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

extension UtilityExtension$Query$FindGalleries$findGalleries
    on Query$FindGalleries$findGalleries {
  CopyWith$Query$FindGalleries$findGalleries<Query$FindGalleries$findGalleries>
  get copyWith => CopyWith$Query$FindGalleries$findGalleries(this, (i) => i);
}

abstract class CopyWith$Query$FindGalleries$findGalleries<TRes> {
  factory CopyWith$Query$FindGalleries$findGalleries(
    Query$FindGalleries$findGalleries instance,
    TRes Function(Query$FindGalleries$findGalleries) then,
  ) = _CopyWithImpl$Query$FindGalleries$findGalleries;

  factory CopyWith$Query$FindGalleries$findGalleries.stub(TRes res) =
      _CopyWithStubImpl$Query$FindGalleries$findGalleries;

  TRes call({
    int? count,
    List<Fragment$GalleryData>? galleries,
    String? $__typename,
  });
  TRes galleries(
    Iterable<Fragment$GalleryData> Function(
      Iterable<CopyWith$Fragment$GalleryData<Fragment$GalleryData>>,
    )
    _fn,
  );
}

class _CopyWithImpl$Query$FindGalleries$findGalleries<TRes>
    implements CopyWith$Query$FindGalleries$findGalleries<TRes> {
  _CopyWithImpl$Query$FindGalleries$findGalleries(this._instance, this._then);

  final Query$FindGalleries$findGalleries _instance;

  final TRes Function(Query$FindGalleries$findGalleries) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? count = _undefined,
    Object? galleries = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$FindGalleries$findGalleries(
      count: count == _undefined || count == null
          ? _instance.count
          : (count as int),
      galleries: galleries == _undefined || galleries == null
          ? _instance.galleries
          : (galleries as List<Fragment$GalleryData>),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  TRes galleries(
    Iterable<Fragment$GalleryData> Function(
      Iterable<CopyWith$Fragment$GalleryData<Fragment$GalleryData>>,
    )
    _fn,
  ) => call(
    galleries: _fn(
      _instance.galleries.map(
        (e) => CopyWith$Fragment$GalleryData(e, (i) => i),
      ),
    ).toList(),
  );
}

class _CopyWithStubImpl$Query$FindGalleries$findGalleries<TRes>
    implements CopyWith$Query$FindGalleries$findGalleries<TRes> {
  _CopyWithStubImpl$Query$FindGalleries$findGalleries(this._res);

  TRes _res;

  call({
    int? count,
    List<Fragment$GalleryData>? galleries,
    String? $__typename,
  }) => _res;

  galleries(_fn) => _res;
}

class Variables$Query$FindGallery {
  factory Variables$Query$FindGallery({required String id}) =>
      Variables$Query$FindGallery._({r'id': id});

  Variables$Query$FindGallery._(this._$data);

  factory Variables$Query$FindGallery.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$id = data['id'];
    result$data['id'] = (l$id as String);
    return Variables$Query$FindGallery._(result$data);
  }

  Map<String, dynamic> _$data;

  String get id => (_$data['id'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$id = id;
    result$data['id'] = l$id;
    return result$data;
  }

  CopyWith$Variables$Query$FindGallery<Variables$Query$FindGallery>
  get copyWith => CopyWith$Variables$Query$FindGallery(this, (i) => i);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$FindGallery ||
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

abstract class CopyWith$Variables$Query$FindGallery<TRes> {
  factory CopyWith$Variables$Query$FindGallery(
    Variables$Query$FindGallery instance,
    TRes Function(Variables$Query$FindGallery) then,
  ) = _CopyWithImpl$Variables$Query$FindGallery;

  factory CopyWith$Variables$Query$FindGallery.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$FindGallery;

  TRes call({String? id});
}

class _CopyWithImpl$Variables$Query$FindGallery<TRes>
    implements CopyWith$Variables$Query$FindGallery<TRes> {
  _CopyWithImpl$Variables$Query$FindGallery(this._instance, this._then);

  final Variables$Query$FindGallery _instance;

  final TRes Function(Variables$Query$FindGallery) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? id = _undefined}) => _then(
    Variables$Query$FindGallery._({
      ..._instance._$data,
      if (id != _undefined && id != null) 'id': (id as String),
    }),
  );
}

class _CopyWithStubImpl$Variables$Query$FindGallery<TRes>
    implements CopyWith$Variables$Query$FindGallery<TRes> {
  _CopyWithStubImpl$Variables$Query$FindGallery(this._res);

  TRes _res;

  call({String? id}) => _res;
}

class Query$FindGallery {
  Query$FindGallery({this.findGallery, this.$__typename = 'Query'});

  factory Query$FindGallery.fromJson(Map<String, dynamic> json) {
    final l$findGallery = json['findGallery'];
    final l$$__typename = json['__typename'];
    return Query$FindGallery(
      findGallery: l$findGallery == null
          ? null
          : Fragment$GalleryData.fromJson(
              (l$findGallery as Map<String, dynamic>),
            ),
      $__typename: (l$$__typename as String),
    );
  }

  final Fragment$GalleryData? findGallery;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$findGallery = findGallery;
    _resultData['findGallery'] = l$findGallery?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$findGallery = findGallery;
    final l$$__typename = $__typename;
    return Object.hashAll([l$findGallery, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$FindGallery || runtimeType != other.runtimeType) {
      return false;
    }
    final l$findGallery = findGallery;
    final lOther$findGallery = other.findGallery;
    if (l$findGallery != lOther$findGallery) {
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

extension UtilityExtension$Query$FindGallery on Query$FindGallery {
  CopyWith$Query$FindGallery<Query$FindGallery> get copyWith =>
      CopyWith$Query$FindGallery(this, (i) => i);
}

abstract class CopyWith$Query$FindGallery<TRes> {
  factory CopyWith$Query$FindGallery(
    Query$FindGallery instance,
    TRes Function(Query$FindGallery) then,
  ) = _CopyWithImpl$Query$FindGallery;

  factory CopyWith$Query$FindGallery.stub(TRes res) =
      _CopyWithStubImpl$Query$FindGallery;

  TRes call({Fragment$GalleryData? findGallery, String? $__typename});
  CopyWith$Fragment$GalleryData<TRes> get findGallery;
}

class _CopyWithImpl$Query$FindGallery<TRes>
    implements CopyWith$Query$FindGallery<TRes> {
  _CopyWithImpl$Query$FindGallery(this._instance, this._then);

  final Query$FindGallery _instance;

  final TRes Function(Query$FindGallery) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? findGallery = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$FindGallery(
      findGallery: findGallery == _undefined
          ? _instance.findGallery
          : (findGallery as Fragment$GalleryData?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  CopyWith$Fragment$GalleryData<TRes> get findGallery {
    final local$findGallery = _instance.findGallery;
    return local$findGallery == null
        ? CopyWith$Fragment$GalleryData.stub(_then(_instance))
        : CopyWith$Fragment$GalleryData(
            local$findGallery,
            (e) => call(findGallery: e),
          );
  }
}

class _CopyWithStubImpl$Query$FindGallery<TRes>
    implements CopyWith$Query$FindGallery<TRes> {
  _CopyWithStubImpl$Query$FindGallery(this._res);

  TRes _res;

  call({Fragment$GalleryData? findGallery, String? $__typename}) => _res;

  CopyWith$Fragment$GalleryData<TRes> get findGallery =>
      CopyWith$Fragment$GalleryData.stub(_res);
}

const documentNodeQueryFindGallery = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.query,
      name: NameNode(value: 'FindGallery'),
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
            name: NameNode(value: 'findGallery'),
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
                  name: NameNode(value: 'GalleryData'),
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
    fragmentDefinitionGalleryData,
  ],
);
Query$FindGallery _parserFn$Query$FindGallery(Map<String, dynamic> data) =>
    Query$FindGallery.fromJson(data);
typedef OnQueryComplete$Query$FindGallery =
    FutureOr<void> Function(Map<String, dynamic>?, Query$FindGallery?);

class Options$Query$FindGallery
    extends graphql.QueryOptions<Query$FindGallery> {
  Options$Query$FindGallery({
    String? operationName,
    required Variables$Query$FindGallery variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$FindGallery? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$FindGallery? onComplete,
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
                 data == null ? null : _parserFn$Query$FindGallery(data),
               ),
         onError: onError,
         document: documentNodeQueryFindGallery,
         parserFn: _parserFn$Query$FindGallery,
       );

  final OnQueryComplete$Query$FindGallery? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
    ...super.onComplete == null
        ? super.properties
        : super.properties.where((property) => property != onComplete),
    onCompleteWithParsed,
  ];
}

class WatchOptions$Query$FindGallery
    extends graphql.WatchQueryOptions<Query$FindGallery> {
  WatchOptions$Query$FindGallery({
    String? operationName,
    required Variables$Query$FindGallery variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$FindGallery? typedOptimisticResult,
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
         document: documentNodeQueryFindGallery,
         pollInterval: pollInterval,
         eagerlyFetchResults: eagerlyFetchResults,
         carryForwardDataOnException: carryForwardDataOnException,
         fetchResults: fetchResults,
         parserFn: _parserFn$Query$FindGallery,
       );
}

class FetchMoreOptions$Query$FindGallery extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$FindGallery({
    required graphql.UpdateQuery updateQuery,
    required Variables$Query$FindGallery variables,
  }) : super(
         updateQuery: updateQuery,
         variables: variables.toJson(),
         document: documentNodeQueryFindGallery,
       );
}

extension ClientExtension$Query$FindGallery on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$FindGallery>> query$FindGallery(
    Options$Query$FindGallery options,
  ) async => await this.query(options);

  graphql.ObservableQuery<Query$FindGallery> watchQuery$FindGallery(
    WatchOptions$Query$FindGallery options,
  ) => this.watchQuery(options);

  void writeQuery$FindGallery({
    required Query$FindGallery data,
    required Variables$Query$FindGallery variables,
    bool broadcast = true,
  }) => this.writeQuery(
    graphql.Request(
      operation: graphql.Operation(document: documentNodeQueryFindGallery),
      variables: variables.toJson(),
    ),
    data: data.toJson(),
    broadcast: broadcast,
  );

  Query$FindGallery? readQuery$FindGallery({
    required Variables$Query$FindGallery variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(document: documentNodeQueryFindGallery),
        variables: variables.toJson(),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$FindGallery.fromJson(result);
  }
}

class Variables$Mutation$UpdateGalleryRating {
  factory Variables$Mutation$UpdateGalleryRating({
    required String id,
    required int rating,
  }) =>
      Variables$Mutation$UpdateGalleryRating._({r'id': id, r'rating': rating});

  Variables$Mutation$UpdateGalleryRating._(this._$data);

  factory Variables$Mutation$UpdateGalleryRating.fromJson(
    Map<String, dynamic> data,
  ) {
    final result$data = <String, dynamic>{};
    final l$id = data['id'];
    result$data['id'] = (l$id as String);
    final l$rating = data['rating'];
    result$data['rating'] = (l$rating as int);
    return Variables$Mutation$UpdateGalleryRating._(result$data);
  }

  Map<String, dynamic> _$data;

  String get id => (_$data['id'] as String);

  int get rating => (_$data['rating'] as int);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$id = id;
    result$data['id'] = l$id;
    final l$rating = rating;
    result$data['rating'] = l$rating;
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdateGalleryRating<
    Variables$Mutation$UpdateGalleryRating
  >
  get copyWith =>
      CopyWith$Variables$Mutation$UpdateGalleryRating(this, (i) => i);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdateGalleryRating ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$rating = rating;
    final lOther$rating = other.rating;
    if (l$rating != lOther$rating) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$rating = rating;
    return Object.hashAll([l$id, l$rating]);
  }
}

abstract class CopyWith$Variables$Mutation$UpdateGalleryRating<TRes> {
  factory CopyWith$Variables$Mutation$UpdateGalleryRating(
    Variables$Mutation$UpdateGalleryRating instance,
    TRes Function(Variables$Mutation$UpdateGalleryRating) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateGalleryRating;

  factory CopyWith$Variables$Mutation$UpdateGalleryRating.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateGalleryRating;

  TRes call({String? id, int? rating});
}

class _CopyWithImpl$Variables$Mutation$UpdateGalleryRating<TRes>
    implements CopyWith$Variables$Mutation$UpdateGalleryRating<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateGalleryRating(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateGalleryRating _instance;

  final TRes Function(Variables$Mutation$UpdateGalleryRating) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? id = _undefined, Object? rating = _undefined}) => _then(
    Variables$Mutation$UpdateGalleryRating._({
      ..._instance._$data,
      if (id != _undefined && id != null) 'id': (id as String),
      if (rating != _undefined && rating != null) 'rating': (rating as int),
    }),
  );
}

class _CopyWithStubImpl$Variables$Mutation$UpdateGalleryRating<TRes>
    implements CopyWith$Variables$Mutation$UpdateGalleryRating<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateGalleryRating(this._res);

  TRes _res;

  call({String? id, int? rating}) => _res;
}

class Mutation$UpdateGalleryRating {
  Mutation$UpdateGalleryRating({
    this.galleryUpdate,
    this.$__typename = 'Mutation',
  });

  factory Mutation$UpdateGalleryRating.fromJson(Map<String, dynamic> json) {
    final l$galleryUpdate = json['galleryUpdate'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateGalleryRating(
      galleryUpdate: l$galleryUpdate == null
          ? null
          : Mutation$UpdateGalleryRating$galleryUpdate.fromJson(
              (l$galleryUpdate as Map<String, dynamic>),
            ),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateGalleryRating$galleryUpdate? galleryUpdate;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$galleryUpdate = galleryUpdate;
    _resultData['galleryUpdate'] = l$galleryUpdate?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$galleryUpdate = galleryUpdate;
    final l$$__typename = $__typename;
    return Object.hashAll([l$galleryUpdate, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdateGalleryRating ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$galleryUpdate = galleryUpdate;
    final lOther$galleryUpdate = other.galleryUpdate;
    if (l$galleryUpdate != lOther$galleryUpdate) {
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

extension UtilityExtension$Mutation$UpdateGalleryRating
    on Mutation$UpdateGalleryRating {
  CopyWith$Mutation$UpdateGalleryRating<Mutation$UpdateGalleryRating>
  get copyWith => CopyWith$Mutation$UpdateGalleryRating(this, (i) => i);
}

abstract class CopyWith$Mutation$UpdateGalleryRating<TRes> {
  factory CopyWith$Mutation$UpdateGalleryRating(
    Mutation$UpdateGalleryRating instance,
    TRes Function(Mutation$UpdateGalleryRating) then,
  ) = _CopyWithImpl$Mutation$UpdateGalleryRating;

  factory CopyWith$Mutation$UpdateGalleryRating.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateGalleryRating;

  TRes call({
    Mutation$UpdateGalleryRating$galleryUpdate? galleryUpdate,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateGalleryRating$galleryUpdate<TRes> get galleryUpdate;
}

class _CopyWithImpl$Mutation$UpdateGalleryRating<TRes>
    implements CopyWith$Mutation$UpdateGalleryRating<TRes> {
  _CopyWithImpl$Mutation$UpdateGalleryRating(this._instance, this._then);

  final Mutation$UpdateGalleryRating _instance;

  final TRes Function(Mutation$UpdateGalleryRating) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? galleryUpdate = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Mutation$UpdateGalleryRating(
      galleryUpdate: galleryUpdate == _undefined
          ? _instance.galleryUpdate
          : (galleryUpdate as Mutation$UpdateGalleryRating$galleryUpdate?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  CopyWith$Mutation$UpdateGalleryRating$galleryUpdate<TRes> get galleryUpdate {
    final local$galleryUpdate = _instance.galleryUpdate;
    return local$galleryUpdate == null
        ? CopyWith$Mutation$UpdateGalleryRating$galleryUpdate.stub(
            _then(_instance),
          )
        : CopyWith$Mutation$UpdateGalleryRating$galleryUpdate(
            local$galleryUpdate,
            (e) => call(galleryUpdate: e),
          );
  }
}

class _CopyWithStubImpl$Mutation$UpdateGalleryRating<TRes>
    implements CopyWith$Mutation$UpdateGalleryRating<TRes> {
  _CopyWithStubImpl$Mutation$UpdateGalleryRating(this._res);

  TRes _res;

  call({
    Mutation$UpdateGalleryRating$galleryUpdate? galleryUpdate,
    String? $__typename,
  }) => _res;

  CopyWith$Mutation$UpdateGalleryRating$galleryUpdate<TRes> get galleryUpdate =>
      CopyWith$Mutation$UpdateGalleryRating$galleryUpdate.stub(_res);
}

const documentNodeMutationUpdateGalleryRating = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.mutation,
      name: NameNode(value: 'UpdateGalleryRating'),
      variableDefinitions: [
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'id')),
          type: NamedTypeNode(name: NameNode(value: 'ID'), isNonNull: true),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'rating')),
          type: NamedTypeNode(name: NameNode(value: 'Int'), isNonNull: true),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
      ],
      directives: [],
      selectionSet: SelectionSetNode(
        selections: [
          FieldNode(
            name: NameNode(value: 'galleryUpdate'),
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
                      name: NameNode(value: 'rating100'),
                      value: VariableNode(name: NameNode(value: 'rating')),
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
                  name: NameNode(value: 'rating100'),
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
Mutation$UpdateGalleryRating _parserFn$Mutation$UpdateGalleryRating(
  Map<String, dynamic> data,
) => Mutation$UpdateGalleryRating.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateGalleryRating =
    FutureOr<void> Function(
      Map<String, dynamic>?,
      Mutation$UpdateGalleryRating?,
    );

class Options$Mutation$UpdateGalleryRating
    extends graphql.MutationOptions<Mutation$UpdateGalleryRating> {
  Options$Mutation$UpdateGalleryRating({
    String? operationName,
    required Variables$Mutation$UpdateGalleryRating variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateGalleryRating? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateGalleryRating? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateGalleryRating>? update,
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
                     : _parserFn$Mutation$UpdateGalleryRating(data),
               ),
         update: update,
         onError: onError,
         document: documentNodeMutationUpdateGalleryRating,
         parserFn: _parserFn$Mutation$UpdateGalleryRating,
       );

  final OnMutationCompleted$Mutation$UpdateGalleryRating? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
    ...super.onCompleted == null
        ? super.properties
        : super.properties.where((property) => property != onCompleted),
    onCompletedWithParsed,
  ];
}

class WatchOptions$Mutation$UpdateGalleryRating
    extends graphql.WatchQueryOptions<Mutation$UpdateGalleryRating> {
  WatchOptions$Mutation$UpdateGalleryRating({
    String? operationName,
    required Variables$Mutation$UpdateGalleryRating variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateGalleryRating? typedOptimisticResult,
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
         document: documentNodeMutationUpdateGalleryRating,
         pollInterval: pollInterval,
         eagerlyFetchResults: eagerlyFetchResults,
         carryForwardDataOnException: carryForwardDataOnException,
         fetchResults: fetchResults,
         parserFn: _parserFn$Mutation$UpdateGalleryRating,
       );
}

extension ClientExtension$Mutation$UpdateGalleryRating
    on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateGalleryRating>>
  mutate$UpdateGalleryRating(
    Options$Mutation$UpdateGalleryRating options,
  ) async => await this.mutate(options);

  graphql.ObservableQuery<Mutation$UpdateGalleryRating>
  watchMutation$UpdateGalleryRating(
    WatchOptions$Mutation$UpdateGalleryRating options,
  ) => this.watchMutation(options);
}

class Mutation$UpdateGalleryRating$galleryUpdate {
  Mutation$UpdateGalleryRating$galleryUpdate({
    required this.id,
    this.rating100,
    this.$__typename = 'Gallery',
  });

  factory Mutation$UpdateGalleryRating$galleryUpdate.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$id = json['id'];
    final l$rating100 = json['rating100'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateGalleryRating$galleryUpdate(
      id: (l$id as String),
      rating100: (l$rating100 as int?),
      $__typename: (l$$__typename as String),
    );
  }

  final String id;

  final int? rating100;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$rating100 = rating100;
    _resultData['rating100'] = l$rating100;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$rating100 = rating100;
    final l$$__typename = $__typename;
    return Object.hashAll([l$id, l$rating100, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdateGalleryRating$galleryUpdate ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$rating100 = rating100;
    final lOther$rating100 = other.rating100;
    if (l$rating100 != lOther$rating100) {
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

extension UtilityExtension$Mutation$UpdateGalleryRating$galleryUpdate
    on Mutation$UpdateGalleryRating$galleryUpdate {
  CopyWith$Mutation$UpdateGalleryRating$galleryUpdate<
    Mutation$UpdateGalleryRating$galleryUpdate
  >
  get copyWith =>
      CopyWith$Mutation$UpdateGalleryRating$galleryUpdate(this, (i) => i);
}

abstract class CopyWith$Mutation$UpdateGalleryRating$galleryUpdate<TRes> {
  factory CopyWith$Mutation$UpdateGalleryRating$galleryUpdate(
    Mutation$UpdateGalleryRating$galleryUpdate instance,
    TRes Function(Mutation$UpdateGalleryRating$galleryUpdate) then,
  ) = _CopyWithImpl$Mutation$UpdateGalleryRating$galleryUpdate;

  factory CopyWith$Mutation$UpdateGalleryRating$galleryUpdate.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateGalleryRating$galleryUpdate;

  TRes call({String? id, int? rating100, String? $__typename});
}

class _CopyWithImpl$Mutation$UpdateGalleryRating$galleryUpdate<TRes>
    implements CopyWith$Mutation$UpdateGalleryRating$galleryUpdate<TRes> {
  _CopyWithImpl$Mutation$UpdateGalleryRating$galleryUpdate(
    this._instance,
    this._then,
  );

  final Mutation$UpdateGalleryRating$galleryUpdate _instance;

  final TRes Function(Mutation$UpdateGalleryRating$galleryUpdate) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? rating100 = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Mutation$UpdateGalleryRating$galleryUpdate(
      id: id == _undefined || id == null ? _instance.id : (id as String),
      rating100: rating100 == _undefined
          ? _instance.rating100
          : (rating100 as int?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Mutation$UpdateGalleryRating$galleryUpdate<TRes>
    implements CopyWith$Mutation$UpdateGalleryRating$galleryUpdate<TRes> {
  _CopyWithStubImpl$Mutation$UpdateGalleryRating$galleryUpdate(this._res);

  TRes _res;

  call({String? id, int? rating100, String? $__typename}) => _res;
}
