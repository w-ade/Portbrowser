import Foundation

enum LaunchURL {
    static var value: String? {
        if let environmentValue = ProcessInfo.processInfo.environment["PORTBROWSER_URL"],
           !environmentValue.isEmpty {
            return environmentValue
        }

        return CommandLine.arguments.dropFirst().first { argument in
            !argument.hasPrefix("-")
        }
    }
}
