import '../../../../core/data/graphql/schema.graphql.dart';
import 'dart:async';
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;

class Fragment$ImageData {
  Fragment$ImageData({
    required this.id,
    this.title,
    this.rating100,
    this.date,
    required this.urls,
    required this.visual_files,
    required this.paths,
    this.$__typename = 'Image',
  });

  factory Fragment$ImageData.fromJson(Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$title = json['title'];
    final l$rating100 = json['rating100'];
    final l$date = json['date'];
    final l$urls = json['urls'];
    final l$visual_files = json['visual_files'];
    final l$paths = json['paths'];
    final l$$__typename = json['__typename'];
    return Fragment$ImageData(
      id: (l$id as String),
      title: (l$title as String?),
      rating100: (l$rating100 as int?),
      date: (l$date as String?),
      urls: (l$urls as List<dynamic>).map((e) => (e as String)).toList(),
      visual_files: (l$visual_files as List<dynamic>)
          .map(
            (e) => Fragment$ImageData$visual_files.fromJson(
              (e as Map<String, dynamic>),
            ),
          )
          .toList(),
      paths: Fragment$ImageData$paths.fromJson(
        (l$paths as Map<String, dynamic>),
      ),
      $__typename: (l$$__typename as String),
    );
  }

  final String id;

  final String? title;

  final int? rating100;

  final String? date;

  final List<String> urls;

  final List<Fragment$ImageData$visual_files> visual_files;

