allprojects {
    repositories {
        google()
        mavenCentral()

        // AGREGAR: Repositorio de Mapbox
        maven {
            url = uri("https://api.mapbox.com/downloads/v2/releases/maven")
            
            authentication {
                create<BasicAuthentication>("basic")
            }
            
            credentials {
                username = "mapbox"
                // Lee el token desde secrets.properties
                password = providers.gradleProperty("MAPBOX_DOWNLOADS_TOKEN").orNull
                    ?: project.findProperty("MAPBOX_DOWNLOADS_TOKEN") as String?
                    ?: System.getenv("MAPBOX_DOWNLOADS_TOKEN")
                    ?: ""
            }
        }
    
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
