// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scene.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Scene {

 String get id; String get title; String? get details; String? get path; DateTime get date; int? get rating100;@JsonKey(name: 'o_counter') int get oCounter; bool get organized; bool get interactive;@JsonKey(name: 'resume_time') double? get resumeTime;@JsonKey(name: 'play_count') int get playCount; List<SceneFile> get files; ScenePaths get paths; List<VideoCaption> get captions;@JsonKey(name: 'urls') List<String> get urls;@JsonKey(name: 'studio_id') String? get studioId;@JsonKey(name: 'studio_name') String? get studioName;@JsonKey(name: 'studio_image_path') String? get studioImagePath;@JsonKey(name: 'performer_ids') List<String> get performerIds;@JsonKey(name: 'performer_names') List<String> get performerNames;@JsonKey(name: 'performer_image_paths') List<String?> get performerImagePaths;@JsonKey(name: 'tag_ids') List<String> get tagIds;@JsonKey(name: 'tag_names') List<String> get tagNames;
/// Create a copy of Scene
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SceneCopyWith<Scene> get copyWith => _$SceneCopyWithImpl<Scene>(this as Scene, _$identity);

  /// Serializes this Scene to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Scene&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.details, details) || other.details == details)&&(identical(other.path, path) || other.path == path)&&(identical(other.date, date) || other.date == date)&&(identical(other.rating100, rating100) || other.rating100 == rating100)&&(identical(other.oCounter, oCounter) || other.oCounter == oCounter)&&(identical(other.organized, organized) || other.organized == organized)&&(identical(other.interactive, interactive) || other.interactive == interactive)&&(identical(other.resumeTime, resumeTime) || other.resumeTime == resumeTime)&&(identical(other.playCount, playCount) || other.playCount == playCount)&&const DeepCollectionEquality().equals(other.files, files)&&(identical(other.paths, paths) || other.paths == paths)&&const DeepCollectionEquality().equals(other.captions, captions)&&const DeepCollectionEquality().equals(other.urls, urls)&&(identical(other.studioId, studioId) || other.studioId == studioId)&&(identical(other.studioName, studioName) || other.studioName == studioName)&&(identical(other.studioImagePath, studioImagePath) || other.studioImagePath == studioImagePath)&&const DeepCollectionEquality().equals(other.performerIds, performerIds)&&const DeepCollectionEquality().equals(other.performerNames, performerNames)&&const DeepCollectionEquality().equals(other.performerImagePaths, performerImagePaths)&&const DeepCollectionEquality().equals(other.tagIds, tagIds)&&const DeepCollectionEquality().equals(other.tagNames, tagNames));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,details,path,date,rating100,oCounter,organized,interactive,resumeTime,playCount,const DeepCollectionEquality().hash(files),paths,const DeepCollectionEquality().hash(captions),const DeepCollectionEquality().hash(urls),studioId,studioName,studioImagePath,const DeepCollectionEquality().hash(performerIds),const DeepCollectionEquality().hash(performerNames),const DeepCollectionEquality().hash(performerImagePaths),const DeepCollectionEquality().hash(tagIds),const DeepCollectionEquality().hash(tagNames)]);

@override
String toString() {
  return 'Scene(id: $id, title: $title, details: $details, path: $path, date: $date, rating100: $rating100, oCounter: $oCounter, organized: $organized, interactive: $interactive, resumeTime: $resumeTime, playCount: $playCount, files: $files, paths: $paths, captions: $captions, urls: $urls, studioId: $studioId, studioName: $studioName, studioImagePath: $studioImagePath, performerIds: $performerIds, performerNames: $performerNames, performerImagePaths: $performerImagePaths, tagIds: $tagIds, tagNames: $tagNames)';
}


}

/// @nodoc
abstract mixin class $SceneCopyWith<$Res>  {
  factory $SceneCopyWith(Scene value, $Res Function(Scene) _then) = _$SceneCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? details, String? path, DateTime date, int? rating100,@JsonKey(name: 'o_counter') int oCounter, bool organized, bool interactive,@JsonKey(name: 'resume_time') double? resumeTime,@JsonKey(name: 'play_count') int playCount, List<SceneFile> files, ScenePaths paths, List<VideoCaption> captions,@JsonKey(name: 'urls') List<String> urls,@JsonKey(name: 'studio_id') String? studioId,@JsonKey(name: 'studio_name') String? studioName,@JsonKey(name: 'studio_image_path') String? studioImagePath,@JsonKey(name: 'performer_ids') List<String> performerIds,@JsonKey(name: 'performer_names') List<String> performerNames,@JsonKey(name: 'performer_image_paths') List<String?> performerImagePaths,@JsonKey(name: 'tag_ids') List<String> tagIds,@JsonKey(name: 'tag_names') List<String> tagNames
});


