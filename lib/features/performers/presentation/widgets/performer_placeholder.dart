/// Stash's bundled default performer silhouettes, copied from the official
/// project (`internal/static`); see `asset/licenses/performer_placeholders.txt`.
const _female = [
  '02', '05', '06', '07', '09', '11', '12', '13', '14', '17', //
  '19', '21', '22', '23', '24', '25', '26', '27', '28', '29', //
  '30', '31', '32', '33', '34', '35', '36', '37', '38', '39',
];
const _femalePng = {'06', '11', '29', '33', '35'};
const _maleCount = 5;

/// Placeholder asset for a performer without a loadable image.
///
/// Rotates through the set by numeric id, so consecutive performers get
/// different silhouettes and each performer keeps the same one. Male
/// performers use the male set, matching Stash's own default images.
String performerPlaceholderAsset(String id, String? gender) {
  final n = (int.tryParse(id) ?? id.hashCode).abs();
  if (gender == 'MALE') {
    return 'asset/performer_placeholders/male/Male0${n % _maleCount + 1}.svg';
  }
  final name = _female[n % _female.length];
  // Stash ships these few as PNG; the rest are SVG.
  final ext = _femalePng.contains(name) ? 'png' : 'svg';
  return 'asset/performer_placeholders/female/NoName$name.$ext';
}
