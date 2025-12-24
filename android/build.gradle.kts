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
    val project = this
    val fixAction = {
         val android = project.extensions.findByName("android")
         if (android != null) {
            try {
                val namespaceMethod = android::class.java.getMethod("getNamespace")
                val namespace = namespaceMethod.invoke(android)
                if (namespace == null) {
                     val setNamespaceMethod = android::class.java.getMethod("setNamespace", String::class.java)
                     setNamespaceMethod.invoke(android, project.group.toString())
                }
            } catch (e: Exception) {
                // Ignore if method not found
            }
         }
    }
    
    if (project.state.executed) {
        fixAction()
    } else {
        project.afterEvaluate {
            fixAction()
        }
    }
}
