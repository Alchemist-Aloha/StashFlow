import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/tag.dart';
import 'tag_list_provider.dart';

part 'tag_details_provider.g.dart';

@riverpod
FutureOr<Tag> tagDetails(Ref ref, String id) async {
  ref.keepAlive();
  final repository = ref.read(tagRepositoryProvider);
  return repository.getTagById(id);
}
