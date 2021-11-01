import Foundation
import Covfefe

public enum RNCTokenizer {
    public static func tokenize(_ string: String) throws {
        let grammar = Grammar(start: "initial") {
            "initial"       --> n("initial") <+> t(.illegalCharacters.inverted)
                            <|> t()
        }

        let parser = EarleyParser(grammar: grammar)

        print(string.count)
        // 2017 -> OK / FAIL
        // 2018 -> FAIL
        let syntaxTree = try parser.syntaxTree(for: String(string.prefix(20)))
        print(syntaxTree.description)
    }
}