# Keep source file and line number metadata for crash symbolication.
-keepattributes SourceFile,LineNumberTable

# Keep Kotlin metadata annotations used by reflection in some dependencies.
-keep class kotlin.Metadata { *; }

# Keep classes implementing Flutter plugins.
-keep class io.flutter.plugins.** { *; }

# Keep MediaSession/AudioService-related classes commonly loaded by name.
-keep class com.ryanheise.audioservice.** { *; }
