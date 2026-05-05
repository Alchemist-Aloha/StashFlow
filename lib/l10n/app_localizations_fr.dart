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
  String get common_token => 'Jeton';

  @override
  String get filter_value => 'Valeur';

  @override
  String get common_yes => 'Oui';

  @override
  String get common_no => 'Non';

  @override
  String get common_clear_history => 'Effacer l\'historique';

  @override
  String get nav_scenes => 'Scènes';

  @override
  String get nav_performers => 'Acteurs';

  @override
  String get nav_studios => 'Studios';

  @override
  String get nav_tags => 'Étiquettes';

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
  String get common_view_all => 'Tout afficher';

  @override
  String get common_default => 'Par défaut';

  @override
  String get common_later => 'Plus tard';

  @override
  String get common_update_now => 'Mettre à jour maintenant';

  @override
  String get common_configure_now => 'Configurer maintenant';

  @override
  String get common_clear_rating => 'effacer la note';

  @override
  String get common_no_media => 'Aucun média disponible';

  @override
  String get common_show => 'Afficher';

  @override
  String get common_hide => 'Masquer';

  @override
  String get galleries_filter_saved =>
      'Préférences de filtrage enregistrées par défaut';

  @override
  String get common_setup_required => 'Configuration requise';

  @override
  String get common_update_available => 'Mise à jour disponible';

  @override
  String get details_studio => 'Détails du studio';

  @override
  String get details_performer => 'Détails de l\'acteur';

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
  String get sort_file_mod_time => 'Date de modification du fichier';

  @override
  String get sort_filesize => 'Taille du fichier';

  @override
  String get sort_o_count => 'Compteur O';

  @override
  String get sort_height => 'Taille';

  @override
  String get sort_birthdate => 'Date de naissance';

  @override
  String get sort_tag_count => 'Nombre d\'étiquettes';

  @override
  String get sort_play_count => 'Nombre de lectures';

  @override
  String get sort_o_counter => 'Compteur O';

  @override
  String get sort_zip_file_count => 'Nombre de fichiers ZIP';

  @override
  String get sort_last_o_at => 'Dernier O';

  @override
  String get sort_latest_scene => 'Dernière scène';

  @override
  String get sort_career_start => 'Début de carrière';

  @override
  String get sort_career_end => 'Fin de carrière';

  @override
  String get sort_weight => 'Poids';

  @override
  String get sort_measurements => 'Mensurations';

  @override
  String get sort_scenes_duration => 'Durée des scènes';

  @override
  String get sort_scenes_size => 'Taille des scènes';

  @override
  String get sort_images_count => 'Nombre d\'images';

  @override
  String get sort_galleries_count => 'Nombre de galeries';

  @override
  String get sort_child_count => 'Nombre de sous-studios';

  @override
  String get sort_performers_count => 'Nombre d\'interprètes';

  @override
  String get sort_groups_count => 'Nombre de groupes';

  @override
  String get sort_marker_count => 'Nombre de marqueurs';

  @override
  String get sort_studios_count => 'Nombre de studios';

  @override
  String get sort_penis_length => 'Longueur du pénis';

  @override
  String get sort_last_played_at => 'Dernière lecture';

  @override
  String get studios_sort_saved => 'Préférences de tri enregistrées par défaut';

  @override
  String get studios_no_random =>
      'Aucun studio disponible pour la navigation aléatoire';

  @override
  String get tags_filter_title => 'Filtrer les étiquettes';

  @override
  String get tags_filter_saved =>
      'Préférences de filtre enregistrées par défaut';

  @override
  String get tags_sort_title => 'Trier les étiquettes';

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

  @override
  String get common_no_media_available => 'aucun média disponible';

  @override
  String common_id(Object id) {
    return 'ID : $id';
  }

  @override
  String get common_search_placeholder => 'Rechercher...';

  @override
  String get common_pause => 'pause';

  @override
  String get common_play => 'lecture';

  @override
  String get common_refresh => 'Rafraîchir';

  @override
  String get common_close => 'fermer';

  @override
  String get common_save => 'enregistrer';

  @override
  String get common_unmute => 'réactiver le son';

  @override
  String get common_mute => 'sourdine';

  @override
  String get common_back => 'retour';

  @override
  String get common_rate => 'noter';

  @override
  String get common_previous => 'précédent';

  @override
  String get common_next => 'suivant';

  @override
  String get common_favorite => 'favori';

  @override
  String get common_unfavorite => 'retirer des favoris';

  @override
  String get common_version => 'version';

  @override
  String get common_loading => 'chargement';

  @override
  String get common_unavailable => 'indisponible';

  @override
  String get common_details => 'détails';

  @override
  String get common_title => 'titre';

  @override
  String get common_release_date => 'date de sortie';

  @override
  String get common_url => 'Lien';

  @override
  String get common_no_url => 'aucune URL';

  @override
  String get common_sort => 'trier';

  @override
  String get common_filter => 'filtrer';

  @override
  String get common_search => 'rechercher';

  @override
  String get common_settings => 'paramètres';

  @override
  String get common_reset_to_1x => 'réinitialiser à 1x';

  @override
  String get common_skip_next => 'suivant';

  @override
  String get common_skip_previous => 'Skip Previous';

  @override
  String get common_select_subtitle => 'choisir sous-titre';

  @override
  String get common_playback_speed => 'vitesse de lecture';

  @override
  String get common_pip => 'image dans l\'image';

  @override
  String get common_toggle_fullscreen => 'plein écran';

  @override
  String get common_exit_fullscreen => 'quitter plein écran';

  @override
  String get common_copy_logs => 'copier les logs';

  @override
  String get common_clear_logs => 'effacer les logs';

  @override
  String get common_enable_autoscroll => 'activer défilement auto';

  @override
  String get common_disable_autoscroll => 'désactiver défilement auto';

  @override
  String get common_retry => 'Réessayer';

  @override
  String get common_no_items => 'Aucun élément trouvé';

  @override
  String get common_none => 'Aucun';

  @override
  String get common_any => 'Tous';

  @override
  String get common_name => 'Nom';

  @override
  String get common_date => 'Date';

  @override
  String get common_rating => 'Note';

  @override
  String get common_image_count => 'Nombre d\'images';

  @override
  String get common_filepath => 'Chemin du fichier';

  @override
  String get common_random => 'Aléatoire';

  @override
  String get common_no_media_found => 'Aucun média trouvé';

  @override
  String common_not_found(String item) {
    return '$item non trouvé';
  }

  @override
  String get common_add_favorite => 'Ajouter aux favoris';

  @override
  String get common_remove_favorite => 'Retirer des favoris';

  @override
  String get details_group => 'détails du groupe';

  @override
  String get details_synopsis => 'Synopsis';

  @override
  String get details_media => 'Médias';

  @override
  String get details_galleries => 'Galeries';

  @override
  String get details_tags => 'Étiquettes';

  @override
  String get details_links => 'Liens';

  @override
  String get details_scene_scrape => 'scraper les métadonnées';

  @override
  String get details_show_more => 'Afficher plus';

  @override
  String get common_more => 'More';

  @override
  String get details_show_less => 'Afficher moins';

  @override
  String get details_more_from_studio => 'Plus du studio';

  @override
  String get details_o_count_incremented => 'Nombre O incrémenté';

  @override
  String details_failed_update_rating(String error) {
    return 'Échec de la mise à jour de la note : $error';
  }

  @override
  String details_failed_update_performer(Object error) {
    return 'Échec de la mise à jour de l\'interprète : $error';
  }

  @override
  String details_failed_increment_o_count(String error) {
    return 'Échec de l\'incrément du compteur O : $error';
  }

  @override
  String get details_scene_add_performer => 'ajouter un interprète';

  @override
  String get details_scene_add_tag => 'ajouter un tag';

  @override
  String get details_scene_add_url => 'ajouter une URL';

  @override
  String get details_scene_remove_url => 'supprimer l\'URL';

  @override
  String get groups_title => 'Groupes';

  @override
  String get groups_unnamed => 'Groupe sans nom';

  @override
  String get groups_untitled => 'Groupe sans titre';

  @override
  String get studios_title => 'Studios';

  @override
  String get studios_galleries_title => 'Galeries du studio';

  @override
  String get studios_media_title => 'Médias du studio';

  @override
  String get studios_sort_title => 'Trier les studios';

  @override
  String get galleries_title => 'Galeries';

  @override
  String get galleries_sort_title => 'Trier les galeries';

  @override
  String get galleries_all_images => 'Toutes les images';

  @override
  String get galleries_filter_title => 'Filtrer les galeries';

  @override
  String get galleries_min_rating => 'Note minimale';

  @override
  String get galleries_image_count => 'Nombre d\'images';

  @override
  String get galleries_organization => 'Organisation';

  @override
  String get galleries_organized_only => 'Organisé uniquement';

  @override
  String get scenes_filter_title => 'Filtrer les scènes';

  @override
  String get scenes_filter_saved =>
      'Préférences de filtre enregistrées par défaut';

  @override
  String get scenes_watched => 'Vu';

  @override
  String get scenes_unwatched => 'Non vu';

  @override
  String get scenes_search_hint => 'Rechercher des scènes...';

  @override
  String get scenes_sort_header => 'Trier les scènes';

  @override
  String get scenes_sort_duration => 'Durée';

  @override
  String get scenes_sort_bitrate => 'Débit';

  @override
  String get scenes_sort_framerate => 'Fréquence d\'images';

  @override
  String get scenes_sort_saved_default =>
      'Préférences de tri enregistrées par défaut';

  @override
  String get scenes_sort_tooltip => 'Options de tri';

  @override
  String get tags_search_hint => 'Rechercher des étiquettes...';

  @override
  String get tags_sort_tooltip => 'Options de tri';

  @override
  String get tags_filter_tooltip => 'Options de filtrage';

  @override
  String get performers_title => 'Acteurs';

  @override
  String get performers_sort_title => 'Trier les acteurs';

  @override
  String get performers_filter_title => 'Filtrer les acteurs';

  @override
  String get performers_galleries_title => 'Toutes les galeries de l\'acteur';

  @override
  String get performers_media_title => 'Tous les médias de l\'acteur';

  @override
  String get performers_gender => 'Genre';

  @override
  String get performers_gender_any => 'Tous';

  @override
  String get performers_gender_female => 'Femme';

  @override
  String get performers_gender_male => 'Homme';

  @override
  String get performers_gender_trans_female => 'Femme trans';

  @override
  String get performers_gender_trans_male => 'Homme trans';

  @override
  String get performers_gender_intersex => 'Intersexe';

  @override
  String get performers_gender_non_binary => 'Non binaire';

  @override
  String get performers_circumcised => 'Circoncis';

  @override
  String get performers_circumcised_cut => 'Coupé';

  @override
  String get performers_circumcised_uncut => 'Non coupé';

  @override
  String get performers_play_count => 'Nombre de lectures';

  @override
  String get performers_field_disambiguation => 'Désambiguïsation';

  @override
  String get performers_field_birthdate => 'Date de naissance';

  @override
  String get performers_field_deathdate => 'Date de décès';

  @override
  String get performers_field_height_cm => 'Taille (cm)';

  @override
  String get performers_field_weight_kg => 'Poids (kg)';

  @override
  String get performers_field_measurements => 'Mensurations';

  @override
  String get performers_field_fake_tits => 'Seins artificiels';

  @override
  String get performers_field_penis_length => 'Longueur du pénis';

  @override
  String get performers_field_ethnicity => 'Ethnicité';

  @override
  String get performers_field_country => 'Pays';

  @override
  String get performers_field_eye_color => 'Couleur des yeux';

  @override
  String get performers_field_hair_color => 'Couleur des cheveux';

  @override
  String get performers_field_career_start => 'Début de carrière';

  @override
  String get performers_field_career_end => 'Fin de carrière';

  @override
  String get performers_field_tattoos => 'Tatouages';

  @override
  String get performers_field_piercings => 'Piercings';

  @override
  String get performers_field_aliases => 'Alias';

  @override
  String get common_organized => 'Organisé';

  @override
  String get scenes_duplicated => 'Dupliqué';

  @override
  String get random_studio => 'studio aléatoire';

  @override
  String get random_gallery => 'galerie aléatoire';

  @override
  String get random_tag => 'tag aléatoire';

  @override
  String get random_scene => 'scène aléatoire';

  @override
  String get random_performer => 'interprète aléatoire';

  @override
  String get filter_modifier => 'Modificateur';

  @override
  String get filter_equals => 'Égal';

  @override
  String get filter_not_equals => 'Pas égal';

  @override
  String get filter_greater_than => 'Plus grand que';

  @override
  String get filter_less_than => 'Moins que';

  @override
  String get filter_is_null => 'Est nul';

  @override
  String get filter_not_null => 'N\'est pas nul';

  @override
  String get images_resolution_title => 'Résolution';

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
  String get common_or => 'OU';

  @override
  String get scrape_from_url => 'Extraire depuis l\'URL';

  @override
  String get scenes_phash_started => 'Génération de phash commencée';

  @override
  String scenes_phash_failed(Object error) {
    return 'Échec de la génération de phash : $error';
  }

  @override
  String details_failed_update_studio(Object error) {
    return 'Échec de la mise à jour du studio : $error';
  }

  @override
  String get settings_title => 'Paramètres';

  @override
  String get settings_customize => 'Personnaliser StashFlow';

  @override
  String get settings_customize_subtitle =>
      'Réglez la lecture, l\'apparence, la disposition et les outils de support en un seul endroit.';

  @override
  String get settings_core_section => 'Paramètres de base';

  @override
  String get settings_core_subtitle =>
      'Pages de configuration les plus utilisées';

  @override
  String get settings_server => 'Serveur';

  @override
  String get settings_server_subtitle =>
      'Configuration de la connexion et de l\'API';

  @override
  String get settings_playback => 'Lecture';

  @override
  String get settings_playback_subtitle =>
      'Comportement du lecteur et interactions';

  @override
  String get settings_keyboard => 'Clavier';

  @override
  String get settings_keyboard_subtitle =>
      'Raccourcis et touches de raccourci personnalisables';

  @override
  String get settings_keyboard_title => 'Raccourcis clavier';

  @override
  String get settings_keyboard_reset_defaults => 'Réinitialiser par défaut';

  @override
  String get settings_keyboard_not_bound => 'Non lié';

  @override
  String get settings_keyboard_volume_up => 'Augmenter le volume';

  @override
  String get settings_keyboard_volume_down => 'Diminuer le volume';

  @override
  String get settings_keyboard_toggle_mute => 'Couper/Rétablir le son';

  @override
  String get settings_keyboard_toggle_fullscreen => 'Plein écran';

  @override
  String get settings_keyboard_next_scene => 'Scène suivante';

  @override
  String get settings_keyboard_prev_scene => 'Scène précédente';

  @override
  String get settings_keyboard_increase_speed =>
      'Augmenter la vitesse de lecture';

  @override
  String get settings_keyboard_decrease_speed =>
      'Diminuer la vitesse de lecture';

  @override
  String get settings_keyboard_reset_speed =>
      'Réinitialiser la vitesse de lecture';

  @override
  String get settings_keyboard_close_player => 'Fermer le lecteur';

  @override
  String get settings_keyboard_next_image => 'Image suivante';

  @override
  String get settings_keyboard_prev_image => 'Image précédente';

  @override
  String get settings_keyboard_go_back => 'Retour';

  @override
  String get settings_keyboard_play_pause_desc =>
      'Basculer entre lecture et pause';

  @override
  String get settings_keyboard_seek_forward_5_desc => 'Avancer de 5 secondes';

  @override
  String get settings_keyboard_seek_backward_5_desc => 'Reculer de 5 secondes';

  @override
  String get settings_keyboard_seek_forward_10_desc => 'Avancer de 10 secondes';

  @override
  String get settings_keyboard_seek_backward_10_desc =>
      'Reculer de 10 secondes';

  @override
  String get settings_appearance => 'Apparence';

  @override
  String get settings_appearance_subtitle => 'Thème et couleurs';

  @override
  String get settings_interface => 'Interface';

  @override
  String get settings_interface_subtitle =>
      'Valeurs par défaut de navigation et de disposition';

  @override
  String get settings_support => 'Support';

  @override
  String get settings_support_subtitle => 'Diagnostics et à propos';

  @override
  String get settings_develop => 'Développer';

  @override
  String get settings_develop_subtitle => 'Outils avancés et surcharges';

  @override
  String get settings_appearance_title => 'Paramètres d\'apparence';

  @override
  String get settings_appearance_theme_mode => 'Mode de thème';

  @override
  String get settings_appearance_theme_mode_subtitle =>
      'Choisissez comment l\'application suit les changements de luminosité';

  @override
  String get settings_appearance_theme_system => 'Système';

  @override
  String get settings_appearance_theme_light => 'Clair';

  @override
  String get settings_appearance_theme_dark => 'Sombre';

  @override
  String get settings_appearance_primary_color => 'Couleur principale';

  @override
  String get settings_appearance_primary_color_subtitle =>
      'Choisissez une couleur de base pour la palette Material 3';

  @override
  String get settings_appearance_advanced_theming => 'Thématisation avancée';

  @override
  String get settings_appearance_advanced_theming_subtitle =>
      'Optimisations pour des types d\'écran spécifiques';

  @override
  String get settings_appearance_true_black => 'Noir pur (AMOLED)';

  @override
  String get settings_appearance_true_black_subtitle =>
      'Utilisez des arrière-plans noir pur en mode sombre pour économiser la batterie sur les écrans OLED';

  @override
  String get settings_appearance_custom_hex => 'Couleur Hex personnalisée';

  @override
  String get settings_appearance_custom_hex_helper =>
      'Entrez un code hexadécimal ARGB à 8 chiffres';

  @override
  String get settings_appearance_font_size =>
      'Échelle mondiale de l\'interface utilisateur';

  @override
  String get settings_appearance_font_size_subtitle =>
      'Mettre à l\'échelle la typographie et l\'espacement proportionnellement';

  @override
  String get settings_interface_title => 'Paramètres d\'interface';

  @override
  String get settings_interface_language => 'Langue';

  @override
  String get settings_interface_language_subtitle =>
      'Surcharger la langue par défaut du système';

  @override
  String get settings_interface_app_language => 'Langue de l\'application';

  @override
  String get settings_interface_navigation => 'Navigation';

  @override
  String get settings_interface_navigation_subtitle =>
      'Visibilité des raccourcis de navigation globaux';

  @override
  String get settings_interface_show_random =>
      'Afficher les boutons de navigation aléatoire';

  @override
  String get settings_interface_show_random_subtitle =>
      'Activer ou désactiver les boutons flottants de casino sur les pages de liste et de détails';

  @override
  String get settings_interface_main_pages_gravity_orientation =>
      'Orientation contrôlée par la gravité (pages principales)';

  @override
  String get settings_interface_main_pages_gravity_orientation_subtitle =>
      'Autoriser les pages principales à pivoter à l\'aide du capteur de l\'appareil. La lecture vidéo en plein écran utilise ses propres paramètres d\'orientation.';

  @override
  String get settings_interface_show_edit => 'Afficher le bouton d\'édition';

  @override
  String get settings_interface_show_edit_subtitle =>
      'Activer ou désactiver le bouton d\'édition sur la page de détails de la scène';

  @override
  String get settings_interface_customize_tabs => 'Personnaliser les onglets';

  @override
  String get settings_interface_customize_tabs_subtitle =>
      'Réorganiser ou masquer les éléments du menu de navigation';

  @override
  String get settings_interface_scenes_layout => 'Disposition des scènes';

  @override
  String get settings_interface_scenes_layout_subtitle =>
      'Mode de navigation par défaut pour les scènes';

  @override
  String get settings_interface_galleries_layout => 'Disposition des galeries';

  @override
  String get settings_interface_galleries_layout_subtitle =>
      'Mode de navigation par défaut pour les galeries';

  @override
  String get settings_interface_max_performer_avatars =>
      'Max d\'avatars d\'interprètes';

  @override
  String get settings_interface_max_performer_avatars_subtitle =>
      'Nombre maximum d\'avatars d\'interprètes à afficher dans la carte de scène.';

  @override
  String get settings_interface_show_performer_avatars =>
      'Afficher les avatars des interprètes';

  @override
  String get settings_interface_show_performer_avatars_subtitle =>
      'Afficher les icônes des interprètes sur les cartes de scène sur toutes les plateformes.';

  @override
  String get settings_interface_performer_avatar_size =>
      'Taille de l\'avatar de l\'interprète';

  @override
  String get settings_interface_layout_default => 'Disposition par défaut';

  @override
  String get settings_interface_layout_default_desc =>
      'Choisissez la disposition par défaut pour la page';

  @override
  String get settings_interface_layout_list => 'Liste';

  @override
  String get settings_interface_layout_grid => 'Grille';

  @override
  String get settings_interface_layout_tiktok => 'Défilement infini';

  @override
  String get settings_interface_grid_columns => 'Colonnes de la grille';

  @override
  String get settings_interface_image_viewer => 'Visionneuse d\'images';

  @override
  String get settings_interface_image_viewer_subtitle =>
      'Configurer le comportement de navigation d\'images en plein écran';

  @override
  String get settings_interface_swipe_direction =>
      'Direction de balayage plein écran';

  @override
  String get settings_interface_swipe_direction_desc =>
      'Choisissez comment les images avancent en mode plein écran';

  @override
  String get settings_interface_swipe_vertical => 'Vertical';

  @override
  String get settings_interface_swipe_horizontal => 'Horizontal';

  @override
  String get settings_interface_waterfall_columns =>
      'Colonnes de la grille en cascade';

  @override
  String get settings_interface_performer_layouts => 'Dispositions des acteurs';

  @override
  String get settings_interface_performer_layouts_subtitle =>
      'Valeurs par défaut des médias et galeries pour les acteurs';

  @override
  String get settings_interface_studio_layouts => 'Dispositions des studios';

  @override
  String get settings_interface_studio_layouts_subtitle =>
      'Valeurs par défaut des médias et galeries pour les studios';

  @override
  String get settings_interface_tag_layouts => 'Dispositions des tags';

  @override
  String get settings_interface_tag_layouts_subtitle =>
      'Valeurs par défaut des médias et galeries pour les tags';

  @override
  String get settings_interface_media_layout => 'Disposition des médias';

  @override
  String get settings_interface_media_layout_subtitle =>
      'Disposition pour la page Médias';

  @override
  String get settings_interface_galleries_layout_item =>
      'Disposition des galeries';

  @override
  String get settings_interface_galleries_layout_subtitle_item =>
      'Disposition pour la page Galeries';

  @override
  String get settings_server_title => 'Paramètres du serveur';

  @override
  String get settings_server_status => 'État de la connexion';

  @override
  String get settings_server_status_subtitle =>
      'Connectivité en direct avec le serveur configuré';

  @override
  String get settings_server_details => 'Détails du serveur';

  @override
  String get settings_server_details_subtitle =>
      'Configurer le point de terminaison et la méthode d\'authentification';

  @override
  String get settings_server_url => 'URL de Stash';

  @override
  String get settings_server_url_helper =>
      'Entrez l\'URL de votre serveur Stash. Si un chemin personnalisé est configuré, incluez-le ici.';

  @override
  String get settings_server_url_example => 'http://192.168.1.100:9999';

  @override
  String get settings_server_login_failed => 'Échec de la connexion';

  @override
  String get settings_server_auth_method => 'Méthode d\'authentification';

  @override
  String get settings_server_auth_apikey => 'Clé API';

  @override
  String get settings_server_auth_password => 'Utilisateur + Mot de passe';

  @override
  String get settings_server_auth_password_desc =>
      'Recommandé : utilisez votre session utilisateur/mot de passe Stash.';

  @override
  String get settings_server_auth_apikey_desc =>
      'Utilisez une clé API pour l\'authentification par jeton statique.';

  @override
  String get settings_server_username => 'Nom d\'utilisateur';

  @override
  String get settings_server_password => 'Mot de passe';

  @override
  String get settings_server_login_test => 'Connexion & Test';

  @override
  String get settings_server_test => 'Tester la connexion';

  @override
  String get settings_server_logout => 'Déconnexion';

  @override
  String get settings_server_clear => 'Effacer les paramètres';

  @override
  String settings_server_connected(String version) {
    return 'Connecté (Stash $version)';
  }

  @override
  String get settings_server_checking => 'Vérification de la connexion...';

  @override
  String settings_server_failed(String error) {
    return 'Échec : $error';
  }

  @override
  String get settings_server_invalid_url => 'URL du serveur invalide';

  @override
  String get settings_server_resolve_error =>
      'Impossible de résoudre l\'URL du serveur. Vérifiez l\'hôte, le port et les identifiants.';

  @override
  String get settings_server_logout_confirm => 'Déconnecté et cookies effacés.';

  @override
  String get settings_server_profile_add => 'Ajouter un profil';

  @override
  String get settings_server_profile_edit => 'Modifier le profil';

  @override
  String get settings_server_profile_name => 'Nom du profil';

  @override
  String get settings_server_profile_delete => 'Supprimer le profil';

  @override
  String get settings_server_profile_delete_confirm =>
      'Êtes-vous sûr de vouloir supprimer ce profil ? Cette action est irréversible.';

  @override
  String get settings_server_profile_active => 'Actif';

  @override
  String get settings_server_profile_empty =>
      'Aucun profil de serveur configuré';

  @override
  String get settings_server_profiles => 'Profils de serveur';

  @override
  String get settings_server_profiles_subtitle =>
      'Gérer plusieurs connexions au serveur Stash';

  @override
  String get settings_server_auth_status_logging_in =>
      'État d\'authentification : connexion en cours...';

  @override
  String get settings_server_auth_status_logged_in =>
      'État d\'authentification : connecté';

  @override
  String get settings_server_auth_status_logged_out =>
      'État d\'authentification : déconnecté';

  @override
  String get settings_playback_title => 'Paramètres de lecture';

  @override
  String get settings_playback_behavior => 'Comportement de lecture';

  @override
  String get settings_playback_behavior_subtitle =>
      'Gestion par défaut de la lecture et de l\'arrière-plan';

  @override
  String get settings_playback_prefer_streams =>
      'Préférer sceneStreams en premier';

  @override
  String get settings_playback_prefer_streams_subtitle =>
      'Si désactivé, la lecture utilise directement paths.stream';

  @override
  String get settings_playback_end_behavior => 'Comportement de fin de lecture';

  @override
  String get settings_playback_end_behavior_subtitle =>
      'Que faire lorsque la lecture en cours se termine';

  @override
  String get settings_playback_end_behavior_stop => 'Arrêt';

  @override
  String get settings_playback_end_behavior_loop => 'Scène actuelle en boucle';

  @override
  String get settings_playback_end_behavior_next => 'Jouer la scène suivante';

  @override
  String get settings_playback_autoplay =>
      'Lecture automatique de la scène suivante';

  @override
  String get settings_playback_autoplay_subtitle =>
      'Lire automatiquement la scène suivante à la fin de la lecture actuelle';

  @override
  String get settings_playback_background => 'Lecture en arrière-plan';

  @override
  String get settings_playback_background_subtitle =>
      'Garder l\'audio de la vidéo pendant que l\'application est en arrière-plan';

  @override
  String get settings_playback_pip => 'Image dans l\'image native';

  @override
  String get settings_playback_pip_subtitle =>
      'Activer le bouton PiP Android et l\'entrée automatique en arrière-plan';

  @override
  String get settings_playback_subtitles => 'Paramètres des sous-titres';

  @override
  String get settings_playback_subtitles_subtitle =>
      'Chargement automatique et apparence';

  @override
  String get settings_playback_subtitle_lang =>
      'Langue par défaut des sous-titres';

  @override
  String get settings_playback_subtitle_lang_subtitle =>
      'Chargement automatique si disponible';

  @override
  String get settings_playback_subtitle_size =>
      'Taille de la police des sous-titres';

  @override
  String get settings_playback_subtitle_pos =>
      'Position verticale des sous-titres';

  @override
  String settings_playback_subtitle_pos_desc(String percent) {
    return '$percent% du bas';
  }

  @override
  String get settings_playback_subtitle_align =>
      'Alignement du texte des sous-titres';

  @override
  String get settings_playback_subtitle_align_subtitle =>
      'Alignement pour les sous-titres multilignes';

  @override
  String get settings_playback_seek => 'Interaction de recherche';

  @override
  String get settings_playback_seek_subtitle =>
      'Choisissez comment le défilement fonctionne pendant la lecture';

  @override
  String get settings_playback_seek_double_tap =>
      'Appuyez deux fois à gauche/droite pour avancer/reculer de 10s';

  @override
  String get settings_playback_seek_drag =>
      'Faire glisser la chronologie pour chercher';

  @override
  String get settings_playback_seek_drag_label => 'Glisser';

  @override
  String get settings_playback_seek_double_tap_label => 'Double-appui';

  @override
  String get settings_playback_gravity_orientation =>
      'Orientation contrôlée par la gravité';

  @override
  String get settings_playback_gravity_orientation_subtitle =>
      'Permettre la rotation entre orientations correspondantes à l\'aide du capteur de l\'appareil (par ex. basculer paysage gauche/droite).';

  @override
  String get settings_playback_subtitle_lang_none_disabled =>
      'Aucun (Désactivé)';

  @override
  String get settings_playback_subtitle_lang_auto_if_only_one =>
      'Automatique (S\'il n\'y en a qu\'un)';

  @override
  String get settings_playback_subtitle_lang_english => 'Anglais';

  @override
  String get settings_playback_subtitle_lang_chinese => 'Chinois';

  @override
  String get settings_playback_subtitle_lang_german => 'Allemand';

  @override
  String get settings_playback_subtitle_lang_french => 'Français';

  @override
  String get settings_playback_subtitle_lang_spanish => 'Espagnol';

  @override
  String get settings_playback_subtitle_lang_italian => 'Italien';

  @override
  String get settings_playback_subtitle_lang_japanese => 'Japonais';

  @override
  String get settings_playback_subtitle_lang_korean => 'Coréen';

  @override
  String get settings_playback_subtitle_align_left => 'Gauche';

  @override
  String get settings_playback_subtitle_align_center => 'Centre';

  @override
  String get settings_playback_subtitle_align_right => 'Droite';

  @override
  String get settings_support_title => 'Support';

  @override
  String get settings_support_diagnostics =>
      'Diagnostics et informations du projet';

  @override
  String get settings_support_diagnostics_subtitle =>
      'Ouvrez les journaux d\'exécution ou allez au dépôt si vous avez besoin d\'aide.';

  @override
  String get settings_support_update_available => 'Mise à jour disponible';

  @override
  String get settings_support_update_available_subtitle =>
      'Une nouvelle version est disponible sur GitHub';

  @override
  String settings_support_update_to(String version) {
    return 'Mettre à jour vers $version';
  }

  @override
  String get settings_support_update_to_subtitle =>
      'De nouvelles fonctionnalités et améliorations vous attendent.';

  @override
  String get settings_support_about => 'À propos';

  @override
  String get settings_support_about_subtitle =>
      'Informations sur le projet et la source';

  @override
  String get settings_support_version => 'Version';

  @override
  String get settings_support_version_loading =>
      'Chargement des informations de version...';

  @override
  String get settings_support_version_unavailable =>
      'Informations de version indisponibles';

  @override
  String get settings_support_github => 'Dépôt GitHub';

  @override
  String get settings_support_github_subtitle =>
      'Voir le code source et signaler des problèmes';

  @override
  String get settings_support_github_error =>
      'Impossible d\'ouvrir le lien GitHub';

  @override
  String get settings_support_issues => 'Signaler un problème';

  @override
  String get settings_support_issues_subtitle =>
      'Aidez à améliorer StashFlow en signalant les bugs';

  @override
  String get settings_develop_title => 'Développer';

  @override
  String get settings_develop_diagnostics => 'Outils de diagnostic';

  @override
  String get settings_develop_diagnostics_subtitle =>
      'Dépannage et performances';

  @override
  String get settings_develop_video_debug =>
      'Afficher les infos de débogage vidéo';

  @override
  String get settings_develop_video_debug_subtitle =>
      'Afficher les détails techniques de lecture en superposition sur le lecteur vidéo.';

  @override
  String get settings_develop_log_viewer =>
      'Visionneuse de journaux de débogage';

  @override
  String get settings_develop_log_viewer_subtitle =>
      'Ouvrir une vue en direct des journaux de l\'application.';

  @override
  String get settings_develop_logs_copied =>
      'Journaux copiés dans le presse-papiers';

  @override
  String get settings_develop_no_logs =>
      'Pas encore de journaux. Interagissez avec l\'application pour capturer des journaux.';

  @override
  String get settings_develop_web_overrides => 'Surcharges Web';

  @override
  String get settings_develop_web_overrides_subtitle =>
      'Drapeaux avancés pour la plateforme Web';

  @override
  String get settings_develop_web_auth =>
      'Autoriser la connexion par mot de passe sur le Web';

  @override
  String get settings_develop_web_auth_subtitle =>
      'Surcharge la restriction native uniquement et force la visibilité de la méthode d\'authentification Utilisateur + Mot de passe sur Flutter Web.';

  @override
  String get settings_develop_proxy_auth =>
      'Activer les modes d\'authentification proxy';

  @override
  String get settings_develop_proxy_auth_subtitle =>
      'Activez les méthodes avancées Basic Auth et Bearer Token pour une utilisation avec des backends sans authentification derrière des proxys comme Authentik.';

  @override
  String get settings_server_auth_basic => 'Authentification de base';

  @override
  String get settings_server_auth_bearer => 'Jeton porteur';

  @override
  String get settings_server_auth_basic_desc =>
      'Envoie l\'en-tête \'Authorization: Basic <base64(user:pass)>\'.';

  @override
  String get settings_server_auth_bearer_desc =>
      'Envoie l\'en-tête \'Authorization: Bearer <token>\'.';

  @override
  String get common_edit => 'Modifier';

  @override
  String get common_resolution => 'Résolution';

  @override
  String get common_orientation => 'Orientation';

  @override
  String get common_landscape => 'Paysage';

  @override
  String get common_portrait => 'Portrait';

  @override
  String get common_square => 'Carré';

  @override
  String get performers_filter_saved =>
      'Préférences de filtre enregistrées comme défaut';

  @override
  String get images_title => 'Images';

  @override
  String get images_filter_title => 'Filtrer les images';

  @override
  String get images_filter_saved =>
      'Préférences de filtre enregistrées par défaut';

  @override
  String get images_sort_title => 'Trier les images';

  @override
  String get images_sort_saved =>
      'Préférences de tri enregistrées comme défaut';

  @override
  String get image_rating_updated => 'Évaluation de l\'image mise à jour.';

  @override
  String get gallery_rating_updated => 'Évaluation de la galerie mise à jour.';

  @override
  String get common_image => 'Image';

  @override
  String get common_gallery => 'Galerie';

  @override
  String get images_gallery_rating_unavailable =>
      'La note de la galerie n\'est disponible que lors de la navigation dans une galerie.';

  @override
  String images_rating(String rating) {
    return 'Note : $rating / 5';
  }

  @override
  String get images_filtered_by_gallery => 'Filtré par galerie';

  @override
  String get images_slideshow_need_two =>
      'Il faut au moins 2 images pour le diaporama.';

  @override
  String get images_slideshow_start_title => 'Démarrer le diaporama';

  @override
  String images_slideshow_interval(num seconds) {
    return 'Intervalle : ${seconds}s';
  }

  @override
  String images_slideshow_transition_ms(num ms) {
    return 'Transition : ${ms}ms';
  }

  @override
  String get common_forward => 'Avant';

  @override
  String get common_backward => 'Arrière';

  @override
  String get images_slideshow_loop_title => 'Boucle du diaporama';

  @override
  String get common_cancel => 'Annuler';

  @override
  String get common_start => 'Démarrer';

  @override
  String get common_done => 'Terminé';

  @override
  String get settings_keybind_assign_shortcut => 'Attribuer un raccourci';

  @override
  String get settings_keybind_press_any =>
      'Appuyez sur n\'importe quelle combinaison de touches...';

  @override
  String get scenes_select_tags => 'Sélectionner des tags';

  @override
  String get scenes_no_scrapers => 'Aucun scrapper disponible';

  @override
  String get scenes_select_scraper => 'Sélectionner un scrapper';

  @override
  String get scenes_no_results_found => 'Aucun résultat trouvé';

  @override
  String get scenes_select_result => 'Sélectionner un résultat';

  @override
  String scenes_scrape_failed(String error) {
    return 'Échec de l\'extraction : $error';
  }

  @override
  String get scenes_updated_successfully => 'Scène mise à jour avec succès';

  @override
  String scenes_update_failed(String error) {
    return 'Échec de la mise à jour de la scène : $error';
  }

  @override
  String get scenes_edit_title => 'Modifier la scène';

  @override
  String get scenes_field_studio => 'Studio';

  @override
  String get scenes_field_tags => 'Étiquettes';

  @override
  String get scenes_field_urls => 'Liens';

  @override
  String get scenes_edit_performer => 'Modifier l\'interprète';

  @override
  String get scenes_edit_studio => 'Modifier le studio';

  @override
  String get common_no_title => 'Sans titre';

  @override
  String get scenes_select_studio => 'Sélectionner un studio';

  @override
  String get scenes_select_performers => 'Sélectionner des interprètes';

  @override
  String get scenes_unmatched_scraped_tags => 'Tags récupérés non appariés';

  @override
  String get scenes_unmatched_scraped_performers =>
      'Interprètes récupérés non appariés';

  @override
  String get scenes_no_matching_performer_found =>
      'Aucun interprète correspondant trouvé dans la bibliothèque';

  @override
  String get common_unknown => 'Inconnu';

  @override
  String scenes_studio_id_prefix(String id) {
    return 'ID du studio : $id';
  }

  @override
  String get tags_search_placeholder => 'Rechercher des étiquettes...';

  @override
  String get scenes_duration_short => '< 5 min.';

  @override
  String get scenes_duration_medium => '5-20 min.';

  @override
  String get scenes_duration_long => '> 20 min.';

  @override
  String get details_scene_fingerprint_query =>
      'Requête d\'empreinte de la scène';

  @override
  String get scenes_available_scrapers => 'Scrapers disponibles';

  @override
  String get scrape_results_existing => 'Existant';

  @override
  String get scrape_results_scraped => 'Récupéré';

  @override
  String get stats_refresh_statistics => 'Actualiser les statistiques';

  @override
  String get stats_library_stats => 'Statistiques de la bibliothèque';

  @override
  String get stats_stash_glance => 'Votre réserve en un coup d\'œil';

  @override
  String get stats_content => 'Contenu';

  @override
  String get stats_organization => 'Organisation';

  @override
  String get stats_activity => 'Activité';

  @override
  String get stats_scenes => 'Scènes';

  @override
  String get stats_galleries => 'Galeries';

  @override
  String get stats_performers => 'Interprètes';

  @override
  String get stats_studios => 'Ateliers';

  @override
  String get stats_groups => 'Groupes';

  @override
  String get stats_tags => 'Balises';

  @override
  String get stats_total_plays => 'Nombre total de lectures';

  @override
  String stats_unique_items(int count) {
    return '$count unique items';
  }

  @override
  String get stats_total_o_count => 'Nombre total d\'O';

  @override
  String get cast_airplay_pairing => 'Couplage AirPlay';

  @override
  String get cast_enter_pin =>
      'Saisissez le code PIN à 4 chiffres affiché sur votre téléviseur';

  @override
  String get cast_pair => 'Paire';

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
  String get cast_searching => 'Recherche d\'appareils...';

  @override
  String get cast_cast_to_device => 'Caster sur l\'appareil';

  @override
  String get settings_storage_images => 'Images';

  @override
  String get settings_storage_videos => 'Vidéos';

  @override
  String get settings_storage_database => 'Base de données';

  @override
  String get settings_storage_clearing_image => 'Vider le cache des images...';

  @override
  String get settings_storage_clearing_video => 'Vider le cache vidéo...';

  @override
  String get settings_storage_clearing_database =>
      'Vider le cache de la base de données...';

  @override
  String get settings_storage_cleared_image => 'Cache d\'images vidé';

  @override
  String get settings_storage_cleared_video => 'Cache vidéo vidé';

  @override
  String get settings_storage_cleared_database =>
      'Cache de base de données vidé';

  @override
  String get settings_storage_clear => 'Clair';

  @override
  String get settings_storage_error_loading =>
      'Erreur de chargement des tailles';

  @override
  String settings_storage_mb(num value) {
    return '$value MB';
  }

  @override
  String settings_storage_gb(num value) {
    return '$value GB';
  }

  @override
  String get settings_storage_100_mb => '100 Mo';

  @override
  String get settings_storage_500_mb => '500 Mo';

  @override
  String get settings_storage_1_gb => '1 Go';

  @override
  String get settings_storage_2_gb => '2 Go';

  @override
  String get settings_storage_unlimited => 'Illimité';

  @override
  String get settings_storage_limits => 'Limites';

  @override
  String get settings_storage_limits_subtitle =>
      'Définir les tailles maximales de cache';

  @override
  String get settings_storage_max_image_cache => 'Cache d\'images maximum (Mo)';

  @override
  String get settings_storage_max_video_cache => 'Cache vidéo maximum (Mo)';

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
