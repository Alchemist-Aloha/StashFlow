import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:gql/ast.dart';
import 'package:stash_app_flutter/core/data/graphql/graphql_exception.dart';
import 'package:stash_app_flutter/features/tools/data/library_tasks_repository.dart';
import 'package:stash_app_flutter/features/tools/domain/library_task.dart';

Map<String, dynamic> configuration() => {
  'general': {
    'stashes': [
      {'path': '/media', '__typename': 'StashConfig'},
    ],
    'previewSegments': 12,
    'previewSegmentDuration': 0.75,
    'previewExcludeStart': '0',
    'previewExcludeEnd': '2%',
    'previewPreset': 'slow',
    '__typename': 'ConfigGeneralResult',
  },
  'defaults': <String, dynamic>{
    'scan': null,
    'generate': null,
    '__typename': 'ConfigDefaultSettingsResult',
  },
  'ui': {
    'theme': 'dark',
    'taskDefaults': {
      'scan': {'scanGenerateCovers': false, 'rescan': true},
      'generate': {
        'covers': true,
        'previews': true,
        'imagePhashes': true,
        'overwrite': true,
        'sceneIDs': ['must-not-limit-library'],
        'previewOptions': {
          'previewSegments': 0,
          'previewSegmentDuration': 0,
          'previewPreset': 'fast',
        },
      },
    },
  },
  '__typename': 'ConfigResult',
};

