import ProcessLauncher

public final class ProcessLauncherRetryPolicyMock: ProcessLauncherRetryPolicy {
    public enum Input {
        case shouldRetry(Result<ProcessLauncherResult, Error>)
    }

    public var shouldRetryResult = false

    public private(set) var inputs = [Input]()

    public init() {}

    public func shouldRetry(_ result: Result<ProcessLauncherResult, Error>) -> Bool {
        inputs.append(.shouldRetry(result))
        return shouldRetryResult
    }
}