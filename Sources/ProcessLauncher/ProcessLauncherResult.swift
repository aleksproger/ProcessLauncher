import Foundation
@objcMembers
public final class ProcessLauncherResult: NSObject {
    public let standardOutput: Data
    public let standardError: Data
    public let terminationStatus: Int

    init(
        standardOutput: Data,
        standardError: Data,
        terminationStatus: Int
    ) {
        self.standardOutput = standardOutput
        self.standardError = standardError
        self.terminationStatus = terminationStatus
    }
}

extension ProcessLauncherResult {
    public var standardOutputString: String? {
        String(data: standardOutput, encoding: .utf8)
    }

    public var standardErrorString: String? {
        String(data: standardError, encoding: .utf8)
    }
}