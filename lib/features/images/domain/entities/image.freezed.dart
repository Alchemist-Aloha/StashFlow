// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'image.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Image {

 String get id; String? get title;@JsonKey(name: 'rating100') int? get rating100; String? get date; List<String> get urls; List<ImageFile> get files; ImagePaths get paths;
/// Create a copy of Image
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImageCopyWith<Image> get copyWith => _$ImageCopyWithImpl<Image>(this as Image, _$identity);

  /// Serializes this Image to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Image&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.rating100, rating100) || other.rating100 == rating100)&&(identical(other.date, date) || other.date == date)&&const DeepCollectionEquality().equals(other.urls, urls)&&const DeepCollectionEquality().equals(other.files, files)&&(identical(other.paths, paths) || other.paths == paths));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,rating100,date,const DeepCollectionEquality().hash(urls),const DeepCollectionEquality().hash(files),paths);

@override
String toString() {
  return 'Image(id: $id, title: $title, rating100: $rating100, date: $date, urls: $urls, files: $files, paths: $paths)';
}


}

/// @nodoc
abstract mixin class $ImageCopyWith<$Res>  {
  factory $ImageCopyWith(Image value, $Res Function(Image) _then) = _$ImageCopyWithImpl;
@useResult
$Res call({
 String id, String? title,@JsonKey(name: 'rating100') int? rating100, String? date, List<String> urls, List<ImageFile> files, ImagePaths paths
});


$ImagePathsCopyWith<$Res> get paths;

}
/// @nodoc
class _$ImageCopyWithImpl<$Res>
    implements $ImageCopyWith<$Res> {
  _$ImageCopyWithImpl(this._self, this._then);

  final Image _self;
  final $Res Function(Image) _then;

/// Create a copy of Image
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = freezed,Object? rating100 = freezed,Object? date = freezed,Object? urls = null,Object? files = null,Object? paths = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,rating100: freezed == rating100 ? _self.rating100 : rating100 // ignore: cast_nullable_to_non_nullable
as int?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String?,urls: null == urls ? _self.urls : urls // ignore: cast_nullable_to_non_nullable
as List<String>,files: null == files ? _self.files : files // ignore: cast_nullable_to_non_nullable
as List<ImageFile>,paths: null == paths ? _self.paths : paths // ignore: cast_nullable_to_non_nullable
as ImagePaths,
  ));
}
/// Create a copy of Image
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImagePathsCopyWith<$Res> get paths {
  
  return $ImagePathsCopyWith<$Res>(_self.paths, (value) {
    return _then(_self.copyWith(paths: value));
  });
}
}


/// Adds pattern-matching-related methods to [Image].
extension ImagePatterns on Image {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Image value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Image() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Image value)  $default,){
final _that = this;
switch (_that) {
case _Image():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Image value)?  $default,){
final _that = this;
switch (_that) {
case _Image() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? title, @JsonKey(name: 'rating100')  int? rating100,  String? date,  List<String> urls,  List<ImageFile> files,  ImagePaths paths)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Image() when $default != null:
return $default(_that.id,_that.title,_that.rating100,_that.date,_that.urls,_that.files,_that.paths);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? title, @JsonKey(name: 'rating100')  int? rating100,  String? date,  List<String> urls,  List<ImageFile> files,  ImagePaths paths)  $default,) {final _that = this;
switch (_that) {
case _Image():
return $default(_that.id,_that.title,_that.rating100,_that.date,_that.urls,_that.files,_that.paths);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? title, @JsonKey(name: 'rating100')  int? rating100,  String? date,  List<String> urls,  List<ImageFile> files,  ImagePaths paths)?  $default,) {final _that = this;
switch (_that) {
case _Image() when $default != null:
return $default(_that.id,_that.title,_that.rating100,_that.date,_that.urls,_that.files,_that.paths);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Image implements Image {
  const _Image({required this.id, this.title, @JsonKey(name: 'rating100') this.rating100, this.date, final  List<String> urls = const [], required final  List<ImageFile> files, required this.paths}): _urls = urls,_files = files;
  factory _Image.fromJson(Map<String, dynamic> json) => _$ImageFromJson(json);

@override final  String id;
@override final  String? title;
@override@JsonKey(name: 'rating100') final  int? rating100;
@override final  String? date;
 final  List<String> _urls;
@override@JsonKey() List<String> get urls {
  if (_urls is EqualUnmodifiableListView) return _urls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_urls);
}

 final  List<ImageFile> _files;
@override List<ImageFile> get files {
  if (_files is EqualUnmodifiableListView) return _files;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_files);
}

@override final  ImagePaths paths;

/// Create a copy of Image
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImageCopyWith<_Image> get copyWith => __$ImageCopyWithImpl<_Image>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Image&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.rating100, rating100) || other.rating100 == rating100)&&(identical(other.date, date) || other.date == date)&&const DeepCollectionEquality().equals(other._urls, _urls)&&const DeepCollectionEquality().equals(other._files, _files)&&(identical(other.paths, paths) || other.paths == paths));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,rating100,date,const DeepCollectionEquality().hash(_urls),const DeepCollectionEquality().hash(_files),paths);

