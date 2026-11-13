import 'package:material_ui/material_ui.dart';

/// Returns the performer's age on the scene date.
///
/// Year-only birthdates use calendar-year subtraction. Full birthdates account
/// for whether the birthday had occurred. Invalid or future dates are omitted.
int? ageAtSceneYear({required DateTime sceneDate, String? birthdate}) {
  final match = RegExp(
    r'^(\d{4})(?:-(\d{2})-(\d{2}))?$',
  ).firstMatch(birthdate?.trim() ?? '');
  if (match == null) return null;

  final birthYear = int.parse(match[1]!);
  var age = sceneDate.year - birthYear;
  if (age < 0) return null;

  final month = int.tryParse(match[2] ?? '');
  final day = int.tryParse(match[3] ?? '');
  if (month == null || day == null) return age;

  final parsedBirthdate = DateTime.tryParse(
    '${match[1]}-${match[2]}-${match[3]}',
  );
  if (parsedBirthdate == null ||
      parsedBirthdate.month != month ||
      parsedBirthdate.day != day) {
    return null;
  }

  if (sceneDate.month < month ||
      (sceneDate.month == month && sceneDate.day < day)) {
    age--;
  }
  return age < 0 ? null : age;
}

/// Displays a performer name followed by their muted age in the scene year.
class ScenePerformerTitle extends StatelessWidget {
  const ScenePerformerTitle({
    required this.performerName,
    required this.sceneDate,
    this.birthdate,
    super.key,
  });

  final String performerName;
  final DateTime sceneDate;
  final String? birthdate;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyLarge;
    final age = ageAtSceneYear(sceneDate: sceneDate, birthdate: birthdate);

    return Text.rich(
      TextSpan(
        style: textStyle,
        children: [
          TextSpan(text: performerName),
          if (age != null)
            TextSpan(
              text: ' ($age)',
              style: textStyle?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}
