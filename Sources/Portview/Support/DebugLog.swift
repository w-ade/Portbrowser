import Foundation

/// Opt-in tracing for diagnosing reload/render churn. Enable with PORTBROWSER_DEBUG=1.
enum DebugLog {
    static let isEnabled = ProcessInfo.processInfo.environment["PORTBROWSER_DEBUG"] == "1"

    static func log(_ message: @autoclosure () -> String) {
        guard isEnabled else {
            return
        }

        FileHandle.standardError.write(Data("[portview] \(message())\n".utf8))
    }
}
