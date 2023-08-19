// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

// Note: !SKIP code paths used to validate implementation only.
// Not used in applications. See contribution guide for details.
#if !SKIP
import CryptoKit
@_implementationOnly import struct Foundation.Data

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public typealias SymmetricKey = CryptoKit.SymmetricKey

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public typealias HMAC = CryptoKit.HMAC

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public typealias Insecure = CryptoKit.Insecure

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public typealias HashFunction = CryptoKit.HashFunction

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public typealias MD5 = CryptoKit.Insecure.MD5
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public typealias MD5Digest = CryptoKit.Insecure.MD5Digest
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public typealias SHA1 = CryptoKit.Insecure.SHA1
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public typealias SHA1Digest = CryptoKit.Insecure.SHA1Digest
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public typealias SHA256 = CryptoKit.SHA256
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public typealias SHA256Digest = CryptoKit.SHA256Digest
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public typealias SHA384 = CryptoKit.SHA384
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public typealias SHA384Digest = CryptoKit.SHA384Digest
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public typealias SHA512 = CryptoKit.SHA512
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public typealias SHA512Digest = CryptoKit.SHA512Digest

/// A sequence that both `Data` and `String.UTF8View` conform to.
extension Sequence where Element == UInt8 {
    /// Returns this data as a base-64 encoded string
    public func base64() -> String {
        Foundation.Data(self).base64EncodedString()
    }

    /// Returns the contents of the Data as a hex string
    public func hex() -> String {
        map { String(format: "%02x", $0) }.joined()
    }

    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    public func sha256() -> SHA256.Digest {
        CryptoKit.SHA256.hash(data: Foundation.Data(self))
    }

    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    public func sha384() -> SHA384.Digest {
        CryptoKit.SHA384.hash(data: Foundation.Data(self))
    }

    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    public func sha512() -> SHA512.Digest {
        CryptoKit.SHA512.hash(data: Foundation.Data(self))
    }
}

/// An alias for `HMAC<Insecure.MD5>` since Kotlin does not support static access to generics
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public typealias HMACMD5 = HMAC<Insecure.MD5>
/// An alias for `HMAC<Insecure.SHA1>` since Kotlin does not support static access to generics
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public typealias HMACSHA1 = HMAC<Insecure.SHA1>
/// An alias for `HMAC<SHA256>` since Kotlin does not support static access to generics
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public typealias HMACSHA256 = HMAC<SHA256>
/// An alias for `HMAC<SHA384>` since Kotlin does not support static access to generics
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public typealias HMACSHA384 = HMAC<SHA384>
/// An alias for `HMAC<SHA512>` since Kotlin does not support static access to generics
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public typealias HMACSHA512 = HMAC<SHA512>

#else
public typealias MessageDigest = java.security.MessageDigest
#endif

extension Data {
    /// Convert the bytes into a base64 string.
    public func base64EncodedString() -> String {
        #if !SKIP
        return platformValue.base64EncodedString()
        #else
        return java.util.Base64.getEncoder().encodeToString(platformValue)
        #endif
    }

    /// Convert the bytes into a hex string.
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    public func sha256() -> Data {
        #if !SKIP
        return Data(platformValue: Foundation.Data(SHA256.hash(data: platformValue)))
        #else
        return Data(SHA256.hash(data: self).bytes)
        #endif
    }

    /// Convert the bytes into a hex string.
    public func hex() -> String {
        return platformValue.hex()
    }
}

#if SKIP
extension Data {
    public init(_ checksum: Digest) {
        self.init(checksum.bytes)
    }
}

/// A holder for a digest.
public protocol Digest {
    var bytes: PlatformData { get }
}

public protocol HashFunction {
    func update(_ data: DataProtocol)
    func finalize() -> Digest
}

public protocol NamedHashFunction : HashFunction {
    associatedtype Digest // : Digest
    var digest: MessageDigest { get }
    var digestName: String { get } // Kotlin does not support static members in protocols
    //func createMessageDigest() throws -> MessageDigest
}

public struct SHA256 : NamedHashFunction {
    typealias Digest = SHA256Digest
    public let digest: MessageDigest = MessageDigest.getInstance("SHA-256")
    public let digestName = "SHA256"

    public static func hash(data: Data) -> SHA256Digest {
        return SHA256Digest(bytes: SHA256().digest.digest(data.platformValue))
    }

    public func update(_ data: DataProtocol) {
        digest.update(data.platformData)
    }

    public func finalize() -> SHA256Digest {
        SHA256Digest(bytes: digest.digest())
    }
}

public struct SHA256Digest : Digest {
    let bytes: PlatformData

    var description: String {
        "SHA256 digest: " + bytes.hex()
    }
}

public struct SHA384 : NamedHashFunction {
    typealias Digest = SHA384Digest
    public let digest: MessageDigest = MessageDigest.getInstance("SHA-384")
    public let digestName = "SHA384"

