import '../../../../core/data/graphql/schema.graphql.dart';
import 'dart:async';
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;

class Fragment$SlimSceneData {
  Fragment$SlimSceneData({
    required this.id,
    this.title,
    this.date,
    this.rating100,
    this.o_counter,
    required this.organized,
    required this.interactive,
    this.resume_time,
    this.play_count,
    required this.files,
    required this.paths,
    this.studio,
    required this.performers,
    this.$__typename = 'Scene',
  });

  factory Fragment$SlimSceneData.fromJson(Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$title = json['title'];
    final l$date = json['date'];
    final l$rating100 = json['rating100'];
    final l$o_counter = json['o_counter'];
    final l$organized = json['organized'];
    final l$interactive = json['interactive'];
    final l$resume_time = json['resume_time'];
    final l$play_count = json['play_count'];
    final l$files = json['files'];
    final l$paths = json['paths'];
    final l$studio = json['studio'];
    final l$performers = json['performers'];
    final l$$__typename = json['__typename'];
    return Fragment$SlimSceneData(
      id: (l$id as String),
      title: (l$title as String?),
      date: (l$date as String?),
      rating100: (l$rating100 as int?),
      o_counter: (l$o_counter as int?),
      organized: (l$organized as bool),
      interactive: (l$interactive as bool),
      resume_time: (l$resume_time as num?)?.toDouble(),
      play_count: (l$play_count as int?),
      files: (l$files as List<dynamic>)
          .map(
            (e) => Fragment$SlimSceneData$files.fromJson(
              (e as Map<String, dynamic>),
            ),
          )
          .toList(),
      paths: Fragment$SlimSceneData$paths.fromJson(
        (l$paths as Map<String, dynamic>),
      ),
      studio: l$studio == null
          ? null
          : Fragment$SlimSceneData$studio.fromJson(
              (l$studio as Map<String, dynamic>),
            ),
      performers: (l$performers as List<dynamic>)
          .map(
            (e) => Fragment$SlimSceneData$performers.fromJson(
              (e as Map<String, dynamic>),
            ),
          )
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final String id;

  final String? title;

  final String? date;

  final int? rating100;

  final int? o_counter;

  final bool organized;

  final bool interactive;

  final double? resume_time;

  final int? play_count;

  final List<Fragment$SlimSceneData$files> files;

  final Fragment$SlimSceneData$paths paths;

  final Fragment$SlimSceneData$studio? studio;

  final List<Fragment$SlimSceneData$performers> performers;

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
    final l$o_counter = o_counter;
    _resultData['o_counter'] = l$o_counter;
    final l$organized = organized;
    _resultData['organized'] = l$organized;
    final l$interactive = interactive;
    _resultData['interactive'] = l$interactive;
    final l$resume_time = resume_time;
    _resultData['resume_time'] = l$resume_time;
    final l$play_count = play_count;
    _resultData['play_count'] = l$play_count;
    final l$files = files;
    _resultData['files'] = l$files.map((e) => e.toJson()).toList();
    final l$paths = paths;
    _resultData['paths'] = l$paths.toJson();
    final l$studio = studio;
    _resultData['studio'] = l$studio?.toJson();
    final l$performers = performers;
    _resultData['performers'] = l$performers.map((e) => e.toJson()).toList();
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
    final l$o_counter = o_counter;
    final l$organized = organized;
    final l$interactive = interactive;
    final l$resume_time = resume_time;
    final l$play_count = play_count;
    final l$files = files;
    final l$paths = paths;
    final l$studio = studio;
    final l$performers = performers;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$title,
      l$date,
      l$rating100,
      l$o_counter,
      l$organized,
      l$interactive,
      l$resume_time,
      l$play_count,
      Object.hashAll(l$files.map((v) => v)),
      l$paths,
      l$studio,
      Object.hashAll(l$performers.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$SlimSceneData || runtimeType != other.runtimeType) {
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
    final l$o_counter = o_counter;
    final lOther$o_counter = other.o_counter;
    if (l$o_counter != lOther$o_counter) {
      return false;
    }
    final l$organized = organized;
    final lOther$organized = other.organized;
    if (l$organized != lOther$organized) {
      return false;
    }
    final l$interactive = interactive;
    final lOther$interactive = other.interactive;
    if (l$interactive != lOther$interactive) {
      return false;
    }
    final l$resume_time = resume_time;
    final lOther$resume_time = other.resume_time;
    if (l$resume_time != lOther$resume_time) {
      return false;
    }
    final l$play_count = play_count;
    final lOther$play_count = other.play_count;
    if (l$play_count != lOther$play_count) {
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
    final l$studio = studio;
    final lOther$studio = other.studio;
    if (l$studio != lOther$studio) {
      return false;
    }
    final l$performers = performers;
    final lOther$performers = other.performers;
    if (l$performers.length != lOther$performers.length) {
      return false;
    }
    for (int i = 0; i < l$performers.length; i++) {
      final l$performers$entry = l$performers[i];
      final lOther$performers$entry = lOther$performers[i];
      if (l$performers$entry != lOther$performers$entry) {
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

extension UtilityExtension$Fragment$SlimSceneData on Fragment$SlimSceneData {
  CopyWith$Fragment$SlimSceneData<Fragment$SlimSceneData> get copyWith =>
      CopyWith$Fragment$SlimSceneData(this, (i) => i);
}

abstract class CopyWith$Fragment$SlimSceneData<TRes> {
  factory CopyWith$Fragment$SlimSceneData(
    Fragment$SlimSceneData instance,
    TRes Function(Fragment$SlimSceneData) then,
  ) = _CopyWithImpl$Fragment$SlimSceneData;

  factory CopyWith$Fragment$SlimSceneData.stub(TRes res) =
      _CopyWithStubImpl$Fragment$SlimSceneData;

  TRes call({
    String? id,
    String? title,
    String? date,
    int? rating100,
    int? o_counter,
    bool? organized,
    bool? interactive,
    double? resume_time,
    int? play_count,
    List<Fragment$SlimSceneData$files>? files,
    Fragment$SlimSceneData$paths? paths,
    Fragment$SlimSceneData$studio? studio,
    List<Fragment$SlimSceneData$performers>? performers,
    String? $__typename,
  });
  TRes files(
    Iterable<Fragment$SlimSceneData$files> Function(
      Iterable<
        CopyWith$Fragment$SlimSceneData$files<Fragment$SlimSceneData$files>
      >,
    )
    _fn,
  );
  CopyWith$Fragment$SlimSceneData$paths<TRes> get paths;
  CopyWith$Fragment$SlimSceneData$studio<TRes> get studio;
  TRes performers(
    Iterable<Fragment$SlimSceneData$performers> Function(
      Iterable<
        CopyWith$Fragment$SlimSceneData$performers<
          Fragment$SlimSceneData$performers
        >
      >,
    )
    _fn,
  );
}

class _CopyWithImpl$Fragment$SlimSceneData<TRes>
    implements CopyWith$Fragment$SlimSceneData<TRes> {
  _CopyWithImpl$Fragment$SlimSceneData(this._instance, this._then);

  final Fragment$SlimSceneData _instance;

  final TRes Function(Fragment$SlimSceneData) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? title = _undefined,
    Object? date = _undefined,
    Object? rating100 = _undefined,
    Object? o_counter = _undefined,
    Object? organized = _undefined,
    Object? interactive = _undefined,
    Object? resume_time = _undefined,
    Object? play_count = _undefined,
    Object? files = _undefined,
    Object? paths = _undefined,
    Object? studio = _undefined,
    Object? performers = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Fragment$SlimSceneData(
      id: id == _undefined || id == null ? _instance.id : (id as String),
      title: title == _undefined ? _instance.title : (title as String?),
      date: date == _undefined ? _instance.date : (date as String?),
      rating100: rating100 == _undefined
          ? _instance.rating100
          : (rating100 as int?),
      o_counter: o_counter == _undefined
          ? _instance.o_counter
          : (o_counter as int?),
      organized: organized == _undefined || organized == null
          ? _instance.organized
          : (organized as bool),
      interactive: interactive == _undefined || interactive == null
          ? _instance.interactive
          : (interactive as bool),
      resume_time: resume_time == _undefined
          ? _instance.resume_time
          : (resume_time as double?),
      play_count: play_count == _undefined
          ? _instance.play_count
          : (play_count as int?),
      files: files == _undefined || files == null
          ? _instance.files
          : (files as List<Fragment$SlimSceneData$files>),
      paths: paths == _undefined || paths == null
          ? _instance.paths
          : (paths as Fragment$SlimSceneData$paths),
      studio: studio == _undefined
          ? _instance.studio
          : (studio as Fragment$SlimSceneData$studio?),
      performers: performers == _undefined || performers == null
          ? _instance.performers
          : (performers as List<Fragment$SlimSceneData$performers>),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  TRes files(
    Iterable<Fragment$SlimSceneData$files> Function(
      Iterable<
        CopyWith$Fragment$SlimSceneData$files<Fragment$SlimSceneData$files>
      >,
    )
    _fn,
  ) => call(
    files: _fn(
      _instance.files.map(
        (e) => CopyWith$Fragment$SlimSceneData$files(e, (i) => i),
      ),
    ).toList(),
  );

  CopyWith$Fragment$SlimSceneData$paths<TRes> get paths {
    final local$paths = _instance.paths;
    return CopyWith$Fragment$SlimSceneData$paths(
      local$paths,
      (e) => call(paths: e),
    );
  }

  CopyWith$Fragment$SlimSceneData$studio<TRes> get studio {
    final local$studio = _instance.studio;
    return local$studio == null
        ? CopyWith$Fragment$SlimSceneData$studio.stub(_then(_instance))
        : CopyWith$Fragment$SlimSceneData$studio(
            local$studio,
            (e) => call(studio: e),
          );
  }

  TRes performers(
    Iterable<Fragment$SlimSceneData$performers> Function(
      Iterable<
        CopyWith$Fragment$SlimSceneData$performers<
          Fragment$SlimSceneData$performers
        >
      >,
    )
    _fn,
  ) => call(
    performers: _fn(
      _instance.performers.map(
        (e) => CopyWith$Fragment$SlimSceneData$performers(e, (i) => i),
      ),
    ).toList(),
  );
}

class _CopyWithStubImpl$Fragment$SlimSceneData<TRes>
    implements CopyWith$Fragment$SlimSceneData<TRes> {
  _CopyWithStubImpl$Fragment$SlimSceneData(this._res);

  TRes _res;

  call({
    String? id,
    String? title,
    String? date,
    int? rating100,
    int? o_counter,
    bool? organized,
    bool? interactive,
    double? resume_time,
    int? play_count,
    List<Fragment$SlimSceneData$files>? files,
    Fragment$SlimSceneData$paths? paths,
    Fragment$SlimSceneData$studio? studio,
    List<Fragment$SlimSceneData$performers>? performers,
    String? $__typename,
  }) => _res;

  files(_fn) => _res;

  CopyWith$Fragment$SlimSceneData$paths<TRes> get paths =>
      CopyWith$Fragment$SlimSceneData$paths.stub(_res);

  CopyWith$Fragment$SlimSceneData$studio<TRes> get studio =>
      CopyWith$Fragment$SlimSceneData$studio.stub(_res);

  performers(_fn) => _res;
}

const fragmentDefinitionSlimSceneData = FragmentDefinitionNode(
  name: NameNode(value: 'SlimSceneData'),
  typeCondition: TypeConditionNode(
    on: NamedTypeNode(name: NameNode(value: 'Scene'), isNonNull: false),
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
        name: NameNode(value: 'o_counter'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'organized'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'interactive'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'resume_time'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'play_count'),
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
              name: NameNode(value: 'duration'),
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
              name: NameNode(value: 'screenshot'),
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
              name: NameNode(value: 'stream'),
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
        name: NameNode(value: 'studio'),
        alias: null,
        arguments: [],
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
              name: NameNode(value: 'image_path'),
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
        name: NameNode(value: 'performers'),
        alias: null,
        arguments: [],
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
              name: NameNode(value: 'image_path'),
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
const documentNodeFragmentSlimSceneData = DocumentNode(
  definitions: [fragmentDefinitionSlimSceneData],
);

extension ClientExtension$Fragment$SlimSceneData on graphql.GraphQLClient {
  void writeFragment$SlimSceneData({
    required Fragment$SlimSceneData data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) => this.writeFragment(
    graphql.FragmentRequest(
      idFields: idFields,
      fragment: const graphql.Fragment(
        fragmentName: 'SlimSceneData',
        document: documentNodeFragmentSlimSceneData,
      ),
    ),
    data: data.toJson(),
    broadcast: broadcast,
  );

  Fragment$SlimSceneData? readFragment$SlimSceneData({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'SlimSceneData',
          document: documentNodeFragmentSlimSceneData,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$SlimSceneData.fromJson(result);
  }
}

class Fragment$SlimSceneData$files {
  Fragment$SlimSceneData$files({
    required this.path,
    required this.duration,
    this.$__typename = 'VideoFile',
  });

  factory Fragment$SlimSceneData$files.fromJson(Map<String, dynamic> json) {
    final l$path = json['path'];
    final l$duration = json['duration'];
    final l$$__typename = json['__typename'];
    return Fragment$SlimSceneData$files(
      path: (l$path as String),
      duration: (l$duration as num).toDouble(),
      $__typename: (l$$__typename as String),
    );
  }

  final String path;

  final double duration;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$path = path;
    _resultData['path'] = l$path;
    final l$duration = duration;
    _resultData['duration'] = l$duration;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$path = path;
    final l$duration = duration;
    final l$$__typename = $__typename;
    return Object.hashAll([l$path, l$duration, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$SlimSceneData$files ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$path = path;
    final lOther$path = other.path;
    if (l$path != lOther$path) {
      return false;
    }
    final l$duration = duration;
    final lOther$duration = other.duration;
    if (l$duration != lOther$duration) {
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

extension UtilityExtension$Fragment$SlimSceneData$files
    on Fragment$SlimSceneData$files {
  CopyWith$Fragment$SlimSceneData$files<Fragment$SlimSceneData$files>
  get copyWith => CopyWith$Fragment$SlimSceneData$files(this, (i) => i);
}

abstract class CopyWith$Fragment$SlimSceneData$files<TRes> {
  factory CopyWith$Fragment$SlimSceneData$files(
    Fragment$SlimSceneData$files instance,
    TRes Function(Fragment$SlimSceneData$files) then,
  ) = _CopyWithImpl$Fragment$SlimSceneData$files;

  factory CopyWith$Fragment$SlimSceneData$files.stub(TRes res) =
      _CopyWithStubImpl$Fragment$SlimSceneData$files;

  TRes call({String? path, double? duration, String? $__typename});
}

class _CopyWithImpl$Fragment$SlimSceneData$files<TRes>
    implements CopyWith$Fragment$SlimSceneData$files<TRes> {
  _CopyWithImpl$Fragment$SlimSceneData$files(this._instance, this._then);

  final Fragment$SlimSceneData$files _instance;

  final TRes Function(Fragment$SlimSceneData$files) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? path = _undefined,
    Object? duration = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Fragment$SlimSceneData$files(
      path: path == _undefined || path == null
          ? _instance.path
          : (path as String),
      duration: duration == _undefined || duration == null
          ? _instance.duration
          : (duration as double),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Fragment$SlimSceneData$files<TRes>
    implements CopyWith$Fragment$SlimSceneData$files<TRes> {
  _CopyWithStubImpl$Fragment$SlimSceneData$files(this._res);

  TRes _res;

  call({String? path, double? duration, String? $__typename}) => _res;
}

class Fragment$SlimSceneData$paths {
  Fragment$SlimSceneData$paths({
    this.screenshot,
    this.preview,
    this.stream,
    this.$__typename = 'ScenePathsType',
  });

  factory Fragment$SlimSceneData$paths.fromJson(Map<String, dynamic> json) {
    final l$screenshot = json['screenshot'];
    final l$preview = json['preview'];
    final l$stream = json['stream'];
    final l$$__typename = json['__typename'];
    return Fragment$SlimSceneData$paths(
      screenshot: (l$screenshot as String?),
      preview: (l$preview as String?),
      stream: (l$stream as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String? screenshot;

  final String? preview;

  final String? stream;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$screenshot = screenshot;
    _resultData['screenshot'] = l$screenshot;
    final l$preview = preview;
    _resultData['preview'] = l$preview;
    final l$stream = stream;
    _resultData['stream'] = l$stream;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$screenshot = screenshot;
    final l$preview = preview;
    final l$stream = stream;
    final l$$__typename = $__typename;
    return Object.hashAll([l$screenshot, l$preview, l$stream, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$SlimSceneData$paths ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$screenshot = screenshot;
    final lOther$screenshot = other.screenshot;
    if (l$screenshot != lOther$screenshot) {
      return false;
    }
    final l$preview = preview;
    final lOther$preview = other.preview;
    if (l$preview != lOther$preview) {
      return false;
    }
    final l$stream = stream;
    final lOther$stream = other.stream;
    if (l$stream != lOther$stream) {
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

extension UtilityExtension$Fragment$SlimSceneData$paths
    on Fragment$SlimSceneData$paths {
  CopyWith$Fragment$SlimSceneData$paths<Fragment$SlimSceneData$paths>
  get copyWith => CopyWith$Fragment$SlimSceneData$paths(this, (i) => i);
}

abstract class CopyWith$Fragment$SlimSceneData$paths<TRes> {
  factory CopyWith$Fragment$SlimSceneData$paths(
    Fragment$SlimSceneData$paths instance,
    TRes Function(Fragment$SlimSceneData$paths) then,
  ) = _CopyWithImpl$Fragment$SlimSceneData$paths;

  factory CopyWith$Fragment$SlimSceneData$paths.stub(TRes res) =
      _CopyWithStubImpl$Fragment$SlimSceneData$paths;

  TRes call({
    String? screenshot,
    String? preview,
    String? stream,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$SlimSceneData$paths<TRes>
    implements CopyWith$Fragment$SlimSceneData$paths<TRes> {
  _CopyWithImpl$Fragment$SlimSceneData$paths(this._instance, this._then);

  final Fragment$SlimSceneData$paths _instance;

  final TRes Function(Fragment$SlimSceneData$paths) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? screenshot = _undefined,
    Object? preview = _undefined,
    Object? stream = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Fragment$SlimSceneData$paths(
      screenshot: screenshot == _undefined
          ? _instance.screenshot
          : (screenshot as String?),
      preview: preview == _undefined ? _instance.preview : (preview as String?),
      stream: stream == _undefined ? _instance.stream : (stream as String?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Fragment$SlimSceneData$paths<TRes>
    implements CopyWith$Fragment$SlimSceneData$paths<TRes> {
  _CopyWithStubImpl$Fragment$SlimSceneData$paths(this._res);

  TRes _res;

  call({
    String? screenshot,
    String? preview,
    String? stream,
    String? $__typename,
  }) => _res;
}

class Fragment$SlimSceneData$studio {
  Fragment$SlimSceneData$studio({
    required this.id,
    required this.name,
    this.image_path,
    this.$__typename = 'Studio',
  });

  factory Fragment$SlimSceneData$studio.fromJson(Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$name = json['name'];
    final l$image_path = json['image_path'];
    final l$$__typename = json['__typename'];
    return Fragment$SlimSceneData$studio(
      id: (l$id as String),
      name: (l$name as String),
      image_path: (l$image_path as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String id;

  final String name;

  final String? image_path;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$name = name;
    _resultData['name'] = l$name;
    final l$image_path = image_path;
    _resultData['image_path'] = l$image_path;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$name = name;
    final l$image_path = image_path;
    final l$$__typename = $__typename;
    return Object.hashAll([l$id, l$name, l$image_path, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$SlimSceneData$studio ||
        runtimeType != other.runtimeType) {
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
    final l$image_path = image_path;
    final lOther$image_path = other.image_path;
    if (l$image_path != lOther$image_path) {
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

extension UtilityExtension$Fragment$SlimSceneData$studio
    on Fragment$SlimSceneData$studio {
  CopyWith$Fragment$SlimSceneData$studio<Fragment$SlimSceneData$studio>
  get copyWith => CopyWith$Fragment$SlimSceneData$studio(this, (i) => i);
}

abstract class CopyWith$Fragment$SlimSceneData$studio<TRes> {
  factory CopyWith$Fragment$SlimSceneData$studio(
    Fragment$SlimSceneData$studio instance,
    TRes Function(Fragment$SlimSceneData$studio) then,
  ) = _CopyWithImpl$Fragment$SlimSceneData$studio;

  factory CopyWith$Fragment$SlimSceneData$studio.stub(TRes res) =
      _CopyWithStubImpl$Fragment$SlimSceneData$studio;

  TRes call({
    String? id,
    String? name,
    String? image_path,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$SlimSceneData$studio<TRes>
    implements CopyWith$Fragment$SlimSceneData$studio<TRes> {
  _CopyWithImpl$Fragment$SlimSceneData$studio(this._instance, this._then);

  final Fragment$SlimSceneData$studio _instance;

  final TRes Function(Fragment$SlimSceneData$studio) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? name = _undefined,
    Object? image_path = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Fragment$SlimSceneData$studio(
      id: id == _undefined || id == null ? _instance.id : (id as String),
      name: name == _undefined || name == null
          ? _instance.name
          : (name as String),
      image_path: image_path == _undefined
          ? _instance.image_path
          : (image_path as String?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Fragment$SlimSceneData$studio<TRes>
    implements CopyWith$Fragment$SlimSceneData$studio<TRes> {
  _CopyWithStubImpl$Fragment$SlimSceneData$studio(this._res);

  TRes _res;

  call({String? id, String? name, String? image_path, String? $__typename}) =>
      _res;
}

class Fragment$SlimSceneData$performers {
  Fragment$SlimSceneData$performers({
    required this.id,
    required this.name,
    this.image_path,
    this.$__typename = 'Performer',
  });

  factory Fragment$SlimSceneData$performers.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$id = json['id'];
    final l$name = json['name'];
    final l$image_path = json['image_path'];
    final l$$__typename = json['__typename'];
    return Fragment$SlimSceneData$performers(
      id: (l$id as String),
      name: (l$name as String),
      image_path: (l$image_path as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String id;

  final String name;

  final String? image_path;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$name = name;
    _resultData['name'] = l$name;
    final l$image_path = image_path;
    _resultData['image_path'] = l$image_path;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$name = name;
    final l$image_path = image_path;
    final l$$__typename = $__typename;
    return Object.hashAll([l$id, l$name, l$image_path, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$SlimSceneData$performers ||
        runtimeType != other.runtimeType) {
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
    final l$image_path = image_path;
    final lOther$image_path = other.image_path;
    if (l$image_path != lOther$image_path) {
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

extension UtilityExtension$Fragment$SlimSceneData$performers
    on Fragment$SlimSceneData$performers {
  CopyWith$Fragment$SlimSceneData$performers<Fragment$SlimSceneData$performers>
  get copyWith => CopyWith$Fragment$SlimSceneData$performers(this, (i) => i);
}

abstract class CopyWith$Fragment$SlimSceneData$performers<TRes> {
  factory CopyWith$Fragment$SlimSceneData$performers(
    Fragment$SlimSceneData$performers instance,
    TRes Function(Fragment$SlimSceneData$performers) then,
  ) = _CopyWithImpl$Fragment$SlimSceneData$performers;

  factory CopyWith$Fragment$SlimSceneData$performers.stub(TRes res) =
      _CopyWithStubImpl$Fragment$SlimSceneData$performers;

  TRes call({
    String? id,
    String? name,
    String? image_path,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$SlimSceneData$performers<TRes>
    implements CopyWith$Fragment$SlimSceneData$performers<TRes> {
  _CopyWithImpl$Fragment$SlimSceneData$performers(this._instance, this._then);

  final Fragment$SlimSceneData$performers _instance;

  final TRes Function(Fragment$SlimSceneData$performers) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? name = _undefined,
    Object? image_path = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Fragment$SlimSceneData$performers(
      id: id == _undefined || id == null ? _instance.id : (id as String),
      name: name == _undefined || name == null
          ? _instance.name
          : (name as String),
      image_path: image_path == _undefined
          ? _instance.image_path
          : (image_path as String?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Fragment$SlimSceneData$performers<TRes>
    implements CopyWith$Fragment$SlimSceneData$performers<TRes> {
  _CopyWithStubImpl$Fragment$SlimSceneData$performers(this._res);

  TRes _res;

  call({String? id, String? name, String? image_path, String? $__typename}) =>
      _res;
}

class Fragment$SceneData implements Fragment$SlimSceneData {
  Fragment$SceneData({
    required this.id,
    this.title,
    this.date,
    this.rating100,
    this.o_counter,
    required this.organized,
    required this.interactive,
    this.resume_time,
    this.play_count,
    required this.files,
    required this.paths,
    this.studio,
    required this.performers,
    this.$__typename = 'Scene',
    this.details,
    required this.urls,
    this.director,
    required this.tags,
  });

  factory Fragment$SceneData.fromJson(Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$title = json['title'];
    final l$date = json['date'];
    final l$rating100 = json['rating100'];
    final l$o_counter = json['o_counter'];
    final l$organized = json['organized'];
    final l$interactive = json['interactive'];
    final l$resume_time = json['resume_time'];
    final l$play_count = json['play_count'];
    final l$files = json['files'];
    final l$paths = json['paths'];
    final l$studio = json['studio'];
    final l$performers = json['performers'];
    final l$$__typename = json['__typename'];
    final l$details = json['details'];
    final l$urls = json['urls'];
    final l$director = json['director'];
    final l$tags = json['tags'];
    return Fragment$SceneData(
      id: (l$id as String),
      title: (l$title as String?),
      date: (l$date as String?),
      rating100: (l$rating100 as int?),
      o_counter: (l$o_counter as int?),
      organized: (l$organized as bool),
      interactive: (l$interactive as bool),
      resume_time: (l$resume_time as num?)?.toDouble(),
      play_count: (l$play_count as int?),
      files: (l$files as List<dynamic>)
          .map(
            (e) =>
                Fragment$SceneData$files.fromJson((e as Map<String, dynamic>)),
          )
          .toList(),
      paths: Fragment$SceneData$paths.fromJson(
        (l$paths as Map<String, dynamic>),
      ),
      studio: l$studio == null
          ? null
          : Fragment$SceneData$studio.fromJson(
              (l$studio as Map<String, dynamic>),
            ),
      performers: (l$performers as List<dynamic>)
          .map(
            (e) => Fragment$SceneData$performers.fromJson(
              (e as Map<String, dynamic>),
            ),
          )
          .toList(),
      $__typename: (l$$__typename as String),
      details: (l$details as String?),
      urls: (l$urls as List<dynamic>).map((e) => (e as String)).toList(),
      director: (l$director as String?),
      tags: (l$tags as List<dynamic>)
          .map(
            (e) =>
                Fragment$SceneData$tags.fromJson((e as Map<String, dynamic>)),
          )
          .toList(),
    );
  }

  final String id;

  final String? title;

  final String? date;

  final int? rating100;

  final int? o_counter;

  final bool organized;

  final bool interactive;

  final double? resume_time;

  final int? play_count;

  final List<Fragment$SceneData$files> files;

  final Fragment$SceneData$paths paths;

  final Fragment$SceneData$studio? studio;

  final List<Fragment$SceneData$performers> performers;

  final String $__typename;

  final String? details;

  final List<String> urls;

  final String? director;

  final List<Fragment$SceneData$tags> tags;

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
    final l$o_counter = o_counter;
    _resultData['o_counter'] = l$o_counter;
    final l$organized = organized;
    _resultData['organized'] = l$organized;
    final l$interactive = interactive;
    _resultData['interactive'] = l$interactive;
    final l$resume_time = resume_time;
    _resultData['resume_time'] = l$resume_time;
    final l$play_count = play_count;
    _resultData['play_count'] = l$play_count;
    final l$files = files;
    _resultData['files'] = l$files.map((e) => e.toJson()).toList();
    final l$paths = paths;
    _resultData['paths'] = l$paths.toJson();
    final l$studio = studio;
    _resultData['studio'] = l$studio?.toJson();
    final l$performers = performers;
    _resultData['performers'] = l$performers.map((e) => e.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    final l$details = details;
    _resultData['details'] = l$details;
    final l$urls = urls;
    _resultData['urls'] = l$urls.map((e) => e).toList();
    final l$director = director;
    _resultData['director'] = l$director;
    final l$tags = tags;
    _resultData['tags'] = l$tags.map((e) => e.toJson()).toList();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$title = title;
    final l$date = date;
    final l$rating100 = rating100;
    final l$o_counter = o_counter;
    final l$organized = organized;
    final l$interactive = interactive;
    final l$resume_time = resume_time;
    final l$play_count = play_count;
    final l$files = files;
    final l$paths = paths;
    final l$studio = studio;
    final l$performers = performers;
    final l$$__typename = $__typename;
    final l$details = details;
    final l$urls = urls;
    final l$director = director;
    final l$tags = tags;
    return Object.hashAll([
      l$id,
      l$title,
      l$date,
      l$rating100,
      l$o_counter,
      l$organized,
      l$interactive,
      l$resume_time,
      l$play_count,
      Object.hashAll(l$files.map((v) => v)),
      l$paths,
      l$studio,
      Object.hashAll(l$performers.map((v) => v)),
      l$$__typename,
      l$details,
      Object.hashAll(l$urls.map((v) => v)),
      l$director,
      Object.hashAll(l$tags.map((v) => v)),
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$SceneData || runtimeType != other.runtimeType) {
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
    final l$o_counter = o_counter;
    final lOther$o_counter = other.o_counter;
    if (l$o_counter != lOther$o_counter) {
      return false;
    }
    final l$organized = organized;
    final lOther$organized = other.organized;
    if (l$organized != lOther$organized) {
      return false;
    }
    final l$interactive = interactive;
    final lOther$interactive = other.interactive;
    if (l$interactive != lOther$interactive) {
      return false;
    }
    final l$resume_time = resume_time;
    final lOther$resume_time = other.resume_time;
    if (l$resume_time != lOther$resume_time) {
      return false;
    }
    final l$play_count = play_count;
    final lOther$play_count = other.play_count;
    if (l$play_count != lOther$play_count) {
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
    final l$studio = studio;
    final lOther$studio = other.studio;
    if (l$studio != lOther$studio) {
      return false;
    }
    final l$performers = performers;
    final lOther$performers = other.performers;
    if (l$performers.length != lOther$performers.length) {
      return false;
    }
    for (int i = 0; i < l$performers.length; i++) {
      final l$performers$entry = l$performers[i];
      final lOther$performers$entry = lOther$performers[i];
      if (l$performers$entry != lOther$performers$entry) {
        return false;
      }
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    final l$details = details;
    final lOther$details = other.details;
    if (l$details != lOther$details) {
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
    final l$director = director;
    final lOther$director = other.director;
    if (l$director != lOther$director) {
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
    return true;
  }
}

extension UtilityExtension$Fragment$SceneData on Fragment$SceneData {
  CopyWith$Fragment$SceneData<Fragment$SceneData> get copyWith =>
      CopyWith$Fragment$SceneData(this, (i) => i);
}

abstract class CopyWith$Fragment$SceneData<TRes> {
  factory CopyWith$Fragment$SceneData(
    Fragment$SceneData instance,
    TRes Function(Fragment$SceneData) then,
  ) = _CopyWithImpl$Fragment$SceneData;

  factory CopyWith$Fragment$SceneData.stub(TRes res) =
      _CopyWithStubImpl$Fragment$SceneData;

  TRes call({
    String? id,
    String? title,
    String? date,
    int? rating100,
    int? o_counter,
    bool? organized,
    bool? interactive,
    double? resume_time,
    int? play_count,
    List<Fragment$SceneData$files>? files,
    Fragment$SceneData$paths? paths,
    Fragment$SceneData$studio? studio,
    List<Fragment$SceneData$performers>? performers,
    String? $__typename,
    String? details,
    List<String>? urls,
    String? director,
    List<Fragment$SceneData$tags>? tags,
  });
  TRes files(
    Iterable<Fragment$SceneData$files> Function(
      Iterable<CopyWith$Fragment$SceneData$files<Fragment$SceneData$files>>,
    )
    _fn,
  );
  CopyWith$Fragment$SceneData$paths<TRes> get paths;
  CopyWith$Fragment$SceneData$studio<TRes> get studio;
  TRes performers(
    Iterable<Fragment$SceneData$performers> Function(
      Iterable<
        CopyWith$Fragment$SceneData$performers<Fragment$SceneData$performers>
      >,
    )
    _fn,
  );
  TRes tags(
    Iterable<Fragment$SceneData$tags> Function(
      Iterable<CopyWith$Fragment$SceneData$tags<Fragment$SceneData$tags>>,
    )
    _fn,
  );
}

class _CopyWithImpl$Fragment$SceneData<TRes>
    implements CopyWith$Fragment$SceneData<TRes> {
  _CopyWithImpl$Fragment$SceneData(this._instance, this._then);

  final Fragment$SceneData _instance;

  final TRes Function(Fragment$SceneData) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? title = _undefined,
    Object? date = _undefined,
    Object? rating100 = _undefined,
    Object? o_counter = _undefined,
    Object? organized = _undefined,
    Object? interactive = _undefined,
    Object? resume_time = _undefined,
    Object? play_count = _undefined,
    Object? files = _undefined,
    Object? paths = _undefined,
    Object? studio = _undefined,
    Object? performers = _undefined,
    Object? $__typename = _undefined,
    Object? details = _undefined,
    Object? urls = _undefined,
    Object? director = _undefined,
    Object? tags = _undefined,
  }) => _then(
    Fragment$SceneData(
      id: id == _undefined || id == null ? _instance.id : (id as String),
      title: title == _undefined ? _instance.title : (title as String?),
      date: date == _undefined ? _instance.date : (date as String?),
      rating100: rating100 == _undefined
          ? _instance.rating100
          : (rating100 as int?),
      o_counter: o_counter == _undefined
          ? _instance.o_counter
          : (o_counter as int?),
      organized: organized == _undefined || organized == null
          ? _instance.organized
          : (organized as bool),
      interactive: interactive == _undefined || interactive == null
          ? _instance.interactive
          : (interactive as bool),
      resume_time: resume_time == _undefined
          ? _instance.resume_time
          : (resume_time as double?),
      play_count: play_count == _undefined
          ? _instance.play_count
          : (play_count as int?),
      files: files == _undefined || files == null
          ? _instance.files
          : (files as List<Fragment$SceneData$files>),
      paths: paths == _undefined || paths == null
          ? _instance.paths
          : (paths as Fragment$SceneData$paths),
      studio: studio == _undefined
          ? _instance.studio
          : (studio as Fragment$SceneData$studio?),
      performers: performers == _undefined || performers == null
          ? _instance.performers
          : (performers as List<Fragment$SceneData$performers>),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
      details: details == _undefined ? _instance.details : (details as String?),
      urls: urls == _undefined || urls == null
          ? _instance.urls
          : (urls as List<String>),
      director: director == _undefined
          ? _instance.director
          : (director as String?),
      tags: tags == _undefined || tags == null
          ? _instance.tags
          : (tags as List<Fragment$SceneData$tags>),
    ),
  );

  TRes files(
    Iterable<Fragment$SceneData$files> Function(
      Iterable<CopyWith$Fragment$SceneData$files<Fragment$SceneData$files>>,
    )
    _fn,
  ) => call(
    files: _fn(
      _instance.files.map(
        (e) => CopyWith$Fragment$SceneData$files(e, (i) => i),
      ),
    ).toList(),
  );

  CopyWith$Fragment$SceneData$paths<TRes> get paths {
    final local$paths = _instance.paths;
    return CopyWith$Fragment$SceneData$paths(
      local$paths,
      (e) => call(paths: e),
    );
  }

  CopyWith$Fragment$SceneData$studio<TRes> get studio {
    final local$studio = _instance.studio;
    return local$studio == null
        ? CopyWith$Fragment$SceneData$studio.stub(_then(_instance))
        : CopyWith$Fragment$SceneData$studio(
            local$studio,
            (e) => call(studio: e),
          );
  }

  TRes performers(
    Iterable<Fragment$SceneData$performers> Function(
      Iterable<
        CopyWith$Fragment$SceneData$performers<Fragment$SceneData$performers>
      >,
    )
    _fn,
  ) => call(
    performers: _fn(
      _instance.performers.map(
        (e) => CopyWith$Fragment$SceneData$performers(e, (i) => i),
      ),
    ).toList(),
  );

  TRes tags(
    Iterable<Fragment$SceneData$tags> Function(
      Iterable<CopyWith$Fragment$SceneData$tags<Fragment$SceneData$tags>>,
    )
    _fn,
  ) => call(
    tags: _fn(
      _instance.tags.map((e) => CopyWith$Fragment$SceneData$tags(e, (i) => i)),
    ).toList(),
  );
}

class _CopyWithStubImpl$Fragment$SceneData<TRes>
    implements CopyWith$Fragment$SceneData<TRes> {
  _CopyWithStubImpl$Fragment$SceneData(this._res);

  TRes _res;

  call({
    String? id,
    String? title,
    String? date,
    int? rating100,
    int? o_counter,
    bool? organized,
    bool? interactive,
    double? resume_time,
    int? play_count,
    List<Fragment$SceneData$files>? files,
    Fragment$SceneData$paths? paths,
    Fragment$SceneData$studio? studio,
    List<Fragment$SceneData$performers>? performers,
    String? $__typename,
    String? details,
    List<String>? urls,
    String? director,
    List<Fragment$SceneData$tags>? tags,
  }) => _res;

  files(_fn) => _res;

  CopyWith$Fragment$SceneData$paths<TRes> get paths =>
      CopyWith$Fragment$SceneData$paths.stub(_res);

  CopyWith$Fragment$SceneData$studio<TRes> get studio =>
      CopyWith$Fragment$SceneData$studio.stub(_res);

  performers(_fn) => _res;

  tags(_fn) => _res;
}

const fragmentDefinitionSceneData = FragmentDefinitionNode(
  name: NameNode(value: 'SceneData'),
  typeCondition: TypeConditionNode(
    on: NamedTypeNode(name: NameNode(value: 'Scene'), isNonNull: false),
  ),
  directives: [],
  selectionSet: SelectionSetNode(
    selections: [
      FragmentSpreadNode(
        name: NameNode(value: 'SlimSceneData'),
        directives: [],
      ),
      FieldNode(
        name: NameNode(value: 'details'),
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
        name: NameNode(value: 'director'),
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
              name: NameNode(value: 'basename'),
              alias: null,
              arguments: [],
              directives: [],
              selectionSet: null,
            ),
            FieldNode(
              name: NameNode(value: 'format'),
              alias: null,
              arguments: [],
              directives: [],
              selectionSet: null,
            ),
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
              name: NameNode(value: 'video_codec'),
              alias: null,
              arguments: [],
              directives: [],
              selectionSet: null,
            ),
            FieldNode(
              name: NameNode(value: 'audio_codec'),
              alias: null,
              arguments: [],
              directives: [],
              selectionSet: null,
            ),
            FieldNode(
              name: NameNode(value: 'bit_rate'),
              alias: null,
              arguments: [],
              directives: [],
              selectionSet: null,
            ),
            FieldNode(
              name: NameNode(value: 'duration'),
              alias: null,
              arguments: [],
              directives: [],
              selectionSet: null,
            ),
            FieldNode(
              name: NameNode(value: 'frame_rate'),
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
        name: NameNode(value: 'tags'),
        alias: null,
        arguments: [],
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
const documentNodeFragmentSceneData = DocumentNode(
  definitions: [fragmentDefinitionSceneData, fragmentDefinitionSlimSceneData],
);

extension ClientExtension$Fragment$SceneData on graphql.GraphQLClient {
  void writeFragment$SceneData({
    required Fragment$SceneData data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) => this.writeFragment(
    graphql.FragmentRequest(
      idFields: idFields,
      fragment: const graphql.Fragment(
        fragmentName: 'SceneData',
        document: documentNodeFragmentSceneData,
      ),
    ),
    data: data.toJson(),
    broadcast: broadcast,
  );

  Fragment$SceneData? readFragment$SceneData({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'SceneData',
          document: documentNodeFragmentSceneData,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$SceneData.fromJson(result);
  }
}

class Fragment$SceneData$files implements Fragment$SlimSceneData$files {
  Fragment$SceneData$files({
    required this.path,
    required this.duration,
    this.$__typename = 'VideoFile',
    required this.basename,
    required this.format,
    required this.width,
    required this.height,
    required this.video_codec,
    required this.audio_codec,
    required this.bit_rate,
    required this.frame_rate,
  });

  factory Fragment$SceneData$files.fromJson(Map<String, dynamic> json) {
    final l$path = json['path'];
    final l$duration = json['duration'];
    final l$$__typename = json['__typename'];
    final l$basename = json['basename'];
    final l$format = json['format'];
    final l$width = json['width'];
    final l$height = json['height'];
    final l$video_codec = json['video_codec'];
    final l$audio_codec = json['audio_codec'];
    final l$bit_rate = json['bit_rate'];
    final l$frame_rate = json['frame_rate'];
    return Fragment$SceneData$files(
      path: (l$path as String),
      duration: (l$duration as num).toDouble(),
      $__typename: (l$$__typename as String),
      basename: (l$basename as String),
      format: (l$format as String),
      width: (l$width as int),
      height: (l$height as int),
      video_codec: (l$video_codec as String),
      audio_codec: (l$audio_codec as String),
      bit_rate: (l$bit_rate as int),
      frame_rate: (l$frame_rate as num).toDouble(),
    );
  }

  final String path;

  final double duration;

  final String $__typename;

  final String basename;

  final String format;

  final int width;

  final int height;

  final String video_codec;

  final String audio_codec;

  final int bit_rate;

  final double frame_rate;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$path = path;
    _resultData['path'] = l$path;
    final l$duration = duration;
    _resultData['duration'] = l$duration;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    final l$basename = basename;
    _resultData['basename'] = l$basename;
    final l$format = format;
    _resultData['format'] = l$format;
    final l$width = width;
    _resultData['width'] = l$width;
    final l$height = height;
    _resultData['height'] = l$height;
    final l$video_codec = video_codec;
    _resultData['video_codec'] = l$video_codec;
    final l$audio_codec = audio_codec;
    _resultData['audio_codec'] = l$audio_codec;
    final l$bit_rate = bit_rate;
    _resultData['bit_rate'] = l$bit_rate;
    final l$frame_rate = frame_rate;
    _resultData['frame_rate'] = l$frame_rate;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$path = path;
    final l$duration = duration;
    final l$$__typename = $__typename;
    final l$basename = basename;
    final l$format = format;
    final l$width = width;
    final l$height = height;
    final l$video_codec = video_codec;
    final l$audio_codec = audio_codec;
    final l$bit_rate = bit_rate;
    final l$frame_rate = frame_rate;
    return Object.hashAll([
      l$path,
      l$duration,
      l$$__typename,
      l$basename,
      l$format,
      l$width,
      l$height,
      l$video_codec,
      l$audio_codec,
      l$bit_rate,
      l$frame_rate,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$SceneData$files ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$path = path;
    final lOther$path = other.path;
    if (l$path != lOther$path) {
      return false;
    }
    final l$duration = duration;
    final lOther$duration = other.duration;
    if (l$duration != lOther$duration) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    final l$basename = basename;
    final lOther$basename = other.basename;
    if (l$basename != lOther$basename) {
      return false;
    }
    final l$format = format;
    final lOther$format = other.format;
    if (l$format != lOther$format) {
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
    final l$video_codec = video_codec;
    final lOther$video_codec = other.video_codec;
    if (l$video_codec != lOther$video_codec) {
      return false;
    }
    final l$audio_codec = audio_codec;
    final lOther$audio_codec = other.audio_codec;
    if (l$audio_codec != lOther$audio_codec) {
      return false;
    }
    final l$bit_rate = bit_rate;
    final lOther$bit_rate = other.bit_rate;
    if (l$bit_rate != lOther$bit_rate) {
      return false;
    }
    final l$frame_rate = frame_rate;
    final lOther$frame_rate = other.frame_rate;
    if (l$frame_rate != lOther$frame_rate) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$SceneData$files
    on Fragment$SceneData$files {
  CopyWith$Fragment$SceneData$files<Fragment$SceneData$files> get copyWith =>
      CopyWith$Fragment$SceneData$files(this, (i) => i);
}

abstract class CopyWith$Fragment$SceneData$files<TRes> {
  factory CopyWith$Fragment$SceneData$files(
    Fragment$SceneData$files instance,
    TRes Function(Fragment$SceneData$files) then,
  ) = _CopyWithImpl$Fragment$SceneData$files;

  factory CopyWith$Fragment$SceneData$files.stub(TRes res) =
      _CopyWithStubImpl$Fragment$SceneData$files;

  TRes call({
    String? path,
    double? duration,
    String? $__typename,
    String? basename,
    String? format,
    int? width,
    int? height,
    String? video_codec,
    String? audio_codec,
    int? bit_rate,
    double? frame_rate,
  });
}

class _CopyWithImpl$Fragment$SceneData$files<TRes>
    implements CopyWith$Fragment$SceneData$files<TRes> {
  _CopyWithImpl$Fragment$SceneData$files(this._instance, this._then);

  final Fragment$SceneData$files _instance;

  final TRes Function(Fragment$SceneData$files) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? path = _undefined,
    Object? duration = _undefined,
    Object? $__typename = _undefined,
    Object? basename = _undefined,
    Object? format = _undefined,
    Object? width = _undefined,
    Object? height = _undefined,
    Object? video_codec = _undefined,
    Object? audio_codec = _undefined,
    Object? bit_rate = _undefined,
    Object? frame_rate = _undefined,
  }) => _then(
    Fragment$SceneData$files(
      path: path == _undefined || path == null
          ? _instance.path
          : (path as String),
      duration: duration == _undefined || duration == null
          ? _instance.duration
          : (duration as double),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
      basename: basename == _undefined || basename == null
          ? _instance.basename
          : (basename as String),
      format: format == _undefined || format == null
          ? _instance.format
          : (format as String),
      width: width == _undefined || width == null
          ? _instance.width
          : (width as int),
      height: height == _undefined || height == null
          ? _instance.height
          : (height as int),
      video_codec: video_codec == _undefined || video_codec == null
          ? _instance.video_codec
          : (video_codec as String),
      audio_codec: audio_codec == _undefined || audio_codec == null
          ? _instance.audio_codec
          : (audio_codec as String),
      bit_rate: bit_rate == _undefined || bit_rate == null
          ? _instance.bit_rate
          : (bit_rate as int),
      frame_rate: frame_rate == _undefined || frame_rate == null
          ? _instance.frame_rate
          : (frame_rate as double),
    ),
  );
}

class _CopyWithStubImpl$Fragment$SceneData$files<TRes>
    implements CopyWith$Fragment$SceneData$files<TRes> {
  _CopyWithStubImpl$Fragment$SceneData$files(this._res);

  TRes _res;

  call({
    String? path,
    double? duration,
    String? $__typename,
    String? basename,
    String? format,
    int? width,
    int? height,
    String? video_codec,
    String? audio_codec,
    int? bit_rate,
    double? frame_rate,
  }) => _res;
}

class Fragment$SceneData$paths implements Fragment$SlimSceneData$paths {
  Fragment$SceneData$paths({
    this.screenshot,
    this.preview,
    this.stream,
    this.$__typename = 'ScenePathsType',
  });

  factory Fragment$SceneData$paths.fromJson(Map<String, dynamic> json) {
    final l$screenshot = json['screenshot'];
    final l$preview = json['preview'];
    final l$stream = json['stream'];
    final l$$__typename = json['__typename'];
    return Fragment$SceneData$paths(
      screenshot: (l$screenshot as String?),
      preview: (l$preview as String?),
      stream: (l$stream as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String? screenshot;

  final String? preview;

  final String? stream;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$screenshot = screenshot;
    _resultData['screenshot'] = l$screenshot;
    final l$preview = preview;
    _resultData['preview'] = l$preview;
    final l$stream = stream;
    _resultData['stream'] = l$stream;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$screenshot = screenshot;
    final l$preview = preview;
    final l$stream = stream;
    final l$$__typename = $__typename;
    return Object.hashAll([l$screenshot, l$preview, l$stream, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$SceneData$paths ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$screenshot = screenshot;
    final lOther$screenshot = other.screenshot;
    if (l$screenshot != lOther$screenshot) {
      return false;
    }
    final l$preview = preview;
    final lOther$preview = other.preview;
    if (l$preview != lOther$preview) {
      return false;
    }
    final l$stream = stream;
    final lOther$stream = other.stream;
    if (l$stream != lOther$stream) {
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

extension UtilityExtension$Fragment$SceneData$paths
    on Fragment$SceneData$paths {
  CopyWith$Fragment$SceneData$paths<Fragment$SceneData$paths> get copyWith =>
      CopyWith$Fragment$SceneData$paths(this, (i) => i);
}

abstract class CopyWith$Fragment$SceneData$paths<TRes> {
  factory CopyWith$Fragment$SceneData$paths(
    Fragment$SceneData$paths instance,
    TRes Function(Fragment$SceneData$paths) then,
  ) = _CopyWithImpl$Fragment$SceneData$paths;

  factory CopyWith$Fragment$SceneData$paths.stub(TRes res) =
      _CopyWithStubImpl$Fragment$SceneData$paths;

  TRes call({
    String? screenshot,
    String? preview,
    String? stream,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$SceneData$paths<TRes>
    implements CopyWith$Fragment$SceneData$paths<TRes> {
  _CopyWithImpl$Fragment$SceneData$paths(this._instance, this._then);

  final Fragment$SceneData$paths _instance;

  final TRes Function(Fragment$SceneData$paths) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? screenshot = _undefined,
    Object? preview = _undefined,
    Object? stream = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Fragment$SceneData$paths(
      screenshot: screenshot == _undefined
          ? _instance.screenshot
          : (screenshot as String?),
      preview: preview == _undefined ? _instance.preview : (preview as String?),
      stream: stream == _undefined ? _instance.stream : (stream as String?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Fragment$SceneData$paths<TRes>
    implements CopyWith$Fragment$SceneData$paths<TRes> {
  _CopyWithStubImpl$Fragment$SceneData$paths(this._res);

  TRes _res;

  call({
    String? screenshot,
    String? preview,
    String? stream,
    String? $__typename,
  }) => _res;
}

class Fragment$SceneData$studio implements Fragment$SlimSceneData$studio {
  Fragment$SceneData$studio({
    required this.id,
    required this.name,
    this.image_path,
    this.$__typename = 'Studio',
  });

  factory Fragment$SceneData$studio.fromJson(Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$name = json['name'];
    final l$image_path = json['image_path'];
    final l$$__typename = json['__typename'];
    return Fragment$SceneData$studio(
      id: (l$id as String),
      name: (l$name as String),
      image_path: (l$image_path as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String id;

  final String name;

  final String? image_path;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$name = name;
    _resultData['name'] = l$name;
    final l$image_path = image_path;
    _resultData['image_path'] = l$image_path;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$name = name;
    final l$image_path = image_path;
    final l$$__typename = $__typename;
    return Object.hashAll([l$id, l$name, l$image_path, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$SceneData$studio ||
        runtimeType != other.runtimeType) {
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
    final l$image_path = image_path;
    final lOther$image_path = other.image_path;
    if (l$image_path != lOther$image_path) {
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

extension UtilityExtension$Fragment$SceneData$studio
    on Fragment$SceneData$studio {
  CopyWith$Fragment$SceneData$studio<Fragment$SceneData$studio> get copyWith =>
      CopyWith$Fragment$SceneData$studio(this, (i) => i);
}

abstract class CopyWith$Fragment$SceneData$studio<TRes> {
  factory CopyWith$Fragment$SceneData$studio(
    Fragment$SceneData$studio instance,
    TRes Function(Fragment$SceneData$studio) then,
  ) = _CopyWithImpl$Fragment$SceneData$studio;

  factory CopyWith$Fragment$SceneData$studio.stub(TRes res) =
      _CopyWithStubImpl$Fragment$SceneData$studio;

  TRes call({
    String? id,
    String? name,
    String? image_path,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$SceneData$studio<TRes>
    implements CopyWith$Fragment$SceneData$studio<TRes> {
  _CopyWithImpl$Fragment$SceneData$studio(this._instance, this._then);

  final Fragment$SceneData$studio _instance;

  final TRes Function(Fragment$SceneData$studio) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? name = _undefined,
    Object? image_path = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Fragment$SceneData$studio(
      id: id == _undefined || id == null ? _instance.id : (id as String),
      name: name == _undefined || name == null
          ? _instance.name
          : (name as String),
      image_path: image_path == _undefined
          ? _instance.image_path
          : (image_path as String?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Fragment$SceneData$studio<TRes>
    implements CopyWith$Fragment$SceneData$studio<TRes> {
  _CopyWithStubImpl$Fragment$SceneData$studio(this._res);

  TRes _res;

  call({String? id, String? name, String? image_path, String? $__typename}) =>
      _res;
}

class Fragment$SceneData$performers
    implements Fragment$SlimSceneData$performers {
  Fragment$SceneData$performers({
    required this.id,
    required this.name,
    this.image_path,
    this.$__typename = 'Performer',
  });

  factory Fragment$SceneData$performers.fromJson(Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$name = json['name'];
    final l$image_path = json['image_path'];
    final l$$__typename = json['__typename'];
    return Fragment$SceneData$performers(
      id: (l$id as String),
      name: (l$name as String),
      image_path: (l$image_path as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String id;

  final String name;

  final String? image_path;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$name = name;
    _resultData['name'] = l$name;
    final l$image_path = image_path;
    _resultData['image_path'] = l$image_path;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$name = name;
    final l$image_path = image_path;
    final l$$__typename = $__typename;
    return Object.hashAll([l$id, l$name, l$image_path, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$SceneData$performers ||
        runtimeType != other.runtimeType) {
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
    final l$image_path = image_path;
    final lOther$image_path = other.image_path;
    if (l$image_path != lOther$image_path) {
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

extension UtilityExtension$Fragment$SceneData$performers
    on Fragment$SceneData$performers {
  CopyWith$Fragment$SceneData$performers<Fragment$SceneData$performers>
  get copyWith => CopyWith$Fragment$SceneData$performers(this, (i) => i);
}

abstract class CopyWith$Fragment$SceneData$performers<TRes> {
  factory CopyWith$Fragment$SceneData$performers(
    Fragment$SceneData$performers instance,
    TRes Function(Fragment$SceneData$performers) then,
  ) = _CopyWithImpl$Fragment$SceneData$performers;

  factory CopyWith$Fragment$SceneData$performers.stub(TRes res) =
      _CopyWithStubImpl$Fragment$SceneData$performers;

  TRes call({
    String? id,
    String? name,
    String? image_path,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$SceneData$performers<TRes>
    implements CopyWith$Fragment$SceneData$performers<TRes> {
  _CopyWithImpl$Fragment$SceneData$performers(this._instance, this._then);

  final Fragment$SceneData$performers _instance;

  final TRes Function(Fragment$SceneData$performers) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? name = _undefined,
    Object? image_path = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Fragment$SceneData$performers(
      id: id == _undefined || id == null ? _instance.id : (id as String),
      name: name == _undefined || name == null
          ? _instance.name
          : (name as String),
      image_path: image_path == _undefined
          ? _instance.image_path
          : (image_path as String?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Fragment$SceneData$performers<TRes>
    implements CopyWith$Fragment$SceneData$performers<TRes> {
  _CopyWithStubImpl$Fragment$SceneData$performers(this._res);

  TRes _res;

  call({String? id, String? name, String? image_path, String? $__typename}) =>
      _res;
}

class Fragment$SceneData$tags {
  Fragment$SceneData$tags({
    required this.id,
    required this.name,
    this.$__typename = 'Tag',
  });

  factory Fragment$SceneData$tags.fromJson(Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$name = json['name'];
    final l$$__typename = json['__typename'];
    return Fragment$SceneData$tags(
      id: (l$id as String),
      name: (l$name as String),
      $__typename: (l$$__typename as String),
    );
  }

  final String id;

  final String name;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$name = name;
    _resultData['name'] = l$name;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$name = name;
    final l$$__typename = $__typename;
    return Object.hashAll([l$id, l$name, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$SceneData$tags || runtimeType != other.runtimeType) {
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
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$SceneData$tags on Fragment$SceneData$tags {
  CopyWith$Fragment$SceneData$tags<Fragment$SceneData$tags> get copyWith =>
      CopyWith$Fragment$SceneData$tags(this, (i) => i);
}

abstract class CopyWith$Fragment$SceneData$tags<TRes> {
  factory CopyWith$Fragment$SceneData$tags(
    Fragment$SceneData$tags instance,
    TRes Function(Fragment$SceneData$tags) then,
  ) = _CopyWithImpl$Fragment$SceneData$tags;

  factory CopyWith$Fragment$SceneData$tags.stub(TRes res) =
      _CopyWithStubImpl$Fragment$SceneData$tags;

  TRes call({String? id, String? name, String? $__typename});
}

class _CopyWithImpl$Fragment$SceneData$tags<TRes>
    implements CopyWith$Fragment$SceneData$tags<TRes> {
  _CopyWithImpl$Fragment$SceneData$tags(this._instance, this._then);

  final Fragment$SceneData$tags _instance;

  final TRes Function(Fragment$SceneData$tags) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? name = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Fragment$SceneData$tags(
      id: id == _undefined || id == null ? _instance.id : (id as String),
      name: name == _undefined || name == null
          ? _instance.name
          : (name as String),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Fragment$SceneData$tags<TRes>
    implements CopyWith$Fragment$SceneData$tags<TRes> {
  _CopyWithStubImpl$Fragment$SceneData$tags(this._res);

  TRes _res;

  call({String? id, String? name, String? $__typename}) => _res;
}

class Variables$Query$FindScenes {
  factory Variables$Query$FindScenes({
    Input$FindFilterType? filter,
    Input$SceneFilterType? scene_filter,
  }) => Variables$Query$FindScenes._({
    if (filter != null) r'filter': filter,
    if (scene_filter != null) r'scene_filter': scene_filter,
  });

  Variables$Query$FindScenes._(this._$data);

  factory Variables$Query$FindScenes.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('filter')) {
      final l$filter = data['filter'];
      result$data['filter'] = l$filter == null
          ? null
          : Input$FindFilterType.fromJson((l$filter as Map<String, dynamic>));
    }
    if (data.containsKey('scene_filter')) {
      final l$scene_filter = data['scene_filter'];
      result$data['scene_filter'] = l$scene_filter == null
          ? null
          : Input$SceneFilterType.fromJson(
              (l$scene_filter as Map<String, dynamic>),
            );
    }
    return Variables$Query$FindScenes._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$FindFilterType? get filter =>
      (_$data['filter'] as Input$FindFilterType?);

  Input$SceneFilterType? get scene_filter =>
      (_$data['scene_filter'] as Input$SceneFilterType?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('filter')) {
      final l$filter = filter;
      result$data['filter'] = l$filter?.toJson();
    }
    if (_$data.containsKey('scene_filter')) {
      final l$scene_filter = scene_filter;
      result$data['scene_filter'] = l$scene_filter?.toJson();
    }
    return result$data;
  }

  CopyWith$Variables$Query$FindScenes<Variables$Query$FindScenes>
  get copyWith => CopyWith$Variables$Query$FindScenes(this, (i) => i);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$FindScenes ||
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
    final l$scene_filter = scene_filter;
    final lOther$scene_filter = other.scene_filter;
    if (_$data.containsKey('scene_filter') !=
        other._$data.containsKey('scene_filter')) {
      return false;
    }
    if (l$scene_filter != lOther$scene_filter) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$filter = filter;
    final l$scene_filter = scene_filter;
    return Object.hashAll([
      _$data.containsKey('filter') ? l$filter : const {},
      _$data.containsKey('scene_filter') ? l$scene_filter : const {},
    ]);
  }
}

abstract class CopyWith$Variables$Query$FindScenes<TRes> {
  factory CopyWith$Variables$Query$FindScenes(
    Variables$Query$FindScenes instance,
    TRes Function(Variables$Query$FindScenes) then,
  ) = _CopyWithImpl$Variables$Query$FindScenes;

  factory CopyWith$Variables$Query$FindScenes.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$FindScenes;

  TRes call({
    Input$FindFilterType? filter,
    Input$SceneFilterType? scene_filter,
  });
}

class _CopyWithImpl$Variables$Query$FindScenes<TRes>
    implements CopyWith$Variables$Query$FindScenes<TRes> {
  _CopyWithImpl$Variables$Query$FindScenes(this._instance, this._then);

  final Variables$Query$FindScenes _instance;

  final TRes Function(Variables$Query$FindScenes) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? filter = _undefined, Object? scene_filter = _undefined}) =>
      _then(
        Variables$Query$FindScenes._({
          ..._instance._$data,
          if (filter != _undefined) 'filter': (filter as Input$FindFilterType?),
          if (scene_filter != _undefined)
            'scene_filter': (scene_filter as Input$SceneFilterType?),
        }),
      );
}

class _CopyWithStubImpl$Variables$Query$FindScenes<TRes>
    implements CopyWith$Variables$Query$FindScenes<TRes> {
  _CopyWithStubImpl$Variables$Query$FindScenes(this._res);

  TRes _res;

  call({Input$FindFilterType? filter, Input$SceneFilterType? scene_filter}) =>
      _res;
}

class Query$FindScenes {
  Query$FindScenes({required this.findScenes, this.$__typename = 'Query'});

  factory Query$FindScenes.fromJson(Map<String, dynamic> json) {
    final l$findScenes = json['findScenes'];
    final l$$__typename = json['__typename'];
    return Query$FindScenes(
      findScenes: Query$FindScenes$findScenes.fromJson(
        (l$findScenes as Map<String, dynamic>),
      ),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$FindScenes$findScenes findScenes;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$findScenes = findScenes;
    _resultData['findScenes'] = l$findScenes.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$findScenes = findScenes;
    final l$$__typename = $__typename;
    return Object.hashAll([l$findScenes, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$FindScenes || runtimeType != other.runtimeType) {
      return false;
    }
    final l$findScenes = findScenes;
    final lOther$findScenes = other.findScenes;
    if (l$findScenes != lOther$findScenes) {
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

extension UtilityExtension$Query$FindScenes on Query$FindScenes {
  CopyWith$Query$FindScenes<Query$FindScenes> get copyWith =>
      CopyWith$Query$FindScenes(this, (i) => i);
}

abstract class CopyWith$Query$FindScenes<TRes> {
  factory CopyWith$Query$FindScenes(
    Query$FindScenes instance,
    TRes Function(Query$FindScenes) then,
  ) = _CopyWithImpl$Query$FindScenes;

  factory CopyWith$Query$FindScenes.stub(TRes res) =
      _CopyWithStubImpl$Query$FindScenes;

  TRes call({Query$FindScenes$findScenes? findScenes, String? $__typename});
  CopyWith$Query$FindScenes$findScenes<TRes> get findScenes;
}

class _CopyWithImpl$Query$FindScenes<TRes>
    implements CopyWith$Query$FindScenes<TRes> {
  _CopyWithImpl$Query$FindScenes(this._instance, this._then);

  final Query$FindScenes _instance;

  final TRes Function(Query$FindScenes) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? findScenes = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$FindScenes(
      findScenes: findScenes == _undefined || findScenes == null
          ? _instance.findScenes
          : (findScenes as Query$FindScenes$findScenes),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  CopyWith$Query$FindScenes$findScenes<TRes> get findScenes {
    final local$findScenes = _instance.findScenes;
    return CopyWith$Query$FindScenes$findScenes(
      local$findScenes,
      (e) => call(findScenes: e),
    );
  }
}

class _CopyWithStubImpl$Query$FindScenes<TRes>
    implements CopyWith$Query$FindScenes<TRes> {
  _CopyWithStubImpl$Query$FindScenes(this._res);

  TRes _res;

  call({Query$FindScenes$findScenes? findScenes, String? $__typename}) => _res;

  CopyWith$Query$FindScenes$findScenes<TRes> get findScenes =>
      CopyWith$Query$FindScenes$findScenes.stub(_res);
}

const documentNodeQueryFindScenes = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.query,
      name: NameNode(value: 'FindScenes'),
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
          variable: VariableNode(name: NameNode(value: 'scene_filter')),
          type: NamedTypeNode(
            name: NameNode(value: 'SceneFilterType'),
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
            name: NameNode(value: 'findScenes'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'filter'),
                value: VariableNode(name: NameNode(value: 'filter')),
              ),
              ArgumentNode(
                name: NameNode(value: 'scene_filter'),
                value: VariableNode(name: NameNode(value: 'scene_filter')),
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
                  name: NameNode(value: 'scenes'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: SelectionSetNode(
                    selections: [
                      FragmentSpreadNode(
                        name: NameNode(value: 'SlimSceneData'),
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
    fragmentDefinitionSlimSceneData,
  ],
);
Query$FindScenes _parserFn$Query$FindScenes(Map<String, dynamic> data) =>
    Query$FindScenes.fromJson(data);
typedef OnQueryComplete$Query$FindScenes =
    FutureOr<void> Function(Map<String, dynamic>?, Query$FindScenes?);

class Options$Query$FindScenes extends graphql.QueryOptions<Query$FindScenes> {
  Options$Query$FindScenes({
    String? operationName,
    Variables$Query$FindScenes? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$FindScenes? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$FindScenes? onComplete,
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
                 data == null ? null : _parserFn$Query$FindScenes(data),
               ),
         onError: onError,
         document: documentNodeQueryFindScenes,
         parserFn: _parserFn$Query$FindScenes,
       );

  final OnQueryComplete$Query$FindScenes? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
    ...super.onComplete == null
        ? super.properties
        : super.properties.where((property) => property != onComplete),
    onCompleteWithParsed,
  ];
}

class WatchOptions$Query$FindScenes
    extends graphql.WatchQueryOptions<Query$FindScenes> {
  WatchOptions$Query$FindScenes({
    String? operationName,
    Variables$Query$FindScenes? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$FindScenes? typedOptimisticResult,
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
         document: documentNodeQueryFindScenes,
         pollInterval: pollInterval,
         eagerlyFetchResults: eagerlyFetchResults,
         carryForwardDataOnException: carryForwardDataOnException,
         fetchResults: fetchResults,
         parserFn: _parserFn$Query$FindScenes,
       );
}

class FetchMoreOptions$Query$FindScenes extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$FindScenes({
    required graphql.UpdateQuery updateQuery,
    Variables$Query$FindScenes? variables,
  }) : super(
         updateQuery: updateQuery,
         variables: variables?.toJson() ?? {},
         document: documentNodeQueryFindScenes,
       );
}

extension ClientExtension$Query$FindScenes on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$FindScenes>> query$FindScenes([
    Options$Query$FindScenes? options,
  ]) async => await this.query(options ?? Options$Query$FindScenes());

  graphql.ObservableQuery<Query$FindScenes> watchQuery$FindScenes([
    WatchOptions$Query$FindScenes? options,
  ]) => this.watchQuery(options ?? WatchOptions$Query$FindScenes());

  void writeQuery$FindScenes({
    required Query$FindScenes data,
    Variables$Query$FindScenes? variables,
    bool broadcast = true,
  }) => this.writeQuery(
    graphql.Request(
      operation: graphql.Operation(document: documentNodeQueryFindScenes),
      variables: variables?.toJson() ?? const {},
    ),
    data: data.toJson(),
    broadcast: broadcast,
  );

  Query$FindScenes? readQuery$FindScenes({
    Variables$Query$FindScenes? variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(document: documentNodeQueryFindScenes),
        variables: variables?.toJson() ?? const {},
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$FindScenes.fromJson(result);
  }
}

class Query$FindScenes$findScenes {
  Query$FindScenes$findScenes({
    required this.count,
    required this.scenes,
    this.$__typename = 'FindScenesResultType',
  });

  factory Query$FindScenes$findScenes.fromJson(Map<String, dynamic> json) {
    final l$count = json['count'];
    final l$scenes = json['scenes'];
    final l$$__typename = json['__typename'];
    return Query$FindScenes$findScenes(
      count: (l$count as int),
      scenes: (l$scenes as List<dynamic>)
          .map(
            (e) => Fragment$SlimSceneData.fromJson((e as Map<String, dynamic>)),
          )
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final int count;

  final List<Fragment$SlimSceneData> scenes;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$count = count;
    _resultData['count'] = l$count;
    final l$scenes = scenes;
    _resultData['scenes'] = l$scenes.map((e) => e.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$count = count;
    final l$scenes = scenes;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$count,
      Object.hashAll(l$scenes.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$FindScenes$findScenes ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$count = count;
    final lOther$count = other.count;
    if (l$count != lOther$count) {
      return false;
    }
    final l$scenes = scenes;
    final lOther$scenes = other.scenes;
    if (l$scenes.length != lOther$scenes.length) {
      return false;
    }
    for (int i = 0; i < l$scenes.length; i++) {
      final l$scenes$entry = l$scenes[i];
      final lOther$scenes$entry = lOther$scenes[i];
      if (l$scenes$entry != lOther$scenes$entry) {
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

extension UtilityExtension$Query$FindScenes$findScenes
    on Query$FindScenes$findScenes {
  CopyWith$Query$FindScenes$findScenes<Query$FindScenes$findScenes>
  get copyWith => CopyWith$Query$FindScenes$findScenes(this, (i) => i);
}

abstract class CopyWith$Query$FindScenes$findScenes<TRes> {
  factory CopyWith$Query$FindScenes$findScenes(
    Query$FindScenes$findScenes instance,
    TRes Function(Query$FindScenes$findScenes) then,
  ) = _CopyWithImpl$Query$FindScenes$findScenes;

  factory CopyWith$Query$FindScenes$findScenes.stub(TRes res) =
      _CopyWithStubImpl$Query$FindScenes$findScenes;

  TRes call({
    int? count,
    List<Fragment$SlimSceneData>? scenes,
    String? $__typename,
  });
  TRes scenes(
    Iterable<Fragment$SlimSceneData> Function(
      Iterable<CopyWith$Fragment$SlimSceneData<Fragment$SlimSceneData>>,
    )
    _fn,
  );
}

class _CopyWithImpl$Query$FindScenes$findScenes<TRes>
    implements CopyWith$Query$FindScenes$findScenes<TRes> {
  _CopyWithImpl$Query$FindScenes$findScenes(this._instance, this._then);

  final Query$FindScenes$findScenes _instance;

  final TRes Function(Query$FindScenes$findScenes) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? count = _undefined,
    Object? scenes = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$FindScenes$findScenes(
      count: count == _undefined || count == null
          ? _instance.count
          : (count as int),
      scenes: scenes == _undefined || scenes == null
          ? _instance.scenes
          : (scenes as List<Fragment$SlimSceneData>),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  TRes scenes(
    Iterable<Fragment$SlimSceneData> Function(
      Iterable<CopyWith$Fragment$SlimSceneData<Fragment$SlimSceneData>>,
    )
    _fn,
  ) => call(
    scenes: _fn(
      _instance.scenes.map((e) => CopyWith$Fragment$SlimSceneData(e, (i) => i)),
    ).toList(),
  );
}

class _CopyWithStubImpl$Query$FindScenes$findScenes<TRes>
    implements CopyWith$Query$FindScenes$findScenes<TRes> {
  _CopyWithStubImpl$Query$FindScenes$findScenes(this._res);

  TRes _res;

  call({
    int? count,
    List<Fragment$SlimSceneData>? scenes,
    String? $__typename,
  }) => _res;

  scenes(_fn) => _res;
}

class Variables$Query$FindScene {
  factory Variables$Query$FindScene({required String id}) =>
      Variables$Query$FindScene._({r'id': id});

  Variables$Query$FindScene._(this._$data);

  factory Variables$Query$FindScene.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$id = data['id'];
    result$data['id'] = (l$id as String);
    return Variables$Query$FindScene._(result$data);
  }

  Map<String, dynamic> _$data;

  String get id => (_$data['id'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$id = id;
    result$data['id'] = l$id;
    return result$data;
  }

  CopyWith$Variables$Query$FindScene<Variables$Query$FindScene> get copyWith =>
      CopyWith$Variables$Query$FindScene(this, (i) => i);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$FindScene ||
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

abstract class CopyWith$Variables$Query$FindScene<TRes> {
  factory CopyWith$Variables$Query$FindScene(
    Variables$Query$FindScene instance,
    TRes Function(Variables$Query$FindScene) then,
  ) = _CopyWithImpl$Variables$Query$FindScene;

  factory CopyWith$Variables$Query$FindScene.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$FindScene;

  TRes call({String? id});
}

class _CopyWithImpl$Variables$Query$FindScene<TRes>
    implements CopyWith$Variables$Query$FindScene<TRes> {
  _CopyWithImpl$Variables$Query$FindScene(this._instance, this._then);

  final Variables$Query$FindScene _instance;

  final TRes Function(Variables$Query$FindScene) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? id = _undefined}) => _then(
    Variables$Query$FindScene._({
      ..._instance._$data,
      if (id != _undefined && id != null) 'id': (id as String),
    }),
  );
}

class _CopyWithStubImpl$Variables$Query$FindScene<TRes>
    implements CopyWith$Variables$Query$FindScene<TRes> {
  _CopyWithStubImpl$Variables$Query$FindScene(this._res);

  TRes _res;

  call({String? id}) => _res;
}

class Query$FindScene {
  Query$FindScene({this.findScene, this.$__typename = 'Query'});

  factory Query$FindScene.fromJson(Map<String, dynamic> json) {
    final l$findScene = json['findScene'];
    final l$$__typename = json['__typename'];
    return Query$FindScene(
      findScene: l$findScene == null
          ? null
          : Fragment$SceneData.fromJson((l$findScene as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Fragment$SceneData? findScene;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$findScene = findScene;
    _resultData['findScene'] = l$findScene?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$findScene = findScene;
    final l$$__typename = $__typename;
    return Object.hashAll([l$findScene, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$FindScene || runtimeType != other.runtimeType) {
      return false;
    }
    final l$findScene = findScene;
    final lOther$findScene = other.findScene;
    if (l$findScene != lOther$findScene) {
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

extension UtilityExtension$Query$FindScene on Query$FindScene {
  CopyWith$Query$FindScene<Query$FindScene> get copyWith =>
      CopyWith$Query$FindScene(this, (i) => i);
}

abstract class CopyWith$Query$FindScene<TRes> {
  factory CopyWith$Query$FindScene(
    Query$FindScene instance,
    TRes Function(Query$FindScene) then,
  ) = _CopyWithImpl$Query$FindScene;

  factory CopyWith$Query$FindScene.stub(TRes res) =
      _CopyWithStubImpl$Query$FindScene;

  TRes call({Fragment$SceneData? findScene, String? $__typename});
  CopyWith$Fragment$SceneData<TRes> get findScene;
}

class _CopyWithImpl$Query$FindScene<TRes>
    implements CopyWith$Query$FindScene<TRes> {
  _CopyWithImpl$Query$FindScene(this._instance, this._then);

  final Query$FindScene _instance;

  final TRes Function(Query$FindScene) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? findScene = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$FindScene(
      findScene: findScene == _undefined
          ? _instance.findScene
          : (findScene as Fragment$SceneData?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  CopyWith$Fragment$SceneData<TRes> get findScene {
    final local$findScene = _instance.findScene;
    return local$findScene == null
        ? CopyWith$Fragment$SceneData.stub(_then(_instance))
        : CopyWith$Fragment$SceneData(
            local$findScene,
            (e) => call(findScene: e),
          );
  }
}

class _CopyWithStubImpl$Query$FindScene<TRes>
    implements CopyWith$Query$FindScene<TRes> {
  _CopyWithStubImpl$Query$FindScene(this._res);

  TRes _res;

  call({Fragment$SceneData? findScene, String? $__typename}) => _res;

  CopyWith$Fragment$SceneData<TRes> get findScene =>
      CopyWith$Fragment$SceneData.stub(_res);
}

const documentNodeQueryFindScene = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.query,
      name: NameNode(value: 'FindScene'),
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
            name: NameNode(value: 'findScene'),
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
                  name: NameNode(value: 'SceneData'),
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
    fragmentDefinitionSceneData,
    fragmentDefinitionSlimSceneData,
  ],
);
Query$FindScene _parserFn$Query$FindScene(Map<String, dynamic> data) =>
    Query$FindScene.fromJson(data);
typedef OnQueryComplete$Query$FindScene =
    FutureOr<void> Function(Map<String, dynamic>?, Query$FindScene?);

class Options$Query$FindScene extends graphql.QueryOptions<Query$FindScene> {
  Options$Query$FindScene({
    String? operationName,
    required Variables$Query$FindScene variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$FindScene? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$FindScene? onComplete,
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
                 data == null ? null : _parserFn$Query$FindScene(data),
               ),
         onError: onError,
         document: documentNodeQueryFindScene,
         parserFn: _parserFn$Query$FindScene,
       );

  final OnQueryComplete$Query$FindScene? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
    ...super.onComplete == null
        ? super.properties
        : super.properties.where((property) => property != onComplete),
    onCompleteWithParsed,
  ];
}

class WatchOptions$Query$FindScene
    extends graphql.WatchQueryOptions<Query$FindScene> {
  WatchOptions$Query$FindScene({
    String? operationName,
    required Variables$Query$FindScene variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$FindScene? typedOptimisticResult,
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
         document: documentNodeQueryFindScene,
         pollInterval: pollInterval,
         eagerlyFetchResults: eagerlyFetchResults,
         carryForwardDataOnException: carryForwardDataOnException,
         fetchResults: fetchResults,
         parserFn: _parserFn$Query$FindScene,
       );
}

class FetchMoreOptions$Query$FindScene extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$FindScene({
    required graphql.UpdateQuery updateQuery,
    required Variables$Query$FindScene variables,
  }) : super(
         updateQuery: updateQuery,
         variables: variables.toJson(),
         document: documentNodeQueryFindScene,
       );
}

extension ClientExtension$Query$FindScene on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$FindScene>> query$FindScene(
    Options$Query$FindScene options,
  ) async => await this.query(options);

  graphql.ObservableQuery<Query$FindScene> watchQuery$FindScene(
    WatchOptions$Query$FindScene options,
  ) => this.watchQuery(options);

  void writeQuery$FindScene({
    required Query$FindScene data,
    required Variables$Query$FindScene variables,
    bool broadcast = true,
  }) => this.writeQuery(
    graphql.Request(
      operation: graphql.Operation(document: documentNodeQueryFindScene),
      variables: variables.toJson(),
    ),
    data: data.toJson(),
    broadcast: broadcast,
  );

  Query$FindScene? readQuery$FindScene({
    required Variables$Query$FindScene variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(document: documentNodeQueryFindScene),
        variables: variables.toJson(),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$FindScene.fromJson(result);
  }
}

class Variables$Query$SceneStreams {
  factory Variables$Query$SceneStreams({required String id}) =>
      Variables$Query$SceneStreams._({r'id': id});

  Variables$Query$SceneStreams._(this._$data);

  factory Variables$Query$SceneStreams.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$id = data['id'];
    result$data['id'] = (l$id as String);
    return Variables$Query$SceneStreams._(result$data);
  }

  Map<String, dynamic> _$data;

  String get id => (_$data['id'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$id = id;
    result$data['id'] = l$id;
    return result$data;
  }

  CopyWith$Variables$Query$SceneStreams<Variables$Query$SceneStreams>
  get copyWith => CopyWith$Variables$Query$SceneStreams(this, (i) => i);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$SceneStreams ||
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

abstract class CopyWith$Variables$Query$SceneStreams<TRes> {
  factory CopyWith$Variables$Query$SceneStreams(
    Variables$Query$SceneStreams instance,
    TRes Function(Variables$Query$SceneStreams) then,
  ) = _CopyWithImpl$Variables$Query$SceneStreams;

  factory CopyWith$Variables$Query$SceneStreams.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$SceneStreams;

  TRes call({String? id});
}

class _CopyWithImpl$Variables$Query$SceneStreams<TRes>
    implements CopyWith$Variables$Query$SceneStreams<TRes> {
  _CopyWithImpl$Variables$Query$SceneStreams(this._instance, this._then);

  final Variables$Query$SceneStreams _instance;

  final TRes Function(Variables$Query$SceneStreams) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? id = _undefined}) => _then(
    Variables$Query$SceneStreams._({
      ..._instance._$data,
      if (id != _undefined && id != null) 'id': (id as String),
    }),
  );
}

class _CopyWithStubImpl$Variables$Query$SceneStreams<TRes>
    implements CopyWith$Variables$Query$SceneStreams<TRes> {
  _CopyWithStubImpl$Variables$Query$SceneStreams(this._res);

  TRes _res;

  call({String? id}) => _res;
}

class Query$SceneStreams {
  Query$SceneStreams({this.findScene, this.$__typename = 'Query'});

  factory Query$SceneStreams.fromJson(Map<String, dynamic> json) {
    final l$findScene = json['findScene'];
    final l$$__typename = json['__typename'];
    return Query$SceneStreams(
      findScene: l$findScene == null
          ? null
          : Query$SceneStreams$findScene.fromJson(
              (l$findScene as Map<String, dynamic>),
            ),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$SceneStreams$findScene? findScene;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$findScene = findScene;
    _resultData['findScene'] = l$findScene?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$findScene = findScene;
    final l$$__typename = $__typename;
    return Object.hashAll([l$findScene, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$SceneStreams || runtimeType != other.runtimeType) {
      return false;
    }
    final l$findScene = findScene;
    final lOther$findScene = other.findScene;
    if (l$findScene != lOther$findScene) {
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

extension UtilityExtension$Query$SceneStreams on Query$SceneStreams {
  CopyWith$Query$SceneStreams<Query$SceneStreams> get copyWith =>
      CopyWith$Query$SceneStreams(this, (i) => i);
}

abstract class CopyWith$Query$SceneStreams<TRes> {
  factory CopyWith$Query$SceneStreams(
    Query$SceneStreams instance,
    TRes Function(Query$SceneStreams) then,
  ) = _CopyWithImpl$Query$SceneStreams;

  factory CopyWith$Query$SceneStreams.stub(TRes res) =
      _CopyWithStubImpl$Query$SceneStreams;

  TRes call({Query$SceneStreams$findScene? findScene, String? $__typename});
  CopyWith$Query$SceneStreams$findScene<TRes> get findScene;
}

class _CopyWithImpl$Query$SceneStreams<TRes>
    implements CopyWith$Query$SceneStreams<TRes> {
  _CopyWithImpl$Query$SceneStreams(this._instance, this._then);

  final Query$SceneStreams _instance;

  final TRes Function(Query$SceneStreams) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? findScene = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$SceneStreams(
      findScene: findScene == _undefined
          ? _instance.findScene
          : (findScene as Query$SceneStreams$findScene?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  CopyWith$Query$SceneStreams$findScene<TRes> get findScene {
    final local$findScene = _instance.findScene;
    return local$findScene == null
        ? CopyWith$Query$SceneStreams$findScene.stub(_then(_instance))
        : CopyWith$Query$SceneStreams$findScene(
            local$findScene,
            (e) => call(findScene: e),
          );
  }
}

class _CopyWithStubImpl$Query$SceneStreams<TRes>
    implements CopyWith$Query$SceneStreams<TRes> {
  _CopyWithStubImpl$Query$SceneStreams(this._res);

  TRes _res;

  call({Query$SceneStreams$findScene? findScene, String? $__typename}) => _res;

  CopyWith$Query$SceneStreams$findScene<TRes> get findScene =>
      CopyWith$Query$SceneStreams$findScene.stub(_res);
}

const documentNodeQuerySceneStreams = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.query,
      name: NameNode(value: 'SceneStreams'),
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
            name: NameNode(value: 'findScene'),
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
                FieldNode(
                  name: NameNode(value: 'sceneStreams'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: SelectionSetNode(
                    selections: [
                      FieldNode(
                        name: NameNode(value: 'url'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                      FieldNode(
                        name: NameNode(value: 'mime_type'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                      FieldNode(
                        name: NameNode(value: 'label'),
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
  ],
);
Query$SceneStreams _parserFn$Query$SceneStreams(Map<String, dynamic> data) =>
    Query$SceneStreams.fromJson(data);
typedef OnQueryComplete$Query$SceneStreams =
    FutureOr<void> Function(Map<String, dynamic>?, Query$SceneStreams?);

class Options$Query$SceneStreams
    extends graphql.QueryOptions<Query$SceneStreams> {
  Options$Query$SceneStreams({
    String? operationName,
    required Variables$Query$SceneStreams variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$SceneStreams? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$SceneStreams? onComplete,
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
                 data == null ? null : _parserFn$Query$SceneStreams(data),
               ),
         onError: onError,
         document: documentNodeQuerySceneStreams,
         parserFn: _parserFn$Query$SceneStreams,
       );

  final OnQueryComplete$Query$SceneStreams? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
    ...super.onComplete == null
        ? super.properties
        : super.properties.where((property) => property != onComplete),
    onCompleteWithParsed,
  ];
}

class WatchOptions$Query$SceneStreams
    extends graphql.WatchQueryOptions<Query$SceneStreams> {
  WatchOptions$Query$SceneStreams({
    String? operationName,
    required Variables$Query$SceneStreams variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$SceneStreams? typedOptimisticResult,
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
         document: documentNodeQuerySceneStreams,
         pollInterval: pollInterval,
         eagerlyFetchResults: eagerlyFetchResults,
         carryForwardDataOnException: carryForwardDataOnException,
         fetchResults: fetchResults,
         parserFn: _parserFn$Query$SceneStreams,
       );
}

class FetchMoreOptions$Query$SceneStreams extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$SceneStreams({
    required graphql.UpdateQuery updateQuery,
    required Variables$Query$SceneStreams variables,
  }) : super(
         updateQuery: updateQuery,
         variables: variables.toJson(),
         document: documentNodeQuerySceneStreams,
       );
}

extension ClientExtension$Query$SceneStreams on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$SceneStreams>> query$SceneStreams(
    Options$Query$SceneStreams options,
  ) async => await this.query(options);

  graphql.ObservableQuery<Query$SceneStreams> watchQuery$SceneStreams(
    WatchOptions$Query$SceneStreams options,
  ) => this.watchQuery(options);

  void writeQuery$SceneStreams({
    required Query$SceneStreams data,
    required Variables$Query$SceneStreams variables,
    bool broadcast = true,
  }) => this.writeQuery(
    graphql.Request(
      operation: graphql.Operation(document: documentNodeQuerySceneStreams),
      variables: variables.toJson(),
    ),
    data: data.toJson(),
    broadcast: broadcast,
  );

  Query$SceneStreams? readQuery$SceneStreams({
    required Variables$Query$SceneStreams variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(document: documentNodeQuerySceneStreams),
        variables: variables.toJson(),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$SceneStreams.fromJson(result);
  }
}

class Query$SceneStreams$findScene {
  Query$SceneStreams$findScene({
    required this.sceneStreams,
    this.$__typename = 'Scene',
  });

  factory Query$SceneStreams$findScene.fromJson(Map<String, dynamic> json) {
    final l$sceneStreams = json['sceneStreams'];
    final l$$__typename = json['__typename'];
    return Query$SceneStreams$findScene(
      sceneStreams: (l$sceneStreams as List<dynamic>)
          .map(
            (e) => Query$SceneStreams$findScene$sceneStreams.fromJson(
              (e as Map<String, dynamic>),
            ),
          )
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Query$SceneStreams$findScene$sceneStreams> sceneStreams;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$sceneStreams = sceneStreams;
    _resultData['sceneStreams'] = l$sceneStreams
        .map((e) => e.toJson())
        .toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$sceneStreams = sceneStreams;
    final l$$__typename = $__typename;
    return Object.hashAll([
      Object.hashAll(l$sceneStreams.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$SceneStreams$findScene ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$sceneStreams = sceneStreams;
    final lOther$sceneStreams = other.sceneStreams;
    if (l$sceneStreams.length != lOther$sceneStreams.length) {
      return false;
    }
    for (int i = 0; i < l$sceneStreams.length; i++) {
      final l$sceneStreams$entry = l$sceneStreams[i];
      final lOther$sceneStreams$entry = lOther$sceneStreams[i];
      if (l$sceneStreams$entry != lOther$sceneStreams$entry) {
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

extension UtilityExtension$Query$SceneStreams$findScene
    on Query$SceneStreams$findScene {
  CopyWith$Query$SceneStreams$findScene<Query$SceneStreams$findScene>
  get copyWith => CopyWith$Query$SceneStreams$findScene(this, (i) => i);
}

abstract class CopyWith$Query$SceneStreams$findScene<TRes> {
  factory CopyWith$Query$SceneStreams$findScene(
    Query$SceneStreams$findScene instance,
    TRes Function(Query$SceneStreams$findScene) then,
  ) = _CopyWithImpl$Query$SceneStreams$findScene;

  factory CopyWith$Query$SceneStreams$findScene.stub(TRes res) =
      _CopyWithStubImpl$Query$SceneStreams$findScene;

  TRes call({
    List<Query$SceneStreams$findScene$sceneStreams>? sceneStreams,
    String? $__typename,
  });
  TRes sceneStreams(
    Iterable<Query$SceneStreams$findScene$sceneStreams> Function(
      Iterable<
        CopyWith$Query$SceneStreams$findScene$sceneStreams<
          Query$SceneStreams$findScene$sceneStreams
        >
      >,
    )
    _fn,
  );
}

class _CopyWithImpl$Query$SceneStreams$findScene<TRes>
    implements CopyWith$Query$SceneStreams$findScene<TRes> {
  _CopyWithImpl$Query$SceneStreams$findScene(this._instance, this._then);

  final Query$SceneStreams$findScene _instance;

  final TRes Function(Query$SceneStreams$findScene) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? sceneStreams = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$SceneStreams$findScene(
      sceneStreams: sceneStreams == _undefined || sceneStreams == null
          ? _instance.sceneStreams
          : (sceneStreams as List<Query$SceneStreams$findScene$sceneStreams>),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  TRes sceneStreams(
    Iterable<Query$SceneStreams$findScene$sceneStreams> Function(
      Iterable<
        CopyWith$Query$SceneStreams$findScene$sceneStreams<
          Query$SceneStreams$findScene$sceneStreams
        >
      >,
    )
    _fn,
  ) => call(
    sceneStreams: _fn(
      _instance.sceneStreams.map(
        (e) => CopyWith$Query$SceneStreams$findScene$sceneStreams(e, (i) => i),
      ),
    ).toList(),
  );
}

class _CopyWithStubImpl$Query$SceneStreams$findScene<TRes>
    implements CopyWith$Query$SceneStreams$findScene<TRes> {
  _CopyWithStubImpl$Query$SceneStreams$findScene(this._res);

  TRes _res;

  call({
    List<Query$SceneStreams$findScene$sceneStreams>? sceneStreams,
    String? $__typename,
  }) => _res;

  sceneStreams(_fn) => _res;
}

class Query$SceneStreams$findScene$sceneStreams {
  Query$SceneStreams$findScene$sceneStreams({
    required this.url,
    this.mime_type,
    this.label,
    this.$__typename = 'SceneStreamEndpoint',
  });

  factory Query$SceneStreams$findScene$sceneStreams.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$url = json['url'];
    final l$mime_type = json['mime_type'];
    final l$label = json['label'];
    final l$$__typename = json['__typename'];
    return Query$SceneStreams$findScene$sceneStreams(
      url: (l$url as String),
      mime_type: (l$mime_type as String?),
      label: (l$label as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String url;

  final String? mime_type;

  final String? label;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$url = url;
    _resultData['url'] = l$url;
    final l$mime_type = mime_type;
    _resultData['mime_type'] = l$mime_type;
    final l$label = label;
    _resultData['label'] = l$label;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$url = url;
    final l$mime_type = mime_type;
    final l$label = label;
    final l$$__typename = $__typename;
    return Object.hashAll([l$url, l$mime_type, l$label, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$SceneStreams$findScene$sceneStreams ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$url = url;
    final lOther$url = other.url;
    if (l$url != lOther$url) {
      return false;
    }
    final l$mime_type = mime_type;
    final lOther$mime_type = other.mime_type;
    if (l$mime_type != lOther$mime_type) {
      return false;
    }
    final l$label = label;
    final lOther$label = other.label;
    if (l$label != lOther$label) {
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

extension UtilityExtension$Query$SceneStreams$findScene$sceneStreams
    on Query$SceneStreams$findScene$sceneStreams {
  CopyWith$Query$SceneStreams$findScene$sceneStreams<
    Query$SceneStreams$findScene$sceneStreams
  >
  get copyWith =>
      CopyWith$Query$SceneStreams$findScene$sceneStreams(this, (i) => i);
}

abstract class CopyWith$Query$SceneStreams$findScene$sceneStreams<TRes> {
  factory CopyWith$Query$SceneStreams$findScene$sceneStreams(
    Query$SceneStreams$findScene$sceneStreams instance,
    TRes Function(Query$SceneStreams$findScene$sceneStreams) then,
  ) = _CopyWithImpl$Query$SceneStreams$findScene$sceneStreams;

  factory CopyWith$Query$SceneStreams$findScene$sceneStreams.stub(TRes res) =
      _CopyWithStubImpl$Query$SceneStreams$findScene$sceneStreams;

  TRes call({
    String? url,
    String? mime_type,
    String? label,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$SceneStreams$findScene$sceneStreams<TRes>
    implements CopyWith$Query$SceneStreams$findScene$sceneStreams<TRes> {
  _CopyWithImpl$Query$SceneStreams$findScene$sceneStreams(
    this._instance,
    this._then,
  );

  final Query$SceneStreams$findScene$sceneStreams _instance;

  final TRes Function(Query$SceneStreams$findScene$sceneStreams) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? url = _undefined,
    Object? mime_type = _undefined,
    Object? label = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$SceneStreams$findScene$sceneStreams(
      url: url == _undefined || url == null ? _instance.url : (url as String),
      mime_type: mime_type == _undefined
          ? _instance.mime_type
          : (mime_type as String?),
      label: label == _undefined ? _instance.label : (label as String?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Query$SceneStreams$findScene$sceneStreams<TRes>
    implements CopyWith$Query$SceneStreams$findScene$sceneStreams<TRes> {
  _CopyWithStubImpl$Query$SceneStreams$findScene$sceneStreams(this._res);

  TRes _res;

  call({String? url, String? mime_type, String? label, String? $__typename}) =>
      _res;
}

class Variables$Mutation$UpdateSceneRating {
  factory Variables$Mutation$UpdateSceneRating({
    required String id,
    required int rating,
  }) => Variables$Mutation$UpdateSceneRating._({r'id': id, r'rating': rating});

  Variables$Mutation$UpdateSceneRating._(this._$data);

  factory Variables$Mutation$UpdateSceneRating.fromJson(
    Map<String, dynamic> data,
  ) {
    final result$data = <String, dynamic>{};
    final l$id = data['id'];
    result$data['id'] = (l$id as String);
    final l$rating = data['rating'];
    result$data['rating'] = (l$rating as int);
    return Variables$Mutation$UpdateSceneRating._(result$data);
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

  CopyWith$Variables$Mutation$UpdateSceneRating<
    Variables$Mutation$UpdateSceneRating
  >
  get copyWith => CopyWith$Variables$Mutation$UpdateSceneRating(this, (i) => i);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdateSceneRating ||
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

abstract class CopyWith$Variables$Mutation$UpdateSceneRating<TRes> {
  factory CopyWith$Variables$Mutation$UpdateSceneRating(
    Variables$Mutation$UpdateSceneRating instance,
    TRes Function(Variables$Mutation$UpdateSceneRating) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateSceneRating;

  factory CopyWith$Variables$Mutation$UpdateSceneRating.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateSceneRating;

  TRes call({String? id, int? rating});
}

class _CopyWithImpl$Variables$Mutation$UpdateSceneRating<TRes>
    implements CopyWith$Variables$Mutation$UpdateSceneRating<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateSceneRating(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateSceneRating _instance;

  final TRes Function(Variables$Mutation$UpdateSceneRating) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? id = _undefined, Object? rating = _undefined}) => _then(
    Variables$Mutation$UpdateSceneRating._({
      ..._instance._$data,
      if (id != _undefined && id != null) 'id': (id as String),
      if (rating != _undefined && rating != null) 'rating': (rating as int),
    }),
  );
}

class _CopyWithStubImpl$Variables$Mutation$UpdateSceneRating<TRes>
    implements CopyWith$Variables$Mutation$UpdateSceneRating<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateSceneRating(this._res);

  TRes _res;

  call({String? id, int? rating}) => _res;
}

class Mutation$UpdateSceneRating {
  Mutation$UpdateSceneRating({this.sceneUpdate, this.$__typename = 'Mutation'});

  factory Mutation$UpdateSceneRating.fromJson(Map<String, dynamic> json) {
    final l$sceneUpdate = json['sceneUpdate'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateSceneRating(
      sceneUpdate: l$sceneUpdate == null
          ? null
          : Mutation$UpdateSceneRating$sceneUpdate.fromJson(
              (l$sceneUpdate as Map<String, dynamic>),
            ),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateSceneRating$sceneUpdate? sceneUpdate;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$sceneUpdate = sceneUpdate;
    _resultData['sceneUpdate'] = l$sceneUpdate?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$sceneUpdate = sceneUpdate;
    final l$$__typename = $__typename;
    return Object.hashAll([l$sceneUpdate, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdateSceneRating ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$sceneUpdate = sceneUpdate;
    final lOther$sceneUpdate = other.sceneUpdate;
    if (l$sceneUpdate != lOther$sceneUpdate) {
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

extension UtilityExtension$Mutation$UpdateSceneRating
    on Mutation$UpdateSceneRating {
  CopyWith$Mutation$UpdateSceneRating<Mutation$UpdateSceneRating>
  get copyWith => CopyWith$Mutation$UpdateSceneRating(this, (i) => i);
}

abstract class CopyWith$Mutation$UpdateSceneRating<TRes> {
  factory CopyWith$Mutation$UpdateSceneRating(
    Mutation$UpdateSceneRating instance,
    TRes Function(Mutation$UpdateSceneRating) then,
  ) = _CopyWithImpl$Mutation$UpdateSceneRating;

  factory CopyWith$Mutation$UpdateSceneRating.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateSceneRating;

  TRes call({
    Mutation$UpdateSceneRating$sceneUpdate? sceneUpdate,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateSceneRating$sceneUpdate<TRes> get sceneUpdate;
}

class _CopyWithImpl$Mutation$UpdateSceneRating<TRes>
    implements CopyWith$Mutation$UpdateSceneRating<TRes> {
  _CopyWithImpl$Mutation$UpdateSceneRating(this._instance, this._then);

  final Mutation$UpdateSceneRating _instance;

  final TRes Function(Mutation$UpdateSceneRating) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? sceneUpdate = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Mutation$UpdateSceneRating(
      sceneUpdate: sceneUpdate == _undefined
          ? _instance.sceneUpdate
          : (sceneUpdate as Mutation$UpdateSceneRating$sceneUpdate?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  CopyWith$Mutation$UpdateSceneRating$sceneUpdate<TRes> get sceneUpdate {
    final local$sceneUpdate = _instance.sceneUpdate;
    return local$sceneUpdate == null
        ? CopyWith$Mutation$UpdateSceneRating$sceneUpdate.stub(_then(_instance))
        : CopyWith$Mutation$UpdateSceneRating$sceneUpdate(
            local$sceneUpdate,
            (e) => call(sceneUpdate: e),
          );
  }
}

class _CopyWithStubImpl$Mutation$UpdateSceneRating<TRes>
    implements CopyWith$Mutation$UpdateSceneRating<TRes> {
  _CopyWithStubImpl$Mutation$UpdateSceneRating(this._res);

  TRes _res;

  call({
    Mutation$UpdateSceneRating$sceneUpdate? sceneUpdate,
    String? $__typename,
  }) => _res;

  CopyWith$Mutation$UpdateSceneRating$sceneUpdate<TRes> get sceneUpdate =>
      CopyWith$Mutation$UpdateSceneRating$sceneUpdate.stub(_res);
}

const documentNodeMutationUpdateSceneRating = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.mutation,
      name: NameNode(value: 'UpdateSceneRating'),
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
            name: NameNode(value: 'sceneUpdate'),
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
Mutation$UpdateSceneRating _parserFn$Mutation$UpdateSceneRating(
  Map<String, dynamic> data,
) => Mutation$UpdateSceneRating.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateSceneRating =
    FutureOr<void> Function(Map<String, dynamic>?, Mutation$UpdateSceneRating?);

class Options$Mutation$UpdateSceneRating
    extends graphql.MutationOptions<Mutation$UpdateSceneRating> {
  Options$Mutation$UpdateSceneRating({
    String? operationName,
    required Variables$Mutation$UpdateSceneRating variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateSceneRating? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateSceneRating? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateSceneRating>? update,
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
                     : _parserFn$Mutation$UpdateSceneRating(data),
               ),
         update: update,
         onError: onError,
         document: documentNodeMutationUpdateSceneRating,
         parserFn: _parserFn$Mutation$UpdateSceneRating,
       );

  final OnMutationCompleted$Mutation$UpdateSceneRating? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
    ...super.onCompleted == null
        ? super.properties
        : super.properties.where((property) => property != onCompleted),
    onCompletedWithParsed,
  ];
}

class WatchOptions$Mutation$UpdateSceneRating
    extends graphql.WatchQueryOptions<Mutation$UpdateSceneRating> {
  WatchOptions$Mutation$UpdateSceneRating({
    String? operationName,
    required Variables$Mutation$UpdateSceneRating variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateSceneRating? typedOptimisticResult,
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
         document: documentNodeMutationUpdateSceneRating,
         pollInterval: pollInterval,
         eagerlyFetchResults: eagerlyFetchResults,
         carryForwardDataOnException: carryForwardDataOnException,
         fetchResults: fetchResults,
         parserFn: _parserFn$Mutation$UpdateSceneRating,
       );
}

extension ClientExtension$Mutation$UpdateSceneRating on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateSceneRating>>
  mutate$UpdateSceneRating(Options$Mutation$UpdateSceneRating options) async =>
      await this.mutate(options);

  graphql.ObservableQuery<Mutation$UpdateSceneRating>
  watchMutation$UpdateSceneRating(
    WatchOptions$Mutation$UpdateSceneRating options,
  ) => this.watchMutation(options);
}

class Mutation$UpdateSceneRating$sceneUpdate {
  Mutation$UpdateSceneRating$sceneUpdate({
    required this.id,
    this.rating100,
    this.$__typename = 'Scene',
  });

  factory Mutation$UpdateSceneRating$sceneUpdate.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$id = json['id'];
    final l$rating100 = json['rating100'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateSceneRating$sceneUpdate(
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
    if (other is! Mutation$UpdateSceneRating$sceneUpdate ||
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

extension UtilityExtension$Mutation$UpdateSceneRating$sceneUpdate
    on Mutation$UpdateSceneRating$sceneUpdate {
  CopyWith$Mutation$UpdateSceneRating$sceneUpdate<
    Mutation$UpdateSceneRating$sceneUpdate
  >
  get copyWith =>
      CopyWith$Mutation$UpdateSceneRating$sceneUpdate(this, (i) => i);
}

abstract class CopyWith$Mutation$UpdateSceneRating$sceneUpdate<TRes> {
  factory CopyWith$Mutation$UpdateSceneRating$sceneUpdate(
    Mutation$UpdateSceneRating$sceneUpdate instance,
    TRes Function(Mutation$UpdateSceneRating$sceneUpdate) then,
  ) = _CopyWithImpl$Mutation$UpdateSceneRating$sceneUpdate;

  factory CopyWith$Mutation$UpdateSceneRating$sceneUpdate.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateSceneRating$sceneUpdate;

  TRes call({String? id, int? rating100, String? $__typename});
}

class _CopyWithImpl$Mutation$UpdateSceneRating$sceneUpdate<TRes>
    implements CopyWith$Mutation$UpdateSceneRating$sceneUpdate<TRes> {
  _CopyWithImpl$Mutation$UpdateSceneRating$sceneUpdate(
    this._instance,
    this._then,
  );

  final Mutation$UpdateSceneRating$sceneUpdate _instance;

  final TRes Function(Mutation$UpdateSceneRating$sceneUpdate) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? rating100 = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Mutation$UpdateSceneRating$sceneUpdate(
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

class _CopyWithStubImpl$Mutation$UpdateSceneRating$sceneUpdate<TRes>
    implements CopyWith$Mutation$UpdateSceneRating$sceneUpdate<TRes> {
  _CopyWithStubImpl$Mutation$UpdateSceneRating$sceneUpdate(this._res);

  TRes _res;

  call({String? id, int? rating100, String? $__typename}) => _res;
}
