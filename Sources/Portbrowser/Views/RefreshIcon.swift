import AppKit
import SwiftUI

struct RefreshIcon: View {
    var body: some View {
        Image(nsImage: Self.image)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: 16, height: 16)
    }

    /// Bundled refresh glyph, drawn as a template so it picks up the control tint.
    static let image: NSImage = {
        let bundled = Bundle.module
            .url(forResource: "refresh", withExtension: "svg")
            .flatMap(NSImage.init(contentsOf:))

        let image = bundled
            ?? NSImage(systemSymbolName: "arrow.clockwise", accessibilityDescription: "Reload")!

        image.size = NSSize(width: 16, height: 16)
        image.isTemplate = true

        return image
    }()
}
