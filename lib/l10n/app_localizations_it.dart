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
  String get nav_tags => 'Etichette';

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
  String get common_reset => 'Ripristina';

  @override
  String get common_apply => 'Applica';

  @override
  String get common_save_default => 'Salva come Predefinito';

  @override
  String get common_sort_method => 'Metodo di Ordinamento';

  @override
  String get common_direction => 'Direzione';

  @override
  String get common_ascending => 'Crescente';

  @override
  String get common_descending => 'Decrescente';

  @override
  String get common_favorites_only => 'Solo preferiti';

  @override
  String get common_apply_sort => 'Applica Ordinamento';

  @override
  String get common_apply_filters => 'Applica Filtri';

  @override
  String get common_view_all => 'Vedi tutto';

  @override
  String get common_default => 'Predefinito';

  @override
  String get common_later => 'Più tardi';

  @override
  String get common_update_now => 'Aggiorna Ora';

  @override
  String get common_configure_now => 'Configura Ora';

  @override
  String get common_clear_rating => 'cancella valutazione';

  @override
  String get common_no_media => 'Nessun media disponibile';

  @override
  String get common_show => 'Mostra';

  @override
  String get common_hide => 'Nascondi';

  @override
  String get galleries_filter_saved =>
      'Preferenze filtro salvate come predefinite';

  @override
  String get common_setup_required => 'Configurazione Richiesta';

  @override
  String get common_update_available => 'Aggiornamento Disponibile';

  @override
  String get details_studio => 'Dettagli Studio';

  @override
  String get details_performer => 'Dettagli Attore';

  @override
  String get details_tag => 'Dettagli Tag';

  @override
  String get details_scene => 'Dettagli Scena';

  @override
  String get details_gallery => 'Dettagli Galleria';

  @override
  String get studios_filter_title => 'Filtra Studi';

  @override
  String get studios_filter_saved =>
      'Preferenze del filtro salvate come predefinite';

  @override
  String get sort_name => 'Nome';

  @override
  String get sort_scene_count => 'Numero di Scene';

  @override
  String get sort_rating => 'Valutazione';

  @override
  String get sort_updated_at => 'Aggiornato il';

  @override
  String get sort_created_at => 'Creato il';

  @override
  String get sort_random => 'Casuale';

  @override
  String get sort_file_mod_time => 'Ora di modifica del file';

  @override
  String get sort_filesize => 'Dimensione file';

  @override
  String get sort_o_count => 'Contatore O';

  @override
  String get sort_height => 'Altezza';

  @override
  String get sort_birthdate => 'Data di nascita';

  @override
  String get sort_tag_count => 'Numero tag';

  @override
  String get sort_play_count => 'Riproduzioni';

  @override
  String get sort_o_counter => 'Contatore O';

  @override
  String get sort_zip_file_count => 'Numero di file ZIP';

  @override
  String get sort_last_o_at => 'Ultimo O';

  @override
  String get sort_latest_scene => 'Ultima scena';

  @override
  String get sort_career_start => 'Inizio carriera';

  @override
  String get sort_career_end => 'Fine carriera';

  @override
  String get sort_weight => 'Peso';

  @override
  String get sort_measurements => 'Misure';

  @override
  String get sort_scenes_duration => 'Durata scene';

  @override
  String get sort_scenes_size => 'Dimensione scene';

  @override
  String get sort_images_count => 'Numero di immagini';

  @override
  String get sort_galleries_count => 'Numero di gallerie';

  @override
  String get sort_child_count => 'Numero sotto-studio';

  @override
  String get sort_performers_count => 'Numero di interpreti';

  @override
  String get sort_groups_count => 'Numero di gruppi';

  @override
  String get sort_marker_count => 'Numero di marker';

  @override
  String get sort_studios_count => 'Numero di studi';

  @override
  String get sort_penis_length => 'Lunghezza del pene';

  @override
  String get sort_last_played_at => 'Ultima riproduzione';

  @override
  String get studios_sort_saved =>
      'Preferenze di ordinamento salvate come predefinite';

  @override
  String get studios_no_random =>
      'Nessuno studio disponibile per la navigazione casuale';

  @override
  String get tags_filter_title => 'Filtra Etichette';

  @override
  String get tags_filter_saved =>
      'Preferenze del filtro salvate come predefinite';

  @override
  String get tags_sort_title => 'Ordina Etichette';

  @override
  String get tags_sort_saved =>
      'Preferenze di ordinamento salvate come predefinite';

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

  @override
  String get common_no_media_available => 'nessun media disponibile';

  @override
  String common_id(Object id) {
    return 'ID: $id';
  }

  @override
  String get common_search_placeholder => 'Cerca...';

  @override
  String get common_pause => 'pausa';

  @override
  String get common_play => 'riproduci';

  @override
  String get common_close => 'chiudi';

  @override
  String get common_save => 'salva';

  @override
  String get common_unmute => 'riattiva audio';

  @override
  String get common_mute => 'muto';

  @override
  String get common_back => 'indietro';

  @override
  String get common_rate => 'valuta';

  @override
  String get common_previous => 'precedente';

  @override
  String get common_next => 'successivo';

  @override
  String get common_favorite => 'preferito';

  @override
  String get common_unfavorite => 'rimuovi preferito';

  @override
  String get common_version => 'versione';

  @override
  String get common_loading => 'caricamento';

  @override
  String get common_unavailable => 'non disponibile';

  @override
  String get common_details => 'dettagli';

  @override
  String get common_title => 'titolo';

  @override
  String get common_release_date => 'data di rilascio';

  @override
  String get common_url => 'Indirizzo';

  @override
  String get common_no_url => 'nessuna URL';

  @override
  String get common_sort => 'ordina';

  @override
  String get common_filter => 'filtra';

  @override
  String get common_search => 'cerca';

  @override
  String get common_settings => 'impostazioni';

  @override
  String get common_reset_to_1x => 'ripristina a 1x';

  @override
  String get common_skip_next => 'salta succ.';

  @override
  String get common_select_subtitle => 'selez. sottotitoli';

  @override
  String get common_playback_speed => 'vel. riproduzione';

  @override
  String get common_pip => 'PiP';

  @override
  String get common_toggle_fullscreen => 'schermo intero';

  @override
  String get common_exit_fullscreen => 'esci da schermo intero';

  @override
  String get common_copy_logs => 'copia log';

  @override
  String get common_clear_logs => 'cancella log';

  @override
  String get common_enable_autoscroll => 'attiva auto-scroll';

  @override
  String get common_disable_autoscroll => 'disattiva auto-scroll';

  @override
  String get common_retry => 'Riprova';

  @override
  String get common_no_items => 'Nessun elemento trovato';

  @override
  String get common_none => 'Nessuno';

  @override
  String get common_any => 'Qualsiasi';

  @override
  String get common_name => 'Nome';

  @override
  String get common_date => 'Data';

  @override
  String get common_rating => 'Valutazione';

  @override
  String get common_image_count => 'Conteggio immagini';

  @override
  String get common_filepath => 'Percorso file';

  @override
  String get common_random => 'Casuale';

  @override
  String get common_no_media_found => 'Nessun media trovato';

  @override
  String common_not_found(String item) {
    return '$item non trovato';
  }

  @override
  String get common_add_favorite => 'Aggiungi ai preferiti';

  @override
  String get common_remove_favorite => 'Rimuovi dai preferiti';

  @override
  String get details_group => 'dettagli gruppo';

  @override
  String get details_synopsis => 'Sinossi';

  @override
  String get details_media => 'Media';

  @override
  String get details_galleries => 'Gallerie';

  @override
  String get details_tags => 'Etichette';

  @override
  String get details_links => 'Link';

  @override
  String get details_scene_scrape => 'scarica metadati';

  @override
  String get details_show_more => 'Mostra di più';

  @override
  String get details_show_less => 'Mostra meno';

  @override
  String get details_more_from_studio => 'Altro dallo studio';

  @override
  String get details_o_count_incremented => 'Conteggio O incrementato';

  @override
  String details_failed_update_rating(String error) {
    return 'Aggiornamento della valutazione non riuscito: $error';
  }

  @override
  String details_failed_update_performer(Object error) {
    return 'Impossibile aggiornare l\'interprete: $error';
  }

  @override
  String details_failed_increment_o_count(String error) {
    return 'Impossibile incrementare il conteggio O: $error';
  }

  @override
  String get details_scene_add_performer => 'aggiungi interprete';

  @override
  String get details_scene_add_tag => 'aggiungi tag';

  @override
  String get details_scene_add_url => 'aggiungi URL';

  @override
  String get details_scene_remove_url => 'rimuovi URL';

  @override
  String get groups_title => 'Gruppi';

  @override
  String get groups_unnamed => 'Gruppo senza nome';

  @override
  String get groups_untitled => 'Gruppo senza titolo';

  @override
  String get studios_title => 'Studio';

  @override
  String get studios_galleries_title => 'Gallerie dello studio';

  @override
  String get studios_media_title => 'Media dello studio';

  @override
  String get studios_sort_title => 'Ordina studio';

  @override
  String get galleries_title => 'Gallerie';

  @override
  String get galleries_sort_title => 'Ordina gallerie';

  @override
  String get galleries_all_images => 'Tutte le immagini';

  @override
  String get galleries_filter_title => 'Filtra gallerie';

  @override
  String get galleries_min_rating => 'Valutazione minima';

  @override
  String get galleries_image_count => 'Conteggio immagini';

  @override
  String get galleries_organization => 'Organizzazione';

  @override
  String get galleries_organized_only => 'Solo organizzati';

  @override
  String get scenes_filter_title => 'Filtra scene';

  @override
  String get scenes_filter_saved =>
      'Preferenze del filtro salvate come predefinite';

  @override
  String get scenes_watched => 'Guardato';

  @override
  String get scenes_unwatched => 'Non guardato';

  @override
  String get scenes_search_hint => 'Cerca scene...';

  @override
  String get scenes_sort_header => 'Ordina scene';

  @override
  String get scenes_sort_duration => 'Durata';

  @override
  String get scenes_sort_bitrate => 'Bitrate';

  @override
  String get scenes_sort_framerate => 'Frequenza fotogrammi';

  @override
  String get scenes_sort_saved_default =>
      'Preferenze di ordinamento salvate come predefinito';

  @override
  String get scenes_sort_tooltip => 'Opzioni di ordinamento';

  @override
  String get tags_search_hint => 'Cerca etichette...';

  @override
  String get tags_sort_tooltip => 'Opzioni di ordinamento';

  @override
  String get tags_filter_tooltip => 'Opzioni di filtro';

  @override
  String get performers_title => 'Attori';

  @override
  String get performers_sort_title => 'Ordina attori';

  @override
  String get performers_filter_title => 'Filtra attori';

  @override
  String get performers_galleries_title => 'Tutte le gallerie dell\'attore';

  @override
  String get performers_media_title => 'Tutti i media dell\'attore';

  @override
  String get performers_gender => 'Genere';

  @override
  String get performers_gender_any => 'Qualsiasi';

  @override
  String get performers_gender_female => 'Femmina';

  @override
  String get performers_gender_male => 'Maschio';

  @override
  String get performers_gender_trans_female => 'Trans femmina';

  @override
  String get performers_gender_trans_male => 'Trans maschio';

  @override
  String get performers_gender_intersex => 'Intersessuale';

  @override
  String get performers_gender_non_binary => 'Non binario';

  @override
  String get performers_circumcised => 'Circumciso';

  @override
  String get performers_circumcised_cut => 'Circonciso';

  @override
  String get performers_circumcised_uncut => 'Non circonciso';

  @override
  String get performers_play_count => 'Conteggio riproduzioni';

  @override
  String get performers_field_disambiguation => 'Disambiguazione';

  @override
  String get performers_field_birthdate => 'Data di nascita';

  @override
  String get performers_field_deathdate => 'Data di morte';

  @override
  String get performers_field_height_cm => 'Altezza (cm)';

  @override
  String get performers_field_weight_kg => 'Peso (kg)';

  @override
  String get performers_field_measurements => 'Misure';

  @override
  String get performers_field_fake_tits => 'Seno (finto)';

  @override
  String get performers_field_penis_length => 'Lunghezza del pene';

  @override
  String get performers_field_ethnicity => 'Etnia';

  @override
  String get performers_field_country => 'Paese';

  @override
  String get performers_field_eye_color => 'Colore occhi';

  @override
  String get performers_field_hair_color => 'Colore capelli';

  @override
  String get performers_field_career_start => 'Inizio carriera';

  @override
  String get performers_field_career_end => 'Fine carriera';

  @override
  String get performers_field_tattoos => 'Tatuaggi';

  @override
  String get performers_field_piercings => 'Piercing';

  @override
  String get performers_field_aliases => 'Alias';

  @override
  String get common_organized => 'Organizzato';

  @override
  String get scenes_duplicated => 'Duplicato';

  @override
  String get random_studio => 'studio casuale';

  @override
  String get random_gallery => 'galleria casuale';

  @override
  String get random_tag => 'tag casuale';

  @override
  String get random_scene => 'scena casuale';

  @override
  String get random_performer => 'interprete casuale';

  @override
  String get filter_modifier => 'Modificatore';

  @override
  String get filter_value => 'Valore';

  @override
  String get filter_equals => 'Uguale';

  @override
  String get filter_not_equals => 'Diverso';

  @override
  String get filter_greater_than => 'Maggiore di';

  @override
  String get filter_less_than => 'Minore di';

  @override
  String get filter_is_null => 'È nullo';

  @override
  String get filter_not_null => 'Non è nullo';

  @override
  String get images_resolution_title => 'Risoluzione';

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
  String get images_orientation_title => 'Orientamento';

  @override
  String get common_or => 'O';

  @override
  String get scrape_from_url => 'Estrai da URL';

  @override
  String get scenes_phash_started => 'Generazione phash avviata';

  @override
  String scenes_phash_failed(Object error) {
    return 'Impossibile generare phash: $error';
  }

  @override
  String details_failed_update_studio(Object error) {
    return 'Impossibile aggiornare lo studio: $error';
  }

  @override
  String get settings_title => 'Impostazioni';

  @override
  String get settings_customize => 'Personalizza StashFlow';

  @override
  String get settings_customize_subtitle =>
      'Regola riproduzione, aspetto, layout e strumenti di supporto da un unico posto.';

  @override
  String get settings_core_section => 'Impostazioni principali';

  @override
  String get settings_core_subtitle =>
      'Pagine di configurazione più utilizzate';

  @override
  String get settings_server => 'Server';

  @override
  String get settings_server_subtitle => 'Configurazione connessione e API';

  @override
  String get settings_playback => 'Riproduzione';

  @override
  String get settings_playback_subtitle =>
      'Comportamento del lettore e interazioni';

  @override
  String get settings_keyboard => 'Tastiera';

  @override
  String get settings_keyboard_subtitle =>
      'Scorciatoie e tasti rapidi personalizzabili';

  @override
  String get settings_keyboard_title => 'Scorciatoie da tastiera';

  @override
  String get settings_keyboard_reset_defaults => 'Ripristina predefiniti';

  @override
  String get settings_keyboard_not_bound => 'Non assegnato';

  @override
  String get settings_keyboard_volume_up => 'Alza volume';

  @override
  String get settings_keyboard_volume_down => 'Abbassa volume';

  @override
  String get settings_keyboard_toggle_mute => 'Attiva/Disattiva muto';

  @override
  String get settings_keyboard_toggle_fullscreen =>
      'Attiva/Disattiva schermo intero';

  @override
  String get settings_keyboard_next_scene => 'Scena successiva';

  @override
  String get settings_keyboard_prev_scene => 'Scena precedente';

  @override
  String get settings_keyboard_increase_speed =>
      'Aumenta velocità di riproduzione';

  @override
  String get settings_keyboard_decrease_speed =>
      'Diminuisci velocità di riproduzione';

  @override
  String get settings_keyboard_reset_speed =>
      'Ripristina velocità di riproduzione';

  @override
  String get settings_keyboard_close_player => 'Chiudi lettore';

  @override
  String get settings_keyboard_next_image => 'Immagine successiva';

  @override
  String get settings_keyboard_prev_image => 'Immagine precedente';

  @override
  String get settings_keyboard_go_back => 'Torna indietro';

  @override
  String get settings_keyboard_play_pause_desc =>
      'Alterna tra riproduzione e pausa del video';

  @override
  String get settings_keyboard_seek_forward_5_desc => 'Avanza di 5 secondi';

  @override
  String get settings_keyboard_seek_backward_5_desc =>
      'Torna indietro di 5 secondi';

  @override
  String get settings_keyboard_seek_forward_10_desc => 'Avanza di 10 secondi';

  @override
  String get settings_keyboard_seek_backward_10_desc =>
      'Torna indietro di 10 secondi';

  @override
  String get settings_appearance => 'Aspetto';

  @override
  String get settings_appearance_subtitle => 'Tema e colori';

  @override
  String get settings_interface => 'Interfaccia';

  @override
  String get settings_interface_subtitle =>
      'Predefiniti di navigazione e layout';

  @override
  String get settings_support => 'Supporto';

  @override
  String get settings_support_subtitle => 'Diagnostica e informazioni';

  @override
  String get settings_develop => 'Sviluppo';

  @override
  String get settings_develop_subtitle => 'Strumenti avanzati e override';

  @override
  String get settings_appearance_title => 'Impostazioni Aspetto';

  @override
  String get settings_appearance_theme_mode => 'Modalità Tema';

  @override
  String get settings_appearance_theme_mode_subtitle =>
      'Scegli come l\'app segue i cambiamenti di luminosità';

  @override
  String get settings_appearance_theme_system => 'Sistema';

  @override
  String get settings_appearance_theme_light => 'Chiaro';

  @override
  String get settings_appearance_theme_dark => 'Scuro';

  @override
  String get settings_appearance_primary_color => 'Colore Primario';

  @override
  String get settings_appearance_primary_color_subtitle =>
      'Scegli un colore base per la tavolozza Material 3';

  @override
  String get settings_appearance_advanced_theming => 'Temi Avanzati';

  @override
  String get settings_appearance_advanced_theming_subtitle =>
      'Ottimizzazioni per tipi specifici di schermo';

  @override
  String get settings_appearance_true_black => 'Nero Assoluto (AMOLED)';

  @override
  String get settings_appearance_true_black_subtitle =>
      'Usa sfondi neri puri in modalità scura per risparmiare batteria sugli schermi OLED';

  @override
  String get settings_appearance_custom_hex =>
      'Colore Esadecimale Personalizzato';

  @override
  String get settings_appearance_custom_hex_helper =>
      'Inserisci un codice esadecimale ARGB a 8 cifre';

  @override
  String get settings_interface_title => 'Impostazioni Interfaccia';

  @override
  String get settings_interface_language => 'Lingua';

  @override
  String get settings_interface_language_subtitle =>
      'Sovrascrivi la lingua di sistema predefinita';

  @override
  String get settings_interface_app_language => 'Lingua dell\'App';

  @override
  String get settings_interface_navigation => 'Navigazione';

  @override
  String get settings_interface_navigation_subtitle =>
      'Visibilità delle scorciatoie di navigazione globale';

  @override
  String get settings_interface_show_random =>
      'Mostra Pulsanti Navigazione Casuale';

  @override
  String get settings_interface_show_random_subtitle =>
      'Abilita o disabilita i pulsanti fluttuanti nelle pagine di elenco e dettaglio';

  @override
  String get settings_interface_main_pages_gravity_orientation =>
      'Orientamento controllato dalla gravità (pagine principali)';

  @override
  String get settings_interface_main_pages_gravity_orientation_subtitle =>
      'Consenti alle pagine principali di ruotare usando il sensore del dispositivo. La riproduzione video a schermo intero usa le proprie impostazioni di orientamento.';

  @override
  String get settings_interface_show_edit => 'Mostra Pulsante Modifica';

  @override
  String get settings_interface_show_edit_subtitle =>
      'Abilita o disabilita il pulsante di modifica nella pagina dei dettagli della scena';

  @override
  String get settings_interface_customize_tabs => 'Personalizza Schede';

  @override
  String get settings_interface_customize_tabs_subtitle =>
      'Riordina o nascondi le voci del menu di navigazione';

  @override
  String get settings_interface_scenes_layout => 'Layout Scene';

  @override
  String get settings_interface_scenes_layout_subtitle =>
      'Modalità di navigazione predefinita per le scene';

  @override
  String get settings_interface_galleries_layout => 'Layout Gallerie';

  @override
  String get settings_interface_galleries_layout_subtitle =>
      'Modalità di navigazione predefinita per le gallerie';

  @override
  String get settings_interface_max_performer_avatars =>
      'Numero massimo di avatar degli attori';

  @override
  String get settings_interface_max_performer_avatars_subtitle =>
      'Numero massimo di avatar degli attori da mostrare nella scheda della scena.';

  @override
  String get settings_interface_show_performer_avatars =>
      'Mostra avatar degli attori';

  @override
  String get settings_interface_show_performer_avatars_subtitle =>
      'Visualizza le icone degli attori sulle schede delle scene su tutte le piattaforme.';

  @override
  String get settings_interface_performer_avatar_size =>
      'Dimensioni avatar dell\'attore';

  @override
  String get settings_interface_layout_default => 'Layout Predefinito';

  @override
  String get settings_interface_layout_default_desc =>
      'Scegli il layout predefinito per la pagina';

  @override
  String get settings_interface_layout_list => 'Elenco';

  @override
  String get settings_interface_layout_grid => 'Griglia';

  @override
  String get settings_interface_layout_tiktok => 'Scorrimento Infinito';

  @override
  String get settings_interface_grid_columns => 'Colonne Griglia';

  @override
  String get settings_interface_image_viewer => 'Visualizzatore Immagini';

  @override
  String get settings_interface_image_viewer_subtitle =>
      'Configura il comportamento della navigazione immagini a schermo intero';

  @override
  String get settings_interface_swipe_direction =>
      'Direzione Scorrimento Schermo Intero';

  @override
  String get settings_interface_swipe_direction_desc =>
      'Scegli come avanzano le immagini in modalità schermo intero';

  @override
  String get settings_interface_swipe_vertical => 'Verticale';

  @override
  String get settings_interface_swipe_horizontal => 'Orizzontale';

  @override
  String get settings_interface_waterfall_columns =>
      'Colonne Griglia Waterfall';

  @override
  String get settings_interface_performer_layouts => 'Layout Attori';

  @override
  String get settings_interface_performer_layouts_subtitle =>
      'Predefiniti media e gallerie per gli attori';

  @override
  String get settings_interface_studio_layouts => 'Layout Studi';

  @override
  String get settings_interface_studio_layouts_subtitle =>
      'Predefiniti media e gallerie per gli studi';

  @override
  String get settings_interface_tag_layouts => 'Layout Tag';

  @override
  String get settings_interface_tag_layouts_subtitle =>
      'Predefiniti media e gallerie per i tag';

  @override
  String get settings_interface_media_layout => 'Layout Media';

  @override
  String get settings_interface_media_layout_subtitle =>
      'Layout per la pagina Media';

  @override
  String get settings_interface_galleries_layout_item => 'Layout Gallerie';

  @override
  String get settings_interface_galleries_layout_subtitle_item =>
      'Layout per la pagina Gallerie';

  @override
  String get settings_server_title => 'Impostazioni Server';

  @override
  String get settings_server_status => 'Stato Connessione';

  @override
  String get settings_server_status_subtitle =>
      'Connettività in tempo reale con il server configurato';

  @override
  String get settings_server_details => 'Dettagli Server';

  @override
  String get settings_server_details_subtitle =>
      'Configura endpoint e metodo di autenticazione';

  @override
  String get settings_server_url => 'URL di Stash';

  @override
  String get settings_server_url_helper =>
      'Inserisci l\'URL del tuo server Stash. Se configurato con un percorso personalizzato, includilo qui.';

  @override
  String get settings_server_url_example => 'http://192.168.1.100:9999';

  @override
  String get settings_server_login_failed => 'Accesso non riuscito';

  @override
  String get settings_server_auth_method => 'Metodo di Autenticazione';

  @override
  String get settings_server_auth_apikey => 'Chiave API';

  @override
  String get settings_server_auth_password => 'Nome utente + Password';

  @override
  String get settings_server_auth_password_desc =>
      'Consigliato: usa la sessione nome utente/password di Stash.';

  @override
  String get settings_server_auth_apikey_desc =>
      'Usa la chiave API per l\'autenticazione tramite token statico.';

  @override
  String get settings_server_username => 'Nome utente';

  @override
  String get settings_server_password => 'Password';

  @override
  String get settings_server_login_test => 'Accedi & Testa';

  @override
  String get settings_server_test => 'Testa Connessione';

  @override
  String get settings_server_logout => 'Esci';

  @override
  String get settings_server_clear => 'Cancella Impostazioni';

  @override
  String settings_server_connected(String version) {
    return 'Connesso (Stash $version)';
  }

  @override
  String get settings_server_checking => 'Verifica connessione in corso...';

  @override
  String settings_server_failed(String error) {
    return 'Fallito: $error';
  }

  @override
  String get settings_server_invalid_url => 'URL server non valido';

  @override
  String get settings_server_resolve_error =>
      'Impossibile risolvere l\'URL del server. Controlla host, porta e credenziali.';

  @override
  String get settings_server_logout_confirm =>
      'Disconnessione effettuata e cookie cancellati.';

  @override
  String get settings_server_profile_add => 'Aggiungi profilo';

  @override
  String get settings_server_profile_edit => 'Modifica profilo';

  @override
  String get settings_server_profile_name => 'Nome profilo';

  @override
  String get settings_server_profile_delete => 'Elimina profilo';

  @override
  String get settings_server_profile_delete_confirm =>
      'Sei sicuro di voler eliminare questo profilo? Questa azione non può essere annullata.';

  @override
  String get settings_server_profile_active => 'Attivo';

  @override
  String get settings_server_profile_empty =>
      'Nessun profilo server configurato';

  @override
  String get settings_server_profiles => 'Profili server';

  @override
  String get settings_server_profiles_subtitle =>
      'Gestisci connessioni multiple al server Stash';

  @override
  String get settings_server_auth_status_logging_in =>
      'Stato autenticazione: accesso in corso...';

  @override
  String get settings_server_auth_status_logged_in =>
      'Stato autenticazione: connesso';

  @override
  String get settings_server_auth_status_logged_out =>
      'Stato autenticazione: disconnesso';

  @override
  String get settings_playback_title => 'Impostazioni Riproduzione';

  @override
  String get settings_playback_behavior => 'Comportamento riproduzione';

  @override
  String get settings_playback_behavior_subtitle =>
      'Gestione riproduzione predefinita e background';

  @override
  String get settings_playback_prefer_streams =>
      'Preferisci sceneStreams prima';

  @override
  String get settings_playback_prefer_streams_subtitle =>
      'Quando disattivato, la riproduzione utilizza direttamente paths.stream';

  @override
  String get settings_playback_autoplay =>
      'Riproduzione Automatica Prossima Scena';

  @override
  String get settings_playback_autoplay_subtitle =>
      'Riproduci automaticamente la scena successiva al termine della corrente';

  @override
  String get settings_playback_background => 'Riproduzione in Background';

  @override
  String get settings_playback_background_subtitle =>
      'Mantieni l\'audio del video attivo quando l\'app è in background';

  @override
  String get settings_playback_pip => 'Picture-in-Picture Nativo';

  @override
  String get settings_playback_pip_subtitle =>
      'Abilita il pulsante PiP di Android e l\'ingresso automatico in background';

  @override
  String get settings_playback_subtitles => 'Impostazioni sottotitoli';

  @override
  String get settings_playback_subtitles_subtitle =>
      'Caricamento automatico e aspetto';

  @override
  String get settings_playback_subtitle_lang =>
      'Lingua Sottotitoli Predefinita';

  @override
  String get settings_playback_subtitle_lang_subtitle =>
      'Carica automaticamente se disponibile';

  @override
  String get settings_playback_subtitle_size =>
      'Dimensione Carattere Sottotitoli';

  @override
  String get settings_playback_subtitle_pos =>
      'Posizione Verticale Sottotitoli';

  @override
  String settings_playback_subtitle_pos_desc(String percent) {
    return '$percent% dal fondo';
  }

  @override
  String get settings_playback_subtitle_align =>
      'Allineamento Testo Sottotitoli';

  @override
  String get settings_playback_subtitle_align_subtitle =>
      'Allineamento per sottotitoli su più righe';

  @override
  String get settings_playback_seek => 'Interazione ricerca';

  @override
  String get settings_playback_seek_subtitle =>
      'Scegli come funziona lo scorrimento durante la riproduzione';

  @override
  String get settings_playback_seek_double_tap =>
      'Doppio tocco sinistra/destra per cercare 10s';

  @override
  String get settings_playback_seek_drag => 'Trascina la timeline per cercare';

  @override
  String get settings_playback_seek_drag_label => 'Trascina';

  @override
  String get settings_playback_seek_double_tap_label => 'Doppio tocco';

  @override
  String get settings_playback_gravity_orientation =>
      'Orientamento controllato dalla gravità';

  @override
  String get settings_playback_gravity_orientation_subtitle =>
      'Consenti la rotazione tra orientamenti corrispondenti usando il sensore del dispositivo (es. capovolgere il paesaggio a sinistra/destra).';

  @override
  String get settings_playback_subtitle_lang_none_disabled =>
      'Nessuno (Disattivato)';

  @override
  String get settings_playback_subtitle_lang_auto_if_only_one =>
      'Automatico (Se ce n\'è solo uno)';

  @override
  String get settings_playback_subtitle_lang_english => 'Inglese';

  @override
  String get settings_playback_subtitle_lang_chinese => 'Cinese';

  @override
  String get settings_playback_subtitle_lang_german => 'Tedesco';

  @override
  String get settings_playback_subtitle_lang_french => 'Francese';

  @override
  String get settings_playback_subtitle_lang_spanish => 'Spagnolo';

  @override
  String get settings_playback_subtitle_lang_italian => 'Italiano';

  @override
  String get settings_playback_subtitle_lang_japanese => 'Giapponese';

  @override
  String get settings_playback_subtitle_lang_korean => 'Coreano';

  @override
  String get settings_playback_subtitle_align_left => 'Sinistra';

  @override
  String get settings_playback_subtitle_align_center => 'Centro';

  @override
  String get settings_playback_subtitle_align_right => 'Destra';

  @override
  String get settings_support_title => 'Supporto';

  @override
  String get settings_support_diagnostics => 'Diagnostica e info progetto';

  @override
  String get settings_support_diagnostics_subtitle =>
      'Apri i log di runtime o vai al repository quando hai bisogno di aiuto.';

  @override
  String get settings_support_update_available => 'Aggiornamento Disponibile';

  @override
  String get settings_support_update_available_subtitle =>
      'Una nuova versione è disponibile su GitHub';

  @override
  String settings_support_update_to(String version) {
    return 'Aggiorna a $version';
  }

  @override
  String get settings_support_update_to_subtitle =>
      'Nuove funzionalità e miglioramenti ti aspettano.';

  @override
  String get settings_support_about => 'Informazioni';

  @override
  String get settings_support_about_subtitle =>
      'Informazioni su progetto e sorgenti';

  @override
  String get settings_support_version => 'Versione';

  @override
  String get settings_support_version_loading => 'Caricamento info versione...';

  @override
  String get settings_support_version_unavailable =>
      'Info versione non disponibili';

  @override
  String get settings_support_github => 'Repository GitHub';

  @override
  String get settings_support_github_subtitle =>
      'Visualizza il codice sorgente e segnala problemi';

  @override
  String get settings_support_github_error =>
      'Impossibile aprire il link GitHub';

  @override
  String get settings_develop_title => 'Sviluppo';

  @override
  String get settings_develop_diagnostics => 'Strumenti Diagnostici';

  @override
  String get settings_develop_diagnostics_subtitle =>
      'Risoluzione dei problemi e prestazioni';

  @override
  String get settings_develop_video_debug => 'Mostra Info Debug Video';

  @override
  String get settings_develop_video_debug_subtitle =>
      'Visualizza dettagli tecnici di riproduzione in sovrimpressione sul lettore video.';

  @override
  String get settings_develop_log_viewer => 'Visualizzatore Log di Debug';

  @override
  String get settings_develop_log_viewer_subtitle =>
      'Apri una visualizzazione in tempo reale dei log interni all\'app.';

  @override
  String get settings_develop_logs_copied => 'Log copiati negli appunti';

  @override
  String get settings_develop_no_logs =>
      'Ancora nessun log. Interagisci con l\'app per acquisire i log.';

  @override
  String get settings_develop_web_overrides => 'Override Web';

  @override
  String get settings_develop_web_overrides_subtitle =>
      'Flag avanzati per la piattaforma web';

  @override
  String get settings_develop_web_auth =>
      'Consenti Accesso con Password su Web';

  @override
  String get settings_develop_web_auth_subtitle =>
      'Ignora la restrizione solo-nativa e forza la visibilità del metodo di autenticazione Nome utente + Password su Flutter Web.';

  @override
  String get settings_develop_proxy_auth =>
      'Abilita modalità di autenticazione proxy';

  @override
  String get settings_develop_proxy_auth_subtitle =>
      'Abilita i metodi avanzati Basic Auth e Bearer Token per l\'uso con backend senza autenticazione dietro proxy come Authentik.';

  @override
  String get settings_server_auth_basic => 'Autenticazione di base';

  @override
  String get settings_server_auth_bearer => 'Token Bearer';

  @override
  String get settings_server_auth_basic_desc =>
      'Invia l\'header \'Authorization: Basic <base64(user:pass)>\'.';

  @override
  String get settings_server_auth_bearer_desc =>
      'Invia l\'header \'Authorization: Bearer <token>\'.';

  @override
  String get common_edit => 'Modifica';

  @override
  String get common_resolution => 'Risoluzione';

  @override
  String get common_orientation => 'Orientamento';

  @override
  String get common_landscape => 'Orizzontale';

  @override
  String get common_portrait => 'Verticale';

  @override
  String get common_square => 'Quadrato';

  @override
  String get performers_filter_saved =>
      'Preferenze del filtro salvate come predefinite';

  @override
  String get images_title => 'Immagini';

  @override
  String get images_filter_title => 'Filtra immagini';

  @override
  String get images_filter_saved =>
      'Preferenze del filtro salvate come predefinite';

  @override
  String get images_sort_title => 'Ordina immagini';

  @override
  String get images_sort_saved =>
      'Preferenze di ordinamento salvate come predefinite';

  @override
  String get image_rating_updated => 'Valutazione immagine aggiornata.';

  @override
  String get gallery_rating_updated => 'Valutazione della galleria aggiornata.';

  @override
  String get common_image => 'Immagine';

  @override
  String get common_gallery => 'Galleria';

  @override
  String get images_gallery_rating_unavailable =>
      'La valutazione della galleria è disponibile solo quando si sfoglia una galleria.';

  @override
  String images_rating(String rating) {
    return 'Valutazione: $rating / 5';
  }

  @override
  String get images_filtered_by_gallery => 'Filtrato per galleria';

  @override
  String get images_slideshow_need_two =>
      'Sono necessarie almeno 2 immagini per la presentazione.';

  @override
  String get images_slideshow_start_title => 'Avvia presentazione';

  @override
  String images_slideshow_interval(num seconds) {
    return 'Intervallo: ${seconds}s';
  }

  @override
  String images_slideshow_transition_ms(num ms) {
    return 'Transizione: ${ms}ms';
  }

  @override
  String get common_forward => 'Avanti';

  @override
  String get common_backward => 'Indietro';

  @override
  String get images_slideshow_loop_title => 'Loop presentazione';

  @override
  String get common_cancel => 'Annulla';

  @override
  String get common_start => 'Avvia';

  @override
  String get common_done => 'Fatto';

  @override
  String get settings_keybind_assign_shortcut =>
      'Premi una scorciatoia per assegnare';

  @override
  String get settings_keybind_press_any =>
      'Premi qualsiasi tasto per assegnare la scorciatoia';

  @override
  String get scenes_select_tags => 'Seleziona tag';

  @override
  String get scenes_no_scrapers => 'Nessun scraper trovato';

  @override
  String get scenes_select_scraper => 'Seleziona scraper';

  @override
  String get scenes_no_results_found => 'Nessun risultato trovato';

  @override
  String get scenes_select_result => 'Seleziona risultato';

  @override
  String scenes_scrape_failed(String error) {
    return 'Estrazione fallita';
  }

  @override
  String get scenes_updated_successfully => 'Scene aggiornate con successo';

  @override
  String scenes_update_failed(String error) {
    return 'Aggiornamento scene fallito';
  }

  @override
  String get scenes_edit_title => 'Modifica scena';

  @override
  String get scenes_field_studio => 'Studio';

  @override
  String get scenes_field_tags => 'Etichette';

  @override
  String get scenes_field_urls => 'Indirizzi';

  @override
  String get scenes_edit_performer => 'Modifica interprete';

  @override
  String get scenes_edit_studio => 'Modifica studio';

  @override
  String get common_no_title => 'Nessun titolo';

  @override
  String get scenes_select_studio => 'Seleziona studio';

  @override
  String get scenes_select_performers => 'Seleziona interpreti';

  @override
  String get scenes_unmatched_scraped_tags => 'Tag estratti non corrispondenti';

  @override
  String get scenes_unmatched_scraped_performers =>
      'Interpreti estratti non corrispondenti';

  @override
  String get scenes_no_matching_performer_found =>
      'Nessun interprete corrispondente trovato nella libreria';

  @override
  String get common_unknown => 'Sconosciuto';

  @override
  String scenes_studio_id_prefix(String id) {
    return 'ID studio: $id';
  }

  @override
  String get tags_search_placeholder => 'Cerca etichette...';

  @override
  String get scenes_duration_short => '< 5 min.';

  @override
  String get scenes_duration_medium => '5-20 min.';

  @override
  String get scenes_duration_long => '> 20 min.';

  @override
  String get details_scene_fingerprint_query => 'Query fingerprint scena';

  @override
  String get scenes_available_scrapers => 'Scraper disponibili';

  @override
  String get scrape_results_existing => 'Esistente';

  @override
  String get scrape_results_scraped => 'Estratto';
}
