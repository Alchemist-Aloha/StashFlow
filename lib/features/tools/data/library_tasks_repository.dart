import 'package:graphql/client.dart';

import '../../../core/data/graphql/graphql_exception.dart';
import '../../../core/data/graphql/schema.graphql.dart';
import '../domain/library_task.dart';
import 'graphql/library_tasks.graphql.dart';

/// Profile-bound access to library task configuration and the server job queue.
class LibraryTasksRepository {
  LibraryTasksRepository(this._client);
  final GraphQLClient _client;

  Future<LibraryTaskSettings> loadSettings() async {
    final result = await _client.query$LibraryTaskConfiguration(
      Options$Query$LibraryTaskConfiguration(fetchPolicy: FetchPolicy.noCache),
    );
    validateGraphQLResult(result);
    return LibraryTaskSettings.fromJson(
      result.parsedData!.configuration.toJson(),
    );
  }

  /// Patch only this task branch; other tasks and unrelated UI settings survive.
  Future<void> saveOptions(LibraryTask task, Map<String, bool> options) async {
    final result = await _client.mutate$SaveLibraryTaskOptions(
      Options$Mutation$SaveLibraryTaskOptions(
        variables: Variables$Mutation$SaveLibraryTaskOptions(
          partial: {
            'taskDefaults': {task.name: options},
          },
        ),
      ),
    );
    validateGraphQLResult(result);
  }

  Future<String> start(
    LibraryTask task,
    Map<String, bool> options, {
    List<String>? paths,
  }) async {
    if (paths != null &&
        (paths.isEmpty || paths.any((p) => p.trim().isEmpty))) {
      throw ArgumentError.value(
        paths,
        'paths',
        'Select at least one directory',
      );
    }
    final keys = task == LibraryTask.scan ? scanOptionKeys : generateOptionKeys;
    final input = <String, dynamic>{
      for (final key in keys) key: options[key] == true,
      if (paths != null) 'paths': paths.toSet().toList(),
    };
    if (task == LibraryTask.scan) {
      final result = await _client.mutate$StartLibraryScan(
        Options$Mutation$StartLibraryScan(
          variables: Variables$Mutation$StartLibraryScan(
            input: Input$ScanMetadataInput.fromJson(input),
          ),
        ),
      );
      validateGraphQLResult(result);
      return result.parsedData!.metadataScan;
    }
    // Preview settings can change in the web app while this page is open.
    final settings = await loadSettings();
    input['previewOptions'] = settings.previewOptions;
    final result = await _client.mutate$StartLibraryGenerate(
      Options$Mutation$StartLibraryGenerate(
        variables: Variables$Mutation$StartLibraryGenerate(
          input: Input$GenerateMetadataInput.fromJson(input),
        ),
      ),
    );
    validateGraphQLResult(result);
    return result.parsedData!.metadataGenerate;
  }

  Future<ServerDirectory> directory(String path) async {
    final result = await _client.query$LibraryTaskDirectory(
      Options$Query$LibraryTaskDirectory(
        fetchPolicy: FetchPolicy.noCache,
        variables: Variables$Query$LibraryTaskDirectory(path: path),
      ),
    );
    validateGraphQLResult(result);
    final directory = result.parsedData!.directory;
    return ServerDirectory(
      path: directory.path,
      parent: directory.parent,
      children: directory.directories,
    );
  }

  Future<List<LibraryJob>> jobs() async {
    final result = await _client.query$LibraryTaskJobs(
      Options$Query$LibraryTaskJobs(fetchPolicy: FetchPolicy.noCache),
    );
    validateGraphQLResult(result);
    return [
      for (final job
          in result.parsedData!.jobQueue ?? <Fragment$LibraryTaskJob>[])
        _job(job),
    ];
  }

  Future<LibraryJob?> findJob(String id) async {
    final result = await _client.query$FindLibraryTaskJob(
      Options$Query$FindLibraryTaskJob(
        fetchPolicy: FetchPolicy.noCache,
        variables: Variables$Query$FindLibraryTaskJob(id: id),
      ),
    );
    validateGraphQLResult(result);
    final job = result.parsedData!.findJob;
    return job == null ? null : _job(job);
  }

  LibraryJob _job(Fragment$LibraryTaskJob job) => LibraryJob(
    id: job.id,
    status: job.status.name,
    description: job.description,
    progress: job.progress,
    subTasks: job.subTasks ?? [],
    error: job.error,
    startTime: DateTime.tryParse(job.startTime ?? ''),
  );

  Future<void> stopJob(String id) async {
    final result = await _client.mutate$StopLibraryJob(
      Options$Mutation$StopLibraryJob(
        variables: Variables$Mutation$StopLibraryJob(id: id),
      ),
    );
    validateGraphQLResult(result);
    if (result.parsedData!.stopJob != true) throw StateError('Job not stopped');
  }

  Future<void> stopAllJobs() async {
    final result = await _client.mutate$StopAllLibraryJobs(
      Options$Mutation$StopAllLibraryJobs(),
    );
    validateGraphQLResult(result);
    if (result.parsedData!.stopAllJobs != true) {
      throw StateError('Jobs not stopped');
    }
  }
}
