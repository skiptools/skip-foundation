## 1.1.11

Released 2024-10-15

  - Merge pull request #25 from shial4/feat/date-components-missing-logic
  - disable assertion
  - revert
  - address PR feedback
  - .
  - refactor date components
  - another set of fixes
  - Add missing max
  - fix ranges
  - fix test
  - Add missing functionality
  - implement handling of date field differences for date components

## 1.1.10

Released 2024-10-15


## 1.1.9

Released 2024-10-15

  - Make mainInfoDictionary a lazy variable to prevent over-eager initialization

## 1.1.8

Released 2024-10-15

  - Merge pull request #27 from skiptools/main-info-dictionary
  - And synthesized Bundle.main.infoDictionary with application metadata
  - Merge pull request #26 from skiptools/localized-string-fix
  - Fix NSLocalizedString to not attempt to re-localize an already localized bundle parameter
  - Fix NSLocalizedString to not attempt to re-localize an already localized bundle parameter
  - Fix NSLocalizedString to not attempt to re-localize an already localized bundle parameter
  - Fix NSLocalizedString to not attempt to re-localize an already localized bundle parameter
  - Fix NSLocalizedString to use the current locale

## 1.1.6

Released 2024-10-04

  - Merge pull request #23 from skiptools/calendar-timezone-handling
  - Calendar.dateComponents was not zeroing unset components fields
  - Merge pull request #22 from skiptools/update-test-cases-swift6
  - Update Foundation test cases on Darwin for Swift 6 swift-foundation differences

## 1.1.3

Released 2024-09-06

  - Merge pull request #18 from tyiu/currency
  - Fix broken tests and address code review feedback
  - Add support for Currency

## 1.0.0

Released 2024-08-15


## 0.7.1

Released 2024-08-01

  - Fix for https://github.com/skiptools/skip/issues/182 where we were wrapping/rolling dates rather than incrementing higher values
  - Fix typo in Package.swift syntax
  - Test null in JSON decoding
  - Disable test_timerRepeats due to intermittent CI failure

## 0.7.0

Released 2024-07-03


## 0.6.11

Released 2024-05-27

  - Add region

## 0.6.10

Released 2024-05-26

  - Add Locale.Currency, Locale.Language, Locale.Region, Locale.Variant, and Locale.Script
  - Update API support table colors

## 0.6.9

Released 2024-05-13

  - Make resourcesIndex public so external frameworks can query the indexed resources list

## 0.5.13

Released 2024-03-24

  - Add androidx.test.core and androidx.test.rules to test dependencies; make Data.withUnsafeMutableBytes internal so it can be implemented by SkipFFI

## 0.5.10

Released 2024-02-25

  - Check for appContext.getApplicationInfo().className being null during test cases

## 0.5.9

Released 2024-02-25

  - Map unspecified "zh" language to "zh-Hans" for bundle localization
  - Make Digest work as a Sequence of Bytes
  - Add stubs and API docs for URLSession
  - Fix test
  - Additional stubs and API documentation
  - Additional stubs and API documentation
  - Tweaks for ISO8601DateFormatter
  - Update README
  - Support more IndexPath functionality

## 0.5.7

Released 2024-02-20

  - Support Data.withUnsafeBytes when SkipFFI is imported
  - Accommodate differences in String.Encoding.utf16 and .utf32 between Java and Darwin

## 0.5.6

Released 2024-02-18


## 0.5.4

Released 2024-02-15

  - Merge pull request #9 from iankoex/URLSession-upload
  - added implementation for URLSession.upload
  - Fill in some missing Date-related API. Make Calendar, DateComponents, TimeZone Codable
  - docs: update README table

## 0.5.2

Released 2024-02-10

  - Fix declaration of UserDefaults.object()

## 0.5.1

Released 2024-02-10

  - Remove calls to UserDefaults.object()
  - Rename object calls to obj
  - Fix Int64 for URLTests.testAsyncBytes
  - Retry URLSession.shared.bytes test case to handle intermittent network failures

## 0.5.0

Released 2024-02-05


## 0.4.3

