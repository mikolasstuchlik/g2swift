import Foundation
import Covfefe

public enum RNCSema {
    public static func produceXmlDescription(using syntaxTree: ParseTree, source: String, tokens: [String: String]) throws {
        var start = ""
        var elements = [String]()

        syntaxTree.iterate { _, item, _ in
            guard case let .node(nonTerminal, _) = item else {
                return
            }

            switch nonTerminal.name {
            case "start.value":
                start = String(item.realize(from: source))
            case "element.decl":
                elements.append(String(item.realize(from: source)))
            default: break
            }
        }

        print("Start: \(start)")
        print(elements)
    }
}

extension ParseTree {
    func realize(from source: String) -> Substring {
        let leafs = self.leafs
        let lower = leafs.first!.lowerBound
        let upper = leafs.last!.upperBound
        return source[lower...upper]
    }
}