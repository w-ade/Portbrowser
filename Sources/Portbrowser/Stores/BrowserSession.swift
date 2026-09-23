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
    @Published private(set) var goBackToken = 0
    /// Where the web view actually is, which moves on link clicks and redirects.
    @Published private(set) var currentURL: URL?
    @Published private(set) var canGoBack = false

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

    var recentURLs: [String] {
        recentStore.urls
    }

    func goBack() {
        goBackToken += 1
    }

    func didNavigate(to url: URL?, canGoBack: Bool) {
        currentURL = url
        self.canGoBack = canGoBack

        if let url {
            inputURL = url.absoluteString
        }
    }

    func reload() {
        reloadToken += 1
    }

    func focusAddress() {
        focusAddressToken += 1
    }
}
