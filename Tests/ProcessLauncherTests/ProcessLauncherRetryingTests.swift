@testable import ProcessLauncher
import ProcessLauncherTestKit
import RetryStrategies
import RetryStrategiesTestKit

import XCTest

final class ProcessLauncherRetryingTests: XCTestCase {
    private lazy var sut = ProcessLauncherRetrying(
        subject: subject,
        retryStrategy: retryStrategy
    )

    private let subject = ProcessLauncherMock()
    private let retryStrategy = RetryStrategyMock<ProcessLauncherResult, ProcessLauncherRetryPolicyDefault>()
    private let callbackChecker = BlockCallChecker<Result<ProcessLauncherResult, Error>, Void>(())

    func test_Launch_RetryStrategyExecutesBlock() {
        _ = sut.launch(["cmd"])

        XCTAssertEqual(retryStrategy.blocks.count, 1)
    }

    func test_Launch_RetryingBlockCallsSubject() {
        _ = sut.launch(["cmd"])

        _ = retryStrategy.blocks.last?()

        XCTAssertEqual(subject.inputs, [.launch(["cmd"])])
        XCTAssertEqual(subject.completions.count, 0)
    }

    func test_Launch_ReturnsResultObtainedFromStrategy() throws {
        retryStrategy.result = .success(.fixture())
        
        let result = sut.launch(["cmd"])

        XCTAssertEqual(try retryStrategy.result.get(), try result.get())
    }

    func test_LaunchAsync_RetryStrategyExecutesBlock() {
        sut.launch(["cmd"], completion: callbackChecker.call)

        XCTAssertEqual(retryStrategy.asyncBlocks.count, 1)
    }

    func test_LaunchAsync_RetryingBlockCallsSubject() {
        sut.launch(["cmd"], completion: callbackChecker.call)

        retryStrategy.asyncBlocks.last?(callbackChecker.call)

        XCTAssertEqual(subject.inputs, [.launch(["cmd"])])
        XCTAssertEqual(subject.completions.count, 1)
    }

    func test_LaunchAsync_ReturnsResultObtainedFromStrategy() throws {
        retryStrategy.result = .success(.fixture())

        sut.launch(["cmd"], completion: callbackChecker.call)

        XCTAssertEqual(try callbackChecker.inputs.last?.get(), try retryStrategy.result.get())
    }
}