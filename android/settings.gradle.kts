pluginManagement {
    val flutterSdkPath = file("local.properties")
        .readLines()
        .firstOrNull { it.trim().startsWith("flutter.sdk=") }
        ?.substringAfter("=")
        ?.trim()

    require(!flutterSdkPath.isNullOrBlank()) {
        "flutter.sdk not set in local.properties"
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.9.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

include(":app")
