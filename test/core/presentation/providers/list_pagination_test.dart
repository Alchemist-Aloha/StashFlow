import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/presentation/providers/list_pagination.dart';

class _PagedList extends AsyncNotifier<List<int>> with ListPagination<int> {
  _PagedList(this.fetch);

  final Future<List<int>> Function(int page) fetch;
  final appendedPages = <List<int>>[];

  @override
  Future<List<int>> build() async {
    final generation = resetPagination();
    final items = await fetch(1);
    updatePagination(items, 2, generation);
    return items;
  }

  Future<void> fetchNextPage() =>
      loadNextPage(perPage: 2, fetch: fetch, onLoaded: appendedPages.add);

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

void main() {
  test(
    'coalesces requests, appends once and stops after a short page',
    () async {
      final nextPage = Completer<List<int>>();
      final calls = <int>[];
      final provider = AsyncNotifierProvider<_PagedList, List<int>>(
        () => _PagedList((page) async {
          calls.add(page);
          return page == 1 ? [1, 2] : nextPage.future;
        }),
      );
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(provider.future);
      final notifier = container.read(provider.notifier);

      final loading = notifier.fetchNextPage();
      await notifier.fetchNextPage();
      expect(notifier.isLoadingMore, isTrue);
      expect(calls, [1, 2]);
      nextPage.complete([3]);
      await loading;

      expect(container.read(provider).value, [1, 2, 3]);
      expect(notifier.appendedPages, [
        [3],
      ]);
      expect(notifier.hasMore, isFalse);
      expect(notifier.isLoadingMore, isFalse);
      await notifier.fetchNextPage();
      expect(calls, [1, 2]);
    },
  );

  test('failure preserves items and retries the same page', () async {
    final calls = <int>[];
    var fail = true;
    final provider = AsyncNotifierProvider<_PagedList, List<int>>(
      () => _PagedList((page) async {
        calls.add(page);
        if (page == 1) return [1, 2];
        if (fail) throw StateError('offline');
        return [3];
      }),
    );
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(provider.future);
    final notifier = container.read(provider.notifier);

    await expectLater(notifier.fetchNextPage(), throwsStateError);
    expect(container.read(provider).value, [1, 2]);
    expect(container.read(provider).hasError, isFalse);
    expect(notifier.isLoadingMore, isFalse);
    expect(notifier.hasMore, isTrue);
    expect(notifier.appendedPages, isEmpty);

    fail = false;
    await notifier.fetchNextPage();
    expect(calls, [1, 2, 2]);
    expect(container.read(provider).value, [1, 2, 3]);
  });

  for (final failOldRequest in [false, true]) {
    test(
      'ignores stale ${failOldRequest ? 'failures' : 'results'} without unlocking a newer request',
      () async {
        final oldPage = Completer<List<int>>();
        final newPage = Completer<List<int>>();
        var refreshed = false;
        final provider = AsyncNotifierProvider<_PagedList, List<int>>(
          () => _PagedList((page) async {
            if (page == 1) return refreshed ? [10, 11] : [1, 2];
            return refreshed ? newPage.future : oldPage.future;
          }),
        );
        final container = ProviderContainer();
        addTearDown(container.dispose);
        await container.read(provider.future);
        final notifier = container.read(provider.notifier);
        final staleRequest = notifier.fetchNextPage();

        refreshed = true;
        await notifier.refresh();
        final currentRequest = notifier.fetchNextPage();
        if (failOldRequest) {
          oldPage.completeError(StateError('old failure'));
        } else {
          oldPage.complete([3]);
        }
        await staleRequest;
        expect(container.read(provider).value, [10, 11]);
        expect(notifier.isLoadingMore, isTrue);
        expect(notifier.hasMore, isTrue);
        expect(notifier.appendedPages, isEmpty);

        newPage.complete([12]);
        await currentRequest;
        expect(container.read(provider).value, [10, 11, 12]);
        expect(notifier.isLoadingMore, isFalse);
        expect(notifier.hasMore, isFalse);
      },
    );
  }

  for (final failRequest in [false, true]) {
    test(
      'ignores a ${failRequest ? 'failure' : 'result'} after disposal',
      () async {
        final nextPage = Completer<List<int>>();
        final provider = AsyncNotifierProvider<_PagedList, List<int>>(
          () => _PagedList((page) async {
            return page == 1 ? [1, 2] : nextPage.future;
          }),
        );
        final container = ProviderContainer();
        await container.read(provider.future);
        final loading = container.read(provider.notifier).fetchNextPage();
        container.dispose();
        if (failRequest) {
          nextPage.completeError(StateError('offline'));
        } else {
          nextPage.complete([3]);
        }
        await loading;
      },
    );
  }

  test('a short first page disables pagination', () async {
    final calls = <int>[];
    final provider = AsyncNotifierProvider<_PagedList, List<int>>(
      () => _PagedList((page) async {
        calls.add(page);
        return [1];
      }),
    );
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(provider.future);
    final notifier = container.read(provider.notifier);
    await notifier.fetchNextPage();
    expect(notifier.hasMore, isFalse);
    expect(calls, [1]);
  });
}
