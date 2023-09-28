# SkipFoundation

Foundation support for [Skip](https://skip.tools) apps.

## About 

SkipFoundation vends the `skip.foundation` Kotlin package. It is a reimplementation of Foundation for Kotlin on Android. Its goal is to mirror as much of Foundation as possible, allowing Skip developers to use Foundation API with confidence.

## Dependencies

SkipFoundation depends on the [skip](https://source.skip.tools/skip) transpiler plugin as well as the [SkipLib](https://github.com/skiptools/skip-lib) library.

SkipFoundation is part of the core Skip stack and is not intended to be imported directly.
The module is transparently adopted through the translation of `import Foundation` into `import skip.foundation.*` by the Skip transpiler.

## Status

SkipFoundation supports many of the Foundation framework's most common APIs, but there are many more that are not yet ported. The best way to monitor SkipFoundation's status is through its comprehensive set of [Tests](#tests). A skipped test generally means the API has not been implemented.

When you want to use a Foundation API that has not been implemented, you have options. You can try to find a workaround using only supported API, embed Kotlin code directly as described in the [Skip docs](https://skip.tools/docs), or [add support to SkipFoundation](#contributing). If you choose to enhance SkipFoundation itself, please consider [contributing](#contributing) your code back for inclusion in the official release.

## Contributing

We welcome contributions to SkipFoundation. The Skip product documentation includes helpful instructions on [local Skip library development](https://skip.tools/docs/#local-libraries). 

The most pressing need is to implement more of the most-used Foundation APIs.
To help fill in unimplemented API in SkipFoundation:

1. Find unimplemented API. Unimplemented API will generally be commented out or have TODO comments in the source. The set of skipped [tests](#tests) also gives a high-level view of what is not yet ported to Skip.
1. Write an appropriate Compose implementation. See [Implementation Strategy](#implementation-strategy) below.
1. Edit the corresponding tests to make sure they are no longer skipped, and that they pass. If there aren't existing tests, write some. See [Tests](#tests).
1. [Submit a PR.](https://github.com/skiptools/skip-foundation/pulls)

Other forms of contributions such as test cases, comments, and documentation are also welcome!

## Implementation Strategy

The goal of SkipFoundation is to mirror the Foundation framework for Android. iOS developers will never use SkipFoundation directly, because they already have access to Foundation. Nevertheless, SkipFoundation's API ports include both an Android branch **and** an iOS branch. SkipFoundation is structured more like a library that is providing new functionality to both platforms than as a Skip library designed to replicate existing iOS functionality on Android.

Why is SkipFoundation structured this way? Two reasons:

1. SkipFoundation can serve as an example to developers who want to create new dual-platform Skip libraries. The patterns used here are the same patterns you employ to vend a library that Skip developers can use within their iOS code, but will also function in their transpiled Android apps.
1. Although the iOS code branches will never be used in an iOS app, they are exercised by SkipFoundation's comprehensive [tests](#tests). The experience of writing the iOS implementation first and verifying that it passes the test suite helps us design and validate the Android implementation.

SkipFoundation uses `#if SKIP` compiler directives extensively to inline the use of Kotlin and Java API. See the [Skip documentation](https://skip.tools/docs) for more information on Android customization.

### Example

Many Foundation types have very close analogs from Kotlin or Java. A SkipFoundation implementation, therefore, often looks like something like `Calendar`:

```swift
#if !SKIP
@_implementationOnly import struct Foundation.Calendar
internal typealias PlatformCalendar = Foundation.Calendar
#else
public typealias PlatformCalendar = java.util.Calendar
#endif

public struct Calendar : Hashable, CustomStringConvertible {
    internal var platformValue: PlatformCalendar
    #if SKIP
    public var locale: Locale
    #endif

    public static var current: Calendar {
        #if !SKIP
        return Calendar(platformValue: PlatformCalendar.current)
        #else
        return Calendar(platformValue: PlatformCalendar.getInstance())
        #endif
    }

    internal init(platformValue: PlatformCalendar) {
        self.platformValue = platformValue
        #if SKIP
        self.locale = Locale.current
        #endif
    }

    ...

    public var amSymbol: String {
        #if !SKIP
        return platformValue.amSymbol
        #else
        return dateFormatSymbols.getAmPmStrings()[0]
        #endif
    }

    ...
}
```

When a Foundation type wraps a corresponding Kotlin or Java type, please provide Skip's standard `.kotlin()` and `.swift()` functions for converting between the two:

```swift
#if SKIP
extension Calendar {
    public func kotlin(nocopy: Bool = false) -> java.util.Calendar {
        return nocopy ? platformValue : platformValue.clone() as java.util.Calendar
    }
}

extension java.util.Calendar {
    public func swift(nocopy: Bool = false) -> Calendar {
        let platformValue = nocopy ? self : clone() as java.util.Calendar
        return Calendar(platformValue: platformValue)
    }
}
#endif
```

## Tests

SkipFoundation's `Tests/` folder contains the entire set of official Foundation framework test cases. Through the magic of [SkipUnit](https://github.com/skiptools/skip-unit), this allows us to validate our SkipFoundation API implementations on Android against the same test suite used by the Foundation team on iOS.

The table below details the current test run status. Many tests are skipped, which typically means that the corresponding API has not yet been ported to Skip. It is SkipFoundation's goal to include - and pass - as much of the official test suite as possible.

Documentation in progress

