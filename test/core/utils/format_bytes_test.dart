import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/utils/format_bytes.dart';

void main() {
  test('formats byte sizes consistently for metadata panels', () {
    expect(formatBytes(0), '0 B');
    expect(formatBytes(512), '512 B');
    expect(formatBytes(1024), '1.00 KB');
    expect(formatBytes(1572864), '1.50 MB');
    expect(formatBytes(3221225472), '3.00 GB');
  });
}
