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
  String get common_url => 'URL';

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
  String get details_tags => 'Tags';

  @override
  String get details_links => 'Liens';

  @override
  String get details_scene_scrape => 'scraper les métadonnées';

  @override
  String get details_show_more => 'Afficher plus';

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
  String get tags_search_hint => 'Rechercher des tags...';

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
  String get performers_play_count => 'Nombre de lectures';

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
  String get settings_interface_shake_random => 'Secouer pour découvrir';

  @override
  String get settings_interface_shake_random_subtitle =>
      'Secouez votre appareil pour passer à un élément aléatoire dans l\'onglet actuel';

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
  String get settings_server_url => 'URL du serveur GraphQL';

  @override
  String get settings_server_url_helper =>
      'Exemple de format : http(s)://hôte:port/graphql.';

  @override
  String get settings_server_url_example => 'http://192.168.1.100:9999/graphql';

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
  String get scenes_field_tags => 'Tags';

  @override
  String get scenes_field_urls => 'URLs';

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
  String get tags_search_placeholder => 'Rechercher des tags...';

  @override
  String get scenes_duration_short => '< 5 min.';

  @override
  String get scenes_duration_medium => '5-20 min.';

  @override
  String get scenes_duration_long => '> 20 min.';
}
