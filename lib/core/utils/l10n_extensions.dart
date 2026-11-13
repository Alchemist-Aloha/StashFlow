import 'package:material_ui/material_ui.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';
import 'package:stash_app_flutter/l10n/app_localizations_en.dart';

/// App strings plus `material_ui` design-widget localizations.
///
/// Use this instead of `AppLocalizations.localizationsDelegates`: gen-l10n
/// still emits the SDK `flutter_localizations` delegates, which `material_ui`
/// widgets do not read.
const List<LocalizationsDelegate<dynamic>> appLocalizationsDelegates = [
  AppLocalizations.delegate,
  ...GlobalMaterialLocalizations.delegates,
];

extension L10nX on BuildContext {
  AppLocalizations get l10n =>
      AppLocalizations.of(this) ?? AppLocalizationsEn();
}
