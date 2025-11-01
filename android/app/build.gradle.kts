import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localProperties.load(localPropertiesFile.inputStream())
}

val flutterVersionCode = localProperties.getProperty("flutter.versionCode") ?: "1"
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0"

android {
    namespace = "com.example.mindmirrorapp"
    compileSdk = 35 // Usamos 35 como en tu intento anterior
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Habilita desugaring (para notificaciones)
        isCoreLibraryDesugaringEnabled = true 
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    defaultConfig {
        applicationId = "com.example.mindmirrorapp"
        minSdk = flutter.minSdkVersion // Requerido por flutter_local_notifications
        targetSdk = 35
        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Librería para desugaring (para notificaciones)
    // ACTUALIZADO: Cambiado de 2.0.4 a 2.1.4 (o más nuevo, 2.2.0 es seguro)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.2.0")
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
}

