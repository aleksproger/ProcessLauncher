import Foundation
import TimeoutStrategy
import os.log

private let log = OSLog(subsystem: "com.ProcessLauncher.TimeoutingReadabilityHandler", category: "TimeoutingReadabilityHandler")

final class TimeoutingReadabilityHandler {
    private let dispatchQueue: DispatchQueue
    private let dispatchSemaphore: DispatchSemaphore
    private var data = Data()

    init(
        dispatchSemaphore: DispatchSemaphore = DispatchSemaphore(value: 0),
        dispatchQueue: DispatchQueue = DispatchQueue(label: "com.ProcessLauncher.TimeoutingReadabilityHandler")
    ) {
        self.dispatchSemaphore = dispatchSemaphore
        self.dispatchQueue = dispatchQueue
    }

    func consume(_ handle: FileHandle) {
        let receivedData = try? handle.readToEnd()
        handle.readabilityHandler = nil
        dispatchQueue.sync {
            data.append(receivedData ?? Data())
            dispatchSemaphore.signal()
        }
    }

    func receive() -> Data {
        if dispatchSemaphore.wait(timeout: .now() + .seconds(10)) != .success {
            os_log(.error, log: log, "Timeout waiting for EOF from command")
        }
        var receivedData = Data()
        dispatchQueue.sync { receivedData = data }
        return receivedData
    }
}
