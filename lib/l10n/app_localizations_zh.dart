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
  String get common_no => '不';

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
  String get common_update_now => '立即更新';

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
  String get common_more => 'More';

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
  String get filter_equals => '等于';

  @override
  String get filter_not_equals => '不等于';

  @override
  String get filter_greater_than => '大于';

  @override
  String get filter_less_than => '小于';

  @override
  String get filter_is_null => '为空';

  @override
  String get filter_not_null => '不为空';

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
  String get settings_server_url => 'Stash URL';

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
    return '$count unique items';
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
  String get performers_field_name => 'Name';

  @override
  String get performers_field_url => 'URL';

  @override
  String get performers_field_details => 'Details';

  @override
  String get performers_field_birth_year => 'Birth Year';

  @override
  String get performers_field_age => 'Age';

  @override
  String get performers_field_death_year => 'Death Year';

  @override
  String get performers_field_scene_count => 'Scene Count';

  @override
  String get performers_field_image_count => 'Image Count';

  @override
  String get performers_field_gallery_count => 'Gallery Count';

  @override
  String get performers_field_play_count => 'Play Count';

  @override
  String get performers_field_o_counter => 'O-Counter';

  @override
  String get performers_field_tag_count => 'Tag Count';

  @override
  String get performers_field_created_at => 'Created At';

  @override
  String get performers_field_updated_at => 'Updated At';

  @override
  String get galleries_field_title => 'Title';

  @override
  String get galleries_field_details => 'Details';

  @override
  String get galleries_field_date => 'Date';

  @override
  String get galleries_field_performer_age => 'Performer Age';

  @override
  String get galleries_field_performer_count => 'Performer Count';

  @override
  String get galleries_field_tag_count => 'Tag Count';

  @override
  String get galleries_field_url => 'URL';

  @override
  String get galleries_field_id => 'ID';

  @override
  String get galleries_field_path => 'Path';

  @override
  String get galleries_field_checksum => 'Checksum';

  @override
  String get galleries_field_image_count => 'Image Count';

  @override
  String get galleries_field_file_count => 'File Count';

  @override
  String get galleries_field_created_at => 'Created At';

  @override
  String get galleries_field_updated_at => 'Updated At';

  @override
  String get images_field_title => 'Title';

  @override
  String get images_field_details => 'Details';

  @override
  String get images_field_path => 'Path';

  @override
  String get images_field_url => 'URL';

  @override
  String get images_field_file_count => 'File Count';

  @override
  String get images_field_o_counter => 'O-Counter';

  @override
  String get studios_field_name => 'Name';

  @override
  String get studios_field_details => 'Details';

  @override
  String get studios_field_aliases => 'Aliases';

  @override
  String get studios_field_url => 'URL';

  @override
  String get studios_field_tag_count => 'Tag Count';

  @override
  String get studios_field_scene_count => 'Scene Count';

  @override
  String get studios_field_image_count => 'Image Count';

  @override
  String get studios_field_gallery_count => 'Gallery Count';

  @override
  String get studios_field_sub_studio_count => 'Sub-studio Count';

  @override
  String get studios_field_created_at => 'Created At';

  @override
  String get studios_field_updated_at => 'Updated At';

  @override
  String get scenes_field_performer_age => 'Performer Age';

  @override
  String get scenes_field_performer_count => 'Performer Count';

  @override
  String get scenes_field_tag_count => 'Tag Count';

  @override
  String get scenes_field_code => 'Code';

  @override
  String get scenes_field_details => 'Details';

  @override
  String get scenes_field_director => 'Director';

  @override
  String get scenes_field_url => 'URL';

  @override
  String get scenes_field_date => 'Date';

  @override
  String get scenes_field_path => 'Path';

  @override
  String get scenes_field_captions => 'Captions';

  @override
  String get scenes_field_duration => 'Duration (seconds)';

  @override
  String get scenes_field_bitrate => 'Bitrate';

  @override
  String get scenes_field_video_codec => 'Video Codec';

  @override
  String get scenes_field_audio_codec => 'Audio Codec';

  @override
  String get scenes_field_framerate => 'Framerate';

  @override
  String get scenes_field_file_count => 'File Count';

  @override
  String get scenes_field_play_count => 'Play Count';

  @override
  String get scenes_field_play_duration => 'Play Duration';

  @override
  String get scenes_field_o_counter => 'O-Counter';

  @override
  String get scenes_field_last_played_at => 'Last Played At';

  @override
  String get scenes_field_resume_time => 'Resume Time';

  @override
  String get scenes_field_interactive_speed => 'Interactive Speed';

  @override
  String get scenes_field_id => 'ID';

  @override
  String get scenes_field_stash_id_count => 'Stash ID Count';

  @override
  String get scenes_field_oshash => 'Oshash';

  @override
  String get scenes_field_checksum => 'Checksum';

  @override
  String get scenes_field_phash => 'Phash';

  @override
  String get scenes_field_created_at => 'Created At';

  @override
  String get scenes_field_updated_at => 'Updated At';

  @override
  String get cast_stopped_resuming_locally => 'Cast stopped, resuming locally';

  @override
  String get cast_stop_casting => 'Stop Casting';

  @override
  String get cast_cast => 'Cast';

  @override
  String get common_add => 'Add';

  @override
  String get common_remove => 'Remove';

  @override
  String get common_clear => 'Clear';

  @override
  String get common_download => 'Download';

  @override
  String get common_star => 'Star';

  @override
  String get settings_interface_card_title_font_size => 'Card Title Font Size';

  @override
  String get common_hint_date => 'YYYY-MM-DD';

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
  String get settings_playback_direct_play => 'Direct-play on scene navigation';

  @override
  String get settings_playback_direct_play_subtitle =>
      'When navigating from another playing scene, directly play the new scene';
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
  String get common_no => '不';

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
  String get common_update_now => '立即更新';

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
  String get filter_equals => '等于';

  @override
  String get filter_not_equals => '不等于';

  @override
  String get filter_greater_than => '大于';

  @override
  String get filter_less_than => '小于';

  @override
  String get filter_is_null => '为空';

  @override
  String get filter_not_null => '不为空';

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
  String get settings_server_url => 'Stash URL';

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
    return '$count unique items';
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
  String get common_no => '不';

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
  String get common_update_now => '立即更新';

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
  String get filter_equals => '等于';

  @override
  String get filter_not_equals => '不等于';

  @override
  String get filter_greater_than => '大于';

  @override
  String get filter_less_than => '小于';

  @override
  String get filter_is_null => '为空';

  @override
  String get filter_not_null => '不为空';

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
  String get settings_server_url => 'Stash URL';

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
    return '$count unique items';
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
}