@override
String toString() {
  return 'Image(id: $id, title: $title, rating100: $rating100, date: $date, urls: $urls, files: $files, paths: $paths)';
}


}

/// @nodoc
abstract mixin class _$ImageCopyWith<$Res> implements $ImageCopyWith<$Res> {
  factory _$ImageCopyWith(_Image value, $Res Function(_Image) _then) = __$ImageCopyWithImpl;
@override @useResult
$Res call({
 String id, String? title,@JsonKey(name: 'rating100') int? rating100, String? date, List<String> urls, List<ImageFile> files, ImagePaths paths
});


@override $ImagePathsCopyWith<$Res> get paths;

}
/// @nodoc
class __$ImageCopyWithImpl<$Res>
    implements _$ImageCopyWith<$Res> {
  __$ImageCopyWithImpl(this._self, this._then);

  final _Image _self;
  final $Res Function(_Image) _then;

/// Create a copy of Image
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = freezed,Object? rating100 = freezed,Object? date = freezed,Object? urls = null,Object? files = null,Object? paths = null,}) {
  return _then(_Image(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,rating100: freezed == rating100 ? _self.rating100 : rating100 // ignore: cast_nullable_to_non_nullable
as int?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String?,urls: null == urls ? _self._urls : urls // ignore: cast_nullable_to_non_nullable
as List<String>,files: null == files ? _self._files : files // ignore: cast_nullable_to_non_nullable
as List<ImageFile>,paths: null == paths ? _self.paths : paths // ignore: cast_nullable_to_non_nullable
as ImagePaths,
  ));
}

/// Create a copy of Image
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImagePathsCopyWith<$Res> get paths {
  
  return $ImagePathsCopyWith<$Res>(_self.paths, (value) {
    return _then(_self.copyWith(paths: value));
  });
}
}


/// @nodoc
mixin _$ImageFile {

 int get width; int get height;
/// Create a copy of ImageFile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImageFileCopyWith<ImageFile> get copyWith => _$ImageFileCopyWithImpl<ImageFile>(this as ImageFile, _$identity);

  /// Serializes this ImageFile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImageFile&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,width,height);

@override
String toString() {
  return 'ImageFile(width: $width, height: $height)';
}


}

