import SourceKittenFramework
import Foundation

final class SourceKitDriver {
    enum Source: String { 
        case foundation = "Foundation"
        case swift = "Swift"
        case glibc = "Glibc"
        case darwin = "Darwin" 
    }

    static func request(for source: Source) throws -> ModuleResponse {
        try ModuleResponse(response: 
            try SourceKittenFramework.Request.moduleInfo(module: source.rawValue, arguments: []).send()
        )
    }
}