import AppKit
import Combine
import SwiftUI

struct URLBarView: NSViewRepresentable {
    @ObservedObject var session: BrowserSession

    func makeNSView(context: Context) -> URLBarNSView {
        URLBarNSView(session: session)
    }

    func updateNSView(_ nsView: URLBarNSView, context: Context) {
        nsView.updateSession(session)
    }
}

final class URLBarNSView: NSView, NSTextFieldDelegate {
    private let deviceButton = NSPopUpButton(frame: .zero, pullsDown: false)
    private let addressField = NSTextField()
    private let refreshButton = NSButton()
    private let separator = NSBox()
    private var session: BrowserSession
    private var inputURLCancellable: AnyCancellable?
    private var focusAddressCancellable: AnyCancellable?
    private var devicePresetCancellable: AnyCancellable?

    init(session: BrowserSession) {
        self.session = session
        super.init(frame: .zero)

        wantsLayer = true
        layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor

        configureDeviceButton()
        configureAddressField()
        configureRefreshButton()

        separator.boxType = .separator
        addSubview(separator)

        observeInputURL()
        observeFocusAddress()
        observeDevicePreset()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layout() {
        super.layout()

        let controlHeight: CGFloat = 22
        let controlY = floor((bounds.height - controlHeight) / 2)
        let leading: CGFloat = 12
        let trailing: CGFloat = 7
        let refreshWidth: CGFloat = 24
        let gap: CGFloat = 6
        let deviceWidth: CGFloat = 128

        deviceButton.frame = NSRect(x: leading, y: controlY, width: deviceWidth, height: controlHeight)

        let refreshX = bounds.width - trailing - refreshWidth
        let addressX = leading + deviceWidth + gap
        addressField.frame = NSRect(
            x: addressX,
            y: controlY,
            width: max(80, refreshX - gap - addressX),
            height: controlHeight
        )
        refreshButton.frame = NSRect(x: refreshX, y: controlY, width: refreshWidth, height: controlHeight)
        separator.frame = NSRect(x: 0, y: bounds.height - 1, width: bounds.width, height: 1)
    }

    func updateSession(_ session: BrowserSession) {
        guard self.session !== session else {
            return
        }

        self.session = session
        observeInputURL()
        observeFocusAddress()
        observeDevicePreset()
    }

    func controlTextDidChange(_ notification: Notification) {
        session.inputURL = addressField.stringValue
    }

    private func configureDeviceButton() {
        deviceButton.controlSize = .small
        deviceButton.font = .systemFont(ofSize: 11)
        deviceButton.removeAllItems()

        for preset in DevicePreset.presets {
            deviceButton.addItem(withTitle: preset.name)
            deviceButton.lastItem?.representedObject = preset.id
        }

        deviceButton.target = self
        deviceButton.action = #selector(selectDevice)
        deviceButton.toolTip = "Device viewport"
        addSubview(deviceButton)
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
        refreshButton.image = RefreshIcon.image
        refreshButton.imagePosition = .imageOnly
        refreshButton.setAccessibilityLabel("Reload")
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

    private func observeDevicePreset() {
        devicePresetCancellable = session.$devicePreset
            .removeDuplicates()
            .sink { [weak self] preset in
                guard
                    let self,
                    let index = DevicePreset.presets.firstIndex(where: { $0.id == preset.id })
                else {
                    return
                }

                self.deviceButton.selectItem(at: index)
            }
    }

    @objc private func selectDevice() {
        guard
            let id = deviceButton.selectedItem?.representedObject as? String,
            let preset = DevicePreset.presets.first(where: { $0.id == id })
        else {
            return
        }

        session.devicePreset = preset
    }

    @objc private func loadAddress() {
        DebugLog.log("loadAddress field=\(addressField.stringValue) session=\(ObjectIdentifier(session))")
        session.inputURL = addressField.stringValue
        session.loadInput()
    }

    @objc private func reload() {
        session.reload()
    }
}
