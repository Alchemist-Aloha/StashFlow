enum OrganizedFilter {
  all,
  organized,
  unorganized;

  bool? toBool() => switch (this) {
        OrganizedFilter.all => null,
        OrganizedFilter.organized => true,
        OrganizedFilter.unorganized => false,
      };

  static OrganizedFilter fromBool(bool? value) {
    if (value == null) return OrganizedFilter.all;
    return value ? OrganizedFilter.organized : OrganizedFilter.unorganized;
  }
}
