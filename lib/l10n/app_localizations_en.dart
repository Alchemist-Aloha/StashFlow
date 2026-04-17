// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'StashFlow';

  @override
  String get nav_scenes => 'Scenes';

  @override
  String get nav_performers => 'Performers';

  @override
  String get nav_studios => 'Studios';

  @override
  String get nav_tags => 'Tags';

  @override
  String get nav_galleries => 'Galleries';

  @override
  String nScenes(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString scenes',
      one: '1 scene',
      zero: 'no scenes',
    );
    return '$_temp0';
  }

  @override
  String nPerformers(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString performers',
      one: '1 performer',
      zero: 'no performers',
    );
    return '$_temp0';
  }

  @override
  String get common_reset => 'Reset';

  @override
  String get common_apply => 'Apply';

  @override
  String get common_save_default => 'Save as Default';

  @override
  String get common_sort_method => 'Sort Method';

  @override
  String get common_direction => 'Direction';

  @override
  String get common_ascending => 'Ascending';

  @override
  String get common_descending => 'Descending';

  @override
  String get common_favorites_only => 'Favorites only';

  @override
  String get common_apply_sort => 'Apply Sort';

  @override
  String get common_apply_filters => 'Apply Filters';

  @override
  String get common_view_all => 'View all';

  @override
  String get common_later => 'Later';

  @override
  String get common_update_now => 'Update Now';

  @override
  String get common_configure_now => 'Configure Now';

  @override
  String get common_clear_rating => 'Clear Rating';

  @override
  String get common_no_media => 'No media available';

  @override
  String get common_setup_required => 'Setup Required';

  @override
  String get common_update_available => 'Update Available';

  @override
  String get details_studio => 'Studio Details';

  @override
  String get details_performer => 'Performer Details';

  @override
  String get details_tag => 'Tag Details';

  @override
  String get details_scene => 'Scene Details';

  @override
  String get details_gallery => 'Gallery Details';

  @override
  String get studios_filter_title => 'Filter Studios';

  @override
  String get studios_filter_saved => 'Filter preferences saved as default';

  @override
  String get sort_name => 'Name';

  @override
  String get sort_scene_count => 'Scene Count';

  @override
  String get sort_rating => 'Rating';

  @override
  String get sort_updated_at => 'Updated At';

  @override
  String get sort_created_at => 'Created At';

  @override
  String get sort_random => 'Random';

  @override
  String get studios_sort_saved => 'Sort preferences saved as default';

  @override
  String get studios_no_random => 'No studios available for random navigation';

  @override
  String get tags_filter_title => 'Filter Tags';

  @override
  String get tags_filter_saved => 'Filter preferences saved as default';

  @override
  String get tags_sort_saved => 'Sort preferences saved as default';

  @override
  String get tags_no_random => 'No tags available for random navigation';

  @override
  String get scenes_no_random => 'No scenes available for random navigation';

  @override
  String get performers_no_random =>
      'No performers available for random navigation';

  @override
  String get galleries_no_random =>
      'No galleries available for random navigation';

  @override
  String common_error(String message) {
    return 'Error: $message';
  }
}
