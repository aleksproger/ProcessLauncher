import Foundation
import TimeoutStrategy

public final class ProcessLauncherDefault<Strategy: TimeoutStrategy>: ProcessLauncher 
where Strategy.BlockResult == ProcessLauncherResult {
    private let timeoutStrategy: Strategy

    public init(timeoutStrategy: Strategy) {
        self.timeoutStrategy = timeoutStrategy
    }

    public func launch(_ commands: [String]) -> Result<ProcessLauncherResult, Error> {
        timeoutStrategy.execute({ [weak self] callback in 
            guard let self else {
                callback(.failure(ProcessLauncherError.selfDeinitialized))
                return
            }
            self.run(commands, completion: callback) 
        })
    }

    public func launch(
        _ commands: [String],
        completion: @escaping (Result<ProcessLauncherResult, Error>) -> Void
    ) {
        timeoutStrategy.execute(
            { [weak self] callback in
                guard let self else { 
                    callback(.failure(ProcessLauncherError.selfDeinitialized))
                    return
                }
                self.run(commands, completion: callback) 
            },
            completion: completion
        )
    }

    private func run(
        _ commands: [String],
        completion: @escaping (Result<ProcessLauncherResult, Error>) -> Void
    ) {
        let stdout = TimeoutingReadabilityHandler()
        let stderr = TimeoutingReadabilityHandler()

        do {
            let process = try configureProcess(
                with: commands,
                handleStandardOutput: stdout.consume,
                handleStandardError: stderr.consume
            )

            process.terminationHandler = { launchResult in
                let result = ProcessLauncherResult(standardOutput: stdout.receive(), standardError: stderr.receive(), terminationStatus: Int(launchResult.terminationStatus))
                completion(.success(result))
            }

            try process.run()
        } catch {
            completion(.failure(error))
        }
    }

    private func configureProcess(
        with commands: [String],
        handleStandardOutput: @escaping (FileHandle) -> Void,
        handleStandardError: @escaping (FileHandle) -> Void
    ) throws -> Process {
        guard commands.count > 0 else {
            throw ProcessLauncherError.emptyCommand
        }

        let process = Process()
        process.launchPath = commands[0]

        if commands.count > 1 {
            process.arguments = Array(commands[1...])
        }

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        outputPipe.fileHandleForReading.readabilityHandler = handleStandardOutput
        errorPipe.fileHandleForReading.readabilityHandler = handleStandardError

        return process
    }
}