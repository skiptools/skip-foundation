// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

// Note: !SKIP code paths used to validate implementation only.
// Not used in applications. See contribution guide for details.
#if !SKIP
@_implementationOnly import class Foundation.ProcessInfo
internal typealias PlatformProcessInfo = Foundation.ProcessInfo
#else
#endif

/// A collection of information about the current process.
public class ProcessInfo {
    #if SKIP
    /// The global `processInfo` must be set manually at app launch with `skip.foundation.ProcessInfo.launch(context)`
    /// Otherwise error: `skip.lib.ErrorException: kotlin.UninitializedPropertyAccessException: lateinit property processInfo has not been initialized`
    public static var processInfo: ProcessInfo = ProcessInfo()

    init() {
    }

    /// The Android context for the process, which should have been set on app launch, and will fall back on using an Android test context.
    public var androidContext: android.content.Context! {
        // androidx.compose.ui.platform.LocalContext.current could be used, but it is @Composable and so can't be called from a static context
        launchContext ?? testContext
    }

    /// Called when an app is launched to store the global context from the `android.app.Application` subclass.
    public static func launch(context: android.content.Context) {
        ProcessInfo.processInfo.launchContext = context
    }

    private var testContext: android.content.Context {
        // fallback to assuming we are running in a test environment
        // we don't have a compile dependency on android test, so we need to load using reflection
        // androidx.test.core.app.ApplicationProvider.getApplicationContext()
        return Class.forName("androidx.test.core.app.ApplicationProvider")
            .getDeclaredMethod("getApplicationContext")
            .invoke(nil) as android.content.Context
    }

    private var launchContext: android.content.Context?

    #else
    public static var processInfo = ProcessInfo(platformValue: PlatformProcessInfo.processInfo)
    let platformValue: PlatformProcessInfo

    init(platformValue: PlatformProcessInfo) {
        self.platformValue = platformValue
    }
    #endif

    open var globallyUniqueString: String {
        #if !SKIP
        return platformValue.globallyUniqueString
        #else
        return UUID().description
        #endif
    }

    #if SKIP
    private let systemProperties: Dictionary<String, String> = Self.buildSystemProperties()

