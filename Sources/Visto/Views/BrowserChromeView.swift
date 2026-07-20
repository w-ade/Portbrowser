import AppKit
import Combine
import SwiftUI

struct BrowserChromeView: NSViewRepresentable {
    @ObservedObject var session: BrowserSession

    func makeNSView(context: Context) -> BrowserChromeNSView {
        BrowserChromeNSView(session: session)
    }

    func updateNSView(_ nsView: BrowserChromeNSView, context: Context) {
        nsView.updateSession(session)
    }
}

final class BrowserChromeNSView: NSView, NSTextFieldDelegate {
    private let closeButton = NSWindow.standardWindowButton(
        .closeButton,
        for: [.titled, .closable]
    )!
    private let minimizeButton = NSWindow.standardWindowButton(
        .miniaturizeButton,
        for: [.titled, .miniaturizable]
    )!
    private let zoomButton = NSWindow.standardWindowButton(
        .zoomButton,
        for: [.titled, .resizable]
    )!
    private let addressField = NSTextField()
    private let refreshButton = NSButton()
    private let separator = NSBox()
    private var session: BrowserSession
    private var inputURLCancellable: AnyCancellable?
    private var focusAddressCancellable: AnyCancellable?

    init(session: BrowserSession) {
        self.session = session
        super.init(frame: .zero)

        wantsLayer = true
        layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor

        configureWindowButtons()
        configureAddressField()
        configureRefreshButton()

        separator.boxType = .separator
        addSubview(separator)

        observeInputURL()
        observeFocusAddress()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layout() {
        super.layout()

        let buttonSize = NSSize(width: 14, height: 14)
        let buttonY = floor((bounds.height - buttonSize.height) / 2)
        closeButton.frame = NSRect(x: 12, y: buttonY, width: buttonSize.width, height: buttonSize.height)
        minimizeButton.frame = NSRect(x: 32, y: buttonY, width: buttonSize.width, height: buttonSize.height)
        zoomButton.frame = NSRect(x: 52, y: buttonY, width: buttonSize.width, height: buttonSize.height)

        let controlHeight: CGFloat = 22
        let controlY = floor((bounds.height - controlHeight) / 2)
        let addressX: CGFloat = 78
        let refreshWidth: CGFloat = 24
        let trailing: CGFloat = 7
        let gap: CGFloat = 5
        let refreshX = bounds.width - trailing - refreshWidth
        addressField.frame = NSRect(
            x: addressX,
            y: controlY,
            width: max(80, refreshX - gap - addressX),
            height: controlHeight
        )
        refreshButton.frame = NSRect(x: refreshX, y: controlY, width: refreshWidth, height: controlHeight)
        separator.frame = NSRect(x: 0, y: 0, width: bounds.width, height: 1)
    }

    override func mouseDown(with event: NSEvent) {
        window?.performDrag(with: event)
    }

    func updateSession(_ session: BrowserSession) {
        guard self.session !== session else {
            return
        }

        self.session = session
        observeInputURL()
        observeFocusAddress()
    }

    func controlTextDidChange(_ notification: Notification) {
        session.inputURL = addressField.stringValue
    }

    private func configureWindowButtons() {
        closeButton.target = self
        closeButton.action = #selector(closeWindow)
        minimizeButton.target = self
        minimizeButton.action = #selector(minimizeWindow)
        zoomButton.isEnabled = false

        addSubview(closeButton)
        addSubview(minimizeButton)
        addSubview(zoomButton)
    }

    private func configureAddressField() {
        addressField.placeholderString = "localhost:3000"
        addressField.controlSize = .small
        addressField.font = .systemFont(ofSize: 12)
        addressField.delegate = self
        addressField.target = self
        addressField.action = #selector(loadAddress)
        addSubview(addressField)
    }

    private func configureRefreshButton() {
        refreshButton.image = NSImage(
            systemSymbolName: "arrow.clockwise",
            accessibilityDescription: "Reload"
        )
        refreshButton.imagePosition = .imageOnly
        refreshButton.isBordered = false
        refreshButton.target = self
        refreshButton.action = #selector(reload)
        refreshButton.toolTip = "Reload"
        addSubview(refreshButton)
    }

    private func observeInputURL() {
        inputURLCancellable = session.$inputURL
            .removeDuplicates()
            .sink { [weak self] inputURL in
                guard let self, self.addressField.currentEditor() == nil else {
                    return
                }

                self.addressField.stringValue = inputURL
            }
    }

    private func observeFocusAddress() {
        focusAddressCancellable = session.$focusAddressToken
            .dropFirst()
            .sink { [weak self] _ in
                guard let self else {
                    return
                }

                self.window?.makeFirstResponder(self.addressField)
                self.addressField.selectText(nil)
            }
    }

    @objc private func closeWindow() {
        window?.close()
    }

    @objc private func minimizeWindow() {
        window?.miniaturize(nil)
    }

    @objc private func loadAddress() {
        session.inputURL = addressField.stringValue
        session.loadInput()
    }

    @objc private func reload() {
        session.reload()
    }
}
