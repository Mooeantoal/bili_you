import java.io.File

object AppConfiguration {
    const val appId = "dev.aaa1115910.bv"
    const val compileSdk = 36
    const val minSdk = 23
    const val targetSdk = 36
    private const val major = 0
    private const val minor = 3
    private const val patch = 0
    private const val hotFix = 0

    @Suppress("KotlinConstantConditions")
    val versionName: String by lazy {
        "$major.$minor.$patch${".$hotFix".takeIf { hotFix != 0 } ?: ""}" +
                ".r${versionCode}.${"git rev-list HEAD --abbrev-commit --max-count=1".exec()}"
    }
    val versionCode: Int by lazy { "git rev-list --count HEAD".exec().toInt() }
    const val libVLCVersion = "3.0.18"
    var googleServicesAvailable = true
    const val blacklistUrl =
        "https://raw.githubusercontent.com/aaa1115910/bv-blacklist/main/blacklist.bin"

    init {
        initConfigurations()
    }

    private fun initConfigurations() {
        val googleServicesJsonFile = File("app/google-services.json")
        googleServicesAvailable =
            googleServicesJsonFile.exists() && googleServicesJsonFile.readText().let {
                it.contains(appId) && it.contains("$appId.debug")
            }
        println("Google Services available: $googleServicesAvailable")
    }
}

fun String.exec() = String(Runtime.getRuntime().exec(this).inputStream.readBytes()).trim()
