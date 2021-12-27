import Foundation

// Implementation based on https://github.com/rhx/gir2swift/blob/development/Sources/libgir2swift/utilities/System.swift

enum ProcessError: Error {
    case endedWith(code: Int, error: String?)
    case couldNotBeSpawned
}

private extension ProcessInfo {
    var environmentPaths: [String]? {
        environment["PATH"].flatMap { $0.split(separator: ":", omittingEmptySubsequences: true) }?.map(String.init)
    }
}

private extension Pipe {
    var stringContents: String? {
        String(
            data: self.fileHandleForReading.readDataToEndOfFile(),
            encoding: .utf8
        )?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

/// Return the current working directory
/// - Returns: Upon successful completion, a string containing the pathname is returned.
private func getWorkingDirectory() -> String? {
    guard let dir = getcwd(nil, 0) else { return nil }
    defer { free(dir) }
    let wd = String(cString: dir)
    return wd
}

/// Search for an executable in the path
/// - Parameters:
///   - executable: The executable to search for
///   - path: The array of directories to search in (defaults to the contents of the `PATH` environment variable)
/// - Returns: a `URL` representing the full path of the executable if successful, `nil` otherwise
private func urlForExecutable(named executable: String, in path: [String]) -> URL? {
    guard let workingDirectory = getWorkingDirectory().map(URL.init(fileURLWithPath:)) else {
        return nil
    }

    return path.map { path in
            if #available(macOS 10.11, *) {
                return URL(fileURLWithPath: path, isDirectory: true, relativeTo: workingDirectory)
                    .appendingPathComponent(executable, isDirectory: false)
            } else {
                return URL(fileURLWithPath: path)
                    .appendingPathComponent(executable, isDirectory: false)
            }
        }
        .first { file in
            var directory = ObjCBool(false)
            return  FileManager.default.fileExists(atPath: file.path, isDirectory: &directory)
                    && !directory.boolValue
                    && FileManager.default.isExecutableFile(atPath: file.path)
        }
}

/// Create a process to execute the given command
/// - Parameters:
///   - command: the name of the executable to run
///   - path: The array of directories to search in (defaults to the contents of the `PATH` environment variable)
///   - arguments: the arguments to pass to the command
///   - standardInput: the pipe to redirect standard input
///   - standardOutput: the pipe to redirect standard output
///   - standardError: the pipe to redirect standard error
///   - fallbackToEnv: if the executable is not found, attempts to find program `env` and run it through it
/// - Throws: an error if the command cannot be run
/// - Returns: The process being executed.  Call `run()` and then `waitUntilExit()` on the process to collect its `terminationStatus`
private func createProcess(
    command: String,
    in path: [String] = ProcessInfo.processInfo.environmentPaths ?? [],
    arguments: [String] = [],
    standardInput: Any = stdin,
    standardOutput: Any = stdout,
    standardError: Any = stderr,
    fallbackToEnv: Bool
) throws -> Process {
    var arguments = arguments

    var url = urlForExecutable(named: command, in: path)
    if url == nil, fallbackToEnv {
        url = urlForExecutable(named: "env", in: path)
        arguments.insert(command, at: 0)
    }

    guard let url = url else {
        throw POSIXError(.ENOENT)
    }

    let process = Process()

    if !arguments.isEmpty {
        process.arguments = arguments
    }

    process.standardInput = standardInput
    process.standardOutput = standardOutput
    process.standardError = standardError

    if #available(macOS 10.13, *) {
        process.executableURL = url
    } else {
        process.launchPath = url.path
    }

    return process
}


extension Process {
    /// Executes desired program and
    /// - Parameters:
    ///   - program: The name of the program
    ///   - arguments: List of arguments
    /// - Throws: Throws in case, that the process could not be executed or returned non-zero code.
    /// - Returns: The contents of std-out
    static func executeAndWait(_ program: String, arguments: [String], fallbackToEnv: Bool = false) throws -> String? {
        let outPipe = Pipe()
        let inPipe = Pipe()
        let errorPipe = Pipe()
        let process = try createProcess(
            command: program,
            arguments: arguments,
            standardInput: inPipe,
            standardOutput: outPipe,
            standardError: errorPipe,
            fallbackToEnv: fallbackToEnv
        )

        if #available(macOS 10.13, *) {
            try process.run()
        } else {
            process.launch()
        }
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw ProcessError.endedWith(code: Int(process.terminationStatus), error: errorPipe.stringContents)
        }

        return outPipe.stringContents
    }
}
