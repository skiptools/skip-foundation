# SkipFoundation

Foundation support for [Skip](https://skip.tools) apps.

## About 

SkipFoundation vends the `skip.foundation` Kotlin package. It is a reimplementation of Foundation for Kotlin on Android. Its goal is to mirror as much of Foundation as possible, allowing Skip developers to use Foundation API with confidence.

## Dependencies

SkipFoundation depends on the [skip](https://source.skip.tools/skip) transpiler plugin as well as the [SkipLib](https://github.com/skiptools/SkipLib) library.

SkipFoundation is part of the core Skip stack and is not intended to be imported directly.
The module is transparently adopted through the translation of `import Foundation` into `import skip.foundation.*` by the Skip transpiler.

## Status

SkipFoundation supports many of the Foundation framework's most common APIs, but there are many more that are not yet ported. The best way to monitor SkipFoundation's status is through its comprehensive set of [Tests](#tests). A skipped test generally means the API has not been implemented.

When you want to use a Foundation API that has not been implemented, you have options. You can try to find a workaround using only supported API, embed Kotlin code directly as described in the [Skip docs](https://skip.tools/docs), or [add support to SkipFoundation](#contributing). If you choose to enhance SkipFoundation itself, please consider [contributing](#contributing) your code back for inclusion in the official release.

## Contributing

We welcome contributions to SkipFoundation. The Skip product documentation includes helpful instructions on [local Skip library development](https://skip.tools/docs/#local-libraries). 

The most pressing need is to implement more of the most-used Foundation APIs.
To help fill in unimplemented API in SkipFoundation:

1. Find unimplemented API. Unimplemented API will generally be commented out or have TODO comments in the source. The set of skipped [Tests](#tests) also gives a high-level view of what is not yet ported to Skip.
1. Write an appropriate Compose implementation. See [Implementation Strategy](#implementation-strategy) below.
1. Edit the corresponding tests to make sure they are no longer skipped, and that they pass. If there aren't existing tests, write some. See [Tests](#tests).
1. [Submit a PR.](https://github.com/skiptools/skip-foundation/pulls)

Other forms of contributions such as test cases, comments, and documentation are also welcome!

## Implementation Strategy

The goal of SkipFoundation is to mirror the Foundation framework for Android. iOS developers will never use SkipFoundation directly, because they already have access to Foundation. Nevertheless, SkipFoundation's API ports include both an Android implementation **and** an iOS implementation

## Tests

Documentation in progress

