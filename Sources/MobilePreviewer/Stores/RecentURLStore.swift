import Foundation
import Observation

@Observable
final class RecentURLStore {
    private let key = "recentURLs"
    private let limit = 8

    var urls: [String] = []

    init(defaultURL: String? = LaunchURL.value ?? PreviewTarget.defaultURL) {
        load()

        if let defaultURL, !defaultURL.isEmpty {
            add(defaultURL)
        }
    }

    func add(_ url: String) {
        let cleaned = url.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleaned.isEmpty else {
            return
        }

        urls.removeAll { $0.caseInsensitiveCompare(cleaned) == .orderedSame }
        urls.insert(cleaned, at: 0)
        urls = Array(urls.prefix(limit))
        save()
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let decoded = try? JSONDecoder().decode([String].self, from: data)
        else {
            urls = []
            return
        }

        urls = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(urls) else {
            return
        }

        UserDefaults.standard.set(data, forKey: key)
    }
}
