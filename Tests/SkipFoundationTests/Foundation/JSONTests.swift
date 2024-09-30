// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org
import OSLog
import XCTest
import Foundation

@available(macOS 11, iOS 14, watchOS 7, tvOS 14, *)
class TestJSON : XCTestCase {
    fileprivate let logger: Logger = Logger(subsystem: "test", category: "TestJSON")

    struct StringField : Equatable, Codable {
        var stringField: String
    }

    struct IntField : Equatable, Codable {
        var intField: Int
    }

    struct BoolField : Equatable, Codable {
        var boolField: Bool
    }

    struct FloatField : Equatable, Codable {
        var floatField: Float
    }

    struct DoubleField : Equatable, Codable {
        var doubleField: Double
    }

    struct DataField : Equatable, Codable {
        var dataField: Data
    }

    struct DateField : Equatable, Codable {
        var dateField: Date
    }

    struct URLField : Equatable, Codable {
        var urlField: URL
    }

    struct UUIDField : Equatable, Codable {
        var uuidField: UUID
    }

    struct UUIDArrayField : Equatable, Codable {
        var uuidArrayField: Array<UUID>
    }

    struct StringArrayField : Equatable, Codable {
        var stringArrayField: Array<String>
    }

    struct IntArrayField : Equatable, Codable {
        var intArrayField: Array<Int>
    }

    struct CustomSingleValueIntArrayField : Codable {
        var intArrayField: Array<Int>

        init(intArrayField: Array<Int>) {
            self.intArrayField = intArrayField
        }

        init(from decoder: Decoder) throws {
            var container = try decoder.singleValueContainer()
            intArrayField = try container.decode([Int].self)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(intArrayField)
        }
    }

    struct UIntArrayField : Equatable, Codable {
        var uintArrayField: Array<UInt>
    }

    struct Int8ArrayField : Equatable, Codable {
        var int8ArrayField: Array<Int8>
    }

    struct UInt8ArrayField : Equatable, Codable {
        var uint8ArrayField: Array<UInt8>
    }

    struct Int16ArrayField : Equatable, Codable {
        var int16ArrayField: Array<Int16>
    }

    struct UInt16ArrayField : Equatable, Codable {
        var uint16ArrayField: Array<UInt16>
    }

    struct Int32ArrayField : Equatable, Codable {
        var int32ArrayField: Array<Int32>
    }

    struct UInt32ArrayField : Equatable, Codable {
        var uint32ArrayField: Array<UInt32>
    }

    struct Int64ArrayField : Equatable, Codable {
        var int64ArrayField: Array<Int64>
    }

    struct UInt64ArrayField : Equatable, Codable {
        var uint64ArrayField: Array<UInt64>
    }

    struct FloatArrayField : Equatable, Codable {
        var floatArrayField: Array<Float>
    }

    struct DoubleArrayField : Equatable, Codable {
        var doubleArrayField: Array<Double>
    }

    struct BoolArrayField : Equatable, Codable {
        var boolArrayField: Array<Bool>
    }

    struct BoolArrayArrayField : Equatable, Encodable {
        var boolArrayArrayField: Array<Array<Bool>>
    }

    struct BoolArrayArrayArrayField : Equatable, Encodable {
        var boolArrayArrayArrayField: Array<Array<Array<Bool>>>
    }

    struct StringSetField : Equatable, Codable {
        var stringSetField: Set<String>
    }

    struct EmptyField : Equatable, Codable {
    }

    struct Person : Equatable, Codable {
        var firstName: String
        var lastName: String
        var age: Int?
        var height: Double?
        var isStudent: Bool?
        var friends: [Person]?
    }

    struct Org : Equatable, Codable {
        var head: Person?
        var people: [Person]
        var departmentHeads: [String: Person]
        var departmentMembers: [String: [Person]]
    }

    struct ManualPerson: Codable {
        let name: String
        let age: Int

        init(name: String, age: Int) {
            self.name = name
            self.age = age
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try container.decode(String.self, forKey: .nameX)
            age = try container.decode(Int.self, forKey: .ageX)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .nameX)
            try container.encode(age, forKey: .ageX)
        }

