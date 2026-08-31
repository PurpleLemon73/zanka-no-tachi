import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseSigningPropertiesFile = rootProject.file("key.properties")
val releaseSigningProperties = Properties()
if (releaseSigningPropertiesFile.isFile) {
    releaseSigningPropertiesFile.inputStream().use(releaseSigningProperties::load)
}

fun requiredSigningProperty(name: String): String =
    requireNotNull(releaseSigningProperties.getProperty(name)?.takeIf(String::isNotBlank)) {
        "Missing required release-signing property '$name' in android/key.properties"
    }

android {
    namespace = "dev.zanka.notachi"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "dev.zanka.notachi"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (releaseSigningPropertiesFile.isFile) {
            create("release") {
                keyAlias = requiredSigningProperty("keyAlias")
                keyPassword = requiredSigningProperty("keyPassword")
                storePassword = requiredSigningProperty("storePassword")
                storeFile = rootProject.file(requiredSigningProperty("storeFile"))
                require(storeFile?.isFile == true) {
                    "Configured release keystore does not exist"
                }
            }
        }
    }

    buildTypes {
        debug {
            // Keep local/debug probes installable beside the permanent public
            // signing identity without replacing production user data.
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-debug"
        }
        release {
            // Never fall back to the debug identity. Public release tooling
            // additionally verifies the certificate fingerprint after build.
            signingConfig = signingConfigs.findByName("release")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
