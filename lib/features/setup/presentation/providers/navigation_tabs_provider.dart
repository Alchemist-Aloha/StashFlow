import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';

/// Represents a main navigation tab in the application.
enum NavigationTabType {
  scenes('scenes', 'Scenes', Icons.video_library),
  performers('performers', 'Performers', Icons.people),
  studios('studios', 'Studios', Icons.business),
  tags('tags', 'Tags', Icons.local_offer),
  galleries('galleries', 'Galleries', Icons.perm_media);

  final String id;
  final String label;
  final IconData icon;

  const NavigationTabType(this.id, this.label, this.icon);

  static NavigationTabType fromId(String id) {
    return NavigationTabType.values.firstWhere(
      (t) => t.id == id,
      orElse: () => NavigationTabType.scenes,
    );
  }
}

/// Data model for a navigation tab with visibility state.
class NavigationTab {
  final NavigationTabType type;
  final bool visible;

  const NavigationTab({required this.type, this.visible = true});

  NavigationTab copyWith({bool? visible}) {
    return NavigationTab(type: type, visible: visible ?? this.visible);
  }

  Map<String, dynamic> toJson() => {'id': type.id, 'visible': visible};

  factory NavigationTab.fromJson(Map<String, dynamic> json) {
    return NavigationTab(
      type: NavigationTabType.fromId(json['id'] as String),
      visible: json['visible'] as bool? ?? true,
    );
  }
}

/// Notifier for managing the order and visibility of navigation tabs.
class NavigationTabsNotifier extends Notifier<List<NavigationTab>> {
  static const _key = 'navigation_tabs_config';

  @override
  List<NavigationTab> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final raw = prefs.getString(_key);

    if (raw == null) {
      return NavigationTabType.values
          .map((t) => NavigationTab(type: t))
          .toList();
    }

    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((j) => NavigationTab.fromJson(j)).toList();
    } catch (_) {
      return NavigationTabType.values
          .map((t) => NavigationTab(type: t))
          .toList();
    }
  }

  /// Updates the entire list of tabs (for reordering or multiple visibility changes).
  Future<void> updateTabs(List<NavigationTab> tabs) async {
    state = tabs;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(
      _key,
      jsonEncode(tabs.map((t) => t.toJson()).toList()),
    );
  }

  /// Toggles the visibility of a specific tab.
  Future<void> toggleTab(NavigationTabType type, bool visible) async {
    final newState = state.map((t) {
      if (t.type == type) return t.copyWith(visible: visible);
      return t;
    }).toList();

    // Ensure at least one tab is always visible.
    if (!newState.any((t) => t.visible)) return;

    await updateTabs(newState);
  }

  /// Reorders tabs.
  Future<void> reorder(int oldIndex, int newIndex) async {
    final tabs = List<NavigationTab>.from(state);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = tabs.removeAt(oldIndex);
    tabs.insert(newIndex, item);
    await updateTabs(tabs);
  }
}

/// Provider for the list of navigation tabs.
final navigationTabsProvider =
    NotifierProvider<NavigationTabsNotifier, List<NavigationTab>>(
      NavigationTabsNotifier.new,
    );
