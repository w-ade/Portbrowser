import Foundation

enum URLNormalizer {
    static func normalize(_ rawValue: String) -> URL? {
        var value = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !value.isEmpty else {
            return nil
        }

        if value.hasPrefix("localhost:") ||
            value.hasPrefix("127.0.0.1:") ||
            value.hasPrefix("0.0.0.0:") ||
            value.range(of: #"^\d{1,3}(\.\d{1,3}){3}(:|/|$)"#, options: .regularExpression) != nil {
            value = "http://" + value
        } else if !value.contains("://") {
            value = "https://" + value
        }

        return URL(string: value)
    }
}

extension URL {
    /// Host plus any non-default port, e.g. "localhost:3000" or "ref.garden".
    var displayHost: String? {
        guard let host = host() else {
            return nil
        }

        return port.map { "\(host):\($0)" } ?? host
    }
}