  final Fragment$ImageData$paths paths;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$title = title;
    _resultData['title'] = l$title;
    final l$rating100 = rating100;
    _resultData['rating100'] = l$rating100;
    final l$date = date;
    _resultData['date'] = l$date;
    final l$urls = urls;
    _resultData['urls'] = l$urls.map((e) => e).toList();
    final l$visual_files = visual_files;
    _resultData['visual_files'] = l$visual_files
        .map((e) => e.toJson())
        .toList();
    final l$paths = paths;
    _resultData['paths'] = l$paths.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$title = title;
    final l$rating100 = rating100;
    final l$date = date;
    final l$urls = urls;
    final l$visual_files = visual_files;
    final l$paths = paths;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$title,
      l$rating100,
      l$date,
      Object.hashAll(l$urls.map((v) => v)),
      Object.hashAll(l$visual_files.map((v) => v)),
      l$paths,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$ImageData || runtimeType != other.runtimeType) {
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
    final l$rating100 = rating100;
    final lOther$rating100 = other.rating100;
    if (l$rating100 != lOther$rating100) {
      return false;
    }
    final l$date = date;
    final lOther$date = other.date;
    if (l$date != lOther$date) {
      return false;
    }
    final l$urls = urls;
    final lOther$urls = other.urls;
    if (l$urls.length != lOther$urls.length) {
      return false;
    }
    for (int i = 0; i < l$urls.length; i++) {
      final l$urls$entry = l$urls[i];
      final lOther$urls$entry = lOther$urls[i];
      if (l$urls$entry != lOther$urls$entry) {
        return false;
      }
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
    final l$paths = paths;
    final lOther$paths = other.paths;
    if (l$paths != lOther$paths) {
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

extension UtilityExtension$Fragment$ImageData on Fragment$ImageData {
  CopyWith$Fragment$ImageData<Fragment$ImageData> get copyWith =>
      CopyWith$Fragment$ImageData(this, (i) => i);
}

abstract class CopyWith$Fragment$ImageData<TRes> {
  factory CopyWith$Fragment$ImageData(
    Fragment$ImageData instance,
    TRes Function(Fragment$ImageData) then,
  ) = _CopyWithImpl$Fragment$ImageData;

  factory CopyWith$Fragment$ImageData.stub(TRes res) =
      _CopyWithStubImpl$Fragment$ImageData;

  TRes call({
    String? id,
    String? title,
    int? rating100,
    String? date,
    List<String>? urls,
    List<Fragment$ImageData$visual_files>? visual_files,
    Fragment$ImageData$paths? paths,
    String? $__typename,
  });
  TRes visual_files(
    Iterable<Fragment$ImageData$visual_files> Function(
      Iterable<
        CopyWith$Fragment$ImageData$visual_files<
          Fragment$ImageData$visual_files
        >
      >,
    )
    _fn,
  );
  CopyWith$Fragment$ImageData$paths<TRes> get paths;
}

class _CopyWithImpl$Fragment$ImageData<TRes>
    implements CopyWith$Fragment$ImageData<TRes> {
  _CopyWithImpl$Fragment$ImageData(this._instance, this._then);

  final Fragment$ImageData _instance;

  final TRes Function(Fragment$ImageData) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? title = _undefined,
    Object? rating100 = _undefined,
    Object? date = _undefined,
    Object? urls = _undefined,
    Object? visual_files = _undefined,
    Object? paths = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Fragment$ImageData(
      id: id == _undefined || id == null ? _instance.id : (id as String),
      title: title == _undefined ? _instance.title : (title as String?),
      rating100: rating100 == _undefined
          ? _instance.rating100
          : (rating100 as int?),
      date: date == _undefined ? _instance.date : (date as String?),
      urls: urls == _undefined || urls == null
          ? _instance.urls
          : (urls as List<String>),
      visual_files: visual_files == _undefined || visual_files == null
          ? _instance.visual_files
          : (visual_files as List<Fragment$ImageData$visual_files>),
      paths: paths == _undefined || paths == null
          ? _instance.paths
          : (paths as Fragment$ImageData$paths),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  TRes visual_files(
    Iterable<Fragment$ImageData$visual_files> Function(
      Iterable<
        CopyWith$Fragment$ImageData$visual_files<
          Fragment$ImageData$visual_files
        >
      >,
    )
    _fn,
  ) => call(
    visual_files: _fn(
      _instance.visual_files.map(
        (e) => CopyWith$Fragment$ImageData$visual_files(e, (i) => i),
      ),
    ).toList(),
  );

  CopyWith$Fragment$ImageData$paths<TRes> get paths {
    final local$paths = _instance.paths;
    return CopyWith$Fragment$ImageData$paths(
      local$paths,
      (e) => call(paths: e),
    );
  }
}

class _CopyWithStubImpl$Fragment$ImageData<TRes>
    implements CopyWith$Fragment$ImageData<TRes> {
  _CopyWithStubImpl$Fragment$ImageData(this._res);

  TRes _res;

  call({
    String? id,
    String? title,
    int? rating100,
    String? date,
    List<String>? urls,
    List<Fragment$ImageData$visual_files>? visual_files,
    Fragment$ImageData$paths? paths,
    String? $__typename,
  }) => _res;

  visual_files(_fn) => _res;

  CopyWith$Fragment$ImageData$paths<TRes> get paths =>
      CopyWith$Fragment$ImageData$paths.stub(_res);
}

const fragmentDefinitionImageData = FragmentDefinitionNode(
  name: NameNode(value: 'ImageData'),
  typeCondition: TypeConditionNode(
    on: NamedTypeNode(name: NameNode(value: 'Image'), isNonNull: false),
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
        name: NameNode(value: 'rating100'),
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
        name: NameNode(value: 'urls'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
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
              name: NameNode(value: 'thumbnail'),
              alias: null,
              arguments: [],
              directives: [],
              selectionSet: null,
            ),
            FieldNode(
              name: NameNode(value: 'preview'),
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
const documentNodeFragmentImageData = DocumentNode(
  definitions: [fragmentDefinitionImageData],
);

extension ClientExtension$Fragment$ImageData on graphql.GraphQLClient {
  void writeFragment$ImageData({
    required Fragment$ImageData data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) => this.writeFragment(
    graphql.FragmentRequest(
      idFields: idFields,
      fragment: const graphql.Fragment(
        fragmentName: 'ImageData',
        document: documentNodeFragmentImageData,
      ),
    ),
    data: data.toJson(),
    broadcast: broadcast,
  );

  Fragment$ImageData? readFragment$ImageData({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'ImageData',
          document: documentNodeFragmentImageData,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$ImageData.fromJson(result);
  }
}

class Fragment$ImageData$visual_files {
  Fragment$ImageData$visual_files({required this.$__typename});

  factory Fragment$ImageData$visual_files.fromJson(Map<String, dynamic> json) {
    switch (json["__typename"] as String) {
      case "ImageFile":
        return Fragment$ImageData$visual_files$$ImageFile.fromJson(json);

      case "VideoFile":
        return Fragment$ImageData$visual_files$$VideoFile.fromJson(json);

      default:
        final l$$__typename = json['__typename'];
        return Fragment$ImageData$visual_files(
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
    if (other is! Fragment$ImageData$visual_files ||
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

extension UtilityExtension$Fragment$ImageData$visual_files
    on Fragment$ImageData$visual_files {
  CopyWith$Fragment$ImageData$visual_files<Fragment$ImageData$visual_files>
  get copyWith => CopyWith$Fragment$ImageData$visual_files(this, (i) => i);

  _T when<_T>({
    required _T Function(Fragment$ImageData$visual_files$$ImageFile) imageFile,
    required _T Function(Fragment$ImageData$visual_files$$VideoFile) videoFile,
    required _T Function() orElse,
  }) {
    switch ($__typename) {
      case "ImageFile":
        return imageFile(this as Fragment$ImageData$visual_files$$ImageFile);

      case "VideoFile":
        return videoFile(this as Fragment$ImageData$visual_files$$VideoFile);

      default:
        return orElse();
    }
  }

  _T maybeWhen<_T>({
    _T Function(Fragment$ImageData$visual_files$$ImageFile)? imageFile,
    _T Function(Fragment$ImageData$visual_files$$VideoFile)? videoFile,
    required _T Function() orElse,
  }) {
    switch ($__typename) {
      case "ImageFile":
        if (imageFile != null) {
          return imageFile(this as Fragment$ImageData$visual_files$$ImageFile);
        } else {
          return orElse();
        }

      case "VideoFile":
        if (videoFile != null) {
          return videoFile(this as Fragment$ImageData$visual_files$$VideoFile);
        } else {
          return orElse();
        }

      default:
        return orElse();
    }
  }
}

abstract class CopyWith$Fragment$ImageData$visual_files<TRes> {
  factory CopyWith$Fragment$ImageData$visual_files(
    Fragment$ImageData$visual_files instance,
    TRes Function(Fragment$ImageData$visual_files) then,
  ) = _CopyWithImpl$Fragment$ImageData$visual_files;

  factory CopyWith$Fragment$ImageData$visual_files.stub(TRes res) =
      _CopyWithStubImpl$Fragment$ImageData$visual_files;

  TRes call({String? $__typename});
}

class _CopyWithImpl$Fragment$ImageData$visual_files<TRes>
    implements CopyWith$Fragment$ImageData$visual_files<TRes> {
  _CopyWithImpl$Fragment$ImageData$visual_files(this._instance, this._then);

  final Fragment$ImageData$visual_files _instance;

  final TRes Function(Fragment$ImageData$visual_files) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? $__typename = _undefined}) => _then(
    Fragment$ImageData$visual_files(
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Fragment$ImageData$visual_files<TRes>
    implements CopyWith$Fragment$ImageData$visual_files<TRes> {
  _CopyWithStubImpl$Fragment$ImageData$visual_files(this._res);

  TRes _res;

  call({String? $__typename}) => _res;
}

class Fragment$ImageData$visual_files$$ImageFile
    implements Fragment$ImageData$visual_files {
  Fragment$ImageData$visual_files$$ImageFile({
    required this.width,
    required this.height,
    required this.path,
    this.$__typename = 'ImageFile',
  });

  factory Fragment$ImageData$visual_files$$ImageFile.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$width = json['width'];
    final l$height = json['height'];
    final l$path = json['path'];
    final l$$__typename = json['__typename'];
    return Fragment$ImageData$visual_files$$ImageFile(
      width: (l$width as int),
      height: (l$height as int),
      path: (l$path as String),
      $__typename: (l$$__typename as String),
    );
  }

  final int width;

  final int height;

  final String path;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$width = width;
    _resultData['width'] = l$width;
    final l$height = height;
    _resultData['height'] = l$height;
    final l$path = path;
    _resultData['path'] = l$path;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$width = width;
    final l$height = height;
    final l$path = path;
    final l$$__typename = $__typename;
    return Object.hashAll([l$width, l$height, l$path, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$ImageData$visual_files$$ImageFile ||
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

extension UtilityExtension$Fragment$ImageData$visual_files$$ImageFile
    on Fragment$ImageData$visual_files$$ImageFile {
  CopyWith$Fragment$ImageData$visual_files$$ImageFile<
    Fragment$ImageData$visual_files$$ImageFile
  >
  get copyWith =>
      CopyWith$Fragment$ImageData$visual_files$$ImageFile(this, (i) => i);
}

abstract class CopyWith$Fragment$ImageData$visual_files$$ImageFile<TRes> {
  factory CopyWith$Fragment$ImageData$visual_files$$ImageFile(
    Fragment$ImageData$visual_files$$ImageFile instance,
    TRes Function(Fragment$ImageData$visual_files$$ImageFile) then,
  ) = _CopyWithImpl$Fragment$ImageData$visual_files$$ImageFile;

  factory CopyWith$Fragment$ImageData$visual_files$$ImageFile.stub(TRes res) =
      _CopyWithStubImpl$Fragment$ImageData$visual_files$$ImageFile;

  TRes call({int? width, int? height, String? path, String? $__typename});
}

class _CopyWithImpl$Fragment$ImageData$visual_files$$ImageFile<TRes>
    implements CopyWith$Fragment$ImageData$visual_files$$ImageFile<TRes> {
  _CopyWithImpl$Fragment$ImageData$visual_files$$ImageFile(
    this._instance,
    this._then,
  );

  final Fragment$ImageData$visual_files$$ImageFile _instance;

  final TRes Function(Fragment$ImageData$visual_files$$ImageFile) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? width = _undefined,
    Object? height = _undefined,
    Object? path = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Fragment$ImageData$visual_files$$ImageFile(
      width: width == _undefined || width == null
          ? _instance.width
          : (width as int),
      height: height == _undefined || height == null
          ? _instance.height
          : (height as int),
      path: path == _undefined || path == null
          ? _instance.path
          : (path as String),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Fragment$ImageData$visual_files$$ImageFile<TRes>
    implements CopyWith$Fragment$ImageData$visual_files$$ImageFile<TRes> {
  _CopyWithStubImpl$Fragment$ImageData$visual_files$$ImageFile(this._res);

  TRes _res;

  call({int? width, int? height, String? path, String? $__typename}) => _res;
}

class Fragment$ImageData$visual_files$$VideoFile
    implements Fragment$ImageData$visual_files {
  Fragment$ImageData$visual_files$$VideoFile({
    required this.width,
    required this.height,
    required this.path,
    this.$__typename = 'VideoFile',
  });

  factory Fragment$ImageData$visual_files$$VideoFile.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$width = json['width'];
    final l$height = json['height'];
    final l$path = json['path'];
    final l$$__typename = json['__typename'];
    return Fragment$ImageData$visual_files$$VideoFile(
      width: (l$width as int),
      height: (l$height as int),
      path: (l$path as String),
      $__typename: (l$$__typename as String),
    );
  }

  final int width;

  final int height;

  final String path;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$width = width;
    _resultData['width'] = l$width;
    final l$height = height;
    _resultData['height'] = l$height;
    final l$path = path;
    _resultData['path'] = l$path;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$width = width;
    final l$height = height;
    final l$path = path;
    final l$$__typename = $__typename;
    return Object.hashAll([l$width, l$height, l$path, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$ImageData$visual_files$$VideoFile ||
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

extension UtilityExtension$Fragment$ImageData$visual_files$$VideoFile
    on Fragment$ImageData$visual_files$$VideoFile {
  CopyWith$Fragment$ImageData$visual_files$$VideoFile<
    Fragment$ImageData$visual_files$$VideoFile
  >
  get copyWith =>
      CopyWith$Fragment$ImageData$visual_files$$VideoFile(this, (i) => i);
}

abstract class CopyWith$Fragment$ImageData$visual_files$$VideoFile<TRes> {
  factory CopyWith$Fragment$ImageData$visual_files$$VideoFile(
    Fragment$ImageData$visual_files$$VideoFile instance,
    TRes Function(Fragment$ImageData$visual_files$$VideoFile) then,
  ) = _CopyWithImpl$Fragment$ImageData$visual_files$$VideoFile;

  factory CopyWith$Fragment$ImageData$visual_files$$VideoFile.stub(TRes res) =
      _CopyWithStubImpl$Fragment$ImageData$visual_files$$VideoFile;

  TRes call({int? width, int? height, String? path, String? $__typename});
}

class _CopyWithImpl$Fragment$ImageData$visual_files$$VideoFile<TRes>
    implements CopyWith$Fragment$ImageData$visual_files$$VideoFile<TRes> {
  _CopyWithImpl$Fragment$ImageData$visual_files$$VideoFile(
    this._instance,
    this._then,
  );

  final Fragment$ImageData$visual_files$$VideoFile _instance;

  final TRes Function(Fragment$ImageData$visual_files$$VideoFile) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? width = _undefined,
    Object? height = _undefined,
    Object? path = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Fragment$ImageData$visual_files$$VideoFile(
      width: width == _undefined || width == null
          ? _instance.width
          : (width as int),
      height: height == _undefined || height == null
          ? _instance.height
          : (height as int),
      path: path == _undefined || path == null
          ? _instance.path
          : (path as String),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Fragment$ImageData$visual_files$$VideoFile<TRes>
    implements CopyWith$Fragment$ImageData$visual_files$$VideoFile<TRes> {
  _CopyWithStubImpl$Fragment$ImageData$visual_files$$VideoFile(this._res);

  TRes _res;

  call({int? width, int? height, String? path, String? $__typename}) => _res;
}

class Fragment$ImageData$paths {
  Fragment$ImageData$paths({
    this.thumbnail,
    this.preview,
    this.image,
    this.$__typename = 'ImagePathsType',
  });

  factory Fragment$ImageData$paths.fromJson(Map<String, dynamic> json) {
    final l$thumbnail = json['thumbnail'];
    final l$preview = json['preview'];
    final l$image = json['image'];
    final l$$__typename = json['__typename'];
    return Fragment$ImageData$paths(
      thumbnail: (l$thumbnail as String?),
      preview: (l$preview as String?),
      image: (l$image as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String? thumbnail;

  final String? preview;

  final String? image;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$thumbnail = thumbnail;
    _resultData['thumbnail'] = l$thumbnail;
    final l$preview = preview;
    _resultData['preview'] = l$preview;
    final l$image = image;
    _resultData['image'] = l$image;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$thumbnail = thumbnail;
    final l$preview = preview;
    final l$image = image;
    final l$$__typename = $__typename;
    return Object.hashAll([l$thumbnail, l$preview, l$image, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$ImageData$paths ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$thumbnail = thumbnail;
    final lOther$thumbnail = other.thumbnail;
    if (l$thumbnail != lOther$thumbnail) {
      return false;
    }
    final l$preview = preview;
    final lOther$preview = other.preview;
    if (l$preview != lOther$preview) {
      return false;
    }
    final l$image = image;
    final lOther$image = other.image;
    if (l$image != lOther$image) {
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

extension UtilityExtension$Fragment$ImageData$paths
    on Fragment$ImageData$paths {
  CopyWith$Fragment$ImageData$paths<Fragment$ImageData$paths> get copyWith =>
      CopyWith$Fragment$ImageData$paths(this, (i) => i);
}

abstract class CopyWith$Fragment$ImageData$paths<TRes> {
  factory CopyWith$Fragment$ImageData$paths(
    Fragment$ImageData$paths instance,
    TRes Function(Fragment$ImageData$paths) then,
  ) = _CopyWithImpl$Fragment$ImageData$paths;

  factory CopyWith$Fragment$ImageData$paths.stub(TRes res) =
      _CopyWithStubImpl$Fragment$ImageData$paths;

  TRes call({
    String? thumbnail,
    String? preview,
    String? image,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$ImageData$paths<TRes>
    implements CopyWith$Fragment$ImageData$paths<TRes> {
  _CopyWithImpl$Fragment$ImageData$paths(this._instance, this._then);

  final Fragment$ImageData$paths _instance;

  final TRes Function(Fragment$ImageData$paths) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? thumbnail = _undefined,
    Object? preview = _undefined,
    Object? image = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Fragment$ImageData$paths(
      thumbnail: thumbnail == _undefined
          ? _instance.thumbnail
          : (thumbnail as String?),
      preview: preview == _undefined ? _instance.preview : (preview as String?),
      image: image == _undefined ? _instance.image : (image as String?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Fragment$ImageData$paths<TRes>
    implements CopyWith$Fragment$ImageData$paths<TRes> {
  _CopyWithStubImpl$Fragment$ImageData$paths(this._res);

  TRes _res;

  call({
    String? thumbnail,
    String? preview,
    String? image,
    String? $__typename,
  }) => _res;
}

class Variables$Query$FindImages {
  factory Variables$Query$FindImages({
    Input$FindFilterType? filter,
    Input$ImageFilterType? image_filter,
  }) => Variables$Query$FindImages._({
    if (filter != null) r'filter': filter,
    if (image_filter != null) r'image_filter': image_filter,
  });

  Variables$Query$FindImages._(this._$data);

  factory Variables$Query$FindImages.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('filter')) {
      final l$filter = data['filter'];
      result$data['filter'] = l$filter == null
          ? null
          : Input$FindFilterType.fromJson((l$filter as Map<String, dynamic>));
    }
    if (data.containsKey('image_filter')) {
      final l$image_filter = data['image_filter'];
      result$data['image_filter'] = l$image_filter == null
          ? null
          : Input$ImageFilterType.fromJson(
              (l$image_filter as Map<String, dynamic>),
            );
    }
    return Variables$Query$FindImages._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$FindFilterType? get filter =>
      (_$data['filter'] as Input$FindFilterType?);

  Input$ImageFilterType? get image_filter =>
      (_$data['image_filter'] as Input$ImageFilterType?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('filter')) {
      final l$filter = filter;
      result$data['filter'] = l$filter?.toJson();
    }
    if (_$data.containsKey('image_filter')) {
      final l$image_filter = image_filter;
      result$data['image_filter'] = l$image_filter?.toJson();
    }
    return result$data;
  }

  CopyWith$Variables$Query$FindImages<Variables$Query$FindImages>
  get copyWith => CopyWith$Variables$Query$FindImages(this, (i) => i);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$FindImages ||
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
    final l$image_filter = image_filter;
    final lOther$image_filter = other.image_filter;
    if (_$data.containsKey('image_filter') !=
        other._$data.containsKey('image_filter')) {
      return false;
    }
    if (l$image_filter != lOther$image_filter) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$filter = filter;
    final l$image_filter = image_filter;
    return Object.hashAll([
      _$data.containsKey('filter') ? l$filter : const {},
      _$data.containsKey('image_filter') ? l$image_filter : const {},
    ]);
  }
}

abstract class CopyWith$Variables$Query$FindImages<TRes> {
  factory CopyWith$Variables$Query$FindImages(
    Variables$Query$FindImages instance,
    TRes Function(Variables$Query$FindImages) then,
  ) = _CopyWithImpl$Variables$Query$FindImages;

  factory CopyWith$Variables$Query$FindImages.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$FindImages;

  TRes call({
    Input$FindFilterType? filter,
    Input$ImageFilterType? image_filter,
  });
}

class _CopyWithImpl$Variables$Query$FindImages<TRes>
    implements CopyWith$Variables$Query$FindImages<TRes> {
  _CopyWithImpl$Variables$Query$FindImages(this._instance, this._then);

  final Variables$Query$FindImages _instance;

  final TRes Function(Variables$Query$FindImages) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? filter = _undefined, Object? image_filter = _undefined}) =>
      _then(
        Variables$Query$FindImages._({
          ..._instance._$data,
          if (filter != _undefined) 'filter': (filter as Input$FindFilterType?),
          if (image_filter != _undefined)
            'image_filter': (image_filter as Input$ImageFilterType?),
        }),
      );
}

class _CopyWithStubImpl$Variables$Query$FindImages<TRes>
    implements CopyWith$Variables$Query$FindImages<TRes> {
  _CopyWithStubImpl$Variables$Query$FindImages(this._res);

  TRes _res;

  call({Input$FindFilterType? filter, Input$ImageFilterType? image_filter}) =>
      _res;
}

class Query$FindImages {
  Query$FindImages({required this.findImages, this.$__typename = 'Query'});

  factory Query$FindImages.fromJson(Map<String, dynamic> json) {
    final l$findImages = json['findImages'];
    final l$$__typename = json['__typename'];
    return Query$FindImages(
      findImages: Query$FindImages$findImages.fromJson(
        (l$findImages as Map<String, dynamic>),
      ),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$FindImages$findImages findImages;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$findImages = findImages;
    _resultData['findImages'] = l$findImages.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$findImages = findImages;
    final l$$__typename = $__typename;
    return Object.hashAll([l$findImages, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$FindImages || runtimeType != other.runtimeType) {
      return false;
    }
    final l$findImages = findImages;
    final lOther$findImages = other.findImages;
    if (l$findImages != lOther$findImages) {
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

extension UtilityExtension$Query$FindImages on Query$FindImages {
  CopyWith$Query$FindImages<Query$FindImages> get copyWith =>
      CopyWith$Query$FindImages(this, (i) => i);
}

abstract class CopyWith$Query$FindImages<TRes> {
  factory CopyWith$Query$FindImages(
    Query$FindImages instance,
    TRes Function(Query$FindImages) then,
  ) = _CopyWithImpl$Query$FindImages;

  factory CopyWith$Query$FindImages.stub(TRes res) =
      _CopyWithStubImpl$Query$FindImages;

  TRes call({Query$FindImages$findImages? findImages, String? $__typename});
  CopyWith$Query$FindImages$findImages<TRes> get findImages;
}

class _CopyWithImpl$Query$FindImages<TRes>
    implements CopyWith$Query$FindImages<TRes> {
  _CopyWithImpl$Query$FindImages(this._instance, this._then);

  final Query$FindImages _instance;

  final TRes Function(Query$FindImages) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? findImages = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$FindImages(
      findImages: findImages == _undefined || findImages == null
          ? _instance.findImages
          : (findImages as Query$FindImages$findImages),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  CopyWith$Query$FindImages$findImages<TRes> get findImages {
    final local$findImages = _instance.findImages;
    return CopyWith$Query$FindImages$findImages(
      local$findImages,
      (e) => call(findImages: e),
    );
  }
}

class _CopyWithStubImpl$Query$FindImages<TRes>
    implements CopyWith$Query$FindImages<TRes> {
  _CopyWithStubImpl$Query$FindImages(this._res);

  TRes _res;

  call({Query$FindImages$findImages? findImages, String? $__typename}) => _res;

  CopyWith$Query$FindImages$findImages<TRes> get findImages =>
      CopyWith$Query$FindImages$findImages.stub(_res);
}

const documentNodeQueryFindImages = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.query,
      name: NameNode(value: 'FindImages'),
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
          variable: VariableNode(name: NameNode(value: 'image_filter')),
          type: NamedTypeNode(
            name: NameNode(value: 'ImageFilterType'),
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
            name: NameNode(value: 'findImages'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'filter'),
                value: VariableNode(name: NameNode(value: 'filter')),
              ),
              ArgumentNode(
                name: NameNode(value: 'image_filter'),
                value: VariableNode(name: NameNode(value: 'image_filter')),
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
                  name: NameNode(value: 'images'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: SelectionSetNode(
                    selections: [
                      FragmentSpreadNode(
                        name: NameNode(value: 'ImageData'),
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
    fragmentDefinitionImageData,
  ],
);
Query$FindImages _parserFn$Query$FindImages(Map<String, dynamic> data) =>
    Query$FindImages.fromJson(data);
typedef OnQueryComplete$Query$FindImages =
    FutureOr<void> Function(Map<String, dynamic>?, Query$FindImages?);

class Options$Query$FindImages extends graphql.QueryOptions<Query$FindImages> {
  Options$Query$FindImages({
    String? operationName,
    Variables$Query$FindImages? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$FindImages? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$FindImages? onComplete,
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
                 data == null ? null : _parserFn$Query$FindImages(data),
               ),
         onError: onError,
         document: documentNodeQueryFindImages,
         parserFn: _parserFn$Query$FindImages,
       );

  final OnQueryComplete$Query$FindImages? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
    ...super.onComplete == null
        ? super.properties
        : super.properties.where((property) => property != onComplete),
    onCompleteWithParsed,
  ];
}

class WatchOptions$Query$FindImages
    extends graphql.WatchQueryOptions<Query$FindImages> {
  WatchOptions$Query$FindImages({
    String? operationName,
    Variables$Query$FindImages? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$FindImages? typedOptimisticResult,
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
         document: documentNodeQueryFindImages,
         pollInterval: pollInterval,
         eagerlyFetchResults: eagerlyFetchResults,
         carryForwardDataOnException: carryForwardDataOnException,
         fetchResults: fetchResults,
         parserFn: _parserFn$Query$FindImages,
       );
}

class FetchMoreOptions$Query$FindImages extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$FindImages({
    required graphql.UpdateQuery updateQuery,
    Variables$Query$FindImages? variables,
  }) : super(
         updateQuery: updateQuery,
         variables: variables?.toJson() ?? {},
         document: documentNodeQueryFindImages,
       );
}

extension ClientExtension$Query$FindImages on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$FindImages>> query$FindImages([
    Options$Query$FindImages? options,
  ]) async => await this.query(options ?? Options$Query$FindImages());

  graphql.ObservableQuery<Query$FindImages> watchQuery$FindImages([
    WatchOptions$Query$FindImages? options,
  ]) => this.watchQuery(options ?? WatchOptions$Query$FindImages());

  void writeQuery$FindImages({
    required Query$FindImages data,
    Variables$Query$FindImages? variables,
    bool broadcast = true,
  }) => this.writeQuery(
    graphql.Request(
      operation: graphql.Operation(document: documentNodeQueryFindImages),
      variables: variables?.toJson() ?? const {},
    ),
    data: data.toJson(),
    broadcast: broadcast,
  );

  Query$FindImages? readQuery$FindImages({
    Variables$Query$FindImages? variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(document: documentNodeQueryFindImages),
        variables: variables?.toJson() ?? const {},
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$FindImages.fromJson(result);
  }
}

class Query$FindImages$findImages {
  Query$FindImages$findImages({
    required this.count,
    required this.images,
    this.$__typename = 'FindImagesResultType',
  });

  factory Query$FindImages$findImages.fromJson(Map<String, dynamic> json) {
    final l$count = json['count'];
    final l$images = json['images'];
    final l$$__typename = json['__typename'];
    return Query$FindImages$findImages(
      count: (l$count as int),
      images: (l$images as List<dynamic>)
          .map((e) => Fragment$ImageData.fromJson((e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final int count;

  final List<Fragment$ImageData> images;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$count = count;
    _resultData['count'] = l$count;
    final l$images = images;
    _resultData['images'] = l$images.map((e) => e.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$count = count;
    final l$images = images;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$count,
      Object.hashAll(l$images.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$FindImages$findImages ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$count = count;
    final lOther$count = other.count;
    if (l$count != lOther$count) {
      return false;
    }
    final l$images = images;
    final lOther$images = other.images;
    if (l$images.length != lOther$images.length) {
      return false;
    }
    for (int i = 0; i < l$images.length; i++) {
      final l$images$entry = l$images[i];
      final lOther$images$entry = lOther$images[i];
      if (l$images$entry != lOther$images$entry) {
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

extension UtilityExtension$Query$FindImages$findImages
    on Query$FindImages$findImages {
  CopyWith$Query$FindImages$findImages<Query$FindImages$findImages>
  get copyWith => CopyWith$Query$FindImages$findImages(this, (i) => i);
}

abstract class CopyWith$Query$FindImages$findImages<TRes> {
  factory CopyWith$Query$FindImages$findImages(
    Query$FindImages$findImages instance,
    TRes Function(Query$FindImages$findImages) then,
  ) = _CopyWithImpl$Query$FindImages$findImages;

  factory CopyWith$Query$FindImages$findImages.stub(TRes res) =
      _CopyWithStubImpl$Query$FindImages$findImages;

  TRes call({
    int? count,
    List<Fragment$ImageData>? images,
    String? $__typename,
  });
  TRes images(
    Iterable<Fragment$ImageData> Function(
      Iterable<CopyWith$Fragment$ImageData<Fragment$ImageData>>,
    )
    _fn,
  );
}

class _CopyWithImpl$Query$FindImages$findImages<TRes>
    implements CopyWith$Query$FindImages$findImages<TRes> {
  _CopyWithImpl$Query$FindImages$findImages(this._instance, this._then);

  final Query$FindImages$findImages _instance;

  final TRes Function(Query$FindImages$findImages) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? count = _undefined,
    Object? images = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$FindImages$findImages(
      count: count == _undefined || count == null
          ? _instance.count
          : (count as int),
      images: images == _undefined || images == null
          ? _instance.images
          : (images as List<Fragment$ImageData>),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  TRes images(
    Iterable<Fragment$ImageData> Function(
      Iterable<CopyWith$Fragment$ImageData<Fragment$ImageData>>,
    )
    _fn,
  ) => call(
    images: _fn(
      _instance.images.map((e) => CopyWith$Fragment$ImageData(e, (i) => i)),
    ).toList(),
  );
}

class _CopyWithStubImpl$Query$FindImages$findImages<TRes>
    implements CopyWith$Query$FindImages$findImages<TRes> {
  _CopyWithStubImpl$Query$FindImages$findImages(this._res);

  TRes _res;

  call({int? count, List<Fragment$ImageData>? images, String? $__typename}) =>
      _res;

  images(_fn) => _res;
}

class Variables$Query$FindImage {
  factory Variables$Query$FindImage({required String id}) =>
      Variables$Query$FindImage._({r'id': id});

  Variables$Query$FindImage._(this._$data);

  factory Variables$Query$FindImage.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$id = data['id'];
    result$data['id'] = (l$id as String);
    return Variables$Query$FindImage._(result$data);
  }

  Map<String, dynamic> _$data;

  String get id => (_$data['id'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$id = id;
    result$data['id'] = l$id;
    return result$data;
  }

  CopyWith$Variables$Query$FindImage<Variables$Query$FindImage> get copyWith =>
      CopyWith$Variables$Query$FindImage(this, (i) => i);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$FindImage ||
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

abstract class CopyWith$Variables$Query$FindImage<TRes> {
  factory CopyWith$Variables$Query$FindImage(
    Variables$Query$FindImage instance,
    TRes Function(Variables$Query$FindImage) then,
  ) = _CopyWithImpl$Variables$Query$FindImage;

  factory CopyWith$Variables$Query$FindImage.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$FindImage;

  TRes call({String? id});
}

class _CopyWithImpl$Variables$Query$FindImage<TRes>
    implements CopyWith$Variables$Query$FindImage<TRes> {
  _CopyWithImpl$Variables$Query$FindImage(this._instance, this._then);

  final Variables$Query$FindImage _instance;

  final TRes Function(Variables$Query$FindImage) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? id = _undefined}) => _then(
    Variables$Query$FindImage._({
      ..._instance._$data,
      if (id != _undefined && id != null) 'id': (id as String),
    }),
  );
}

class _CopyWithStubImpl$Variables$Query$FindImage<TRes>
    implements CopyWith$Variables$Query$FindImage<TRes> {
  _CopyWithStubImpl$Variables$Query$FindImage(this._res);

  TRes _res;

  call({String? id}) => _res;
}

class Query$FindImage {
  Query$FindImage({this.findImage, this.$__typename = 'Query'});

  factory Query$FindImage.fromJson(Map<String, dynamic> json) {
    final l$findImage = json['findImage'];
    final l$$__typename = json['__typename'];
    return Query$FindImage(
      findImage: l$findImage == null
          ? null
          : Fragment$ImageData.fromJson((l$findImage as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Fragment$ImageData? findImage;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$findImage = findImage;
    _resultData['findImage'] = l$findImage?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$findImage = findImage;
    final l$$__typename = $__typename;
    return Object.hashAll([l$findImage, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$FindImage || runtimeType != other.runtimeType) {
      return false;
    }
    final l$findImage = findImage;
    final lOther$findImage = other.findImage;
    if (l$findImage != lOther$findImage) {
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

extension UtilityExtension$Query$FindImage on Query$FindImage {
  CopyWith$Query$FindImage<Query$FindImage> get copyWith =>
      CopyWith$Query$FindImage(this, (i) => i);
}

abstract class CopyWith$Query$FindImage<TRes> {
  factory CopyWith$Query$FindImage(
    Query$FindImage instance,
    TRes Function(Query$FindImage) then,
  ) = _CopyWithImpl$Query$FindImage;

  factory CopyWith$Query$FindImage.stub(TRes res) =
      _CopyWithStubImpl$Query$FindImage;

  TRes call({Fragment$ImageData? findImage, String? $__typename});
  CopyWith$Fragment$ImageData<TRes> get findImage;
}

class _CopyWithImpl$Query$FindImage<TRes>
    implements CopyWith$Query$FindImage<TRes> {
  _CopyWithImpl$Query$FindImage(this._instance, this._then);

  final Query$FindImage _instance;

  final TRes Function(Query$FindImage) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? findImage = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$FindImage(
      findImage: findImage == _undefined
          ? _instance.findImage
          : (findImage as Fragment$ImageData?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  CopyWith$Fragment$ImageData<TRes> get findImage {
    final local$findImage = _instance.findImage;
    return local$findImage == null
        ? CopyWith$Fragment$ImageData.stub(_then(_instance))
        : CopyWith$Fragment$ImageData(
            local$findImage,
            (e) => call(findImage: e),
          );
  }
}

class _CopyWithStubImpl$Query$FindImage<TRes>
    implements CopyWith$Query$FindImage<TRes> {
  _CopyWithStubImpl$Query$FindImage(this._res);

  TRes _res;

  call({Fragment$ImageData? findImage, String? $__typename}) => _res;

  CopyWith$Fragment$ImageData<TRes> get findImage =>
      CopyWith$Fragment$ImageData.stub(_res);
}

const documentNodeQueryFindImage = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.query,
      name: NameNode(value: 'FindImage'),
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
            name: NameNode(value: 'findImage'),
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
                  name: NameNode(value: 'ImageData'),
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
    fragmentDefinitionImageData,
  ],
);
Query$FindImage _parserFn$Query$FindImage(Map<String, dynamic> data) =>
    Query$FindImage.fromJson(data);
typedef OnQueryComplete$Query$FindImage =
    FutureOr<void> Function(Map<String, dynamic>?, Query$FindImage?);

class Options$Query$FindImage extends graphql.QueryOptions<Query$FindImage> {
  Options$Query$FindImage({
    String? operationName,
    required Variables$Query$FindImage variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$FindImage? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$FindImage? onComplete,
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
                 data == null ? null : _parserFn$Query$FindImage(data),
               ),
         onError: onError,
         document: documentNodeQueryFindImage,
         parserFn: _parserFn$Query$FindImage,
       );

  final OnQueryComplete$Query$FindImage? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
    ...super.onComplete == null
        ? super.properties
        : super.properties.where((property) => property != onComplete),
    onCompleteWithParsed,
  ];
}

class WatchOptions$Query$FindImage
    extends graphql.WatchQueryOptions<Query$FindImage> {
  WatchOptions$Query$FindImage({
    String? operationName,
    required Variables$Query$FindImage variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$FindImage? typedOptimisticResult,
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
         document: documentNodeQueryFindImage,
         pollInterval: pollInterval,
         eagerlyFetchResults: eagerlyFetchResults,
         carryForwardDataOnException: carryForwardDataOnException,
         fetchResults: fetchResults,
         parserFn: _parserFn$Query$FindImage,
       );
}

class FetchMoreOptions$Query$FindImage extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$FindImage({
    required graphql.UpdateQuery updateQuery,
    required Variables$Query$FindImage variables,
  }) : super(
         updateQuery: updateQuery,
         variables: variables.toJson(),
         document: documentNodeQueryFindImage,
       );
}

extension ClientExtension$Query$FindImage on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$FindImage>> query$FindImage(
    Options$Query$FindImage options,
  ) async => await this.query(options);

  graphql.ObservableQuery<Query$FindImage> watchQuery$FindImage(
    WatchOptions$Query$FindImage options,
  ) => this.watchQuery(options);

  void writeQuery$FindImage({
    required Query$FindImage data,
    required Variables$Query$FindImage variables,
    bool broadcast = true,
  }) => this.writeQuery(
    graphql.Request(
      operation: graphql.Operation(document: documentNodeQueryFindImage),
      variables: variables.toJson(),
    ),
    data: data.toJson(),
    broadcast: broadcast,
  );

  Query$FindImage? readQuery$FindImage({
    required Variables$Query$FindImage variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(document: documentNodeQueryFindImage),
        variables: variables.toJson(),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$FindImage.fromJson(result);
  }
}
