import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final listRandomSeedProvider =
    NotifierProvider.family<ListRandomSeedNotifier, int, String>(
      ListRandomSeedNotifier.new,
    );

class ListRandomSeedNotifier extends Notifier<int> {
  ListRandomSeedNotifier(this.key);

  final String key;

  @override
  int build() => Random().nextInt(10000000);

  void next() => state = Random().nextInt(10000000);
}
