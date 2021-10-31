import SourceKittenFramework
import struct Foundation.Data

enum SourceKitError: Error {
    case valueMissingOrMismatch(forKey: String?)
    case valueMissingOrNotAnObject
}

public protocol SKInitializable {
    init(from skRepresentable: SourceKitRepresentable?) throws
}

protocol SKObject: SKInitializable { 
    init()
}
extension SKObject {
    mutating func load(from skRepresentable: SourceKitRepresentable) throws {
        guard let object = skRepresentable as? [String: SourceKitRepresentable] else {
            throw SourceKitError.valueMissingOrNotAnObject
        }
        let mirror = Mirror(reflecting: self)
        try mirror.children.forEach { child in
            try (child.value as? SKObjectContainer)?.load(from: object)
        }
    }

    public init(from skRepresentable: SourceKitRepresentable?) throws {
        var aSelf = Self.init()
        try aSelf.load(from: skRepresentable!)
        self = aSelf
    }
}

extension String: SKInitializable {
    public init(from skRepresentable: SourceKitRepresentable?) throws {
        self = skRepresentable as! String
    }
}

extension Int64: SKInitializable {
    public init(from skRepresentable: SourceKitRepresentable?) throws {
        self = skRepresentable as! Int64
    }
}

extension Int: SKInitializable {
    public init(from skRepresentable: SourceKitRepresentable?) throws {
        self = Int(skRepresentable as! Int64)
    }
}

extension Bool: SKInitializable {
    public init(from skRepresentable: SourceKitRepresentable?) throws {
        self = skRepresentable as! Bool
    }
}

extension Data: SKInitializable {
    public init(from skRepresentable: SourceKitRepresentable?) throws {
        self = skRepresentable as! Data
    }
}
extension Optional: SKInitializable where Wrapped: SKInitializable {
    public init(from skRepresentable: SourceKitRepresentable?) throws {
        self = try skRepresentable.flatMap(Wrapped.init(from:))
    }
}

extension Array: SKInitializable where Element: SKInitializable {
    public init(from skRepresentable: SourceKitRepresentable?) throws {
        self = try (skRepresentable as! [SourceKitRepresentable]).map(Element.init(from:))
    }
}

protocol SKObjectContainer: AnyObject {
    func load(from object: [String: SourceKitRepresentable]) throws
}

@propertyWrapper
public final class SKValue<T: SKInitializable>: SKObjectContainer {
    public var wrappedValue: T {
        get { 
            guard case let .some(value) = buffer else {
                fatalError("SKValue key: \(key) was not initialized")
            }
            return value
        }
        set { 
            buffer = .some(newValue)
        }
    }

    private var key: String
    private var buffer: Optional<T> = nil

    init(key: String, wrappedValue: T) {
        self.key = key
        self.buffer = .some(wrappedValue)
    }

    init(key: String) {
        self.key = key
    }

    func load(from object: [String: SourceKitRepresentable]) throws {
        buffer = try .some(T.init(from: object[key]))
    }

}

