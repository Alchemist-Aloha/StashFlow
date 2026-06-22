import 'package:stash_app_flutter/core/domain/entities/criterion.dart';

class GroupFilter {
  final String? isMissingField;
  final IntCriterion? subGroupCount;
  final IntCriterion? sceneCount;

  const GroupFilter({this.isMissingField, this.subGroupCount, this.sceneCount});

  factory GroupFilter.empty() => const GroupFilter();

  GroupFilter copyWith({
    String? isMissingField,
    bool clearIsMissingField = false,
    IntCriterion? subGroupCount,
    bool clearSubGroupCount = false,
    IntCriterion? sceneCount,
    bool clearSceneCount = false,
  }) {
    return GroupFilter(
      isMissingField: clearIsMissingField
          ? null
          : (isMissingField ?? this.isMissingField),
      subGroupCount: clearSubGroupCount
          ? null
          : (subGroupCount ?? this.subGroupCount),
      sceneCount: clearSceneCount ? null : (sceneCount ?? this.sceneCount),
    );
  }

  bool get isEmpty =>
      isMissingField == null && subGroupCount == null && sceneCount == null;

  Map<String, dynamic> toJson() {
    return {
      'isMissingField': isMissingField,
      'subGroupCount': subGroupCount?.toJson(),
      'sceneCount': sceneCount?.toJson(),
    };
  }

  factory GroupFilter.fromJson(Map<String, dynamic> json) {
    return GroupFilter(
      isMissingField: json['isMissingField'] as String?,
      subGroupCount: json['subGroupCount'] is Map<String, dynamic>
          ? IntCriterion.fromJson(json['subGroupCount'] as Map<String, dynamic>)
          : null,
      sceneCount: json['sceneCount'] is Map<String, dynamic>
          ? IntCriterion.fromJson(json['sceneCount'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GroupFilter &&
        other.isMissingField == isMissingField &&
        other.subGroupCount == subGroupCount &&
        other.sceneCount == sceneCount;
  }

  @override
  int get hashCode => Object.hash(isMissingField, subGroupCount, sceneCount);
}
