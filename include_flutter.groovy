// Generated file. Do not edit.
// by flutter boot

// 线上构建
DEV_LINE = System.getenv("DEV_LINE") as String ?: "unknown"

mFlutterProjectRoot = "${gradle.settingsDir}" + '/girgir_flutter_module'

if (!isLocalBuild()) {
    // 线上构建，直接拉子工程代码，build aar, add aar to im's libs
    println "[INFO]: is not localBuild, need to run flutter build aar"
    gradle.getGradle().ext.isDetectedFlutterDir = false

    String shFilePath = "${gradle.settingsDir}" + "/pre_ci_build.sh"
    println "[INFO]: shFilePath is: $shFilePath"

    def proc = shFilePath.execute()
    def b = new StringBuffer()
    proc.consumeProcessErrorStream(b)
    println "[INFO]: success message is: " + proc.text
    println "[INFO]: error message is: " + b.toString()
} else {
    if (isUseFlutterDevelop()) {
        if (isWindows()) {
            //调用bat
            println "[INFO]: isDetectedFlutterDir use Windows: $mFlutterProjectRoot"
            useBatFlutterPubGet(mFlutterProjectRoot)
        } else {
            //调用sh
            println "[INFO]: isDetectedFlutterDir use macOS: $mFlutterProjectRoot"
            useShellFlutterPubGet(mFlutterProjectRoot)
        }
    
        println "[INFO]: process /android_flutter_get.sh run success"
        evaluate(new File(mFlutterProjectRoot, '.android/include_flutter.groovy'))
    }
}

static def isWindows() {
    return org.gradle.internal.os.OperatingSystem.current().isWindows()
}

def useShellFlutterPubGet(String flutterProjectRoot) {
    String shFilePath = "${flutterProjectRoot}" + "/android_flutter_get.sh"
    println "[INFO]: shFilePath is: $shFilePath"
    def process = shFilePath.execute()
    def outputStream = new StringBuffer()
    process.waitForProcessOutput(outputStream, System.err)
}

def useBatFlutterPubGet(String flutterProjectRoot) {
    def batchFile = "${flutterProjectRoot}" + "/android_flutter_get.bat"
    println "[INFO]: $batchFile"
    def process = batchFile.execute()
    def outputStream = new StringBuffer()
    process.waitForProcessOutput(outputStream, System.err)
    println "[INFO]s: $outputStream"
}

def isLocalBuild() {
//    return false
    return DEV_LINE == "unknown"
}

// 检测是否使用Flutter开发
def isUseFlutterDevelop() {
    boolean enableDetectFlutterDir = gradle.android_enableDetectFlutterDir && gradle.android_enableDetectFlutterDir.toBoolean()

    mFlutterProjectRoot = "${gradle.settingsDir}" + '/girgir_flutter_module'

    println "[INFO]: groovy enableDetectFlutterDir is $enableDetectFlutterDir"

    boolean isDetectedFlutterDir = mFlutterProjectRoot != null && !mFlutterProjectRoot.isEmpty() && enableDetectFlutterDir
    gradle.getGradle().ext.isDetectedFlutterDir = isDetectedFlutterDir

    println "[INFO]: groovy isDetectedFlutterDir is: ${isDetectedFlutterDir}"

    return isDetectedFlutterDir
}