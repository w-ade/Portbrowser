import AppKit
import SwiftUI

struct ContentView: View {
    @State private var recentStore = RecentURLStore()
    @State private var inputURL = ""
    @State private var loadedURL: URL?
    @State private var selectedPreset = DevicePreset.presets[1]
    @State private var isLandscape = false
    @State private var isAlwaysOnTop = false
    @State private var reloadToken = 0
    @State private var hardReloadToken = 0
    @State private var window: NSWindow?

    private var viewportWidth: CGFloat {
        isLandscape ? selectedPreset.height : selectedPreset.width
    }

    private var viewportHeight: CGFloat {
        isLandscape ? selectedPreset.width : selectedPreset.height
    }

    var body: some View {
        VStack(spacing: 0) {
            controls

            Divider()

            GeometryReader { proxy in
                let scale = scaleToFit(in: proxy.size)

                ZStack {
                    Color(nsColor: .underPageBackgroundColor)

                    deviceViewport(scale: scale)
                }
            }

            statusBar
        }
        .background(WindowAccessor { resolvedWindow in
            window = resolvedWindow
            applyWindowLevel()
        })
        .onAppear {
            if let firstURL = recentStore.urls.first {
                inputURL = firstURL
                load(firstURL)
            } else {
                let defaultURL = LaunchURL.value ?? PreviewTarget.defaultURL
                inputURL = defaultURL
                load(defaultURL)
            }
        }
        .onChange(of: isAlwaysOnTop) {
            applyWindowLevel()
        }
    }

    private var controls: some View {
        HStack(spacing: 10) {
            TextField("localhost:3000 or 192.168.1.100:3000/rework", text: $inputURL)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 13))
                .onSubmit {
                    load(inputURL)
                }

            Button("Go") {
                load(inputURL)
            }
            .keyboardShortcut(.return, modifiers: .command)

            Picker("Device", selection: $selectedPreset) {
                ForEach(DevicePreset.presets) { preset in
                    Text(preset.name).tag(preset)
                }
            }
            .labelsHidden()
            .frame(width: 170)

            Button {
                isLandscape.toggle()
            } label: {
                Image(systemName: "rectangle.rotate.90")
            }
            .help("Rotate viewport")
            .keyboardShortcut(.return, modifiers: [.command, .shift])

            Button {
                reloadToken += 1
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .help("Reload")
            .keyboardShortcut("r", modifiers: .command)

            Button {
                hardReloadToken += 1
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath")
            }
            .help("Hard reload")
            .keyboardShortcut("r", modifiers: [.command, .shift])

            Toggle(isOn: $isAlwaysOnTop) {
                Image(systemName: "pin")
            }
            .toggleStyle(.button)
            .help("Always on top")
            .keyboardShortcut("t", modifiers: [.command, .shift])
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    private var statusBar: some View {
        HStack(spacing: 8) {
            Text("\(selectedPreset.name) · \(Int(viewportWidth)) x \(Int(viewportHeight))")

            if isAlwaysOnTop {
                Text("Pinned")
            }

            Spacer()

            if !recentStore.urls.isEmpty {
                Menu("Recent") {
                    ForEach(recentStore.urls, id: \.self) { url in
                        Button(url) {
                            inputURL = url
                            load(url)
                        }
                    }
                }
                .menuStyle(.button)
                .fixedSize()
            }
        }
        .font(.system(size: 12))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background(.bar)
    }

    private func deviceViewport(scale: CGFloat) -> some View {
        WebViewContainer(
            url: loadedURL,
            reloadToken: reloadToken,
            hardReloadToken: hardReloadToken,
            pageZoom: scale
        )
        .frame(width: viewportWidth * scale, height: viewportHeight * scale)
        .clipShape(RoundedRectangle(cornerRadius: max(10, 24 * scale)))
        .overlay {
            RoundedRectangle(cornerRadius: max(10, 24 * scale))
                .strokeBorder(.white.opacity(0.18), lineWidth: 1)
                .allowsHitTesting(false)
        }
        .shadow(color: .black.opacity(0.22), radius: max(12, 28 * scale), y: 10)
    }

    private func scaleToFit(in size: CGSize) -> CGFloat {
        let horizontalPadding: CGFloat = 56
        let verticalPadding: CGFloat = 48
        let widthScale = (size.width - horizontalPadding) / viewportWidth
        let heightScale = (size.height - verticalPadding) / viewportHeight

        return max(0.32, min(1.0, widthScale, heightScale))
    }

    private func load(_ rawValue: String) {
        guard let url = URLNormalizer.normalize(rawValue) else {
            return
        }

        let normalized = url.absoluteString
        loadedURL = url
        inputURL = normalized
        recentStore.add(normalized)
    }

    private func applyWindowLevel() {
        window?.level = isAlwaysOnTop ? .floating : .normal
    }
}
