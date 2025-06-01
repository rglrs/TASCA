allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Menentukan direktori build yang baru
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    // Menentukan direktori build baru untuk subproject
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // Menentukan dependensi evaluasi untuk subproject
    project.evaluationDependsOn(":app")
}

// Mendaftarkan task clean untuk menghapus direktori build
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}