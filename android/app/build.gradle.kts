import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
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
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
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
        release {
            // Never fall back to the debug identity. Public release tooling
            // additionally verifies the certificate fingerprint after build.
            signingConfig = signingConfigs.findByName("release")
        }
    }
}

flutter {
    source = "../.."
}
