plugins {
    // Android Gradle Plugin Version 8.11.1
    id("com.android.application") version "8.11.1" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Saubere Build-Ordner-Struktur (File statt String)
rootProject.buildDir = file("../build")
subprojects {
    project.buildDir = file("${rootProject.buildDir}/${project.name}")
    project.evaluationDependsOn(":app")
}

// Clean-Task
tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}