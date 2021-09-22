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
        var arguments: [String]

        #if os(macOS)
        let commands = [
            "-c",
            "echo $(xcrun --show-sdk-platform-path)/Developer/SDKs/MacOSX$(xcrun --show-sdk-version).sdk"
        ]
        guard let sdk = try Process.executeAndWait("bash", arguments: commands, fallbackToEnv: true) else {
            fatalError("SDK select command result was nil")
        }

        arguments = [
            "-sdk",
            sdk
        ]
        #endif

        return try ModuleResponse(response: 
            try SourceKittenFramework.Request.moduleInfo(module: source.rawValue, arguments: arguments).send()
        )
    }
}
