// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'StashFlow';

  @override
  String get common_token => 'Simbólico';

  @override
  String get filter_value => 'Valor';

  @override
  String get common_yes => 'Sí';

  @override
  String get common_no => 'No';

  @override
  String get common_clear_history => 'Borrar historial';

  @override
  String get nav_scenes => 'Escenas';

  @override
  String get nav_performers => 'Actores';

  @override
  String get nav_studios => 'Estudios';

  @override
  String get nav_tags => 'Etiquetas';

  @override
  String get nav_galleries => 'Galerías';

  @override
  String nScenes(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString escenas',
      one: '1 escena',
      zero: 'no hay escenas',
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
      other: '$countString actores',
      one: '1 actor',
      zero: 'no hay actores',
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
  String get common_reset => 'Restablecer';

  @override
  String get common_apply => 'Aplicar';

  @override
  String get common_save_default => 'Guardar como predeterminado';

  @override
  String get common_sort_method => 'Método de ordenación';

  @override
  String get common_direction => 'Dirección';

  @override
  String get common_ascending => 'Ascendente';

  @override
  String get common_descending => 'Descendente';

  @override
  String get common_favorites_only => 'Solo favoritos';

  @override
  String get common_apply_sort => 'Aplicar orden';

  @override
  String get common_apply_filters => 'Aplicar filtros';

  @override
  String get common_view_all => 'Ver todo';

  @override
  String get common_default => 'Predeterminado';

  @override
  String get common_later => 'Más tarde';

  @override
  String get common_update_now => 'Actualizar ahora';

  @override
  String get common_configure_now => 'Configurar ahora';

  @override
  String get common_clear_rating => 'borrar calificación';

  @override
  String get common_no_media => 'No hay medios disponibles';

  @override
  String get common_show => 'Mostrar';

  @override
  String get common_hide => 'Ocultar';

  @override
  String get galleries_filter_saved =>
      'Preferencias de filtrado guardadas como predeterminadas';

  @override
  String get common_setup_required => 'Configuración requerida';

  @override
  String get common_update_available => 'Actualización disponible';

  @override
  String get details_studio => 'Detalles del estudio';

  @override
  String get details_performer => 'Detalles del actor';

  @override
  String get details_tag => 'Detalles de la etiqueta';

  @override
  String get details_scene => 'Detalles de la escena';

  @override
  String get details_gallery => 'Detalles de la galería';

  @override
  String get studios_filter_title => 'Filtrar estudios';

  @override
  String get studios_filter_saved =>
      'Preferencias de filtro guardadas como predeterminadas';

  @override
  String get sort_name => 'Nombre';

  @override
  String get sort_scene_count => 'Número de escenas';

  @override
  String get sort_rating => 'Calificación';

  @override
  String get sort_updated_at => 'Actualizado el';

  @override
  String get sort_created_at => 'Creado el';

  @override
  String get sort_random => 'Aleatorio';

  @override
  String get sort_file_mod_time => 'Fecha de modificación del archivo';

  @override
  String get sort_filesize => 'Tamaño de archivo';

  @override
  String get sort_o_count => 'Contador O';

  @override
  String get sort_height => 'Altura';

  @override
  String get sort_birthdate => 'Fecha de nacimiento';

  @override
  String get sort_tag_count => 'Número de etiquetas';

  @override
  String get sort_play_count => 'Reproducciones';

  @override
  String get sort_o_counter => 'Contador O';

  @override
  String get sort_zip_file_count => 'Número de archivos ZIP';

  @override
  String get sort_last_o_at => 'Último O';

  @override
  String get sort_latest_scene => 'Última escena';

  @override
  String get sort_career_start => 'Inicio de carrera';

  @override
  String get sort_career_end => 'Fin de carrera';

  @override
  String get sort_weight => 'Peso';

  @override
  String get sort_measurements => 'Medidas';

  @override
  String get sort_scenes_duration => 'Duración de escenas';

  @override
  String get sort_scenes_size => 'Tamaño de escenas';

  @override
  String get sort_images_count => 'Número de imágenes';

  @override
  String get sort_galleries_count => 'Número de galerías';

  @override
  String get sort_child_count => 'Número de subestudios';

  @override
  String get sort_performers_count => 'Número de intérpretes';

  @override
  String get sort_groups_count => 'Número de grupos';

  @override
  String get sort_marker_count => 'Número de marcadores';

  @override
  String get sort_studios_count => 'Número de estudios';

  @override
  String get sort_penis_length => 'Longitud del pene';

  @override
  String get sort_last_played_at => 'Última reproducción';

  @override
  String get studios_sort_saved =>
      'Preferencias de ordenación guardadas como predeterminadas';

  @override
  String get studios_no_random =>
      'No hay estudios disponibles para navegación aleatoria';

  @override
  String get tags_filter_title => 'Filtrar etiquetas';

  @override
  String get tags_filter_saved =>
      'Preferencias de filtro guardadas como predeterminadas';

  @override
  String get tags_sort_title => 'Ordenar etiquetas';

  @override
  String get tags_sort_saved =>
      'Preferencias de ordenación guardadas como predeterminadas';

  @override
  String get tags_no_random =>
      'No hay etiquetas disponibles para navegación aleatoria';

  @override
  String get scenes_no_random =>
      'No hay escenas disponibles para navegación aleatoria';

  @override
  String get performers_no_random =>
      'No hay actores disponibles para navegación aleatoria';

  @override
  String get galleries_no_random =>
      'No hay galerías disponibles para navegación aleatoria';

  @override
  String common_error(String message) {
    return 'Error: $message';
  }

  @override
  String get common_no_media_available => 'sin medios disponibles';

  @override
  String common_id(Object id) {
    return 'ID: $id';
  }

  @override
  String get common_search_placeholder => 'Buscar...';

  @override
  String get common_pause => 'pausa';

  @override
  String get common_play => 'reproducir';

  @override
  String get common_refresh => 'Refrescar';

  @override
  String get common_close => 'cerrar';

  @override
  String get common_save => 'guardar';

  @override
  String get common_unmute => 'activar sonido';

  @override
  String get common_mute => 'silenciar';

  @override
  String get common_back => 'atrás';

  @override
  String get common_rate => 'calificar';

  @override
  String get common_previous => 'anterior';

  @override
  String get common_next => 'siguiente';

  @override
  String get common_favorite => 'favorito';

  @override
  String get common_unfavorite => 'quitar favorito';

  @override
  String get common_version => 'versión';

  @override
  String get common_loading => 'Cargando';

  @override
  String get common_unavailable => 'no disponible';

  @override
  String get common_details => 'detalles';

  @override
  String get common_title => 'título';

  @override
  String get common_release_date => 'fecha de estreno';

  @override
  String get common_url => 'Enlace';

  @override
  String get common_no_url => 'sin URL';

  @override
  String get common_sort => 'ordenar';

  @override
  String get common_filter => 'filtrar';

  @override
  String get common_search => 'buscar';

  @override
  String get common_settings => 'ajustes';

  @override
  String get common_reset_to_1x => 'restablecer a 1x';

  @override
  String get common_skip_next => 'saltar siguiente';

  @override
  String get common_skip_previous => 'Saltar anterior';

  @override
  String get common_select_subtitle => 'elegir subtítulo';

  @override
  String get common_playback_speed => 'vel. reproducción';

  @override
  String get common_pip => 'imagen en imagen';

  @override
  String get common_toggle_fullscreen => 'pantalla completa';

  @override
  String get common_exit_fullscreen => 'salir de pantalla completa';

  @override
  String get common_copy_logs => 'copiar registros';

  @override
  String get common_clear_logs => 'borrar registros';

  @override
  String get common_enable_autoscroll => 'activar auto-scroll';

  @override
  String get common_disable_autoscroll => 'desactivar auto-scroll';

  @override
  String get common_retry => 'Reintentar';

  @override
  String get common_no_items => 'No se encontraron elementos';

  @override
  String get common_none => 'Ninguno';

  @override
  String get common_any => 'Cualquiera';

  @override
  String get common_name => 'Nombre';

  @override
  String get common_date => 'Fecha';

  @override
  String get common_rating => 'Calificación';

  @override
  String get common_image_count => 'Número de imágenes';

  @override
  String get common_filepath => 'Ruta del archivo';

  @override
  String get common_random => 'Aleatorio';

  @override
  String get common_no_media_found => 'No se encontraron medios';

  @override
  String common_not_found(String item) {
    return '$item no encontrado';
  }

  @override
  String get common_add_favorite => 'Añadir a favoritos';

  @override
  String get common_remove_favorite => 'Quitar de favoritos';

  @override
  String get details_group => 'detalles del grupo';

  @override
  String get details_synopsis => 'Sinopsis';

  @override
  String get details_media => 'Medios';

  @override
  String get details_galleries => 'Galerías';

  @override
  String get details_tags => 'Etiquetas';

  @override
  String get details_links => 'Enlaces';

  @override
  String get details_scene_scrape => 'extraer metadatos';

  @override
  String get details_show_more => 'Mostrar más';

  @override
  String get common_more => 'Más';

  @override
  String get details_show_less => 'Mostrar menos';

  @override
  String get details_more_from_studio => 'Más del estudio';

  @override
  String get details_o_count_incremented => 'Recuento O incrementado';

  @override
  String details_failed_update_rating(String error) {
    return 'Error al actualizar la calificación: $error';
  }

  @override
  String details_failed_update_performer(Object error) {
    return 'Error al actualizar el intérprete: $error';
  }

  @override
  String details_failed_increment_o_count(String error) {
    return 'Error al incrementar el recuento O: $error';
  }

  @override
  String get details_scene_add_performer => 'añadir intérprete';

  @override
  String get details_scene_add_tag => 'añadir etiqueta';

  @override
  String get details_scene_add_url => 'añadir URL';

  @override
  String get details_scene_remove_url => 'quitar URL';

  @override
  String get groups_title => 'Grupos';

  @override
  String get groups_unnamed => 'Grupo sin nombre';

  @override
  String get groups_untitled => 'Grupo sin título';

  @override
  String get studios_title => 'Estudios';

  @override
  String get studios_galleries_title => 'Galerías del estudio';

  @override
  String get studios_media_title => 'Medios del estudio';

  @override
  String get studios_sort_title => 'Ordenar estudios';

  @override
  String get galleries_title => 'Galerías';

  @override
  String get galleries_sort_title => 'Ordenar galerías';

  @override
  String get galleries_all_images => 'Todas las imágenes';

  @override
  String get galleries_filter_title => 'Filtrar galerías';

  @override
  String get galleries_min_rating => 'Calificación mínima';

  @override
  String get galleries_image_count => 'Número de imágenes';

  @override
  String get galleries_organization => 'Organización';

  @override
  String get galleries_organized_only => 'Solo organizados';

  @override
  String get scenes_filter_title => 'Filtrar escenas';

  @override
  String get scenes_filter_saved =>
      'Preferencias de filtro guardadas como predeterminadas';

  @override
  String get scenes_watched => 'Vistas';

  @override
  String get scenes_unwatched => 'Sin ver';

  @override
  String get scenes_search_hint => 'Buscar escenas...';

  @override
  String get scenes_sort_header => 'Ordenar escenas';

  @override
  String get scenes_sort_duration => 'Duración';

  @override
  String get scenes_sort_bitrate => 'Tasa de bits';

  @override
  String get scenes_sort_framerate => 'Frecuencia de fotogramas';

  @override
  String get scenes_sort_saved_default =>
      'Preferencias de orden guardadas como predeterminado';

  @override
  String get scenes_sort_tooltip => 'Opciones de orden';

  @override
  String get tags_search_hint => 'Buscar etiquetas...';

  @override
  String get tags_sort_tooltip => 'Opciones de ordenación';

  @override
  String get tags_filter_tooltip => 'Opciones de filtrado';

  @override
  String get performers_title => 'Actores';

  @override
  String get performers_sort_title => 'Ordenar actores';

  @override
  String get performers_filter_title => 'Filtrar actores';

  @override
  String get performers_galleries_title => 'Todas las galerías del actor';

  @override
  String get performers_media_title => 'Todos los medios del actor';

  @override
  String get performers_gender => 'Género';

  @override
  String get performers_gender_any => 'Cualquiera';

  @override
  String get performers_gender_female => 'Mujer';

  @override
  String get performers_gender_male => 'Hombre';

  @override
  String get performers_gender_trans_female => 'Mujer trans';

  @override
  String get performers_gender_trans_male => 'Hombre trans';

  @override
  String get performers_gender_intersex => 'Intersexual';

  @override
  String get performers_gender_non_binary => 'No binario';

  @override
  String get performers_circumcised => 'Circuncidado';

  @override
  String get performers_circumcised_cut => 'Circuncidado';

  @override
  String get performers_circumcised_uncut => 'No circuncidado';

  @override
  String get performers_play_count => 'Número de reproducciones';

  @override
  String get performers_field_disambiguation => 'Desambiguación';

  @override
  String get performers_field_birthdate => 'Fecha de nacimiento';

  @override
  String get performers_field_deathdate => 'Fecha de fallecimiento';

  @override
  String get performers_field_height_cm => 'Altura (cm)';

  @override
  String get performers_field_weight_kg => 'Peso (kg)';

  @override
  String get performers_field_measurements => 'Medidas';

  @override
  String get performers_field_fake_tits => 'Pecho(s) falso(s)';

  @override
  String get performers_field_penis_length => 'Longitud del pene';

  @override
  String get performers_field_ethnicity => 'Etnia';

  @override
  String get performers_field_country => 'País';

  @override
  String get performers_field_eye_color => 'Color de ojos';

  @override
  String get performers_field_hair_color => 'Color de pelo';

  @override
  String get performers_field_career_start => 'Inicio de carrera';

  @override
  String get performers_field_career_end => 'Fin de carrera';

  @override
  String get performers_field_tattoos => 'Tatuajes';

  @override
  String get performers_field_piercings => 'Perforaciones';

  @override
  String get performers_field_aliases => 'Alias';

  @override
  String get common_organized => 'Organizado';

  @override
  String get scenes_duplicated => 'Duplicado';

  @override
  String get random_studio => 'estudio aleatorio';

  @override
  String get random_gallery => 'galería aleatoria';

  @override
  String get random_tag => 'etiqueta aleatoria';

  @override
  String get random_scene => 'escena aleatoria';

  @override
  String get random_performer => 'intérprete aleatorio';

  @override
  String get filter_modifier => 'Modificador';

  @override
  String get filter_group_general => 'General';

  @override
  String get filter_group_performer => 'Intérprete';

  @override
  String get filter_group_library => 'Biblioteca';

  @override
  String get filter_group_metadata => 'Metadatos';

  @override
  String get filter_group_media_info => 'Info. de medios';

  @override
  String get filter_group_usage => 'Uso';

  @override
  String get filter_group_system => 'Sistema';

  @override
  String get filter_group_physical => 'Físico';

  @override
  String get filter_equals => 'Igual';

  @override
  String get filter_not_equals => 'No igual';

  @override
  String get filter_greater_than => 'Mayor que';

  @override
  String get filter_less_than => 'Menor que';

  @override
  String get filter_is_null => 'Es nulo';

  @override
  String get filter_not_null => 'No es nulo';

  @override
  String get images_resolution_title => 'Resolución';

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
  String get images_orientation_title => 'Orientación';

  @override
  String get common_or => 'O';

  @override
  String get scrape_from_url => 'Raspar desde URL';

  @override
  String get scenes_phash_started => 'Generación de phash iniciada';

  @override
  String scenes_phash_failed(Object error) {
    return 'Error al generar phash: $error';
  }

  @override
  String details_failed_update_studio(Object error) {
    return 'Error al actualizar el estudio: $error';
  }

  @override
  String get settings_title => 'Ajustes';

  @override
  String get settings_customize => 'Personalizar StashFlow';

  @override
  String get settings_customize_subtitle =>
      'Ajusta la reproducción, apariencia, diseño y herramientas de soporte desde un solo lugar.';

  @override
  String get settings_core_section => 'Ajustes principales';

  @override
  String get settings_core_subtitle =>
      'Páginas de configuración más utilizadas';

  @override
  String get settings_server => 'Servidor';

  @override
  String get settings_server_subtitle => 'Configuración de conexión y API';

  @override
  String get settings_playback => 'Reproducción';

  @override
  String get settings_playback_subtitle =>
      'Comportamiento e interacciones del reproductor';

  @override
  String get settings_keyboard => 'Teclado';

  @override
  String get settings_keyboard_subtitle =>
      'Atajos y teclas de acceso rápido personalizables';

  @override
  String get settings_keyboard_title => 'Atajos de teclado';

  @override
  String get settings_keyboard_reset_defaults =>
      'Restablecer valores predeterminados';

  @override
  String get settings_keyboard_not_bound => 'No asignado';

  @override
  String get settings_keyboard_volume_up => 'Subir volumen';

  @override
  String get settings_keyboard_volume_down => 'Bajar volumen';

  @override
  String get settings_keyboard_toggle_mute => 'Alternar silencio';

  @override
  String get settings_keyboard_toggle_fullscreen =>
      'Alternar pantalla completa';

  @override
  String get settings_keyboard_next_scene => 'Siguiente escena';

  @override
  String get settings_keyboard_prev_scene => 'Escena anterior';

  @override
  String get settings_keyboard_increase_speed =>
      'Aumentar velocidad de reproducción';

  @override
  String get settings_keyboard_decrease_speed =>
      'Disminuir velocidad de reproducción';

  @override
  String get settings_keyboard_reset_speed =>
      'Restablecer velocidad de reproducción';

  @override
  String get settings_keyboard_close_player => 'Cerrar reproductor';

  @override
  String get settings_keyboard_next_image => 'Siguiente imagen';

  @override
  String get settings_keyboard_prev_image => 'Imagen anterior';

  @override
  String get settings_keyboard_go_back => 'Volver';

  @override
  String get settings_keyboard_play_pause_desc =>
      'Alternar entre reproducir y pausar video';

  @override
  String get settings_keyboard_seek_forward_5_desc =>
      'Saltar adelante 5 segundos';

  @override
  String get settings_keyboard_seek_backward_5_desc =>
      'Saltar atrás 5 segundos';

  @override
  String get settings_keyboard_seek_forward_10_desc =>
      'Saltar adelante 10 segundos';

  @override
  String get settings_keyboard_seek_backward_10_desc =>
      'Saltar atrás 10 segundos';

  @override
  String get settings_appearance => 'Apariencia';

  @override
  String get settings_appearance_subtitle => 'Tema y colores';

  @override
  String get settings_interface => 'Interfaz';

  @override
  String get settings_interface_subtitle =>
      'Valores predeterminados de navegación y diseño';

  @override
  String get settings_support => 'Soporte';

  @override
  String get settings_support_subtitle => 'Diagnósticos y acerca de';

  @override
  String get settings_develop => 'Desarrollo';

  @override
  String get settings_develop_subtitle =>
      'Herramientas avanzadas y anulaciones';

  @override
  String get settings_appearance_title => 'Ajustes de apariencia';

  @override
  String get settings_appearance_theme_mode => 'Modo de tema';

  @override
  String get settings_appearance_theme_mode_subtitle =>
      'Elige cómo la aplicación sigue los cambios de brillo';

  @override
  String get settings_appearance_theme_system => 'Sistema';

  @override
  String get settings_appearance_theme_light => 'Claro';

  @override
  String get settings_appearance_theme_dark => 'Oscuro';

  @override
  String get settings_appearance_primary_color => 'Color primario';

  @override
  String get settings_appearance_primary_color_subtitle =>
      'Elige un color base para la paleta Material 3';

  @override
  String get settings_appearance_advanced_theming => 'Tematización avanzada';

  @override
  String get settings_appearance_advanced_theming_subtitle =>
      'Optimizaciones para tipos de pantalla específicos';

  @override
  String get settings_appearance_true_black => 'Negro puro (AMOLED)';

  @override
  String get settings_appearance_true_black_subtitle =>
      'Usa fondos negros puros en el modo oscuro para ahorrar batería en pantallas OLED';

  @override
  String get settings_appearance_custom_hex =>
      'Color hexadecimal personalizado';

  @override
  String get settings_appearance_custom_hex_helper =>
      'Introduce un código hexadecimal ARGB de 8 dígitos';

  @override
  String get settings_appearance_font_size =>
      'Escala de interfaz de usuario global';

  @override
  String get settings_appearance_font_size_subtitle =>
      'Escalar la tipografía y el espaciado proporcionalmente';

  @override
  String get settings_interface_title => 'Ajustes de interfaz';

  @override
  String get settings_interface_language => 'Idioma';

  @override
  String get settings_interface_language_subtitle =>
      'Anular el idioma predeterminado del sistema';

  @override
  String get settings_interface_app_language => 'Idioma de la aplicación';

  @override
  String get settings_interface_navigation => 'Navegación';

  @override
  String get settings_interface_navigation_subtitle =>
      'Visibilidad de los atajos de navegación global';

  @override
  String get settings_interface_show_random =>
      'Mostrar botones de navegación aleatoria';

  @override
  String get settings_interface_show_random_subtitle =>
      'Habilitar o deshabilitar los botones flotantes de casino en las páginas de lista y detalles';

  @override
  String get settings_interface_main_pages_gravity_orientation =>
      'Orientación controlada por gravedad (páginas principales)';

  @override
  String get settings_interface_main_pages_gravity_orientation_subtitle =>
      'Permite que las páginas principales roten usando el sensor del dispositivo. La reproducción de video en pantalla completa usa su propia configuración de orientación.';

  @override
  String get settings_interface_show_edit => 'Mostrar botón de editar';

  @override
  String get settings_interface_show_edit_subtitle =>
      'Habilitar o deshabilitar el botón de editar en la página de detalles de la escena';

  @override
  String get settings_interface_customize_tabs => 'Personalizar pestañas';

  @override
  String get settings_interface_customize_tabs_subtitle =>
      'Reordenar u ocultar elementos del menú de navegación';

  @override
  String get settings_interface_scenes_layout => 'Diseño de escenas';

  @override
  String get settings_interface_scenes_layout_subtitle =>
      'Modo de navegación predeterminado para escenas';

  @override
  String get settings_interface_galleries_layout => 'Diseño de galerías';

  @override
  String get settings_interface_galleries_layout_subtitle =>
      'Modo de navegación predeterminado para galerías';

  @override
  String get settings_interface_max_performer_avatars =>
      'Máximo de avatares de intérpretes';

  @override
  String get settings_interface_max_performer_avatars_subtitle =>
      'Número máximo de avatares de intérpretes a mostrar en la tarjeta de escena.';

  @override
  String get settings_interface_show_performer_avatars =>
      'Mostrar avatares de intérpretes';

  @override
  String get settings_interface_show_performer_avatars_subtitle =>
      'Mostrar iconos de intérpretes en las tarjetas de escena en todas las plataformas.';

  @override
  String get settings_interface_performer_avatar_size =>
      'Tamaño del avatar del intérprete';

  @override
  String get settings_interface_layout_default => 'Diseño predeterminado';

  @override
  String get settings_interface_layout_default_desc =>
      'Elige el diseño predeterminado para la página';

  @override
  String get settings_interface_layout_list => 'Lista';

  @override
  String get settings_interface_layout_grid => 'Cuadrícula';

  @override
  String get settings_interface_layout_tiktok => 'Desplazamiento infinito';

  @override
  String get settings_interface_grid_columns => 'Columnas de la cuadrícula';

  @override
  String get settings_interface_image_viewer => 'Visor de imágenes';

  @override
  String get settings_interface_image_viewer_subtitle =>
      'Configurar el comportamiento de navegación de imágenes a pantalla completa';

  @override
  String get settings_interface_swipe_direction =>
      'Dirección de deslizamiento a pantalla completa';

  @override
  String get settings_interface_swipe_direction_desc =>
      'Elige cómo avanzan las imágenes en el modo de pantalla completa';

  @override
  String get settings_interface_swipe_vertical => 'Vertical';

  @override
  String get settings_interface_swipe_horizontal => 'Horizontal';

  @override
  String get settings_interface_waterfall_columns =>
      'Columnas de cuadrícula en cascada';

  @override
  String get settings_interface_performer_layouts => 'Diseños de actores';

  @override
  String get settings_interface_performer_layouts_subtitle =>
      'Valores predeterminados de medios y galerías para actores';

  @override
  String get settings_interface_studio_layouts => 'Diseños de estudios';

  @override
  String get settings_interface_studio_layouts_subtitle =>
      'Valores predeterminados de medios y galerías para estudios';

  @override
  String get settings_interface_tag_layouts => 'Diseños de etiquetas';

  @override
  String get settings_interface_tag_layouts_subtitle =>
      'Valores predeterminados de medios y galerías para etiquetas';

  @override
  String get settings_interface_media_layout => 'Diseño de medios';

  @override
  String get settings_interface_media_layout_subtitle =>
      'Diseño para la página de medios';

  @override
  String get settings_interface_galleries_layout_item => 'Diseño de galerías';

  @override
  String get settings_interface_galleries_layout_subtitle_item =>
      'Diseño para la página de galerías';

  @override
  String get settings_server_title => 'Ajustes del servidor';

  @override
  String get settings_server_status => 'Estado de la conexión';

  @override
  String get settings_server_status_subtitle =>
      'Conectividad en vivo con el servidor configurado';

  @override
  String get settings_server_details => 'Detalles del servidor';

  @override
  String get settings_server_details_subtitle =>
      'Configurar el endpoint y el método de autenticación';

  @override
  String get settings_server_url => 'URL de Stash';

  @override
  String get settings_server_url_helper =>
      'Introduce la URL de tu servidor Stash. Si está configurado con una ruta personalizada, inclúyela aquí.';

  @override
  String get settings_server_url_example => 'http://192.168.1.100:9999';

  @override
  String get settings_server_login_failed => 'Error de inicio de sesión';

  @override
  String get settings_server_auth_method => 'Método de autenticación';

  @override
  String get settings_server_auth_apikey => 'Clave API';

  @override
  String get settings_server_auth_password => 'Usuario + Contraseña';

  @override
  String get settings_server_auth_password_desc =>
      'Recomendado: usa tu sesión de usuario/contraseña de Stash.';

  @override
  String get settings_server_auth_apikey_desc =>
      'Usa la clave API para la autenticación de token estático.';

  @override
  String get settings_server_username => 'Nombre de usuario';

  @override
  String get settings_server_password => 'Contraseña';

  @override
  String get settings_server_login_test => 'Iniciar sesión y probar';

  @override
  String get settings_server_test => 'Probar conexión';

  @override
  String get settings_server_logout => 'Cerrar sesión';

  @override
  String get settings_server_clear => 'Borrar ajustes';

  @override
  String settings_server_connected(String version) {
    return 'Conectado (Stash $version)';
  }

  @override
  String get settings_server_checking => 'Comprobando conexión...';

  @override
  String settings_server_failed(String error) {
    return 'Fallo: $error';
  }

  @override
  String get settings_server_invalid_url => 'URL del servidor no válida';

  @override
  String get settings_server_resolve_error =>
      'No se pudo resolver la URL del servidor. Comprueba el host, el puerto y las credenciales.';

  @override
  String get settings_server_logout_confirm =>
      'Sesión cerrada y cookies borradas.';

  @override
  String get settings_server_profile_add => 'Añadir perfil';

  @override
  String get settings_server_profile_edit => 'Editar perfil';

  @override
  String get settings_server_profile_name => 'Nombre del perfil';

  @override
  String get settings_server_profile_delete => 'Eliminar perfil';

  @override
  String get settings_server_profile_delete_confirm =>
      '¿Estás seguro de que quieres eliminar este perfil? Esta acción no se puede deshacer.';

  @override
  String get settings_server_profile_active => 'Activo';

  @override
  String get settings_server_profile_empty =>
      'No hay perfiles de servidor configurados';

  @override
  String get settings_server_profiles => 'Perfiles de servidor';

  @override
  String get settings_server_profiles_subtitle =>
      'Gestionar múltiples conexiones de servidor Stash';

  @override
  String get settings_server_auth_status_logging_in =>
      'Estado de autenticación: iniciando sesión...';

  @override
  String get settings_server_auth_status_logged_in =>
      'Estado de autenticación: sesión iniciada';

  @override
  String get settings_server_auth_status_logged_out =>
      'Estado de autenticación: sesión cerrada';

  @override
  String get settings_playback_title => 'Ajustes de reproducción';

  @override
  String get settings_playback_behavior => 'Comportamiento de reproducción';

  @override
  String get settings_playback_behavior_subtitle =>
      'Manejo predeterminado de la reproducción y el segundo plano';

  @override
  String get settings_playback_prefer_streams =>
      'Preferir sceneStreams primero';

  @override
  String get settings_playback_prefer_streams_subtitle =>
      'Cuando está desactivado, la reproducción usa directamente paths.stream';

  @override
  String get settings_playback_end_behavior =>
      'Comportamiento de finalización del juego';

  @override
  String get settings_playback_end_behavior_subtitle =>
      'Qué hacer cuando finaliza la reproducción actual';

  @override
  String get settings_playback_end_behavior_stop => 'Detener';

  @override
  String get settings_playback_end_behavior_loop => 'Bucle de escena actual';

  @override
  String get settings_playback_end_behavior_next =>
      'Reproducir la siguiente escena';

  @override
  String get settings_playback_autoplay =>
      'Reproducción automática de la siguiente escena';

  @override
  String get settings_playback_autoplay_subtitle =>
      'Reproducir automáticamente la siguiente escena cuando finalice la reproducción actual';

  @override
  String get settings_playback_background => 'Reproducción en segundo plano';

  @override
  String get settings_playback_background_subtitle =>
      'Mantener el audio del video reproduciéndose cuando la aplicación está en segundo plano';

  @override
  String get settings_playback_pip => 'Imagen en imagen nativa';

  @override
  String get settings_playback_pip_subtitle =>
      'Habilitar el botón PiP de Android y entrar automáticamente al pasar a segundo plano';

  @override
  String get settings_playback_subtitles => 'Ajustes de subtítulos';

  @override
  String get settings_playback_subtitles_subtitle =>
      'Carga automática y apariencia';

  @override
  String get settings_playback_subtitle_lang =>
      'Idioma de subtítulos predeterminado';

  @override
  String get settings_playback_subtitle_lang_subtitle =>
      'Carga automática si está disponible';

  @override
  String get settings_playback_subtitle_size =>
      'Tamaño de fuente de los subtítulos';

  @override
  String get settings_playback_subtitle_pos =>
      'Posición vertical de los subtítulos';

  @override
  String settings_playback_subtitle_pos_desc(String percent) {
    return '$percent% desde abajo';
  }

  @override
  String get settings_playback_subtitle_align =>
      'Alineación del texto de los subtítulos';

  @override
  String get settings_playback_subtitle_align_subtitle =>
      'Alineación para subtítulos de varias líneas';

  @override
  String get settings_playback_seek => 'Interacción de búsqueda';

  @override
  String get settings_playback_seek_subtitle =>
      'Elige cómo funciona el desplazamiento durante la reproducción';

  @override
  String get settings_playback_seek_double_tap =>
      'Doble toque izquierda/derecha para buscar 10s';

  @override
  String get settings_playback_seek_drag =>
      'Arrastra la línea de tiempo para buscar';

  @override
  String get settings_playback_seek_drag_label => 'Arrastrar';

  @override
  String get settings_playback_seek_double_tap_label => 'Doble toque';

  @override
  String get settings_playback_gravity_orientation =>
      'Orientación controlada por la gravedad';

  @override
  String get settings_playback_direct_play =>
      'Reproducción directa al navegar por escenas';

  @override
  String get settings_playback_direct_play_subtitle =>
      'Al navegar desde otra escena en reproducción, reproducir directamente la nueva escena';

  @override
  String get settings_playback_gravity_orientation_subtitle =>
      'Permitir rotar entre orientaciones coincidentes usando el sensor del dispositivo (p. ej., girar el paisaje izquierda/derecha).';

  @override
  String get settings_playback_subtitle_lang_none_disabled =>
      'Ninguno (Desactivado)';

  @override
  String get settings_playback_subtitle_lang_auto_if_only_one =>
      'Automático (Si solo hay uno)';

  @override
  String get settings_playback_subtitle_lang_english => 'Inglés';

  @override
  String get settings_playback_subtitle_lang_chinese => 'Chino';

  @override
  String get settings_playback_subtitle_lang_german => 'Alemán';

  @override
  String get settings_playback_subtitle_lang_french => 'Francés';

  @override
  String get settings_playback_subtitle_lang_spanish => 'Español';

  @override
  String get settings_playback_subtitle_lang_italian => 'Italiano';

  @override
  String get settings_playback_subtitle_lang_japanese => 'Japonés';

  @override
  String get settings_playback_subtitle_lang_korean => 'Coreano';

  @override
  String get settings_playback_subtitle_align_left => 'Izquierda';

  @override
  String get settings_playback_subtitle_align_center => 'Centro';

  @override
  String get settings_playback_subtitle_align_right => 'Derecha';

  @override
  String get settings_support_title => 'Soporte';

  @override
  String get settings_support_diagnostics =>
      'Diagnósticos e información del proyecto';

  @override
  String get settings_support_diagnostics_subtitle =>
      'Abre los registros de ejecución o ve al repositorio cuando necesites ayuda.';

  @override
  String get settings_support_update_available => 'Actualización disponible';

  @override
  String get settings_support_update_available_subtitle =>
      'Hay una versión más reciente disponible en GitHub';

  @override
  String settings_support_update_to(String version) {
    return 'Actualizar a $version';
  }

  @override
  String get settings_support_update_to_subtitle =>
      'Nuevas características y mejoras te esperan.';

  @override
  String get settings_support_about => 'Acerca de';

  @override
  String get settings_support_about_subtitle =>
      'Información del proyecto y de las fuentes';

  @override
  String get settings_support_version => 'Versión';

  @override
  String get settings_support_version_loading =>
      'Cargando información de la versión...';

  @override
  String get settings_support_version_unavailable =>
      'Información de la versión no disponible';

  @override
  String get settings_support_github => 'Repositorio de GitHub';

  @override
  String get settings_support_github_subtitle =>
      'Ver el código fuente e informar de problemas';

  @override
  String get settings_support_github_error =>
      'No se pudo abrir el enlace de GitHub';

  @override
  String get settings_support_issues => 'Informar un problema';

  @override
  String get settings_support_issues_subtitle =>
      'Ayude a mejorar StashFlow informando errores';

  @override
  String get settings_develop_title => 'Desarrollo';

  @override
  String get settings_develop_diagnostics => 'Herramientas de diagnóstico';

  @override
  String get settings_develop_diagnostics_subtitle =>
      'Solución de problemas y rendimiento';

  @override
  String get settings_develop_video_debug =>
      'Mostrar información de depuración de video';

  @override
  String get settings_develop_video_debug_subtitle =>
      'Muestra detalles técnicos de reproducción como una superposición en el reproductor de video.';

  @override
  String get settings_develop_log_viewer => 'Visor de registros de depuración';

  @override
  String get settings_develop_log_viewer_subtitle =>
      'Abre una vista en vivo de los registros de la aplicación.';

  @override
  String get settings_develop_logs_copied =>
      'Registros copiados al portapapeles';

  @override
  String get settings_develop_no_logs =>
      'No hay registros todavía. Interactúa con la app para capturar registros.';

  @override
  String get settings_develop_web_overrides => 'Anulaciones web';

  @override
  String get settings_develop_web_overrides_subtitle =>
      'Indicadores avanzados para la plataforma web';

  @override
  String get settings_develop_web_auth =>
      'Permitir inicio de sesión con contraseña en la web';

  @override
  String get settings_develop_web_auth_subtitle =>
      'Anula la restricción solo nativa y fuerza a que el método de autenticación Usuario + Contraseña sea visible en Flutter Web.';

  @override
  String get settings_develop_proxy_auth =>
      'Habilitar modos de autenticación de proxy';

  @override
  String get settings_develop_proxy_auth_subtitle =>
      'Habilite los métodos avanzados de Basic Auth y Bearer Token para su uso con backends sin autenticación detrás de proxies como Authentik.';

  @override
  String get settings_server_auth_basic => 'Autenticación básica';

  @override
  String get settings_server_auth_bearer => 'Token de portador';

  @override
  String get settings_server_auth_basic_desc =>
      'Envía el encabezado \'Authorization: Basic <base64(user:pass)>\'.';

  @override
  String get settings_server_auth_bearer_desc =>
      'Envía el encabezado \'Authorization: Bearer <token>\'.';

  @override
  String get common_edit => 'Editar';

  @override
  String get common_resolution => 'Resolución';

  @override
  String get common_orientation => 'Orientación';

  @override
  String get common_landscape => 'Horizontal';

  @override
  String get common_portrait => 'Vertical';

  @override
  String get common_square => 'Cuadrado';

  @override
  String get performers_filter_saved =>
      'Preferencias de filtro guardadas como predeterminadas';

  @override
  String get images_title => 'Imágenes';

  @override
  String get images_filter_title => 'Filtrar imágenes';

  @override
  String get images_filter_saved =>
      'Preferencias de filtro guardadas como predeterminadas';

  @override
  String get images_sort_title => 'Ordenar imágenes';

  @override
  String get images_sort_saved =>
      'Preferencias de orden guardadas como predeterminadas';

  @override
  String get image_rating_updated => 'Clasificación de la imagen actualizada.';

  @override
  String get gallery_rating_updated =>
      'Clasificación de la galería actualizada.';

  @override
  String get common_image => 'Imagen';

  @override
  String get common_gallery => 'Galería';

  @override
  String get images_gallery_rating_unavailable =>
      'La clasificación de la galería solo está disponible cuando se navega en una galería.';

  @override
  String images_rating(String rating) {
    return 'Clasificación: $rating / 5';
  }

  @override
  String get images_filtered_by_gallery => 'Filtrado por galería';

  @override
  String get images_slideshow_need_two =>
      'Se necesitan al menos 2 imágenes para la presentación.';

  @override
  String get images_slideshow_start_title => 'Iniciar presentación';

  @override
  String images_slideshow_interval(num seconds) {
    return 'Intervalo: ${seconds}s';
  }

  @override
  String images_slideshow_transition_ms(num ms) {
    return 'Transición: ${ms}ms';
  }

  @override
  String get common_forward => 'Adelante';

  @override
  String get common_backward => 'Atrás';

  @override
  String get images_slideshow_loop_title => 'Repetir presentación';

  @override
  String get common_cancel => 'Cancelar';

  @override
  String get common_start => 'Iniciar';

  @override
  String get common_done => 'Hecho';

  @override
  String get settings_keybind_assign_shortcut => 'Asignar acceso directo';

  @override
  String get settings_keybind_press_any =>
      'Presiona cualquier combinación de teclas...';

  @override
  String get scenes_select_tags => 'Seleccionar etiquetas';

  @override
  String get scenes_no_scrapers => 'No hay scrapers disponibles';

  @override
  String get scenes_select_scraper => 'Seleccionar scraper';

  @override
  String get scenes_no_results_found => 'No se encontraron resultados';

  @override
  String get scenes_select_result => 'Seleccionar resultado';

  @override
  String scenes_scrape_failed(String error) {
    return 'Error de extracción: $error';
  }

  @override
  String get scenes_updated_successfully => 'Escena actualizada con éxito';

  @override
  String scenes_update_failed(String error) {
    return 'Error al actualizar la escena: $error';
  }

  @override
  String get scenes_edit_title => 'Editar escena';

  @override
  String get scenes_field_studio => 'Estudio';

  @override
  String get scenes_field_tags => 'Etiquetas';

  @override
  String get scenes_field_urls => 'Enlaces';

  @override
  String get scenes_edit_performer => 'Editar intérprete';

  @override
  String get scenes_edit_studio => 'Editar estudio';

  @override
  String get common_no_title => 'Sin título';

  @override
  String get scenes_select_studio => 'Seleccionar estudio';

  @override
  String get scenes_select_performers => 'Seleccionar intérpretes';

  @override
  String get scenes_unmatched_scraped_tags =>
      'Etiquetas obtenidas sin emparejar';

  @override
  String get scenes_unmatched_scraped_performers =>
      'Actores obtenidos sin emparejar';

  @override
  String get scenes_no_matching_performer_found =>
      'No se encontró un intérprete coincidente en la biblioteca';

  @override
  String get common_unknown => 'Desconocido';

  @override
  String scenes_studio_id_prefix(String id) {
    return 'ID del estudio: $id';
  }

  @override
  String get tags_search_placeholder => 'Buscar etiquetas...';

  @override
  String get scenes_duration_short => '< 5 min.';

  @override
  String get scenes_duration_medium => '5-20 min.';

  @override
  String get scenes_duration_long => '> 20 min.';

  @override
  String get details_scene_fingerprint_query =>
      'Consulta de huella de la escena';

  @override
  String get scenes_available_scrapers => 'Scrapers disponibles';

  @override
  String get scrape_results_existing => 'Existente';

  @override
  String get scrape_results_scraped => 'Extraído';

  @override
  String get stats_refresh_statistics => 'Actualizar estadísticas';

  @override
  String get stats_library_stats => 'Estadísticas de la biblioteca';

  @override
  String get stats_stash_glance => 'Tu alijo de un vistazo';

  @override
  String get stats_content => 'Contenido';

  @override
  String get stats_organization => 'Organización';

  @override
  String get stats_activity => 'Actividad';

  @override
  String get stats_scenes => 'Escenas';

  @override
  String get stats_galleries => 'Galerías';

  @override
  String get stats_performers => 'Artistas';

  @override
  String get stats_studios => 'Estudios';

  @override
  String get stats_groups => 'Grupos';

  @override
  String get stats_tags => 'Etiquetas';

  @override
  String get stats_total_plays => 'Total de jugadas';

  @override
  String stats_unique_items(int count) {
    return '$count unique items';
  }

  @override
  String get stats_total_o_count => 'Total O-Recuento';

  @override
  String get cast_airplay_pairing => 'Emparejamiento AirPlay';

  @override
  String get cast_enter_pin =>
      'Ingrese el PIN de 4 dígitos que se muestra en su televisor';

  @override
  String get cast_pair => 'Par';

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
  String get cast_searching => 'Buscando dispositivos...';

  @override
  String get cast_cast_to_device => 'Transmitir al dispositivo';

  @override
  String get settings_storage_images => 'Imágenes';

  @override
  String get settings_storage_videos => 'Vídeos';

  @override
  String get settings_storage_database => 'Base de datos';

  @override
  String get settings_storage_clearing_image => 'Borrando caché de imágenes...';

  @override
  String get settings_storage_clearing_video => 'Borrando caché de vídeo...';

  @override
  String get settings_storage_clearing_database =>
      'Borrando el caché de la base de datos...';

  @override
  String get settings_storage_cleared_image => 'Caché de imagen borrado';

  @override
  String get settings_storage_cleared_video => 'Caché de vídeo borrada';

  @override
  String get settings_storage_cleared_database =>
      'Caché de base de datos borrado';

  @override
  String get settings_storage_clear => 'Claro';

  @override
  String get settings_storage_error_loading => 'Error al cargar tamaños';

  @override
  String settings_storage_mb(num value) {
    return '$value MB';
  }

  @override
  String settings_storage_gb(num value) {
    return '$value GB';
  }

  @override
  String get settings_storage_100_mb => '100 megas';

  @override
  String get settings_storage_500_mb => '500 megas';

  @override
  String get settings_storage_1_gb => '1GB';

  @override
  String get settings_storage_2_gb => '2GB';

  @override
  String get settings_storage_unlimited => 'Ilimitado';

  @override
  String get settings_storage_limits => 'Límites';

  @override
  String get settings_storage_limits_subtitle =>
      'Establecer tamaños máximos de caché';

  @override
  String get settings_storage_max_image_cache => 'Caché de imagen máxima (MB)';

  @override
  String get settings_storage_max_video_cache => 'Caché de vídeo máxima (MB)';

  @override
  String get settings_storage => 'Almacenamiento y caché';

  @override
  String get settings_storage_usage => 'Uso de almacenamiento';

  @override
  String get settings_storage_usage_subtitle => 'Espacio usado por la caché';

  @override
  String get settings_storage_subtitle =>
      'Administrar cachés locales y límites de almacenamiento';

  @override
  String get performers_field_name => 'Nombre';

  @override
  String get performers_field_url => 'URL';

  @override
  String get performers_field_details => 'Detalles';

  @override
  String get performers_field_birth_year => 'Año de nacimiento';

  @override
  String get performers_field_age => 'Edad';

  @override
  String get performers_field_death_year => 'Año de fallecimiento';

  @override
  String get performers_field_scene_count => 'Número de escenas';

  @override
  String get performers_field_image_count => 'Número de imágenes';

  @override
  String get performers_field_gallery_count => 'Número de galerías';

  @override
  String get performers_field_play_count => 'Número de reproducciones';

  @override
  String get performers_field_o_counter => 'Contador O';

  @override
  String get performers_field_tag_count => 'Número de etiquetas';

  @override
  String get performers_field_created_at => 'Creado el';

  @override
  String get performers_field_updated_at => 'Actualizado el';

  @override
  String get galleries_field_title => 'Título';

  @override
  String get galleries_field_details => 'Detalles';

  @override
  String get galleries_field_date => 'Fecha';

  @override
  String get galleries_field_performer_age => 'Edad del artista';

  @override
  String get galleries_field_performer_count => 'Número de artistas';

  @override
  String get galleries_field_tag_count => 'Número de etiquetas';

  @override
  String get galleries_field_url => 'URL';

  @override
  String get galleries_field_id => 'ID';

  @override
  String get galleries_field_path => 'Ruta';

  @override
  String get galleries_field_checksum => 'Suma de comprobación';

  @override
  String get galleries_field_image_count => 'Número de imágenes';

  @override
  String get galleries_field_file_count => 'Número de archivos';

  @override
  String get galleries_field_created_at => 'Creado el';

  @override
  String get galleries_field_updated_at => 'Actualizado el';

  @override
  String get images_field_title => 'Título';

  @override
  String get images_field_details => 'Detalles';

  @override
  String get images_field_path => 'Ruta';

  @override
  String get images_field_url => 'URL';

  @override
  String get images_field_file_count => 'Número de archivos';

  @override
  String get images_field_o_counter => 'Contador O';

  @override
  String get studios_field_name => 'Nombre';

  @override
  String get studios_field_details => 'Detalles';

  @override
  String get studios_field_aliases => 'Alias';

  @override
  String get studios_field_url => 'URL';

  @override
  String get studios_field_tag_count => 'Número de etiquetas';

  @override
  String get studios_field_scene_count => 'Número de escenas';

  @override
  String get studios_field_image_count => 'Número de imágenes';

  @override
  String get studios_field_gallery_count => 'Número de galerías';

  @override
  String get studios_field_sub_studio_count => 'Número de sub-estudios';

  @override
  String get studios_field_created_at => 'Creado el';

  @override
  String get studios_field_updated_at => 'Actualizado el';

  @override
  String get scenes_field_performer_age => 'Edad del artista';

  @override
  String get scenes_field_performer_count => 'Número de artistas';

  @override
  String get scenes_field_tag_count => 'Número de etiquetas';

  @override
  String get scenes_field_code => 'Código';

  @override
  String get scenes_field_details => 'Detalles';

  @override
  String get scenes_field_director => 'Director';

  @override
  String get scenes_field_url => 'URL';

  @override
  String get scenes_field_date => 'Fecha';

  @override
  String get scenes_field_path => 'Ruta';

  @override
  String get scenes_field_captions => 'Subtítulos';

  @override
  String get scenes_field_duration => 'Duración (segundos)';

  @override
  String get scenes_field_bitrate => 'Tasa de bits';

  @override
  String get scenes_field_video_codec => 'Códec de vídeo';

  @override
  String get scenes_field_audio_codec => 'Códec de audio';

  @override
  String get scenes_field_framerate => 'Frecuencia de cuadros';

  @override
  String get scenes_field_file_count => 'Número de archivos';

  @override
  String get scenes_field_play_count => 'Número de reproducciones';

  @override
  String get scenes_field_play_duration => 'Duración de reproducción';

  @override
  String get scenes_field_o_counter => 'Contador O';

  @override
  String get scenes_field_last_played_at => 'Última reproducción';

  @override
  String get scenes_field_resume_time => 'Tiempo de reanudación';

  @override
  String get scenes_field_interactive_speed => 'Velocidad interactiva';

  @override
  String get scenes_field_id => 'ID';

  @override
  String get scenes_field_stash_id_count => 'Recuento de IDs de Stash';

  @override
  String get scenes_field_oshash => 'Oshash';

  @override
  String get scenes_field_checksum => 'Suma de comprobación';

  @override
  String get scenes_field_phash => 'Phash';

  @override
  String get scenes_field_created_at => 'Creado el';

  @override
  String get scenes_field_updated_at => 'Actualizado el';

  @override
  String get cast_stopped_resuming_locally =>
      'Transmisión detenida, reanudando localmente';

  @override
  String get cast_stop_casting => 'Detener transmisión';

  @override
  String get cast_cast => 'Transmitir';

  @override
  String get common_add => 'Añadir';

  @override
  String get common_remove => 'Eliminar';

  @override
  String get common_clear => 'Limpiar';

  @override
  String get common_download => 'Descargar';

  @override
  String get common_star => 'Estrella';

  @override
  String get settings_interface_card_title_font_size =>
      'Tamaño de fuente del título de la tarjeta';

  @override
  String get common_hint_date => 'AAAA-MM-DD';

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
  String get saving_video => 'Guardando en galería...';

  @override
  String get saved_to_album => 'Guardado en álbum de StashFlow';

  @override
  String gallery_error(String message) {
    return 'Error de galería: $message';
  }

  @override
  String failed_to_save(String error) {
    return 'Error al guardar: $error';
  }

  @override
  String get saving_image => 'Guardando imagen...';

  @override
  String common_select(String label) {
    return 'Seleccionar $label';
  }

  @override
  String common_saved_to(String path) {
    return 'Guardado en $path';
  }
}