Released 2024-01-23

  - URLSession httpBody to be sent after requests (fixes https://github.com/skiptools/skip-foundation/issues/7)

## 0.4.2

Released 2024-01-22

  - Implement httpBody (fixes https://github.com/skiptools/skip-foundation/issues/7)
  - Update README.md
  - Fix or disable tests failing on Android emulator

## 0.4.1

Released 2024-01-12

  - Update Locale API tests
  - Update Locale API tests
  - Update Locale API tests
  - Update Locale API tests
  - Update Locale API tests
  - Add more Locale API

## 0.3.15

Released 2024-01-07

  - Update localization tests
  - Handle failure to load localized resources for packages that have no resources.lst index

## 0.3.14

Released 2024-01-06

  - Have bundle mark when to resources index has been loaded to handle bundles without resources

## 0.3.11

Released 2023-12-20

  - Enable Bundle.url for directory arguments by consulting the embedded resources.lst index

## 0.3.10

Released 2023-12-12

  - Make NSLocalizedString value parameter default to nil

## 0.3.9

Released 2023-12-11

  - Add string format localization support; add changelog; move regexp tests to skip-lib

## 0.3.6

Released 2023-11-22

  - Typealias IndexSet to skip.lib.IntSet

## 0.3.4

Released 2023-11-19

  - Add Logger functions and OSLogType

## 0.3.3

Released 2023-11-18

  - Add public URL.platformURL to return the java.net.URL
  - Workaround DST failure

## 0.3.2

Released 2023-11-02

  - Add various FileManager and Date API
  - Add FileManager.url(for:) access for FileManager.SearchPathDirectory.documentDirectory and .cachesDirectory to Android Context getFilesDir() and getCachesDir()

## 0.3.1

Released 2023-11-01

  - Move Random support code to SkipLib
  - Make Bundle.module local-only, relying on transpiler to generate for each module
  - Remove Bundle.module in favor of transpiler-generated solution
  - Re-enable Bundle resource tests
  - Remove test table from README
  - Add section on Codable restrictions
  - Update README
  - Update README

## 0.2.17

Released 2023-10-21

  - Support encoding/decoding arrays-of-arrays and dictionaries-of-arrays. Fix decoding bugs in UUID and Date
  - JSON encode/decode work
  - Get JSONSerializer working Remove duplication of official API comments
  - Update README

## 0.2.15

Released 2023-10-10

  - Add more unavailable attributes

## 0.2.13

Released 2023-10-06

  - Export dependencies in build.gradle.kts as api

## 0.2.12

Released 2023-10-05

  - Add testImplementation dependency on org.json:json to avoid JSON tests needing a Robolectric/Android environment set up

## 0.2.8

Released 2023-10-02

  - Remove math functions sin/cos/abs/etc since they exist in SkipLib and result in oberload ambiguity errors

## 0.2.7

Released 2023-10-01

  - Clarify usage of time separator as NARROW NO-BREAK SPACE

## 0.2.6

Released 2023-09-29

  - Update tests to handle changes in macOS 14 Sonoma; fix some test warnings
  - Begin to flesh out README

## 0.2.5

Released 2023-09-27

  - Add ProcessInfo environment properties for android.os.Build.VERSION fields like SDK_INT

## 0.2.3

Released 2023-09-26

  - Add registerOnSharedPreferenceChangeListener to listen for defaults changes

## 0.2.2

Released 2023-09-26

  - Add UserDefaults registration support and handle Data, Date, and URL
  - Disable negative emoji test for Android emulator due to different behavior
  - Disable more tests to work around errors RESOURCE_EXHAUSTED: gRPC message exceeds maximum size
  - Transfer some android.os.Build properties into ProcessInfo.processInfo.environment
  - Fix tearDown function to not throw XCTSkip and break the rest of the tests

## 0.2.1

Released 2023-09-18

  - Use new .__ import syntax

## 0.1.21

Released 2023-09-11

  - Reduce test count to enable Android emulator tests to complete
  - Remove NS bridging tests

## 0.1.19

Released 2023-09-09

  - Update Android emulator checks
  - Android emulator checks
  - Disable some tests for emulators lack of android.permission.INTERNET

## 0.1.17

Released 2023-09-08

  - Remove vestigial Kt file

## 0.1.15

Released 2023-09-07

  - Call and cache NSUserName/NSHomeDirectory/NSTemporaryDirectory only once
  - Handle String.Encoding via typealias

## 0.1.1

Released 2023-09-03

  - Improvements to String API support

## 0.0.14

Released 2023-08-24

  - Fix test availability

## 0.0.13

Released 2023-08-23

  - Add URL.appendingPathExtension
  - Fix incorrect README description

## 0.0.12

Released 2023-08-21

  - Update dependencies

## 0.0.11

Released 2023-08-20

  - first commit

