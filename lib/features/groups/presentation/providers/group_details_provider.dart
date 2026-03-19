import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/group.dart';
import 'group_list_provider.dart';

part 'group_details_provider.g.dart';

@riverpod
FutureOr<Group> groupDetails(Ref ref, String id) async {
  final repository = ref.watch(groupRepositoryProvider);
  return repository.getGroupById(id);
}
