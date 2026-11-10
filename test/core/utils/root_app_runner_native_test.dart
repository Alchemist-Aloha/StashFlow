import 'dart:ui' show ViewFocusEvent, ViewFocusState;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/utils/root_app_runner_native.dart';

class _FocusEvents extends WidgetsBindingObserver {
  final events = <ViewFocusEvent>[];

  @override
  void didChangeViewFocus(ViewFocusEvent event) => events.add(event);
}

void main() {
  testWidgets('Linux activation waits for the view frame and preserves order', (
    tester,
  ) async {
    final events = _FocusEvents();
    tester.binding.addObserver(events);
    addTearDown(() => tester.binding.removeObserver(events));
    final observer = LinuxWindowFocusObserver((id) => id);
    observer.onWindowEvent(10, 'focus');
    observer.onWindowEvent(10, 'blur');
    observer.onWindowEvent(20, 'focus');
    expect(events.events, isEmpty);
    await tester.pump();
    expect(events.events.map((event) => event.viewId), [10, 10, 20]);
    expect(events.events.map((event) => event.state), [
      ViewFocusState.focused,
      ViewFocusState.unfocused,
      ViewFocusState.focused,
    ]);
  });

  testWidgets('Linux window activation restores and releases keyboard focus', (
    tester,
  ) async {
    const windowId = 42;
    final observer = LinuxWindowFocusObserver((id) {
      expect(id, windowId);
      return tester.view.viewId;
    });
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    var presses = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
                presses++,
          },
          child: Focus(
            focusNode: focusNode,
            autofocus: true,
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
    await tester.pump();

    // Public IDs differ from Flutter view IDs, including after hot restart.
    observer.onWindowEvent(windowId, 'blur');
    await tester.pump();
    expect(focusNode.hasFocus, isFalse);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    expect(presses, 0);

    // Native activation, not a pointer click or another autofocus pass.
    observer.onWindowEvent(windowId, 'focus');
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    expect(presses, 1);
    observer.onWindowEvent(windowId, 'resize');
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);

    observer.onDialogEvent(windowId, 'blur');
    await tester.pump();
    expect(focusNode.hasFocus, isFalse);
    observer.onDialogEvent(windowId, 'focus');
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    expect(presses, 2);
  });
}