/// @nodoc
abstract mixin class $ImageFileCopyWith<$Res>  {
  factory $ImageFileCopyWith(ImageFile value, $Res Function(ImageFile) _then) = _$ImageFileCopyWithImpl;
@useResult
$Res call({
 int width, int height
});




}
/// @nodoc
class _$ImageFileCopyWithImpl<$Res>
    implements $ImageFileCopyWith<$Res> {
  _$ImageFileCopyWithImpl(this._self, this._then);

  final ImageFile _self;
  final $Res Function(ImageFile) _then;

/// Create a copy of ImageFile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? width = null,Object? height = null,}) {
  return _then(_self.copyWith(
width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ImageFile].
extension ImageFilePatterns on ImageFile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImageFile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImageFile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImageFile value)  $default,){
final _that = this;
switch (_that) {
case _ImageFile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImageFile value)?  $default,){
final _that = this;
switch (_that) {
case _ImageFile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int width,  int height)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImageFile() when $default != null:
return $default(_that.width,_that.height);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int width,  int height)  $default,) {final _that = this;
switch (_that) {
case _ImageFile():
return $default(_that.width,_that.height);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int width,  int height)?  $default,) {final _that = this;
switch (_that) {
case _ImageFile() when $default != null:
return $default(_that.width,_that.height);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImageFile implements ImageFile {
  const _ImageFile({required this.width, required this.height});
  factory _ImageFile.fromJson(Map<String, dynamic> json) => _$ImageFileFromJson(json);

@override final  int width;
@override final  int height;

/// Create a copy of ImageFile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImageFileCopyWith<_ImageFile> get copyWith => __$ImageFileCopyWithImpl<_ImageFile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImageFileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImageFile&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,width,height);

@override
String toString() {
  return 'ImageFile(width: $width, height: $height)';
}


}

/// @nodoc
abstract mixin class _$ImageFileCopyWith<$Res> implements $ImageFileCopyWith<$Res> {
  factory _$ImageFileCopyWith(_ImageFile value, $Res Function(_ImageFile) _then) = __$ImageFileCopyWithImpl;
@override @useResult
$Res call({
 int width, int height
});




}
/// @nodoc
class __$ImageFileCopyWithImpl<$Res>
    implements _$ImageFileCopyWith<$Res> {
  __$ImageFileCopyWithImpl(this._self, this._then);

  final _ImageFile _self;
  final $Res Function(_ImageFile) _then;

/// Create a copy of ImageFile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? width = null,Object? height = null,}) {
  return _then(_ImageFile(
width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ImagePaths {

 String? get thumbnail; String? get preview; String? get image;
/// Create a copy of ImagePaths
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImagePathsCopyWith<ImagePaths> get copyWith => _$ImagePathsCopyWithImpl<ImagePaths>(this as ImagePaths, _$identity);

  /// Serializes this ImagePaths to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImagePaths&&(identical(other.thumbnail, thumbnail) || other.thumbnail == thumbnail)&&(identical(other.preview, preview) || other.preview == preview)&&(identical(other.image, image) || other.image == image));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,thumbnail,preview,image);

@override
String toString() {
  return 'ImagePaths(thumbnail: $thumbnail, preview: $preview, image: $image)';
}


}

/// @nodoc
abstract mixin class $ImagePathsCopyWith<$Res>  {
  factory $ImagePathsCopyWith(ImagePaths value, $Res Function(ImagePaths) _then) = _$ImagePathsCopyWithImpl;
@useResult
$Res call({
 String? thumbnail, String? preview, String? image
});




}
/// @nodoc
class _$ImagePathsCopyWithImpl<$Res>
    implements $ImagePathsCopyWith<$Res> {
  _$ImagePathsCopyWithImpl(this._self, this._then);

  final ImagePaths _self;
  final $Res Function(ImagePaths) _then;

/// Create a copy of ImagePaths
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? thumbnail = freezed,Object? preview = freezed,Object? image = freezed,}) {
  return _then(_self.copyWith(
thumbnail: freezed == thumbnail ? _self.thumbnail : thumbnail // ignore: cast_nullable_to_non_nullable
as String?,preview: freezed == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as String?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ImagePaths].
extension ImagePathsPatterns on ImagePaths {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImagePaths value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImagePaths() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImagePaths value)  $default,){
final _that = this;
switch (_that) {
case _ImagePaths():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImagePaths value)?  $default,){
final _that = this;
switch (_that) {
case _ImagePaths() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? thumbnail,  String? preview,  String? image)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImagePaths() when $default != null:
return $default(_that.thumbnail,_that.preview,_that.image);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? thumbnail,  String? preview,  String? image)  $default,) {final _that = this;
switch (_that) {
case _ImagePaths():
return $default(_that.thumbnail,_that.preview,_that.image);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? thumbnail,  String? preview,  String? image)?  $default,) {final _that = this;
switch (_that) {
case _ImagePaths() when $default != null:
return $default(_that.thumbnail,_that.preview,_that.image);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImagePaths implements ImagePaths {
  const _ImagePaths({this.thumbnail, this.preview, this.image});
  factory _ImagePaths.fromJson(Map<String, dynamic> json) => _$ImagePathsFromJson(json);

@override final  String? thumbnail;
@override final  String? preview;
@override final  String? image;

/// Create a copy of ImagePaths
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImagePathsCopyWith<_ImagePaths> get copyWith => __$ImagePathsCopyWithImpl<_ImagePaths>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImagePathsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImagePaths&&(identical(other.thumbnail, thumbnail) || other.thumbnail == thumbnail)&&(identical(other.preview, preview) || other.preview == preview)&&(identical(other.image, image) || other.image == image));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,thumbnail,preview,image);

@override
String toString() {
  return 'ImagePaths(thumbnail: $thumbnail, preview: $preview, image: $image)';
}


}

/// @nodoc
abstract mixin class _$ImagePathsCopyWith<$Res> implements $ImagePathsCopyWith<$Res> {
  factory _$ImagePathsCopyWith(_ImagePaths value, $Res Function(_ImagePaths) _then) = __$ImagePathsCopyWithImpl;
@override @useResult
$Res call({
 String? thumbnail, String? preview, String? image
});




}
/// @nodoc
class __$ImagePathsCopyWithImpl<$Res>
    implements _$ImagePathsCopyWith<$Res> {
  __$ImagePathsCopyWithImpl(this._self, this._then);

  final _ImagePaths _self;
  final $Res Function(_ImagePaths) _then;

/// Create a copy of ImagePaths
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? thumbnail = freezed,Object? preview = freezed,Object? image = freezed,}) {
  return _then(_ImagePaths(
thumbnail: freezed == thumbnail ? _self.thumbnail : thumbnail // ignore: cast_nullable_to_non_nullable
as String?,preview: freezed == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as String?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
