import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/preferences/shared_preferences_provider.dart';

/// A customizable utility button in the inline or fullscreen player.
enum PlayerControlButton {
  stream,
  subtitles,
  speed,
  volume,
  cast,
  pip,
  fullscreen,
  playlist,
  random,
}

/// Where a player utility button is rendered.
enum PlayerControlPlacement { bottom, topRight }

/// Visibility and placement of one button; list order is display order.
class PlayerControlItem {
  const PlayerControlItem(
    this.button, {
    this.visible = true,
    this.placement = PlayerControlPlacement.bottom,
  });

  final PlayerControlButton button;
  final bool visible;
  final PlayerControlPlacement placement;

  PlayerControlItem copyWith({
    bool? visible,
    PlayerControlPlacement? placement,
  }) => PlayerControlItem(
    button,
    visible: visible ?? this.visible,
    placement: placement ?? this.placement,
  );

  Map<String, dynamic> toJson() => {
    'id': button.name,
    'visible': visible,
    'placement': placement.name,
  };
}

/// Persists the button layout for one player mode (inline or fullscreen).
class PlayerControlsLayoutNotifier extends Notifier<List<PlayerControlItem>> {
  PlayerControlsLayoutNotifier({required this.fullscreen});

  final bool fullscreen;

  static const inlineKey = 'player_controls_layout_inline';
  static const fullscreenKey = 'player_controls_layout_fullscreen';

  String get _key => fullscreen ? fullscreenKey : inlineKey;

  /// Matches the player layout from before customization existed.
  List<PlayerControlItem> defaults() => [
    for (final button in PlayerControlButton.values)
      PlayerControlItem(
        button,
        visible: fullscreen || button != PlayerControlButton.random,
        placement:
            button == PlayerControlButton.playlist ||
                button == PlayerControlButton.random
            ? PlayerControlPlacement.topRight
            : PlayerControlPlacement.bottom,
      ),
  ];

  @override
  List<PlayerControlItem> build() {
    final raw = ref.watch(sharedPreferencesProvider).getString(_key);
    if (raw == null) return defaults();
    final byButton = <PlayerControlButton, PlayerControlItem>{};
    try {
      for (final entry in jsonDecode(raw) as List<dynamic>) {
        final json = entry as Map<String, dynamic>;
        final button = PlayerControlButton.values.asNameMap()[json['id']];
        if (button == null) continue;
        byButton.putIfAbsent(
          button,
          () => PlayerControlItem(
            button,
            visible: json['visible'] as bool? ?? true,
            placement:
                PlayerControlPlacement.values.asNameMap()[json['placement']] ??
                PlayerControlPlacement.bottom,
          ),
        );
      }
    } on Object {
      return defaults();
    }
    // Buttons added in later versions keep their default slot at the end.
    for (final item in defaults()) {
      byButton.putIfAbsent(item.button, () => item);
    }
    return byButton.values.toList();
  }

  Future<void> _save(List<PlayerControlItem> items) async {
    state = items;
    await ref
        .read(sharedPreferencesProvider)
        .setString(_key, jsonEncode([for (final i in items) i.toJson()]));
  }

  Future<void> update(PlayerControlItem item) =>
      _save([for (final i in state) i.button == item.button ? item : i]);

  Future<void> reorder(int oldIndex, int newIndex) {
    final items = List.of(state);
    items.insert(newIndex, items.removeAt(oldIndex));
    return _save(items);
  }

  Future<void> reset() async {
    state = defaults();
    await ref.read(sharedPreferencesProvider).remove(_key);
  }
}

final inlinePlayerControlsLayoutProvider =
    NotifierProvider<PlayerControlsLayoutNotifier, List<PlayerControlItem>>(
      () => PlayerControlsLayoutNotifier(fullscreen: false),
    );

final fullscreenPlayerControlsLayoutProvider =
    NotifierProvider<PlayerControlsLayoutNotifier, List<PlayerControlItem>>(
      () => PlayerControlsLayoutNotifier(fullscreen: true),
    );

/// The layout provider for the given player mode.
NotifierProvider<PlayerControlsLayoutNotifier, List<PlayerControlItem>>
playerControlsLayoutProvider(bool fullscreen) => fullscreen
    ? fullscreenPlayerControlsLayoutProvider
    : inlinePlayerControlsLayoutProvider;
