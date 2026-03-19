// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scene_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SceneFilter {

 String? get searchQuery; int? get minRating; String? get studioId; List<String>? get performerIds; List<String>? get includeTags; List<String>? get excludeTags; bool? get isWatched; DateTime? get startDate; DateTime? get endDate;
/// Create a copy of SceneFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SceneFilterCopyWith<SceneFilter> get copyWith => _$SceneFilterCopyWithImpl<SceneFilter>(this as SceneFilter, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SceneFilter&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.minRating, minRating) || other.minRating == minRating)&&(identical(other.studioId, studioId) || other.studioId == studioId)&&const DeepCollectionEquality().equals(other.performerIds, performerIds)&&const DeepCollectionEquality().equals(other.includeTags, includeTags)&&const DeepCollectionEquality().equals(other.excludeTags, excludeTags)&&(identical(other.isWatched, isWatched) || other.isWatched == isWatched)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}


@override
int get hashCode => Object.hash(runtimeType,searchQuery,minRating,studioId,const DeepCollectionEquality().hash(performerIds),const DeepCollectionEquality().hash(includeTags),const DeepCollectionEquality().hash(excludeTags),isWatched,startDate,endDate);

@override
String toString() {
  return 'SceneFilter(searchQuery: $searchQuery, minRating: $minRating, studioId: $studioId, performerIds: $performerIds, includeTags: $includeTags, excludeTags: $excludeTags, isWatched: $isWatched, startDate: $startDate, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class $SceneFilterCopyWith<$Res>  {
  factory $SceneFilterCopyWith(SceneFilter value, $Res Function(SceneFilter) _then) = _$SceneFilterCopyWithImpl;
@useResult
$Res call({
 String? searchQuery, int? minRating, String? studioId, List<String>? performerIds, List<String>? includeTags, List<String>? excludeTags, bool? isWatched, DateTime? startDate, DateTime? endDate
});




}
/// @nodoc
class _$SceneFilterCopyWithImpl<$Res>
    implements $SceneFilterCopyWith<$Res> {
  _$SceneFilterCopyWithImpl(this._self, this._then);

  final SceneFilter _self;
  final $Res Function(SceneFilter) _then;

/// Create a copy of SceneFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? searchQuery = freezed,Object? minRating = freezed,Object? studioId = freezed,Object? performerIds = freezed,Object? includeTags = freezed,Object? excludeTags = freezed,Object? isWatched = freezed,Object? startDate = freezed,Object? endDate = freezed,}) {
  return _then(_self.copyWith(
searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,minRating: freezed == minRating ? _self.minRating : minRating // ignore: cast_nullable_to_non_nullable
as int?,studioId: freezed == studioId ? _self.studioId : studioId // ignore: cast_nullable_to_non_nullable
as String?,performerIds: freezed == performerIds ? _self.performerIds : performerIds // ignore: cast_nullable_to_non_nullable
as List<String>?,includeTags: freezed == includeTags ? _self.includeTags : includeTags // ignore: cast_nullable_to_non_nullable
as List<String>?,excludeTags: freezed == excludeTags ? _self.excludeTags : excludeTags // ignore: cast_nullable_to_non_nullable
as List<String>?,isWatched: freezed == isWatched ? _self.isWatched : isWatched // ignore: cast_nullable_to_non_nullable
as bool?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SceneFilter].
extension SceneFilterPatterns on SceneFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SceneFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SceneFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SceneFilter value)  $default,){
final _that = this;
switch (_that) {
case _SceneFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SceneFilter value)?  $default,){
final _that = this;
switch (_that) {
case _SceneFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? searchQuery,  int? minRating,  String? studioId,  List<String>? performerIds,  List<String>? includeTags,  List<String>? excludeTags,  bool? isWatched,  DateTime? startDate,  DateTime? endDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SceneFilter() when $default != null:
return $default(_that.searchQuery,_that.minRating,_that.studioId,_that.performerIds,_that.includeTags,_that.excludeTags,_that.isWatched,_that.startDate,_that.endDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? searchQuery,  int? minRating,  String? studioId,  List<String>? performerIds,  List<String>? includeTags,  List<String>? excludeTags,  bool? isWatched,  DateTime? startDate,  DateTime? endDate)  $default,) {final _that = this;
switch (_that) {
case _SceneFilter():
return $default(_that.searchQuery,_that.minRating,_that.studioId,_that.performerIds,_that.includeTags,_that.excludeTags,_that.isWatched,_that.startDate,_that.endDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? searchQuery,  int? minRating,  String? studioId,  List<String>? performerIds,  List<String>? includeTags,  List<String>? excludeTags,  bool? isWatched,  DateTime? startDate,  DateTime? endDate)?  $default,) {final _that = this;
switch (_that) {
case _SceneFilter() when $default != null:
return $default(_that.searchQuery,_that.minRating,_that.studioId,_that.performerIds,_that.includeTags,_that.excludeTags,_that.isWatched,_that.startDate,_that.endDate);case _:
  return null;

}
}

}

/// @nodoc


class _SceneFilter implements SceneFilter {
  const _SceneFilter({this.searchQuery, this.minRating, this.studioId, final  List<String>? performerIds, final  List<String>? includeTags, final  List<String>? excludeTags, this.isWatched, this.startDate, this.endDate}): _performerIds = performerIds,_includeTags = includeTags,_excludeTags = excludeTags;
  

@override final  String? searchQuery;
@override final  int? minRating;
@override final  String? studioId;
 final  List<String>? _performerIds;
@override List<String>? get performerIds {
  final value = _performerIds;
  if (value == null) return null;
  if (_performerIds is EqualUnmodifiableListView) return _performerIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _includeTags;
@override List<String>? get includeTags {
  final value = _includeTags;
  if (value == null) return null;
  if (_includeTags is EqualUnmodifiableListView) return _includeTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _excludeTags;
@override List<String>? get excludeTags {
  final value = _excludeTags;
  if (value == null) return null;
  if (_excludeTags is EqualUnmodifiableListView) return _excludeTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  bool? isWatched;
@override final  DateTime? startDate;
@override final  DateTime? endDate;

/// Create a copy of SceneFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SceneFilterCopyWith<_SceneFilter> get copyWith => __$SceneFilterCopyWithImpl<_SceneFilter>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SceneFilter&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.minRating, minRating) || other.minRating == minRating)&&(identical(other.studioId, studioId) || other.studioId == studioId)&&const DeepCollectionEquality().equals(other._performerIds, _performerIds)&&const DeepCollectionEquality().equals(other._includeTags, _includeTags)&&const DeepCollectionEquality().equals(other._excludeTags, _excludeTags)&&(identical(other.isWatched, isWatched) || other.isWatched == isWatched)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}


@override
int get hashCode => Object.hash(runtimeType,searchQuery,minRating,studioId,const DeepCollectionEquality().hash(_performerIds),const DeepCollectionEquality().hash(_includeTags),const DeepCollectionEquality().hash(_excludeTags),isWatched,startDate,endDate);

@override
String toString() {
  return 'SceneFilter(searchQuery: $searchQuery, minRating: $minRating, studioId: $studioId, performerIds: $performerIds, includeTags: $includeTags, excludeTags: $excludeTags, isWatched: $isWatched, startDate: $startDate, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class _$SceneFilterCopyWith<$Res> implements $SceneFilterCopyWith<$Res> {
  factory _$SceneFilterCopyWith(_SceneFilter value, $Res Function(_SceneFilter) _then) = __$SceneFilterCopyWithImpl;
@override @useResult
$Res call({
 String? searchQuery, int? minRating, String? studioId, List<String>? performerIds, List<String>? includeTags, List<String>? excludeTags, bool? isWatched, DateTime? startDate, DateTime? endDate
});




}
/// @nodoc
class __$SceneFilterCopyWithImpl<$Res>
    implements _$SceneFilterCopyWith<$Res> {
  __$SceneFilterCopyWithImpl(this._self, this._then);

  final _SceneFilter _self;
  final $Res Function(_SceneFilter) _then;

/// Create a copy of SceneFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? searchQuery = freezed,Object? minRating = freezed,Object? studioId = freezed,Object? performerIds = freezed,Object? includeTags = freezed,Object? excludeTags = freezed,Object? isWatched = freezed,Object? startDate = freezed,Object? endDate = freezed,}) {
  return _then(_SceneFilter(
searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,minRating: freezed == minRating ? _self.minRating : minRating // ignore: cast_nullable_to_non_nullable
as int?,studioId: freezed == studioId ? _self.studioId : studioId // ignore: cast_nullable_to_non_nullable
as String?,performerIds: freezed == performerIds ? _self._performerIds : performerIds // ignore: cast_nullable_to_non_nullable
as List<String>?,includeTags: freezed == includeTags ? _self._includeTags : includeTags // ignore: cast_nullable_to_non_nullable
as List<String>?,excludeTags: freezed == excludeTags ? _self._excludeTags : excludeTags // ignore: cast_nullable_to_non_nullable
as List<String>?,isWatched: freezed == isWatched ? _self.isWatched : isWatched // ignore: cast_nullable_to_non_nullable
as bool?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
