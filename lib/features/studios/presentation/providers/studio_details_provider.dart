import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/studio.dart';
import 'studio_list_provider.dart';

part 'studio_details_provider.g.dart';

@riverpod
FutureOr<Studio> studioDetails(Ref ref, String id) async {
  ref.keepAlive();
  final repository = ref.read(studioRepositoryProvider);
  return repository.getStudioById(id);
}
