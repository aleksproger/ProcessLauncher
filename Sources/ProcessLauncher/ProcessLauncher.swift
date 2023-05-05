import Foundation
import RetryStrategies
import TimeoutStrategy

public protocol ProcessLauncher {
    /// - Parameters:
    ///   - commands: The list of components that form shell command e.g. ["/usr/bin", "echo"].
    ///
    /// - Returns: The result of process termination synchronously.
    ///
    /// - Warning: Blocks current thread
    func launch(_ commands: [String]) -> Result<ProcessLauncherResult, Error>

    /// - Parameters:
    ///   - commands: The list of components that form shell command e.g. ["/usr/bin", "echo"].
    ///   - completion: Block called asynchronously after the process termination
    func launch(
        _ commands: [String],
        completion: @escaping (Result<ProcessLauncherResult, Error>) -> Void
    )
}

/// Factory methods that simpilfy clients' usage and hide the generic signatures
/// Allows, for unified control of behaviour across clients if needed
public enum ProcessLaunchers {
    public static func common(timeout: Int) -> ProcessLauncher {
        return ProcessLauncherLogging(
            ProcessLauncherDefault(
                timeoutStrategy: TimeoutStrategyDefault(timeout: Double(timeout))
            )
        )
    }

    public static func retrying(
        initialDelay: TimeInterval = 30.0,
        maximumDelay: TimeInterval = 600.0,
        delayMultiplier: Double = 2.0,
        expectedTerminationStatuses: Set<Int> = [0],
        onTimeout: Bool = true,
        timeout: Int = 120
    ) -> ProcessLauncher {
        ProcessLauncherRetrying(
            subject: Self.common(timeout: timeout),
            retryStrategy: DelayBasedRetryStrategy(
                initialDelay: initialDelay,
                maximumDelay: maximumDelay,
                delayMultiplier: delayMultiplier,
                retryPolicy: ProcessLauncherRetryPolicyDefault(
                    expectedTerminationStatuses: expectedTerminationStatuses,
                    onTimeout: onTimeout
                )
            )
        )
    }


    public static func retrying(
        maximumAttempts: Int,
        expectedTerminationStatuses: Set<Int> = [0],
        onTimeout: Bool = true,
        timeout: Int = 120
    ) -> ProcessLauncher {
        ProcessLauncherRetrying(
            subject: Self.common(timeout: timeout),
            retryStrategy: AttemptsBasedRetryStrategy(
                maximumAttempts: maximumAttempts,
                retryPolicy: ProcessLauncherRetryPolicyDefault(
                    expectedTerminationStatuses: expectedTerminationStatuses,
                    onTimeout: onTimeout
                )
            )
        )
    }
}