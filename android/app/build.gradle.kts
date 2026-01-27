import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Plugin para el auth de Google Flutter Fire
    id("com.google.gms.google-services")
}

// Cargar secrets si no se cargaron en settings
val secretsPropertiesFile = rootProject.file("secrets.properties")
val secretsProperties = Properties()

if (secretsPropertiesFile.exists()) {
    secretsPropertiesFile.inputStream().use { stream ->
        secretsProperties.load(stream)
    }
}

fun getMapboxToken(key: String): String {
    return secretsProperties.getProperty(key)
        ?: rootProject.ext.get(key) as? String
        ?: System.getenv(key)
        ?: ""
}

android {
    namespace = "com.auronix.ando.app2026"
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
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.auronix.ando.app2026"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        multiDexEnabled = true //IMPORTANTE PARA MAPBOX
    }

    // IMPORTANTE: Habilitar BuildConfig para acceder a los tokens
    buildFeatures {
        buildConfig = true
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // Flavors environments
    flavorDimensions += "env"
    productFlavors {
        create("dev") {
            dimension = "env"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "Ando Dev")
            
            //Token de Mapbox para DESARROLLO
            buildConfigField(
                "String",
                "MAPBOX_ACCESS_TOKEN",
                "\"${getMapboxToken("MAPBOX_PUBLIC_TOKEN_DEV")}\""
            )
            resValue(
                "string",
                "mapbox_access_token",
                getMapboxToken("MAPBOX_PUBLIC_TOKEN_DEV")
            )
        }
        create("prod") {
            dimension = "env"
            resValue("string", "app_name", "Ando")
            // Token de Mapbox para PRODUCCIÓN
            buildConfigField(
                "String",
                "MAPBOX_ACCESS_TOKEN",
                "\"${getMapboxToken("MAPBOX_PUBLIC_TOKEN_PROD")}\""
            )
            
            // También como resource string (para AndroidManifest)
            resValue(
                "string",
                "mapbox_access_token",
                getMapboxToken("MAPBOX_PUBLIC_TOKEN_PROD")
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // MultiDex support
    implementation("androidx.multidex:multidex:2.0.1")
}
