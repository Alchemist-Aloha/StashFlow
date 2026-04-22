import 'package:freezed_annotation/freezed_annotation.dart';

part 'criterion.freezed.dart';
part 'criterion.g.dart';

enum CriterionModifier {
  @JsonValue('EQUALS')
  equals,
  @JsonValue('NOT_EQUALS')
  notEquals,
  @JsonValue('GREATER_THAN')
  greaterThan,
  @JsonValue('LESS_THAN')
  lessThan,
  @JsonValue('IS_NULL')
  isNull,
  @JsonValue('NOT_NULL')
  notNull,
  @JsonValue('INCLUDES_ALL')
  includesAll,
  @JsonValue('INCLUDES')
  includes,
  @JsonValue('EXCLUDES')
  excludes,
  @JsonValue('MATCHES_REGEX')
  matchesRegex,
  @JsonValue('NOT_MATCHES_REGEX')
  notMatchesRegex,
  @JsonValue('BETWEEN')
  between,
  @JsonValue('NOT_BETWEEN')
  notBetween,
}

@freezed
abstract class IntCriterion with _$IntCriterion {
  const factory IntCriterion({
    required int value,
    int? value2,
    @Default(CriterionModifier.equals) CriterionModifier modifier,
  }) = _IntCriterion;

  factory IntCriterion.fromJson(Map<String, dynamic> json) => _$IntCriterionFromJson(json);
}

@freezed
abstract class StringCriterion with _$StringCriterion {
  const factory StringCriterion({
    required String value,
    @Default(CriterionModifier.equals) CriterionModifier modifier,
  }) = _StringCriterion;

  factory StringCriterion.fromJson(Map<String, dynamic> json) => _$StringCriterionFromJson(json);
}

@freezed
abstract class DateCriterion with _$DateCriterion {
  const factory DateCriterion({
    required String value,
    String? value2,
    @Default(CriterionModifier.equals) CriterionModifier modifier,
  }) = _DateCriterion;

  factory DateCriterion.fromJson(Map<String, dynamic> json) => _$DateCriterionFromJson(json);
}

@freezed
abstract class MultiCriterion with _$MultiCriterion {
  const factory MultiCriterion({
    required List<String> value,
    @Default(CriterionModifier.includes) CriterionModifier modifier,
  }) = _MultiCriterion;

  factory MultiCriterion.fromJson(Map<String, dynamic> json) => _$MultiCriterionFromJson(json);
}

@freezed
abstract class HierarchicalMultiCriterion with _$HierarchicalMultiCriterion {
  const factory HierarchicalMultiCriterion({
    required List<String> value,
    @Default(CriterionModifier.includes) CriterionModifier modifier,
  }) = _HierarchicalMultiCriterion;

  factory HierarchicalMultiCriterion.fromJson(Map<String, dynamic> json) => _$HierarchicalMultiCriterionFromJson(json);
}
