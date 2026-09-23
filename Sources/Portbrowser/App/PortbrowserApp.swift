import SwiftUI
import AppKit
import Combine

@main
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private var windows: [NSWindow] = []
    private var sessions: [ObjectIdentifier: BrowserSession] = [:]
    private var presetObservers: [ObjectIdentifier: AnyCancellable] = [:]
    private let urlBarHeight: CGFloat = 32
    private let styleMask: NSWindow.StyleMask = [.titled, .closable, .miniaturizable]
    private let screenMargin: CGFloat = 8

    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()

        app.delegate = delegate
        app.setActivationPolicy(.regular)
        app.run()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        installMainMenu()
        openNewWindow(nil)
    }

    @objc private func openNewWindow(_ sender: Any?) {
        let session = BrowserSession()
        let contentSize = contentSize(for: session.devicePreset, on: mainDisplay)
        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: contentSize),
            styleMask: styleMask,
            backing: .buffered,
            defer: false
        )

        window.title = "Portbrowser"
        window.backgroundColor = .white
        window.isOpaque = true
        window.hasShadow = true
        window.contentMinSize = contentSize
        window.contentMaxSize = contentSize
        window.isReleasedWhenClosed = false
        window.delegate = self
        window.contentView = NSHostingView(
            rootView: VStack(spacing: 0) {
                ContentView(session: session)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                URLBarView(session: session)
                    .frame(maxWidth: .infinity)
                    .frame(height: urlBarHeight)
            }
        )
        placeOnMainDisplay(window)

        windows.append(window)
        sessions[ObjectIdentifier(window)] = session
        presetObservers[ObjectIdentifier(window)] = session.$devicePreset
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self, weak window] preset in
                guard let self, let window else { return }
                self.resize(window, for: preset)
            }

        NSApp.setActivationPolicy(.regular)
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func closeWindow(_ sender: Any?) {
        NSApp.keyWindow?.close()
    }

    @objc private func reloadCurrentWindow(_ sender: Any?) {
        guard let window = NSApp.keyWindow else {
            return
        }

        sessions[ObjectIdentifier(window)]?.reload()
    }

    @objc private func focusLocationCurrentWindow(_ sender: Any?) {
        guard let window = NSApp.keyWindow else {
            return
        }

        sessions[ObjectIdentifier(window)]?.focusAddress()
    }

    // Re-fit when the window moves to another display, so it's 100% wherever that fits.
    func windowDidChangeScreen(_ notification: Notification) {
        guard let window = notification.object as? NSWindow,
              let session = sessions[ObjectIdentifier(window)] else {
            return
        }

        resize(window, for: session.devicePreset)
    }

    func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else {
            return
        }

        sessions.removeValue(forKey: ObjectIdentifier(window))
        presetObservers.removeValue(forKey: ObjectIdentifier(window))
        windows.removeAll { $0 === window }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    private var mainDisplay: NSScreen? {
        NSScreen.screens.first { $0.frame.origin == .zero } ?? NSScreen.main ?? NSScreen.screens.first
    }

    /// The device at 100% (1 point = 1 point) plus the URL bar, scaled down
    /// only when the screen can't fit it.
    private func contentSize(for preset: DevicePreset, on screen: NSScreen?) -> NSSize {
        var scale: CGFloat = 1

        if let visible = screen?.visibleFrame {
            let probe = NSRect(x: 0, y: 0, width: 100, height: 100)
            let titleBarHeight = NSWindow.frameRect(forContentRect: probe, styleMask: styleMask).height - probe.height
            let maxHeight = visible.height - titleBarHeight - urlBarHeight - screenMargin * 2
            let maxWidth = visible.width - screenMargin * 2
            scale = min(1, maxHeight / preset.height, maxWidth / preset.width)
        }

        return NSSize(
            width: (preset.width * scale).rounded(),
            height: (preset.height * scale).rounded() + urlBarHeight
        )
    }

    private func resize(_ window: NSWindow, for preset: DevicePreset) {
        let screen = window.screen ?? mainDisplay
        let size = contentSize(for: preset, on: screen)
        let old = window.frame
        var frame = window.frameRect(forContentRect: NSRect(origin: .zero, size: size))

        // Grow and shrink around the top center so the title bar stays put.
        frame.origin = NSPoint(x: old.midX - frame.width / 2, y: old.maxY - frame.height)

        if let visible = screen?.visibleFrame {
            frame.origin.x = min(max(frame.minX, visible.minX), visible.maxX - frame.width)
            frame.origin.y = min(max(frame.minY, visible.minY), visible.maxY - frame.height)
        }

        window.contentMinSize = size
        window.contentMaxSize = size
        window.setFrame(frame, display: true, animate: !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion)
    }

    private func placeOnMainDisplay(_ window: NSWindow) {
        guard let visibleFrame = mainDisplay?.visibleFrame else {
            window.center()
            return
        }

        let frame = window.frame
        let origin = NSPoint(
            x: visibleFrame.midX - frame.width / 2,
            y: visibleFrame.midY - frame.height / 2
        )

        window.setFrameOrigin(origin)
    }

    private func installMainMenu() {
        let mainMenu = NSMenu()

        let appMenuItem = NSMenuItem()
        let appMenu = NSMenu(title: "Portbrowser")
        appMenu.addItem(menuItem(title: "Quit Portbrowser", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        appMenuItem.submenu = appMenu
        mainMenu.addItem(appMenuItem)

        let fileMenuItem = NSMenuItem()
        let fileMenu = NSMenu(title: "File")
        fileMenu.addItem(menuItem(title: "New Window", action: #selector(openNewWindow(_:)), keyEquivalent: "n"))
        fileMenu.addItem(menuItem(title: "Open Location…", action: #selector(focusLocationCurrentWindow(_:)), keyEquivalent: "k"))
        fileMenu.addItem(.separator())
        fileMenu.addItem(menuItem(title: "Close Window", action: #selector(closeWindow(_:)), keyEquivalent: "w"))
        fileMenuItem.submenu = fileMenu
        mainMenu.addItem(fileMenuItem)

        let editMenuItem = NSMenuItem()
        let editMenu = NSMenu(title: "Edit")
        editMenu.addItem(menuItem(title: "Undo", action: Selector(("undo:")), keyEquivalent: "z"))
        editMenu.addItem(menuItem(title: "Redo", action: Selector(("redo:")), keyEquivalent: "z", modifiers: [.command, .shift]))
        editMenu.addItem(.separator())
        editMenu.addItem(menuItem(title: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x"))
        editMenu.addItem(menuItem(title: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c"))
        editMenu.addItem(menuItem(title: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v"))
        editMenu.addItem(menuItem(title: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a"))
        editMenuItem.submenu = editMenu
        mainMenu.addItem(editMenuItem)

        let viewMenuItem = NSMenuItem()
        let viewMenu = NSMenu(title: "View")
        viewMenu.addItem(menuItem(title: "Reload", action: #selector(reloadCurrentWindow(_:)), keyEquivalent: "r"))
        viewMenuItem.submenu = viewMenu
        mainMenu.addItem(viewMenuItem)

        NSApp.mainMenu = mainMenu
    }

    private func menuItem(
        title: String,
        action: Selector,
        keyEquivalent: String,
        modifiers: NSEvent.ModifierFlags = .command
    ) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: keyEquivalent)
        item.keyEquivalentModifierMask = modifiers
        return item
    }
}
