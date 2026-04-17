import '../../utils/pagination.dart';

mixin PaginationNotifierMixin {
  int _perPage = kDefaultPageSize;

  int get perPage => _perPage;

  void setPerPageInternal(int value, {required void Function() onInvalidate}) {
    if (_perPage == value) return;
    _perPage = value;
    onInvalidate();
  }
}
