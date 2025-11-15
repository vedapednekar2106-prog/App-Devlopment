plugins {
    id("com.android.application")
    id("kotlin-android")

    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")

    // ✅ FlutterFire Configuration (Google Services)
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.wanderlist_app"
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
        applicationId = "com.example.wanderlist_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // ✅ Enable MultiDex (required by Firebase)
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // ✅ Use debug keys for now
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // ✅ Helps avoid dependency conflicts with Firebase
    packagingOptions {
        exclude("META-INF/DEPENDENCIES")
        exclude("META-INF/LICENSE")
        exclude("META-INF/LICENSE.txt")
        exclude("META-INF/license.txt")
        exclude("META-INF/NOTICE")
        exclude("META-INF/NOTICE.txt")
        exclude("META-INF/notice.txt")
        exclude("META-INF/AL2.0")
        exclude("META-INF/LGPL2.1")
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ✅ MultiDex support for Firebase
    implementation("androidx.multidex:multidex:2.0.1")
}
