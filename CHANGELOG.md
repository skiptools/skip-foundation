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

  - Add ProcessInfo envrionment properties for android.os.Build.VERSION fields like SDK_INT

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