    public static func hash(data: Data) -> SHA384Digest {
        return SHA384Digest(bytes: SHA384().digest.digest(data.platformValue))
    }

    public func update(_ data: DataProtocol) {
        digest.update(data.platformData)
    }

    public func finalize() -> SHA384Digest {
        SHA384Digest(bytes: digest.digest())
    }
}

public struct SHA384Digest : Digest {
    let bytes: PlatformData

    var description: String {
        "SHA384 digest: " + bytes.hex()
    }
}

public struct SHA512 : NamedHashFunction {
    typealias Digest = SHA512Digest
    public let digest: MessageDigest = MessageDigest.getInstance("SHA-512")
    public let digestName = "SHA"

    public static func hash(data: Data) -> SHA512Digest {
        return SHA512Digest(bytes: SHA512().digest.digest(data.platformValue))
    }

    public func update(_ data: DataProtocol) {
        digest.update(data.platformData)
    }

    public func finalize() -> SHA512Digest {
        SHA512Digest(bytes: digest.digest())
    }
}

public struct SHA512Digest : Digest {
    let bytes: PlatformData

    var description: String {
        "SHA512 digest: " + bytes.hex()
    }
}

public struct Insecure {
    public struct MD5 : NamedHashFunction {
        typealias Digest = MD5Digest
        public let digest: MessageDigest = MessageDigest.getInstance("MD5")
        public let digestName = "MD5"

        public static func hash(data: Data) -> MD5Digest {
            return MD5Digest(bytes: MD5().digest.digest(data.platformValue))
        }

        public func update(_ data: DataProtocol) {
            digest.update(data.platformData)
        }

        public func finalize() -> MD5Digest {
            MD5Digest(bytes: digest.digest())
        }
    }

    public struct MD5Digest : Digest {
        let bytes: PlatformData

        var description: String {
            "MD5 digest: " + bytes.hex()
        }
    }

    public struct SHA1 : NamedHashFunction {
        typealias Digest = SHA1Digest
        public let digest: MessageDigest = MessageDigest.getInstance("SHA1")
        public let digestName = "SHA1"

        public static func hash(data: Data) -> SHA1Digest {
            return SHA1Digest(bytes: SHA1().digest.digest(data.platformValue))
        }

        public func update(_ data: DataProtocol) {
            digest.update(data.platformData)
        }

        public func finalize() -> SHA1Digest {
            SHA1Digest(bytes: digest.digest())
        }
    }

    public struct SHA1Digest : Digest {
        let bytes: PlatformData

        var description: String {
            "SHA1 digest: " + bytes.hex()
        }
    }
}

/// Implemented as a simple Data wrapper.
public struct SymmetricKey {
    let data: Data
}

open class HMACMD5 : DigestFunction {
    public static func authenticationCode(for message: Data, using secret: SymmetricKey) -> PlatformData {
        DigestFunction.authenticationCode(for: message, using: secret, algorithm: "MD5")
    }
}

open class HMACSHA1 : DigestFunction {
    public static func authenticationCode(for message: Data, using secret: SymmetricKey) -> PlatformData {
        DigestFunction.authenticationCode(for: message, using: secret, algorithm: "SHA1")
    }
}

open class HMACSHA256 : DigestFunction {
    public static func authenticationCode(for message: Data, using secret: SymmetricKey) -> PlatformData {
        DigestFunction.authenticationCode(for: message, using: secret, algorithm: "SHA256")
    }
}

open class HMACSHA384 : DigestFunction {
    public static func authenticationCode(for message: Data, using secret: SymmetricKey) -> PlatformData {
        DigestFunction.authenticationCode(for: message, using: secret, algorithm: "SHA384")
    }
}

open class HMACSHA512 : DigestFunction {
    public static func authenticationCode(for message: Data, using secret: SymmetricKey) -> PlatformData {
        DigestFunction.authenticationCode(for: message, using: secret, algorithm: "SHA512")
    }
}

public extension kotlin.ByteArray {
    /// Convert the bytes of this data into a hex string.
    public func hex() -> String {
        joinToString("") {
            java.lang.Byte.toUnsignedInt($0).toString(radix: 16).padStart(2, "0".get(0))
        }
    }
}

open class DigestFunction {
    static func authenticationCode(for message: Data, using secret: SymmetricKey, algorithm hashName: String) -> PlatformData {
        let secretKeySpec = javax.crypto.spec.SecretKeySpec(secret.data.platformValue, "Hmac\(hashName)")
        let mac = javax.crypto.Mac.getInstance("Hmac\(hashName)")
        // Skip removes .init because it assumes you want a constructor, so we need to put it back in
        // SKIP REPLACE: mac.init(secretKeySpec)
        mac.init(secretKeySpec)
        let signature = mac.doFinal(message.platformValue)
        return signature
    }
}

#endif
