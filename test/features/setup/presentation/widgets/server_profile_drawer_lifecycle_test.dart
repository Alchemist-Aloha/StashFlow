import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'server profile drawer guards async state and ref updates after dispose',
    () {
      final source = File(
        'lib/features/setup/presentation/widgets/server_profile_drawer.dart',
      ).readAsStringSync();

      expect(
        source,
        contains(
          '        final loggedIn = await service.login(\n'
          '          graphqlEndpoint: endpointUri,\n'
          '          username: username,\n'
          '          password: password,\n'
          '        );\n'
          '\n'
          '        if (!mounted) return;\n'
          '        if (!loggedIn) {',
        ),
      );
      expect(source, contains('await notifier.updateProfileCredentials('));
      expect(
        source,
        contains(
          '    if (!mounted) return;\n'
          '\n'
          '    final profile = ServerProfile(',
        ),
      );
      expect(
        source,
        contains(
          '      await ref\n'
          '          .read(serverProfilesProvider.notifier)\n'
          '          .removeProfile(widget.profile!.id);\n'
          '      if (!mounted) return;\n',
        ),
      );
    },
  );
}
