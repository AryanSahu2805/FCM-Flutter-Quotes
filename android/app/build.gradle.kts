plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Add the Google services Gradle plugin
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.firebase_messaging_app"
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
        applicationId = "com.example.firebase_messaging_app"
        // Set minSdk to at least 21 for Firebase Messaging
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion  // Fixed: Changed from targetSdk to targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    
    buildTypes {
        release {
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:34.5.0"))
    
    // Firebase Analytics (optional but recommended)
    implementation("com.google.firebase:firebase-analytics")
    
    // Firebase Messaging
    implementation("com.google.firebase:firebase-messaging")
    
    // Note: When using the BoM, don't specify versions in Firebase dependencies
}
