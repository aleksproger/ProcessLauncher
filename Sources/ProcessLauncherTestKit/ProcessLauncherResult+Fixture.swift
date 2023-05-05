@testable import ProcessLauncher

import Foundation

extension ProcessLauncherResult {
    public static func fixture(
        standardOutput: String = "stdout",
        standardError: String = "stderr",
        terminationStatus: Int = 0
    ) -> ProcessLauncherResult {
        ProcessLauncherResult(
            standardOutput: standardOutput.data(using: .utf8) ?? Data(),
            standardError: standardError.data(using: .utf8) ?? Data(),
            terminationStatus: terminationStatus
        )
    }
}