void main() {
  late LibraryTasksRepository repository;
  late GraphQLClient client;
  late List<Request> requests;
  late Map<String, dynamic> config;
  late bool reject;
  late Map<String, dynamic> defaults;
  late Map<String, dynamic> ui;
  late Map<String, dynamic> tasks;

  setUp(() {
    requests = [];
    config = configuration();
    defaults = config['defaults'] as Map<String, dynamic>;
    ui = config['ui'] as Map<String, dynamic>;
    tasks = ui['taskDefaults'] as Map<String, dynamic>;
    reject = false;
    client = GraphQLClient(
      cache: GraphQLCache(),
      link: Link.function((request, [forward]) async* {
        requests.add(request);
        if (reject) {
          yield Response(
            response: const {},
            errors: const [GraphQLError(message: 'Denied')],
          );
          return;
        }
        final operation = request.operation.document.definitions
            .whereType<OperationDefinitionNode>()
            .single
            .name!
            .value;
        final data = switch (operation) {
          'LibraryTaskConfiguration' => {'configuration': config},
          'SaveLibraryTaskOptions' => {'configureUI': config['ui']},
          'StartLibraryScan' => {'metadataScan': '41'},
          'StartLibraryGenerate' => {'metadataGenerate': '42'},
          'LibraryTaskDirectory' => {
            'directory': {
              'path': request.variables['path'],
              'parent': '/media',
              'directories': ['/media/日本語'],
              '__typename': 'Directory',
            },
          },
          'LibraryTaskJobs' => {'jobQueue': null},
          'FindLibraryTaskJob' => {
            'findJob': {
              'id': request.variables['id'],
              'status': 'FAILED',
              'description': 'Generating',
              'progress': 0.5,
              'subTasks': ['Preview'],
              'error': 'Missing ffmpeg',
              'startTime': '2026-01-01T00:00:00Z',
              '__typename': 'Job',
            },
          },
          'StopLibraryJob' => {'stopJob': true},
          'StopAllLibraryJobs' => {'stopAllJobs': true},
          _ => throw StateError(
            'Unexpected operation ${request.operation.operationName}',
          ),
        };
        yield Response(
          response: const {},
          data: {
            ...data,
            '__typename':
                operation.startsWith('Start') ||
                    operation.startsWith('Stop') ||
                    operation == 'SaveLibraryTaskOptions'
                ? 'Mutation'
                : 'Query',
          },
        );
      }),
    );
    repository = LibraryTasksRepository(client);
  });

  tearDown(() => client.link.dispose());

  test('UI options win over legacy defaults, including explicit false', () {
    defaults['scan'] = {'scanGenerateCovers': true};
    final settings = LibraryTaskSettings.fromJson(config);
    expect(settings.scan['scanGenerateCovers'], isFalse);
    expect(settings.scan['rescan'], isTrue);
    expect(settings.scan['scanGeneratePreviews'], isFalse);
    expect(settings.generate['overwrite'], isTrue);
    expect(settings.generate['imagePhashes'], isTrue);
    expect(settings.generate.keys, unorderedEquals(generateOptionKeys));
    expect(settings.libraryPaths, ['/media']);
  });

  test('legacy defaults and official fallbacks are respected', () {
    config['ui'] = <String, dynamic>{};
    defaults['scan'] = {'rescan': true};
    var settings = LibraryTaskSettings.fromJson(config);
    expect(settings.scan['rescan'], isTrue);
    expect(settings.scan['scanGenerateCovers'], isFalse);
    defaults['scan'] = null;
    settings = LibraryTaskSettings.fromJson(config);
    expect(settings.scan.entries.where((e) => e.value).map((e) => e.key), [
      'scanGenerateCovers',
    ]);
    expect(
      settings.generate.entries.where((e) => e.value).map((e) => e.key),
      unorderedEquals(['covers', 'sprites', 'phashes', 'previews', 'markers']),
    );
  });

  test(
    'configuration bypasses cache and partial saves touch only this task',
    () async {
      final settings = await repository.loadSettings();
      (tasks['scan'] as Map<String, dynamic>)['rescan'] = false;
      expect((await repository.loadSettings()).scan['rescan'], isFalse);
      await repository.saveOptions(LibraryTask.scan, settings.scan);
      expect(requests.last.variables, {
        'partial': {
          'taskDefaults': {'scan': settings.scan},
        },
      });
      expect(ui['theme'], 'dark');
      expect(
        (tasks['generate'] as Map<String, dynamic>)['imagePhashes'],
        isTrue,
      );
    },
  );

  test(
    'all-library scan omits paths; selective scan preserves server paths',
    () async {
      final options = LibraryTaskSettings.fromJson(config).scan;
      expect(await repository.start(LibraryTask.scan, options), '41');
      expect(requests.last.variables['input'], options);
      await repository.start(
        LibraryTask.scan,
        options,
        paths: [r'C:\Media\日本語', '/media/a b', '/media/a b'],
      );
      expect(
        (requests.last.variables['input'] as Map<String, dynamic>)['paths'],
        [r'C:\Media\日本語', '/media/a b'],
      );
    },
  );

  test(
    'empty selections cannot silently run across the entire library',
    () async {
      for (final paths in <List<String>>[
        [],
        ['   '],
      ]) {
        await expectLater(
          repository.start(LibraryTask.scan, {}, paths: paths),
          throwsArgumentError,
        );
      }
      expect(requests, isEmpty);
    },
  );

  test('generation reads fresh general preview values and strips input-only scopes', () async {
    final settings = await repository.loadSettings();
    (config['general'] as Map<String, dynamic>)['previewSegments'] = 24;
    expect(
      await repository.start(
        LibraryTask.generate,
        settings.generate,
        paths: ['/media'],
      ),
      '42',
    );
    final input = requests.last.variables['input'] as Map<String, dynamic>;
    expect(input['paths'], ['/media']);
    expect(input['overwrite'], isTrue);
    expect(input['imagePhashes'], isTrue);
    expect(input.containsKey('sceneIDs'), isFalse);
    expect(input['previewOptions'], {
      'previewSegments': 24,
      'previewSegmentDuration': 0.75,
      'previewExcludeStart': '0',
      'previewExcludeEnd': '2%',
      'previewPreset': 'slow',
    });
    expect(input.toString(), isNot(contains('__typename')));
    await repository.start(LibraryTask.generate, settings.generate);
    expect(
      (requests.last.variables['input'] as Map<String, dynamic>).containsKey(
        'paths',
      ),
      isFalse,
    );
  });

  test(
    'directory, null queue, completed job lookup and cancellation',
    () async {
      final directory = await repository.directory('/media/日本語');
      expect(directory.path, '/media/日本語');
      expect(directory.parent, '/media');
      expect(directory.children, ['/media/日本語']);
      expect(await repository.jobs(), isEmpty);
      final job = (await repository.findJob('42'))!;
      expect(job.status, 'FAILED');
      expect(job.error, 'Missing ffmpeg');
      expect(job.canStop, isFalse);
      expect(job.startTime, DateTime.utc(2026));
      await repository.stopJob('42');
      expect(requests.last.variables, {'id': '42'});
      await repository.stopAllJobs();
      expect(
        requests.last.operation.document.definitions
            .whereType<OperationDefinitionNode>()
            .single
            .name!
            .value,
        'StopAllLibraryJobs',
      );
    },
  );

  test(
    'GraphQL failures do not look like successful saves or submissions',
    () async {
      reject = true;
      await expectLater(
        repository.loadSettings(),
        throwsA(isA<AppGraphQLException>()),
      );
      await expectLater(
        repository.saveOptions(LibraryTask.scan, {}),
        throwsA(isA<AppGraphQLException>()),
      );
      await expectLater(
        repository.start(LibraryTask.scan, {}),
        throwsA(isA<AppGraphQLException>()),
      );
      await expectLater(
        repository.start(LibraryTask.generate, {}),
        throwsA(isA<AppGraphQLException>()),
      );
      await expectLater(
        repository.directory('/media'),
        throwsA(isA<AppGraphQLException>()),
      );
      await expectLater(repository.jobs(), throwsA(isA<AppGraphQLException>()));
      await expectLater(
        repository.stopJob('42'),
        throwsA(isA<AppGraphQLException>()),
      );
      await expectLater(
        repository.stopAllJobs(),
        throwsA(isA<AppGraphQLException>()),
      );
    },
  );

  const endpoint = String.fromEnvironment('STASH_TEST_ENDPOINT');
  test(
    'live endpoint reads configuration, directory and queue without mutations',
    () async {
      final liveClient = GraphQLClient(
        cache: GraphQLCache(),
        link: HttpLink(endpoint),
      );
      addTearDown(liveClient.link.dispose);
      final live = LibraryTasksRepository(liveClient);
      final settings = await live.loadSettings();
      expect(settings.scan.keys, unorderedEquals(scanOptionKeys));
      expect(settings.generate.keys, unorderedEquals(generateOptionKeys));
      if (settings.libraryPaths.isNotEmpty) {
        final path = settings.libraryPaths.first;
        expect((await live.directory(path)).path, path);
      }
      await live.jobs();
    },
    skip: endpoint.isEmpty,
  );
}
