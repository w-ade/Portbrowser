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

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = context.coordinator
        webView.setValue(true, forKey: "drawsBackground")

        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
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

        guard context.coordinator.currentURL != url else {
            return
        }

        context.coordinator.currentURL = url

        if let url {
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
            font: 15px -apple-system, BlinkMacSystemFont, sans-serif;
            color: #8f8f96;
            background: #151518;
            display: grid;
            place-items: center;
          }
        </style>
        <span>Paste a local URL to preview it.</span>
        """
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        var currentURL: URL?
        var reloadToken = 0
        var hardReloadToken = 0
    }
}