$ScenePathsCopyWith<$Res> get paths;

}
/// @nodoc
class _$SceneCopyWithImpl<$Res>
    implements $SceneCopyWith<$Res> {
  _$SceneCopyWithImpl(this._self, this._then);

  final Scene _self;
  final $Res Function(Scene) _then;

/// Create a copy of Scene
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? details = freezed,Object? path = freezed,Object? date = null,Object? rating100 = freezed,Object? oCounter = null,Object? organized = null,Object? interactive = null,Object? resumeTime = freezed,Object? playCount = null,Object? files = null,Object? paths = null,Object? captions = null,Object? urls = null,Object? studioId = freezed,Object? studioName = freezed,Object? studioImagePath = freezed,Object? performerIds = null,Object? performerNames = null,Object? performerImagePaths = null,Object? tagIds = null,Object? tagNames = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,details: freezed == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String?,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,rating100: freezed == rating100 ? _self.rating100 : rating100 // ignore: cast_nullable_to_non_nullable
as int?,oCounter: null == oCounter ? _self.oCounter : oCounter // ignore: cast_nullable_to_non_nullable
as int,organized: null == organized ? _self.organized : organized // ignore: cast_nullable_to_non_nullable
as bool,interactive: null == interactive ? _self.interactive : interactive // ignore: cast_nullable_to_non_nullable
as bool,resumeTime: freezed == resumeTime ? _self.resumeTime : resumeTime // ignore: cast_nullable_to_non_nullable
as double?,playCount: null == playCount ? _self.playCount : playCount // ignore: cast_nullable_to_non_nullable
as int,files: null == files ? _self.files : files // ignore: cast_nullable_to_non_nullable
as List<SceneFile>,paths: null == paths ? _self.paths : paths // ignore: cast_nullable_to_non_nullable
as ScenePaths,captions: null == captions ? _self.captions : captions // ignore: cast_nullable_to_non_nullable
as List<VideoCaption>,urls: null == urls ? _self.urls : urls // ignore: cast_nullable_to_non_nullable
as List<String>,studioId: freezed == studioId ? _self.studioId : studioId // ignore: cast_nullable_to_non_nullable
as String?,studioName: freezed == studioName ? _self.studioName : studioName // ignore: cast_nullable_to_non_nullable
as String?,studioImagePath: freezed == studioImagePath ? _self.studioImagePath : studioImagePath // ignore: cast_nullable_to_non_nullable
as String?,performerIds: null == performerIds ? _self.performerIds : performerIds // ignore: cast_nullable_to_non_nullable
as List<String>,performerNames: null == performerNames ? _self.performerNames : performerNames // ignore: cast_nullable_to_non_nullable
as List<String>,performerImagePaths: null == performerImagePaths ? _self.performerImagePaths : performerImagePaths // ignore: cast_nullable_to_non_nullable
as List<String?>,tagIds: null == tagIds ? _self.tagIds : tagIds // ignore: cast_nullable_to_non_nullable
as List<String>,tagNames: null == tagNames ? _self.tagNames : tagNames // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}
/// Create a copy of Scene
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScenePathsCopyWith<$Res> get paths {
  
  return $ScenePathsCopyWith<$Res>(_self.paths, (value) {
    return _then(_self.copyWith(paths: value));
  });
}
}


