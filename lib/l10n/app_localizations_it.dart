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
  String get studios_sort_saved =>
      'Preferenze di ordinamento salvate come predefinite';

  @override
  String get studios_no_random =>
      'Nessuno studio disponibile per la navigazione casuale';

  @override
  String get tags_filter_title => 'Filtra Tag';

  @override
  String get tags_filter_saved =>
      'Preferenze del filtro salvate come predefinite';

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
  String get common_url => 'URL';

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
  String get details_group => 'dettagli gruppo';

  @override
  String get details_scene_scrape => 'scarica metadati';

  @override
  String get details_scene_add_performer => 'aggiungi interprete';

  @override
  String get details_scene_add_tag => 'aggiungi tag';

  @override
  String get details_scene_add_url => 'aggiungi URL';

  @override
  String get details_scene_remove_url => 'rimuovi URL';

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
  String get settings_interface_shake_random => 'Agita per Scoprire';

  @override
  String get settings_interface_shake_random_subtitle =>
      'Agita il dispositivo per passare a un elemento casuale nella scheda corrente';

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
  String get settings_server_url => 'URL server GraphQL';

  @override
  String get settings_server_url_helper =>
      'Esempio formato: http(s)://host:port/graphql.';

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
}
