import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/performer.dart';
import '../../domain/repositories/performer_repository.dart';

part 'performer_list_provider.g.dart';

// Provider for Repository interface (implemented by data layer later)
final performerRepositoryProvider = Provider<PerformerRepository>((ref) {
  throw UnimplementedError();
});

@riverpod
class PerformerList extends _$PerformerList {
  @override
  FutureOr<List<Performer>> build() async {
    final repository = ref.watch(performerRepositoryProvider);
    return repository.findPerformers();
  }
}
