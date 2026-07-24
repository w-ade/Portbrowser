import Combine
import Foundation

@MainActor
final class BrowserSession: ObservableObject {
    @Published var inputURL = ""
    @Published var devicePreset: DevicePreset = .defaultPreset
    @Published private(set) var loadedURL: URL?
    @Published private(set) var reloadToken = 0
    @Published private(set) var hardReloadToken = 0
    @Published private(set) var focusAddressToken = 0

    private let recentStore = RecentURLStore()
    private var hasLoadedInitialURL = false

    func loadInitialURLIfNeeded() {
        DebugLog.log("loadInitialURLIfNeeded already=\(hasLoadedInitialURL) session=\(ObjectIdentifier(self))")

        guard !hasLoadedInitialURL else {
            return
        }

        hasLoadedInitialURL = true

        if let launchURL = LaunchURL.value {
            load(launchURL)
        } else if let recentURL = recentStore.urls.first {
            load(recentURL)
        }
    }

    func loadInput() {
        load(inputURL)
    }

    func load(_ rawValue: String) {
        DebugLog.log("session.load raw=\(rawValue) session=\(ObjectIdentifier(self))")

        guard let url = URLNormalizer.normalize(rawValue) else {
            return
        }

        let normalized = url.absoluteString
        inputURL = normalized
        loadedURL = url
        recentStore.add(normalized)
    }

    func reload() {
        reloadToken += 1
    }

    func focusAddress() {
        focusAddressToken += 1
    }
}
