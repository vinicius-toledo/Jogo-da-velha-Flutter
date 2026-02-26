plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.viniciustoledo.jogodavelha"
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
        // ID Oficial do seu jogo na Google Play
        applicationId = "com.viniciustoledo.jogodavelha"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // A SUA CHAVE DE SEGURANÇA AQUI
    signingConfigs {
        create("release") {
            storeFile = file("keystore.jks")
            storePassword = "677264ebb7b4c2c2fd38c4ee15725783"
            keyAlias = "4c5dbf14c43d9da1dd0eb49727158770"
            keyPassword = "eb26091f8bb6c49d329732ed9576925b"
        }
    }

    buildTypes {
        release {
            // Diz para o Flutter usar a chave "release" criada acima
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}