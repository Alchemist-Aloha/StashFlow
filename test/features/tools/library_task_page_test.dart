import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:stash_app_flutter/core/utils/l10n_extensions.dart';
import 'package:stash_app_flutter/core/data/graphql/graphql_client.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/tools/data/library_tasks_repository.dart';
import 'package:stash_app_flutter/features/tools/domain/library_task.dart';
import 'package:stash_app_flutter/features/tools/presentation/pages/library_task_page.dart';
import 'package:stash_app_flutter/features/tools/presentation/providers/library_tasks_provider.dart';
import 'package:stash_app_flutter/features/tools/presentation/widgets/library_job_queue.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';

class _Repository extends LibraryTasksRepository {
  _Repository()
    : super(
        GraphQLClient(
          link: Link.function((request, [forward]) => const Stream.empty()),
          cache: GraphQLCache(),
        ),
      );
  bool loadFails = false;
  bool saveFails = false;
  bool directoryFails = false;
  Completer<void>? saving;
  Completer<String>? starting;
  final saves = <Map<String, bool>>[];
  final starts = <(LibraryTask, Map<String, bool>, List<String>?)>[];
  final browsed = <String>[];
  final stopped = <String?>[];
  List<LibraryJob> queue = [];
  LibraryJob? finished;
  int lookups = 0;

  @override
  Future<LibraryTaskSettings> loadSettings() async {
    if (loadFails) throw StateError('Offline');
    return LibraryTaskSettings.fromJson({
      'general': {
        'stashes': [
          {'path': '/media'},
        ],
      },
      'ui': {
        'taskDefaults': {
          'scan': {'scanGenerateCovers': true},
          'generate': {'covers': true, 'overwrite': true},
        },
      },
    });
  }

  @override
  Future<void> saveOptions(LibraryTask task, Map<String, bool> options) async {
    saves.add({...options});
    if (saving != null) await saving!.future;
    if (saveFails) throw StateError('Denied');
  }

  @override
  Future<String> start(
    LibraryTask task,
    Map<String, bool> options, {
    List<String>? paths,
  }) async {
    starts.add((task, {...options}, paths));
    return starting?.future ?? Future.value('42');
  }

  @override
  Future<ServerDirectory> directory(String path) async {
    browsed.add(path);
    if (directoryFails) throw StateError('No access');
    return ServerDirectory(path: path, parent: '/', children: ['/media/日本語']);
  }

  @override
  Future<List<LibraryJob>> jobs() async => [...queue];
  @override
  Future<LibraryJob?> findJob(String id) async {
    lookups++;
    return finished;
  }

  @override
  Future<void> stopJob(String id) async => stopped.add(id);
  @override
  Future<void> stopAllJobs() async => stopped.add(null);
}

