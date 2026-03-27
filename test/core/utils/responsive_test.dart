import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/utils/responsive.dart';

void main() {
  testWidgets('Responsive utility identifies mobile and tablet widths', (
    tester,
  ) async {
    // Mobile width: 400 logical pixels
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(400, 800)),
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              expect(
                Responsive.isMobile(context),
                isTrue,
                reason: 'Should be mobile at 400px',
              );
              expect(Responsive.isTablet(context), isFalse);
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    // Tablet width: 800 logical pixels
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(800, 1200)),
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              expect(
                Responsive.isMobile(context),
                isFalse,
                reason: 'Should not be mobile at 800px',
              );
              expect(
                Responsive.isTablet(context),
                isTrue,
                reason: 'Should be tablet at 800px',
              );
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  });
}
