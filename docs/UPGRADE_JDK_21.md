Upgrade notes: Java 21 (LTS)

This project uses Gradle and Android modules. Automated upgrade tools were not available in this environment, so I made safe, minimal manual changes to point the Android module at Java 21.

What I changed
- `android/app/build.gradle.kts`: updated `sourceCompatibility` and `targetCompatibility` to `JavaVersion.VERSION_21` and set Kotlin `jvmTarget = "21"`.

What you must do locally
1. Install JDK 21 on your machine. On Windows (PowerShell):

```powershell
# AdoptOpenJDK/Temurin via winget (Windows 10/11)
winget install -e --id EclipseTemurin.Temurin.21.JDK
# Or using manual installer from https://adoptium.net/
```

2. Point your JAVA_HOME to the JDK 21 install and ensure `java -version` reports 21.

```powershell
$env:JAVA_HOME = 'C:\\Program Files\\Eclipse Adoptium\\jdk-21'
java -version
```

3. Run Gradle build from project root (uses wrapper):

```powershell
cd android
..\\gradlew.bat clean assembleDebug
```

Notes and next steps
- `gradle-wrapper.properties` currently uses Gradle 8.12 which supports Java 21, so no change needed there.
- Kotlin plugin is `2.1.0` and AGP is `8.9.1`; both should be compatible with Java 21, but if you see issues consider upgrading AGP/Kotlin per Android docs.
- I could not run the automated GitHub Copilot upgrade tools (plan/setup/install) due to account limitations; I used manual edits instead.

If you want, I can: 
- revert or further change module files to use Java toolchains (recommended for reproducible builds),
- update Gradle plugin/Kotlin versions and test the build here,
- or produce a PR with these changes.