/// Adds pattern-matching-related methods to [Scene].
extension ScenePatterns on Scene {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Scene value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Scene() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Scene value)  $default,){
final _that = this;
switch (_that) {
case _Scene():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Scene value)?  $default,){
final _that = this;
switch (_that) {
case _Scene() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? details,  String? path,  DateTime date,  int? rating100, @JsonKey(name: 'o_counter')  int oCounter,  bool organized,  bool interactive, @JsonKey(name: 'resume_time')  double? resumeTime, @JsonKey(name: 'play_count')  int playCount,  List<SceneFile> files,  ScenePaths paths,  List<VideoCaption> captions, @JsonKey(name: 'urls')  List<String> urls, @JsonKey(name: 'studio_id')  String? studioId, @JsonKey(name: 'studio_name')  String? studioName, @JsonKey(name: 'studio_image_path')  String? studioImagePath, @JsonKey(name: 'performer_ids')  List<String> performerIds, @JsonKey(name: 'performer_names')  List<String> performerNames, @JsonKey(name: 'performer_image_paths')  List<String?> performerImagePaths, @JsonKey(name: 'tag_ids')  List<String> tagIds, @JsonKey(name: 'tag_names')  List<String> tagNames)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Scene() when $default != null:
return $default(_that.id,_that.title,_that.details,_that.path,_that.date,_that.rating100,_that.oCounter,_that.organized,_that.interactive,_that.resumeTime,_that.playCount,_that.files,_that.paths,_that.captions,_that.urls,_that.studioId,_that.studioName,_that.studioImagePath,_that.performerIds,_that.performerNames,_that.performerImagePaths,_that.tagIds,_that.tagNames);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? details,  String? path,  DateTime date,  int? rating100, @JsonKey(name: 'o_counter')  int oCounter,  bool organized,  bool interactive, @JsonKey(name: 'resume_time')  double? resumeTime, @JsonKey(name: 'play_count')  int playCount,  List<SceneFile> files,  ScenePaths paths,  List<VideoCaption> captions, @JsonKey(name: 'urls')  List<String> urls, @JsonKey(name: 'studio_id')  String? studioId, @JsonKey(name: 'studio_name')  String? studioName, @JsonKey(name: 'studio_image_path')  String? studioImagePath, @JsonKey(name: 'performer_ids')  List<String> performerIds, @JsonKey(name: 'performer_names')  List<String> performerNames, @JsonKey(name: 'performer_image_paths')  List<String?> performerImagePaths, @JsonKey(name: 'tag_ids')  List<String> tagIds, @JsonKey(name: 'tag_names')  List<String> tagNames)  $default,) {final _that = this;
switch (_that) {
case _Scene():
return $default(_that.id,_that.title,_that.details,_that.path,_that.date,_that.rating100,_that.oCounter,_that.organized,_that.interactive,_that.resumeTime,_that.playCount,_that.files,_that.paths,_that.captions,_that.urls,_that.studioId,_that.studioName,_that.studioImagePath,_that.performerIds,_that.performerNames,_that.performerImagePaths,_that.tagIds,_that.tagNames);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? details,  String? path,  DateTime date,  int? rating100, @JsonKey(name: 'o_counter')  int oCounter,  bool organized,  bool interactive, @JsonKey(name: 'resume_time')  double? resumeTime, @JsonKey(name: 'play_count')  int playCount,  List<SceneFile> files,  ScenePaths paths,  List<VideoCaption> captions, @JsonKey(name: 'urls')  List<String> urls, @JsonKey(name: 'studio_id')  String? studioId, @JsonKey(name: 'studio_name')  String? studioName, @JsonKey(name: 'studio_image_path')  String? studioImagePath, @JsonKey(name: 'performer_ids')  List<String> performerIds, @JsonKey(name: 'performer_names')  List<String> performerNames, @JsonKey(name: 'performer_image_paths')  List<String?> performerImagePaths, @JsonKey(name: 'tag_ids')  List<String> tagIds, @JsonKey(name: 'tag_names')  List<String> tagNames)?  $default,) {final _that = this;
switch (_that) {
case _Scene() when $default != null:
return $default(_that.id,_that.title,_that.details,_that.path,_that.date,_that.rating100,_that.oCounter,_that.organized,_that.interactive,_that.resumeTime,_that.playCount,_that.files,_that.paths,_that.captions,_that.urls,_that.studioId,_that.studioName,_that.studioImagePath,_that.performerIds,_that.performerNames,_that.performerImagePaths,_that.tagIds,_that.tagNames);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Scene implements Scene {
  const _Scene({required this.id, required this.title, this.details, this.path, required this.date, required this.rating100, @JsonKey(name: 'o_counter') required this.oCounter, required this.organized, required this.interactive, @JsonKey(name: 'resume_time') required this.resumeTime, @JsonKey(name: 'play_count') required this.playCount, required final  List<SceneFile> files, required this.paths, final  List<VideoCaption> captions = const [], @JsonKey(name: 'urls') required final  List<String> urls, @JsonKey(name: 'studio_id') required this.studioId, @JsonKey(name: 'studio_name') required this.studioName, @JsonKey(name: 'studio_image_path') required this.studioImagePath, @JsonKey(name: 'performer_ids') required final  List<String> performerIds, @JsonKey(name: 'performer_names') required final  List<String> performerNames, @JsonKey(name: 'performer_image_paths') required final  List<String?> performerImagePaths, @JsonKey(name: 'tag_ids') required final  List<String> tagIds, @JsonKey(name: 'tag_names') required final  List<String> tagNames}): _files = files,_captions = captions,_urls = urls,_performerIds = performerIds,_performerNames = performerNames,_performerImagePaths = performerImagePaths,_tagIds = tagIds,_tagNames = tagNames;
  factory _Scene.fromJson(Map<String, dynamic> json) => _$SceneFromJson(json);

@override final  String id;
@override final  String title;
@override final  String? details;
@override final  String? path;
@override final  DateTime date;
@override final  int? rating100;
@override@JsonKey(name: 'o_counter') final  int oCounter;
@override final  bool organized;
@override final  bool interactive;
@override@JsonKey(name: 'resume_time') final  double? resumeTime;
@override@JsonKey(name: 'play_count') final  int playCount;
 final  List<SceneFile> _files;
@override List<SceneFile> get files {
  if (_files is EqualUnmodifiableListView) return _files;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_files);
}

@override final  ScenePaths paths;
 final  List<VideoCaption> _captions;
@override@JsonKey() List<VideoCaption> get captions {
  if (_captions is EqualUnmodifiableListView) return _captions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_captions);
}

 final  List<String> _urls;
@override@JsonKey(name: 'urls') List<String> get urls {
  if (_urls is EqualUnmodifiableListView) return _urls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_urls);
}

@override@JsonKey(name: 'studio_id') final  String? studioId;
@override@JsonKey(name: 'studio_name') final  String? studioName;
@override@JsonKey(name: 'studio_image_path') final  String? studioImagePath;
 final  List<String> _performerIds;
@override@JsonKey(name: 'performer_ids') List<String> get performerIds {
  if (_performerIds is EqualUnmodifiableListView) return _performerIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_performerIds);
}

 final  List<String> _performerNames;
