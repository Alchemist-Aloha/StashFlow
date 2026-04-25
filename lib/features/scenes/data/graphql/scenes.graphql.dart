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
    this.captions,
    required this.urls,
    this.studio,
    required this.performers,
    required this.tags,
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
    final l$captions = json['captions'];
    final l$urls = json['urls'];
    final l$studio = json['studio'];
    final l$performers = json['performers'];
    final l$tags = json['tags'];
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
      captions: (l$captions as List<dynamic>?)
          ?.map(
            (e) => Fragment$SlimSceneData$captions.fromJson(
              (e as Map<String, dynamic>),
            ),
          )
          .toList(),
      urls: (l$urls as List<dynamic>).map((e) => (e as String)).toList(),
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
      tags: (l$tags as List<dynamic>)
          .map(
            (e) => Fragment$SlimSceneData$tags.fromJson(
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

  final List<Fragment$SlimSceneData$captions>? captions;

  final List<String> urls;

  final Fragment$SlimSceneData$studio? studio;

  final List<Fragment$SlimSceneData$performers> performers;

  final List<Fragment$SlimSceneData$tags> tags;

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
    final l$captions = captions;
    _resultData['captions'] = l$captions?.map((e) => e.toJson()).toList();
    final l$urls = urls;
    _resultData['urls'] = l$urls.map((e) => e).toList();
    final l$studio = studio;
    _resultData['studio'] = l$studio?.toJson();
    final l$performers = performers;
    _resultData['performers'] = l$performers.map((e) => e.toJson()).toList();
    final l$tags = tags;
    _resultData['tags'] = l$tags.map((e) => e.toJson()).toList();
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
    final l$captions = captions;
    final l$urls = urls;
    final l$studio = studio;
    final l$performers = performers;
    final l$tags = tags;
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
      l$captions == null ? null : Object.hashAll(l$captions.map((v) => v)),
      Object.hashAll(l$urls.map((v) => v)),
      l$studio,
      Object.hashAll(l$performers.map((v) => v)),
      Object.hashAll(l$tags.map((v) => v)),
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
    final l$captions = captions;
    final lOther$captions = other.captions;
    if (l$captions != null && lOther$captions != null) {
      if (l$captions.length != lOther$captions.length) {
        return false;
      }
      for (int i = 0; i < l$captions.length; i++) {
        final l$captions$entry = l$captions[i];
        final lOther$captions$entry = lOther$captions[i];
        if (l$captions$entry != lOther$captions$entry) {
          return false;
        }
      }
    } else if (l$captions != lOther$captions) {
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
    List<Fragment$SlimSceneData$captions>? captions,
    List<String>? urls,
    Fragment$SlimSceneData$studio? studio,
    List<Fragment$SlimSceneData$performers>? performers,
    List<Fragment$SlimSceneData$tags>? tags,
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
  TRes captions(
    Iterable<Fragment$SlimSceneData$captions>? Function(
      Iterable<
        CopyWith$Fragment$SlimSceneData$captions<
          Fragment$SlimSceneData$captions
        >
      >?,
    )
    _fn,
  );
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
  TRes tags(
    Iterable<Fragment$SlimSceneData$tags> Function(
      Iterable<
        CopyWith$Fragment$SlimSceneData$tags<Fragment$SlimSceneData$tags>
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
    Object? captions = _undefined,
    Object? urls = _undefined,
    Object? studio = _undefined,
    Object? performers = _undefined,
    Object? tags = _undefined,
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
      captions: captions == _undefined
          ? _instance.captions
          : (captions as List<Fragment$SlimSceneData$captions>?),
      urls: urls == _undefined || urls == null
          ? _instance.urls
          : (urls as List<String>),
      studio: studio == _undefined
          ? _instance.studio
          : (studio as Fragment$SlimSceneData$studio?),
      performers: performers == _undefined || performers == null
          ? _instance.performers
          : (performers as List<Fragment$SlimSceneData$performers>),
      tags: tags == _undefined || tags == null
          ? _instance.tags
          : (tags as List<Fragment$SlimSceneData$tags>),
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

  TRes captions(
    Iterable<Fragment$SlimSceneData$captions>? Function(
      Iterable<
        CopyWith$Fragment$SlimSceneData$captions<
          Fragment$SlimSceneData$captions
        >
      >?,
    )
    _fn,
  ) => call(
    captions: _fn(
      _instance.captions?.map(
        (e) => CopyWith$Fragment$SlimSceneData$captions(e, (i) => i),
      ),
    )?.toList(),
  );

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

  TRes tags(
    Iterable<Fragment$SlimSceneData$tags> Function(
      Iterable<
        CopyWith$Fragment$SlimSceneData$tags<Fragment$SlimSceneData$tags>
      >,
    )
    _fn,
  ) => call(
    tags: _fn(
      _instance.tags.map(
        (e) => CopyWith$Fragment$SlimSceneData$tags(e, (i) => i),
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
    List<Fragment$SlimSceneData$captions>? captions,
    List<String>? urls,
    Fragment$SlimSceneData$studio? studio,
    List<Fragment$SlimSceneData$performers>? performers,
    List<Fragment$SlimSceneData$tags>? tags,
    String? $__typename,
  }) => _res;

  files(_fn) => _res;

  CopyWith$Fragment$SlimSceneData$paths<TRes> get paths =>
      CopyWith$Fragment$SlimSceneData$paths.stub(_res);

  captions(_fn) => _res;

  CopyWith$Fragment$SlimSceneData$studio<TRes> get studio =>
      CopyWith$Fragment$SlimSceneData$studio.stub(_res);

  performers(_fn) => _res;

  tags(_fn) => _res;
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
              name: NameNode(value: 'fingerprints'),
              alias: null,
              arguments: [],
              directives: [],
              selectionSet: SelectionSetNode(
                selections: [
                  FieldNode(
                    name: NameNode(value: 'type'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: 'value'),
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
              name: NameNode(value: 'caption'),
              alias: null,
              arguments: [],
              directives: [],
              selectionSet: null,
            ),
            FieldNode(
              name: NameNode(value: 'vtt'),
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
        name: NameNode(value: 'captions'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: SelectionSetNode(
          selections: [
            FieldNode(
              name: NameNode(value: 'language_code'),
              alias: null,
              arguments: [],
              directives: [],
              selectionSet: null,
            ),
            FieldNode(
              name: NameNode(value: 'caption_type'),
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
        name: NameNode(value: 'urls'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
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
    required this.width,
    required this.height,
    required this.fingerprints,
    this.$__typename = 'VideoFile',
  });

  factory Fragment$SlimSceneData$files.fromJson(Map<String, dynamic> json) {
    final l$path = json['path'];
    final l$duration = json['duration'];
    final l$width = json['width'];
    final l$height = json['height'];
    final l$fingerprints = json['fingerprints'];
    final l$$__typename = json['__typename'];
    return Fragment$SlimSceneData$files(
      path: (l$path as String),
      duration: (l$duration as num).toDouble(),
      width: (l$width as int),
      height: (l$height as int),
      fingerprints: (l$fingerprints as List<dynamic>)
          .map(
            (e) => Fragment$SlimSceneData$files$fingerprints.fromJson(
              (e as Map<String, dynamic>),
            ),
          )
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final String path;

  final double duration;

  final int width;

  final int height;

  final List<Fragment$SlimSceneData$files$fingerprints> fingerprints;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$path = path;
    _resultData['path'] = l$path;
    final l$duration = duration;
    _resultData['duration'] = l$duration;
    final l$width = width;
    _resultData['width'] = l$width;
    final l$height = height;
    _resultData['height'] = l$height;
    final l$fingerprints = fingerprints;
    _resultData['fingerprints'] = l$fingerprints
        .map((e) => e.toJson())
        .toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$path = path;
    final l$duration = duration;
    final l$width = width;
    final l$height = height;
    final l$fingerprints = fingerprints;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$path,
      l$duration,
      l$width,
      l$height,
      Object.hashAll(l$fingerprints.map((v) => v)),
      l$$__typename,
    ]);
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
    final l$fingerprints = fingerprints;
    final lOther$fingerprints = other.fingerprints;
    if (l$fingerprints.length != lOther$fingerprints.length) {
      return false;
    }
    for (int i = 0; i < l$fingerprints.length; i++) {
      final l$fingerprints$entry = l$fingerprints[i];
      final lOther$fingerprints$entry = lOther$fingerprints[i];
      if (l$fingerprints$entry != lOther$fingerprints$entry) {
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

  TRes call({
    String? path,
    double? duration,
    int? width,
    int? height,
    List<Fragment$SlimSceneData$files$fingerprints>? fingerprints,
    String? $__typename,
  });
  TRes fingerprints(
    Iterable<Fragment$SlimSceneData$files$fingerprints> Function(
      Iterable<
        CopyWith$Fragment$SlimSceneData$files$fingerprints<
          Fragment$SlimSceneData$files$fingerprints
        >
      >,
    )
    _fn,
  );
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
    Object? width = _undefined,
    Object? height = _undefined,
    Object? fingerprints = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Fragment$SlimSceneData$files(
      path: path == _undefined || path == null
          ? _instance.path
          : (path as String),
      duration: duration == _undefined || duration == null
          ? _instance.duration
          : (duration as double),
      width: width == _undefined || width == null
          ? _instance.width
          : (width as int),
      height: height == _undefined || height == null
          ? _instance.height
          : (height as int),
      fingerprints: fingerprints == _undefined || fingerprints == null
          ? _instance.fingerprints
          : (fingerprints as List<Fragment$SlimSceneData$files$fingerprints>),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  TRes fingerprints(
    Iterable<Fragment$SlimSceneData$files$fingerprints> Function(
      Iterable<
        CopyWith$Fragment$SlimSceneData$files$fingerprints<
          Fragment$SlimSceneData$files$fingerprints
        >
      >,
    )
    _fn,
  ) => call(
    fingerprints: _fn(
      _instance.fingerprints.map(
        (e) => CopyWith$Fragment$SlimSceneData$files$fingerprints(e, (i) => i),
      ),
    ).toList(),
  );
}

class _CopyWithStubImpl$Fragment$SlimSceneData$files<TRes>
    implements CopyWith$Fragment$SlimSceneData$files<TRes> {
  _CopyWithStubImpl$Fragment$SlimSceneData$files(this._res);

  TRes _res;

  call({
    String? path,
    double? duration,
    int? width,
    int? height,
    List<Fragment$SlimSceneData$files$fingerprints>? fingerprints,
    String? $__typename,
  }) => _res;

  fingerprints(_fn) => _res;
}

class Fragment$SlimSceneData$files$fingerprints {
  Fragment$SlimSceneData$files$fingerprints({
    required this.type,
    required this.value,
    this.$__typename = 'Fingerprint',
  });

  factory Fragment$SlimSceneData$files$fingerprints.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$type = json['type'];
    final l$value = json['value'];
    final l$$__typename = json['__typename'];
    return Fragment$SlimSceneData$files$fingerprints(
      type: (l$type as String),
      value: (l$value as String),
      $__typename: (l$$__typename as String),
    );
  }

  final String type;

  final String value;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$type = type;
    _resultData['type'] = l$type;
    final l$value = value;
    _resultData['value'] = l$value;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$type = type;
    final l$value = value;
    final l$$__typename = $__typename;
    return Object.hashAll([l$type, l$value, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$SlimSceneData$files$fingerprints ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$type = type;
    final lOther$type = other.type;
    if (l$type != lOther$type) {
      return false;
    }
    final l$value = value;
    final lOther$value = other.value;
    if (l$value != lOther$value) {
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

extension UtilityExtension$Fragment$SlimSceneData$files$fingerprints
    on Fragment$SlimSceneData$files$fingerprints {
  CopyWith$Fragment$SlimSceneData$files$fingerprints<
    Fragment$SlimSceneData$files$fingerprints
  >
  get copyWith =>
      CopyWith$Fragment$SlimSceneData$files$fingerprints(this, (i) => i);
}

abstract class CopyWith$Fragment$SlimSceneData$files$fingerprints<TRes> {
  factory CopyWith$Fragment$SlimSceneData$files$fingerprints(
    Fragment$SlimSceneData$files$fingerprints instance,
    TRes Function(Fragment$SlimSceneData$files$fingerprints) then,
  ) = _CopyWithImpl$Fragment$SlimSceneData$files$fingerprints;

  factory CopyWith$Fragment$SlimSceneData$files$fingerprints.stub(TRes res) =
      _CopyWithStubImpl$Fragment$SlimSceneData$files$fingerprints;

  TRes call({String? type, String? value, String? $__typename});
}

class _CopyWithImpl$Fragment$SlimSceneData$files$fingerprints<TRes>
    implements CopyWith$Fragment$SlimSceneData$files$fingerprints<TRes> {
  _CopyWithImpl$Fragment$SlimSceneData$files$fingerprints(
    this._instance,
    this._then,
  );

  final Fragment$SlimSceneData$files$fingerprints _instance;

  final TRes Function(Fragment$SlimSceneData$files$fingerprints) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? type = _undefined,
    Object? value = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Fragment$SlimSceneData$files$fingerprints(
      type: type == _undefined || type == null
          ? _instance.type
          : (type as String),
      value: value == _undefined || value == null
          ? _instance.value
          : (value as String),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Fragment$SlimSceneData$files$fingerprints<TRes>
    implements CopyWith$Fragment$SlimSceneData$files$fingerprints<TRes> {
  _CopyWithStubImpl$Fragment$SlimSceneData$files$fingerprints(this._res);

  TRes _res;

  call({String? type, String? value, String? $__typename}) => _res;
}

class Fragment$SlimSceneData$paths {
  Fragment$SlimSceneData$paths({
    this.screenshot,
    this.preview,
    this.stream,
    this.caption,
    this.vtt,
    this.$__typename = 'ScenePathsType',
  });

  factory Fragment$SlimSceneData$paths.fromJson(Map<String, dynamic> json) {
    final l$screenshot = json['screenshot'];
    final l$preview = json['preview'];
    final l$stream = json['stream'];
    final l$caption = json['caption'];
    final l$vtt = json['vtt'];
    final l$$__typename = json['__typename'];
    return Fragment$SlimSceneData$paths(
      screenshot: (l$screenshot as String?),
      preview: (l$preview as String?),
      stream: (l$stream as String?),
      caption: (l$caption as String?),
      vtt: (l$vtt as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String? screenshot;

  final String? preview;

  final String? stream;

  final String? caption;

  final String? vtt;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$screenshot = screenshot;
    _resultData['screenshot'] = l$screenshot;
    final l$preview = preview;
    _resultData['preview'] = l$preview;
    final l$stream = stream;
    _resultData['stream'] = l$stream;
    final l$caption = caption;
    _resultData['caption'] = l$caption;
    final l$vtt = vtt;
    _resultData['vtt'] = l$vtt;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$screenshot = screenshot;
    final l$preview = preview;
    final l$stream = stream;
    final l$caption = caption;
    final l$vtt = vtt;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$screenshot,
      l$preview,
      l$stream,
      l$caption,
      l$vtt,
      l$$__typename,
    ]);
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
    final l$caption = caption;
    final lOther$caption = other.caption;
    if (l$caption != lOther$caption) {
      return false;
    }
    final l$vtt = vtt;
    final lOther$vtt = other.vtt;
    if (l$vtt != lOther$vtt) {
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
    String? caption,
    String? vtt,
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
    Object? caption = _undefined,
    Object? vtt = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Fragment$SlimSceneData$paths(
      screenshot: screenshot == _undefined
          ? _instance.screenshot
          : (screenshot as String?),
      preview: preview == _undefined ? _instance.preview : (preview as String?),
      stream: stream == _undefined ? _instance.stream : (stream as String?),
      caption: caption == _undefined ? _instance.caption : (caption as String?),
      vtt: vtt == _undefined ? _instance.vtt : (vtt as String?),
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
    String? caption,
    String? vtt,
    String? $__typename,
  }) => _res;
}

class Fragment$SlimSceneData$captions {
  Fragment$SlimSceneData$captions({
    required this.language_code,
    required this.caption_type,
    this.$__typename = 'VideoCaption',
  });

  factory Fragment$SlimSceneData$captions.fromJson(Map<String, dynamic> json) {
    final l$language_code = json['language_code'];
    final l$caption_type = json['caption_type'];
    final l$$__typename = json['__typename'];
    return Fragment$SlimSceneData$captions(
      language_code: (l$language_code as String),
      caption_type: (l$caption_type as String),
      $__typename: (l$$__typename as String),
    );
  }

  final String language_code;

  final String caption_type;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$language_code = language_code;
    _resultData['language_code'] = l$language_code;
    final l$caption_type = caption_type;
    _resultData['caption_type'] = l$caption_type;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$language_code = language_code;
    final l$caption_type = caption_type;
    final l$$__typename = $__typename;
    return Object.hashAll([l$language_code, l$caption_type, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$SlimSceneData$captions ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$language_code = language_code;
    final lOther$language_code = other.language_code;
    if (l$language_code != lOther$language_code) {
      return false;
    }
    final l$caption_type = caption_type;
    final lOther$caption_type = other.caption_type;
    if (l$caption_type != lOther$caption_type) {
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

extension UtilityExtension$Fragment$SlimSceneData$captions
    on Fragment$SlimSceneData$captions {
  CopyWith$Fragment$SlimSceneData$captions<Fragment$SlimSceneData$captions>
  get copyWith => CopyWith$Fragment$SlimSceneData$captions(this, (i) => i);
}

abstract class CopyWith$Fragment$SlimSceneData$captions<TRes> {
  factory CopyWith$Fragment$SlimSceneData$captions(
    Fragment$SlimSceneData$captions instance,
    TRes Function(Fragment$SlimSceneData$captions) then,
  ) = _CopyWithImpl$Fragment$SlimSceneData$captions;

  factory CopyWith$Fragment$SlimSceneData$captions.stub(TRes res) =
      _CopyWithStubImpl$Fragment$SlimSceneData$captions;

  TRes call({String? language_code, String? caption_type, String? $__typename});
}

class _CopyWithImpl$Fragment$SlimSceneData$captions<TRes>
    implements CopyWith$Fragment$SlimSceneData$captions<TRes> {
  _CopyWithImpl$Fragment$SlimSceneData$captions(this._instance, this._then);

  final Fragment$SlimSceneData$captions _instance;

  final TRes Function(Fragment$SlimSceneData$captions) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? language_code = _undefined,
    Object? caption_type = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Fragment$SlimSceneData$captions(
      language_code: language_code == _undefined || language_code == null
          ? _instance.language_code
          : (language_code as String),
      caption_type: caption_type == _undefined || caption_type == null
          ? _instance.caption_type
          : (caption_type as String),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Fragment$SlimSceneData$captions<TRes>
    implements CopyWith$Fragment$SlimSceneData$captions<TRes> {
  _CopyWithStubImpl$Fragment$SlimSceneData$captions(this._res);

  TRes _res;

  call({String? language_code, String? caption_type, String? $__typename}) =>
      _res;
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

class Fragment$SlimSceneData$tags {
  Fragment$SlimSceneData$tags({
    required this.id,
    required this.name,
    this.$__typename = 'Tag',
  });

  factory Fragment$SlimSceneData$tags.fromJson(Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$name = json['name'];
    final l$$__typename = json['__typename'];
    return Fragment$SlimSceneData$tags(
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
    if (other is! Fragment$SlimSceneData$tags ||
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
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$SlimSceneData$tags
    on Fragment$SlimSceneData$tags {
  CopyWith$Fragment$SlimSceneData$tags<Fragment$SlimSceneData$tags>
  get copyWith => CopyWith$Fragment$SlimSceneData$tags(this, (i) => i);
}

abstract class CopyWith$Fragment$SlimSceneData$tags<TRes> {
  factory CopyWith$Fragment$SlimSceneData$tags(
    Fragment$SlimSceneData$tags instance,
    TRes Function(Fragment$SlimSceneData$tags) then,
  ) = _CopyWithImpl$Fragment$SlimSceneData$tags;

  factory CopyWith$Fragment$SlimSceneData$tags.stub(TRes res) =
      _CopyWithStubImpl$Fragment$SlimSceneData$tags;

  TRes call({String? id, String? name, String? $__typename});
}

class _CopyWithImpl$Fragment$SlimSceneData$tags<TRes>
    implements CopyWith$Fragment$SlimSceneData$tags<TRes> {
  _CopyWithImpl$Fragment$SlimSceneData$tags(this._instance, this._then);

  final Fragment$SlimSceneData$tags _instance;

  final TRes Function(Fragment$SlimSceneData$tags) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? name = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Fragment$SlimSceneData$tags(
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

class _CopyWithStubImpl$Fragment$SlimSceneData$tags<TRes>
    implements CopyWith$Fragment$SlimSceneData$tags<TRes> {
  _CopyWithStubImpl$Fragment$SlimSceneData$tags(this._res);

  TRes _res;

  call({String? id, String? name, String? $__typename}) => _res;
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
    this.captions,
    required this.urls,
    this.studio,
    required this.performers,
    required this.tags,
    this.$__typename = 'Scene',
    this.details,
    this.director,
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
    final l$captions = json['captions'];
    final l$urls = json['urls'];
    final l$studio = json['studio'];
    final l$performers = json['performers'];
    final l$tags = json['tags'];
    final l$$__typename = json['__typename'];
    final l$details = json['details'];
    final l$director = json['director'];
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
      captions: (l$captions as List<dynamic>?)
          ?.map(
            (e) => Fragment$SceneData$captions.fromJson(
              (e as Map<String, dynamic>),
            ),
          )
          .toList(),
      urls: (l$urls as List<dynamic>).map((e) => (e as String)).toList(),
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
      tags: (l$tags as List<dynamic>)
          .map(
            (e) =>
                Fragment$SceneData$tags.fromJson((e as Map<String, dynamic>)),
          )
          .toList(),
      $__typename: (l$$__typename as String),
      details: (l$details as String?),
      director: (l$director as String?),
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

  final List<Fragment$SceneData$captions>? captions;

  final List<String> urls;

  final Fragment$SceneData$studio? studio;

  final List<Fragment$SceneData$performers> performers;

  final List<Fragment$SceneData$tags> tags;

  final String $__typename;

  final String? details;

  final String? director;

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
    final l$captions = captions;
    _resultData['captions'] = l$captions?.map((e) => e.toJson()).toList();
    final l$urls = urls;
    _resultData['urls'] = l$urls.map((e) => e).toList();
    final l$studio = studio;
    _resultData['studio'] = l$studio?.toJson();
    final l$performers = performers;
    _resultData['performers'] = l$performers.map((e) => e.toJson()).toList();
    final l$tags = tags;
    _resultData['tags'] = l$tags.map((e) => e.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    final l$details = details;
    _resultData['details'] = l$details;
    final l$director = director;
    _resultData['director'] = l$director;
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
    final l$captions = captions;
    final l$urls = urls;
    final l$studio = studio;
    final l$performers = performers;
    final l$tags = tags;
    final l$$__typename = $__typename;
    final l$details = details;
    final l$director = director;
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
      l$captions == null ? null : Object.hashAll(l$captions.map((v) => v)),
      Object.hashAll(l$urls.map((v) => v)),
      l$studio,
      Object.hashAll(l$performers.map((v) => v)),
      Object.hashAll(l$tags.map((v) => v)),
      l$$__typename,
      l$details,
      l$director,
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
    final l$captions = captions;
    final lOther$captions = other.captions;
    if (l$captions != null && lOther$captions != null) {
      if (l$captions.length != lOther$captions.length) {
        return false;
      }
      for (int i = 0; i < l$captions.length; i++) {
        final l$captions$entry = l$captions[i];
        final lOther$captions$entry = lOther$captions[i];
        if (l$captions$entry != lOther$captions$entry) {
          return false;
        }
      }
    } else if (l$captions != lOther$captions) {
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
    final l$details = details;
    final lOther$details = other.details;
    if (l$details != lOther$details) {
      return false;
    }
    final l$director = director;
    final lOther$director = other.director;
    if (l$director != lOther$director) {
      return false;
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
    List<Fragment$SceneData$captions>? captions,
    List<String>? urls,
    Fragment$SceneData$studio? studio,
    List<Fragment$SceneData$performers>? performers,
    List<Fragment$SceneData$tags>? tags,
    String? $__typename,
    String? details,
    String? director,
  });
  TRes files(
    Iterable<Fragment$SceneData$files> Function(
      Iterable<CopyWith$Fragment$SceneData$files<Fragment$SceneData$files>>,
    )
    _fn,
  );
  CopyWith$Fragment$SceneData$paths<TRes> get paths;
  TRes captions(
    Iterable<Fragment$SceneData$captions>? Function(
      Iterable<
        CopyWith$Fragment$SceneData$captions<Fragment$SceneData$captions>
      >?,
    )
    _fn,
  );
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
    Object? captions = _undefined,
    Object? urls = _undefined,
    Object? studio = _undefined,
    Object? performers = _undefined,
    Object? tags = _undefined,
    Object? $__typename = _undefined,
    Object? details = _undefined,
    Object? director = _undefined,
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
      captions: captions == _undefined
          ? _instance.captions
          : (captions as List<Fragment$SceneData$captions>?),
      urls: urls == _undefined || urls == null
          ? _instance.urls
          : (urls as List<String>),
      studio: studio == _undefined
          ? _instance.studio
          : (studio as Fragment$SceneData$studio?),
      performers: performers == _undefined || performers == null
          ? _instance.performers
          : (performers as List<Fragment$SceneData$performers>),
      tags: tags == _undefined || tags == null
          ? _instance.tags
          : (tags as List<Fragment$SceneData$tags>),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
      details: details == _undefined ? _instance.details : (details as String?),
      director: director == _undefined
          ? _instance.director
          : (director as String?),
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

  TRes captions(
    Iterable<Fragment$SceneData$captions>? Function(
      Iterable<
        CopyWith$Fragment$SceneData$captions<Fragment$SceneData$captions>
      >?,
    )
    _fn,
  ) => call(
    captions: _fn(
      _instance.captions?.map(
        (e) => CopyWith$Fragment$SceneData$captions(e, (i) => i),
      ),
    )?.toList(),
  );

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
    List<Fragment$SceneData$captions>? captions,
    List<String>? urls,
    Fragment$SceneData$studio? studio,
    List<Fragment$SceneData$performers>? performers,
    List<Fragment$SceneData$tags>? tags,
    String? $__typename,
    String? details,
    String? director,
  }) => _res;

  files(_fn) => _res;

  CopyWith$Fragment$SceneData$paths<TRes> get paths =>
      CopyWith$Fragment$SceneData$paths.stub(_res);

  captions(_fn) => _res;

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
              name: NameNode(value: 'fingerprints'),
              alias: null,
              arguments: [],
              directives: [],
              selectionSet: SelectionSetNode(
                selections: [
                  FieldNode(
                    name: NameNode(value: 'type'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: 'value'),
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
    required this.width,
    required this.height,
    required this.fingerprints,
    this.$__typename = 'VideoFile',
    required this.basename,
    required this.format,
    required this.video_codec,
    required this.audio_codec,
    required this.bit_rate,
    required this.frame_rate,
  });

  factory Fragment$SceneData$files.fromJson(Map<String, dynamic> json) {
    final l$path = json['path'];
    final l$duration = json['duration'];
    final l$width = json['width'];
    final l$height = json['height'];
    final l$fingerprints = json['fingerprints'];
    final l$$__typename = json['__typename'];
    final l$basename = json['basename'];
    final l$format = json['format'];
    final l$video_codec = json['video_codec'];
    final l$audio_codec = json['audio_codec'];
    final l$bit_rate = json['bit_rate'];
    final l$frame_rate = json['frame_rate'];
    return Fragment$SceneData$files(
      path: (l$path as String),
      duration: (l$duration as num).toDouble(),
      width: (l$width as int),
      height: (l$height as int),
      fingerprints: (l$fingerprints as List<dynamic>)
          .map(
            (e) => Fragment$SceneData$files$fingerprints.fromJson(
              (e as Map<String, dynamic>),
            ),
          )
          .toList(),
      $__typename: (l$$__typename as String),
      basename: (l$basename as String),
      format: (l$format as String),
      video_codec: (l$video_codec as String),
      audio_codec: (l$audio_codec as String),
      bit_rate: (l$bit_rate as int),
      frame_rate: (l$frame_rate as num).toDouble(),
    );
  }

  final String path;

  final double duration;

  final int width;

  final int height;

  final List<Fragment$SceneData$files$fingerprints> fingerprints;

  final String $__typename;

  final String basename;

  final String format;

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
    final l$width = width;
    _resultData['width'] = l$width;
    final l$height = height;
    _resultData['height'] = l$height;
    final l$fingerprints = fingerprints;
    _resultData['fingerprints'] = l$fingerprints
        .map((e) => e.toJson())
        .toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    final l$basename = basename;
    _resultData['basename'] = l$basename;
    final l$format = format;
    _resultData['format'] = l$format;
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
    final l$width = width;
    final l$height = height;
    final l$fingerprints = fingerprints;
    final l$$__typename = $__typename;
    final l$basename = basename;
    final l$format = format;
    final l$video_codec = video_codec;
    final l$audio_codec = audio_codec;
    final l$bit_rate = bit_rate;
    final l$frame_rate = frame_rate;
    return Object.hashAll([
      l$path,
      l$duration,
      l$width,
      l$height,
      Object.hashAll(l$fingerprints.map((v) => v)),
      l$$__typename,
      l$basename,
      l$format,
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
    final l$fingerprints = fingerprints;
    final lOther$fingerprints = other.fingerprints;
    if (l$fingerprints.length != lOther$fingerprints.length) {
      return false;
    }
    for (int i = 0; i < l$fingerprints.length; i++) {
      final l$fingerprints$entry = l$fingerprints[i];
      final lOther$fingerprints$entry = lOther$fingerprints[i];
      if (l$fingerprints$entry != lOther$fingerprints$entry) {
        return false;
      }
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
    int? width,
    int? height,
    List<Fragment$SceneData$files$fingerprints>? fingerprints,
    String? $__typename,
    String? basename,
    String? format,
    String? video_codec,
    String? audio_codec,
    int? bit_rate,
    double? frame_rate,
  });
  TRes fingerprints(
    Iterable<Fragment$SceneData$files$fingerprints> Function(
      Iterable<
        CopyWith$Fragment$SceneData$files$fingerprints<
          Fragment$SceneData$files$fingerprints
        >
      >,
    )
    _fn,
  );
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
    Object? width = _undefined,
    Object? height = _undefined,
    Object? fingerprints = _undefined,
    Object? $__typename = _undefined,
    Object? basename = _undefined,
    Object? format = _undefined,
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
      width: width == _undefined || width == null
          ? _instance.width
          : (width as int),
      height: height == _undefined || height == null
          ? _instance.height
          : (height as int),
      fingerprints: fingerprints == _undefined || fingerprints == null
          ? _instance.fingerprints
          : (fingerprints as List<Fragment$SceneData$files$fingerprints>),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
      basename: basename == _undefined || basename == null
          ? _instance.basename
          : (basename as String),
      format: format == _undefined || format == null
          ? _instance.format
          : (format as String),
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

  TRes fingerprints(
    Iterable<Fragment$SceneData$files$fingerprints> Function(
      Iterable<
        CopyWith$Fragment$SceneData$files$fingerprints<
          Fragment$SceneData$files$fingerprints
        >
      >,
    )
    _fn,
  ) => call(
    fingerprints: _fn(
      _instance.fingerprints.map(
        (e) => CopyWith$Fragment$SceneData$files$fingerprints(e, (i) => i),
      ),
    ).toList(),
  );
}

class _CopyWithStubImpl$Fragment$SceneData$files<TRes>
    implements CopyWith$Fragment$SceneData$files<TRes> {
  _CopyWithStubImpl$Fragment$SceneData$files(this._res);

  TRes _res;

  call({
    String? path,
    double? duration,
    int? width,
    int? height,
    List<Fragment$SceneData$files$fingerprints>? fingerprints,
    String? $__typename,
    String? basename,
    String? format,
    String? video_codec,
    String? audio_codec,
    int? bit_rate,
    double? frame_rate,
  }) => _res;

  fingerprints(_fn) => _res;
}

class Fragment$SceneData$files$fingerprints
    implements Fragment$SlimSceneData$files$fingerprints {
  Fragment$SceneData$files$fingerprints({
    required this.type,
    required this.value,
    this.$__typename = 'Fingerprint',
  });

  factory Fragment$SceneData$files$fingerprints.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$type = json['type'];
    final l$value = json['value'];
    final l$$__typename = json['__typename'];
    return Fragment$SceneData$files$fingerprints(
      type: (l$type as String),
      value: (l$value as String),
      $__typename: (l$$__typename as String),
    );
  }

  final String type;

  final String value;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$type = type;
    _resultData['type'] = l$type;
    final l$value = value;
    _resultData['value'] = l$value;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$type = type;
    final l$value = value;
    final l$$__typename = $__typename;
    return Object.hashAll([l$type, l$value, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$SceneData$files$fingerprints ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$type = type;
    final lOther$type = other.type;
    if (l$type != lOther$type) {
      return false;
    }
    final l$value = value;
    final lOther$value = other.value;
    if (l$value != lOther$value) {
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

extension UtilityExtension$Fragment$SceneData$files$fingerprints
    on Fragment$SceneData$files$fingerprints {
  CopyWith$Fragment$SceneData$files$fingerprints<
    Fragment$SceneData$files$fingerprints
  >
  get copyWith =>
      CopyWith$Fragment$SceneData$files$fingerprints(this, (i) => i);
}

abstract class CopyWith$Fragment$SceneData$files$fingerprints<TRes> {
  factory CopyWith$Fragment$SceneData$files$fingerprints(
    Fragment$SceneData$files$fingerprints instance,
    TRes Function(Fragment$SceneData$files$fingerprints) then,
  ) = _CopyWithImpl$Fragment$SceneData$files$fingerprints;

  factory CopyWith$Fragment$SceneData$files$fingerprints.stub(TRes res) =
      _CopyWithStubImpl$Fragment$SceneData$files$fingerprints;

  TRes call({String? type, String? value, String? $__typename});
}

class _CopyWithImpl$Fragment$SceneData$files$fingerprints<TRes>
    implements CopyWith$Fragment$SceneData$files$fingerprints<TRes> {
  _CopyWithImpl$Fragment$SceneData$files$fingerprints(
    this._instance,
    this._then,
  );

  final Fragment$SceneData$files$fingerprints _instance;

  final TRes Function(Fragment$SceneData$files$fingerprints) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? type = _undefined,
    Object? value = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Fragment$SceneData$files$fingerprints(
      type: type == _undefined || type == null
          ? _instance.type
          : (type as String),
      value: value == _undefined || value == null
          ? _instance.value
          : (value as String),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Fragment$SceneData$files$fingerprints<TRes>
    implements CopyWith$Fragment$SceneData$files$fingerprints<TRes> {
  _CopyWithStubImpl$Fragment$SceneData$files$fingerprints(this._res);

  TRes _res;

  call({String? type, String? value, String? $__typename}) => _res;
}

class Fragment$SceneData$paths implements Fragment$SlimSceneData$paths {
  Fragment$SceneData$paths({
    this.screenshot,
    this.preview,
    this.stream,
    this.caption,
    this.vtt,
    this.$__typename = 'ScenePathsType',
  });

  factory Fragment$SceneData$paths.fromJson(Map<String, dynamic> json) {
    final l$screenshot = json['screenshot'];
    final l$preview = json['preview'];
    final l$stream = json['stream'];
    final l$caption = json['caption'];
    final l$vtt = json['vtt'];
    final l$$__typename = json['__typename'];
    return Fragment$SceneData$paths(
      screenshot: (l$screenshot as String?),
      preview: (l$preview as String?),
      stream: (l$stream as String?),
      caption: (l$caption as String?),
      vtt: (l$vtt as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String? screenshot;

  final String? preview;

  final String? stream;

  final String? caption;

  final String? vtt;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$screenshot = screenshot;
    _resultData['screenshot'] = l$screenshot;
    final l$preview = preview;
    _resultData['preview'] = l$preview;
    final l$stream = stream;
    _resultData['stream'] = l$stream;
    final l$caption = caption;
    _resultData['caption'] = l$caption;
    final l$vtt = vtt;
    _resultData['vtt'] = l$vtt;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$screenshot = screenshot;
    final l$preview = preview;
    final l$stream = stream;
    final l$caption = caption;
    final l$vtt = vtt;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$screenshot,
      l$preview,
      l$stream,
      l$caption,
      l$vtt,
      l$$__typename,
    ]);
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
    final l$caption = caption;
    final lOther$caption = other.caption;
    if (l$caption != lOther$caption) {
      return false;
    }
    final l$vtt = vtt;
    final lOther$vtt = other.vtt;
    if (l$vtt != lOther$vtt) {
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
    String? caption,
    String? vtt,
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
    Object? caption = _undefined,
    Object? vtt = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Fragment$SceneData$paths(
      screenshot: screenshot == _undefined
          ? _instance.screenshot
          : (screenshot as String?),
      preview: preview == _undefined ? _instance.preview : (preview as String?),
      stream: stream == _undefined ? _instance.stream : (stream as String?),
      caption: caption == _undefined ? _instance.caption : (caption as String?),
      vtt: vtt == _undefined ? _instance.vtt : (vtt as String?),
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
    String? caption,
    String? vtt,
    String? $__typename,
  }) => _res;
}

class Fragment$SceneData$captions implements Fragment$SlimSceneData$captions {
  Fragment$SceneData$captions({
    required this.language_code,
    required this.caption_type,
    this.$__typename = 'VideoCaption',
  });

  factory Fragment$SceneData$captions.fromJson(Map<String, dynamic> json) {
    final l$language_code = json['language_code'];
    final l$caption_type = json['caption_type'];
    final l$$__typename = json['__typename'];
    return Fragment$SceneData$captions(
      language_code: (l$language_code as String),
      caption_type: (l$caption_type as String),
      $__typename: (l$$__typename as String),
    );
  }

  final String language_code;

  final String caption_type;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$language_code = language_code;
    _resultData['language_code'] = l$language_code;
    final l$caption_type = caption_type;
    _resultData['caption_type'] = l$caption_type;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$language_code = language_code;
    final l$caption_type = caption_type;
    final l$$__typename = $__typename;
    return Object.hashAll([l$language_code, l$caption_type, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$SceneData$captions ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$language_code = language_code;
    final lOther$language_code = other.language_code;
    if (l$language_code != lOther$language_code) {
      return false;
    }
    final l$caption_type = caption_type;
    final lOther$caption_type = other.caption_type;
    if (l$caption_type != lOther$caption_type) {
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

extension UtilityExtension$Fragment$SceneData$captions
    on Fragment$SceneData$captions {
  CopyWith$Fragment$SceneData$captions<Fragment$SceneData$captions>
  get copyWith => CopyWith$Fragment$SceneData$captions(this, (i) => i);
}

abstract class CopyWith$Fragment$SceneData$captions<TRes> {
  factory CopyWith$Fragment$SceneData$captions(
    Fragment$SceneData$captions instance,
    TRes Function(Fragment$SceneData$captions) then,
  ) = _CopyWithImpl$Fragment$SceneData$captions;

  factory CopyWith$Fragment$SceneData$captions.stub(TRes res) =
      _CopyWithStubImpl$Fragment$SceneData$captions;

  TRes call({String? language_code, String? caption_type, String? $__typename});
}

class _CopyWithImpl$Fragment$SceneData$captions<TRes>
    implements CopyWith$Fragment$SceneData$captions<TRes> {
  _CopyWithImpl$Fragment$SceneData$captions(this._instance, this._then);

  final Fragment$SceneData$captions _instance;

  final TRes Function(Fragment$SceneData$captions) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? language_code = _undefined,
    Object? caption_type = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Fragment$SceneData$captions(
      language_code: language_code == _undefined || language_code == null
          ? _instance.language_code
          : (language_code as String),
      caption_type: caption_type == _undefined || caption_type == null
          ? _instance.caption_type
          : (caption_type as String),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Fragment$SceneData$captions<TRes>
    implements CopyWith$Fragment$SceneData$captions<TRes> {
  _CopyWithStubImpl$Fragment$SceneData$captions(this._res);

  TRes _res;

  call({String? language_code, String? caption_type, String? $__typename}) =>
      _res;
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

class Fragment$SceneData$tags implements Fragment$SlimSceneData$tags {
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

class Variables$Mutation$SceneAddO {
  factory Variables$Mutation$SceneAddO({required String id}) =>
      Variables$Mutation$SceneAddO._({r'id': id});

  Variables$Mutation$SceneAddO._(this._$data);

  factory Variables$Mutation$SceneAddO.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$id = data['id'];
    result$data['id'] = (l$id as String);
    return Variables$Mutation$SceneAddO._(result$data);
  }

  Map<String, dynamic> _$data;

  String get id => (_$data['id'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$id = id;
    result$data['id'] = l$id;
    return result$data;
  }

  CopyWith$Variables$Mutation$SceneAddO<Variables$Mutation$SceneAddO>
  get copyWith => CopyWith$Variables$Mutation$SceneAddO(this, (i) => i);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$SceneAddO ||
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

abstract class CopyWith$Variables$Mutation$SceneAddO<TRes> {
  factory CopyWith$Variables$Mutation$SceneAddO(
    Variables$Mutation$SceneAddO instance,
    TRes Function(Variables$Mutation$SceneAddO) then,
  ) = _CopyWithImpl$Variables$Mutation$SceneAddO;

  factory CopyWith$Variables$Mutation$SceneAddO.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$SceneAddO;

  TRes call({String? id});
}

class _CopyWithImpl$Variables$Mutation$SceneAddO<TRes>
    implements CopyWith$Variables$Mutation$SceneAddO<TRes> {
  _CopyWithImpl$Variables$Mutation$SceneAddO(this._instance, this._then);

  final Variables$Mutation$SceneAddO _instance;

  final TRes Function(Variables$Mutation$SceneAddO) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? id = _undefined}) => _then(
    Variables$Mutation$SceneAddO._({
      ..._instance._$data,
      if (id != _undefined && id != null) 'id': (id as String),
    }),
  );
}

class _CopyWithStubImpl$Variables$Mutation$SceneAddO<TRes>
    implements CopyWith$Variables$Mutation$SceneAddO<TRes> {
  _CopyWithStubImpl$Variables$Mutation$SceneAddO(this._res);

  TRes _res;

  call({String? id}) => _res;
}

class Mutation$SceneAddO {
  Mutation$SceneAddO({required this.sceneAddO, this.$__typename = 'Mutation'});

  factory Mutation$SceneAddO.fromJson(Map<String, dynamic> json) {
    final l$sceneAddO = json['sceneAddO'];
    final l$$__typename = json['__typename'];
    return Mutation$SceneAddO(
      sceneAddO: Mutation$SceneAddO$sceneAddO.fromJson(
        (l$sceneAddO as Map<String, dynamic>),
      ),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$SceneAddO$sceneAddO sceneAddO;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$sceneAddO = sceneAddO;
    _resultData['sceneAddO'] = l$sceneAddO.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$sceneAddO = sceneAddO;
    final l$$__typename = $__typename;
    return Object.hashAll([l$sceneAddO, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$SceneAddO || runtimeType != other.runtimeType) {
      return false;
    }
    final l$sceneAddO = sceneAddO;
    final lOther$sceneAddO = other.sceneAddO;
    if (l$sceneAddO != lOther$sceneAddO) {
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

extension UtilityExtension$Mutation$SceneAddO on Mutation$SceneAddO {
  CopyWith$Mutation$SceneAddO<Mutation$SceneAddO> get copyWith =>
      CopyWith$Mutation$SceneAddO(this, (i) => i);
}

abstract class CopyWith$Mutation$SceneAddO<TRes> {
  factory CopyWith$Mutation$SceneAddO(
    Mutation$SceneAddO instance,
    TRes Function(Mutation$SceneAddO) then,
  ) = _CopyWithImpl$Mutation$SceneAddO;

  factory CopyWith$Mutation$SceneAddO.stub(TRes res) =
      _CopyWithStubImpl$Mutation$SceneAddO;

  TRes call({Mutation$SceneAddO$sceneAddO? sceneAddO, String? $__typename});
  CopyWith$Mutation$SceneAddO$sceneAddO<TRes> get sceneAddO;
}

class _CopyWithImpl$Mutation$SceneAddO<TRes>
    implements CopyWith$Mutation$SceneAddO<TRes> {
  _CopyWithImpl$Mutation$SceneAddO(this._instance, this._then);

  final Mutation$SceneAddO _instance;

  final TRes Function(Mutation$SceneAddO) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? sceneAddO = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Mutation$SceneAddO(
      sceneAddO: sceneAddO == _undefined || sceneAddO == null
          ? _instance.sceneAddO
          : (sceneAddO as Mutation$SceneAddO$sceneAddO),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  CopyWith$Mutation$SceneAddO$sceneAddO<TRes> get sceneAddO {
    final local$sceneAddO = _instance.sceneAddO;
    return CopyWith$Mutation$SceneAddO$sceneAddO(
      local$sceneAddO,
      (e) => call(sceneAddO: e),
    );
  }
}

class _CopyWithStubImpl$Mutation$SceneAddO<TRes>
    implements CopyWith$Mutation$SceneAddO<TRes> {
  _CopyWithStubImpl$Mutation$SceneAddO(this._res);

  TRes _res;

  call({Mutation$SceneAddO$sceneAddO? sceneAddO, String? $__typename}) => _res;

  CopyWith$Mutation$SceneAddO$sceneAddO<TRes> get sceneAddO =>
      CopyWith$Mutation$SceneAddO$sceneAddO.stub(_res);
}

const documentNodeMutationSceneAddO = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.mutation,
      name: NameNode(value: 'SceneAddO'),
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
            name: NameNode(value: 'sceneAddO'),
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
                  name: NameNode(value: 'count'),
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
Mutation$SceneAddO _parserFn$Mutation$SceneAddO(Map<String, dynamic> data) =>
    Mutation$SceneAddO.fromJson(data);
typedef OnMutationCompleted$Mutation$SceneAddO =
    FutureOr<void> Function(Map<String, dynamic>?, Mutation$SceneAddO?);

class Options$Mutation$SceneAddO
    extends graphql.MutationOptions<Mutation$SceneAddO> {
  Options$Mutation$SceneAddO({
    String? operationName,
    required Variables$Mutation$SceneAddO variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$SceneAddO? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$SceneAddO? onCompleted,
    graphql.OnMutationUpdate<Mutation$SceneAddO>? update,
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
                 data == null ? null : _parserFn$Mutation$SceneAddO(data),
               ),
         update: update,
         onError: onError,
         document: documentNodeMutationSceneAddO,
         parserFn: _parserFn$Mutation$SceneAddO,
       );

  final OnMutationCompleted$Mutation$SceneAddO? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
    ...super.onCompleted == null
        ? super.properties
        : super.properties.where((property) => property != onCompleted),
    onCompletedWithParsed,
  ];
}

class WatchOptions$Mutation$SceneAddO
    extends graphql.WatchQueryOptions<Mutation$SceneAddO> {
  WatchOptions$Mutation$SceneAddO({
    String? operationName,
    required Variables$Mutation$SceneAddO variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$SceneAddO? typedOptimisticResult,
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
         document: documentNodeMutationSceneAddO,
         pollInterval: pollInterval,
         eagerlyFetchResults: eagerlyFetchResults,
         carryForwardDataOnException: carryForwardDataOnException,
         fetchResults: fetchResults,
         parserFn: _parserFn$Mutation$SceneAddO,
       );
}

extension ClientExtension$Mutation$SceneAddO on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$SceneAddO>> mutate$SceneAddO(
    Options$Mutation$SceneAddO options,
  ) async => await this.mutate(options);

  graphql.ObservableQuery<Mutation$SceneAddO> watchMutation$SceneAddO(
    WatchOptions$Mutation$SceneAddO options,
  ) => this.watchMutation(options);
}

class Mutation$SceneAddO$sceneAddO {
  Mutation$SceneAddO$sceneAddO({
    required this.count,
    this.$__typename = 'HistoryMutationResult',
  });

  factory Mutation$SceneAddO$sceneAddO.fromJson(Map<String, dynamic> json) {
    final l$count = json['count'];
    final l$$__typename = json['__typename'];
    return Mutation$SceneAddO$sceneAddO(
      count: (l$count as int),
      $__typename: (l$$__typename as String),
    );
  }

  final int count;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$count = count;
    _resultData['count'] = l$count;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$count = count;
    final l$$__typename = $__typename;
    return Object.hashAll([l$count, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$SceneAddO$sceneAddO ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$count = count;
    final lOther$count = other.count;
    if (l$count != lOther$count) {
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

extension UtilityExtension$Mutation$SceneAddO$sceneAddO
    on Mutation$SceneAddO$sceneAddO {
  CopyWith$Mutation$SceneAddO$sceneAddO<Mutation$SceneAddO$sceneAddO>
  get copyWith => CopyWith$Mutation$SceneAddO$sceneAddO(this, (i) => i);
}

abstract class CopyWith$Mutation$SceneAddO$sceneAddO<TRes> {
  factory CopyWith$Mutation$SceneAddO$sceneAddO(
    Mutation$SceneAddO$sceneAddO instance,
    TRes Function(Mutation$SceneAddO$sceneAddO) then,
  ) = _CopyWithImpl$Mutation$SceneAddO$sceneAddO;

  factory CopyWith$Mutation$SceneAddO$sceneAddO.stub(TRes res) =
      _CopyWithStubImpl$Mutation$SceneAddO$sceneAddO;

  TRes call({int? count, String? $__typename});
}

class _CopyWithImpl$Mutation$SceneAddO$sceneAddO<TRes>
    implements CopyWith$Mutation$SceneAddO$sceneAddO<TRes> {
  _CopyWithImpl$Mutation$SceneAddO$sceneAddO(this._instance, this._then);

  final Mutation$SceneAddO$sceneAddO _instance;

  final TRes Function(Mutation$SceneAddO$sceneAddO) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? count = _undefined, Object? $__typename = _undefined}) =>
      _then(
        Mutation$SceneAddO$sceneAddO(
          count: count == _undefined || count == null
              ? _instance.count
              : (count as int),
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String),
        ),
      );
}

class _CopyWithStubImpl$Mutation$SceneAddO$sceneAddO<TRes>
    implements CopyWith$Mutation$SceneAddO$sceneAddO<TRes> {
  _CopyWithStubImpl$Mutation$SceneAddO$sceneAddO(this._res);

  TRes _res;

  call({int? count, String? $__typename}) => _res;
}

class Variables$Mutation$SceneAddPlay {
  factory Variables$Mutation$SceneAddPlay({required String id}) =>
      Variables$Mutation$SceneAddPlay._({r'id': id});

  Variables$Mutation$SceneAddPlay._(this._$data);

  factory Variables$Mutation$SceneAddPlay.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$id = data['id'];
    result$data['id'] = (l$id as String);
    return Variables$Mutation$SceneAddPlay._(result$data);
  }

  Map<String, dynamic> _$data;

  String get id => (_$data['id'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$id = id;
    result$data['id'] = l$id;
    return result$data;
  }

  CopyWith$Variables$Mutation$SceneAddPlay<Variables$Mutation$SceneAddPlay>
  get copyWith => CopyWith$Variables$Mutation$SceneAddPlay(this, (i) => i);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$SceneAddPlay ||
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

abstract class CopyWith$Variables$Mutation$SceneAddPlay<TRes> {
  factory CopyWith$Variables$Mutation$SceneAddPlay(
    Variables$Mutation$SceneAddPlay instance,
    TRes Function(Variables$Mutation$SceneAddPlay) then,
  ) = _CopyWithImpl$Variables$Mutation$SceneAddPlay;

  factory CopyWith$Variables$Mutation$SceneAddPlay.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$SceneAddPlay;

  TRes call({String? id});
}

class _CopyWithImpl$Variables$Mutation$SceneAddPlay<TRes>
    implements CopyWith$Variables$Mutation$SceneAddPlay<TRes> {
  _CopyWithImpl$Variables$Mutation$SceneAddPlay(this._instance, this._then);

  final Variables$Mutation$SceneAddPlay _instance;

  final TRes Function(Variables$Mutation$SceneAddPlay) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? id = _undefined}) => _then(
    Variables$Mutation$SceneAddPlay._({
      ..._instance._$data,
      if (id != _undefined && id != null) 'id': (id as String),
    }),
  );
}

class _CopyWithStubImpl$Variables$Mutation$SceneAddPlay<TRes>
    implements CopyWith$Variables$Mutation$SceneAddPlay<TRes> {
  _CopyWithStubImpl$Variables$Mutation$SceneAddPlay(this._res);

  TRes _res;

  call({String? id}) => _res;
}

class Mutation$SceneAddPlay {
  Mutation$SceneAddPlay({
    required this.sceneAddPlay,
    this.$__typename = 'Mutation',
  });

  factory Mutation$SceneAddPlay.fromJson(Map<String, dynamic> json) {
    final l$sceneAddPlay = json['sceneAddPlay'];
    final l$$__typename = json['__typename'];
    return Mutation$SceneAddPlay(
      sceneAddPlay: Mutation$SceneAddPlay$sceneAddPlay.fromJson(
        (l$sceneAddPlay as Map<String, dynamic>),
      ),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$SceneAddPlay$sceneAddPlay sceneAddPlay;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$sceneAddPlay = sceneAddPlay;
    _resultData['sceneAddPlay'] = l$sceneAddPlay.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$sceneAddPlay = sceneAddPlay;
    final l$$__typename = $__typename;
    return Object.hashAll([l$sceneAddPlay, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$SceneAddPlay || runtimeType != other.runtimeType) {
      return false;
    }
    final l$sceneAddPlay = sceneAddPlay;
    final lOther$sceneAddPlay = other.sceneAddPlay;
    if (l$sceneAddPlay != lOther$sceneAddPlay) {
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

extension UtilityExtension$Mutation$SceneAddPlay on Mutation$SceneAddPlay {
  CopyWith$Mutation$SceneAddPlay<Mutation$SceneAddPlay> get copyWith =>
      CopyWith$Mutation$SceneAddPlay(this, (i) => i);
}

abstract class CopyWith$Mutation$SceneAddPlay<TRes> {
  factory CopyWith$Mutation$SceneAddPlay(
    Mutation$SceneAddPlay instance,
    TRes Function(Mutation$SceneAddPlay) then,
  ) = _CopyWithImpl$Mutation$SceneAddPlay;

  factory CopyWith$Mutation$SceneAddPlay.stub(TRes res) =
      _CopyWithStubImpl$Mutation$SceneAddPlay;

  TRes call({
    Mutation$SceneAddPlay$sceneAddPlay? sceneAddPlay,
    String? $__typename,
  });
  CopyWith$Mutation$SceneAddPlay$sceneAddPlay<TRes> get sceneAddPlay;
}

class _CopyWithImpl$Mutation$SceneAddPlay<TRes>
    implements CopyWith$Mutation$SceneAddPlay<TRes> {
  _CopyWithImpl$Mutation$SceneAddPlay(this._instance, this._then);

  final Mutation$SceneAddPlay _instance;

  final TRes Function(Mutation$SceneAddPlay) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? sceneAddPlay = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Mutation$SceneAddPlay(
      sceneAddPlay: sceneAddPlay == _undefined || sceneAddPlay == null
          ? _instance.sceneAddPlay
          : (sceneAddPlay as Mutation$SceneAddPlay$sceneAddPlay),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  CopyWith$Mutation$SceneAddPlay$sceneAddPlay<TRes> get sceneAddPlay {
    final local$sceneAddPlay = _instance.sceneAddPlay;
    return CopyWith$Mutation$SceneAddPlay$sceneAddPlay(
      local$sceneAddPlay,
      (e) => call(sceneAddPlay: e),
    );
  }
}

class _CopyWithStubImpl$Mutation$SceneAddPlay<TRes>
    implements CopyWith$Mutation$SceneAddPlay<TRes> {
  _CopyWithStubImpl$Mutation$SceneAddPlay(this._res);

  TRes _res;

  call({
    Mutation$SceneAddPlay$sceneAddPlay? sceneAddPlay,
    String? $__typename,
  }) => _res;

  CopyWith$Mutation$SceneAddPlay$sceneAddPlay<TRes> get sceneAddPlay =>
      CopyWith$Mutation$SceneAddPlay$sceneAddPlay.stub(_res);
}

const documentNodeMutationSceneAddPlay = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.mutation,
      name: NameNode(value: 'SceneAddPlay'),
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
            name: NameNode(value: 'sceneAddPlay'),
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
                  name: NameNode(value: 'count'),
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
Mutation$SceneAddPlay _parserFn$Mutation$SceneAddPlay(
  Map<String, dynamic> data,
) => Mutation$SceneAddPlay.fromJson(data);
typedef OnMutationCompleted$Mutation$SceneAddPlay =
    FutureOr<void> Function(Map<String, dynamic>?, Mutation$SceneAddPlay?);

class Options$Mutation$SceneAddPlay
    extends graphql.MutationOptions<Mutation$SceneAddPlay> {
  Options$Mutation$SceneAddPlay({
    String? operationName,
    required Variables$Mutation$SceneAddPlay variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$SceneAddPlay? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$SceneAddPlay? onCompleted,
    graphql.OnMutationUpdate<Mutation$SceneAddPlay>? update,
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
                 data == null ? null : _parserFn$Mutation$SceneAddPlay(data),
               ),
         update: update,
         onError: onError,
         document: documentNodeMutationSceneAddPlay,
         parserFn: _parserFn$Mutation$SceneAddPlay,
       );

  final OnMutationCompleted$Mutation$SceneAddPlay? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
    ...super.onCompleted == null
        ? super.properties
        : super.properties.where((property) => property != onCompleted),
    onCompletedWithParsed,
  ];
}

class WatchOptions$Mutation$SceneAddPlay
    extends graphql.WatchQueryOptions<Mutation$SceneAddPlay> {
  WatchOptions$Mutation$SceneAddPlay({
    String? operationName,
    required Variables$Mutation$SceneAddPlay variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$SceneAddPlay? typedOptimisticResult,
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
         document: documentNodeMutationSceneAddPlay,
         pollInterval: pollInterval,
         eagerlyFetchResults: eagerlyFetchResults,
         carryForwardDataOnException: carryForwardDataOnException,
         fetchResults: fetchResults,
         parserFn: _parserFn$Mutation$SceneAddPlay,
       );
}

extension ClientExtension$Mutation$SceneAddPlay on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$SceneAddPlay>> mutate$SceneAddPlay(
    Options$Mutation$SceneAddPlay options,
  ) async => await this.mutate(options);

  graphql.ObservableQuery<Mutation$SceneAddPlay> watchMutation$SceneAddPlay(
    WatchOptions$Mutation$SceneAddPlay options,
  ) => this.watchMutation(options);
}

class Mutation$SceneAddPlay$sceneAddPlay {
  Mutation$SceneAddPlay$sceneAddPlay({
    required this.count,
    this.$__typename = 'HistoryMutationResult',
  });

  factory Mutation$SceneAddPlay$sceneAddPlay.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$count = json['count'];
    final l$$__typename = json['__typename'];
    return Mutation$SceneAddPlay$sceneAddPlay(
      count: (l$count as int),
      $__typename: (l$$__typename as String),
    );
  }

  final int count;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$count = count;
    _resultData['count'] = l$count;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$count = count;
    final l$$__typename = $__typename;
    return Object.hashAll([l$count, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$SceneAddPlay$sceneAddPlay ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$count = count;
    final lOther$count = other.count;
    if (l$count != lOther$count) {
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

extension UtilityExtension$Mutation$SceneAddPlay$sceneAddPlay
    on Mutation$SceneAddPlay$sceneAddPlay {
  CopyWith$Mutation$SceneAddPlay$sceneAddPlay<
    Mutation$SceneAddPlay$sceneAddPlay
  >
  get copyWith => CopyWith$Mutation$SceneAddPlay$sceneAddPlay(this, (i) => i);
}

abstract class CopyWith$Mutation$SceneAddPlay$sceneAddPlay<TRes> {
  factory CopyWith$Mutation$SceneAddPlay$sceneAddPlay(
    Mutation$SceneAddPlay$sceneAddPlay instance,
    TRes Function(Mutation$SceneAddPlay$sceneAddPlay) then,
  ) = _CopyWithImpl$Mutation$SceneAddPlay$sceneAddPlay;

  factory CopyWith$Mutation$SceneAddPlay$sceneAddPlay.stub(TRes res) =
      _CopyWithStubImpl$Mutation$SceneAddPlay$sceneAddPlay;

  TRes call({int? count, String? $__typename});
}

class _CopyWithImpl$Mutation$SceneAddPlay$sceneAddPlay<TRes>
    implements CopyWith$Mutation$SceneAddPlay$sceneAddPlay<TRes> {
  _CopyWithImpl$Mutation$SceneAddPlay$sceneAddPlay(this._instance, this._then);

  final Mutation$SceneAddPlay$sceneAddPlay _instance;

  final TRes Function(Mutation$SceneAddPlay$sceneAddPlay) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? count = _undefined, Object? $__typename = _undefined}) =>
      _then(
        Mutation$SceneAddPlay$sceneAddPlay(
          count: count == _undefined || count == null
              ? _instance.count
              : (count as int),
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String),
        ),
      );
}

class _CopyWithStubImpl$Mutation$SceneAddPlay$sceneAddPlay<TRes>
    implements CopyWith$Mutation$SceneAddPlay$sceneAddPlay<TRes> {
  _CopyWithStubImpl$Mutation$SceneAddPlay$sceneAddPlay(this._res);

  TRes _res;

  call({int? count, String? $__typename}) => _res;
}

class Variables$Query$ListScrapers {
  factory Variables$Query$ListScrapers({
    required List<Enum$ScrapeContentType> types,
  }) => Variables$Query$ListScrapers._({r'types': types});

  Variables$Query$ListScrapers._(this._$data);

  factory Variables$Query$ListScrapers.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$types = data['types'];
    result$data['types'] = (l$types as List<dynamic>)
        .map((e) => fromJson$Enum$ScrapeContentType((e as String)))
        .toList();
    return Variables$Query$ListScrapers._(result$data);
  }

  Map<String, dynamic> _$data;

  List<Enum$ScrapeContentType> get types =>
      (_$data['types'] as List<Enum$ScrapeContentType>);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$types = types;
    result$data['types'] = l$types
        .map((e) => toJson$Enum$ScrapeContentType(e))
        .toList();
    return result$data;
  }

  CopyWith$Variables$Query$ListScrapers<Variables$Query$ListScrapers>
  get copyWith => CopyWith$Variables$Query$ListScrapers(this, (i) => i);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$ListScrapers ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$types = types;
    final lOther$types = other.types;
    if (l$types.length != lOther$types.length) {
      return false;
    }
    for (int i = 0; i < l$types.length; i++) {
      final l$types$entry = l$types[i];
      final lOther$types$entry = lOther$types[i];
      if (l$types$entry != lOther$types$entry) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode {
    final l$types = types;
    return Object.hashAll([Object.hashAll(l$types.map((v) => v))]);
  }
}

abstract class CopyWith$Variables$Query$ListScrapers<TRes> {
  factory CopyWith$Variables$Query$ListScrapers(
    Variables$Query$ListScrapers instance,
    TRes Function(Variables$Query$ListScrapers) then,
  ) = _CopyWithImpl$Variables$Query$ListScrapers;

  factory CopyWith$Variables$Query$ListScrapers.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$ListScrapers;

  TRes call({List<Enum$ScrapeContentType>? types});
}

class _CopyWithImpl$Variables$Query$ListScrapers<TRes>
    implements CopyWith$Variables$Query$ListScrapers<TRes> {
  _CopyWithImpl$Variables$Query$ListScrapers(this._instance, this._then);

  final Variables$Query$ListScrapers _instance;

  final TRes Function(Variables$Query$ListScrapers) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? types = _undefined}) => _then(
    Variables$Query$ListScrapers._({
      ..._instance._$data,
      if (types != _undefined && types != null)
        'types': (types as List<Enum$ScrapeContentType>),
    }),
  );
}

class _CopyWithStubImpl$Variables$Query$ListScrapers<TRes>
    implements CopyWith$Variables$Query$ListScrapers<TRes> {
  _CopyWithStubImpl$Variables$Query$ListScrapers(this._res);

  TRes _res;

  call({List<Enum$ScrapeContentType>? types}) => _res;
}

class Query$ListScrapers {
  Query$ListScrapers({required this.listScrapers, this.$__typename = 'Query'});

  factory Query$ListScrapers.fromJson(Map<String, dynamic> json) {
    final l$listScrapers = json['listScrapers'];
    final l$$__typename = json['__typename'];
    return Query$ListScrapers(
      listScrapers: (l$listScrapers as List<dynamic>)
          .map(
            (e) => Query$ListScrapers$listScrapers.fromJson(
              (e as Map<String, dynamic>),
            ),
          )
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Query$ListScrapers$listScrapers> listScrapers;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$listScrapers = listScrapers;
    _resultData['listScrapers'] = l$listScrapers
        .map((e) => e.toJson())
        .toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$listScrapers = listScrapers;
    final l$$__typename = $__typename;
    return Object.hashAll([
      Object.hashAll(l$listScrapers.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$ListScrapers || runtimeType != other.runtimeType) {
      return false;
    }
    final l$listScrapers = listScrapers;
    final lOther$listScrapers = other.listScrapers;
    if (l$listScrapers.length != lOther$listScrapers.length) {
      return false;
    }
    for (int i = 0; i < l$listScrapers.length; i++) {
      final l$listScrapers$entry = l$listScrapers[i];
      final lOther$listScrapers$entry = lOther$listScrapers[i];
      if (l$listScrapers$entry != lOther$listScrapers$entry) {
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

extension UtilityExtension$Query$ListScrapers on Query$ListScrapers {
  CopyWith$Query$ListScrapers<Query$ListScrapers> get copyWith =>
      CopyWith$Query$ListScrapers(this, (i) => i);
}

abstract class CopyWith$Query$ListScrapers<TRes> {
  factory CopyWith$Query$ListScrapers(
    Query$ListScrapers instance,
    TRes Function(Query$ListScrapers) then,
  ) = _CopyWithImpl$Query$ListScrapers;

  factory CopyWith$Query$ListScrapers.stub(TRes res) =
      _CopyWithStubImpl$Query$ListScrapers;

  TRes call({
    List<Query$ListScrapers$listScrapers>? listScrapers,
    String? $__typename,
  });
  TRes listScrapers(
    Iterable<Query$ListScrapers$listScrapers> Function(
      Iterable<
        CopyWith$Query$ListScrapers$listScrapers<
          Query$ListScrapers$listScrapers
        >
      >,
    )
    _fn,
  );
}

class _CopyWithImpl$Query$ListScrapers<TRes>
    implements CopyWith$Query$ListScrapers<TRes> {
  _CopyWithImpl$Query$ListScrapers(this._instance, this._then);

  final Query$ListScrapers _instance;

  final TRes Function(Query$ListScrapers) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? listScrapers = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$ListScrapers(
      listScrapers: listScrapers == _undefined || listScrapers == null
          ? _instance.listScrapers
          : (listScrapers as List<Query$ListScrapers$listScrapers>),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  TRes listScrapers(
    Iterable<Query$ListScrapers$listScrapers> Function(
      Iterable<
        CopyWith$Query$ListScrapers$listScrapers<
          Query$ListScrapers$listScrapers
        >
      >,
    )
    _fn,
  ) => call(
    listScrapers: _fn(
      _instance.listScrapers.map(
        (e) => CopyWith$Query$ListScrapers$listScrapers(e, (i) => i),
      ),
    ).toList(),
  );
}

class _CopyWithStubImpl$Query$ListScrapers<TRes>
    implements CopyWith$Query$ListScrapers<TRes> {
  _CopyWithStubImpl$Query$ListScrapers(this._res);

  TRes _res;

  call({
    List<Query$ListScrapers$listScrapers>? listScrapers,
    String? $__typename,
  }) => _res;

  listScrapers(_fn) => _res;
}

const documentNodeQueryListScrapers = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.query,
      name: NameNode(value: 'ListScrapers'),
      variableDefinitions: [
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'types')),
          type: ListTypeNode(
            type: NamedTypeNode(
              name: NameNode(value: 'ScrapeContentType'),
              isNonNull: true,
            ),
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
            name: NameNode(value: 'listScrapers'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'types'),
                value: VariableNode(name: NameNode(value: 'types')),
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
                  name: NameNode(value: 'name'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
                FieldNode(
                  name: NameNode(value: 'scene'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: SelectionSetNode(
                    selections: [
                      FieldNode(
                        name: NameNode(value: 'urls'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                      FieldNode(
                        name: NameNode(value: 'supported_scrapes'),
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
                  name: NameNode(value: 'performer'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: SelectionSetNode(
                    selections: [
                      FieldNode(
                        name: NameNode(value: 'urls'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                      FieldNode(
                        name: NameNode(value: 'supported_scrapes'),
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
                  name: NameNode(value: 'gallery'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: SelectionSetNode(
                    selections: [
                      FieldNode(
                        name: NameNode(value: 'urls'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                      FieldNode(
                        name: NameNode(value: 'supported_scrapes'),
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
                  name: NameNode(value: 'image'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: SelectionSetNode(
                    selections: [
                      FieldNode(
                        name: NameNode(value: 'urls'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                      FieldNode(
                        name: NameNode(value: 'supported_scrapes'),
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
Query$ListScrapers _parserFn$Query$ListScrapers(Map<String, dynamic> data) =>
    Query$ListScrapers.fromJson(data);
typedef OnQueryComplete$Query$ListScrapers =
    FutureOr<void> Function(Map<String, dynamic>?, Query$ListScrapers?);

class Options$Query$ListScrapers
    extends graphql.QueryOptions<Query$ListScrapers> {
  Options$Query$ListScrapers({
    String? operationName,
    required Variables$Query$ListScrapers variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$ListScrapers? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$ListScrapers? onComplete,
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
                 data == null ? null : _parserFn$Query$ListScrapers(data),
               ),
         onError: onError,
         document: documentNodeQueryListScrapers,
         parserFn: _parserFn$Query$ListScrapers,
       );

  final OnQueryComplete$Query$ListScrapers? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
    ...super.onComplete == null
        ? super.properties
        : super.properties.where((property) => property != onComplete),
    onCompleteWithParsed,
  ];
}

class WatchOptions$Query$ListScrapers
    extends graphql.WatchQueryOptions<Query$ListScrapers> {
  WatchOptions$Query$ListScrapers({
    String? operationName,
    required Variables$Query$ListScrapers variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$ListScrapers? typedOptimisticResult,
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
         document: documentNodeQueryListScrapers,
         pollInterval: pollInterval,
         eagerlyFetchResults: eagerlyFetchResults,
         carryForwardDataOnException: carryForwardDataOnException,
         fetchResults: fetchResults,
         parserFn: _parserFn$Query$ListScrapers,
       );
}

class FetchMoreOptions$Query$ListScrapers extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$ListScrapers({
    required graphql.UpdateQuery updateQuery,
    required Variables$Query$ListScrapers variables,
  }) : super(
         updateQuery: updateQuery,
         variables: variables.toJson(),
         document: documentNodeQueryListScrapers,
       );
}

extension ClientExtension$Query$ListScrapers on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$ListScrapers>> query$ListScrapers(
    Options$Query$ListScrapers options,
  ) async => await this.query(options);

  graphql.ObservableQuery<Query$ListScrapers> watchQuery$ListScrapers(
    WatchOptions$Query$ListScrapers options,
  ) => this.watchQuery(options);

  void writeQuery$ListScrapers({
    required Query$ListScrapers data,
    required Variables$Query$ListScrapers variables,
    bool broadcast = true,
  }) => this.writeQuery(
    graphql.Request(
      operation: graphql.Operation(document: documentNodeQueryListScrapers),
      variables: variables.toJson(),
    ),
    data: data.toJson(),
    broadcast: broadcast,
  );

  Query$ListScrapers? readQuery$ListScrapers({
    required Variables$Query$ListScrapers variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(document: documentNodeQueryListScrapers),
        variables: variables.toJson(),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$ListScrapers.fromJson(result);
  }
}

class Query$ListScrapers$listScrapers {
  Query$ListScrapers$listScrapers({
    required this.id,
    required this.name,
    this.scene,
    this.performer,
    this.gallery,
    this.image,
    this.$__typename = 'Scraper',
  });

  factory Query$ListScrapers$listScrapers.fromJson(Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$name = json['name'];
    final l$scene = json['scene'];
    final l$performer = json['performer'];
    final l$gallery = json['gallery'];
    final l$image = json['image'];
    final l$$__typename = json['__typename'];
    return Query$ListScrapers$listScrapers(
      id: (l$id as String),
      name: (l$name as String),
      scene: l$scene == null
          ? null
          : Query$ListScrapers$listScrapers$scene.fromJson(
              (l$scene as Map<String, dynamic>),
            ),
      performer: l$performer == null
          ? null
          : Query$ListScrapers$listScrapers$performer.fromJson(
              (l$performer as Map<String, dynamic>),
            ),
      gallery: l$gallery == null
          ? null
          : Query$ListScrapers$listScrapers$gallery.fromJson(
              (l$gallery as Map<String, dynamic>),
            ),
      image: l$image == null
          ? null
          : Query$ListScrapers$listScrapers$image.fromJson(
              (l$image as Map<String, dynamic>),
            ),
      $__typename: (l$$__typename as String),
    );
  }

  final String id;

  final String name;

  final Query$ListScrapers$listScrapers$scene? scene;

  final Query$ListScrapers$listScrapers$performer? performer;

  final Query$ListScrapers$listScrapers$gallery? gallery;

  final Query$ListScrapers$listScrapers$image? image;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$name = name;
    _resultData['name'] = l$name;
    final l$scene = scene;
    _resultData['scene'] = l$scene?.toJson();
    final l$performer = performer;
    _resultData['performer'] = l$performer?.toJson();
    final l$gallery = gallery;
    _resultData['gallery'] = l$gallery?.toJson();
    final l$image = image;
    _resultData['image'] = l$image?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$name = name;
    final l$scene = scene;
    final l$performer = performer;
    final l$gallery = gallery;
    final l$image = image;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$name,
      l$scene,
      l$performer,
      l$gallery,
      l$image,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$ListScrapers$listScrapers ||
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
    final l$scene = scene;
    final lOther$scene = other.scene;
    if (l$scene != lOther$scene) {
      return false;
    }
    final l$performer = performer;
    final lOther$performer = other.performer;
    if (l$performer != lOther$performer) {
      return false;
    }
    final l$gallery = gallery;
    final lOther$gallery = other.gallery;
    if (l$gallery != lOther$gallery) {
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

extension UtilityExtension$Query$ListScrapers$listScrapers
    on Query$ListScrapers$listScrapers {
  CopyWith$Query$ListScrapers$listScrapers<Query$ListScrapers$listScrapers>
  get copyWith => CopyWith$Query$ListScrapers$listScrapers(this, (i) => i);
}

abstract class CopyWith$Query$ListScrapers$listScrapers<TRes> {
  factory CopyWith$Query$ListScrapers$listScrapers(
    Query$ListScrapers$listScrapers instance,
    TRes Function(Query$ListScrapers$listScrapers) then,
  ) = _CopyWithImpl$Query$ListScrapers$listScrapers;

  factory CopyWith$Query$ListScrapers$listScrapers.stub(TRes res) =
      _CopyWithStubImpl$Query$ListScrapers$listScrapers;

  TRes call({
    String? id,
    String? name,
    Query$ListScrapers$listScrapers$scene? scene,
    Query$ListScrapers$listScrapers$performer? performer,
    Query$ListScrapers$listScrapers$gallery? gallery,
    Query$ListScrapers$listScrapers$image? image,
    String? $__typename,
  });
  CopyWith$Query$ListScrapers$listScrapers$scene<TRes> get scene;
  CopyWith$Query$ListScrapers$listScrapers$performer<TRes> get performer;
  CopyWith$Query$ListScrapers$listScrapers$gallery<TRes> get gallery;
  CopyWith$Query$ListScrapers$listScrapers$image<TRes> get image;
}

class _CopyWithImpl$Query$ListScrapers$listScrapers<TRes>
    implements CopyWith$Query$ListScrapers$listScrapers<TRes> {
  _CopyWithImpl$Query$ListScrapers$listScrapers(this._instance, this._then);

  final Query$ListScrapers$listScrapers _instance;

  final TRes Function(Query$ListScrapers$listScrapers) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? name = _undefined,
    Object? scene = _undefined,
    Object? performer = _undefined,
    Object? gallery = _undefined,
    Object? image = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$ListScrapers$listScrapers(
      id: id == _undefined || id == null ? _instance.id : (id as String),
      name: name == _undefined || name == null
          ? _instance.name
          : (name as String),
      scene: scene == _undefined
          ? _instance.scene
          : (scene as Query$ListScrapers$listScrapers$scene?),
      performer: performer == _undefined
          ? _instance.performer
          : (performer as Query$ListScrapers$listScrapers$performer?),
      gallery: gallery == _undefined
          ? _instance.gallery
          : (gallery as Query$ListScrapers$listScrapers$gallery?),
      image: image == _undefined
          ? _instance.image
          : (image as Query$ListScrapers$listScrapers$image?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  CopyWith$Query$ListScrapers$listScrapers$scene<TRes> get scene {
    final local$scene = _instance.scene;
    return local$scene == null
        ? CopyWith$Query$ListScrapers$listScrapers$scene.stub(_then(_instance))
        : CopyWith$Query$ListScrapers$listScrapers$scene(
            local$scene,
            (e) => call(scene: e),
          );
  }

  CopyWith$Query$ListScrapers$listScrapers$performer<TRes> get performer {
    final local$performer = _instance.performer;
    return local$performer == null
        ? CopyWith$Query$ListScrapers$listScrapers$performer.stub(
            _then(_instance),
          )
        : CopyWith$Query$ListScrapers$listScrapers$performer(
            local$performer,
            (e) => call(performer: e),
          );
  }

  CopyWith$Query$ListScrapers$listScrapers$gallery<TRes> get gallery {
    final local$gallery = _instance.gallery;
    return local$gallery == null
        ? CopyWith$Query$ListScrapers$listScrapers$gallery.stub(
            _then(_instance),
          )
        : CopyWith$Query$ListScrapers$listScrapers$gallery(
            local$gallery,
            (e) => call(gallery: e),
          );
  }

  CopyWith$Query$ListScrapers$listScrapers$image<TRes> get image {
    final local$image = _instance.image;
    return local$image == null
        ? CopyWith$Query$ListScrapers$listScrapers$image.stub(_then(_instance))
        : CopyWith$Query$ListScrapers$listScrapers$image(
            local$image,
            (e) => call(image: e),
          );
  }
}

class _CopyWithStubImpl$Query$ListScrapers$listScrapers<TRes>
    implements CopyWith$Query$ListScrapers$listScrapers<TRes> {
  _CopyWithStubImpl$Query$ListScrapers$listScrapers(this._res);

  TRes _res;

  call({
    String? id,
    String? name,
    Query$ListScrapers$listScrapers$scene? scene,
    Query$ListScrapers$listScrapers$performer? performer,
    Query$ListScrapers$listScrapers$gallery? gallery,
    Query$ListScrapers$listScrapers$image? image,
    String? $__typename,
  }) => _res;

  CopyWith$Query$ListScrapers$listScrapers$scene<TRes> get scene =>
      CopyWith$Query$ListScrapers$listScrapers$scene.stub(_res);

  CopyWith$Query$ListScrapers$listScrapers$performer<TRes> get performer =>
      CopyWith$Query$ListScrapers$listScrapers$performer.stub(_res);

  CopyWith$Query$ListScrapers$listScrapers$gallery<TRes> get gallery =>
      CopyWith$Query$ListScrapers$listScrapers$gallery.stub(_res);

  CopyWith$Query$ListScrapers$listScrapers$image<TRes> get image =>
      CopyWith$Query$ListScrapers$listScrapers$image.stub(_res);
}

class Query$ListScrapers$listScrapers$scene {
  Query$ListScrapers$listScrapers$scene({
    this.urls,
    required this.supported_scrapes,
    this.$__typename = 'ScraperSpec',
  });

  factory Query$ListScrapers$listScrapers$scene.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$urls = json['urls'];
    final l$supported_scrapes = json['supported_scrapes'];
    final l$$__typename = json['__typename'];
    return Query$ListScrapers$listScrapers$scene(
      urls: (l$urls as List<dynamic>?)?.map((e) => (e as String)).toList(),
      supported_scrapes: (l$supported_scrapes as List<dynamic>)
          .map((e) => fromJson$Enum$ScrapeType((e as String)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<String>? urls;

  final List<Enum$ScrapeType> supported_scrapes;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$urls = urls;
    _resultData['urls'] = l$urls?.map((e) => e).toList();
    final l$supported_scrapes = supported_scrapes;
    _resultData['supported_scrapes'] = l$supported_scrapes
        .map((e) => toJson$Enum$ScrapeType(e))
        .toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$urls = urls;
    final l$supported_scrapes = supported_scrapes;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$urls == null ? null : Object.hashAll(l$urls.map((v) => v)),
      Object.hashAll(l$supported_scrapes.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$ListScrapers$listScrapers$scene ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$urls = urls;
    final lOther$urls = other.urls;
    if (l$urls != null && lOther$urls != null) {
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
    } else if (l$urls != lOther$urls) {
      return false;
    }
    final l$supported_scrapes = supported_scrapes;
    final lOther$supported_scrapes = other.supported_scrapes;
    if (l$supported_scrapes.length != lOther$supported_scrapes.length) {
      return false;
    }
    for (int i = 0; i < l$supported_scrapes.length; i++) {
      final l$supported_scrapes$entry = l$supported_scrapes[i];
      final lOther$supported_scrapes$entry = lOther$supported_scrapes[i];
      if (l$supported_scrapes$entry != lOther$supported_scrapes$entry) {
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

extension UtilityExtension$Query$ListScrapers$listScrapers$scene
    on Query$ListScrapers$listScrapers$scene {
  CopyWith$Query$ListScrapers$listScrapers$scene<
    Query$ListScrapers$listScrapers$scene
  >
  get copyWith =>
      CopyWith$Query$ListScrapers$listScrapers$scene(this, (i) => i);
}

abstract class CopyWith$Query$ListScrapers$listScrapers$scene<TRes> {
  factory CopyWith$Query$ListScrapers$listScrapers$scene(
    Query$ListScrapers$listScrapers$scene instance,
    TRes Function(Query$ListScrapers$listScrapers$scene) then,
  ) = _CopyWithImpl$Query$ListScrapers$listScrapers$scene;

  factory CopyWith$Query$ListScrapers$listScrapers$scene.stub(TRes res) =
      _CopyWithStubImpl$Query$ListScrapers$listScrapers$scene;

  TRes call({
    List<String>? urls,
    List<Enum$ScrapeType>? supported_scrapes,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$ListScrapers$listScrapers$scene<TRes>
    implements CopyWith$Query$ListScrapers$listScrapers$scene<TRes> {
  _CopyWithImpl$Query$ListScrapers$listScrapers$scene(
    this._instance,
    this._then,
  );

  final Query$ListScrapers$listScrapers$scene _instance;

  final TRes Function(Query$ListScrapers$listScrapers$scene) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? urls = _undefined,
    Object? supported_scrapes = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$ListScrapers$listScrapers$scene(
      urls: urls == _undefined ? _instance.urls : (urls as List<String>?),
      supported_scrapes:
          supported_scrapes == _undefined || supported_scrapes == null
          ? _instance.supported_scrapes
          : (supported_scrapes as List<Enum$ScrapeType>),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Query$ListScrapers$listScrapers$scene<TRes>
    implements CopyWith$Query$ListScrapers$listScrapers$scene<TRes> {
  _CopyWithStubImpl$Query$ListScrapers$listScrapers$scene(this._res);

  TRes _res;

  call({
    List<String>? urls,
    List<Enum$ScrapeType>? supported_scrapes,
    String? $__typename,
  }) => _res;
}

class Query$ListScrapers$listScrapers$performer {
  Query$ListScrapers$listScrapers$performer({
    this.urls,
    required this.supported_scrapes,
    this.$__typename = 'ScraperSpec',
  });

  factory Query$ListScrapers$listScrapers$performer.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$urls = json['urls'];
    final l$supported_scrapes = json['supported_scrapes'];
    final l$$__typename = json['__typename'];
    return Query$ListScrapers$listScrapers$performer(
      urls: (l$urls as List<dynamic>?)?.map((e) => (e as String)).toList(),
      supported_scrapes: (l$supported_scrapes as List<dynamic>)
          .map((e) => fromJson$Enum$ScrapeType((e as String)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<String>? urls;

  final List<Enum$ScrapeType> supported_scrapes;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$urls = urls;
    _resultData['urls'] = l$urls?.map((e) => e).toList();
    final l$supported_scrapes = supported_scrapes;
    _resultData['supported_scrapes'] = l$supported_scrapes
        .map((e) => toJson$Enum$ScrapeType(e))
        .toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$urls = urls;
    final l$supported_scrapes = supported_scrapes;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$urls == null ? null : Object.hashAll(l$urls.map((v) => v)),
      Object.hashAll(l$supported_scrapes.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$ListScrapers$listScrapers$performer ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$urls = urls;
    final lOther$urls = other.urls;
    if (l$urls != null && lOther$urls != null) {
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
    } else if (l$urls != lOther$urls) {
      return false;
    }
    final l$supported_scrapes = supported_scrapes;
    final lOther$supported_scrapes = other.supported_scrapes;
    if (l$supported_scrapes.length != lOther$supported_scrapes.length) {
      return false;
    }
    for (int i = 0; i < l$supported_scrapes.length; i++) {
      final l$supported_scrapes$entry = l$supported_scrapes[i];
      final lOther$supported_scrapes$entry = lOther$supported_scrapes[i];
      if (l$supported_scrapes$entry != lOther$supported_scrapes$entry) {
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

extension UtilityExtension$Query$ListScrapers$listScrapers$performer
    on Query$ListScrapers$listScrapers$performer {
  CopyWith$Query$ListScrapers$listScrapers$performer<
    Query$ListScrapers$listScrapers$performer
  >
  get copyWith =>
      CopyWith$Query$ListScrapers$listScrapers$performer(this, (i) => i);
}

abstract class CopyWith$Query$ListScrapers$listScrapers$performer<TRes> {
  factory CopyWith$Query$ListScrapers$listScrapers$performer(
    Query$ListScrapers$listScrapers$performer instance,
    TRes Function(Query$ListScrapers$listScrapers$performer) then,
  ) = _CopyWithImpl$Query$ListScrapers$listScrapers$performer;

  factory CopyWith$Query$ListScrapers$listScrapers$performer.stub(TRes res) =
      _CopyWithStubImpl$Query$ListScrapers$listScrapers$performer;

  TRes call({
    List<String>? urls,
    List<Enum$ScrapeType>? supported_scrapes,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$ListScrapers$listScrapers$performer<TRes>
    implements CopyWith$Query$ListScrapers$listScrapers$performer<TRes> {
  _CopyWithImpl$Query$ListScrapers$listScrapers$performer(
    this._instance,
    this._then,
  );

  final Query$ListScrapers$listScrapers$performer _instance;

  final TRes Function(Query$ListScrapers$listScrapers$performer) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? urls = _undefined,
    Object? supported_scrapes = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$ListScrapers$listScrapers$performer(
      urls: urls == _undefined ? _instance.urls : (urls as List<String>?),
      supported_scrapes:
          supported_scrapes == _undefined || supported_scrapes == null
          ? _instance.supported_scrapes
          : (supported_scrapes as List<Enum$ScrapeType>),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Query$ListScrapers$listScrapers$performer<TRes>
    implements CopyWith$Query$ListScrapers$listScrapers$performer<TRes> {
  _CopyWithStubImpl$Query$ListScrapers$listScrapers$performer(this._res);

  TRes _res;

  call({
    List<String>? urls,
    List<Enum$ScrapeType>? supported_scrapes,
    String? $__typename,
  }) => _res;
}

class Query$ListScrapers$listScrapers$gallery {
  Query$ListScrapers$listScrapers$gallery({
    this.urls,
    required this.supported_scrapes,
    this.$__typename = 'ScraperSpec',
  });

  factory Query$ListScrapers$listScrapers$gallery.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$urls = json['urls'];
    final l$supported_scrapes = json['supported_scrapes'];
    final l$$__typename = json['__typename'];
    return Query$ListScrapers$listScrapers$gallery(
      urls: (l$urls as List<dynamic>?)?.map((e) => (e as String)).toList(),
      supported_scrapes: (l$supported_scrapes as List<dynamic>)
          .map((e) => fromJson$Enum$ScrapeType((e as String)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<String>? urls;

  final List<Enum$ScrapeType> supported_scrapes;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$urls = urls;
    _resultData['urls'] = l$urls?.map((e) => e).toList();
    final l$supported_scrapes = supported_scrapes;
    _resultData['supported_scrapes'] = l$supported_scrapes
        .map((e) => toJson$Enum$ScrapeType(e))
        .toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$urls = urls;
    final l$supported_scrapes = supported_scrapes;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$urls == null ? null : Object.hashAll(l$urls.map((v) => v)),
      Object.hashAll(l$supported_scrapes.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$ListScrapers$listScrapers$gallery ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$urls = urls;
    final lOther$urls = other.urls;
    if (l$urls != null && lOther$urls != null) {
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
    } else if (l$urls != lOther$urls) {
      return false;
    }
    final l$supported_scrapes = supported_scrapes;
    final lOther$supported_scrapes = other.supported_scrapes;
    if (l$supported_scrapes.length != lOther$supported_scrapes.length) {
      return false;
    }
    for (int i = 0; i < l$supported_scrapes.length; i++) {
      final l$supported_scrapes$entry = l$supported_scrapes[i];
      final lOther$supported_scrapes$entry = lOther$supported_scrapes[i];
      if (l$supported_scrapes$entry != lOther$supported_scrapes$entry) {
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

extension UtilityExtension$Query$ListScrapers$listScrapers$gallery
    on Query$ListScrapers$listScrapers$gallery {
  CopyWith$Query$ListScrapers$listScrapers$gallery<
    Query$ListScrapers$listScrapers$gallery
  >
  get copyWith =>
      CopyWith$Query$ListScrapers$listScrapers$gallery(this, (i) => i);
}

abstract class CopyWith$Query$ListScrapers$listScrapers$gallery<TRes> {
  factory CopyWith$Query$ListScrapers$listScrapers$gallery(
    Query$ListScrapers$listScrapers$gallery instance,
    TRes Function(Query$ListScrapers$listScrapers$gallery) then,
  ) = _CopyWithImpl$Query$ListScrapers$listScrapers$gallery;

  factory CopyWith$Query$ListScrapers$listScrapers$gallery.stub(TRes res) =
      _CopyWithStubImpl$Query$ListScrapers$listScrapers$gallery;

  TRes call({
    List<String>? urls,
    List<Enum$ScrapeType>? supported_scrapes,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$ListScrapers$listScrapers$gallery<TRes>
    implements CopyWith$Query$ListScrapers$listScrapers$gallery<TRes> {
  _CopyWithImpl$Query$ListScrapers$listScrapers$gallery(
    this._instance,
    this._then,
  );

  final Query$ListScrapers$listScrapers$gallery _instance;

  final TRes Function(Query$ListScrapers$listScrapers$gallery) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? urls = _undefined,
    Object? supported_scrapes = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$ListScrapers$listScrapers$gallery(
      urls: urls == _undefined ? _instance.urls : (urls as List<String>?),
      supported_scrapes:
          supported_scrapes == _undefined || supported_scrapes == null
          ? _instance.supported_scrapes
          : (supported_scrapes as List<Enum$ScrapeType>),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Query$ListScrapers$listScrapers$gallery<TRes>
    implements CopyWith$Query$ListScrapers$listScrapers$gallery<TRes> {
  _CopyWithStubImpl$Query$ListScrapers$listScrapers$gallery(this._res);

  TRes _res;

  call({
    List<String>? urls,
    List<Enum$ScrapeType>? supported_scrapes,
    String? $__typename,
  }) => _res;
}

class Query$ListScrapers$listScrapers$image {
  Query$ListScrapers$listScrapers$image({
    this.urls,
    required this.supported_scrapes,
    this.$__typename = 'ScraperSpec',
  });

  factory Query$ListScrapers$listScrapers$image.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$urls = json['urls'];
    final l$supported_scrapes = json['supported_scrapes'];
    final l$$__typename = json['__typename'];
    return Query$ListScrapers$listScrapers$image(
      urls: (l$urls as List<dynamic>?)?.map((e) => (e as String)).toList(),
      supported_scrapes: (l$supported_scrapes as List<dynamic>)
          .map((e) => fromJson$Enum$ScrapeType((e as String)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<String>? urls;

  final List<Enum$ScrapeType> supported_scrapes;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$urls = urls;
    _resultData['urls'] = l$urls?.map((e) => e).toList();
    final l$supported_scrapes = supported_scrapes;
    _resultData['supported_scrapes'] = l$supported_scrapes
        .map((e) => toJson$Enum$ScrapeType(e))
        .toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$urls = urls;
    final l$supported_scrapes = supported_scrapes;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$urls == null ? null : Object.hashAll(l$urls.map((v) => v)),
      Object.hashAll(l$supported_scrapes.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$ListScrapers$listScrapers$image ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$urls = urls;
    final lOther$urls = other.urls;
    if (l$urls != null && lOther$urls != null) {
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
    } else if (l$urls != lOther$urls) {
      return false;
    }
    final l$supported_scrapes = supported_scrapes;
    final lOther$supported_scrapes = other.supported_scrapes;
    if (l$supported_scrapes.length != lOther$supported_scrapes.length) {
      return false;
    }
    for (int i = 0; i < l$supported_scrapes.length; i++) {
      final l$supported_scrapes$entry = l$supported_scrapes[i];
      final lOther$supported_scrapes$entry = lOther$supported_scrapes[i];
      if (l$supported_scrapes$entry != lOther$supported_scrapes$entry) {
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

extension UtilityExtension$Query$ListScrapers$listScrapers$image
    on Query$ListScrapers$listScrapers$image {
  CopyWith$Query$ListScrapers$listScrapers$image<
    Query$ListScrapers$listScrapers$image
  >
  get copyWith =>
      CopyWith$Query$ListScrapers$listScrapers$image(this, (i) => i);
}

abstract class CopyWith$Query$ListScrapers$listScrapers$image<TRes> {
  factory CopyWith$Query$ListScrapers$listScrapers$image(
    Query$ListScrapers$listScrapers$image instance,
    TRes Function(Query$ListScrapers$listScrapers$image) then,
  ) = _CopyWithImpl$Query$ListScrapers$listScrapers$image;

  factory CopyWith$Query$ListScrapers$listScrapers$image.stub(TRes res) =
      _CopyWithStubImpl$Query$ListScrapers$listScrapers$image;

  TRes call({
    List<String>? urls,
    List<Enum$ScrapeType>? supported_scrapes,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$ListScrapers$listScrapers$image<TRes>
    implements CopyWith$Query$ListScrapers$listScrapers$image<TRes> {
  _CopyWithImpl$Query$ListScrapers$listScrapers$image(
    this._instance,
    this._then,
  );

  final Query$ListScrapers$listScrapers$image _instance;

  final TRes Function(Query$ListScrapers$listScrapers$image) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? urls = _undefined,
    Object? supported_scrapes = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$ListScrapers$listScrapers$image(
      urls: urls == _undefined ? _instance.urls : (urls as List<String>?),
      supported_scrapes:
          supported_scrapes == _undefined || supported_scrapes == null
          ? _instance.supported_scrapes
          : (supported_scrapes as List<Enum$ScrapeType>),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Query$ListScrapers$listScrapers$image<TRes>
    implements CopyWith$Query$ListScrapers$listScrapers$image<TRes> {
  _CopyWithStubImpl$Query$ListScrapers$listScrapers$image(this._res);

  TRes _res;

  call({
    List<String>? urls,
    List<Enum$ScrapeType>? supported_scrapes,
    String? $__typename,
  }) => _res;
}

class Variables$Mutation$MetadataGenerate {
  factory Variables$Mutation$MetadataGenerate({
    required Input$GenerateMetadataInput input,
  }) => Variables$Mutation$MetadataGenerate._({r'input': input});

  Variables$Mutation$MetadataGenerate._(this._$data);

  factory Variables$Mutation$MetadataGenerate.fromJson(
    Map<String, dynamic> data,
  ) {
    final result$data = <String, dynamic>{};
    final l$input = data['input'];
    result$data['input'] = Input$GenerateMetadataInput.fromJson(
      (l$input as Map<String, dynamic>),
    );
    return Variables$Mutation$MetadataGenerate._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$GenerateMetadataInput get input =>
      (_$data['input'] as Input$GenerateMetadataInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$input = input;
    result$data['input'] = l$input.toJson();
    return result$data;
  }

  CopyWith$Variables$Mutation$MetadataGenerate<
    Variables$Mutation$MetadataGenerate
  >
  get copyWith => CopyWith$Variables$Mutation$MetadataGenerate(this, (i) => i);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$MetadataGenerate ||
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

abstract class CopyWith$Variables$Mutation$MetadataGenerate<TRes> {
  factory CopyWith$Variables$Mutation$MetadataGenerate(
    Variables$Mutation$MetadataGenerate instance,
    TRes Function(Variables$Mutation$MetadataGenerate) then,
  ) = _CopyWithImpl$Variables$Mutation$MetadataGenerate;

  factory CopyWith$Variables$Mutation$MetadataGenerate.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$MetadataGenerate;

  TRes call({Input$GenerateMetadataInput? input});
}

class _CopyWithImpl$Variables$Mutation$MetadataGenerate<TRes>
    implements CopyWith$Variables$Mutation$MetadataGenerate<TRes> {
  _CopyWithImpl$Variables$Mutation$MetadataGenerate(this._instance, this._then);

  final Variables$Mutation$MetadataGenerate _instance;

  final TRes Function(Variables$Mutation$MetadataGenerate) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? input = _undefined}) => _then(
    Variables$Mutation$MetadataGenerate._({
      ..._instance._$data,
      if (input != _undefined && input != null)
        'input': (input as Input$GenerateMetadataInput),
    }),
  );
}

class _CopyWithStubImpl$Variables$Mutation$MetadataGenerate<TRes>
    implements CopyWith$Variables$Mutation$MetadataGenerate<TRes> {
  _CopyWithStubImpl$Variables$Mutation$MetadataGenerate(this._res);

  TRes _res;

  call({Input$GenerateMetadataInput? input}) => _res;
}

class Mutation$MetadataGenerate {
  Mutation$MetadataGenerate({
    required this.metadataGenerate,
    this.$__typename = 'Mutation',
  });

  factory Mutation$MetadataGenerate.fromJson(Map<String, dynamic> json) {
    final l$metadataGenerate = json['metadataGenerate'];
    final l$$__typename = json['__typename'];
    return Mutation$MetadataGenerate(
      metadataGenerate: (l$metadataGenerate as String),
      $__typename: (l$$__typename as String),
    );
  }

  final String metadataGenerate;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$metadataGenerate = metadataGenerate;
    _resultData['metadataGenerate'] = l$metadataGenerate;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$metadataGenerate = metadataGenerate;
    final l$$__typename = $__typename;
    return Object.hashAll([l$metadataGenerate, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$MetadataGenerate ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$metadataGenerate = metadataGenerate;
    final lOther$metadataGenerate = other.metadataGenerate;
    if (l$metadataGenerate != lOther$metadataGenerate) {
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

extension UtilityExtension$Mutation$MetadataGenerate
    on Mutation$MetadataGenerate {
  CopyWith$Mutation$MetadataGenerate<Mutation$MetadataGenerate> get copyWith =>
      CopyWith$Mutation$MetadataGenerate(this, (i) => i);
}

abstract class CopyWith$Mutation$MetadataGenerate<TRes> {
  factory CopyWith$Mutation$MetadataGenerate(
    Mutation$MetadataGenerate instance,
    TRes Function(Mutation$MetadataGenerate) then,
  ) = _CopyWithImpl$Mutation$MetadataGenerate;

  factory CopyWith$Mutation$MetadataGenerate.stub(TRes res) =
      _CopyWithStubImpl$Mutation$MetadataGenerate;

  TRes call({String? metadataGenerate, String? $__typename});
}

class _CopyWithImpl$Mutation$MetadataGenerate<TRes>
    implements CopyWith$Mutation$MetadataGenerate<TRes> {
  _CopyWithImpl$Mutation$MetadataGenerate(this._instance, this._then);

  final Mutation$MetadataGenerate _instance;

  final TRes Function(Mutation$MetadataGenerate) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? metadataGenerate = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Mutation$MetadataGenerate(
      metadataGenerate:
          metadataGenerate == _undefined || metadataGenerate == null
          ? _instance.metadataGenerate
          : (metadataGenerate as String),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Mutation$MetadataGenerate<TRes>
    implements CopyWith$Mutation$MetadataGenerate<TRes> {
  _CopyWithStubImpl$Mutation$MetadataGenerate(this._res);

  TRes _res;

  call({String? metadataGenerate, String? $__typename}) => _res;
}

const documentNodeMutationMetadataGenerate = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.mutation,
      name: NameNode(value: 'MetadataGenerate'),
      variableDefinitions: [
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'input')),
          type: NamedTypeNode(
            name: NameNode(value: 'GenerateMetadataInput'),
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
            name: NameNode(value: 'metadataGenerate'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'input'),
                value: VariableNode(name: NameNode(value: 'input')),
              ),
            ],
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
  ],
);
Mutation$MetadataGenerate _parserFn$Mutation$MetadataGenerate(
  Map<String, dynamic> data,
) => Mutation$MetadataGenerate.fromJson(data);
typedef OnMutationCompleted$Mutation$MetadataGenerate =
    FutureOr<void> Function(Map<String, dynamic>?, Mutation$MetadataGenerate?);

class Options$Mutation$MetadataGenerate
    extends graphql.MutationOptions<Mutation$MetadataGenerate> {
  Options$Mutation$MetadataGenerate({
    String? operationName,
    required Variables$Mutation$MetadataGenerate variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$MetadataGenerate? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$MetadataGenerate? onCompleted,
    graphql.OnMutationUpdate<Mutation$MetadataGenerate>? update,
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
                     : _parserFn$Mutation$MetadataGenerate(data),
               ),
         update: update,
         onError: onError,
         document: documentNodeMutationMetadataGenerate,
         parserFn: _parserFn$Mutation$MetadataGenerate,
       );

  final OnMutationCompleted$Mutation$MetadataGenerate? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
    ...super.onCompleted == null
        ? super.properties
        : super.properties.where((property) => property != onCompleted),
    onCompletedWithParsed,
  ];
}

class WatchOptions$Mutation$MetadataGenerate
    extends graphql.WatchQueryOptions<Mutation$MetadataGenerate> {
  WatchOptions$Mutation$MetadataGenerate({
    String? operationName,
    required Variables$Mutation$MetadataGenerate variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$MetadataGenerate? typedOptimisticResult,
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
         document: documentNodeMutationMetadataGenerate,
         pollInterval: pollInterval,
         eagerlyFetchResults: eagerlyFetchResults,
         carryForwardDataOnException: carryForwardDataOnException,
         fetchResults: fetchResults,
         parserFn: _parserFn$Mutation$MetadataGenerate,
       );
}

extension ClientExtension$Mutation$MetadataGenerate on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$MetadataGenerate>>
  mutate$MetadataGenerate(Options$Mutation$MetadataGenerate options) async =>
      await this.mutate(options);

  graphql.ObservableQuery<Mutation$MetadataGenerate>
  watchMutation$MetadataGenerate(
    WatchOptions$Mutation$MetadataGenerate options,
  ) => this.watchMutation(options);
}

class Variables$Query$ScrapeSingleScene {
  factory Variables$Query$ScrapeSingleScene({
    required Input$ScraperSourceInput source,
    required Input$ScrapeSingleSceneInput input,
  }) =>
      Variables$Query$ScrapeSingleScene._({r'source': source, r'input': input});

  Variables$Query$ScrapeSingleScene._(this._$data);

  factory Variables$Query$ScrapeSingleScene.fromJson(
    Map<String, dynamic> data,
  ) {
    final result$data = <String, dynamic>{};
    final l$source = data['source'];
    result$data['source'] = Input$ScraperSourceInput.fromJson(
      (l$source as Map<String, dynamic>),
    );
    final l$input = data['input'];
    result$data['input'] = Input$ScrapeSingleSceneInput.fromJson(
      (l$input as Map<String, dynamic>),
    );
    return Variables$Query$ScrapeSingleScene._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$ScraperSourceInput get source =>
      (_$data['source'] as Input$ScraperSourceInput);

  Input$ScrapeSingleSceneInput get input =>
      (_$data['input'] as Input$ScrapeSingleSceneInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$source = source;
    result$data['source'] = l$source.toJson();
    final l$input = input;
    result$data['input'] = l$input.toJson();
    return result$data;
  }

  CopyWith$Variables$Query$ScrapeSingleScene<Variables$Query$ScrapeSingleScene>
  get copyWith => CopyWith$Variables$Query$ScrapeSingleScene(this, (i) => i);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$ScrapeSingleScene ||
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

abstract class CopyWith$Variables$Query$ScrapeSingleScene<TRes> {
  factory CopyWith$Variables$Query$ScrapeSingleScene(
    Variables$Query$ScrapeSingleScene instance,
    TRes Function(Variables$Query$ScrapeSingleScene) then,
  ) = _CopyWithImpl$Variables$Query$ScrapeSingleScene;

  factory CopyWith$Variables$Query$ScrapeSingleScene.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$ScrapeSingleScene;

  TRes call({
    Input$ScraperSourceInput? source,
    Input$ScrapeSingleSceneInput? input,
  });
}

class _CopyWithImpl$Variables$Query$ScrapeSingleScene<TRes>
    implements CopyWith$Variables$Query$ScrapeSingleScene<TRes> {
  _CopyWithImpl$Variables$Query$ScrapeSingleScene(this._instance, this._then);

  final Variables$Query$ScrapeSingleScene _instance;

  final TRes Function(Variables$Query$ScrapeSingleScene) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? source = _undefined, Object? input = _undefined}) => _then(
    Variables$Query$ScrapeSingleScene._({
      ..._instance._$data,
      if (source != _undefined && source != null)
        'source': (source as Input$ScraperSourceInput),
      if (input != _undefined && input != null)
        'input': (input as Input$ScrapeSingleSceneInput),
    }),
  );
}

class _CopyWithStubImpl$Variables$Query$ScrapeSingleScene<TRes>
    implements CopyWith$Variables$Query$ScrapeSingleScene<TRes> {
  _CopyWithStubImpl$Variables$Query$ScrapeSingleScene(this._res);

  TRes _res;

  call({
    Input$ScraperSourceInput? source,
    Input$ScrapeSingleSceneInput? input,
  }) => _res;
}

class Query$ScrapeSingleScene {
  Query$ScrapeSingleScene({
    required this.scrapeSingleScene,
    this.$__typename = 'Query',
  });

  factory Query$ScrapeSingleScene.fromJson(Map<String, dynamic> json) {
    final l$scrapeSingleScene = json['scrapeSingleScene'];
    final l$$__typename = json['__typename'];
    return Query$ScrapeSingleScene(
      scrapeSingleScene: (l$scrapeSingleScene as List<dynamic>)
          .map(
            (e) => Query$ScrapeSingleScene$scrapeSingleScene.fromJson(
              (e as Map<String, dynamic>),
            ),
          )
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Query$ScrapeSingleScene$scrapeSingleScene> scrapeSingleScene;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$scrapeSingleScene = scrapeSingleScene;
    _resultData['scrapeSingleScene'] = l$scrapeSingleScene
        .map((e) => e.toJson())
        .toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$scrapeSingleScene = scrapeSingleScene;
    final l$$__typename = $__typename;
    return Object.hashAll([
      Object.hashAll(l$scrapeSingleScene.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$ScrapeSingleScene || runtimeType != other.runtimeType) {
      return false;
    }
    final l$scrapeSingleScene = scrapeSingleScene;
    final lOther$scrapeSingleScene = other.scrapeSingleScene;
    if (l$scrapeSingleScene.length != lOther$scrapeSingleScene.length) {
      return false;
    }
    for (int i = 0; i < l$scrapeSingleScene.length; i++) {
      final l$scrapeSingleScene$entry = l$scrapeSingleScene[i];
      final lOther$scrapeSingleScene$entry = lOther$scrapeSingleScene[i];
      if (l$scrapeSingleScene$entry != lOther$scrapeSingleScene$entry) {
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

extension UtilityExtension$Query$ScrapeSingleScene on Query$ScrapeSingleScene {
  CopyWith$Query$ScrapeSingleScene<Query$ScrapeSingleScene> get copyWith =>
      CopyWith$Query$ScrapeSingleScene(this, (i) => i);
}

abstract class CopyWith$Query$ScrapeSingleScene<TRes> {
  factory CopyWith$Query$ScrapeSingleScene(
    Query$ScrapeSingleScene instance,
    TRes Function(Query$ScrapeSingleScene) then,
  ) = _CopyWithImpl$Query$ScrapeSingleScene;

  factory CopyWith$Query$ScrapeSingleScene.stub(TRes res) =
      _CopyWithStubImpl$Query$ScrapeSingleScene;

  TRes call({
    List<Query$ScrapeSingleScene$scrapeSingleScene>? scrapeSingleScene,
    String? $__typename,
  });
  TRes scrapeSingleScene(
    Iterable<Query$ScrapeSingleScene$scrapeSingleScene> Function(
      Iterable<
        CopyWith$Query$ScrapeSingleScene$scrapeSingleScene<
          Query$ScrapeSingleScene$scrapeSingleScene
        >
      >,
    )
    _fn,
  );
}

class _CopyWithImpl$Query$ScrapeSingleScene<TRes>
    implements CopyWith$Query$ScrapeSingleScene<TRes> {
  _CopyWithImpl$Query$ScrapeSingleScene(this._instance, this._then);

  final Query$ScrapeSingleScene _instance;

  final TRes Function(Query$ScrapeSingleScene) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? scrapeSingleScene = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$ScrapeSingleScene(
      scrapeSingleScene:
          scrapeSingleScene == _undefined || scrapeSingleScene == null
          ? _instance.scrapeSingleScene
          : (scrapeSingleScene
                as List<Query$ScrapeSingleScene$scrapeSingleScene>),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  TRes scrapeSingleScene(
    Iterable<Query$ScrapeSingleScene$scrapeSingleScene> Function(
      Iterable<
        CopyWith$Query$ScrapeSingleScene$scrapeSingleScene<
          Query$ScrapeSingleScene$scrapeSingleScene
        >
      >,
    )
    _fn,
  ) => call(
    scrapeSingleScene: _fn(
      _instance.scrapeSingleScene.map(
        (e) => CopyWith$Query$ScrapeSingleScene$scrapeSingleScene(e, (i) => i),
      ),
    ).toList(),
  );
}

class _CopyWithStubImpl$Query$ScrapeSingleScene<TRes>
    implements CopyWith$Query$ScrapeSingleScene<TRes> {
  _CopyWithStubImpl$Query$ScrapeSingleScene(this._res);

  TRes _res;

  call({
    List<Query$ScrapeSingleScene$scrapeSingleScene>? scrapeSingleScene,
    String? $__typename,
  }) => _res;

  scrapeSingleScene(_fn) => _res;
}

const documentNodeQueryScrapeSingleScene = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.query,
      name: NameNode(value: 'ScrapeSingleScene'),
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
            name: NameNode(value: 'ScrapeSingleSceneInput'),
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
            name: NameNode(value: 'scrapeSingleScene'),
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
                  name: NameNode(value: 'title'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
                FieldNode(
                  name: NameNode(value: 'code'),
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
                  name: NameNode(value: 'director'),
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
                  name: NameNode(value: 'date'),
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
                  name: NameNode(value: 'studio'),
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
                  name: NameNode(value: 'tags'),
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
                  name: NameNode(value: 'performers'),
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
                        name: NameNode(value: 'remote_site_id'),
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
                        name: NameNode(value: 'images'),
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
Query$ScrapeSingleScene _parserFn$Query$ScrapeSingleScene(
  Map<String, dynamic> data,
) => Query$ScrapeSingleScene.fromJson(data);
typedef OnQueryComplete$Query$ScrapeSingleScene =
    FutureOr<void> Function(Map<String, dynamic>?, Query$ScrapeSingleScene?);

class Options$Query$ScrapeSingleScene
    extends graphql.QueryOptions<Query$ScrapeSingleScene> {
  Options$Query$ScrapeSingleScene({
    String? operationName,
    required Variables$Query$ScrapeSingleScene variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$ScrapeSingleScene? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$ScrapeSingleScene? onComplete,
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
                 data == null ? null : _parserFn$Query$ScrapeSingleScene(data),
               ),
         onError: onError,
         document: documentNodeQueryScrapeSingleScene,
         parserFn: _parserFn$Query$ScrapeSingleScene,
       );

  final OnQueryComplete$Query$ScrapeSingleScene? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
    ...super.onComplete == null
        ? super.properties
        : super.properties.where((property) => property != onComplete),
    onCompleteWithParsed,
  ];
}

class WatchOptions$Query$ScrapeSingleScene
    extends graphql.WatchQueryOptions<Query$ScrapeSingleScene> {
  WatchOptions$Query$ScrapeSingleScene({
    String? operationName,
    required Variables$Query$ScrapeSingleScene variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$ScrapeSingleScene? typedOptimisticResult,
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
         document: documentNodeQueryScrapeSingleScene,
         pollInterval: pollInterval,
         eagerlyFetchResults: eagerlyFetchResults,
         carryForwardDataOnException: carryForwardDataOnException,
         fetchResults: fetchResults,
         parserFn: _parserFn$Query$ScrapeSingleScene,
       );
}

class FetchMoreOptions$Query$ScrapeSingleScene
    extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$ScrapeSingleScene({
    required graphql.UpdateQuery updateQuery,
    required Variables$Query$ScrapeSingleScene variables,
  }) : super(
         updateQuery: updateQuery,
         variables: variables.toJson(),
         document: documentNodeQueryScrapeSingleScene,
       );
}

extension ClientExtension$Query$ScrapeSingleScene on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$ScrapeSingleScene>> query$ScrapeSingleScene(
    Options$Query$ScrapeSingleScene options,
  ) async => await this.query(options);

  graphql.ObservableQuery<Query$ScrapeSingleScene> watchQuery$ScrapeSingleScene(
    WatchOptions$Query$ScrapeSingleScene options,
  ) => this.watchQuery(options);

  void writeQuery$ScrapeSingleScene({
    required Query$ScrapeSingleScene data,
    required Variables$Query$ScrapeSingleScene variables,
    bool broadcast = true,
  }) => this.writeQuery(
    graphql.Request(
      operation: graphql.Operation(
        document: documentNodeQueryScrapeSingleScene,
      ),
      variables: variables.toJson(),
    ),
    data: data.toJson(),
    broadcast: broadcast,
  );

  Query$ScrapeSingleScene? readQuery$ScrapeSingleScene({
    required Variables$Query$ScrapeSingleScene variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(
          document: documentNodeQueryScrapeSingleScene,
        ),
        variables: variables.toJson(),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$ScrapeSingleScene.fromJson(result);
  }
}

class Query$ScrapeSingleScene$scrapeSingleScene {
  Query$ScrapeSingleScene$scrapeSingleScene({
    this.title,
    this.code,
    this.details,
    this.director,
    this.urls,
    this.date,
    this.image,
    this.remote_site_id,
    this.studio,
    this.tags,
    this.performers,
    this.$__typename = 'ScrapedScene',
  });

  factory Query$ScrapeSingleScene$scrapeSingleScene.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$title = json['title'];
    final l$code = json['code'];
    final l$details = json['details'];
    final l$director = json['director'];
    final l$urls = json['urls'];
    final l$date = json['date'];
    final l$image = json['image'];
    final l$remote_site_id = json['remote_site_id'];
    final l$studio = json['studio'];
    final l$tags = json['tags'];
    final l$performers = json['performers'];
    final l$$__typename = json['__typename'];
    return Query$ScrapeSingleScene$scrapeSingleScene(
      title: (l$title as String?),
      code: (l$code as String?),
      details: (l$details as String?),
      director: (l$director as String?),
      urls: (l$urls as List<dynamic>?)?.map((e) => (e as String)).toList(),
      date: (l$date as String?),
      image: (l$image as String?),
      remote_site_id: (l$remote_site_id as String?),
      studio: l$studio == null
          ? null
          : Query$ScrapeSingleScene$scrapeSingleScene$studio.fromJson(
              (l$studio as Map<String, dynamic>),
            ),
      tags: (l$tags as List<dynamic>?)
          ?.map(
            (e) => Query$ScrapeSingleScene$scrapeSingleScene$tags.fromJson(
              (e as Map<String, dynamic>),
            ),
          )
          .toList(),
      performers: (l$performers as List<dynamic>?)
          ?.map(
            (e) =>
                Query$ScrapeSingleScene$scrapeSingleScene$performers.fromJson(
                  (e as Map<String, dynamic>),
                ),
          )
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final String? title;

  final String? code;

  final String? details;

  final String? director;

  final List<String>? urls;

  final String? date;

  final String? image;

  final String? remote_site_id;

  final Query$ScrapeSingleScene$scrapeSingleScene$studio? studio;

  final List<Query$ScrapeSingleScene$scrapeSingleScene$tags>? tags;

  final List<Query$ScrapeSingleScene$scrapeSingleScene$performers>? performers;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$title = title;
    _resultData['title'] = l$title;
    final l$code = code;
    _resultData['code'] = l$code;
    final l$details = details;
    _resultData['details'] = l$details;
    final l$director = director;
    _resultData['director'] = l$director;
    final l$urls = urls;
    _resultData['urls'] = l$urls?.map((e) => e).toList();
    final l$date = date;
    _resultData['date'] = l$date;
    final l$image = image;
    _resultData['image'] = l$image;
    final l$remote_site_id = remote_site_id;
    _resultData['remote_site_id'] = l$remote_site_id;
    final l$studio = studio;
    _resultData['studio'] = l$studio?.toJson();
    final l$tags = tags;
    _resultData['tags'] = l$tags?.map((e) => e.toJson()).toList();
    final l$performers = performers;
    _resultData['performers'] = l$performers?.map((e) => e.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$title = title;
    final l$code = code;
    final l$details = details;
    final l$director = director;
    final l$urls = urls;
    final l$date = date;
    final l$image = image;
    final l$remote_site_id = remote_site_id;
    final l$studio = studio;
    final l$tags = tags;
    final l$performers = performers;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$title,
      l$code,
      l$details,
      l$director,
      l$urls == null ? null : Object.hashAll(l$urls.map((v) => v)),
      l$date,
      l$image,
      l$remote_site_id,
      l$studio,
      l$tags == null ? null : Object.hashAll(l$tags.map((v) => v)),
      l$performers == null ? null : Object.hashAll(l$performers.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$ScrapeSingleScene$scrapeSingleScene ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$title = title;
    final lOther$title = other.title;
    if (l$title != lOther$title) {
      return false;
    }
    final l$code = code;
    final lOther$code = other.code;
    if (l$code != lOther$code) {
      return false;
    }
    final l$details = details;
    final lOther$details = other.details;
    if (l$details != lOther$details) {
      return false;
    }
    final l$director = director;
    final lOther$director = other.director;
    if (l$director != lOther$director) {
      return false;
    }
    final l$urls = urls;
    final lOther$urls = other.urls;
    if (l$urls != null && lOther$urls != null) {
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
    } else if (l$urls != lOther$urls) {
      return false;
    }
    final l$date = date;
    final lOther$date = other.date;
    if (l$date != lOther$date) {
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
    final l$studio = studio;
    final lOther$studio = other.studio;
    if (l$studio != lOther$studio) {
      return false;
    }
    final l$tags = tags;
    final lOther$tags = other.tags;
    if (l$tags != null && lOther$tags != null) {
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
    } else if (l$tags != lOther$tags) {
      return false;
    }
    final l$performers = performers;
    final lOther$performers = other.performers;
    if (l$performers != null && lOther$performers != null) {
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
    } else if (l$performers != lOther$performers) {
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

extension UtilityExtension$Query$ScrapeSingleScene$scrapeSingleScene
    on Query$ScrapeSingleScene$scrapeSingleScene {
  CopyWith$Query$ScrapeSingleScene$scrapeSingleScene<
    Query$ScrapeSingleScene$scrapeSingleScene
  >
  get copyWith =>
      CopyWith$Query$ScrapeSingleScene$scrapeSingleScene(this, (i) => i);
}

abstract class CopyWith$Query$ScrapeSingleScene$scrapeSingleScene<TRes> {
  factory CopyWith$Query$ScrapeSingleScene$scrapeSingleScene(
    Query$ScrapeSingleScene$scrapeSingleScene instance,
    TRes Function(Query$ScrapeSingleScene$scrapeSingleScene) then,
  ) = _CopyWithImpl$Query$ScrapeSingleScene$scrapeSingleScene;

  factory CopyWith$Query$ScrapeSingleScene$scrapeSingleScene.stub(TRes res) =
      _CopyWithStubImpl$Query$ScrapeSingleScene$scrapeSingleScene;

  TRes call({
    String? title,
    String? code,
    String? details,
    String? director,
    List<String>? urls,
    String? date,
    String? image,
    String? remote_site_id,
    Query$ScrapeSingleScene$scrapeSingleScene$studio? studio,
    List<Query$ScrapeSingleScene$scrapeSingleScene$tags>? tags,
    List<Query$ScrapeSingleScene$scrapeSingleScene$performers>? performers,
    String? $__typename,
  });
  CopyWith$Query$ScrapeSingleScene$scrapeSingleScene$studio<TRes> get studio;
  TRes tags(
    Iterable<Query$ScrapeSingleScene$scrapeSingleScene$tags>? Function(
      Iterable<
        CopyWith$Query$ScrapeSingleScene$scrapeSingleScene$tags<
          Query$ScrapeSingleScene$scrapeSingleScene$tags
        >
      >?,
    )
    _fn,
  );
  TRes performers(
    Iterable<Query$ScrapeSingleScene$scrapeSingleScene$performers>? Function(
      Iterable<
        CopyWith$Query$ScrapeSingleScene$scrapeSingleScene$performers<
          Query$ScrapeSingleScene$scrapeSingleScene$performers
        >
      >?,
    )
    _fn,
  );
}

class _CopyWithImpl$Query$ScrapeSingleScene$scrapeSingleScene<TRes>
    implements CopyWith$Query$ScrapeSingleScene$scrapeSingleScene<TRes> {
  _CopyWithImpl$Query$ScrapeSingleScene$scrapeSingleScene(
    this._instance,
    this._then,
  );

  final Query$ScrapeSingleScene$scrapeSingleScene _instance;

  final TRes Function(Query$ScrapeSingleScene$scrapeSingleScene) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? title = _undefined,
    Object? code = _undefined,
    Object? details = _undefined,
    Object? director = _undefined,
    Object? urls = _undefined,
    Object? date = _undefined,
    Object? image = _undefined,
    Object? remote_site_id = _undefined,
    Object? studio = _undefined,
    Object? tags = _undefined,
    Object? performers = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$ScrapeSingleScene$scrapeSingleScene(
      title: title == _undefined ? _instance.title : (title as String?),
      code: code == _undefined ? _instance.code : (code as String?),
      details: details == _undefined ? _instance.details : (details as String?),
      director: director == _undefined
          ? _instance.director
          : (director as String?),
      urls: urls == _undefined ? _instance.urls : (urls as List<String>?),
      date: date == _undefined ? _instance.date : (date as String?),
      image: image == _undefined ? _instance.image : (image as String?),
      remote_site_id: remote_site_id == _undefined
          ? _instance.remote_site_id
          : (remote_site_id as String?),
      studio: studio == _undefined
          ? _instance.studio
          : (studio as Query$ScrapeSingleScene$scrapeSingleScene$studio?),
      tags: tags == _undefined
          ? _instance.tags
          : (tags as List<Query$ScrapeSingleScene$scrapeSingleScene$tags>?),
      performers: performers == _undefined
          ? _instance.performers
          : (performers
                as List<Query$ScrapeSingleScene$scrapeSingleScene$performers>?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  CopyWith$Query$ScrapeSingleScene$scrapeSingleScene$studio<TRes> get studio {
    final local$studio = _instance.studio;
    return local$studio == null
        ? CopyWith$Query$ScrapeSingleScene$scrapeSingleScene$studio.stub(
            _then(_instance),
          )
        : CopyWith$Query$ScrapeSingleScene$scrapeSingleScene$studio(
            local$studio,
            (e) => call(studio: e),
          );
  }

  TRes tags(
    Iterable<Query$ScrapeSingleScene$scrapeSingleScene$tags>? Function(
      Iterable<
        CopyWith$Query$ScrapeSingleScene$scrapeSingleScene$tags<
          Query$ScrapeSingleScene$scrapeSingleScene$tags
        >
      >?,
    )
    _fn,
  ) => call(
    tags: _fn(
      _instance.tags?.map(
        (e) => CopyWith$Query$ScrapeSingleScene$scrapeSingleScene$tags(
          e,
          (i) => i,
        ),
      ),
    )?.toList(),
  );

  TRes performers(
    Iterable<Query$ScrapeSingleScene$scrapeSingleScene$performers>? Function(
      Iterable<
        CopyWith$Query$ScrapeSingleScene$scrapeSingleScene$performers<
          Query$ScrapeSingleScene$scrapeSingleScene$performers
        >
      >?,
    )
    _fn,
  ) => call(
    performers: _fn(
      _instance.performers?.map(
        (e) => CopyWith$Query$ScrapeSingleScene$scrapeSingleScene$performers(
          e,
          (i) => i,
        ),
      ),
    )?.toList(),
  );
}

class _CopyWithStubImpl$Query$ScrapeSingleScene$scrapeSingleScene<TRes>
    implements CopyWith$Query$ScrapeSingleScene$scrapeSingleScene<TRes> {
  _CopyWithStubImpl$Query$ScrapeSingleScene$scrapeSingleScene(this._res);

  TRes _res;

  call({
    String? title,
    String? code,
    String? details,
    String? director,
    List<String>? urls,
    String? date,
    String? image,
    String? remote_site_id,
    Query$ScrapeSingleScene$scrapeSingleScene$studio? studio,
    List<Query$ScrapeSingleScene$scrapeSingleScene$tags>? tags,
    List<Query$ScrapeSingleScene$scrapeSingleScene$performers>? performers,
    String? $__typename,
  }) => _res;

  CopyWith$Query$ScrapeSingleScene$scrapeSingleScene$studio<TRes> get studio =>
      CopyWith$Query$ScrapeSingleScene$scrapeSingleScene$studio.stub(_res);

  tags(_fn) => _res;

  performers(_fn) => _res;
}

class Query$ScrapeSingleScene$scrapeSingleScene$studio {
  Query$ScrapeSingleScene$scrapeSingleScene$studio({
    required this.name,
    this.stored_id,
    this.$__typename = 'ScrapedStudio',
  });

  factory Query$ScrapeSingleScene$scrapeSingleScene$studio.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$name = json['name'];
    final l$stored_id = json['stored_id'];
    final l$$__typename = json['__typename'];
    return Query$ScrapeSingleScene$scrapeSingleScene$studio(
      name: (l$name as String),
      stored_id: (l$stored_id as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String name;

  final String? stored_id;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$name = name;
    _resultData['name'] = l$name;
    final l$stored_id = stored_id;
    _resultData['stored_id'] = l$stored_id;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$name = name;
    final l$stored_id = stored_id;
    final l$$__typename = $__typename;
    return Object.hashAll([l$name, l$stored_id, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$ScrapeSingleScene$scrapeSingleScene$studio ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
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

extension UtilityExtension$Query$ScrapeSingleScene$scrapeSingleScene$studio
    on Query$ScrapeSingleScene$scrapeSingleScene$studio {
  CopyWith$Query$ScrapeSingleScene$scrapeSingleScene$studio<
    Query$ScrapeSingleScene$scrapeSingleScene$studio
  >
  get copyWith =>
      CopyWith$Query$ScrapeSingleScene$scrapeSingleScene$studio(this, (i) => i);
}

abstract class CopyWith$Query$ScrapeSingleScene$scrapeSingleScene$studio<TRes> {
  factory CopyWith$Query$ScrapeSingleScene$scrapeSingleScene$studio(
    Query$ScrapeSingleScene$scrapeSingleScene$studio instance,
    TRes Function(Query$ScrapeSingleScene$scrapeSingleScene$studio) then,
  ) = _CopyWithImpl$Query$ScrapeSingleScene$scrapeSingleScene$studio;

  factory CopyWith$Query$ScrapeSingleScene$scrapeSingleScene$studio.stub(
    TRes res,
  ) = _CopyWithStubImpl$Query$ScrapeSingleScene$scrapeSingleScene$studio;

  TRes call({String? name, String? stored_id, String? $__typename});
}

class _CopyWithImpl$Query$ScrapeSingleScene$scrapeSingleScene$studio<TRes>
    implements CopyWith$Query$ScrapeSingleScene$scrapeSingleScene$studio<TRes> {
  _CopyWithImpl$Query$ScrapeSingleScene$scrapeSingleScene$studio(
    this._instance,
    this._then,
  );

  final Query$ScrapeSingleScene$scrapeSingleScene$studio _instance;

  final TRes Function(Query$ScrapeSingleScene$scrapeSingleScene$studio) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? name = _undefined,
    Object? stored_id = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$ScrapeSingleScene$scrapeSingleScene$studio(
      name: name == _undefined || name == null
          ? _instance.name
          : (name as String),
      stored_id: stored_id == _undefined
          ? _instance.stored_id
          : (stored_id as String?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Query$ScrapeSingleScene$scrapeSingleScene$studio<TRes>
    implements CopyWith$Query$ScrapeSingleScene$scrapeSingleScene$studio<TRes> {
  _CopyWithStubImpl$Query$ScrapeSingleScene$scrapeSingleScene$studio(this._res);

  TRes _res;

  call({String? name, String? stored_id, String? $__typename}) => _res;
}

class Query$ScrapeSingleScene$scrapeSingleScene$tags {
  Query$ScrapeSingleScene$scrapeSingleScene$tags({
    required this.name,
    this.stored_id,
    this.$__typename = 'ScrapedTag',
  });

  factory Query$ScrapeSingleScene$scrapeSingleScene$tags.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$name = json['name'];
    final l$stored_id = json['stored_id'];
    final l$$__typename = json['__typename'];
    return Query$ScrapeSingleScene$scrapeSingleScene$tags(
      name: (l$name as String),
      stored_id: (l$stored_id as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String name;

  final String? stored_id;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$name = name;
    _resultData['name'] = l$name;
    final l$stored_id = stored_id;
    _resultData['stored_id'] = l$stored_id;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$name = name;
    final l$stored_id = stored_id;
    final l$$__typename = $__typename;
    return Object.hashAll([l$name, l$stored_id, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$ScrapeSingleScene$scrapeSingleScene$tags ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
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

extension UtilityExtension$Query$ScrapeSingleScene$scrapeSingleScene$tags
    on Query$ScrapeSingleScene$scrapeSingleScene$tags {
  CopyWith$Query$ScrapeSingleScene$scrapeSingleScene$tags<
    Query$ScrapeSingleScene$scrapeSingleScene$tags
  >
  get copyWith =>
      CopyWith$Query$ScrapeSingleScene$scrapeSingleScene$tags(this, (i) => i);
}

abstract class CopyWith$Query$ScrapeSingleScene$scrapeSingleScene$tags<TRes> {
  factory CopyWith$Query$ScrapeSingleScene$scrapeSingleScene$tags(
    Query$ScrapeSingleScene$scrapeSingleScene$tags instance,
    TRes Function(Query$ScrapeSingleScene$scrapeSingleScene$tags) then,
  ) = _CopyWithImpl$Query$ScrapeSingleScene$scrapeSingleScene$tags;

  factory CopyWith$Query$ScrapeSingleScene$scrapeSingleScene$tags.stub(
    TRes res,
  ) = _CopyWithStubImpl$Query$ScrapeSingleScene$scrapeSingleScene$tags;

  TRes call({String? name, String? stored_id, String? $__typename});
}

class _CopyWithImpl$Query$ScrapeSingleScene$scrapeSingleScene$tags<TRes>
    implements CopyWith$Query$ScrapeSingleScene$scrapeSingleScene$tags<TRes> {
  _CopyWithImpl$Query$ScrapeSingleScene$scrapeSingleScene$tags(
    this._instance,
    this._then,
  );

  final Query$ScrapeSingleScene$scrapeSingleScene$tags _instance;

  final TRes Function(Query$ScrapeSingleScene$scrapeSingleScene$tags) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? name = _undefined,
    Object? stored_id = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$ScrapeSingleScene$scrapeSingleScene$tags(
      name: name == _undefined || name == null
          ? _instance.name
          : (name as String),
      stored_id: stored_id == _undefined
          ? _instance.stored_id
          : (stored_id as String?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Query$ScrapeSingleScene$scrapeSingleScene$tags<TRes>
    implements CopyWith$Query$ScrapeSingleScene$scrapeSingleScene$tags<TRes> {
  _CopyWithStubImpl$Query$ScrapeSingleScene$scrapeSingleScene$tags(this._res);

  TRes _res;

  call({String? name, String? stored_id, String? $__typename}) => _res;
}

class Query$ScrapeSingleScene$scrapeSingleScene$performers {
  Query$ScrapeSingleScene$scrapeSingleScene$performers({
    this.name,
    this.remote_site_id,
    this.urls,
    this.images,
    this.stored_id,
    this.$__typename = 'ScrapedPerformer',
  });

  factory Query$ScrapeSingleScene$scrapeSingleScene$performers.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$name = json['name'];
    final l$remote_site_id = json['remote_site_id'];
    final l$urls = json['urls'];
    final l$images = json['images'];
    final l$stored_id = json['stored_id'];
    final l$$__typename = json['__typename'];
    return Query$ScrapeSingleScene$scrapeSingleScene$performers(
      name: (l$name as String?),
      remote_site_id: (l$remote_site_id as String?),
      urls: (l$urls as List<dynamic>?)?.map((e) => (e as String)).toList(),
      images: (l$images as List<dynamic>?)?.map((e) => (e as String)).toList(),
      stored_id: (l$stored_id as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String? name;

  final String? remote_site_id;

  final List<String>? urls;

  final List<String>? images;

  final String? stored_id;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$name = name;
    _resultData['name'] = l$name;
    final l$remote_site_id = remote_site_id;
    _resultData['remote_site_id'] = l$remote_site_id;
    final l$urls = urls;
    _resultData['urls'] = l$urls?.map((e) => e).toList();
    final l$images = images;
    _resultData['images'] = l$images?.map((e) => e).toList();
    final l$stored_id = stored_id;
    _resultData['stored_id'] = l$stored_id;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$name = name;
    final l$remote_site_id = remote_site_id;
    final l$urls = urls;
    final l$images = images;
    final l$stored_id = stored_id;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$name,
      l$remote_site_id,
      l$urls == null ? null : Object.hashAll(l$urls.map((v) => v)),
      l$images == null ? null : Object.hashAll(l$images.map((v) => v)),
      l$stored_id,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$ScrapeSingleScene$scrapeSingleScene$performers ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    final l$remote_site_id = remote_site_id;
    final lOther$remote_site_id = other.remote_site_id;
    if (l$remote_site_id != lOther$remote_site_id) {
      return false;
    }
    final l$urls = urls;
    final lOther$urls = other.urls;
    if (l$urls != null && lOther$urls != null) {
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
    } else if (l$urls != lOther$urls) {
      return false;
    }
    final l$images = images;
    final lOther$images = other.images;
    if (l$images != null && lOther$images != null) {
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
    } else if (l$images != lOther$images) {
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

extension UtilityExtension$Query$ScrapeSingleScene$scrapeSingleScene$performers
    on Query$ScrapeSingleScene$scrapeSingleScene$performers {
  CopyWith$Query$ScrapeSingleScene$scrapeSingleScene$performers<
    Query$ScrapeSingleScene$scrapeSingleScene$performers
  >
  get copyWith => CopyWith$Query$ScrapeSingleScene$scrapeSingleScene$performers(
    this,
    (i) => i,
  );
}

abstract class CopyWith$Query$ScrapeSingleScene$scrapeSingleScene$performers<
  TRes
> {
  factory CopyWith$Query$ScrapeSingleScene$scrapeSingleScene$performers(
    Query$ScrapeSingleScene$scrapeSingleScene$performers instance,
    TRes Function(Query$ScrapeSingleScene$scrapeSingleScene$performers) then,
  ) = _CopyWithImpl$Query$ScrapeSingleScene$scrapeSingleScene$performers;

  factory CopyWith$Query$ScrapeSingleScene$scrapeSingleScene$performers.stub(
    TRes res,
  ) = _CopyWithStubImpl$Query$ScrapeSingleScene$scrapeSingleScene$performers;

  TRes call({
    String? name,
    String? remote_site_id,
    List<String>? urls,
    List<String>? images,
    String? stored_id,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$ScrapeSingleScene$scrapeSingleScene$performers<TRes>
    implements
        CopyWith$Query$ScrapeSingleScene$scrapeSingleScene$performers<TRes> {
  _CopyWithImpl$Query$ScrapeSingleScene$scrapeSingleScene$performers(
    this._instance,
    this._then,
  );

  final Query$ScrapeSingleScene$scrapeSingleScene$performers _instance;

  final TRes Function(Query$ScrapeSingleScene$scrapeSingleScene$performers)
  _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? name = _undefined,
    Object? remote_site_id = _undefined,
    Object? urls = _undefined,
    Object? images = _undefined,
    Object? stored_id = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$ScrapeSingleScene$scrapeSingleScene$performers(
      name: name == _undefined ? _instance.name : (name as String?),
      remote_site_id: remote_site_id == _undefined
          ? _instance.remote_site_id
          : (remote_site_id as String?),
      urls: urls == _undefined ? _instance.urls : (urls as List<String>?),
      images: images == _undefined
          ? _instance.images
          : (images as List<String>?),
      stored_id: stored_id == _undefined
          ? _instance.stored_id
          : (stored_id as String?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Query$ScrapeSingleScene$scrapeSingleScene$performers<
  TRes
>
    implements
        CopyWith$Query$ScrapeSingleScene$scrapeSingleScene$performers<TRes> {
  _CopyWithStubImpl$Query$ScrapeSingleScene$scrapeSingleScene$performers(
    this._res,
  );

  TRes _res;

  call({
    String? name,
    String? remote_site_id,
    List<String>? urls,
    List<String>? images,
    String? stored_id,
    String? $__typename,
  }) => _res;
}

class Variables$Query$ScrapeSceneURL {
  factory Variables$Query$ScrapeSceneURL({required String url}) =>
      Variables$Query$ScrapeSceneURL._({r'url': url});

  Variables$Query$ScrapeSceneURL._(this._$data);

  factory Variables$Query$ScrapeSceneURL.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$url = data['url'];
    result$data['url'] = (l$url as String);
    return Variables$Query$ScrapeSceneURL._(result$data);
  }

  Map<String, dynamic> _$data;

  String get url => (_$data['url'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$url = url;
    result$data['url'] = l$url;
    return result$data;
  }

  CopyWith$Variables$Query$ScrapeSceneURL<Variables$Query$ScrapeSceneURL>
  get copyWith => CopyWith$Variables$Query$ScrapeSceneURL(this, (i) => i);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$ScrapeSceneURL ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$url = url;
    final lOther$url = other.url;
    if (l$url != lOther$url) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$url = url;
    return Object.hashAll([l$url]);
  }
}

abstract class CopyWith$Variables$Query$ScrapeSceneURL<TRes> {
  factory CopyWith$Variables$Query$ScrapeSceneURL(
    Variables$Query$ScrapeSceneURL instance,
    TRes Function(Variables$Query$ScrapeSceneURL) then,
  ) = _CopyWithImpl$Variables$Query$ScrapeSceneURL;

  factory CopyWith$Variables$Query$ScrapeSceneURL.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$ScrapeSceneURL;

  TRes call({String? url});
}

class _CopyWithImpl$Variables$Query$ScrapeSceneURL<TRes>
    implements CopyWith$Variables$Query$ScrapeSceneURL<TRes> {
  _CopyWithImpl$Variables$Query$ScrapeSceneURL(this._instance, this._then);

  final Variables$Query$ScrapeSceneURL _instance;

  final TRes Function(Variables$Query$ScrapeSceneURL) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? url = _undefined}) => _then(
    Variables$Query$ScrapeSceneURL._({
      ..._instance._$data,
      if (url != _undefined && url != null) 'url': (url as String),
    }),
  );
}

class _CopyWithStubImpl$Variables$Query$ScrapeSceneURL<TRes>
    implements CopyWith$Variables$Query$ScrapeSceneURL<TRes> {
  _CopyWithStubImpl$Variables$Query$ScrapeSceneURL(this._res);

  TRes _res;

  call({String? url}) => _res;
}

class Query$ScrapeSceneURL {
  Query$ScrapeSceneURL({this.scrapeSceneURL, this.$__typename = 'Query'});

  factory Query$ScrapeSceneURL.fromJson(Map<String, dynamic> json) {
    final l$scrapeSceneURL = json['scrapeSceneURL'];
    final l$$__typename = json['__typename'];
    return Query$ScrapeSceneURL(
      scrapeSceneURL: l$scrapeSceneURL == null
          ? null
          : Query$ScrapeSceneURL$scrapeSceneURL.fromJson(
              (l$scrapeSceneURL as Map<String, dynamic>),
            ),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$ScrapeSceneURL$scrapeSceneURL? scrapeSceneURL;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$scrapeSceneURL = scrapeSceneURL;
    _resultData['scrapeSceneURL'] = l$scrapeSceneURL?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$scrapeSceneURL = scrapeSceneURL;
    final l$$__typename = $__typename;
    return Object.hashAll([l$scrapeSceneURL, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$ScrapeSceneURL || runtimeType != other.runtimeType) {
      return false;
    }
    final l$scrapeSceneURL = scrapeSceneURL;
    final lOther$scrapeSceneURL = other.scrapeSceneURL;
    if (l$scrapeSceneURL != lOther$scrapeSceneURL) {
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

extension UtilityExtension$Query$ScrapeSceneURL on Query$ScrapeSceneURL {
  CopyWith$Query$ScrapeSceneURL<Query$ScrapeSceneURL> get copyWith =>
      CopyWith$Query$ScrapeSceneURL(this, (i) => i);
}

abstract class CopyWith$Query$ScrapeSceneURL<TRes> {
  factory CopyWith$Query$ScrapeSceneURL(
    Query$ScrapeSceneURL instance,
    TRes Function(Query$ScrapeSceneURL) then,
  ) = _CopyWithImpl$Query$ScrapeSceneURL;

  factory CopyWith$Query$ScrapeSceneURL.stub(TRes res) =
      _CopyWithStubImpl$Query$ScrapeSceneURL;

  TRes call({
    Query$ScrapeSceneURL$scrapeSceneURL? scrapeSceneURL,
    String? $__typename,
  });
  CopyWith$Query$ScrapeSceneURL$scrapeSceneURL<TRes> get scrapeSceneURL;
}

class _CopyWithImpl$Query$ScrapeSceneURL<TRes>
    implements CopyWith$Query$ScrapeSceneURL<TRes> {
  _CopyWithImpl$Query$ScrapeSceneURL(this._instance, this._then);

  final Query$ScrapeSceneURL _instance;

  final TRes Function(Query$ScrapeSceneURL) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? scrapeSceneURL = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$ScrapeSceneURL(
      scrapeSceneURL: scrapeSceneURL == _undefined
          ? _instance.scrapeSceneURL
          : (scrapeSceneURL as Query$ScrapeSceneURL$scrapeSceneURL?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  CopyWith$Query$ScrapeSceneURL$scrapeSceneURL<TRes> get scrapeSceneURL {
    final local$scrapeSceneURL = _instance.scrapeSceneURL;
    return local$scrapeSceneURL == null
        ? CopyWith$Query$ScrapeSceneURL$scrapeSceneURL.stub(_then(_instance))
        : CopyWith$Query$ScrapeSceneURL$scrapeSceneURL(
            local$scrapeSceneURL,
            (e) => call(scrapeSceneURL: e),
          );
  }
}

class _CopyWithStubImpl$Query$ScrapeSceneURL<TRes>
    implements CopyWith$Query$ScrapeSceneURL<TRes> {
  _CopyWithStubImpl$Query$ScrapeSceneURL(this._res);

  TRes _res;

  call({
    Query$ScrapeSceneURL$scrapeSceneURL? scrapeSceneURL,
    String? $__typename,
  }) => _res;

  CopyWith$Query$ScrapeSceneURL$scrapeSceneURL<TRes> get scrapeSceneURL =>
      CopyWith$Query$ScrapeSceneURL$scrapeSceneURL.stub(_res);
}

const documentNodeQueryScrapeSceneURL = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.query,
      name: NameNode(value: 'ScrapeSceneURL'),
      variableDefinitions: [
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'url')),
          type: NamedTypeNode(name: NameNode(value: 'String'), isNonNull: true),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
      ],
      directives: [],
      selectionSet: SelectionSetNode(
        selections: [
          FieldNode(
            name: NameNode(value: 'scrapeSceneURL'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'url'),
                value: VariableNode(name: NameNode(value: 'url')),
              ),
            ],
            directives: [],
            selectionSet: SelectionSetNode(
              selections: [
                FieldNode(
                  name: NameNode(value: 'title'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
                FieldNode(
                  name: NameNode(value: 'code'),
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
                  name: NameNode(value: 'director'),
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
                  name: NameNode(value: 'date'),
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
                  name: NameNode(value: 'studio'),
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
                  name: NameNode(value: 'tags'),
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
                  name: NameNode(value: 'performers'),
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
                        name: NameNode(value: 'remote_site_id'),
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
                        name: NameNode(value: 'images'),
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
Query$ScrapeSceneURL _parserFn$Query$ScrapeSceneURL(
  Map<String, dynamic> data,
) => Query$ScrapeSceneURL.fromJson(data);
typedef OnQueryComplete$Query$ScrapeSceneURL =
    FutureOr<void> Function(Map<String, dynamic>?, Query$ScrapeSceneURL?);

class Options$Query$ScrapeSceneURL
    extends graphql.QueryOptions<Query$ScrapeSceneURL> {
  Options$Query$ScrapeSceneURL({
    String? operationName,
    required Variables$Query$ScrapeSceneURL variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$ScrapeSceneURL? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$ScrapeSceneURL? onComplete,
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
                 data == null ? null : _parserFn$Query$ScrapeSceneURL(data),
               ),
         onError: onError,
         document: documentNodeQueryScrapeSceneURL,
         parserFn: _parserFn$Query$ScrapeSceneURL,
       );

  final OnQueryComplete$Query$ScrapeSceneURL? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
    ...super.onComplete == null
        ? super.properties
        : super.properties.where((property) => property != onComplete),
    onCompleteWithParsed,
  ];
}

class WatchOptions$Query$ScrapeSceneURL
    extends graphql.WatchQueryOptions<Query$ScrapeSceneURL> {
  WatchOptions$Query$ScrapeSceneURL({
    String? operationName,
    required Variables$Query$ScrapeSceneURL variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$ScrapeSceneURL? typedOptimisticResult,
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
         document: documentNodeQueryScrapeSceneURL,
         pollInterval: pollInterval,
         eagerlyFetchResults: eagerlyFetchResults,
         carryForwardDataOnException: carryForwardDataOnException,
         fetchResults: fetchResults,
         parserFn: _parserFn$Query$ScrapeSceneURL,
       );
}

class FetchMoreOptions$Query$ScrapeSceneURL extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$ScrapeSceneURL({
    required graphql.UpdateQuery updateQuery,
    required Variables$Query$ScrapeSceneURL variables,
  }) : super(
         updateQuery: updateQuery,
         variables: variables.toJson(),
         document: documentNodeQueryScrapeSceneURL,
       );
}

extension ClientExtension$Query$ScrapeSceneURL on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$ScrapeSceneURL>> query$ScrapeSceneURL(
    Options$Query$ScrapeSceneURL options,
  ) async => await this.query(options);

  graphql.ObservableQuery<Query$ScrapeSceneURL> watchQuery$ScrapeSceneURL(
    WatchOptions$Query$ScrapeSceneURL options,
  ) => this.watchQuery(options);

  void writeQuery$ScrapeSceneURL({
    required Query$ScrapeSceneURL data,
    required Variables$Query$ScrapeSceneURL variables,
    bool broadcast = true,
  }) => this.writeQuery(
    graphql.Request(
      operation: graphql.Operation(document: documentNodeQueryScrapeSceneURL),
      variables: variables.toJson(),
    ),
    data: data.toJson(),
    broadcast: broadcast,
  );

  Query$ScrapeSceneURL? readQuery$ScrapeSceneURL({
    required Variables$Query$ScrapeSceneURL variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(document: documentNodeQueryScrapeSceneURL),
        variables: variables.toJson(),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$ScrapeSceneURL.fromJson(result);
  }
}

class Query$ScrapeSceneURL$scrapeSceneURL {
  Query$ScrapeSceneURL$scrapeSceneURL({
    this.title,
    this.code,
    this.details,
    this.director,
    this.urls,
    this.date,
    this.image,
    this.remote_site_id,
    this.studio,
    this.tags,
    this.performers,
    this.$__typename = 'ScrapedScene',
  });

  factory Query$ScrapeSceneURL$scrapeSceneURL.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$title = json['title'];
    final l$code = json['code'];
    final l$details = json['details'];
    final l$director = json['director'];
    final l$urls = json['urls'];
    final l$date = json['date'];
    final l$image = json['image'];
    final l$remote_site_id = json['remote_site_id'];
    final l$studio = json['studio'];
    final l$tags = json['tags'];
    final l$performers = json['performers'];
    final l$$__typename = json['__typename'];
    return Query$ScrapeSceneURL$scrapeSceneURL(
      title: (l$title as String?),
      code: (l$code as String?),
      details: (l$details as String?),
      director: (l$director as String?),
      urls: (l$urls as List<dynamic>?)?.map((e) => (e as String)).toList(),
      date: (l$date as String?),
      image: (l$image as String?),
      remote_site_id: (l$remote_site_id as String?),
      studio: l$studio == null
          ? null
          : Query$ScrapeSceneURL$scrapeSceneURL$studio.fromJson(
              (l$studio as Map<String, dynamic>),
            ),
      tags: (l$tags as List<dynamic>?)
          ?.map(
            (e) => Query$ScrapeSceneURL$scrapeSceneURL$tags.fromJson(
              (e as Map<String, dynamic>),
            ),
          )
          .toList(),
      performers: (l$performers as List<dynamic>?)
          ?.map(
            (e) => Query$ScrapeSceneURL$scrapeSceneURL$performers.fromJson(
              (e as Map<String, dynamic>),
            ),
          )
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final String? title;

  final String? code;

  final String? details;

  final String? director;

  final List<String>? urls;

  final String? date;

  final String? image;

  final String? remote_site_id;

  final Query$ScrapeSceneURL$scrapeSceneURL$studio? studio;

  final List<Query$ScrapeSceneURL$scrapeSceneURL$tags>? tags;

  final List<Query$ScrapeSceneURL$scrapeSceneURL$performers>? performers;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$title = title;
    _resultData['title'] = l$title;
    final l$code = code;
    _resultData['code'] = l$code;
    final l$details = details;
    _resultData['details'] = l$details;
    final l$director = director;
    _resultData['director'] = l$director;
    final l$urls = urls;
    _resultData['urls'] = l$urls?.map((e) => e).toList();
    final l$date = date;
    _resultData['date'] = l$date;
    final l$image = image;
    _resultData['image'] = l$image;
    final l$remote_site_id = remote_site_id;
    _resultData['remote_site_id'] = l$remote_site_id;
    final l$studio = studio;
    _resultData['studio'] = l$studio?.toJson();
    final l$tags = tags;
    _resultData['tags'] = l$tags?.map((e) => e.toJson()).toList();
    final l$performers = performers;
    _resultData['performers'] = l$performers?.map((e) => e.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$title = title;
    final l$code = code;
    final l$details = details;
    final l$director = director;
    final l$urls = urls;
    final l$date = date;
    final l$image = image;
    final l$remote_site_id = remote_site_id;
    final l$studio = studio;
    final l$tags = tags;
    final l$performers = performers;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$title,
      l$code,
      l$details,
      l$director,
      l$urls == null ? null : Object.hashAll(l$urls.map((v) => v)),
      l$date,
      l$image,
      l$remote_site_id,
      l$studio,
      l$tags == null ? null : Object.hashAll(l$tags.map((v) => v)),
      l$performers == null ? null : Object.hashAll(l$performers.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$ScrapeSceneURL$scrapeSceneURL ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$title = title;
    final lOther$title = other.title;
    if (l$title != lOther$title) {
      return false;
    }
    final l$code = code;
    final lOther$code = other.code;
    if (l$code != lOther$code) {
      return false;
    }
    final l$details = details;
    final lOther$details = other.details;
    if (l$details != lOther$details) {
      return false;
    }
    final l$director = director;
    final lOther$director = other.director;
    if (l$director != lOther$director) {
      return false;
    }
    final l$urls = urls;
    final lOther$urls = other.urls;
    if (l$urls != null && lOther$urls != null) {
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
    } else if (l$urls != lOther$urls) {
      return false;
    }
    final l$date = date;
    final lOther$date = other.date;
    if (l$date != lOther$date) {
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
    final l$studio = studio;
    final lOther$studio = other.studio;
    if (l$studio != lOther$studio) {
      return false;
    }
    final l$tags = tags;
    final lOther$tags = other.tags;
    if (l$tags != null && lOther$tags != null) {
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
    } else if (l$tags != lOther$tags) {
      return false;
    }
    final l$performers = performers;
    final lOther$performers = other.performers;
    if (l$performers != null && lOther$performers != null) {
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
    } else if (l$performers != lOther$performers) {
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

extension UtilityExtension$Query$ScrapeSceneURL$scrapeSceneURL
    on Query$ScrapeSceneURL$scrapeSceneURL {
  CopyWith$Query$ScrapeSceneURL$scrapeSceneURL<
    Query$ScrapeSceneURL$scrapeSceneURL
  >
  get copyWith => CopyWith$Query$ScrapeSceneURL$scrapeSceneURL(this, (i) => i);
}

abstract class CopyWith$Query$ScrapeSceneURL$scrapeSceneURL<TRes> {
  factory CopyWith$Query$ScrapeSceneURL$scrapeSceneURL(
    Query$ScrapeSceneURL$scrapeSceneURL instance,
    TRes Function(Query$ScrapeSceneURL$scrapeSceneURL) then,
  ) = _CopyWithImpl$Query$ScrapeSceneURL$scrapeSceneURL;

  factory CopyWith$Query$ScrapeSceneURL$scrapeSceneURL.stub(TRes res) =
      _CopyWithStubImpl$Query$ScrapeSceneURL$scrapeSceneURL;

  TRes call({
    String? title,
    String? code,
    String? details,
    String? director,
    List<String>? urls,
    String? date,
    String? image,
    String? remote_site_id,
    Query$ScrapeSceneURL$scrapeSceneURL$studio? studio,
    List<Query$ScrapeSceneURL$scrapeSceneURL$tags>? tags,
    List<Query$ScrapeSceneURL$scrapeSceneURL$performers>? performers,
    String? $__typename,
  });
  CopyWith$Query$ScrapeSceneURL$scrapeSceneURL$studio<TRes> get studio;
  TRes tags(
    Iterable<Query$ScrapeSceneURL$scrapeSceneURL$tags>? Function(
      Iterable<
        CopyWith$Query$ScrapeSceneURL$scrapeSceneURL$tags<
          Query$ScrapeSceneURL$scrapeSceneURL$tags
        >
      >?,
    )
    _fn,
  );
  TRes performers(
    Iterable<Query$ScrapeSceneURL$scrapeSceneURL$performers>? Function(
      Iterable<
        CopyWith$Query$ScrapeSceneURL$scrapeSceneURL$performers<
          Query$ScrapeSceneURL$scrapeSceneURL$performers
        >
      >?,
    )
    _fn,
  );
}

class _CopyWithImpl$Query$ScrapeSceneURL$scrapeSceneURL<TRes>
    implements CopyWith$Query$ScrapeSceneURL$scrapeSceneURL<TRes> {
  _CopyWithImpl$Query$ScrapeSceneURL$scrapeSceneURL(this._instance, this._then);

  final Query$ScrapeSceneURL$scrapeSceneURL _instance;

  final TRes Function(Query$ScrapeSceneURL$scrapeSceneURL) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? title = _undefined,
    Object? code = _undefined,
    Object? details = _undefined,
    Object? director = _undefined,
    Object? urls = _undefined,
    Object? date = _undefined,
    Object? image = _undefined,
    Object? remote_site_id = _undefined,
    Object? studio = _undefined,
    Object? tags = _undefined,
    Object? performers = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$ScrapeSceneURL$scrapeSceneURL(
      title: title == _undefined ? _instance.title : (title as String?),
      code: code == _undefined ? _instance.code : (code as String?),
      details: details == _undefined ? _instance.details : (details as String?),
      director: director == _undefined
          ? _instance.director
          : (director as String?),
      urls: urls == _undefined ? _instance.urls : (urls as List<String>?),
      date: date == _undefined ? _instance.date : (date as String?),
      image: image == _undefined ? _instance.image : (image as String?),
      remote_site_id: remote_site_id == _undefined
          ? _instance.remote_site_id
          : (remote_site_id as String?),
      studio: studio == _undefined
          ? _instance.studio
          : (studio as Query$ScrapeSceneURL$scrapeSceneURL$studio?),
      tags: tags == _undefined
          ? _instance.tags
          : (tags as List<Query$ScrapeSceneURL$scrapeSceneURL$tags>?),
      performers: performers == _undefined
          ? _instance.performers
          : (performers
                as List<Query$ScrapeSceneURL$scrapeSceneURL$performers>?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  CopyWith$Query$ScrapeSceneURL$scrapeSceneURL$studio<TRes> get studio {
    final local$studio = _instance.studio;
    return local$studio == null
        ? CopyWith$Query$ScrapeSceneURL$scrapeSceneURL$studio.stub(
            _then(_instance),
          )
        : CopyWith$Query$ScrapeSceneURL$scrapeSceneURL$studio(
            local$studio,
            (e) => call(studio: e),
          );
  }

  TRes tags(
    Iterable<Query$ScrapeSceneURL$scrapeSceneURL$tags>? Function(
      Iterable<
        CopyWith$Query$ScrapeSceneURL$scrapeSceneURL$tags<
          Query$ScrapeSceneURL$scrapeSceneURL$tags
        >
      >?,
    )
    _fn,
  ) => call(
    tags: _fn(
      _instance.tags?.map(
        (e) => CopyWith$Query$ScrapeSceneURL$scrapeSceneURL$tags(e, (i) => i),
      ),
    )?.toList(),
  );

  TRes performers(
    Iterable<Query$ScrapeSceneURL$scrapeSceneURL$performers>? Function(
      Iterable<
        CopyWith$Query$ScrapeSceneURL$scrapeSceneURL$performers<
          Query$ScrapeSceneURL$scrapeSceneURL$performers
        >
      >?,
    )
    _fn,
  ) => call(
    performers: _fn(
      _instance.performers?.map(
        (e) => CopyWith$Query$ScrapeSceneURL$scrapeSceneURL$performers(
          e,
          (i) => i,
        ),
      ),
    )?.toList(),
  );
}

class _CopyWithStubImpl$Query$ScrapeSceneURL$scrapeSceneURL<TRes>
    implements CopyWith$Query$ScrapeSceneURL$scrapeSceneURL<TRes> {
  _CopyWithStubImpl$Query$ScrapeSceneURL$scrapeSceneURL(this._res);

  TRes _res;

  call({
    String? title,
    String? code,
    String? details,
    String? director,
    List<String>? urls,
    String? date,
    String? image,
    String? remote_site_id,
    Query$ScrapeSceneURL$scrapeSceneURL$studio? studio,
    List<Query$ScrapeSceneURL$scrapeSceneURL$tags>? tags,
    List<Query$ScrapeSceneURL$scrapeSceneURL$performers>? performers,
    String? $__typename,
  }) => _res;

  CopyWith$Query$ScrapeSceneURL$scrapeSceneURL$studio<TRes> get studio =>
      CopyWith$Query$ScrapeSceneURL$scrapeSceneURL$studio.stub(_res);

  tags(_fn) => _res;

  performers(_fn) => _res;
}

class Query$ScrapeSceneURL$scrapeSceneURL$studio {
  Query$ScrapeSceneURL$scrapeSceneURL$studio({
    required this.name,
    this.stored_id,
    this.$__typename = 'ScrapedStudio',
  });

  factory Query$ScrapeSceneURL$scrapeSceneURL$studio.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$name = json['name'];
    final l$stored_id = json['stored_id'];
    final l$$__typename = json['__typename'];
    return Query$ScrapeSceneURL$scrapeSceneURL$studio(
      name: (l$name as String),
      stored_id: (l$stored_id as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String name;

  final String? stored_id;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$name = name;
    _resultData['name'] = l$name;
    final l$stored_id = stored_id;
    _resultData['stored_id'] = l$stored_id;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$name = name;
    final l$stored_id = stored_id;
    final l$$__typename = $__typename;
    return Object.hashAll([l$name, l$stored_id, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$ScrapeSceneURL$scrapeSceneURL$studio ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
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

extension UtilityExtension$Query$ScrapeSceneURL$scrapeSceneURL$studio
    on Query$ScrapeSceneURL$scrapeSceneURL$studio {
  CopyWith$Query$ScrapeSceneURL$scrapeSceneURL$studio<
    Query$ScrapeSceneURL$scrapeSceneURL$studio
  >
  get copyWith =>
      CopyWith$Query$ScrapeSceneURL$scrapeSceneURL$studio(this, (i) => i);
}

abstract class CopyWith$Query$ScrapeSceneURL$scrapeSceneURL$studio<TRes> {
  factory CopyWith$Query$ScrapeSceneURL$scrapeSceneURL$studio(
    Query$ScrapeSceneURL$scrapeSceneURL$studio instance,
    TRes Function(Query$ScrapeSceneURL$scrapeSceneURL$studio) then,
  ) = _CopyWithImpl$Query$ScrapeSceneURL$scrapeSceneURL$studio;

  factory CopyWith$Query$ScrapeSceneURL$scrapeSceneURL$studio.stub(TRes res) =
      _CopyWithStubImpl$Query$ScrapeSceneURL$scrapeSceneURL$studio;

  TRes call({String? name, String? stored_id, String? $__typename});
}

class _CopyWithImpl$Query$ScrapeSceneURL$scrapeSceneURL$studio<TRes>
    implements CopyWith$Query$ScrapeSceneURL$scrapeSceneURL$studio<TRes> {
  _CopyWithImpl$Query$ScrapeSceneURL$scrapeSceneURL$studio(
    this._instance,
    this._then,
  );

  final Query$ScrapeSceneURL$scrapeSceneURL$studio _instance;

  final TRes Function(Query$ScrapeSceneURL$scrapeSceneURL$studio) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? name = _undefined,
    Object? stored_id = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$ScrapeSceneURL$scrapeSceneURL$studio(
      name: name == _undefined || name == null
          ? _instance.name
          : (name as String),
      stored_id: stored_id == _undefined
          ? _instance.stored_id
          : (stored_id as String?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Query$ScrapeSceneURL$scrapeSceneURL$studio<TRes>
    implements CopyWith$Query$ScrapeSceneURL$scrapeSceneURL$studio<TRes> {
  _CopyWithStubImpl$Query$ScrapeSceneURL$scrapeSceneURL$studio(this._res);

  TRes _res;

  call({String? name, String? stored_id, String? $__typename}) => _res;
}

class Query$ScrapeSceneURL$scrapeSceneURL$tags {
  Query$ScrapeSceneURL$scrapeSceneURL$tags({
    required this.name,
    this.stored_id,
    this.$__typename = 'ScrapedTag',
  });

  factory Query$ScrapeSceneURL$scrapeSceneURL$tags.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$name = json['name'];
    final l$stored_id = json['stored_id'];
    final l$$__typename = json['__typename'];
    return Query$ScrapeSceneURL$scrapeSceneURL$tags(
      name: (l$name as String),
      stored_id: (l$stored_id as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String name;

  final String? stored_id;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$name = name;
    _resultData['name'] = l$name;
    final l$stored_id = stored_id;
    _resultData['stored_id'] = l$stored_id;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$name = name;
    final l$stored_id = stored_id;
    final l$$__typename = $__typename;
    return Object.hashAll([l$name, l$stored_id, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$ScrapeSceneURL$scrapeSceneURL$tags ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
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

extension UtilityExtension$Query$ScrapeSceneURL$scrapeSceneURL$tags
    on Query$ScrapeSceneURL$scrapeSceneURL$tags {
  CopyWith$Query$ScrapeSceneURL$scrapeSceneURL$tags<
    Query$ScrapeSceneURL$scrapeSceneURL$tags
  >
  get copyWith =>
      CopyWith$Query$ScrapeSceneURL$scrapeSceneURL$tags(this, (i) => i);
}

abstract class CopyWith$Query$ScrapeSceneURL$scrapeSceneURL$tags<TRes> {
  factory CopyWith$Query$ScrapeSceneURL$scrapeSceneURL$tags(
    Query$ScrapeSceneURL$scrapeSceneURL$tags instance,
    TRes Function(Query$ScrapeSceneURL$scrapeSceneURL$tags) then,
  ) = _CopyWithImpl$Query$ScrapeSceneURL$scrapeSceneURL$tags;

  factory CopyWith$Query$ScrapeSceneURL$scrapeSceneURL$tags.stub(TRes res) =
      _CopyWithStubImpl$Query$ScrapeSceneURL$scrapeSceneURL$tags;

  TRes call({String? name, String? stored_id, String? $__typename});
}

class _CopyWithImpl$Query$ScrapeSceneURL$scrapeSceneURL$tags<TRes>
    implements CopyWith$Query$ScrapeSceneURL$scrapeSceneURL$tags<TRes> {
  _CopyWithImpl$Query$ScrapeSceneURL$scrapeSceneURL$tags(
    this._instance,
    this._then,
  );

  final Query$ScrapeSceneURL$scrapeSceneURL$tags _instance;

  final TRes Function(Query$ScrapeSceneURL$scrapeSceneURL$tags) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? name = _undefined,
    Object? stored_id = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$ScrapeSceneURL$scrapeSceneURL$tags(
      name: name == _undefined || name == null
          ? _instance.name
          : (name as String),
      stored_id: stored_id == _undefined
          ? _instance.stored_id
          : (stored_id as String?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Query$ScrapeSceneURL$scrapeSceneURL$tags<TRes>
    implements CopyWith$Query$ScrapeSceneURL$scrapeSceneURL$tags<TRes> {
  _CopyWithStubImpl$Query$ScrapeSceneURL$scrapeSceneURL$tags(this._res);

  TRes _res;

  call({String? name, String? stored_id, String? $__typename}) => _res;
}

class Query$ScrapeSceneURL$scrapeSceneURL$performers {
  Query$ScrapeSceneURL$scrapeSceneURL$performers({
    this.name,
    this.remote_site_id,
    this.urls,
    this.images,
    this.stored_id,
    this.$__typename = 'ScrapedPerformer',
  });

  factory Query$ScrapeSceneURL$scrapeSceneURL$performers.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$name = json['name'];
    final l$remote_site_id = json['remote_site_id'];
    final l$urls = json['urls'];
    final l$images = json['images'];
    final l$stored_id = json['stored_id'];
    final l$$__typename = json['__typename'];
    return Query$ScrapeSceneURL$scrapeSceneURL$performers(
      name: (l$name as String?),
      remote_site_id: (l$remote_site_id as String?),
      urls: (l$urls as List<dynamic>?)?.map((e) => (e as String)).toList(),
      images: (l$images as List<dynamic>?)?.map((e) => (e as String)).toList(),
      stored_id: (l$stored_id as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String? name;

  final String? remote_site_id;

  final List<String>? urls;

  final List<String>? images;

  final String? stored_id;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$name = name;
    _resultData['name'] = l$name;
    final l$remote_site_id = remote_site_id;
    _resultData['remote_site_id'] = l$remote_site_id;
    final l$urls = urls;
    _resultData['urls'] = l$urls?.map((e) => e).toList();
    final l$images = images;
    _resultData['images'] = l$images?.map((e) => e).toList();
    final l$stored_id = stored_id;
    _resultData['stored_id'] = l$stored_id;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$name = name;
    final l$remote_site_id = remote_site_id;
    final l$urls = urls;
    final l$images = images;
    final l$stored_id = stored_id;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$name,
      l$remote_site_id,
      l$urls == null ? null : Object.hashAll(l$urls.map((v) => v)),
      l$images == null ? null : Object.hashAll(l$images.map((v) => v)),
      l$stored_id,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$ScrapeSceneURL$scrapeSceneURL$performers ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    final l$remote_site_id = remote_site_id;
    final lOther$remote_site_id = other.remote_site_id;
    if (l$remote_site_id != lOther$remote_site_id) {
      return false;
    }
    final l$urls = urls;
    final lOther$urls = other.urls;
    if (l$urls != null && lOther$urls != null) {
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
    } else if (l$urls != lOther$urls) {
      return false;
    }
    final l$images = images;
    final lOther$images = other.images;
    if (l$images != null && lOther$images != null) {
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
    } else if (l$images != lOther$images) {
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

extension UtilityExtension$Query$ScrapeSceneURL$scrapeSceneURL$performers
    on Query$ScrapeSceneURL$scrapeSceneURL$performers {
  CopyWith$Query$ScrapeSceneURL$scrapeSceneURL$performers<
    Query$ScrapeSceneURL$scrapeSceneURL$performers
  >
  get copyWith =>
      CopyWith$Query$ScrapeSceneURL$scrapeSceneURL$performers(this, (i) => i);
}

abstract class CopyWith$Query$ScrapeSceneURL$scrapeSceneURL$performers<TRes> {
  factory CopyWith$Query$ScrapeSceneURL$scrapeSceneURL$performers(
    Query$ScrapeSceneURL$scrapeSceneURL$performers instance,
    TRes Function(Query$ScrapeSceneURL$scrapeSceneURL$performers) then,
  ) = _CopyWithImpl$Query$ScrapeSceneURL$scrapeSceneURL$performers;

  factory CopyWith$Query$ScrapeSceneURL$scrapeSceneURL$performers.stub(
    TRes res,
  ) = _CopyWithStubImpl$Query$ScrapeSceneURL$scrapeSceneURL$performers;

  TRes call({
    String? name,
    String? remote_site_id,
    List<String>? urls,
    List<String>? images,
    String? stored_id,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$ScrapeSceneURL$scrapeSceneURL$performers<TRes>
    implements CopyWith$Query$ScrapeSceneURL$scrapeSceneURL$performers<TRes> {
  _CopyWithImpl$Query$ScrapeSceneURL$scrapeSceneURL$performers(
    this._instance,
    this._then,
  );

  final Query$ScrapeSceneURL$scrapeSceneURL$performers _instance;

  final TRes Function(Query$ScrapeSceneURL$scrapeSceneURL$performers) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? name = _undefined,
    Object? remote_site_id = _undefined,
    Object? urls = _undefined,
    Object? images = _undefined,
    Object? stored_id = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$ScrapeSceneURL$scrapeSceneURL$performers(
      name: name == _undefined ? _instance.name : (name as String?),
      remote_site_id: remote_site_id == _undefined
          ? _instance.remote_site_id
          : (remote_site_id as String?),
      urls: urls == _undefined ? _instance.urls : (urls as List<String>?),
      images: images == _undefined
          ? _instance.images
          : (images as List<String>?),
      stored_id: stored_id == _undefined
          ? _instance.stored_id
          : (stored_id as String?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Query$ScrapeSceneURL$scrapeSceneURL$performers<TRes>
    implements CopyWith$Query$ScrapeSceneURL$scrapeSceneURL$performers<TRes> {
  _CopyWithStubImpl$Query$ScrapeSceneURL$scrapeSceneURL$performers(this._res);

  TRes _res;

  call({
    String? name,
    String? remote_site_id,
    List<String>? urls,
    List<String>? images,
    String? stored_id,
    String? $__typename,
  }) => _res;
}

class Variables$Mutation$SceneMerge {
  factory Variables$Mutation$SceneMerge({
    required Input$SceneMergeInput input,
  }) => Variables$Mutation$SceneMerge._({r'input': input});

  Variables$Mutation$SceneMerge._(this._$data);

  factory Variables$Mutation$SceneMerge.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$input = data['input'];
    result$data['input'] = Input$SceneMergeInput.fromJson(
      (l$input as Map<String, dynamic>),
    );
    return Variables$Mutation$SceneMerge._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$SceneMergeInput get input => (_$data['input'] as Input$SceneMergeInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$input = input;
    result$data['input'] = l$input.toJson();
    return result$data;
  }

  CopyWith$Variables$Mutation$SceneMerge<Variables$Mutation$SceneMerge>
  get copyWith => CopyWith$Variables$Mutation$SceneMerge(this, (i) => i);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$SceneMerge ||
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

abstract class CopyWith$Variables$Mutation$SceneMerge<TRes> {
  factory CopyWith$Variables$Mutation$SceneMerge(
    Variables$Mutation$SceneMerge instance,
    TRes Function(Variables$Mutation$SceneMerge) then,
  ) = _CopyWithImpl$Variables$Mutation$SceneMerge;

  factory CopyWith$Variables$Mutation$SceneMerge.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$SceneMerge;

  TRes call({Input$SceneMergeInput? input});
}

class _CopyWithImpl$Variables$Mutation$SceneMerge<TRes>
    implements CopyWith$Variables$Mutation$SceneMerge<TRes> {
  _CopyWithImpl$Variables$Mutation$SceneMerge(this._instance, this._then);

  final Variables$Mutation$SceneMerge _instance;

  final TRes Function(Variables$Mutation$SceneMerge) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? input = _undefined}) => _then(
    Variables$Mutation$SceneMerge._({
      ..._instance._$data,
      if (input != _undefined && input != null)
        'input': (input as Input$SceneMergeInput),
    }),
  );
}

class _CopyWithStubImpl$Variables$Mutation$SceneMerge<TRes>
    implements CopyWith$Variables$Mutation$SceneMerge<TRes> {
  _CopyWithStubImpl$Variables$Mutation$SceneMerge(this._res);

  TRes _res;

  call({Input$SceneMergeInput? input}) => _res;
}

class Mutation$SceneMerge {
  Mutation$SceneMerge({this.sceneMerge, this.$__typename = 'Mutation'});

  factory Mutation$SceneMerge.fromJson(Map<String, dynamic> json) {
    final l$sceneMerge = json['sceneMerge'];
    final l$$__typename = json['__typename'];
    return Mutation$SceneMerge(
      sceneMerge: l$sceneMerge == null
          ? null
          : Mutation$SceneMerge$sceneMerge.fromJson(
              (l$sceneMerge as Map<String, dynamic>),
            ),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$SceneMerge$sceneMerge? sceneMerge;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$sceneMerge = sceneMerge;
    _resultData['sceneMerge'] = l$sceneMerge?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$sceneMerge = sceneMerge;
    final l$$__typename = $__typename;
    return Object.hashAll([l$sceneMerge, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$SceneMerge || runtimeType != other.runtimeType) {
      return false;
    }
    final l$sceneMerge = sceneMerge;
    final lOther$sceneMerge = other.sceneMerge;
    if (l$sceneMerge != lOther$sceneMerge) {
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

extension UtilityExtension$Mutation$SceneMerge on Mutation$SceneMerge {
  CopyWith$Mutation$SceneMerge<Mutation$SceneMerge> get copyWith =>
      CopyWith$Mutation$SceneMerge(this, (i) => i);
}

abstract class CopyWith$Mutation$SceneMerge<TRes> {
  factory CopyWith$Mutation$SceneMerge(
    Mutation$SceneMerge instance,
    TRes Function(Mutation$SceneMerge) then,
  ) = _CopyWithImpl$Mutation$SceneMerge;

  factory CopyWith$Mutation$SceneMerge.stub(TRes res) =
      _CopyWithStubImpl$Mutation$SceneMerge;

  TRes call({Mutation$SceneMerge$sceneMerge? sceneMerge, String? $__typename});
  CopyWith$Mutation$SceneMerge$sceneMerge<TRes> get sceneMerge;
}

class _CopyWithImpl$Mutation$SceneMerge<TRes>
    implements CopyWith$Mutation$SceneMerge<TRes> {
  _CopyWithImpl$Mutation$SceneMerge(this._instance, this._then);

  final Mutation$SceneMerge _instance;

  final TRes Function(Mutation$SceneMerge) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? sceneMerge = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Mutation$SceneMerge(
      sceneMerge: sceneMerge == _undefined
          ? _instance.sceneMerge
          : (sceneMerge as Mutation$SceneMerge$sceneMerge?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  CopyWith$Mutation$SceneMerge$sceneMerge<TRes> get sceneMerge {
    final local$sceneMerge = _instance.sceneMerge;
    return local$sceneMerge == null
        ? CopyWith$Mutation$SceneMerge$sceneMerge.stub(_then(_instance))
        : CopyWith$Mutation$SceneMerge$sceneMerge(
            local$sceneMerge,
            (e) => call(sceneMerge: e),
          );
  }
}

class _CopyWithStubImpl$Mutation$SceneMerge<TRes>
    implements CopyWith$Mutation$SceneMerge<TRes> {
  _CopyWithStubImpl$Mutation$SceneMerge(this._res);

  TRes _res;

  call({Mutation$SceneMerge$sceneMerge? sceneMerge, String? $__typename}) =>
      _res;

  CopyWith$Mutation$SceneMerge$sceneMerge<TRes> get sceneMerge =>
      CopyWith$Mutation$SceneMerge$sceneMerge.stub(_res);
}

const documentNodeMutationSceneMerge = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.mutation,
      name: NameNode(value: 'SceneMerge'),
      variableDefinitions: [
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'input')),
          type: NamedTypeNode(
            name: NameNode(value: 'SceneMergeInput'),
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
            name: NameNode(value: 'sceneMerge'),
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
Mutation$SceneMerge _parserFn$Mutation$SceneMerge(Map<String, dynamic> data) =>
    Mutation$SceneMerge.fromJson(data);
typedef OnMutationCompleted$Mutation$SceneMerge =
    FutureOr<void> Function(Map<String, dynamic>?, Mutation$SceneMerge?);

class Options$Mutation$SceneMerge
    extends graphql.MutationOptions<Mutation$SceneMerge> {
  Options$Mutation$SceneMerge({
    String? operationName,
    required Variables$Mutation$SceneMerge variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$SceneMerge? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$SceneMerge? onCompleted,
    graphql.OnMutationUpdate<Mutation$SceneMerge>? update,
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
                 data == null ? null : _parserFn$Mutation$SceneMerge(data),
               ),
         update: update,
         onError: onError,
         document: documentNodeMutationSceneMerge,
         parserFn: _parserFn$Mutation$SceneMerge,
       );

  final OnMutationCompleted$Mutation$SceneMerge? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
    ...super.onCompleted == null
        ? super.properties
        : super.properties.where((property) => property != onCompleted),
    onCompletedWithParsed,
  ];
}

class WatchOptions$Mutation$SceneMerge
    extends graphql.WatchQueryOptions<Mutation$SceneMerge> {
  WatchOptions$Mutation$SceneMerge({
    String? operationName,
    required Variables$Mutation$SceneMerge variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$SceneMerge? typedOptimisticResult,
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
         document: documentNodeMutationSceneMerge,
         pollInterval: pollInterval,
         eagerlyFetchResults: eagerlyFetchResults,
         carryForwardDataOnException: carryForwardDataOnException,
         fetchResults: fetchResults,
         parserFn: _parserFn$Mutation$SceneMerge,
       );
}

extension ClientExtension$Mutation$SceneMerge on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$SceneMerge>> mutate$SceneMerge(
    Options$Mutation$SceneMerge options,
  ) async => await this.mutate(options);

  graphql.ObservableQuery<Mutation$SceneMerge> watchMutation$SceneMerge(
    WatchOptions$Mutation$SceneMerge options,
  ) => this.watchMutation(options);
}

class Mutation$SceneMerge$sceneMerge {
  Mutation$SceneMerge$sceneMerge({
    required this.id,
    this.$__typename = 'Scene',
  });

  factory Mutation$SceneMerge$sceneMerge.fromJson(Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$$__typename = json['__typename'];
    return Mutation$SceneMerge$sceneMerge(
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
    if (other is! Mutation$SceneMerge$sceneMerge ||
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

extension UtilityExtension$Mutation$SceneMerge$sceneMerge
    on Mutation$SceneMerge$sceneMerge {
  CopyWith$Mutation$SceneMerge$sceneMerge<Mutation$SceneMerge$sceneMerge>
  get copyWith => CopyWith$Mutation$SceneMerge$sceneMerge(this, (i) => i);
}

abstract class CopyWith$Mutation$SceneMerge$sceneMerge<TRes> {
  factory CopyWith$Mutation$SceneMerge$sceneMerge(
    Mutation$SceneMerge$sceneMerge instance,
    TRes Function(Mutation$SceneMerge$sceneMerge) then,
  ) = _CopyWithImpl$Mutation$SceneMerge$sceneMerge;

  factory CopyWith$Mutation$SceneMerge$sceneMerge.stub(TRes res) =
      _CopyWithStubImpl$Mutation$SceneMerge$sceneMerge;

  TRes call({String? id, String? $__typename});
}

class _CopyWithImpl$Mutation$SceneMerge$sceneMerge<TRes>
    implements CopyWith$Mutation$SceneMerge$sceneMerge<TRes> {
  _CopyWithImpl$Mutation$SceneMerge$sceneMerge(this._instance, this._then);

  final Mutation$SceneMerge$sceneMerge _instance;

  final TRes Function(Mutation$SceneMerge$sceneMerge) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? id = _undefined, Object? $__typename = _undefined}) =>
      _then(
        Mutation$SceneMerge$sceneMerge(
          id: id == _undefined || id == null ? _instance.id : (id as String),
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String),
        ),
      );
}

class _CopyWithStubImpl$Mutation$SceneMerge$sceneMerge<TRes>
    implements CopyWith$Mutation$SceneMerge$sceneMerge<TRes> {
  _CopyWithStubImpl$Mutation$SceneMerge$sceneMerge(this._res);

  TRes _res;

  call({String? id, String? $__typename}) => _res;
}

class Variables$Mutation$SceneUpdate {
  factory Variables$Mutation$SceneUpdate({
    required Input$SceneUpdateInput input,
  }) => Variables$Mutation$SceneUpdate._({r'input': input});

  Variables$Mutation$SceneUpdate._(this._$data);

  factory Variables$Mutation$SceneUpdate.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$input = data['input'];
    result$data['input'] = Input$SceneUpdateInput.fromJson(
      (l$input as Map<String, dynamic>),
    );
    return Variables$Mutation$SceneUpdate._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$SceneUpdateInput get input =>
      (_$data['input'] as Input$SceneUpdateInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$input = input;
    result$data['input'] = l$input.toJson();
    return result$data;
  }

  CopyWith$Variables$Mutation$SceneUpdate<Variables$Mutation$SceneUpdate>
  get copyWith => CopyWith$Variables$Mutation$SceneUpdate(this, (i) => i);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$SceneUpdate ||
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

abstract class CopyWith$Variables$Mutation$SceneUpdate<TRes> {
  factory CopyWith$Variables$Mutation$SceneUpdate(
    Variables$Mutation$SceneUpdate instance,
    TRes Function(Variables$Mutation$SceneUpdate) then,
  ) = _CopyWithImpl$Variables$Mutation$SceneUpdate;

  factory CopyWith$Variables$Mutation$SceneUpdate.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$SceneUpdate;

  TRes call({Input$SceneUpdateInput? input});
}

class _CopyWithImpl$Variables$Mutation$SceneUpdate<TRes>
    implements CopyWith$Variables$Mutation$SceneUpdate<TRes> {
  _CopyWithImpl$Variables$Mutation$SceneUpdate(this._instance, this._then);

  final Variables$Mutation$SceneUpdate _instance;

  final TRes Function(Variables$Mutation$SceneUpdate) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? input = _undefined}) => _then(
    Variables$Mutation$SceneUpdate._({
      ..._instance._$data,
      if (input != _undefined && input != null)
        'input': (input as Input$SceneUpdateInput),
    }),
  );
}

class _CopyWithStubImpl$Variables$Mutation$SceneUpdate<TRes>
    implements CopyWith$Variables$Mutation$SceneUpdate<TRes> {
  _CopyWithStubImpl$Variables$Mutation$SceneUpdate(this._res);

  TRes _res;

  call({Input$SceneUpdateInput? input}) => _res;
}

class Mutation$SceneUpdate {
  Mutation$SceneUpdate({this.sceneUpdate, this.$__typename = 'Mutation'});

  factory Mutation$SceneUpdate.fromJson(Map<String, dynamic> json) {
    final l$sceneUpdate = json['sceneUpdate'];
    final l$$__typename = json['__typename'];
    return Mutation$SceneUpdate(
      sceneUpdate: l$sceneUpdate == null
          ? null
          : Mutation$SceneUpdate$sceneUpdate.fromJson(
              (l$sceneUpdate as Map<String, dynamic>),
            ),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$SceneUpdate$sceneUpdate? sceneUpdate;

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
    if (other is! Mutation$SceneUpdate || runtimeType != other.runtimeType) {
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

extension UtilityExtension$Mutation$SceneUpdate on Mutation$SceneUpdate {
  CopyWith$Mutation$SceneUpdate<Mutation$SceneUpdate> get copyWith =>
      CopyWith$Mutation$SceneUpdate(this, (i) => i);
}

abstract class CopyWith$Mutation$SceneUpdate<TRes> {
  factory CopyWith$Mutation$SceneUpdate(
    Mutation$SceneUpdate instance,
    TRes Function(Mutation$SceneUpdate) then,
  ) = _CopyWithImpl$Mutation$SceneUpdate;

  factory CopyWith$Mutation$SceneUpdate.stub(TRes res) =
      _CopyWithStubImpl$Mutation$SceneUpdate;

  TRes call({
    Mutation$SceneUpdate$sceneUpdate? sceneUpdate,
    String? $__typename,
  });
  CopyWith$Mutation$SceneUpdate$sceneUpdate<TRes> get sceneUpdate;
}

class _CopyWithImpl$Mutation$SceneUpdate<TRes>
    implements CopyWith$Mutation$SceneUpdate<TRes> {
  _CopyWithImpl$Mutation$SceneUpdate(this._instance, this._then);

  final Mutation$SceneUpdate _instance;

  final TRes Function(Mutation$SceneUpdate) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? sceneUpdate = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Mutation$SceneUpdate(
      sceneUpdate: sceneUpdate == _undefined
          ? _instance.sceneUpdate
          : (sceneUpdate as Mutation$SceneUpdate$sceneUpdate?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  CopyWith$Mutation$SceneUpdate$sceneUpdate<TRes> get sceneUpdate {
    final local$sceneUpdate = _instance.sceneUpdate;
    return local$sceneUpdate == null
        ? CopyWith$Mutation$SceneUpdate$sceneUpdate.stub(_then(_instance))
        : CopyWith$Mutation$SceneUpdate$sceneUpdate(
            local$sceneUpdate,
            (e) => call(sceneUpdate: e),
          );
  }
}

class _CopyWithStubImpl$Mutation$SceneUpdate<TRes>
    implements CopyWith$Mutation$SceneUpdate<TRes> {
  _CopyWithStubImpl$Mutation$SceneUpdate(this._res);

  TRes _res;

  call({Mutation$SceneUpdate$sceneUpdate? sceneUpdate, String? $__typename}) =>
      _res;

  CopyWith$Mutation$SceneUpdate$sceneUpdate<TRes> get sceneUpdate =>
      CopyWith$Mutation$SceneUpdate$sceneUpdate.stub(_res);
}

const documentNodeMutationSceneUpdate = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.mutation,
      name: NameNode(value: 'SceneUpdate'),
      variableDefinitions: [
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'input')),
          type: NamedTypeNode(
            name: NameNode(value: 'SceneUpdateInput'),
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
            name: NameNode(value: 'sceneUpdate'),
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
Mutation$SceneUpdate _parserFn$Mutation$SceneUpdate(
  Map<String, dynamic> data,
) => Mutation$SceneUpdate.fromJson(data);
typedef OnMutationCompleted$Mutation$SceneUpdate =
    FutureOr<void> Function(Map<String, dynamic>?, Mutation$SceneUpdate?);

class Options$Mutation$SceneUpdate
    extends graphql.MutationOptions<Mutation$SceneUpdate> {
  Options$Mutation$SceneUpdate({
    String? operationName,
    required Variables$Mutation$SceneUpdate variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$SceneUpdate? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$SceneUpdate? onCompleted,
    graphql.OnMutationUpdate<Mutation$SceneUpdate>? update,
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
                 data == null ? null : _parserFn$Mutation$SceneUpdate(data),
               ),
         update: update,
         onError: onError,
         document: documentNodeMutationSceneUpdate,
         parserFn: _parserFn$Mutation$SceneUpdate,
       );

  final OnMutationCompleted$Mutation$SceneUpdate? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
    ...super.onCompleted == null
        ? super.properties
        : super.properties.where((property) => property != onCompleted),
    onCompletedWithParsed,
  ];
}

class WatchOptions$Mutation$SceneUpdate
    extends graphql.WatchQueryOptions<Mutation$SceneUpdate> {
  WatchOptions$Mutation$SceneUpdate({
    String? operationName,
    required Variables$Mutation$SceneUpdate variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$SceneUpdate? typedOptimisticResult,
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
         document: documentNodeMutationSceneUpdate,
         pollInterval: pollInterval,
         eagerlyFetchResults: eagerlyFetchResults,
         carryForwardDataOnException: carryForwardDataOnException,
         fetchResults: fetchResults,
         parserFn: _parserFn$Mutation$SceneUpdate,
       );
}

extension ClientExtension$Mutation$SceneUpdate on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$SceneUpdate>> mutate$SceneUpdate(
    Options$Mutation$SceneUpdate options,
  ) async => await this.mutate(options);

  graphql.ObservableQuery<Mutation$SceneUpdate> watchMutation$SceneUpdate(
    WatchOptions$Mutation$SceneUpdate options,
  ) => this.watchMutation(options);
}

class Mutation$SceneUpdate$sceneUpdate {
  Mutation$SceneUpdate$sceneUpdate({
    required this.id,
    this.$__typename = 'Scene',
  });

  factory Mutation$SceneUpdate$sceneUpdate.fromJson(Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$$__typename = json['__typename'];
    return Mutation$SceneUpdate$sceneUpdate(
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
    if (other is! Mutation$SceneUpdate$sceneUpdate ||
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

extension UtilityExtension$Mutation$SceneUpdate$sceneUpdate
    on Mutation$SceneUpdate$sceneUpdate {
  CopyWith$Mutation$SceneUpdate$sceneUpdate<Mutation$SceneUpdate$sceneUpdate>
  get copyWith => CopyWith$Mutation$SceneUpdate$sceneUpdate(this, (i) => i);
}

abstract class CopyWith$Mutation$SceneUpdate$sceneUpdate<TRes> {
  factory CopyWith$Mutation$SceneUpdate$sceneUpdate(
    Mutation$SceneUpdate$sceneUpdate instance,
    TRes Function(Mutation$SceneUpdate$sceneUpdate) then,
  ) = _CopyWithImpl$Mutation$SceneUpdate$sceneUpdate;

  factory CopyWith$Mutation$SceneUpdate$sceneUpdate.stub(TRes res) =
      _CopyWithStubImpl$Mutation$SceneUpdate$sceneUpdate;

  TRes call({String? id, String? $__typename});
}

class _CopyWithImpl$Mutation$SceneUpdate$sceneUpdate<TRes>
    implements CopyWith$Mutation$SceneUpdate$sceneUpdate<TRes> {
  _CopyWithImpl$Mutation$SceneUpdate$sceneUpdate(this._instance, this._then);

  final Mutation$SceneUpdate$sceneUpdate _instance;

  final TRes Function(Mutation$SceneUpdate$sceneUpdate) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? id = _undefined, Object? $__typename = _undefined}) =>
      _then(
        Mutation$SceneUpdate$sceneUpdate(
          id: id == _undefined || id == null ? _instance.id : (id as String),
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String),
        ),
      );
}

class _CopyWithStubImpl$Mutation$SceneUpdate$sceneUpdate<TRes>
    implements CopyWith$Mutation$SceneUpdate$sceneUpdate<TRes> {
  _CopyWithStubImpl$Mutation$SceneUpdate$sceneUpdate(this._res);

  TRes _res;

  call({String? id, String? $__typename}) => _res;
}

class Variables$Query$SceneStreamsForPlayer {
  factory Variables$Query$SceneStreamsForPlayer({required String id}) =>
      Variables$Query$SceneStreamsForPlayer._({r'id': id});

  Variables$Query$SceneStreamsForPlayer._(this._$data);

  factory Variables$Query$SceneStreamsForPlayer.fromJson(
    Map<String, dynamic> data,
  ) {
    final result$data = <String, dynamic>{};
    final l$id = data['id'];
    result$data['id'] = (l$id as String);
    return Variables$Query$SceneStreamsForPlayer._(result$data);
  }

  Map<String, dynamic> _$data;

  String get id => (_$data['id'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$id = id;
    result$data['id'] = l$id;
    return result$data;
  }

  CopyWith$Variables$Query$SceneStreamsForPlayer<
    Variables$Query$SceneStreamsForPlayer
  >
  get copyWith =>
      CopyWith$Variables$Query$SceneStreamsForPlayer(this, (i) => i);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$SceneStreamsForPlayer ||
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

abstract class CopyWith$Variables$Query$SceneStreamsForPlayer<TRes> {
  factory CopyWith$Variables$Query$SceneStreamsForPlayer(
    Variables$Query$SceneStreamsForPlayer instance,
    TRes Function(Variables$Query$SceneStreamsForPlayer) then,
  ) = _CopyWithImpl$Variables$Query$SceneStreamsForPlayer;

  factory CopyWith$Variables$Query$SceneStreamsForPlayer.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$SceneStreamsForPlayer;

  TRes call({String? id});
}

class _CopyWithImpl$Variables$Query$SceneStreamsForPlayer<TRes>
    implements CopyWith$Variables$Query$SceneStreamsForPlayer<TRes> {
  _CopyWithImpl$Variables$Query$SceneStreamsForPlayer(
    this._instance,
    this._then,
  );

  final Variables$Query$SceneStreamsForPlayer _instance;

  final TRes Function(Variables$Query$SceneStreamsForPlayer) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? id = _undefined}) => _then(
    Variables$Query$SceneStreamsForPlayer._({
      ..._instance._$data,
      if (id != _undefined && id != null) 'id': (id as String),
    }),
  );
}

class _CopyWithStubImpl$Variables$Query$SceneStreamsForPlayer<TRes>
    implements CopyWith$Variables$Query$SceneStreamsForPlayer<TRes> {
  _CopyWithStubImpl$Variables$Query$SceneStreamsForPlayer(this._res);

  TRes _res;

  call({String? id}) => _res;
}

class Query$SceneStreamsForPlayer {
  Query$SceneStreamsForPlayer({
    required this.sceneStreams,
    this.findScene,
    this.$__typename = 'Query',
  });

  factory Query$SceneStreamsForPlayer.fromJson(Map<String, dynamic> json) {
    final l$sceneStreams = json['sceneStreams'];
    final l$findScene = json['findScene'];
    final l$$__typename = json['__typename'];
    return Query$SceneStreamsForPlayer(
      sceneStreams: (l$sceneStreams as List<dynamic>)
          .map(
            (e) => Query$SceneStreamsForPlayer$sceneStreams.fromJson(
              (e as Map<String, dynamic>),
            ),
          )
          .toList(),
      findScene: l$findScene == null
          ? null
          : Query$SceneStreamsForPlayer$findScene.fromJson(
              (l$findScene as Map<String, dynamic>),
            ),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Query$SceneStreamsForPlayer$sceneStreams> sceneStreams;

  final Query$SceneStreamsForPlayer$findScene? findScene;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$sceneStreams = sceneStreams;
    _resultData['sceneStreams'] = l$sceneStreams
        .map((e) => e.toJson())
        .toList();
    final l$findScene = findScene;
    _resultData['findScene'] = l$findScene?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$sceneStreams = sceneStreams;
    final l$findScene = findScene;
    final l$$__typename = $__typename;
    return Object.hashAll([
      Object.hashAll(l$sceneStreams.map((v) => v)),
      l$findScene,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$SceneStreamsForPlayer ||
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

extension UtilityExtension$Query$SceneStreamsForPlayer
    on Query$SceneStreamsForPlayer {
  CopyWith$Query$SceneStreamsForPlayer<Query$SceneStreamsForPlayer>
  get copyWith => CopyWith$Query$SceneStreamsForPlayer(this, (i) => i);
}

abstract class CopyWith$Query$SceneStreamsForPlayer<TRes> {
  factory CopyWith$Query$SceneStreamsForPlayer(
    Query$SceneStreamsForPlayer instance,
    TRes Function(Query$SceneStreamsForPlayer) then,
  ) = _CopyWithImpl$Query$SceneStreamsForPlayer;

  factory CopyWith$Query$SceneStreamsForPlayer.stub(TRes res) =
      _CopyWithStubImpl$Query$SceneStreamsForPlayer;

  TRes call({
    List<Query$SceneStreamsForPlayer$sceneStreams>? sceneStreams,
    Query$SceneStreamsForPlayer$findScene? findScene,
    String? $__typename,
  });
  TRes sceneStreams(
    Iterable<Query$SceneStreamsForPlayer$sceneStreams> Function(
      Iterable<
        CopyWith$Query$SceneStreamsForPlayer$sceneStreams<
          Query$SceneStreamsForPlayer$sceneStreams
        >
      >,
    )
    _fn,
  );
  CopyWith$Query$SceneStreamsForPlayer$findScene<TRes> get findScene;
}

class _CopyWithImpl$Query$SceneStreamsForPlayer<TRes>
    implements CopyWith$Query$SceneStreamsForPlayer<TRes> {
  _CopyWithImpl$Query$SceneStreamsForPlayer(this._instance, this._then);

  final Query$SceneStreamsForPlayer _instance;

  final TRes Function(Query$SceneStreamsForPlayer) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? sceneStreams = _undefined,
    Object? findScene = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$SceneStreamsForPlayer(
      sceneStreams: sceneStreams == _undefined || sceneStreams == null
          ? _instance.sceneStreams
          : (sceneStreams as List<Query$SceneStreamsForPlayer$sceneStreams>),
      findScene: findScene == _undefined
          ? _instance.findScene
          : (findScene as Query$SceneStreamsForPlayer$findScene?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  TRes sceneStreams(
    Iterable<Query$SceneStreamsForPlayer$sceneStreams> Function(
      Iterable<
        CopyWith$Query$SceneStreamsForPlayer$sceneStreams<
          Query$SceneStreamsForPlayer$sceneStreams
        >
      >,
    )
    _fn,
  ) => call(
    sceneStreams: _fn(
      _instance.sceneStreams.map(
        (e) => CopyWith$Query$SceneStreamsForPlayer$sceneStreams(e, (i) => i),
      ),
    ).toList(),
  );

  CopyWith$Query$SceneStreamsForPlayer$findScene<TRes> get findScene {
    final local$findScene = _instance.findScene;
    return local$findScene == null
        ? CopyWith$Query$SceneStreamsForPlayer$findScene.stub(_then(_instance))
        : CopyWith$Query$SceneStreamsForPlayer$findScene(
            local$findScene,
            (e) => call(findScene: e),
          );
  }
}

class _CopyWithStubImpl$Query$SceneStreamsForPlayer<TRes>
    implements CopyWith$Query$SceneStreamsForPlayer<TRes> {
  _CopyWithStubImpl$Query$SceneStreamsForPlayer(this._res);

  TRes _res;

  call({
    List<Query$SceneStreamsForPlayer$sceneStreams>? sceneStreams,
    Query$SceneStreamsForPlayer$findScene? findScene,
    String? $__typename,
  }) => _res;

  sceneStreams(_fn) => _res;

  CopyWith$Query$SceneStreamsForPlayer$findScene<TRes> get findScene =>
      CopyWith$Query$SceneStreamsForPlayer$findScene.stub(_res);
}

const documentNodeQuerySceneStreamsForPlayer = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.query,
      name: NameNode(value: 'SceneStreamsForPlayer'),
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
            name: NameNode(value: 'sceneStreams'),
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
Query$SceneStreamsForPlayer _parserFn$Query$SceneStreamsForPlayer(
  Map<String, dynamic> data,
) => Query$SceneStreamsForPlayer.fromJson(data);
typedef OnQueryComplete$Query$SceneStreamsForPlayer =
    FutureOr<void> Function(
      Map<String, dynamic>?,
      Query$SceneStreamsForPlayer?,
    );

class Options$Query$SceneStreamsForPlayer
    extends graphql.QueryOptions<Query$SceneStreamsForPlayer> {
  Options$Query$SceneStreamsForPlayer({
    String? operationName,
    required Variables$Query$SceneStreamsForPlayer variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$SceneStreamsForPlayer? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$SceneStreamsForPlayer? onComplete,
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
                 data == null
                     ? null
                     : _parserFn$Query$SceneStreamsForPlayer(data),
               ),
         onError: onError,
         document: documentNodeQuerySceneStreamsForPlayer,
         parserFn: _parserFn$Query$SceneStreamsForPlayer,
       );

  final OnQueryComplete$Query$SceneStreamsForPlayer? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
    ...super.onComplete == null
        ? super.properties
        : super.properties.where((property) => property != onComplete),
    onCompleteWithParsed,
  ];
}

class WatchOptions$Query$SceneStreamsForPlayer
    extends graphql.WatchQueryOptions<Query$SceneStreamsForPlayer> {
  WatchOptions$Query$SceneStreamsForPlayer({
    String? operationName,
    required Variables$Query$SceneStreamsForPlayer variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$SceneStreamsForPlayer? typedOptimisticResult,
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
         document: documentNodeQuerySceneStreamsForPlayer,
         pollInterval: pollInterval,
         eagerlyFetchResults: eagerlyFetchResults,
         carryForwardDataOnException: carryForwardDataOnException,
         fetchResults: fetchResults,
         parserFn: _parserFn$Query$SceneStreamsForPlayer,
       );
}

class FetchMoreOptions$Query$SceneStreamsForPlayer
    extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$SceneStreamsForPlayer({
    required graphql.UpdateQuery updateQuery,
    required Variables$Query$SceneStreamsForPlayer variables,
  }) : super(
         updateQuery: updateQuery,
         variables: variables.toJson(),
         document: documentNodeQuerySceneStreamsForPlayer,
       );
}

extension ClientExtension$Query$SceneStreamsForPlayer on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$SceneStreamsForPlayer>>
  query$SceneStreamsForPlayer(
    Options$Query$SceneStreamsForPlayer options,
  ) async => await this.query(options);

  graphql.ObservableQuery<Query$SceneStreamsForPlayer>
  watchQuery$SceneStreamsForPlayer(
    WatchOptions$Query$SceneStreamsForPlayer options,
  ) => this.watchQuery(options);

  void writeQuery$SceneStreamsForPlayer({
    required Query$SceneStreamsForPlayer data,
    required Variables$Query$SceneStreamsForPlayer variables,
    bool broadcast = true,
  }) => this.writeQuery(
    graphql.Request(
      operation: graphql.Operation(
        document: documentNodeQuerySceneStreamsForPlayer,
      ),
      variables: variables.toJson(),
    ),
    data: data.toJson(),
    broadcast: broadcast,
  );

  Query$SceneStreamsForPlayer? readQuery$SceneStreamsForPlayer({
    required Variables$Query$SceneStreamsForPlayer variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(
          document: documentNodeQuerySceneStreamsForPlayer,
        ),
        variables: variables.toJson(),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$SceneStreamsForPlayer.fromJson(result);
  }
}

class Query$SceneStreamsForPlayer$sceneStreams {
  Query$SceneStreamsForPlayer$sceneStreams({
    required this.url,
    this.mime_type,
    this.label,
    this.$__typename = 'SceneStreamEndpoint',
  });

  factory Query$SceneStreamsForPlayer$sceneStreams.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$url = json['url'];
    final l$mime_type = json['mime_type'];
    final l$label = json['label'];
    final l$$__typename = json['__typename'];
    return Query$SceneStreamsForPlayer$sceneStreams(
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
    if (other is! Query$SceneStreamsForPlayer$sceneStreams ||
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

extension UtilityExtension$Query$SceneStreamsForPlayer$sceneStreams
    on Query$SceneStreamsForPlayer$sceneStreams {
  CopyWith$Query$SceneStreamsForPlayer$sceneStreams<
    Query$SceneStreamsForPlayer$sceneStreams
  >
  get copyWith =>
      CopyWith$Query$SceneStreamsForPlayer$sceneStreams(this, (i) => i);
}

abstract class CopyWith$Query$SceneStreamsForPlayer$sceneStreams<TRes> {
  factory CopyWith$Query$SceneStreamsForPlayer$sceneStreams(
    Query$SceneStreamsForPlayer$sceneStreams instance,
    TRes Function(Query$SceneStreamsForPlayer$sceneStreams) then,
  ) = _CopyWithImpl$Query$SceneStreamsForPlayer$sceneStreams;

  factory CopyWith$Query$SceneStreamsForPlayer$sceneStreams.stub(TRes res) =
      _CopyWithStubImpl$Query$SceneStreamsForPlayer$sceneStreams;

  TRes call({
    String? url,
    String? mime_type,
    String? label,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$SceneStreamsForPlayer$sceneStreams<TRes>
    implements CopyWith$Query$SceneStreamsForPlayer$sceneStreams<TRes> {
  _CopyWithImpl$Query$SceneStreamsForPlayer$sceneStreams(
    this._instance,
    this._then,
  );

  final Query$SceneStreamsForPlayer$sceneStreams _instance;

  final TRes Function(Query$SceneStreamsForPlayer$sceneStreams) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? url = _undefined,
    Object? mime_type = _undefined,
    Object? label = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$SceneStreamsForPlayer$sceneStreams(
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

class _CopyWithStubImpl$Query$SceneStreamsForPlayer$sceneStreams<TRes>
    implements CopyWith$Query$SceneStreamsForPlayer$sceneStreams<TRes> {
  _CopyWithStubImpl$Query$SceneStreamsForPlayer$sceneStreams(this._res);

  TRes _res;

  call({String? url, String? mime_type, String? label, String? $__typename}) =>
      _res;
}

class Query$SceneStreamsForPlayer$findScene {
  Query$SceneStreamsForPlayer$findScene({
    required this.sceneStreams,
    this.$__typename = 'Scene',
  });

  factory Query$SceneStreamsForPlayer$findScene.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$sceneStreams = json['sceneStreams'];
    final l$$__typename = json['__typename'];
    return Query$SceneStreamsForPlayer$findScene(
      sceneStreams: (l$sceneStreams as List<dynamic>)
          .map(
            (e) => Query$SceneStreamsForPlayer$findScene$sceneStreams.fromJson(
              (e as Map<String, dynamic>),
            ),
          )
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Query$SceneStreamsForPlayer$findScene$sceneStreams> sceneStreams;

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
    if (other is! Query$SceneStreamsForPlayer$findScene ||
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

extension UtilityExtension$Query$SceneStreamsForPlayer$findScene
    on Query$SceneStreamsForPlayer$findScene {
  CopyWith$Query$SceneStreamsForPlayer$findScene<
    Query$SceneStreamsForPlayer$findScene
  >
  get copyWith =>
      CopyWith$Query$SceneStreamsForPlayer$findScene(this, (i) => i);
}

abstract class CopyWith$Query$SceneStreamsForPlayer$findScene<TRes> {
  factory CopyWith$Query$SceneStreamsForPlayer$findScene(
    Query$SceneStreamsForPlayer$findScene instance,
    TRes Function(Query$SceneStreamsForPlayer$findScene) then,
  ) = _CopyWithImpl$Query$SceneStreamsForPlayer$findScene;

  factory CopyWith$Query$SceneStreamsForPlayer$findScene.stub(TRes res) =
      _CopyWithStubImpl$Query$SceneStreamsForPlayer$findScene;

  TRes call({
    List<Query$SceneStreamsForPlayer$findScene$sceneStreams>? sceneStreams,
    String? $__typename,
  });
  TRes sceneStreams(
    Iterable<Query$SceneStreamsForPlayer$findScene$sceneStreams> Function(
      Iterable<
        CopyWith$Query$SceneStreamsForPlayer$findScene$sceneStreams<
          Query$SceneStreamsForPlayer$findScene$sceneStreams
        >
      >,
    )
    _fn,
  );
}

class _CopyWithImpl$Query$SceneStreamsForPlayer$findScene<TRes>
    implements CopyWith$Query$SceneStreamsForPlayer$findScene<TRes> {
  _CopyWithImpl$Query$SceneStreamsForPlayer$findScene(
    this._instance,
    this._then,
  );

  final Query$SceneStreamsForPlayer$findScene _instance;

  final TRes Function(Query$SceneStreamsForPlayer$findScene) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? sceneStreams = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$SceneStreamsForPlayer$findScene(
      sceneStreams: sceneStreams == _undefined || sceneStreams == null
          ? _instance.sceneStreams
          : (sceneStreams
                as List<Query$SceneStreamsForPlayer$findScene$sceneStreams>),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  TRes sceneStreams(
    Iterable<Query$SceneStreamsForPlayer$findScene$sceneStreams> Function(
      Iterable<
        CopyWith$Query$SceneStreamsForPlayer$findScene$sceneStreams<
          Query$SceneStreamsForPlayer$findScene$sceneStreams
        >
      >,
    )
    _fn,
  ) => call(
    sceneStreams: _fn(
      _instance.sceneStreams.map(
        (e) => CopyWith$Query$SceneStreamsForPlayer$findScene$sceneStreams(
          e,
          (i) => i,
        ),
      ),
    ).toList(),
  );
}

class _CopyWithStubImpl$Query$SceneStreamsForPlayer$findScene<TRes>
    implements CopyWith$Query$SceneStreamsForPlayer$findScene<TRes> {
  _CopyWithStubImpl$Query$SceneStreamsForPlayer$findScene(this._res);

  TRes _res;

  call({
    List<Query$SceneStreamsForPlayer$findScene$sceneStreams>? sceneStreams,
    String? $__typename,
  }) => _res;

  sceneStreams(_fn) => _res;
}

class Query$SceneStreamsForPlayer$findScene$sceneStreams {
  Query$SceneStreamsForPlayer$findScene$sceneStreams({
    required this.url,
    this.mime_type,
    this.label,
    this.$__typename = 'SceneStreamEndpoint',
  });

  factory Query$SceneStreamsForPlayer$findScene$sceneStreams.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$url = json['url'];
    final l$mime_type = json['mime_type'];
    final l$label = json['label'];
    final l$$__typename = json['__typename'];
    return Query$SceneStreamsForPlayer$findScene$sceneStreams(
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
    if (other is! Query$SceneStreamsForPlayer$findScene$sceneStreams ||
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

extension UtilityExtension$Query$SceneStreamsForPlayer$findScene$sceneStreams
    on Query$SceneStreamsForPlayer$findScene$sceneStreams {
  CopyWith$Query$SceneStreamsForPlayer$findScene$sceneStreams<
    Query$SceneStreamsForPlayer$findScene$sceneStreams
  >
  get copyWith => CopyWith$Query$SceneStreamsForPlayer$findScene$sceneStreams(
    this,
    (i) => i,
  );
}

abstract class CopyWith$Query$SceneStreamsForPlayer$findScene$sceneStreams<
  TRes
> {
  factory CopyWith$Query$SceneStreamsForPlayer$findScene$sceneStreams(
    Query$SceneStreamsForPlayer$findScene$sceneStreams instance,
    TRes Function(Query$SceneStreamsForPlayer$findScene$sceneStreams) then,
  ) = _CopyWithImpl$Query$SceneStreamsForPlayer$findScene$sceneStreams;

  factory CopyWith$Query$SceneStreamsForPlayer$findScene$sceneStreams.stub(
    TRes res,
  ) = _CopyWithStubImpl$Query$SceneStreamsForPlayer$findScene$sceneStreams;

  TRes call({
    String? url,
    String? mime_type,
    String? label,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$SceneStreamsForPlayer$findScene$sceneStreams<TRes>
    implements
        CopyWith$Query$SceneStreamsForPlayer$findScene$sceneStreams<TRes> {
  _CopyWithImpl$Query$SceneStreamsForPlayer$findScene$sceneStreams(
    this._instance,
    this._then,
  );

  final Query$SceneStreamsForPlayer$findScene$sceneStreams _instance;

  final TRes Function(Query$SceneStreamsForPlayer$findScene$sceneStreams) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? url = _undefined,
    Object? mime_type = _undefined,
    Object? label = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$SceneStreamsForPlayer$findScene$sceneStreams(
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

class _CopyWithStubImpl$Query$SceneStreamsForPlayer$findScene$sceneStreams<TRes>
    implements
        CopyWith$Query$SceneStreamsForPlayer$findScene$sceneStreams<TRes> {
  _CopyWithStubImpl$Query$SceneStreamsForPlayer$findScene$sceneStreams(
    this._res,
  );

  TRes _res;

  call({String? url, String? mime_type, String? label, String? $__typename}) =>
      _res;
}
