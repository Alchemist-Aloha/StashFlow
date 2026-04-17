import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('ru'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'StashFlow'**
  String get appTitle;

  /// No description provided for @nav_scenes.
  ///
  /// In en, this message translates to:
  /// **'Scenes'**
  String get nav_scenes;

  /// No description provided for @nav_performers.
  ///
  /// In en, this message translates to:
  /// **'Performers'**
  String get nav_performers;

  /// No description provided for @nav_studios.
  ///
  /// In en, this message translates to:
  /// **'Studios'**
  String get nav_studios;

  /// No description provided for @nav_tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get nav_tags;

  /// No description provided for @nav_galleries.
  ///
  /// In en, this message translates to:
  /// **'Galleries'**
  String get nav_galleries;

  /// No description provided for @nScenes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{no scenes} =1{1 scene} other{{count} scenes}}'**
  String nScenes(num count);

  /// No description provided for @nPerformers.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{no performers} =1{1 performer} other{{count} performers}}'**
  String nPerformers(num count);

  /// No description provided for @common_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get common_reset;

  /// No description provided for @common_apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get common_apply;

  /// No description provided for @common_save_default.
  ///
  /// In en, this message translates to:
  /// **'Save as Default'**
  String get common_save_default;

  /// No description provided for @common_sort_method.
  ///
  /// In en, this message translates to:
  /// **'Sort Method'**
  String get common_sort_method;

  /// No description provided for @common_direction.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get common_direction;

  /// No description provided for @common_ascending.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get common_ascending;

  /// No description provided for @common_descending.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get common_descending;

  /// No description provided for @common_favorites_only.
  ///
  /// In en, this message translates to:
  /// **'Favorites only'**
  String get common_favorites_only;

  /// No description provided for @common_apply_sort.
  ///
  /// In en, this message translates to:
  /// **'Apply Sort'**
  String get common_apply_sort;

  /// No description provided for @common_apply_filters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get common_apply_filters;

  /// No description provided for @common_view_all.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get common_view_all;

  /// No description provided for @common_later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get common_later;

  /// No description provided for @common_update_now.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get common_update_now;

  /// No description provided for @common_configure_now.
  ///
  /// In en, this message translates to:
  /// **'Configure Now'**
  String get common_configure_now;

  /// No description provided for @common_clear_rating.
  ///
  /// In en, this message translates to:
  /// **'Clear Rating'**
  String get common_clear_rating;

  /// No description provided for @common_no_media.
  ///
  /// In en, this message translates to:
  /// **'No media available'**
  String get common_no_media;

  /// No description provided for @common_setup_required.
  ///
  /// In en, this message translates to:
  /// **'Setup Required'**
  String get common_setup_required;

  /// No description provided for @common_update_available.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get common_update_available;

  /// No description provided for @details_studio.
  ///
  /// In en, this message translates to:
  /// **'Studio Details'**
  String get details_studio;

  /// No description provided for @details_performer.
  ///
  /// In en, this message translates to:
  /// **'Performer Details'**
  String get details_performer;

  /// No description provided for @details_tag.
  ///
  /// In en, this message translates to:
  /// **'Tag Details'**
  String get details_tag;

  /// No description provided for @details_scene.
  ///
  /// In en, this message translates to:
  /// **'Scene Details'**
  String get details_scene;

  /// No description provided for @details_gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery Details'**
  String get details_gallery;

  /// No description provided for @studios_filter_title.
  ///
  /// In en, this message translates to:
  /// **'Filter Studios'**
  String get studios_filter_title;

  /// No description provided for @studios_filter_saved.
  ///
  /// In en, this message translates to:
  /// **'Filter preferences saved as default'**
  String get studios_filter_saved;

  /// No description provided for @sort_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sort_name;

  /// No description provided for @sort_scene_count.
  ///
  /// In en, this message translates to:
  /// **'Scene Count'**
  String get sort_scene_count;

  /// No description provided for @sort_rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get sort_rating;

  /// No description provided for @sort_updated_at.
  ///
  /// In en, this message translates to:
  /// **'Updated At'**
  String get sort_updated_at;

  /// No description provided for @sort_created_at.
  ///
  /// In en, this message translates to:
  /// **'Created At'**
  String get sort_created_at;

  /// No description provided for @sort_random.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get sort_random;

  /// No description provided for @studios_sort_saved.
  ///
  /// In en, this message translates to:
  /// **'Sort preferences saved as default'**
  String get studios_sort_saved;

  /// No description provided for @studios_no_random.
  ///
  /// In en, this message translates to:
  /// **'No studios available for random navigation'**
  String get studios_no_random;

  /// No description provided for @tags_filter_title.
  ///
  /// In en, this message translates to:
  /// **'Filter Tags'**
  String get tags_filter_title;

  /// No description provided for @tags_filter_saved.
  ///
  /// In en, this message translates to:
  /// **'Filter preferences saved as default'**
  String get tags_filter_saved;

  /// No description provided for @tags_sort_saved.
  ///
  /// In en, this message translates to:
  /// **'Sort preferences saved as default'**
  String get tags_sort_saved;

  /// No description provided for @tags_no_random.
  ///
  /// In en, this message translates to:
  /// **'No tags available for random navigation'**
  String get tags_no_random;

  /// No description provided for @scenes_no_random.
  ///
  /// In en, this message translates to:
  /// **'No scenes available for random navigation'**
  String get scenes_no_random;

  /// No description provided for @performers_no_random.
  ///
  /// In en, this message translates to:
  /// **'No performers available for random navigation'**
  String get performers_no_random;

  /// No description provided for @galleries_no_random.
  ///
  /// In en, this message translates to:
  /// **'No galleries available for random navigation'**
  String get galleries_no_random;

  /// No description provided for @common_error.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String common_error(String message);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'ja',
    'ko',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hans':
            return AppLocalizationsZhHans();
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
