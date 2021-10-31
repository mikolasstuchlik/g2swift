#if DIAGNOSTIC
import SourceKittenFramework

public struct PropertyScanner {

    public static var responses = [PropertyScanner]()
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

    struct EmmitableProperty: Hashable {
        let name: String
        let key: String
        let type: String
    }

    private static func objectName(_ name: String, isArray: Bool = false) -> String { 
        if isArray {
            return "[Obj<\(name)>]"
        } else {
            return "Obj<\(name)>"
        }
    }

    public init() {}

    public static func initialize(from object: [String: SourceKitRepresentable], name: String = "<root>") -> PropertyScanner {
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

    public mutating func merge(_ other: PropertyScanner) {
        keys.merge(other.keys) { $0.union($1) }
        nonOpt.merge(other.nonOpt) { $0.intersection($1) }
    }

    var keys = [String: Set<Property>]()
    var nonOpt = [String: Set<Property>]()

    private func getEmmitable() -> [String: Set<EmmitableProperty>] {
        var result = [String: Set<EmmitableProperty>]()
        for (objectName, properties) in keys {
            let (rootName, isRoot) = objectName.renameRoot(to: "Root")
            let (candidateName, isObject) = rootName.dropObjectDecorator()

            let canonicalName = candidateName.typeName

            assert(isRoot || isObject)

            var canonicalProperties = Set<EmmitableProperty>()
            for property in properties {
                let canonicalPropertyName = property.name.propertyName
                let (arrayLessName, isArray) = property.type.dropArrayDecorator()
                let (objectLessName, _) = arrayLessName.dropObjectDecorator()

                let isOptional = nonOpt[objectName]?.first { $0 == property } == nil 

                let typeName = objectLessName.typeName
                let arrayDecoratedName = isArray
                    ? "[\(typeName)]"
                    : typeName

                let canonicalType = isOptional
                    ? arrayDecoratedName + "?"
                    : arrayDecoratedName 

                canonicalProperties.insert(EmmitableProperty(
                    name: canonicalPropertyName, 
                    key: property.name, 
                    type: canonicalType
                ))
            }

            result[canonicalName] = canonicalProperties
        }

        return result
    }

    public var pretty: String {
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

    public var modelDeclaration: String {
        let emmitable = getEmmitable()
        var output = ""

        for (typeName, properties) in emmitable {
            output += "public struct \(typeName): SKObject {\n"
            output += "\n"
            for property in properties {
                output += #"    @SKValue(key: "\#(property.key)") var \#(property.name): \#(property.type)\#n"#
            }
            output += "\n"
            output += "}\n"
            output += "\n"
            output += "\n"
        }

        return output
    }
}

private extension String {
    var parsingKey: String { self }

    private var pascalCalse: String {
        self.components(separatedBy: ".")
            .last!
            .components(separatedBy: "_")
            .map(\.capitalized)
            .joined()
    }

    var typeName: String {
        pascalCalse
    }

    var propertyName: String {
        pascalCalse.first!.lowercased() + pascalCalse.dropFirst()
    }

    func dropObjectDecorator() -> (result: String, isObject: Bool) {
        guard hasPrefix("Obj<"), hasSuffix(">") else {
            return (self, false)
        }

        return (String(self.dropFirst(4).dropLast(1)), true)
    }

    func dropArrayDecorator() -> (result: String, isArray: Bool) {
        guard hasPrefix("["), hasSuffix("]") else {
            return (self, false)
        }

        return (String(self.dropFirst().dropLast()), true)
    }

    func renameRoot(to rootName: String) -> (result: String, isRoot: Bool) {
        guard self == "<root>" else {
            return (self, false)
        }

        return (rootName, true)
    }
}

#endif