Future<ProviderContainer> _pump(
  WidgetTester tester,
  _Repository repository, {
  LibraryTask task = LibraryTask.scan,
  Widget? child,
  Size size = const Size(900, 1400),
  double scale = 1,
  Brightness brightness = Brightness.light,
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final container = ProviderContainer(
    overrides: [
      libraryTasksRepositoryProvider.overrideWithValue(repository),
      serverUrlProvider.overrideWithValue(''),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.buildTheme(
          brightness,
          const Color(0xFF0F766E),
          fontSizeFactor: scale,
        ),
        home: child ?? LibraryTaskPage(task: task),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

SwitchListTile _toggle(WidgetTester tester, String key) =>
    tester.widget<SwitchListTile>(find.byKey(ValueKey(key)));
Finder get _runAll =>
    find.widgetWithText(FilledButton, 'Run for entire library');
Finder get _select =>
    find.widgetWithText(OutlinedButton, 'Run for selected folders');

void main() {
  testWidgets('remote defaults load; saves serialize and failures roll back', (
    tester,
  ) async {
    final repository = _Repository();
    await _pump(tester, repository);
    expect(_toggle(tester, 'scanGenerateCovers').value, isTrue);
    expect(_toggle(tester, 'scanGenerateImagePreviews').onChanged, isNull);
    repository.saving = Completer<void>();
    await tester.tap(find.byKey(const ValueKey('scanGeneratePreviews')));
    await tester.pump();
    expect(repository.saves.single['scanGeneratePreviews'], isTrue);
    expect(_toggle(tester, 'scanGenerateCovers').onChanged, isNull);
    expect(tester.widget<FilledButton>(_runAll).onPressed, isNull);
    repository.saving!.complete();
    await tester.pumpAndSettle();
    expect(_toggle(tester, 'scanGenerateImagePreviews').onChanged, isNotNull);
    repository.saving = null;
    repository.saveFails = true;
    await tester.tap(find.byKey(const ValueKey('scanGenerateCovers')));
    await tester.pumpAndSettle();
    expect(_toggle(tester, 'scanGenerateCovers').value, isTrue);
    expect(repository.saves.last['scanGenerateCovers'], isFalse);
    expect(
      find.text(
        'Could not save this change to the server. The previous value was restored; try again.',
      ),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('load failure offers retry', (tester) async {
    final repository = _Repository()..loadFails = true;
    await _pump(tester, repository);
    expect(find.byType(SwitchListTile), findsNothing);
    repository.loadFails = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.byType(SwitchListTile), findsNWidgets(scanOptionKeys.length));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('all-library submission acknowledges queued ID, not completion', (
    tester,
  ) async {
    final repository = _Repository();
    await _pump(tester, repository);
    await tester.tap(_runAll);
    await tester.pumpAndSettle();
    expect(repository.starts.single.$1, LibraryTask.scan);
    expect(repository.starts.single.$3, isNull);
    expect(find.text('Job 42 queued on the server.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'server picker browses, deduplicates, removes and submits exact remote paths',
    (tester) async {
      final repository = _Repository();
      await _pump(tester, repository);
      await tester.tap(_select);
      await tester.pumpAndSettle();
      Finder confirm() => find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(FilledButton),
      );
      expect(tester.widget<FilledButton>(confirm()).onPressed, isNull);
      await tester.tap(find.text('/media'));
      await tester.pumpAndSettle();
      expect(repository.browsed, ['/media']);
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Remove'), findsOneWidget);
      await tester.tap(find.byTooltip('Remove'));
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(confirm()).onPressed, isNull);
      await tester.enterText(find.byType(TextField), r'C:\Media\日本語');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      await tester.tap(confirm());
      await tester.pumpAndSettle();
      expect(repository.starts.single.$3, [r'C:\Media\日本語']);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('cancel does not launch a job; directory error can retry', (
    tester,
  ) async {
    final repository = _Repository()..directoryFails = true;
    await _pump(tester, repository);
    await tester.tap(_select);
    await tester.pumpAndSettle();
    await tester.tap(find.text('/media'));
    await tester.pumpAndSettle();
    repository.directoryFails = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(repository.browsed, ['/media', '/media']);
    expect(find.text('/media/日本語'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(repository.starts, isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'profile switch dismisses the remote picker and reloads defaults',
    (tester) async {
      final first = _Repository();
      final container = await _pump(tester, first);
      await tester.tap(_select);
      await tester.pumpAndSettle();
      final second = _Repository();
      container.updateOverrides([
        libraryTasksRepositoryProvider.overrideWithValue(second),
        serverUrlProvider.overrideWithValue(''),
      ]);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(first.starts, isEmpty);
      await tester.tap(_runAll);
      await tester.pumpAndSettle();
      expect(second.starts, hasLength(1));
      expect(first.starts, isEmpty);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('profile switch ignores an old submission response', (
    tester,
  ) async {
    final first = _Repository()..starting = Completer<String>();
    final container = await _pump(tester, first);
    await tester.tap(_runAll);
    await tester.pump();
    final second = _Repository();
    container.updateOverrides([
      libraryTasksRepositoryProvider.overrideWithValue(second),
      serverUrlProvider.overrideWithValue(''),
    ]);
    await tester.pumpAndSettle();
    first.starting!.complete('old-profile-job');
    await tester.pumpAndSettle();
    expect(find.textContaining('old-profile-job'), findsNothing);
    expect(second.starts, isEmpty);
    await tester.tap(_runAll);
    await tester.pumpAndSettle();
    expect(second.starts.single.$1, LibraryTask.scan);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('failed submissions allow retry without claiming success', (
    tester,
  ) async {
    final repository = _Repository()..starting = Completer<String>();
    await _pump(tester, repository);
    await tester.tap(_runAll);
    await tester.pump();
    repository.starting!.completeError(StateError('Denied'));
    await tester.pumpAndSettle();
    expect(find.text('Job 42 queued on the server.'), findsNothing);
    expect(tester.widget<FilledButton>(_runAll).onPressed, isNotNull);
    repository.starting = null;
    await tester.tap(_runAll);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('Job 42 queued on the server.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('remote picker fits narrow, enlarged localized layouts', (
    tester,
  ) async {
    await _pump(
      tester,
      _Repository(),
      scale: 1.5,
      size: const Size(360, 800),
      locale: const Locale('de'),
      brightness: Brightness.dark,
    );
    final launch = find.byType(OutlinedButton);
    await tester.ensureVisible(launch);
    await tester.tap(launch);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField),
      '/media/very long folder name/日本語',
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('short submitted jobs are looked up after leaving the queue', (
    tester,
  ) async {
    final repository = _Repository()
      ..finished = const LibraryJob(
        id: '42',
        status: 'FAILED',
        description: 'Generating content',
        error: 'Missing ffmpeg',
      );
    await _pump(
      tester,
      repository,
      child: Scaffold(
        body: LibraryJobQueue(repository: repository, queuedJobId: '42'),
      ),
    );
    expect(repository.lookups, 1);
    expect(find.text('Missing ffmpeg'), findsOneWidget);
    expect(find.text('Job failed'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    expect(repository.lookups, 1);
    expect(find.text('Missing ffmpeg'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('queue shows progress, subtasks and single/all cancellation', (
    tester,
  ) async {
    final repository = _Repository()
      ..queue = const [
        LibraryJob(
          id: '1',
          status: 'RUNNING',
          description: 'Scanning',
          progress: 0.5,
          subTasks: ['Reading /media'],
        ),
      ];
    await _pump(
      tester,
      repository,
      child: Scaffold(body: LibraryJobQueue(repository: repository)),
    );
    expect(find.text('50%'), findsOneWidget);
    expect(find.text('Reading /media'), findsOneWidget);
    await tester.tap(find.byTooltip('Stop job'));
    await tester.pumpAndSettle();
    expect(repository.stopped, ['1']);
    await tester.tap(find.text('Stop all server jobs'));
    await tester.pumpAndSettle();
    expect(repository.stopped, ['1', null]);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final task in LibraryTask.values) {
    for (final scale in [0.8, 1.5]) {
      testWidgets('$task Material layout at scale $scale on a narrow screen', (
        tester,
      ) async {
        await _pump(
          tester,
          _Repository(),
          task: task,
          scale: scale,
          size: const Size(360, 800),
          brightness: scale == 1.5 ? Brightness.dark : Brightness.light,
          locale: const Locale('de'),
        );
        expect(
          find.byType(SwitchListTile),
          findsNWidgets(
            task == LibraryTask.scan
                ? scanOptionKeys.length
                : generateOptionKeys.length,
          ),
        );
        await tester.ensureVisible(
          find.byKey(
            ValueKey(task == LibraryTask.scan ? 'rescan' : 'overwrite'),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }
}
