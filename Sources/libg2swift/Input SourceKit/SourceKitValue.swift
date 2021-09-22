import SourceKittenFramework

enum SourceKitError: Error {
    case valueMissingOrMismatch(forKey: String?)
    case valueMissingOrNotAnObject
}

protocol SKInitializable {
    init(from skRepresentable: SourceKitRepresentable) throws
}

extension Array: SKInitializable where Element: SKInitializable {
    init(from skRepresentable: SourceKitRepresentable) throws {
        guard let array = skRepresentable as? [SourceKitRepresentable] else {
            throw SourceKitError.valueMissingOrNotAnObject
        }
        self = try array.map(Element.init(from:))
    }
}

@propertyWrapper
struct SKValue<T> {
    var wrappedValue: T {
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

    mutating func getOptional<Wrapped>(from object: [String: SourceKitRepresentable]) throws where T == Optional<Wrapped>, Wrapped: SKInitializable {
        buffer = try .some(object[key].flatMap(Wrapped.init(from:)))
    }

    mutating func getOptional<Wrapped>(from object: [String: SourceKitRepresentable]) throws where T == Optional<Wrapped> {
        buffer = .some(object[key] as? Wrapped)
    }
    
    mutating func get(from object: [String: SourceKitRepresentable]) throws where T: SKInitializable {
        guard let value = try object[key].flatMap(T.init(from:)) else {
            throw SourceKitError.valueMissingOrMismatch(forKey: key)
        }
        buffer = .some(value)
    }

    mutating func get(from object: [String: SourceKitRepresentable]) throws {
        guard let value = object[key] as? T else {
            throw SourceKitError.valueMissingOrMismatch(forKey: key)
        }
        buffer = .some(value)
    }
}
