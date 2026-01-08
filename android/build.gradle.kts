allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url = uri("$project.rootDir/../external/AusweisApp-SDK-Wrapper/android/ausweisapp")
        }
    }
}

extra.set("ausweisapp_version", "2.4.0")
extra.set("sdkwrapper_version", "2.4.0")

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

subprojects {
    if (project.name == "sdkwrapper") {
        afterEvaluate {
            tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
                compilerOptions {
                    allWarningsAsErrors.set(false)
                }
            }
            extensions.findByName("android")?.let { android ->
                if (android is com.android.build.gradle.BaseExtension) {
                    @Suppress("DEPRECATION")
                    android.lintOptions.isWarningsAsErrors = false
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
