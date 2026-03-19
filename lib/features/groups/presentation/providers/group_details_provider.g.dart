// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_details_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(groupDetails)
final groupDetailsProvider = GroupDetailsFamily._();

final class GroupDetailsProvider
    extends $FunctionalProvider<AsyncValue<Group>, Group, FutureOr<Group>>
    with $FutureModifier<Group>, $FutureProvider<Group> {
  GroupDetailsProvider._({
    required GroupDetailsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'groupDetailsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groupDetailsHash();

  @override
  String toString() {
    return r'groupDetailsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Group> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Group> create(Ref ref) {
    final argument = this.argument as String;
    return groupDetails(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupDetailsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupDetailsHash() => r'f139957b6b83a2aa6f42aeae8509c8b36fe0315e';

final class GroupDetailsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Group>, String> {
  GroupDetailsFamily._()
    : super(
        retry: null,
        name: r'groupDetailsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GroupDetailsProvider call(String id) =>
      GroupDetailsProvider._(argument: id, from: this);

  @override
  String toString() => r'groupDetailsProvider';
}
