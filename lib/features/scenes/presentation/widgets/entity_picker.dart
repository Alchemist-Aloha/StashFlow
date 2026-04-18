import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
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
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: context.l10n.common_search_placeholder,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
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
              child: listAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return Center(
                      child: Text(context.l10n.common_no_items),
                    );
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
                              _selectedIds.add(id);
                              _selectedEntities.add(item as T);
                            } else {
                              _selectedIds.remove(id);
                              _selectedEntities.removeWhere(
                                (e) => _getId(e) == id,
                              );
                            }
                          });
                          if (!widget.multiSelect && val == true) {
                            Navigator.of(context).pop([item as T]);
                          }
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (err, _) => Center(
                  child: Text(context.l10n.common_error(err.toString())),
                ),
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
        if (widget.multiSelect)
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(_selectedEntities);
            },
            child: Text(context.l10n.common_done),
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
