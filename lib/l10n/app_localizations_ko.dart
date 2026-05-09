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
  String get common_token => '토큰';

  @override
  String get filter_value => '값';

  @override
  String get common_yes => '예';

  @override
  String get common_no => '아니요';

  @override
  String get common_clear_history => '기록 지우기';

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
  String get common_default => '기본값';

  @override
  String get common_later => '나중에';

  @override
  String get common_update_now => '지금 업데이트';

  @override
  String get common_configure_now => '지금 설정';

  @override
  String get common_clear_rating => '평가 삭제';

  @override
  String get common_no_media => '미디어가 없습니다';

  @override
  String get common_show => '표시';

  @override
  String get common_hide => '숨기기';

  @override
  String get galleries_filter_saved => '필터 환경설정이 기본값으로 저장되었습니다';

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
  String get sort_file_mod_time => '파일 수정 시간';

  @override
  String get sort_filesize => '파일 크기';

  @override
  String get sort_o_count => 'O 카운터';

  @override
  String get sort_height => '키';

  @override
  String get sort_birthdate => '생년월일';

  @override
  String get sort_tag_count => '태그 수';

  @override
  String get sort_play_count => '재생 수';

  @override
  String get sort_o_counter => 'O 카운터';

  @override
  String get sort_zip_file_count => 'ZIP 파일 수';

  @override
  String get sort_last_o_at => '마지막 O';

  @override
  String get sort_latest_scene => '최신 씬';

  @override
  String get sort_career_start => '경력 시작';

  @override
  String get sort_career_end => '경력 종료';

  @override
  String get sort_weight => '체중';

  @override
  String get sort_measurements => '치수';

  @override
  String get sort_scenes_duration => '씬 길이';

  @override
  String get sort_scenes_size => '씬 크기';

  @override
  String get sort_images_count => '이미지 수';

  @override
  String get sort_galleries_count => '갤러리 수';

  @override
  String get sort_child_count => '하위 스튜디오 수';

  @override
  String get sort_performers_count => '출연자 수';

  @override
  String get sort_groups_count => '그룹 수';

  @override
  String get sort_marker_count => '마커 수';

  @override
  String get sort_studios_count => '스튜디오 수';

  @override
  String get sort_penis_length => '음경 길이';

  @override
  String get sort_last_played_at => '마지막 재생';

  @override
  String get studios_sort_saved => '정렬 설정이 기본값으로 저장되었습니다';

  @override
  String get studios_no_random => '랜덤 탐색에 사용할 수 있는 스튜디오가 없습니다';

  @override
  String get tags_filter_title => '태그 필터';

  @override
  String get tags_filter_saved => '필터 설정이 기본값으로 저장되었습니다';

  @override
  String get tags_sort_title => '태그 정렬';

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

  @override
  String get common_no_media_available => '미디어 없음';

  @override
  String common_id(Object id) {
    return 'ID: $id';
  }

  @override
  String get common_search_placeholder => '검색...';

  @override
  String get common_pause => '일시정지';

  @override
  String get common_play => '재생';

  @override
  String get common_refresh => '새로 고치다';

  @override
  String get common_close => '닫기';

  @override
  String get common_save => '저장';

  @override
  String get common_unmute => '음소거 해제';

  @override
  String get common_mute => '음소거';

  @override
  String get common_back => '뒤로';

  @override
  String get common_rate => '평가하기';

  @override
  String get common_previous => '이전';

  @override
  String get common_next => '다음';

  @override
  String get common_favorite => '즐겨찾기';

  @override
  String get common_unfavorite => '즐겨찾기 해제';

  @override
  String get common_version => '버전';

  @override
  String get common_loading => '로딩 중';

  @override
  String get common_unavailable => '사용 불가';

  @override
  String get common_details => '상세 정보';

  @override
  String get common_title => '제목';

  @override
  String get common_release_date => '출시일';

  @override
  String get common_url => '링크';

  @override
  String get common_no_url => 'URL 없음';

  @override
  String get common_sort => '정렬';

  @override
  String get common_filter => '필터';

  @override
  String get common_search => '검색';

  @override
  String get common_settings => '설정';

  @override
  String get common_reset_to_1x => '1배속으로 재설정';

  @override
  String get common_skip_next => '다음 건너뛰기';

  @override
  String get common_skip_previous => '이전으로 건너뛰기';

  @override
  String get common_select_subtitle => '자막 선택';

  @override
  String get common_playback_speed => '재생 속도';

  @override
  String get common_pip => 'PIP';

  @override
  String get common_toggle_fullscreen => '전체 화면 전환';

  @override
  String get common_exit_fullscreen => '전체 화면 종료';

  @override
  String get common_copy_logs => '로그 복사';

  @override
  String get common_clear_logs => '로그 삭제';

  @override
  String get common_enable_autoscroll => '자동 스크롤 활성화';

  @override
  String get common_disable_autoscroll => '자동 스크롤 비활성화';

  @override
  String get common_retry => '재시도';

  @override
  String get common_no_items => '항목을 찾을 수 없습니다';

  @override
  String get common_none => '없음';

  @override
  String get common_any => '모두';

  @override
  String get common_name => '이름';

  @override
  String get common_date => '날짜';

  @override
  String get common_rating => '평점';

  @override
  String get common_image_count => '이미지 수';

  @override
  String get common_filepath => '파일 경로';

  @override
  String get common_random => '무작위';

  @override
  String get common_no_media_found => '미디어를 찾을 수 없습니다';

  @override
  String common_not_found(String item) {
    return '$item을(를) 찾을 수 없습니다';
  }

  @override
  String get common_add_favorite => '즐겨찾기에 추가';

  @override
  String get common_remove_favorite => '즐겨찾기에서 삭제';

  @override
  String get details_group => '그룹 상세 정보';

  @override
  String get details_synopsis => '시놉시스';

  @override
  String get details_media => '미디어';

  @override
  String get details_galleries => '갤러리';

  @override
  String get details_tags => '태그';

  @override
  String get details_links => '링크';

  @override
  String get details_scene_scrape => '메타데이터 스크래핑';

  @override
  String get details_show_more => '더 보기';

  @override
  String get common_more => '더 보기';

  @override
  String get details_show_less => '간략히 보기';

  @override
  String get details_more_from_studio => '스튜디오의 기타';

  @override
  String get details_o_count_incremented => 'O 수가 증가했습니다';

  @override
  String details_failed_update_rating(String error) {
    return '평점 업데이트 실패: $error';
  }

  @override
  String details_failed_update_performer(Object error) {
    return '출연자 업데이트에 실패했습니다: $error';
  }

  @override
  String details_failed_increment_o_count(String error) {
    return 'O 수 증가 실패: $error';
  }

  @override
  String get details_scene_add_performer => '출연자 추가';

  @override
  String get details_scene_add_tag => '태그 추가';

  @override
  String get details_scene_add_url => 'URL 추가';

  @override
  String get details_scene_remove_url => 'URL 제거';

  @override
  String get groups_title => '그룹';

  @override
  String get groups_unnamed => '이름 없는 그룹';

  @override
  String get groups_untitled => '제목 없는 그룹';

  @override
  String get studios_title => '스튜디오';

  @override
  String get studios_galleries_title => '스튜디오 갤러리';

  @override
  String get studios_media_title => '스튜디오 미디어';

  @override
  String get studios_sort_title => '스튜디오 정렬';

  @override
  String get galleries_title => '갤러리';

  @override
  String get galleries_sort_title => '갤러리 정렬';

  @override
  String get galleries_all_images => '모든 이미지';

  @override
  String get galleries_filter_title => '갤러리 필터';

  @override
  String get galleries_min_rating => '최소 평점';

  @override
  String get galleries_image_count => '이미지 수';

  @override
  String get galleries_organization => '정리';

  @override
  String get galleries_organized_only => '정리된 항목만';

  @override
  String get scenes_filter_title => '장면 필터';

  @override
  String get scenes_filter_saved => '필터 설정이 기본값으로 저장되었습니다';

  @override
  String get scenes_watched => '본 항목';

  @override
  String get scenes_unwatched => '안 본 항목';

  @override
  String get scenes_search_hint => '장면 검색...';

  @override
  String get scenes_sort_header => '장면 정렬';

  @override
  String get scenes_sort_duration => '길이';

  @override
  String get scenes_sort_bitrate => '비트레이트';

  @override
  String get scenes_sort_framerate => '프레임 속도';

  @override
  String get scenes_sort_saved_default => '정렬 설정이 기본값으로 저장됨';

  @override
  String get scenes_sort_tooltip => '정렬 옵션';

  @override
  String get tags_search_hint => '태그 검색...';

  @override
  String get tags_sort_tooltip => '정렬 옵션';

  @override
  String get tags_filter_tooltip => '필터 옵션';

  @override
  String get performers_title => '출연자';

  @override
  String get performers_sort_title => '출연자 정렬';

  @override
  String get performers_filter_title => '출연자 필터';

  @override
  String get performers_galleries_title => '모든 출연자 갤러리';

  @override
  String get performers_media_title => '모든 출연자 미디어';

  @override
  String get performers_gender => '성별';

  @override
  String get performers_gender_any => '모두';

  @override
  String get performers_gender_female => '여성';

  @override
  String get performers_gender_male => '남성';

  @override
  String get performers_gender_trans_female => '트랜스 여성';

  @override
  String get performers_gender_trans_male => '트랜스 남성';

  @override
  String get performers_gender_intersex => '인터섹스';

  @override
  String get performers_gender_non_binary => '논바이너리';

  @override
  String get performers_circumcised => '포경';

  @override
  String get performers_circumcised_cut => '포경';

  @override
  String get performers_circumcised_uncut => '비포경';

  @override
  String get performers_play_count => '재생 횟수';

  @override
  String get performers_field_disambiguation => '중복 해소';

  @override
  String get performers_field_birthdate => '생년월일';

  @override
  String get performers_field_deathdate => '사망일';

  @override
  String get performers_field_height_cm => '키 (cm)';

  @override
  String get performers_field_weight_kg => '체중 (kg)';

  @override
  String get performers_field_measurements => '치수';

  @override
  String get performers_field_fake_tits => '가짜 가슴';

  @override
  String get performers_field_penis_length => '음경 길이';

  @override
  String get performers_field_ethnicity => '민족';

  @override
  String get performers_field_country => '국가';

  @override
  String get performers_field_eye_color => '눈 색깔';

  @override
  String get performers_field_hair_color => '머리 색깔';

  @override
  String get performers_field_career_start => '경력 시작';

  @override
  String get performers_field_career_end => '경력 종료';

  @override
  String get performers_field_tattoos => '문신';

  @override
  String get performers_field_piercings => '피어싱';

  @override
  String get performers_field_aliases => '별명';

  @override
  String get common_organized => '정리됨';

  @override
  String get scenes_duplicated => '중복됨';

  @override
  String get random_studio => '랜덤 스튜디오';

  @override
  String get random_gallery => '랜덤 갤러리';

  @override
  String get random_tag => '랜덤 태그';

  @override
  String get random_scene => '랜덤 장면';

  @override
  String get random_performer => '랜덤 출연자';

  @override
  String get filter_modifier => '수정자';

  @override
  String get filter_group_general => '일반';

  @override
  String get filter_group_performer => '출연자';

  @override
  String get filter_group_library => '라이브러리';

  @override
  String get filter_group_metadata => '메타데이터';

  @override
  String get filter_group_media_info => '미디어 정보';

  @override
  String get filter_group_usage => '사용량';

  @override
  String get filter_group_system => '시스템';

  @override
  String get filter_group_physical => '물리적';

  @override
  String get filter_equals => '같음';

  @override
  String get filter_not_equals => '같지 않음';

  @override
  String get filter_greater_than => '보다 큼';

  @override
  String get filter_less_than => '보다 작음';

  @override
  String get filter_is_null => '널임';

  @override
  String get filter_not_null => '널 아님';

  @override
  String get images_resolution_title => '해상도';

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
  String get images_orientation_title => '방향';

  @override
  String get common_or => '또는';

  @override
  String get scrape_from_url => 'URL에서 스크랩';

  @override
  String get scenes_phash_started => 'Phash 생성 시작됨';

  @override
  String scenes_phash_failed(Object error) {
    return 'Phash 생성 실패: $error';
  }

  @override
  String details_failed_update_studio(Object error) {
    return '스튜디오 업데이트 실패: $error';
  }

  @override
  String get settings_title => '설정';

  @override
  String get settings_customize => 'StashFlow 사용자 정의';

  @override
  String get settings_customize_subtitle =>
      '재생, 모양, 레이아웃 및 지원 도구를 한 곳에서 조정하세요.';

  @override
  String get settings_core_section => '핵심 설정';

  @override
  String get settings_core_subtitle => '가장 많이 사용되는 설정 페이지';

  @override
  String get settings_server => '서버';

  @override
  String get settings_server_subtitle => '연결 및 API 설정';

  @override
  String get settings_playback => '재생';

  @override
  String get settings_playback_subtitle => '플레이어 동작 및 상호작용';

  @override
  String get settings_keyboard => '키보드';

  @override
  String get settings_keyboard_subtitle => '사용자 정의 가능한 단축키 및 핫키';

  @override
  String get settings_keyboard_title => '키보드 단축키';

  @override
  String get settings_keyboard_reset_defaults => '기본값으로 재설정';

  @override
  String get settings_keyboard_not_bound => '할당되지 않음';

  @override
  String get settings_keyboard_volume_up => '볼륨 높이기';

  @override
  String get settings_keyboard_volume_down => '볼륨 낮추기';

  @override
  String get settings_keyboard_toggle_mute => '음소거 전환';

  @override
  String get settings_keyboard_toggle_fullscreen => '전체 화면 전환';

  @override
  String get settings_keyboard_next_scene => '다음 장면';

  @override
  String get settings_keyboard_prev_scene => '이전 장면';

  @override
  String get settings_keyboard_increase_speed => '재생 속도 증가';

  @override
  String get settings_keyboard_decrease_speed => '재생 속도 감소';

  @override
  String get settings_keyboard_reset_speed => '재생 속도 재설정';

  @override
  String get settings_keyboard_close_player => '플레이어 닫기';

  @override
  String get settings_keyboard_next_image => '다음 이미지';

  @override
  String get settings_keyboard_prev_image => '이전 이미지';

  @override
  String get settings_keyboard_go_back => '뒤로 가기';

  @override
  String get settings_keyboard_play_pause_desc => '동영상 재생/일시중지 전환';

  @override
  String get settings_keyboard_seek_forward_5_desc => '5초 앞으로 이동';

  @override
  String get settings_keyboard_seek_backward_5_desc => '5초 뒤로 이동';

  @override
  String get settings_keyboard_seek_forward_10_desc => '10초 앞으로 이동';

  @override
  String get settings_keyboard_seek_backward_10_desc => '10초 뒤로 이동';

  @override
  String get settings_appearance => '모양';

  @override
  String get settings_appearance_subtitle => '테마 및 색상';

  @override
  String get settings_interface => '인터페이스';

  @override
  String get settings_interface_subtitle => '탐색 및 레이아웃 기본값';

  @override
  String get settings_support => '지원';

  @override
  String get settings_support_subtitle => '진단 및 정보';

  @override
  String get settings_develop => '개발';

  @override
  String get settings_develop_subtitle => '고급 도구 및 재정의';

  @override
  String get settings_appearance_title => '모양 설정';

  @override
  String get settings_appearance_theme_mode => '테마 모드';

  @override
  String get settings_appearance_theme_mode_subtitle => '앱이 밝기 변화를 따르는 방식 선택';

  @override
  String get settings_appearance_theme_system => '시스템';

  @override
  String get settings_appearance_theme_light => '밝게';

  @override
  String get settings_appearance_theme_dark => '어둡게';

  @override
  String get settings_appearance_primary_color => '기본 색상';

  @override
  String get settings_appearance_primary_color_subtitle =>
      'Material 3 팔레트의 시드 색상 선택';

  @override
  String get settings_appearance_advanced_theming => '고급 테마 설정';

  @override
  String get settings_appearance_advanced_theming_subtitle =>
      '특정 화면 유형에 대한 최적화';

  @override
  String get settings_appearance_true_black => '트루 블랙 (AMOLED)';

  @override
  String get settings_appearance_true_black_subtitle =>
      '어두운 모드에서 순수 검정색 배경을 사용하여 OLED 화면의 배터리 절약';

  @override
  String get settings_appearance_custom_hex => '사용자 정의 헥스 색상';

  @override
  String get settings_appearance_custom_hex_helper => '8자리 ARGB 헥스 코드를 입력하세요';

  @override
  String get settings_appearance_font_size => '글로벌 UI 규모';

  @override
  String get settings_appearance_font_size_subtitle => '타이포그래피와 간격을 비례적으로 조정';

  @override
  String get settings_interface_title => '인터페이스 설정';

  @override
  String get settings_interface_language => '언어';

  @override
  String get settings_interface_language_subtitle => '기본 시스템 언어 재정의';

  @override
  String get settings_interface_app_language => '앱 언어';

  @override
  String get settings_interface_navigation => '탐색';

  @override
  String get settings_interface_navigation_subtitle => '전역 탐색 단축키 표시 여부';

  @override
  String get settings_interface_show_random => '랜덤 탐색 버튼 표시';

  @override
  String get settings_interface_show_random_subtitle =>
      '목록 및 상세 페이지에서 부동 카지노 버튼 활성화 또는 비활성화';

  @override
  String get settings_interface_main_pages_gravity_orientation =>
      '중력 제어 화면 방향(메인 페이지)';

  @override
  String get settings_interface_main_pages_gravity_orientation_subtitle =>
      '기기 센서를 사용해 메인 페이지가 회전하도록 허용합니다. 전체 화면 동영상 재생은 별도의 화면 방향 설정을 따릅니다.';

  @override
  String get settings_interface_show_edit => '편집 버튼 표시';

  @override
  String get settings_interface_show_edit_subtitle =>
      '장면 상세 페이지에서 편집 버튼 활성화 또는 비활성화';

  @override
  String get settings_interface_customize_tabs => '탭 사용자 정의';

  @override
  String get settings_interface_customize_tabs_subtitle =>
      '탐색 메뉴 항목 순서 변경 또는 숨기기';

  @override
  String get settings_interface_scenes_layout => '장면 레이아웃';

  @override
  String get settings_interface_scenes_layout_subtitle => '장면의 기본 브라우징 모드';

  @override
  String get settings_interface_galleries_layout => '갤러리 레이아웃';

  @override
  String get settings_interface_galleries_layout_subtitle => '갤러리의 기본 브라우징 모드';

  @override
  String get settings_interface_max_performer_avatars => '출연자 아바타 최대 수';

  @override
  String get settings_interface_max_performer_avatars_subtitle =>
      '장면 카드에 표시할 출연자 아바타의 최대 수입니다.';

  @override
  String get settings_interface_show_performer_avatars => '출연자 아바타 표시';

  @override
  String get settings_interface_show_performer_avatars_subtitle =>
      '모든 플랫폼의 장면 카드에 출연자 아이콘을 표시합니다.';

  @override
  String get settings_interface_performer_avatar_size => '출연자 아바타 크기';

  @override
  String get settings_interface_layout_default => '기본 레이아웃';

  @override
  String get settings_interface_layout_default_desc => '페이지의 기본 레이아웃 선택';

  @override
  String get settings_interface_layout_list => '목록';

  @override
  String get settings_interface_layout_grid => '그리드';

  @override
  String get settings_interface_layout_tiktok => '무한 스크롤';

  @override
  String get settings_interface_grid_columns => '그리드 열';

  @override
  String get settings_interface_image_viewer => '이미지 뷰어';

  @override
  String get settings_interface_image_viewer_subtitle => '전체 화면 이미지 브라우징 동작 설정';

  @override
  String get settings_interface_swipe_direction => '전체 화면 스와이프 방향';

  @override
  String get settings_interface_swipe_direction_desc =>
      '전체 화면 모드에서 이미지가 넘어가는 방식 선택';

  @override
  String get settings_interface_swipe_vertical => '세로';

  @override
  String get settings_interface_swipe_horizontal => '가로';

  @override
  String get settings_interface_waterfall_columns => '폭포수 그리드 열';

  @override
  String get settings_interface_performer_layouts => '출연자 레이아웃';

  @override
  String get settings_interface_performer_layouts_subtitle =>
      '출연자의 미디어 및 갤러리 기본값';

  @override
  String get settings_interface_studio_layouts => '스튜디오 레이아웃';

  @override
  String get settings_interface_studio_layouts_subtitle =>
      '스튜디오의 미디어 및 갤러리 기본값';

  @override
  String get settings_interface_tag_layouts => '태그 레이아웃';

  @override
  String get settings_interface_tag_layouts_subtitle => '태그의 미디어 및 갤러리 기본값';

  @override
  String get settings_interface_media_layout => '미디어 레이아웃';

  @override
  String get settings_interface_media_layout_subtitle => '미디어 페이지용 레이아웃';

  @override
  String get settings_interface_galleries_layout_item => '갤러리 레이아웃';

  @override
  String get settings_interface_galleries_layout_subtitle_item =>
      '갤러리 페이지용 레이아웃';

  @override
  String get settings_server_title => '서버 설정';

  @override
  String get settings_server_status => '연결 상태';

  @override
  String get settings_server_status_subtitle => '구성된 서버에 대한 실시간 연결 상태';

  @override
  String get settings_server_details => '서버 상세 정보';

  @override
  String get settings_server_details_subtitle => '엔드포인트 및 인증 방식 설정';

  @override
  String get settings_server_url => 'Stash URL';

  @override
  String get settings_server_url_helper =>
      'Stash 서버의 URL을 입력하세요. 사용자 정의 경로가 구성된 경우 여기에 포함하세요.';

  @override
  String get settings_server_url_example => 'http://192.168.1.100:9999';

  @override
  String get settings_server_login_failed => '로그인 실패';

  @override
  String get settings_server_auth_method => '인증 방식';

  @override
  String get settings_server_auth_apikey => 'API 키';

  @override
  String get settings_server_auth_password => '사용자 이름 + 비밀번호';

  @override
  String get settings_server_auth_password_desc =>
      '권장: Stash 사용자 이름/비밀번호 세션을 사용하세요.';

  @override
  String get settings_server_auth_apikey_desc => '정적 토큰 인증을 위해 API 키를 사용하세요.';

  @override
  String get settings_server_username => '사용자 이름';

  @override
  String get settings_server_password => '비밀번호';

  @override
  String get settings_server_login_test => '로그인 및 테스트';

  @override
  String get settings_server_test => '연결 테스트';

  @override
  String get settings_server_logout => '로그아웃';

  @override
  String get settings_server_clear => '설정 초기화';

  @override
  String settings_server_connected(String version) {
    return '연결됨 (Stash $version)';
  }

  @override
  String get settings_server_checking => '연결 확인 중...';

  @override
  String settings_server_failed(String error) {
    return '실패: $error';
  }

  @override
  String get settings_server_invalid_url => '잘못된 서버 URL';

  @override
  String get settings_server_resolve_error =>
      '서버 URL을 확인할 수 없습니다. 호스트, 포트 및 자격 증명을 확인하세요.';

  @override
  String get settings_server_logout_confirm => '로그아웃되었으며 쿠키가 삭제되었습니다.';

  @override
  String get settings_server_profile_add => '프로필 추가';

  @override
  String get settings_server_profile_edit => '프로필 편집';

  @override
  String get settings_server_profile_name => '프로필 이름';

  @override
  String get settings_server_profile_delete => '프로필 삭제';

  @override
  String get settings_server_profile_delete_confirm =>
      '이 프로필을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.';

  @override
  String get settings_server_profile_active => '활성';

  @override
  String get settings_server_profile_empty => '구성된 서버 프로필이 없습니다';

  @override
  String get settings_server_profiles => '서버 프로필';

  @override
  String get settings_server_profiles_subtitle => '여러 Stash 서버 연결 관리';

  @override
  String get settings_server_auth_status_logging_in => '인증 상태: 로그인 중...';

  @override
  String get settings_server_auth_status_logged_in => '인증 상태: 로그인됨';

  @override
  String get settings_server_auth_status_logged_out => '인증 상태: 로그아웃됨';

  @override
  String get settings_playback_title => '재생 설정';

  @override
  String get settings_playback_behavior => '재생 동작';

  @override
  String get settings_playback_behavior_subtitle => '기본 재생 및 백그라운드 처리';

  @override
  String get settings_playback_prefer_streams => 'sceneStreams 우선';

  @override
  String get settings_playback_prefer_streams_subtitle =>
      '꺼져 있으면 재생 시 paths.stream을 직접 사용합니다';

  @override
  String get settings_playback_end_behavior => '재생 종료 동작';

  @override
  String get settings_playback_end_behavior_subtitle =>
      '현재 재생이 끝나면 어떻게 해야 할까요?';

  @override
  String get settings_playback_end_behavior_stop => '멈추다';

  @override
  String get settings_playback_end_behavior_loop => '현재 장면 반복';

  @override
  String get settings_playback_end_behavior_next => '다음 장면 재생';

  @override
  String get settings_playback_autoplay => '다음 장면 자동 재생';

  @override
  String get settings_playback_autoplay_subtitle =>
      '현재 재생이 끝나면 자동으로 다음 장면을 재생합니다';

  @override
  String get settings_playback_background => '백그라운드 재생';

  @override
  String get settings_playback_background_subtitle =>
      '앱이 백그라운드로 전환되어도 동영상 오디오를 계속 재생합니다';

  @override
  String get settings_playback_pip => '네이티브 화면 속 화면 (PiP)';

  @override
  String get settings_playback_pip_subtitle =>
      'Android PiP 버튼을 활성화하고 백그라운드 전환 시 자동 진입합니다';

  @override
  String get settings_playback_subtitles => '자막 설정';

  @override
  String get settings_playback_subtitles_subtitle => '자동 로드 및 모양';

  @override
  String get settings_playback_subtitle_lang => '기본 자막 언어';

  @override
  String get settings_playback_subtitle_lang_subtitle => '가능한 경우 자동 로드';

  @override
  String get settings_playback_subtitle_size => '자막 글꼴 크기';

  @override
  String get settings_playback_subtitle_pos => '자막 세로 위치';

  @override
  String settings_playback_subtitle_pos_desc(String percent) {
    return '하단에서 $percent%';
  }

  @override
  String get settings_playback_subtitle_align => '자막 텍스트 정렬';

  @override
  String get settings_playback_subtitle_align_subtitle => '다중 행 자막 정렬';

  @override
  String get settings_playback_seek => '탐색 상호작용';

  @override
  String get settings_playback_seek_subtitle => '재생 중 스크러빙 작동 방식 선택';

  @override
  String get settings_playback_seek_double_tap => '왼쪽/오른쪽 두 번 탭하여 10초 탐색';

  @override
  String get settings_playback_seek_drag => '타임라인을 드래그하여 탐색';

  @override
  String get settings_playback_seek_drag_label => '드래그';

  @override
  String get settings_playback_seek_double_tap_label => '두 번 탭';

  @override
  String get settings_playback_gravity_orientation => '중력 제어 화면 방향';

  @override
  String get settings_playback_direct_play => '장면 이동 시 즉시 재생';

  @override
  String get settings_playback_direct_play_subtitle =>
      '다른 재생 중인 장면에서 이동할 때 새 장면을 즉시 재생합니다';

  @override
  String get settings_playback_gravity_orientation_subtitle =>
      '기기 센서를 사용하여 일치하는 방향으로 회전하도록 허용합니다(예: 좌/우 가로 방향 전환).';

  @override
  String get settings_playback_subtitle_lang_none_disabled => '없음(비활성화)';

  @override
  String get settings_playback_subtitle_lang_auto_if_only_one => '자동(하나만 있을 때)';

  @override
  String get settings_playback_subtitle_lang_english => '영어';

  @override
  String get settings_playback_subtitle_lang_chinese => '중국어';

  @override
  String get settings_playback_subtitle_lang_german => '독일어';

  @override
  String get settings_playback_subtitle_lang_french => '프랑스어';

  @override
  String get settings_playback_subtitle_lang_spanish => '스페인어';

  @override
  String get settings_playback_subtitle_lang_italian => '이탈리아어';

  @override
  String get settings_playback_subtitle_lang_japanese => '일본어';

  @override
  String get settings_playback_subtitle_lang_korean => '한국어';

  @override
  String get settings_playback_subtitle_align_left => '왼쪽';

  @override
  String get settings_playback_subtitle_align_center => '가운데';

  @override
  String get settings_playback_subtitle_align_right => '오른쪽';

  @override
  String get settings_support_title => '지원';

  @override
  String get settings_support_diagnostics => '진단 및 프로젝트 정보';

  @override
  String get settings_support_diagnostics_subtitle =>
      '도움이 필요할 때 런타임 로그를 열거나 저장소로 이동하세요.';

  @override
  String get settings_support_update_available => '업데이트 가능';

  @override
  String get settings_support_update_available_subtitle =>
      'GitHub에서 새 버전을 사용할 수 있습니다';

  @override
  String settings_support_update_to(String version) {
    return '$version 버전으로 업데이트';
  }

  @override
  String get settings_support_update_to_subtitle => '새로운 기능과 개선 사항이 기다리고 있습니다.';

  @override
  String get settings_support_about => '정보';

  @override
  String get settings_support_about_subtitle => '프로젝트 및 소스 정보';

  @override
  String get settings_support_version => '버전';

  @override
  String get settings_support_version_loading => '버전 정보 로드 중...';

  @override
  String get settings_support_version_unavailable => '버전 정보를 사용할 수 없음';

  @override
  String get settings_support_github => 'GitHub 저장소';

  @override
  String get settings_support_github_subtitle => '소스 코드를 확인하고 문제를 보고하세요';

  @override
  String get settings_support_github_error => 'GitHub 링크를 열 수 없습니다';

  @override
  String get settings_support_issues => '문제 신고';

  @override
  String get settings_support_issues_subtitle =>
      '버그를 보고하여 StashFlow 개선에 도움을 주세요.';

  @override
  String get settings_develop_title => '개발';

  @override
  String get settings_develop_diagnostics => '진단 도구';

  @override
  String get settings_develop_diagnostics_subtitle => '문제 해결 및 성능';

  @override
  String get settings_develop_video_debug => '비디오 디버그 정보 표시';

  @override
  String get settings_develop_video_debug_subtitle =>
      '비디오 플레이어 위에 기술적인 재생 세부 정보를 오버레이로 표시합니다.';

  @override
  String get settings_develop_log_viewer => '디버그 로그 뷰어';

  @override
  String get settings_develop_log_viewer_subtitle => '앱 내 로그의 실시간 보기를 엽니다.';

  @override
  String get settings_develop_logs_copied => '로그가 클립보드에 복사되었습니다';

  @override
  String get settings_develop_no_logs => '아직 로그가 없습니다. 앱과 상호작용하여 로그를 캡처하세요.';

  @override
  String get settings_develop_web_overrides => '웹 재정의';

  @override
  String get settings_develop_web_overrides_subtitle => '웹 플랫폼용 고급 플래그';

  @override
  String get settings_develop_web_auth => '웹에서 비밀번호 로그인 허용';

  @override
  String get settings_develop_web_auth_subtitle =>
      '네이티브 전용 제한을 무시하고 Flutter 웹에서 사용자 이름 + 비밀번호 인증 방식을 강제로 표시합니다.';

  @override
  String get settings_develop_proxy_auth => '프록시 인증 모드 활성화';

  @override
  String get settings_develop_proxy_auth_subtitle =>
      'Authentik과 같은 프록시 뒤의 인증 없는 백엔드에서 사용하기 위해 고급 Basic Auth 및 Bearer Token 방식을 활성화합니다.';

  @override
  String get settings_server_auth_basic => '기본 인증';

  @override
  String get settings_server_auth_bearer => '전달자 토큰';

  @override
  String get settings_server_auth_basic_desc =>
      '\'Authorization: Basic <base64(user:pass)>\' 헤더를 전송합니다.';

  @override
  String get settings_server_auth_bearer_desc =>
      '\'Authorization: Bearer <token>\' 헤더를 전송합니다.';

  @override
  String get common_edit => '편집';

  @override
  String get common_resolution => '해상도';

  @override
  String get common_orientation => '방향';

  @override
  String get common_landscape => '가로';

  @override
  String get common_portrait => '세로';

  @override
  String get common_square => '정사각형';

  @override
  String get performers_filter_saved => '필터 설정을 기본값으로 저장했습니다';

  @override
  String get images_title => '이미지';

  @override
  String get images_filter_title => '이미지 필터링';

  @override
  String get images_filter_saved => '필터 설정이 기본값으로 저장되었습니다';

  @override
  String get images_sort_title => '이미지 정렬';

  @override
  String get images_sort_saved => '정렬 환경설정이 기본값으로 저장되었습니다';

  @override
  String get image_rating_updated => '이미지 평점이 업데이트되었습니다.';

  @override
  String get gallery_rating_updated => '갤러리 평점이 업데이트되었습니다.';

  @override
  String get common_image => '이미지';

  @override
  String get common_gallery => '갤러리';

  @override
  String get images_gallery_rating_unavailable =>
      '갤러리 평점은 갤러리를 탐색할 때만 사용할 수 있습니다.';

  @override
  String images_rating(String rating) {
    return '평점: $rating / 5';
  }

  @override
  String get images_filtered_by_gallery => '갤러리로 필터링됨';

  @override
  String get images_slideshow_need_two => '슬라이드쇼에는 최소 2개의 이미지가 필요합니다.';

  @override
  String get images_slideshow_start_title => '슬라이드쇼 시작';

  @override
  String images_slideshow_interval(num seconds) {
    return '간격: ${seconds}s';
  }

  @override
  String images_slideshow_transition_ms(num ms) {
    return '전환: ${ms}ms';
  }

  @override
  String get common_forward => '앞으로';

  @override
  String get common_backward => '뒤로';

  @override
  String get images_slideshow_loop_title => '슬라이드쇼 반복';

  @override
  String get common_cancel => '취소';

  @override
  String get common_start => '시작';

  @override
  String get common_done => '완료';

  @override
  String get settings_keybind_assign_shortcut => '단축키 할당';

  @override
  String get settings_keybind_press_any => '아무 키 조합이나 누르세요...';

  @override
  String get scenes_select_tags => '태그 선택';

  @override
  String get scenes_no_scrapers => '사용 가능한 스크레이퍼가 없습니다';

  @override
  String get scenes_select_scraper => '스크레이퍼 선택';

  @override
  String get scenes_no_results_found => '결과를 찾을 수 없습니다';

  @override
  String get scenes_select_result => '결과 선택';

  @override
  String scenes_scrape_failed(String error) {
    return '스크랩 실패: $error';
  }

  @override
  String get scenes_updated_successfully => '장면이 성공적으로 업데이트되었습니다';

  @override
  String scenes_update_failed(String error) {
    return '장면 업데이트에 실패했습니다: $error';
  }

  @override
  String get scenes_edit_title => '장면 편집';

  @override
  String get scenes_field_studio => '스튜디오';

  @override
  String get scenes_field_tags => '태그';

  @override
  String get scenes_field_urls => '링크';

  @override
  String get scenes_edit_performer => '출연자 편집';

  @override
  String get scenes_edit_studio => '스튜디오 편집';

  @override
  String get common_no_title => '제목 없음';

  @override
  String get scenes_select_studio => '스튜디오 선택';

  @override
  String get scenes_select_performers => '출연자 선택';

  @override
  String get scenes_unmatched_scraped_tags => '일치하지 않는 스크랩된 태그';

  @override
  String get scenes_unmatched_scraped_performers => '일치하지 않는 스크랩된 출연자';

  @override
  String get scenes_no_matching_performer_found =>
      '라이브러리에서 일치하는 출연자를 찾을 수 없습니다';

  @override
  String get common_unknown => '알 수 없음';

  @override
  String scenes_studio_id_prefix(String id) {
    return '스튜디오 ID: $id';
  }

  @override
  String get tags_search_placeholder => '태그 검색...';

  @override
  String get scenes_duration_short => '< 5분';

  @override
  String get scenes_duration_medium => '5-20분';

  @override
  String get scenes_duration_long => '> 20분';

  @override
  String get details_scene_fingerprint_query => '씬 지문 쿼리';

  @override
  String get scenes_available_scrapers => '사용 가능한 스크레이퍼';

  @override
  String get scrape_results_existing => '기존 결과';

  @override
  String get scrape_results_scraped => '스크랩된 결과';

  @override
  String get stats_refresh_statistics => '통계 새로 고침';

  @override
  String get stats_library_stats => '도서관 통계';

  @override
  String get stats_stash_glance => '귀하의 보관함을 한 눈에 살펴보세요';

  @override
  String get stats_content => '콘텐츠';

  @override
  String get stats_organization => '조직';

  @override
  String get stats_activity => '활동';

  @override
  String get stats_scenes => '장면';

  @override
  String get stats_galleries => '갤러리';

  @override
  String get stats_performers => '출연자';

  @override
  String get stats_studios => '스튜디오';

  @override
  String get stats_groups => '여러 떼';

  @override
  String get stats_tags => '태그';

  @override
  String get stats_total_plays => '총 플레이 횟수';

  @override
  String stats_unique_items(int count) {
    return '$count unique items';
  }

  @override
  String get stats_total_o_count => '총 O-카운트';

  @override
  String get cast_airplay_pairing => 'AirPlay 페어링';

  @override
  String get cast_enter_pin => 'TV에 표시된 4자리 PIN을 입력하세요.';

  @override
  String get cast_pair => '쌍';

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
  String get cast_searching => '기기 검색 중...';

  @override
  String get cast_cast_to_device => '기기로 전송';

  @override
  String get settings_storage_images => '이미지';

  @override
  String get settings_storage_videos => '비디오';

  @override
  String get settings_storage_database => '데이터 베이스';

  @override
  String get settings_storage_clearing_image => '이미지 캐시를 지우는 중...';

  @override
  String get settings_storage_clearing_video => '비디오 캐시를 지우는 중...';

  @override
  String get settings_storage_clearing_database => '데이터베이스 캐시를 지우는 중...';

  @override
  String get settings_storage_cleared_image => '이미지 캐시가 삭제되었습니다.';

  @override
  String get settings_storage_cleared_video => '비디오 캐시가 삭제되었습니다.';

  @override
  String get settings_storage_cleared_database => '데이터베이스 캐시가 지워졌습니다.';

  @override
  String get settings_storage_clear => '분명한';

  @override
  String get settings_storage_error_loading => '크기를 로드하는 중에 오류가 발생했습니다.';

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
  String get settings_storage_unlimited => '제한 없는';

  @override
  String get settings_storage_limits => '제한';

  @override
  String get settings_storage_limits_subtitle => '최대 캐시 크기 설정';

  @override
  String get settings_storage_max_image_cache => '최대 이미지 캐시(MB)';

  @override
  String get settings_storage_max_video_cache => '최대 비디오 캐시(MB)';

  @override
  String get settings_storage => '저장소 및 캐시';

  @override
  String get settings_storage_usage => '저장소 사용량';

  @override
  String get settings_storage_usage_subtitle => '현재 캐시 사용 공간';

  @override
  String get settings_storage_subtitle => '로컬 캐시 및 저장 용량 제한 관리';

  @override
  String get performers_field_name => '이름';

  @override
  String get performers_field_url => 'URL';

  @override
  String get performers_field_details => '상세 정보';

  @override
  String get performers_field_birth_year => '출생 연도';

  @override
  String get performers_field_age => '나이';

  @override
  String get performers_field_death_year => '사망 연도';

  @override
  String get performers_field_scene_count => '장면 수';

  @override
  String get performers_field_image_count => '이미지 수';

  @override
  String get performers_field_gallery_count => '갤러리 수';

  @override
  String get performers_field_play_count => '재생 횟수';

  @override
  String get performers_field_o_counter => 'O-카운터';

  @override
  String get performers_field_tag_count => '태그 수';

  @override
  String get performers_field_created_at => '생성 일시';

  @override
  String get performers_field_updated_at => '수정 일시';

  @override
  String get galleries_field_title => '제목';

  @override
  String get galleries_field_details => '상세 정보';

  @override
  String get galleries_field_date => '날짜';

  @override
  String get galleries_field_performer_age => '출연자 나이';

  @override
  String get galleries_field_performer_count => '출연자 수';

  @override
  String get galleries_field_tag_count => '태그 수';

  @override
  String get galleries_field_url => 'URL';

  @override
  String get galleries_field_id => 'ID';

  @override
  String get galleries_field_path => '경로';

  @override
  String get galleries_field_checksum => '체크섬';

  @override
  String get galleries_field_image_count => '이미지 수';

  @override
  String get galleries_field_file_count => '파일 수';

  @override
  String get galleries_field_created_at => '생성 일시';

  @override
  String get galleries_field_updated_at => '수정 일시';

  @override
  String get images_field_title => '제목';

  @override
  String get images_field_details => '상세 정보';

  @override
  String get images_field_path => '경로';

  @override
  String get images_field_url => 'URL';

  @override
  String get images_field_file_count => '파일 수';

  @override
  String get images_field_o_counter => 'O-카운터';

  @override
  String get studios_field_name => '이름';

  @override
  String get studios_field_details => '상세 정보';

  @override
  String get studios_field_aliases => '별칭';

  @override
  String get studios_field_url => 'URL';

  @override
  String get studios_field_tag_count => '태그 수';

  @override
  String get studios_field_scene_count => '장면 수';

  @override
  String get studios_field_image_count => '이미지 수';

  @override
  String get studios_field_gallery_count => '갤러리 수';

  @override
  String get studios_field_sub_studio_count => '하위 스튜디오 수';

  @override
  String get studios_field_created_at => '생성 일시';

  @override
  String get studios_field_updated_at => '수정 일시';

  @override
  String get scenes_field_performer_age => '출연자 나이';

  @override
  String get scenes_field_performer_count => '출연자 수';

  @override
  String get scenes_field_tag_count => '태그 수';

  @override
  String get scenes_field_code => '코드';

  @override
  String get scenes_field_details => '상세 정보';

  @override
  String get scenes_field_director => '감독';

  @override
  String get scenes_field_url => 'URL';

  @override
  String get scenes_field_date => '날짜';

  @override
  String get scenes_field_path => '경로';

  @override
  String get scenes_field_captions => '자막';

  @override
  String get scenes_field_duration => '길이 (초)';

  @override
  String get scenes_field_bitrate => '비트레이트';

  @override
  String get scenes_field_video_codec => '비디오 코덱';

  @override
  String get scenes_field_audio_codec => '오디오 코덱';

  @override
  String get scenes_field_framerate => '프레임레이트';

  @override
  String get scenes_field_file_count => '파일 수';

  @override
  String get scenes_field_play_count => '재생 횟수';

  @override
  String get scenes_field_play_duration => '재생 시간';

  @override
  String get scenes_field_o_counter => 'O-카운터';

  @override
  String get scenes_field_last_played_at => '최근 재생 일시';

  @override
  String get scenes_field_resume_time => '이어보기 시간';

  @override
  String get scenes_field_interactive_speed => '인터랙티브 속도';

  @override
  String get scenes_field_id => 'ID';

  @override
  String get scenes_field_stash_id_count => 'Stash ID 수';

  @override
  String get scenes_field_oshash => 'Oshash';

  @override
  String get scenes_field_checksum => '체크섬';

  @override
  String get scenes_field_phash => 'Phash';

  @override
  String get scenes_field_created_at => '생성 일시';

  @override
  String get scenes_field_updated_at => '수정 일시';

  @override
  String get cast_stopped_resuming_locally => '전송이 중단되었습니다. 로컬에서 재생을 재개합니다';

  @override
  String get cast_stop_casting => '전송 중지';

  @override
  String get cast_cast => '전송';

  @override
  String get common_add => '추가';

  @override
  String get common_remove => '제거';

  @override
  String get common_clear => '비우기';

  @override
  String get common_download => '다운로드';

  @override
  String get common_star => '스타';

  @override
  String get settings_interface_card_title_font_size => '카드 제목 글자 크기';

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
  String get saving_video => '갤러리에 저장 중...';

  @override
  String get saved_to_album => 'StashFlow 앨범에 저장됨';

  @override
  String gallery_error(String message) {
    return '갤러리 오류: $message';
  }

  @override
  String failed_to_save(String error) {
    return '저장 실패: $error';
  }

  @override
  String get saving_image => '이미지 저장 중...';

  @override
  String common_select(String label) {
    return '$label 선택';
  }

  @override
  String common_saved_to(String path) {
    return '$path에 저장됨';
  }
}
