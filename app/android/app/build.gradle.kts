import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // google-services.json を Android リソースへ展開する。
    id("com.google.gms.google-services")
}

// release 署名は app/android/key.properties と、そこが指す keystore を使う。
// どちらも Git には置かない。配置手順は docs/constraints.md の App Distribution。
// Android プラグイン適用後は java が影付きになるため、FQCN ではなく import した Properties を使う。
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.reader(Charsets.UTF_8).use { reader ->
        keystoreProperties.load(reader)
    }
}

android {
    namespace = "io.github.madahataraku.coglog"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // flutter_local_notifications が要求する java.time 互換のため有効化する。
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // applicationId は productFlavors で上書きする。ここは production と同じ値を置く。
        applicationId = "io.github.madahataraku.coglog"
        // minSdk は docs/constraints.md の Android 節に従い 34 以上。
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 34
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // アプリ ID はフレーバーだけで切り替える。buildTypes では変えない。
    flavorDimensions += "app"
    productFlavors {
        create("development") {
            dimension = "app"
            applicationId = "io.github.madahataraku.coglog.debug"
        }
        create("production") {
            dimension = "app"
            applicationId = "io.github.madahataraku.coglog"
        }
    }

    if (keystorePropertiesFile.exists()) {
        signingConfigs {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storePassword = keystoreProperties.getProperty("storePassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
            }
        }
    }

    buildTypes {
        release {
            // debug 署名は実行ごとに鍵が変わるため、配布済み APK を上書き更新できない。
            if (keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("release")
            }
            // Flutter / AGP が minify を有効にしても GenAI getClient が壊れないようにする。
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

gradle.taskGraph.whenReady {
    val releaseRequested = allTasks.any { task -> task.name.contains("Release") }
    if (releaseRequested && !keystorePropertiesFile.exists()) {
        throw GradleException(
            "release 署名には app/android/key.properties が必要です。docs/constraints.md の App Distribution を参照してください。",
        )
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    // google_mlkit_text_recognition の日本語モデルは compileOnly のため実行時依存を足す。
    implementation("com.google.mlkit:text-recognition-japanese:16.0.1")
}

flutter {
    source = "../.."
}
