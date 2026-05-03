plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.studysphere"

    compileSdk = 36

    ndkVersion = flutter.ndkVersion

    // ✅ Java 17 FIX
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    // ✅ Kotlin FIX
    kotlinOptions {
        jvmTarget = "17"
    }

    // ✅ IMPORTANT FIX (removes Java 8 warning completely)
    kotlin {
        jvmToolchain(17)
    }

    defaultConfig {
        applicationId = "com.example.studysphere"

        minSdk = flutter.minSdkVersion
        targetSdk = 36

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Required for modern Android + notifications
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}