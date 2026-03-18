// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performer_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PerformerList)
final performerListProvider = PerformerListProvider._();

final class PerformerListProvider
    extends $AsyncNotifierProvider<PerformerList, List<Performer>> {
  PerformerListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'performerListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$performerListHash();

  @$internal
  @override
  PerformerList create() => PerformerList();
}

String _$performerListHash() => r'0da630edce23add0469232e680ac7a1835fb56bd';

abstract class _$PerformerList extends $AsyncNotifier<List<Performer>> {
  FutureOr<List<Performer>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Performer>>, List<Performer>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Performer>>, List<Performer>>,
              AsyncValue<List<Performer>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
