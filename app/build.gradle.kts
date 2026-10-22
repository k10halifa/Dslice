import java.util.Properties

plugins {
    id("com.android.application")
}

val signingProps = Properties()
val signingPropsFile = rootProject.file("signing.properties")
if (signingPropsFile.exists()) signingProps.load(signingPropsFile.inputStream())
val releaseSigningConfigured = listOf(
    "KEYSTORE_FILE",
    "KEYSTORE_PASSWORD",
    "KEY_ALIAS",
    "KEY_PASSWORD",
).all { !signingProps.getProperty(it).isNullOrBlank() }

android {
    namespace = "df.D10slice"
    compileSdk = 37

    buildFeatures {
        buildConfig = true
    }

    defaultConfig {
        applicationId = "df.D10slice"
        minSdk = 32
        targetSdk = 37
        versionCode = 62
        versionName = "6.2"

        ndk {
            abiFilters += listOf("arm64-v8a")
        }
    }

    
        }
    }

    buildTypes {
        debug {
            isDebuggable = true
            
        }
        release {
            if (releaseSigningConfigured) {
                
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    lint {
        checkReleaseBuilds = false
    }

    externalNativeBuild {
        cmake {
            path("src/main/jni/CMakeLists.txt")
        }
    }

    packaging {
        jniLibs {
            useLegacyPackaging = true
        }
    }
}

androidComponents {
    onVariants { variant ->
        variant.outputs.forEach { output ->
            output.outputFileName.set(output.versionName.map { vn -> "Dslice_${vn}.apk" })
        }
    }
}

dependencies {
    implementation(libs.material)
}
