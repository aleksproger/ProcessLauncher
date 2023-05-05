@testable import ProcessLauncher
import TimeoutStrategyTestKit
import ProcessLauncherTestKit

import XCTest

final class ProcessLauncherDefaultTests: XCTestCase {
    private lazy var sut = ProcessLauncherDefault(
        timeoutStrategy: timeoutStrategy
    )

    private let timeoutStrategy = TimeoutStrategyMock<ProcessLauncherResult>()

    func test_Launch_ExecutesUsingTimeoutStrategy() {
        _ = sut.launch(["cmd"])

        XCTAssertEqual(timeoutStrategy.blocks.count, 1)
    }

    func test_LaunchAsync_ExecutesUsingTimeoutStrategy() {
        sut.launch(["cmd"], completion: { _ in })

        XCTAssertEqual(timeoutStrategy.blocks.count, 1)
        XCTAssertEqual(timeoutStrategy.completions.count, 1)
    }

    func test_Launch_EmptyCommand_ReturnsFailure() {    
        let result = sut.launch([])

        XCTAssertThrowsError(try result.get()) {
            XCTAssertTrue($0 is ProcessLauncherError)
        }
    }

    func test_LaunchAsync_EmptyCommand_ReturnsFailure() {
        sut.launch([]) { result in
            do {
                _ = try result.get()
                XCTFail("Expected to throw")
            } catch {
                guard error is ProcessLauncherError else {
                    return XCTFail("Unexpected error")
                }
            }
        }
    }

    func test_LaunchAsync_NonEmptyCommand_ReturnsSuccess() {
        sut.launch(["/bin/echo"]) { result in
            do {
                _ = try result.get()
            } catch {
                return XCTFail("Unexpected error")
            }
        }
    }

    func test_LaunchAsync_NonEmptyCommand_ReturnsOutputAndStatus() {
        sut.launch(["/bin/echo", "-n", "hello world"]) { result in
            do {
                let result = try result.get()
                XCTAssertEqual(result.standardOutputString ?? "", "hello world")
                XCTAssertEqual(result.standardErrorString ?? "", "")
                XCTAssertEqual(result.terminationStatus, 0)
            } catch {
                return XCTFail("Unexpected error")
            }
        }
    }

    func test_LaunchAsync_ReturnsOutputAndStatusAndError() {
        sut.launch(["/bin/zsh", "-c", "(echo -n 123); (echo -n 456 >&2)"]) { result in
            do {
                let result = try result.get()
                XCTAssertEqual(result.standardOutputString ?? "", "123")
                XCTAssertEqual(result.standardErrorString ?? "", "456")
                XCTAssertEqual(result.terminationStatus, 0)
            } catch {
                return XCTFail("Unexpected error")
            }
        }
    }
}