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
  String get common_default => 'По умолчанию';

  @override
  String get common_later => 'Позже';

  @override
  String get common_update_now => 'Обновить сейчас';

  @override
  String get common_configure_now => 'Настроить сейчас';

  @override
  String get common_clear_rating => 'очистить рейтинг';

  @override
  String get common_no_media => 'Медиафайлы отсутствуют';

  @override
  String get common_show => 'показать';

  @override
  String get common_hide => 'скрыть';

  @override
  String get galleries_filter_saved =>
      'Настройки фильтра сохранены по умолчанию';

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
  String get sort_file_mod_time => 'Время изменения файла';

  @override
  String get sort_filesize => 'Размер файла';

  @override
  String get sort_o_count => 'Счётчик O';

  @override
  String get sort_height => 'Рост';

  @override
  String get sort_birthdate => 'Дата рождения';

  @override
  String get sort_tag_count => 'Количество тегов';

  @override
  String get sort_play_count => 'Количество воспроизведений';

  @override
  String get sort_o_counter => 'Счётчик O';

  @override
  String get sort_zip_file_count => 'Количество ZIP-файлов';

  @override
  String get sort_last_o_at => 'Последний O';

  @override
  String get sort_latest_scene => 'Последняя сцена';

  @override
  String get sort_career_start => 'Начало карьеры';

  @override
  String get sort_career_end => 'Окончание карьеры';

  @override
  String get sort_weight => 'Вес';

  @override
  String get sort_measurements => 'Размеры';

  @override
  String get sort_scenes_duration => 'Длительность сцен';

  @override
  String get sort_scenes_size => 'Размер сцен';

  @override
  String get sort_images_count => 'Количество изображений';

  @override
  String get sort_galleries_count => 'Количество галерей';

  @override
  String get sort_child_count => 'Количество суб-студий';

  @override
  String get sort_performers_count => 'Количество исполнителей';

  @override
  String get sort_groups_count => 'Количество групп';

  @override
  String get sort_marker_count => 'Количество меток';

  @override
  String get sort_studios_count => 'Количество студий';

  @override
  String get sort_penis_length => 'Длина пениса';

  @override
  String get sort_last_played_at => 'Последнее воспроизведение';

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
  String get tags_sort_title => 'Сортировать теги';

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

  @override
  String get common_no_media_available => 'нет доступных медиа';

  @override
  String common_id(Object id) {
    return 'ID: $id';
  }

  @override
  String get common_search_placeholder => 'Поиск...';

  @override
  String get common_pause => 'пауза';

  @override
  String get common_play => 'играть';

  @override
  String get common_close => 'закрыть';

  @override
  String get common_save => 'сохранить';

  @override
  String get common_unmute => 'включить звук';

  @override
  String get common_mute => 'без звука';

  @override
  String get common_back => 'назад';

  @override
  String get common_rate => 'оценить';

  @override
  String get common_previous => 'предыд.';

  @override
  String get common_next => 'след.';

  @override
  String get common_favorite => 'избранное';

  @override
  String get common_unfavorite => 'убрать из избр.';

  @override
  String get common_version => 'версия';

  @override
  String get common_loading => 'загрузка';

  @override
  String get common_unavailable => 'недоступно';

  @override
  String get common_details => 'детали';

  @override
  String get common_title => 'название';

  @override
  String get common_release_date => 'дата выхода';

  @override
  String get common_url => 'Ссылка';

  @override
  String get common_no_url => 'нет URL';

  @override
  String get common_sort => 'сорт.';

  @override
  String get common_filter => 'фильтр';

  @override
  String get common_search => 'поиск';

  @override
  String get common_settings => 'настройки';

  @override
  String get common_reset_to_1x => 'сброс до 1x';

  @override
  String get common_skip_next => 'пропустить';

  @override
  String get common_select_subtitle => 'выбрать субтитры';

  @override
  String get common_playback_speed => 'скор. воспр.';

  @override
  String get common_pip => 'картинка в карт.';

  @override
  String get common_toggle_fullscreen => 'весь экран';

  @override
  String get common_exit_fullscreen => 'выйти из полноэкр.';

  @override
  String get common_copy_logs => 'коп. логи';

  @override
  String get common_clear_logs => 'очистить логи';

  @override
  String get common_enable_autoscroll => 'автопрокрутка вкл';

  @override
  String get common_disable_autoscroll => 'автопрокрутка выкл';

  @override
  String get common_retry => 'Повторить';

  @override
  String get common_no_items => 'Элементы не найдены';

  @override
  String get common_none => 'Нет';

  @override
  String get common_any => 'Любой';

  @override
  String get common_name => 'Имя';

  @override
  String get common_date => 'Дата';

  @override
  String get common_rating => 'Рейтинг';

  @override
  String get common_image_count => 'Количество изображений';

  @override
  String get common_filepath => 'Путь к файлу';

  @override
  String get common_random => 'Случайно';

  @override
  String get common_no_media_found => 'Медиа не найдены';

  @override
  String common_not_found(String item) {
    return '$item не найден';
  }

  @override
  String get common_add_favorite => 'Добавить в избранное';

  @override
  String get common_remove_favorite => 'Удалить из избранного';

  @override
  String get details_group => 'детали группы';

  @override
  String get details_synopsis => 'Синопсис';

  @override
  String get details_media => 'Медиа';

  @override
  String get details_galleries => 'Галереи';

  @override
  String get details_tags => 'Теги';

  @override
  String get details_links => 'Ссылки';

  @override
  String get details_scene_scrape => 'собрать метаданные';

  @override
  String get details_show_more => 'Показать больше';

  @override
  String get details_show_less => 'Показать меньше';

  @override
  String get details_more_from_studio => 'Еще от студии';

  @override
  String get details_o_count_incremented => 'Счет O увеличен';

  @override
  String details_failed_update_rating(String error) {
    return 'Не удалось обновить рейтинг: $error';
  }

  @override
  String details_failed_update_performer(Object error) {
    return 'Не удалось обновить исполнителя: $error';
  }

  @override
  String details_failed_increment_o_count(String error) {
    return 'Не удалось увеличить счет O: $error';
  }

  @override
  String get details_scene_add_performer => 'добавить исполнителя';

  @override
  String get details_scene_add_tag => 'добавить тег';

  @override
  String get details_scene_add_url => 'добавить URL';

  @override
  String get details_scene_remove_url => 'удалить URL';

  @override
  String get groups_title => 'Группы';

  @override
  String get groups_unnamed => 'Группа без имени';

  @override
  String get groups_untitled => 'Группа без названия';

  @override
  String get studios_title => 'Студии';

  @override
  String get studios_galleries_title => 'Галереи студии';

  @override
  String get studios_media_title => 'Медиа студии';

  @override
  String get studios_sort_title => 'Сортировать студии';

  @override
  String get galleries_title => 'Галереи';

  @override
  String get galleries_sort_title => 'Сортировать галереи';

  @override
  String get galleries_all_images => 'Все изображения';

  @override
  String get galleries_filter_title => 'Фильтр галерей';

  @override
  String get galleries_min_rating => 'Минимальный рейтинг';

  @override
  String get galleries_image_count => 'Количество изображений';

  @override
  String get galleries_organization => 'Организация';

  @override
  String get galleries_organized_only => 'Только организованные';

  @override
  String get scenes_filter_title => 'Фильтровать сцены';

  @override
  String get scenes_filter_saved => 'Настройки фильтра сохранены по умолчанию';

  @override
  String get scenes_watched => 'Просмотрено';

  @override
  String get scenes_unwatched => 'Не просмотрено';

  @override
  String get scenes_search_hint => 'Поиск сцен...';

  @override
  String get scenes_sort_header => 'Сортировать сцены';

  @override
  String get scenes_sort_duration => 'Длительность';

  @override
  String get scenes_sort_bitrate => 'Битрейт';

  @override
  String get scenes_sort_framerate => 'Частота кадров';

  @override
  String get scenes_sort_saved_default =>
      'Настройки сортировки сохранены по умолчанию';

  @override
  String get scenes_sort_tooltip => 'Параметры сортировки';

  @override
  String get tags_search_hint => 'Поиск тегов...';

  @override
  String get tags_sort_tooltip => 'Параметры сортировки';

  @override
  String get tags_filter_tooltip => 'Параметры фильтрации';

  @override
  String get performers_title => 'Исполнители';

  @override
  String get performers_sort_title => 'Сортировать исполнителей';

  @override
  String get performers_filter_title => 'Фильтр исполнителей';

  @override
  String get performers_galleries_title => 'Все галереи исполнителя';

  @override
  String get performers_media_title => 'Все медиа исполнителя';

  @override
  String get performers_gender => 'Пол';

  @override
  String get performers_gender_any => 'Любой';

  @override
  String get performers_gender_female => 'Женский';

  @override
  String get performers_gender_male => 'Мужской';

  @override
  String get performers_gender_trans_female => 'Транс-женщина';

  @override
  String get performers_gender_trans_male => 'Транс-мужчина';

  @override
  String get performers_gender_intersex => 'Интерсекс';

  @override
  String get performers_gender_non_binary => 'Небинарный';

  @override
  String get performers_circumcised => 'Обрезан';

  @override
  String get performers_circumcised_cut => 'Обрезан';

  @override
  String get performers_circumcised_uncut => 'Необрезан';

  @override
  String get performers_play_count => 'Количество воспроизведений';

  @override
  String get performers_field_disambiguation => 'Разрешение неоднозначности';

  @override
  String get performers_field_birthdate => 'Дата рождения';

  @override
  String get performers_field_deathdate => 'Дата смерти';

  @override
  String get performers_field_height_cm => 'Рост (см)';

  @override
  String get performers_field_weight_kg => 'Вес (кг)';

  @override
  String get performers_field_measurements => 'Замеры';

  @override
  String get performers_field_fake_tits => 'Искусственная грудь';

  @override
  String get performers_field_penis_length => 'Длина пениса';

  @override
  String get performers_field_ethnicity => 'Этничность';

  @override
  String get performers_field_country => 'Страна';

  @override
  String get performers_field_eye_color => 'Цвет глаз';

  @override
  String get performers_field_hair_color => 'Цвет волос';

  @override
  String get performers_field_career_start => 'Начало карьеры';

  @override
  String get performers_field_career_end => 'Конец карьеры';

  @override
  String get performers_field_tattoos => 'Татуировки';

  @override
  String get performers_field_piercings => 'Пирсинг';

  @override
  String get performers_field_aliases => 'Псевдонимы';

  @override
  String get common_organized => 'Организовано';

  @override
  String get scenes_duplicated => 'Дублировано';

  @override
  String get random_studio => 'случайная студия';

  @override
  String get random_gallery => 'случайная галерея';

  @override
  String get random_tag => 'случайный тег';

  @override
  String get random_scene => 'случайная сцена';

  @override
  String get random_performer => 'случайный исполнитель';

  @override
  String get filter_modifier => 'Модификатор';

  @override
  String get filter_value => 'Значение';

  @override
  String get filter_equals => 'Равно';

  @override
  String get filter_not_equals => 'Не равно';

  @override
  String get filter_greater_than => 'Больше чем';

  @override
  String get filter_less_than => 'Меньше чем';

  @override
  String get filter_is_null => 'Null';

  @override
  String get filter_not_null => 'Не null';

  @override
  String get images_resolution_title => 'Разрешение';

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
  String get images_orientation_title => 'Ориентация';

  @override
  String get common_or => 'ИЛИ';

  @override
  String get scrape_from_url => 'Собрать с URL';

  @override
  String get scenes_phash_started => 'Генерация phash начата';

  @override
  String scenes_phash_failed(Object error) {
    return 'Не удалось сгенерировать phash: $error';
  }

  @override
  String details_failed_update_studio(Object error) {
    return 'Не удалось обновить студию: $error';
  }

  @override
  String get settings_title => 'Настройки';

  @override
  String get settings_customize => 'Настройка StashFlow';

  @override
  String get settings_customize_subtitle =>
      'Настройте воспроизведение, внешний вид, макет и инструменты поддержки в одном месте.';

  @override
  String get settings_core_section => 'Основные настройки';

  @override
  String get settings_core_subtitle =>
      'Самые используемые страницы конфигурации';

  @override
  String get settings_server => 'Сервер';

  @override
  String get settings_server_subtitle => 'Конфигурация подключения и API';

  @override
  String get settings_playback => 'Воспроизведение';

  @override
  String get settings_playback_subtitle => 'Поведение плеера и взаимодействия';

  @override
  String get settings_keyboard => 'Клавиатура';

  @override
  String get settings_keyboard_subtitle => 'Настраиваемые сочетания клавиш';

  @override
  String get settings_keyboard_title => 'Горячие клавиши';

  @override
  String get settings_keyboard_reset_defaults => 'Сбросить настройки';

  @override
  String get settings_keyboard_not_bound => 'Не назначено';

  @override
  String get settings_keyboard_volume_up => 'Увеличить громкость';

  @override
  String get settings_keyboard_volume_down => 'Уменьшить громкость';

  @override
  String get settings_keyboard_toggle_mute => 'Вкл/выкл звук';

  @override
  String get settings_keyboard_toggle_fullscreen => 'Полноэкранный режим';

  @override
  String get settings_keyboard_next_scene => 'Следующая сцена';

  @override
  String get settings_keyboard_prev_scene => 'Предыдущая сцена';

  @override
  String get settings_keyboard_increase_speed => 'Увеличить скорость';

  @override
  String get settings_keyboard_decrease_speed => 'Уменьшить скорость';

  @override
  String get settings_keyboard_reset_speed => 'Сбросить скорость';

  @override
  String get settings_keyboard_close_player => 'Закрыть плеер';

  @override
  String get settings_keyboard_next_image => 'Следующее изображение';

  @override
  String get settings_keyboard_prev_image => 'Предыдущее изображение';

  @override
  String get settings_keyboard_go_back => 'Назад';

  @override
  String get settings_keyboard_play_pause_desc =>
      'Переключение между воспроизведением и паузой';

  @override
  String get settings_keyboard_seek_forward_5_desc => 'Вперед на 5 секунд';

  @override
  String get settings_keyboard_seek_backward_5_desc => 'Назад на 5 секунд';

  @override
  String get settings_keyboard_seek_forward_10_desc => 'Вперед на 10 секунд';

  @override
  String get settings_keyboard_seek_backward_10_desc => 'Назад на 10 секунд';

  @override
  String get settings_appearance => 'Внешний вид';

  @override
  String get settings_appearance_subtitle => 'Тема и цвета';

  @override
  String get settings_interface => 'Интерфейс';

  @override
  String get settings_interface_subtitle =>
      'Навигация и настройки макета по умолчанию';

  @override
  String get settings_support => 'Поддержка';

  @override
  String get settings_support_subtitle => 'Диагностика и информация';

  @override
  String get settings_develop => 'Разработка';

  @override
  String get settings_develop_subtitle =>
      'Расширенные инструменты и переопределения';

  @override
  String get settings_appearance_title => 'Настройки внешнего вида';

  @override
  String get settings_appearance_theme_mode => 'Режим темы';

  @override
  String get settings_appearance_theme_mode_subtitle =>
      'Выберите, как приложение следует за изменениями яркости';

  @override
  String get settings_appearance_theme_system => 'Системная';

  @override
  String get settings_appearance_theme_light => 'Светлая';

  @override
  String get settings_appearance_theme_dark => 'Темная';

  @override
  String get settings_appearance_primary_color => 'Основной цвет';

  @override
  String get settings_appearance_primary_color_subtitle =>
      'Выберите базовый цвет для палитры Material 3';

  @override
  String get settings_appearance_advanced_theming => 'Расширенная темизация';

  @override
  String get settings_appearance_advanced_theming_subtitle =>
      'Оптимизация для конкретных типов экранов';

  @override
  String get settings_appearance_true_black => 'Истинный черный (AMOLED)';

  @override
  String get settings_appearance_true_black_subtitle =>
      'Использовать чисто черный фон в темном режиме для экономии заряда батареи на OLED-экранах';

  @override
  String get settings_appearance_custom_hex => 'Пользовательский Hex-цвет';

  @override
  String get settings_appearance_custom_hex_helper =>
      'Введите 8-значный ARGB hex-код';

  @override
  String get settings_appearance_font_size => 'Global Font Size';

  @override
  String get settings_appearance_font_size_subtitle =>
      'Scale the text across the entire application interface';

  @override
  String get settings_interface_title => 'Настройки интерфейса';

  @override
  String get settings_interface_language => 'Язык';

  @override
  String get settings_interface_language_subtitle =>
      'Переопределить язык системы по умолчанию';

  @override
  String get settings_interface_app_language => 'Язык приложения';

  @override
  String get settings_interface_navigation => 'Навигация';

  @override
  String get settings_interface_navigation_subtitle =>
      'Видимость глобальных ярлыков навигации';

  @override
  String get settings_interface_show_random =>
      'Показывать кнопки случайной навигации';

  @override
  String get settings_interface_show_random_subtitle =>
      'Включить или отключить плавающие кнопки казино на страницах списков и деталей';

  @override
  String get settings_interface_main_pages_gravity_orientation =>
      'Ориентация, управляемая гравитацией (основные страницы)';

  @override
  String get settings_interface_main_pages_gravity_orientation_subtitle =>
      'Разрешить основным страницам поворачиваться с помощью датчика устройства. Полноэкранное воспроизведение видео использует собственные настройки ориентации.';

  @override
  String get settings_interface_show_edit => 'Показывать кнопку редактирования';

  @override
  String get settings_interface_show_edit_subtitle =>
      'Включить или отключить кнопку редактирования на странице деталей сцены';

  @override
  String get settings_interface_customize_tabs => 'Настройка вкладок';

  @override
  String get settings_interface_customize_tabs_subtitle =>
      'Изменить порядок или скрыть элементы меню навигации';

  @override
  String get settings_interface_scenes_layout => 'Макет сцен';

  @override
  String get settings_interface_scenes_layout_subtitle =>
      'Режим просмотра по умолчанию для сцен';

  @override
  String get settings_interface_galleries_layout => 'Макет галерей';

  @override
  String get settings_interface_galleries_layout_subtitle =>
      'Режим просмотра по умолчанию для галерей';

  @override
  String get settings_interface_max_performer_avatars =>
      'Максимальное количество аватаров исполнителей';

  @override
  String get settings_interface_max_performer_avatars_subtitle =>
      'Максимальное количество аватаров исполнителей, отображаемых в карточке сцены.';

  @override
  String get settings_interface_show_performer_avatars =>
      'Показывать аватары исполнителей';

  @override
  String get settings_interface_show_performer_avatars_subtitle =>
      'Отображать иконки исполнителей на карточках сцен на всех платформах.';

  @override
  String get settings_interface_performer_avatar_size =>
      'Размер аватара исполнителя';

  @override
  String get settings_interface_layout_default => 'Макет по умолчанию';

  @override
  String get settings_interface_layout_default_desc =>
      'Выберите макет по умолчанию для страницы';

  @override
  String get settings_interface_layout_list => 'Список';

  @override
  String get settings_interface_layout_grid => 'Сетка';

  @override
  String get settings_interface_layout_tiktok => 'Бесконечная прокрутка';

  @override
  String get settings_interface_grid_columns => 'Колонки сетки';

  @override
  String get settings_interface_image_viewer => 'Просмотр изображений';

  @override
  String get settings_interface_image_viewer_subtitle =>
      'Настроить поведение полноэкранного просмотра изображений';

  @override
  String get settings_interface_swipe_direction =>
      'Направление свайпа в полноэкранном режиме';

  @override
  String get settings_interface_swipe_direction_desc =>
      'Выберите способ перелистывания изображений в полноэкранном режиме';

  @override
  String get settings_interface_swipe_vertical => 'Вертикально';

  @override
  String get settings_interface_swipe_horizontal => 'Горизонтально';

  @override
  String get settings_interface_waterfall_columns => 'Колонки сетки «Водопад»';

  @override
  String get settings_interface_performer_layouts => 'Макеты исполнителей';

  @override
  String get settings_interface_performer_layouts_subtitle =>
      'Настройки медиа и галерей для исполнителей по умолчанию';

  @override
  String get settings_interface_studio_layouts => 'Макеты студий';

  @override
  String get settings_interface_studio_layouts_subtitle =>
      'Настройки медиа и галерей для студий по умолчанию';

  @override
  String get settings_interface_tag_layouts => 'Макеты тегов';

  @override
  String get settings_interface_tag_layouts_subtitle =>
      'Настройки медиа и галерей для тегов по умолчанию';

  @override
  String get settings_interface_media_layout => 'Макет медиа';

  @override
  String get settings_interface_media_layout_subtitle =>
      'Макет для страницы Медиа';

  @override
  String get settings_interface_galleries_layout_item => 'Макет галерей';

  @override
  String get settings_interface_galleries_layout_subtitle_item =>
      'Макет для страницы Галереи';

  @override
  String get settings_server_title => 'Настройки сервера';

  @override
  String get settings_server_status => 'Статус подключения';

  @override
  String get settings_server_status_subtitle =>
      'Текущее состояние подключения к настроенному серверу';

  @override
  String get settings_server_details => 'Детали сервера';

  @override
  String get settings_server_details_subtitle =>
      'Настройте адрес и метод аутентификации';

  @override
  String get settings_server_url => 'URL-адрес Stash';

  @override
  String get settings_server_url_helper =>
      'Введите URL-адрес вашего сервера Stash. Если настроен пользовательский путь, укажите его здесь.';

  @override
  String get settings_server_url_example => 'http://192.168.1.100:9999';

  @override
  String get settings_server_login_failed => 'Ошибка входа';

  @override
  String get settings_server_auth_method => 'Метод аутентификации';

  @override
  String get settings_server_auth_apikey => 'API-ключ';

  @override
  String get settings_server_auth_password => 'Имя пользователя + Пароль';

  @override
  String get settings_server_auth_password_desc =>
      'Рекомендуется: используйте имя пользователя и пароль Stash.';

  @override
  String get settings_server_auth_apikey_desc =>
      'Используйте API-ключ для аутентификации по статическому токену.';

  @override
  String get settings_server_username => 'Имя пользователя';

  @override
  String get settings_server_password => 'Пароль';

  @override
  String get settings_server_login_test => 'Войти и проверить';

  @override
  String get settings_server_test => 'Проверить подключение';

  @override
  String get settings_server_logout => 'Выйти';

  @override
  String get settings_server_clear => 'Очистить настройки';

  @override
  String settings_server_connected(String version) {
    return 'Подключено (Stash $version)';
  }

  @override
  String get settings_server_checking => 'Проверка подключения...';

  @override
  String settings_server_failed(String error) {
    return 'Ошибка: $error';
  }

  @override
  String get settings_server_invalid_url => 'Недопустимый URL сервера';

  @override
  String get settings_server_resolve_error =>
      'Не удалось разрешить URL сервера. Проверьте хост, порт и учетные данные.';

  @override
  String get settings_server_logout_confirm =>
      'Выход выполнен, файлы cookie очищены.';

  @override
  String get settings_server_profile_add => 'Добавить профиль';

  @override
  String get settings_server_profile_edit => 'Изменить профиль';

  @override
  String get settings_server_profile_name => 'Имя профиля';

  @override
  String get settings_server_profile_delete => 'Удалить профиль';

  @override
  String get settings_server_profile_delete_confirm =>
      'Вы уверены, что хотите удалить этот профиль? Это действие нельзя отменить.';

  @override
  String get settings_server_profile_active => 'Активен';

  @override
  String get settings_server_profile_empty => 'Серверные профили не настроены';

  @override
  String get settings_server_profiles => 'Профили сервера';

  @override
  String get settings_server_profiles_subtitle =>
      'Управление несколькими подключениями к серверу Stash';

  @override
  String get settings_server_auth_status_logging_in =>
      'Статус аутентификации: выполняется вход...';

  @override
  String get settings_server_auth_status_logged_in =>
      'Статус аутентификации: вход выполнен';

  @override
  String get settings_server_auth_status_logged_out =>
      'Статус аутентификации: выход выполнен';

  @override
  String get settings_playback_title => 'Настройки воспроизведения';

  @override
  String get settings_playback_behavior => 'Поведение воспроизведения';

  @override
  String get settings_playback_behavior_subtitle =>
      'Настройки воспроизведения и фонового режима по умолчанию';

  @override
  String get settings_playback_prefer_streams => 'Предпочитать sceneStreams';

  @override
  String get settings_playback_prefer_streams_subtitle =>
      'Если отключено, воспроизведение использует paths.stream напрямую';

  @override
  String get settings_playback_autoplay =>
      'Автовоспроизведение следующей сцены';

  @override
  String get settings_playback_autoplay_subtitle =>
      'Автоматически воспроизводить следующую сцену по завершении текущей';

  @override
  String get settings_playback_background => 'Фоновое воспроизведение';

  @override
  String get settings_playback_background_subtitle =>
      'Продолжать воспроизведение звука видео при сворачивании приложения';

  @override
  String get settings_playback_pip => 'Нативная «Картинка в картинке»';

  @override
  String get settings_playback_pip_subtitle =>
      'Включить кнопку PiP на Android и автоматический переход при сворачивании';

  @override
  String get settings_playback_subtitles => 'Настройки субтитров';

  @override
  String get settings_playback_subtitles_subtitle =>
      'Автоматическая загрузка и внешний вид';

  @override
  String get settings_playback_subtitle_lang => 'Язык субтитров по умолчанию';

  @override
  String get settings_playback_subtitle_lang_subtitle =>
      'Автозагрузка при наличии';

  @override
  String get settings_playback_subtitle_size => 'Размер шрифта субтитров';

  @override
  String get settings_playback_subtitle_pos =>
      'Вертикальное положение субтитров';

  @override
  String settings_playback_subtitle_pos_desc(String percent) {
    return '$percent% снизу';
  }

  @override
  String get settings_playback_subtitle_align =>
      'Выравнивание текста субтитров';

  @override
  String get settings_playback_subtitle_align_subtitle =>
      'Выравнивание для многострочных субтитров';

  @override
  String get settings_playback_seek => 'Взаимодействие при перемотке';

  @override
  String get settings_playback_seek_subtitle =>
      'Выберите способ перемотки во время воспроизведения';

  @override
  String get settings_playback_seek_double_tap =>
      'Двойное нажатие влево/вправо для перемотки на 10с';

  @override
  String get settings_playback_seek_drag =>
      'Перетаскивание временной шкалы для перемотки';

  @override
  String get settings_playback_seek_drag_label => 'Перетаскивание';

  @override
  String get settings_playback_seek_double_tap_label => 'Двойное нажатие';

  @override
  String get settings_playback_gravity_orientation =>
      'Ориентация, управляемая гравитацией';

  @override
  String get settings_playback_gravity_orientation_subtitle =>
      'Разрешить поворот между совпадающими ориентациями с помощью датчика устройства (например, переворачивать альбомную ориентацию влево/вправо).';

  @override
  String get settings_playback_subtitle_lang_none_disabled => 'Нет (Отключено)';

  @override
  String get settings_playback_subtitle_lang_auto_if_only_one =>
      'Авто (если только один)';

  @override
  String get settings_playback_subtitle_lang_english => 'Английский';

  @override
  String get settings_playback_subtitle_lang_chinese => 'Китайский';

  @override
  String get settings_playback_subtitle_lang_german => 'Немецкий';

  @override
  String get settings_playback_subtitle_lang_french => 'Французский';

  @override
  String get settings_playback_subtitle_lang_spanish => 'Испанский';

  @override
  String get settings_playback_subtitle_lang_italian => 'Итальянский';

  @override
  String get settings_playback_subtitle_lang_japanese => 'Японский';

  @override
  String get settings_playback_subtitle_lang_korean => 'Корейский';

  @override
  String get settings_playback_subtitle_align_left => 'Слева';

  @override
  String get settings_playback_subtitle_align_center => 'По центру';

  @override
  String get settings_playback_subtitle_align_right => 'Справа';

  @override
  String get settings_support_title => 'Поддержка';

  @override
  String get settings_support_diagnostics =>
      'Диагностика и информация о проекте';

  @override
  String get settings_support_diagnostics_subtitle =>
      'Открыть журналы работы или перейти в репозиторий за помощью.';

  @override
  String get settings_support_update_available => 'Доступно обновление';

  @override
  String get settings_support_update_available_subtitle =>
      'На GitHub доступна более новая версия';

  @override
  String settings_support_update_to(String version) {
    return 'Обновить до $version';
  }

  @override
  String get settings_support_update_to_subtitle =>
      'Вас ждут новые функции и улучшения.';

  @override
  String get settings_support_about => 'О программе';

  @override
  String get settings_support_about_subtitle =>
      'Информация о проекте и исходном коде';

  @override
  String get settings_support_version => 'Версия';

  @override
  String get settings_support_version_loading =>
      'Загрузка информации о версии...';

  @override
  String get settings_support_version_unavailable =>
      'Информация о версии недоступна';

  @override
  String get settings_support_github => 'Репозиторий GitHub';

  @override
  String get settings_support_github_subtitle =>
      'Просмотр исходного кода и сообщение об ошибках';

  @override
  String get settings_support_github_error =>
      'Не удалось открыть ссылку на GitHub';

  @override
  String get settings_develop_title => 'Разработка';

  @override
  String get settings_develop_diagnostics => 'Инструменты диагностики';

  @override
  String get settings_develop_diagnostics_subtitle =>
      'Устранение неполадок и производительность';

  @override
  String get settings_develop_video_debug =>
      'Показывать отладочную информацию видео';

  @override
  String get settings_develop_video_debug_subtitle =>
      'Отображать технические детали воспроизведения поверх видеоплеера.';

  @override
  String get settings_develop_log_viewer => 'Просмотр журнала отладки';

  @override
  String get settings_develop_log_viewer_subtitle =>
      'Открыть просмотр журналов приложения в реальном времени.';

  @override
  String get settings_develop_logs_copied => 'Логи скопированы в буфер обмена';

  @override
  String get settings_develop_no_logs =>
      'Журналы отсутствуют. Взаимодействуйте с приложением, чтобы собрать логи.';

  @override
  String get settings_develop_web_overrides => 'Переопределения для Web';

  @override
  String get settings_develop_web_overrides_subtitle =>
      'Расширенные флаги для веб-платформы';

  @override
  String get settings_develop_web_auth => 'Разрешить вход по паролю в Web';

  @override
  String get settings_develop_web_auth_subtitle =>
      'Переопределяет ограничение «только для нативных приложений» и делает видимым метод аутентификации по имени пользователя и паролю во Flutter Web.';

  @override
  String get settings_develop_proxy_auth =>
      'Включить режимы аутентификации через прокси';

  @override
  String get settings_develop_proxy_auth_subtitle =>
      'Включите расширенные методы Basic Auth и Bearer Token для использования с бэкендами без аутентификации за прокси-серверами, такими как Authentik.';

  @override
  String get settings_server_auth_basic => 'Базовая аутентификация';

  @override
  String get settings_server_auth_bearer => 'Токен носителя';

  @override
  String get settings_server_auth_basic_desc =>
      'Отправляет заголовок \'Authorization: Basic <base64(user:pass)>\'.';

  @override
  String get settings_server_auth_bearer_desc =>
      'Отправляет заголовок \'Authorization: Bearer <token>\'.';

  @override
  String get common_edit => 'Редактировать';

  @override
  String get common_resolution => 'Разрешение';

  @override
  String get common_orientation => 'Ориентация';

  @override
  String get common_landscape => 'Альбомная';

  @override
  String get common_portrait => 'Портретная';

  @override
  String get common_square => 'Квадрат';

  @override
  String get performers_filter_saved =>
      'Параметры фильтра сохранены как по умолчанию';

  @override
  String get images_title => 'Изображения';

  @override
  String get images_filter_title => 'Фильтровать изображения';

  @override
  String get images_filter_saved => 'Настройки фильтра сохранены по умолчанию';

  @override
  String get images_sort_title => 'Сортировать изображения';

  @override
  String get images_sort_saved =>
      'Параметры сортировки сохранены как по умолчанию';

  @override
  String get image_rating_updated => 'Рейтинг изображения обновлен.';

  @override
  String get gallery_rating_updated => 'Рейтинг галереи обновлен.';

  @override
  String get common_image => 'Изображение';

  @override
  String get common_gallery => 'Галерея';

  @override
  String get images_gallery_rating_unavailable =>
      'Рейтинг галереи доступен только при просмотре галереи.';

  @override
  String images_rating(String rating) {
    return 'Рейтинг: $rating / 5';
  }

  @override
  String get images_filtered_by_gallery => 'Отфильтровано по галерее';

  @override
  String get images_slideshow_need_two =>
      'Требуется как минимум 2 изображения для слайд-шоу.';

  @override
  String get images_slideshow_start_title => 'Запустить слайд-шоу';

  @override
  String images_slideshow_interval(num seconds) {
    return 'Интервал: $secondsс';
  }

  @override
  String images_slideshow_transition_ms(num ms) {
    return 'Переход: $msмс';
  }

  @override
  String get common_forward => 'Вперед';

  @override
  String get common_backward => 'Назад';

  @override
  String get images_slideshow_loop_title => 'Зациклить слайд-шоу';

  @override
  String get common_cancel => 'Отмена';

  @override
  String get common_start => 'Начать';

  @override
  String get common_done => 'Готово';

  @override
  String get settings_keybind_assign_shortcut => 'Назначить сочетание клавиш';

  @override
  String get settings_keybind_press_any => 'Нажмите любую комбинацию клавиш...';

  @override
  String get scenes_select_tags => 'Выбрать теги';

  @override
  String get scenes_no_scrapers => 'Нет доступных скрейперов';

  @override
  String get scenes_select_scraper => 'Выбрать скрейпер';

  @override
  String get scenes_no_results_found => 'Результаты не найдены';

  @override
  String get scenes_select_result => 'Выбрать результат';

  @override
  String scenes_scrape_failed(String error) {
    return 'Сбор данных не удался: $error';
  }

  @override
  String get scenes_updated_successfully => 'Сцена успешно обновлена';

  @override
  String scenes_update_failed(String error) {
    return 'Не удалось обновить сцену: $error';
  }

  @override
  String get scenes_edit_title => 'Редактировать сцену';

  @override
  String get scenes_field_studio => 'Студия';

  @override
  String get scenes_field_tags => 'Теги';

  @override
  String get scenes_field_urls => 'Ссылки';

  @override
  String get scenes_edit_performer => 'Редактировать исполнителя';

  @override
  String get scenes_edit_studio => 'Редактировать студию';

  @override
  String get common_no_title => 'Без названия';

  @override
  String get scenes_select_studio => 'Выбрать студию';

  @override
  String get scenes_select_performers => 'Выбрать исполнителей';

  @override
  String get scenes_unmatched_scraped_tags =>
      'Несопоставленные полученные теги';

  @override
  String get scenes_unmatched_scraped_performers =>
      'Несопоставленные полученные исполнители';

  @override
  String get scenes_no_matching_performer_found =>
      'Не найден подходящий исполнитель в библиотеке';

  @override
  String get common_unknown => 'Неизвестно';

  @override
  String scenes_studio_id_prefix(String id) {
    return 'ID студии: $id';
  }

  @override
  String get tags_search_placeholder => 'Поиск тегов...';

  @override
  String get scenes_duration_short => '< 5 мин.';

  @override
  String get scenes_duration_medium => '5-20 мин.';

  @override
  String get scenes_duration_long => '> 20 мин.';

  @override
  String get details_scene_fingerprint_query => 'Запрос отпечатка сцены';

  @override
  String get scenes_available_scrapers => 'Доступные скрейперы';

  @override
  String get scrape_results_existing => 'Существующие результаты';

  @override
  String get scrape_results_scraped => 'Полученные результаты';
}
