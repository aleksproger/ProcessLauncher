import Foundation

public enum ProcessLauncherError: Error {
    case emptyCommand
    case selfDeinitialized
}