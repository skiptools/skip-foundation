// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if SKIP

import kotlin.reflect.full.companionObject
import kotlin.reflect.full.companionObjectInstance
import kotlin.reflect.full.functions
import kotlin.reflect.full.__

public class ProcessInfo {
    /// The global `processInfo` must be set manually at app launch with `skip.foundation.ProcessInfo.launch(context)`
    /// Otherwise error: `skip.lib.ErrorException: kotlin.UninitializedPropertyAccessException: lateinit property processInfo has not been initialized`
    ///
    /// Note that this API is accessed via JNI in `SkipAndroidBridge.ProcessInfo`.
    public static var processInfo: ProcessInfo = ProcessInfo()

    init() {
    }

    /// The Android context for the process, which should have been set on app launch, and will fall back on using an Android test context.
    ///
    /// Note that this API is accessed via JNI in `SkipAndroidBridge.ProcessInfo`.
    public var androidContext: android.content.Context! {
        // androidx.compose.ui.platform.LocalContext.current could be used, but it is @Composable and so can't be called from a static context
        launchContext ?? testContext
    }

    /// Called when an app is launched to store the global context from the `android.app.Application` subclass.
    public static func launch(context: android.content.Context) {
        ProcessInfo.processInfo.launchContext = context
        Thread.main = Thread.current
        AssetURLProtocol.register()

        // if we import SkipBridge it includes an AndroidManifest.xml that defines the "SKIP_BRIDGE_MODULES" list of native modules to load
        // since SkipBridge is not a dependency of SkipFoundation, we need to use reflection to call the
        // skip.android.bridge.AndroidBridge.initBridge function
        if let packageManager = context.getPackageManager() {
            if let packageInfo = packageManager.getPackageInfo(context.getPackageName(), android.content.pm.PackageManager.GET_META_DATA) {
                if let packageMetaData = packageInfo.applicationInfo?.metaData {
                    if let bridgeModules = packageMetaData.getString("SKIP_BRIDGE_MODULES") {
                        android.util.Log.i("SkipFoundation", "loading SKIP_BRIDGE_MODULES: \(bridgeModules)")
                        let bridgeClass = Class.forName("skip.android.bridge.AndroidBridge").kotlin
                        android.util.Log.i("SkipFoundation", "calling bridgeClass: \(bridgeClass)")
                        if let companionObject = bridgeClass.companionObject,
                            let initBridge = companionObject.functions?.find({ $0.name == "initBridge" }) {
                            android.util.Log.i("SkipFoundation", "invoking initBridge: \(initBridge)")
                            initBridge.call(bridgeClass.companionObjectInstance, bridgeModules)
                        } else {
                            android.util.Log.w("SkipFoundation", "could not func skip.android.bridge.AndroidBridge.initBridge")
                        }
                    }
                }
            }
        }
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

    public var globallyUniqueString: String {
        return UUID().description
    }

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

    public var environment: [String : String] {
        return systemProperties
    }

    public var processIdentifier: Int32 {
        do {
            return android.os.Process.myPid()
        } catch {
            // seems to happen in Robolectric tests
            // return java.lang.ProcessHandle.current().pid().toInt() // JDK9+, so doesn't compile
            // JMX name is "pid@hostname" (e.g., "57924@zap.local")
            // return java.lang.management.ManagementFactory.getRuntimeMXBean().getName().split(separator: "@").first?.toLong() ?? -1
            return -1
        }
    }

    @available(*, unavailable)
    public var processName: String {
        fatalError()
    }

    public var arguments: [String] {
        return [] // no arguments on Android
    }

    public var hostName: String {
        // Android 30+: NetworkOnMainThreadException
        return java.net.InetAddress.getLocalHost().hostName
    }

    public var processorCount: Int {
        return Runtime.getRuntime().availableProcessors()
    }

    public var operatingSystemVersionString: String {
        return android.os.Build.VERSION.RELEASE
    }

    public var isMacCatalystApp: Bool {
        return false
    }

    public var isiOSAppOnMac: Bool {
        return false
    }

    @available(*, unavailable)
    public var userName: String {
        fatalError()
    }

    @available(*, unavailable)
    public var fullUserName: String {
        fatalError()
    }

    @available(*, unavailable)
    public func disableSuddenTermination() {
    }

    @available(*, unavailable)
    public func enableSuddenTermination() {
    }

    @available(*, unavailable)
    public func disableAutomaticTermination(_ value: String) {
    }

    @available(*, unavailable)
    public func enableAutomaticTermination(_ value: String) {
    }

    @available(*, unavailable)
    public var automaticTerminationSupportEnabled: Bool {
        fatalError()
    }

    @available(*, unavailable)
    public var operatingSystemVersion: OperatingSystemVersion {
        fatalError()
    }

    @available(*, unavailable)
    public func isOperatingSystemAtLeast(_ value: OperatingSystemVersion) -> Bool {
        fatalError()
    }

    @available(*, unavailable)
    public func operatingSystem() -> Int {
        fatalError()
    }

    @available(*, unavailable)
    public func operatingSystemName() -> String {
        fatalError()
    }

    @available(*, unavailable)
    public var activeProcessorCount: Int {
        fatalError()
    }

    @available(*, unavailable)
    public var physicalMemory: UInt64 {
        fatalError()
    }

    @available(*, unavailable)
    public var systemUptime: TimeInterval {
        fatalError()
    }

    @available(*, unavailable)
    public func beginActivity(options: ProcessInfo.ActivityOptions, reason: String) -> Any {
        fatalError()
    }

    @available(*, unavailable)
    public func endActivity(_ value: Any) {
    }

    @available(*, unavailable)
    public func performActivity(options: ProcessInfo.ActivityOptions, reason: String, using: () -> Void) {
    }

    @available(*, unavailable)
    public func performExpiringActivity(withReason: String, using: (Bool) -> Void) {
    }

    @available(*, unavailable)
    public var thermalState: ProcessInfo.ThermalState {
        fatalError()
    }

    @available(*, unavailable)
    public var isLowPowerModeEnabled: Bool {
        fatalError()
    }

    public struct ActivityOptions: OptionSet, RawRepresentable {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static var idleDisplaySleepDisabled = ProcessInfo.ActivityOptions(rawValue: 1)
        public static var idleSystemSleepDisabled = ProcessInfo.ActivityOptions(rawValue: 2)
        public static var suddenTerminationDisabled = ProcessInfo.ActivityOptions(rawValue: 4)
        public static var automaticTerminationDisabled = ProcessInfo.ActivityOptions(rawValue: 8)
        public static var userInitiated = ProcessInfo.ActivityOptions(rawValue: 16)
        public static var userInteractive = ProcessInfo.ActivityOptions(rawValue: 32)
        public static var userInitiatedAllowingIdleSystemSleep = ProcessInfo.ActivityOptions(rawValue: 64)
        public static var background = ProcessInfo.ActivityOptions(rawValue: 128)
        public static var latencyCritical = ProcessInfo.ActivityOptions(rawValue: 256)
        public static var animationTrackingEnabled = ProcessInfo.ActivityOptions(rawValue: 512)
        public static var trackingEnabled = ProcessInfo.ActivityOptions(rawValue: 1024)
    }

    public struct OperatingSystemVersion {
        public var majorVersion: Int
        public var minorVersion: Int
        public var patchVersion: Int

        public init(majorVersion: Int = 0, minorVersion: Int = 0, patchVersion: Int = 0) {
            self.majorVersion = majorVersion
            self.minorVersion = minorVersion
            self.patchVersion = patchVersion
        }
    }

    public enum ThermalState: Int {
        case nominal, fair, serious, critical
    }
}

#endif
