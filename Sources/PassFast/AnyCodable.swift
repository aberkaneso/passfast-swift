import Foundation

/// A type-erased `Codable` value for handling arbitrary JSON (e.g. `dynamic_data`).
public struct AnyCodable: Codable, Equatable, Hashable, @unchecked Sendable, CustomStringConvertible {
    public let value: Any

    public init(_ value: Any) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            value = NSNull()
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map(\.value)
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            value = dict.mapValues(\.value)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported JSON value")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case is NSNull:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dict as [String: Any]:
            try container.encode(dict.mapValues { AnyCodable($0) })
        default:
            throw EncodingError.invalidValue(value, .init(codingPath: encoder.codingPath, debugDescription: "Unsupported type"))
        }
    }

    public static func == (lhs: AnyCodable, rhs: AnyCodable) -> Bool {
        switch (lhs.value, rhs.value) {
        case is (NSNull, NSNull):
            return true
        case let (l as Bool, r as Bool):
            return l == r
        case let (l as Int, r as Int):
            return l == r
        case let (l as Double, r as Double):
            return l == r
        case let (l as String, r as String):
            return l == r
        case let (l as [Any], r as [Any]):
            return l.count == r.count && zip(l, r).allSatisfy { AnyCodable($0) == AnyCodable($1) }
        case let (l as [String: Any], r as [String: Any]):
            return l.count == r.count && l.allSatisfy { key, val in
                r[key].map { AnyCodable(val) == AnyCodable($0) } ?? false
            }
        default:
            return false
        }
    }

    public func hash(into hasher: inout Hasher) {
        switch value {
        case is NSNull:
            hasher.combine(0)
        case let bool as Bool:
            hasher.combine(1)
            hasher.combine(bool)
        case let int as Int:
            hasher.combine(2)
            hasher.combine(int)
        case let double as Double:
            hasher.combine(3)
            hasher.combine(double)
        case let string as String:
            hasher.combine(4)
            hasher.combine(string)
        default:
            hasher.combine(5)
            hasher.combine(String(describing: value))
        }
    }

    public var description: String {
        String(describing: value)
    }
}

// MARK: - Convenience initializers

extension AnyCodable: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) { self.init(value) }
}

extension AnyCodable: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) { self.init(value) }
}

extension AnyCodable: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) { self.init(value) }
}

extension AnyCodable: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) { self.init(value) }
}

extension AnyCodable: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) { self.init(NSNull()) }
}

extension AnyCodable: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, Any)...) {
        self.init(Dictionary(uniqueKeysWithValues: elements))
    }
}

extension AnyCodable: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Any...) {
        self.init(elements)
    }
}
