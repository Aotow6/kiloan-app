allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
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

subprojects {

    if (!project.state.executed) {
        project.afterEvaluate {
            val android = extensions.findByName("android")
            if (android != null) {
                try {
                    val namespaceProp = android.javaClass.getMethod("getNamespace").invoke(android)
                    if (namespaceProp == null) {
                        android.javaClass.getMethod("setNamespace", String::class.java).invoke(android, project.group.toString())
                    }
                } catch (e: Exception) {

                }
            }
        }
    }
}