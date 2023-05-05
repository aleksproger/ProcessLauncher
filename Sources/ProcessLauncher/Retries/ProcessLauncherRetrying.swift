import Foundation
import RetryStrategies

public final class ProcessLauncherRetrying<RS: RetryStrategy>: ProcessLauncher 
where RS.BlockResult == ProcessLauncherResult {
    private let subject: ProcessLauncher
    private let retryStrategy: RS

    public init(
        subject: ProcessLauncher,
        retryStrategy: RS
    ) {
        self.subject = subject
        self.retryStrategy = retryStrategy
    }

    public func launch(_ commands: [String]) -> Result<ProcessLauncherResult, Error> {
        retryStrategy.execute({ [weak self] in
            guard let self else { return .failure(ProcessLauncherError.selfDeinitialized) }
            return self.subject.launch(commands) 
        })
    }

    public func launch(
        _ commands: [String],
        completion: @escaping (Result<ProcessLauncherResult, Error>) -> Void
    ) {
        retryStrategy.execute(
            { [weak self] callback in
                guard let self else {
                    return callback(.failure(ProcessLauncherError.selfDeinitialized))
                }
                self.subject.launch(commands, completion: callback) 
            },
            completion: completion
        )
    }
}