import Covfefe
import Foundation

public enum Preprocessor {
    public static func replaceDocumentationByTokens(_ text: String) -> (result: String, tokens: [String: String]) {
        var tokens = [String:String]()
        var result = [String]()

        for line in text.split(separator: "\n") {
            if let commentStart = line.firstIndex(of: "#") {
                let comment = line[commentStart...].trimmingCharacters(in: CharacterSet(charactersIn: "#"))
                let token = "<\(tokens.count)>"
                let tokenizedLine = String(line[..<commentStart]) + token
                result.append( tokenizedLine )
                tokens[token] = comment
            } else {
                result.append(String(line))
            }
        }

        return (result.joined(separator: "\n"), tokens)
    }

    public static func dropInitialNamespaceDeclarationsLines(_ text: String) -> String {
        let splitted = text.split(separator: "\n")
        let nonDeclLine = splitted.firstIndex { !$0.contains("namespace") } ?? 0
        return splitted[nonDeclLine...].joined(separator: "\n")
    }

    public static func replaceWhitespacesBySpaces(_ text: String) -> String {
        text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.joined(separator: " ")
    }
}