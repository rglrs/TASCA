plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import java.io.FileInputStream

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.tascaid.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "29.0.13113456"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.tascaid.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = 4
        versionName = "1.0.3"
        ndk {
            debugSymbolLevel = "FULL"
        }
    }

signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"]?.toString() ?: throw IllegalArgumentException("Key alias is missing")
        keyPassword = keystoreProperties["keyPassword"]?.toString() ?: throw IllegalArgumentException("Key password is missing")
        storePassword = keystoreProperties["storePassword"]?.toString() ?: throw IllegalArgumentException("Keystore password is missing")
        storeFile = keystoreProperties["storeFile"]?.let { file(it) } ?: throw IllegalArgumentException("Keystore file is missing")
    }
}


    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }

}

flutter {
    source = "../.."
}