@override@JsonKey(name: 'performer_names') List<String> get performerNames {
  if (_performerNames is EqualUnmodifiableListView) return _performerNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_performerNames);
}

 final  List<String?> _performerImagePaths;
@override@JsonKey(name: 'performer_image_paths') List<String?> get performerImagePaths {
  if (_performerImagePaths is EqualUnmodifiableListView) return _performerImagePaths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_performerImagePaths);
}

 final  List<String> _tagIds;
@override@JsonKey(name: 'tag_ids') List<String> get tagIds {
  if (_tagIds is EqualUnmodifiableListView) return _tagIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tagIds);
}

 final  List<String> _tagNames;
@override@JsonKey(name: 'tag_names') List<String> get tagNames {
  if (_tagNames is EqualUnmodifiableListView) return _tagNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tagNames);
}


/// Create a copy of Scene
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SceneCopyWith<_Scene> get copyWith => __$SceneCopyWithImpl<_Scene>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SceneToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Scene&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.details, details) || other.details == details)&&(identical(other.path, path) || other.path == path)&&(identical(other.date, date) || other.date == date)&&(identical(other.rating100, rating100) || other.rating100 == rating100)&&(identical(other.oCounter, oCounter) || other.oCounter == oCounter)&&(identical(other.organized, organized) || other.organized == organized)&&(identical(other.interactive, interactive) || other.interactive == interactive)&&(identical(other.resumeTime, resumeTime) || other.resumeTime == resumeTime)&&(identical(other.playCount, playCount) || other.playCount == playCount)&&const DeepCollectionEquality().equals(other._files, _files)&&(identical(other.paths, paths) || other.paths == paths)&&const DeepCollectionEquality().equals(other._captions, _captions)&&const DeepCollectionEquality().equals(other._urls, _urls)&&(identical(other.studioId, studioId) || other.studioId == studioId)&&(identical(other.studioName, studioName) || other.studioName == studioName)&&(identical(other.studioImagePath, studioImagePath) || other.studioImagePath == studioImagePath)&&const DeepCollectionEquality().equals(other._performerIds, _performerIds)&&const DeepCollectionEquality().equals(other._performerNames, _performerNames)&&const DeepCollectionEquality().equals(other._performerImagePaths, _performerImagePaths)&&const DeepCollectionEquality().equals(other._tagIds, _tagIds)&&const DeepCollectionEquality().equals(other._tagNames, _tagNames));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,details,path,date,rating100,oCounter,organized,interactive,resumeTime,playCount,const DeepCollectionEquality().hash(_files),paths,const DeepCollectionEquality().hash(_captions),const DeepCollectionEquality().hash(_urls),studioId,studioName,studioImagePath,const DeepCollectionEquality().hash(_performerIds),const DeepCollectionEquality().hash(_performerNames),const DeepCollectionEquality().hash(_performerImagePaths),const DeepCollectionEquality().hash(_tagIds),const DeepCollectionEquality().hash(_tagNames)]);

@override
String toString() {
  return 'Scene(id: $id, title: $title, details: $details, path: $path, date: $date, rating100: $rating100, oCounter: $oCounter, organized: $organized, interactive: $interactive, resumeTime: $resumeTime, playCount: $playCount, files: $files, paths: $paths, captions: $captions, urls: $urls, studioId: $studioId, studioName: $studioName, studioImagePath: $studioImagePath, performerIds: $performerIds, performerNames: $performerNames, performerImagePaths: $performerImagePaths, tagIds: $tagIds, tagNames: $tagNames)';
}


}

/// @nodoc
abstract mixin class _$SceneCopyWith<$Res> implements $SceneCopyWith<$Res> {
  factory _$SceneCopyWith(_Scene value, $Res Function(_Scene) _then) = __$SceneCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? details, String? path, DateTime date, int? rating100,@JsonKey(name: 'o_counter') int oCounter, bool organized, bool interactive,@JsonKey(name: 'resume_time') double? resumeTime,@JsonKey(name: 'play_count') int playCount, List<SceneFile> files, ScenePaths paths, List<VideoCaption> captions,@JsonKey(name: 'urls') List<String> urls,@JsonKey(name: 'studio_id') String? studioId,@JsonKey(name: 'studio_name') String? studioName,@JsonKey(name: 'studio_image_path') String? studioImagePath,@JsonKey(name: 'performer_ids') List<String> performerIds,@JsonKey(name: 'performer_names') List<String> performerNames,@JsonKey(name: 'performer_image_paths') List<String?> performerImagePaths,@JsonKey(name: 'tag_ids') List<String> tagIds,@JsonKey(name: 'tag_names') List<String> tagNames
});


