library;

import 'package:json_annotation/json_annotation.dart';

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

class IntCriterion {
  final int value;
  final int? value2;
  final CriterionModifier modifier;

  const IntCriterion({
    required this.value,
    this.value2,
    this.modifier = CriterionModifier.equals,
  });

  factory IntCriterion.fromJson(Map<String, dynamic> json) {
    return IntCriterion(
      value: json['value'] as int,
      value2: json['value2'] as int?,
      modifier: CriterionModifier.values.firstWhere(
        (e) => e.toString().split('.').last.toUpperCase() == json['modifier'],
        orElse: () => CriterionModifier.equals,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      if (value2 != null) 'value2': value2,
      'modifier': modifier.toString().split('.').last.toUpperCase(),
    };
  }
}

class StringCriterion {
  final String value;
  final CriterionModifier modifier;

  const StringCriterion({
    required this.value,
    this.modifier = CriterionModifier.equals,
  });

  factory StringCriterion.fromJson(Map<String, dynamic> json) {
    return StringCriterion(
      value: json['value'] as String,
      modifier: CriterionModifier.values.firstWhere(
        (e) => e.toString().split('.').last.toUpperCase() == json['modifier'],
        orElse: () => CriterionModifier.equals,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'modifier': modifier.toString().split('.').last.toUpperCase(),
    };
  }
}

class DateCriterion {
  final String value;
  final String? value2;
  final CriterionModifier modifier;

  const DateCriterion({
    required this.value,
    this.value2,
    this.modifier = CriterionModifier.equals,
  });

  factory DateCriterion.fromJson(Map<String, dynamic> json) {
    return DateCriterion(
      value: json['value'] as String,
      value2: json['value2'] as String?,
      modifier: CriterionModifier.values.firstWhere(
        (e) => e.toString().split('.').last.toUpperCase() == json['modifier'],
        orElse: () => CriterionModifier.equals,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      if (value2 != null) 'value2': value2,
      'modifier': modifier.toString().split('.').last.toUpperCase(),
    };
  }
}

class MultiCriterion {
  final List<String> value;
  final CriterionModifier modifier;

  const MultiCriterion({
    required this.value,
    this.modifier = CriterionModifier.includes,
  });

  factory MultiCriterion.fromJson(Map<String, dynamic> json) {
    return MultiCriterion(
      value: (json['value'] as List).cast<String>(),
      modifier: CriterionModifier.values.firstWhere(
        (e) => e.toString().split('.').last.toUpperCase() == json['modifier'],
        orElse: () => CriterionModifier.includes,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'modifier': modifier.toString().split('.').last.toUpperCase(),
    };
  }
}

class HierarchicalMultiCriterion {
  final List<String> value;
  final CriterionModifier modifier;

  const HierarchicalMultiCriterion({
    required this.value,
    this.modifier = CriterionModifier.includes,
  });

  factory HierarchicalMultiCriterion.fromJson(Map<String, dynamic> json) {
    return HierarchicalMultiCriterion(
      value: (json['value'] as List).cast<String>(),
      modifier: CriterionModifier.values.firstWhere(
        (e) => e.toString().split('.').last.toUpperCase() == json['modifier'],
        orElse: () => CriterionModifier.includes,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'modifier': modifier.toString().split('.').last.toUpperCase(),
    };
  }
}
