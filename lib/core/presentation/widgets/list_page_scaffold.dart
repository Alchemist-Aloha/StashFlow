import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import 'error_state_view.dart';
import '../../utils/pagination.dart';

class ListPageScaffold<T> extends ConsumerStatefulWidget {
  const ListPageScaffold({
    super.key,
    required this.title,
    required this.searchHint,
    required this.onSearchChanged,
    required this.provider,
    this.itemBuilder,
    this.customBody,
    this.gridDelegate,
    this.actions = const [],
    this.sortBar,
    this.emptyMessage = 'No items found',
    this.onRefresh,
    this.onFetchNextPage,
    this.floatingActionButton,
    this.padding = const EdgeInsets.all(AppTheme.spacingMedium),
    this.hideAppBar = false,
    this.scrollController,
  });

  final String title;
  final String searchHint;
  final ValueChanged<String> onSearchChanged;
  final AsyncValue<List<T>> provider;
  final Widget Function(BuildContext context, T item)? itemBuilder;
  final Widget? customBody;
  final SliverGridDelegate? gridDelegate;
  final List<Widget> actions;
  final Widget? sortBar;
  final String emptyMessage;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onFetchNextPage;
  final Widget? floatingActionButton;
  final EdgeInsetsGeometry padding;
  final bool hideAppBar;
  final ScrollController? scrollController;

  @override
  ConsumerState<ListPageScaffold<T>> createState() =>
      _ListPageScaffoldState<T>();
}

class _ListPageScaffoldState<T> extends ConsumerState<ListPageScaffold<T>> {
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.hideAppBar ? null : AppBar(
        scrolledUnderElevation: 4.0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: context.colors.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                style: TextStyle(color: context.colors.onSurface),
                onChanged: widget.onSearchChanged,
              )
            : Text(
                widget.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() => _isSearching = false);
                _searchController.clear();
                widget.onSearchChanged('');
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => setState(() => _isSearching = true),
            ),
          ...widget.actions,
        ],
      ),
      body: Column(
        children: [
          if (widget.sortBar != null) widget.sortBar!,
          Expanded(
            child: widget.customBody ?? RefreshIndicator(
              onRefresh: widget.onRefresh ?? () async {},
              child: widget.provider.when(
                data: (items) {
                  if (items.isEmpty) {
                    return Center(
                      child: Text(
                        widget.emptyMessage,
                        style: TextStyle(
                          color: context.colors.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    );
                  }

                  return NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (shouldLoadNextPage(scrollInfo.metrics)) {
                        widget.onFetchNextPage?.call();
                      }
                      return false;
                    },
                    child: widget.gridDelegate != null
                        ? GridView.builder(
                            controller: widget.scrollController,
                            padding: widget.padding,
                            gridDelegate: widget.gridDelegate!,
                            itemCount: items.length,
                            itemBuilder: (context, index) =>
                                widget.itemBuilder!(context, items[index]),
                          )
                        : ListView.builder(
                            controller: widget.scrollController,
                            padding: widget.padding,
                            itemCount: items.length,
                            itemBuilder: (context, index) =>
                                widget.itemBuilder!(context, items[index]),
                          ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => ErrorStateView(
                  message: 'Failed to load items.\n$err',
                  onRetry: widget.onRefresh,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: widget.floatingActionButton,
    );
  }
}
