import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ListScrollTarget { scene, performer, studio, tag, gallery, image, group }

final listScrollControllerProvider =
    NotifierProvider.family<
      ListScrollControllerNotifier,
      ScrollController,
      ListScrollTarget
    >(ListScrollControllerNotifier.new);

class ListScrollControllerNotifier extends Notifier<ScrollController> {
  ListScrollControllerNotifier(this.target);

  final ListScrollTarget target;

  @override
  ScrollController build() {
    final controller = ScrollController();
    ref.onDispose(controller.dispose);
    return controller;
  }

  void scrollToTop() {
    if (state.hasClients) {
      state.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}
