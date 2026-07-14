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
  String get common_token => 'Gettone';

  @override
  String get filter_value => 'Valore';

  @override
  String get common_yes => 'SÌ';

  @override
  String get common_no => 'No';

  @override
  String get common_clear_history => 'Cancella cronologia';

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
  String get common_update_now => 'Dettagli versione';

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
  String get common_refresh => 'Aggiorna';

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
  String get common_loading => 'Caricamento';

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
  String get common_skip_previous => 'Salta al precedente';

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
  String get common_more => 'Altro';

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
  String get scenes_sort_file_count => 'Numero di file';

  @override
  String get scenes_sort_filesize => 'Dimensione del file';

  @override
  String get scenes_sort_resolution => 'Risoluzione';

  @override
  String get scenes_sort_last_played_at => 'Ultima riproduzione';

  @override
  String get scenes_sort_resume_time => 'Tempo di ripresa';

  @override
  String get scenes_sort_play_duration => 'Durata riproduzione';

  @override
  String get scenes_sort_interactive => 'Interattivo';

  @override
  String get scenes_sort_interactive_speed => 'Velocità interattiva';

  @override
  String get scenes_sort_perceptual_similarity => 'Somiglianza percettiva';

  @override
  String get scenes_sort_performer_age => 'Età dell\'artista';

  @override
  String get scenes_sort_studio => 'Studio';

  @override
  String get scenes_sort_path => 'Percorso';

  @override
  String get scenes_sort_file_mod_time => 'Data di modifica del file';

  @override
  String get scenes_sort_tag_count => 'Numero di tag';

  @override
  String get scenes_sort_performer_count => 'Numero di artisti';

  @override
  String get scenes_sort_o_counter => 'Contatore O';

  @override
  String get scenes_sort_last_o_at => 'Ultimo O il';

  @override
  String get scenes_sort_group_scene_number => 'Numero scena nel gruppo/film';

  @override
  String get scenes_sort_code => 'Codice';

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
  String get filter_group_general => 'Generale';

  @override
  String get filter_group_performer => 'Interprete';

  @override
  String get filter_group_library => 'Libreria';

  @override
  String get filter_group_metadata => 'Metadati';

  @override
  String get filter_group_media_info => 'Info media';

  @override
  String get filter_group_usage => 'Utilizzo';

  @override
  String get filter_group_system => 'Sistema';

  @override
  String get filter_group_physical => 'Fisico';

  @override
  String get filter_equals => 'Uguale';

  @override
  String get filter_not_equals => 'Diverso';

  @override
  String get filter_greater_than => 'Maggiore di';

  @override
  String get filter_less_than => 'Minore di';

  @override
  String get filter_includes => 'Include';

  @override
  String get filter_excludes => 'Esclude';

  @override
  String get filter_includes_all => 'Include tutto';

  @override
  String get filter_is_null => 'È nullo';

  @override
  String get filter_not_null => 'Non è nullo';

  @override
  String get filter_matches_regex => 'Corrisponde a Regex';

  @override
  String get filter_not_matches_regex => 'Non corrisponde a Regex';

  @override
  String get filter_between => 'Fra';

  @override
  String get filter_not_between => 'Non tra';

  @override
  String get filter_value_secondary => 'Secondo valore';

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
  String get settings_appearance_font_size =>
      'Scala globale dell\'interfaccia utente';

  @override
  String get settings_appearance_font_size_subtitle =>
      'Ridimensiona la tipografia e la spaziatura proporzionalmente';

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
  String get settings_interface_hide_scene_metadata =>
      'Nascondi i metadati della scena per impostazione predefinita';

  @override
  String get settings_interface_hide_scene_metadata_subtitle =>
      'Mostra i metadati tecnici della scena solo dopo aver toccato Mostra metadati.';

  @override
  String get settings_interface_random_scene_filter =>
      'Rispetta i filtri attivi per la scena casuale';

  @override
  String get settings_interface_random_scene_filter_subtitle =>
      'Quando è attivata, la navigazione casuale delle scene usa i filtri scena correnti.';

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
  String get settings_interface_use_actual_scene_video_miniplayer =>
      'Usa il video reale della scena nel mini player';

  @override
  String get settings_interface_use_actual_scene_video_miniplayer_subtitle =>
      'Mostra la superficie video live invece dello screenshot della scena quando la riproduzione è attiva.';

  @override
  String get details_show_metadata => 'Mostra metadati';

  @override
  String get settings_interface_entity_image_filtering =>
      'Filtraggio immagini entità';

  @override
  String get settings_interface_entity_image_filtering_subtitle =>
      'Scegli se le pagine delle immagini dell\'entità corrispondono ai metadati dell\'immagine o alle gallerie correlate.';

  @override
  String get settings_interface_entity_image_filtering_direct =>
      'Entità diretta';

  @override
  String get settings_interface_entity_image_filtering_galleries =>
      'Gallerie correlate';

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
  String get settings_playback_feed_random =>
      'Avvia Feed da una posizione casuale';

  @override
  String get settings_playback_feed_random_subtitle =>
      'Durante la riproduzione di scene in modalità Feed, avvia da una posizione casuale tra lo 0% e il 90% della durata del video';

  @override
  String get settings_playback_resume_position =>
      'Riprendi dall\'ultima posizione di gioco';

  @override
  String get settings_playback_resume_position_subtitle =>
      'Quando apri un video, riprendi automaticamente da dove avevi interrotto';

  @override
  String get settings_playback_end_behavior =>
      'Riproduci il comportamento finale';

  @override
  String get settings_playback_end_behavior_subtitle =>
      'Cosa fare al termine della riproduzione corrente';

  @override
  String get settings_playback_end_behavior_stop => 'Fermare';

  @override
  String get settings_playback_end_behavior_loop =>
      'Eseguire il loop della scena corrente';

  @override
  String get settings_playback_end_behavior_next =>
      'Riproduci la scena successiva';

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
  String get settings_playback_direct_play =>
      'Riproduzione diretta alla navigazione della scena';

  @override
  String get settings_playback_direct_play_subtitle =>
      'Quando si naviga da un\'altra scena in riproduzione, riproduce direttamente la nuova scena';

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
  String get settings_support_issues => 'Segnala un problema';

  @override
  String get settings_support_issues_subtitle =>
      'Aiuta a migliorare StashFlow segnalando bug';

  @override
  String get settings_develop_title => 'Sviluppo';

  @override
  String get settings_develop_enable_logging =>
      'Abilita registrazione di debug';

  @override
  String get settings_develop_enable_logging_subtitle =>
      'Registra i log dell\'applicazione per la risoluzione dei problemi';

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

  @override
  String get stats_refresh_statistics => 'Aggiorna statistiche';

  @override
  String get stats_library_stats => 'Statistiche della biblioteca';

  @override
  String get stats_stash_glance => 'La tua scorta a colpo d\'occhio';

  @override
  String get stats_content => 'Contenuto';

  @override
  String get stats_organization => 'Organizzazione';

  @override
  String get stats_activity => 'Attività';

  @override
  String get stats_scenes => 'Scene';

  @override
  String get stats_galleries => 'Gallerie';

  @override
  String get stats_performers => 'Artisti';

  @override
  String get stats_studios => 'Studi';

  @override
  String get stats_groups => 'Gruppi';

  @override
  String get stats_tags => 'Tag';

  @override
  String get stats_total_plays => 'Riproduzioni totali';

  @override
  String stats_unique_items(int count) {
    return '$count elementi unici';
  }

  @override
  String get stats_total_o_count => 'Conteggio O totale';

  @override
  String get cast_airplay_pairing => 'Associazione AirPlay';

  @override
  String get cast_enter_pin =>
      'Inserisci il PIN di 4 cifre mostrato sulla tua TV';

  @override
  String get cast_pair => 'Paio';

  @override
  String cast_connecting_to(String deviceName) {
    return 'Connessione a $deviceName...';
  }

  @override
  String cast_casting_to(String deviceName) {
    return 'Trasmissione su $deviceName';
  }

  @override
  String cast_pairing_failed(String error) {
    return 'Associazione non riuscita: $error';
  }

  @override
  String cast_failed_to_cast(String error) {
    return 'Trasmissione non riuscita: $error';
  }

  @override
  String get cast_searching => 'Ricerca dispositivi...';

  @override
  String get cast_cast_to_device => 'Trasmetti al dispositivo';

  @override
  String get settings_storage_images => 'Immagini';

  @override
  String get settings_storage_videos => 'Video';

  @override
  String get settings_storage_database => 'Banca dati';

  @override
  String get settings_storage_clearing_image =>
      'Cancellazione della cache delle immagini...';

  @override
  String get settings_storage_clearing_video =>
      'Cancellazione della cache video...';

  @override
  String get settings_storage_clearing_database =>
      'Cancellazione della cache del database...';

  @override
  String get settings_storage_cleared_image =>
      'Cache delle immagini cancellata';

  @override
  String get settings_storage_cleared_video => 'Cache video cancellata';

  @override
  String get settings_storage_cleared_database =>
      'Cache del database cancellata';

  @override
  String get settings_storage_clear => 'Chiaro';

  @override
  String get settings_storage_error_loading =>
      'Errore durante il caricamento delle dimensioni';

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
  String get settings_storage_500_mb => '500mb';

  @override
  String get settings_storage_1_gb => '1GB';

  @override
  String get settings_storage_2_gb => '2GB';

  @override
  String get settings_storage_unlimited => 'Illimitato';

  @override
  String get settings_storage_limits => 'Limiti';

  @override
  String get settings_storage_limits_subtitle =>
      'Imposta le dimensioni massime della cache';

  @override
  String get settings_storage_max_image_cache => 'Cache immagini massima (MB)';

  @override
  String get settings_storage_max_video_cache => 'Cache video massima (MB)';

  @override
  String get settings_storage => 'Archiviazione e cache';

  @override
  String get settings_storage_usage => 'Utilizzo archiviazione';

  @override
  String get settings_storage_usage_subtitle => 'Spazio usato dalle cache';

  @override
  String get settings_storage_subtitle =>
      'Gestisci cache locali e limiti di archiviazione';

  @override
  String get performers_field_name => 'Nome';

  @override
  String get performers_field_url => 'URL';

  @override
  String get performers_field_details => 'Dettagli';

  @override
  String get performers_field_birth_year => 'Anno di nascita';

  @override
  String get performers_field_age => 'Età';

  @override
  String get performers_field_death_year => 'Anno di morte';

  @override
  String get performers_field_scene_count => 'Numero di scene';

  @override
  String get performers_field_image_count => 'Numero di immagini';

  @override
  String get performers_field_gallery_count => 'Numero di gallerie';

  @override
  String get performers_field_play_count => 'Numero di riproduzioni';

  @override
  String get performers_field_o_counter => 'Contatore O';

  @override
  String get performers_field_tag_count => 'Numero di tag';

  @override
  String get performers_field_created_at => 'Creato il';

  @override
  String get performers_field_updated_at => 'Aggiornato il';

  @override
  String get galleries_field_title => 'Titolo';

  @override
  String get galleries_field_details => 'Dettagli';

  @override
  String get galleries_field_date => 'Data';

  @override
  String get galleries_field_performer_age => 'Età dell\'artista';

  @override
  String get galleries_field_performer_count => 'Numero di artisti';

  @override
  String get galleries_field_tag_count => 'Numero di tag';

  @override
  String get galleries_field_url => 'URL';

  @override
  String get galleries_field_id => 'ID';

  @override
  String get galleries_field_path => 'Percorso';

  @override
  String get galleries_field_checksum => 'Checksum';

  @override
  String get galleries_field_image_count => 'Numero di immagini';

  @override
  String get galleries_field_file_count => 'Numero di file';

  @override
  String get galleries_field_created_at => 'Creato il';

  @override
  String get galleries_field_updated_at => 'Aggiornato il';

  @override
  String get images_field_title => 'Titolo';

  @override
  String get images_field_details => 'Dettagli';

  @override
  String get images_field_path => 'Percorso';

  @override
  String get images_field_url => 'URL';

  @override
  String get images_field_file_count => 'Numero di file';

  @override
  String get images_field_o_counter => 'Contatore O';

  @override
  String get studios_field_name => 'Nome';

  @override
  String get studios_field_details => 'Dettagli';

  @override
  String get studios_field_aliases => 'Alias';

  @override
  String get studios_field_url => 'URL';

  @override
  String get studios_field_tag_count => 'Numero di tag';

  @override
  String get studios_field_scene_count => 'Numero di scene';

  @override
  String get studios_field_image_count => 'Numero di immagini';

  @override
  String get studios_field_gallery_count => 'Numero di gallerie';

  @override
  String get studios_field_sub_studio_count => 'Numero di sottostudi';

  @override
  String get studios_field_created_at => 'Creato il';

  @override
  String get studios_field_updated_at => 'Aggiornato il';

  @override
  String get scenes_field_performer_age => 'Età dell\'artista';

  @override
  String get scenes_field_performer_count => 'Numero di artisti';

  @override
  String get scenes_field_tag_count => 'Numero di tag';

  @override
  String get scenes_field_code => 'Codice';

  @override
  String get scenes_field_details => 'Dettagli';

  @override
  String get scenes_field_director => 'Regista';

  @override
  String get scenes_field_url => 'URL';

  @override
  String get scenes_field_date => 'Data';

  @override
  String get scenes_field_path => 'Percorso';

  @override
  String get scenes_field_captions => 'Sottotitoli';

  @override
  String get scenes_field_duration => 'Durata (secondi)';

  @override
  String get scenes_field_bitrate => 'Bitrate';

  @override
  String get scenes_field_video_codec => 'Codec video';

  @override
  String get scenes_field_audio_codec => 'Codec audio';

  @override
  String get scenes_field_framerate => 'Frequenza fotogrammi';

  @override
  String get scenes_field_file_count => 'Numero di file';

  @override
  String get scenes_field_play_count => 'Numero di riproduzioni';

  @override
  String get scenes_field_play_duration => 'Durata riproduzione';

  @override
  String get scenes_field_o_counter => 'Contatore O';

  @override
  String get scenes_field_last_played_at => 'Ultima riproduzione';

  @override
  String get scenes_field_resume_time => 'Tempo di ripresa';

  @override
  String get scenes_field_interactive_speed => 'Velocità interattiva';

  @override
  String get scenes_field_id => 'ID';

  @override
  String get scenes_field_stash_id_count => 'Conteggio ID Stash';

  @override
  String get scenes_field_oshash => 'Oshash';

  @override
  String get scenes_field_checksum => 'Checksum';

  @override
  String get scenes_field_phash => 'Phash';

  @override
  String get scenes_field_created_at => 'Creato il';

  @override
  String get scenes_field_updated_at => 'Aggiornato il';

  @override
  String get cast_stopped_resuming_locally =>
      'Trasmissione interrotta, ripresa locale';

  @override
  String get cast_stop_casting => 'Interrompi trasmissione';

  @override
  String get cast_cast => 'Trasmetti';

  @override
  String get common_add => 'Aggiungi';

  @override
  String get common_remove => 'Rimuovi';

  @override
  String get common_clear => 'Cancella';

  @override
  String get common_download => 'Scarica';

  @override
  String get common_star => 'Stella';

  @override
  String get settings_interface_card_title_font_size =>
      'Dimensione carattere titolo scheda';

  @override
  String get common_hint_date => 'AAAA-MM-GG';

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
  String get saving_video => 'Salvataggio in galleria...';

  @override
  String get saved_to_album => 'Salvato nell\'album StashFlow';

  @override
  String gallery_error(String message) {
    return 'Errore galleria: $message';
  }

  @override
  String failed_to_save(String error) {
    return 'Impossibile salvare: $error';
  }

  @override
  String get saving_image => 'Salvataggio immagine...';

  @override
  String common_select(String label) {
    return 'Seleziona $label';
  }

  @override
  String common_saved_to(String path) {
    return 'Salvato in $path';
  }

  @override
  String get recent_searches => 'Ricerche recenti';

  @override
  String get initializing_player => 'Inizializzazione del player...';

  @override
  String get sort_scenes => 'Ordina scene';

  @override
  String get failed_to_load_tap_to_retry =>
      'Impossibile caricare. Tocca per riprovare.';

  @override
  String get would_you_like_to_visit_the_release_page_to_download_it =>
      'Vuoi visitare la pagina della release per scaricarlo?';

  @override
  String get to_get_started_configure_stash_server =>
      'Per iniziare, devi configurare i dettagli di connessione del tuo server Stash.';

  @override
  String get loading => 'Caricamento';

  @override
  String get wip => 'WIP';

  @override
  String get performer_filters => 'Filtri artisti';

  @override
  String update_available(String version) {
    return 'Una nuova versione di StashFlow ($version) è disponibile.';
  }

  @override
  String details_failed_update_favorite(String error) {
    return 'Impossibile aggiornare il preferito: $error';
  }

  @override
  String details_failed_load_galleries(String error) {
    return 'Impossibile caricare le gallerie: $error';
  }

  @override
  String get scene_info_id => 'Identificativo della scena';

  @override
  String get scene_info_original_file_path => 'Percorso file originale';

  @override
  String get scene_info_resume_time => 'Riprendi tempo';

  @override
  String get scene_info_play_duration => 'Durata della riproduzione';

  @override
  String get scene_info_urls => 'URL';

  @override
  String get scene_info_resolution => 'Risoluzione';

  @override
  String get scene_info_bitrate => 'Velocità in bit';

  @override
  String get scene_info_frame_rate => 'Frequenza fotogrammi';

  @override
  String get scene_info_format => 'Formato';

  @override
  String get scene_info_video_codec => 'Codec video';

  @override
  String get scene_info_audio_codec => 'Codec audio';

  @override
  String get scene_info_stream => 'Flusso';

  @override
  String get scene_info_preview => 'Anteprima';

  @override
  String get scene_info_screenshot => 'Schermata';

  @override
  String get scene_info_cover => 'Copertina';

  @override
  String get scene_info_caption => 'Didascalia';

  @override
  String get scene_info_vtt => 'VTT';

  @override
  String get scene_info_sprite => 'Folletto';

  @override
  String get scene_info_technical => 'Tecnico';

  @override
  String scene_studio_id(String id) {
    return 'ID: $id';
  }

  @override
  String scene_rating_stars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Stelle',
      one: '1 stella',
    );
    return '$_temp0';
  }

  @override
  String get main_startup_failed => 'Impossibile avviare StashFlow';

  @override
  String get main_startup_failed_desc =>
      'Un servizio di avvio non è riuscito prima che l\'app potesse completare l\'inizializzazione.Riavvia l\'app dopo aver controllato la diagnostica.';

  @override
  String common_searching_for(String query) {
    return 'Cercando: \"$query\"';
  }

  @override
  String get cast_device => 'Dispositivo';

  @override
  String get auth_enter_passcode => 'Inserisci il tuo passcode per continuare.';

  @override
  String get auth_unlock => 'Sbloccare';

  @override
  String get auth_incorrect_passcode => 'Codice di accesso errato';

  @override
  String get auth_app_locked => 'Applicazione bloccata';

  @override
  String get settings_security_passcode => 'Codice di accesso';

  @override
  String get settings_security_passcode_configured => 'Configurato';

  @override
  String get settings_security_passcode_not_configured => 'Non configurato';

  @override
  String get settings_security_passcode_saved => 'Codice di accesso salvato';

  @override
  String get settings_security_passcode_removed => 'Codice rimosso';

  @override
  String get settings_security_enable_app_lock => 'Abilita il blocco dell\'app';

  @override
  String get settings_security_enable_app_lock_subtitle =>
      'Richiedi il passcode al ripristino/avvio dell\'app.';

  @override
  String get settings_security_lock_on_launch => 'Blocca all\'avvio dell\'app';

  @override
  String get settings_security_lock_on_launch_subtitle =>
      'Richiedi immediatamente il passcode all\'apertura dell\'app.';

  @override
  String get settings_security_background_lock_timer =>
      'Temporizzatore di blocco dello sfondo';

  @override
  String get settings_security_background_lock_timer_subtitle =>
      'Per quanto tempo l\'app può rimanere in background prima di bloccarsi.';

  @override
  String get settings_security_set_passcode => 'Imposta il codice di accesso';

  @override
  String get settings_security_passcode_prompt =>
      'Codice di accesso (4-8 cifre)';

  @override
  String get settings_security_confirm_passcode => 'Confermare';

  @override
  String get settings_security_error_numeric =>
      'Utilizzare solo cifre, con lunghezza compresa tra 4 e 8.';

  @override
  String get settings_security_error_mismatch =>
      'I codici di accesso non corrispondono.';

  @override
  String get common_change => 'Modifica';

  @override
  String get common_set => 'Impostato';

  @override
  String get common_immediately => 'Immediatamente';

  @override
  String common_sec(int value) {
    return '$value sec';
  }

  @override
  String common_min(int value) {
    return '$value min';
  }

  @override
  String common_s(int value) {
    return '${value}s';
  }

  @override
  String get settings_security_title => 'Sicurezza';

  @override
  String get settings_security_subtitle =>
      'Impostazioni del blocco dell\'applicazione e del passcode';

  @override
  String get settings_security_app_lock => 'Blocco dell\'app';

  @override
  String get settings_security_app_lock_subtitle =>
      'Proteggi l\'accesso con un passcode dopo il background.';

  @override
  String get common_saved_filters => 'Filtri salvati';

  @override
  String get tools => 'Utensili';

  @override
  String get tools_section_subtitle =>
      'Flussi di lavoro di manutenzione e metadati per le scene.';

  @override
  String get tools_scene_deduplication_subtitle =>
      'Trova e gestisci le scene duplicate.';

  @override
  String get tools_scene_tagger_subtitle =>
      'Scrape delle pagine delle scene correnti con Stash-box.';

  @override
  String get preset_deleted => 'Preimpostazione eliminata';

  @override
  String get delete_preset => 'Elimina preimpostazione';

  @override
  String get common_delete => 'Eliminare';

  @override
  String get save_preset => 'Salva preimpostazione';

  @override
  String get no_saved_presets => 'Nessun preset salvato';

  @override
  String get scene_tagger => 'Etichettatore scene';

  @override
  String get page_size => 'Dimensioni della pagina';

  @override
  String get mode => 'Modalità';

  @override
  String get sort => 'Ordina';

  @override
  String get desc => 'Disc';

  @override
  String get asc => 'Asc';

  @override
  String get filter => 'Filtro';

  @override
  String get load_preset => 'Carica preimpostazione';

  @override
  String get preset => 'Preimpostazione';

  @override
  String get stash_box_scraper => 'Raschietto per scatole portaoggetti';

  @override
  String get start_tagging => 'Inizia a taggare';

  @override
  String get stop => 'Arresta';

  @override
  String get open_scene => 'Apri scena';

  @override
  String get skip => 'Saltare';

  @override
  String get apply => 'Applica';

  @override
  String get selected => 'Selezionato';

  @override
  String get select => 'Selezionare';

  @override
  String get preview => 'Anteprima';

  @override
  String get delete_scene => 'Elimina scena';

  @override
  String get metadata_only => 'Solo metadati';

  @override
  String get files => 'File';

  @override
  String get scene_deleted => 'Scena eliminata';

  @override
  String get delete_metadata => 'Elimina i metadati';

  @override
  String get delete_files => 'Elimina file';

  @override
  String get scene_deduplication => 'Deduplicazione delle scene';

  @override
  String get no_duplicates_found => 'Nessun duplicato trovato.';

  @override
  String get search_accuracy => 'Precisione della ricerca';

  @override
  String get duration_difference => 'Differenza di durata';

  @override
  String get only_select_matching_codecs =>
      'Seleziona solo i codec corrispondenti';

  @override
  String get select_scenes => 'Seleziona le scene';

  @override
  String get all_but_largest_resolution =>
      'Tutto tranne la massima risoluzione';

  @override
  String get all_but_largest_file => 'Tutto tranne il file più grande';

  @override
  String get all_but_oldest => 'Tutti tranne il più vecchio';

  @override
  String get all_but_youngest => 'Tutti tranne il più giovane';

  @override
  String get select_none => 'Seleziona nessuno';

  @override
  String get merge => 'Unisci';

  @override
  String get previous_page => 'Pagina precedente';

  @override
  String get next_page => 'Pagina successiva';

  @override
  String scene_deduplication_page_count(int page, int totalPages) {
    return 'Pagina $page di $totalPages';
  }

  @override
  String scene_tagger_result_count(int index, int total) {
    return 'Risultato $index di $total';
  }

  @override
  String delete_preset_confirm(String name) {
    return 'Eliminare \"$name\"? Questa azione non può essere annullata.';
  }

  @override
  String get enter_preset_name => 'Inserisci il nome del preset';

  @override
  String get delete_scene_confirm =>
      'Sei sicuro di voler eliminare questa scena?';

  @override
  String delete_selected_count(int selectedCount) {
    return 'Elimina selezionati ($selectedCount)';
  }

  @override
  String get saved_presets => 'Preset salvati';

  @override
  String get current_settings => 'Impostazioni correnti';

  @override
  String get available_presets => 'Preset disponibili';

  @override
  String get existing_names_are_overwritten =>
      'I nomi esistenti verranno sovrascritti';

  @override
  String get active_settings_saved_server =>
      'Le impostazioni attive correnti verranno salvate sul server.';

  @override
  String failed_to_save_filter(String error) {
    return 'Impossibile salvare il filtro: $error';
  }

  @override
  String failed_to_delete_preset(String error) {
    return 'Impossibile eliminare il preset: $error';
  }

  @override
  String sort_label(String sortLabel) {
    return 'Ordina: $sortLabel';
  }

  @override
  String filters_count(int count) {
    return 'Filtri: $count';
  }

  @override
  String search_label(String query) {
    return 'Cerca: $query';
  }

  @override
  String failed_to_load_presets(String error) {
    return 'Impossibile caricare i preset: $error';
  }

  @override
  String saved_item(String item) {
    return '$item salvato';
  }

  @override
  String unable_to_load_stash_boxes(String error) {
    return 'Impossibile caricare le Stash Box: $error';
  }

  @override
  String delete_n_scenes_question(int count) {
    return 'Eliminare $count scene?';
  }

  @override
  String get delete_scenes_help =>
      'Scegli se rimuovere solo i metadati di Stash oppure eliminare anche i file della scena e i file di supporto generati.';

  @override
  String deleted_n_scenes(int count) {
    return '$count scene eliminate';
  }

  @override
  String delete_failed_error(String error) {
    return 'Eliminazione non riuscita: $error';
  }

  @override
  String get configuration => 'Configurazione';

  @override
  String missing_phashes_for_scenes(int count) {
    return 'Mancano i phash per $count scene. Esegui l\'attività di generazione dei phash.';
  }

  @override
  String get merge_editing_not_wired =>
      'La modifica delle unioni non è ancora collegata in StashFlow.';

  @override
  String duplicate_sets_count(int count) {
    return '$count insiemi duplicati';
  }

  @override
  String duplicate_set_number(int number) {
    return 'Insieme duplicato $number';
  }

  @override
  String resolution_dimensions(int width, int height) {
    return '${width}x$height';
  }

  @override
  String duration_seconds_format(String seconds) {
    return '${seconds}s';
  }

  @override
  String bitrate_bps(int bitrate) {
    return '$bitrate bps';
  }

  @override
  String o_count(int count) {
    return 'O $count';
  }

  @override
  String nTags(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString tag',
      one: '1 tag',
      zero: 'nessun tag',
    );
    return '$_temp0';
  }

  @override
  String nGroups(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString gruppi',
      one: '1 gruppo',
      zero: 'nessun gruppo',
    );
    return '$_temp0';
  }

  @override
  String nMarkers(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString marker',
      one: '1 marker',
      zero: 'nessun marker',
    );
    return '$_temp0';
  }

  @override
  String nGalleries(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString gallerie',
      one: '1 galleria',
      zero: 'nessuna galleria',
    );
    return '$_temp0';
  }

  @override
  String scene_tagger_checked_matches_summary(int checked, int matches) {
    return '$checked controllate • $matches corrispondenze';
  }

  @override
  String scene_tagger_page_summary(int count) {
    return '$count scene in questa pagina';
  }

  @override
  String get no_matched_scenes_yet => 'Nessuna scena corrispondente finora.';

  @override
  String get no_scenes_match_configuration =>
      'Nessuna scena corrisponde a questa configurazione.';

  @override
  String scene_tagger_checked_count(int count) {
    return '$count controllate';
  }

  @override
  String scene_tagger_progress(int checked, int total) {
    return '$checked / $total';
  }

  @override
  String get stats_library_stats_tooltip =>
      'Tieni premuto per le statistiche della libreria';

  @override
  String get scene_details_marker_created => 'Marcatore creato';

  @override
  String scene_details_failed_to_create_marker(String error) {
    return 'Impossibile creare l\'indicatore: $error';
  }

  @override
  String get scene_details_delete_marker_title => 'Elimina marcatori';

  @override
  String scene_details_delete_marker_content(String title) {
    return 'Eliminare l\'indicatore \"$title\"?';
  }

  @override
  String get scene_details_marker_deleted => 'Indicatore eliminato';

  @override
  String scene_details_failed_to_delete_marker(String error) {
    return 'Impossibile eliminare l\'indicatore: $error';
  }

  @override
  String get scene_details_add_marker => 'Aggiungi marcatore';

  @override
  String get scene_details_create_marker => 'Creare';

  @override
  String scene_details_delete_marker_tooltip(String title) {
    return 'Elimina indicatore $title';
  }

  @override
  String get scenes_page_markers_tooltip => 'Marcatori';

  @override
  String get auto_marker_name => 'Nome del marcatore';

  @override
  String get auto_missing_field => 'Campo mancante';

  @override
  String get filter_markers_title => 'Marcatori di filtro';

  @override
  String get marker_title => 'Marcatore';

  @override
  String get duration_title => 'Durata';

  @override
  String get scene_title => 'Scena';

  @override
  String get dates_title => 'Date';

  @override
  String get created_at_title => 'Creato a';

  @override
  String get updated_at_title => 'Aggiornato a';

  @override
  String get scene_date_title => 'Data della scena';

  @override
  String get scene_created_at_title => 'Scena creata a';

  @override
  String get scene_updated_at_title => 'Scena aggiornata a';

  @override
  String get organized_title => 'Organizzato';

  @override
  String get interactive_title => 'Interattivo';

  @override
  String get scraped_metadata_title => 'Metadati raschiati';

  @override
  String get local_scene_title => 'Scena locale';

  @override
  String get sort_markers_title => 'Ordina i marcatori';

  @override
  String get markers_title => 'Marcatori';

  @override
  String get sub_group_count_title => 'Conteggio sottogruppi';

  @override
  String get groups_browsing_mode_subtitle =>
      'Modalità di navigazione predefinita per i gruppi';

  @override
  String get markers_browsing_mode_subtitle =>
      'Modalità di navigazione predefinita per i marcatori';

  @override
  String get entity_layouts_title => 'Layout di entità';

  @override
  String get entity_layouts_subtitle =>
      'Impostazioni predefinite del layout multimediale e della galleria per artisti, studi e tag';

  @override
  String get stats_subtitle_0_gb => '0,00GB';

  @override
  String get stats_subtitle_0_unique_items => '0 oggetti unici';

  @override
  String get markers_search_hint => 'Cerca marcatori';

  @override
  String get tags_title => 'Tag';

  @override
  String get scenes_title => 'Scene';
}
