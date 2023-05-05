import RetryStrategies

public protocol ProcessLauncherRetryPolicy: RetryPolicy 
where Self.BlockResult == ProcessLauncherResult {
    func shouldRetry(_ result: Result<ProcessLauncherResult, Error>) -> Bool
}
