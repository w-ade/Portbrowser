import SwiftUI
import AppKit

@main
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private var windows: [NSWindow] = []
    private var sessions: [ObjectIdentifier: BrowserSession] = [:]
    private let viewportSize = NSSize(width: 366, height: 795)
    private let urlBarHeight: CGFloat = 32

    private var contentSize: NSSize {
        NSSize(width: viewportSize.width, height: viewportSize.height + urlBarHeight)
    }

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
        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: contentSize),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )

        window.title = "Visto"
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
                    .frame(width: viewportSize.width, height: viewportSize.height)

                URLBarView(session: session)
                    .frame(width: viewportSize.width, height: urlBarHeight)
            }
            .frame(width: contentSize.width, height: contentSize.height)
        )
        placeOnMainDisplay(window)

        windows.append(window)
        sessions[ObjectIdentifier(window)] = session

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

    func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else {
            return
        }

        sessions.removeValue(forKey: ObjectIdentifier(window))
        windows.removeAll { $0 === window }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    private func placeOnMainDisplay(_ window: NSWindow) {
        let screen = NSScreen.screens.first { $0.frame.origin == .zero } ?? NSScreen.main ?? NSScreen.screens.first

        guard let visibleFrame = screen?.visibleFrame else {
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
        let appMenu = NSMenu(title: "Visto")
        appMenu.addItem(menuItem(title: "Quit Visto", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
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
