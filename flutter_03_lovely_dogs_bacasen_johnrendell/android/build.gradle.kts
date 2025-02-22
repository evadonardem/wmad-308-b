allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("build").get() // Adjusted from ../../build
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    if (project.name != "app") {
        try {
            project.evaluationDependsOn(":app")
        } catch (e: Exception) {
            println("Warning: Could not evaluate :app for ${project.name}: ${e.message}")
        }
    }
}

tasks.register<Delete>("clean") {
    delete(newBuildDir.asFile)
}