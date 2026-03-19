// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery_details_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(galleryDetails)
final galleryDetailsProvider = GalleryDetailsFamily._();

final class GalleryDetailsProvider
    extends $FunctionalProvider<AsyncValue<Gallery>, Gallery, FutureOr<Gallery>>
    with $FutureModifier<Gallery>, $FutureProvider<Gallery> {
  GalleryDetailsProvider._({
    required GalleryDetailsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'galleryDetailsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$galleryDetailsHash();

  @override
  String toString() {
    return r'galleryDetailsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Gallery> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Gallery> create(Ref ref) {
    final argument = this.argument as String;
    return galleryDetails(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GalleryDetailsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$galleryDetailsHash() => r'8f6b94aaf3b9c7987111ea87c691451f0e60fb74';

final class GalleryDetailsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Gallery>, String> {
  GalleryDetailsFamily._()
    : super(
        retry: null,
        name: r'galleryDetailsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GalleryDetailsProvider call(String id) =>
      GalleryDetailsProvider._(argument: id, from: this);

  @override
  String toString() => r'galleryDetailsProvider';
}
