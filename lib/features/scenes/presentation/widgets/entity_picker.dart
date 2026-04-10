import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../studios/presentation/providers/studio_list_provider.dart';
import '../../../performers/presentation/providers/performer_list_provider.dart';
import '../../../tags/presentation/providers/tag_list_provider.dart';
import '../../../studios/domain/entities/studio.dart';
import '../../../performers/domain/entities/performer.dart';
import '../../../tags/domain/entities/tag.dart';

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
  final List<T> _selectedEntities = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialSelection != null) {
      _selectedIds.addAll(widget.initialSelection!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AsyncValue<List<dynamic>> listAsync;

    switch (widget.providerType) {
      case 'studio':
        listAsync = ref.watch(studioListProvider);
        break;
      case 'performer':
        listAsync = ref.watch(performerListProvider);
        break;
      case 'tag':
        listAsync = ref.watch(tagListProvider);
        break;
      default:
        listAsync = const AsyncValue.data([]);
    }

    return AlertDialog(
      title: Text(widget.title),
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'Clear search',
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
            Flexible(
              child: listAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No entities found'),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final String id = _getId(item);
                      final String name = _getName(item);
                      final isSelected = _selectedIds.contains(id);

                      return ListTile(
                        title: Text(name),
                        selected: isSelected,
                        trailing: widget.multiSelect
                            ? Checkbox(
                                value: isSelected,
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      _selectedIds.add(id);
                                      _selectedEntities.add(item as T);
                                    } else {
                                      _selectedIds.remove(id);
                                      _selectedEntities.removeWhere(
                                        (e) => _getId(e) == id,
                                      );
                                    }
                                  });
                                },
                              )
                            : null,
                        onTap: () {
                          if (widget.multiSelect) {
                            setState(() {
                              if (isSelected) {
                                _selectedIds.remove(id);
                                _selectedEntities.removeWhere(
                                  (e) => _getId(e) == id,
                                );
                              } else {
                                _selectedIds.add(id);
                                _selectedEntities.add(item as T);
                              }
                            });
                          } else {
                            Navigator.of(context).pop(item);
                          }
                        },
                      );
                    },
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error: $err'),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        if (widget.multiSelect)
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(_selectedEntities);
            },
            child: const Text('Done'),
          ),
      ],
    );
  }

  void _updateQuery(String query) {
    switch (widget.providerType) {
      case 'studio':
        ref.read(studioSearchQueryProvider.notifier).update(query);
        break;
      case 'performer':
        ref.read(performerSearchQueryProvider.notifier).update(query);
        break;
      case 'tag':
        ref.read(tagSearchQueryProvider.notifier).update(query);
        break;
    }
  }

  String _getId(dynamic item) {
    if (item is Studio) return item.id;
    if (item is Performer) return item.id;
    if (item is Tag) return item.id;
    return '';
  }

  String _getName(dynamic item) {
    if (item is Studio) return item.name;
    if (item is Performer) return item.name;
    if (item is Tag) return item.name;
    return '';
  }
}