    private static func buildSystemProperties() -> Dictionary<String, String> {
        var dict: [String: String] = [:]
        // The system properties contains the System environment (which, on Android, doesn't contain much of interest),
        for (key, value) in System.getenv() {
            dict[key] = value
        }

        // as well as the Java System.getProperties()
        // there are only a few system properties on the Android emulator: java.io.tmpdir, user.home, and http.agent "Dalvik/2.1.0 (Linux; U; Android 13; sdk_gphone64_arm64 Build/ TE1A.220922.021)"
        for (key, value) in System.getProperties() {
            dict[key.toString()] = value.toString()
        }

        // there are more system properties than are listed in the getProperties() keys, so also fetch sepcific individual known property keys
        for key in [
            "os.version", // version of the Android operating system e.g.: "5.1.1"
            "java.vendor", // vendor of the Java runtime used on Android e.g.: "The Android Project"
            "java.version", // version of the Java runtime used on Android e.g.: "1.8.0_292"
            "user.home", // user's home directory e.g.: "/data/data/com.example.myapp"
            "user.name", // username associated with the Android user e.g.: "android"
            "file.separator", // file separator used on the device e.g.: "/"
            "line.separator", // line separator used in text files e.g.: "\n"
            "java.class.path", // classpath for Java classes e.g.: ""
            "java.library.path", // library path for native libraries e.g.: "/system/lib:/vendor/lib"
            "java.class.version", // Java class file version e.g.: "52.0"
            "java.vm.name", // name of the Java Virtual Machine (JVM) on Android e.g.: "Dalvik"
            "java.vm.version", // version of the JVM on Android e.g.: "2.1.0"
            "java.vm.vendor", // vendor of the JVM on Android e.g.: "The Android Project"
            "java.ext.dirs", // extension directory for Java classes e.g.: "/system/framework"
            "java.io.tmpdir", // directory for temporary files e.g.: "/data/data/com.example.myapp/cache"
            "java.specification.version", // Java specification version e.g.: "1.8"
            "java.specification.vendor", // vendor of the Java specification e.g.: "The Android Project"
            "java.specification.name", // name of the Java specification e.g.: "Java Platform API Specification"
            "java.home", // directory where the Java runtime is installed e.g.: "/system"
            "user.dir", // current working directory of the application e.g.: "/data/data/com.example.myapp"
        ] {
            dict[key] = System.getProperty(key)
        }

        // and finally add in some android build constants so clients have a Foundation-compatible way of testing for the Android build number, ec.

        dict["android.os.Build.BOARD"] = android.os.Build.BOARD // The name of the underlying board, like "goldfish".
        dict["android.os.Build.BOOTLOADER"] = android.os.Build.BOOTLOADER // The system bootloader version number.
        dict["android.os.Build.BRAND"] = android.os.Build.BRAND // The consumer-visible brand with which the product/hardware will be associated, if any.
        dict["android.os.Build.DEVICE"] = android.os.Build.DEVICE // The name of the industrial design.
        dict["android.os.Build.DISPLAY"] = android.os.Build.DISPLAY // A build ID string meant for displaying to the user
        dict["android.os.Build.FINGERPRINT"] = android.os.Build.FINGERPRINT // A string that uniquely identifies this build.
        dict["android.os.Build.HARDWARE"] = android.os.Build.HARDWARE // The name of the hardware (from the kernel command line or /proc).
        dict["android.os.Build.HOST"] = android.os.Build.HOST // A string that uniquely identifies this build.
        dict["android.os.Build.ID"] = android.os.Build.ID // Either a changelist number, or a label like "M4-rc20".
        dict["android.os.Build.MANUFACTURER"] = android.os.Build.MANUFACTURER // The manufacturer of the product/hardware.
        dict["android.os.Build.MODEL"] = android.os.Build.MODEL // The end-user-visible name for the end product.
        //dict["android.os.Build.ODM_SKU"] = android.os.Build.ODM_SKU // The SKU of the device as set by the original design manufacturer (ODM). // API 31: java.lang.NoSuchFieldError: ODM_SKU
        dict["android.os.Build.PRODUCT"] = android.os.Build.PRODUCT // The name of the overall product.
        //dict["android.os.Build.SKU"] = android.os.Build.SKU // The SKU of the hardware (from the kernel command line). // API 31: java.lang.NoSuchFieldError: SKU
        //dict["android.os.Build.SOC_MANUFACTURER"] = android.os.Build.SOC_MANUFACTURER // The manufacturer of the device's primary system-on-chip. // API 31: java.lang.NoSuchFieldError: SOC_MANUFACTURER
        //dict["android.os.Build.SOC_MODEL"] = android.os.Build.SOC_MODEL // The model name of the device's primary system-on-chip. // API 31
        dict["android.os.Build.TAGS"] = android.os.Build.TAGS // Comma-separated tags describing the build, like "unsigned,debug".
        dict["android.os.Build.TYPE"] = android.os.Build.TYPE // The type of build, like "user" or "eng".
        dict["android.os.Build.USER"] = android.os.Build.USER // The user


        dict["android.os.Build.TIME"] = android.os.Build.TIME.toString() //  The time at which the build was produced, given in milliseconds since the UNIX epoch.

//        dict["android.os.Build.SUPPORTED_32_BIT_ABIS"] = android.os.Build.SUPPORTED_32_BIT_ABIS.joinToString(",") // An ordered list of 32 bit ABIs supported by this device.
//        dict["android.os.Build.SUPPORTED_64_BIT_ABIS"] = android.os.Build.SUPPORTED_64_BIT_ABIS.joinToString(",") // An ordered list of 64 bit ABIs supported by this device.
//        dict["android.os.Build.SUPPORTED_ABIS"] = android.os.Build.SUPPORTED_ABIS.joinToString(",") // An ordered list of ABIs supported by this device.

        dict["android.os.Build.VERSION.BASE_OS"] = android.os.Build.VERSION.BASE_OS // The base OS build the product is based on.
        dict["android.os.Build.VERSION.CODENAME"] = android.os.Build.VERSION.CODENAME // The current development codename, or the string "REL" if this is a release build.
        dict["android.os.Build.VERSION.INCREMENTAL"] = android.os.Build.VERSION.INCREMENTAL // The internal value used by the underlying source control to represent this build. E.g., a perforce changelist number or a git hash.
        dict["android.os.Build.VERSION.PREVIEW_SDK_INT"] = android.os.Build.VERSION.PREVIEW_SDK_INT.description // The developer preview revision of a prerelease SDK. This value will always be 0 on production platform builds/devices.
        dict["android.os.Build.VERSION.RELEASE"] = android.os.Build.VERSION.RELEASE // The user-visible version string. E.g., "1.0" or "3.4b5" or "bananas". This field is an opaque string. Do not assume that its value has any particular structure or that values of RELEASE from different releases can be somehow ordered.
        dict["android.os.Build.VERSION.SDK_INT"] = android.os.Build.VERSION.SDK_INT.description // The SDK version of the software currently running on this hardware device. This value never changes while a device is booted, but it may increase when the hardware manufacturer provides an OTA update.
        dict["android.os.Build.VERSION.SECURITY_PATCH"] = android.os.Build.VERSION.SECURITY_PATCH // The user-visible security patch level. This value represents the date when the device most recently applied a security patch.

        return dict
    }
    #endif

    open var environment: [String : String] {
        #if !SKIP
        return platformValue.environment
        #else
        return systemProperties
        #endif
    }

    open var processIdentifier: Int32 {
        #if !SKIP
        return platformValue.processIdentifier
        #else
        do {
            return android.os.Process.myPid()
        } catch {
            // seems to happen in Robolectric tests
            // return java.lang.ProcessHandle.current().pid().toInt() // JDK9+, so doesn't compile
            // JMX name is "pid@hostname" (e.g., "57924@zap.local")
            // return java.lang.management.ManagementFactory.getRuntimeMXBean().getName().split(separator: "@").first?.toLong() ?? -1
            return -1
        }
        #endif
    }

    open var arguments: [String] {
        #if !SKIP
        return platformValue.arguments
        #else
        return [] // no arguments on Android
        #endif
    }

    open var hostName: String {
        #if !SKIP
        return platformValue.hostName
        #else
        // Android 30+: NetworkOnMainThreadException
        return java.net.InetAddress.getLocalHost().hostName
        #endif
    }

    @available(*, unavailable)
    open var processName: String {
        #if !SKIP
        return platformValue.processName
        #else
        fatalError("TODO: ProcessInfo")
        #endif
    }

    open var processorCount: Int {
        #if !SKIP
        return platformValue.processorCount
        #else
        return Runtime.getRuntime().availableProcessors()
        #endif
    }

    open var operatingSystemVersionString: String {
        #if !SKIP
        return platformValue.operatingSystemVersionString
        #else
        return android.os.Build.VERSION.RELEASE
        #endif
    }
}
