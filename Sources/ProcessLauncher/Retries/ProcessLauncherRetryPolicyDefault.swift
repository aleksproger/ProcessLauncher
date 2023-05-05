import RetryStrategies
import TimeoutStrategy

public final class ProcessLauncherRetryPolicyDefault: ProcessLauncherRetryPolicy {
    private let expectedTerminationStatuses: Set<Int>
    private let onTimeout: Bool

    public init(
        expectedTerminationStatuses: Set<Int>,
        onTimeout: Bool
    ) {
        self.expectedTerminationStatuses = expectedTerminationStatuses
        self.onTimeout = onTimeout
    }

    public func shouldRetry(_ result: Result<ProcessLauncherResult, Error>) -> Bool {
        switch result {
            case let .success(taskResult):
                return !expectedTerminationStatuses.contains(taskResult.terminationStatus)
            case let .failure(error):
                switch error {
                    case TimeoutStrategyError.timeout:
                        return onTimeout
                    default:
                        return false
                }
        }
    }
}