// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'StashFlow';

  @override
  String get nav_scenes => 'Scènes';

  @override
  String get nav_performers => 'Acteurs';

  @override
  String get nav_studios => 'Studios';

  @override
  String get nav_tags => 'Tags';

  @override
  String get nav_galleries => 'Galeries';

  @override
  String nScenes(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString scènes',
      one: '1 scène',
      zero: 'aucune scène',
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
      other: '$countString acteurs',
      one: '1 acteur',
      zero: 'aucun acteur',
    );
    return '$_temp0';
  }

  @override
  String get common_reset => 'Réinitialiser';

  @override
  String get common_apply => 'Appliquer';

  @override
  String get common_save_default => 'Enregistrer par défaut';

  @override
  String get common_sort_method => 'Méthode de tri';

  @override
  String get common_direction => 'Direction';

  @override
  String get common_ascending => 'Croissant';

  @override
  String get common_descending => 'Décroissant';

  @override
  String get common_favorites_only => 'Favoris uniquement';

  @override
  String get common_apply_sort => 'Appliquer le tri';

  @override
  String get common_apply_filters => 'Appliquer les filtres';

  @override
  String get common_view_all => 'Voir tout';

  @override
  String get common_later => 'Plus tard';

  @override
  String get common_update_now => 'Mettre à jour maintenant';

  @override
  String get common_configure_now => 'Configurer maintenant';

  @override
  String get common_clear_rating => 'Effacer la note';

  @override
  String get common_no_media => 'Aucun média disponible';

  @override
  String get common_setup_required => 'Configuration requise';

  @override
  String get common_update_available => 'Mise à jour disponible';

  @override
  String get details_studio => 'Détails du studio';

  @override
  String get details_performer => 'Détails de lacteur';

  @override
  String get details_tag => 'Détails du tag';

  @override
  String get details_scene => 'Détails de la scène';

  @override
  String get details_gallery => 'Détails de la galerie';

  @override
  String get studios_filter_title => 'Filtrer les studios';

  @override
  String get studios_filter_saved =>
      'Préférences de filtre enregistrées par défaut';

  @override
  String get sort_name => 'Nom';

  @override
  String get sort_scene_count => 'Nombre de scènes';

  @override
  String get sort_rating => 'Note';

  @override
  String get sort_updated_at => 'Mis à jour le';

  @override
  String get sort_created_at => 'Créé le';

  @override
  String get sort_random => 'Aléatoire';

  @override
  String get studios_sort_saved => 'Préférences de tri enregistrées par défaut';

  @override
  String get studios_no_random =>
      'Aucun studio disponible pour la navigation aléatoire';

  @override
  String get tags_filter_title => 'Filtrer les tags';

  @override
  String get tags_filter_saved =>
      'Préférences de filtre enregistrées par défaut';

  @override
  String get tags_sort_saved => 'Préférences de tri enregistrées par défaut';

  @override
  String get tags_no_random =>
      'Aucun tag disponible pour la navigation aléatoire';

  @override
  String get scenes_no_random =>
      'Aucune scène disponible pour la navigation aléatoire';

  @override
  String get performers_no_random =>
      'Aucun acteur disponible pour la navigation aléatoire';

  @override
  String get galleries_no_random =>
      'Aucune galerie disponible pour la navigation aléatoire';

  @override
  String common_error(String message) {
    return 'Erreur: $message';
  }
}
