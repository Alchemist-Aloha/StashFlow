// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sprite_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SpriteInfo {

 String get url; double get start; double get end; double get x; double get y; double get w; double get h;
/// Create a copy of SpriteInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpriteInfoCopyWith<SpriteInfo> get copyWith => _$SpriteInfoCopyWithImpl<SpriteInfo>(this as SpriteInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpriteInfo&&(identical(other.url, url) || other.url == url)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.w, w) || other.w == w)&&(identical(other.h, h) || other.h == h));
}


@override
int get hashCode => Object.hash(runtimeType,url,start,end,x,y,w,h);

@override
String toString() {
  return 'SpriteInfo(url: $url, start: $start, end: $end, x: $x, y: $y, w: $w, h: $h)';
}


}

/// @nodoc
abstract mixin class $SpriteInfoCopyWith<$Res>  {
  factory $SpriteInfoCopyWith(SpriteInfo value, $Res Function(SpriteInfo) _then) = _$SpriteInfoCopyWithImpl;
@useResult
$Res call({
 String url, double start, double end, double x, double y, double w, double h
});




}
/// @nodoc
class _$SpriteInfoCopyWithImpl<$Res>
    implements $SpriteInfoCopyWith<$Res> {
  _$SpriteInfoCopyWithImpl(this._self, this._then);

  final SpriteInfo _self;
  final $Res Function(SpriteInfo) _then;

/// Create a copy of SpriteInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? start = null,Object? end = null,Object? x = null,Object? y = null,Object? w = null,Object? h = null,}) {
  return _then(_self.copyWith(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as double,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as double,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,w: null == w ? _self.w : w // ignore: cast_nullable_to_non_nullable
as double,h: null == h ? _self.h : h // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [SpriteInfo].
extension SpriteInfoPatterns on SpriteInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpriteInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpriteInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpriteInfo value)  $default,){
final _that = this;
switch (_that) {
case _SpriteInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpriteInfo value)?  $default,){
final _that = this;
switch (_that) {
case _SpriteInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  double start,  double end,  double x,  double y,  double w,  double h)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpriteInfo() when $default != null:
return $default(_that.url,_that.start,_that.end,_that.x,_that.y,_that.w,_that.h);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  double start,  double end,  double x,  double y,  double w,  double h)  $default,) {final _that = this;
switch (_that) {
case _SpriteInfo():
return $default(_that.url,_that.start,_that.end,_that.x,_that.y,_that.w,_that.h);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  double start,  double end,  double x,  double y,  double w,  double h)?  $default,) {final _that = this;
switch (_that) {
case _SpriteInfo() when $default != null:
return $default(_that.url,_that.start,_that.end,_that.x,_that.y,_that.w,_that.h);case _:
  return null;

}
}

}

/// @nodoc


class _SpriteInfo implements SpriteInfo {
  const _SpriteInfo({required this.url, required this.start, required this.end, required this.x, required this.y, required this.w, required this.h});
  

@override final  String url;
@override final  double start;
@override final  double end;
@override final  double x;
@override final  double y;
@override final  double w;
@override final  double h;

/// Create a copy of SpriteInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpriteInfoCopyWith<_SpriteInfo> get copyWith => __$SpriteInfoCopyWithImpl<_SpriteInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpriteInfo&&(identical(other.url, url) || other.url == url)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.w, w) || other.w == w)&&(identical(other.h, h) || other.h == h));
}


@override
int get hashCode => Object.hash(runtimeType,url,start,end,x,y,w,h);

@override
String toString() {
  return 'SpriteInfo(url: $url, start: $start, end: $end, x: $x, y: $y, w: $w, h: $h)';
}


}

/// @nodoc
abstract mixin class _$SpriteInfoCopyWith<$Res> implements $SpriteInfoCopyWith<$Res> {
  factory _$SpriteInfoCopyWith(_SpriteInfo value, $Res Function(_SpriteInfo) _then) = __$SpriteInfoCopyWithImpl;
@override @useResult
$Res call({
 String url, double start, double end, double x, double y, double w, double h
});




}
/// @nodoc
class __$SpriteInfoCopyWithImpl<$Res>
    implements _$SpriteInfoCopyWith<$Res> {
  __$SpriteInfoCopyWithImpl(this._self, this._then);

  final _SpriteInfo _self;
  final $Res Function(_SpriteInfo) _then;

/// Create a copy of SpriteInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? start = null,Object? end = null,Object? x = null,Object? y = null,Object? w = null,Object? h = null,}) {
  return _then(_SpriteInfo(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as double,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as double,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,w: null == w ? _self.w : w // ignore: cast_nullable_to_non_nullable
as double,h: null == h ? _self.h : h // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
