// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if SKIP
import kotlin.math.roundToInt

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
        prefs.remove("\(unrepresentableTypePrefix)\(defaultName)")
        prefs.apply()
    }

    public func `set`(_ value: Float, forKey defaultName: String) {
        let prefs = platformValue.edit()
        prefs.putFloat(defaultName, value)
        prefs.remove("\(unrepresentableTypePrefix)\(defaultName)")
        prefs.apply()
    }

    public func `set`(_ value: Boolean, forKey defaultName: String) {
        let prefs = platformValue.edit()
        prefs.putBoolean(defaultName, value)
        prefs.remove("\(unrepresentableTypePrefix)\(defaultName)")
        prefs.apply()
    }

    public func `set`(_ value: Double, forKey defaultName: String) {
        let prefs = platformValue.edit()
        prefs.putLong(defaultName, value.toRawBits())
        putUnrepresentableType(prefs, type: .double, forKey: defaultName)
        prefs.apply()
    }

    public func `set`(_ value: String, forKey defaultName: String) {
        let prefs = platformValue.edit()
        prefs.putString(defaultName, value)
        prefs.remove("\(unrepresentableTypePrefix)\(defaultName)")
        prefs.apply()
    }

    public func `set`(_ value: Any?, forKey defaultName: String) {
        let prefs = platformValue.edit()
        defer { prefs.apply() }

        if value == nil {
            prefs.remove(defaultName)
            prefs.remove("\(unrepresentableTypePrefix)\(defaultName)")
        } else if let v = value as? Float {
            prefs.putFloat(defaultName, v)
            prefs.remove("\(unrepresentableTypePrefix)\(defaultName)")
        } else if let v = value as? Int64 {
            prefs.putLong(defaultName, v)
            prefs.remove("\(unrepresentableTypePrefix)\(defaultName)")
        } else if let v = value as? Int {
            prefs.putInt(defaultName, v)
            prefs.remove("\(unrepresentableTypePrefix)\(defaultName)")
        } else if let v = value as? Bool {
            prefs.putBoolean(defaultName, v)
            prefs.remove("\(unrepresentableTypePrefix)\(defaultName)")
        } else if let v = value as? Double {
            prefs.putLong(defaultName, value.toRawBits())
            putUnrepresentableType(prefs, type: .double, forKey: defaultName)
        } else if let v = value as? Number {
            prefs.putString(defaultName, v.toString())
            prefs.remove("\(unrepresentableTypePrefix)\(defaultName)")
        } else if let v = value as? String {
            prefs.putString(defaultName, v)
            prefs.remove("\(unrepresentableTypePrefix)\(defaultName)")
        } else if let v = value as? URL {
            prefs.putString(defaultName, v.absoluteString)
            putUnrepresentableType(prefs, type: .url, forKey: defaultName)
        } else if let v = value as? Data {
            prefs.putString(defaultName, dataToString(v))
            putUnrepresentableType(prefs, type: .data, forKey: defaultName)
        } else if let v = value as? Date {
            prefs.putString(defaultName, dateToString(v))
            putUnrepresentableType(prefs, type: .date, forKey: defaultName)
        } else {
            // we ignore
            return
        }
    }

    public func removeObject(forKey defaultName: String) {
        let prefs = platformValue.edit()
        prefs.remove(defaultName)
        prefs.remove("\(unrepresentableTypePrefix)\(defaultName)")
        prefs.apply()
    }

    public func object(forKey defaultName: String) -> Any? {
        let value = platformValue.getAll()[defaultName] ?? registrationDictionary[defaultName] ?? nil
        return fromStoredRepresentation(value, key: defaultName)
    }

    private func putUnrepresentableType(_ prefs: android.content.SharedPreferences.Editor, type: UnrepresentableType, forKey key: String) {
        prefs.putInt("\(unrepresentableTypePrefix)\(key)", type.rawValue)
    }
    
    private func getUnrepresentableType(forKey key: String) -> UnrepresentableType? {
        let unrepresentableTypeId = platformValue.getInt("\(unrepresentableTypePrefix)\(key)", 0)
        if unrepresentableTypeId == 0 {
            return nil
        }
        return UnrepresentableType(rawValue: unrepresentableTypeId)
    }
    
    private func fromStoredRepresentation(_ value: Any?, key: String) -> Any? {
        if let l = value as? Long {
            if getUnrepresentableType(forKey: key) == .double {
                return Double.fromBits(l)
            } else {
                return value
            }
        } else if let string = value as? String {
            if string.hasPrefix(Self.dataStringPrefix) {
                return dataFromString(string.dropFirst(Self.dataStringPrefix.count))
            } else if string.hasPrefix(Self.dateStringPrefix) {
                return dateFromString(string.dropFirst(Self.dateStringPrefix.count))
            } else {
                switch getUnrepresentableType(forKey: key) {
                    case .data:
                        return dataFromString(string)
                    case .date:
                        return dateFromString(string)
                    case .url:
                        return URL(string: string)
                    default: return value
                }
            }
        }
        return value
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

    public func double(forKey defaultName: String) -> Double {
        guard let value = object(forKey: defaultName) else {
            return 0.0
        }
        if let double = value as? Double {
            return double
        } else if let float = value as? Float {
            return removeDoubleSlop(float.toDouble())
        } else if let number = value as? Number {
            // Number could be stored before #54 was fixed
            if let double = number as? Long {
                return Double.fromBits(double)
            } else {
                return removeDoubleSlop(number.toDouble())
            }
        } else if let bool = value as? Bool {
            return bool ? 1.0 : 0.0
        } else if let string = value as? String {
            return string.toDouble()
        } else {
            return 0.0
        }
    }

    public func integer(forKey defaultName: String) -> Int {
        guard let value = object(forKey: defaultName) else {
            return 0
        }
        if let number = value as? Number {
            return number.toInt()
        } else if let bool = value as? Bool {
            return bool ? 1 : 0
        } else if let string = value as? String {
            return string.toInt()
        } else {
            return 0
        }
    }

    public func float(forKey defaultName: String) -> Float {
        guard let value = object(forKey: defaultName) else {
            return Float(0.0)
        }
        if let float = value as? Float {
            return float
        } else if let number = value as? Number {
            // Number could be stored before #54 was fixed
            if let i = number as? Int {
                return Float.fromBits(i)
            } else {
                return removeFloatSlop(number.toFloat())
            }
        } else if let bool = value as? Bool {
            return bool ? Float(1.0) : Float(0.0)
        } else if let string = value as? String {
            return string.toFloat()
        } else {
            return Float(0.0)
        }
    }

    public func bool(forKey defaultName: String) -> Bool {
        guard let value = object(forKey: defaultName) else {
            return false
        }
        if let number = value as? Number {
            return number.toDouble() == 0.0 ? false : true
        } else if let bool = value as? Bool {
            return bool
        } else if let string = value as? String {
            // match the default string->bool conversion for UserDefaults
            return ["true", "yes", "1"].contains(string.lowercased())
        } else {
            return false
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
            if let value = fromStoredRepresentation(entry.value, key: entry.key) {
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

    enum UnrepresentableType: Int {
        case unspecified = 0,
             double = 1,
             date = 2,
             data = 3,
             url = 4
    }
    
    private static let unrepresentableTypePrefix = "__unrepresentable__:"
    private static let dataStringPrefix = "__data__:"
    private static let dateStringPrefix = "__date__:"
    private static let dateFormatter = ISO8601DateFormatter()

    private func removeFloatSlop(_ value: Float) -> Float {
        let factor = 100000.0
        return Float((value * factor).roundToInt() / factor)
    }

    private func removeDoubleSlop(_ value: Double) -> Double {
        let factor = 100000.0
        return (value * factor).roundToInt() / factor
    }

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
