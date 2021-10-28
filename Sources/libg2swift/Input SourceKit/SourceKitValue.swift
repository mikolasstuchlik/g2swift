import SourceKittenFramework

enum SourceKitError: Error {
    case valueMissingOrMismatch(forKey: String?)
    case valueMissingOrNotAnObject
}

protocol SKInitializable {
    init(from skRepresentable: SourceKitRepresentable) throws
}

extension SKInitializable {
    func load(from skRepresentable: SourceKitRepresentable) throws {
        let mirror = Mirror(reflecting: self)
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

    mutating func load<Wrapped>(from object: [String: SourceKitRepresentable]) throws where T == Optional<Wrapped>, Wrapped: SourceKitRepresentable {
        buffer = .some(object[key] as? Wrapped)
    }

    mutating func load(from object: [String: SourceKitRepresentable]) throws where T: SourceKitRepresentable {
        guard let value = object[key] as? T else {
            throw SourceKitError.valueMissingOrMismatch(forKey: key)
        }
        buffer = .some(value)
    }
}

@propertyWrapper
struct SKArray<T> {
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

    mutating func load<Element>(from object: [String: SourceKitRepresentable]) throws where T == Array<Element>, Element: SKInitializable {
        guard let value = object[key] as? Array<SourceKitRepresentable> else {
            throw SourceKitError.valueMissingOrMismatch(forKey: key)
        }
        buffer = try .some(value.map(Element.init(from:)))
    }

    mutating func load<Element>(from object: [String: SourceKitRepresentable]) throws where T == Optional<Array<Element>>, Element: SKInitializable {
        let value = object[key] as? Array<SourceKitRepresentable>
        guard value != nil || object[key] == nil else {
            throw SourceKitError.valueMissingOrMismatch(forKey: key)
        }
        buffer = try .some(value.flatMap { try $0.map(Element.init(from:))} )
    }

    mutating func load<Element>(from object: [String: SourceKitRepresentable]) throws where T == Array<Element>, Element: SourceKitRepresentable {
        guard let value = object[key] as? Array<Element> else {
            throw SourceKitError.valueMissingOrMismatch(forKey: key)
        }
        buffer = .some(value)
    }

    mutating func load<Element>(from object: [String: SourceKitRepresentable]) throws where T == Optional<Array<Element>>, Element: SourceKitRepresentable {
        buffer = .some(object[key] as? Array<Element>)
    }
}
