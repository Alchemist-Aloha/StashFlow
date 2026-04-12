// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateInfo {

 bool get isUpdateAvailable; String get latestVersion; String get currentVersion; String get releaseUrl; String? get releaseNotes;
/// Create a copy of UpdateInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateInfoCopyWith<UpdateInfo> get copyWith => _$UpdateInfoCopyWithImpl<UpdateInfo>(this as UpdateInfo, _$identity);

  /// Serializes this UpdateInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateInfo&&(identical(other.isUpdateAvailable, isUpdateAvailable) || other.isUpdateAvailable == isUpdateAvailable)&&(identical(other.latestVersion, latestVersion) || other.latestVersion == latestVersion)&&(identical(other.currentVersion, currentVersion) || other.currentVersion == currentVersion)&&(identical(other.releaseUrl, releaseUrl) || other.releaseUrl == releaseUrl)&&(identical(other.releaseNotes, releaseNotes) || other.releaseNotes == releaseNotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isUpdateAvailable,latestVersion,currentVersion,releaseUrl,releaseNotes);

@override
String toString() {
  return 'UpdateInfo(isUpdateAvailable: $isUpdateAvailable, latestVersion: $latestVersion, currentVersion: $currentVersion, releaseUrl: $releaseUrl, releaseNotes: $releaseNotes)';
}


}

/// @nodoc
abstract mixin class $UpdateInfoCopyWith<$Res>  {
  factory $UpdateInfoCopyWith(UpdateInfo value, $Res Function(UpdateInfo) _then) = _$UpdateInfoCopyWithImpl;
@useResult
$Res call({
 bool isUpdateAvailable, String latestVersion, String currentVersion, String releaseUrl, String? releaseNotes
});




}
/// @nodoc
class _$UpdateInfoCopyWithImpl<$Res>
    implements $UpdateInfoCopyWith<$Res> {
  _$UpdateInfoCopyWithImpl(this._self, this._then);

  final UpdateInfo _self;
  final $Res Function(UpdateInfo) _then;

/// Create a copy of UpdateInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isUpdateAvailable = null,Object? latestVersion = null,Object? currentVersion = null,Object? releaseUrl = null,Object? releaseNotes = freezed,}) {
  return _then(_self.copyWith(
isUpdateAvailable: null == isUpdateAvailable ? _self.isUpdateAvailable : isUpdateAvailable // ignore: cast_nullable_to_non_nullable
as bool,latestVersion: null == latestVersion ? _self.latestVersion : latestVersion // ignore: cast_nullable_to_non_nullable
as String,currentVersion: null == currentVersion ? _self.currentVersion : currentVersion // ignore: cast_nullable_to_non_nullable
as String,releaseUrl: null == releaseUrl ? _self.releaseUrl : releaseUrl // ignore: cast_nullable_to_non_nullable
as String,releaseNotes: freezed == releaseNotes ? _self.releaseNotes : releaseNotes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateInfo].
extension UpdateInfoPatterns on UpdateInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateInfo value)  $default,){
final _that = this;
switch (_that) {
case _UpdateInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateInfo value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isUpdateAvailable,  String latestVersion,  String currentVersion,  String releaseUrl,  String? releaseNotes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateInfo() when $default != null:
return $default(_that.isUpdateAvailable,_that.latestVersion,_that.currentVersion,_that.releaseUrl,_that.releaseNotes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isUpdateAvailable,  String latestVersion,  String currentVersion,  String releaseUrl,  String? releaseNotes)  $default,) {final _that = this;
switch (_that) {
case _UpdateInfo():
return $default(_that.isUpdateAvailable,_that.latestVersion,_that.currentVersion,_that.releaseUrl,_that.releaseNotes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isUpdateAvailable,  String latestVersion,  String currentVersion,  String releaseUrl,  String? releaseNotes)?  $default,) {final _that = this;
switch (_that) {
case _UpdateInfo() when $default != null:
return $default(_that.isUpdateAvailable,_that.latestVersion,_that.currentVersion,_that.releaseUrl,_that.releaseNotes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateInfo implements UpdateInfo {
  const _UpdateInfo({required this.isUpdateAvailable, required this.latestVersion, required this.currentVersion, required this.releaseUrl, this.releaseNotes});
  factory _UpdateInfo.fromJson(Map<String, dynamic> json) => _$UpdateInfoFromJson(json);

@override final  bool isUpdateAvailable;
@override final  String latestVersion;
@override final  String currentVersion;
@override final  String releaseUrl;
@override final  String? releaseNotes;

/// Create a copy of UpdateInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateInfoCopyWith<_UpdateInfo> get copyWith => __$UpdateInfoCopyWithImpl<_UpdateInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateInfo&&(identical(other.isUpdateAvailable, isUpdateAvailable) || other.isUpdateAvailable == isUpdateAvailable)&&(identical(other.latestVersion, latestVersion) || other.latestVersion == latestVersion)&&(identical(other.currentVersion, currentVersion) || other.currentVersion == currentVersion)&&(identical(other.releaseUrl, releaseUrl) || other.releaseUrl == releaseUrl)&&(identical(other.releaseNotes, releaseNotes) || other.releaseNotes == releaseNotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isUpdateAvailable,latestVersion,currentVersion,releaseUrl,releaseNotes);

@override
String toString() {
  return 'UpdateInfo(isUpdateAvailable: $isUpdateAvailable, latestVersion: $latestVersion, currentVersion: $currentVersion, releaseUrl: $releaseUrl, releaseNotes: $releaseNotes)';
}


}

/// @nodoc
abstract mixin class _$UpdateInfoCopyWith<$Res> implements $UpdateInfoCopyWith<$Res> {
  factory _$UpdateInfoCopyWith(_UpdateInfo value, $Res Function(_UpdateInfo) _then) = __$UpdateInfoCopyWithImpl;
@override @useResult
$Res call({
 bool isUpdateAvailable, String latestVersion, String currentVersion, String releaseUrl, String? releaseNotes
});




}
/// @nodoc
class __$UpdateInfoCopyWithImpl<$Res>
    implements _$UpdateInfoCopyWith<$Res> {
  __$UpdateInfoCopyWithImpl(this._self, this._then);

  final _UpdateInfo _self;
  final $Res Function(_UpdateInfo) _then;

/// Create a copy of UpdateInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isUpdateAvailable = null,Object? latestVersion = null,Object? currentVersion = null,Object? releaseUrl = null,Object? releaseNotes = freezed,}) {
  return _then(_UpdateInfo(
isUpdateAvailable: null == isUpdateAvailable ? _self.isUpdateAvailable : isUpdateAvailable // ignore: cast_nullable_to_non_nullable
as bool,latestVersion: null == latestVersion ? _self.latestVersion : latestVersion // ignore: cast_nullable_to_non_nullable
as String,currentVersion: null == currentVersion ? _self.currentVersion : currentVersion // ignore: cast_nullable_to_non_nullable
as String,releaseUrl: null == releaseUrl ? _self.releaseUrl : releaseUrl // ignore: cast_nullable_to_non_nullable
as String,releaseNotes: freezed == releaseNotes ? _self.releaseNotes : releaseNotes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
