import Foundation

// Aliases
public struct XmlAlias: Hashable {
    public let name: String
    public let documentation: String?

    static public func ==(_ lhs: XmlAlias, _ rhs: XmlAlias) -> Bool {
        lhs.name == rhs.name
    }

    public func hash(into hasher: inout Hasher) {
        name.hash(into: &hasher)
    }
}

// Attributes
public struct XmlAttribute {
    public enum TypeDefinition {
        case aliasName(String)
        case cases([String], name: String)
        case type(String, name: String)
    }

    public let documentation: String?
    public let type: TypeDefinition
    public let isOptional: Bool
}

// Child elements
public struct XmlChildElement {
    public enum TypeDefinition {
        case oneOf(elements: [XmlChildElement])
        case anyOf(elements: [XmlChildElement])

        case zeroOrOne(typeName: String)
        case exactlyOne(typeName: String)
        case anyNumberOf(typeName: String)

        case empty
        case text
    }

    public let type: TypeDefinition
    public let documentation: String?

    func decorate(with operatorSign: String, documentation: String?) -> XmlChildElement {
        switch type {
        case .oneOf, .anyOf, .empty, .text:
            fatalError("Type \(type) cannot be decorated")
        case .zeroOrOne(typeName: let typeName), .exactlyOne(typeName: let typeName), .anyNumberOf(typeName: let typeName):
            switch operatorSign {
            case "*":
                return XmlChildElement(type: .anyNumberOf(typeName: typeName), documentation: )
            case "?":
                return XmlChildElement(type: .zeroOrOne(typeName: typeName), documentation: [self.documentation + documentation].compactMap { $0 }.joined(separator: " ;; "))
            default:
                fatalError("Unknown operator " + operatorSign)
            }
        }
    }
}

// Element
public struct XmlElement {
    public let name: String
    public let attributes: [XmlAttribute]
    public let childs: XmlChildElement
}
