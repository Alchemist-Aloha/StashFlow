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
  String get common_token => '代币';

  @override
  String get filter_value => '值';

  @override
  String get common_yes => '是的';

  @override
  String get common_no => '否';

  @override
  String get common_clear_history => '清除历史记录';

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
  String get common_default => '默认';

  @override
  String get common_later => '以后';

  @override
  String get common_update_now => '发布详情';

  @override
  String get common_configure_now => '立即配置';

  @override
  String get common_clear_rating => '清除评分';

  @override
  String get common_no_media => '暂无媒体';

  @override
  String get common_show => '显示';

  @override
  String get common_hide => '隐藏';

  @override
  String get galleries_filter_saved => '筛选偏好已保存为默认';

  @override
  String get common_setup_required => '需要设置';

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
  String get sort_file_mod_time => '文件修改时间';

  @override
  String get sort_filesize => '文件大小';

  @override
  String get sort_o_count => 'O 计数器';

  @override
  String get sort_height => '身高';

  @override
  String get sort_birthdate => '出生日期';

  @override
  String get sort_tag_count => '标签数量';

  @override
  String get sort_play_count => '播放次数';

  @override
  String get sort_o_counter => 'O 计数';

  @override
  String get sort_zip_file_count => 'ZIP 文件数';

  @override
  String get sort_last_o_at => '上次 O 时间';

  @override
  String get sort_latest_scene => '最新场景';

  @override
  String get sort_career_start => '职业开始';

  @override
  String get sort_career_end => '职业结束';

  @override
  String get sort_weight => '体重';

  @override
  String get sort_measurements => '三围';

  @override
  String get sort_scenes_duration => '场景时长';

  @override
  String get sort_scenes_size => '场景大小';

  @override
  String get sort_images_count => '图片数量';

  @override
  String get sort_galleries_count => '画廊数量';

  @override
  String get sort_child_count => '子工作室数量';

  @override
  String get sort_performers_count => '演员数量';

  @override
  String get sort_groups_count => '分组数量';

  @override
  String get sort_marker_count => '标记数量';

  @override
  String get sort_studios_count => '工作室数量';

  @override
  String get sort_penis_length => '阴茎长度';

  @override
  String get sort_last_played_at => '上次播放时间';

  @override
  String get studios_sort_saved => '排序偏好已保存为默认';

  @override
  String get studios_no_random => '没有可用于随机导航的制片商';

  @override
  String get tags_filter_title => '筛选标签';

  @override
  String get tags_filter_saved => '筛选偏好已保存为默认';

  @override
  String get tags_sort_title => '排序标签';

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

  @override
  String get common_no_media_available => '无可用媒体';

  @override
  String common_id(Object id) {
    return 'ID：$id';
  }

  @override
  String get common_search_placeholder => '搜索...';

  @override
  String get common_pause => '暂停';

  @override
  String get common_play => '播放';

  @override
  String get common_refresh => '刷新';

  @override
  String get common_close => '关闭';

  @override
  String get common_save => '保存';

  @override
  String get common_unmute => '取消静音';

  @override
  String get common_mute => '静音';

  @override
  String get common_back => '返回';

  @override
  String get common_rate => '评分';

  @override
  String get common_previous => '上一个';

  @override
  String get common_next => '下一个';

  @override
  String get common_favorite => '收藏';

  @override
  String get common_unfavorite => '取消收藏';

  @override
  String get common_version => '版本';

  @override
  String get common_loading => '加载中';

  @override
  String get common_unavailable => '不可用';

  @override
  String get common_details => '详情';

  @override
  String get common_title => '标题';

  @override
  String get common_release_date => '发布日期';

  @override
  String get common_url => '链接';

  @override
  String get common_no_url => '无 URL';

  @override
  String get common_sort => '排序';

  @override
  String get common_filter => '筛选';

  @override
  String get common_search => '搜索';

  @override
  String get common_settings => '设置';

  @override
  String get common_reset_to_1x => '重置为 1x';

  @override
  String get common_skip_next => '跳过下一个';

  @override
  String get common_skip_previous => '跳过上一个';

  @override
  String get common_select_subtitle => '选择字幕';

  @override
  String get common_playback_speed => '播放速度';

  @override
  String get common_pip => '画中画';

  @override
  String get common_toggle_fullscreen => '切换全屏';

  @override
  String get common_exit_fullscreen => '退出全屏';

  @override
  String get common_copy_logs => '复制日志';

  @override
  String get common_clear_logs => '清除日志';

  @override
  String get common_enable_autoscroll => '启用自动滚动';

  @override
  String get common_disable_autoscroll => '禁用自动滚动';

  @override
  String get common_retry => '重试';

  @override
  String get common_no_items => '未找到项目';

  @override
  String get common_none => '无';

  @override
  String get common_any => '任意';

  @override
  String get common_name => '名称';

  @override
  String get common_date => '日期';

  @override
  String get common_rating => '评分';

  @override
  String get common_image_count => '图片数量';

  @override
  String get common_filepath => '文件路径';

  @override
  String get common_random => '随机';

  @override
  String get common_no_media_found => '未找到媒体';

  @override
  String common_not_found(String item) {
    return '未找到 $item';
  }

  @override
  String get common_add_favorite => '添加收藏';

  @override
  String get common_remove_favorite => '取消收藏';

  @override
  String get details_group => '小组详情';

  @override
  String get details_synopsis => '剧情简介';

  @override
  String get details_media => '媒体';

  @override
  String get details_galleries => '图库';

  @override
  String get details_tags => '标签';

  @override
  String get details_links => '链接';

  @override
  String get details_scene_scrape => '抓取元数据';

  @override
  String get details_show_more => '显示更多';

  @override
  String get common_more => '更多';

  @override
  String get details_show_less => '显示较少';

  @override
  String get details_more_from_studio => '更多来自该制片商';

  @override
  String get details_o_count_incremented => 'O 计数已增加';

  @override
  String details_failed_update_rating(String error) {
    return '更新评分失败：$error';
  }

  @override
  String details_failed_update_performer(Object error) {
    return '更新演员失败：$error';
  }

  @override
  String details_failed_increment_o_count(String error) {
    return '增加 O 计数失败：$error';
  }

  @override
  String get details_scene_add_performer => '添加出演者';

  @override
  String get details_scene_add_tag => '添加标签';

  @override
  String get details_scene_add_url => '添加 URL';

  @override
  String get details_scene_remove_url => '移除 URL';

  @override
  String get groups_title => '小组';

  @override
  String get groups_unnamed => '未命名小组';

  @override
  String get groups_untitled => '无标题小组';

  @override
  String get studios_title => '制片商';

  @override
  String get studios_galleries_title => '制片商图库';

  @override
  String get studios_media_title => '制片商媒体';

  @override
  String get studios_sort_title => '制片商排序';

  @override
  String get galleries_title => '图库';

  @override
  String get galleries_sort_title => '图库排序';

  @override
  String get galleries_all_images => '所有图片';

  @override
  String get galleries_filter_title => '图库筛选';

  @override
  String get galleries_min_rating => '最低评分';

  @override
  String get galleries_image_count => '图片数量';

  @override
  String get galleries_organization => '整理';

  @override
  String get galleries_organized_only => '仅已整理';

  @override
  String get scenes_filter_title => '筛选场景';

  @override
  String get scenes_filter_saved => '筛选偏好已保存为默认设置';

  @override
  String get scenes_watched => '已看';

  @override
  String get scenes_unwatched => '未看';

  @override
  String get scenes_search_hint => '搜索场景...';

  @override
  String get scenes_sort_header => '排序场景';

  @override
  String get scenes_sort_duration => '时长';

  @override
  String get scenes_sort_bitrate => '比特率';

  @override
  String get scenes_sort_framerate => '帧率';

  @override
  String get scenes_sort_file_count => '文件数量';

  @override
  String get scenes_sort_filesize => '文件大小';

  @override
  String get scenes_sort_resolution => '分辨率';

  @override
  String get scenes_sort_last_played_at => '最后播放时间';

  @override
  String get scenes_sort_resume_time => '恢复时间';

  @override
  String get scenes_sort_play_duration => '播放时长';

  @override
  String get scenes_sort_interactive => '交互式';

  @override
  String get scenes_sort_interactive_speed => '交互速度';

  @override
  String get scenes_sort_perceptual_similarity => '感知相似度';

  @override
  String get scenes_sort_performer_age => '演员年龄';

  @override
  String get scenes_sort_studio => '制片商';

  @override
  String get scenes_sort_path => '路径';

  @override
  String get scenes_sort_file_mod_time => '文件修改时间';

  @override
  String get scenes_sort_tag_count => '标签数量';

  @override
  String get scenes_sort_performer_count => '演员数量';

  @override
  String get scenes_sort_o_counter => 'O计数器';

  @override
  String get scenes_sort_last_o_at => '上次O时间';

  @override
  String get scenes_sort_group_scene_number => '合集/电影场景编号';

  @override
  String get scenes_sort_code => '代码';

  @override
  String get scenes_sort_saved_default => '排序偏好已保存为默认';

  @override
  String get scenes_sort_tooltip => '排序选项';

  @override
  String get tags_search_hint => '搜索标签...';

  @override
  String get tags_sort_tooltip => '排序选项';

  @override
  String get tags_filter_tooltip => '筛选选项';

  @override
  String get performers_title => '演职人员';

  @override
  String get performers_sort_title => '演职人员排序';

  @override
  String get performers_filter_title => '演职人员筛选';

  @override
  String get performers_galleries_title => '所有演职人员图库';

  @override
  String get performers_media_title => '所有演职人员媒体';

  @override
  String get performers_gender => '性别';

  @override
  String get performers_gender_any => '任意';

  @override
  String get performers_gender_female => '女性';

  @override
  String get performers_gender_male => '男性';

  @override
  String get performers_gender_trans_female => '跨性别女性';

  @override
  String get performers_gender_trans_male => '跨性别男性';

  @override
  String get performers_gender_intersex => '双性人';

  @override
  String get performers_gender_non_binary => '非二元';

  @override
  String get performers_circumcised => '割礼';

  @override
  String get performers_circumcised_cut => '已割礼';

  @override
  String get performers_circumcised_uncut => '未割礼';

  @override
  String get performers_play_count => '播放次数';

  @override
  String get performers_field_disambiguation => '消歧义';

  @override
  String get performers_field_birthdate => '出生日期';

  @override
  String get performers_field_deathdate => '死亡日期';

  @override
  String get performers_field_height_cm => '身高（cm）';

  @override
  String get performers_field_weight_kg => '体重（kg）';

  @override
  String get performers_field_measurements => '三围';

  @override
  String get performers_field_fake_tits => '假胸';

  @override
  String get performers_field_penis_length => '阴茎长度';

  @override
  String get performers_field_ethnicity => '族裔';

  @override
  String get performers_field_country => '国家';

  @override
  String get performers_field_eye_color => '眼睛颜色';

  @override
  String get performers_field_hair_color => '头发颜色';

  @override
  String get performers_field_career_start => '职业开始';

  @override
  String get performers_field_career_end => '职业结束';

  @override
  String get performers_field_tattoos => '纹身';

  @override
  String get performers_field_piercings => '穿孔';

  @override
  String get performers_field_aliases => '别名';

  @override
  String get common_organized => '已整理';

  @override
  String get scenes_duplicated => '重复';

  @override
  String get random_studio => '随机制片商';

  @override
  String get random_gallery => '随机图库';

  @override
  String get random_tag => '随机标签';

  @override
  String get random_scene => '随机场景';

  @override
  String get random_performer => '随机出演者';

  @override
  String get filter_modifier => '修饰符';

  @override
  String get filter_group_general => '常规';

  @override
  String get filter_group_performer => '演员';

  @override
  String get filter_group_library => '媒体库';

  @override
  String get filter_group_metadata => '元数据';

  @override
  String get filter_group_media_info => '媒体信息';

  @override
  String get filter_group_usage => '使用情况';

  @override
  String get filter_group_system => '系统';

  @override
  String get filter_group_physical => '物理';

  @override
  String get filter_equals => '等于';

  @override
  String get filter_not_equals => '不等于';

  @override
  String get filter_greater_than => '大于';

  @override
  String get filter_less_than => '小于';

  @override
  String get filter_includes => 'Includes';

  @override
  String get filter_excludes => 'Excludes';

  @override
  String get filter_includes_all => 'Includes All';

  @override
  String get filter_is_null => '为空';

  @override
  String get filter_not_null => '不为空';

  @override
  String get filter_matches_regex => 'Matches Regex';

  @override
  String get filter_not_matches_regex => 'Does Not Match Regex';

  @override
  String get filter_between => 'Between';

  @override
  String get filter_not_between => 'Not Between';

  @override
  String get filter_value_secondary => 'Second Value';

  @override
  String get images_resolution_title => '分辨率';

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
  String get images_orientation_title => '方向';

  @override
  String get common_or => '或';

  @override
  String get scrape_from_url => '从 URL 抓取';

  @override
  String get scenes_phash_started => '开始生成 phash';

  @override
  String scenes_phash_failed(Object error) {
    return '生成 phash 失败：$error';
  }

  @override
  String details_failed_update_studio(Object error) {
    return '更新工作室失败：$error';
  }

  @override
  String get settings_title => '设置';

  @override
  String get settings_customize => '自定义 StashFlow';

  @override
  String get settings_customize_subtitle => '集中调整播放、外观、布局和支持工具。';

  @override
  String get settings_core_section => '核心设置';

  @override
  String get settings_core_subtitle => '最常用的配置页面';

  @override
  String get settings_server => '服务器';

  @override
  String get settings_server_subtitle => '连接和 API 配置';

  @override
  String get settings_playback => '播放';

  @override
  String get settings_playback_subtitle => '播放器行为和交互';

  @override
  String get settings_keyboard => '键盘';

  @override
  String get settings_keyboard_subtitle => '可自定义的快捷键';

  @override
  String get settings_keyboard_title => '键盘快捷键';

  @override
  String get settings_keyboard_reset_defaults => '重置为默认值';

  @override
  String get settings_keyboard_not_bound => '未绑定';

  @override
  String get settings_keyboard_volume_up => '提高音量';

  @override
  String get settings_keyboard_volume_down => '降低音量';

  @override
  String get settings_keyboard_toggle_mute => '切换静音';

  @override
  String get settings_keyboard_toggle_fullscreen => '切换全屏';

  @override
  String get settings_keyboard_next_scene => '下一个场景';

  @override
  String get settings_keyboard_prev_scene => '上一个场景';

  @override
  String get settings_keyboard_increase_speed => '提高播放速度';

  @override
  String get settings_keyboard_decrease_speed => '降低播放速度';

  @override
  String get settings_keyboard_reset_speed => '重置播放速度';

  @override
  String get settings_keyboard_close_player => '关闭播放器';

  @override
  String get settings_keyboard_next_image => '下一张图片';

  @override
  String get settings_keyboard_prev_image => '上一张图片';

  @override
  String get settings_keyboard_go_back => '返回';

  @override
  String get settings_keyboard_play_pause_desc => '在播放和暂停视频之间切换';

  @override
  String get settings_keyboard_seek_forward_5_desc => '快进 5 秒';

  @override
  String get settings_keyboard_seek_backward_5_desc => '快退 5 秒';

  @override
  String get settings_keyboard_seek_forward_10_desc => '快进 10 秒';

  @override
  String get settings_keyboard_seek_backward_10_desc => '快退 10 秒';

  @override
  String get settings_appearance => '外观';

  @override
  String get settings_appearance_subtitle => '主题和颜色';

  @override
  String get settings_interface => '界面';

  @override
  String get settings_interface_subtitle => '导航和布局默认值';

  @override
  String get settings_support => '支持';

  @override
  String get settings_support_subtitle => '诊断与关于';

  @override
  String get settings_develop => '开发';

  @override
  String get settings_develop_subtitle => '高级工具和覆盖';

  @override
  String get settings_appearance_title => '外观设置';

  @override
  String get settings_appearance_theme_mode => '主题模式';

  @override
  String get settings_appearance_theme_mode_subtitle => '选择应用如何跟随亮度变化';

  @override
  String get settings_appearance_theme_system => '系统默认';

  @override
  String get settings_appearance_theme_light => '浅色';

  @override
  String get settings_appearance_theme_dark => '深色';

  @override
  String get settings_appearance_primary_color => '主色调';

  @override
  String get settings_appearance_primary_color_subtitle =>
      '为 Material 3 调色板选择种子颜色';

  @override
  String get settings_appearance_advanced_theming => '高级主题';

  @override
  String get settings_appearance_advanced_theming_subtitle => '针对特定屏幕类型的优化';

  @override
  String get settings_appearance_true_black => '纯黑 (AMOLED)';

  @override
  String get settings_appearance_true_black_subtitle =>
      '在深色模式下使用纯黑背景以节省 OLED 屏幕电量';

  @override
  String get settings_appearance_custom_hex => '自定义 Hex 颜色';

  @override
  String get settings_appearance_custom_hex_helper => '输入 8 位 ARGB hex 代码';

  @override
  String get settings_appearance_font_size => '全球用户界面规模';

  @override
  String get settings_appearance_font_size_subtitle => '按比例缩放版式和间距';

  @override
  String get settings_interface_title => '界面设置';

  @override
  String get settings_interface_language => '语言';

  @override
  String get settings_interface_language_subtitle => '覆盖默认系统语言';

  @override
  String get settings_interface_app_language => '应用语言';

  @override
  String get settings_interface_navigation => '导航';

  @override
  String get settings_interface_navigation_subtitle => '全局导航快捷方式的可见性';

  @override
  String get settings_interface_show_random => '显示随机导航按钮';

  @override
  String get settings_interface_show_random_subtitle => '在列表和详情页启用或禁用悬浮随机按钮';

  @override
  String get settings_interface_hide_scene_metadata => '默认隐藏场景元数据';

  @override
  String get settings_interface_hide_scene_metadata_subtitle =>
      '点击“显示元数据”后才显示场景技术元数据。';

  @override
  String get settings_interface_random_scene_filter => '随机场景遵循当前筛选条件';

  @override
  String get settings_interface_random_scene_filter_subtitle =>
      '启用后，随机场景导航会使用当前场景筛选条件。';

  @override
  String get settings_interface_main_pages_gravity_orientation =>
      '重力控制的方向（主页面）';

  @override
  String get settings_interface_main_pages_gravity_orientation_subtitle =>
      '允许主页面使用设备传感器旋转。全屏视频播放将使用其自己的方向设置。';

  @override
  String get settings_interface_show_edit => '显示编辑按钮';

  @override
  String get settings_interface_show_edit_subtitle => '在场景详情页启用或禁用编辑按钮';

  @override
  String get settings_interface_use_actual_scene_video_miniplayer =>
      '在迷你播放器中使用实际场景视频';

  @override
  String get settings_interface_use_actual_scene_video_miniplayer_subtitle =>
      '播放时显示实时场景视频画面，而不是场景截图。';

  @override
  String get details_show_metadata => '显示元数据';

  @override
  String get settings_interface_entity_image_filtering => '实体图像过滤';

  @override
  String get settings_interface_entity_image_filtering_subtitle =>
      '选择实体图像页面是匹配图像元数据还是关联图库。';

  @override
  String get settings_interface_entity_image_filtering_direct => '直接实体';

  @override
  String get settings_interface_entity_image_filtering_galleries => '关联图库';

  @override
  String get settings_interface_customize_tabs => '自定义标签页';

  @override
  String get settings_interface_customize_tabs_subtitle => '重新排序或隐藏导航菜单项';

  @override
  String get settings_interface_scenes_layout => '场景布局';

  @override
  String get settings_interface_scenes_layout_subtitle => '场景的默认浏览模式';

  @override
  String get settings_interface_galleries_layout => '图库布局';

  @override
  String get settings_interface_galleries_layout_subtitle => '图库的默认浏览模式';

  @override
  String get settings_interface_max_performer_avatars => '最多出演者头像';

  @override
  String get settings_interface_max_performer_avatars_subtitle =>
      '在场景卡上显示的出演者头像的最大数量。';

  @override
  String get settings_interface_show_performer_avatars => '显示出演者头像';

  @override
  String get settings_interface_show_performer_avatars_subtitle =>
      '在所有平台的场景卡上显示出演者图标。';

  @override
  String get settings_interface_performer_avatar_size => '出演者头像大小';

  @override
  String get settings_interface_layout_default => '默认布局';

  @override
  String get settings_interface_layout_default_desc => '选择页面的默认布局';

  @override
  String get settings_interface_layout_list => '列表';

  @override
  String get settings_interface_layout_grid => '网格';

  @override
  String get settings_interface_layout_tiktok => '无限滚动';

  @override
  String get settings_interface_grid_columns => '网格列数';

  @override
  String get settings_interface_image_viewer => '图片查看器';

  @override
  String get settings_interface_image_viewer_subtitle => '配置全屏图片浏览行为';

  @override
  String get settings_interface_swipe_direction => '全屏滑动方向';

  @override
  String get settings_interface_swipe_direction_desc => '选择全屏模式下图片的切换方式';

  @override
  String get settings_interface_swipe_vertical => '垂直';

  @override
  String get settings_interface_swipe_horizontal => '水平';

  @override
  String get settings_interface_waterfall_columns => '瀑布流网格列数';

  @override
  String get settings_interface_performer_layouts => '演职人员布局';

  @override
  String get settings_interface_performer_layouts_subtitle => '演职人员的媒体和图库默认设置';

  @override
  String get settings_interface_studio_layouts => '制片商布局';

  @override
  String get settings_interface_studio_layouts_subtitle => '制片商的媒体和图库默认设置';

  @override
  String get settings_interface_tag_layouts => '标签布局';

  @override
  String get settings_interface_tag_layouts_subtitle => '标签的媒体和图库默认设置';

  @override
  String get settings_interface_media_layout => '媒体布局';

  @override
  String get settings_interface_media_layout_subtitle => '媒体页面的布局';

  @override
  String get settings_interface_galleries_layout_item => '图库布局';

  @override
  String get settings_interface_galleries_layout_subtitle_item => '图库页面的布局';

  @override
  String get settings_server_title => '服务器设置';

  @override
  String get settings_server_status => '连接状态';

  @override
  String get settings_server_status_subtitle => '与配置服务器的实时连接状态';

  @override
  String get settings_server_details => '服务器详情';

  @override
  String get settings_server_details_subtitle => '配置端点和身份验证方式';

  @override
  String get settings_server_url => 'Stash 地址';

  @override
  String get settings_server_url_helper =>
      '输入 Stash 服务器的 URL。如果配置了自定义路径，请在此处包含它。';

  @override
  String get settings_server_url_example => 'http://192.168.1.100:9999';

  @override
  String get settings_server_login_failed => '登录失败';

  @override
  String get settings_server_auth_method => '身份验证方式';

  @override
  String get settings_server_auth_apikey => 'API 密钥';

  @override
  String get settings_server_auth_password => '用户名 + 密码';

  @override
  String get settings_server_auth_password_desc => '推荐：使用您的 Stash 用户名/密码会话。';

  @override
  String get settings_server_auth_apikey_desc => '使用 API 密钥进行静态令牌身份验证。';

  @override
  String get settings_server_username => '用户名';

  @override
  String get settings_server_password => '密码';

  @override
  String get settings_server_login_test => '登录并测试';

  @override
  String get settings_server_test => '测试连接';

  @override
  String get settings_server_logout => '退出登录';

  @override
  String get settings_server_clear => '清除设置';

  @override
  String settings_server_connected(String version) {
    return '已连接 (Stash $version)';
  }

  @override
  String get settings_server_checking => '正在检查连接...';

  @override
  String settings_server_failed(String error) {
    return '失败：$error';
  }

  @override
  String get settings_server_invalid_url => '无效的服务器 URL';

  @override
  String get settings_server_resolve_error => '无法解析服务器 URL。请检查主机、端口和凭据。';

  @override
  String get settings_server_logout_confirm => '已退出登录并清除 Cookie。';

  @override
  String get settings_server_profile_add => '添加配置文件';

  @override
  String get settings_server_profile_edit => '编辑配置文件';

  @override
  String get settings_server_profile_name => '配置文件名称';

  @override
  String get settings_server_profile_delete => '删除配置文件';

  @override
  String get settings_server_profile_delete_confirm => '您确定要删除此配置文件吗？此操作无法撤消。';

  @override
  String get settings_server_profile_active => '激活';

  @override
  String get settings_server_profile_empty => '未配置服务器配置文件';

  @override
  String get settings_server_profiles => '服务器配置文件';

  @override
  String get settings_server_profiles_subtitle => '管理多个 Stash 服务器连接';

  @override
  String get settings_server_auth_status_logging_in => '身份验证状态：正在登录...';

  @override
  String get settings_server_auth_status_logged_in => '身份验证状态：已登录';

  @override
  String get settings_server_auth_status_logged_out => '身份验证状态：已登出';

  @override
  String get settings_playback_title => '播放设置';

  @override
  String get settings_playback_behavior => '播放行为';

  @override
  String get settings_playback_behavior_subtitle => '默认播放和后台处理';

  @override
  String get settings_playback_prefer_streams => '优先使用 sceneStreams';

  @override
  String get settings_playback_prefer_streams_subtitle =>
      '关闭时，播放将直接使用 paths.stream';

  @override
  String get settings_playback_feed_random => '从随机位置开始播放Feed';

  @override
  String get settings_playback_feed_random_subtitle =>
      '在Feed模式下播放场景时，从视频长度的0%到90%之间的随机位置开始播放';

  @override
  String get settings_playback_resume_position => '从上次播放位置恢复';

  @override
  String get settings_playback_resume_position_subtitle =>
      '打开视频时，自动从上次中断的地方继续播放';

  @override
  String get settings_playback_end_behavior => '播放结束行为';

  @override
  String get settings_playback_end_behavior_subtitle => '当前视频播放结束时的操作';

  @override
  String get settings_playback_end_behavior_stop => '停止';

  @override
  String get settings_playback_end_behavior_loop => '循环播放当前场景';

  @override
  String get settings_playback_end_behavior_next => '播放下一个场景';

  @override
  String get settings_playback_autoplay => '自动播放下一个场景';

  @override
  String get settings_playback_autoplay_subtitle => '当前播放结束时自动播放下一个场景';

  @override
  String get settings_playback_background => '后台播放';

  @override
  String get settings_playback_background_subtitle => '应用在后台时继续播放视频音频';

  @override
  String get settings_playback_pip => '原生画中画';

  @override
  String get settings_playback_pip_subtitle => '启用 Android 画中画按钮并在进入后台时自动进入';

  @override
  String get settings_playback_subtitles => '字幕设置';

  @override
  String get settings_playback_subtitles_subtitle => '自动加载和外观';

  @override
  String get settings_playback_subtitle_lang => '默认字幕语言';

  @override
  String get settings_playback_subtitle_lang_subtitle => '如果可用则自动加载';

  @override
  String get settings_playback_subtitle_size => '字幕字体大小';

  @override
  String get settings_playback_subtitle_pos => '字幕垂直位置';

  @override
  String settings_playback_subtitle_pos_desc(String percent) {
    return '距离底部 $percent%';
  }

  @override
  String get settings_playback_subtitle_align => '字幕文本对齐';

  @override
  String get settings_playback_subtitle_align_subtitle => '多行字幕的对齐方式';

  @override
  String get settings_playback_seek => '快进/快退交互';

  @override
  String get settings_playback_seek_subtitle => '选择播放期间的进度条拖动方式';

  @override
  String get settings_playback_seek_double_tap => '双击左/右侧快进/快退 10 秒';

  @override
  String get settings_playback_seek_drag => '拖动时间轴进行快进/快退';

  @override
  String get settings_playback_seek_drag_label => '拖动';

  @override
  String get settings_playback_seek_double_tap_label => '双击';

  @override
  String get settings_playback_gravity_orientation => '重力控制的方向';

  @override
  String get settings_playback_direct_play => '切换场景时直接播放';

  @override
  String get settings_playback_direct_play_subtitle =>
      '从另一个正在播放的场景切换过来时，直接播放新场景';

  @override
  String get settings_playback_gravity_orientation_subtitle =>
      '允许使用设备传感器在匹配的方向之间旋转（例如：左右翻转横向）。';

  @override
  String get settings_playback_subtitle_lang_none_disabled => '无（禁用）';

  @override
  String get settings_playback_subtitle_lang_auto_if_only_one => '自动（仅有一个时）';

  @override
  String get settings_playback_subtitle_lang_english => '英语';

  @override
  String get settings_playback_subtitle_lang_chinese => '中文';

  @override
  String get settings_playback_subtitle_lang_german => '德语';

  @override
  String get settings_playback_subtitle_lang_french => '法语';

  @override
  String get settings_playback_subtitle_lang_spanish => '西班牙语';

  @override
  String get settings_playback_subtitle_lang_italian => '意大利语';

  @override
  String get settings_playback_subtitle_lang_japanese => '日语';

  @override
  String get settings_playback_subtitle_lang_korean => '韩语';

  @override
  String get settings_playback_subtitle_align_left => '左对齐';

  @override
  String get settings_playback_subtitle_align_center => '居中';

  @override
  String get settings_playback_subtitle_align_right => '右对齐';

  @override
  String get settings_support_title => '支持';

  @override
  String get settings_support_diagnostics => '诊断和项目信息';

  @override
  String get settings_support_diagnostics_subtitle => '在需要帮助时打开运行日志或跳转到存储库。';

  @override
  String get settings_support_update_available => '有可用更新';

  @override
  String get settings_support_update_available_subtitle => 'GitHub 上有新版本可用';

  @override
  String settings_support_update_to(String version) {
    return '更新至 $version';
  }

  @override
  String get settings_support_update_to_subtitle => '新功能和改进正等着您。';

  @override
  String get settings_support_about => '关于';

  @override
  String get settings_support_about_subtitle => '项目和源代码信息';

  @override
  String get settings_support_version => '版本';

  @override
  String get settings_support_version_loading => '正在加载版本信息...';

  @override
  String get settings_support_version_unavailable => '版本信息不可用';

  @override
  String get settings_support_github => 'GitHub 存储库';

  @override
  String get settings_support_github_subtitle => '查看源代码并报告问题';

  @override
  String get settings_support_github_error => '无法打开 GitHub 链接';

  @override
  String get settings_support_issues => '报告问题';

  @override
  String get settings_support_issues_subtitle => '通过报告错误帮助改进 StashFlow';

  @override
  String get settings_develop_title => '开发';

  @override
  String get settings_develop_enable_logging => '启用调试日志';

  @override
  String get settings_develop_enable_logging_subtitle => '记录应用日志以供排查问题';

  @override
  String get settings_develop_diagnostics => '诊断工具';

  @override
  String get settings_develop_diagnostics_subtitle => '故障排除和性能';

  @override
  String get settings_develop_video_debug => '显示视频调试信息';

  @override
  String get settings_develop_video_debug_subtitle => '在视频播放器上以叠加层形式显示技术播放详情。';

  @override
  String get settings_develop_log_viewer => '调试日志查看器';

  @override
  String get settings_develop_log_viewer_subtitle => '打开应用内日志的实时视图。';

  @override
  String get settings_develop_logs_copied => '日志已复制到剪贴板';

  @override
  String get settings_develop_no_logs => '尚无日志。与应用交互以捕获日志。';

  @override
  String get settings_develop_web_overrides => 'Web 覆盖';

  @override
  String get settings_develop_web_overrides_subtitle => 'Web 平台的高级标志';

  @override
  String get settings_develop_web_auth => '允许在 Web 上使用密码登录';

  @override
  String get settings_develop_web_auth_subtitle =>
      '覆盖仅限原生的限制，并强制用户名 + 密码身份验证方式在 Flutter Web 上可见。';

  @override
  String get settings_develop_proxy_auth => '启用代理认证模式';

  @override
  String get settings_develop_proxy_auth_subtitle =>
      '启用高级 Basic Auth 和 Bearer Token 方法，以便在 Authentik 等代理背后的无认证后端中使用。';

  @override
  String get settings_server_auth_basic => '基础认证';

  @override
  String get settings_server_auth_bearer => 'Bearer 令牌';

  @override
  String get settings_server_auth_basic_desc =>
      '发送 \'Authorization: Basic <base64(user:pass)>\' 请求头。';

  @override
  String get settings_server_auth_bearer_desc =>
      '发送 \'Authorization: Bearer <token>\' 请求头。';

  @override
  String get common_edit => '编辑';

  @override
  String get common_resolution => '分辨率';

  @override
  String get common_orientation => '方向';

  @override
  String get common_landscape => '横向';

  @override
  String get common_portrait => '纵向';

  @override
  String get common_square => '正方形';

  @override
  String get performers_filter_saved => '筛选首选项已保存为默认值';

  @override
  String get images_title => '图片';

  @override
  String get images_filter_title => '过滤图片';

  @override
  String get images_filter_saved => '筛选偏好已保存为默认设置';

  @override
  String get images_sort_title => '对图片排序';

  @override
  String get images_sort_saved => '排序首选项已保存为默认值';

  @override
  String get image_rating_updated => '图片评分已更新。';

  @override
  String get gallery_rating_updated => '图库评分已更新。';

  @override
  String get common_image => '图片';

  @override
  String get common_gallery => '图库';

  @override
  String get images_gallery_rating_unavailable => '图库评分仅在浏览图库时可用。';

  @override
  String images_rating(String rating) {
    return '评分：$rating / 5';
  }

  @override
  String get images_filtered_by_gallery => '按画廊筛选';

  @override
  String get images_slideshow_need_two => '幻灯片放映至少需要 2 张图片。';

  @override
  String get images_slideshow_start_title => '开始幻灯片放映';

  @override
  String images_slideshow_interval(num seconds) {
    return '间隔：${seconds}s';
  }

  @override
  String images_slideshow_transition_ms(num ms) {
    return '过渡：${ms}ms';
  }

  @override
  String get common_forward => '前进';

  @override
  String get common_backward => '后退';

  @override
  String get images_slideshow_loop_title => '循环幻灯片放映';

  @override
  String get common_cancel => '取消';

  @override
  String get common_start => '开始';

  @override
  String get common_done => '完成';

  @override
  String get settings_keybind_assign_shortcut => '分配快捷键';

  @override
  String get settings_keybind_press_any => '按任意键组合...';

  @override
  String get scenes_select_tags => '选择标签';

  @override
  String get scenes_no_scrapers => '没有可用的抓取器';

  @override
  String get scenes_select_scraper => '选择抓取器';

  @override
  String get scenes_no_results_found => '未找到结果';

  @override
  String get scenes_select_result => '选择结果';

  @override
  String scenes_scrape_failed(String error) {
    return '抓取失败：$error';
  }

  @override
  String get scenes_updated_successfully => '场景更新成功';

  @override
  String scenes_update_failed(String error) {
    return '场景更新失败：$error';
  }

  @override
  String get scenes_edit_title => '编辑场景';

  @override
  String get scenes_field_studio => '制片商';

  @override
  String get scenes_field_tags => '标签';

  @override
  String get scenes_field_urls => '链接';

  @override
  String get scenes_edit_performer => '编辑演员';

  @override
  String get scenes_edit_studio => '编辑工作室';

  @override
  String get common_no_title => '无标题';

  @override
  String get scenes_select_studio => '选择制片商';

  @override
  String get scenes_select_performers => '选择出演者';

  @override
  String get scenes_unmatched_scraped_tags => '未匹配的抓取标签';

  @override
  String get scenes_unmatched_scraped_performers => '未匹配的抓取出演者';

  @override
  String get scenes_no_matching_performer_found => '在库中未找到匹配的出演者';

  @override
  String get common_unknown => '未知';

  @override
  String scenes_studio_id_prefix(String id) {
    return '制片商 ID：$id';
  }

  @override
  String get tags_search_placeholder => '搜索标签...';

  @override
  String get scenes_duration_short => '< 5分钟';

  @override
  String get scenes_duration_medium => '5-20分钟';

  @override
  String get scenes_duration_long => '> 20分钟';

  @override
  String get details_scene_fingerprint_query => '场景指纹查询';

  @override
  String get scenes_available_scrapers => '可用抓取器';

  @override
  String get scrape_results_existing => '已存在';

  @override
  String get scrape_results_scraped => '已抓取';

  @override
  String get stats_refresh_statistics => '刷新统计数据';

  @override
  String get stats_library_stats => '图书馆统计';

  @override
  String get stats_stash_glance => '您的藏品一目了然';

  @override
  String get stats_content => '内容';

  @override
  String get stats_organization => '组织';

  @override
  String get stats_activity => '活动';

  @override
  String get stats_scenes => '场景';

  @override
  String get stats_galleries => '画廊';

  @override
  String get stats_performers => '表演者';

  @override
  String get stats_studios => '工作室';

  @override
  String get stats_groups => '团体';

  @override
  String get stats_tags => '标签';

  @override
  String get stats_total_plays => '总播放次数';

  @override
  String stats_unique_items(int count) {
    return '$count 个唯一项目';
  }

  @override
  String get stats_total_o_count => '总 O 计数';

  @override
  String get cast_airplay_pairing => '隔空播放配对';

  @override
  String get cast_enter_pin => '输入电视上显示的 4 位 PIN 码';

  @override
  String get cast_pair => '一对';

  @override
  String cast_connecting_to(String deviceName) {
    return '正在连接到 $deviceName...';
  }

  @override
  String cast_casting_to(String deviceName) {
    return '正在投放到 $deviceName';
  }

  @override
  String cast_pairing_failed(String error) {
    return '配对失败：$error';
  }

  @override
  String cast_failed_to_cast(String error) {
    return '投放失败：$error';
  }

  @override
  String get cast_searching => '正在搜索设备...';

  @override
  String get cast_cast_to_device => '投射到设备';

  @override
  String get settings_storage_images => '图片';

  @override
  String get settings_storage_videos => '视频';

  @override
  String get settings_storage_database => '数据库';

  @override
  String get settings_storage_clearing_image => '正在清除图像缓存...';

  @override
  String get settings_storage_clearing_video => '清除视频缓存...';

  @override
  String get settings_storage_clearing_database => '清除数据库缓存...';

  @override
  String get settings_storage_cleared_image => '图像缓存已清除';

  @override
  String get settings_storage_cleared_video => '视频缓存已清除';

  @override
  String get settings_storage_cleared_database => '数据库缓存已清除';

  @override
  String get settings_storage_clear => '清除';

  @override
  String get settings_storage_error_loading => '加载尺寸时出错';

  @override
  String settings_storage_mb(num value) {
    return '$value MB';
  }

  @override
  String settings_storage_gb(num value) {
    return '$value GB';
  }

  @override
  String get settings_storage_100_mb => '100MB';

  @override
  String get settings_storage_500_mb => '500MB';

  @override
  String get settings_storage_1_gb => '1GB';

  @override
  String get settings_storage_2_gb => '2GB';

  @override
  String get settings_storage_unlimited => '无限';

  @override
  String get settings_storage_limits => '限制';

  @override
  String get settings_storage_limits_subtitle => '设置最大缓存大小';

  @override
  String get settings_storage_max_image_cache => '最大图像缓存 (MB)';

  @override
  String get settings_storage_max_video_cache => '最大视频缓存 (MB)';

  @override
  String get settings_storage => '存储与缓存';

  @override
  String get settings_storage_usage => '存储占用';

  @override
  String get settings_storage_usage_subtitle => '当前缓存占用空间';

  @override
  String get settings_storage_subtitle => '管理本地缓存和存储限制';

  @override
  String get performers_field_name => '姓名';

  @override
  String get performers_field_url => 'URL';

  @override
  String get performers_field_details => '详情';

  @override
  String get performers_field_birth_year => '出生年份';

  @override
  String get performers_field_age => '年龄';

  @override
  String get performers_field_death_year => '去世年份';

  @override
  String get performers_field_scene_count => '场景数';

  @override
  String get performers_field_image_count => '图片数';

  @override
  String get performers_field_gallery_count => '图库数';

  @override
  String get performers_field_play_count => '播放次数';

  @override
  String get performers_field_o_counter => 'O-计数器';

  @override
  String get performers_field_tag_count => '标签数';

  @override
  String get performers_field_created_at => '创建于';

  @override
  String get performers_field_updated_at => '更新于';

  @override
  String get galleries_field_title => '标题';

  @override
  String get galleries_field_details => '详情';

  @override
  String get galleries_field_date => '日期';

  @override
  String get galleries_field_performer_age => '演出者年龄';

  @override
  String get galleries_field_performer_count => '演出者人数';

  @override
  String get galleries_field_tag_count => '标签数';

  @override
  String get galleries_field_url => 'URL';

  @override
  String get galleries_field_id => 'ID';

  @override
  String get galleries_field_path => '路径';

  @override
  String get galleries_field_checksum => '校验和';

  @override
  String get galleries_field_image_count => '图片数';

  @override
  String get galleries_field_file_count => '文件数';

  @override
  String get galleries_field_created_at => '创建于';

  @override
  String get galleries_field_updated_at => '更新于';

  @override
  String get images_field_title => '标题';

  @override
  String get images_field_details => '详情';

  @override
  String get images_field_path => '路径';

  @override
  String get images_field_url => 'URL';

  @override
  String get images_field_file_count => '文件数';

  @override
  String get images_field_o_counter => 'O-计数器';

  @override
  String get studios_field_name => '名称';

  @override
  String get studios_field_details => '详情';

  @override
  String get studios_field_aliases => '别名';

  @override
  String get studios_field_url => 'URL';

  @override
  String get studios_field_tag_count => '标签数';

  @override
  String get studios_field_scene_count => '场景数';

  @override
  String get studios_field_image_count => '图片数';

  @override
  String get studios_field_gallery_count => '图库数';

  @override
  String get studios_field_sub_studio_count => '子工作室数';

  @override
  String get studios_field_created_at => '创建于';

  @override
  String get studios_field_updated_at => '更新于';

  @override
  String get scenes_field_performer_age => '演出者年龄';

  @override
  String get scenes_field_performer_count => '演出者人数';

  @override
  String get scenes_field_tag_count => '标签数';

  @override
  String get scenes_field_code => '代码';

  @override
  String get scenes_field_details => '详情';

  @override
  String get scenes_field_director => '导演';

  @override
  String get scenes_field_url => 'URL';

  @override
  String get scenes_field_date => '日期';

  @override
  String get scenes_field_path => '路径';

  @override
  String get scenes_field_captions => '字幕';

  @override
  String get scenes_field_duration => '时长（秒）';

  @override
  String get scenes_field_bitrate => '比特率';

  @override
  String get scenes_field_video_codec => '视频编码';

  @override
  String get scenes_field_audio_codec => '音频编码';

  @override
  String get scenes_field_framerate => '帧率';

  @override
  String get scenes_field_file_count => '文件数';

  @override
  String get scenes_field_play_count => '播放次数';

  @override
  String get scenes_field_play_duration => '播放时长';

  @override
  String get scenes_field_o_counter => 'O-计数器';

  @override
  String get scenes_field_last_played_at => '最后播放于';

  @override
  String get scenes_field_resume_time => '恢复时间';

  @override
  String get scenes_field_interactive_speed => '交互速度';

  @override
  String get scenes_field_id => 'ID';

  @override
  String get scenes_field_stash_id_count => 'Stash ID 数量';

  @override
  String get scenes_field_oshash => 'Oshash';

  @override
  String get scenes_field_checksum => '校验和';

  @override
  String get scenes_field_phash => 'Phash';

  @override
  String get scenes_field_created_at => '创建于';

  @override
  String get scenes_field_updated_at => '更新于';

  @override
  String get cast_stopped_resuming_locally => '投放已停止，在本地恢复播放';

  @override
  String get cast_stop_casting => '停止投放';

  @override
  String get cast_cast => '投放';

  @override
  String get common_add => '添加';

  @override
  String get common_remove => '移除';

  @override
  String get common_clear => '清除';

  @override
  String get common_download => '下载';

  @override
  String get common_star => '收藏';

  @override
  String get settings_interface_card_title_font_size => '卡片标题字体大小';

  @override
  String get common_hint_date => 'YYYY-MM-DD';

  @override
  String get common_hint_url => 'https://...';

  @override
  String get common_hint_hex => 'FF0F766E';

  @override
  String common_px(int value) {
    return '$value 像素';
  }

  @override
  String common_pt(int value) {
    return '$value 点';
  }

  @override
  String common_percent(int value) {
    return '$value%';
  }

  @override
  String get saving_video => '正在保存到相册...';

  @override
  String get saved_to_album => '已保存到 StashFlow 相册';

  @override
  String gallery_error(String message) {
    return '相册错误: $message';
  }

  @override
  String failed_to_save(String error) {
    return '保存失败: $error';
  }

  @override
  String get saving_image => '正在保存图片...';

  @override
  String common_select(String label) {
    return '选择 $label';
  }

  @override
  String common_saved_to(String path) {
    return '已保存到 $path';
  }

  @override
  String get recent_searches => '最近搜索';

  @override
  String get initializing_player => '正在初始化播放器...';

  @override
  String get sort_scenes => '排序场景';

  @override
  String get failed_to_load_tap_to_retry => '加载失败。点击重试。';

  @override
  String get would_you_like_to_visit_the_release_page_to_download_it =>
      '您想访问发布页面下载吗？';

  @override
  String get to_get_started_configure_stash_server =>
      '要开始使用，您需要配置您的 Stash 服务器连接详细信息。';

  @override
  String get loading => '加载中';

  @override
  String get wip => 'WIP';

  @override
  String get performer_filters => '演员筛选';

  @override
  String update_available(String version) {
    return 'StashFlow的更新版本 ($version) 已经发布。';
  }

  @override
  String details_failed_update_favorite(String error) {
    return '更新收藏失败: $error';
  }

  @override
  String details_failed_load_galleries(String error) {
    return '加载图库失败: $error';
  }

  @override
  String get scene_info_id => '场景ID';

  @override
  String get scene_info_original_file_path => '原始文件路径';

  @override
  String get scene_info_resume_time => '恢复时间';

  @override
  String get scene_info_play_duration => '播放时长';

  @override
  String get scene_info_urls => '网址';

  @override
  String get scene_info_resolution => '解决';

  @override
  String get scene_info_bitrate => '比特率';

  @override
  String get scene_info_frame_rate => '帧率';

  @override
  String get scene_info_format => '格式';

  @override
  String get scene_info_video_codec => '视频编解码器';

  @override
  String get scene_info_audio_codec => '音频编解码器';

  @override
  String get scene_info_stream => '溪流';

  @override
  String get scene_info_preview => '预览';

  @override
  String get scene_info_screenshot => '截屏';

  @override
  String get scene_info_cover => '封面';

  @override
  String get scene_info_caption => '标题';

  @override
  String get scene_info_vtt => '视听测试';

  @override
  String get scene_info_sprite => '雪碧';

  @override
  String get scene_info_technical => '技术的';

  @override
  String scene_studio_id(String id) {
    return 'ID：$id';
  }

  @override
  String scene_rating_stars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 星星',
      one: '1 星',
    );
    return '$_temp0';
  }

  @override
  String get main_startup_failed => 'StashFlow 启动失败';

  @override
  String get main_startup_failed_desc => '在应用程序完成初始化之前启动服务失败。检查诊断后重新启动应用程序。';

  @override
  String common_searching_for(String query) {
    return '正在搜索：“$query”';
  }

  @override
  String get cast_device => '设备';

  @override
  String get auth_enter_passcode => '输入您的密码以继续。';

  @override
  String get auth_unlock => '开锁';

  @override
  String get auth_incorrect_passcode => '密码不正确';

  @override
  String get auth_app_locked => '应用程序已锁定';

  @override
  String get settings_security_passcode => '密码';

  @override
  String get settings_security_passcode_configured => '已配置';

  @override
  String get settings_security_passcode_not_configured => '未配置';

  @override
  String get settings_security_passcode_saved => '密码已保存';

  @override
  String get settings_security_passcode_removed => '密码已删除';

  @override
  String get settings_security_enable_app_lock => '启用应用程序锁定';

  @override
  String get settings_security_enable_app_lock_subtitle => '应用程序恢复/启动时需要密码。';

  @override
  String get settings_security_lock_on_launch => '锁定应用程序启动';

  @override
  String get settings_security_lock_on_launch_subtitle => '应用程序打开时立即询问密码。';

  @override
  String get settings_security_background_lock_timer => '后台锁定定时器';

  @override
  String get settings_security_background_lock_timer_subtitle =>
      '应用程序在锁定之前可以在后台停留多长时间。';

  @override
  String get settings_security_set_passcode => '设置密码';

  @override
  String get settings_security_passcode_prompt => '密码（4-8位）';

  @override
  String get settings_security_confirm_passcode => '确认';

  @override
  String get settings_security_error_numeric => '仅使用数字，长度为 4-8。';

  @override
  String get settings_security_error_mismatch => '密码不匹配。';

  @override
  String get common_change => '改变';

  @override
  String get common_set => '放';

  @override
  String get common_immediately => '立即地';

  @override
  String common_sec(int value) {
    return '$value 秒';
  }

  @override
  String common_min(int value) {
    return '$value 分钟';
  }

  @override
  String common_s(int value) {
    return '${value}s';
  }

  @override
  String get settings_security_title => '安全';

  @override
  String get settings_security_subtitle => '应用锁和密码设置';

  @override
  String get settings_security_app_lock => '应用锁';

  @override
  String get settings_security_app_lock_subtitle => '后台运行后使用密码保护访问。';

  @override
  String get common_saved_filters => '保存的筛选';

  @override
  String get tools => '工具';

  @override
  String get tools_section_subtitle => '场景的维护和元数据工作流。';

  @override
  String get tools_scene_deduplication_subtitle => '查找并管理重复的场景。';

  @override
  String get tools_scene_tagger_subtitle => '使用 Stash-box 刮削当前场景页面。';

  @override
  String get preset_deleted => '预设已删除';

  @override
  String get delete_preset => '删除预设';

  @override
  String get common_delete => '删除';

  @override
  String get save_preset => '保存预设';

  @override
  String get no_saved_presets => '没有已保存的预设';

  @override
  String get scene_tagger => '场景标注';

  @override
  String get page_size => '每页数量';

  @override
  String get mode => '模式';

  @override
  String get sort => '排序';

  @override
  String get desc => '降序';

  @override
  String get asc => '升序';

  @override
  String get filter => '筛选';

  @override
  String get load_preset => '加载预设';

  @override
  String get preset => '预设';

  @override
  String get stash_box_scraper => 'Stash Box 抓取器';

  @override
  String get start_tagging => '开始标注';

  @override
  String get stop => '停止';

  @override
  String get open_scene => '打开场景';

  @override
  String get skip => '跳过';

  @override
  String get apply => '应用';

  @override
  String get selected => '已选择';

  @override
  String get select => '选择';

  @override
  String get preview => '预览';

  @override
  String get delete_scene => '删除场景';

  @override
  String get metadata_only => '仅元数据';

  @override
  String get files => '文件';

  @override
  String get scene_deleted => '场景已删除';

  @override
  String get delete_metadata => '删除元数据';

  @override
  String get delete_files => '删除文件';

  @override
  String get scene_deduplication => '场景去重';

  @override
  String get no_duplicates_found => '未发现重复项。';

  @override
  String get search_accuracy => '搜索精度';

  @override
  String get duration_difference => '时长差异';

  @override
  String get only_select_matching_codecs => '仅选择匹配的编解码器';

  @override
  String get select_scenes => '选择场景';

  @override
  String get all_but_largest_resolution => '除最大分辨率外全部';

  @override
  String get all_but_largest_file => '除最大文件外全部';

  @override
  String get all_but_oldest => '除最旧项外全部';

  @override
  String get all_but_youngest => '除最新项外全部';

  @override
  String get select_none => '取消全选';

  @override
  String get merge => '合并';

  @override
  String get previous_page => '上一页';

  @override
  String get next_page => '下一页';

  @override
  String scene_deduplication_page_count(int page, int totalPages) {
    return '第 $page 页，共 $totalPages 页';
  }

  @override
  String scene_tagger_result_count(int index, int total) {
    return '结果 $index / $total';
  }

  @override
  String delete_preset_confirm(String name) {
    return '删除“$name”？此操作无法撤销。';
  }

  @override
  String get enter_preset_name => '输入预设名称';

  @override
  String get delete_scene_confirm => '确定要删除此场景吗？';

  @override
  String delete_selected_count(int selectedCount) {
    return '删除已选项 ($selectedCount)';
  }

  @override
  String get saved_presets => '已保存的预设';

  @override
  String get current_settings => '当前设置';

  @override
  String get available_presets => '可用预设';

  @override
  String get existing_names_are_overwritten => '已有名称将被覆盖';

  @override
  String get active_settings_saved_server => '当前生效的设置将保存到服务器。';

  @override
  String failed_to_save_filter(String error) {
    return '无法保存筛选器：$error';
  }

  @override
  String failed_to_delete_preset(String error) {
    return '无法删除预设：$error';
  }

  @override
  String sort_label(String sortLabel) {
    return '排序：$sortLabel';
  }

  @override
  String filters_count(int count) {
    return '筛选器：$count';
  }

  @override
  String search_label(String query) {
    return '搜索：$query';
  }

  @override
  String failed_to_load_presets(String error) {
    return '无法加载预设：$error';
  }

  @override
  String saved_item(String item) {
    return '已保存 $item';
  }

  @override
  String unable_to_load_stash_boxes(String error) {
    return '无法加载 Stash Box：$error';
  }

  @override
  String delete_n_scenes_question(int count) {
    return '删除 $count 个场景？';
  }

  @override
  String get delete_scenes_help => '选择仅删除 Stash 元数据，还是同时删除场景文件及其生成的辅助文件。';

  @override
  String deleted_n_scenes(int count) {
    return '已删除 $count 个场景';
  }

  @override
  String delete_failed_error(String error) {
    return '删除失败：$error';
  }

  @override
  String get configuration => '配置';

  @override
  String missing_phashes_for_scenes(int count) {
    return '$count 个场景缺少感知哈希。请运行感知哈希生成任务。';
  }

  @override
  String get merge_editing_not_wired => 'StashFlow 尚未支持合并编辑。';

  @override
  String duplicate_sets_count(int count) {
    return '$count 组重复项';
  }

  @override
  String duplicate_set_number(int number) {
    return '重复组 $number';
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

    return '$countString 个标签';
  }

  @override
  String nGroups(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '$countString 个分组';
  }

  @override
  String nMarkers(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '$countString 个标记';
  }

  @override
  String nGalleries(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '$countString 个画廊';
  }

  @override
  String scene_tagger_checked_matches_summary(int checked, int matches) {
    return '已检查 $checked 项 • $matches 个匹配';
  }

  @override
  String scene_tagger_page_summary(int count) {
    return '本页 $count 个场景';
  }

  @override
  String get no_matched_scenes_yet => '还没有匹配到的场景。';

  @override
  String get no_scenes_match_configuration => '没有场景符合此配置。';

  @override
  String scene_tagger_checked_count(int count) {
    return '已检查 $count 项';
  }

  @override
  String scene_tagger_progress(int checked, int total) {
    return '$checked / $total';
  }

  @override
  String get stats_library_stats_tooltip => '长按查看资料库统计';

  @override
  String get scene_details_marker_created => '标记已创建';

  @override
  String scene_details_failed_to_create_marker(String error) {
    return '无法创建标记：$error';
  }

  @override
  String get scene_details_delete_marker_title => '删除标记';

  @override
  String scene_details_delete_marker_content(String title) {
    return '删除标记“$title”吗？';
  }

  @override
  String get scene_details_marker_deleted => '标记已删除';

  @override
  String scene_details_failed_to_delete_marker(String error) {
    return '无法删除标记：$error';
  }

  @override
  String get scene_details_add_marker => '添加标记';

  @override
  String get scene_details_create_marker => '创造';

  @override
  String scene_details_delete_marker_tooltip(String title) {
    return '删除标记 $title';
  }

  @override
  String get scenes_page_markers_tooltip => '标记';

  @override
  String get auto_marker_name => '标记名称';

  @override
  String get auto_missing_field => '缺失字段';

  @override
  String get filter_markers_title => '过滤标记';

  @override
  String get marker_title => '标记';

  @override
  String get duration_title => '期间';

  @override
  String get scene_title => '场景';

  @override
  String get dates_title => '日期';

  @override
  String get created_at_title => '创建于';

  @override
  String get updated_at_title => '更新于';

  @override
  String get scene_date_title => '场景日期';

  @override
  String get scene_created_at_title => '场景创建于';

  @override
  String get scene_updated_at_title => '场景更新于';

  @override
  String get organized_title => '有组织';

  @override
  String get interactive_title => '交互的';

  @override
  String get scraped_metadata_title => '抓取的元数据';

  @override
  String get local_scene_title => '当地场景';

  @override
  String get sort_markers_title => '对标记进行排序';

  @override
  String get markers_title => '标记';

  @override
  String get sub_group_count_title => '子组计数';

  @override
  String get groups_browsing_mode_subtitle => '群组的默认浏览模式';

  @override
  String get markers_browsing_mode_subtitle => '标记的默认浏览模式';

  @override
  String get entity_layouts_title => '实体布局';

  @override
  String get entity_layouts_subtitle => '表演者、工作室和标签的媒体和画廊布局默认值';

  @override
  String get stats_subtitle_0_gb => '0.00GB';

  @override
  String get stats_subtitle_0_unique_items => '0 件独特物品';

  @override
  String get markers_search_hint => '搜索标记';

  @override
  String get tags_title => '标签';

  @override
  String get scenes_title => '场景';
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');

  @override
  String get appTitle => 'StashFlow';

  @override
  String get common_token => '代币';

  @override
  String get filter_value => '值';

  @override
  String get common_yes => '是的';

  @override
  String get common_no => '否';

  @override
  String get common_clear_history => '清除历史记录';

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
  String get common_default => '默认';

  @override
  String get common_later => '以后';

  @override
  String get common_update_now => '发布详情';

  @override
  String get common_configure_now => '立即配置';

  @override
  String get common_clear_rating => '清除评分';

  @override
  String get common_no_media => '暂无媒体';

  @override
  String get common_show => '显示';

  @override
  String get common_hide => '隐藏';

  @override
  String get galleries_filter_saved => '筛选偏好已保存为默认';

  @override
  String get common_setup_required => '需要设置';

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
  String get sort_file_mod_time => '文件修改时间';

  @override
  String get sort_filesize => '文件大小';

  @override
  String get sort_o_count => 'O 计数器';

  @override
  String get sort_height => '身高';

  @override
  String get sort_birthdate => '出生日期';

  @override
  String get sort_tag_count => '标签数量';

  @override
  String get sort_play_count => '播放次数';

  @override
  String get sort_o_counter => 'O 计数';

  @override
  String get sort_zip_file_count => 'ZIP 文件数';

  @override
  String get sort_last_o_at => '上次 O 时间';

  @override
  String get sort_latest_scene => '最新场景';

  @override
  String get sort_career_start => '职业开始';

  @override
  String get sort_career_end => '职业结束';

  @override
  String get sort_weight => '体重';

  @override
  String get sort_measurements => '三围';

  @override
  String get sort_scenes_duration => '场景时长';

  @override
  String get sort_scenes_size => '场景大小';

  @override
  String get sort_images_count => '图片数量';

  @override
  String get sort_galleries_count => '画廊数量';

  @override
  String get sort_child_count => '子工作室数量';

  @override
  String get sort_performers_count => '演员数量';

  @override
  String get sort_groups_count => '分组数量';

  @override
  String get sort_marker_count => '标记数量';

  @override
  String get sort_studios_count => '工作室数量';

  @override
  String get sort_penis_length => '阴茎长度';

  @override
  String get sort_last_played_at => '上次播放时间';

  @override
  String get studios_sort_saved => '排序偏好已保存为默认';

  @override
  String get studios_no_random => '没有可用于随机导航的制片商';

  @override
  String get tags_filter_title => '筛选标签';

  @override
  String get tags_filter_saved => '筛选偏好已保存为默认';

  @override
  String get tags_sort_title => '排序标签';

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

  @override
  String get common_no_media_available => '无可用媒体';

  @override
  String common_id(Object id) {
    return 'ID：$id';
  }

  @override
  String get common_search_placeholder => '搜索...';

  @override
  String get common_pause => '暂停';

  @override
  String get common_play => '播放';

  @override
  String get common_refresh => '刷新';

  @override
  String get common_close => '关闭';

  @override
  String get common_save => '保存';

  @override
  String get common_unmute => '取消静音';

  @override
  String get common_mute => '静音';

  @override
  String get common_back => '返回';

  @override
  String get common_rate => '评分';

  @override
  String get common_previous => '上一个';

  @override
  String get common_next => '下一个';

  @override
  String get common_favorite => '收藏';

  @override
  String get common_unfavorite => '取消收藏';

  @override
  String get common_version => '版本';

  @override
  String get common_loading => '加载中';

  @override
  String get common_unavailable => '不可用';

  @override
  String get common_details => '详情';

  @override
  String get common_title => '标题';

  @override
  String get common_release_date => '发布日期';

  @override
  String get common_url => '链接';

  @override
  String get common_no_url => '无 URL';

  @override
  String get common_sort => '排序';

  @override
  String get common_filter => '筛选';

  @override
  String get common_search => '搜索';

  @override
  String get common_settings => '设置';

  @override
  String get common_reset_to_1x => '重置为 1x';

  @override
  String get common_skip_next => '跳过下一个';

  @override
  String get common_skip_previous => '跳过上一个';

  @override
  String get common_select_subtitle => '选择字幕';

  @override
  String get common_playback_speed => '播放速度';

  @override
  String get common_pip => '画中画';

  @override
  String get common_toggle_fullscreen => '切换全屏';

  @override
  String get common_exit_fullscreen => '退出全屏';

  @override
  String get common_copy_logs => '复制日志';

  @override
  String get common_clear_logs => '清除日志';

  @override
  String get common_enable_autoscroll => '启用自动滚动';

  @override
  String get common_disable_autoscroll => '禁用自动滚动';

  @override
  String get common_retry => '重试';

  @override
  String get common_no_items => '未找到项目';

  @override
  String get common_none => '无';

  @override
  String get common_any => '任意';

  @override
  String get common_name => '名称';

  @override
  String get common_date => '日期';

  @override
  String get common_rating => '评分';

  @override
  String get common_image_count => '图片数量';

  @override
  String get common_filepath => '文件路径';

  @override
  String get common_random => '随机';

  @override
  String get common_no_media_found => '未找到媒体';

  @override
  String common_not_found(String item) {
    return '未找到 $item';
  }

  @override
  String get common_add_favorite => '添加收藏';

  @override
  String get common_remove_favorite => '取消收藏';

  @override
  String get details_group => '小组详情';

  @override
  String get details_synopsis => '剧情简介';

  @override
  String get details_media => '媒体';

  @override
  String get details_galleries => '图库';

  @override
  String get details_tags => '标签';

  @override
  String get details_links => '链接';

  @override
  String get details_scene_scrape => '抓取元数据';

  @override
  String get details_show_more => '显示更多';

  @override
  String get common_more => '更多';

  @override
  String get details_show_less => '显示较少';

  @override
  String get details_more_from_studio => '更多来自该制片商';

  @override
  String get details_o_count_incremented => 'O 计数已增加';

  @override
  String details_failed_update_rating(String error) {
    return '更新评分失败：$error';
  }

  @override
  String details_failed_update_performer(Object error) {
    return '更新演员失败：$error';
  }

  @override
  String details_failed_increment_o_count(String error) {
    return '增加 O 计数失败：$error';
  }

  @override
  String get details_scene_add_performer => '添加出演者';

  @override
  String get details_scene_add_tag => '添加标签';

  @override
  String get details_scene_add_url => '添加 URL';

  @override
  String get details_scene_remove_url => '移除 URL';

  @override
  String get groups_title => '小组';

  @override
  String get groups_unnamed => '未命名小组';

  @override
  String get groups_untitled => '无标题小组';

  @override
  String get studios_title => '制片商';

  @override
  String get studios_galleries_title => '制片商图库';

  @override
  String get studios_media_title => '制片商媒体';

  @override
  String get studios_sort_title => '制片商排序';

  @override
  String get galleries_title => '图库';

  @override
  String get galleries_sort_title => '图库排序';

  @override
  String get galleries_all_images => '所有图片';

  @override
  String get galleries_filter_title => '图库筛选';

  @override
  String get galleries_min_rating => '最低评分';

  @override
  String get galleries_image_count => '图片数量';

  @override
  String get galleries_organization => '整理';

  @override
  String get galleries_organized_only => '仅已整理';

  @override
  String get scenes_filter_title => '筛选场景';

  @override
  String get scenes_filter_saved => '筛选偏好已保存为默认设置';

  @override
  String get scenes_watched => '已看';

  @override
  String get scenes_unwatched => '未看';

  @override
  String get scenes_search_hint => '搜索场景...';

  @override
  String get scenes_sort_header => '排序场景';

  @override
  String get scenes_sort_duration => '时长';

  @override
  String get scenes_sort_bitrate => '比特率';

  @override
  String get scenes_sort_framerate => '帧率';

  @override
  String get scenes_sort_file_count => '文件数量';

  @override
  String get scenes_sort_filesize => '文件大小';

  @override
  String get scenes_sort_resolution => '分辨率';

  @override
  String get scenes_sort_last_played_at => '最后播放时间';

  @override
  String get scenes_sort_resume_time => '恢复时间';

  @override
  String get scenes_sort_play_duration => '播放时长';

  @override
  String get scenes_sort_interactive => '交互式';

  @override
  String get scenes_sort_interactive_speed => '交互速度';

  @override
  String get scenes_sort_perceptual_similarity => '感知相似度';

  @override
  String get scenes_sort_performer_age => '演员年龄';

  @override
  String get scenes_sort_studio => '制片商';

  @override
  String get scenes_sort_path => '路径';

  @override
  String get scenes_sort_file_mod_time => '文件修改时间';

  @override
  String get scenes_sort_tag_count => '标签数量';

  @override
  String get scenes_sort_performer_count => '演员数量';

  @override
  String get scenes_sort_o_counter => 'O计数器';

  @override
  String get scenes_sort_last_o_at => '上次O时间';

  @override
  String get scenes_sort_group_scene_number => '合集/电影场景编号';

  @override
  String get scenes_sort_code => '代码';

  @override
  String get scenes_sort_saved_default => '排序偏好已保存为默认';

  @override
  String get scenes_sort_tooltip => '排序选项';

  @override
  String get tags_search_hint => '搜索标签...';

  @override
  String get tags_sort_tooltip => '排序选项';

  @override
  String get tags_filter_tooltip => '筛选选项';

  @override
  String get performers_title => '演职人员';

  @override
  String get performers_sort_title => '演职人员排序';

  @override
  String get performers_filter_title => '演职人员筛选';

  @override
  String get performers_galleries_title => '所有演职人员图库';

  @override
  String get performers_media_title => '所有演职人员媒体';

  @override
  String get performers_gender => '性别';

  @override
  String get performers_gender_any => '任意';

  @override
  String get performers_gender_female => '女性';

  @override
  String get performers_gender_male => '男性';

  @override
  String get performers_gender_trans_female => '跨性别女性';

  @override
  String get performers_gender_trans_male => '跨性别男性';

  @override
  String get performers_gender_intersex => '双性人';

  @override
  String get performers_gender_non_binary => '非二元';

  @override
  String get performers_circumcised => '割礼';

  @override
  String get performers_circumcised_cut => '已割礼';

  @override
  String get performers_circumcised_uncut => '未割礼';

  @override
  String get performers_play_count => '播放次数';

  @override
  String get performers_field_disambiguation => '消歧义';

  @override
  String get performers_field_birthdate => '出生日期';

  @override
  String get performers_field_deathdate => '死亡日期';

  @override
  String get performers_field_height_cm => '身高（cm）';

  @override
  String get performers_field_weight_kg => '体重（kg）';

  @override
  String get performers_field_measurements => '三围';

  @override
  String get performers_field_fake_tits => '假胸';

  @override
  String get performers_field_penis_length => '阴茎长度';

  @override
  String get performers_field_ethnicity => '族裔';

  @override
  String get performers_field_country => '国家';

  @override
  String get performers_field_eye_color => '眼睛颜色';

  @override
  String get performers_field_hair_color => '头发颜色';

  @override
  String get performers_field_career_start => '职业开始';

  @override
  String get performers_field_career_end => '职业结束';

  @override
  String get performers_field_tattoos => '纹身';

  @override
  String get performers_field_piercings => '穿孔';

  @override
  String get performers_field_aliases => '别名';

  @override
  String get common_organized => '已整理';

  @override
  String get scenes_duplicated => '重复';

  @override
  String get random_studio => '随机制片商';

  @override
  String get random_gallery => '随机图库';

  @override
  String get random_tag => '随机标签';

  @override
  String get random_scene => '随机场景';

  @override
  String get random_performer => '随机出演者';

  @override
  String get filter_modifier => '修饰符';

  @override
  String get filter_group_general => '常规';

  @override
  String get filter_group_performer => '演员';

  @override
  String get filter_group_library => '媒体库';

  @override
  String get filter_group_metadata => '元数据';

  @override
  String get filter_group_media_info => '媒体信息';

  @override
  String get filter_group_usage => '使用情况';

  @override
  String get filter_group_system => '系统';

  @override
  String get filter_group_physical => '物理';

  @override
  String get filter_equals => '等于';

  @override
  String get filter_not_equals => '不等于';

  @override
  String get filter_greater_than => '大于';

  @override
  String get filter_less_than => '小于';

  @override
  String get filter_includes => '包括';

  @override
  String get filter_excludes => '不包括';

  @override
  String get filter_includes_all => '包括全部';

  @override
  String get filter_is_null => '为空';

  @override
  String get filter_not_null => '不为空';

  @override
  String get filter_matches_regex => '匹配正则表达式';

  @override
  String get filter_not_matches_regex => '与正则表达式不匹配';

  @override
  String get filter_between => '之间';

  @override
  String get filter_not_between => '不在之间';

  @override
  String get filter_value_secondary => '第二个值';

  @override
  String get images_resolution_title => '分辨率';

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
  String get images_orientation_title => '方向';

  @override
  String get common_or => '或';

  @override
  String get scrape_from_url => '从 URL 抓取';

  @override
  String get scenes_phash_started => '开始生成 phash';

  @override
  String scenes_phash_failed(Object error) {
    return '生成 phash 失败：$error';
  }

  @override
  String details_failed_update_studio(Object error) {
    return '更新工作室失败：$error';
  }

  @override
  String get settings_title => '设置';

  @override
  String get settings_customize => '自定义 StashFlow';

  @override
  String get settings_customize_subtitle => '集中调整播放、外观、布局和支持工具。';

  @override
  String get settings_core_section => '核心设置';

  @override
  String get settings_core_subtitle => '最常用的配置页面';

  @override
  String get settings_server => '服务器';

  @override
  String get settings_server_subtitle => '连接和 API 配置';

  @override
  String get settings_playback => '播放';

  @override
  String get settings_playback_subtitle => '播放器行为和交互';

  @override
  String get settings_keyboard => '键盘';

  @override
  String get settings_keyboard_subtitle => '可自定义的快捷键';

  @override
  String get settings_keyboard_title => '键盘快捷键';

  @override
  String get settings_keyboard_reset_defaults => '重置为默认值';

  @override
  String get settings_keyboard_not_bound => '未绑定';

  @override
  String get settings_keyboard_volume_up => '提高音量';

  @override
  String get settings_keyboard_volume_down => '降低音量';

  @override
  String get settings_keyboard_toggle_mute => '切换静音';

  @override
  String get settings_keyboard_toggle_fullscreen => '切换全屏';

  @override
  String get settings_keyboard_next_scene => '下一个场景';

  @override
  String get settings_keyboard_prev_scene => '上一个场景';

  @override
  String get settings_keyboard_increase_speed => '提高播放速度';

  @override
  String get settings_keyboard_decrease_speed => '降低播放速度';

  @override
  String get settings_keyboard_reset_speed => '重置播放速度';

  @override
  String get settings_keyboard_close_player => '关闭播放器';

  @override
  String get settings_keyboard_next_image => '下一张图片';

  @override
  String get settings_keyboard_prev_image => '上一张图片';

  @override
  String get settings_keyboard_go_back => '返回';

  @override
  String get settings_keyboard_play_pause_desc => '在播放和暂停视频之间切换';

  @override
  String get settings_keyboard_seek_forward_5_desc => '快进 5 秒';

  @override
  String get settings_keyboard_seek_backward_5_desc => '快退 5 秒';

  @override
  String get settings_keyboard_seek_forward_10_desc => '快进 10 秒';

  @override
  String get settings_keyboard_seek_backward_10_desc => '快退 10 秒';

  @override
  String get settings_appearance => '外观';

  @override
  String get settings_appearance_subtitle => '主题和颜色';

  @override
  String get settings_interface => '界面';

  @override
  String get settings_interface_subtitle => '导航和布局默认值';

  @override
  String get settings_support => '支持';

  @override
  String get settings_support_subtitle => '诊断与关于';

  @override
  String get settings_develop => '开发';

  @override
  String get settings_develop_subtitle => '高级工具和覆盖';

  @override
  String get settings_appearance_title => '外观设置';

  @override
  String get settings_appearance_theme_mode => '主题模式';

  @override
  String get settings_appearance_theme_mode_subtitle => '选择应用如何跟随亮度变化';

  @override
  String get settings_appearance_theme_system => '系统默认';

  @override
  String get settings_appearance_theme_light => '浅色';

  @override
  String get settings_appearance_theme_dark => '深色';

  @override
  String get settings_appearance_primary_color => '主色调';

  @override
  String get settings_appearance_primary_color_subtitle =>
      '为 Material 3 调色板选择种子颜色';

  @override
  String get settings_appearance_advanced_theming => '高级主题';

  @override
  String get settings_appearance_advanced_theming_subtitle => '针对特定屏幕类型的优化';

  @override
  String get settings_appearance_true_black => '纯黑 (AMOLED)';

  @override
  String get settings_appearance_true_black_subtitle =>
      '在深色模式下使用纯黑背景以节省 OLED 屏幕电量';

  @override
  String get settings_appearance_custom_hex => '自定义 Hex 颜色';

  @override
  String get settings_appearance_custom_hex_helper => '输入 8 位 ARGB hex 代码';

  @override
  String get settings_appearance_font_size => '全球用户界面规模';

  @override
  String get settings_appearance_font_size_subtitle => '按比例缩放版式和间距';

  @override
  String get settings_interface_title => '界面设置';

  @override
  String get settings_interface_language => '语言';

  @override
  String get settings_interface_language_subtitle => '覆盖默认系统语言';

  @override
  String get settings_interface_app_language => '应用语言';

  @override
  String get settings_interface_navigation => '导航';

  @override
  String get settings_interface_navigation_subtitle => '全局导航快捷方式的可见性';

  @override
  String get settings_interface_show_random => '显示随机导航按钮';

  @override
  String get settings_interface_show_random_subtitle => '在列表和详情页启用或禁用悬浮随机按钮';

  @override
  String get settings_interface_hide_scene_metadata => '默认隐藏场景元数据';

  @override
  String get settings_interface_hide_scene_metadata_subtitle =>
      '点击“显示元数据”后才显示场景技术元数据。';

  @override
  String get settings_interface_random_scene_filter => '随机场景遵循当前筛选条件';

  @override
  String get settings_interface_random_scene_filter_subtitle =>
      '启用后，随机场景导航会使用当前场景筛选条件。';

  @override
  String get settings_interface_main_pages_gravity_orientation =>
      '重力控制的方向（主页面）';

  @override
  String get settings_interface_main_pages_gravity_orientation_subtitle =>
      '允许主页面使用设备传感器旋转。全屏视频播放将使用其自己的方向设置。';

  @override
  String get settings_interface_show_edit => '显示编辑按钮';

  @override
  String get settings_interface_show_edit_subtitle => '在场景详情页启用或禁用编辑按钮';

  @override
  String get settings_interface_use_actual_scene_video_miniplayer =>
      '在迷你播放器中使用实际场景视频';

  @override
  String get settings_interface_use_actual_scene_video_miniplayer_subtitle =>
      '播放时显示实时场景视频画面，而不是场景截图。';

  @override
  String get details_show_metadata => '显示元数据';

  @override
  String get settings_interface_entity_image_filtering => '实体图像过滤';

  @override
  String get settings_interface_entity_image_filtering_subtitle =>
      '选择实体图像页面是匹配图像元数据还是关联图库。';

  @override
  String get settings_interface_entity_image_filtering_direct => '直接实体';

  @override
  String get settings_interface_entity_image_filtering_galleries => '关联图库';

  @override
  String get settings_interface_customize_tabs => '自定义标签页';

  @override
  String get settings_interface_customize_tabs_subtitle => '重新排序或隐藏导航菜单项';

  @override
  String get settings_interface_scenes_layout => '场景布局';

  @override
  String get settings_interface_scenes_layout_subtitle => '场景的默认浏览模式';

  @override
  String get settings_interface_galleries_layout => '图库布局';

  @override
  String get settings_interface_galleries_layout_subtitle => '图库的默认浏览模式';

  @override
  String get settings_interface_max_performer_avatars => '最多出演者头像';

  @override
  String get settings_interface_max_performer_avatars_subtitle =>
      '在场景卡上显示的出演者头像的最大数量。';

  @override
  String get settings_interface_show_performer_avatars => '显示出演者头像';

  @override
  String get settings_interface_show_performer_avatars_subtitle =>
      '在所有平台的场景卡上显示出演者图标。';

  @override
  String get settings_interface_performer_avatar_size => '出演者头像大小';

  @override
  String get settings_interface_layout_default => '默认布局';

  @override
  String get settings_interface_layout_default_desc => '选择页面的默认布局';

  @override
  String get settings_interface_layout_list => '列表';

  @override
  String get settings_interface_layout_grid => '网格';

  @override
  String get settings_interface_layout_tiktok => '无限滚动';

  @override
  String get settings_interface_grid_columns => '网格列数';

  @override
  String get settings_interface_image_viewer => '图片查看器';

  @override
  String get settings_interface_image_viewer_subtitle => '配置全屏图片浏览行为';

  @override
  String get settings_interface_swipe_direction => '全屏滑动方向';

  @override
  String get settings_interface_swipe_direction_desc => '选择全屏模式下图片的切换方式';

  @override
  String get settings_interface_swipe_vertical => '垂直';

  @override
  String get settings_interface_swipe_horizontal => '水平';

  @override
  String get settings_interface_waterfall_columns => '瀑布流网格列数';

  @override
  String get settings_interface_performer_layouts => '演职人员布局';

  @override
  String get settings_interface_performer_layouts_subtitle => '演职人员的媒体和图库默认设置';

  @override
  String get settings_interface_studio_layouts => '制片商布局';

  @override
  String get settings_interface_studio_layouts_subtitle => '制片商的媒体和图库默认设置';

  @override
  String get settings_interface_tag_layouts => '标签布局';

  @override
  String get settings_interface_tag_layouts_subtitle => '标签的媒体和图库默认设置';

  @override
  String get settings_interface_media_layout => '媒体布局';

  @override
  String get settings_interface_media_layout_subtitle => '媒体页面的布局';

  @override
  String get settings_interface_galleries_layout_item => '图库布局';

  @override
  String get settings_interface_galleries_layout_subtitle_item => '图库页面的布局';

  @override
  String get settings_server_title => '服务器设置';

  @override
  String get settings_server_status => '连接状态';

  @override
  String get settings_server_status_subtitle => '与配置服务器的实时连接状态';

  @override
  String get settings_server_details => '服务器详情';

  @override
  String get settings_server_details_subtitle => '配置端点和身份验证方式';

  @override
  String get settings_server_url => 'Stash 地址';

  @override
  String get settings_server_url_helper =>
      '输入 Stash 服务器的 URL。如果配置了自定义路径，请在此处包含它。';

  @override
  String get settings_server_url_example => 'http://192.168.1.100:9999';

  @override
  String get settings_server_login_failed => '登录失败';

  @override
  String get settings_server_auth_method => '身份验证方式';

  @override
  String get settings_server_auth_apikey => 'API 密钥';

  @override
  String get settings_server_auth_password => '用户名 + 密码';

  @override
  String get settings_server_auth_password_desc => '推荐：使用您的 Stash 用户名/密码会话。';

  @override
  String get settings_server_auth_apikey_desc => '使用 API 密钥进行静态令牌身份验证。';

  @override
  String get settings_server_username => '用户名';

  @override
  String get settings_server_password => '密码';

  @override
  String get settings_server_login_test => '登录并测试';

  @override
  String get settings_server_test => '测试连接';

  @override
  String get settings_server_logout => '退出登录';

  @override
  String get settings_server_clear => '清除设置';

  @override
  String settings_server_connected(String version) {
    return '已连接 (Stash $version)';
  }

  @override
  String get settings_server_checking => '正在检查连接...';

  @override
  String settings_server_failed(String error) {
    return '失败：$error';
  }

  @override
  String get settings_server_invalid_url => '无效的服务器 URL';

  @override
  String get settings_server_resolve_error => '无法解析服务器 URL。请检查主机、端口和凭据。';

  @override
  String get settings_server_logout_confirm => '已退出登录并清除 Cookie。';

  @override
  String get settings_server_profile_add => '添加配置文件';

  @override
  String get settings_server_profile_edit => '编辑配置文件';

  @override
  String get settings_server_profile_name => '配置文件名称';

  @override
  String get settings_server_profile_delete => '删除配置文件';

  @override
  String get settings_server_profile_delete_confirm => '您确定要删除此配置文件吗？此操作无法撤消。';

  @override
  String get settings_server_profile_active => '激活';

  @override
  String get settings_server_profile_empty => '未配置服务器配置文件';

  @override
  String get settings_server_profiles => '服务器配置文件';

  @override
  String get settings_server_profiles_subtitle => '管理多个 Stash 服务器连接';

  @override
  String get settings_server_auth_status_logging_in => '身份验证状态：正在登录...';

  @override
  String get settings_server_auth_status_logged_in => '身份验证状态：已登录';

  @override
  String get settings_server_auth_status_logged_out => '身份验证状态：已登出';

  @override
  String get settings_playback_title => '播放设置';

  @override
  String get settings_playback_behavior => '播放行为';

  @override
  String get settings_playback_behavior_subtitle => '默认播放和后台处理';

  @override
  String get settings_playback_prefer_streams => '优先使用 sceneStreams';

  @override
  String get settings_playback_prefer_streams_subtitle =>
      '关闭时，播放将直接使用 paths.stream';

  @override
  String get settings_playback_feed_random => '从随机位置开始播放Feed';

  @override
  String get settings_playback_feed_random_subtitle =>
      '在Feed模式下播放场景时，从视频长度的0%到90%之间的随机位置开始播放';

  @override
  String get settings_playback_resume_position => '从上次播放位置恢复';

  @override
  String get settings_playback_resume_position_subtitle =>
      '打开视频时，自动从上次中断的地方继续播放';

  @override
  String get settings_playback_end_behavior => '播放结束行为';

  @override
  String get settings_playback_end_behavior_subtitle => '当前视频播放结束时的操作';

  @override
  String get settings_playback_end_behavior_stop => '停止';

  @override
  String get settings_playback_end_behavior_loop => '循环播放当前场景';

  @override
  String get settings_playback_end_behavior_next => '播放下一个场景';

  @override
  String get settings_playback_autoplay => '自动播放下一个场景';

  @override
  String get settings_playback_autoplay_subtitle => '当前播放结束时自动播放下一个场景';

  @override
  String get settings_playback_background => '后台播放';

  @override
  String get settings_playback_background_subtitle => '应用在后台时继续播放视频音频';

  @override
  String get settings_playback_pip => '原生画中画';

  @override
  String get settings_playback_pip_subtitle => '启用 Android 画中画按钮并在进入后台时自动进入';

  @override
  String get settings_playback_subtitles => '字幕设置';

  @override
  String get settings_playback_subtitles_subtitle => '自动加载和外观';

  @override
  String get settings_playback_subtitle_lang => '默认字幕语言';

  @override
  String get settings_playback_subtitle_lang_subtitle => '如果可用则自动加载';

  @override
  String get settings_playback_subtitle_size => '字幕字体大小';

  @override
  String get settings_playback_subtitle_pos => '字幕垂直位置';

  @override
  String settings_playback_subtitle_pos_desc(String percent) {
    return '距离底部 $percent%';
  }

  @override
  String get settings_playback_subtitle_align => '字幕文本对齐';

  @override
  String get settings_playback_subtitle_align_subtitle => '多行字幕的对齐方式';

  @override
  String get settings_playback_seek => '快进/快退交互';

  @override
  String get settings_playback_seek_subtitle => '选择播放期间的进度条拖动方式';

  @override
  String get settings_playback_seek_double_tap => '双击左/右侧快进/快退 10 秒';

  @override
  String get settings_playback_seek_drag => '拖动时间轴进行快进/快退';

  @override
  String get settings_playback_seek_drag_label => '拖动';

  @override
  String get settings_playback_seek_double_tap_label => '双击';

  @override
  String get settings_playback_gravity_orientation => '重力控制的方向';

  @override
  String get settings_playback_direct_play => '切换场景时直接播放';

  @override
  String get settings_playback_direct_play_subtitle =>
      '从另一个正在播放的场景切换过来时，直接播放新场景';

  @override
  String get settings_playback_gravity_orientation_subtitle =>
      '允许使用设备传感器在匹配的方向之间旋转（例如：左右翻转横向）。';

  @override
  String get settings_playback_subtitle_lang_none_disabled => '无（禁用）';

  @override
  String get settings_playback_subtitle_lang_auto_if_only_one => '自动（仅有一个时）';

  @override
  String get settings_playback_subtitle_lang_english => '英语';

  @override
  String get settings_playback_subtitle_lang_chinese => '中文';

  @override
  String get settings_playback_subtitle_lang_german => '德语';

  @override
  String get settings_playback_subtitle_lang_french => '法语';

  @override
  String get settings_playback_subtitle_lang_spanish => '西班牙语';

  @override
  String get settings_playback_subtitle_lang_italian => '意大利语';

  @override
  String get settings_playback_subtitle_lang_japanese => '日语';

  @override
  String get settings_playback_subtitle_lang_korean => '韩语';

  @override
  String get settings_playback_subtitle_align_left => '左对齐';

  @override
  String get settings_playback_subtitle_align_center => '居中';

  @override
  String get settings_playback_subtitle_align_right => '右对齐';

  @override
  String get settings_support_title => '支持';

  @override
  String get settings_support_diagnostics => '诊断和项目信息';

  @override
  String get settings_support_diagnostics_subtitle => '在需要帮助时打开运行日志或跳转到存储库。';

  @override
  String get settings_support_update_available => '有可用更新';

  @override
  String get settings_support_update_available_subtitle => 'GitHub 上有新版本可用';

  @override
  String settings_support_update_to(String version) {
    return '更新至 $version';
  }

  @override
  String get settings_support_update_to_subtitle => '新功能和改进正等着您。';

  @override
  String get settings_support_about => '关于';

  @override
  String get settings_support_about_subtitle => '项目和源代码信息';

  @override
  String get settings_support_version => '版本';

  @override
  String get settings_support_version_loading => '正在加载版本信息...';

  @override
  String get settings_support_version_unavailable => '版本信息不可用';

  @override
  String get settings_support_github => 'GitHub 存储库';

  @override
  String get settings_support_github_subtitle => '查看源代码并报告问题';

  @override
  String get settings_support_github_error => '无法打开 GitHub 链接';

  @override
  String get settings_support_issues => '报告问题';

  @override
  String get settings_support_issues_subtitle => '通过报告错误帮助改进 StashFlow';

  @override
  String get settings_develop_title => '开发';

  @override
  String get settings_develop_enable_logging => '启用调试日志';

  @override
  String get settings_develop_enable_logging_subtitle => '记录应用日志以供排查问题';

  @override
  String get settings_develop_diagnostics => '诊断工具';

  @override
  String get settings_develop_diagnostics_subtitle => '故障排除和性能';

  @override
  String get settings_develop_video_debug => '显示视频调试信息';

  @override
  String get settings_develop_video_debug_subtitle => '在视频播放器上以叠加层形式显示技术播放详情。';

  @override
  String get settings_develop_log_viewer => '调试日志查看器';

  @override
  String get settings_develop_log_viewer_subtitle => '打开应用内日志的实时视图。';

  @override
  String get settings_develop_logs_copied => '日志已复制到剪贴板';

  @override
  String get settings_develop_no_logs => '尚无日志。与应用交互以捕获日志。';

  @override
  String get settings_develop_web_overrides => 'Web 覆盖';

  @override
  String get settings_develop_web_overrides_subtitle => 'Web 平台的高级标志';

  @override
  String get settings_develop_web_auth => '允许在 Web 上使用密码登录';

  @override
  String get settings_develop_web_auth_subtitle =>
      '覆盖仅限原生的限制，并强制用户名 + 密码身份验证方式在 Flutter Web 上可见。';

  @override
  String get settings_develop_proxy_auth => '启用代理认证模式';

  @override
  String get settings_develop_proxy_auth_subtitle =>
      '启用高级 Basic Auth 和 Bearer Token 方法，以便在 Authentik 等代理背后的无认证后端中使用。';

  @override
  String get settings_server_auth_basic => '基础认证';

  @override
  String get settings_server_auth_bearer => 'Bearer 令牌';

  @override
  String get settings_server_auth_basic_desc =>
      '发送 \'Authorization: Basic <base64(user:pass)>\' 请求头。';

  @override
  String get settings_server_auth_bearer_desc =>
      '发送 \'Authorization: Bearer <token>\' 请求头。';

  @override
  String get common_edit => '编辑';

  @override
  String get common_resolution => '分辨率';

  @override
  String get common_orientation => '方向';

  @override
  String get common_landscape => '横向';

  @override
  String get common_portrait => '纵向';

  @override
  String get common_square => '正方形';

  @override
  String get performers_filter_saved => '筛选首选项已保存为默认值';

  @override
  String get images_title => '图片';

  @override
  String get images_filter_title => '过滤图片';

  @override
  String get images_filter_saved => '筛选偏好已保存为默认设置';

  @override
  String get images_sort_title => '对图片排序';

  @override
  String get images_sort_saved => '排序首选项已保存为默认值';

  @override
  String get image_rating_updated => '图片评分已更新。';

  @override
  String get gallery_rating_updated => '图库评分已更新。';

  @override
  String get common_image => '图片';

  @override
  String get common_gallery => '图库';

  @override
  String get images_gallery_rating_unavailable => '图库评分仅在浏览图库时可用。';

  @override
  String images_rating(String rating) {
    return '评分：$rating / 5';
  }

  @override
  String get images_filtered_by_gallery => '按画廊筛选';

  @override
  String get images_slideshow_need_two => '幻灯片放映至少需要 2 张图片。';

  @override
  String get images_slideshow_start_title => '开始幻灯片放映';

  @override
  String images_slideshow_interval(num seconds) {
    return '间隔：${seconds}s';
  }

  @override
  String images_slideshow_transition_ms(num ms) {
    return '过渡：${ms}ms';
  }

  @override
  String get common_forward => '前进';

  @override
  String get common_backward => '后退';

  @override
  String get images_slideshow_loop_title => '循环幻灯片放映';

  @override
  String get common_cancel => '取消';

  @override
  String get common_start => '开始';

  @override
  String get common_done => '完成';

  @override
  String get settings_keybind_assign_shortcut => '分配快捷键';

  @override
  String get settings_keybind_press_any => '按任意键组合...';

  @override
  String get scenes_select_tags => '选择标签';

  @override
  String get scenes_no_scrapers => '没有可用的抓取器';

  @override
  String get scenes_select_scraper => '选择抓取器';

  @override
  String get scenes_no_results_found => '未找到结果';

  @override
  String get scenes_select_result => '选择结果';

  @override
  String scenes_scrape_failed(String error) {
    return '抓取失败：$error';
  }

  @override
  String get scenes_updated_successfully => '场景更新成功';

  @override
  String scenes_update_failed(String error) {
    return '场景更新失败：$error';
  }

  @override
  String get scenes_edit_title => '编辑场景';

  @override
  String get scenes_field_studio => '制片商';

  @override
  String get scenes_field_tags => '标签';

  @override
  String get scenes_field_urls => '链接';

  @override
  String get scenes_edit_performer => '编辑演员';

  @override
  String get scenes_edit_studio => '编辑工作室';

  @override
  String get common_no_title => '无标题';

  @override
  String get scenes_select_studio => '选择制片商';

  @override
  String get scenes_select_performers => '选择出演者';

  @override
  String get scenes_unmatched_scraped_tags => '未匹配的抓取标签';

  @override
  String get scenes_unmatched_scraped_performers => '未匹配的抓取出演者';

  @override
  String get scenes_no_matching_performer_found => '在库中未找到匹配的出演者';

  @override
  String get common_unknown => '未知';

  @override
  String scenes_studio_id_prefix(String id) {
    return '制片商 ID：$id';
  }

  @override
  String get tags_search_placeholder => '搜索标签...';

  @override
  String get scenes_duration_short => '< 5分钟';

  @override
  String get scenes_duration_medium => '5-20分钟';

  @override
  String get scenes_duration_long => '> 20分钟';

  @override
  String get details_scene_fingerprint_query => '场景指纹查询';

  @override
  String get scenes_available_scrapers => '可用抓取器';

  @override
  String get scrape_results_existing => '已存在';

  @override
  String get scrape_results_scraped => '已抓取';

  @override
  String get stats_refresh_statistics => '刷新统计数据';

  @override
  String get stats_library_stats => '图书馆统计';

  @override
  String get stats_stash_glance => '您的藏品一目了然';

  @override
  String get stats_content => '内容';

  @override
  String get stats_organization => '组织';

  @override
  String get stats_activity => '活动';

  @override
  String get stats_scenes => '场景';

  @override
  String get stats_galleries => '画廊';

  @override
  String get stats_performers => '表演者';

  @override
  String get stats_studios => '工作室';

  @override
  String get stats_groups => '团体';

  @override
  String get stats_tags => '标签';

  @override
  String get stats_total_plays => '总播放次数';

  @override
  String stats_unique_items(int count) {
    return '$count 个唯一项目';
  }

  @override
  String get stats_total_o_count => '总 O 计数';

  @override
  String get cast_airplay_pairing => '隔空播放配对';

  @override
  String get cast_enter_pin => '输入电视上显示的 4 位 PIN 码';

  @override
  String get cast_pair => '一对';

  @override
  String cast_connecting_to(String deviceName) {
    return '正在连接到 $deviceName...';
  }

  @override
  String cast_casting_to(String deviceName) {
    return '正在投放到 $deviceName';
  }

  @override
  String cast_pairing_failed(String error) {
    return '配对失败：$error';
  }

  @override
  String cast_failed_to_cast(String error) {
    return '投放失败：$error';
  }

  @override
  String get cast_searching => '正在搜索设备...';

  @override
  String get cast_cast_to_device => '投射到设备';

  @override
  String get settings_storage_images => '图片';

  @override
  String get settings_storage_videos => '视频';

  @override
  String get settings_storage_database => '数据库';

  @override
  String get settings_storage_clearing_image => '正在清除图像缓存...';

  @override
  String get settings_storage_clearing_video => '清除视频缓存...';

  @override
  String get settings_storage_clearing_database => '清除数据库缓存...';

  @override
  String get settings_storage_cleared_image => '图像缓存已清除';

  @override
  String get settings_storage_cleared_video => '视频缓存已清除';

  @override
  String get settings_storage_cleared_database => '数据库缓存已清除';

  @override
  String get settings_storage_clear => '清除';

  @override
  String get settings_storage_error_loading => '加载尺寸时出错';

  @override
  String settings_storage_mb(num value) {
    return '$value MB';
  }

  @override
  String settings_storage_gb(num value) {
    return '$value GB';
  }

  @override
  String get settings_storage_100_mb => '100MB';

  @override
  String get settings_storage_500_mb => '500MB';

  @override
  String get settings_storage_1_gb => '1GB';

  @override
  String get settings_storage_2_gb => '2GB';

  @override
  String get settings_storage_unlimited => '无限';

  @override
  String get settings_storage_limits => '限制';

  @override
  String get settings_storage_limits_subtitle => '设置最大缓存大小';

  @override
  String get settings_storage_max_image_cache => '最大图像缓存 (MB)';

  @override
  String get settings_storage_max_video_cache => '最大视频缓存 (MB)';

  @override
  String get settings_storage => '存储与缓存';

  @override
  String get settings_storage_usage => '存储占用';

  @override
  String get settings_storage_usage_subtitle => '当前缓存占用空间';

  @override
  String get settings_storage_subtitle => '管理本地缓存和存储限制';

  @override
  String get performers_field_name => '姓名';

  @override
  String get performers_field_url => 'URL';

  @override
  String get performers_field_details => '详情';

  @override
  String get performers_field_birth_year => '出生年份';

  @override
  String get performers_field_age => '年龄';

  @override
  String get performers_field_death_year => '去世年份';

  @override
  String get performers_field_scene_count => '场景数';

  @override
  String get performers_field_image_count => '图片数';

  @override
  String get performers_field_gallery_count => '图库数';

  @override
  String get performers_field_play_count => '播放次数';

  @override
  String get performers_field_o_counter => 'O-计数器';

  @override
  String get performers_field_tag_count => '标签数';

  @override
  String get performers_field_created_at => '创建于';

  @override
  String get performers_field_updated_at => '更新于';

  @override
  String get galleries_field_title => '标题';

  @override
  String get galleries_field_details => '详情';

  @override
  String get galleries_field_date => '日期';

  @override
  String get galleries_field_performer_age => '演出者年龄';

  @override
  String get galleries_field_performer_count => '演出者人数';

  @override
  String get galleries_field_tag_count => '标签数';

  @override
  String get galleries_field_url => 'URL';

  @override
  String get galleries_field_id => 'ID';

  @override
  String get galleries_field_path => '路径';

  @override
  String get galleries_field_checksum => '校验和';

  @override
  String get galleries_field_image_count => '图片数';

  @override
  String get galleries_field_file_count => '文件数';

  @override
  String get galleries_field_created_at => '创建于';

  @override
  String get galleries_field_updated_at => '更新于';

  @override
  String get images_field_title => '标题';

  @override
  String get images_field_details => '详情';

  @override
  String get images_field_path => '路径';

  @override
  String get images_field_url => 'URL';

  @override
  String get images_field_file_count => '文件数';

  @override
  String get images_field_o_counter => 'O-计数器';

  @override
  String get studios_field_name => '名称';

  @override
  String get studios_field_details => '详情';

  @override
  String get studios_field_aliases => '别名';

  @override
  String get studios_field_url => 'URL';

  @override
  String get studios_field_tag_count => '标签数';

  @override
  String get studios_field_scene_count => '场景数';

  @override
  String get studios_field_image_count => '图片数';

  @override
  String get studios_field_gallery_count => '图库数';

  @override
  String get studios_field_sub_studio_count => '子工作室数';

  @override
  String get studios_field_created_at => '创建于';

  @override
  String get studios_field_updated_at => '更新于';

  @override
  String get scenes_field_performer_age => '演出者年龄';

  @override
  String get scenes_field_performer_count => '演出者人数';

  @override
  String get scenes_field_tag_count => '标签数';

  @override
  String get scenes_field_code => '代码';

  @override
  String get scenes_field_details => '详情';

  @override
  String get scenes_field_director => '导演';

  @override
  String get scenes_field_url => 'URL';

  @override
  String get scenes_field_date => '日期';

  @override
  String get scenes_field_path => '路径';

  @override
  String get scenes_field_captions => '字幕';

  @override
  String get scenes_field_duration => '时长（秒）';

  @override
  String get scenes_field_bitrate => '比特率';

  @override
  String get scenes_field_video_codec => '视频编码';

  @override
  String get scenes_field_audio_codec => '音频编码';

  @override
  String get scenes_field_framerate => '帧率';

  @override
  String get scenes_field_file_count => '文件数';

  @override
  String get scenes_field_play_count => '播放次数';

  @override
  String get scenes_field_play_duration => '播放时长';

  @override
  String get scenes_field_o_counter => 'O-计数器';

  @override
  String get scenes_field_last_played_at => '最后播放于';

  @override
  String get scenes_field_resume_time => '恢复时间';

  @override
  String get scenes_field_interactive_speed => '交互速度';

  @override
  String get scenes_field_id => 'ID';

  @override
  String get scenes_field_stash_id_count => 'Stash ID 数量';

  @override
  String get scenes_field_oshash => 'Oshash';

  @override
  String get scenes_field_checksum => '校验和';

  @override
  String get scenes_field_phash => 'Phash';

  @override
  String get scenes_field_created_at => '创建于';

  @override
  String get scenes_field_updated_at => '更新于';

  @override
  String get cast_stopped_resuming_locally => '投放已停止，在本地恢复播放';

  @override
  String get cast_stop_casting => '停止投放';

  @override
  String get cast_cast => '投放';

  @override
  String get common_add => '添加';

  @override
  String get common_remove => '移除';

  @override
  String get common_clear => '清除';

  @override
  String get common_download => '下载';

  @override
  String get common_star => '收藏';

  @override
  String get settings_interface_card_title_font_size => '卡片标题字体大小';

  @override
  String get common_hint_date => 'YYYY-MM-DD';

  @override
  String get common_hint_url => 'https://...';

  @override
  String get common_hint_hex => 'FF0F766E';

  @override
  String common_px(int value) {
    return '$value 像素';
  }

  @override
  String common_pt(int value) {
    return '$value 点';
  }

  @override
  String common_percent(int value) {
    return '$value%';
  }

  @override
  String get saving_video => '正在保存到相册...';

  @override
  String get saved_to_album => '已保存到 StashFlow 相册';

  @override
  String gallery_error(String message) {
    return '相册错误: $message';
  }

  @override
  String failed_to_save(String error) {
    return '保存失败: $error';
  }

  @override
  String get saving_image => '正在保存图片...';

  @override
  String common_select(String label) {
    return '选择 $label';
  }

  @override
  String common_saved_to(String path) {
    return '保存至 $path';
  }

  @override
  String get recent_searches => '最近搜索';

  @override
  String get initializing_player => '正在初始化播放器...';

  @override
  String get sort_scenes => '排序场景';

  @override
  String get failed_to_load_tap_to_retry => '加载失败。点击重试。';

  @override
  String get would_you_like_to_visit_the_release_page_to_download_it =>
      '您想访问发布页面下载吗？';

  @override
  String get to_get_started_configure_stash_server =>
      '要开始使用，您需要配置您的 Stash 服务器连接详细信息。';

  @override
  String get loading => '加载中';

  @override
  String get wip => 'WIP';

  @override
  String get performer_filters => '演员筛选';

  @override
  String update_available(String version) {
    return 'StashFlow的更新版本 ($version) 已经发布。';
  }

  @override
  String details_failed_update_favorite(String error) {
    return '更新收藏失败: $error';
  }

  @override
  String details_failed_load_galleries(String error) {
    return '加载图库失败: $error';
  }

  @override
  String get scene_info_id => '场景ID';

  @override
  String get scene_info_original_file_path => '原始文件路径';

  @override
  String get scene_info_resume_time => '恢复时间';

  @override
  String get scene_info_play_duration => '播放时长';

  @override
  String get scene_info_urls => '网址';

  @override
  String get scene_info_resolution => '解决';

  @override
  String get scene_info_bitrate => '比特率';

  @override
  String get scene_info_frame_rate => '帧率';

  @override
  String get scene_info_format => '格式';

  @override
  String get scene_info_video_codec => '视频编解码器';

  @override
  String get scene_info_audio_codec => '音频编解码器';

  @override
  String get scene_info_stream => '溪流';

  @override
  String get scene_info_preview => '预览';

  @override
  String get scene_info_screenshot => '截屏';

  @override
  String get scene_info_cover => '封面';

  @override
  String get scene_info_caption => '标题';

  @override
  String get scene_info_vtt => '视听测试';

  @override
  String get scene_info_sprite => '雪碧';

  @override
  String get scene_info_technical => '技术的';

  @override
  String scene_studio_id(String id) {
    return 'ID：$id';
  }

  @override
  String scene_rating_stars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 星星',
      one: '1 星',
    );
    return '$_temp0';
  }

  @override
  String get main_startup_failed => 'StashFlow 启动失败';

  @override
  String get main_startup_failed_desc => '在应用程序完成初始化之前启动服务失败。检查诊断后重新启动应用程序。';

  @override
  String common_searching_for(String query) {
    return '正在搜索：“$query”';
  }

  @override
  String get cast_device => '设备';

  @override
  String get auth_enter_passcode => '输入您的密码以继续。';

  @override
  String get auth_unlock => '开锁';

  @override
  String get auth_incorrect_passcode => '密码不正确';

  @override
  String get auth_app_locked => '应用程序已锁定';

  @override
  String get settings_security_passcode => '密码';

  @override
  String get settings_security_passcode_configured => '已配置';

  @override
  String get settings_security_passcode_not_configured => '未配置';

  @override
  String get settings_security_passcode_saved => '密码已保存';

  @override
  String get settings_security_passcode_removed => '密码已删除';

  @override
  String get settings_security_enable_app_lock => '启用应用程序锁定';

  @override
  String get settings_security_enable_app_lock_subtitle => '应用程序恢复/启动时需要密码。';

  @override
  String get settings_security_lock_on_launch => '锁定应用程序启动';

  @override
  String get settings_security_lock_on_launch_subtitle => '应用程序打开时立即询问密码。';

  @override
  String get settings_security_background_lock_timer => '后台锁定定时器';

  @override
  String get settings_security_background_lock_timer_subtitle =>
      '应用程序在锁定之前可以在后台停留多长时间。';

  @override
  String get settings_security_set_passcode => '设置密码';

  @override
  String get settings_security_passcode_prompt => '密码（4-8位）';

  @override
  String get settings_security_confirm_passcode => '确认';

  @override
  String get settings_security_error_numeric => '仅使用数字，长度为 4-8。';

  @override
  String get settings_security_error_mismatch => '密码不匹配。';

  @override
  String get common_change => '改变';

  @override
  String get common_set => '设置';

  @override
  String get common_immediately => '立即地';

  @override
  String common_sec(int value) {
    return '$value 秒';
  }

  @override
  String common_min(int value) {
    return '$value 分钟';
  }

  @override
  String common_s(int value) {
    return '${value}s';
  }

  @override
  String get settings_security_title => '安全';

  @override
  String get settings_security_subtitle => '应用锁和密码设置';

  @override
  String get settings_security_app_lock => '应用锁';

  @override
  String get settings_security_app_lock_subtitle => '后台运行后使用密码保护访问。';

  @override
  String get common_saved_filters => '已保存的过滤器';

  @override
  String get tools => '工具';

  @override
  String get tools_section_subtitle => '场景的维护和元数据工作流。';

  @override
  String get tools_scene_deduplication_subtitle => '查找并管理重复场景。';

  @override
  String get tools_scene_tagger_subtitle => '使用 Stash-box 刮削当前场景页面。';

  @override
  String get preset_deleted => '预设已删除';

  @override
  String get delete_preset => '删除预设';

  @override
  String get common_delete => '删除';

  @override
  String get save_preset => '保存预设';

  @override
  String get no_saved_presets => '没有保存的预设';

  @override
  String get scene_tagger => '场景标注';

  @override
  String get page_size => '每页数量';

  @override
  String get mode => '模式';

  @override
  String get sort => '排序';

  @override
  String get desc => '降序';

  @override
  String get asc => '升序';

  @override
  String get filter => '筛选';

  @override
  String get load_preset => '加载预设';

  @override
  String get preset => '预设';

  @override
  String get stash_box_scraper => 'Stash Box 抓取器';

  @override
  String get start_tagging => '开始标注';

  @override
  String get stop => '停止';

  @override
  String get open_scene => '打开场景';

  @override
  String get skip => '跳过';

  @override
  String get apply => '应用';

  @override
  String get selected => '已选择';

  @override
  String get select => '选择';

  @override
  String get preview => '预览';

  @override
  String get delete_scene => '删除场景';

  @override
  String get metadata_only => '仅元数据';

  @override
  String get files => '文件';

  @override
  String get scene_deleted => '场景已删除';

  @override
  String get delete_metadata => '删除元数据';

  @override
  String get delete_files => '删除文件';

  @override
  String get scene_deduplication => '场景去重';

  @override
  String get no_duplicates_found => '没有发现重复项。';

  @override
  String get search_accuracy => '搜索准确率';

  @override
  String get duration_difference => '持续时间差异';

  @override
  String get only_select_matching_codecs => '仅选择匹配的编解码器';

  @override
  String get select_scenes => '选择场景';

  @override
  String get all_but_largest_resolution => '除最大分辨率外的所有分辨率';

  @override
  String get all_but_largest_file => '除最大文件外的所有文件';

  @override
  String get all_but_oldest => '除最旧项外全部';

  @override
  String get all_but_youngest => '除最新项外全部';

  @override
  String get select_none => '取消全选';

  @override
  String get merge => '合并';

  @override
  String get previous_page => '上一页';

  @override
  String get next_page => '下一页';

  @override
  String scene_deduplication_page_count(int page, int totalPages) {
    return '第 $page 页，共 $totalPages 页';
  }

  @override
  String scene_tagger_result_count(int index, int total) {
    return '结果 $index / $total';
  }

  @override
  String delete_preset_confirm(String name) {
    return '删除“$name”？此操作无法撤消。';
  }

  @override
  String get enter_preset_name => '输入预设名称';

  @override
  String get delete_scene_confirm => '您确定要删除该场景吗？';

  @override
  String delete_selected_count(int selectedCount) {
    return '删除所选内容 ($selectedCount)';
  }

  @override
  String get saved_presets => '已保存的预设';

  @override
  String get current_settings => '当前设置';

  @override
  String get available_presets => '可用预设';

  @override
  String get existing_names_are_overwritten => '已有名称将被覆盖';

  @override
  String get active_settings_saved_server => '当前生效的设置将保存到服务器。';

  @override
  String failed_to_save_filter(String error) {
    return '无法保存筛选器：$error';
  }

  @override
  String failed_to_delete_preset(String error) {
    return '无法删除预设：$error';
  }

  @override
  String sort_label(String sortLabel) {
    return '排序：$sortLabel';
  }

  @override
  String filters_count(int count) {
    return '筛选器：$count';
  }

  @override
  String search_label(String query) {
    return '搜索：$query';
  }

  @override
  String failed_to_load_presets(String error) {
    return '无法加载预设：$error';
  }

  @override
  String saved_item(String item) {
    return '已保存 $item';
  }

  @override
  String unable_to_load_stash_boxes(String error) {
    return '无法加载 Stash Box：$error';
  }

  @override
  String delete_n_scenes_question(int count) {
    return '删除 $count 个场景？';
  }

  @override
  String get delete_scenes_help => '选择仅删除 Stash 元数据，还是同时删除场景文件及其生成的辅助文件。';

  @override
  String deleted_n_scenes(int count) {
    return '已删除 $count 个场景';
  }

  @override
  String delete_failed_error(String error) {
    return '删除失败：$error';
  }

  @override
  String get configuration => '配置';

  @override
  String missing_phashes_for_scenes(int count) {
    return '$count 个场景缺少感知哈希。请运行感知哈希生成任务。';
  }

  @override
  String get merge_editing_not_wired => 'StashFlow 尚未支持合并编辑。';

  @override
  String duplicate_sets_count(int count) {
    return '$count 组重复项';
  }

  @override
  String duplicate_set_number(int number) {
    return '重复组 $number';
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

    return '$countString 个标签';
  }

  @override
  String nGroups(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '$countString 个分组';
  }

  @override
  String nMarkers(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '$countString 个标记';
  }

  @override
  String nGalleries(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '$countString 个画廊';
  }

  @override
  String scene_tagger_checked_matches_summary(int checked, int matches) {
    return '已检查 $checked 项 • $matches 个匹配';
  }

  @override
  String scene_tagger_page_summary(int count) {
    return '本页 $count 个场景';
  }

  @override
  String get no_matched_scenes_yet => '还没有匹配到的场景。';

  @override
  String get no_scenes_match_configuration => '没有场景符合此配置。';

  @override
  String scene_tagger_checked_count(int count) {
    return '已检查 $count 项';
  }

  @override
  String scene_tagger_progress(int checked, int total) {
    return '$checked / $total';
  }

  @override
  String get stats_library_stats_tooltip => '长按查看资料库统计';

  @override
  String get scene_details_marker_created => '标记已创建';

  @override
  String scene_details_failed_to_create_marker(String error) {
    return '无法创建标记：$error';
  }

  @override
  String get scene_details_delete_marker_title => '删除标记';

  @override
  String scene_details_delete_marker_content(String title) {
    return '删除标记“$title”吗？';
  }

  @override
  String get scene_details_marker_deleted => '标记已删除';

  @override
  String scene_details_failed_to_delete_marker(String error) {
    return '无法删除标记：$error';
  }

  @override
  String get scene_details_add_marker => '添加标记';

  @override
  String get scene_details_create_marker => '创造';

  @override
  String scene_details_delete_marker_tooltip(String title) {
    return '删除标记 $title';
  }

  @override
  String get scenes_page_markers_tooltip => '标记';

  @override
  String get auto_marker_name => '标记名称';

  @override
  String get auto_missing_field => '缺失字段';

  @override
  String get filter_markers_title => '过滤标记';

  @override
  String get marker_title => '标记';

  @override
  String get duration_title => '期间';

  @override
  String get scene_title => '场景';

  @override
  String get dates_title => '日期';

  @override
  String get created_at_title => '创建于';

  @override
  String get updated_at_title => '更新于';

  @override
  String get scene_date_title => '场景日期';

  @override
  String get scene_created_at_title => '场景创建于';

  @override
  String get scene_updated_at_title => '场景更新于';

  @override
  String get organized_title => '有组织';

  @override
  String get interactive_title => '交互的';

  @override
  String get scraped_metadata_title => '抓取的元数据';

  @override
  String get local_scene_title => '当地场景';

  @override
  String get sort_markers_title => '对标记进行排序';

  @override
  String get markers_title => '标记';

  @override
  String get sub_group_count_title => '子组计数';

  @override
  String get groups_browsing_mode_subtitle => '群组的默认浏览模式';

  @override
  String get markers_browsing_mode_subtitle => '标记的默认浏览模式';

  @override
  String get entity_layouts_title => '实体布局';

  @override
  String get entity_layouts_subtitle => '演员、制片商和标签的媒体和画廊布局默认值';

  @override
  String get stats_subtitle_0_gb => '0.00GB';

  @override
  String get stats_subtitle_0_unique_items => '0 件独特物品';

  @override
  String get markers_search_hint => '搜索标记';

  @override
  String get tags_title => '标签';

  @override
  String get scenes_title => '场景';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => 'StashFlow';

  @override
  String get common_token => '代幣';

  @override
  String get filter_value => '值';

  @override
  String get common_yes => '是的';

  @override
  String get common_no => '否';

  @override
  String get common_clear_history => '清除歷史記錄';

  @override
  String get nav_scenes => '場景';

  @override
  String get nav_performers => '演出者';

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
      one: '1 個場景',
      zero: '沒有場景',
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
      other: '$countString 位演出者',
      one: '1 位演出者',
      zero: '沒有演出者',
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
  String get common_reset => '重設';

  @override
  String get common_apply => '套用';

  @override
  String get common_save_default => '儲存為預設';

  @override
  String get common_sort_method => '排序方式';

  @override
  String get common_direction => '方向';

  @override
  String get common_ascending => '遞增';

  @override
  String get common_descending => '遞減';

  @override
  String get common_favorites_only => '僅限收藏';

  @override
  String get common_apply_sort => '套用排序';

  @override
  String get common_apply_filters => '套用篩選';

  @override
  String get common_view_all => '查看全部';

  @override
  String get common_default => '預設';

  @override
  String get common_later => '稍後';

  @override
  String get common_update_now => '發佈詳情';

  @override
  String get common_configure_now => '立即設定';

  @override
  String get common_clear_rating => '清除評分';

  @override
  String get common_no_media => '沒有可用的媒體';

  @override
  String get common_show => '顯示';

  @override
  String get common_hide => '隱藏';

  @override
  String get galleries_filter_saved => '篩選偏好已儲存為預設';

  @override
  String get common_setup_required => '需要設定';

  @override
  String get common_update_available => '有可用更新';

  @override
  String get details_studio => '製片商詳情';

  @override
  String get details_performer => '演出者詳情';

  @override
  String get details_tag => '標籤詳情';

  @override
  String get details_scene => '場景詳情';

  @override
  String get details_gallery => '圖庫詳情';

  @override
  String get studios_filter_title => '篩選製片商';

  @override
  String get studios_filter_saved => '篩選偏好已儲存為預設';

  @override
  String get sort_name => '名稱';

  @override
  String get sort_scene_count => '場景數量';

  @override
  String get sort_rating => '評分';

  @override
  String get sort_updated_at => '更新於';

  @override
  String get sort_created_at => '建立於';

  @override
  String get sort_random => '隨機';

  @override
  String get sort_file_mod_time => '檔案修改時間';

  @override
  String get sort_filesize => '檔案大小';

  @override
  String get sort_o_count => 'O 計數器';

  @override
  String get sort_height => '身高';

  @override
  String get sort_birthdate => '出生日期';

  @override
  String get sort_tag_count => '標籤數';

  @override
  String get sort_play_count => '播放次數';

  @override
  String get sort_o_counter => 'O 計數器';

  @override
  String get sort_zip_file_count => 'ZIP 檔案數';

  @override
  String get sort_last_o_at => '上次 O 時間';

  @override
  String get sort_latest_scene => '最新場景';

  @override
  String get sort_career_start => '職業開始';

  @override
  String get sort_career_end => '職業結束';

  @override
  String get sort_weight => '體重';

  @override
  String get sort_measurements => '三圍';

  @override
  String get sort_scenes_duration => '場景時長';

  @override
  String get sort_scenes_size => '場景大小';

  @override
  String get sort_images_count => '圖片數';

  @override
  String get sort_galleries_count => '畫廊數';

  @override
  String get sort_child_count => '子工作室數';

  @override
  String get sort_performers_count => '演出者數';

  @override
  String get sort_groups_count => '分組數';

  @override
  String get sort_marker_count => '標記數';

  @override
  String get sort_studios_count => '工作室數';

  @override
  String get sort_penis_length => '陰莖長度';

  @override
  String get sort_last_played_at => '上次播放時間';

  @override
  String get studios_sort_saved => '排序偏好已儲存為預設';

  @override
  String get studios_no_random => '沒有可用的製片商進行隨機導航';

  @override
  String get tags_filter_title => '篩選標籤';

  @override
  String get tags_filter_saved => '篩選偏好已儲存為預設';

  @override
  String get tags_sort_title => '排序標籤';

  @override
  String get tags_sort_saved => '排序偏好已儲存為預設';

  @override
  String get tags_no_random => '沒有可用的標籤進行隨機導航';

  @override
  String get scenes_no_random => '沒有可用的場景進行隨機導航';

  @override
  String get performers_no_random => '沒有可用的演出者進行隨機導航';

  @override
  String get galleries_no_random => '沒有可用的圖庫進行隨機導航';

  @override
  String common_error(String message) {
    return '錯誤：$message';
  }

  @override
  String get common_no_media_available => '無可用媒體';

  @override
  String common_id(Object id) {
    return 'ID：$id';
  }

  @override
  String get common_search_placeholder => '搜尋...';

  @override
  String get common_pause => '暫停';

  @override
  String get common_play => '播放';

  @override
  String get common_refresh => '重新整理';

  @override
  String get common_close => '關閉';

  @override
  String get common_save => '儲存';

  @override
  String get common_unmute => '取消靜音';

  @override
  String get common_mute => '靜音';

  @override
  String get common_back => '返回';

  @override
  String get common_rate => '評分';

  @override
  String get common_previous => '上一個';

  @override
  String get common_next => '下一個';

  @override
  String get common_favorite => '收藏';

  @override
  String get common_unfavorite => '取消收藏';

  @override
  String get common_version => '版本';

  @override
  String get common_loading => '載入中';

  @override
  String get common_unavailable => '不可用';

  @override
  String get common_details => '詳情';

  @override
  String get common_title => '標題';

  @override
  String get common_release_date => '發佈日期';

  @override
  String get common_url => '連結';

  @override
  String get common_no_url => '無 URL';

  @override
  String get common_sort => '排序';

  @override
  String get common_filter => '篩選';

  @override
  String get common_search => '搜尋';

  @override
  String get common_settings => '設定';

  @override
  String get common_reset_to_1x => '重設為 1x';

  @override
  String get common_skip_next => '跳過下一個';

  @override
  String get common_skip_previous => '跳過上一個';

  @override
  String get common_select_subtitle => '選擇字幕';

  @override
  String get common_playback_speed => '播放速度';

  @override
  String get common_pip => '子母畫面';

  @override
  String get common_toggle_fullscreen => '切換全螢幕';

  @override
  String get common_exit_fullscreen => '退出全螢幕';

  @override
  String get common_copy_logs => '複製日誌';

  @override
  String get common_clear_logs => '清除日誌';

  @override
  String get common_enable_autoscroll => '啟用自動捲動';

  @override
  String get common_disable_autoscroll => '禁用自動捲動';

  @override
  String get common_retry => '重試';

  @override
  String get common_no_items => '未找到項目';

  @override
  String get common_none => '無';

  @override
  String get common_any => '任意';

  @override
  String get common_name => '名稱';

  @override
  String get common_date => '日期';

  @override
  String get common_rating => '評分';

  @override
  String get common_image_count => '圖片數量';

  @override
  String get common_filepath => '文件路徑';

  @override
  String get common_random => '隨機';

  @override
  String get common_no_media_found => '未找到媒體';

  @override
  String common_not_found(String item) {
    return '未找到 $item';
  }

  @override
  String get common_add_favorite => '添加收藏';

  @override
  String get common_remove_favorite => '取消收藏';

  @override
  String get details_group => '小組詳情';

  @override
  String get details_synopsis => '劇情簡介';

  @override
  String get details_media => '媒體';

  @override
  String get details_galleries => '圖庫';

  @override
  String get details_tags => '標籤';

  @override
  String get details_links => '鏈接';

  @override
  String get details_scene_scrape => '擷取中繼資料';

  @override
  String get details_show_more => '顯示更多';

  @override
  String get common_more => '更多';

  @override
  String get details_show_less => '顯示較少';

  @override
  String get details_more_from_studio => '來自該製片商的更多內容';

  @override
  String get details_o_count_incremented => 'O 計數已增加';

  @override
  String details_failed_update_rating(String error) {
    return '更新評分失敗：$error';
  }

  @override
  String details_failed_update_performer(Object error) {
    return '更新演员失败：$error';
  }

  @override
  String details_failed_increment_o_count(String error) {
    return '增加 O 計數失敗：$error';
  }

  @override
  String get details_scene_add_performer => '添加演出者';

  @override
  String get details_scene_add_tag => '添加標籤';

  @override
  String get details_scene_add_url => '添加 URL';

  @override
  String get details_scene_remove_url => '移除 URL';

  @override
  String get groups_title => '小組';

  @override
  String get groups_unnamed => '未命名小組';

  @override
  String get groups_untitled => '無標題小組';

  @override
  String get studios_title => '製片商';

  @override
  String get studios_galleries_title => '製片商圖庫';

  @override
  String get studios_media_title => '製片商媒體';

  @override
  String get studios_sort_title => '製片商排序';

  @override
  String get galleries_title => '圖库';

  @override
  String get galleries_sort_title => '圖库排序';

  @override
  String get galleries_all_images => '所有圖片';

  @override
  String get galleries_filter_title => '圖库篩選';

  @override
  String get galleries_min_rating => '最低評分';

  @override
  String get galleries_image_count => '圖片數量';

  @override
  String get galleries_organization => '整理';

  @override
  String get galleries_organized_only => '僅已整理';

  @override
  String get scenes_filter_title => '篩選場景';

  @override
  String get scenes_filter_saved => '篩選偏好已儲存為預設設定';

  @override
  String get scenes_watched => '已看';

  @override
  String get scenes_unwatched => '未看';

  @override
  String get scenes_search_hint => '搜尋場景...';

  @override
  String get scenes_sort_header => '排序場景';

  @override
  String get scenes_sort_duration => '時長';

  @override
  String get scenes_sort_bitrate => '比特率';

  @override
  String get scenes_sort_framerate => '幀率';

  @override
  String get scenes_sort_file_count => '檔案數量';

  @override
  String get scenes_sort_filesize => '檔案大小';

  @override
  String get scenes_sort_resolution => '解析度';

  @override
  String get scenes_sort_last_played_at => '最後播放時間';

  @override
  String get scenes_sort_resume_time => '恢復時間';

  @override
  String get scenes_sort_play_duration => '播放時長';

  @override
  String get scenes_sort_interactive => '互動式';

  @override
  String get scenes_sort_interactive_speed => '交互速度';

  @override
  String get scenes_sort_perceptual_similarity => '感知相似度';

  @override
  String get scenes_sort_performer_age => '演出者年齡';

  @override
  String get scenes_sort_studio => '工作室';

  @override
  String get scenes_sort_path => '路徑';

  @override
  String get scenes_sort_file_mod_time => '檔案修改時間';

  @override
  String get scenes_sort_tag_count => '標籤數量';

  @override
  String get scenes_sort_performer_count => '演出者數量';

  @override
  String get scenes_sort_o_counter => 'O計數器';

  @override
  String get scenes_sort_last_o_at => '上次O時間';

  @override
  String get scenes_sort_group_scene_number => '合集/電影場景編號';

  @override
  String get scenes_sort_code => '代碼';

  @override
  String get scenes_sort_saved_default => '排序偏好已保存為預設';

  @override
  String get scenes_sort_tooltip => '排序選項';

  @override
  String get tags_search_hint => '搜尋標籤...';

  @override
  String get tags_sort_tooltip => '排序選項';

  @override
  String get tags_filter_tooltip => '篩選選項';

  @override
  String get performers_title => '演職人員';

  @override
  String get performers_sort_title => '演職人員排序';

  @override
  String get performers_filter_title => '演职人员篩選';

  @override
  String get performers_galleries_title => '所有演職人員圖库';

  @override
  String get performers_media_title => '所有演職人員媒體';

  @override
  String get performers_gender => '性別';

  @override
  String get performers_gender_any => '任意';

  @override
  String get performers_gender_female => '女性';

  @override
  String get performers_gender_male => '男性';

  @override
  String get performers_gender_trans_female => '跨性別女性';

  @override
  String get performers_gender_trans_male => '跨性別男性';

  @override
  String get performers_gender_intersex => '雙性人';

  @override
  String get performers_gender_non_binary => '非二元';

  @override
  String get performers_circumcised => '割礼';

  @override
  String get performers_circumcised_cut => '已割禮';

  @override
  String get performers_circumcised_uncut => '未割禮';

  @override
  String get performers_play_count => '播放次數';

  @override
  String get performers_field_disambiguation => '消歧义';

  @override
  String get performers_field_birthdate => '出生日期';

  @override
  String get performers_field_deathdate => '死亡日期';

  @override
  String get performers_field_height_cm => '身高（cm）';

  @override
  String get performers_field_weight_kg => '体重（kg）';

  @override
  String get performers_field_measurements => '三围';

  @override
  String get performers_field_fake_tits => '假胸';

  @override
  String get performers_field_penis_length => '阴茎长度';

  @override
  String get performers_field_ethnicity => '族裔';

  @override
  String get performers_field_country => '国家';

  @override
  String get performers_field_eye_color => '眼睛颜色';

  @override
  String get performers_field_hair_color => '头发颜色';

  @override
  String get performers_field_career_start => '职业开始';

  @override
  String get performers_field_career_end => '职业结束';

  @override
  String get performers_field_tattoos => '纹身';

  @override
  String get performers_field_piercings => '穿孔';

  @override
  String get performers_field_aliases => '别名';

  @override
  String get common_organized => '已整理';

  @override
  String get scenes_duplicated => '重复';

  @override
  String get random_studio => '隨機製片商';

  @override
  String get random_gallery => '隨機圖庫';

  @override
  String get random_tag => '隨機標籤';

  @override
  String get random_scene => '隨機場景';

  @override
  String get random_performer => '隨機演出者';

  @override
  String get filter_modifier => '修饰符';

  @override
  String get filter_group_general => '一般';

  @override
  String get filter_group_performer => '演出者';

  @override
  String get filter_group_library => '媒體庫';

  @override
  String get filter_group_metadata => '元數據';

  @override
  String get filter_group_media_info => '媒體資訊';

  @override
  String get filter_group_usage => '使用情況';

  @override
  String get filter_group_system => '系統';

  @override
  String get filter_group_physical => '實體';

  @override
  String get filter_equals => '等于';

  @override
  String get filter_not_equals => '不等于';

  @override
  String get filter_greater_than => '大于';

  @override
  String get filter_less_than => '小于';

  @override
  String get filter_includes => '包括';

  @override
  String get filter_excludes => '不包括';

  @override
  String get filter_includes_all => '包括全部';

  @override
  String get filter_is_null => '为空';

  @override
  String get filter_not_null => '不为空';

  @override
  String get filter_matches_regex => '匹配正規表示式';

  @override
  String get filter_not_matches_regex => '與正規表示式不符';

  @override
  String get filter_between => '之間';

  @override
  String get filter_not_between => '不在之間';

  @override
  String get filter_value_secondary => '第二個值';

  @override
  String get images_resolution_title => '解析度';

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
  String get images_orientation_title => '方向';

  @override
  String get common_or => '或';

  @override
  String get scrape_from_url => '从 URL 抓取';

  @override
  String get scenes_phash_started => '开始生成 phash';

  @override
  String scenes_phash_failed(Object error) {
    return '生成 phash 失败：$error';
  }

  @override
  String details_failed_update_studio(Object error) {
    return '更新工作室失败：$error';
  }

  @override
  String get settings_title => '設定';

  @override
  String get settings_customize => '自訂 StashFlow';

  @override
  String get settings_customize_subtitle => '在一個地方調整播放、外觀、佈局和支援工具。';

  @override
  String get settings_core_section => '核心設定';

  @override
  String get settings_core_subtitle => '最常用的設定頁面';

  @override
  String get settings_server => '伺服器';

  @override
  String get settings_server_subtitle => '連線和 API 設定';

  @override
  String get settings_playback => '播放';

  @override
  String get settings_playback_subtitle => '播放器行為和互動';

  @override
  String get settings_keyboard => '鍵盤';

  @override
  String get settings_keyboard_subtitle => '可自訂的捷徑和熱鍵';

  @override
  String get settings_keyboard_title => '鍵盤快捷鍵';

  @override
  String get settings_keyboard_reset_defaults => '重置為默認值';

  @override
  String get settings_keyboard_not_bound => '未绑定';

  @override
  String get settings_keyboard_volume_up => '提高音量';

  @override
  String get settings_keyboard_volume_down => '降低音量';

  @override
  String get settings_keyboard_toggle_mute => '切換静音';

  @override
  String get settings_keyboard_toggle_fullscreen => '切換全屏';

  @override
  String get settings_keyboard_next_scene => '下一個場景';

  @override
  String get settings_keyboard_prev_scene => '上一個場景';

  @override
  String get settings_keyboard_increase_speed => '提高播放速度';

  @override
  String get settings_keyboard_decrease_speed => '降低播放速度';

  @override
  String get settings_keyboard_reset_speed => '重置播放速度';

  @override
  String get settings_keyboard_close_player => '關閉播放器';

  @override
  String get settings_keyboard_next_image => '下一張圖片';

  @override
  String get settings_keyboard_prev_image => '上一張圖片';

  @override
  String get settings_keyboard_go_back => '返回';

  @override
  String get settings_keyboard_play_pause_desc => '在播放和暫停視頻之間切換';

  @override
  String get settings_keyboard_seek_forward_5_desc => '快進 5 秒';

  @override
  String get settings_keyboard_seek_backward_5_desc => '快退 5 秒';

  @override
  String get settings_keyboard_seek_forward_10_desc => '快進 10 秒';

  @override
  String get settings_keyboard_seek_backward_10_desc => '快退 10 秒';

  @override
  String get settings_appearance => '外觀';

  @override
  String get settings_appearance_subtitle => '佈景主題和顏色';

  @override
  String get settings_interface => '介面';

  @override
  String get settings_interface_subtitle => '導航和佈局預設';

  @override
  String get settings_support => '支援';

  @override
  String get settings_support_subtitle => '診斷和關於';

  @override
  String get settings_develop => '開發';

  @override
  String get settings_develop_subtitle => '進階工具和覆寫';

  @override
  String get settings_appearance_title => '外觀設定';

  @override
  String get settings_appearance_theme_mode => '主題模式';

  @override
  String get settings_appearance_theme_mode_subtitle => '選擇應用程式如何跟隨亮度變化';

  @override
  String get settings_appearance_theme_system => '系統';

  @override
  String get settings_appearance_theme_light => '淺色';

  @override
  String get settings_appearance_theme_dark => '深色';

  @override
  String get settings_appearance_primary_color => '主要顏色';

  @override
  String get settings_appearance_primary_color_subtitle =>
      '為 Material 3 調色盤挑選種子顏色';

  @override
  String get settings_appearance_advanced_theming => '進階主題';

  @override
  String get settings_appearance_advanced_theming_subtitle => '針對特定螢幕類型的最佳化';

  @override
  String get settings_appearance_true_black => '純黑 (AMOLED)';

  @override
  String get settings_appearance_true_black_subtitle =>
      '在深色模式下使用純黑背景，以節省 OLED 螢幕的電量';

  @override
  String get settings_appearance_custom_hex => '自訂 Hex 顏色';

  @override
  String get settings_appearance_custom_hex_helper => '輸入 8 位數 ARGB hex 代碼';

  @override
  String get settings_appearance_font_size => '全球使用者介面規模';

  @override
  String get settings_appearance_font_size_subtitle => '按比例縮放版式和間距';

  @override
  String get settings_interface_title => '介面設定';

  @override
  String get settings_interface_language => '語言';

  @override
  String get settings_interface_language_subtitle => '覆寫預設系統語言';

  @override
  String get settings_interface_app_language => '應用程式語言';

  @override
  String get settings_interface_navigation => '導航';

  @override
  String get settings_interface_navigation_subtitle => '全域導航捷徑的可見度';

  @override
  String get settings_interface_show_random => '顯示隨機導航按鈕';

  @override
  String get settings_interface_show_random_subtitle => '在列表和詳情頁面啟用或停用浮動隨機按鈕';

  @override
  String get settings_interface_hide_scene_metadata => '預設隱藏場景中繼資料';

  @override
  String get settings_interface_hide_scene_metadata_subtitle =>
      '點選「顯示中繼資料」後才顯示場景技術中繼資料。';

  @override
  String get settings_interface_random_scene_filter => '隨機場景遵循目前篩選條件';

  @override
  String get settings_interface_random_scene_filter_subtitle =>
      '啟用後，隨機場景導覽會使用目前的場景篩選條件。';

  @override
  String get settings_interface_main_pages_gravity_orientation =>
      '重力控制的方向（主頁面）';

  @override
  String get settings_interface_main_pages_gravity_orientation_subtitle =>
      '允許主頁面使用裝置感測器旋轉。全螢幕影片播放將使用其自己的方向設定。';

  @override
  String get settings_interface_show_edit => '顯示編輯按鈕';

  @override
  String get settings_interface_show_edit_subtitle => '在場景詳情頁面上啟用或停用編輯按鈕';

  @override
  String get settings_interface_use_actual_scene_video_miniplayer =>
      '在迷你播放器中使用實際場景影片';

  @override
  String get settings_interface_use_actual_scene_video_miniplayer_subtitle =>
      '播放時顯示即時場景影片畫面，而不是場景截圖。';

  @override
  String get details_show_metadata => '顯示中繼資料';

  @override
  String get settings_interface_entity_image_filtering => '實體圖像過濾';

  @override
  String get settings_interface_entity_image_filtering_subtitle =>
      '選擇實體圖像頁面是匹配圖像元數據還是關聯圖庫。';

  @override
  String get settings_interface_entity_image_filtering_direct => '直接實體';

  @override
  String get settings_interface_entity_image_filtering_galleries => '關聯圖庫';

  @override
  String get settings_interface_customize_tabs => '自訂分頁';

  @override
  String get settings_interface_customize_tabs_subtitle => '重新排序或隱藏導航選單項目';

  @override
  String get settings_interface_scenes_layout => '場景佈局';

  @override
  String get settings_interface_scenes_layout_subtitle => '場景的預設瀏覽模式';

  @override
  String get settings_interface_galleries_layout => '圖庫佈局';

  @override
  String get settings_interface_galleries_layout_subtitle => '圖庫的預設瀏覽模式';

  @override
  String get settings_interface_max_performer_avatars => '最多演出者頭像';

  @override
  String get settings_interface_max_performer_avatars_subtitle =>
      '在場景卡上顯示的演出者頭像的最大數量。';

  @override
  String get settings_interface_show_performer_avatars => '顯示演出者頭像';

  @override
  String get settings_interface_show_performer_avatars_subtitle =>
      '在所有平台的場景卡上顯示演出者圖標。';

  @override
  String get settings_interface_performer_avatar_size => '演出者頭像大小';

  @override
  String get settings_interface_layout_default => '預設佈局';

  @override
  String get settings_interface_layout_default_desc => '選擇頁面的預設佈局';

  @override
  String get settings_interface_layout_list => '列表';

  @override
  String get settings_interface_layout_grid => '網格';

  @override
  String get settings_interface_layout_tiktok => '無限捲動';

  @override
  String get settings_interface_grid_columns => '網格欄數';

  @override
  String get settings_interface_image_viewer => '圖片查看器';

  @override
  String get settings_interface_image_viewer_subtitle => '設定全螢幕圖片瀏覽行為';

  @override
  String get settings_interface_swipe_direction => '全螢幕滑動方向';

  @override
  String get settings_interface_swipe_direction_desc => '選擇圖片在全螢幕模式下如何切換';

  @override
  String get settings_interface_swipe_vertical => '垂直';

  @override
  String get settings_interface_swipe_horizontal => '水平';

  @override
  String get settings_interface_waterfall_columns => '瀑布流網格欄數';

  @override
  String get settings_interface_performer_layouts => '演出者佈局';

  @override
  String get settings_interface_performer_layouts_subtitle => '演出者的媒體和圖庫預設';

  @override
  String get settings_interface_studio_layouts => '製片商佈局';

  @override
  String get settings_interface_studio_layouts_subtitle => '製片商的媒體和圖庫預設';

  @override
  String get settings_interface_tag_layouts => '標籤佈局';

  @override
  String get settings_interface_tag_layouts_subtitle => '標籤的媒體和圖庫預設';

  @override
  String get settings_interface_media_layout => '媒體佈局';

  @override
  String get settings_interface_media_layout_subtitle => '媒體頁面的佈局';

  @override
  String get settings_interface_galleries_layout_item => '圖庫佈局';

  @override
  String get settings_interface_galleries_layout_subtitle_item => '圖庫頁面的佈局';

  @override
  String get settings_server_title => '伺服器設定';

  @override
  String get settings_server_status => '連線狀態';

  @override
  String get settings_server_status_subtitle => '與設定伺服器的即時連線情況';

  @override
  String get settings_server_details => '伺服器詳情';

  @override
  String get settings_server_details_subtitle => '設定端點和驗證方式';

  @override
  String get settings_server_url => 'Stash 位址';

  @override
  String get settings_server_url_helper =>
      '輸入 Stash 伺服器的 URL。如果配置了自定義路徑，請在此處包含它。';

  @override
  String get settings_server_url_example => 'http://192.168.1.100:9999';

  @override
  String get settings_server_login_failed => '登入失敗';

  @override
  String get settings_server_auth_method => '驗證方式';

  @override
  String get settings_server_auth_apikey => 'API 金鑰';

  @override
  String get settings_server_auth_password => '使用者名稱 + 密碼';

  @override
  String get settings_server_auth_password_desc =>
      '建議：使用您的 Stash 使用者名稱/密碼工作階段。';

  @override
  String get settings_server_auth_apikey_desc => '使用 API 金鑰進行靜態權杖驗證。';

  @override
  String get settings_server_username => '使用者名稱';

  @override
  String get settings_server_password => '密碼';

  @override
  String get settings_server_login_test => '登入並測試';

  @override
  String get settings_server_test => '測試連線';

  @override
  String get settings_server_logout => '登出';

  @override
  String get settings_server_clear => '清除設定';

  @override
  String settings_server_connected(String version) {
    return '已連線 (Stash $version)';
  }

  @override
  String get settings_server_checking => '正在檢查連線...';

  @override
  String settings_server_failed(String error) {
    return '失敗：$error';
  }

  @override
  String get settings_server_invalid_url => '無效的伺服器網址';

  @override
  String get settings_server_resolve_error => '無法解析伺服器網址。請檢查主機、連接埠和認證。';

  @override
  String get settings_server_logout_confirm => '已登出且 Cookie 已清除。';

  @override
  String get settings_server_profile_add => '新增設定檔';

  @override
  String get settings_server_profile_edit => '編輯設定檔';

  @override
  String get settings_server_profile_name => '設定檔名稱';

  @override
  String get settings_server_profile_delete => '刪除設定檔';

  @override
  String get settings_server_profile_delete_confirm => '您確定要刪除此設定檔嗎？此動作無法復原。';

  @override
  String get settings_server_profile_active => '使用中';

  @override
  String get settings_server_profile_empty => '未設定伺服器設定檔';

  @override
  String get settings_server_profiles => '伺服器設定檔';

  @override
  String get settings_server_profiles_subtitle => '管理多個 Stash 伺服器連線';

  @override
  String get settings_server_auth_status_logging_in => '驗證狀態：正在登入...';

  @override
  String get settings_server_auth_status_logged_in => '驗證狀態：已登入';

  @override
  String get settings_server_auth_status_logged_out => '驗證狀態：已登出';

  @override
  String get settings_playback_title => '播放設定';

  @override
  String get settings_playback_behavior => '播放行為';

  @override
  String get settings_playback_behavior_subtitle => '預設播放和背景處理';

  @override
  String get settings_playback_prefer_streams => '優先使用 sceneStreams';

  @override
  String get settings_playback_prefer_streams_subtitle =>
      '關閉時，播放將直接使用 paths.stream';

  @override
  String get settings_playback_feed_random => '從隨機位置開始播放Feed';

  @override
  String get settings_playback_feed_random_subtitle =>
      '在Feed模式下播放場景時，從影片長度的0%到90%之間的隨機位置開始播放';

  @override
  String get settings_playback_resume_position => '從上次播放位置恢復';

  @override
  String get settings_playback_resume_position_subtitle =>
      '打開影片時，自動從上次中斷的地方繼續播放';

  @override
  String get settings_playback_end_behavior => '播放結束行為';

  @override
  String get settings_playback_end_behavior_subtitle => '目前播放結束後該怎麼辦';

  @override
  String get settings_playback_end_behavior_stop => '停止';

  @override
  String get settings_playback_end_behavior_loop => '循環當前場景';

  @override
  String get settings_playback_end_behavior_next => '播放下一個場景';

  @override
  String get settings_playback_autoplay => '自動播放下一個場景';

  @override
  String get settings_playback_autoplay_subtitle => '當目前播放結束時自動播放下一個場景';

  @override
  String get settings_playback_background => '背景播放';

  @override
  String get settings_playback_background_subtitle => '應用程式在背景執行時保持音訊播放';

  @override
  String get settings_playback_pip => '原生子母畫面';

  @override
  String get settings_playback_pip_subtitle => '啟用 Android 子母畫面按鈕並在背景執行時自動進入';

  @override
  String get settings_playback_subtitles => '字幕設定';

  @override
  String get settings_playback_subtitles_subtitle => '自動載入和外觀';

  @override
  String get settings_playback_subtitle_lang => '預設字幕語言';

  @override
  String get settings_playback_subtitle_lang_subtitle => '如果可用則自動載入';

  @override
  String get settings_playback_subtitle_size => '字幕字體大小';

  @override
  String get settings_playback_subtitle_pos => '字幕垂直位置';

  @override
  String settings_playback_subtitle_pos_desc(String percent) {
    return '距離底部 $percent%';
  }

  @override
  String get settings_playback_subtitle_align => '字幕文字對齊方式';

  @override
  String get settings_playback_subtitle_align_subtitle => '多行字幕的對齊方式';

  @override
  String get settings_playback_seek => '尋找互動';

  @override
  String get settings_playback_seek_subtitle => '選擇播放期間如何進行尋找';

  @override
  String get settings_playback_seek_double_tap => '雙擊左/右尋找 10 秒';

  @override
  String get settings_playback_seek_drag => '拖動時間軸進行尋找';

  @override
  String get settings_playback_seek_drag_label => '拖動';

  @override
  String get settings_playback_seek_double_tap_label => '雙擊';

  @override
  String get settings_playback_gravity_orientation => '重力控制的方向';

  @override
  String get settings_playback_direct_play => '切換場景時直接播放';

  @override
  String get settings_playback_direct_play_subtitle =>
      '從另一個正在播放的場景切換過來時，直接播放新場景';

  @override
  String get settings_playback_gravity_orientation_subtitle =>
      '允許使用裝置感測器在相符方向之間旋轉（例如：將橫向向左/向右翻轉）。';

  @override
  String get settings_playback_subtitle_lang_none_disabled => '無（停用）';

  @override
  String get settings_playback_subtitle_lang_auto_if_only_one => '自動（僅有一個時）';

  @override
  String get settings_playback_subtitle_lang_english => '英語';

  @override
  String get settings_playback_subtitle_lang_chinese => '中文';

  @override
  String get settings_playback_subtitle_lang_german => '德語';

  @override
  String get settings_playback_subtitle_lang_french => '法語';

  @override
  String get settings_playback_subtitle_lang_spanish => '西班牙語';

  @override
  String get settings_playback_subtitle_lang_italian => '義大利語';

  @override
  String get settings_playback_subtitle_lang_japanese => '日語';

  @override
  String get settings_playback_subtitle_lang_korean => '韓語';

  @override
  String get settings_playback_subtitle_align_left => '靠左';

  @override
  String get settings_playback_subtitle_align_center => '置中';

  @override
  String get settings_playback_subtitle_align_right => '靠右';

  @override
  String get settings_support_title => '支援';

  @override
  String get settings_support_diagnostics => '診斷和專案資訊';

  @override
  String get settings_support_diagnostics_subtitle =>
      '當您需要協助時，開啟執行階段記錄或跳轉至儲存庫。';

  @override
  String get settings_support_update_available => '有可用更新';

  @override
  String get settings_support_update_available_subtitle => 'GitHub 上有較新版本';

  @override
  String settings_support_update_to(String version) {
    return '更新至 $version';
  }

  @override
  String get settings_support_update_to_subtitle => '新功能和改進正在等著您。';

  @override
  String get settings_support_about => '關於';

  @override
  String get settings_support_about_subtitle => '專案和原始碼資訊';

  @override
  String get settings_support_version => '版本';

  @override
  String get settings_support_version_loading => '正在載入版本資訊...';

  @override
  String get settings_support_version_unavailable => '無法取得版本資訊';

  @override
  String get settings_support_github => 'GitHub 儲存庫';

  @override
  String get settings_support_github_subtitle => '查看原始碼並回報問題';

  @override
  String get settings_support_github_error => '無法開啟 GitHub 連結';

  @override
  String get settings_support_issues => '報告問題';

  @override
  String get settings_support_issues_subtitle => '透過報告錯誤幫助改進 StashFlow';

  @override
  String get settings_develop_title => '開發';

  @override
  String get settings_develop_enable_logging => '啟用調試日誌';

  @override
  String get settings_develop_enable_logging_subtitle => '記錄應用程式日誌以供排查問題';

  @override
  String get settings_develop_diagnostics => '診斷工具';

  @override
  String get settings_develop_diagnostics_subtitle => '疑難排解和效能';

  @override
  String get settings_develop_video_debug => '顯示視訊偵錯資訊';

  @override
  String get settings_develop_video_debug_subtitle => '在視訊播放器上以疊加層方式顯示技術播放細節。';

  @override
  String get settings_develop_log_viewer => '偵錯記錄檢視器';

  @override
  String get settings_develop_log_viewer_subtitle => '開啟應用程式內記錄的即時檢視。';

  @override
  String get settings_develop_logs_copied => '日誌已複製到剪貼簿';

  @override
  String get settings_develop_no_logs => '尚無日誌。與應用互動以捕捉日誌。';

  @override
  String get settings_develop_web_overrides => '網頁覆寫';

  @override
  String get settings_develop_web_overrides_subtitle => '網頁平台的進階旗標';

  @override
  String get settings_develop_web_auth => '允許在網頁上使用密碼登入';

  @override
  String get settings_develop_web_auth_subtitle =>
      '覆寫僅限原生的限制，並強制「使用者名稱 + 密碼」驗證方式在 Flutter Web 上可見。';

  @override
  String get settings_develop_proxy_auth => '啟用代理認證模式';

  @override
  String get settings_develop_proxy_auth_subtitle =>
      '啟用進階 Basic Auth 和 Bearer Token 方法，以便在 Authentik 等代理背後的無認證後端中使用。';

  @override
  String get settings_server_auth_basic => '基礎認證';

  @override
  String get settings_server_auth_bearer => 'Bearer 權杖';

  @override
  String get settings_server_auth_basic_desc =>
      '發送 \'Authorization: Basic <base64(user:pass)>\' 請求頭。';

  @override
  String get settings_server_auth_bearer_desc =>
      '發送 \'Authorization: Bearer <token>\' 請求頭。';

  @override
  String get common_edit => '編輯';

  @override
  String get common_resolution => '解析度';

  @override
  String get common_orientation => '方向';

  @override
  String get common_landscape => '橫向';

  @override
  String get common_portrait => '縱向';

  @override
  String get common_square => '正方形';

  @override
  String get performers_filter_saved => '篩選偏好已儲存為預設值';

  @override
  String get images_title => '圖片';

  @override
  String get images_filter_title => '過濾圖片';

  @override
  String get images_filter_saved => '篩選偏好已儲存為預設設定';

  @override
  String get images_sort_title => '排序圖片';

  @override
  String get images_sort_saved => '排序首選項已儲存為預設值';

  @override
  String get image_rating_updated => '圖片評分已更新。';

  @override
  String get gallery_rating_updated => '圖庫評分已更新。';

  @override
  String get common_image => '圖片';

  @override
  String get common_gallery => '圖庫';

  @override
  String get images_gallery_rating_unavailable => '圖庫評分僅在瀏覽圖庫時可用。';

  @override
  String images_rating(String rating) {
    return '評分：$rating / 5';
  }

  @override
  String get images_filtered_by_gallery => '按圖庫篩選';

  @override
  String get images_slideshow_need_two => '幻燈片播放至少需要 2 張圖片。';

  @override
  String get images_slideshow_start_title => '開始幻燈片播放';

  @override
  String images_slideshow_interval(num seconds) {
    return '間隔：${seconds}s';
  }

  @override
  String images_slideshow_transition_ms(num ms) {
    return '過渡：${ms}ms';
  }

  @override
  String get common_forward => '向前';

  @override
  String get common_backward => '向後';

  @override
  String get images_slideshow_loop_title => '循環幻燈片播放';

  @override
  String get common_cancel => '取消';

  @override
  String get common_start => '開始';

  @override
  String get common_done => '完成';

  @override
  String get settings_keybind_assign_shortcut => '分配快速鍵';

  @override
  String get settings_keybind_press_any => '按任何鍵組合...';

  @override
  String get scenes_select_tags => '選取標籤';

  @override
  String get scenes_no_scrapers => '沒有可用的抓取器';

  @override
  String get scenes_select_scraper => '選取抓取器';

  @override
  String get scenes_no_results_found => '未找到結果';

  @override
  String get scenes_select_result => '選擇結果';

  @override
  String scenes_scrape_failed(String error) {
    return '抓取失敗：$error';
  }

  @override
  String get scenes_updated_successfully => '場景更新成功';

  @override
  String scenes_update_failed(String error) {
    return '場景更新失敗：$error';
  }

  @override
  String get scenes_edit_title => '編輯場景';

  @override
  String get scenes_field_studio => '製片商';

  @override
  String get scenes_field_tags => '標籤';

  @override
  String get scenes_field_urls => '連結';

  @override
  String get scenes_edit_performer => '編輯演出者';

  @override
  String get scenes_edit_studio => '編輯工作室';

  @override
  String get common_no_title => '無標題';

  @override
  String get scenes_select_studio => '選取製片商';

  @override
  String get scenes_select_performers => '選取演出者';

  @override
  String get scenes_unmatched_scraped_tags => '未匹配的抓取標籤';

  @override
  String get scenes_unmatched_scraped_performers => '未匹配的抓取演出者';

  @override
  String get scenes_no_matching_performer_found => '在資料庫中未找到匹配的演出者';

  @override
  String get common_unknown => '未知';

  @override
  String scenes_studio_id_prefix(String id) {
    return '製片商 ID：$id';
  }

  @override
  String get tags_search_placeholder => '搜尋標籤...';

  @override
  String get scenes_duration_short => '< 5分鐘';

  @override
  String get scenes_duration_medium => '5-20分鐘';

  @override
  String get scenes_duration_long => '> 20分鐘';

  @override
  String get details_scene_fingerprint_query => '場景指紋查詢';

  @override
  String get scenes_available_scrapers => '可用的抓取器';

  @override
  String get scrape_results_existing => '已存在';

  @override
  String get scrape_results_scraped => '已抓取';

  @override
  String get stats_refresh_statistics => '重新整理統計數據';

  @override
  String get stats_library_stats => '圖書館統計';

  @override
  String get stats_stash_glance => '您的藏品一目了然';

  @override
  String get stats_content => '內容';

  @override
  String get stats_organization => '組織';

  @override
  String get stats_activity => '活動';

  @override
  String get stats_scenes => '場景';

  @override
  String get stats_galleries => '畫廊';

  @override
  String get stats_performers => '表演者';

  @override
  String get stats_studios => '工作室';

  @override
  String get stats_groups => '團體';

  @override
  String get stats_tags => '標籤';

  @override
  String get stats_total_plays => '總播放次數';

  @override
  String stats_unique_items(int count) {
    return '$count 個唯一項目';
  }

  @override
  String get stats_total_o_count => '總 O 計數';

  @override
  String get cast_airplay_pairing => '隔空播放配對';

  @override
  String get cast_enter_pin => '輸入電視上顯示的 4 位 PIN 碼';

  @override
  String get cast_pair => '一對';

  @override
  String cast_connecting_to(String deviceName) {
    return '正在連線到 $deviceName...';
  }

  @override
  String cast_casting_to(String deviceName) {
    return '正在投放到 $deviceName';
  }

  @override
  String cast_pairing_failed(String error) {
    return '配對失敗：$error';
  }

  @override
  String cast_failed_to_cast(String error) {
    return '投放失敗：$error';
  }

  @override
  String get cast_searching => '正在搜尋設備...';

  @override
  String get cast_cast_to_device => '投射到設備';

  @override
  String get settings_storage_images => '圖片';

  @override
  String get settings_storage_videos => '影片';

  @override
  String get settings_storage_database => '資料庫';

  @override
  String get settings_storage_clearing_image => '正在清除圖像快取...';

  @override
  String get settings_storage_clearing_video => '清除視訊快取...';

  @override
  String get settings_storage_clearing_database => '清除資料庫快取...';

  @override
  String get settings_storage_cleared_image => '影像快取已清除';

  @override
  String get settings_storage_cleared_video => '視訊快取已清除';

  @override
  String get settings_storage_cleared_database => '資料庫快取已清除';

  @override
  String get settings_storage_clear => '清除';

  @override
  String get settings_storage_error_loading => '加載尺寸時出錯';

  @override
  String settings_storage_mb(num value) {
    return '$value MB';
  }

  @override
  String settings_storage_gb(num value) {
    return '$value GB';
  }

  @override
  String get settings_storage_100_mb => '100MB';

  @override
  String get settings_storage_500_mb => '500MB';

  @override
  String get settings_storage_1_gb => '1GB';

  @override
  String get settings_storage_2_gb => '2GB';

  @override
  String get settings_storage_unlimited => '無限';

  @override
  String get settings_storage_limits => '限制';

  @override
  String get settings_storage_limits_subtitle => '設定最大快取大小';

  @override
  String get settings_storage_max_image_cache => '最大圖像快取 (MB)';

  @override
  String get settings_storage_max_video_cache => '最大視訊快取 (MB)';

  @override
  String get settings_storage => '儲存與快取';

  @override
  String get settings_storage_usage => '儲存佔用';

  @override
  String get settings_storage_usage_subtitle => '目前快取佔用空間';

  @override
  String get settings_storage_subtitle => '管理本地快取和儲存限制';

  @override
  String get performers_field_name => '姓名';

  @override
  String get performers_field_url => 'URL';

  @override
  String get performers_field_details => '詳情';

  @override
  String get performers_field_birth_year => '出生年份';

  @override
  String get performers_field_age => '年齡';

  @override
  String get performers_field_death_year => '去世年份';

  @override
  String get performers_field_scene_count => '場景數';

  @override
  String get performers_field_image_count => '圖片數';

  @override
  String get performers_field_gallery_count => '圖庫數';

  @override
  String get performers_field_play_count => '播放次數';

  @override
  String get performers_field_o_counter => 'O-計數器';

  @override
  String get performers_field_tag_count => '標籤數';

  @override
  String get performers_field_created_at => '建立於';

  @override
  String get performers_field_updated_at => '更新於';

  @override
  String get galleries_field_title => '標題';

  @override
  String get galleries_field_details => '詳情';

  @override
  String get galleries_field_date => '日期';

  @override
  String get galleries_field_performer_age => '演出者年齡';

  @override
  String get galleries_field_performer_count => '演出者人數';

  @override
  String get galleries_field_tag_count => '標籤數';

  @override
  String get galleries_field_url => 'URL';

  @override
  String get galleries_field_id => 'ID';

  @override
  String get galleries_field_path => '路徑';

  @override
  String get galleries_field_checksum => '校驗和';

  @override
  String get galleries_field_image_count => '圖片數';

  @override
  String get galleries_field_file_count => '文件數';

  @override
  String get galleries_field_created_at => '建立於';

  @override
  String get galleries_field_updated_at => '更新於';

  @override
  String get images_field_title => '標題';

  @override
  String get images_field_details => '詳情';

  @override
  String get images_field_path => '路徑';

  @override
  String get images_field_url => 'URL';

  @override
  String get images_field_file_count => '文件數';

  @override
  String get images_field_o_counter => 'O-計數器';

  @override
  String get studios_field_name => '名稱';

  @override
  String get studios_field_details => '詳情';

  @override
  String get studios_field_aliases => '別名';

  @override
  String get studios_field_url => 'URL';

  @override
  String get studios_field_tag_count => '標籤數';

  @override
  String get studios_field_scene_count => '場景數';

  @override
  String get studios_field_image_count => '圖片數';

  @override
  String get studios_field_gallery_count => '圖庫數';

  @override
  String get studios_field_sub_studio_count => '子工作室數';

  @override
  String get studios_field_created_at => '建立於';

  @override
  String get studios_field_updated_at => '更新於';

  @override
  String get scenes_field_performer_age => '演出者年齡';

  @override
  String get scenes_field_performer_count => '演出者人數';

  @override
  String get scenes_field_tag_count => '標籤數';

  @override
  String get scenes_field_code => '代碼';

  @override
  String get scenes_field_details => '詳情';

  @override
  String get scenes_field_director => '導演';

  @override
  String get scenes_field_url => 'URL';

  @override
  String get scenes_field_date => '日期';

  @override
  String get scenes_field_path => '路徑';

  @override
  String get scenes_field_captions => '字幕';

  @override
  String get scenes_field_duration => '時長（秒）';

  @override
  String get scenes_field_bitrate => '位元率';

  @override
  String get scenes_field_video_codec => '視訊編碼';

  @override
  String get scenes_field_audio_codec => '音訊編碼';

  @override
  String get scenes_field_framerate => '幀率';

  @override
  String get scenes_field_file_count => '文件數';

  @override
  String get scenes_field_play_count => '播放次數';

  @override
  String get scenes_field_play_duration => '播放時長';

  @override
  String get scenes_field_o_counter => 'O-計數器';

  @override
  String get scenes_field_last_played_at => '最後播放於';

  @override
  String get scenes_field_resume_time => '恢復時間';

  @override
  String get scenes_field_interactive_speed => '交互速度';

  @override
  String get scenes_field_id => 'ID';

  @override
  String get scenes_field_stash_id_count => 'Stash ID 數量';

  @override
  String get scenes_field_oshash => 'Oshash';

  @override
  String get scenes_field_checksum => '校驗和';

  @override
  String get scenes_field_phash => 'Phash';

  @override
  String get scenes_field_created_at => '建立於';

  @override
  String get scenes_field_updated_at => '更新於';

  @override
  String get cast_stopped_resuming_locally => '投放已停止，在本地恢復播放';

  @override
  String get cast_stop_casting => '停止投放';

  @override
  String get cast_cast => '投放';

  @override
  String get common_add => '添加';

  @override
  String get common_remove => '移除';

  @override
  String get common_clear => '清除';

  @override
  String get common_download => '下載';

  @override
  String get common_star => '收藏';

  @override
  String get settings_interface_card_title_font_size => '卡片標題字體大小';

  @override
  String get common_hint_date => 'YYYY-MM-DD';

  @override
  String get common_hint_url => 'https://...';

  @override
  String get common_hint_hex => 'FF0F766E';

  @override
  String common_px(int value) {
    return '$value 像素';
  }

  @override
  String common_pt(int value) {
    return '$value 點';
  }

  @override
  String common_percent(int value) {
    return '$value%';
  }

  @override
  String get saving_video => '正在儲存到相簿...';

  @override
  String get saved_to_album => '已儲存到 StashFlow 相簿';

  @override
  String gallery_error(String message) {
    return '相簿錯誤: $message';
  }

  @override
  String failed_to_save(String error) {
    return '儲存失敗: $error';
  }

  @override
  String get saving_image => '正在儲存圖片...';

  @override
  String common_select(String label) {
    return '選擇 $label';
  }

  @override
  String common_saved_to(String path) {
    return '儲存至 $path';
  }

  @override
  String get recent_searches => '最近搜尋';

  @override
  String get initializing_player => '正在初始化播放器...';

  @override
  String get sort_scenes => '排序場景';

  @override
  String get failed_to_load_tap_to_retry => '載入失敗。點擊重試。';

  @override
  String get would_you_like_to_visit_the_release_page_to_download_it =>
      '您想訪問發佈頁面下載嗎？';

  @override
  String get to_get_started_configure_stash_server =>
      '要開始使用，您需要配置您的 Stash 伺服器連接詳細資訊。';

  @override
  String get loading => '載入中';

  @override
  String get wip => 'WIP';

  @override
  String get performer_filters => '演員篩選';

  @override
  String update_available(String version) {
    return 'StashFlow的更新版本 ($version) 已經發布。';
  }

  @override
  String details_failed_update_favorite(String error) {
    return '更新收藏失敗: $error';
  }

  @override
  String details_failed_load_galleries(String error) {
    return '載入圖庫失敗: $error';
  }

  @override
  String get scene_info_id => '場景ID';

  @override
  String get scene_info_original_file_path => '原始檔案路徑';

  @override
  String get scene_info_resume_time => '恢復時間';

  @override
  String get scene_info_play_duration => '播放時長';

  @override
  String get scene_info_urls => '網址';

  @override
  String get scene_info_resolution => '解決';

  @override
  String get scene_info_bitrate => '位元率';

  @override
  String get scene_info_frame_rate => '幀率';

  @override
  String get scene_info_format => '格式';

  @override
  String get scene_info_video_codec => '視訊編解碼器';

  @override
  String get scene_info_audio_codec => '音訊編解碼器';

  @override
  String get scene_info_stream => '溪流';

  @override
  String get scene_info_preview => '預覽';

  @override
  String get scene_info_screenshot => '螢幕截圖';

  @override
  String get scene_info_cover => '封面';

  @override
  String get scene_info_caption => '標題';

  @override
  String get scene_info_vtt => '視聽測試';

  @override
  String get scene_info_sprite => '雪碧';

  @override
  String get scene_info_technical => '技術的';

  @override
  String scene_studio_id(String id) {
    return 'ID：$id';
  }

  @override
  String scene_rating_stars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 星星',
      one: '1 顆星',
    );
    return '$_temp0';
  }

  @override
  String get main_startup_failed => 'StashFlow 啟動失敗';

  @override
  String get main_startup_failed_desc => '在應用程式完成初始化之前啟動服務失敗。檢查診斷後重新啟動應用程式。';

  @override
  String common_searching_for(String query) {
    return '正在搜尋：“$query”';
  }

  @override
  String get cast_device => '裝置';

  @override
  String get auth_enter_passcode => '輸入您的密碼以繼續。';

  @override
  String get auth_unlock => '開鎖';

  @override
  String get auth_incorrect_passcode => '密碼不正確';

  @override
  String get auth_app_locked => '應用程式已鎖定';

  @override
  String get settings_security_passcode => '密碼';

  @override
  String get settings_security_passcode_configured => '已配置';

  @override
  String get settings_security_passcode_not_configured => '未配置';

  @override
  String get settings_security_passcode_saved => '密碼已儲存';

  @override
  String get settings_security_passcode_removed => '密碼已刪除';

  @override
  String get settings_security_enable_app_lock => '啟用應用程式鎖定';

  @override
  String get settings_security_enable_app_lock_subtitle => '應用程式恢復/啟動時需要密碼。';

  @override
  String get settings_security_lock_on_launch => '鎖定應用程式啟動';

  @override
  String get settings_security_lock_on_launch_subtitle => '應用程式開啟時立即詢問密碼。';

  @override
  String get settings_security_background_lock_timer => '後台鎖定定時器';

  @override
  String get settings_security_background_lock_timer_subtitle =>
      '應用程式在鎖定之前可以在背景停留多長時間。';

  @override
  String get settings_security_set_passcode => '設定密碼';

  @override
  String get settings_security_passcode_prompt => '密碼（4-8位）';

  @override
  String get settings_security_confirm_passcode => '確認';

  @override
  String get settings_security_error_numeric => '僅使用數字，長度為 4-8。';

  @override
  String get settings_security_error_mismatch => '密碼不符。';

  @override
  String get common_change => '改變';

  @override
  String get common_set => '設定';

  @override
  String get common_immediately => '立即地';

  @override
  String common_sec(int value) {
    return '$value 秒';
  }

  @override
  String common_min(int value) {
    return '$value 分鐘';
  }

  @override
  String common_s(int value) {
    return '${value}s';
  }

  @override
  String get settings_security_title => '安全';

  @override
  String get settings_security_subtitle => '應用鎖和密碼設定';

  @override
  String get settings_security_app_lock => '應用鎖';

  @override
  String get settings_security_app_lock_subtitle => '後台運行後使用密碼保護存取。';

  @override
  String get common_saved_filters => '已儲存的過濾器';

  @override
  String get tools => '工具';

  @override
  String get tools_section_subtitle => '場景的維護和元數據工作流。';

  @override
  String get tools_scene_deduplication_subtitle => '查找並管理重複的場景。';

  @override
  String get tools_scene_tagger_subtitle => '使用 Stash-box 刮削當前場景頁面。';

  @override
  String get preset_deleted => '預設已刪除';

  @override
  String get delete_preset => '刪除預設';

  @override
  String get common_delete => '刪除';

  @override
  String get save_preset => '儲存預設';

  @override
  String get no_saved_presets => '沒有儲存的預設';

  @override
  String get scene_tagger => '場景標註';

  @override
  String get page_size => '每頁數量';

  @override
  String get mode => '模式';

  @override
  String get sort => '排序';

  @override
  String get desc => '降冪';

  @override
  String get asc => '升冪';

  @override
  String get filter => '篩選';

  @override
  String get load_preset => '載入預設';

  @override
  String get preset => '預設';

  @override
  String get stash_box_scraper => 'Stash Box 擷取器';

  @override
  String get start_tagging => '開始標註';

  @override
  String get stop => '停止';

  @override
  String get open_scene => '開啟場景';

  @override
  String get skip => '跳過';

  @override
  String get apply => '套用';

  @override
  String get selected => '已選擇';

  @override
  String get select => '選擇';

  @override
  String get preview => '預覽';

  @override
  String get delete_scene => '刪除場景';

  @override
  String get metadata_only => '僅元數據';

  @override
  String get files => '文件';

  @override
  String get scene_deleted => '場景已刪除';

  @override
  String get delete_metadata => '刪除元數據';

  @override
  String get delete_files => '刪除文件';

  @override
  String get scene_deduplication => '場景去重';

  @override
  String get no_duplicates_found => '沒有發現重複項。';

  @override
  String get search_accuracy => '搜尋準確率';

  @override
  String get duration_difference => '持續時間差異';

  @override
  String get only_select_matching_codecs => '僅選擇相符的編解碼器';

  @override
  String get select_scenes => '選擇場景';

  @override
  String get all_but_largest_resolution => '除最大分辨率外的所有分辨率';

  @override
  String get all_but_largest_file => '除最大文件外的所有文件';

  @override
  String get all_but_oldest => '除最舊項外全部';

  @override
  String get all_but_youngest => '除最新項外全部';

  @override
  String get select_none => '取消全選';

  @override
  String get merge => '合併';

  @override
  String get previous_page => '上一頁';

  @override
  String get next_page => '下一頁';

  @override
  String scene_deduplication_page_count(int page, int totalPages) {
    return '第 $page 頁，共 $totalPages 頁';
  }

  @override
  String scene_tagger_result_count(int index, int total) {
    return '結果 $index / $total';
  }

  @override
  String delete_preset_confirm(String name) {
    return '刪除“$name”？此操作無法撤銷。';
  }

  @override
  String get enter_preset_name => '輸入預設名稱';

  @override
  String get delete_scene_confirm => '您確定要刪除該場景嗎？';

  @override
  String delete_selected_count(int selectedCount) {
    return '刪除所選內容 ($selectedCount)';
  }

  @override
  String get saved_presets => '已儲存的預設';

  @override
  String get current_settings => '目前設定';

  @override
  String get available_presets => '可用預設';

  @override
  String get existing_names_are_overwritten => '現有名稱將會被覆寫';

  @override
  String get active_settings_saved_server => '目前生效的設定將儲存到伺服器。';

  @override
  String failed_to_save_filter(String error) {
    return '無法儲存篩選器：$error';
  }

  @override
  String failed_to_delete_preset(String error) {
    return '無法刪除預設：$error';
  }

  @override
  String sort_label(String sortLabel) {
    return '排序：$sortLabel';
  }

  @override
  String filters_count(int count) {
    return '篩選器：$count';
  }

  @override
  String search_label(String query) {
    return '搜尋：$query';
  }

  @override
  String failed_to_load_presets(String error) {
    return '無法載入預設：$error';
  }

  @override
  String saved_item(String item) {
    return '已儲存 $item';
  }

  @override
  String unable_to_load_stash_boxes(String error) {
    return '無法載入 Stash Box：$error';
  }

  @override
  String delete_n_scenes_question(int count) {
    return '刪除 $count 個場景？';
  }

  @override
  String get delete_scenes_help => '選擇僅刪除 Stash 中繼資料，還是同時刪除場景檔案及其產生的輔助檔案。';

  @override
  String deleted_n_scenes(int count) {
    return '已刪除 $count 個場景';
  }

  @override
  String delete_failed_error(String error) {
    return '刪除失敗：$error';
  }

  @override
  String get configuration => '設定';

  @override
  String missing_phashes_for_scenes(int count) {
    return '$count 個場景缺少感知雜湊。請執行感知雜湊產生任務。';
  }

  @override
  String get merge_editing_not_wired => 'StashFlow 尚未支援合併編輯。';

  @override
  String duplicate_sets_count(int count) {
    return '$count 組重複項';
  }

  @override
  String duplicate_set_number(int number) {
    return '重複組 $number';
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

    return '$countString 個標籤';
  }

  @override
  String nGroups(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '$countString 個分組';
  }

  @override
  String nMarkers(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '$countString 個標記';
  }

  @override
  String nGalleries(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '$countString 個畫廊';
  }

  @override
  String scene_tagger_checked_matches_summary(int checked, int matches) {
    return '已檢查 $checked 項 • $matches 個符合項目';
  }

  @override
  String scene_tagger_page_summary(int count) {
    return '本頁 $count 個場景';
  }

  @override
  String get no_matched_scenes_yet => '還沒有符合的場景。';

  @override
  String get no_scenes_match_configuration => '沒有場景符合此設定。';

  @override
  String scene_tagger_checked_count(int count) {
    return '已檢查 $count 項';
  }

  @override
  String scene_tagger_progress(int checked, int total) {
    return '$checked / $total';
  }

  @override
  String get stats_library_stats_tooltip => '長按查看資料庫統計';

  @override
  String get scene_details_marker_created => '標記已建立';

  @override
  String scene_details_failed_to_create_marker(String error) {
    return '無法建立標記：$error';
  }

  @override
  String get scene_details_delete_marker_title => '刪除標記';

  @override
  String scene_details_delete_marker_content(String title) {
    return '刪除標記“$title”嗎？';
  }

  @override
  String get scene_details_marker_deleted => '標記已刪除';

  @override
  String scene_details_failed_to_delete_marker(String error) {
    return '無法刪除標記：$error';
  }

  @override
  String get scene_details_add_marker => '添加標記';

  @override
  String get scene_details_create_marker => '創造';

  @override
  String scene_details_delete_marker_tooltip(String title) {
    return '刪除標記 $title';
  }

  @override
  String get scenes_page_markers_tooltip => '標記';

  @override
  String get auto_marker_name => '標記名稱';

  @override
  String get auto_missing_field => '缺失字段';

  @override
  String get filter_markers_title => '過濾標記';

  @override
  String get marker_title => '標記';

  @override
  String get duration_title => '期間';

  @override
  String get scene_title => '場景';

  @override
  String get dates_title => '棗子';

  @override
  String get created_at_title => '創建於';

  @override
  String get updated_at_title => '更新於';

  @override
  String get scene_date_title => '場景日期';

  @override
  String get scene_created_at_title => '場景創建於';

  @override
  String get scene_updated_at_title => '場景更新於';

  @override
  String get organized_title => '有組織';

  @override
  String get interactive_title => '互動的';

  @override
  String get scraped_metadata_title => '抓取的元數據';

  @override
  String get local_scene_title => '當地場景';

  @override
  String get sort_markers_title => '對標記進行排序';

  @override
  String get markers_title => '標記';

  @override
  String get sub_group_count_title => '子組計數';

  @override
  String get groups_browsing_mode_subtitle => '群組的預設瀏覽模式';

  @override
  String get markers_browsing_mode_subtitle => '標記的預設瀏覽模式';

  @override
  String get entity_layouts_title => '實體佈局';

  @override
  String get entity_layouts_subtitle => '表演者、工作室和標籤的媒體和畫廊佈局預設值';

  @override
  String get stats_subtitle_0_gb => '0.00GB';

  @override
  String get stats_subtitle_0_unique_items => '0 件獨特物品';

  @override
  String get markers_search_hint => '搜尋標記';

  @override
  String get tags_title => '標籤';

  @override
  String get scenes_title => '場景';
}
