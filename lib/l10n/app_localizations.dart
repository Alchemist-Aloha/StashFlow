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
    Locale('en'),
    Locale('it'),
    Locale('es'),
    Locale('fr'),
    Locale('de'),
    Locale('ru'),
    Locale('ja'),
    Locale('ko'),
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

  /// No description provided for @common_default.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get common_default;

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

  /// No description provided for @common_show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get common_show;

  /// No description provided for @common_hide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get common_hide;

  /// No description provided for @galleries_filter_saved.
  ///
  /// In en, this message translates to:
  /// **'Filter preferences saved as default'**
  String get galleries_filter_saved;

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

  /// No description provided for @common_no_media_available.
  ///
  /// In en, this message translates to:
  /// **'No media available'**
  String get common_no_media_available;

  /// No description provided for @common_id.
  ///
  /// In en, this message translates to:
  /// **'ID: {id}'**
  String common_id(Object id);

  /// No description provided for @common_search_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get common_search_placeholder;

  /// No description provided for @common_pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get common_pause;

  /// No description provided for @common_play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get common_play;

  /// No description provided for @common_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get common_close;

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @common_unmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get common_unmute;

  /// No description provided for @common_mute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get common_mute;

  /// No description provided for @common_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get common_back;

  /// No description provided for @common_rate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get common_rate;

  /// No description provided for @common_previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get common_previous;

  /// No description provided for @common_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get common_next;

  /// No description provided for @common_favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get common_favorite;

  /// No description provided for @common_unfavorite.
  ///
  /// In en, this message translates to:
  /// **'Unfavorite'**
  String get common_unfavorite;

  /// No description provided for @common_version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get common_version;

  /// No description provided for @common_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get common_loading;

  /// No description provided for @common_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get common_unavailable;

  /// No description provided for @common_details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get common_details;

  /// No description provided for @common_title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get common_title;

  /// No description provided for @common_release_date.
  ///
  /// In en, this message translates to:
  /// **'Release Date'**
  String get common_release_date;

  /// No description provided for @common_url.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get common_url;

  /// No description provided for @common_no_url.
  ///
  /// In en, this message translates to:
  /// **'No URL'**
  String get common_no_url;

  /// No description provided for @common_sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get common_sort;

  /// No description provided for @common_filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get common_filter;

  /// No description provided for @common_search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get common_search;

  /// No description provided for @common_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get common_settings;

  /// No description provided for @common_reset_to_1x.
  ///
  /// In en, this message translates to:
  /// **'Reset to 1x'**
  String get common_reset_to_1x;

  /// No description provided for @common_skip_next.
  ///
  /// In en, this message translates to:
  /// **'Skip Next'**
  String get common_skip_next;

  /// No description provided for @common_select_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Select subtitle'**
  String get common_select_subtitle;

  /// No description provided for @common_playback_speed.
  ///
  /// In en, this message translates to:
  /// **'Playback speed'**
  String get common_playback_speed;

  /// No description provided for @common_pip.
  ///
  /// In en, this message translates to:
  /// **'Picture-in-Picture'**
  String get common_pip;

  /// No description provided for @common_toggle_fullscreen.
  ///
  /// In en, this message translates to:
  /// **'Toggle Fullscreen'**
  String get common_toggle_fullscreen;

  /// No description provided for @common_exit_fullscreen.
  ///
  /// In en, this message translates to:
  /// **'Exit Fullscreen'**
  String get common_exit_fullscreen;

  /// No description provided for @common_copy_logs.
  ///
  /// In en, this message translates to:
  /// **'Copy all logs'**
  String get common_copy_logs;

  /// No description provided for @common_clear_logs.
  ///
  /// In en, this message translates to:
  /// **'Clear logs'**
  String get common_clear_logs;

  /// No description provided for @common_enable_autoscroll.
  ///
  /// In en, this message translates to:
  /// **'Enable auto-scroll'**
  String get common_enable_autoscroll;

  /// No description provided for @common_disable_autoscroll.
  ///
  /// In en, this message translates to:
  /// **'Disable auto-scroll'**
  String get common_disable_autoscroll;

  /// No description provided for @common_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get common_retry;

  /// No description provided for @common_no_items.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get common_no_items;

  /// No description provided for @common_none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get common_none;

  /// No description provided for @common_any.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get common_any;

  /// No description provided for @common_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get common_name;

  /// No description provided for @common_date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get common_date;

  /// No description provided for @common_rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get common_rating;

  /// No description provided for @common_image_count.
  ///
  /// In en, this message translates to:
  /// **'Image Count'**
  String get common_image_count;

  /// No description provided for @common_filepath.
  ///
  /// In en, this message translates to:
  /// **'Filepath'**
  String get common_filepath;

  /// No description provided for @common_random.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get common_random;

  /// No description provided for @common_no_media_found.
  ///
  /// In en, this message translates to:
  /// **'No media found'**
  String get common_no_media_found;

  /// No description provided for @common_not_found.
  ///
  /// In en, this message translates to:
  /// **'{item} not found'**
  String common_not_found(String item);

  /// No description provided for @common_add_favorite.
  ///
  /// In en, this message translates to:
  /// **'Add favorite'**
  String get common_add_favorite;

  /// No description provided for @common_remove_favorite.
  ///
  /// In en, this message translates to:
  /// **'Remove favorite'**
  String get common_remove_favorite;

  /// No description provided for @details_group.
  ///
  /// In en, this message translates to:
  /// **'Group Details'**
  String get details_group;

  /// No description provided for @details_synopsis.
  ///
  /// In en, this message translates to:
  /// **'Synopsis'**
  String get details_synopsis;

  /// No description provided for @details_media.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get details_media;

  /// No description provided for @details_galleries.
  ///
  /// In en, this message translates to:
  /// **'Galleries'**
  String get details_galleries;

  /// No description provided for @details_tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get details_tags;

  /// No description provided for @details_links.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get details_links;

  /// No description provided for @details_scene_scrape.
  ///
  /// In en, this message translates to:
  /// **'Scrape metadata'**
  String get details_scene_scrape;

  /// No description provided for @details_show_more.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get details_show_more;

  /// No description provided for @details_show_less.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get details_show_less;

  /// No description provided for @details_more_from_studio.
  ///
  /// In en, this message translates to:
  /// **'More From Studio'**
  String get details_more_from_studio;

  /// No description provided for @details_o_count_incremented.
  ///
  /// In en, this message translates to:
  /// **'O count incremented'**
  String get details_o_count_incremented;

  /// No description provided for @details_failed_update_rating.
  ///
  /// In en, this message translates to:
  /// **'Failed to update rating: {error}'**
  String details_failed_update_rating(String error);

  /// No description provided for @details_failed_increment_o_count.
  ///
  /// In en, this message translates to:
  /// **'Failed to increment O count: {error}'**
  String details_failed_increment_o_count(String error);

  /// No description provided for @details_scene_add_performer.
  ///
  /// In en, this message translates to:
  /// **'Add Performer'**
  String get details_scene_add_performer;

  /// No description provided for @details_scene_add_tag.
  ///
  /// In en, this message translates to:
  /// **'Add Tag'**
  String get details_scene_add_tag;

  /// No description provided for @details_scene_add_url.
  ///
  /// In en, this message translates to:
  /// **'Add URL'**
  String get details_scene_add_url;

  /// No description provided for @details_scene_remove_url.
  ///
  /// In en, this message translates to:
  /// **'Remove URL'**
  String get details_scene_remove_url;

  /// No description provided for @groups_title.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups_title;

  /// No description provided for @groups_unnamed.
  ///
  /// In en, this message translates to:
  /// **'Unnamed group'**
  String get groups_unnamed;

  /// No description provided for @groups_untitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled group'**
  String get groups_untitled;

  /// No description provided for @studios_title.
  ///
  /// In en, this message translates to:
  /// **'Studios'**
  String get studios_title;

  /// No description provided for @studios_galleries_title.
  ///
  /// In en, this message translates to:
  /// **'Studio Galleries'**
  String get studios_galleries_title;

  /// No description provided for @studios_media_title.
  ///
  /// In en, this message translates to:
  /// **'Studio Media'**
  String get studios_media_title;

  /// No description provided for @studios_sort_title.
  ///
  /// In en, this message translates to:
  /// **'Sort Studios'**
  String get studios_sort_title;

  /// No description provided for @galleries_title.
  ///
  /// In en, this message translates to:
  /// **'Galleries'**
  String get galleries_title;

  /// No description provided for @galleries_sort_title.
  ///
  /// In en, this message translates to:
  /// **'Sort Galleries'**
  String get galleries_sort_title;

  /// No description provided for @galleries_all_images.
  ///
  /// In en, this message translates to:
  /// **'All Images'**
  String get galleries_all_images;

  /// No description provided for @galleries_filter_title.
  ///
  /// In en, this message translates to:
  /// **'Filter Galleries'**
  String get galleries_filter_title;

  /// No description provided for @galleries_min_rating.
  ///
  /// In en, this message translates to:
  /// **'Minimum Rating'**
  String get galleries_min_rating;

  /// No description provided for @galleries_image_count.
  ///
  /// In en, this message translates to:
  /// **'Image Count'**
  String get galleries_image_count;

  /// No description provided for @galleries_organization.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get galleries_organization;

  /// No description provided for @galleries_organized_only.
  ///
  /// In en, this message translates to:
  /// **'Organized only'**
  String get galleries_organized_only;

  /// No description provided for @scenes_filter_title.
  ///
  /// In en, this message translates to:
  /// **'Filter Scenes'**
  String get scenes_filter_title;

  /// No description provided for @scenes_watched.
  ///
  /// In en, this message translates to:
  /// **'Watched'**
  String get scenes_watched;

  /// No description provided for @scenes_unwatched.
  ///
  /// In en, this message translates to:
  /// **'Unwatched'**
  String get scenes_unwatched;

  /// No description provided for @performers_title.
  ///
  /// In en, this message translates to:
  /// **'Performers'**
  String get performers_title;

  /// No description provided for @performers_sort_title.
  ///
  /// In en, this message translates to:
  /// **'Sort Performers'**
  String get performers_sort_title;

  /// No description provided for @performers_filter_title.
  ///
  /// In en, this message translates to:
  /// **'Filter Performers'**
  String get performers_filter_title;

  /// No description provided for @performers_galleries_title.
  ///
  /// In en, this message translates to:
  /// **'All Performer Galleries'**
  String get performers_galleries_title;

  /// No description provided for @performers_media_title.
  ///
  /// In en, this message translates to:
  /// **'All Performer Media'**
  String get performers_media_title;

  /// No description provided for @performers_gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get performers_gender;

  /// No description provided for @performers_gender_any.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get performers_gender_any;

  /// No description provided for @performers_gender_female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get performers_gender_female;

  /// No description provided for @performers_gender_male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get performers_gender_male;

  /// No description provided for @performers_gender_trans_female.
  ///
  /// In en, this message translates to:
  /// **'Trans Female'**
  String get performers_gender_trans_female;

  /// No description provided for @performers_gender_trans_male.
  ///
  /// In en, this message translates to:
  /// **'Trans Male'**
  String get performers_gender_trans_male;

  /// No description provided for @performers_gender_intersex.
  ///
  /// In en, this message translates to:
  /// **'Intersex'**
  String get performers_gender_intersex;

  /// No description provided for @performers_play_count.
  ///
  /// In en, this message translates to:
  /// **'Play Count'**
  String get performers_play_count;

  /// No description provided for @random_studio.
  ///
  /// In en, this message translates to:
  /// **'Random studio'**
  String get random_studio;

  /// No description provided for @random_gallery.
  ///
  /// In en, this message translates to:
  /// **'Random gallery'**
  String get random_gallery;

  /// No description provided for @random_tag.
  ///
  /// In en, this message translates to:
  /// **'Random tag'**
  String get random_tag;

  /// No description provided for @random_scene.
  ///
  /// In en, this message translates to:
  /// **'Random scene'**
  String get random_scene;

  /// No description provided for @random_performer.
  ///
  /// In en, this message translates to:
  /// **'Random performer'**
  String get random_performer;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_customize.
  ///
  /// In en, this message translates to:
  /// **'Customize StashFlow'**
  String get settings_customize;

  /// No description provided for @settings_customize_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Tune playback, appearance, layout, and support tools from one place.'**
  String get settings_customize_subtitle;

  /// No description provided for @settings_core_section.
  ///
  /// In en, this message translates to:
  /// **'Core settings'**
  String get settings_core_section;

  /// No description provided for @settings_core_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Most-used configuration pages'**
  String get settings_core_subtitle;

  /// No description provided for @settings_server.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get settings_server;

  /// No description provided for @settings_server_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Connection and API configuration'**
  String get settings_server_subtitle;

  /// No description provided for @settings_playback.
  ///
  /// In en, this message translates to:
  /// **'Playback'**
  String get settings_playback;

  /// No description provided for @settings_playback_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Player behavior and interactions'**
  String get settings_playback_subtitle;

  /// No description provided for @settings_keyboard.
  ///
  /// In en, this message translates to:
  /// **'Keyboard'**
  String get settings_keyboard;

  /// No description provided for @settings_keyboard_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Customizable shortcuts and hotkeys'**
  String get settings_keyboard_subtitle;

  /// No description provided for @settings_keyboard_title.
  ///
  /// In en, this message translates to:
  /// **'Keyboard Shortcuts'**
  String get settings_keyboard_title;

  /// No description provided for @settings_keyboard_reset_defaults.
  ///
  /// In en, this message translates to:
  /// **'Reset to Defaults'**
  String get settings_keyboard_reset_defaults;

  /// No description provided for @settings_keyboard_not_bound.
  ///
  /// In en, this message translates to:
  /// **'Not bound'**
  String get settings_keyboard_not_bound;

  /// No description provided for @settings_keyboard_volume_up.
  ///
  /// In en, this message translates to:
  /// **'Volume Up'**
  String get settings_keyboard_volume_up;

  /// No description provided for @settings_keyboard_volume_down.
  ///
  /// In en, this message translates to:
  /// **'Volume Down'**
  String get settings_keyboard_volume_down;

  /// No description provided for @settings_keyboard_toggle_mute.
  ///
  /// In en, this message translates to:
  /// **'Toggle Mute'**
  String get settings_keyboard_toggle_mute;

  /// No description provided for @settings_keyboard_toggle_fullscreen.
  ///
  /// In en, this message translates to:
  /// **'Toggle Fullscreen'**
  String get settings_keyboard_toggle_fullscreen;

  /// No description provided for @settings_keyboard_next_scene.
  ///
  /// In en, this message translates to:
  /// **'Next Scene'**
  String get settings_keyboard_next_scene;

  /// No description provided for @settings_keyboard_prev_scene.
  ///
  /// In en, this message translates to:
  /// **'Previous Scene'**
  String get settings_keyboard_prev_scene;

  /// No description provided for @settings_keyboard_increase_speed.
  ///
  /// In en, this message translates to:
  /// **'Increase Playback Speed'**
  String get settings_keyboard_increase_speed;

  /// No description provided for @settings_keyboard_decrease_speed.
  ///
  /// In en, this message translates to:
  /// **'Decrease Playback Speed'**
  String get settings_keyboard_decrease_speed;

  /// No description provided for @settings_keyboard_reset_speed.
  ///
  /// In en, this message translates to:
  /// **'Reset Playback Speed'**
  String get settings_keyboard_reset_speed;

  /// No description provided for @settings_keyboard_close_player.
  ///
  /// In en, this message translates to:
  /// **'Close Player'**
  String get settings_keyboard_close_player;

  /// No description provided for @settings_keyboard_next_image.
  ///
  /// In en, this message translates to:
  /// **'Next Image'**
  String get settings_keyboard_next_image;

  /// No description provided for @settings_keyboard_prev_image.
  ///
  /// In en, this message translates to:
  /// **'Previous Image'**
  String get settings_keyboard_prev_image;

  /// No description provided for @settings_keyboard_go_back.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get settings_keyboard_go_back;

  /// No description provided for @settings_keyboard_play_pause_desc.
  ///
  /// In en, this message translates to:
  /// **'Toggle between playing and pausing video'**
  String get settings_keyboard_play_pause_desc;

  /// No description provided for @settings_keyboard_seek_forward_5_desc.
  ///
  /// In en, this message translates to:
  /// **'Jump forward by 5 seconds'**
  String get settings_keyboard_seek_forward_5_desc;

  /// No description provided for @settings_keyboard_seek_backward_5_desc.
  ///
  /// In en, this message translates to:
  /// **'Jump backward by 5 seconds'**
  String get settings_keyboard_seek_backward_5_desc;

  /// No description provided for @settings_keyboard_seek_forward_10_desc.
  ///
  /// In en, this message translates to:
  /// **'Jump forward by 10 seconds'**
  String get settings_keyboard_seek_forward_10_desc;

  /// No description provided for @settings_keyboard_seek_backward_10_desc.
  ///
  /// In en, this message translates to:
  /// **'Jump backward by 10 seconds'**
  String get settings_keyboard_seek_backward_10_desc;

  /// No description provided for @settings_appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settings_appearance;

  /// No description provided for @settings_appearance_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Theme and colors'**
  String get settings_appearance_subtitle;

  /// No description provided for @settings_interface.
  ///
  /// In en, this message translates to:
  /// **'Interface'**
  String get settings_interface;

  /// No description provided for @settings_interface_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Navigation and layout defaults'**
  String get settings_interface_subtitle;

  /// No description provided for @settings_support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settings_support;

  /// No description provided for @settings_support_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics and about'**
  String get settings_support_subtitle;

  /// No description provided for @settings_develop.
  ///
  /// In en, this message translates to:
  /// **'Develop'**
  String get settings_develop;

  /// No description provided for @settings_develop_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Advanced tools and overrides'**
  String get settings_develop_subtitle;

  /// No description provided for @settings_appearance_title.
  ///
  /// In en, this message translates to:
  /// **'Appearance Settings'**
  String get settings_appearance_title;

  /// No description provided for @settings_appearance_theme_mode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get settings_appearance_theme_mode;

  /// No description provided for @settings_appearance_theme_mode_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how the app follows brightness changes'**
  String get settings_appearance_theme_mode_subtitle;

  /// No description provided for @settings_appearance_theme_system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settings_appearance_theme_system;

  /// No description provided for @settings_appearance_theme_light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settings_appearance_theme_light;

  /// No description provided for @settings_appearance_theme_dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settings_appearance_theme_dark;

  /// No description provided for @settings_appearance_primary_color.
  ///
  /// In en, this message translates to:
  /// **'Primary Color'**
  String get settings_appearance_primary_color;

  /// No description provided for @settings_appearance_primary_color_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a seed color for the Material 3 palette'**
  String get settings_appearance_primary_color_subtitle;

  /// No description provided for @settings_appearance_advanced_theming.
  ///
  /// In en, this message translates to:
  /// **'Advanced Theming'**
  String get settings_appearance_advanced_theming;

  /// No description provided for @settings_appearance_advanced_theming_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Optimizations for specific screen types'**
  String get settings_appearance_advanced_theming_subtitle;

  /// No description provided for @settings_appearance_true_black.
  ///
  /// In en, this message translates to:
  /// **'True Black (AMOLED)'**
  String get settings_appearance_true_black;

  /// No description provided for @settings_appearance_true_black_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Use pure black backgrounds in dark mode to save battery on OLED screens'**
  String get settings_appearance_true_black_subtitle;

  /// No description provided for @settings_appearance_custom_hex.
  ///
  /// In en, this message translates to:
  /// **'Custom Hex Color'**
  String get settings_appearance_custom_hex;

  /// No description provided for @settings_appearance_custom_hex_helper.
  ///
  /// In en, this message translates to:
  /// **'Enter an 8-digit ARGB hex code'**
  String get settings_appearance_custom_hex_helper;

  /// No description provided for @settings_interface_title.
  ///
  /// In en, this message translates to:
  /// **'Interface Settings'**
  String get settings_interface_title;

  /// No description provided for @settings_interface_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_interface_language;

  /// No description provided for @settings_interface_language_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Overwrite the default system language'**
  String get settings_interface_language_subtitle;

  /// No description provided for @settings_interface_app_language.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get settings_interface_app_language;

  /// No description provided for @settings_interface_navigation.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get settings_interface_navigation;

  /// No description provided for @settings_interface_navigation_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Visibility of global navigation shortcuts'**
  String get settings_interface_navigation_subtitle;

  /// No description provided for @settings_interface_show_random.
  ///
  /// In en, this message translates to:
  /// **'Show Random Navigation Buttons'**
  String get settings_interface_show_random;

  /// No description provided for @settings_interface_show_random_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable or disable the floating casino buttons across list and details pages'**
  String get settings_interface_show_random_subtitle;

  /// No description provided for @settings_interface_shake_random.
  ///
  /// In en, this message translates to:
  /// **'Shake to Discover'**
  String get settings_interface_shake_random;

  /// No description provided for @settings_interface_shake_random_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Shake your device to jump to a random item in the current tab'**
  String get settings_interface_shake_random_subtitle;

  /// No description provided for @settings_interface_show_edit.
  ///
  /// In en, this message translates to:
  /// **'Show Edit Button'**
  String get settings_interface_show_edit;

  /// No description provided for @settings_interface_show_edit_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable or disable the edit button on the scene details page'**
  String get settings_interface_show_edit_subtitle;

  /// No description provided for @settings_interface_customize_tabs.
  ///
  /// In en, this message translates to:
  /// **'Customize Tabs'**
  String get settings_interface_customize_tabs;

  /// No description provided for @settings_interface_customize_tabs_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Reorder or hide navigation menu items'**
  String get settings_interface_customize_tabs_subtitle;

  /// No description provided for @settings_interface_scenes_layout.
  ///
  /// In en, this message translates to:
  /// **'Scenes Layout'**
  String get settings_interface_scenes_layout;

  /// No description provided for @settings_interface_scenes_layout_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Default browsing mode for scenes'**
  String get settings_interface_scenes_layout_subtitle;

  /// No description provided for @settings_interface_galleries_layout.
  ///
  /// In en, this message translates to:
  /// **'Galleries Layout'**
  String get settings_interface_galleries_layout;

  /// No description provided for @settings_interface_galleries_layout_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Default browsing mode for galleries'**
  String get settings_interface_galleries_layout_subtitle;

  /// No description provided for @settings_interface_layout_default.
  ///
  /// In en, this message translates to:
  /// **'Default Layout'**
  String get settings_interface_layout_default;

  /// No description provided for @settings_interface_layout_default_desc.
  ///
  /// In en, this message translates to:
  /// **'Choose the default layout for the page'**
  String get settings_interface_layout_default_desc;

  /// No description provided for @settings_interface_layout_list.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get settings_interface_layout_list;

  /// No description provided for @settings_interface_layout_grid.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get settings_interface_layout_grid;

  /// No description provided for @settings_interface_layout_tiktok.
  ///
  /// In en, this message translates to:
  /// **'Infinite Scroll'**
  String get settings_interface_layout_tiktok;

  /// No description provided for @settings_interface_grid_columns.
  ///
  /// In en, this message translates to:
  /// **'Grid Columns'**
  String get settings_interface_grid_columns;

  /// No description provided for @settings_interface_image_viewer.
  ///
  /// In en, this message translates to:
  /// **'Image Viewer'**
  String get settings_interface_image_viewer;

  /// No description provided for @settings_interface_image_viewer_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Configure fullscreen image browsing behavior'**
  String get settings_interface_image_viewer_subtitle;

  /// No description provided for @settings_interface_swipe_direction.
  ///
  /// In en, this message translates to:
  /// **'Fullscreen Swipe Direction'**
  String get settings_interface_swipe_direction;

  /// No description provided for @settings_interface_swipe_direction_desc.
  ///
  /// In en, this message translates to:
  /// **'Choose how images advance in fullscreen mode'**
  String get settings_interface_swipe_direction_desc;

  /// No description provided for @settings_interface_swipe_vertical.
  ///
  /// In en, this message translates to:
  /// **'Vertical'**
  String get settings_interface_swipe_vertical;

  /// No description provided for @settings_interface_swipe_horizontal.
  ///
  /// In en, this message translates to:
  /// **'Horizontal'**
  String get settings_interface_swipe_horizontal;

  /// No description provided for @settings_interface_waterfall_columns.
  ///
  /// In en, this message translates to:
  /// **'Waterfall Grid Columns'**
  String get settings_interface_waterfall_columns;

  /// No description provided for @settings_interface_performer_layouts.
  ///
  /// In en, this message translates to:
  /// **'Performer Layouts'**
  String get settings_interface_performer_layouts;

  /// No description provided for @settings_interface_performer_layouts_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Media and gallery defaults for performers'**
  String get settings_interface_performer_layouts_subtitle;

  /// No description provided for @settings_interface_studio_layouts.
  ///
  /// In en, this message translates to:
  /// **'Studio Layouts'**
  String get settings_interface_studio_layouts;

  /// No description provided for @settings_interface_studio_layouts_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Media and gallery defaults for studios'**
  String get settings_interface_studio_layouts_subtitle;

  /// No description provided for @settings_interface_tag_layouts.
  ///
  /// In en, this message translates to:
  /// **'Tag Layouts'**
  String get settings_interface_tag_layouts;

  /// No description provided for @settings_interface_tag_layouts_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Media and gallery defaults for tags'**
  String get settings_interface_tag_layouts_subtitle;

  /// No description provided for @settings_interface_media_layout.
  ///
  /// In en, this message translates to:
  /// **'Media Layout'**
  String get settings_interface_media_layout;

  /// No description provided for @settings_interface_media_layout_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Layout for Media page'**
  String get settings_interface_media_layout_subtitle;

  /// No description provided for @settings_interface_galleries_layout_item.
  ///
  /// In en, this message translates to:
  /// **'Galleries Layout'**
  String get settings_interface_galleries_layout_item;

  /// No description provided for @settings_interface_galleries_layout_subtitle_item.
  ///
  /// In en, this message translates to:
  /// **'Layout for Galleries page'**
  String get settings_interface_galleries_layout_subtitle_item;

  /// No description provided for @settings_server_title.
  ///
  /// In en, this message translates to:
  /// **'Server Settings'**
  String get settings_server_title;

  /// No description provided for @settings_server_status.
  ///
  /// In en, this message translates to:
  /// **'Connection Status'**
  String get settings_server_status;

  /// No description provided for @settings_server_status_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Live connectivity against the configured server'**
  String get settings_server_status_subtitle;

  /// No description provided for @settings_server_details.
  ///
  /// In en, this message translates to:
  /// **'Server Details'**
  String get settings_server_details;

  /// No description provided for @settings_server_details_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Configure endpoint and authentication method'**
  String get settings_server_details_subtitle;

  /// No description provided for @settings_server_url.
  ///
  /// In en, this message translates to:
  /// **'GraphQL server URL'**
  String get settings_server_url;

  /// No description provided for @settings_server_url_helper.
  ///
  /// In en, this message translates to:
  /// **'Example format: http(s)://host:port/graphql.'**
  String get settings_server_url_helper;

  /// No description provided for @settings_server_auth_method.
  ///
  /// In en, this message translates to:
  /// **'Authentication Method'**
  String get settings_server_auth_method;

  /// No description provided for @settings_server_auth_apikey.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get settings_server_auth_apikey;

  /// No description provided for @settings_server_auth_password.
  ///
  /// In en, this message translates to:
  /// **'Username + Password'**
  String get settings_server_auth_password;

  /// No description provided for @settings_server_auth_password_desc.
  ///
  /// In en, this message translates to:
  /// **'Recommended: use your Stash username/password session.'**
  String get settings_server_auth_password_desc;

  /// No description provided for @settings_server_auth_apikey_desc.
  ///
  /// In en, this message translates to:
  /// **'Use API key for static-token authentication.'**
  String get settings_server_auth_apikey_desc;

  /// No description provided for @settings_server_username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get settings_server_username;

  /// No description provided for @settings_server_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get settings_server_password;

  /// No description provided for @settings_server_login_test.
  ///
  /// In en, this message translates to:
  /// **'Login & Test'**
  String get settings_server_login_test;

  /// No description provided for @settings_server_test.
  ///
  /// In en, this message translates to:
  /// **'Test Connection'**
  String get settings_server_test;

  /// No description provided for @settings_server_logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get settings_server_logout;

  /// No description provided for @settings_server_clear.
  ///
  /// In en, this message translates to:
  /// **'Clear Settings'**
  String get settings_server_clear;

  /// No description provided for @settings_server_connected.
  ///
  /// In en, this message translates to:
  /// **'Connected (Stash {version})'**
  String settings_server_connected(String version);

  /// No description provided for @settings_server_checking.
  ///
  /// In en, this message translates to:
  /// **'Checking connection...'**
  String get settings_server_checking;

  /// No description provided for @settings_server_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String settings_server_failed(String error);

  /// No description provided for @settings_server_invalid_url.
  ///
  /// In en, this message translates to:
  /// **'Invalid server URL'**
  String get settings_server_invalid_url;

  /// No description provided for @settings_server_resolve_error.
  ///
  /// In en, this message translates to:
  /// **'Could not resolve server URL. Check host, port, and credentials.'**
  String get settings_server_resolve_error;

  /// No description provided for @settings_server_logout_confirm.
  ///
  /// In en, this message translates to:
  /// **'Logged out and cookies cleared.'**
  String get settings_server_logout_confirm;

  /// No description provided for @settings_server_auth_status_logging_in.
  ///
  /// In en, this message translates to:
  /// **'Authentication status: logging in...'**
  String get settings_server_auth_status_logging_in;

  /// No description provided for @settings_server_auth_status_logged_in.
  ///
  /// In en, this message translates to:
  /// **'Authentication status: logged in'**
  String get settings_server_auth_status_logged_in;

  /// No description provided for @settings_server_auth_status_logged_out.
  ///
  /// In en, this message translates to:
  /// **'Authentication status: logged out'**
  String get settings_server_auth_status_logged_out;

  /// No description provided for @settings_playback_title.
  ///
  /// In en, this message translates to:
  /// **'Playback Settings'**
  String get settings_playback_title;

  /// No description provided for @settings_playback_behavior.
  ///
  /// In en, this message translates to:
  /// **'Playback behavior'**
  String get settings_playback_behavior;

  /// No description provided for @settings_playback_behavior_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Default playback and background handling'**
  String get settings_playback_behavior_subtitle;

  /// No description provided for @settings_playback_prefer_streams.
  ///
  /// In en, this message translates to:
  /// **'Prefer sceneStreams first'**
  String get settings_playback_prefer_streams;

  /// No description provided for @settings_playback_prefer_streams_subtitle.
  ///
  /// In en, this message translates to:
  /// **'When off, playback directly uses paths.stream'**
  String get settings_playback_prefer_streams_subtitle;

  /// No description provided for @settings_playback_autoplay.
  ///
  /// In en, this message translates to:
  /// **'Autoplay Next Scene'**
  String get settings_playback_autoplay;

  /// No description provided for @settings_playback_autoplay_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically play the next scene when current playback ends'**
  String get settings_playback_autoplay_subtitle;

  /// No description provided for @settings_playback_background.
  ///
  /// In en, this message translates to:
  /// **'Background Playback'**
  String get settings_playback_background;

  /// No description provided for @settings_playback_background_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep video audio playing when app is backgrounded'**
  String get settings_playback_background_subtitle;

  /// No description provided for @settings_playback_pip.
  ///
  /// In en, this message translates to:
  /// **'Native Picture-in-Picture'**
  String get settings_playback_pip;

  /// No description provided for @settings_playback_pip_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable Android PiP button and auto-enter on background'**
  String get settings_playback_pip_subtitle;

  /// No description provided for @settings_playback_subtitles.
  ///
  /// In en, this message translates to:
  /// **'Subtitle settings'**
  String get settings_playback_subtitles;

  /// No description provided for @settings_playback_subtitles_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatic loading and appearance'**
  String get settings_playback_subtitles_subtitle;

  /// No description provided for @settings_playback_subtitle_lang.
  ///
  /// In en, this message translates to:
  /// **'Default Subtitle Language'**
  String get settings_playback_subtitle_lang;

  /// No description provided for @settings_playback_subtitle_lang_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-load if available'**
  String get settings_playback_subtitle_lang_subtitle;

  /// No description provided for @settings_playback_subtitle_size.
  ///
  /// In en, this message translates to:
  /// **'Subtitle Font Size'**
  String get settings_playback_subtitle_size;

  /// No description provided for @settings_playback_subtitle_pos.
  ///
  /// In en, this message translates to:
  /// **'Subtitle Vertical Position'**
  String get settings_playback_subtitle_pos;

  /// No description provided for @settings_playback_subtitle_pos_desc.
  ///
  /// In en, this message translates to:
  /// **'{percent}% from bottom'**
  String settings_playback_subtitle_pos_desc(String percent);

  /// No description provided for @settings_playback_subtitle_align.
  ///
  /// In en, this message translates to:
  /// **'Subtitle Text Alignment'**
  String get settings_playback_subtitle_align;

  /// No description provided for @settings_playback_subtitle_align_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Alignment for multiline subtitles'**
  String get settings_playback_subtitle_align_subtitle;

  /// No description provided for @settings_playback_seek.
  ///
  /// In en, this message translates to:
  /// **'Seek interaction'**
  String get settings_playback_seek;

  /// No description provided for @settings_playback_seek_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how scrubbing works during playback'**
  String get settings_playback_seek_subtitle;

  /// No description provided for @settings_playback_seek_double_tap.
  ///
  /// In en, this message translates to:
  /// **'Double-tap left/right to seek 10s'**
  String get settings_playback_seek_double_tap;

  /// No description provided for @settings_playback_seek_drag.
  ///
  /// In en, this message translates to:
  /// **'Drag the timeline to seek'**
  String get settings_playback_seek_drag;

  /// No description provided for @settings_playback_seek_drag_label.
  ///
  /// In en, this message translates to:
  /// **'Drag'**
  String get settings_playback_seek_drag_label;

  /// No description provided for @settings_playback_seek_double_tap_label.
  ///
  /// In en, this message translates to:
  /// **'Double-tap'**
  String get settings_playback_seek_double_tap_label;

  /// No description provided for @settings_support_title.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settings_support_title;

  /// No description provided for @settings_support_diagnostics.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics and project info'**
  String get settings_support_diagnostics;

  /// No description provided for @settings_support_diagnostics_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Open runtime logs or jump to the repository when you need help.'**
  String get settings_support_diagnostics_subtitle;

  /// No description provided for @settings_support_update_available.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get settings_support_update_available;

  /// No description provided for @settings_support_update_available_subtitle.
  ///
  /// In en, this message translates to:
  /// **'A newer version is available on GitHub'**
  String get settings_support_update_available_subtitle;

  /// No description provided for @settings_support_update_to.
  ///
  /// In en, this message translates to:
  /// **'Update to {version}'**
  String settings_support_update_to(String version);

  /// No description provided for @settings_support_update_to_subtitle.
  ///
  /// In en, this message translates to:
  /// **'New features and improvements are waiting for you.'**
  String get settings_support_update_to_subtitle;

  /// No description provided for @settings_support_about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settings_support_about;

  /// No description provided for @settings_support_about_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Project and source information'**
  String get settings_support_about_subtitle;

  /// No description provided for @settings_support_version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settings_support_version;

  /// No description provided for @settings_support_version_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading version info...'**
  String get settings_support_version_loading;

  /// No description provided for @settings_support_version_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Version info unavailable'**
  String get settings_support_version_unavailable;

  /// No description provided for @settings_support_github.
  ///
  /// In en, this message translates to:
  /// **'GitHub Repository'**
  String get settings_support_github;

  /// No description provided for @settings_support_github_subtitle.
  ///
  /// In en, this message translates to:
  /// **'View source code and report issues'**
  String get settings_support_github_subtitle;

  /// No description provided for @settings_support_github_error.
  ///
  /// In en, this message translates to:
  /// **'Could not open GitHub link'**
  String get settings_support_github_error;

  /// No description provided for @settings_develop_title.
  ///
  /// In en, this message translates to:
  /// **'Develop'**
  String get settings_develop_title;

  /// No description provided for @settings_develop_diagnostics.
  ///
  /// In en, this message translates to:
  /// **'Diagnostic Tools'**
  String get settings_develop_diagnostics;

  /// No description provided for @settings_develop_diagnostics_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Troubleshooting and performance'**
  String get settings_develop_diagnostics_subtitle;

  /// No description provided for @settings_develop_video_debug.
  ///
  /// In en, this message translates to:
  /// **'Show Video Debug Info'**
  String get settings_develop_video_debug;

  /// No description provided for @settings_develop_video_debug_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Display technical playback details as an overlay on the video player.'**
  String get settings_develop_video_debug_subtitle;

  /// No description provided for @settings_develop_log_viewer.
  ///
  /// In en, this message translates to:
  /// **'Debug Log Viewer'**
  String get settings_develop_log_viewer;

  /// No description provided for @settings_develop_log_viewer_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Open a live view of in-app logs.'**
  String get settings_develop_log_viewer_subtitle;

  /// No description provided for @settings_develop_logs_copied.
  ///
  /// In en, this message translates to:
  /// **'Logs copied to clipboard'**
  String get settings_develop_logs_copied;

  /// No description provided for @settings_develop_no_logs.
  ///
  /// In en, this message translates to:
  /// **'No logs yet. Interact with the app to capture logs.'**
  String get settings_develop_no_logs;

  /// No description provided for @settings_develop_web_overrides.
  ///
  /// In en, this message translates to:
  /// **'Web Overrides'**
  String get settings_develop_web_overrides;

  /// No description provided for @settings_develop_web_overrides_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Advanced flags for web platform'**
  String get settings_develop_web_overrides_subtitle;

  /// No description provided for @settings_develop_web_auth.
  ///
  /// In en, this message translates to:
  /// **'Allow Password Login on Web'**
  String get settings_develop_web_auth;

  /// No description provided for @settings_develop_web_auth_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Overrides the native-only restriction and forces the Username + Password auth method to be visible on Flutter Web.'**
  String get settings_develop_web_auth_subtitle;

  /// No description provided for @common_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get common_edit;

  /// No description provided for @common_resolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get common_resolution;

  /// No description provided for @common_orientation.
  ///
  /// In en, this message translates to:
  /// **'Orientation'**
  String get common_orientation;

  /// No description provided for @common_landscape.
  ///
  /// In en, this message translates to:
  /// **'Landscape'**
  String get common_landscape;

  /// No description provided for @common_portrait.
  ///
  /// In en, this message translates to:
  /// **'Portrait'**
  String get common_portrait;

  /// No description provided for @common_square.
  ///
  /// In en, this message translates to:
  /// **'Square'**
  String get common_square;

  /// No description provided for @performers_filter_saved.
  ///
  /// In en, this message translates to:
  /// **'Filter preferences saved as default'**
  String get performers_filter_saved;

  /// No description provided for @images_title.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images_title;

  /// No description provided for @images_sort_title.
  ///
  /// In en, this message translates to:
  /// **'Sort Images'**
  String get images_sort_title;

  /// No description provided for @images_sort_saved.
  ///
  /// In en, this message translates to:
  /// **'Sort preferences saved as default'**
  String get images_sort_saved;

  /// No description provided for @image_rating_updated.
  ///
  /// In en, this message translates to:
  /// **'Image rating updated.'**
  String get image_rating_updated;

  /// No description provided for @gallery_rating_updated.
  ///
  /// In en, this message translates to:
  /// **'Gallery rating updated.'**
  String get gallery_rating_updated;

  /// No description provided for @common_image.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get common_image;

  /// No description provided for @common_gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get common_gallery;

  /// No description provided for @images_gallery_rating_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Gallery rating is only available when browsing a gallery.'**
  String get images_gallery_rating_unavailable;

  /// No description provided for @images_rating.
  ///
  /// In en, this message translates to:
  /// **'Rating: {rating} / 5'**
  String images_rating(String rating);

  /// No description provided for @images_filtered_by_gallery.
  ///
  /// In en, this message translates to:
  /// **'Filtered by Gallery'**
  String get images_filtered_by_gallery;

  /// No description provided for @images_slideshow_need_two.
  ///
  /// In en, this message translates to:
  /// **'Need at least 2 images for slideshow.'**
  String get images_slideshow_need_two;

  /// No description provided for @images_slideshow_start_title.
  ///
  /// In en, this message translates to:
  /// **'Start Slideshow'**
  String get images_slideshow_start_title;

  /// No description provided for @images_slideshow_interval.
  ///
  /// In en, this message translates to:
  /// **'Interval: {seconds}s'**
  String images_slideshow_interval(num seconds);

  /// No description provided for @images_slideshow_transition_ms.
  ///
  /// In en, this message translates to:
  /// **'Transition: {ms}ms'**
  String images_slideshow_transition_ms(num ms);

  /// No description provided for @common_forward.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get common_forward;

  /// No description provided for @common_backward.
  ///
  /// In en, this message translates to:
  /// **'Backward'**
  String get common_backward;

  /// No description provided for @images_slideshow_loop_title.
  ///
  /// In en, this message translates to:
  /// **'Loop slideshow'**
  String get images_slideshow_loop_title;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @common_start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get common_start;

  /// No description provided for @common_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get common_done;
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
