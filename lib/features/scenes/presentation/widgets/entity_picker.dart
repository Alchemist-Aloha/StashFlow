import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../studios/presentation/providers/studio_list_provider.dart';
import '../../../performers/presentation/providers/performer_list_provider.dart';
import '../../../tags/presentation/providers/tag_list_provider.dart';
import '../providers/scene_list_provider.dart';
import '../../../galleries/presentation/providers/gallery_list_provider.dart';
import '../../../studios/domain/entities/studio.dart';
import '../../../performers/domain/entities/performer.dart';
import '../../../tags/domain/entities/tag.dart';
import '../../domain/entities/scene.dart';
import '../../../galleries/domain/entities/gallery.dart';

class EntityPicker<T> extends ConsumerStatefulWidget {
  final String title;
  final String providerType; // 'studio', 'performer', 'tag'
  final bool multiSelect;
  final List<String>? initialSelection;

  const EntityPicker({
    required this.title,
    required this.providerType,
    this.multiSelect = false,
    this.initialSelection,
    super.key,
  });

  @override
  ConsumerState<EntityPicker<T>> createState() => _EntityPickerState<T>();
}

class _EntityPickerState<T> extends ConsumerState<EntityPicker<T>> {
  final _searchController = TextEditingController();
  final Set<String> _selectedIds = {};
  final Map<String, T> _selectedEntities = {};
  late Future<List<dynamic>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    if (widget.initialSelection != null) {
      _selectedIds.addAll(widget.initialSelection!);
    }
    _itemsFuture = _loadItems('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      content: SizedBox(
        width: double.maxFinite,
        // Using MediaQuery.sizeOf(context) instead of MediaQuery.of(context).size
        // to prevent unnecessary rebuilds when unrelated MediaQueryData properties change.
        height: MediaQuery.sizeOf(context).height * 0.6,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              textInputAction: TextInputAction.next,
              controller: _searchController,
              decoration: InputDecoration(
                hintText: context.l10n.common_search_placeholder,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: context.l10n.common_clear,
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _updateQuery('');
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onChanged: _updateQuery,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _itemsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        context.l10n.common_error(snapshot.error.toString()),
                      ),
                    );
                  }
                  final items = snapshot.data ?? [];
                  if (items.isEmpty) {
                    return Center(child: Text(context.l10n.common_no_items));
                  }
                  for (final item in items) {
                    final id = _getId(item);
                    if (_selectedIds.contains(id)) {
                      _selectedEntities[id] ??= item as T;
                    }
                  }
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final String id = _getId(item);
                      final String name = _getName(item);
                      final isSelected = _selectedIds.contains(id);

                      return CheckboxListTile(
                        title: Text(name),
                        value: isSelected,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              if (!widget.multiSelect) {
                                _selectedIds.clear();
                                _selectedEntities.clear();
                              }
                              _selectedIds.add(id);
                              _selectedEntities[id] = item as T;
                            } else {
                              _selectedIds.remove(id);
                              _selectedEntities.remove(id);
                            }
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.common_cancel),
        ),
        ElevatedButton(
          onPressed: () {
            if (widget.multiSelect) {
              Navigator.of(context).pop(
                _selectedIds
                    .map((id) => _selectedEntities[id])
                    .whereType<T>()
                    .toList(),
              );
              return;
            }
            Navigator.of(context).pop(_selectedEntity);
          },
          child: Text(context.l10n.common_done),
        ),
      ],
    );
  }

  T? get _selectedEntity {
    for (final id in _selectedIds) {
      final entity = _selectedEntities[id];
      if (entity != null) return entity;
    }
    return null;
  }

  void _updateQuery(String query) {
    setState(() {
      _itemsFuture = _loadItems(query);
    });
  }

  Future<List<dynamic>> _loadItems(String query) {
    final filter = query.isEmpty ? null : query;
    switch (widget.providerType) {
      case 'studio':
        return ref.read(studioRepositoryProvider).findStudios(filter: filter);
      case 'performer':
        return ref
            .read(performerRepositoryProvider)
            .findPerformers(filter: filter);
      case 'tag':
        return ref.read(tagRepositoryProvider).findTags(filter: filter);
      case 'scene':
        return ref.read(sceneRepositoryProvider).findScenes(filter: filter);
      case 'gallery':
        return ref
            .read(galleryRepositoryProvider)
            .findGalleries(filter: filter);
      default:
        return Future.value([]);
    }
  }

  String _getId(dynamic item) {
    if (item is Studio) return item.id;
    if (item is Performer) return item.id;
    if (item is Tag) return item.id;
    if (item is Scene) return item.id;
    if (item is Gallery) return item.id;
    return '';
  }

  String _getName(dynamic item) {
    if (item is Studio) return item.name;
    if (item is Performer) return item.name;
    if (item is Tag) return item.name;
    if (item is Scene) return item.title;
    if (item is Gallery) return item.displayName;
    return '';
  }
}
