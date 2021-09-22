#if DIAGNOSTIC
import SourceKittenFramework

struct PropertyScanner {

    static var responses = [PropertyScanner]()
    struct Property: Hashable {
        let name: String
        let type: String

        init(_ name: String, _ value: Any) {
            self.name = name
            self.type = String(describing: Swift.type(of: value))
        }
        init(_ name: String, type: String) {
            self.name = name
            self.type = type
        }
    }

    private static func objectName(_ name: String, isArray: Bool = false) -> String { 
        if isArray {
            return "[Obj<\(name)>]"
        } else {
            return "Obj<\(name)>"
        }
    }

    static func initialize(from object: [String: SourceKitRepresentable], name: String = "<root>") -> PropertyScanner {
        var output = PropertyScanner()

        var objects = [PropertyScanner]()
        for (key, value) in object {
            switch value {
            case let value as [SourceKitRepresentable]:
                if let objectArray = value as? [[String: SourceKitRepresentable]] {
                    for item in objectArray {
                        objects.append(initialize(from: item, name: objectName(key)))  
                    }
                    output.keys[name, default: []].insert(Property(key, type: objectName(key, isArray: true)))
                    output.nonOpt[name, default: []].insert(Property(key, type: objectName(key, isArray: true)))
                } else {
                    var types = Set<String>()
                    for item in value {
                        types.insert(String(describing: Swift.type(of: item)))
                    }
                    output.keys[name, default: []].insert(Property(key, type: "[\(types.joined(separator: ", "))]"))
                    output.nonOpt[name, default: []].insert(Property(key, type: "[\(types.joined(separator: ", "))]"))
                }
            case let value as [String: SourceKitRepresentable]:
                output.keys[name, default: []].insert(Property(key, type: objectName(key)))
                output.nonOpt[name, default: []].insert(Property(key, type: objectName(key)))
                objects.append(initialize(from: value, name: objectName(key)))
            default:
                output.keys[name, default: []].insert(Property(key, value))
                output.nonOpt[name, default: []].insert(Property(key, value))
            }
        }

        objects.forEach { output.merge($0) }

        return output
    }

    mutating func merge(_ other: PropertyScanner) {
        keys.merge(other.keys) { $0.union($1) }
        nonOpt.merge(other.nonOpt) { $0.intersection($1) }
    }

    var keys = [String: Set<Property>]()
    var nonOpt = [String: Set<Property>]()

    var pretty: String {
        var output = ""
        output += "PrettyScanner(" + "\n"

        output += "    keys: [" + "\n"
        for (key, values) in keys {
            output += "        \(key) ::=" + "\n"
            for value in values {
                output += "            \(value.name) : \(value.type)" + "\n"
            }
        }
        output += "    ]," + "\n"

        output += "    nonOpt: [" + "\n"
        for (key, values) in nonOpt {
            output += "        \(key) ::=" + "\n"
            for value in values {
                output += "            \(value.name) : \(value.type)" + "\n"
            }
        }
        output += "    ]" + "\n"

        output += ")"
        return output
    }
}

#endif