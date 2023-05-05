import Foundation
import os.log

private let log = OSLog(subsystem: "ProcessLauncher", category: "ProcessLauncher")

public final class ProcessLauncherLogging: ProcessLauncher {
    private let subject: ProcessLauncher

    public init(_ subject: ProcessLauncher) {
        self.subject = subject
    }

    public func launch(_ commands: [String]) -> Result<ProcessLauncherResult, Error> {
        let result = subject.launch(commands)
        logResult(result, of: commands)
        return result
    }

    public func launch(
        _ commands: [String],
        completion: @escaping (Result<ProcessLauncherResult, Error>) -> Void
    ) {
        subject.launch(commands) { [weak self] result in
            self?.logResult(result, of: commands)
            completion(result)
        }
    }

    private func logResult(_ result: Result<ProcessLauncherResult, Error>, of commands: [String]) {
        os_log(.debug, log: log, "Finished running commands: %@", commands)
        switch result {
            case let .success(taskResult):
                os_log(.debug, log: log, "Error output of the command: %@", taskResult.standardErrorString ?? "<Empty stderr>")
                os_log(.debug, log: log, "Output of the command: %@", taskResult.standardOutputString ?? "<Empty stdout>")
                os_log(.debug, log: log, "Termination code of the command: %ld", taskResult.terminationStatus)
            case let .failure(error):
                os_log(.error, log: log, "Error %@ while launching command: %@", error.localizedDescription, commands)
        }
    }
}
