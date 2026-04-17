// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'StashFlow';

  @override
  String get nav_scenes => 'Сцены';

  @override
  String get nav_performers => 'Исполнители';

  @override
  String get nav_studios => 'Студии';

  @override
  String get nav_tags => 'Теги';

  @override
  String get nav_galleries => 'Галереи';

  @override
  String nScenes(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString сцен',
      few: '$countString сцены',
      one: '$countString сцена',
      zero: 'нет сцен',
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
      other: '$countString исполнителей',
      few: '$countString исполнителя',
      one: '$countString исполнитель',
      zero: 'нет исполнителей',
    );
    return '$_temp0';
  }

  @override
  String get common_reset => 'Сбросить';

  @override
  String get common_apply => 'Применить';

  @override
  String get common_save_default => 'Сохранить по умолчанию';

  @override
  String get common_sort_method => 'Способ сортировки';

  @override
  String get common_direction => 'Направление';

  @override
  String get common_ascending => 'По возрастанию';

  @override
  String get common_descending => 'По убыванию';

  @override
  String get common_favorites_only => 'Только избранное';

  @override
  String get common_apply_sort => 'Применить сортировку';

  @override
  String get common_apply_filters => 'Применить фильтры';

  @override
  String get common_view_all => 'Посмотреть все';

  @override
  String get common_later => 'Позже';

  @override
  String get common_update_now => 'Обновить сейчас';

  @override
  String get common_configure_now => 'Настроить сейчас';

  @override
  String get common_clear_rating => 'Очистить рейтинг';

  @override
  String get common_no_media => 'Медиафайлы отсутствуют';

  @override
  String get common_setup_required => 'Требуется настройка';

  @override
  String get common_update_available => 'Доступно обновление';

  @override
  String get details_studio => 'Подробности о студии';

  @override
  String get details_performer => 'Подробности об исполнителе';

  @override
  String get details_tag => 'Подробности о теге';

  @override
  String get details_scene => 'Подробности о сцене';

  @override
  String get details_gallery => 'Подробности о галерее';

  @override
  String get studios_filter_title => 'Фильтр студий';

  @override
  String get studios_filter_saved => 'Настройки фильтра сохранены по умолчанию';

  @override
  String get sort_name => 'Имя';

  @override
  String get sort_scene_count => 'Количество сцен';

  @override
  String get sort_rating => 'Рейтинг';

  @override
  String get sort_updated_at => 'Обновлено';

  @override
  String get sort_created_at => 'Создано';

  @override
  String get sort_random => 'Случайно';

  @override
  String get studios_sort_saved =>
      'Настройки сортировки сохранены по умолчанию';

  @override
  String get studios_no_random => 'Нет доступных студий для случайного выбора';

  @override
  String get tags_filter_title => 'Фильтр тегов';

  @override
  String get tags_filter_saved => 'Настройки фильтра сохранены по умолчанию';

  @override
  String get tags_sort_saved => 'Настройки сортировки сохранены по умолчанию';

  @override
  String get tags_no_random => 'Нет доступных тегов для случайного выбора';

  @override
  String get scenes_no_random => 'Нет доступных сцен для случайного выбора';

  @override
  String get performers_no_random =>
      'Нет доступных исполнителей для случайного выбора';

  @override
  String get galleries_no_random =>
      'Нет доступных галерей для случайного выбора';

  @override
  String common_error(String message) {
    return 'Ошибка: $message';
  }
}
