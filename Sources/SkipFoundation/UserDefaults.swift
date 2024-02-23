// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

public class UserDefaults: KotlinConverting<android.content.SharedPreferences> {
    let platformValue: android.content.SharedPreferences
    /// The default default values
    private var registrationDictionary: [String: Any] = [:]

    public static var standard: UserDefaults {
        UserDefaults(suiteName: nil)
    }

    public init(platformValue: android.content.SharedPreferences) {
        self.platformValue = platformValue
    }

    public init(suiteName: String?) {
        platformValue = ProcessInfo.processInfo.androidContext.getSharedPreferences(suiteName ?? "defaults", android.content.Context.MODE_PRIVATE)
    }

    public func register(defaults registrationDictionary: [String : Any]) {
        self.registrationDictionary = registrationDictionary
    }

    public func registerOnSharedPreferenceChangeListener(key: String, onChange: () -> Void) -> AnyObject {
        let listener = android.content.SharedPreferences.OnSharedPreferenceChangeListener { (_, changedKey: String?) in
            if let changedKey, key == changedKey {
                onChange()
            }
        }

        platformValue.registerOnSharedPreferenceChangeListener(listener)
        return listener
    }

    public func `set`(_ value: Int, forKey defaultName: String) {
        let prefs = platformValue.edit()
        prefs.putInt(defaultName, value)
        prefs.apply()
    }

    public func `set`(_ value: Boolean, forKey defaultName: String) {
        let prefs = platformValue.edit()
        prefs.putBoolean(defaultName, value)
        prefs.apply()
    }

    public func `set`(_ value: Double, forKey defaultName: String) {
        let prefs = platformValue.edit()
        prefs.putFloat(defaultName, value.toFloat())
        prefs.apply()
    }

    public func `set`(_ value: String, forKey defaultName: String) {
        let prefs = platformValue.edit()
        prefs.putString(defaultName, value)
        prefs.apply()
    }

    public func `set`(_ value: Any?, forKey defaultName: String) {
        let prefs = platformValue.edit()
        defer { prefs.apply() }

        if let v = value as? Float {
            prefs.putFloat(defaultName, v)
        } else if let v = value as? Int64 {
            prefs.putLong(defaultName, v)
        } else if let v = value as? Int {
            prefs.putInt(defaultName, v)
        } else if let v = value as? Bool {
            prefs.putBoolean(defaultName, v)
        } else if let v = value as? Double {
            prefs.putFloat(defaultName, v.toFloat())
        } else if let v = value as? Number {
            prefs.putString(defaultName, v.toString())
        } else if let v = value as? String {
            prefs.putString(defaultName, v)
        } else if let v = value as? URL {
            prefs.putString(defaultName, v.absoluteString)
        } else if let v = value as? Data {
            prefs.putString(defaultName, Self.dataStringPrefix + dataToString(v))
        } else if let v = value as? Date {
            prefs.putString(defaultName, Self.dateStringPrefix + dateToString(v))
        } else {
            // we ignore
            return
        }
    }

    public func removeObject(forKey defaultName: String) {
        let prefs = platformValue.edit()
        prefs.remove(defaultName)
        prefs.apply()
    }

    public func object(forKey defaultName: String) -> Any? {
        let value = platformValue.getAll()[defaultName] ?? registrationDictionary[defaultName] ?? nil
        return fromStoredRepresentation(value)
    }

    private func fromStoredRepresentation(_ value: Any?) -> Any? {
        guard let string = value as? String else {
            return value
        }
        if string.hasPrefix(Self.dataStringPrefix) {
            return dataFromString(string.dropFirst(Self.dataStringPrefix.count))
        } else if string.hasPrefix(Self.dateStringPrefix) {
            return dateFromString(string.dropFirst(Self.dateStringPrefix.count))
        } else {
            return string
        }
    }

    @available(*, unavailable)
    public func array(forKey defaultName: String) -> [Any]? {
        fatalError()
    }

    @available(*, unavailable)
    public func dictionary(forKey defaultName: String) -> [String: Any]? {
        fatalError()
    }

    public func string(forKey defaultName: String) -> String? {
        guard let value = object(forKey: defaultName) else {
            return nil
        }
        if let number = value as? Number {
            return number.toString()
        } else if let bool = value as? Bool {
            return bool ? "YES" : "NO"
        } else if let string = value as? String {
            if string.hasPrefix(Self.dataStringPrefix) {
                return string.dropFirst(Self.dataStringPrefix.count)
            } else if string.hasPrefix(Self.dateStringPrefix) {
                return string.dropFirst(Self.dateStringPrefix.count)
            } else {
                return string
            }
        } else {
            return nil
        }
    }

    @available(*, unavailable)
    public func stringArray(forKey defaultName: String) -> [String]? {
        fatalError()
    }

