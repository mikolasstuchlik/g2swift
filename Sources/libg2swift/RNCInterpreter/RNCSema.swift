import Foundation
import Covfefe

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
    private var namedElements = [XmlAlias: XmlElement]()
    private var unnamedElements = [String: XMLElement]()
    private var namedChildElements = [XmlAlias: XmlChildElement]()
    private var namedAttributes = [XmlAlias: [XmlAttribute]]()

    public func produceXmlDescription() throws {
        let cleanTree = rootTree.filter { !$0.name.contains("ws") }!
        let startDecl = cleanTree.first { $0.root?.name == "start.value" }!
        start = String(startDecl.realize(from: source))

        cleanTree.allNodes { $0.name == "alias.decl" }.forEach { aliasNode in
            let (alias, content) = loadFirstAlias(node: aliasNode)
            guard case let .node(_, child) = content else {
                fatalError()
            }

            switch child.first! {
            case let .node(key, _) where key.name == "attr.decl":
            loadAttributeTopLevelDecl(alias: alias, node: child.first!)
            case let .node(key, _) where key.name == "element.decl":
            loadElementTopLevelDecl(alias: alias, node: child.first!)
            case let .node(key, _) where key.name == "child.brack":
            loadChildBracketTopLevelDecl(alias: alias, node: child.first!)
            case let .node(key, _) where key.name == "attr.col.decl":
                loadAttributeCollectionTopLevelDecl(alias: alias, node: child.first!)
            default:
                fatalError()
            }
        }

        print("Start: \(start)")
    }

    func loadFirstAlias(node syntaxTree: ParseTree) -> (alias: XmlAlias, content: ParseTree) {
        let name = syntaxTree.first { $0.root?.name == "alias.decl.name"}!.realize(from: source)
        let doc = syntaxTree.first { $0.root?.name == "alias.decl.doc.op" }.flatMap { loadDoc(from: $0) }
        let content = syntaxTree.first { $0.root?.name == "alias.content" }!

        return (XmlAlias(name: String(name), documentation: doc), content)
    }

    func loadDoc(from node: ParseTree) -> String {
        node.allNodes { $0.name == "doc.token" } 
            .map { String($0.realize(from: source)) }
            .map { tokens[$0]! }
            .joined(separator: ";; ")
    }

    func loadAttributeTopLevelDecl(alias: XmlAlias, node: ParseTree) {
        guard let attribute = loadAttribute(node: node) else {
            assertionFailure("Failed to load top level attribute declaration for alias \(alias)")
            return
        }

        namedAttributes[alias] = [attribute]
    }

    func loadElementTopLevelDecl(alias: XmlAlias, node: ParseTree) {
        guard let name = node.allNodes(where: { $0.name == "element.decl.name" }).first?.realize(from: source) else {
            return
        }

        let attributes = node.children?
            .first { $0.root?.name == "attrs.list.opt" }?
            .allNodes { $0.name == "attr.decl" }
            .compactMap(loadAttribute(node:))
        let childEmenets = node.children?.first { $0.root?.name == "child.expr.opt" }.flatMap(loadChildElements(node:))

        let element = XmlElement(
            name: String(name),
            attributes: attributes ?? [],
            childs: childEmenets ?? XmlChildElement(type: .empty, documentation: nil)
        )

        namedElements[alias] = element
    }

    func loadChildBracketTopLevelDecl(alias: XmlAlias, node: ParseTree) {
        guard let child = loadChildElements(node: node) else {
            assertionFailure("Failed to load element declaration for alias \(alias)")
            return
        }
        namedChildElements[alias] = child
    }

    func loadAttributeCollectionTopLevelDecl(alias: XmlAlias, node: ParseTree) {
        let attributes = node
            .allNodes { $0.name == "attr.decl" }
            .compactMap(loadAttribute(node:))

        namedAttributes[alias] = attributes
    }

    func loadChildElements(node: ParseTree) -> XmlChildElement? {
        return nil
    }

    func loadAttribute(node: ParseTree) -> XmlAttribute? {
        let doc = loadDoc(from: node)
        let isOpt = node.children?.first { $0.root?.name == "attr.is.opt" }?.leaf?.isEmpty == false

        if let refName = node.first(where: { $0.root?.name == "attr.decl.ref" } )?.realize(from: source) {
            return XmlAttribute(documentation: doc, type: .aliasName(String(refName)), isOptional: isOpt)
        }

        guard let name = node.first(where: { $0.root?.name == "attr.decl.name" } )?.realize(from: source) else {
            return nil
        }

        let options = node.allNodes { $0.name == "attr.option.name" }.map { $0.realize(from: source) }
        if !options.isEmpty {
            return XmlAttribute(documentation: doc, type: .cases(options.map(String.init(_:)), name: String(name)), isOptional: isOpt)
        }

        if let typeName = node.allNodes(where: { $0.name == "attr.content.type" }).first?.realize(from: source) {
            return XmlAttribute(documentation: doc, type: .type(String(typeName), name: String(name)), isOptional: isOpt)
        }

        return nil
    }

}
