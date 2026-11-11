import org.jetbrains.kotlin.gradle.dsl.JvmTarget

group = "dev.flutter_device_ai"
version = "0.1.1"

buildscript {
    val kotlinVersion = "2.2.20"
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.11.1")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

plugins {
    id("com.android.library")
    id("kotlin-android")
}

android {
    namespace = "dev.flutter_device_ai"

    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
    }

    defaultConfig {
        // ML Kit GenAI requires API 26.
        minSdk = 26
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}

dependencies {
    // Match Gemini Nano Playground: beta3/4 request AICore features many devices lack.
    // See googlesamples/mlkit#1061 (feature 648 vs shipping 636).
    implementation("com.google.mlkit:genai-prompt:1.0.0-beta2")
    implementation("com.google.mlkit:common:18.11.0")
    // Keep coroutines artifacts on one line; genai-prompt pulls an older guava bridge.
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.11.0")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-guava:1.11.0")
}
