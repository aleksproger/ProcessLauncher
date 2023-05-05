import ProcessLauncher

public final class ProcessLauncherMock: ProcessLauncher {
    public enum Input: Equatable {
        case launch([String])
    }

    public private(set) var completions: [(Result<ProcessLauncherResult, Error>) -> Void] = []

    public var launchResult: Result<ProcessLauncherResult, Error> = .failure(MockError())

    public private(set) var inputs = [Input]()

    public init() {}

    public func launch(_ commands: [String]) -> Result<ProcessLauncherResult, Error> {
        inputs.append(.launch(commands))
        return launchResult
    }

   public func launch(
        _ commands: [String],
        completion: @escaping (Result<ProcessLauncherResult, Error>) -> Void
    ) {
        inputs.append(.launch(commands))
        completions.append(completion)
        completion(launchResult)
    }
}

private struct MockError: Error {}