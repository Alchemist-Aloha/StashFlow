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
  String get common_token => 'Token';

  @override
  String get filter_value => 'Value';

  @override
  String get common_yes => 'Yes';

  @override
  String get common_no => 'No';

  @override
  String get common_clear_history => 'Clear History';

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
  String nPlays(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString plays',
      one: '1 play',
      zero: 'no plays',
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
  String get common_default => 'Default';

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
  String get common_show => 'Show';

  @override
  String get common_hide => 'Hide';

  @override
  String get galleries_filter_saved => 'Filter preferences saved as default';

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
  String get sort_file_mod_time => 'File Mod Time';

  @override
  String get sort_filesize => 'Filesize';

  @override
  String get sort_o_count => 'O-Counter';

  @override
  String get sort_height => 'Height';

  @override
  String get sort_birthdate => 'Birthdate';

  @override
  String get sort_tag_count => 'Tag Count';

  @override
  String get sort_play_count => 'Play Count';

  @override
  String get sort_o_counter => 'O-Counter';

  @override
  String get sort_zip_file_count => 'Zip File Count';

  @override
  String get sort_last_o_at => 'Last O At';

  @override
  String get sort_latest_scene => 'Latest Scene';

  @override
  String get sort_career_start => 'Career Start';

  @override
  String get sort_career_end => 'Career End';

  @override
  String get sort_weight => 'Weight';

  @override
  String get sort_measurements => 'Measurements';

  @override
  String get sort_scenes_duration => 'Scenes Duration';

  @override
  String get sort_scenes_size => 'Scenes Size';

  @override
  String get sort_images_count => 'Image Count';

  @override
  String get sort_galleries_count => 'Gallery Count';

  @override
  String get sort_child_count => 'Sub-studio Count';

  @override
  String get sort_performers_count => 'Performer Count';

  @override
  String get sort_groups_count => 'Group Count';

  @override
  String get sort_marker_count => 'Marker Count';

  @override
  String get sort_studios_count => 'Studio Count';

  @override
  String get sort_penis_length => 'Penis Length';

  @override
  String get sort_last_played_at => 'Last Played At';

  @override
  String get studios_sort_saved => 'Sort preferences saved as default';

  @override
  String get studios_no_random => 'No studios available for random navigation';

  @override
  String get tags_filter_title => 'Filter Tags';

  @override
  String get tags_filter_saved => 'Filter preferences saved as default';

  @override
  String get tags_sort_title => 'Sort Tags';

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

  @override
  String get common_no_media_available => 'No media available';

  @override
  String common_id(Object id) {
    return 'ID: $id';
  }

  @override
  String get common_search_placeholder => 'Search...';

  @override
  String get common_pause => 'Pause';

  @override
  String get common_play => 'Play';

  @override
  String get common_close => 'Close';

  @override
  String get common_save => 'Save';

  @override
  String get common_unmute => 'Unmute';

  @override
  String get common_mute => 'Mute';

  @override
  String get common_back => 'Back';

  @override
  String get common_rate => 'Rate';

  @override
  String get common_previous => 'Previous';

  @override
  String get common_next => 'Next';

  @override
  String get common_favorite => 'Favorite';

  @override
  String get common_unfavorite => 'Unfavorite';

  @override
  String get common_version => 'Version';

  @override
  String get common_loading => 'Loading...';

  @override
  String get common_unavailable => 'Unavailable';

  @override
  String get common_details => 'Details';

  @override
  String get common_title => 'Title';

  @override
  String get common_release_date => 'Release Date';

  @override
  String get common_url => 'URL';

  @override
  String get common_no_url => 'No URL';

  @override
  String get common_sort => 'Sort';

  @override
  String get common_filter => 'Filter';

  @override
  String get common_search => 'Search';

  @override
  String get common_settings => 'Settings';

  @override
  String get common_reset_to_1x => 'Reset to 1x';

  @override
  String get common_skip_next => 'Skip Next';

  @override
  String get common_select_subtitle => 'Select subtitle';

  @override
  String get common_playback_speed => 'Playback speed';

  @override
  String get common_pip => 'Picture-in-Picture';

  @override
  String get common_toggle_fullscreen => 'Toggle Fullscreen';

  @override
  String get common_exit_fullscreen => 'Exit Fullscreen';

  @override
  String get common_copy_logs => 'Copy all logs';

  @override
  String get common_clear_logs => 'Clear logs';

  @override
  String get common_enable_autoscroll => 'Enable auto-scroll';

  @override
  String get common_disable_autoscroll => 'Disable auto-scroll';

  @override
  String get common_retry => 'Retry';

  @override
  String get common_no_items => 'No items found';

  @override
  String get common_none => 'None';

  @override
  String get common_any => 'Any';

  @override
  String get common_name => 'Name';

  @override
  String get common_date => 'Date';

  @override
  String get common_rating => 'Rating';

  @override
  String get common_image_count => 'Image Count';

  @override
  String get common_filepath => 'Filepath';

  @override
  String get common_random => 'Random';

  @override
  String get common_no_media_found => 'No media found';

  @override
  String common_not_found(String item) {
    return '$item not found';
  }

  @override
  String get common_add_favorite => 'Add favorite';

  @override
  String get common_remove_favorite => 'Remove favorite';

  @override
  String get details_group => 'Group Details';

  @override
  String get details_synopsis => 'Synopsis';

  @override
  String get details_media => 'Media';

  @override
  String get details_galleries => 'Galleries';

  @override
  String get details_tags => 'Tags';

  @override
  String get details_links => 'Links';

  @override
  String get details_scene_scrape => 'Scrape metadata';

  @override
  String get details_show_more => 'Show more';

  @override
  String get details_show_less => 'Show less';

  @override
  String get details_more_from_studio => 'More From Studio';

  @override
  String get details_o_count_incremented => 'O count incremented';

  @override
  String details_failed_update_rating(String error) {
    return 'Failed to update rating: $error';
  }

  @override
  String details_failed_update_performer(Object error) {
    return 'Failed to update performer: $error';
  }

  @override
  String details_failed_increment_o_count(String error) {
    return 'Failed to increment O count: $error';
  }

  @override
  String get details_scene_add_performer => 'Add Performer';

  @override
  String get details_scene_add_tag => 'Add Tag';

  @override
  String get details_scene_add_url => 'Add URL';

  @override
  String get details_scene_remove_url => 'Remove URL';

  @override
  String get groups_title => 'Groups';

  @override
  String get groups_unnamed => 'Unnamed group';

  @override
  String get groups_untitled => 'Untitled group';

  @override
  String get studios_title => 'Studios';

  @override
  String get studios_galleries_title => 'Studio Galleries';

  @override
  String get studios_media_title => 'Studio Media';

  @override
  String get studios_sort_title => 'Sort Studios';

  @override
  String get galleries_title => 'Galleries';

  @override
  String get galleries_sort_title => 'Sort Galleries';

  @override
  String get galleries_all_images => 'All Images';

  @override
  String get galleries_filter_title => 'Filter Galleries';

  @override
  String get galleries_min_rating => 'Minimum Rating';

  @override
  String get galleries_image_count => 'Image Count';

  @override
  String get galleries_organization => 'Organization';

  @override
  String get galleries_organized_only => 'Organized only';

  @override
  String get scenes_filter_title => 'Filter Scenes';

  @override
  String get scenes_filter_saved => 'Filter preferences saved as default';

  @override
  String get scenes_watched => 'Watched';

  @override
  String get scenes_unwatched => 'Unwatched';

  @override
  String get scenes_search_hint => 'Search scenes...';

  @override
  String get scenes_sort_header => 'Sort Scenes';

  @override
  String get scenes_sort_duration => 'Duration';

  @override
  String get scenes_sort_bitrate => 'Bitrate';

  @override
  String get scenes_sort_framerate => 'Framerate';

  @override
  String get scenes_sort_saved_default => 'Sort preferences saved as default';

  @override
  String get scenes_sort_tooltip => 'Sort options';

  @override
  String get tags_search_hint => 'Search tags...';

  @override
  String get tags_sort_tooltip => 'Sort options';

  @override
  String get tags_filter_tooltip => 'Filter options';

  @override
  String get performers_title => 'Performers';

  @override
  String get performers_sort_title => 'Sort Performers';

  @override
  String get performers_filter_title => 'Filter Performers';

  @override
  String get performers_galleries_title => 'All Performer Galleries';

  @override
  String get performers_media_title => 'All Performer Media';

  @override
  String get performers_gender => 'Gender';

  @override
  String get performers_gender_any => 'Any';

  @override
  String get performers_gender_female => 'Female';

  @override
  String get performers_gender_male => 'Male';

  @override
  String get performers_gender_trans_female => 'Trans Female';

  @override
  String get performers_gender_trans_male => 'Trans Male';

  @override
  String get performers_gender_intersex => 'Intersex';

  @override
  String get performers_gender_non_binary => 'Non Binary';

  @override
  String get performers_circumcised => 'Circumcised';

  @override
  String get performers_circumcised_cut => 'Cut';

  @override
  String get performers_circumcised_uncut => 'Uncut';

  @override
  String get performers_play_count => 'Play Count';

  @override
  String get performers_field_disambiguation => 'Disambiguation';

  @override
  String get performers_field_birthdate => 'Birthdate';

  @override
  String get performers_field_deathdate => 'Death Date';

  @override
  String get performers_field_height_cm => 'Height (cm)';

  @override
  String get performers_field_weight_kg => 'Weight (kg)';

  @override
  String get performers_field_measurements => 'Measurements';

  @override
  String get performers_field_fake_tits => 'Fake Tits';

  @override
  String get performers_field_penis_length => 'Penis Length';

  @override
  String get performers_field_ethnicity => 'Ethnicity';

  @override
  String get performers_field_country => 'Country';

  @override
  String get performers_field_eye_color => 'Eye Color';

  @override
  String get performers_field_hair_color => 'Hair Color';

  @override
  String get performers_field_career_start => 'Career Start';

  @override
  String get performers_field_career_end => 'Career End';

  @override
  String get performers_field_tattoos => 'Tattoos';

  @override
  String get performers_field_piercings => 'Piercings';

  @override
  String get performers_field_aliases => 'Aliases';

  @override
  String get common_organized => 'Organized';

  @override
  String get scenes_duplicated => 'Duplicated';

  @override
  String get random_studio => 'Random studio';

  @override
  String get random_gallery => 'Random gallery';

  @override
  String get random_tag => 'Random tag';

  @override
  String get random_scene => 'Random scene';

  @override
  String get random_performer => 'Random performer';

  @override
  String get filter_modifier => 'Modifier';

  @override
  String get filter_equals => 'Equals';

  @override
  String get filter_not_equals => 'Not Equals';

  @override
  String get filter_greater_than => 'Greater Than';

  @override
  String get filter_less_than => 'Less Than';

  @override
  String get filter_is_null => 'Is Null';

  @override
  String get filter_not_null => 'Not Null';

  @override
  String get images_resolution_title => 'Resolution';

  @override
  String get resolution_144p => '144p';

  @override
  String get resolution_240p => '240p';

  @override
  String get resolution_360p => '360p';

  @override
  String get resolution_480p => '480p';

  @override
  String get resolution_540p => '540p';

  @override
  String get resolution_720p => '720p';

  @override
  String get resolution_1080p => '1080p';

  @override
  String get resolution_1440p => '1440p';

  @override
  String get resolution_1920p => '1920p';

  @override
  String get resolution_2160p => '4K (2160p)';

  @override
  String get resolution_4320p => '8K (4320p)';

  @override
  String get images_orientation_title => 'Orientation';

  @override
  String get common_or => 'OR';

  @override
  String get scrape_from_url => 'Scrape from URL';

  @override
  String get scenes_phash_started => 'Phash generation started';

  @override
  String scenes_phash_failed(Object error) {
    return 'Failed to generate phash: $error';
  }

  @override
  String details_failed_update_studio(Object error) {
    return 'Failed to update studio: $error';
  }

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_customize => 'Customize StashFlow';

  @override
  String get settings_customize_subtitle =>
      'Tune playback, appearance, layout, and support tools from one place.';

  @override
  String get settings_core_section => 'Core settings';

  @override
  String get settings_core_subtitle => 'Most-used configuration pages';

  @override
  String get settings_server => 'Server';

  @override
  String get settings_server_subtitle => 'Connection and API configuration';

  @override
  String get settings_playback => 'Playback';

  @override
  String get settings_playback_subtitle => 'Player behavior and interactions';

  @override
  String get settings_keyboard => 'Keyboard';

  @override
  String get settings_keyboard_subtitle => 'Customizable shortcuts and hotkeys';

  @override
  String get settings_keyboard_title => 'Keyboard Shortcuts';

  @override
  String get settings_keyboard_reset_defaults => 'Reset to Defaults';

  @override
  String get settings_keyboard_not_bound => 'Not bound';

  @override
  String get settings_keyboard_volume_up => 'Volume Up';

  @override
  String get settings_keyboard_volume_down => 'Volume Down';

  @override
  String get settings_keyboard_toggle_mute => 'Toggle Mute';

  @override
  String get settings_keyboard_toggle_fullscreen => 'Toggle Fullscreen';

  @override
  String get settings_keyboard_next_scene => 'Next Scene';

  @override
  String get settings_keyboard_prev_scene => 'Previous Scene';

  @override
  String get settings_keyboard_increase_speed => 'Increase Playback Speed';

  @override
  String get settings_keyboard_decrease_speed => 'Decrease Playback Speed';

  @override
  String get settings_keyboard_reset_speed => 'Reset Playback Speed';

  @override
  String get settings_keyboard_close_player => 'Close Player';

  @override
  String get settings_keyboard_next_image => 'Next Image';

  @override
  String get settings_keyboard_prev_image => 'Previous Image';

  @override
  String get settings_keyboard_go_back => 'Go Back';

  @override
  String get settings_keyboard_play_pause_desc =>
      'Toggle between playing and pausing video';

  @override
  String get settings_keyboard_seek_forward_5_desc =>
      'Jump forward by 5 seconds';

  @override
  String get settings_keyboard_seek_backward_5_desc =>
      'Jump backward by 5 seconds';

  @override
  String get settings_keyboard_seek_forward_10_desc =>
      'Jump forward by 10 seconds';

  @override
  String get settings_keyboard_seek_backward_10_desc =>
      'Jump backward by 10 seconds';

  @override
  String get settings_appearance => 'Appearance';

  @override
  String get settings_appearance_subtitle => 'Theme and colors';

  @override
  String get settings_interface => 'Interface';

  @override
  String get settings_interface_subtitle => 'Navigation and layout defaults';

  @override
  String get settings_support => 'Support';

  @override
  String get settings_support_subtitle => 'Diagnostics and about';

  @override
  String get settings_develop => 'Develop';

  @override
  String get settings_develop_subtitle => 'Advanced tools and overrides';

  @override
  String get settings_appearance_title => 'Appearance Settings';

  @override
  String get settings_appearance_theme_mode => 'Theme Mode';

  @override
  String get settings_appearance_theme_mode_subtitle =>
      'Choose how the app follows brightness changes';

  @override
  String get settings_appearance_theme_system => 'System';

  @override
  String get settings_appearance_theme_light => 'Light';

  @override
  String get settings_appearance_theme_dark => 'Dark';

  @override
  String get settings_appearance_primary_color => 'Primary Color';

  @override
  String get settings_appearance_primary_color_subtitle =>
      'Pick a seed color for the Material 3 palette';

  @override
  String get settings_appearance_advanced_theming => 'Advanced Theming';

  @override
  String get settings_appearance_advanced_theming_subtitle =>
      'Optimizations for specific screen types';

  @override
  String get settings_appearance_true_black => 'True Black (AMOLED)';

  @override
  String get settings_appearance_true_black_subtitle =>
      'Use pure black backgrounds in dark mode to save battery on OLED screens';

  @override
  String get settings_appearance_custom_hex => 'Custom Hex Color';

  @override
  String get settings_appearance_custom_hex_helper =>
      'Enter an 8-digit ARGB hex code';

  @override
  String get settings_appearance_font_size => 'Global UI Scale';

  @override
  String get settings_appearance_font_size_subtitle =>
      'Scale typography and spacing proportionally';

  @override
  String get settings_interface_title => 'Interface Settings';

  @override
  String get settings_interface_language => 'Language';

  @override
  String get settings_interface_language_subtitle =>
      'Overwrite the default system language';

  @override
  String get settings_interface_app_language => 'App Language';

  @override
  String get settings_interface_navigation => 'Navigation';

  @override
  String get settings_interface_navigation_subtitle =>
      'Visibility of global navigation shortcuts';

  @override
  String get settings_interface_show_random => 'Show Random Navigation Buttons';

  @override
  String get settings_interface_show_random_subtitle =>
      'Enable or disable the floating casino buttons across list and details pages';

  @override
  String get settings_interface_main_pages_gravity_orientation =>
      'Gravity-controlled orientation (main pages)';

  @override
  String get settings_interface_main_pages_gravity_orientation_subtitle =>
      'Allow main pages to rotate using the device sensor. Fullscreen video playback follows its own orientation settings.';

  @override
  String get settings_interface_show_edit => 'Show Edit Button';

  @override
  String get settings_interface_show_edit_subtitle =>
      'Enable or disable the edit button on the scene details page';

  @override
  String get settings_interface_customize_tabs => 'Customize Tabs';

  @override
  String get settings_interface_customize_tabs_subtitle =>
      'Reorder or hide navigation menu items';

  @override
  String get settings_interface_scenes_layout => 'Scenes Layout';

  @override
  String get settings_interface_scenes_layout_subtitle =>
      'Default browsing mode for scenes';

  @override
  String get settings_interface_galleries_layout => 'Galleries Layout';

  @override
  String get settings_interface_galleries_layout_subtitle =>
      'Default browsing mode for galleries';

  @override
  String get settings_interface_max_performer_avatars =>
      'Max Performer Avatars';

  @override
  String get settings_interface_max_performer_avatars_subtitle =>
      'Maximum number of performer avatars to show in the scene card.';

  @override
  String get settings_interface_show_performer_avatars =>
      'Show Performer Avatars';

  @override
  String get settings_interface_show_performer_avatars_subtitle =>
      'Display performer icons on scene cards across all platforms.';

  @override
  String get settings_interface_performer_avatar_size =>
      'Performer Avatar Size';

  @override
  String get settings_interface_layout_default => 'Default Layout';

  @override
  String get settings_interface_layout_default_desc =>
      'Choose the default layout for the page';

  @override
  String get settings_interface_layout_list => 'List';

  @override
  String get settings_interface_layout_grid => 'Grid';

  @override
  String get settings_interface_layout_tiktok => 'Feed';

  @override
  String get settings_interface_grid_columns => 'Grid Columns';

  @override
  String get settings_interface_image_viewer => 'Image Viewer';

  @override
  String get settings_interface_image_viewer_subtitle =>
      'Configure fullscreen image browsing behavior';

  @override
  String get settings_interface_swipe_direction => 'Fullscreen Swipe Direction';

  @override
  String get settings_interface_swipe_direction_desc =>
      'Choose how images advance in fullscreen mode';

  @override
  String get settings_interface_swipe_vertical => 'Vertical';

  @override
  String get settings_interface_swipe_horizontal => 'Horizontal';

  @override
  String get settings_interface_waterfall_columns => 'Waterfall Grid Columns';

  @override
  String get settings_interface_performer_layouts => 'Performer Layouts';

  @override
  String get settings_interface_performer_layouts_subtitle =>
      'Media and gallery defaults for performers';

  @override
  String get settings_interface_studio_layouts => 'Studio Layouts';

  @override
  String get settings_interface_studio_layouts_subtitle =>
      'Media and gallery defaults for studios';

  @override
  String get settings_interface_tag_layouts => 'Tag Layouts';

  @override
  String get settings_interface_tag_layouts_subtitle =>
      'Media and gallery defaults for tags';

  @override
  String get settings_interface_media_layout => 'Media Layout';

  @override
  String get settings_interface_media_layout_subtitle =>
      'Layout for Media page';

  @override
  String get settings_interface_galleries_layout_item => 'Galleries Layout';

  @override
  String get settings_interface_galleries_layout_subtitle_item =>
      'Layout for Galleries page';

  @override
  String get settings_server_title => 'Server Settings';

  @override
  String get settings_server_status => 'Connection Status';

  @override
  String get settings_server_status_subtitle =>
      'Live connectivity against the configured server';

  @override
  String get settings_server_details => 'Server Details';

  @override
  String get settings_server_details_subtitle =>
      'Configure endpoint and authentication method';

  @override
  String get settings_server_url => 'Stash URL';

  @override
  String get settings_server_url_helper =>
      'Enter the URL of your Stash server. If configured with a custom path, include it here.';

  @override
  String get settings_server_url_example => 'http://192.168.1.100:9999';

  @override
  String get settings_server_login_failed => 'Login failed';

  @override
  String get settings_server_auth_method => 'Authentication Method';

  @override
  String get settings_server_auth_apikey => 'API Key';

  @override
  String get settings_server_auth_password => 'Username + Password';

  @override
  String get settings_server_auth_password_desc =>
      'Recommended: use your Stash username/password session.';

  @override
  String get settings_server_auth_apikey_desc =>
      'Use API key for static-token authentication.';

  @override
  String get settings_server_username => 'Username';

  @override
  String get settings_server_password => 'Password';

  @override
  String get settings_server_login_test => 'Login & Test';

  @override
  String get settings_server_test => 'Test Connection';

  @override
  String get settings_server_logout => 'Logout';

  @override
  String get settings_server_clear => 'Clear Settings';

  @override
  String settings_server_connected(String version) {
    return 'Connected (Stash $version)';
  }

  @override
  String get settings_server_checking => 'Checking connection...';

  @override
  String settings_server_failed(String error) {
    return 'Failed: $error';
  }

  @override
  String get settings_server_invalid_url => 'Invalid server URL';

  @override
  String get settings_server_resolve_error =>
      'Could not resolve server URL. Check host, port, and credentials.';

  @override
  String get settings_server_logout_confirm =>
      'Logged out and cookies cleared.';

  @override
  String get settings_server_profile_add => 'Add Profile';

  @override
  String get settings_server_profile_edit => 'Edit Profile';

  @override
  String get settings_server_profile_name => 'Profile Name';

  @override
  String get settings_server_profile_delete => 'Delete Profile';

  @override
  String get settings_server_profile_delete_confirm =>
      'Are you sure you want to delete this profile? This action cannot be undone.';

  @override
  String get settings_server_profile_active => 'Active';

  @override
  String get settings_server_profile_empty => 'No server profiles configured';

  @override
  String get settings_server_profiles => 'Server Profiles';

  @override
  String get settings_server_profiles_subtitle =>
      'Manage multiple Stash server connections';

  @override
  String get settings_server_auth_status_logging_in =>
      'Authentication status: logging in...';

  @override
  String get settings_server_auth_status_logged_in =>
      'Authentication status: logged in';

  @override
  String get settings_server_auth_status_logged_out =>
      'Authentication status: logged out';

  @override
  String get settings_playback_title => 'Playback Settings';

  @override
  String get settings_playback_behavior => 'Playback behavior';

  @override
  String get settings_playback_behavior_subtitle =>
      'Default playback and background handling';

  @override
  String get settings_playback_prefer_streams => 'Prefer sceneStreams first';

  @override
  String get settings_playback_prefer_streams_subtitle =>
      'When off, playback directly uses paths.stream';

  @override
  String get settings_playback_end_behavior => 'Play End Behavior';

  @override
  String get settings_playback_end_behavior_subtitle =>
      'What to do when current playback ends';

  @override
  String get settings_playback_end_behavior_stop => 'Stop';

  @override
  String get settings_playback_end_behavior_loop => 'Loop current scene';

  @override
  String get settings_playback_end_behavior_next => 'Play next scene';

  @override
  String get settings_playback_autoplay => 'Autoplay Next Scene';

  @override
  String get settings_playback_autoplay_subtitle =>
      'Automatically play the next scene when current playback ends';

  @override
  String get settings_playback_background => 'Background Playback';

  @override
  String get settings_playback_background_subtitle =>
      'Keep video audio playing when app is backgrounded';

  @override
  String get settings_playback_pip => 'Native Picture-in-Picture';

  @override
  String get settings_playback_pip_subtitle =>
      'Enable Android PiP button and auto-enter on background';

  @override
  String get settings_playback_subtitles => 'Subtitle settings';

  @override
  String get settings_playback_subtitles_subtitle =>
      'Automatic loading and appearance';

  @override
  String get settings_playback_subtitle_lang => 'Default Subtitle Language';

  @override
  String get settings_playback_subtitle_lang_subtitle =>
      'Auto-load if available';

  @override
  String get settings_playback_subtitle_size => 'Subtitle Font Size';

  @override
  String get settings_playback_subtitle_pos => 'Subtitle Vertical Position';

  @override
  String settings_playback_subtitle_pos_desc(String percent) {
    return '$percent% from bottom';
  }

  @override
  String get settings_playback_subtitle_align => 'Subtitle Text Alignment';

  @override
  String get settings_playback_subtitle_align_subtitle =>
      'Alignment for multiline subtitles';

  @override
  String get settings_playback_seek => 'Seek interaction';

  @override
  String get settings_playback_seek_subtitle =>
      'Choose how scrubbing works during playback';

  @override
  String get settings_playback_seek_double_tap =>
      'Double-tap left/right to seek 10s';

  @override
  String get settings_playback_seek_drag => 'Drag the timeline to seek';

  @override
  String get settings_playback_seek_drag_label => 'Drag';

  @override
  String get settings_playback_seek_double_tap_label => 'Double-tap';

  @override
  String get settings_playback_gravity_orientation =>
      'Gravity-controlled orientation';

  @override
  String get settings_playback_gravity_orientation_subtitle =>
      'Allow rotating between matching orientations using the device sensor (e.g. flipping landscape left/right).';

  @override
  String get settings_playback_subtitle_lang_none_disabled => 'None (Disabled)';

  @override
  String get settings_playback_subtitle_lang_auto_if_only_one =>
      'Auto (If only one)';

  @override
  String get settings_playback_subtitle_lang_english => 'English';

  @override
  String get settings_playback_subtitle_lang_chinese => 'Chinese';

  @override
  String get settings_playback_subtitle_lang_german => 'German';

  @override
  String get settings_playback_subtitle_lang_french => 'French';

  @override
  String get settings_playback_subtitle_lang_spanish => 'Spanish';

  @override
  String get settings_playback_subtitle_lang_italian => 'Italian';

  @override
  String get settings_playback_subtitle_lang_japanese => 'Japanese';

  @override
  String get settings_playback_subtitle_lang_korean => 'Korean';

  @override
  String get settings_playback_subtitle_align_left => 'Left';

  @override
  String get settings_playback_subtitle_align_center => 'Center';

  @override
  String get settings_playback_subtitle_align_right => 'Right';

  @override
  String get settings_support_title => 'Support';

  @override
  String get settings_support_diagnostics => 'Diagnostics and project info';

  @override
  String get settings_support_diagnostics_subtitle =>
      'Open runtime logs or jump to the repository when you need help.';

  @override
  String get settings_support_update_available => 'Update Available';

  @override
  String get settings_support_update_available_subtitle =>
      'A newer version is available on GitHub';

  @override
  String settings_support_update_to(String version) {
    return 'Update to $version';
  }

  @override
  String get settings_support_update_to_subtitle =>
      'New features and improvements are waiting for you.';

  @override
  String get settings_support_about => 'About';

  @override
  String get settings_support_about_subtitle =>
      'Project and source information';

  @override
  String get settings_support_version => 'Version';

  @override
  String get settings_support_version_loading => 'Loading version info...';

  @override
  String get settings_support_version_unavailable => 'Version info unavailable';

  @override
  String get settings_support_github => 'GitHub Repository';

  @override
  String get settings_support_github_subtitle => 'View source code';

  @override
  String get settings_support_github_error => 'Could not open GitHub link';

  @override
  String get settings_support_issues => 'Report an Issue';

  @override
  String get settings_support_issues_subtitle =>
      'Help improve StashFlow by reporting bugs';

  @override
  String get settings_develop_title => 'Develop';

  @override
  String get settings_develop_diagnostics => 'Diagnostic Tools';

  @override
  String get settings_develop_diagnostics_subtitle =>
      'Troubleshooting and performance';

  @override
  String get settings_develop_video_debug => 'Show Video Debug Info';

  @override
  String get settings_develop_video_debug_subtitle =>
      'Display technical playback details as an overlay on the video player.';

  @override
  String get settings_develop_log_viewer => 'Debug Log Viewer';

  @override
  String get settings_develop_log_viewer_subtitle =>
      'Open a live view of in-app logs.';

  @override
  String get settings_develop_logs_copied => 'Logs copied to clipboard';

  @override
  String get settings_develop_no_logs =>
      'No logs yet. Interact with the app to capture logs.';

  @override
  String get settings_develop_web_overrides => 'Web Overrides';

  @override
  String get settings_develop_web_overrides_subtitle =>
      'Advanced flags for web platform';

  @override
  String get settings_develop_web_auth => 'Allow Password Login on Web';

  @override
  String get settings_develop_web_auth_subtitle =>
      'Overrides the native-only restriction and forces the Username + Password auth method to be visible on Flutter Web.';

  @override
  String get settings_develop_proxy_auth => 'Enable Proxy Auth Modes';

  @override
  String get settings_develop_proxy_auth_subtitle =>
      'Enable advanced Basic Auth and Bearer Token methods for use with auth-free backends behind proxies like Authentik.';

  @override
  String get settings_server_auth_basic => 'Basic Auth';

  @override
  String get settings_server_auth_bearer => 'Bearer Token';

  @override
  String get settings_server_auth_basic_desc =>
      'Sends \'Authorization: Basic <base64(user:pass)>\' header.';

  @override
  String get settings_server_auth_bearer_desc =>
      'Sends \'Authorization: Bearer <token>\' header.';

  @override
  String get common_edit => 'Edit';

  @override
  String get common_resolution => 'Resolution';

  @override
  String get common_orientation => 'Orientation';

  @override
  String get common_landscape => 'Landscape';

  @override
  String get common_portrait => 'Portrait';

  @override
  String get common_square => 'Square';

  @override
  String get performers_filter_saved => 'Filter preferences saved as default';

  @override
  String get images_title => 'Images';

  @override
  String get images_filter_title => 'Filter Images';

  @override
  String get images_filter_saved => 'Filter preferences saved as default';

  @override
  String get images_sort_title => 'Sort Images';

  @override
  String get images_sort_saved => 'Sort preferences saved as default';

  @override
  String get image_rating_updated => 'Image rating updated.';

  @override
  String get gallery_rating_updated => 'Gallery rating updated.';

  @override
  String get common_image => 'Image';

  @override
  String get common_gallery => 'Gallery';

  @override
  String get images_gallery_rating_unavailable =>
      'Gallery rating is only available when browsing a gallery.';

  @override
  String images_rating(String rating) {
    return 'Rating: $rating / 5';
  }

  @override
  String get images_filtered_by_gallery => 'Filtered by Gallery';

  @override
  String get images_slideshow_need_two =>
      'Need at least 2 images for slideshow.';

  @override
  String get images_slideshow_start_title => 'Start Slideshow';

  @override
  String images_slideshow_interval(num seconds) {
    return 'Interval: ${seconds}s';
  }

  @override
  String images_slideshow_transition_ms(num ms) {
    return 'Transition: ${ms}ms';
  }

  @override
  String get common_forward => 'Forward';

  @override
  String get common_backward => 'Backward';

  @override
  String get images_slideshow_loop_title => 'Loop slideshow';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_start => 'Start';

  @override
  String get common_done => 'Done';

  @override
  String get settings_keybind_assign_shortcut => 'Assign Shortcut';

  @override
  String get settings_keybind_press_any => 'Press any key combination...';

  @override
  String get scenes_select_tags => 'Select Tags';

  @override
  String get scenes_no_scrapers => 'No scrapers available';

  @override
  String get scenes_select_scraper => 'Select Scraper';

  @override
  String get scenes_no_results_found => 'No results found';

  @override
  String get scenes_select_result => 'Select Result';

  @override
  String scenes_scrape_failed(String error) {
    return 'Scrape failed: $error';
  }

  @override
  String get scenes_updated_successfully => 'Scene updated successfully';

  @override
  String scenes_update_failed(String error) {
    return 'Failed to update scene: $error';
  }

  @override
  String get scenes_edit_title => 'Edit Scene';

  @override
  String get scenes_field_studio => 'Studio';

  @override
  String get scenes_field_tags => 'Tags';

  @override
  String get scenes_field_urls => 'URLs';

  @override
  String get scenes_edit_performer => 'Edit Performer';

  @override
  String get scenes_edit_studio => 'Edit Studio';

  @override
  String get common_no_title => 'No title';

  @override
  String get scenes_select_studio => 'Select Studio';

  @override
  String get scenes_select_performers => 'Select Performers';

  @override
  String get scenes_unmatched_scraped_tags => 'Unmatched Scraped Tags';

  @override
  String get scenes_unmatched_scraped_performers =>
      'Unmatched Scraped Performers';

  @override
  String get scenes_no_matching_performer_found =>
      'No matching performer found in library';

  @override
  String get common_unknown => 'Unknown';

  @override
  String scenes_studio_id_prefix(String id) {
    return 'Studio ID: $id';
  }

  @override
  String get tags_search_placeholder => 'Search tags...';

  @override
  String get scenes_duration_short => '< 5m';

  @override
  String get scenes_duration_medium => '5-20m';

  @override
  String get scenes_duration_long => '> 20m';

  @override
  String get details_scene_fingerprint_query => 'Query by Fingerprint';

  @override
  String get scenes_available_scrapers => 'Available Scrapers';

  @override
  String get scrape_results_existing => 'Existing';

  @override
  String get scrape_results_scraped => 'Scraped';
}
