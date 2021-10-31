import SourceKittenFramework
import Foundation

public final class SourceKitDriver {
    public static func request(for module: String, path: String?) throws -> ModuleResponse {
        var arguments: [String] = []

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

        let result = try SourceKittenFramework.Request.moduleInfo(module: module, arguments: arguments).send()

        #if DIAGNOSTIC
        PropertyScanner.responses.append(PropertyScanner.initialize(from: result))
        #endif

        return try ModuleResponse(from: result)
    }
}
