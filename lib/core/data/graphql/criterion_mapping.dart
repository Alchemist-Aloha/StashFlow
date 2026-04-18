import '../../domain/entities/criterion.dart';
import 'schema.graphql.dart';

Enum$CriterionModifier mapModifier(CriterionModifier modifier) {
  switch (modifier) {
    case CriterionModifier.equals:
      return Enum$CriterionModifier.EQUALS;
    case CriterionModifier.notEquals:
      return Enum$CriterionModifier.NOT_EQUALS;
    case CriterionModifier.greaterThan:
      return Enum$CriterionModifier.GREATER_THAN;
    case CriterionModifier.lessThan:
      return Enum$CriterionModifier.LESS_THAN;
    case CriterionModifier.isNull:
      return Enum$CriterionModifier.IS_NULL;
    case CriterionModifier.notNull:
      return Enum$CriterionModifier.NOT_NULL;
    case CriterionModifier.includesAll:
      return Enum$CriterionModifier.INCLUDES_ALL;
    case CriterionModifier.includes:
      return Enum$CriterionModifier.INCLUDES;
    case CriterionModifier.excludes:
      return Enum$CriterionModifier.EXCLUDES;
    case CriterionModifier.matchesRegex:
      return Enum$CriterionModifier.MATCHES_REGEX;
    case CriterionModifier.notMatchesRegex:
      return Enum$CriterionModifier.NOT_MATCHES_REGEX;
    case CriterionModifier.between:
      return Enum$CriterionModifier.BETWEEN;
    case CriterionModifier.notBetween:
      return Enum$CriterionModifier.NOT_BETWEEN;
  }
}

Input$IntCriterionInput? mapIntCriterion(IntCriterion? criterion) {
  if (criterion == null) return null;
  return Input$IntCriterionInput(
    value: criterion.value,
    value2: criterion.value2,
    modifier: mapModifier(criterion.modifier),
  );
}

Input$FloatCriterionInput? mapFloatCriterion(IntCriterion? criterion) {
  if (criterion == null) return null;
  return Input$FloatCriterionInput(
    value: criterion.value.toDouble(),
    value2: criterion.value2?.toDouble(),
    modifier: mapModifier(criterion.modifier),
  );
}

Input$StringCriterionInput? mapStringCriterion(StringCriterion? criterion) {
  if (criterion == null) return null;
  return Input$StringCriterionInput(
    value: criterion.value,
    modifier: mapModifier(criterion.modifier),
  );
}

Input$DateCriterionInput? mapDateCriterion(DateCriterion? criterion) {
  if (criterion == null) return null;
  return Input$DateCriterionInput(
    value: criterion.value,
    value2: criterion.value2,
    modifier: mapModifier(criterion.modifier),
  );
}

Input$TimestampCriterionInput? mapTimestampCriterion(DateCriterion? criterion) {
  if (criterion == null) return null;
  return Input$TimestampCriterionInput(
    value: criterion.value,
    value2: criterion.value2,
    modifier: mapModifier(criterion.modifier),
  );
}

Input$MultiCriterionInput? mapMultiCriterion(MultiCriterion? criterion) {
  if (criterion == null) return null;
  return Input$MultiCriterionInput(
    value: criterion.value,
    modifier: mapModifier(criterion.modifier),
  );
}

Input$HierarchicalMultiCriterionInput? mapHierarchicalMultiCriterion(
    HierarchicalMultiCriterion? criterion) {
  if (criterion == null) return null;
  return Input$HierarchicalMultiCriterionInput(
    value: criterion.value,
    modifier: mapModifier(criterion.modifier),
  );
}

Input$GenderCriterionInput? mapGenderCriterion(String? gender) {
  if (gender == null) return null;
  return Input$GenderCriterionInput(
    value: fromJson$Enum$GenderEnum(gender),
    modifier: Enum$CriterionModifier.EQUALS,
  );
}

Input$CircumcisionCriterionInput? mapCircumcisionCriterion(String? circumcised) {
  if (circumcised == null) return null;
  return Input$CircumcisionCriterionInput(
    value: [fromJson$Enum$CircumcisedEnum(circumcised)],
    modifier: Enum$CriterionModifier.EQUALS,
  );
}
