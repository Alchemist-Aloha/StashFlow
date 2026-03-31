// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'image_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ImageFilter {

 String? get searchQuery; int? get minRating; bool? get organized; List<String>? get resolutions; List<String>? get orientations;
/// Create a copy of ImageFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImageFilterCopyWith<ImageFilter> get copyWith => _$ImageFilterCopyWithImpl<ImageFilter>(this as ImageFilter, _$identity);

  /// Serializes this ImageFilter to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImageFilter&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.minRating, minRating) || other.minRating == minRating)&&(identical(other.organized, organized) || other.organized == organized)&&const DeepCollectionEquality().equals(other.resolutions, resolutions)&&const DeepCollectionEquality().equals(other.orientations, orientations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,searchQuery,minRating,organized,const DeepCollectionEquality().hash(resolutions),const DeepCollectionEquality().hash(orientations));

@override
String toString() {
  return 'ImageFilter(searchQuery: $searchQuery, minRating: $minRating, organized: $organized, resolutions: $resolutions, orientations: $orientations)';
}


}

/// @nodoc
abstract mixin class $ImageFilterCopyWith<$Res>  {
  factory $ImageFilterCopyWith(ImageFilter value, $Res Function(ImageFilter) _then) = _$ImageFilterCopyWithImpl;
@useResult
$Res call({
 String? searchQuery, int? minRating, bool? organized, List<String>? resolutions, List<String>? orientations
});




}
/// @nodoc
class _$ImageFilterCopyWithImpl<$Res>
    implements $ImageFilterCopyWith<$Res> {
  _$ImageFilterCopyWithImpl(this._self, this._then);

  final ImageFilter _self;
  final $Res Function(ImageFilter) _then;

/// Create a copy of ImageFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? searchQuery = freezed,Object? minRating = freezed,Object? organized = freezed,Object? resolutions = freezed,Object? orientations = freezed,}) {
  return _then(_self.copyWith(
searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,minRating: freezed == minRating ? _self.minRating : minRating // ignore: cast_nullable_to_non_nullable
as int?,organized: freezed == organized ? _self.organized : organized // ignore: cast_nullable_to_non_nullable
as bool?,resolutions: freezed == resolutions ? _self.resolutions : resolutions // ignore: cast_nullable_to_non_nullable
as List<String>?,orientations: freezed == orientations ? _self.orientations : orientations // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ImageFilter].
extension ImageFilterPatterns on ImageFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImageFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImageFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImageFilter value)  $default,){
final _that = this;
switch (_that) {
case _ImageFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImageFilter value)?  $default,){
final _that = this;
switch (_that) {
case _ImageFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? searchQuery,  int? minRating,  bool? organized,  List<String>? resolutions,  List<String>? orientations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImageFilter() when $default != null:
return $default(_that.searchQuery,_that.minRating,_that.organized,_that.resolutions,_that.orientations);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? searchQuery,  int? minRating,  bool? organized,  List<String>? resolutions,  List<String>? orientations)  $default,) {final _that = this;
switch (_that) {
case _ImageFilter():
return $default(_that.searchQuery,_that.minRating,_that.organized,_that.resolutions,_that.orientations);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? searchQuery,  int? minRating,  bool? organized,  List<String>? resolutions,  List<String>? orientations)?  $default,) {final _that = this;
switch (_that) {
case _ImageFilter() when $default != null:
return $default(_that.searchQuery,_that.minRating,_that.organized,_that.resolutions,_that.orientations);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImageFilter implements ImageFilter {
  const _ImageFilter({this.searchQuery, this.minRating, this.organized, final  List<String>? resolutions, final  List<String>? orientations}): _resolutions = resolutions,_orientations = orientations;
  factory _ImageFilter.fromJson(Map<String, dynamic> json) => _$ImageFilterFromJson(json);

@override final  String? searchQuery;
@override final  int? minRating;
@override final  bool? organized;
 final  List<String>? _resolutions;
@override List<String>? get resolutions {
  final value = _resolutions;
  if (value == null) return null;
  if (_resolutions is EqualUnmodifiableListView) return _resolutions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _orientations;
@override List<String>? get orientations {
  final value = _orientations;
  if (value == null) return null;
  if (_orientations is EqualUnmodifiableListView) return _orientations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ImageFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImageFilterCopyWith<_ImageFilter> get copyWith => __$ImageFilterCopyWithImpl<_ImageFilter>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImageFilterToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImageFilter&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.minRating, minRating) || other.minRating == minRating)&&(identical(other.organized, organized) || other.organized == organized)&&const DeepCollectionEquality().equals(other._resolutions, _resolutions)&&const DeepCollectionEquality().equals(other._orientations, _orientations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,searchQuery,minRating,organized,const DeepCollectionEquality().hash(_resolutions),const DeepCollectionEquality().hash(_orientations));

@override
String toString() {
  return 'ImageFilter(searchQuery: $searchQuery, minRating: $minRating, organized: $organized, resolutions: $resolutions, orientations: $orientations)';
}


}

/// @nodoc
abstract mixin class _$ImageFilterCopyWith<$Res> implements $ImageFilterCopyWith<$Res> {
  factory _$ImageFilterCopyWith(_ImageFilter value, $Res Function(_ImageFilter) _then) = __$ImageFilterCopyWithImpl;
@override @useResult
$Res call({
 String? searchQuery, int? minRating, bool? organized, List<String>? resolutions, List<String>? orientations
});




}
/// @nodoc
class __$ImageFilterCopyWithImpl<$Res>
    implements _$ImageFilterCopyWith<$Res> {
  __$ImageFilterCopyWithImpl(this._self, this._then);

  final _ImageFilter _self;
  final $Res Function(_ImageFilter) _then;

/// Create a copy of ImageFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? searchQuery = freezed,Object? minRating = freezed,Object? organized = freezed,Object? resolutions = freezed,Object? orientations = freezed,}) {
  return _then(_ImageFilter(
searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,minRating: freezed == minRating ? _self.minRating : minRating // ignore: cast_nullable_to_non_nullable
as int?,organized: freezed == organized ? _self.organized : organized // ignore: cast_nullable_to_non_nullable
as bool?,resolutions: freezed == resolutions ? _self._resolutions : resolutions // ignore: cast_nullable_to_non_nullable
as List<String>?,orientations: freezed == orientations ? _self._orientations : orientations // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
