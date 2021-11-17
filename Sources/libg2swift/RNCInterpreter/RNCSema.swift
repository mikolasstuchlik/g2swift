import Foundation
import Covfefe

// Aliases
public final class XmlAlias {
    public internal(set) var name: String = ""
    public internal(set) var documentation: String?
}

// Attributes
public class XmlAttribute {
}

public final class XmlConcreteAttribute: XmlAttribute {
    public enum XmlType {
        case cases([String])
        case type(String)
    }

    public internal(set) var documentation: String?
    public internal(set) var name: String = ""
    public internal(set) var type: XmlType = .type("")
    public internal(set) var isOptional: Bool = false
    public internal(set) var aliasName: XmlAlias?
}

public final class XmlNamedAttributes: XmlAttribute {
    public internal(set) var attributes: [XmlConcreteAttribute] = []
    public internal(set) var aliasName: XmlAlias?
}

// Child elements
public class XmlChildElement {
}

public final class XmlEitherChild: XmlChildElement {
    public internal(set) var optinos: [XmlChildElement] = []
}

public final class XmlConcreteChild: XmlChildElement {
    public enum Mode {
        case some, optional, array
    }

    public internal(set) var typeName: String = ""
    public internal(set) var documentation: String?
    public internal(set) var mode: Mode = .some
}

public final class XmlNamedChilds: XmlChildElement {
    public internal(set) var alias: XmlAlias = XmlAlias()
    public internal(set) var childs: [XmlChildElement] = []
}

// Element
public final class XmlElement {
    public internal(set) var name: String = ""
    public internal(set) var attributes: [XmlAttribute] = []
    public internal(set) var childs: [XmlChildElement] = []
}

public class RNCSema {
    public let rootTree: ParseTree
    public let source: String
    public let tokens: [String: String]

    public init(rootTree: ParseTree, source: String, tokens: [String: String]) {
        self.rootTree = rootTree
        self.source = source
        self.tokens = tokens
    }

    private var start: String = ""
    private var knownElements = [String: XmlElement]()
    private var knownNamedAttributes = [String: XmlNamedAttributes]()

    public func produceXmlDescription() throws {
        let startDecl = rootTree.first { $0.root?.name == "start.value" }!
        start = String(startDecl.realize(from: source))

        rootTree.allNodes { $0.name == "alias.decl" }.forEach { aliasNode in
            let (alias, content) = loadFirstAlias(node: aliasNode)
            guard case let .node(_, child) = content else {
                fatalError()
            }

            switch child.first! {
            case let .node(key, _) where key.name == "attr.decl":
            loadAttrTopLevelDecl(alias: alias, node: child.first!)
            case let .node(key, _) where key.name == "element.decl":
            loadElementTopLevelDecl(alias: alias, node: child.first!)
            case let .node(key, _) where key.name == "child.brack":
            loadChildBracketTopLevelDecl(alias: alias, node: child.first!)
            case let .node(key, _) where key.name == "attr.col.decl":
            loadAttributesTopLevelDecl(alias: alias, node: child.first!)
            default:
                fatalError()
            }
        }

        print("Start: \(start)")
    }

    func loadFirstAlias(node syntaxTree: ParseTree) -> (alias: XmlAlias, content: ParseTree) {
        let name = syntaxTree.first { $0.root?.name == "word.capitalized"}!.realize(from: source)
        let doc = syntaxTree.first { $0.root?.name == "doc.token.opt" }.flatMap { loadDoc(from: $0) }
        let content = syntaxTree.first { $0.root?.name == "alias.content" }!

        let newAlias = XmlAlias()
        newAlias.name = String(name)
        newAlias.documentation = doc

        return (newAlias, content)
    }

    func loadDoc(from node: ParseTree) -> String {
        node.allNodes { $0.name == "doc.token" } 
            .map { String($0.realize(from: source)) }
            .map { tokens[$0]! }
            .joined(separator: ";; ")
    }

    func loadAttrTopLevelDecl(alias: XmlAlias, node: ParseTree) {
        print(alias.name)
    }

    func loadElementTopLevelDecl(alias: XmlAlias, node: ParseTree) {
        print(alias.name)
    }

    func loadChildBracketTopLevelDecl(alias: XmlAlias, node: ParseTree) {
        print(alias.name)
    }

    func loadAttributesTopLevelDecl(alias: XmlAlias, node: ParseTree) {
        print(alias.name)
    }

    func loadAttr
}
