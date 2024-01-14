# SkipFoundation

Foundation support for [Skip](https://skip.tools) apps.

## About 

SkipFoundation vends the `skip.foundation` Kotlin package. It is a reimplementation of Foundation for Kotlin on Android. Its goal is to mirror as much of Foundation as possible, allowing Skip developers to use Foundation API with confidence.

## Dependencies

SkipFoundation depends on the [skip](https://source.skip.tools/skip) transpiler plugin as well as the [SkipLib](https://github.com/skiptools/skip-lib) package.

SkipFoundation is part of the core *SkipStack* and is not intended to be imported directly.
The module is transparently adopted through the translation of `import Foundation` into `import skip.foundation.*` by the Skip transpiler.

## Status

SkipFoundation supports many of the Foundation framework's most common APIs, but there are many more that are not yet ported. The best way to monitor SkipFoundation's status is through its comprehensive set of [Tests](#tests). A skipped test generally means the API has not been implemented.

When you want to use a Foundation API that has not been implemented, you have options. You can try to find a workaround using only supported API, embed Kotlin code directly as described in the [Skip docs](https://skip.tools/docs), or [add support to SkipFoundation](#contributing). If you choose to enhance SkipFoundation itself, please consider [contributing](#contributing) your code back for inclusion in the official release.

## Contributing

We welcome contributions to SkipFoundation. The Skip product [documentation](https://skip.tools/docs/contributing/) includes helpful instructions and tips on local Skip library development. 

The most pressing need is to implement more of the most-used Foundation APIs.
To help fill in unimplemented API in SkipFoundation:

1. Find unimplemented API. Unimplemented API will generally be commented out or have TODO comments in the source. The set of skipped [tests](#tests) also gives a high-level view of what is not yet ported to Skip.
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


### Codable

Swift uses the `Encodable` and `Decodable` protocols to convert objects to and from various data formats. In keeping with its philosophy of *transparent adoption*, Skip supports `Encodable`, `Decodable`, and the combined `Codable` protocols for object serialization and deserialization. This includes automatic synthesis of default encoding and decoding as well as support for custom encoding and decoding using Swift's `Encodable` and `Decodable` APIs. Skip does, however, have some restrictions:

- JSON is currently the only supported format. SkipFoundation includes Foundation's `JSONEncoder` and `JSONDecoder` classes.
- Not all JSON formatting options are supported.
- `Array`, `Set`, and `Dictionary` are fully supported, but nesting of these types is limited. So for example Skip can encode and decode `Array<MyCodableType>` and `Dictionary<String, MyCodableType>`, but not `Array<Dictionary<String, MyCodableType>>`. Two forms of container nesting **are** currently supported: arrays-of-arrays - e.g. `Array<Array<MyCodableType>>` - and dictionaries-of-array-values - e.g. `Dictionary<String, Array<MyCodableType>>`. In practice, other nesting patters are rare.
- When implementing your own `init(from: Decoder)` decoding, your `decode` calls must supply a concrete type literal to decode. The following will work:

    ```swift
    init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)
        self.array = try container.decode([Int].self, forKey: CodingKeys.array) 
    }
    ```

    But these examples will not work:

    ```swift
    init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)
        let arrayType = [Int].self
        self.array = try container.decode(arrayType, forKey: CodingKeys.array) 
    }

    init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)
        // T is a generic type of this class
        self.array = try container.decode([T].self, forKey: CodingKeys.array) 
    }
    ```

- As in the examples above, you must fully qualify your `CodingKeys` cases when calling `decode(_:forKey:)`.

## Tests

SkipFoundation's `Tests/` folder contains the entire set of official Foundation framework test cases. Through the magic of [SkipUnit](https://github.com/skiptools/skip-unit), this allows us to validate our SkipFoundation API implementations on Android against the same test suite used by the Foundation team on iOS.

It is SkipFoundation's goal to include - and pass - as much of the official test suite as possible.


