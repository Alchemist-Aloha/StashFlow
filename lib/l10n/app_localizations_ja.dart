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
  String get studios_sort_saved => '並べ替え設定をデフォルトとして保存しました';

  @override
  String get studios_no_random => 'ランダムナビゲーションに使用できるスタジオがありません';

  @override
  String get tags_filter_title => 'タグをフィルター';

  @override
  String get tags_filter_saved => 'フィルター設定をデフォルトとして保存しました';

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
  String get common_url => 'URL';

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
  String get details_group => 'グループ詳細';

  @override
  String get details_scene_scrape => 'メタデータ取得';

  @override
  String get details_scene_add_performer => '出演者を追加';

  @override
  String get details_scene_add_tag => 'タグを追加';

  @override
  String get details_scene_add_url => 'URLを追加';

  @override
  String get details_scene_remove_url => 'URLを削除';

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
  String get settings_develop_web_overrides => 'Webオーバーライド';

  @override
  String get settings_develop_web_overrides_subtitle => 'Webプラットフォーム向けの高度なフラグ';

  @override
  String get settings_develop_web_auth => 'Webでのパスワードログインを許可';

  @override
  String get settings_develop_web_auth_subtitle =>
      'ネイティブ限定の制限を上書きし、Flutter Webでユーザー名 + パスワード認証を強制表示します。';
}
