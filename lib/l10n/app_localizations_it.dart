// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'StashFlow';

  @override
  String get nav_scenes => 'Scene';

  @override
  String get nav_performers => 'Attori';

  @override
  String get nav_studios => 'Studi';

  @override
  String get nav_tags => 'Tag';

  @override
  String get nav_galleries => 'Gallerie';

  @override
  String nScenes(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString scene',
      one: '1 scena',
      zero: 'nessuna scena',
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
      other: '$countString attori',
      one: '1 attore',
      zero: 'nessun attore',
    );
    return '$_temp0';
  }

  @override
  String get common_reset => 'Ripristina';

  @override
  String get common_apply => 'Applica';

  @override
  String get common_save_default => 'Salva come predefinito';

  @override
  String get common_sort_method => 'Metodo di ordinamento';

  @override
  String get common_direction => 'Direzione';

  @override
  String get common_ascending => 'Crescente';

  @override
  String get common_descending => 'Decrescente';

  @override
  String get common_favorites_only => 'Solo preferiti';

  @override
  String get common_apply_sort => 'Applica ordinamento';

  @override
  String get common_apply_filters => 'Applica filtri';

  @override
  String get common_view_all => 'Vedi tutto';

  @override
  String get common_later => 'Più tardi';

  @override
  String get common_update_now => 'Aggiorna ora';

  @override
  String get common_configure_now => 'Configura ora';

  @override
  String get common_clear_rating => 'Cancella valutazione';

  @override
  String get common_no_media => 'Nessun media disponibile';

  @override
  String get common_setup_required => 'Configurazione richiesta';

  @override
  String get common_update_available => 'Aggiornamento disponibile';

  @override
  String get details_studio => 'Dettagli studio';

  @override
  String get details_performer => 'Dettagli attore';

  @override
  String get details_tag => 'Dettagli tag';

  @override
  String get details_scene => 'Dettagli scena';

  @override
  String get details_gallery => 'Dettagli galleria';

  @override
  String get studios_filter_title => 'Filtra studi';

  @override
  String get studios_filter_saved =>
      'Preferenze filtro salvate come predefinite';

  @override
  String get sort_name => 'Nome';

  @override
  String get sort_scene_count => 'Numero di scene';

  @override
  String get sort_rating => 'Valutazione';

  @override
  String get sort_updated_at => 'Aggiornato il';

  @override
  String get sort_created_at => 'Creato il';

  @override
  String get sort_random => 'Casuale';

  @override
  String get studios_sort_saved =>
      'Preferenze ordinamento salvate come predefinite';

  @override
  String get studios_no_random =>
      'Nessuno studio disponibile per la navigazione casuale';

  @override
  String get tags_filter_title => 'Filtra tag';

  @override
  String get tags_filter_saved => 'Preferenze filtro salvate come predefinite';

  @override
  String get tags_sort_saved =>
      'Preferenze ordinamento salvate come predefinite';

  @override
  String get tags_no_random =>
      'Nessun tag disponibile per la navigazione casuale';

  @override
  String get scenes_no_random =>
      'Nessuna scena disponibile per la navigazione casuale';

  @override
  String get performers_no_random =>
      'Nessun attore disponibile per la navigazione casuale';

  @override
  String get galleries_no_random =>
      'Nessuna galleria disponibile per la navigazione casuale';

  @override
  String common_error(String message) {
    return 'Errore: $message';
  }
}
