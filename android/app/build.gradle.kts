import java.util.Properties
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
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

    defaultConfig {
        applicationId = "com.auronix.ando.app2026"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildFeatures {
        buildConfig = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    flavorDimensions += "env"

    productFlavors {
        create("dev") {
            dimension = "env"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "Ando Dev")

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

            buildConfigField(
                "String",
                "MAPBOX_ACCESS_TOKEN",
                "\"${getMapboxToken("MAPBOX_PUBLIC_TOKEN_PROD")}\""
            )
            resValue(
                "string",
                "mapbox_access_token",
                getMapboxToken("MAPBOX_PUBLIC_TOKEN_PROD")
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_11)
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}