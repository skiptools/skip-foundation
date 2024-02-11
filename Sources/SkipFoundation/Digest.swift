// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

public typealias MessageDigest = java.security.MessageDigest

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

// Implemented as a simple Data wrapper.
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
