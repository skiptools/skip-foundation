// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

// Note: !SKIP code paths used to validate implementation only.
// Not used in applications. See contribution guide for details.
#if !SKIP
@_implementationOnly import class Foundation.UserDefaults
internal typealias PlatformUserDefaults = Foundation.UserDefaults
#else
internal typealias PlatformUserDefaults = android.content.SharedPreferences
#endif

/// An interface to the user’s defaults database, where you store key-value pairs persistently across launches of your app.
public class UserDefaults {
    let platformValue: PlatformUserDefaults

    init(platformValue: PlatformUserDefaults) {
        self.platformValue = platformValue
    }

    init(_ platformValue: PlatformUserDefaults) {
        self.platformValue = platformValue
    }
}

#if SKIP
extension UserDefaults {
    public static var standard: UserDefaults {
        // FIXME: uses androidx.test
        UserDefaults(ProcessInfo.processInfo.androidContext.getSharedPreferences("defaults", android.content.Context.MODE_PRIVATE))
    }

    public func `set`(_ value: Int, forKey keyName: String) {
        let prefs = platformValue.edit()
        prefs.putInt(keyName, value)
        prefs.apply()
    }

    public func `set`(_ value: Boolean, forKey keyName: String) {
        let prefs = platformValue.edit()
        prefs.putBoolean(keyName, value)
        prefs.apply()
    }

    public func `set`(_ value: Double, forKey keyName: String) {
        let prefs = platformValue.edit()
        prefs.putFloat(keyName, value.toFloat())
        prefs.apply()
    }

    public func `set`(_ value: String, forKey keyName: String) {
        let prefs = platformValue.edit()
        prefs.putString(keyName, value)
        prefs.apply()
    }

    public func string(forKey keyName: String) -> String? {
        platformValue.getString(keyName, nil)
    }

    public func double(forKey keyName: String) -> Double? {
        !platformValue.contains(keyName) ? nil : platformValue.getFloat(keyName, 0.toFloat()).toDouble()
    }

    public func integer(forKey keyName: String) -> Int? {
        !platformValue.contains(keyName) ? nil : platformValue.getInt(keyName, 0)
    }

    public func bool(forKey keyName: String) -> Bool? {
        !platformValue.contains(keyName) ? nil : platformValue.getBoolean(keyName, false)
    }

}
#endif

#if SKIP
extension UserDefaults {
    public func kotlin(nocopy: Bool = false) -> android.content.SharedPreferences {
        return platformValue
    }
}

extension android.content.SharedPreferences {
    public func swift(nocopy: Bool = false) -> UserDefaults {
        return UserDefaults(platformValue: self)
    }
}
#endif
