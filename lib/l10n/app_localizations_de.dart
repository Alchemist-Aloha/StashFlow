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
}
