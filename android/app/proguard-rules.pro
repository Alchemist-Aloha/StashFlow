# Keep source file and line number metadata for crash symbolication.
-keepattributes SourceFile,LineNumberTable

# Keep Kotlin metadata annotations used by reflection in some dependencies.
-keep class kotlin.Metadata { *; }

# Dart JNI resolves Kotlin coroutine/result types by literal JVM names and signatures.
-keep interface kotlin.coroutines.Continuation { *; }
-keep class kotlin.coroutines.intrinsics.CoroutineSingletons { *; }
-keep class kotlin.coroutines.intrinsics.IntrinsicsKt { *; }
-keep class kotlin.coroutines.intrinsics.IntrinsicsKt__IntrinsicsKt { *; }
-keep class kotlin.Result { *; }
-keep class kotlin.Result$Failure { *; }
-keep class kotlin.Unit { *; }
