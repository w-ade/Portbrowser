import AppKit
import SwiftUI

struct ContentView: View {
    @State private var recentStore = RecentURLStore()
    @State private var inputURL = ""
    @State private var loadedURL: URL?
    @State private var selectedPreset = DevicePreset.defaultPreset
    @State private var isLandscape = false
    @State private var reloadToken = 0
    @State private var hardReloadToken = 0

    private var viewportWidth: CGFloat {
        isLandscape ? selectedPreset.height : selectedPreset.width
    }

    private var viewportHeight: CGFloat {
        isLandscape ? selectedPreset.width : selectedPreset.height
    }

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { proxy in
                let scale = scaleToFit(in: proxy.size)

                ZStack {
                    Color(nsColor: .controlBackgroundColor)

                    deviceViewport(scale: scale)
                }
            }

            urlBar
        }
        .onAppear {
            if let launchURL = LaunchURL.value {
                inputURL = launchURL
                load(launchURL)
            }
        }
    }

    private var urlBar: some View {
        HStack(spacing: 6) {
            TextField("localhost:3000 or 192.168.1.100:3000", text: $inputURL)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 13))
                .onSubmit {
                    load(inputURL)
                }

            Button {
                reloadToken += 1
            } label: {
                RefreshIcon()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .frame(width: 24, height: 24)
            .help("Refresh")
            .keyboardShortcut("r", modifiers: .command)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .frame(height: 46)
        .background(Color(nsColor: .controlBackgroundColor))
        .overlay(alignment: .top) {
            Divider()
        }
    }

    private func deviceViewport(scale: CGFloat) -> some View {
        WebViewContainer(
            url: loadedURL,
            reloadToken: reloadToken,
            hardReloadToken: hardReloadToken,
            pageZoom: scale
        )
        .frame(width: viewportWidth * scale, height: viewportHeight * scale)
        .clipped()
    }

    private func scaleToFit(in size: CGSize) -> CGFloat {
        let widthScale = size.width / viewportWidth
        let heightScale = size.height / viewportHeight

        return max(0.1, min(1.0, widthScale, heightScale))
    }

    private func load(_ rawValue: String) {
        guard let url = URLNormalizer.normalize(rawValue) else {
            return
        }

        let normalized = url.absoluteString
        inputURL = normalized
        loadedURL = url
        recentStore.add(normalized)
    }
}
