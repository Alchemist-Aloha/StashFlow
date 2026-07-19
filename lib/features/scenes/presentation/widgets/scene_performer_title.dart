import 'package:flutter/material.dart';

int? ageAtSceneYear({required DateTime sceneDate, String? birthdate}) {
  final parsedBirthdate = DateTime.tryParse(birthdate?.trim() ?? '');
  if (parsedBirthdate == null) return null;

  final age = sceneDate.year - parsedBirthdate.year;
  return age < 0 ? null : age;
}

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
