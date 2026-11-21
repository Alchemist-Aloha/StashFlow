# StashFlow patch of avif_native 0.2.0

Copied from pub.dev `avif_native` 0.2.0 (MIT) and used through
`dependency_overrides` in the app `pubspec.yaml`.

Only change: `hook/build.dart` emits no code asset for targets without a
prebuilt libavif (Windows ARM64 at 0.2.0) instead of throwing, so those builds
succeed and AVIF decoding fails at runtime there. Native sources, tools, and
tests from the upstream package are omitted.

Drop this copy once upstream ships every target StashFlow builds.
