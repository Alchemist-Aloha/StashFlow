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
  String get common_later => 'Más tarde';

  @override
  String get common_update_now => 'Actualizar ahora';

  @override
  String get common_configure_now => 'Configurar ahora';

  @override
  String get common_clear_rating => 'Borrar calificación';

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
}
