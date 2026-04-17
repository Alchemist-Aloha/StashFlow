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
}