    public func double(forKey defaultName: String) -> Double? {
        guard let value = object(forKey: defaultName) else {
            return nil
        }
        if let number = value as? Number {
            return number.toDouble()
        } else if let bool = value as? Bool {
            return bool ? 1.0 : 0.0
        } else if let string = value as? String {
            return string.toDouble()
        } else {
            return nil
        }
    }

    public func integer(forKey defaultName: String) -> Int? {
        guard let value = object(forKey: defaultName) else {
            return nil
        }
        if let number = value as? Number {
            return number.toInt()
        } else if let bool = value as? Bool {
            return bool ? 1 : 0
        } else if let string = value as? String {
            return string.toInt()
        } else {
            return nil
        }
    }

    public func bool(forKey defaultName: String) -> Bool? {
        guard let value = object(forKey: defaultName) else {
            return nil
        }
        if let number = value as? Number {
            return number.toDouble() == 0.0 ? false : true
        } else if let bool = value as? Bool {
            return bool
        } else if let string = value as? String {
            // match the default string->bool conversion for UserDefaults
            return ["true", "yes", "1"].contains(string.lowercased())
        } else {
            return nil
        }
    }

    public func url(forKey defaultName: String) -> URL? {
        guard let value = object(forKey: defaultName) else {
            return nil
        }
        if let url = value as? URL {
            return url
        } else if let string = value as? String {
            return URL(string: string)
        } else {
            return nil
        }
    }

    public func data(forKey defaultName: String) -> Data? {
        guard let value = object(forKey: defaultName) else {
            return nil
        }
        if let data = value as? Data {
            return data
        } else if let string = value as? String {
            return dataFromString(string.hasPrefix(Self.dataStringPrefix) ? string.dropFirst(Self.dataStringPrefix.count) : string)
        } else {
            return nil
        }
    }

    public func dictionaryRepresentation() -> [String : Any] {
        let map = platformValue.getAll()
        var dict = Dictionary<String, Any>()
        for entry in map {
            if let value = fromStoredRepresentation(entry.value) {
                dict[entry.key] = value
            }
        }
        return dict
    }

    public func synchronize() -> Bool {
        return true
    }

    public static func resetStandardUserDefaults() {
    }

    @available(*, unavailable)
    public func addSuite(named: String) {
    }

    @available(*, unavailable)
    public func removeSuite(named: String) {
    }

    @available(*, unavailable)
    public func persistentDomain(forName: String) -> [String : Any]? {
        fatalError()
    }

    @available(*, unavailable)
    public func setPersistentDomain(_ value: [String : Any], forName: String) {
    }

    @available(*, unavailable)
    public func removePersistentDomain(forName: String) {
    }

    @available(*, unavailable)
    public var volatileDomainNames: [String] {
        fatalError()
    }

    @available(*, unavailable)
    public func volatileDomain(forName: String) -> [String : Any] {
        fatalError()
    }

    @available(*, unavailable)
    public func setVolatileDomain(_ value: [String : Any], forName: String) {
        fatalError()
    }

    @available(*, unavailable)
    public func removeVolatileDomain(forName: String) {
    }

    @available(*, unavailable)
    public static let argumentDomain: String = ""

    @available(*, unavailable)
    public static let globalDomain: String = ""

    @available(*, unavailable)
    public static let registrationDomain: String = ""

    @available(*, unavailable)
    public static let didChangeNotification = Notification.Name(rawValue: "NSUserDefaultsDidChangeNotification")

    @available(*, unavailable)
    public static let sizeLimitExceededNotification = Notification.Name(rawValue: "NSUserDefaultsSizeLimitExceededNotification")

    @available(*, unavailable)
    public static let completedInitialCloudSyncNotification = Notification.Name(rawValue: "NSUserDefaultsCompletedInitialCloudSyncNotification")

    @available(*, unavailable)
    public static let didChangeCloudAccountsNotification = Notification.Name(rawValue: "NSUserDefaultsDidChangeCloudAccountsNotification")

    @available(*, unavailable)
    public static let noCloudAccountNotification = Notification.Name(rawValue: "NSUserDefaultsNoCloudAccountNotification")

    @available(*, unavailable)
    public func objectIsForced(forKey: String) -> Bool {
        fatalError()
    }

    @available(*, unavailable)
    public func objectIsForced(forKey: String, inDomain: String) -> Bool {
        fatalError()
    }

    private static let dataStringPrefix = "__data__:"
    private static let dateStringPrefix = "__date__:"
    private static let dateFormatter = ISO8601DateFormatter()

    private func dataToString(_ data: Data) -> String {
        return data.base64EncodedString()
    }

    private func dataFromString(_ string: String) -> Data? {
        return Data(base64Encoded: string)
    }

    private func dateToString(_ date: Date) -> String {
        return date.ISO8601Format()
    }

    private func dateFromString(_ string: String) -> Date? {
        return Self.dateFormatter.date(from: string)
    }

    public override func kotlin(nocopy: Bool = false) -> android.content.SharedPreferences {
        return platformValue
    }
}

#endif
