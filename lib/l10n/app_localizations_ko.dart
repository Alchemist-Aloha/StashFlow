// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'StashFlow';

  @override
  String get nav_scenes => '장면';

  @override
  String get nav_performers => '출연자';

  @override
  String get nav_studios => '스튜디오';

  @override
  String get nav_tags => '태그';

  @override
  String get nav_galleries => '갤러리';

  @override
  String nScenes(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString개의 장면',
      zero: '장면 없음',
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
      other: '$countString명의 출연자',
      zero: '출연자 없음',
    );
    return '$_temp0';
  }

  @override
  String get common_reset => '초기화';

  @override
  String get common_apply => '적용';

  @override
  String get common_save_default => '기본값으로 저장';

  @override
  String get common_sort_method => '정렬 방식';

  @override
  String get common_direction => '방향';

  @override
  String get common_ascending => '오름차순';

  @override
  String get common_descending => '내림차순';

  @override
  String get common_favorites_only => '즐겨찾기만';

  @override
  String get common_apply_sort => '정렬 적용';

  @override
  String get common_apply_filters => '필터 적용';

  @override
  String get common_view_all => '전체 보기';

  @override
  String get common_later => '나중에';

  @override
  String get common_update_now => '지금 업데이트';

  @override
  String get common_configure_now => '지금 설정';

  @override
  String get common_clear_rating => '평점 지우기';

  @override
  String get common_no_media => '미디어가 없습니다';

  @override
  String get common_setup_required => '설정이 필요합니다';

  @override
  String get common_update_available => '업데이트 가능';

  @override
  String get details_studio => '스튜디오 상세';

  @override
  String get details_performer => '출연자 상세';

  @override
  String get details_tag => '태그 상세';

  @override
  String get details_scene => '장면 상세';

  @override
  String get details_gallery => '갤러리 상세';

  @override
  String get studios_filter_title => '스튜디오 필터';

  @override
  String get studios_filter_saved => '필터 설정이 기본값으로 저장되었습니다';

  @override
  String get sort_name => '이름';

  @override
  String get sort_scene_count => '장면 수';

  @override
  String get sort_rating => '평점';

  @override
  String get sort_updated_at => '업데이트 날짜';

  @override
  String get sort_created_at => '생성 날짜';

  @override
  String get sort_random => '랜덤';

  @override
  String get studios_sort_saved => '정렬 설정이 기본값으로 저장되었습니다';

  @override
  String get studios_no_random => '랜덤 탐색에 사용할 수 있는 스튜디오가 없습니다';

  @override
  String get tags_filter_title => '태그 필터';

  @override
  String get tags_filter_saved => '필터 설정이 기본값으로 저장되었습니다';

  @override
  String get tags_sort_saved => '정렬 설정이 기본값으로 저장되었습니다';

  @override
  String get tags_no_random => '랜덤 탐색에 사용할 수 있는 태그가 없습니다';

  @override
  String get scenes_no_random => '랜덤 탐색에 사용할 수 있는 장면이 없습니다';

  @override
  String get performers_no_random => '랜덤 탐색에 사용할 수 있는 출연자가 없습니다';

  @override
  String get galleries_no_random => '랜덤 탐색에 사용할 수 있는 갤러리가 없습니다';

  @override
  String common_error(String message) {
    return '오류: $message';
  }
}
