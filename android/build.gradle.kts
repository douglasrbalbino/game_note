allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// O bloco "rootProject.buildDir" também mudou recentemente, 
// mas se o seu arquivo já tiver um código de limpeza padrão, pode mantê-lo.
// O importante é remover o "buildscript" com "ext.kotlin_version" que causa o erro.
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