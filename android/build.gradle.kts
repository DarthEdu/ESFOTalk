allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Removed custom build directory logic to use Gradle's default build directory
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
