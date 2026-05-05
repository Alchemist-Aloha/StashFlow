// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'StashFlow';

  @override
  String get common_token => 'Token';

  @override
  String get filter_value => 'Wert';

  @override
  String get common_yes => 'Ja';

  @override
  String get common_no => 'NEIN';

  @override
  String get common_clear_history => 'Verlauf löschen';

  @override
  String get nav_scenes => 'Szenen';

  @override
  String get nav_performers => 'Darsteller';

  @override
  String get nav_studios => 'Studios';

  @override
  String get nav_tags => 'Tags';

  @override
  String get nav_galleries => 'Galerien';

  @override
  String nScenes(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString Szenen',
      one: '1 Szene',
      zero: 'keine Szenen',
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
      other: '$countString Darsteller',
      one: '1 Darsteller',
      zero: 'keine Darsteller',
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
  String get common_reset => 'Zurücksetzen';

  @override
  String get common_apply => 'Anwenden';

  @override
  String get common_save_default => 'Als Standard speichern';

  @override
  String get common_sort_method => 'Sortiermethode';

  @override
  String get common_direction => 'Richtung';

  @override
  String get common_ascending => 'Aufsteigend';

  @override
  String get common_descending => 'Absteigend';

  @override
  String get common_favorites_only => 'Nur Favoriten';

  @override
  String get common_apply_sort => 'Sortierung anwenden';

  @override
  String get common_apply_filters => 'Filter anwenden';

  @override
  String get common_view_all => 'Alle anzeigen';

  @override
  String get common_default => 'Standard';

  @override
  String get common_later => 'Später';

  @override
  String get common_update_now => 'Jetzt aktualisieren';

  @override
  String get common_configure_now => 'Jetzt konfigurieren';

  @override
  String get common_clear_rating => 'Bewertung löschen';

  @override
  String get common_no_media => 'Keine Medien verfügbar';

  @override
  String get common_show => 'Anzeigen';

  @override
  String get common_hide => 'Ausblenden';

  @override
  String get galleries_filter_saved =>
      'Filtereinstellungen als Standard gespeichert';

  @override
  String get common_setup_required => 'Einrichtung erforderlich';

  @override
  String get common_update_available => 'Update verfügbar';

  @override
  String get details_studio => 'Studio-Details';

  @override
  String get details_performer => 'Darsteller-Details';

  @override
  String get details_tag => 'Tag-Details';

  @override
  String get details_scene => 'Szenen-Details';

  @override
  String get details_gallery => 'Galerie-Details';

  @override
  String get studios_filter_title => 'Studios filtern';

  @override
  String get studios_filter_saved =>
      'Filtereinstellungen als Standard gespeichert';

  @override
  String get sort_name => 'Name';

  @override
  String get sort_scene_count => 'Szenenanzahl';

  @override
  String get sort_rating => 'Bewertung';

  @override
  String get sort_updated_at => 'Aktualisiert am';

  @override
  String get sort_created_at => 'Erstellt am';

  @override
  String get sort_random => 'Zufällig';

  @override
  String get sort_file_mod_time => 'Dateiänderungszeit';

  @override
  String get sort_filesize => 'Dateigröße';

  @override
  String get sort_o_count => 'O-Zähler';

  @override
  String get sort_height => 'Größe';

  @override
  String get sort_birthdate => 'Geburtsdatum';

  @override
  String get sort_tag_count => 'Anzahl Tags';

  @override
  String get sort_play_count => 'Wiedergabeanzahl';

  @override
  String get sort_o_counter => 'O-Zähler';

  @override
  String get sort_zip_file_count => 'Anzahl von ZIP-Dateien';

  @override
  String get sort_last_o_at => 'Letzte O-Zeit';

  @override
  String get sort_latest_scene => 'Neueste Szene';

  @override
  String get sort_career_start => 'Karrierebeginn';

  @override
  String get sort_career_end => 'Karriereende';

  @override
  String get sort_weight => 'Gewicht';

  @override
  String get sort_measurements => 'Maße';

  @override
  String get sort_scenes_duration => 'Szenen-Dauer';

  @override
  String get sort_scenes_size => 'Szenengröße';

  @override
  String get sort_images_count => 'Bilderanzahl';

  @override
  String get sort_galleries_count => 'Galerienanzahl';

  @override
  String get sort_child_count => 'Anzahl Unterstudios';

  @override
  String get sort_performers_count => 'Darstelleranzahl';

  @override
  String get sort_groups_count => 'Gruppenanzahl';

  @override
  String get sort_marker_count => 'Marker-Anzahl';

  @override
  String get sort_studios_count => 'Studiosanzahl';

  @override
  String get sort_penis_length => 'Penislänge';

  @override
  String get sort_last_played_at => 'Zuletzt abgespielt am';

  @override
  String get studios_sort_saved =>
      'Sortiereinstellungen als Standard gespeichert';

  @override
  String get studios_no_random =>
      'Keine Studios für zufällige Navigation verfügbar';

  @override
  String get tags_filter_title => 'Tags filtern';

  @override
  String get tags_filter_saved =>
      'Filtereinstellungen als Standard gespeichert';

  @override
  String get tags_sort_title => 'Tags sortieren';

  @override
  String get tags_sort_saved => 'Sortiereinstellungen als Standard gespeichert';

  @override
  String get tags_no_random => 'Keine Tags für zufällige Navigation verfügbar';

  @override
  String get scenes_no_random =>
      'Keine Szenen für zufällige Navigation verfügbar';

  @override
  String get performers_no_random =>
      'Keine Darsteller für zufällige Navigation verfügbar';

  @override
  String get galleries_no_random =>
      'Keine Galerien für zufällige Navigation verfügbar';

  @override
  String common_error(String message) {
    return 'Fehler: $message';
  }

  @override
  String get common_no_media_available => 'keine Medien verfügbar';

  @override
  String common_id(Object id) {
    return 'ID: $id';
  }

  @override
  String get common_search_placeholder => 'Suchen...';

  @override
  String get common_pause => 'Pause';

  @override
  String get common_play => 'Wiedergabe';

  @override
  String get common_refresh => 'Aktualisieren';

  @override
  String get common_close => 'schließen';

  @override
  String get common_save => 'speichern';

  @override
  String get common_unmute => 'Ton an';

  @override
  String get common_mute => 'stumm';

  @override
  String get common_back => 'zurück';

  @override
  String get common_rate => 'bewerten';

  @override
  String get common_previous => 'zurück';

  @override
  String get common_next => 'weiter';

  @override
  String get common_favorite => 'Favorit';

  @override
  String get common_unfavorite => 'entfavorisieren';

  @override
  String get common_version => 'Version';

  @override
  String get common_loading => 'lädt';

  @override
  String get common_unavailable => 'nicht verfügbar';

  @override
  String get common_details => 'Details';

  @override
  String get common_title => 'Titel';

  @override
  String get common_release_date => 'Veröffentlichungsdatum';

  @override
  String get common_url => 'URL';

  @override
  String get common_no_url => 'keine URL';

  @override
  String get common_sort => 'sortieren';

  @override
  String get common_filter => 'filtern';

  @override
  String get common_search => 'suchen';

  @override
  String get common_settings => 'Einstellungen';

  @override
  String get common_reset_to_1x => 'auf 1x zurücksetzen';

  @override
  String get common_skip_next => 'überspringen';

  @override
  String get common_skip_previous => 'Skip Previous';

  @override
  String get common_select_subtitle => 'Untertitel wählen';

  @override
  String get common_playback_speed => 'Tempo';

  @override
  String get common_pip => 'Bild-im-Bild';

  @override
  String get common_toggle_fullscreen => 'Vollbild umschalten';

  @override
  String get common_exit_fullscreen => 'Vollbild beenden';

  @override
  String get common_copy_logs => 'Logs kopieren';

  @override
  String get common_clear_logs => 'Logs löschen';

  @override
  String get common_enable_autoscroll => 'Auto-Scroll an';

  @override
  String get common_disable_autoscroll => 'Auto-Scroll aus';

  @override
  String get common_retry => 'Wiederholen';

  @override
  String get common_no_items => 'Keine Einträge gefunden';

  @override
  String get common_none => 'Keine';

  @override
  String get common_any => 'Alle';

  @override
  String get common_name => 'Name';

  @override
  String get common_date => 'Datum';

  @override
  String get common_rating => 'Bewertung';

  @override
  String get common_image_count => 'Anzahl der Bilder';

  @override
  String get common_filepath => 'Dateipfad';

  @override
  String get common_random => 'Zufällig';

  @override
  String get common_no_media_found => 'Keine Medien gefunden';

  @override
  String common_not_found(String item) {
    return '$item nicht gefunden';
  }

  @override
  String get common_add_favorite => 'Zu Favoriten hinzufügen';

  @override
  String get common_remove_favorite => 'Aus Favoriten entfernen';

  @override
  String get details_group => 'Gruppendetails';

  @override
  String get details_synopsis => 'Zusammenfassung';

  @override
  String get details_media => 'Medien';

  @override
  String get details_galleries => 'Galerien';

  @override
  String get details_tags => 'Tags';

  @override
  String get details_links => 'Links';

  @override
  String get details_scene_scrape => 'Metadaten scrapen';

  @override
  String get details_show_more => 'Mehr anzeigen';

  @override
  String get common_more => 'More';

  @override
  String get details_show_less => 'Weniger anzeigen';

  @override
  String get details_more_from_studio => 'Mehr vom Studio';

  @override
  String get details_o_count_incremented => 'O-Zähler erhöht';

  @override
  String details_failed_update_rating(String error) {
    return 'Fehler beim Aktualisieren der Bewertung: $error';
  }

  @override
  String details_failed_update_performer(Object error) {
    return 'Aktualisierung des Darstellers fehlgeschlagen: $error';
  }

  @override
  String details_failed_increment_o_count(String error) {
    return 'Fehler beim Erhöhen des O-Zählers: $error';
  }

  @override
  String get details_scene_add_performer => 'Darsteller hinzufügen';

  @override
  String get details_scene_add_tag => 'Tag hinzufügen';

  @override
  String get details_scene_add_url => 'URL hinzufügen';

  @override
  String get details_scene_remove_url => 'URL entfernen';

  @override
  String get groups_title => 'Gruppen';

  @override
  String get groups_unnamed => 'Unbenannte Gruppe';

  @override
  String get groups_untitled => 'Unbenannte Gruppe';

  @override
  String get studios_title => 'Studios';

  @override
  String get studios_galleries_title => 'Studio-Galerien';

  @override
  String get studios_media_title => 'Studio-Medien';

  @override
  String get studios_sort_title => 'Studios sortieren';

  @override
  String get galleries_title => 'Galerien';

  @override
  String get galleries_sort_title => 'Galerien sortieren';

  @override
  String get galleries_all_images => 'Alle Bilder';

  @override
  String get galleries_filter_title => 'Galerien filtern';

  @override
  String get galleries_min_rating => 'Mindestbewertung';

  @override
  String get galleries_image_count => 'Anzahl der Bilder';

  @override
  String get galleries_organization => 'Organisation';

  @override
  String get galleries_organized_only => 'Nur organisiert';

  @override
  String get scenes_filter_title => 'Szenen filtern';

  @override
  String get scenes_filter_saved =>
      'Filtereinstellungen als Standard gespeichert';

  @override
  String get scenes_watched => 'Gesehen';

  @override
  String get scenes_unwatched => 'Ungesehen';

  @override
  String get scenes_search_hint => 'Szenen suchen...';

  @override
  String get scenes_sort_header => 'Szenen sortieren';

  @override
  String get scenes_sort_duration => 'Dauer';

  @override
  String get scenes_sort_bitrate => 'Bitrate';

  @override
  String get scenes_sort_framerate => 'Bildrate';

  @override
  String get scenes_sort_saved_default =>
      'Sortiereinstellungen als Standard gespeichert';

  @override
  String get scenes_sort_tooltip => 'Sortieroptionen';

  @override
  String get tags_search_hint => 'Tags suchen...';

  @override
  String get tags_sort_tooltip => 'Sortieroptionen';

  @override
  String get tags_filter_tooltip => 'Filteroptionen';

  @override
  String get performers_title => 'Darsteller';

  @override
  String get performers_sort_title => 'Darsteller sortieren';

  @override
  String get performers_filter_title => 'Darsteller filtern';

  @override
  String get performers_galleries_title => 'Alle Darsteller-Galerien';

  @override
  String get performers_media_title => 'Alle Darsteller-Medien';

  @override
  String get performers_gender => 'Geschlecht';

  @override
  String get performers_gender_any => 'Alle';

  @override
  String get performers_gender_female => 'Weiblich';

  @override
  String get performers_gender_male => 'Männlich';

  @override
  String get performers_gender_trans_female => 'Trans-weiblich';

  @override
  String get performers_gender_trans_male => 'Trans-männlich';

  @override
  String get performers_gender_intersex => 'Intersexuell';

  @override
  String get performers_gender_non_binary => 'Nicht-binär';

  @override
  String get performers_circumcised => 'Beschneidung';

  @override
  String get performers_circumcised_cut => 'Beschnitten';

  @override
  String get performers_circumcised_uncut => 'Unbeschnitten';

  @override
  String get performers_play_count => 'Wiedergabeanzahl';

  @override
  String get performers_field_disambiguation => 'Disambiguierung';

  @override
  String get performers_field_birthdate => 'Geburtsdatum';

  @override
  String get performers_field_deathdate => 'Todesdatum';

  @override
  String get performers_field_height_cm => 'Größe (cm)';

  @override
  String get performers_field_weight_kg => 'Gewicht (kg)';

  @override
  String get performers_field_measurements => 'Maße';

  @override
  String get performers_field_fake_tits => 'Künstliche Brüste';

  @override
  String get performers_field_penis_length => 'Penislänge';

  @override
  String get performers_field_ethnicity => 'Ethnie';

  @override
  String get performers_field_country => 'Land';

  @override
  String get performers_field_eye_color => 'Augenfarbe';

  @override
  String get performers_field_hair_color => 'Haarfarbe';

  @override
  String get performers_field_career_start => 'Karrierebeginn';

  @override
  String get performers_field_career_end => 'Karriereende';

  @override
  String get performers_field_tattoos => 'Tätowierungen';

  @override
  String get performers_field_piercings => 'Piercings';

  @override
  String get performers_field_aliases => 'Aliase';

  @override
  String get common_organized => 'Organisiert';

  @override
  String get scenes_duplicated => 'Dupliziert';

  @override
  String get random_studio => 'Zufälliges Studio';

  @override
  String get random_gallery => 'Zufällige Galerie';

  @override
  String get random_tag => 'Zufälliger Tag';

  @override
  String get random_scene => 'Zufällige Szene';

  @override
  String get random_performer => 'Zufälliger Darsteller';

  @override
  String get filter_modifier => 'Modifikator';

  @override
  String get filter_equals => 'Gleich';

  @override
  String get filter_not_equals => 'Nicht gleich';

  @override
  String get filter_greater_than => 'Größer als';

  @override
  String get filter_less_than => 'Kleiner als';

  @override
  String get filter_is_null => 'Ist null';

  @override
  String get filter_not_null => 'Ist nicht null';

  @override
  String get images_resolution_title => 'Auflösung';

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
  String get images_orientation_title => 'Ausrichtung';

  @override
  String get common_or => 'ODER';

  @override
  String get scrape_from_url => 'Von URL scrapen';

  @override
  String get scenes_phash_started => 'Phash-Generierung gestartet';

  @override
  String scenes_phash_failed(Object error) {
    return 'Phash-Generierung fehlgeschlagen: $error';
  }

  @override
  String details_failed_update_studio(Object error) {
    return 'Aktualisierung des Studios fehlgeschlagen: $error';
  }

  @override
  String get settings_title => 'Einstellungen';

  @override
  String get settings_customize => 'StashFlow anpassen';

  @override
  String get settings_customize_subtitle =>
      'Wiedergabe, Aussehen, Layout und Support-Tools an einem Ort optimieren.';

  @override
  String get settings_core_section => 'Kern-Einstellungen';

  @override
  String get settings_core_subtitle => 'Meistgenutzte Konfigurationsseiten';

  @override
  String get settings_server => 'Server';

  @override
  String get settings_server_subtitle => 'Verbindung und API-Konfiguration';

  @override
  String get settings_playback => 'Wiedergabe';

  @override
  String get settings_playback_subtitle => 'Player-Verhalten und Interaktionen';

  @override
  String get settings_keyboard => 'Tastatur';

  @override
  String get settings_keyboard_subtitle =>
      'Anpassbare Verknüpfungen und Hotkeys';

  @override
  String get settings_keyboard_title => 'Tastaturkürzel';

  @override
  String get settings_keyboard_reset_defaults => 'Auf Standard zurücksetzen';

  @override
  String get settings_keyboard_not_bound => 'Nicht zugewiesen';

  @override
  String get settings_keyboard_volume_up => 'Lauter';

  @override
  String get settings_keyboard_volume_down => 'Leiser';

  @override
  String get settings_keyboard_toggle_mute => 'Stummschaltung umschalten';

  @override
  String get settings_keyboard_toggle_fullscreen => 'Vollbild umschalten';

  @override
  String get settings_keyboard_next_scene => 'Nächste Szene';

  @override
  String get settings_keyboard_prev_scene => 'Vorherige Szene';

  @override
  String get settings_keyboard_increase_speed =>
      'Wiedergabegeschwindigkeit erhöhen';

  @override
  String get settings_keyboard_decrease_speed =>
      'Wiedergabegeschwindigkeit verringern';

  @override
  String get settings_keyboard_reset_speed =>
      'Wiedergabegeschwindigkeit zurücksetzen';

  @override
  String get settings_keyboard_close_player => 'Player schließen';

  @override
  String get settings_keyboard_next_image => 'Nächstes Bild';

  @override
  String get settings_keyboard_prev_image => 'Vorheriges Bild';

  @override
  String get settings_keyboard_go_back => 'Zurückgehen';

  @override
  String get settings_keyboard_play_pause_desc =>
      'Zwischen Wiedergabe und Pause umschalten';

  @override
  String get settings_keyboard_seek_forward_5_desc =>
      '5 Sekunden vorwärts springen';

  @override
  String get settings_keyboard_seek_backward_5_desc =>
      '5 Sekunden rückwärts springen';

  @override
  String get settings_keyboard_seek_forward_10_desc =>
      '10 Sekunden vorwärts springen';

  @override
  String get settings_keyboard_seek_backward_10_desc =>
      '10 Sekunden rückwärts springen';

  @override
  String get settings_appearance => 'Erscheinungsbild';

  @override
  String get settings_appearance_subtitle => 'Design und Farben';

  @override
  String get settings_interface => 'Benutzeroberfläche';

  @override
  String get settings_interface_subtitle => 'Navigations- und Layout-Standards';

  @override
  String get settings_support => 'Support';

  @override
  String get settings_support_subtitle => 'Diagnose und Informationen';

  @override
  String get settings_develop => 'Entwickeln';

  @override
  String get settings_develop_subtitle => 'Erweiterte Tools und Overrides';

  @override
  String get settings_appearance_title => 'Darstellungs-Einstellungen';

  @override
  String get settings_appearance_theme_mode => 'Design-Modus';

  @override
  String get settings_appearance_theme_mode_subtitle =>
      'Wählen Sie, wie die App auf Helligkeitsänderungen reagiert';

  @override
  String get settings_appearance_theme_system => 'System';

  @override
  String get settings_appearance_theme_light => 'Hell';

  @override
  String get settings_appearance_theme_dark => 'Dunkel';

  @override
  String get settings_appearance_primary_color => 'Primärfarbe';

  @override
  String get settings_appearance_primary_color_subtitle =>
      'Wählen Sie eine Ausgangsfarbe für die Material 3-Palette';

  @override
  String get settings_appearance_advanced_theming => 'Erweitertes Theming';

  @override
  String get settings_appearance_advanced_theming_subtitle =>
      'Optimierungen für spezifische Bildschirmtypen';

  @override
  String get settings_appearance_true_black => 'Echtes Schwarz (AMOLED)';

  @override
  String get settings_appearance_true_black_subtitle =>
      'Verwenden Sie rein schwarze Hintergründe im dunklen Modus, um Akku bei OLED-Bildschirmen zu sparen';

  @override
  String get settings_appearance_custom_hex => 'Benutzerdefinierte Hex-Farbe';

  @override
  String get settings_appearance_custom_hex_helper =>
      'Geben Sie einen 8-stelligen ARGB-Hex-Code ein';

  @override
  String get settings_appearance_font_size => 'Globale UI-Skala';

  @override
  String get settings_appearance_font_size_subtitle =>
      'Skalieren Sie Typografie und Abstände proportional';

  @override
  String get settings_interface_title => 'Interface-Einstellungen';

  @override
  String get settings_interface_language => 'Sprache';

  @override
  String get settings_interface_language_subtitle =>
      'Die Standard-Systemsprache überschreiben';

  @override
  String get settings_interface_app_language => 'App-Sprache';

  @override
  String get settings_interface_navigation => 'Navigation';

  @override
  String get settings_interface_navigation_subtitle =>
      'Sichtbarkeit globaler Navigationskürzel';

  @override
  String get settings_interface_show_random =>
      'Zufalls-Navigationsschaltflächen anzeigen';

  @override
  String get settings_interface_show_random_subtitle =>
      'Aktivieren oder deaktivieren Sie die schwebenden Casino-Schaltflächen auf Listen- und Detailseiten';

  @override
  String get settings_interface_main_pages_gravity_orientation =>
      'Schwerkraftgesteuerte Ausrichtung (Hauptseiten)';

  @override
  String get settings_interface_main_pages_gravity_orientation_subtitle =>
      'Erlaube Hauptseiten, sich mithilfe des Gerätesensors zu drehen. Die Vollbild-Videowiedergabe verwendet eigene Ausrichtungseinstellungen.';

  @override
  String get settings_interface_show_edit => 'Bearbeiten-Schaltfläche anzeigen';

  @override
  String get settings_interface_show_edit_subtitle =>
      'Aktivieren oder deaktivieren Sie die Bearbeiten-Schaltfläche auf der Szenendetailseite';

  @override
  String get settings_interface_customize_tabs => 'Tabs anpassen';

  @override
  String get settings_interface_customize_tabs_subtitle =>
      'Navigationselemente neu anordnen oder ausblenden';

  @override
  String get settings_interface_scenes_layout => 'Szenen-Layout';

  @override
  String get settings_interface_scenes_layout_subtitle =>
      'Standard-Browsing-Modus für Szenen';

  @override
  String get settings_interface_galleries_layout => 'Galerien-Layout';

  @override
  String get settings_interface_galleries_layout_subtitle =>
      'Standard-Browsing-Modus für Galerien';

  @override
  String get settings_interface_max_performer_avatars =>
      'Maximale Darsteller-Avatare';

  @override
  String get settings_interface_max_performer_avatars_subtitle =>
      'Maximale Anzahl der Darsteller-Avatare, die in der Szenenkarte angezeigt werden.';

  @override
  String get settings_interface_show_performer_avatars =>
      'Darsteller-Avatare anzeigen';

  @override
  String get settings_interface_show_performer_avatars_subtitle =>
      'Darsteller-Symbole auf Szenenkarten auf allen Plattformen anzeigen.';

  @override
  String get settings_interface_performer_avatar_size =>
      'Größe der Darsteller-Avatare';

  @override
  String get settings_interface_layout_default => 'Standard-Layout';

  @override
  String get settings_interface_layout_default_desc =>
      'Wählen Sie das Standard-Layout für die Seite';

  @override
  String get settings_interface_layout_list => 'Liste';

  @override
  String get settings_interface_layout_grid => 'Raster';

  @override
  String get settings_interface_layout_tiktok => 'Endloses Scrollen';

  @override
  String get settings_interface_grid_columns => 'Rasterspalten';

  @override
  String get settings_interface_image_viewer => 'Bildbetrachter';

  @override
  String get settings_interface_image_viewer_subtitle =>
      'Vollbild-Bild-Browsing-Verhalten konfigurieren';

  @override
  String get settings_interface_swipe_direction => 'Vollbild-Wischrichtung';

  @override
  String get settings_interface_swipe_direction_desc =>
      'Wählen Sie, wie Bilder im Vollbildmodus gewechselt werden';

  @override
  String get settings_interface_swipe_vertical => 'Vertikal';

  @override
  String get settings_interface_swipe_horizontal => 'Horizontal';

  @override
  String get settings_interface_waterfall_columns => 'Wasserfall-Rasterspalten';

  @override
  String get settings_interface_performer_layouts => 'Darsteller-Layouts';

  @override
  String get settings_interface_performer_layouts_subtitle =>
      'Medien- und Galerie-Standards für Darsteller';

  @override
  String get settings_interface_studio_layouts => 'Studio-Layouts';

  @override
  String get settings_interface_studio_layouts_subtitle =>
      'Medien- und Galerie-Standards für Studios';

  @override
  String get settings_interface_tag_layouts => 'Tag-Layouts';

  @override
  String get settings_interface_tag_layouts_subtitle =>
      'Medien- und Galerie-Standards für Tags';

  @override
  String get settings_interface_media_layout => 'Medien-Layout';

  @override
  String get settings_interface_media_layout_subtitle =>
      'Layout für die Medienseite';

  @override
  String get settings_interface_galleries_layout_item => 'Galerien-Layout';

  @override
  String get settings_interface_galleries_layout_subtitle_item =>
      'Layout für die Galerieseite';

  @override
  String get settings_server_title => 'Server-Einstellungen';

  @override
  String get settings_server_status => 'Verbindungsstatus';

  @override
  String get settings_server_status_subtitle =>
      'Live-Konnektivität zum konfigurierten Server';

  @override
  String get settings_server_details => 'Server-Details';

  @override
  String get settings_server_details_subtitle =>
      'Endpunkt und Authentifizierungsmethode konfigurieren';

  @override
  String get settings_server_url => 'Stash-URL';

  @override
  String get settings_server_url_helper =>
      'Geben Sie die URL Ihres Stash-Servers ein. Wenn ein benutzerdefinierter Pfad konfiguriert ist, geben Sie diesen hier an.';

  @override
  String get settings_server_url_example => 'http://192.168.1.100:9999';

  @override
  String get settings_server_login_failed => 'Anmeldung fehlgeschlagen';

  @override
  String get settings_server_auth_method => 'Authentifizierungsmethode';

  @override
  String get settings_server_auth_apikey => 'API-Key';

  @override
  String get settings_server_auth_password => 'Benutzername + Passwort';

  @override
  String get settings_server_auth_password_desc =>
      'Empfohlen: Verwenden Sie Ihre Stash Benutzername/Passwort-Sitzung.';

  @override
  String get settings_server_auth_apikey_desc =>
      'Verwenden Sie einen API-Key für die statische Token-Authentifizierung.';

  @override
  String get settings_server_username => 'Benutzername';

  @override
  String get settings_server_password => 'Passwort';

  @override
  String get settings_server_login_test => 'Anmelden & Testen';

  @override
  String get settings_server_test => 'Verbindung testen';

  @override
  String get settings_server_logout => 'Abmelden';

  @override
  String get settings_server_clear => 'Einstellungen löschen';

  @override
  String settings_server_connected(String version) {
    return 'Verbunden (Stash $version)';
  }

  @override
  String get settings_server_checking => 'Verbindung wird geprüft...';

  @override
  String settings_server_failed(String error) {
    return 'Fehlgeschlagen: $error';
  }

  @override
  String get settings_server_invalid_url => 'Ungültige Server-URL';

  @override
  String get settings_server_resolve_error =>
      'Server-URL konnte nicht aufgelöst werden. Überprüfen Sie Host, Port und Zugangsdaten.';

  @override
  String get settings_server_logout_confirm =>
      'Abgemeldet und Cookies gelöscht.';

  @override
  String get settings_server_profile_add => 'Profil hinzufügen';

  @override
  String get settings_server_profile_edit => 'Profil bearbeiten';

  @override
  String get settings_server_profile_name => 'Profilname';

  @override
  String get settings_server_profile_delete => 'Profil löschen';

  @override
  String get settings_server_profile_delete_confirm =>
      'Sind Sie sicher, dass Sie dieses Profil löschen möchten? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get settings_server_profile_active => 'Aktiv';

  @override
  String get settings_server_profile_empty =>
      'Keine Serverprofile konfiguriert';

  @override
  String get settings_server_profiles => 'Serverprofile';

  @override
  String get settings_server_profiles_subtitle =>
      'Mehrere Stash-Serververbindungen verwalten';

  @override
  String get settings_server_auth_status_logging_in =>
      'Authentifizierungsstatus: Anmeldung...';

  @override
  String get settings_server_auth_status_logged_in =>
      'Authentifizierungsstatus: Angemeldet';

  @override
  String get settings_server_auth_status_logged_out =>
      'Authentifizierungsstatus: Abgemeldet';

  @override
  String get settings_playback_title => 'Wiedergabe-Einstellungen';

  @override
  String get settings_playback_behavior => 'Wiedergabeverhalten';

  @override
  String get settings_playback_behavior_subtitle =>
      'Standard-Wiedergabe- und Hintergrund-Handling';

  @override
  String get settings_playback_prefer_streams => 'sceneStreams bevorzugen';

  @override
  String get settings_playback_prefer_streams_subtitle =>
      'Wenn deaktiviert, wird die Wiedergabe direkt über paths.stream ausgeführt';

  @override
  String get settings_playback_end_behavior => 'Endeverhalten abspielen';

  @override
  String get settings_playback_end_behavior_subtitle =>
      'Was tun, wenn die aktuelle Wiedergabe endet?';

  @override
  String get settings_playback_end_behavior_stop => 'Stoppen';

  @override
  String get settings_playback_end_behavior_loop =>
      'Aktuelle Szene wiederholen';

  @override
  String get settings_playback_end_behavior_next => 'Nächste Szene abspielen';

  @override
  String get settings_playback_autoplay =>
      'Nächste Szene automatisch abspielen';

  @override
  String get settings_playback_autoplay_subtitle =>
      'Nächste Szene automatisch abspielen, wenn die aktuelle endet';

  @override
  String get settings_playback_background => 'Hintergrund-Wiedergabe';

  @override
  String get settings_playback_background_subtitle =>
      'Video-Audio weiter abspielen, wenn die App im Hintergrund ist';

  @override
  String get settings_playback_pip => 'Natives Bild-im-Bild';

  @override
  String get settings_playback_pip_subtitle =>
      'Android PiP-Schaltfläche aktivieren und automatisch bei Hintergrundwechsel starten';

  @override
  String get settings_playback_subtitles => 'Untertitel-Einstellungen';

  @override
  String get settings_playback_subtitles_subtitle =>
      'Automatisches Laden und Erscheinungsbild';

  @override
  String get settings_playback_subtitle_lang => 'Standard-Untertitelsprache';

  @override
  String get settings_playback_subtitle_lang_subtitle =>
      'Automatisch laden, falls verfügbar';

  @override
  String get settings_playback_subtitle_size => 'Schriftgröße der Untertitel';

  @override
  String get settings_playback_subtitle_pos =>
      'Vertikale Position der Untertitel';

  @override
  String settings_playback_subtitle_pos_desc(String percent) {
    return '$percent% von unten';
  }

  @override
  String get settings_playback_subtitle_align =>
      'Textausrichtung der Untertitel';

  @override
  String get settings_playback_subtitle_align_subtitle =>
      'Ausrichtung für mehrzeilige Untertitel';

  @override
  String get settings_playback_seek => 'Seek-Interaktion';

  @override
  String get settings_playback_seek_subtitle =>
      'Wählen Sie, wie das Vorspulen während der Wiedergabe funktioniert';

  @override
  String get settings_playback_seek_double_tap =>
      'Doppeltippen links/rechts zum Springen (10s)';

  @override
  String get settings_playback_seek_drag =>
      'Ziehen Sie auf der Zeitachse zum Suchen';

  @override
  String get settings_playback_seek_drag_label => 'Ziehen';

  @override
  String get settings_playback_seek_double_tap_label => 'Doppeltippen';

  @override
  String get settings_playback_gravity_orientation =>
      'Schwerkraftgesteuerte Ausrichtung';

  @override
  String get settings_playback_gravity_orientation_subtitle =>
      'Erlaube die Rotation zwischen passenden Ausrichtungen mithilfe des Gerätesensors (z. B. Landschaft links/rechts).';

  @override
  String get settings_playback_subtitle_lang_none_disabled =>
      'Keine (Deaktiviert)';

  @override
  String get settings_playback_subtitle_lang_auto_if_only_one =>
      'Automatisch (Wenn nur eins)';

  @override
  String get settings_playback_subtitle_lang_english => 'Englisch';

  @override
  String get settings_playback_subtitle_lang_chinese => 'Chinesisch';

  @override
  String get settings_playback_subtitle_lang_german => 'Deutsch';

  @override
  String get settings_playback_subtitle_lang_french => 'Französisch';

  @override
  String get settings_playback_subtitle_lang_spanish => 'Spanisch';

  @override
  String get settings_playback_subtitle_lang_italian => 'Italienisch';

  @override
  String get settings_playback_subtitle_lang_japanese => 'Japanisch';

  @override
  String get settings_playback_subtitle_lang_korean => 'Koreanisch';

  @override
  String get settings_playback_subtitle_align_left => 'Links';

  @override
  String get settings_playback_subtitle_align_center => 'Zentriert';

  @override
  String get settings_playback_subtitle_align_right => 'Rechts';

  @override
  String get settings_support_title => 'Support';

  @override
  String get settings_support_diagnostics => 'Diagnose und Projektinfo';

  @override
  String get settings_support_diagnostics_subtitle =>
      'Laufzeit-Logs öffnen oder zum Repository springen, wenn Sie Hilfe benötigen.';

  @override
  String get settings_support_update_available => 'Update verfügbar';

  @override
  String get settings_support_update_available_subtitle =>
      'Eine neuere Version ist auf GitHub verfügbar';

  @override
  String settings_support_update_to(String version) {
    return 'Update auf $version';
  }

  @override
  String get settings_support_update_to_subtitle =>
      'Neue Funktionen und Verbesserungen warten auf Sie.';

  @override
  String get settings_support_about => 'Über';

  @override
  String get settings_support_about_subtitle =>
      'Projekt- und Quellinformationen';

  @override
  String get settings_support_version => 'Version';

  @override
  String get settings_support_version_loading => 'Versionsinfo wird geladen...';

  @override
  String get settings_support_version_unavailable =>
      'Versionsinfo nicht verfügbar';

  @override
  String get settings_support_github => 'GitHub-Repository';

  @override
  String get settings_support_github_subtitle =>
      'Quellcode anzeigen und Probleme melden';

  @override
  String get settings_support_github_error =>
      'GitHub-Link konnte nicht geöffnet werden';

  @override
  String get settings_support_issues => 'Melden Sie ein Problem';

  @override
  String get settings_support_issues_subtitle =>
      'Helfen Sie mit, StashFlow zu verbessern, indem Sie Fehler melden';

  @override
  String get settings_develop_title => 'Entwickeln';

  @override
  String get settings_develop_diagnostics => 'Diagnose-Tools';

  @override
  String get settings_develop_diagnostics_subtitle =>
      'Fehlerbehebung und Leistung';

  @override
  String get settings_develop_video_debug => 'Video-Debug-Info anzeigen';

  @override
  String get settings_develop_video_debug_subtitle =>
      'Technische Wiedergabedetails als Overlay im Videoplayer anzeigen.';

  @override
  String get settings_develop_log_viewer => 'Debug-Log-Viewer';

  @override
  String get settings_develop_log_viewer_subtitle =>
      'Live-Ansicht der In-App-Logs öffnen.';

  @override
  String get settings_develop_logs_copied =>
      'Logs in die Zwischenablage kopiert';

  @override
  String get settings_develop_no_logs =>
      'Noch keine Logs. Interagiere mit der App, um Logs zu erfassen.';

  @override
  String get settings_develop_web_overrides => 'Web-Overrides';

  @override
  String get settings_develop_web_overrides_subtitle =>
      'Erweiterte Flags für die Web-Plattform';

  @override
  String get settings_develop_web_auth => 'Passwort-Login im Web erlauben';

  @override
  String get settings_develop_web_auth_subtitle =>
      'Hebt die Native-only-Beschränkung auf und erzwingt die Sichtbarkeit der Benutzername + Passwort-Authentifizierungsmethode in Flutter Web.';

  @override
  String get settings_develop_proxy_auth =>
      'Proxy-Authentifizierungsmodi aktivieren';

  @override
  String get settings_develop_proxy_auth_subtitle =>
      'Aktivieren Sie erweiterte Basic-Auth- und Bearer-Token-Methoden für die Verwendung mit authentifizierungsfreien Backends hinter Proxys wie Authentik.';

  @override
  String get settings_server_auth_basic => 'Basic Auth';

  @override
  String get settings_server_auth_bearer => 'Bearer-Token';

  @override
  String get settings_server_auth_basic_desc =>
      'Sendet den Header \'Authorization: Basic <base64(user:pass)>\'.';

  @override
  String get settings_server_auth_bearer_desc =>
      'Sendet den Header \'Authorization: Bearer <token>\'.';

  @override
  String get common_edit => 'Bearbeiten';

  @override
  String get common_resolution => 'Auflösung';

  @override
  String get common_orientation => 'Ausrichtung';

  @override
  String get common_landscape => 'Querformat';

  @override
  String get common_portrait => 'Hochformat';

  @override
  String get common_square => 'Quadrat';

  @override
  String get performers_filter_saved =>
      'Filtereinstellungen als Standard gespeichert';

  @override
  String get images_title => 'Bilder';

  @override
  String get images_filter_title => 'Bilder filtern';

  @override
  String get images_filter_saved =>
      'Filtereinstellungen als Standard gespeichert';

  @override
  String get images_sort_title => 'Bilder sortieren';

  @override
  String get images_sort_saved =>
      'Sortier-Einstellungen als Standard gespeichert';

  @override
  String get image_rating_updated => 'Bildbewertung aktualisiert.';

  @override
  String get gallery_rating_updated => 'Galeriebewertung aktualisiert.';

  @override
  String get common_image => 'Bild';

  @override
  String get common_gallery => 'Galerie';

  @override
  String get images_gallery_rating_unavailable =>
      'Die Galeriebewertung ist nur verfügbar, wenn Sie eine Galerie durchsuchen.';

  @override
  String images_rating(String rating) {
    return 'Bewertung: $rating / 5';
  }

  @override
  String get images_filtered_by_gallery => 'Gefiltert nach Galerie';

  @override
  String get images_slideshow_need_two =>
      'Mindestens 2 Bilder werden für die Diashow benötigt.';

  @override
  String get images_slideshow_start_title => 'Diashow starten';

  @override
  String images_slideshow_interval(num seconds) {
    return 'Intervall: ${seconds}s';
  }

  @override
  String images_slideshow_transition_ms(num ms) {
    return 'Übergang: ${ms}ms';
  }

  @override
  String get common_forward => 'Vorwärts';

  @override
  String get common_backward => 'Rückwärts';

  @override
  String get images_slideshow_loop_title => 'Diashow wiederholen';

  @override
  String get common_cancel => 'Abbrechen';

  @override
  String get common_start => 'Starten';

  @override
  String get common_done => 'Fertig';

  @override
  String get settings_keybind_assign_shortcut => 'Tastenkürzel zuweisen';

  @override
  String get settings_keybind_press_any =>
      'Drücke eine beliebige Tastenkombination...';

  @override
  String get scenes_select_tags => 'Tags auswählen';

  @override
  String get scenes_no_scrapers => 'Keine Scraper verfügbar';

  @override
  String get scenes_select_scraper => 'Scraper auswählen';

  @override
  String get scenes_no_results_found => 'Keine Ergebnisse gefunden';

  @override
  String get scenes_select_result => 'Ergebnis auswählen';

  @override
  String scenes_scrape_failed(String error) {
    return 'Scrape fehlgeschlagen: $error';
  }

  @override
  String get scenes_updated_successfully => 'Szene erfolgreich aktualisiert';

  @override
  String scenes_update_failed(String error) {
    return 'Fehler beim Aktualisieren der Szene: $error';
  }

  @override
  String get scenes_edit_title => 'Szene bearbeiten';

  @override
  String get scenes_field_studio => 'Studio';

  @override
  String get scenes_field_tags => 'Tags';

  @override
  String get scenes_field_urls => 'URLs';

  @override
  String get scenes_edit_performer => 'Darsteller bearbeiten';

  @override
  String get scenes_edit_studio => 'Studio bearbeiten';

  @override
  String get common_no_title => 'Kein Titel';

  @override
  String get scenes_select_studio => 'Studio auswählen';

  @override
  String get scenes_select_performers => 'Darsteller auswählen';

  @override
  String get scenes_unmatched_scraped_tags =>
      'Nicht übereinstimmende gescrapte Tags';

  @override
  String get scenes_unmatched_scraped_performers =>
      'Nicht übereinstimmende gescrapte Darsteller';

  @override
  String get scenes_no_matching_performer_found =>
      'Kein übereinstimmender Darsteller in der Bibliothek gefunden';

  @override
  String get common_unknown => 'Unbekannt';

  @override
  String scenes_studio_id_prefix(String id) {
    return 'Studio-ID: $id';
  }

  @override
  String get tags_search_placeholder => 'Tags durchsuchen...';

  @override
  String get scenes_duration_short => '< 5 Min.';

  @override
  String get scenes_duration_medium => '5-20 Min.';

  @override
  String get scenes_duration_long => '> 20 Min.';

  @override
  String get details_scene_fingerprint_query => 'Szenen-Fingerprint-Abfrage';

  @override
  String get scenes_available_scrapers => 'Verfügbare Scraper';

  @override
  String get scrape_results_existing => 'Bereits vorhanden';

  @override
  String get scrape_results_scraped => 'Erfasste Ergebnisse';

  @override
  String get stats_refresh_statistics => 'Statistiken aktualisieren';

  @override
  String get stats_library_stats => 'Bibliotheksstatistiken';

  @override
  String get stats_stash_glance => 'Dein Stash auf einen Blick';

  @override
  String get stats_content => 'Inhalt';

  @override
  String get stats_organization => 'Organisation';

  @override
  String get stats_activity => 'Aktivität';

  @override
  String get stats_scenes => 'Szenen';

  @override
  String get stats_galleries => 'Galerien';

  @override
  String get stats_performers => 'Darsteller';

  @override
  String get stats_studios => 'Studios';

  @override
  String get stats_groups => 'Gruppen';

  @override
  String get stats_tags => 'Schlagworte';

  @override
  String get stats_total_plays => 'Gesamtspiele';

  @override
  String stats_unique_items(int count) {
    return '$count unique items';
  }

  @override
  String get stats_total_o_count => 'Gesamt-O-Zählung';

  @override
  String get cast_airplay_pairing => 'AirPlay-Kopplung';

  @override
  String get cast_enter_pin =>
      'Geben Sie die 4-stellige PIN ein, die auf Ihrem Fernseher angezeigt wird';

  @override
  String get cast_pair => 'Paar';

  @override
  String cast_connecting_to(String deviceName) {
    return 'Connecting to $deviceName...';
  }

  @override
  String cast_casting_to(String deviceName) {
    return 'Casting to $deviceName';
  }

  @override
  String cast_pairing_failed(String error) {
    return 'Pairing failed: $error';
  }

  @override
  String cast_failed_to_cast(String error) {
    return 'Failed to cast: $error';
  }

  @override
  String get cast_searching => 'Suche nach Geräten...';

  @override
  String get cast_cast_to_device => 'Auf Gerät übertragen';

  @override
  String get settings_storage_images => 'Bilder';

  @override
  String get settings_storage_videos => 'Videos';

  @override
  String get settings_storage_database => 'Datenbank';

  @override
  String get settings_storage_clearing_image => 'Bildcache wird geleert...';

  @override
  String get settings_storage_clearing_video => 'Video-Cache wird geleert...';

  @override
  String get settings_storage_clearing_database =>
      'Datenbank-Cache wird geleert...';

  @override
  String get settings_storage_cleared_image => 'Bildcache geleert';

  @override
  String get settings_storage_cleared_video => 'Video-Cache geleert';

  @override
  String get settings_storage_cleared_database => 'Datenbankcache geleert';

  @override
  String get settings_storage_clear => 'Klar';

  @override
  String get settings_storage_error_loading => 'Fehler beim Laden der Größen';

  @override
  String settings_storage_mb(num value) {
    return '$value MB';
  }

  @override
  String settings_storage_gb(num value) {
    return '$value GB';
  }

  @override
  String get settings_storage_100_mb => '100 MB';

  @override
  String get settings_storage_500_mb => '500 MB';

  @override
  String get settings_storage_1_gb => '1 GB';

  @override
  String get settings_storage_2_gb => '2 GB';

  @override
  String get settings_storage_unlimited => 'Unbegrenzt';

  @override
  String get settings_storage_limits => 'Grenzen';

  @override
  String get settings_storage_limits_subtitle =>
      'Legen Sie maximale Cache-Größen fest';

  @override
  String get settings_storage_max_image_cache => 'Maximaler Bildcache (MB)';

  @override
  String get settings_storage_max_video_cache => 'Maximaler Video-Cache (MB)';

  @override
  String get performers_field_name => 'Name';

  @override
  String get performers_field_url => 'URL';

  @override
  String get performers_field_details => 'Details';

  @override
  String get performers_field_birth_year => 'Birth Year';

  @override
  String get performers_field_age => 'Age';

  @override
  String get performers_field_death_year => 'Death Year';

  @override
  String get performers_field_scene_count => 'Scene Count';

  @override
  String get performers_field_image_count => 'Image Count';

  @override
  String get performers_field_gallery_count => 'Gallery Count';

  @override
  String get performers_field_play_count => 'Play Count';

  @override
  String get performers_field_o_counter => 'O-Counter';

  @override
  String get performers_field_tag_count => 'Tag Count';

  @override
  String get performers_field_created_at => 'Created At';

  @override
  String get performers_field_updated_at => 'Updated At';

  @override
  String get galleries_field_title => 'Title';

  @override
  String get galleries_field_details => 'Details';

  @override
  String get galleries_field_date => 'Date';

  @override
  String get galleries_field_performer_age => 'Performer Age';

  @override
  String get galleries_field_performer_count => 'Performer Count';

  @override
  String get galleries_field_tag_count => 'Tag Count';

  @override
  String get galleries_field_url => 'URL';

  @override
  String get galleries_field_id => 'ID';

  @override
  String get galleries_field_path => 'Path';

  @override
  String get galleries_field_checksum => 'Checksum';

  @override
  String get galleries_field_image_count => 'Image Count';

  @override
  String get galleries_field_file_count => 'File Count';

  @override
  String get galleries_field_created_at => 'Created At';

  @override
  String get galleries_field_updated_at => 'Updated At';

  @override
  String get images_field_title => 'Title';

  @override
  String get images_field_details => 'Details';

  @override
  String get images_field_path => 'Path';

  @override
  String get images_field_url => 'URL';

  @override
  String get images_field_file_count => 'File Count';

  @override
  String get images_field_o_counter => 'O-Counter';

  @override
  String get studios_field_name => 'Name';

  @override
  String get studios_field_details => 'Details';

  @override
  String get studios_field_aliases => 'Aliases';

  @override
  String get studios_field_url => 'URL';

  @override
  String get studios_field_tag_count => 'Tag Count';

  @override
  String get studios_field_scene_count => 'Scene Count';

  @override
  String get studios_field_image_count => 'Image Count';

  @override
  String get studios_field_gallery_count => 'Gallery Count';

  @override
  String get studios_field_sub_studio_count => 'Sub-studio Count';

  @override
  String get studios_field_created_at => 'Created At';

  @override
  String get studios_field_updated_at => 'Updated At';

  @override
  String get scenes_field_performer_age => 'Performer Age';

  @override
  String get scenes_field_performer_count => 'Performer Count';

  @override
  String get scenes_field_tag_count => 'Tag Count';

  @override
  String get scenes_field_code => 'Code';

  @override
  String get scenes_field_details => 'Details';

  @override
  String get scenes_field_director => 'Director';

  @override
  String get scenes_field_url => 'URL';

  @override
  String get scenes_field_date => 'Date';

  @override
  String get scenes_field_path => 'Path';

  @override
  String get scenes_field_captions => 'Captions';

  @override
  String get scenes_field_duration => 'Duration (seconds)';

  @override
  String get scenes_field_bitrate => 'Bitrate';

  @override
  String get scenes_field_video_codec => 'Video Codec';

  @override
  String get scenes_field_audio_codec => 'Audio Codec';

  @override
  String get scenes_field_framerate => 'Framerate';

  @override
  String get scenes_field_file_count => 'File Count';

  @override
  String get scenes_field_play_count => 'Play Count';

  @override
  String get scenes_field_play_duration => 'Play Duration';

  @override
  String get scenes_field_o_counter => 'O-Counter';

  @override
  String get scenes_field_last_played_at => 'Last Played At';

  @override
  String get scenes_field_resume_time => 'Resume Time';

  @override
  String get scenes_field_interactive_speed => 'Interactive Speed';

  @override
  String get scenes_field_id => 'ID';

  @override
  String get scenes_field_stash_id_count => 'Stash ID Count';

  @override
  String get scenes_field_oshash => 'Oshash';

  @override
  String get scenes_field_checksum => 'Checksum';

  @override
  String get scenes_field_phash => 'Phash';

  @override
  String get scenes_field_created_at => 'Created At';

  @override
  String get scenes_field_updated_at => 'Updated At';

  @override
  String get cast_stopped_resuming_locally => 'Cast stopped, resuming locally';

  @override
  String get cast_stop_casting => 'Stop Casting';

  @override
  String get cast_cast => 'Cast';

  @override
  String get common_add => 'Add';

  @override
  String get common_remove => 'Remove';

  @override
  String get common_clear => 'Clear';

  @override
  String get common_download => 'Download';

  @override
  String get common_star => 'Star';

  @override
  String get settings_interface_card_title_font_size => 'Card Title Font Size';

  @override
  String get common_hint_date => 'YYYY-MM-DD';

  @override
  String get common_hint_url => 'https://...';

  @override
  String get common_hint_hex => 'FF0F766E';

  @override
  String common_px(int value) {
    return '$value px';
  }

  @override
  String common_pt(int value) {
    return '$value pt';
  }

  @override
  String common_percent(int value) {
    return '$value%';
  }

  @override
  String get settings_playback_direct_play => 'Direct-play on scene navigation';

  @override
  String get settings_playback_direct_play_subtitle =>
      'When navigating from another playing scene, directly play the new scene';
}
