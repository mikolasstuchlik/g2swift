import ArgumentParser
import Foundation

enum Modes: String, CaseIterable {
    case sourcekit, grammar
}

enum G2SwiftError: LocalizedError {
    case generic(String)
    case notImplemented
} 

@main
struct G2Swift: ParsableCommand {
    @Argument(
        help: "Available modes: \(Modes.allCases.map(\.rawValue))", 
        completion: .list(Modes.allCases.map(\.rawValue))
    ) 
    var mode: String

    @Option(help: "Required in `sourcekit` mode. The name of the module.")
    var moduleName: String?

    @Option(help: "If module is not in stdlib, specify the path to the module.")
    var modulePath: String?
    
    @Option(help: "Required in `sourcekit` mode. Searches recursively in list of SourceKit provided data and prints the name of each element with corresponding kind. (If empty, prints everything)")
    var sourceKitKind: String?

    #if DIAGNOSTIC
    @Flag(help: "If selected, the program will print definition for Module Response, that will parse this module")
    var generateModuleDefinition: Bool = false
    #endif

    @Option(help: "Required in `grammar` mode. Path to the gir .rnc file.")
    var rncPath: String?

    mutating func run() throws {
        guard let selectedMode = Modes(rawValue: mode) else {
            throw G2SwiftError.generic("Invalid mode: \(mode)")
        }

        switch selectedMode {
        case .sourcekit:
            guard let moduleName = moduleName else {
                throw G2SwiftError.generic("Mode \(mode) requires argument moduleName")
            }

            #if DIAGNOSTIC
            SourceKitMode.generateModuleDefinition = generateModuleDefinition
            #endif

            SourceKitMode.loadModule(name: moduleName, path: modulePath, sourceKitKind: sourceKitKind)
        case .grammar:
            guard let rncPath = rncPath else {
                throw G2SwiftError.generic("Mode \(mode) requires argument rncPath")
            }

            GrammarMode.parseRnc(file: rncPath)
        }
    }
}