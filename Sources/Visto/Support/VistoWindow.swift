import AppKit

/// Utility-style panel so Visto gets the standard compact title bar
/// (traffic lights + title) used by macOS utility apps.
final class VistoWindow: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}
