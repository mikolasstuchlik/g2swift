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
    }

    public let type: TypeDefinition
    public let documentation: String?
}

// Element
public struct XmlElement {
    public let name: String
    public let attributes: [XmlAttribute]
    public let childs: XmlChildElement
}
