plugins {
    id("com.android.application")
    id("kotlin-android") // ou algo similar que já esteja aí
    id("dev.flutter.flutter-gradle-plugin")
    // Adicione esta linha com aspas duplas e parênteses:
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.game_note_application"
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
    // ...
    applicationId "com.exemplo.game_note" // Verifique se está igual ao do Firebase
    minSdkVersion 23 // <--- MUDE PARA 21 OU 23 (O padrão costuma vir baixo)
    targetSdkVersion flutter.targetSdkVersion
    versionCode flutterVersionCode.toInteger()
    versionName flutterVersionName
}

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
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
  implementation(platform("com.google.firebase:firebase-bom:34.6.0"))


  // TODO: Add the dependencies for Firebase products you want to use
  // When using the BoM, don't specify versions in Firebase dependencies
  // https://firebase.google.com/docs/android/setup#available-libraries
}