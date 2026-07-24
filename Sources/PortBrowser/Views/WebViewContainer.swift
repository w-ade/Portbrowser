import SwiftUI
import WebKit

struct WebViewContainer: NSViewRepresentable {
    let url: URL?
    let reloadToken: Int
    let hardReloadToken: Int
    let pageZoom: CGFloat

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        configuration.defaultWebpagePreferences.preferredContentMode = .mobile

        DebugLog.log("makeNSView (new WKWebView)")

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 26_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.0 Mobile/15E148 Safari/604.1"
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = context.coordinator
        webView.setValue(true, forKey: "drawsBackground")

        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        DebugLog.log("updateNSView url=\(url?.absoluteString ?? "nil") reload=\(reloadToken) hard=\(hardReloadToken)")

        let nextZoom = max(0.1, pageZoom)

        if abs(webView.pageZoom - nextZoom) > 0.001 {
            webView.pageZoom = nextZoom
        }

        if context.coordinator.reloadToken != reloadToken {
            context.coordinator.reloadToken = reloadToken
            webView.reload()
        }

        if context.coordinator.hardReloadToken != hardReloadToken {
            context.coordinator.hardReloadToken = hardReloadToken
            clearCacheThenReload(webView)
        }

        guard !context.coordinator.hasLoadedInitialState || context.coordinator.currentURL != url else {
            return
        }

        context.coordinator.hasLoadedInitialState = true
        context.coordinator.currentURL = url

        if let url {
            DebugLog.log("load \(url.absoluteString)")
            webView.load(URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData))
        } else {
            webView.loadHTMLString(emptyStateHTML, baseURL: nil)
        }
    }

    private func clearCacheThenReload(_ webView: WKWebView) {
        let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()

        WKWebsiteDataStore.default().removeData(
            ofTypes: dataTypes,
            modifiedSince: Date(timeIntervalSince1970: 0)
        ) {
            if let url = webView.url {
                webView.load(URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData))
            } else {
                webView.reload()
            }
        }
    }

    private var emptyStateHTML: String {
        """
        <!doctype html>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
          html, body {
            height: 100%;
            margin: 0;
            background: #fff;
          }
        </style>
        """
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        var currentURL: URL?
        var hasLoadedInitialState = false
        var reloadToken = 0
        var hardReloadToken = 0

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DebugLog.log("navigation START \(webView.url?.absoluteString ?? "nil")")
        }
    }
}
