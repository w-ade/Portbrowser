import AppKit
import SwiftUI

/// iOS Safari's floating bottom bar, drawn in device points over the web view.
/// Geometry measured from an iPhone 18 Pro screenshot: 48 pt controls,
/// 8 pt gaps, 34 pt side and bottom insets.
struct SafariToolbar: View {
    /// How far up from the bottom Safari ends the page's layout viewport:
    /// 34 pt inset + 48 pt bar + 16 pt clearance. Derived from ref.garden's
    /// `fixed bottom-5` footer and `min-h-dvh` centering on a real iPhone 17 Pro.
    static let obscuredHeight: CGFloat = 98

    @ObservedObject var session: BrowserSession
    @State private var isEditing = false
    @State private var draft = ""
    @FocusState private var fieldFocused: Bool

    private let controlHeight: CGFloat = 48

    var body: some View {
        glassGroup {
            HStack(spacing: 8) {
                circleButton("chevron.left", label: "Back") {
                    session.goBack()
                }
                .disabled(!session.canGoBack)
                .opacity(session.canGoBack ? 1 : 0.35)

                addressPill

                circleButton("square.on.square", label: "New Window") {
                    NSApp.sendAction(Selector(("openNewWindow:")), to: nil, from: nil)
                }
            }
        }
        .padding(.horizontal, 34)
        .padding(.bottom, 34)
        .onChange(of: session.focusAddressToken) {
            beginEditing()
        }
    }

    private var addressPill: some View {
        HStack(spacing: 0) {
            Menu {
                deviceMenu
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 19, weight: .medium))
                    .frame(width: 44, height: controlHeight)
                    .contentShape(Rectangle())
            }
            .menuStyle(.button)
            .buttonStyle(.plain)
            .menuIndicator(.hidden)
            .fixedSize()
            .help("Device and history")

            ZStack {
                if isEditing {
                    TextField("Search or enter website", text: $draft)
                        .textFieldStyle(.plain)
                        .font(.system(size: 17))
                        .focused($fieldFocused)
                        .onSubmit(commit)
                        .onExitCommand(perform: endEditing)
                        .onChange(of: fieldFocused) {
                            if !fieldFocused { endEditing() }
                        }
                } else {
                    Text(displayHost)
                        .font(.system(size: 17))
                        .foregroundStyle(session.loadedURL == nil ? .secondary : .primary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture(perform: beginEditing)
                }
            }
            .frame(maxWidth: .infinity)

            Button {
                session.reload()
            } label: {
                RefreshIcon()
                    .frame(width: 20, height: 20)
                    .frame(width: 44, height: controlHeight)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help("Reload")
            .accessibilityLabel("Reload")
        }
        .foregroundStyle(.black)
        .frame(maxWidth: .infinity)
        .frame(height: controlHeight)
        .glass(in: Capsule())
    }

    @ViewBuilder
    private var deviceMenu: some View {
        Picker("Device", selection: Binding(
            get: { session.devicePreset.id },
            set: { id in
                if let preset = DevicePreset.presets.first(where: { $0.id == id }) {
                    session.devicePreset = preset
                }
            }
        )) {
            ForEach(DevicePreset.presets) { preset in
                Text(preset.name).tag(preset.id)
            }
        }
        .pickerStyle(.inline)

        if !session.recentURLs.isEmpty {
            Section("Recent") {
                ForEach(session.recentURLs, id: \.self) { url in
                    Button(url) { session.load(url) }
                }
            }
        }

        Divider()
        Button("Reload") { session.reload() }
    }

    private var displayHost: String {
        guard let url = session.currentURL ?? session.loadedURL, let host = url.host() else {
            return "Search or enter website"
        }

        return url.port.map { "\(host):\($0)" } ?? host
    }

    private func circleButton(_ symbol: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.black)
                .frame(width: controlHeight, height: controlHeight)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .glass(in: Circle())
        .help(label)
        .accessibilityLabel(label)
    }

    private func beginEditing() {
        draft = session.inputURL
        isEditing = true
        DispatchQueue.main.async { fieldFocused = true }
    }

    private func endEditing() {
        isEditing = false
        fieldFocused = false
    }

    private func commit() {
        session.load(draft)
        endEditing()
    }

    @ViewBuilder
    private func glassGroup<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        if #available(macOS 26, *) {
            GlassEffectContainer(spacing: 8, content: content)
        } else {
            content()
        }
    }
}

private extension View {
    /// Liquid Glass on macOS 26+, a frosted material before that.
    @ViewBuilder
    func glass<S: Shape>(in shape: S) -> some View {
        if #available(macOS 26, *) {
            glassEffect(.regular, in: shape)
        } else {
            background(.regularMaterial, in: shape)
                .overlay(shape.stroke(.black.opacity(0.08), lineWidth: 0.5))
                .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
        }
    }
}
