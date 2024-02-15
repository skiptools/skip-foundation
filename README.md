# SkipFoundation

Foundation support for [Skip](https://skip.tools) apps.

See what API is currently implemented [here](#foundation-support).

## About 

SkipFoundation vends the `skip.foundation` Kotlin package. It is a reimplementation of Foundation for Kotlin on Android. Its goal is to mirror as much of Foundation as possible, allowing Skip developers to use Foundation API with confidence.

## Dependencies

SkipFoundation depends on the [skip](https://source.skip.tools/skip) transpiler plugin as well as the [SkipLib](https://github.com/skiptools/skip-lib) package.

SkipFoundation is part of the core *SkipStack* and is not intended to be imported directly.
The module is transparently adopted through the translation of `import Foundation` into `import skip.foundation.*` by the Skip transpiler.

## Status

SkipFoundation supports many of the Foundation framework's most common APIs, but there are many more that are not yet ported. See [Foundation Support](#foundation-support).

When you want to use a Foundation API that has not been implemented, you have options. You can try to find a workaround using only supported API, embed Kotlin code directly as described in the [Skip docs](https://skip.tools/docs), or [add support to SkipFoundation](#contributing). If you choose to enhance SkipFoundation itself, please consider [contributing](#contributing) your code back for inclusion in the official release.

## Contributing

We welcome contributions to SkipFoundation. The Skip product [documentation](https://skip.tools/docs/contributing/) includes helpful instructions and tips on local Skip library development. 

The most pressing need is to implement more of the most-used Foundation APIs.
To help fill in unimplemented API in SkipFoundation:

1. Find unimplemented API.
1. Write an appropriate Kotlin implementation. See [Implementation Strategy](#implementation-strategy) below.
1. Edit the corresponding tests to make sure they are no longer skipped, and that they pass. If there aren't existing tests, write some. See [Tests](#tests).
1. [Submit a PR.](https://github.com/skiptools/skip-foundation/pulls)

Other forms of contributions such as test cases, comments, and documentation are also welcome!

## Implementation Strategy

The goal of SkipFoundation is to mirror the Foundation framework for Android. When possible, `SkipFoundation` types wrap corresponding Kotlin or Java foundation types. When a `SkipFoundation` type wraps a corresponding Kotlin or Java type, please conform to the `skip.lib.KotlinConverting<T>` protocol, which means adding a `.kotlin()` function:

```swift
#if SKIP
extension Calendar: KotlinConverting<java.util.Calendar> {
    public override func kotlin(nocopy: Bool = false) -> java.util.Calendar {
        return nocopy ? platformValue : platformValue.clone() as java.util.Calendar
    }
}
#endif
```

You should also implement a constructor that accepts the equivalent Kotlin or Java object.

## Tests

SkipFoundation's `Tests/` folder contains the entire set of official Foundation framework test cases. Through the magic of [SkipUnit](https://github.com/skiptools/skip-unit), this allows us to validate our SkipFoundation API implementations on Android against the same test suite used by the Foundation team on iOS.

It is SkipFoundation's goal to include - and pass - as much of the official test suite as possible.

## Foundation Support

The following table summarizes SkipFoundation's Foundation API support on Android. Anything not listed here is likely not supported. Note that in your iOS-only code - i.e. code within `#if !SKIP` blocks - you can use any Foundation API you want.

Support levels:

  - ✅ – Full
  - 🟢 – High
  - 🟡 – Medium 
  - 🔴 – Low

<table>
  <thead><th>Support</th><th>API</th></thead>
  <tbody>
    <tr>
      <td>🟡</td>
      <td>
        <details>
          <summary><code>Bundle</code></summary>
          <ul>
<li><code>static var main: Bundle</code></li>
<li><code>static var module: Bundle</code></li>
<li><code>init?(path: String)</code></li>
<li><code>init?(url: URL)</code></li>
<li><code>init(for forClass: AnyClass)</code></li>
<li><code>init()</code></li>
<li><code>var bundleURL: URL</code></li>
<li><code>var resourceURL: URL?</code></li>
<li><code>var bundlePath: String</code></li>
<li><code>var resourcePath: String?</code></li>
<li><code>func url(forResource: String? = nil, withExtension: String? = nil, subdirectory: String? = nil, localization: String? = nil) -> URL?</code></li>
<li><code>func path(forResource: String? = nil, ofType: String? = nil, inDirectory: String? = nil, forLocalization: String? = nil) -> String?</code></li>
<li><code>var developmentLocalization: String</code></li>
<li><code>var localizations: [String]</code></li>
<li><code>func localizedString(forKey key: String, value: String?, table tableName: String?) -> String</code></li>
<li><code>var localizations: [String]</code></li>
          </ul>
        </details> 
      </td>
    </tr>
   <tr>
      <td>🟡</td>
      <td>
        <details>
          <summary><code>Calendar</code></summary>
          <ul>
            <li>Only <code>.gregorian</code> and <code>.iso8601</code> identifiers are supported</li>           
<li><code>init(identifier: Calendar.Identifier)</code></li>
<li><code>static var current: Calendar</code></li>
<li><code>var locale: Locale</code></li>
<li><code>var timeZone: TimeZone</code></li>
<li><code>var identifier: Calendar.Identifier</code></li>
<li><code>var eraSymbols: [String]</code></li>
<li><code>var monthSymbols: [String]</code></li>
<li><code>var shortMonthSymbols: [String]</code></li>
<li><code>var weekdaySymbols: [String]</code></li>
<li><code>var shortWeekdaySymbols: [String]</code></li>
<li><code>var amSymbol: String</code></li>
<li><code>var pmSymbol: String</code></li>
<li><code>func date(from components: DateComponents) -> Date?</code></li>
<li><code>func dateComponents(in zone: TimeZone? = nil, from date: Date) -> DateComponents</code></li>
<li><code>func dateComponents(_ components: Set&lt;Calendar.Component>, from start: Date, to end: Date) -> DateComponents</code></li>
<li><code>func dateComponents(_ components: Set&lt;Calendar.Component>, from date: Date) -> DateComponents</code></li>
<li><code>func date(byAdding components: DateComponents, to date: Date, wrappingComponents: Bool = false) -> Date?</code></li>
<li><code>func date(byAdding component: Calendar.Component, value: Int, to date: Date, wrappingComponents: Bool = false) -> Date?</code></li>
<li><code>func isDateInWeekend(_ date: Date) -> Bool</code></li>
          </ul>
        </details> 
      </td>
    </tr>
   <tr>
      <td>🔴</td>
      <td>
        <details>
          <summary><code>CharacterSet</code></summary>
          <ul>
            <li>Vended character sets are not complete</li>
<li><code>static var whitespaces: CharacterSet</code></li>
<li><code>static var whitespacesAndNewlines: CharacterSet</code></li>
<li><code>static var newlines: CharacterSet</code></li>
<li><code>init()</code></li>
<li><code>func insert(_ character: Unicode.Scalar) -> (inserted: Bool, memberAfterInsert: Unicode.Scalar)</code></li>
<li><code>func update(with character: Unicode.Scalar) -> Unicode.Scalar?</code></li>
<li><code>func remove(_ character: Unicode.Scalar) -> Unicode.Scalar?</code></li>
<li><code>func contains(_ member: Unicode.Scalar) -> Bool</code></li>
<li><code>func union(_ other: CharacterSet) -> CharacterSet</code></li>
<li><code>mutating func formUnion(_ other: CharacterSet)</code></li>
<li><code>func intersection(_ other: CharacterSet) -> CharacterSet</code></li>
<li><code>mutating func formIntersection(_ other: CharacterSet)</code></li>
<li><code>func subtracting(_ other: CharacterSet)</code></li>
<li><code>mutating func subtract(_ other: CharacterSet)</code></li>
<li><code>func symmetricDifference(_ other: CharacterSet) -> CharacterSet</code></li>
<li><code>mutating func formSymmetricDifference(_ other: CharacterSet)</code></li>
<li><code>func isSuperset(of other: CharacterSet) -> Bool</code></li>
<li><code>func isSubset(of other: CharacterSet) -> Bool</code></li>
<li><code>func isDisjoint(with other: CharacterSet) -> Bool</code></li>
<li><code>func isStrictSubset(of other: CharacterSet) -> Bool</code></li>
<li><code>func isStrictSuperset(of other: CharacterSet) -> Bool</code></li>
<li><code>var isEmpty: Bool</code></li>
          </ul>
        </details> 
      </td>
    </tr>
    <tr>
      <td>✅</td>
      <td><code>ComparisonResult</code></td>
    </tr>
   <tr>
      <td>🟡</td>
      <td>
        <details>
          <summary><code>Data</code></summary>
          <ul>
<li><code>Data</code> does <strong>not</strong> conform to <code>Collection</code> protocols</li>
<li><code>init()</code></li>
<li><code>init(count: Int)</code></li>
<li><code>init(capacity: Int)</code></li>
<li><code>init(_ data: Data)</code></li>
<li><code>init(_ bytes: [UInt8], length: Int? = nil)</code></li>
<li><code>init(_ checksum: Digest)</code></li>
<li><code>init?(base64Encoded: String, options: Data.Base64DecodingOptions = [])</code></li>
<li><code>init(contentsOfFile filePath: String) throws</code></li>
<li><code>init(contentsOf url: URL, options: Data.ReadingOptions = [])</code></li>
<li><code>var count: Int</code></li>
<li><code>var isEmpty: Bool</code></li>
<li><code>var bytes: [UInt8]</code></li>
<li><code>var utf8String: String?</code></li>
<li><code>func base64EncodedString() -> String</code></li>
<li><code>func sha256() -> Data</code></li>
<li><code>func hex() -> String</code></li>
<li><code>mutating func reserveCapacity(_ minimumCapacity: Int)</code></li>
<li><code>mutating func append(_ other: Data)</code></li>
<li><code>mutating func append(contentsOf bytes: [UInt8])</code></li>
<li><code>mutating func append(contentsOf data: Data)</code></li>
<li><code>subscript(index: Int) -> UInt8</code></li>
<li><code>func write(to url: URL, options: Data.WritingOptions = []) throws</code></li>
          </ul>
        </details> 
      </td>
    </tr>
   <tr>
      <td>🟡</td>
      <td>
        <details>
          <summary><code>Date</code></summary>
          <ul>
<li>Formatting functions not supported with the exception of:</li>
<li><code>func ISO8601Format(_ style: Date.ISO8601FormatStyle = .iso8601) -> String</code></li>
          </ul>
        </details> 
      </td>
    </tr>
   <tr>
      <td>🟢</td>
      <td>
        <details>
          <summary><code>DateComponents</code></summary>
          <ul>
            <li><code>nanosecond</code>, <code>weekdayOrdinal</code>, <code>quarter</code>, <code>yearForWeekOfYear</code> are not supported</li>
          </ul>
        </details> 
      </td>
    </tr>
<tr>
  <td>?</td>
  <td><code>DateFormatter // Not yet documented</code></td>
</tr>
<tr>
  <td>?</td>
  <td><code>DateInterval // Not yet documented</code></td>
</tr>
<tr>
  <td>?</td>
  <td><code>DateIntervalFormatter // Not yet documented</code></td>
</tr>
<tr>
  <td>?</td>
  <td><code>Digest // Not yet documented</code></td>
</tr>
<tr>
  <td>?</td>
  <td><code>Dispatch // Not yet documented</code></td>
</tr>
<tr>
  <td>?</td>
  <td><code>FileManager // Not yet documented</code></td>
</tr>
<tr>
  <td>?</td>
  <td><code>HTTPURLResponse // Not yet documented</code></td>
</tr>
<tr>
  <td>?</td>
  <td><code>IndexPath // Not yet documented</code></td>
</tr>
<tr>
  <td>?</td>
  <td><code>IndexSet // Not yet documented</code></td>
</tr>
<tr>
  <td>?</td>
  <td><code>ISO8601DateFormatter // Not yet documented</code></td>
</tr>
<tr>
  <td>?</td>
  <td><code>JSONDecoder // Not yet documented</code></td>
</tr>
<tr>
  <td>?</td>
  <td><code>JSONEncoder // Not yet documented</code></td>
</tr>
<tr>
  <td>?</td>
  <td><code>JSONSerialization // Not yet documented</code></td>
</tr>
<tr>
  <td>?</td>
  <td><code>Locale // Not yet documented</code></td>
</tr>
<tr>
  <td>?</td>
  <td><code>LocalizedStringResource // Not yet documented</code></td>
</tr>
<tr>
  <td>?</td>
  <td><code>Logger // Not yet documented</code></td>
</tr>
<tr>
  <td>?</td>
  <td><code>NotificationCenter // Not yet documented</code></td>
</tr>
<tr>
  <td>?</td>
  <td><code>NSError // Not yet documented</code></td>
</tr>
    <tr>
      <td>✅</td>
      <td><code>NSLocalizedString</code></td>
    </tr>
<tr>
  <td>?</td>
  <td><code>Number // Not yet documented</code></td>
</tr>
<tr>
  <td>?</td>
  <td><code>NumberFormatter // Not yet documented</code></td>
</tr>
<tr>
  <td>?</td>
  <td><code>OperationQueue // Not yet documented</code></td>
</tr>
<tr>
  <td>?</td>
  <td><code>ProcessInfo // Not yet documented</code></td>
</tr>
<tr>
  <td>?</td>
  <td><code>PropertyListSerialization // Not yet documented</code></td>
</tr>
<tr>
  <td>?</td>
  <td><code>Scanner // Not yet documented</code></td>
</tr>
<tr>
  <td>?</td>
  <td><code>String // Not yet documented</code></td>
</tr>
<tr>
  <td>?</td>
  <td><code>StringEncoding // Not yet documented</code></td>
</tr>
<tr>
  <td>?</td>
  <td><code>StringLocalizationValue // Not yet documented</code></td>
</tr>
<tr>
  <td>?</td>
  <td><code>TimeZone // Not yet documented</code></td>
</tr>
<tr>
  <td>?</td>
  <td><code>Unicode // Not yet documented</code></td>
</tr>
<tr>
  <td>?</td>
  <td><code>URL // Not yet documented</code></td>
</tr>
<tr>
  <td>?</td>
  <td><code>URLRequest // Not yet documented</code></td>
</tr>
<tr>
  <td>?</td>
  <td><code>URLResponse // Not yet documented</code></td>
</tr>
<tr>
  <td>?</td>
  <td><code>URLSession // Not yet documented</code></td>
</tr>
<tr>
  <td>?</td>
  <td><code>URLSessionConfiguration // Not yet documented</code></td>
</tr>
<tr>
  <td>?</td>
  <td><code>UserDefaults // Not yet documented</code></td>
</tr>
<tr>
  <td>?</td>
  <td><code>UUID // Not yet documented</code></td>
</tr>
<tr>
  <td>?</td>
  <td><code>XMLParser // Not yet documented</code></td>
</tr>
  </tbody>
</table>

## Topics

### Files

Skip implements much of `Foundation.FileManager`, which should be
the primary interface for interacting with the file system.

The app-specific folder can be accessed like:

```swift
// on Android, this is Context.getFilesDir()
let folder = try FileManager.default.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false)
```

And to read and write to the cache folders:

```swift
// on Android, this is Context.getCachesDir()
let caches = try FileManager.default.url(for: FileManager.SearchPathDirectory.cachesDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false)
```

And the system temporary folder can be accessed with:

```swift
let tmpdir = NSTemporaryDirectory()
```

None of the other `FileManager.SearchPathDirectory` enumerations are implemented in Skip.

Both `Data` and `String` have the ability to read and write to and from URLs and path strings.

