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
  String get common_loading => 'cargando';

  @override
  String get common_unavailable => 'no disponible';

  @override
  String get common_details => 'detalles';

  @override
  String get common_title => 'título';

  @override
  String get common_release_date => 'fecha de estreno';

  @override
  String get common_url => 'URL';

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
  String get details_group => 'detalles del grupo';

  @override
  String get details_scene_scrape => 'extraer metadatos';

  @override
  String get details_scene_add_performer => 'añadir intérprete';

  @override
  String get details_scene_add_tag => 'añadir etiqueta';

  @override
  String get details_scene_add_url => 'añadir URL';

  @override
  String get details_scene_remove_url => 'quitar URL';

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
  String get settings_interface_shake_random => 'Agitar para descubrir';

  @override
  String get settings_interface_shake_random_subtitle =>
      'Agita tu dispositivo para saltar a un elemento aleatorio en la pestaña actual';

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
  String get settings_server_url => 'URL del servidor GraphQL';

  @override
  String get settings_server_url_helper =>
      'Formato de ejemplo: http(s)://host:puerto/graphql.';

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
}
