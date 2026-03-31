// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gallery_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GalleryFilter {

 String? get searchQuery; int? get minRating; bool? get organized; int? get minImageCount; int? get maxImageCount;
/// Create a copy of GalleryFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GalleryFilterCopyWith<GalleryFilter> get copyWith => _$GalleryFilterCopyWithImpl<GalleryFilter>(this as GalleryFilter, _$identity);

  /// Serializes this GalleryFilter to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GalleryFilter&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.minRating, minRating) || other.minRating == minRating)&&(identical(other.organized, organized) || other.organized == organized)&&(identical(other.minImageCount, minImageCount) || other.minImageCount == minImageCount)&&(identical(other.maxImageCount, maxImageCount) || other.maxImageCount == maxImageCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,searchQuery,minRating,organized,minImageCount,maxImageCount);

@override
String toString() {
  return 'GalleryFilter(searchQuery: $searchQuery, minRating: $minRating, organized: $organized, minImageCount: $minImageCount, maxImageCount: $maxImageCount)';
}


}

/// @nodoc
abstract mixin class $GalleryFilterCopyWith<$Res>  {
  factory $GalleryFilterCopyWith(GalleryFilter value, $Res Function(GalleryFilter) _then) = _$GalleryFilterCopyWithImpl;
@useResult
$Res call({
 String? searchQuery, int? minRating, bool? organized, int? minImageCount, int? maxImageCount
});




}
/// @nodoc
class _$GalleryFilterCopyWithImpl<$Res>
    implements $GalleryFilterCopyWith<$Res> {
  _$GalleryFilterCopyWithImpl(this._self, this._then);

  final GalleryFilter _self;
  final $Res Function(GalleryFilter) _then;

/// Create a copy of GalleryFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? searchQuery = freezed,Object? minRating = freezed,Object? organized = freezed,Object? minImageCount = freezed,Object? maxImageCount = freezed,}) {
  return _then(_self.copyWith(
searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,minRating: freezed == minRating ? _self.minRating : minRating // ignore: cast_nullable_to_non_nullable
as int?,organized: freezed == organized ? _self.organized : organized // ignore: cast_nullable_to_non_nullable
as bool?,minImageCount: freezed == minImageCount ? _self.minImageCount : minImageCount // ignore: cast_nullable_to_non_nullable
as int?,maxImageCount: freezed == maxImageCount ? _self.maxImageCount : maxImageCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [GalleryFilter].
extension GalleryFilterPatterns on GalleryFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GalleryFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GalleryFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GalleryFilter value)  $default,){
final _that = this;
switch (_that) {
case _GalleryFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GalleryFilter value)?  $default,){
final _that = this;
switch (_that) {
case _GalleryFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? searchQuery,  int? minRating,  bool? organized,  int? minImageCount,  int? maxImageCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GalleryFilter() when $default != null:
return $default(_that.searchQuery,_that.minRating,_that.organized,_that.minImageCount,_that.maxImageCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? searchQuery,  int? minRating,  bool? organized,  int? minImageCount,  int? maxImageCount)  $default,) {final _that = this;
switch (_that) {
case _GalleryFilter():
return $default(_that.searchQuery,_that.minRating,_that.organized,_that.minImageCount,_that.maxImageCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? searchQuery,  int? minRating,  bool? organized,  int? minImageCount,  int? maxImageCount)?  $default,) {final _that = this;
switch (_that) {
case _GalleryFilter() when $default != null:
return $default(_that.searchQuery,_that.minRating,_that.organized,_that.minImageCount,_that.maxImageCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GalleryFilter implements GalleryFilter {
  const _GalleryFilter({this.searchQuery, this.minRating, this.organized, this.minImageCount, this.maxImageCount});
  factory _GalleryFilter.fromJson(Map<String, dynamic> json) => _$GalleryFilterFromJson(json);

@override final  String? searchQuery;
@override final  int? minRating;
@override final  bool? organized;
@override final  int? minImageCount;
@override final  int? maxImageCount;

/// Create a copy of GalleryFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GalleryFilterCopyWith<_GalleryFilter> get copyWith => __$GalleryFilterCopyWithImpl<_GalleryFilter>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GalleryFilterToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GalleryFilter&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.minRating, minRating) || other.minRating == minRating)&&(identical(other.organized, organized) || other.organized == organized)&&(identical(other.minImageCount, minImageCount) || other.minImageCount == minImageCount)&&(identical(other.maxImageCount, maxImageCount) || other.maxImageCount == maxImageCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,searchQuery,minRating,organized,minImageCount,maxImageCount);

@override
String toString() {
  return 'GalleryFilter(searchQuery: $searchQuery, minRating: $minRating, organized: $organized, minImageCount: $minImageCount, maxImageCount: $maxImageCount)';
}


}

/// @nodoc
abstract mixin class _$GalleryFilterCopyWith<$Res> implements $GalleryFilterCopyWith<$Res> {
  factory _$GalleryFilterCopyWith(_GalleryFilter value, $Res Function(_GalleryFilter) _then) = __$GalleryFilterCopyWithImpl;
@override @useResult
$Res call({
 String? searchQuery, int? minRating, bool? organized, int? minImageCount, int? maxImageCount
});




}
/// @nodoc
class __$GalleryFilterCopyWithImpl<$Res>
    implements _$GalleryFilterCopyWith<$Res> {
  __$GalleryFilterCopyWithImpl(this._self, this._then);

  final _GalleryFilter _self;
  final $Res Function(_GalleryFilter) _then;

/// Create a copy of GalleryFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? searchQuery = freezed,Object? minRating = freezed,Object? organized = freezed,Object? minImageCount = freezed,Object? maxImageCount = freezed,}) {
  return _then(_GalleryFilter(
searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,minRating: freezed == minRating ? _self.minRating : minRating // ignore: cast_nullable_to_non_nullable
as int?,organized: freezed == organized ? _self.organized : organized // ignore: cast_nullable_to_non_nullable
as bool?,minImageCount: freezed == minImageCount ? _self.minImageCount : minImageCount // ignore: cast_nullable_to_non_nullable
as int?,maxImageCount: freezed == maxImageCount ? _self.maxImageCount : maxImageCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
