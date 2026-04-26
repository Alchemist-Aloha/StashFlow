// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'StashFlow';

  @override
  String get nav_scenes => 'シーン';

  @override
  String get nav_performers => 'パフォーマー';

  @override
  String get nav_studios => 'スタジオ';

  @override
  String get nav_tags => 'タグ';

  @override
  String get nav_galleries => 'ギャラリー';

  @override
  String nScenes(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString シーン',
      one: '1 シーン',
      zero: 'シーンなし',
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
      other: '$countString パフォーマー',
      one: '1 パフォーマー',
      zero: 'パフォーマーなし',
    );
    return '$_temp0';
  }

  @override
  String get common_reset => 'リセット';

  @override
  String get common_apply => '適用';

  @override
  String get common_save_default => 'デフォルトとして保存';

  @override
  String get common_sort_method => '並べ替え方法';

  @override
  String get common_direction => '方向';

  @override
  String get common_ascending => '昇順';

  @override
  String get common_descending => '降順';

  @override
  String get common_favorites_only => 'お気に入りのみ';

  @override
  String get common_apply_sort => '並べ替えを適用';

  @override
  String get common_apply_filters => 'フィルターを適用';

  @override
  String get common_view_all => 'すべて表示';

  @override
  String get common_default => 'デフォルト';

  @override
  String get common_later => '後で';

  @override
  String get common_update_now => '今すぐ更新';

  @override
  String get common_configure_now => '今すぐ設定';

  @override
  String get common_clear_rating => '評価をクリア';

  @override
  String get common_no_media => 'メディアがありません';

  @override
  String get common_show => '表示';

  @override
  String get common_hide => '非表示';

  @override
  String get galleries_filter_saved => 'ギャラリーフィルターの設定がデフォルトとして保存されました';

  @override
  String get common_setup_required => '設定が必要です';

  @override
  String get common_update_available => 'アップデートがあります';

  @override
  String get details_studio => 'スタジオ詳細';

  @override
  String get details_performer => 'パフォーマー詳細';

  @override
  String get details_tag => 'タグ詳細';

  @override
  String get details_scene => 'シーン詳細';

  @override
  String get details_gallery => 'ギャラリー詳細';

  @override
  String get studios_filter_title => 'スタジオをフィルター';

  @override
  String get studios_filter_saved => 'フィルター設定をデフォルトとして保存しました';

  @override
  String get sort_name => '名前';

  @override
  String get sort_scene_count => 'シーン数';

  @override
  String get sort_rating => '評価';

  @override
  String get sort_updated_at => '更新日';

  @override
  String get sort_created_at => '作成日';

  @override
  String get sort_random => 'ランダム';

  @override
  String get sort_file_mod_time => 'ファイル更新日時';

  @override
  String get sort_filesize => 'ファイルサイズ';

  @override
  String get sort_o_count => 'Oカウンター';

  @override
  String get sort_height => '身長';

  @override
  String get sort_birthdate => '生年月日';

  @override
  String get sort_tag_count => 'タグ数';

  @override
  String get sort_play_count => '再生回数';

  @override
  String get sort_o_counter => 'Oカウンター';

  @override
  String get sort_zip_file_count => 'ZIPファイル数';

  @override
  String get sort_last_o_at => '最終O日時';

  @override
  String get sort_latest_scene => '最新シーン';

  @override
  String get sort_career_start => 'キャリア開始';

  @override
  String get sort_career_end => 'キャリア終了';

  @override
  String get sort_weight => '体重';

  @override
  String get sort_measurements => 'スリーサイズ';

  @override
  String get sort_scenes_duration => 'シーンの合計時間';

  @override
  String get sort_scenes_size => 'シーンのサイズ';

  @override
  String get sort_images_count => '画像数';

  @override
  String get sort_galleries_count => 'ギャラリー数';

  @override
  String get sort_child_count => 'サブスタジオ数';

  @override
  String get sort_performers_count => '出演者数';

  @override
  String get sort_groups_count => 'グループ数';

  @override
  String get sort_marker_count => 'マーカー数';

  @override
  String get sort_studios_count => 'スタジオ数';

  @override
  String get sort_penis_length => 'ペニスの長さ';

  @override
  String get sort_last_played_at => '最終再生日時';

  @override
  String get studios_sort_saved => '並べ替え設定をデフォルトとして保存しました';

  @override
  String get studios_no_random => 'ランダムナビゲーションに使用できるスタジオがありません';

  @override
  String get tags_filter_title => 'タグをフィルター';

  @override
  String get tags_filter_saved => 'フィルター設定をデフォルトとして保存しました';

  @override
  String get tags_sort_title => 'タグを並べ替え';

  @override
  String get tags_sort_saved => '並べ替え設定をデフォルトとして保存しました';

  @override
  String get tags_no_random => 'ランダムナビゲーションに使用できるタグがありません';

  @override
  String get scenes_no_random => 'ランダムナビゲーションに使用できるシーンがありません';

  @override
  String get performers_no_random => 'ランダムナビゲーションに使用できるパフォーマーがありません';

  @override
  String get galleries_no_random => 'ランダムナビゲーションに使用できるギャラリーがありません';

  @override
  String common_error(String message) {
    return 'エラー: $message';
  }

  @override
  String get common_no_media_available => 'メディアなし';

  @override
  String common_id(Object id) {
    return 'ID: $id';
  }

  @override
  String get common_search_placeholder => '検索...';

  @override
  String get common_pause => '一時停止';

  @override
  String get common_play => '再生';

  @override
  String get common_close => '閉じる';

  @override
  String get common_save => '保存';

  @override
  String get common_unmute => 'ミュート解除';

  @override
  String get common_mute => 'ミュート';

  @override
  String get common_back => '戻る';

  @override
  String get common_rate => '評価する';

  @override
  String get common_previous => '前へ';

  @override
  String get common_next => '次へ';

  @override
  String get common_favorite => 'お気に入り';

  @override
  String get common_unfavorite => 'お気に入り解除';

  @override
  String get common_version => 'バージョン';

  @override
  String get common_loading => '読み込み中';

  @override
  String get common_unavailable => '利用不可';

  @override
  String get common_details => '詳細';

  @override
  String get common_title => 'タイトル';

  @override
  String get common_release_date => '公開日';

  @override
  String get common_url => 'リンク';

  @override
  String get common_no_url => 'URLなし';

  @override
  String get common_sort => '並べ替え';

  @override
  String get common_filter => 'フィルター';

  @override
  String get common_search => '検索';

  @override
  String get common_settings => '設定';

  @override
  String get common_reset_to_1x => '1倍にリセット';

  @override
  String get common_skip_next => '次をスキップ';

  @override
  String get common_select_subtitle => '字幕を選択';

  @override
  String get common_playback_speed => '再生速度';

  @override
  String get common_pip => 'ピクチャーインピクチャー';

  @override
  String get common_toggle_fullscreen => '全画面切替';

  @override
  String get common_exit_fullscreen => '全画面終了';

  @override
  String get common_copy_logs => 'ログをコピー';

  @override
  String get common_clear_logs => 'ログをクリア';

  @override
  String get common_enable_autoscroll => '自動スクロール有効';

  @override
  String get common_disable_autoscroll => '自動スクロール無効';

  @override
  String get common_retry => '再試行';

  @override
  String get common_no_items => '項目が見つかりませんでした';

  @override
  String get common_none => 'なし';

  @override
  String get common_any => '任意';

  @override
  String get common_name => '名前';

  @override
  String get common_date => '日付';

  @override
  String get common_rating => '評価';

  @override
  String get common_image_count => '画像数';

  @override
  String get common_filepath => 'ファイルパス';

  @override
  String get common_random => 'ランダム';

  @override
  String get common_no_media_found => 'メディアが見つかりませんでした';

  @override
  String common_not_found(String item) {
    return '$item が見つかりません';
  }

  @override
  String get common_add_favorite => 'お気に入りに追加';

  @override
  String get common_remove_favorite => 'お気に入りから削除';

  @override
  String get details_group => 'グループ詳細';

  @override
  String get details_synopsis => 'あらすじ';

  @override
  String get details_media => 'メディア';

  @override
  String get details_galleries => 'ギャラリー';

  @override
  String get details_tags => 'タグ';

  @override
  String get details_links => 'リンク';

  @override
  String get details_scene_scrape => 'メタデータ取得';

  @override
  String get details_show_more => 'もっと見る';

  @override
  String get details_show_less => '簡易表示';

  @override
  String get details_more_from_studio => 'スタジオのその他';

  @override
  String get details_o_count_incremented => 'Oカウントが増えました';

  @override
  String details_failed_update_rating(String error) {
    return '評価の更新に失敗しました: $error';
  }

  @override
  String details_failed_update_performer(Object error) {
    return '出演者の更新に失敗しました: $error';
  }

  @override
  String details_failed_increment_o_count(String error) {
    return 'Oカウントの増加に失敗しました: $error';
  }

  @override
  String get details_scene_add_performer => '出演者を追加';

  @override
  String get details_scene_add_tag => 'タグを追加';

  @override
  String get details_scene_add_url => 'URLを追加';

  @override
  String get details_scene_remove_url => 'URLを削除';

  @override
  String get groups_title => 'グループ';

  @override
  String get groups_unnamed => '名前なしグループ';

  @override
  String get groups_untitled => '無題のグループ';

  @override
  String get studios_title => 'スタジオ';

  @override
  String get studios_galleries_title => 'スタジオギャラリー';

  @override
  String get studios_media_title => 'スタジオメディア';

  @override
  String get studios_sort_title => 'スタジオを並べ替え';

  @override
  String get galleries_title => 'ギャラリー';

  @override
  String get galleries_sort_title => 'ギャラリーを並べ替え';

  @override
  String get galleries_all_images => 'すべての画像';

  @override
  String get galleries_filter_title => 'ギャラリーをフィルター';

  @override
  String get galleries_min_rating => '最小評価';

  @override
  String get galleries_image_count => '画像数';

  @override
  String get galleries_organization => '整理状態';

  @override
  String get galleries_organized_only => '整理済みのみ';

  @override
  String get scenes_filter_title => 'シーンをフィルター';

  @override
  String get scenes_filter_saved => 'フィルター設定をデフォルトとして保存しました';

  @override
  String get scenes_watched => '視聴済み';

  @override
  String get scenes_unwatched => '未視聴';

  @override
  String get scenes_search_hint => 'シーンを検索...';

  @override
  String get scenes_sort_header => 'シーンを並べ替え';

  @override
  String get scenes_sort_duration => '長さ';

  @override
  String get scenes_sort_bitrate => 'ビットレート';

  @override
  String get scenes_sort_framerate => 'フレームレート';

  @override
  String get scenes_sort_saved_default => '並べ替えの設定がデフォルトとして保存されました';

  @override
  String get scenes_sort_tooltip => 'ソートオプション';

  @override
  String get tags_search_hint => 'タグを検索...';

  @override
  String get tags_sort_tooltip => 'ソートオプション';

  @override
  String get tags_filter_tooltip => 'フィルターオプション';

  @override
  String get performers_title => 'パフォーマー';

  @override
  String get performers_sort_title => 'パフォーマーを並べ替え';

  @override
  String get performers_filter_title => 'パフォーマーをフィルター';

  @override
  String get performers_galleries_title => 'すべてのパフォーマーギャラリー';

  @override
  String get performers_media_title => 'すべてのパフォーマーメディア';

  @override
  String get performers_gender => '性別';

  @override
  String get performers_gender_any => '任意';

  @override
  String get performers_gender_female => '女性';

  @override
  String get performers_gender_male => '男性';

  @override
  String get performers_gender_trans_female => 'トランス女性';

  @override
  String get performers_gender_trans_male => 'トランス男性';

  @override
  String get performers_gender_intersex => 'インターセックス';

  @override
  String get performers_gender_non_binary => 'ノンバイナリー';

  @override
  String get performers_circumcised => '包茎';

  @override
  String get performers_circumcised_cut => '切除';

  @override
  String get performers_circumcised_uncut => '非切除';

  @override
  String get performers_play_count => '再生回数';

  @override
  String get performers_field_disambiguation => '識別';

  @override
  String get performers_field_birthdate => '生年月日';

  @override
  String get performers_field_deathdate => '死亡日';

  @override
  String get performers_field_height_cm => '身長 (cm)';

  @override
  String get performers_field_weight_kg => '体重 (kg)';

  @override
  String get performers_field_measurements => 'サイズ';

  @override
  String get performers_field_fake_tits => '豊胸';

  @override
  String get performers_field_penis_length => 'ペニスの長さ';

  @override
  String get performers_field_ethnicity => '人種';

  @override
  String get performers_field_country => '国';

  @override
  String get performers_field_eye_color => '目の色';

  @override
  String get performers_field_hair_color => '髪の色';

  @override
  String get performers_field_career_start => 'キャリア開始';

  @override
  String get performers_field_career_end => 'キャリア終了';

  @override
  String get performers_field_tattoos => 'タトゥー';

  @override
  String get performers_field_piercings => 'ピアス';

  @override
  String get performers_field_aliases => '別名';

  @override
  String get common_organized => '整理済み';

  @override
  String get scenes_duplicated => '重複';

  @override
  String get random_studio => 'ランダムなスタジオ';

  @override
  String get random_gallery => 'ランダムなギャラリー';

  @override
  String get random_tag => 'ランダムなタグ';

  @override
  String get random_scene => 'ランダムなシーン';

  @override
  String get random_performer => 'ランダムな出演者';

  @override
  String get filter_modifier => '修飾子';

  @override
  String get filter_value => '値';

  @override
  String get filter_equals => '等しい';

  @override
  String get filter_not_equals => '等しくない';

  @override
  String get filter_greater_than => 'より大きい';

  @override
  String get filter_less_than => 'より小さい';

  @override
  String get filter_is_null => 'ヌルです';

  @override
  String get filter_not_null => 'ヌルではありません';

  @override
  String get images_resolution_title => '解像度';

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
  String get images_orientation_title => '画像の向き';

  @override
  String get common_or => 'または';

  @override
  String get scrape_from_url => 'URLからスクレイプ';

  @override
  String get scenes_phash_started => 'Phash生成を開始しました';

  @override
  String scenes_phash_failed(Object error) {
    return 'Phashの生成に失敗しました: $error';
  }

  @override
  String details_failed_update_studio(Object error) {
    return 'スタジオの更新に失敗しました: $error';
  }

  @override
  String get settings_title => '設定';

  @override
  String get settings_customize => 'StashFlowをカスタマイズ';

  @override
  String get settings_customize_subtitle => '再生、外観、レイアウト、サポートツールを1か所で調整します。';

  @override
  String get settings_core_section => '基本設定';

  @override
  String get settings_core_subtitle => 'よく使われる設定ページ';

  @override
  String get settings_server => 'サーバー';

  @override
  String get settings_server_subtitle => '接続とAPIの設定';

  @override
  String get settings_playback => '再生';

  @override
  String get settings_playback_subtitle => 'プレーヤーの動作と操作';

  @override
  String get settings_keyboard => 'キーボード';

  @override
  String get settings_keyboard_subtitle => 'カスタマイズ可能なショートカットとホットキー';

  @override
  String get settings_keyboard_title => 'キーボードショートカット';

  @override
  String get settings_keyboard_reset_defaults => 'デフォルトに戻す';

  @override
  String get settings_keyboard_not_bound => '未割り当て';

  @override
  String get settings_keyboard_volume_up => '音量を上げる';

  @override
  String get settings_keyboard_volume_down => '音量を下げる';

  @override
  String get settings_keyboard_toggle_mute => 'ミュート切替';

  @override
  String get settings_keyboard_toggle_fullscreen => '全画面切替';

  @override
  String get settings_keyboard_next_scene => '次のシーン';

  @override
  String get settings_keyboard_prev_scene => '前のシーン';

  @override
  String get settings_keyboard_increase_speed => '再生速度を上げる';

  @override
  String get settings_keyboard_decrease_speed => '再生速度を下げる';

  @override
  String get settings_keyboard_reset_speed => '再生速度をリセット';

  @override
  String get settings_keyboard_close_player => 'プレーヤーを閉じる';

  @override
  String get settings_keyboard_next_image => '次の画像';

  @override
  String get settings_keyboard_prev_image => '前の画像';

  @override
  String get settings_keyboard_go_back => '戻る';

  @override
  String get settings_keyboard_play_pause_desc => '動画の再生と一時停止を切り替えます';

  @override
  String get settings_keyboard_seek_forward_5_desc => '5秒進む';

  @override
  String get settings_keyboard_seek_backward_5_desc => '5秒戻る';

  @override
  String get settings_keyboard_seek_forward_10_desc => '10秒進む';

  @override
  String get settings_keyboard_seek_backward_10_desc => '10秒戻る';

  @override
  String get settings_appearance => '外観';

  @override
  String get settings_appearance_subtitle => 'テーマと色';

  @override
  String get settings_interface => 'インターフェース';

  @override
  String get settings_interface_subtitle => 'ナビゲーションとレイアウトのデフォルト';

  @override
  String get settings_support => 'サポート';

  @override
  String get settings_support_subtitle => '診断と情報';

  @override
  String get settings_develop => '開発';

  @override
  String get settings_develop_subtitle => '高度なツールとオーバーライド';

  @override
  String get settings_appearance_title => '外観設定';

  @override
  String get settings_appearance_theme_mode => 'テーマモード';

  @override
  String get settings_appearance_theme_mode_subtitle => 'アプリが明るさの変化に従う方法を選択します';

  @override
  String get settings_appearance_theme_system => 'システム';

  @override
  String get settings_appearance_theme_light => 'ライト';

  @override
  String get settings_appearance_theme_dark => 'ダーク';

  @override
  String get settings_appearance_primary_color => 'プライマリーカラー';

  @override
  String get settings_appearance_primary_color_subtitle =>
      'Material 3パレットのシードカラーを選択します';

  @override
  String get settings_appearance_advanced_theming => '高度なテーマ設定';

  @override
  String get settings_appearance_advanced_theming_subtitle => '特定の画面タイプ向けの最適化';

  @override
  String get settings_appearance_true_black => 'トゥルーブラック (AMOLED)';

  @override
  String get settings_appearance_true_black_subtitle =>
      'ダークモードで純粋な黒の背景を使用し、OLED画面のバッテリーを節約します';

  @override
  String get settings_appearance_custom_hex => 'カスタム16進数カラー';

  @override
  String get settings_appearance_custom_hex_helper => '8桁のARGB 16進コードを入力してください';

  @override
  String get settings_interface_title => 'インターフェース設定';

  @override
  String get settings_interface_language => '言語';

  @override
  String get settings_interface_language_subtitle => 'デフォルトのシステム言語を上書きします';

  @override
  String get settings_interface_app_language => 'アプリの言語';

  @override
  String get settings_interface_navigation => 'ナビゲーション';

  @override
  String get settings_interface_navigation_subtitle =>
      'グローバルナビゲーションショートカットの表示設定';

  @override
  String get settings_interface_show_random => 'ランダムナビゲーションボタンを表示';

  @override
  String get settings_interface_show_random_subtitle =>
      'リストおよび詳細ページでフローティングカジノボタンを有効または無効にします';

  @override
  String get settings_interface_shake_random => 'シェイクして発見';

  @override
  String get settings_interface_shake_random_subtitle =>
      'デバイスを振って、現在のタブのランダムなアイテムにジャンプします';

  @override
  String get settings_interface_main_pages_gravity_orientation =>
      '重力制御の画面向き（メインページ）';

  @override
  String get settings_interface_main_pages_gravity_orientation_subtitle =>
      'デバイスセンサーを使ってメインページの向きを回転できるようにします。全画面動画再生は専用の画面向き設定に従います。';

  @override
  String get settings_interface_show_edit => '編集ボタンを表示';

  @override
  String get settings_interface_show_edit_subtitle =>
      'シーン詳細ページの編集ボタンを有効または無効にします';

  @override
  String get settings_interface_customize_tabs => 'タブをカスタマイズ';

  @override
  String get settings_interface_customize_tabs_subtitle =>
      'ナビゲーションメニュー項目の並べ替えや非表示を行います';

  @override
  String get settings_interface_scenes_layout => 'シーンのレイアウト';

  @override
  String get settings_interface_scenes_layout_subtitle => 'シーンのデフォルト閲覧モード';

  @override
  String get settings_interface_galleries_layout => 'ギャラリーのレイアウト';

  @override
  String get settings_interface_galleries_layout_subtitle => 'ギャラリーのデフォルト閲覧モード';

  @override
  String get settings_interface_max_performer_avatars =>
      'パフォーマーの最大アバター数（デスクトップ）';

  @override
  String get settings_interface_max_performer_avatars_subtitle =>
      'デスクトップのシーンカードに表示するパフォーマーのアバターの最大数。';

  @override
  String get settings_interface_layout_default => 'デフォルトレイアウト';

  @override
  String get settings_interface_layout_default_desc => 'ページのデフォルトレイアウトを選択します';

  @override
  String get settings_interface_layout_list => 'リスト';

  @override
  String get settings_interface_layout_grid => 'グリッド';

  @override
  String get settings_interface_layout_tiktok => '無限スクロール';

  @override
  String get settings_interface_grid_columns => 'グリッドの列数';

  @override
  String get settings_interface_image_viewer => '画像ビューアー';

  @override
  String get settings_interface_image_viewer_subtitle => 'フルスクリーン画像閲覧の動作を設定します';

  @override
  String get settings_interface_swipe_direction => 'フルスクリーンスワイプ方向';

  @override
  String get settings_interface_swipe_direction_desc =>
      'フルスクリーンモードで画像を切り替える方法を選択します';

  @override
  String get settings_interface_swipe_vertical => '垂直';

  @override
  String get settings_interface_swipe_horizontal => '水平';

  @override
  String get settings_interface_waterfall_columns => 'ウォーターフォールグリッドの列数';

  @override
  String get settings_interface_performer_layouts => 'パフォーマーのレイアウト';

  @override
  String get settings_interface_performer_layouts_subtitle =>
      'パフォーマーのメディアおよびギャラリーのデフォルト設定';

  @override
  String get settings_interface_studio_layouts => 'スタジオのレイアウト';

  @override
  String get settings_interface_studio_layouts_subtitle =>
      'スタジオのメディアおよびギャラリーのデフォルト設定';

  @override
  String get settings_interface_tag_layouts => 'タグのレイアウト';

  @override
  String get settings_interface_tag_layouts_subtitle =>
      'タグのメディアおよびギャラリーのデフォルト設定';

  @override
  String get settings_interface_media_layout => 'メディアのレイアウト';

  @override
  String get settings_interface_media_layout_subtitle => 'メディアページのレイアウト';

  @override
  String get settings_interface_galleries_layout_item => 'ギャラリーのレイアウト';

  @override
  String get settings_interface_galleries_layout_subtitle_item =>
      'ギャラリーページのレイアウト';

  @override
  String get settings_server_title => 'サーバー設定';

  @override
  String get settings_server_status => '接続ステータス';

  @override
  String get settings_server_status_subtitle => '設定されたサーバーへのライブ接続確認';

  @override
  String get settings_server_details => 'サーバー詳細';

  @override
  String get settings_server_details_subtitle => 'エンドポイントと認証方法を設定します';

  @override
  String get settings_server_url => 'GraphQLサーバーのURL';

  @override
  String get settings_server_url_helper => '例: http(s)://host:port/graphql';

  @override
  String get settings_server_url_example => 'http://192.168.1.100:9999/graphql';

  @override
  String get settings_server_login_failed => 'ログインに失敗しました';

  @override
  String get settings_server_auth_method => '認証方法';

  @override
  String get settings_server_auth_apikey => 'APIキー';

  @override
  String get settings_server_auth_password => 'ユーザー名 + パスワード';

  @override
  String get settings_server_auth_password_desc =>
      '推奨: Stashのユーザー名/パスワードセッションを使用します。';

  @override
  String get settings_server_auth_apikey_desc => '静的トークン認証にAPIキーを使用します。';

  @override
  String get settings_server_username => 'ユーザー名';

  @override
  String get settings_server_password => 'パスワード';

  @override
  String get settings_server_login_test => 'ログインとテスト';

  @override
  String get settings_server_test => '接続テスト';

  @override
  String get settings_server_logout => 'ログアウト';

  @override
  String get settings_server_clear => '設定をクリア';

  @override
  String settings_server_connected(String version) {
    return '接続済み (Stash $version)';
  }

  @override
  String get settings_server_checking => '接続を確認中...';

  @override
  String settings_server_failed(String error) {
    return '失敗: $error';
  }

  @override
  String get settings_server_invalid_url => '無効なサーバーURL';

  @override
  String get settings_server_resolve_error =>
      'サーバーURLを解決できませんでした。ホスト、ポート、認証情報を確認してください。';

  @override
  String get settings_server_logout_confirm => 'ログアウトし、クッキーをクリアしました。';

  @override
  String get settings_server_auth_status_logging_in => '認証状態: ログイン中...';

  @override
  String get settings_server_auth_status_logged_in => '認証状態: ログイン済み';

  @override
  String get settings_server_auth_status_logged_out => '認証状態: ログアウト';

  @override
  String get settings_playback_title => '再生設定';

  @override
  String get settings_playback_behavior => '再生動作';

  @override
  String get settings_playback_behavior_subtitle => 'デフォルトの再生とバックグラウンド処理';

  @override
  String get settings_playback_prefer_streams => 'sceneStreamsを優先';

  @override
  String get settings_playback_prefer_streams_subtitle =>
      'オフの場合、再生は直接paths.streamを使用します';

  @override
  String get settings_playback_autoplay => '次のシーンを自動再生';

  @override
  String get settings_playback_autoplay_subtitle =>
      '現在の再生が終了したときに次のシーンを自動的に再生します';

  @override
  String get settings_playback_background => 'バックグラウンド再生';

  @override
  String get settings_playback_background_subtitle =>
      'アプリがバックグラウンドに移動しても動画の音声を再生し続けます';

  @override
  String get settings_playback_pip => 'ネイティブ ピクチャー・イン・ピクチャー';

  @override
  String get settings_playback_pip_subtitle =>
      'Android PiPボタンを有効にし、バックグラウンド時に自動移行します';

  @override
  String get settings_playback_subtitles => '字幕設定';

  @override
  String get settings_playback_subtitles_subtitle => '自動読み込みと外観';

  @override
  String get settings_playback_subtitle_lang => 'デフォルトの字幕言語';

  @override
  String get settings_playback_subtitle_lang_subtitle => '利用可能な場合に自動読み込み';

  @override
  String get settings_playback_subtitle_size => '字幕フォントサイズ';

  @override
  String get settings_playback_subtitle_pos => '字幕の垂直位置';

  @override
  String settings_playback_subtitle_pos_desc(String percent) {
    return '下から $percent%';
  }

  @override
  String get settings_playback_subtitle_align => '字幕テキストの配置';

  @override
  String get settings_playback_subtitle_align_subtitle => '複数行字幕の配置設定';

  @override
  String get settings_playback_seek => 'シーク操作';

  @override
  String get settings_playback_seek_subtitle => '再生中のスクラブ動作を選択します';

  @override
  String get settings_playback_seek_double_tap => '左右をダブルタップして10秒シーク';

  @override
  String get settings_playback_seek_drag => 'タイムラインをドラッグしてシーク';

  @override
  String get settings_playback_seek_drag_label => 'ドラッグ';

  @override
  String get settings_playback_seek_double_tap_label => 'ダブルタップ';

  @override
  String get settings_playback_gravity_orientation => '重力制御の画面向き';

  @override
  String get settings_playback_gravity_orientation_subtitle =>
      'デバイスのセンサーを使って一致する向きに回転できるようにします（例：左右の横向きに反転）。';

  @override
  String get settings_playback_subtitle_lang_none_disabled => 'なし（無効）';

  @override
  String get settings_playback_subtitle_lang_auto_if_only_one => '自動（1つのみの場合）';

  @override
  String get settings_playback_subtitle_lang_english => '英語';

  @override
  String get settings_playback_subtitle_lang_chinese => '中国語';

  @override
  String get settings_playback_subtitle_lang_german => 'ドイツ語';

  @override
  String get settings_playback_subtitle_lang_french => 'フランス語';

  @override
  String get settings_playback_subtitle_lang_spanish => 'スペイン語';

  @override
  String get settings_playback_subtitle_lang_italian => 'イタリア語';

  @override
  String get settings_playback_subtitle_lang_japanese => '日本語';

  @override
  String get settings_playback_subtitle_lang_korean => '韓国語';

  @override
  String get settings_playback_subtitle_align_left => '左';

  @override
  String get settings_playback_subtitle_align_center => '中央';

  @override
  String get settings_playback_subtitle_align_right => '右';

  @override
  String get settings_support_title => 'サポート';

  @override
  String get settings_support_diagnostics => '診断とプロジェクト情報';

  @override
  String get settings_support_diagnostics_subtitle =>
      'ヘルプが必要なときに実行ログを開いたり、リポジトリに移動したりします。';

  @override
  String get settings_support_update_available => 'アップデートがあります';

  @override
  String get settings_support_update_available_subtitle =>
      'GitHubで新しいバージョンが利用可能です';

  @override
  String settings_support_update_to(String version) {
    return '$version に更新';
  }

  @override
  String get settings_support_update_to_subtitle => '新しい機能と改善が用意されています。';

  @override
  String get settings_support_about => 'アプリについて';

  @override
  String get settings_support_about_subtitle => 'プロジェクトとソース情報';

  @override
  String get settings_support_version => 'バージョン';

  @override
  String get settings_support_version_loading => 'バージョン情報を読み込み中...';

  @override
  String get settings_support_version_unavailable => 'バージョン情報が利用できません';

  @override
  String get settings_support_github => 'GitHub リポジトリ';

  @override
  String get settings_support_github_subtitle => 'ソースコードの表示と問題の報告';

  @override
  String get settings_support_github_error => 'GitHubリンクを開けませんでした';

  @override
  String get settings_develop_title => '開発';

  @override
  String get settings_develop_diagnostics => '診断ツール';

  @override
  String get settings_develop_diagnostics_subtitle => 'トラブルシューティングとパフォーマンス';

  @override
  String get settings_develop_video_debug => 'ビデオデバッグ情報を表示';

  @override
  String get settings_develop_video_debug_subtitle =>
      '技術的な再生詳細を動画プレーヤー上にオーバーレイ表示します。';

  @override
  String get settings_develop_log_viewer => 'デバッグログビューアー';

  @override
  String get settings_develop_log_viewer_subtitle => 'アプリ内ログをリアルタイムで表示します。';

  @override
  String get settings_develop_logs_copied => 'ログをクリップボードにコピーしました';

  @override
  String get settings_develop_no_logs => 'まだログはありません。アプリを操作してログを取得してください。';

  @override
  String get settings_develop_web_overrides => 'Webオーバーライド';

  @override
  String get settings_develop_web_overrides_subtitle => 'Webプラットフォーム向けの高度なフラグ';

  @override
  String get settings_develop_web_auth => 'Webでのパスワードログインを許可';

  @override
  String get settings_develop_web_auth_subtitle =>
      'ネイティブ限定の制限を上書きし、Flutter Webでユーザー名 + パスワード認証を強制表示します。';

  @override
  String get settings_develop_proxy_auth => 'プロキシ認証モードを有効にする';

  @override
  String get settings_develop_proxy_auth_subtitle =>
      'Authentikなどのプロキシの背後にある認証不要のバックエンドで使用するために、高度なBasic認証およびBearerトークン方式を有効にします。';

  @override
  String get settings_server_auth_basic => 'Basic認証';

  @override
  String get settings_server_auth_bearer => 'Bearerトークン';

  @override
  String get settings_server_auth_basic_desc =>
      '\'Authorization: Basic <base64(user:pass)>\' ヘッダーを送信します。';

  @override
  String get settings_server_auth_bearer_desc =>
      '\'Authorization: Bearer <token>\' ヘッダーを送信します。';

  @override
  String get common_edit => '編集';

  @override
  String get common_resolution => '解像度';

  @override
  String get common_orientation => '方向';

  @override
  String get common_landscape => '横向き';

  @override
  String get common_portrait => '縦向き';

  @override
  String get common_square => '正方形';

  @override
  String get performers_filter_saved => 'フィルタ設定をデフォルトとして保存しました';

  @override
  String get images_title => '画像';

  @override
  String get images_filter_title => '画像をフィルター';

  @override
  String get images_filter_saved => 'フィルター設定をデフォルトとして保存しました';

  @override
  String get images_sort_title => '画像を並べ替え';

  @override
  String get images_sort_saved => '並べ替えの設定を既定として保存しました';

  @override
  String get image_rating_updated => '画像の評価が更新されました。';

  @override
  String get gallery_rating_updated => 'ギャラリーの評価が更新されました。';

  @override
  String get common_image => '画像';

  @override
  String get common_gallery => 'ギャラリー';

  @override
  String get images_gallery_rating_unavailable =>
      'ギャラリーの評価は、ギャラリーを閲覧しているときにのみ利用できます。';

  @override
  String images_rating(String rating) {
    return '評価：$rating / 5';
  }

  @override
  String get images_filtered_by_gallery => 'ギャラリーでフィルタ済み';

  @override
  String get images_slideshow_need_two => 'スライドショーには少なくとも画像が2枚必要です。';

  @override
  String get images_slideshow_start_title => 'スライドショーを開始';

  @override
  String images_slideshow_interval(num seconds) {
    return '間隔: ${seconds}s';
  }

  @override
  String images_slideshow_transition_ms(num ms) {
    return 'トランジション: ${ms}ms';
  }

  @override
  String get common_forward => '進む';

  @override
  String get common_backward => '戻る';

  @override
  String get images_slideshow_loop_title => 'スライドショーをループ';

  @override
  String get common_cancel => 'キャンセル';

  @override
  String get common_start => '開始';

  @override
  String get common_done => '完了';

  @override
  String get settings_keybind_assign_shortcut => 'ショートカットを割り当て';

  @override
  String get settings_keybind_press_any => '任意のキーの組み合わせを押してください...';

  @override
  String get scenes_select_tags => 'タグを選択';

  @override
  String get scenes_no_scrapers => '使用可能なスクレイパーがありません';

  @override
  String get scenes_select_scraper => 'スクレイパーを選択';

  @override
  String get scenes_no_results_found => '結果が見つかりませんでした';

  @override
  String get scenes_select_result => '結果を選択';

  @override
  String scenes_scrape_failed(String error) {
    return 'スクレイプに失敗しました: $error';
  }

  @override
  String get scenes_updated_successfully => 'シーンが正常に更新されました';

  @override
  String scenes_update_failed(String error) {
    return 'シーンの更新に失敗しました: $error';
  }

  @override
  String get scenes_edit_title => 'シーンを編集';

  @override
  String get scenes_field_studio => 'スタジオ';

  @override
  String get scenes_field_tags => 'タグ';

  @override
  String get scenes_field_urls => 'リンク';

  @override
  String get scenes_edit_performer => '出演者を編集';

  @override
  String get scenes_edit_studio => 'スタジオを編集';

  @override
  String get common_no_title => 'タイトルなし';

  @override
  String get scenes_select_studio => 'スタジオを選択';

  @override
  String get scenes_select_performers => '出演者を選択';

  @override
  String get scenes_unmatched_scraped_tags => '一致しないスクレイプ済みタグ';

  @override
  String get scenes_unmatched_scraped_performers => '一致しないスクレイプ済み出演者';

  @override
  String get scenes_no_matching_performer_found => 'ライブラリに一致する出演者が見つかりません';

  @override
  String get common_unknown => '不明';

  @override
  String scenes_studio_id_prefix(String id) {
    return 'スタジオID: $id';
  }

  @override
  String get tags_search_placeholder => 'タグを検索...';

  @override
  String get scenes_duration_short => '< 5分';

  @override
  String get scenes_duration_medium => '5-20分';

  @override
  String get scenes_duration_long => '> 20分';

  @override
  String get details_scene_fingerprint_query => 'シーンのフィンガープリントクエリ';

  @override
  String get scenes_available_scrapers => '使用可能なスクレイパー';

  @override
  String get scrape_results_existing => '既存の結果';

  @override
  String get scrape_results_scraped => '取得済み結果';
}
