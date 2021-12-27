import Foundation
import Covfefe

public enum RNCTokenizer {
    public static func tokenize(_ string: String) throws -> ParseTree {
        let grammar = Grammar(start: "grammar") {
            "grammar"           --> t("grammar {") <+> n("ws.opt") <+> n("grammar.content") <+> n("ws.opt") <+> t("}") <+> n("ws.opt")

            "grammar.content"   --> n("grammar.content") <+> n("grammar.content")
                                <|> n("start.decl") 
                                <|> n("alias.decl")
                                <|> t()

            // Start
            "start.decl"        --> t("start") <+> n("ws.opt") <+> t("=") <+> n("ws.opt") <+> n("start.value") <+> n("ws.opt")
            "start.value"       --> n("word")

            // Alias
            "alias.decl"        --> n("alias.decl.doc.op") <+> n("ws.opt") <+> n("alias.decl.name") <+> n("ws.opt") <+> t("=") <+> n("ws.opt") <+> n("alias.content") <+> n("ws.opt")
            "alias.decl.name"   --> n("word.capitalized")
            "alias.decl.doc.op" --> n("doc.token.opt")
            "alias.content"     --> n("attr.decl")
                                <|> n("element.decl") 
                                <|> n("child.brack")
                                <|> n("attr.col.decl")

            // Element
            "element.decl"      --> n("doc.token.opt") <+> n("ws.opt") <+> t("element") <+> n("ws.opt") <+> n("element.decl.name") <+> n("ws.opt")
            <+> t("{") <+> n("ws.opt") 
            <+> n("attrs.list.opt") <+> n("ws.opt") 
            <+> n("child.expr.opt") <+> n("ws.opt") 
            <+> t("}") <+> n("ws.opt")
            "element.decl.name" --> n("word")

            "child.expr.opt"    --> n("child.expr")
                                <|> t()
            "child.expr"        --> n("child.bin") <+> n("ws.opt")
                                <|> n("doc.token.opt") <+> n("ws.opt") <+> n("child.brack") <+> n("ws.opt")
                                <|> n("child.unary") <+> n("ws.opt")
                                <|> n("doc.token.opt") <+> n("ws.opt") <+> n("child.value") <+> n("ws.opt")
                                <|> n("doc.token.opt") <+> n("ws.opt") <+> t("empty")
                                <|> n("doc.token.opt") <+> n("ws.opt") <+> t("text")
                                <|> n("doc.token.opt") <+> n("ws.opt") <+> n("element.decl") 
            "child.bin"         --> n("child.expr") <+> n("ws.opt") <+> n("doc.token.opt") <+> n("ws.opt") <+> n("child.bin.o") <+> n("ws.opt") <+> n("child.expr")
            "child.bin.o"       --> t("&")
                                <|> t("|")
            "child.unary"       --> n("child.expr") <+> n("child.unary.o") <+> n("ws.opt")
            "child.unary.o"     --> t("*")
                                <|> t("?")
            "child.brack"       --> t("(") <+> n("ws.opt") <+> n("child.expr") <+> n("ws.opt") <+> t(")") <+> n("ws.opt")
            "child.value"       --> n("word.capitalized") <+> n("ws.opt")

            // Attribute
            "attrs.list.opt"    --> n("attrs.list")
                                <|> t()
            "attrs.list"        --> n("attrs.list") <+> n("attrs.list")
                                <|> n("attr.decl") <+> n("delim.opt") <+> n("ws.opt")

            "attr.decl"         --> n("doc.token.opt") <+> n("ws.opt") <+> t("attribute") <+> n("ws.opt") <+> n("attr.decl.name") <+> n("ws.opt") <+> t("{") <+> n("ws.opt") <+> n("attr.content") <+> n("ws.opt") <+> t("}") <+> n("ws.opt") <+> n("attr.is.opt") <+> n("ws.opt")
                                <|> n("doc.token.opt") <+> n("ws.opt") <+> n("attr.decl.ref") <+> n("ws.opt") <+> n("attr.is.opt") <+> n("ws.opt")
            "attr.decl.name"    --> n("word")
            "attr.decl.ref"     --> n("word.capitalized")

            "attr.is.opt"       --> t("?")
                                <|> t()
            "attr.content"      --> n("attr.content.type")
                                <|> n("attr.options")
            "attr.content.type" --> n("word")
            "attr.options"      --> n("attr.options") <+> n("ws.opt") <+> t("|") <+> n("ws.opt") <+> n("attr.option")  <+> n("ws.opt")
                                <|> n("attr.option")
            "attr.option"       --> t("\"") <+> n("attr.option.name") <+> t("\"")
            "attr.option.name"  --> n("word")

            // Attribute collection
            "attr.col.decl"     --> n("doc.token.opt") <+> n("ws.opt") <+> t("(") <+> n("ws.opt") <+> n("attrs.list") <+> n("ws.opt") <+> t(")") <+> n("ws.opt")

            // Doc tokens
            "doc.token.opt"     --> n("doc.token") <+> n("ws.opt") <+> n("doc.token.opt")
                                <|> t()
            "doc.token"         --> t("<") <+> n("word") <+> t(">")

            // Basics
            "word.capitalized"  --> t(.uppercaseLetters) <+> n("word")
            "word"              --> n("string")
            
            "string"            --> n("string") <+> n("char")
                                <|> n("char")
            "char"              --> t(.illegalCharacters
                                        .inverted
                                        .subtracting(.whitespacesAndNewlines)
                                        .subtracting(CharacterSet(charactersIn: "\"{}()<>?*|&,="))
                                    )
            
            "delim.opt"         --> t(",") <|> t()

            "ws.opt"            --> n("ws")
                                <|> t()
            "ws"                --> t(.whitespacesAndNewlines)
        }

        let parser = EarleyParser(grammar: grammar)
        return try parser.syntaxTree(for: string)
    }
}
