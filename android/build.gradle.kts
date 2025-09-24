import com.android.build.gradle.BaseExtension
buildscript {
    repositories {
        google()
        jcenter()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.2")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.8.0")
        classpath("com.android.tools.build:gradle:8.5.2") // or latest stable
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.24")
    }
}
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
configurations.all {
    resolutionStrategy {
        force("androidx.core:core-ktx:1.6.0")
        force("androidx.appcompat:appcompat:1.6.1")
        force("com.google.android.material:material:1.9.0")
    }
}
