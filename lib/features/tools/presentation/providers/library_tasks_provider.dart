import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/graphql/graphql_client.dart';
import '../../data/library_tasks_repository.dart';
import '../../domain/library_task.dart';

final libraryTasksRepositoryProvider =
    Provider.autoDispose<LibraryTasksRepository>(
      (ref) => LibraryTasksRepository(ref.watch(graphqlClientProvider)),
    );

final libraryTaskSettingsProvider =
    FutureProvider.autoDispose<LibraryTaskSettings>(
      (ref) => ref.watch(libraryTasksRepositoryProvider).loadSettings(),
    );
