import Foundation
import Covfefe

public enum RNCTokenizer {
    public static func tokenize(_ string: String) throws {

        // RESPECT trailing spaces!!!!
        let grammar = Grammar(start: "grammar") {
            "grammar"           --> t("grammar { ") <+> n("grammar.content") <+> t("}")

            "grammar.content"   --> n("word") <+> n("grammar.content")
                                <|> t()

            "word"              --> n("string") <+> t(" ")
            "string"            --> t(.illegalCharacters.inverted.subtracting(.whitespacesAndNewlines)) <+> n("string")
                                <|> t()
        }

        let parser = EarleyParser(grammar: grammar)

        let syntaxTree = try parser.syntaxTree(for: string)

        let words: [String] = syntaxTree.reduce([]) { current, accumulator in
            if case let .node(key: node, children: _) =  current, node.name == "word" {
                let leafs = current.stackLeafs
                let word = string[leafs.first!.lowerBound..<leafs.last!.upperBound]
                accumulator.append(String(word))
                return false
            }

            return true
        }

        print(words)
    }
}

extension SyntaxTree {
    
    private enum ReduceStackFrame {
        case children([SyntaxTree], index: Int)
    }

    func reduce<T>(_ initial: T, nextContinueSubtree: (_ currentItem: SyntaxTree, _ result: inout T) -> Bool ) -> T {
        var stack = [ReduceStackFrame]()
        var accumulator = initial

        func appendNew(_ tree: SyntaxTree) {
            if 
                nextContinueSubtree(tree, &accumulator),
                case .node(key: _, children: let children) = tree 
            {
                stack.append(.children(children, index: 0))
            }
        }

        func resolve(_ children: [SyntaxTree], iteratedIndex: Int) {
            guard children.count > iteratedIndex else {
                return
            } 

            stack.append(.children(children, index: iteratedIndex + 1))
            appendNew(children[iteratedIndex])
        }

        appendNew(self)
        while let currentFrame = stack.popLast() {
            switch currentFrame {
            case let .children(children, index: index):
                resolve(children, iteratedIndex: index)
            }
        }
	
        return accumulator
    }

}

extension SyntaxTree {
    var stackLeafs: [LeafElement] {
         self.reduce([]) { current, accumulator in
            if case let .leaf(leaf) = current {
                accumulator.append(leaf)
            }
            return true
        }
    }
}