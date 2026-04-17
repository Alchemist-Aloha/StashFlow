// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'StashFlow';

  @override
  String get nav_scenes => '场景';

  @override
  String get nav_performers => '演职人员';

  @override
  String get nav_studios => '制片商';

  @override
  String get nav_tags => '标签';

  @override
  String get nav_galleries => '图库';

  @override
  String nScenes(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString 个场景',
      zero: '无场景',
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
      other: '$countString 位演职人员',
      zero: '无演职人员',
    );
    return '$_temp0';
  }

  @override
  String get common_reset => '重置';

  @override
  String get common_apply => '应用';

  @override
  String get common_save_default => '保存为默认';

  @override
  String get common_sort_method => '排序方式';

  @override
  String get common_direction => '方向';

  @override
  String get common_ascending => '升序';

  @override
  String get common_descending => '降序';

  @override
  String get common_favorites_only => '仅收藏';

  @override
  String get common_apply_sort => '应用排序';

  @override
  String get common_apply_filters => '应用筛选';

  @override
  String get common_view_all => '查看全部';

  @override
  String get common_later => '以后再说';

  @override
  String get common_update_now => '立即更新';

  @override
  String get common_configure_now => '立即配置';

  @override
  String get common_clear_rating => '清除评分';

  @override
  String get common_no_media => '暂无内容';

  @override
  String get common_setup_required => '需要配置';

  @override
  String get common_update_available => '有可用更新';

  @override
  String get details_studio => '制片商详情';

  @override
  String get details_performer => '演职人员详情';

  @override
  String get details_tag => '标签详情';

  @override
  String get details_scene => '场景详情';

  @override
  String get details_gallery => '图库详情';

  @override
  String get studios_filter_title => '筛选制片商';

  @override
  String get studios_filter_saved => '筛选偏好已保存为默认';

  @override
  String get sort_name => '名称';

  @override
  String get sort_scene_count => '场景数量';

  @override
  String get sort_rating => '评分';

  @override
  String get sort_updated_at => '更新时间';

  @override
  String get sort_created_at => '创建时间';

  @override
  String get sort_random => '随机';

  @override
  String get studios_sort_saved => '排序偏好已保存为默认';

  @override
  String get studios_no_random => '没有可用于随机导航的制片商';

  @override
  String get tags_filter_title => '筛选标签';

  @override
  String get tags_filter_saved => '筛选偏好已保存为默认';

  @override
  String get tags_sort_saved => '排序偏好已保存为默认';

  @override
  String get tags_no_random => '没有可用于随机导航的标签';

  @override
  String get scenes_no_random => '没有可用于随机导航的场景';

  @override
  String get performers_no_random => '没有可用于随机导航的演职人员';

  @override
  String get galleries_no_random => '没有可用于随机导航的图库';

  @override
  String common_error(String message) {
    return '错误: $message';
  }
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');

  @override
  String get appTitle => 'StashFlow';

  @override
  String get nav_scenes => '场景';

  @override
  String get nav_performers => '演职人员';

  @override
  String get nav_studios => '制片商';

  @override
  String get nav_tags => '标签';

  @override
  String get nav_galleries => '图库';

  @override
  String nScenes(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString 个场景',
      zero: '无场景',
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
      other: '$countString 位演职人员',
      zero: '无演职人员',
    );
    return '$_temp0';
  }

  @override
  String get common_reset => '重置';

  @override
  String get common_apply => '应用';

  @override
  String get common_save_default => '保存为默认';

  @override
  String get common_sort_method => '排序方式';

  @override
  String get common_direction => '方向';

  @override
  String get common_ascending => '升序';

  @override
  String get common_descending => '降序';

  @override
  String get common_favorites_only => '仅收藏';

  @override
  String get common_apply_sort => '应用排序';

  @override
  String get common_apply_filters => '应用筛选';

  @override
  String get common_view_all => '查看全部';

  @override
  String get common_later => '以后再说';

  @override
  String get common_update_now => '立即更新';

  @override
  String get common_configure_now => '立即配置';

  @override
  String get common_clear_rating => '清除评分';

  @override
  String get common_no_media => '暂无内容';

  @override
  String get common_setup_required => '需要配置';

  @override
  String get common_update_available => '有可用更新';

  @override
  String get details_studio => '制片商详情';

  @override
  String get details_performer => '演职人员详情';

  @override
  String get details_tag => '标签详情';

  @override
  String get details_scene => '场景详情';

  @override
  String get details_gallery => '图库详情';

  @override
  String get studios_filter_title => '筛选制片商';

  @override
  String get studios_filter_saved => '筛选偏好已保存为默认';

  @override
  String get sort_name => '名称';

  @override
  String get sort_scene_count => '场景数量';

  @override
  String get sort_rating => '评分';

  @override
  String get sort_updated_at => '更新时间';

  @override
  String get sort_created_at => '创建时间';

  @override
  String get sort_random => '随机';

  @override
  String get studios_sort_saved => '排序偏好已保存为默认';

  @override
  String get studios_no_random => '没有可用于随机导航的制片商';

  @override
  String get tags_filter_title => '筛选标签';

  @override
  String get tags_filter_saved => '筛选偏好已保存为默认';

  @override
  String get tags_sort_saved => '排序偏好已保存为默认';

  @override
  String get tags_no_random => '没有可用于随机导航的标签';

  @override
  String get scenes_no_random => '没有可用于随机导航的场景';

  @override
  String get performers_no_random => '没有可用于随机导航的演职人员';

  @override
  String get galleries_no_random => '没有可用于随机导航的图库';

  @override
  String common_error(String message) {
    return '错误: $message';
  }
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => 'StashFlow';

  @override
  String get nav_scenes => '場景';

  @override
  String get nav_performers => '演職人員';

  @override
  String get nav_studios => '製片商';

  @override
  String get nav_tags => '標籤';

  @override
  String get nav_galleries => '圖庫';

  @override
  String nScenes(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString 個場景',
      zero: '無場景',
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
      other: '$countString 位演職人員',
      zero: '無演職人員',
    );
    return '$_temp0';
  }

  @override
  String get common_reset => '重置';

  @override
  String get common_apply => '應用';

  @override
  String get common_save_default => '保存為默認';

  @override
  String get common_sort_method => '排序方式';

  @override
  String get common_direction => '方向';

  @override
  String get common_ascending => '升序';

  @override
  String get common_descending => '降序';

  @override
  String get common_favorites_only => '僅收藏';

  @override
  String get common_apply_sort => '應用排序';

  @override
  String get common_apply_filters => '應用篩選';

  @override
  String get common_view_all => '查看全部';

  @override
  String get common_later => '以後再說';

  @override
  String get common_update_now => '立即更新';

  @override
  String get common_configure_now => '立即配置';

  @override
  String get common_clear_rating => '清除評分';

  @override
  String get common_no_media => '暫無內容';

  @override
  String get common_setup_required => '需要配置';

  @override
  String get common_update_available => '有可用更新';

  @override
  String get details_studio => '製片商詳情';

  @override
  String get details_performer => '演職人員詳情';

  @override
  String get details_tag => '標籤詳情';

  @override
  String get details_scene => '場景詳情';

  @override
  String get details_gallery => '圖庫詳情';

  @override
  String get studios_filter_title => '篩選製片商';

  @override
  String get studios_filter_saved => '篩選偏好已保存為默認';

  @override
  String get sort_name => '名稱';

  @override
  String get sort_scene_count => '場景數量';

  @override
  String get sort_rating => '評分';

  @override
  String get sort_updated_at => '更新時間';

  @override
  String get sort_created_at => '創建時間';

  @override
  String get sort_random => '隨機';

  @override
  String get studios_sort_saved => '排序偏好已保存為默認';

  @override
  String get studios_no_random => '沒有可用於隨機導航的製片商';

  @override
  String get tags_filter_title => '篩選標籤';

  @override
  String get tags_filter_saved => '篩選偏好已保存為默認';

  @override
  String get tags_sort_saved => '排序偏好已保存為默認';

  @override
  String get tags_no_random => '沒有可用於隨機導航的標籤';

  @override
  String get scenes_no_random => '沒有可用於隨機導航的場景';

  @override
  String get performers_no_random => '沒有可用於隨機導航的演職人員';

  @override
  String get galleries_no_random => '沒有可用於隨機導航的圖庫';

  @override
  String common_error(String message) {
    return '錯誤: $message';
  }
}
