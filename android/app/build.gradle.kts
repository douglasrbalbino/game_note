plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
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
        // CORREÇÃO: O ID deve ser igual ao do google-services.json
        applicationId = "com.example.game_note_application" 
        
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // ADICIONE ISSO: Ajuda a prevenir erros de "app fechando" em projetos com Firebase
        multiDexEnabled = true 
    }

    buildTypes {
        release {
            // Assina com a chave de debug para facilitar testes
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Importa a plataforma do Firebase (BoM)
    implementation(platform("com.google.firebase:firebase-bom:34.6.0"))
    
    // Adicione outras dependências do Firebase aqui se precisar, ex:
    // implementation("com.google.firebase:firebase-analytics")
}