@override $ScenePathsCopyWith<$Res> get paths;

}
/// @nodoc
class __$SceneCopyWithImpl<$Res>
    implements _$SceneCopyWith<$Res> {
  __$SceneCopyWithImpl(this._self, this._then);

  final _Scene _self;
  final $Res Function(_Scene) _then;

/// Create a copy of Scene
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? details = freezed,Object? path = freezed,Object? date = null,Object? rating100 = freezed,Object? oCounter = null,Object? organized = null,Object? interactive = null,Object? resumeTime = freezed,Object? playCount = null,Object? files = null,Object? paths = null,Object? captions = null,Object? urls = null,Object? studioId = freezed,Object? studioName = freezed,Object? studioImagePath = freezed,Object? performerIds = null,Object? performerNames = null,Object? performerImagePaths = null,Object? tagIds = null,Object? tagNames = null,}) {
  return _then(_Scene(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,details: freezed == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String?,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,rating100: freezed == rating100 ? _self.rating100 : rating100 // ignore: cast_nullable_to_non_nullable
as int?,oCounter: null == oCounter ? _self.oCounter : oCounter // ignore: cast_nullable_to_non_nullable
as int,organized: null == organized ? _self.organized : organized // ignore: cast_nullable_to_non_nullable
as bool,interactive: null == interactive ? _self.interactive : interactive // ignore: cast_nullable_to_non_nullable
as bool,resumeTime: freezed == resumeTime ? _self.resumeTime : resumeTime // ignore: cast_nullable_to_non_nullable
as double?,playCount: null == playCount ? _self.playCount : playCount // ignore: cast_nullable_to_non_nullable
as int,files: null == files ? _self._files : files // ignore: cast_nullable_to_non_nullable
as List<SceneFile>,paths: null == paths ? _self.paths : paths // ignore: cast_nullable_to_non_nullable
as ScenePaths,captions: null == captions ? _self._captions : captions // ignore: cast_nullable_to_non_nullable
as List<VideoCaption>,urls: null == urls ? _self._urls : urls // ignore: cast_nullable_to_non_nullable
as List<String>,studioId: freezed == studioId ? _self.studioId : studioId // ignore: cast_nullable_to_non_nullable
as String?,studioName: freezed == studioName ? _self.studioName : studioName // ignore: cast_nullable_to_non_nullable
as String?,studioImagePath: freezed == studioImagePath ? _self.studioImagePath : studioImagePath // ignore: cast_nullable_to_non_nullable
as String?,performerIds: null == performerIds ? _self._performerIds : performerIds // ignore: cast_nullable_to_non_nullable
as List<String>,performerNames: null == performerNames ? _self._performerNames : performerNames // ignore: cast_nullable_to_non_nullable
as List<String>,performerImagePaths: null == performerImagePaths ? _self._performerImagePaths : performerImagePaths // ignore: cast_nullable_to_non_nullable
as List<String?>,tagIds: null == tagIds ? _self._tagIds : tagIds // ignore: cast_nullable_to_non_nullable
as List<String>,tagNames: null == tagNames ? _self._tagNames : tagNames // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of Scene
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScenePathsCopyWith<$Res> get paths {
  
  return $ScenePathsCopyWith<$Res>(_self.paths, (value) {
    return _then(_self.copyWith(paths: value));
  });
}
}


/// @nodoc
mixin _$VideoCaption {

@JsonKey(name: 'language_code') String get languageCode;@JsonKey(name: 'caption_type') String get captionType;
/// Create a copy of VideoCaption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoCaptionCopyWith<VideoCaption> get copyWith => _$VideoCaptionCopyWithImpl<VideoCaption>(this as VideoCaption, _$identity);

  /// Serializes this VideoCaption to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoCaption&&(identical(other.languageCode, languageCode) || other.languageCode == languageCode)&&(identical(other.captionType, captionType) || other.captionType == captionType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,languageCode,captionType);

@override
String toString() {
  return 'VideoCaption(languageCode: $languageCode, captionType: $captionType)';
}


}

/// @nodoc
abstract mixin class $VideoCaptionCopyWith<$Res>  {
  factory $VideoCaptionCopyWith(VideoCaption value, $Res Function(VideoCaption) _then) = _$VideoCaptionCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'language_code') String languageCode,@JsonKey(name: 'caption_type') String captionType
});




}
/// @nodoc
class _$VideoCaptionCopyWithImpl<$Res>
    implements $VideoCaptionCopyWith<$Res> {
  _$VideoCaptionCopyWithImpl(this._self, this._then);

  final VideoCaption _self;
  final $Res Function(VideoCaption) _then;

/// Create a copy of VideoCaption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? languageCode = null,Object? captionType = null,}) {
  return _then(_self.copyWith(
languageCode: null == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as String,captionType: null == captionType ? _self.captionType : captionType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VideoCaption].
extension VideoCaptionPatterns on VideoCaption {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VideoCaption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VideoCaption() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VideoCaption value)  $default,){
final _that = this;
switch (_that) {
case _VideoCaption():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VideoCaption value)?  $default,){
final _that = this;
switch (_that) {
case _VideoCaption() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'language_code')  String languageCode, @JsonKey(name: 'caption_type')  String captionType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoCaption() when $default != null:
return $default(_that.languageCode,_that.captionType);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'language_code')  String languageCode, @JsonKey(name: 'caption_type')  String captionType)  $default,) {final _that = this;
switch (_that) {
case _VideoCaption():
return $default(_that.languageCode,_that.captionType);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'language_code')  String languageCode, @JsonKey(name: 'caption_type')  String captionType)?  $default,) {final _that = this;
switch (_that) {
case _VideoCaption() when $default != null:
return $default(_that.languageCode,_that.captionType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VideoCaption implements VideoCaption {
  const _VideoCaption({@JsonKey(name: 'language_code') required this.languageCode, @JsonKey(name: 'caption_type') required this.captionType});
  factory _VideoCaption.fromJson(Map<String, dynamic> json) => _$VideoCaptionFromJson(json);

@override@JsonKey(name: 'language_code') final  String languageCode;
@override@JsonKey(name: 'caption_type') final  String captionType;

/// Create a copy of VideoCaption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoCaptionCopyWith<_VideoCaption> get copyWith => __$VideoCaptionCopyWithImpl<_VideoCaption>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VideoCaptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoCaption&&(identical(other.languageCode, languageCode) || other.languageCode == languageCode)&&(identical(other.captionType, captionType) || other.captionType == captionType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,languageCode,captionType);

@override
String toString() {
  return 'VideoCaption(languageCode: $languageCode, captionType: $captionType)';
}


}

/// @nodoc
abstract mixin class _$VideoCaptionCopyWith<$Res> implements $VideoCaptionCopyWith<$Res> {
  factory _$VideoCaptionCopyWith(_VideoCaption value, $Res Function(_VideoCaption) _then) = __$VideoCaptionCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'language_code') String languageCode,@JsonKey(name: 'caption_type') String captionType
});




}
/// @nodoc
class __$VideoCaptionCopyWithImpl<$Res>
    implements _$VideoCaptionCopyWith<$Res> {
  __$VideoCaptionCopyWithImpl(this._self, this._then);

  final _VideoCaption _self;
  final $Res Function(_VideoCaption) _then;

/// Create a copy of VideoCaption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? languageCode = null,Object? captionType = null,}) {
  return _then(_VideoCaption(
languageCode: null == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as String,captionType: null == captionType ? _self.captionType : captionType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SceneFile {

 String? get format; int? get width; int? get height;@JsonKey(name: 'video_codec') String? get videoCodec;@JsonKey(name: 'audio_codec') String? get audioCodec;@JsonKey(name: 'bit_rate') int? get bitRate; double? get duration;@JsonKey(name: 'frame_rate') double? get frameRate;
/// Create a copy of SceneFile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SceneFileCopyWith<SceneFile> get copyWith => _$SceneFileCopyWithImpl<SceneFile>(this as SceneFile, _$identity);

  /// Serializes this SceneFile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SceneFile&&(identical(other.format, format) || other.format == format)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.videoCodec, videoCodec) || other.videoCodec == videoCodec)&&(identical(other.audioCodec, audioCodec) || other.audioCodec == audioCodec)&&(identical(other.bitRate, bitRate) || other.bitRate == bitRate)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.frameRate, frameRate) || other.frameRate == frameRate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,format,width,height,videoCodec,audioCodec,bitRate,duration,frameRate);

@override
String toString() {
  return 'SceneFile(format: $format, width: $width, height: $height, videoCodec: $videoCodec, audioCodec: $audioCodec, bitRate: $bitRate, duration: $duration, frameRate: $frameRate)';
}


}

/// @nodoc
abstract mixin class $SceneFileCopyWith<$Res>  {
  factory $SceneFileCopyWith(SceneFile value, $Res Function(SceneFile) _then) = _$SceneFileCopyWithImpl;
@useResult
$Res call({
 String? format, int? width, int? height,@JsonKey(name: 'video_codec') String? videoCodec,@JsonKey(name: 'audio_codec') String? audioCodec,@JsonKey(name: 'bit_rate') int? bitRate, double? duration,@JsonKey(name: 'frame_rate') double? frameRate
});




}
/// @nodoc
class _$SceneFileCopyWithImpl<$Res>
    implements $SceneFileCopyWith<$Res> {
  _$SceneFileCopyWithImpl(this._self, this._then);

  final SceneFile _self;
  final $Res Function(SceneFile) _then;

/// Create a copy of SceneFile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? format = freezed,Object? width = freezed,Object? height = freezed,Object? videoCodec = freezed,Object? audioCodec = freezed,Object? bitRate = freezed,Object? duration = freezed,Object? frameRate = freezed,}) {
  return _then(_self.copyWith(
format: freezed == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,videoCodec: freezed == videoCodec ? _self.videoCodec : videoCodec // ignore: cast_nullable_to_non_nullable
as String?,audioCodec: freezed == audioCodec ? _self.audioCodec : audioCodec // ignore: cast_nullable_to_non_nullable
as String?,bitRate: freezed == bitRate ? _self.bitRate : bitRate // ignore: cast_nullable_to_non_nullable
as int?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as double?,frameRate: freezed == frameRate ? _self.frameRate : frameRate // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [SceneFile].
extension SceneFilePatterns on SceneFile {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SceneFile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SceneFile() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SceneFile value)  $default,){
final _that = this;
switch (_that) {
case _SceneFile():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SceneFile value)?  $default,){
final _that = this;
switch (_that) {
case _SceneFile() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? format,  int? width,  int? height, @JsonKey(name: 'video_codec')  String? videoCodec, @JsonKey(name: 'audio_codec')  String? audioCodec, @JsonKey(name: 'bit_rate')  int? bitRate,  double? duration, @JsonKey(name: 'frame_rate')  double? frameRate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SceneFile() when $default != null:
return $default(_that.format,_that.width,_that.height,_that.videoCodec,_that.audioCodec,_that.bitRate,_that.duration,_that.frameRate);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? format,  int? width,  int? height, @JsonKey(name: 'video_codec')  String? videoCodec, @JsonKey(name: 'audio_codec')  String? audioCodec, @JsonKey(name: 'bit_rate')  int? bitRate,  double? duration, @JsonKey(name: 'frame_rate')  double? frameRate)  $default,) {final _that = this;
switch (_that) {
case _SceneFile():
return $default(_that.format,_that.width,_that.height,_that.videoCodec,_that.audioCodec,_that.bitRate,_that.duration,_that.frameRate);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? format,  int? width,  int? height, @JsonKey(name: 'video_codec')  String? videoCodec, @JsonKey(name: 'audio_codec')  String? audioCodec, @JsonKey(name: 'bit_rate')  int? bitRate,  double? duration, @JsonKey(name: 'frame_rate')  double? frameRate)?  $default,) {final _that = this;
switch (_that) {
case _SceneFile() when $default != null:
return $default(_that.format,_that.width,_that.height,_that.videoCodec,_that.audioCodec,_that.bitRate,_that.duration,_that.frameRate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SceneFile implements SceneFile {
  const _SceneFile({required this.format, required this.width, required this.height, @JsonKey(name: 'video_codec') required this.videoCodec, @JsonKey(name: 'audio_codec') required this.audioCodec, @JsonKey(name: 'bit_rate') required this.bitRate, required this.duration, @JsonKey(name: 'frame_rate') required this.frameRate});
  factory _SceneFile.fromJson(Map<String, dynamic> json) => _$SceneFileFromJson(json);

@override final  String? format;
@override final  int? width;
@override final  int? height;
@override@JsonKey(name: 'video_codec') final  String? videoCodec;
@override@JsonKey(name: 'audio_codec') final  String? audioCodec;
@override@JsonKey(name: 'bit_rate') final  int? bitRate;
@override final  double? duration;
@override@JsonKey(name: 'frame_rate') final  double? frameRate;

/// Create a copy of SceneFile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SceneFileCopyWith<_SceneFile> get copyWith => __$SceneFileCopyWithImpl<_SceneFile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SceneFileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SceneFile&&(identical(other.format, format) || other.format == format)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.videoCodec, videoCodec) || other.videoCodec == videoCodec)&&(identical(other.audioCodec, audioCodec) || other.audioCodec == audioCodec)&&(identical(other.bitRate, bitRate) || other.bitRate == bitRate)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.frameRate, frameRate) || other.frameRate == frameRate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,format,width,height,videoCodec,audioCodec,bitRate,duration,frameRate);

@override
String toString() {
  return 'SceneFile(format: $format, width: $width, height: $height, videoCodec: $videoCodec, audioCodec: $audioCodec, bitRate: $bitRate, duration: $duration, frameRate: $frameRate)';
}


}

/// @nodoc
abstract mixin class _$SceneFileCopyWith<$Res> implements $SceneFileCopyWith<$Res> {
  factory _$SceneFileCopyWith(_SceneFile value, $Res Function(_SceneFile) _then) = __$SceneFileCopyWithImpl;
@override @useResult
$Res call({
 String? format, int? width, int? height,@JsonKey(name: 'video_codec') String? videoCodec,@JsonKey(name: 'audio_codec') String? audioCodec,@JsonKey(name: 'bit_rate') int? bitRate, double? duration,@JsonKey(name: 'frame_rate') double? frameRate
});




}
/// @nodoc
class __$SceneFileCopyWithImpl<$Res>
    implements _$SceneFileCopyWith<$Res> {
  __$SceneFileCopyWithImpl(this._self, this._then);

  final _SceneFile _self;
  final $Res Function(_SceneFile) _then;

/// Create a copy of SceneFile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? format = freezed,Object? width = freezed,Object? height = freezed,Object? videoCodec = freezed,Object? audioCodec = freezed,Object? bitRate = freezed,Object? duration = freezed,Object? frameRate = freezed,}) {
  return _then(_SceneFile(
format: freezed == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,videoCodec: freezed == videoCodec ? _self.videoCodec : videoCodec // ignore: cast_nullable_to_non_nullable
as String?,audioCodec: freezed == audioCodec ? _self.audioCodec : audioCodec // ignore: cast_nullable_to_non_nullable
as String?,bitRate: freezed == bitRate ? _self.bitRate : bitRate // ignore: cast_nullable_to_non_nullable
as int?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as double?,frameRate: freezed == frameRate ? _self.frameRate : frameRate // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$ScenePaths {

 String? get screenshot; String? get preview; String? get stream; String? get caption; String? get vtt;
/// Create a copy of ScenePaths
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScenePathsCopyWith<ScenePaths> get copyWith => _$ScenePathsCopyWithImpl<ScenePaths>(this as ScenePaths, _$identity);

  /// Serializes this ScenePaths to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScenePaths&&(identical(other.screenshot, screenshot) || other.screenshot == screenshot)&&(identical(other.preview, preview) || other.preview == preview)&&(identical(other.stream, stream) || other.stream == stream)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.vtt, vtt) || other.vtt == vtt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,screenshot,preview,stream,caption,vtt);

@override
String toString() {
  return 'ScenePaths(screenshot: $screenshot, preview: $preview, stream: $stream, caption: $caption, vtt: $vtt)';
}


}

/// @nodoc
abstract mixin class $ScenePathsCopyWith<$Res>  {
  factory $ScenePathsCopyWith(ScenePaths value, $Res Function(ScenePaths) _then) = _$ScenePathsCopyWithImpl;
@useResult
$Res call({
 String? screenshot, String? preview, String? stream, String? caption, String? vtt
});




}
/// @nodoc
class _$ScenePathsCopyWithImpl<$Res>
    implements $ScenePathsCopyWith<$Res> {
  _$ScenePathsCopyWithImpl(this._self, this._then);

  final ScenePaths _self;
  final $Res Function(ScenePaths) _then;

/// Create a copy of ScenePaths
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? screenshot = freezed,Object? preview = freezed,Object? stream = freezed,Object? caption = freezed,Object? vtt = freezed,}) {
  return _then(_self.copyWith(
screenshot: freezed == screenshot ? _self.screenshot : screenshot // ignore: cast_nullable_to_non_nullable
as String?,preview: freezed == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as String?,stream: freezed == stream ? _self.stream : stream // ignore: cast_nullable_to_non_nullable
as String?,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,vtt: freezed == vtt ? _self.vtt : vtt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ScenePaths].
extension ScenePathsPatterns on ScenePaths {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScenePaths value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScenePaths() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScenePaths value)  $default,){
final _that = this;
switch (_that) {
case _ScenePaths():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScenePaths value)?  $default,){
final _that = this;
switch (_that) {
case _ScenePaths() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? screenshot,  String? preview,  String? stream,  String? caption,  String? vtt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScenePaths() when $default != null:
return $default(_that.screenshot,_that.preview,_that.stream,_that.caption,_that.vtt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? screenshot,  String? preview,  String? stream,  String? caption,  String? vtt)  $default,) {final _that = this;
switch (_that) {
case _ScenePaths():
return $default(_that.screenshot,_that.preview,_that.stream,_that.caption,_that.vtt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? screenshot,  String? preview,  String? stream,  String? caption,  String? vtt)?  $default,) {final _that = this;
switch (_that) {
case _ScenePaths() when $default != null:
return $default(_that.screenshot,_that.preview,_that.stream,_that.caption,_that.vtt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScenePaths implements ScenePaths {
  const _ScenePaths({required this.screenshot, required this.preview, required this.stream, this.caption = null, this.vtt = null});
  factory _ScenePaths.fromJson(Map<String, dynamic> json) => _$ScenePathsFromJson(json);

@override final  String? screenshot;
@override final  String? preview;
@override final  String? stream;
@override@JsonKey() final  String? caption;
@override@JsonKey() final  String? vtt;

/// Create a copy of ScenePaths
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScenePathsCopyWith<_ScenePaths> get copyWith => __$ScenePathsCopyWithImpl<_ScenePaths>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScenePathsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScenePaths&&(identical(other.screenshot, screenshot) || other.screenshot == screenshot)&&(identical(other.preview, preview) || other.preview == preview)&&(identical(other.stream, stream) || other.stream == stream)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.vtt, vtt) || other.vtt == vtt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,screenshot,preview,stream,caption,vtt);

@override
String toString() {
  return 'ScenePaths(screenshot: $screenshot, preview: $preview, stream: $stream, caption: $caption, vtt: $vtt)';
}


}

/// @nodoc
abstract mixin class _$ScenePathsCopyWith<$Res> implements $ScenePathsCopyWith<$Res> {
  factory _$ScenePathsCopyWith(_ScenePaths value, $Res Function(_ScenePaths) _then) = __$ScenePathsCopyWithImpl;
@override @useResult
$Res call({
 String? screenshot, String? preview, String? stream, String? caption, String? vtt
});




}
/// @nodoc
class __$ScenePathsCopyWithImpl<$Res>
    implements _$ScenePathsCopyWith<$Res> {
  __$ScenePathsCopyWithImpl(this._self, this._then);

  final _ScenePaths _self;
  final $Res Function(_ScenePaths) _then;

/// Create a copy of ScenePaths
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? screenshot = freezed,Object? preview = freezed,Object? stream = freezed,Object? caption = freezed,Object? vtt = freezed,}) {
  return _then(_ScenePaths(
screenshot: freezed == screenshot ? _self.screenshot : screenshot // ignore: cast_nullable_to_non_nullable
as String?,preview: freezed == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as String?,stream: freezed == stream ? _self.stream : stream // ignore: cast_nullable_to_non_nullable
as String?,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,vtt: freezed == vtt ? _self.vtt : vtt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