        enum CodingKeys: String, CodingKey {
            case nameX
            case ageX
        }
    }

    struct MyTestData: Codable, Equatable {
        let thisIsAString: String
        let thisIsABool: Bool
        let thisIsAnInt: Int
        let thisIsAnInt8: Int8
        let thisIsAnInt16: Int16
        let thisIsAnInt32: Int32
        let thisIsAnInt64: Int64
        let thisIsAUint: UInt
        let thisIsAUint8: UInt8
        let thisIsAUint16: UInt16
        let thisIsAUint32: UInt32
        let thisIsAUint64: UInt64
        let thisIsAFloat: Float
        let thisIsADouble: Double
        let thisIsADate: Date
        let thisIsAnArray: Array<Int>
        let thisIsADictionary: Dictionary<String, Bool>
    }

    @inline(__always) private func enc<T: Encodable>(_ value: T, fmt: JSONEncoder.OutputFormatting? = .sortedKeys, data: JSONEncoder.DataEncodingStrategy? = nil, date: JSONEncoder.DateEncodingStrategy? = nil, floats: JSONEncoder.NonConformingFloatEncodingStrategy? = nil, keys: JSONEncoder.KeyEncodingStrategy? = nil) throws -> String {
        let encoder = JSONEncoder()
        if let fmt = fmt {
            encoder.outputFormatting = fmt
        }
        if let data = data {
            encoder.dataEncodingStrategy = data
        }
        if let date = date {
            encoder.dateEncodingStrategy = date
        }
        if let floats = floats {
            encoder.nonConformingFloatEncodingStrategy = floats
        }
        if let keys = keys {
            encoder.keyEncodingStrategy = keys
        }
        let data = try encoder.encode(value)
        return String(data: data, encoding: .utf8) ?? ""
    }

    /// Round-trip a type
    @inline(__always) private func roundtrip<T>(value: T, fmt: JSONEncoder.OutputFormatting? = .sortedKeys, data: JSONEncoder.DataEncodingStrategy? = nil, date: JSONEncoder.DateEncodingStrategy? = nil, floats: JSONEncoder.NonConformingFloatEncodingStrategy? = nil, keys: JSONEncoder.KeyEncodingStrategy? = nil, dkeys: JSONDecoder.KeyDecodingStrategy? = nil) throws -> String where T : Encodable, T : Decodable, T : Equatable {
        let json = try enc(value, fmt: fmt, data: data, date: date, floats: floats, keys: keys)

        let decoder = JSONDecoder()
        if let dkeys {
            decoder.keyDecodingStrategy = dkeys
        }
        let value2 = try decoder.decode(T.self, from: json.data(using: String.Encoding.utf8)!)
        XCTAssertEqual(value, value2)

        return json
    }

    func testJSONCodable() throws {

        XCTAssertEqual(#"{"intField":1}"#, try roundtrip(value: IntField(intField: Int(1))))

        // difference between ObjC and native Swift JSONEncoder
        //XCTAssertEqual(#"{"floatField":1.1000000238418579}"#, try enc(FloatField(floatField: Float(1.1))))
        XCTAssertEqual(#"{"floatField":1.5}"#, try roundtrip(value: FloatField(floatField: Float(1.5))))
        XCTAssertEqual(#"{"stringField":"ABC"}"#, try roundtrip(value: StringField(stringField: "ABC")))
        XCTAssertEqual(#"{"stringField":"ABC\/XYZ"}"#, try roundtrip(value: StringField(stringField: "ABC/XYZ")))

        XCTAssertEqual(#"{"dataField":"AQI="}"#, try roundtrip(value: DataField(dataField: Data([UInt8(0x01), UInt8(0x02)]))))
        XCTAssertEqual(#"{"dataField":"AQI="}"#, try enc(DataField(dataField: Data([UInt8(0x01), UInt8(0x02)])), data: .base64 as JSONEncoder.DataEncodingStrategy))
        XCTAssertEqual(#"{"dataField":3}"#, try enc(DataField(dataField: Data([UInt8(0x01), UInt8(0x02), UInt8(0x03)])), data: .custom({ data, encoder in var container = encoder.singleValueContainer(); try container.encode(data.count) }) as JSONEncoder.DataEncodingStrategy))
        XCTAssertEqual(#"{"dataField":[1,2]}"#, try enc(DataField(dataField: Data([UInt8(0x01), UInt8(0x02)])), data: .deferredToData as JSONEncoder.DataEncodingStrategy))

        XCTAssertEqual(#"{"dateField":-1}"#, try enc(DateField(dateField: Date(timeIntervalSinceReferenceDate: -1.0))))

        XCTAssertEqual(#"{"dateField":1}"#, try enc(DateField(dateField: Date(timeIntervalSince1970: 1.0)), date: .secondsSince1970 as JSONEncoder.DateEncodingStrategy))
        XCTAssertEqual(#"{"dateField":"1970-01-01T00:00:01Z"}"#, try enc(DateField(dateField: Date(timeIntervalSince1970: 1.0)), date: .iso8601 as JSONEncoder.DateEncodingStrategy))

        let df = DateFormatter()
        df.dateFormat = "YYYY"
        XCTAssertEqual(#"{"dateField":"1970"}"#, try enc(DateField(dateField: Date(timeIntervalSince1970: 1.0)), date: .formatted(df) as JSONEncoder.DateEncodingStrategy))

        XCTAssertEqual(#"{"dateField":true}"#, try enc(DateField(dateField: Date(timeIntervalSince1970: 1.0)), date: .custom({ date, encoder in var container = encoder.singleValueContainer(); try container.encode(true) }) as JSONEncoder.DateEncodingStrategy))

        XCTAssertEqual(#"{"dateField":9}"#, try enc(DateField(dateField: Date(timeIntervalSince1970: 1.0)), date: .custom({ date, encoder in var container = encoder.singleValueContainer(); try container.encode(encoder.codingPath.last!.stringValue.count) }) as JSONEncoder.DateEncodingStrategy))

        XCTAssertEqual(#"{"uuidField":"A53BAA1C-B4F5-48DB-9567-9786B76B256C"}"#, try roundtrip(value: UUIDField(uuidField: UUID(uuidString: "a53baa1c-b4f5-48db-9567-9786b76b256c")!)))

        XCTAssertEqual(#"{"stringArrayField":["ABC","XYZ"]}"#, try roundtrip(value: StringArrayField(stringArrayField: ["ABC", "XYZ"])))
        XCTAssertEqual(#"{"intArrayField":[1,2]}"#, try roundtrip(value: IntArrayField(intArrayField: [1,2])))
        XCTAssertEqual(#"{"floatArrayField":[1,2]}"#, try roundtrip(value: FloatArrayField(floatArrayField: [Float(1.0),Float(2.0)])))
        XCTAssertEqual(#"{"int8ArrayField":[1,2]}"#, try roundtrip(value: Int8ArrayField(int8ArrayField: [Int8(1),Int8(2)])))
        XCTAssertEqual(#"{"uint8ArrayField":[1,2]}"#, try roundtrip(value: UInt8ArrayField(uint8ArrayField: [UInt8(1),UInt8(2)])))

        XCTAssertEqual(#"{"uuidArrayField":["A53BAA1C-B4F5-48DB-9567-9786B76B256C"]}"#, try roundtrip(value: UUIDArrayField(uuidArrayField: [UUID(uuidString: "a53baa1c-b4f5-48db-9567-9786b76b256c")!])))

        XCTAssertEqual(#"{"boolArrayField":[false,true]}"#, try roundtrip(value: BoolArrayField(boolArrayField: [false,true])))
        XCTAssertEqual(#"{"boolArrayArrayField":[[false,true]]}"#, try enc(BoolArrayArrayField(boolArrayArrayField: [[false,true]])))
        XCTAssertEqual(#"{"boolArrayArrayArrayField":[[[false,true],[false,true]],[[false,true],[false,true]]]}"#, try enc(BoolArrayArrayArrayField(boolArrayArrayArrayField: [[[false,true],[false,true]],[[false,true],[false,true]]])))

        XCTAssertEqual(#"{}"#, try roundtrip(value: EmptyField()))

        let testData = MyTestData(thisIsAString: "ABC", thisIsABool: true, thisIsAnInt: 1, thisIsAnInt8: Int8(2), thisIsAnInt16: Int16(3), thisIsAnInt32: Int32(4), thisIsAnInt64: Int64(5), thisIsAUint: UInt(6), thisIsAUint8: UInt8(7), thisIsAUint16: UInt16(8), thisIsAUint32: UInt32(9), thisIsAUint64: UInt64(10), thisIsAFloat: Float(11.0), thisIsADouble: Double(12.0), thisIsADate: Date(timeIntervalSinceReferenceDate: 12345.0), thisIsAnArray: [-1,0,1], thisIsADictionary: ["X": true, "Y": false])

        // TODO: Key sorting inconsistency
        #if SKIP
        XCTAssertEqual("""
        {
          "thisIsABool" : true,
          "thisIsADate" : 12345,
          "thisIsADictionary" : {
            "X" : true,
            "Y" : false
          },
          "thisIsADouble" : 12,
          "thisIsAFloat" : 11,
          "thisIsAString" : "ABC",
          "thisIsAUint" : 6,
          "thisIsAUint16" : 8,
          "thisIsAUint32" : 9,
          "thisIsAUint64" : 10,
          "thisIsAUint8" : 7,
          "thisIsAnArray" : [
            -1,
            0,
            1
          ],
          "thisIsAnInt" : 1,
          "thisIsAnInt16" : 3,
          "thisIsAnInt32" : 4,
          "thisIsAnInt64" : 5,
          "thisIsAnInt8" : 2
        }
        """, try roundtrip(value: testData, fmt: [.prettyPrinted, .sortedKeys] as JSONEncoder.OutputFormatting))
        #else
        XCTAssertEqual("""
        {
          "thisIsABool" : true,
          "thisIsADate" : 12345,
          "thisIsADictionary" : {
            "X" : true,
            "Y" : false
          },
          "thisIsADouble" : 12,
          "thisIsAFloat" : 11,
          "thisIsAnArray" : [
            -1,
            0,
            1
          ],
          "thisIsAnInt" : 1,
          "thisIsAnInt8" : 2,
          "thisIsAnInt16" : 3,
          "thisIsAnInt32" : 4,
          "thisIsAnInt64" : 5,
          "thisIsAString" : "ABC",
          "thisIsAUint" : 6,
          "thisIsAUint8" : 7,
          "thisIsAUint16" : 8,
          "thisIsAUint32" : 9,
          "thisIsAUint64" : 10
        }
        """, try roundtrip(value: testData, fmt: [.prettyPrinted, .sortedKeys] as JSONEncoder.OutputFormatting))
        #endif
        
        #if SKIP
        XCTAssertEqual("""
        {
          "this_is_a_bool" : true,
          "this_is_a_date" : 12345,
          "this_is_a_dictionary" : {
            "X" : true,
            "Y" : false
          },
          "this_is_a_double" : 12,
          "this_is_a_float" : 11,
          "this_is_a_string" : "ABC",
          "this_is_a_uint" : 6,
          "this_is_a_uint16" : 8,
          "this_is_a_uint32" : 9,
          "this_is_a_uint64" : 10,
          "this_is_a_uint8" : 7,
          "this_is_an_array" : [
            -1,
            0,
            1
          ],
          "this_is_an_int" : 1,
          "this_is_an_int16" : 3,
          "this_is_an_int32" : 4,
          "this_is_an_int64" : 5,
          "this_is_an_int8" : 2
        }
        """, try enc(testData, fmt: [.prettyPrinted, .sortedKeys] as JSONEncoder.OutputFormatting, keys: .convertToSnakeCase as JSONEncoder.KeyEncodingStrategy))
        #else
        XCTAssertEqual("""
        {
          "this_is_a_bool" : true,
          "this_is_a_date" : 12345,
          "this_is_a_dictionary" : {
            "X" : true,
            "Y" : false
          },
          "this_is_a_double" : 12,
          "this_is_a_float" : 11,
          "this_is_a_string" : "ABC",
          "this_is_a_uint" : 6,
          "this_is_a_uint8" : 7,
          "this_is_a_uint16" : 8,
          "this_is_a_uint32" : 9,
          "this_is_a_uint64" : 10,
          "this_is_an_array" : [
            -1,
            0,
            1
          ],
          "this_is_an_int" : 1,
          "this_is_an_int8" : 2,
          "this_is_an_int16" : 3,
          "this_is_an_int32" : 4,
          "this_is_an_int64" : 5
        }
        """, try enc(testData, fmt: [.prettyPrinted, .sortedKeys] as JSONEncoder.OutputFormatting, keys: .convertToSnakeCase as JSONEncoder.KeyEncodingStrategy))
        #endif

        XCTAssertEqual(#"{"ageX":123,"nameX":"ABC"}"#, try enc(ManualPerson(name: "ABC", age: 123)))

        let p1 = Person(firstName: "Jon", lastName: "Doe", height: 180.5)
        let p2 = Person(firstName: "Jan", lastName: "Noe", height: 170.0)
        let p3 = Person(firstName: "Jim", lastName: "Bro", height: 190.0)

        XCTAssertEqual(#"{"firstName":"Jon","height":180.5,"lastName":"Doe"}"#, try roundtrip(value: p1))
        XCTAssertEqual("""
        {
          "firstName" : "Jon",
          "height" : 180.5,
          "lastName" : "Doe"
        }
        """, try roundtrip(value: p1, fmt: [.prettyPrinted, .sortedKeys] as JSONEncoder.OutputFormatting))
        XCTAssertEqual(#"{"first_name":"Jon","height":180.5,"last_name":"Doe"}"#, try roundtrip(value: p1, keys: JSONEncoder.KeyEncodingStrategy.convertToSnakeCase, dkeys: JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase))

        let org = Org(head: p2, people: [p1, p3], departmentHeads: ["X":p2, "Y": p3], departmentMembers: ["Y":[p1], "X": [p2, p1]])
        XCTAssertEqual("""
            {
              "departmentHeads" : {
                "X" : {
                  "firstName" : "Jan",
                  "height" : 170,
                  "lastName" : "Noe"
                },
                "Y" : {
                  "firstName" : "Jim",
                  "height" : 190,
                  "lastName" : "Bro"
                }
              },
              "departmentMembers" : {
                "X" : [
                  {
                    "firstName" : "Jan",
                    "height" : 170,
                    "lastName" : "Noe"
                  },
                  {
                    "firstName" : "Jon",
                    "height" : 180.5,
                    "lastName" : "Doe"
                  }
                ],
                "Y" : [
                  {
                    "firstName" : "Jon",
                    "height" : 180.5,
                    "lastName" : "Doe"
                  }
                ]
              },
              "head" : {
                "firstName" : "Jan",
                "height" : 170,
                "lastName" : "Noe"
              },
              "people" : [
                {
                  "firstName" : "Jon",
                  "height" : 180.5,
                  "lastName" : "Doe"
                },
                {
                  "firstName" : "Jim",
                  "height" : 190,
                  "lastName" : "Bro"
                }
              ]
            }
            """, try roundtrip(value: org, fmt: [.prettyPrinted, .sortedKeys] as JSONEncoder.OutputFormatting))

        let personJSON = """
        {
            "firstName" : "Jon",
            "height" : 180.5,
            "lastName" : "Doe",
            "age" : null
        }
        """
        let decodedPerson = try JSONDecoder().decode(Person.self, from: personJSON.data(using: String.Encoding.utf8)!)
        XCTAssertEqual(decodedPerson.firstName, "Jon")
    }

    func testSingleValueArrayJSONCodable() throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(CustomSingleValueIntArrayField(intArrayField: [1, 2]))
        let string = String(data: data, encoding: .utf8) ?? ""
        XCTAssertEqual(string, "[1,2]")
        let decoder = JSONDecoder()
        let obj = try decoder.decode(CustomSingleValueIntArrayField.self, from: data)
        XCTAssertEqual(obj.intArrayField, [1, 2])
    }

    struct EntityCustomKeys : Encodable {
        var nameFirst: String
        var nameLast: String
        var age: Int

        enum CodingKeys : String, RawRepresentable, CodingKey {
            case nameFirst = "firstName"
            case nameLast = "lastName"
            case age
        }
    }

    func testEncodeToJSON() throws {

        let person = EntityCustomKeys(nameFirst: "Jon", nameLast: "Doe", age: 44)

        XCTAssertEqual("firstName", EntityCustomKeys.CodingKeys.nameFirst.rawValue)
        XCTAssertEqual("Jon", person.nameFirst)
        XCTAssertEqual("Doe", person.nameLast)
        XCTAssertEqual(44, person.age)

//        let json: JSON = try person.json()
//        XCTAssertEqual(JSON.number(44.0), json.obj?["age"])
//        XCTAssertEqual(JSON.string("Jon"), json.obj?["firstName"])
//        XCTAssertEqual(JSON.string("Doe"), json.obj?["lastName"])
//        XCTAssertEqual(#"{"age":44.0,"firstName":"Jon","lastName":"Doe"}"#, json.stringify())
    }

//    func testJSONParse() throws {
//        XCTAssertEqual(JSON.null, try JSON.parse("null"))
//        XCTAssertEqual(JSON.string("ABC"), try JSON.parse(#""ABC""#))
//        XCTAssertEqual(JSON.bool(true), try JSON.parse("true"))
//        XCTAssertEqual(JSON.bool(false), try JSON.parse("false"))
//        XCTAssertEqual(JSON.number(0.1), try JSON.parse("0.1"))
//        #if SKIP
//        XCTAssertEqual(JSON.number(0.0), try JSON.parse("0"))
//        #else
//        XCTAssertEqual(JSON.number(0), try JSON.parse("0"))
//        #endif
//
//        let json = try JSON.parse("""
//        {
//            "a": 1.1,
//            "b": true,
//            "d": "XYZ",
//            "e": [-9, true, null, {
//                "x": "q",
//                "y": 0.1,
//                "z": [[[[[false]]], true]]
//            }, [null]]
//        }
//        """)
//
//        #if !SKIP // TODO: subscripts and literal initializers
//        XCTAssertEqual(1.1, json["a"])
//        XCTAssertEqual(true, json["b"])
//        XCTAssertEqual(nil, json["c"])
//        XCTAssertEqual("XYZ", json["d"])
//        XCTAssertEqual(5, json["e"]?.count)
//        #endif
//
//        // equivalent (but more verbose) comparisons
//        XCTAssertEqual(JSON.number(1.1), json.obj?["a"])
//        XCTAssertEqual(JSON.bool(true), json.obj?["b"])
//        XCTAssertEqual(nil, json.obj?["c"])
//        XCTAssertEqual(JSON.string("XYZ"), json.obj?["d"])
//        XCTAssertEqual(5, json.obj?["e"]?.count)
//
//
//        let json2 = try JSON.parse(json.stringify(pretty: false))
//        XCTAssertEqual(json, json2, "re-parsed plain JSON should have been equal")
//        XCTAssertEqual(json.stringify(), #"{"a":1.1,"b":true,"d":"XYZ","e":[-9.0,true,null,{"x":"q","y":0.1,"z":[[[[[false]]],true]]},[null]]}"#)
//
//        let json3 = try JSON.parse(json.stringify(pretty: true))
//        XCTAssertEqual(json, json3, "re-parsed pretty JSON should have been equal")
//        XCTAssertEqual(json.stringify(pretty: true), """
//        {
//          "a" : 1.1,
//          "b" : true,
//          "d" : "XYZ",
//          "e" : [
//            -9.0,
//            true,
//            null,
//            {
//              "x" : "q",
//              "y" : 0.1,
//              "z" : [
//                [
//                  [
//                    [
//                      [
//                        false
//                      ]
//                    ]
//                  ],
//                  true
//                ]
//              ]
//            },
//            [
//              null
//            ]
//          ]
//        }
//        """)
//    }

//    func checkJSON(_ json: String) throws {
//        XCTAssertEqual(json, try JSONObjectAny(json: json).stringify(pretty: false, sorted: true))
//    }

//    func testJSONParsing() throws {
//        try checkJSON("""
//        {"a":1}
//        """)
//
//        try checkJSON("""
//        {"x":true}
//        """)
//
//        #if SKIP
//        try checkJSON("""
//        {"_":1.1}
//        """)
//        #else
//        try checkJSON("""
//        {"_":1.1000000000000001}
//        """)
//        #endif
//
//        try checkJSON("""
//        {"a":[1]}
//        """)
//
//        #if false // neither work
//        try checkJSON("""
//        {"a":[1,true,false,0.00001,"X"]}
//        """)
//        #endif
//
//        #if SKIP
        // Android's version of org.json:json is different
        // try checkJSON("""
        // {"a":[1,true,false,1.0E-5,"X"]}
        // """)

        // latest org.json:json
        // try checkJSON("""
        // {"a":[1,true,false,0.00001,"X"]}
        // """)

//        try checkJSON("""
//        {"a":[1,true,false,1.0E-5,"X"]}
//        """)
//        #else
//        try checkJSON("""
//        {"a":[1,true,false,1.0000000000000001e-05,"X"]}
//        """)
//        #endif
//
//        let jsonString = """
//        {
//          "age": 30,
//          "isEmployed": true,
//          "name": "John Smith"
//        }
//        """

        // note that unlike Swift JSON, the JSONObjectAny key/values are in the same order as the document
//        let jsonObject = try JSONObjectAny(json: jsonString)
//
//        let plainString = try jsonObject.stringify(pretty: false, sorted: true)
//
//        XCTAssertTrue(plainString == #"{"age":30,"isEmployed":true,"name":"John Smith"}"# || plainString == #"{"name":"John Smith","isEmployed":true,"age":30}"#, "Unexpected JSON: \(plainString)")
//
//        let prettyString = try jsonObject.stringify(pretty: true, sorted: true)
//
//        // note Android differences:
//        // 1. We do not yet support sorted keys on Android (we'd need to override the JSONStringer, or make a recursive copy of the tree)
//        // 2. Swift pretty output has spaces in front of the colons
//        #if SKIP
//        // Android's version of org.json:json is different
//        XCTAssertEqual(prettyString, """
//        {
//          "age": 30,
//          "isEmployed": true,
//          "name": "John Smith"
//        }
//        """)
//        //XCTAssertEqual(prettyString, """
//        //{
//        //  "name": "John Smith",
//        //  "isEmployed": true,
//        //  "age": 30
//        //}
//        //""")
//        #else
//        XCTAssertEqual(prettyString, """
//        {
//          "age" : 30,
//          "isEmployed" : true,
//          "name" : "John Smith"
//        }
//        """)
//        #endif
//
//        let arrayify: (Int, String) -> (String) = { (count, str) in
//            var s = str
//            for _ in 0..<count {
//                s += "," + str
//            }
//            return "{ \"x\": [" + s + "] }"
//        }
//
//        var bigString = arrayify(10, jsonString)
//        bigString = arrayify(10, bigString)
//        bigString = arrayify(10, bigString)
//        bigString = arrayify(10, bigString)
//        bigString = arrayify(10, bigString) // 100,000: 0.202 Swift, 0.095 Robo
//        //bigString = arrayify(4, bigString) // 400,000 (~50M): 1.021 Swift macOS, 0.311 Java Robolectric
//        //bigString = arrayify(…, bigString) // 10,000,000: 24.408 Swift,  OOME Robo
//
//        // good timing test
//        logger.info("parsing string: \(bigString.count)")
//        let _ = try JSONObjectAny(json: bigString)
//        //let prettyBigString = try prettyBigObject.stringify(pretty: true, sorted: true)
//    }

//    func testJSONDeserialization() throws {
//        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: Data("""
//            {
//                "a": 1.1,
//                "b": true,
//                "d": "XYZ",
//                "e": [-9, true, null, {
//                    "x": "q",
//                    "y": 0.1,
//                    "z": [[[[[false]]], true]]
//                }, [null]]
//            }
//            """.utf8), options: JSONSerialization.ReadingOptions.fragmentsAllowed))
//
//        let obj = try XCTUnwrap(object as? [String: Any])
//
//        XCTAssertEqual(1.1, obj["a"] as? Double)
//        XCTAssertEqual(true, obj["b"] as? Bool)
//        XCTAssertEqual("XYZ", obj["d"] as? String)
//
//        let ex = try XCTUnwrap(obj["e"])
//        let e = try XCTUnwrap(obj["e"] as? [Any])
//        XCTAssertEqual(5, e.count)
//
//        XCTAssertEqual(-9.0, e[0] as? Double)
//        XCTAssertEqual(true, e[1] as? Bool)
//
//        //XCTAssertNil(e[2])
//        //XCTAssertEqual("<null>", "\(e[2])")
//
//        guard let e3 = e[3] as? [String: Any] else {
//            return XCTFail("bad type: \(type(of: e[3]))")
//        }
//
//        XCTAssertEqual("q", (e3["x"] as? String))
//        XCTAssertEqual(0.1, (e3["y"] as? Double))
//
//        XCTAssertEqual(1, (e[4] as? [Any])?.count)
//    }
}
