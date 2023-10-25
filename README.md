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

## Topics

### Codable

Swift uses the `Encodable` and `Decodable` protocols to convert objects to and from various data formats. In keeping with its philosophy of *transparent adoption*, Skip supports `Encodable`, `Decodable`, and the combined `Codable` protocols for object serialization and deserialization. This includes automatic synthesis of default encoding and decoding as well as support for custom encoding and decoding using Swift's `Encodable` and `Decodable` APIs. Skip does, however, have some restrictions:

- JSON is currently the only supported format. SkipFoundation includes Foundation's `JSONEncoder` and `JSONDecoder` classes.
- Not all JSON formatting options are supported.
- `Array`, `Set`, and `Dictionary` **are** supported, but nesting of these types is limited to arrays-of-arrays and dictionaries-of-array-values. Skip does not yet support e.g. an array of dictionaries, or a dictionary with array keys.
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

The table below details the current test run status. Many tests are skipped, which typically means that the corresponding API has not yet been ported to Skip. Other tests show `????`. This is generally equivalent to `SKIP`, but indicates that we've commented out the test altogether to avoid overwhelming GitHub's action output buffer.

It is SkipFoundation's goal to include - and pass - as much of the official test suite as possible.

| Test                      | Case                      | Swift | Kotlin |
| ------------------------- | ------------------------- | ----- | ------ |
| BundleTests               | testBundle                | PASS  | PASS   |
| BundleTests               | testBundleInfo            | PASS  | PASS   |
| DataTests                 | testData                  | PASS  | PASS   |
| DateTests                 | testAbsoluteTimeGetCurren | PASS  | PASS   |
| DateTests                 | testArabicCalendarSymbols | PASS  | PASS   |
| DateTests                 | testChineseCalendarSymbol | PASS  | PASS   |
| DateTests                 | testDateComponentsLeapYea | PASS  | SKIP   |
| DateTests                 | testDateTime              | PASS  | PASS   |
| DateTests                 | testFrenchCalendarSymbols | PASS  | PASS   |
| DateTests                 | testISOFormatting         | PASS  | PASS   |
| DateTests                 | testJapaneseCalendarSymbo | PASS  | PASS   |
| DateTests                 | testMultipleConstructorsS | PASS  | PASS   |
| DateTests                 | testThaiCalendarSymbols   | PASS  | PASS   |
| DateTests                 | testUSCalendarSymbols     | PASS  | PASS   |
| DigestTests               | testDigestHashMD5         | PASS  | PASS   |
| DigestTests               | testDigestHashSHA1        | PASS  | PASS   |
| DigestTests               | testDigestHashSHA256      | PASS  | PASS   |
| DigestTests               | testDigestHashSHA384      | PASS  | PASS   |
| DigestTests               | testDigestHashSHA512      | PASS  | PASS   |
| DigestTests               | testHMACSignSHA256        | PASS  | SKIP   |
| DigestTests               | testHMACSigning           | PASS  | PASS   |
| DigestTests               | testSHA256                | PASS  | PASS   |
| FileManagerTests          | testFileManager           | PASS  | PASS   |
| LocaleTests               | testLanguageCodes         | PASS  | PASS   |
| LocaleTests               | testManualStringLocalizat | PASS  | PASS   |
| LoggerTests               | testLogDebug              | PASS  | PASS   |
| LoggerTests               | testLogError              | PASS  | PASS   |
| LoggerTests               | testLogInfo               | PASS  | PASS   |
| LoggerTests               | testLogWarning            | PASS  | PASS   |
| RandomTests               | testGenerateBools         | PASS  | PASS   |
| RandomTests               | testGenerateInts          | PASS  | PASS   |
| RandomTests               | testGenerateLongs         | PASS  | PASS   |
| RandomTests               | testGenerateUUIDs         | PASS  | PASS   |
| RandomTests               | testSystemRandomNumberGen | PASS  | PASS   |
| RegexTests                | testCharacterClassesRegex | PASS  | PASS   |
| RegexTests                | testEmailValidationRegex  | PASS  | PASS   |
| RegexTests                | testErrorRegex            | PASS  | PASS   |
| RegexTests                | testHashValidationRegex   | PASS  | PASS   |
| RegexTests                | testRegularExpresionParit | PASS  | PASS   |
| RegexTests                | testWordsWithMultipleSuff | PASS  | PASS   |
| RegexTests                | testXMLTagRegex           | PASS  | PASS   |
| SkipFoundationTests       | testSkipFoundation        | PASS  | PASS   |
| SkipFoundationTests       | testSystemProperties      | PASS  | PASS   |
| TestAffineTransform       | testAppendTransform       | PASS  | ????   |
| TestAffineTransform       | testBridging              | PASS  | ????   |
| TestAffineTransform       | testConstruction          | PASS  | ????   |
| TestAffineTransform       | testEqualityHashing       | PASS  | ????   |
| TestAffineTransform       | testIdentity              | PASS  | ????   |
| TestAffineTransform       | testIdentityConstruction  | PASS  | ????   |
| TestAffineTransform       | testInversion             | PASS  | ????   |
| TestAffineTransform       | testPrependTransform      | PASS  | ????   |
| TestAffineTransform       | testRotation              | PASS  | ????   |
| TestAffineTransform       | testRotationConstruction  | PASS  | ????   |
| TestAffineTransform       | testScaling               | PASS  | ????   |
| TestAffineTransform       | testScalingConstruction   | PASS  | ????   |
| TestAffineTransform       | testScalingRotation       | PASS  | ????   |
| TestAffineTransform       | testTranslation           | PASS  | ????   |
| TestAffineTransform       | testTranslationConstructi | PASS  | ????   |
| TestAffineTransform       | testTranslationRotation   | PASS  | ????   |
| TestAffineTransform       | testTranslationScaling    | PASS  | ????   |
| TestAffineTransform       | testVectorTransformations | PASS  | ????   |
| TestAttributedString      | testAddAndRemoveAttribute | PASS  | ????   |
| TestAttributedString      | testAddAttributedString   | PASS  | ????   |
| TestAttributedString      | testAddingAndRemovingAttr | PASS  | ????   |
| TestAttributedString      | testAssignDifferentCharac | PASS  | ????   |
| TestAttributedString      | testAssignDifferentSubstr | PASS  | ????   |
| TestAttributedString      | testAssignDifferentUnicod | PASS  | ????   |
| TestAttributedString      | testAttrViewIndexing      | PASS  | ????   |
| TestAttributedString      | testAttributeContainer    | PASS  | ????   |
| TestAttributedString      | testAttributeContainerEqu | PASS  | ????   |
| TestAttributedString      | testAttributeContainerSet | PASS  | ????   |
| TestAttributedString      | testAttributeMutationCopy | PASS  | ????   |
| TestAttributedString      | testAttributedStringEqual | PASS  | ????   |
| TestAttributedString      | testAttributedSubstringEq | PASS  | ????   |
| TestAttributedString      | testAutomaticCoding       | PASS  | ????   |
| TestAttributedString      | testCOWDuringCharactersMu | PASS  | ????   |
| TestAttributedString      | testCOWDuringSubstringMut | PASS  | ????   |
| TestAttributedString      | testCOWDuringUnicodeScala | PASS  | ????   |
| TestAttributedString      | testChangingSingleCharact | PASS  | ????   |
| TestAttributedString      | testCharViewIndexing_back | PASS  | ????   |
| TestAttributedString      | testCharactersMutation_ap | PASS  | ????   |
| TestAttributedString      | testCharacters_replaceSub | PASS  | ????   |
| TestAttributedString      | testCoalescing            | PASS  | ????   |
| TestAttributedString      | testCodableRawRepresentab | PASS  | ????   |
| TestAttributedString      | testCodingErrorsPropogate | PASS  | ????   |
| TestAttributedString      | testConstructorAttribute  | PASS  | ????   |
| TestAttributedString      | testContainerDescription  | PASS  | ????   |
| TestAttributedString      | testContainerEncoding     | PASS  | ????   |
| TestAttributedString      | testConversionAttributeCo | PASS  | ????   |
| TestAttributedString      | testConversionCoalescing  | PASS  | ????   |
| TestAttributedString      | testConversionFromInvalid | PASS  | ????   |
| TestAttributedString      | testConversionFromObjC    | PASS  | ????   |
| TestAttributedString      | testConversionIncludingOn | PASS  | ????   |
| TestAttributedString      | testConversionNestedScope | PASS  | ????   |
| TestAttributedString      | testConversionToObjC      | PASS  | ????   |
| TestAttributedString      | testConversionToUTF16     | PASS  | ????   |
| TestAttributedString      | testConversionWithoutScop | PASS  | ????   |
| TestAttributedString      | testCreateStringsFromChar | PASS  | ????   |
| TestAttributedString      | testCustomAttributeCoding | PASS  | ????   |
| TestAttributedString      | testCustomCodableTypeWith | PASS  | ????   |
| TestAttributedString      | testDecodingCorruptedData | PASS  | ????   |
| TestAttributedString      | testDecodingThenConvertin | PASS  | ????   |
| TestAttributedString      | testDefaultAttributesCodi | PASS  | ????   |
| TestAttributedString      | testDescription           | PASS  | ????   |
| TestAttributedString      | testDirectMutationCopyOnW | PASS  | ????   |
| TestAttributedString      | testEmptyEnumeration      | PASS  | ????   |
| TestAttributedString      | testEncodeWithPartiallyCo | PASS  | ????   |
| TestAttributedString      | testEnumerationAttributeM | PASS  | ????   |
| TestAttributedString      | testExpressibleByStringLi | PASS  | ????   |
| TestAttributedString      | testHashing               | PASS  | ????   |
| TestAttributedString      | testIncompleteConversionF | PASS  | ????   |
| TestAttributedString      | testIncompleteConversionT | PASS  | ????   |
| TestAttributedString      | testIndexConversion       | PASS  | ????   |
| TestAttributedString      | testInitWithSequence      | PASS  | ????   |
| TestAttributedString      | testJSONEncoding          | PASS  | ????   |
| TestAttributedString      | testLongestEffectiveRange | PASS  | ????   |
| TestAttributedString      | testManualCoding          | PASS  | ????   |
| TestAttributedString      | testMergeAttributeContain | PASS  | ????   |
| TestAttributedString      | testMergeAttributes       | PASS  | ????   |
| TestAttributedString      | testMutateAttributes      | PASS  | ????   |
| TestAttributedString      | testMutateMultipleAttribu | PASS  | ????   |
| TestAttributedString      | testOverlappingSliceMutat | PASS  | ????   |
| TestAttributedString      | testPlusOperators         | PASS  | ????   |
| TestAttributedString      | testRangeConversion       | PASS  | ????   |
| TestAttributedString      | testReplaceAttributes     | PASS  | ????   |
| TestAttributedString      | testReplaceSubrangeWithSu | PASS  | ????   |
| TestAttributedString      | testReplaceSubrange_range | PASS  | ????   |
| TestAttributedString      | testReplaceWithEmptyEleme | PASS  | ????   |
| TestAttributedString      | testReplacingAttributes   | PASS  | ????   |
| TestAttributedString      | testRoundTripConversion_b | PASS  | ????   |
| TestAttributedString      | testRoundTripConversion_c | PASS  | ????   |
| TestAttributedString      | testRunAndSubstringDescri | PASS  | ????   |
| TestAttributedString      | testRunAttributes         | PASS  | ????   |
| TestAttributedString      | testRunEquality           | PASS  | ????   |
| TestAttributedString      | testScopedAttributeContai | PASS  | ????   |
| TestAttributedString      | testScopedAttributes      | PASS  | ????   |
| TestAttributedString      | testScopedCopy            | PASS  | ????   |
| TestAttributedString      | testSearch                | PASS  | ????   |
| TestAttributedString      | testSettingAttributeOnSli | PASS  | ????   |
| TestAttributedString      | testSettingAttributes     | PASS  | ????   |
| TestAttributedString      | testSimpleAttribute       | PASS  | ????   |
| TestAttributedString      | testSimpleEnumeration     | PASS  | ????   |
| TestAttributedString      | testSlice                 | PASS  | ????   |
| TestAttributedString      | testSliceAttributeMutatio | PASS  | ????   |
| TestAttributedString      | testSliceEnumeration      | PASS  | ????   |
| TestAttributedString      | testSliceMutation         | PASS  | ????   |
| TestAttributedString      | testSubCharacterAttribute | PASS  | ????   |
| TestAttributedString      | testSubstringBase         | PASS  | ????   |
| TestAttributedString      | testSubstringDescription  | PASS  | ????   |
| TestAttributedString      | testSubstringEquality     | PASS  | ????   |
| TestAttributedString      | testSubstringGetAttribute | PASS  | ????   |
| TestAttributedString      | testSubstringRunEquality  | PASS  | ????   |
| TestAttributedString      | testSubstringSearch       | PASS  | ????   |
| TestAttributedString      | testUTF16String           | PASS  | ????   |
| TestAttributedString      | testUnicodeScalarsMutatio | PASS  | ????   |
| TestAttributedString      | testUnicodeScalarsSlicing | PASS  | ????   |
| TestAttributedString      | testUnicodeScalarsViewInd | PASS  | ????   |
| TestAttributedString      | testUnicodeScalars_replac | PASS  | ????   |
| TestAttributedStringCOW   | testCharacters            | PASS  | ????   |
| TestAttributedStringCOW   | testGenericProtocol       | PASS  | ????   |
| TestAttributedStringCOW   | testSubstring             | PASS  | ????   |
| TestAttributedStringCOW   | testTopLevelType          | PASS  | ????   |
| TestAttributedStringCOW   | testUnicodeScalars        | PASS  | ????   |
| TestAttributedStringPerfo | testConvertFromNSAS       | PASS  | ????   |
| TestAttributedStringPerfo | testConvertToNSAS         | PASS  | ????   |
| TestAttributedStringPerfo | testCreateLongString      | PASS  | ????   |
| TestAttributedStringPerfo | testCreateManyAttributesS | PASS  | ????   |
| TestAttributedStringPerfo | testDecode                | PASS  | ????   |
| TestAttributedStringPerfo | testEncode                | PASS  | ????   |
| TestAttributedStringPerfo | testEnumerateAttributes   | PASS  | ????   |
| TestAttributedStringPerfo | testEnumerateAttributesSl | PASS  | ????   |
| TestAttributedStringPerfo | testEquality              | PASS  | ????   |
| TestAttributedStringPerfo | testGetAttribute          | PASS  | ????   |
| TestAttributedStringPerfo | testGetAttributeSubrange  | PASS  | ????   |
| TestAttributedStringPerfo | testInsertIntoLongString  | PASS  | ????   |
| TestAttributedStringPerfo | testMergeMultipleAttribut | PASS  | ????   |
| TestAttributedStringPerfo | testModifyAttributes      | PASS  | ????   |
| TestAttributedStringPerfo | testReplaceAttributes     | PASS  | ????   |
| TestAttributedStringPerfo | testReplaceSubrangeOfLong | PASS  | ????   |
| TestAttributedStringPerfo | testSetAttribute          | PASS  | ????   |
| TestAttributedStringPerfo | testSetAttributeSubrange  | PASS  | ????   |
| TestAttributedStringPerfo | testSetMultipleAttributes | PASS  | ????   |
| TestAttributedStringPerfo | testSubstringEquality     | PASS  | ????   |
| TestBundle                | test_URLsForResourcesWith | PASS  | SKIP   |
| TestBundle                | test_bundleFindAuxiliaryE | PASS  | PASS   |
| TestBundle                | test_bundleFindExecutable | PASS  | PASS   |
| TestBundle                | test_bundleForClass       | PASS  | SKIP   |
| TestBundle                | test_bundleLoad           | PASS  | SKIP   |
| TestBundle                | test_bundleLoadWithError  | PASS  | PASS   |
| TestBundle                | test_bundlePreflight      | PASS  | PASS   |
| TestBundle                | test_bundleWithInvalidPat | PASS  | SKIP   |
| TestBundle                | test_infoPlist            | PASS  | SKIP   |
| TestBundle                | test_localizations        | PASS  | SKIP   |
| TestBundle                | test_paths                | PASS  | SKIP   |
| TestBundle                | test_resources            | PASS  | PASS   |
| TestByteCountFormatter    | test_DefaultValues        | PASS  | SKIP   |
| TestByteCountFormatter    | test_adaptiveFalseAllowed | PASS  | SKIP   |
| TestByteCountFormatter    | test_adaptiveFalseAllowed | PASS  | SKIP   |
| TestByteCountFormatter    | test_allowedUnitsBytesGB  | PASS  | SKIP   |
| TestByteCountFormatter    | test_allowedUnitsGB       | PASS  | SKIP   |
| TestByteCountFormatter    | test_allowedUnitsKBGB     | PASS  | SKIP   |
| TestByteCountFormatter    | test_allowedUnitsKBMBGB   | PASS  | SKIP   |
| TestByteCountFormatter    | test_allowedUnitsMBGB     | PASS  | SKIP   |
| TestByteCountFormatter    | test_countStyleBinary     | PASS  | SKIP   |
| TestByteCountFormatter    | test_countStyleDecimal    | PASS  | SKIP   |
| TestByteCountFormatter    | test_isAdaptiveFalse      | PASS  | SKIP   |
| TestByteCountFormatter    | test_isAdaptiveFalseZeroP | PASS  | SKIP   |
| TestByteCountFormatter    | test_isAdaptiveTrue       | PASS  | SKIP   |
| TestByteCountFormatter    | test_largeByteValues      | PASS  | SKIP   |
| TestByteCountFormatter    | test_negativeByteValues   | PASS  | SKIP   |
| TestByteCountFormatter    | test_numberOnly           | PASS  | SKIP   |
| TestByteCountFormatter    | test_oneByte              | PASS  | SKIP   |
| TestByteCountFormatter    | test_unarchivingFixtures  | PASS  | SKIP   |
| TestByteCountFormatter    | test_unitOnly             | PASS  | SKIP   |
| TestByteCountFormatter    | test_zeroBytes            | PASS  | SKIP   |
| TestByteCountFormatter    | test_zeroPadsFractionDigi | PASS  | SKIP   |
| TestCachedURLResponse     | test_copy                 | PASS  | SKIP   |
| TestCachedURLResponse     | test_equalCheckingData    | PASS  | SKIP   |
| TestCachedURLResponse     | test_equalCheckingRespons | PASS  | SKIP   |
| TestCachedURLResponse     | test_equalCheckingStorage | PASS  | SKIP   |
| TestCachedURLResponse     | test_equalWithTheSameInst | PASS  | SKIP   |
| TestCachedURLResponse     | test_equalWithUnrelatedOb | PASS  | SKIP   |
| TestCachedURLResponse     | test_hash                 | PASS  | SKIP   |
| TestCachedURLResponse     | test_initDefaultUserInfo  | PASS  | SKIP   |
| TestCachedURLResponse     | test_initDefaultUserInfoA | PASS  | SKIP   |
| TestCachedURLResponse     | test_initWithoutDefaults  | PASS  | SKIP   |
| TestCalendar              | test_addingDates          | PASS  | PASS   |
| TestCalendar              | test_allCalendars         | PASS  | PASS   |
| TestCalendar              | test_ampmSymbols          | PASS  | PASS   |
| TestCalendar              | test_copy                 | PASS  | SKIP   |
| TestCalendar              | test_currentCalendarRRsta | PASS  | PASS   |
| TestCalendar              | test_customMirror         | PASS  | SKIP   |
| TestCalendar              | test_dateFromDoesntMutate | PASS  | SKIP   |
| TestCalendar              | test_datesNotOnWeekend    | PASS  | PASS   |
| TestCalendar              | test_datesOnWeekend       | PASS  | PASS   |
| TestCalendar              | test_gettingDatesOnChines | PASS  | SKIP   |
| TestCalendar              | test_gettingDatesOnGregor | PASS  | SKIP   |
| TestCalendar              | test_gettingDatesOnHebrew | PASS  | SKIP   |
| TestCalendar              | test_gettingDatesOnISO860 | PASS  | SKIP   |
| TestCalendar              | test_gettingDatesOnJapane | PASS  | SKIP   |
| TestCalendar              | test_gettingDatesOnPersia | PASS  | SKIP   |
| TestCalendar              | test_hashing              | PASS  | SKIP   |
| TestCalendar              | test_nextDate             | PASS  | SKIP   |
| TestCalendar              | test_sr10638              | PASS  | PASS   |
| TestCharacterSet          | testBasicConstruction     | PASS  | SKIP   |
| TestCharacterSet          | testBasics                | PASS  | SKIP   |
| TestCharacterSet          | testClosedRanges_SR_2988  | PASS  | SKIP   |
| TestCharacterSet          | testInsertAndRemove       | PASS  | SKIP   |
| TestCharacterSet          | testMutability_copyOnWrit | PASS  | SKIP   |
| TestCharacterSet          | testRanges                | PASS  | SKIP   |
| TestCharacterSet          | test_AnnexPlanes          | PASS  | SKIP   |
| TestCharacterSet          | test_Bitmap               | PASS  | SKIP   |
| TestCharacterSet          | test_Equatable            | PASS  | SKIP   |
| TestCharacterSet          | test_InlineBuffer         | PASS  | SKIP   |
| TestCharacterSet          | test_Planes               | PASS  | SKIP   |
| TestCharacterSet          | test_Predefines           | PASS  | SKIP   |
| TestCharacterSet          | test_Range                | PASS  | SKIP   |
| TestCharacterSet          | test_SR5971               | PASS  | SKIP   |
| TestCharacterSet          | test_String               | PASS  | SKIP   |
| TestCharacterSet          | test_SubtractEmptySet     | PASS  | SKIP   |
| TestCharacterSet          | test_SubtractNonEmptySet  | PASS  | SKIP   |
| TestCharacterSet          | test_Subtracting          | PASS  | SKIP   |
| TestCharacterSet          | test_SymmetricDifference  | PASS  | SKIP   |
| TestCharacterSet          | test_codingRoundtrip      | PASS  | SKIP   |
| TestCharacterSet          | test_formUnion            | PASS  | SKIP   |
| TestCharacterSet          | test_hashing              | PASS  | SKIP   |
| TestCharacterSet          | test_union                | PASS  | SKIP   |
| TestCodable               | test_CGPoint_JSON         | PASS  | SKIP   |
| TestCodable               | test_CGRect_JSON          | PASS  | SKIP   |
| TestCodable               | test_CGSize_JSON          | PASS  | SKIP   |
| TestCodable               | test_Calendar_JSON        | PASS  | SKIP   |
| TestCodable               | test_CharacterSet_JSON    | PASS  | SKIP   |
| TestCodable               | test_DateComponents_JSON  | PASS  | SKIP   |
| TestCodable               | test_Decimal_JSON         | PASS  | SKIP   |
| TestCodable               | test_IndexPath_JSON       | PASS  | SKIP   |
| TestCodable               | test_IndexSet_JSON        | PASS  | SKIP   |
| TestCodable               | test_Locale_JSON          | PASS  | SKIP   |
| TestCodable               | test_Measurement_JSON     | PASS  | SKIP   |
| TestCodable               | test_NSRange_JSON         | PASS  | SKIP   |
| TestCodable               | test_PersonNameComponents | PASS  | SKIP   |
| TestCodable               | test_TimeZone_JSON        | PASS  | SKIP   |
| TestCodable               | test_URLComponents_JSON   | PASS  | SKIP   |
| TestCodable               | test_URL_JSON             | PASS  | SKIP   |
| TestCodable               | test_UUID_JSON            | PASS  | SKIP   |
| TestDataURLProtocol       | test_invalidURIs          | PASS  | SKIP   |
| TestDataURLProtocol       | test_validURIs            | PASS  | SKIP   |
| TestDate                  | test_BasicConstruction    | PASS  | PASS   |
| TestDate                  | test_Compare              | PASS  | SKIP   |
| TestDate                  | test_DateByAddingTimeInte | PASS  | SKIP   |
| TestDate                  | test_DistantFuture        | PASS  | PASS   |
| TestDate                  | test_DistantPast          | PASS  | PASS   |
| TestDate                  | test_EarlierDate          | PASS  | SKIP   |
| TestDate                  | test_Hashing              | PASS  | PASS   |
| TestDate                  | test_InitTimeIntervalSinc | PASS  | PASS   |
| TestDate                  | test_InitTimeIntervalSinc | PASS  | PASS   |
| TestDate                  | test_IsEqualToDate        | PASS  | SKIP   |
| TestDate                  | test_LaterDate            | PASS  | SKIP   |
| TestDate                  | test_TimeIntervalSinceSin | PASS  | PASS   |
| TestDate                  | test_advancedBy           | PASS  | SKIP   |
| TestDate                  | test_descriptionWithLocal | PASS  | PASS   |
| TestDate                  | test_distanceTo           | PASS  | SKIP   |
| TestDate                  | test_recreateDateComponen | PASS  | SKIP   |
| TestDate                  | test_timeIntervalSinceRef | PASS  | PASS   |
| TestDateComponents        | test_hash                 | PASS  | SKIP   |
| TestDateComponents        | test_isValidDate          | PASS  | PASS   |
| TestDateFormatter         | test_BasicConstruction    | PASS  | SKIP   |
| TestDateFormatter         | test_copy_sr14108         | PASS  | SKIP   |
| TestDateFormatter         | test_customDateFormat     | PASS  | SKIP   |
| TestDateFormatter         | test_dateFormatString     | PASS  | SKIP   |
| TestDateFormatter         | test_dateFrom             | PASS  | SKIP   |
| TestDateFormatter         | test_dateParseAndFormatWi | PASS  | SKIP   |
| TestDateFormatter         | test_dateStyleFull        | PASS  | SKIP   |
| TestDateFormatter         | test_dateStyleLong        | PASS  | SKIP   |
| TestDateFormatter         | test_dateStyleMedium      | PASS  | SKIP   |
| TestDateFormatter         | test_dateStyleShort       | PASS  | SKIP   |
| TestDateFormatter         | test_expectedTimeZone     | PASS  | PASS   |
| TestDateFormatter         | test_orderOfPropertySette | PASS  | SKIP   |
| TestDateFormatter         | test_setLocaleToNil       | PASS  | PASS   |
| TestDateFormatter         | test_setLocalizedDateForm | PASS  | PASS   |
| TestDateFormatter         | test_setTimeZone          | PASS  | PASS   |
| TestDateFormatter         | test_setTimeZoneToNil     | PASS  | PASS   |
| TestDateInterval          | test_compareDifferentDura | PASS  | SKIP   |
| TestDateInterval          | test_compareDifferentStar | PASS  | SKIP   |
| TestDateInterval          | test_compareSame          | PASS  | SKIP   |
| TestDateInterval          | test_comparisonOperators  | PASS  | SKIP   |
| TestDateInterval          | test_contains             | PASS  | SKIP   |
| TestDateInterval          | test_defaultInitializer   | PASS  | SKIP   |
| TestDateInterval          | test_hashing              | PASS  | SKIP   |
| TestDateInterval          | test_intersection         | PASS  | SKIP   |
| TestDateInterval          | test_intersectionNil      | PASS  | SKIP   |
| TestDateInterval          | test_intersectionZeroDura | PASS  | SKIP   |
| TestDateInterval          | test_intersects           | PASS  | SKIP   |
| TestDateInterval          | test_startDurationInitial | PASS  | SKIP   |
| TestDateInterval          | test_startEndInitializer  | PASS  | SKIP   |
| TestDateIntervalFormatter | testCodingRoundtrip       | PASS  | SKIP   |
| TestDateIntervalFormatter | testDecodingFixtures      | PASS  | SKIP   |
| TestDateIntervalFormatter | testStringFromDateInterva | PASS  | SKIP   |
| TestDateIntervalFormatter | testStringFromDateToDateA | PASS  | SKIP   |
| TestDateIntervalFormatter | testStringFromDateToDateA | PASS  | SKIP   |
| TestDateIntervalFormatter | testStringFromDateToDateA | PASS  | SKIP   |
| TestDateIntervalFormatter | testStringFromDateToDateA | PASS  | SKIP   |
| TestDateIntervalFormatter | testStringFromDateToDateA | PASS  | SKIP   |
| TestDateIntervalFormatter | testStringFromDateToDateA | PASS  | SKIP   |
| TestDateIntervalFormatter | testStringFromDateToDateA | PASS  | SKIP   |
| TestDateIntervalFormatter | testStringFromDateToDateA | PASS  | SKIP   |
| TestDateIntervalFormatter | testStringFromDateToSameD | PASS  | SKIP   |
| TestDecimal               | test_AdditionWithNormaliz | PASS  | ????   |
| TestDecimal               | test_BasicConstruction    | PASS  | ????   |
| TestDecimal               | test_Constants            | PASS  | ????   |
| TestDecimal               | test_Description          | PASS  | ????   |
| TestDecimal               | test_ExplicitConstruction | PASS  | ????   |
| TestDecimal               | test_Maths                | PASS  | ????   |
| TestDecimal               | test_Misc                 | PASS  | ????   |
| TestDecimal               | test_MultiplicationOverfl | PASS  | ????   |
| TestDecimal               | test_NSDecimal            | PASS  | ????   |
| TestDecimal               | test_NSDecimalNumberInit  | PASS  | ????   |
| TestDecimal               | test_NSDecimalNumberValue | PASS  | ????   |
| TestDecimal               | test_NSDecimalString      | PASS  | ????   |
| TestDecimal               | test_NSNumberEquality     | PASS  | ????   |
| TestDecimal               | test_NaNInput             | PASS  | ????   |
| TestDecimal               | test_NegativeAndZeroMulti | PASS  | ????   |
| TestDecimal               | test_Normalise            | PASS  | ????   |
| TestDecimal               | test_PositivePowers       | PASS  | ????   |
| TestDecimal               | test_RepeatingDivision    | PASS  | ????   |
| TestDecimal               | test_Round                | PASS  | ????   |
| TestDecimal               | test_ScanDecimal          | PASS  | ????   |
| TestDecimal               | test_Significand          | PASS  | ????   |
| TestDecimal               | test_SimpleMultiplication | PASS  | ????   |
| TestDecimal               | test_SmallerNumbers       | PASS  | ????   |
| TestDecimal               | test_Strideable           | PASS  | ????   |
| TestDecimal               | test_ULP                  | PASS  | ????   |
| TestDecimal               | test_ZeroPower            | PASS  | ????   |
| TestDecimal               | test_bridging             | PASS  | ????   |
| TestDecimal               | test_doubleValue          | PASS  | ????   |
| TestDecimal               | test_initExactly          | PASS  | ????   |
| TestDecimal               | test_intValue             | PASS  | ????   |
| TestDecimal               | test_multiplyingByPowerOf | PASS  | ????   |
| TestDecimal               | test_parseDouble          | PASS  | ????   |
| TestDecimal               | test_stringWithLocale     | PASS  | ????   |
| TestDimension             | test_encodeDecode         | PASS  | SKIP   |
| TestEnergyFormatter       | test_stringFromJoulesCalo | PASS  | ????   |
| TestEnergyFormatter       | test_stringFromJoulesCalo | PASS  | ????   |
| TestEnergyFormatter       | test_stringFromJoulesJoul | PASS  | ????   |
| TestEnergyFormatter       | test_stringFromValue      | PASS  | ????   |
| TestEnergyFormatter       | test_unitStringFromJoules | PASS  | ????   |
| TestEnergyFormatter       | test_unitStringFromValue  | PASS  | ????   |
| TestFileHandle            | testOffset                | PASS  | ????   |
| TestFileHandle            | testReadToEnd             | PASS  | ????   |
| TestFileHandle            | testReadUpToCount         | PASS  | ????   |
| TestFileHandle            | testSynchronizeOnSpecialF | PASS  | ????   |
| TestFileHandle            | testWritingWithBuffer     | PASS  | ????   |
| TestFileHandle            | testWritingWithData       | PASS  | ????   |
| TestFileHandle            | testWritingWithMultiregio | PASS  | ????   |
| TestFileHandle            | test_availableData        | PASS  | ????   |
| TestFileHandle            | test_constants            | PASS  | ????   |
| TestFileHandle            | test_readToEndOfFileAndNo | PASS  | ????   |
| TestFileHandle            | test_readToEndOfFileAndNo | PASS  | ????   |
| TestFileHandle            | test_readToEndOfFileInBac | PASS  | ????   |
| TestFileHandle            | test_readWriteHandlers    | PASS  | ????   |
| TestFileHandle            | test_readabilityHandlerCl | PASS  | ????   |
| TestFileHandle            | test_readabilityHandlerCl | PASS  | ????   |
| TestFileHandle            | test_truncate             | PASS  | ????   |
| TestFileHandle            | test_truncateFile         | PASS  | ????   |
| TestFileHandle            | test_waitForDataInBackgro | PASS  | ????   |
| TestFileManager           | test_NSTemporaryDirectory | PASS  | PASS   |
| TestFileManager           | test_concurrentGetItemRep | PASS  | SKIP   |
| TestFileManager           | test_contentsEqual        | PASS  | SKIP   |
| TestFileManager           | test_contentsOfDirectoryA | PASS  | PASS   |
| TestFileManager           | test_copyItemAtPathToPath | PASS  | PASS   |
| TestFileManager           | test_copyItemsPermissions | PASS  | PASS   |
| TestFileManager           | test_createDirectory      | PASS  | PASS   |
| TestFileManager           | test_createFile           | PASS  | SKIP   |
| TestFileManager           | test_creatingDirectoryWit | PASS  | SKIP   |
| TestFileManager           | test_directoryEnumerator  | PASS  | SKIP   |
| TestFileManager           | test_displayNames         | PASS  | SKIP   |
| TestFileManager           | test_emptyFilename        | PASS  | SKIP   |
| TestFileManager           | test_fileAttributes       | PASS  | PASS   |
| TestFileManager           | test_fileExists           | PASS  | PASS   |
| TestFileManager           | test_fileSystemAttributes | PASS  | SKIP   |
| TestFileManager           | test_fileSystemRepresenta | PASS  | SKIP   |
| TestFileManager           | test_getItemReplacementDi | PASS  | SKIP   |
| TestFileManager           | test_getRelationship      | PASS  | SKIP   |
| TestFileManager           | test_homedirectoryForUser | PASS  | SKIP   |
| TestFileManager           | test_isDeletableFile      | PASS  | PASS   |
| TestFileManager           | test_isExecutableFile     | PASS  | PASS   |
| TestFileManager           | test_isReadableFile       | PASS  | PASS   |
| TestFileManager           | test_isWritableFile       | PASS  | PASS   |
| TestFileManager           | test_linkItemAtPathToPath | PASS  | SKIP   |
| TestFileManager           | test_mountedVolumeURLs    | PASS  | SKIP   |
| TestFileManager           | test_moveFile             | PASS  | PASS   |
| TestFileManager           | test_pathEnumerator       | PASS  | SKIP   |
| TestFileManager           | test_replacement          | PASS  | SKIP   |
| TestFileManager           | test_resolvingSymlinksInP | PASS  | PASS   |
| TestFileManager           | test_setFileAttributes    | PASS  | PASS   |
| TestFileManager           | test_setInvalidFileAttrib | PASS  | PASS   |
| TestFileManager           | test_subpathsOfDirectoryA | PASS  | PASS   |
| TestFileManager           | test_temporaryDirectoryFo | PASS  | PASS   |
| TestFileManager           | test_windowsPaths         | PASS  | SKIP   |
| TestHTTPCookie            | test_BasicConstruction    | PASS  | ????   |
| TestHTTPCookie            | test_RequestHeaderFields  | PASS  | ????   |
| TestHTTPCookie            | test_cookieDomainCanonica | PASS  | ????   |
| TestHTTPCookie            | test_cookieExpiresDateFor | PASS  | ????   |
| TestHTTPCookie            | test_cookiesWithExpiresAs | PASS  | ????   |
| TestHTTPCookie            | test_cookiesWithResponseH | PASS  | ????   |
| TestHTTPCookie            | test_cookiesWithResponseH | PASS  | ????   |
| TestHTTPCookie            | test_cookiesWithResponseH | PASS  | ????   |
| TestHTTPCookie            | test_cookiesWithResponseH | PASS  | ????   |
| TestHTTPCookie            | test_cookiesWithResponseH | PASS  | ????   |
| TestHTTPCookie            | test_cookiesWithResponseH | PASS  | ????   |
| TestHTTPCookie            | test_cookiesWithResponseH | PASS  | ????   |
| TestHTTPCookie            | test_cookiesWithResponseH | PASS  | ????   |
| TestHTTPCookie            | test_cookiesWithResponseH | PASS  | ????   |
| TestHTTPCookie            | test_cookiesWithResponseH | PASS  | ????   |
| TestHTTPCookie            | test_cookiesWithResponseH | PASS  | ????   |
| TestHTTPCookie            | test_cookiesWithResponseH | PASS  | ????   |
| TestHTTPCookie            | test_cookiesWithResponseH | PASS  | ????   |
| TestHTTPCookie            | test_cookiesWithResponseH | PASS  | ????   |
| TestHTTPCookie            | test_cookiesWithResponseH | PASS  | ????   |
| TestHTTPCookie            | test_cookiesWithResponseH | PASS  | ????   |
| TestHTTPCookie            | test_httpCookieWithSubstr | PASS  | ????   |
| TestHTTPCookieStorage     | test_BasicStorageAndRetri | PASS  | ????   |
| TestHTTPCookieStorage     | test_cookieDomainMatching | PASS  | ????   |
| TestHTTPCookieStorage     | test_cookieInXDGSpecPath  | PASS  | ????   |
| TestHTTPCookieStorage     | test_cookiesForURL        | PASS  | ????   |
| TestHTTPCookieStorage     | test_cookiesForURLWithMai | PASS  | ????   |
| TestHTTPCookieStorage     | test_deleteCookie         | PASS  | ????   |
| TestHTTPCookieStorage     | test_descriptionCookie    | PASS  | ????   |
| TestHTTPCookieStorage     | test_removeCookies        | PASS  | ????   |
| TestHTTPCookieStorage     | test_sharedCookieStorageA | PASS  | ????   |
| TestHTTPCookieStorage     | test_sorting              | PASS  | ????   |
| TestHTTPURLResponse       | test_MIMETypeAndCharacter | PASS  | PASS   |
| TestHTTPURLResponse       | test_MIMETypeAndCharacter | PASS  | PASS   |
| TestHTTPURLResponse       | test_MIMETypeAndCharacter | PASS  | PASS   |
| TestHTTPURLResponse       | test_URL_and_status_1     | PASS  | PASS   |
| TestHTTPURLResponse       | test_URL_and_status_2     | PASS  | PASS   |
| TestHTTPURLResponse       | test_contentLength_availa | PASS  | PASS   |
| TestHTTPURLResponse       | test_contentLength_availa | PASS  | PASS   |
| TestHTTPURLResponse       | test_contentLength_availa | PASS  | PASS   |
| TestHTTPURLResponse       | test_contentLength_availa | PASS  | PASS   |
| TestHTTPURLResponse       | test_contentLength_notAva | PASS  | PASS   |
| TestHTTPURLResponse       | test_contentLength_withCo | PASS  | PASS   |
| TestHTTPURLResponse       | test_contentLength_withCo | PASS  | PASS   |
| TestHTTPURLResponse       | test_contentLength_withCo | PASS  | PASS   |
| TestHTTPURLResponse       | test_contentLength_withTr | PASS  | PASS   |
| TestHTTPURLResponse       | test_fieldCapitalisation  | PASS  | SKIP   |
| TestHTTPURLResponse       | test_headerFields_1       | PASS  | PASS   |
| TestHTTPURLResponse       | test_headerFields_2       | PASS  | PASS   |
| TestHTTPURLResponse       | test_headerFields_3       | PASS  | PASS   |
| TestHTTPURLResponse       | test_suggestedFilename_1  | PASS  | PASS   |
| TestHTTPURLResponse       | test_suggestedFilename_2  | PASS  | PASS   |
| TestHTTPURLResponse       | test_suggestedFilename_3  | PASS  | SKIP   |
| TestHTTPURLResponse       | test_suggestedFilename_4  | PASS  | PASS   |
| TestHTTPURLResponse       | test_suggestedFilename_no | PASS  | PASS   |
| TestHTTPURLResponse       | test_suggestedFilename_no | PASS  | PASS   |
| TestHTTPURLResponse       | test_suggestedFilename_re | PASS  | PASS   |
| TestHTTPURLResponse       | test_suggestedFilename_re | PASS  | PASS   |
| TestHost                  | test_addressesDoNotGrow   | PASS  | SKIP   |
| TestHost                  | test_isEqual              | PASS  | SKIP   |
| TestHost                  | test_localNamesNonEmpty   | PASS  | SKIP   |
| TestISO8601DateFormatter  | test_codingRoundtrip      | PASS  | SKIP   |
| TestISO8601DateFormatter  | test_copy                 | PASS  | SKIP   |
| TestISO8601DateFormatter  | test_dateFromString       | PASS  | SKIP   |
| TestISO8601DateFormatter  | test_loadingFixtures      | PASS  | SKIP   |
| TestISO8601DateFormatter  | test_stringFromDate       | PASS  | SKIP   |
| TestISO8601DateFormatter  | test_stringFromDateClass  | PASS  | SKIP   |
| TestIndexPath             | testAppendArray           | PASS  | SKIP   |
| TestIndexPath             | testAppendByOperator      | PASS  | SKIP   |
| TestIndexPath             | testAppendEmpty           | PASS  | SKIP   |
| TestIndexPath             | testAppendEmptyIndexPath  | PASS  | SKIP   |
| TestIndexPath             | testAppendEmptyIndexPathT | PASS  | SKIP   |
| TestIndexPath             | testAppendManyIndexPath   | PASS  | SKIP   |
| TestIndexPath             | testAppendManyIndexPathTo | PASS  | SKIP   |
| TestIndexPath             | testAppendPairIndexPath   | PASS  | SKIP   |
| TestIndexPath             | testAppendSingleIndexPath | PASS  | SKIP   |
| TestIndexPath             | testAppendSingleIndexPath | PASS  | SKIP   |
| TestIndexPath             | testAppending             | PASS  | SKIP   |
| TestIndexPath             | testBridgeToObjC          | PASS  | SKIP   |
| TestIndexPath             | testCodingRoundtrip       | PASS  | SKIP   |
| TestIndexPath             | testCompare               | PASS  | SKIP   |
| TestIndexPath             | testConditionalBridgeFrom | PASS  | SKIP   |
| TestIndexPath             | testCreateFromLiteral     | PASS  | SKIP   |
| TestIndexPath             | testCreateFromSequence    | PASS  | SKIP   |
| TestIndexPath             | testDescription           | PASS  | SKIP   |
| TestIndexPath             | testDropLast              | PASS  | SKIP   |
| TestIndexPath             | testDropLastFromEmpty     | PASS  | SKIP   |
| TestIndexPath             | testDropLastFromPair      | PASS  | SKIP   |
| TestIndexPath             | testDropLastFromSingle    | PASS  | SKIP   |
| TestIndexPath             | testDropLastFromTriple    | PASS  | SKIP   |
| TestIndexPath             | testEmpty                 | PASS  | SKIP   |
| TestIndexPath             | testEquality              | PASS  | SKIP   |
| TestIndexPath             | testForceBridgeFromObjC   | PASS  | SKIP   |
| TestIndexPath             | testHashing               | PASS  | SKIP   |
| TestIndexPath             | testIndexing              | PASS  | SKIP   |
| TestIndexPath             | testIteration             | PASS  | SKIP   |
| TestIndexPath             | testIterator              | PASS  | SKIP   |
| TestIndexPath             | testLoadedValuesMatch     | PASS  | SKIP   |
| TestIndexPath             | testManyIndexes           | PASS  | SKIP   |
| TestIndexPath             | testMoreRanges            | PASS  | SKIP   |
| TestIndexPath             | testObjcBridgeType        | PASS  | SKIP   |
| TestIndexPath             | testRangeFromEmpty        | PASS  | SKIP   |
| TestIndexPath             | testRangeFromMany         | PASS  | SKIP   |
| TestIndexPath             | testRangeFromPair         | PASS  | SKIP   |
| TestIndexPath             | testRangeFromSingle       | PASS  | SKIP   |
| TestIndexPath             | testRangeReplacementPair  | PASS  | SKIP   |
| TestIndexPath             | testRangeReplacementSingl | PASS  | SKIP   |
| TestIndexPath             | testRanges                | PASS  | SKIP   |
| TestIndexPath             | testSingleIndex           | PASS  | SKIP   |
| TestIndexPath             | testStartEndIndex         | PASS  | SKIP   |
| TestIndexPath             | testSubscripting          | PASS  | SKIP   |
| TestIndexPath             | testTwoIndexes            | PASS  | SKIP   |
| TestIndexPath             | testUnconditionalBridgeFr | PASS  | SKIP   |
| TestIndexPath             | test_AnyHashableContainin | PASS  | SKIP   |
| TestIndexPath             | test_AnyHashableCreatedFr | PASS  | SKIP   |
| TestIndexPath             | test_copy                 | PASS  | SKIP   |
| TestIndexPath             | test_slice_1ary           | PASS  | SKIP   |
| TestIndexPath             | test_unconditionallyBridg | PASS  | SKIP   |
| TestIndexSet              | testCodingRoundtrip       | PASS  | SKIP   |
| TestIndexSet              | testContainsAndIntersects | PASS  | SKIP   |
| TestIndexSet              | testContainsIndexSet      | PASS  | SKIP   |
| TestIndexSet              | testEmptyIteration        | PASS  | SKIP   |
| TestIndexSet              | testEnumeration           | PASS  | SKIP   |
| TestIndexSet              | testFiltering             | PASS  | SKIP   |
| TestIndexSet              | testFilteringRanges       | PASS  | SKIP   |
| TestIndexSet              | testHashValue             | PASS  | SKIP   |
| TestIndexSet              | testIndexRange            | PASS  | SKIP   |
| TestIndexSet              | testIndexingPerformance   | PASS  | SKIP   |
| TestIndexSet              | testInsertNonOverlapping  | PASS  | SKIP   |
| TestIndexSet              | testInsertOverlapping     | PASS  | SKIP   |
| TestIndexSet              | testInsertOverlappingExte | PASS  | SKIP   |
| TestIndexSet              | testInsertOverlappingMult | PASS  | SKIP   |
| TestIndexSet              | testIntersection          | PASS  | SKIP   |
| TestIndexSet              | testIteration             | PASS  | SKIP   |
| TestIndexSet              | testLoadedValuesMatch     | PASS  | SKIP   |
| TestIndexSet              | testMutation              | PASS  | SKIP   |
| TestIndexSet              | testRangeIteration        | PASS  | SKIP   |
| TestIndexSet              | testRemoveNonOverlapping  | PASS  | SKIP   |
| TestIndexSet              | testRemoveOverlapping     | PASS  | SKIP   |
| TestIndexSet              | testRemoveSplitting       | PASS  | SKIP   |
| TestIndexSet              | testShift                 | PASS  | SKIP   |
| TestIndexSet              | testSlicing               | PASS  | SKIP   |
| TestIndexSet              | testSubrangeIteration     | PASS  | SKIP   |
| TestIndexSet              | testSubsequence           | PASS  | SKIP   |
| TestIndexSet              | testSubsequences          | PASS  | SKIP   |
| TestIndexSet              | testSymmetricDifference   | PASS  | SKIP   |
| TestIndexSet              | testUnion                 | PASS  | SKIP   |
| TestIndexSet              | test_AnyHashableContainin | PASS  | SKIP   |
| TestIndexSet              | test_AnyHashableCreatedFr | PASS  | SKIP   |
| TestIndexSet              | test_BasicConstruction    | PASS  | SKIP   |
| TestIndexSet              | test_addition             | PASS  | SKIP   |
| TestIndexSet              | test_copy                 | PASS  | SKIP   |
| TestIndexSet              | test_enumeration          | PASS  | SKIP   |
| TestIndexSet              | test_findIndex            | PASS  | SKIP   |
| TestIndexSet              | test_removal              | PASS  | SKIP   |
| TestIndexSet              | test_sequenceType         | PASS  | SKIP   |
| TestIndexSet              | test_setAlgebra           | PASS  | SKIP   |
| TestIndexSet              | test_unconditionallyBridg | PASS  | SKIP   |
| TestJSON                  | testEncodeToJSON          | PASS  | PASS   |
| TestJSON                  | testJSONCodable           | PASS  | PASS   |
| TestJSON                  | testJSONDeserialization   | PASS  | PASS   |
| TestJSON                  | testJSONParse             | PASS  | PASS   |
| TestJSON                  | testJSONParsing           | PASS  | PASS   |
| TestJSONEncoder           | test_OutputFormattingValu | PASS  | SKIP   |
| TestJSONEncoder           | test_SR17581_codingEmptyD | PASS  | SKIP   |
| TestJSONEncoder           | test_codingOfBool         | PASS  | SKIP   |
| TestJSONEncoder           | test_codingOfDecimal      | PASS  | SKIP   |
| TestJSONEncoder           | test_codingOfDouble       | PASS  | SKIP   |
| TestJSONEncoder           | test_codingOfFloat        | PASS  | SKIP   |
| TestJSONEncoder           | test_codingOfInt          | PASS  | SKIP   |
| TestJSONEncoder           | test_codingOfInt16        | PASS  | SKIP   |
| TestJSONEncoder           | test_codingOfInt32        | PASS  | SKIP   |
| TestJSONEncoder           | test_codingOfInt64        | PASS  | SKIP   |
| TestJSONEncoder           | test_codingOfInt8         | PASS  | SKIP   |
| TestJSONEncoder           | test_codingOfNil          | PASS  | SKIP   |
| TestJSONEncoder           | test_codingOfString       | PASS  | SKIP   |
| TestJSONEncoder           | test_codingOfUInt         | PASS  | SKIP   |
| TestJSONEncoder           | test_codingOfUInt16       | PASS  | SKIP   |
| TestJSONEncoder           | test_codingOfUInt32       | PASS  | SKIP   |
| TestJSONEncoder           | test_codingOfUInt64       | PASS  | SKIP   |
| TestJSONEncoder           | test_codingOfUInt8        | PASS  | SKIP   |
| TestJSONEncoder           | test_codingOfUIntMinMax   | PASS  | SKIP   |
| TestJSONEncoder           | test_codingOfURL          | PASS  | SKIP   |
| TestJSONEncoder           | test_dictionary_snake_cas | PASS  | SKIP   |
| TestJSONEncoder           | test_dictionary_snake_cas | PASS  | SKIP   |
| TestJSONEncoder           | test_encodeDecodeNumericT | PASS  | SKIP   |
| TestJSONEncoder           | test_encodingBase64Data   | PASS  | SKIP   |
| TestJSONEncoder           | test_encodingCustomData   | PASS  | SKIP   |
| TestJSONEncoder           | test_encodingCustomDataEm | PASS  | SKIP   |
| TestJSONEncoder           | test_encodingDate         | PASS  | SKIP   |
| TestJSONEncoder           | test_encodingDateCustom   | PASS  | SKIP   |
| TestJSONEncoder           | test_encodingDateCustomEm | PASS  | SKIP   |
| TestJSONEncoder           | test_encodingDateFormatte | PASS  | SKIP   |
| TestJSONEncoder           | test_encodingDateISO8601  | PASS  | SKIP   |
| TestJSONEncoder           | test_encodingDateMillisec | PASS  | SKIP   |
| TestJSONEncoder           | test_encodingDateSecondsS | PASS  | SKIP   |
| TestJSONEncoder           | test_encodingNonConformin | PASS  | SKIP   |
| TestJSONEncoder           | test_encodingNonConformin | PASS  | SKIP   |
| TestJSONEncoder           | test_encodingOutputFormat | PASS  | SKIP   |
| TestJSONEncoder           | test_encodingOutputFormat | PASS  | SKIP   |
| TestJSONEncoder           | test_encodingOutputFormat | PASS  | SKIP   |
| TestJSONEncoder           | test_encodingOutputFormat | PASS  | SKIP   |
| TestJSONEncoder           | test_encodingTopLevelDeep | PASS  | SKIP   |
| TestJSONEncoder           | test_encodingTopLevelEmpt | PASS  | SKIP   |
| TestJSONEncoder           | test_encodingTopLevelEmpt | PASS  | SKIP   |
| TestJSONEncoder           | test_encodingTopLevelFrag | PASS  | SKIP   |
| TestJSONEncoder           | test_encodingTopLevelSing | PASS  | SKIP   |
| TestJSONEncoder           | test_encodingTopLevelSing | PASS  | SKIP   |
| TestJSONEncoder           | test_encodingTopLevelSing | PASS  | SKIP   |
| TestJSONEncoder           | test_encodingTopLevelStru | PASS  | SKIP   |
| TestJSONEncoder           | test_encodingTopLevelStru | PASS  | SKIP   |
| TestJSONEncoder           | test_encodingTopLevelStru | PASS  | SKIP   |
| TestJSONEncoder           | test_encodingTopLevelStru | PASS  | SKIP   |
| TestJSONEncoder           | test_nestedContainerCodin | PASS  | SKIP   |
| TestJSONEncoder           | test_notFoundSuperDecoder | PASS  | SKIP   |
| TestJSONEncoder           | test_numericLimits        | PASS  | SKIP   |
| TestJSONEncoder           | test_snake_case_encoding  | PASS  | SKIP   |
| TestJSONEncoder           | test_superEncoderCodingPa | PASS  | SKIP   |
| TestJSONSerialization     | test_JSONObjectWithData_e | PASS  | SKIP   |
| TestJSONSerialization     | test_JSONObjectWithData_e | PASS  | SKIP   |
| TestJSONSerialization     | test_JSONObjectWithStream | PASS  | SKIP   |
| TestJSONSerialization     | test_JSONObjectWithStream | PASS  | SKIP   |
| TestJSONSerialization     | test_bailOnDeepInvalidStr | PASS  | SKIP   |
| TestJSONSerialization     | test_bailOnDeepValidStruc | PASS  | SKIP   |
| TestJSONSerialization     | test_booleanJSONObject    | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_allowFra | PASS  | PASS   |
| TestJSONSerialization     | test_deserialize_allowFra | PASS  | PASS   |
| TestJSONSerialization     | test_deserialize_badlyFor | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_badlyFor | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_emptyArr | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_emptyArr | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_emptyObj | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_emptyObj | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_highlyNe | PASS  | PASS   |
| TestJSONSerialization     | test_deserialize_highlyNe | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_highlyNe | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_highlyNe | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_invalidE | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_invalidE | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_invalidV | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_invalidV | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_invalidV | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_invalidV | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_invalidV | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_invalidV | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_missingO | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_missingO | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_multiStr | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_multiStr | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_multiStr | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_multiStr | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_numberTh | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_numberTh | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_numberWi | PASS  | PASS   |
| TestJSONSerialization     | test_deserialize_numberWi | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_numbers_ | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_numbers_ | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_numbers_ | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_numbers_ | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_simpleEs | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_simpleEs | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_stringWi | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_stringWi | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_unescape | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_unescape | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_unescape | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_unescape | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_unexpect | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_unexpect | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_unicodeE | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_unicodeE | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_unicodeM | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_unicodeM | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_unicodeM | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_unicodeM | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_unicodeS | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_unicodeS | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_unicodeS | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_unicodeS | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_untermin | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_untermin | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_values_a | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_values_a | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_values_w | PASS  | SKIP   |
| TestJSONSerialization     | test_deserialize_values_w | PASS  | SKIP   |
| TestJSONSerialization     | test_isValidJSONObjectFal | PASS  | SKIP   |
| TestJSONSerialization     | test_isValidJSONObjectTru | PASS  | SKIP   |
| TestJSONSerialization     | test_jsonObjectToOutputSt | PASS  | SKIP   |
| TestJSONSerialization     | test_jsonObjectToOutputSt | PASS  | SKIP   |
| TestJSONSerialization     | test_jsonObjectToOutputSt | PASS  | SKIP   |
| TestJSONSerialization     | test_jsonReadingOffTheEnd | PASS  | SKIP   |
| TestJSONSerialization     | test_nested_array         | PASS  | SKIP   |
| TestJSONSerialization     | test_nested_dictionary    | PASS  | SKIP   |
| TestJSONSerialization     | test_serializeDecimalNumb | PASS  | SKIP   |
| TestJSONSerialization     | test_serializePrettyPrint | PASS  | SKIP   |
| TestJSONSerialization     | test_serializeSortedKeys  | PASS  | SKIP   |
| TestJSONSerialization     | test_serialize_16BitSizes | PASS  | SKIP   |
| TestJSONSerialization     | test_serialize_32BitSizes | PASS  | SKIP   |
| TestJSONSerialization     | test_serialize_64BitSizes | PASS  | SKIP   |
| TestJSONSerialization     | test_serialize_8BitSizes  | PASS  | SKIP   |
| TestJSONSerialization     | test_serialize_Decimal    | PASS  | SKIP   |
| TestJSONSerialization     | test_serialize_Double     | PASS  | SKIP   |
| TestJSONSerialization     | test_serialize_Float      | PASS  | SKIP   |
| TestJSONSerialization     | test_serialize_IntMax     | PASS  | SKIP   |
| TestJSONSerialization     | test_serialize_IntMin     | PASS  | SKIP   |
| TestJSONSerialization     | test_serialize_NSDecimalN | PASS  | SKIP   |
| TestJSONSerialization     | test_serialize_UIntMax    | PASS  | SKIP   |
| TestJSONSerialization     | test_serialize_UIntMin    | PASS  | SKIP   |
| TestJSONSerialization     | test_serialize_complexObj | PASS  | SKIP   |
| TestJSONSerialization     | test_serialize_dictionary | PASS  | SKIP   |
| TestJSONSerialization     | test_serialize_emptyObjec | PASS  | SKIP   |
| TestJSONSerialization     | test_serialize_fragments  | PASS  | SKIP   |
| TestJSONSerialization     | test_serialize_null       | PASS  | SKIP   |
| TestJSONSerialization     | test_serialize_number     | PASS  | SKIP   |
| TestJSONSerialization     | test_serialize_stringEsca | PASS  | SKIP   |
| TestJSONSerialization     | test_serialize_withoutEsc | PASS  | SKIP   |
| TestJSONSerialization     | test_validNumericJSONObje | PASS  | SKIP   |
| TestLengthFormatter       | test_stringFromMetersMetr | PASS  | SKIP   |
| TestLengthFormatter       | test_stringFromMetersMetr | PASS  | SKIP   |
| TestLengthFormatter       | test_stringFromMetersUS   | PASS  | SKIP   |
| TestLengthFormatter       | test_stringFromMetersUSPe | PASS  | SKIP   |
| TestLengthFormatter       | test_stringFromValue      | PASS  | SKIP   |
| TestLengthFormatter       | test_unitStringFromMeters | PASS  | SKIP   |
| TestLengthFormatter       | test_unitStringFromValue  | PASS  | SKIP   |
| TestMassFormatter         | test_stringFromKilogramsI | PASS  | SKIP   |
| TestMassFormatter         | test_stringFromKilogramsM | PASS  | SKIP   |
| TestMassFormatter         | test_stringFromKilogramsM | PASS  | SKIP   |
| TestMassFormatter         | test_stringFromValue      | PASS  | SKIP   |
| TestMassFormatter         | test_unitStringFromKilogr | PASS  | SKIP   |
| TestMassFormatter         | test_unitStringFromValue  | PASS  | SKIP   |
| TestMeasurement           | testCodingRoundtrip       | PASS  | SKIP   |
| TestMeasurement           | testHashing               | PASS  | SKIP   |
| TestMeasurement           | testLoadedValuesMatch     | PASS  | SKIP   |
| TestNotification          | test_NotificationNameInit | PASS  | SKIP   |
| TestNotification          | test_customReflection     | PASS  | SKIP   |
| TestNotificationCenter    | test_addObserverForNilNam | PASS  | SKIP   |
| TestNotificationCenter    | test_defaultCenter        | PASS  | SKIP   |
| TestNotificationCenter    | test_observeOnPostingQueu | PASS  | SKIP   |
| TestNotificationCenter    | test_observeOnSpecificQue | PASS  | SKIP   |
| TestNotificationCenter    | test_observeOnSpecificQue | PASS  | SKIP   |
| TestNotificationCenter    | test_observeOnSpecificQue | PASS  | SKIP   |
| TestNotificationCenter    | test_postMultipleNotifica | PASS  | SKIP   |
| TestNotificationCenter    | test_postNotification     | PASS  | SKIP   |
| TestNotificationCenter    | test_postNotificationForO | PASS  | SKIP   |
| TestNotificationCenter    | test_removeObserver       | PASS  | SKIP   |
| TestNotificationQueue     | test_defaultQueue         | PASS  | SKIP   |
| TestNotificationQueue     | test_notificationQueueLif | PASS  | SKIP   |
| TestNotificationQueue     | test_postAsapToDefaultQue | PASS  | SKIP   |
| TestNotificationQueue     | test_postAsapToDefaultQue | PASS  | SKIP   |
| TestNotificationQueue     | test_postAsapToDefaultQue | PASS  | SKIP   |
| TestNotificationQueue     | test_postIdleToDefaultQue | PASS  | SKIP   |
| TestNotificationQueue     | test_postNowForDefaultRun | PASS  | SKIP   |
| TestNotificationQueue     | test_postNowToCustomQueue | PASS  | SKIP   |
| TestNotificationQueue     | test_postNowToDefaultQueu | PASS  | SKIP   |
| TestNotificationQueue     | test_postNowToDefaultQueu | PASS  | SKIP   |
| TestNumberFormatter       | test_alwaysShowDecimalSep | PASS  | PASS   |
| TestNumberFormatter       | test_changingLocale       | PASS  | PASS   |
| TestNumberFormatter       | test_copy                 | PASS  | SKIP   |
| TestNumberFormatter       | test_currencyAccountingMi | PASS  | SKIP   |
| TestNumberFormatter       | test_currencyCode         | PASS  | PASS   |
| TestNumberFormatter       | test_currencyDecimalSepar | PASS  | PASS   |
| TestNumberFormatter       | test_currencyGroupingSepa | PASS  | SKIP   |
| TestNumberFormatter       | test_currencyISOCodeMinim | PASS  | SKIP   |
| TestNumberFormatter       | test_currencyMinimumInteg | PASS  | PASS   |
| TestNumberFormatter       | test_currencyPluralMinimu | PASS  | SKIP   |
| TestNumberFormatter       | test_currencySymbol       | PASS  | PASS   |
| TestNumberFormatter       | test_decimalMinimumIntege | PASS  | PASS   |
| TestNumberFormatter       | test_decimalSeparator     | PASS  | PASS   |
| TestNumberFormatter       | test_defaultCurrencyISOCo | PASS  | SKIP   |
| TestNumberFormatter       | test_defaultCurrencyPlura | PASS  | SKIP   |
| TestNumberFormatter       | test_defaultCurrencyPrope | PASS  | PASS   |
| TestNumberFormatter       | test_defaultCurrenyAccoun | PASS  | SKIP   |
| TestNumberFormatter       | test_defaultDecimalProper | PASS  | PASS   |
| TestNumberFormatter       | test_defaultOrdinalProper | PASS  | SKIP   |
| TestNumberFormatter       | test_defaultPercentProper | PASS  | PASS   |
| TestNumberFormatter       | test_defaultPropertyValue | PASS  | PASS   |
| TestNumberFormatter       | test_defaultScientificPro | PASS  | SKIP   |
| TestNumberFormatter       | test_defaultSpelloutPrope | PASS  | SKIP   |
| TestNumberFormatter       | test_en_US_initialValues  | PASS  | SKIP   |
| TestNumberFormatter       | test_exponentSymbol       | PASS  | SKIP   |
| TestNumberFormatter       | test_formatPosition       | PASS  | SKIP   |
| TestNumberFormatter       | test_formatWidth          | PASS  | SKIP   |
| TestNumberFormatter       | test_groupingSeparator    | PASS  | PASS   |
| TestNumberFormatter       | test_groupingSize         | PASS  | SKIP   |
| TestNumberFormatter       | test_internationalCurrenc | PASS  | SKIP   |
| TestNumberFormatter       | test_lenient              | PASS  | SKIP   |
| TestNumberFormatter       | test_maximumFractionDigit | PASS  | PASS   |
| TestNumberFormatter       | test_maximumIntegerDigits | PASS  | PASS   |
| TestNumberFormatter       | test_maximumSignificantDi | PASS  | SKIP   |
| TestNumberFormatter       | test_minimumFractionDigit | PASS  | PASS   |
| TestNumberFormatter       | test_minimumSignificantDi | PASS  | SKIP   |
| TestNumberFormatter       | test_minusSignSymbol      | PASS  | SKIP   |
| TestNumberFormatter       | test_multiplier           | PASS  | PASS   |
| TestNumberFormatter       | test_negativePrefix       | PASS  | PASS   |
| TestNumberFormatter       | test_negativeSuffix       | PASS  | PASS   |
| TestNumberFormatter       | test_notANumberSymbol     | PASS  | PASS   |
| TestNumberFormatter       | test_numberFrom           | PASS  | SKIP   |
| TestNumberFormatter       | test_ordinalMinimumIntege | PASS  | SKIP   |
| TestNumberFormatter       | test_percentMinimumIntege | PASS  | PASS   |
| TestNumberFormatter       | test_percentSymbol        | PASS  | SKIP   |
| TestNumberFormatter       | test_plusSignSymbol       | PASS  | SKIP   |
| TestNumberFormatter       | test_positiveInfinitySymb | PASS  | PASS   |
| TestNumberFormatter       | test_positivePrefix       | PASS  | PASS   |
| TestNumberFormatter       | test_positiveSuffix       | PASS  | PASS   |
| TestNumberFormatter       | test_propertyChanges      | PASS  | PASS   |
| TestNumberFormatter       | test_pt_BR_initialValues  | PASS  | SKIP   |
| TestNumberFormatter       | test_roundingIncrement    | PASS  | SKIP   |
| TestNumberFormatter       | test_roundingMode         | PASS  | SKIP   |
| TestNumberFormatter       | test_scientificMinimumInt | PASS  | SKIP   |
| TestNumberFormatter       | test_scientificStrings    | PASS  | SKIP   |
| TestNumberFormatter       | test_secondaryGroupingSiz | PASS  | SKIP   |
| TestNumberFormatter       | test_settingFormat        | PASS  | SKIP   |
| TestNumberFormatter       | test_spellOutMinimumInteg | PASS  | SKIP   |
| TestNumberFormatter       | test_stringFor            | PASS  | SKIP   |
| TestNumberFormatter       | test_usingFormat          | PASS  | SKIP   |
| TestNumberFormatter       | test_zeroSymbol           | PASS  | SKIP   |
| TestPersonNameComponents  | testCopy                  | PASS  | SKIP   |
| TestPersonNameComponents  | testEquality              | PASS  | SKIP   |
| TestPipe                  | test_Pipe                 | PASS  | ????   |
| TestProcessInfo           | test_environment          | PASS  | SKIP   |
| TestProcessInfo           | test_globallyUniqueString | PASS  | SKIP   |
| TestProcessInfo           | test_operatingSystemVersi | PASS  | SKIP   |
| TestProcessInfo           | test_processName          | PASS  | SKIP   |
| TestProgress              | test_alreadyCancelled     | PASS  | SKIP   |
| TestProgress              | test_childCompletionFinis | PASS  | SKIP   |
| TestProgress              | test_childrenAffectFracti | PASS  | SKIP   |
| TestProgress              | test_childrenAffectFracti | PASS  | SKIP   |
| TestProgress              | test_childrenAffectFracti | PASS  | SKIP   |
| TestProgress              | test_grandchildrenAffectF | PASS  | SKIP   |
| TestProgress              | test_grandchildrenAffectF | PASS  | SKIP   |
| TestProgress              | test_handlers             | PASS  | SKIP   |
| TestProgress              | test_indeterminateChildre | PASS  | SKIP   |
| TestProgress              | test_indeterminateChildre | PASS  | SKIP   |
| TestProgress              | test_mixedExplicitAndImpl | PASS  | SKIP   |
| TestProgress              | test_multipleChildren     | PASS  | SKIP   |
| TestProgress              | test_notReturningNaN      | PASS  | SKIP   |
| TestProgress              | test_totalCompletedChange | PASS  | SKIP   |
| TestProgress              | test_userInfo             | PASS  | SKIP   |
| TestPropertyListEncoder   | test_basicEncodeDecode    | PASS  | SKIP   |
| TestPropertyListEncoder   | test_xmlDecoder           | PASS  | SKIP   |
| TestPropertyListSerializa | test_BasicConstruction    | PASS  | SKIP   |
| TestPropertyListSerializa | test_decodeData           | PASS  | SKIP   |
| TestPropertyListSerializa | test_decodeEmptyData      | PASS  | SKIP   |
| TestPropertyListSerializa | test_decodeStream         | PASS  | SKIP   |
| TestScanner               | testHexFloatingPoint      | PASS  | SKIP   |
| TestScanner               | testHexRepresentation     | PASS  | SKIP   |
| TestScanner               | testInt32                 | PASS  | SKIP   |
| TestScanner               | testInt64                 | PASS  | SKIP   |
| TestScanner               | testLocalizedScanner      | PASS  | SKIP   |
| TestScanner               | testScanCharacter         | PASS  | SKIP   |
| TestScanner               | testScanCharactersFromSet | PASS  | SKIP   |
| TestScanner               | testScanFloatingPoint     | PASS  | SKIP   |
| TestScanner               | testScanString            | PASS  | SKIP   |
| TestScanner               | testScanUpToCharactersFro | PASS  | SKIP   |
| TestScanner               | testScanUpToString        | PASS  | SKIP   |
| TestScanner               | testUInt64                | PASS  | SKIP   |
| TestSocketPort            | testInitPicksATCPPort     | PASS  | ????   |
| TestSocketPort            | testRemoteSocketPortsAreU | PASS  | ????   |
| TestSocketPort            | testSendingOneMessageRemo | PASS  | ????   |
| TestStream                | test_InputStreamHasBytesA | PASS  | ????   |
| TestStream                | test_InputStreamInvalidPa | PASS  | ????   |
| TestStream                | test_InputStreamWithData  | PASS  | ????   |
| TestStream                | test_InputStreamWithFile  | PASS  | ????   |
| TestStream                | test_InputStreamWithUrl   | PASS  | ????   |
| TestStream                | test_ouputStreamWithInval | PASS  | ????   |
| TestStream                | test_outputStreamCreation | PASS  | ????   |
| TestStream                | test_outputStreamCreation | PASS  | ????   |
| TestStream                | test_outputStreamCreation | PASS  | ????   |
| TestStream                | test_outputStreamCreation | PASS  | ????   |
| TestStream                | test_outputStreamHasSpace | PASS  | ????   |
| TestThread                | test_callStackReturnAddre | PASS  | SKIP   |
| TestThread                | test_callStackSymbols     | PASS  | SKIP   |
| TestThread                | test_currentThread        | PASS  | SKIP   |
| TestThread                | test_mainThread           | PASS  | SKIP   |
| TestThread                | test_sleepForTimeInterval | PASS  | PASS   |
| TestThread                | test_sleepUntilDate       | PASS  | PASS   |
| TestThread                | test_threadName           | PASS  | SKIP   |
| TestThread                | test_threadStart          | PASS  | SKIP   |
| TestTimeZone              | test_abbreviation         | PASS  | PASS   |
| TestTimeZone              | test_abbreviationDictiona | PASS  | PASS   |
| TestTimeZone              | test_autoupdatingTimeZone | PASS  | PASS   |
| TestTimeZone              | test_changingDefaultTimeZ | PASS  | PASS   |
| TestTimeZone              | test_computedPropertiesMa | PASS  | SKIP   |
| TestTimeZone              | test_initializingTimeZone | PASS  | SKIP   |
| TestTimeZone              | test_initializingTimeZone | PASS  | SKIP   |
| TestTimeZone              | test_isDaylightSavingTime | PASS  | PASS   |
| TestTimeZone              | test_knownTimeZoneNames   | PASS  | PASS   |
| TestTimeZone              | test_knownTimeZones       | PASS  | PASS   |
| TestTimeZone              | test_localizedName        | PASS  | PASS   |
| TestTimeZone              | test_nextDaylightSavingTi | PASS  | PASS   |
| TestTimeZone              | test_systemTimeZoneName   | PASS  | PASS   |
| TestTimeZone              | test_systemTimeZoneUsesSy | PASS  | SKIP   |
| TestTimeZone              | test_tz_customMirror      | PASS  | SKIP   |
| TestTimer                 | test_timerInit            | PASS  | SKIP   |
| TestTimer                 | test_timerInvalidate      | PASS  | SKIP   |
| TestTimer                 | test_timerTickOnce        | PASS  | SKIP   |
| TestURL                   | test_URLByResolvingSymlin | PASS  | SKIP   |
| TestURL                   | test_URLByResolvingSymlin | PASS  | SKIP   |
| TestURL                   | test_URLByResolvingSymlin | PASS  | SKIP   |
| TestURL                   | test_URLByResolvingSymlin | PASS  | SKIP   |
| TestURL                   | test_URLResourceValues    | PASS  | SKIP   |
| TestURL                   | test_URLStrings           | PASS  | SKIP   |
| TestURL                   | test_copy                 | PASS  | SKIP   |
| TestURL                   | test_dataRepresentation   | PASS  | SKIP   |
| TestURL                   | test_description          | PASS  | SKIP   |
| TestURL                   | test_fileURLWithPath      | PASS  | SKIP   |
| TestURL                   | test_fileURLWithPath_isDi | PASS  | SKIP   |
| TestURL                   | test_fileURLWithPath_rela | PASS  | SKIP   |
| TestURL                   | test_reachable            | PASS  | SKIP   |
| TestURL                   | test_relativeFilePath     | PASS  | SKIP   |
| TestURL                   | test_resolvingSymlinksInP | PASS  | SKIP   |
| TestURL                   | test_resolvingSymlinksInP | PASS  | SKIP   |
| TestURL                   | test_resolvingSymlinksInP | PASS  | SKIP   |
| TestURL                   | test_resolvingSymlinksInP | PASS  | SKIP   |
| TestURL                   | test_resolvingSymlinksInP | PASS  | SKIP   |
| TestURL                   | test_resolvingSymlinksInP | PASS  | SKIP   |
| TestURLCache              | testNoDiskUsageIfDisabled | PASS  | ????   |
| TestURLCache              | testNoMemoryUsageIfDisabl | PASS  | ????   |
| TestURLCache              | testRemovingAll           | PASS  | ????   |
| TestURLCache              | testRemovingOne           | PASS  | ????   |
| TestURLCache              | testRemovingSince         | PASS  | ????   |
| TestURLCache              | testShrinkingDiskCapacity | PASS  | ????   |
| TestURLCache              | testShrinkingMemoryCapaci | PASS  | ????   |
| TestURLCache              | testStoragePolicy         | PASS  | ????   |
| TestURLCache              | testStorageRoundtrip      | PASS  | ????   |
| TestURLCache              | testStoringTwiceOnlyHasOn | PASS  | ????   |
| TestURLComponents         | test_copy                 | PASS  | SKIP   |
| TestURLComponents         | test_createURLWithCompone | PASS  | SKIP   |
| TestURLComponents         | test_createURLWithCompone | PASS  | SKIP   |
| TestURLComponents         | test_hash                 | PASS  | SKIP   |
| TestURLComponents         | test_path                 | PASS  | SKIP   |
| TestURLComponents         | test_percentEncodedPath   | PASS  | SKIP   |
| TestURLComponents         | test_percentEncodedQueryI | PASS  | SKIP   |
| TestURLComponents         | test_portSetter           | PASS  | SKIP   |
| TestURLComponents         | test_queryItems           | PASS  | SKIP   |
| TestURLComponents         | test_string               | PASS  | SKIP   |
| TestURLComponents         | test_url                  | PASS  | SKIP   |
| TestURLCredential         | test_construction         | PASS  | SKIP   |
| TestURLCredential         | test_copy                 | PASS  | SKIP   |
| TestURLCredentialStorage  | test_sessionCredentialBec | PASS  | ????   |
| TestURLCredentialStorage  | test_sessionCredentialCan | PASS  | ????   |
| TestURLCredentialStorage  | test_sessionCredentialDoe | PASS  | ????   |
| TestURLCredentialStorage  | test_sessionCredentialDoe | PASS  | ????   |
| TestURLCredentialStorage  | test_sessionCredentialDoe | PASS  | ????   |
| TestURLCredentialStorage  | test_sessionCredentialGet | PASS  | ????   |
| TestURLCredentialStorage  | test_sessionCredentialGet | PASS  | ????   |
| TestURLCredentialStorage  | test_sessionCredentialGet | PASS  | ????   |
| TestURLCredentialStorage  | test_sessionDefaultCreden | PASS  | ????   |
| TestURLCredentialStorage  | test_storageCanRemoveArbi | PASS  | ????   |
| TestURLCredentialStorage  | test_storageStartsEmpty   | PASS  | ????   |
| TestURLCredentialStorage  | test_storageWillNotSaveCr | PASS  | ????   |
| TestURLCredentialStorage  | test_storageWillNotSendNo | PASS  | ????   |
| TestURLCredentialStorage  | test_storageWillNotSendNo | PASS  | ????   |
| TestURLCredentialStorage  | test_storageWillNotSendNo | PASS  | ????   |
| TestURLCredentialStorage  | test_storageWillSendNotif | PASS  | ????   |
| TestURLCredentialStorage  | test_storageWillSendNotif | PASS  | ????   |
| TestURLCredentialStorage  | test_storageWillSendNotif | PASS  | ????   |
| TestURLCredentialStorage  | test_storageWillSendNotif | PASS  | ????   |
| TestURLCredentialStorage  | test_storageWillSendNotif | PASS  | ????   |
| TestURLCredentialStorage  | test_storageWillSendNotif | PASS  | ????   |
| TestURLCredentialStorage  | test_taskBasedGetCredenti | PASS  | ????   |
| TestURLCredentialStorage  | test_taskBasedGetDefaultC | PASS  | ????   |
| TestURLCredentialStorage  | test_taskBasedRemoveCrede | PASS  | ????   |
| TestURLCredentialStorage  | test_taskBasedSetCredenti | PASS  | ????   |
| TestURLCredentialStorage  | test_taskBasedSetDefaultC | PASS  | ????   |
| TestURLProtectionSpace    | test_description          | PASS  | ????   |
| TestURLRequest            | test_construction         | PASS  | PASS   |
| TestURLRequest            | test_copy                 | PASS  | PASS   |
| TestURLRequest            | test_description          | PASS  | PASS   |
| TestURLRequest            | test_hash                 | PASS  | SKIP   |
| TestURLRequest            | test_headerFields         | PASS  | PASS   |
| TestURLRequest            | test_invalidHeaderValues  | PASS  | SKIP   |
| TestURLRequest            | test_methodNormalization  | PASS  | PASS   |
| TestURLRequest            | test_mutableConstruction  | PASS  | PASS   |
| TestURLRequest            | test_mutableCopy_1        | PASS  | PASS   |
| TestURLRequest            | test_mutableCopy_2        | PASS  | PASS   |
| TestURLRequest            | test_mutableCopy_3        | PASS  | PASS   |
| TestURLRequest            | test_relativeURL          | PASS  | SKIP   |
| TestURLRequest            | test_validLineFoldedHeade | PASS  | PASS   |
| TestURLResponse           | test_ExpectedContentLengt | PASS  | PASS   |
| TestURLResponse           | test_MIMEType             | PASS  | PASS   |
| TestURLResponse           | test_TextEncodingName     | PASS  | PASS   |
| TestURLResponse           | test_URL                  | PASS  | PASS   |
| TestURLResponse           | test_copyWithZone         | PASS  | PASS   |
| TestURLResponse           | test_equalCheckingExpecte | PASS  | PASS   |
| TestURLResponse           | test_equalCheckingMimeTyp | PASS  | PASS   |
| TestURLResponse           | test_equalCheckingTextEnc | PASS  | PASS   |
| TestURLResponse           | test_equalCheckingURL     | PASS  | PASS   |
| TestURLResponse           | test_equalWithTheSameInst | PASS  | PASS   |
| TestURLResponse           | test_equalWithUnrelatedOb | PASS  | PASS   |
| TestURLResponse           | test_hash                 | PASS  | PASS   |
| TestURLResponse           | test_suggestedFilename_1  | PASS  | PASS   |
| TestURLResponse           | test_suggestedFilename_2  | PASS  | PASS   |
| TestURLResponse           | test_suggestedFilename_3  | PASS  | PASS   |
| TestUUID                  | test_UUIDEquality         | PASS  | SKIP   |
| TestUUID                  | test_UUIDInvalid          | PASS  | PASS   |
| TestUUID                  | test_UUIDdescription      | PASS  | PASS   |
| TestUUID                  | test_UUIDuuidString       | PASS  | SKIP   |
| TestUUID                  | test_hash                 | PASS  | PASS   |
| TestUnit                  | test_equality             | PASS  | SKIP   |
| TestUnitConverter         | test_baseUnit             | PASS  | SKIP   |
| TestUnitConverter         | test_bijectivity          | PASS  | SKIP   |
| TestUnitConverter         | test_equality             | PASS  | SKIP   |
| TestUnitConverter         | test_linearity            | PASS  | SKIP   |
| TestUnitInformationStorag | testUnitInformationStorag | PASS  | SKIP   |
| TestUnitVolume            | testImperialVolumeConvers | PASS  | SKIP   |
| TestUnitVolume            | testMetricToImperialVolum | PASS  | SKIP   |
| TestUnitVolume            | testMetricVolumeConversio | PASS  | SKIP   |
| TestUserDefaults          | test_createUserDefaults   | PASS  | PASS   |
| TestUserDefaults          | test_getRegisteredDefault | PASS  | PASS   |
| TestUserDefaults          | test_getRegisteredDefault | PASS  | PASS   |
| TestUserDefaults          | test_getRegisteredDefault | PASS  | PASS   |
| TestUserDefaults          | test_getRegisteredDefault | PASS  | PASS   |
| TestUserDefaults          | test_getRegisteredDefault | PASS  | PASS   |
| TestUserDefaults          | test_getRegisteredDefault | PASS  | PASS   |
| TestUserDefaults          | test_getRegisteredDefault | PASS  | PASS   |
| TestUserDefaults          | test_getRegisteredDefault | PASS  | PASS   |
| TestUserDefaults          | test_getRegisteredDefault | PASS  | PASS   |
| TestUserDefaults          | test_getRegisteredDefault | PASS  | PASS   |
| TestUserDefaults          | test_persistentDomain     | PASS  | SKIP   |
| TestUserDefaults          | test_setValue_BoolFromStr | PASS  | PASS   |
| TestUserDefaults          | test_setValue_Data        | PASS  | PASS   |
| TestUserDefaults          | test_setValue_DoubleFromS | PASS  | PASS   |
| TestUserDefaults          | test_setValue_IntFromStri | PASS  | PASS   |
| TestUserDefaults          | test_setValue_NSData      | PASS  | PASS   |
| TestUserDefaults          | test_setValue_NSString    | PASS  | PASS   |
| TestUserDefaults          | test_setValue_NSURL       | PASS  | PASS   |
| TestUserDefaults          | test_setValue_String      | PASS  | PASS   |
| TestUserDefaults          | test_setValue_URL         | PASS  | PASS   |
| TestUserDefaults          | test_volatileDomains      | PASS  | SKIP   |
| TestXMLDocument           | test_addNamespace         | PASS  | ????   |
| TestXMLDocument           | test_attributes           | PASS  | ????   |
| TestXMLDocument           | test_attributesWithNamesp | PASS  | ????   |
| TestXMLDocument           | test_basicCreation        | PASS  | ????   |
| TestXMLDocument           | test_comments             | PASS  | ????   |
| TestXMLDocument           | test_createElement        | PASS  | ????   |
| TestXMLDocument           | test_creatingAnEmptyDTD   | PASS  | ????   |
| TestXMLDocument           | test_creatingAnEmptyDocum | PASS  | ????   |
| TestXMLDocument           | test_documentWithDTD      | PASS  | ????   |
| TestXMLDocument           | test_documentWithEncoding | PASS  | ????   |
| TestXMLDocument           | test_dtd                  | PASS  | ????   |
| TestXMLDocument           | test_dtd_attributes       | PASS  | ????   |
| TestXMLDocument           | test_elementChildren      | PASS  | ????   |
| TestXMLDocument           | test_elementCreation      | PASS  | ????   |
| TestXMLDocument           | test_nextPreviousNode     | PASS  | ????   |
| TestXMLDocument           | test_nodeFindingWithNames | PASS  | ????   |
| TestXMLDocument           | test_nodeKinds            | PASS  | ????   |
| TestXMLDocument           | test_nodeNames            | PASS  | ????   |
| TestXMLDocument           | test_objectValue          | PASS  | ????   |
| TestXMLDocument           | test_optionPreserveAll    | PASS  | ????   |
| TestXMLDocument           | test_parseXMLString       | PASS  | ????   |
| TestXMLDocument           | test_parsingCDataSections | PASS  | ????   |
| TestXMLDocument           | test_prefixes             | PASS  | ????   |
| TestXMLDocument           | test_processingInstructio | PASS  | ????   |
| TestXMLDocument           | test_removeNamespace      | PASS  | ????   |
| TestXMLDocument           | test_rootElementRetainsDo | PASS  | ????   |
| TestXMLDocument           | test_stringValue          | PASS  | ????   |
| TestXMLDocument           | test_validation_failure   | PASS  | ????   |
| TestXMLDocument           | test_validation_success   | PASS  | ????   |
| TestXMLDocument           | test_xpath                | PASS  | ????   |
| TestXMLParser             | test_sr10157_swappedEleme | PASS  | SKIP   |
| TestXMLParser             | test_sr9758_abortParsing  | PASS  | SKIP   |
| TestXMLParser             | test_withData             | PASS  | SKIP   |
| TestXMLParser             | test_withDataEncodings    | PASS  | SKIP   |
| TestXMLParser             | test_withDataOptions      | PASS  | SKIP   |
| URLTests                  | testAsyncBytes            | PASS  | PASS   |
| URLTests                  | testAsyncStream           | PASS  | SKIP   |
| URLTests                  | testDefaultURLSessionConf | PASS  | PASS   |
| URLTests                  | testDownloadURLAsync      | PASS  | PASS   |
| URLTests                  | testEphemeralURLSessionCo | PASS  | PASS   |
| URLTests                  | testFetchURLAsync         | PASS  | PASS   |
| URLTests                  | testURLs                  | PASS  | PASS   |
| UUIDTests                 | testFixedUUID             | PASS  | PASS   |
| UUIDTests                 | testRandomUUID            | PASS  | PASS   |
| UUIDTests                 | testUUIDFromBits          | PASS  | PASS   |
| UUIDTests                 | test_UUIDEquality         | PASS  | PASS   |
| UUIDTests                 | test_UUIDInvalid          | PASS  | PASS   |
| UUIDTests                 | test_UUIDdescription      | PASS  | PASS   |
| XCSkipTests               | testSkipModule            | PASS  | ????   |
|                           |                           | 100%  | 19%    |



