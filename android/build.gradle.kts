allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}
subprojects {
    plugins.withType<com.android.build.gradle.AppPlugin> {
        val android = project.extensions.getByName("android") as com.android.build.gradle.BaseExtension
        android.ndkVersion = "28.2.13676358"
    }
    plugins.withType<com.android.build.gradle.LibraryPlugin> {
        val android = project.extensions.getByName("android") as com.android.build.gradle.BaseExtension
        android.ndkVersion = "28.2.13676358"
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
