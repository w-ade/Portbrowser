import AppKit
import SwiftUI

struct ContentView: View {
    @ObservedObject var session: BrowserSession
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isLandscape = false

    // The bundled status-bar asset is drawn for a 402 x 62 iPhone 17 canvas;
    // everything scales off that so the chrome morphs with the device.
    private let designWidth: CGFloat = 402
    private let designStatusHeight: CGFloat = 62

    private var preset: DevicePreset {
        session.devicePreset
    }

    private var viewportWidth: CGFloat {
        isLandscape ? preset.height : preset.width
    }

    private var viewportHeight: CGFloat {
        isLandscape ? preset.width : preset.height
    }

    private var statusScale: CGFloat {
        viewportWidth / designWidth
    }

    private var statusHeight: CGFloat {
        designStatusHeight * statusScale
    }

    private var webViewHeight: CGFloat {
        max(1, viewportHeight - statusHeight)
    }

    var body: some View {
        GeometryReader { proxy in
            let scale = scaleToFit(in: proxy.size)

            ZStack(alignment: .topLeading) {
                Color.white

                deviceViewport(scale: scale)
                statusOverlay(scale: scale)
            }
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.28), value: preset)
        }
        .onAppear {
            session.loadInitialURLIfNeeded()
        }
    }

    private func deviceViewport(scale: CGFloat) -> some View {
        VStack(spacing: 0) {
            Color.white
                .frame(width: viewportWidth, height: statusHeight)

            WebViewContainer(
                url: session.loadedURL,
                reloadToken: session.reloadToken,
                hardReloadToken: session.hardReloadToken,
                pageZoom: 1
            )
            .frame(width: viewportWidth, height: webViewHeight)
        }
        .frame(width: viewportWidth, height: viewportHeight)
        .scaleEffect(scale, anchor: .topLeading)
        .frame(width: viewportWidth * scale, height: viewportHeight * scale, alignment: .topLeading)
        .clipped()
    }

    private func statusOverlay(scale: CGFloat) -> some View {
        IPhoneStatusOverlay()
            .frame(width: designWidth, height: designStatusHeight, alignment: .top)
            .scaleEffect(statusScale * scale, anchor: .topLeading)
            .frame(width: viewportWidth * scale, height: statusHeight * scale, alignment: .topLeading)
            .allowsHitTesting(false)
    }

    private func scaleToFit(in size: CGSize) -> CGFloat {
        let widthScale = size.width / viewportWidth
        let heightScale = size.height / viewportHeight

        return max(0.1, min(1.0, widthScale, heightScale))
    }

}

private struct IPhoneStatusOverlay: View {
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 19, style: .continuous)
                .fill(.black)
                .frame(width: 126, height: 37)
                .padding(.top, 14)

            if let imageURL = Bundle.module.url(
                forResource: "iphone-status-bar",
                withExtension: "svg"
            ), let statusImage = NSImage(contentsOf: imageURL) {
                Image(nsImage: statusImage)
                    .resizable()
                    .interpolation(.high)
                    .frame(width: 402, height: 62)
            }

            StatusClock()
        }
    }
}

// Live replacement for the time the status-bar asset used to bake in.
// Matches the asset's glyph box: centered at x 73.5, baseline at y 39.
private struct StatusClock: View {
    var body: some View {
        TimelineView(.everyMinute) { context in
            Text(context.date.formatted(.dateTime.hour(.defaultDigits(amPM: .omitted)).minute(.twoDigits)))
                .font(.system(size: 17, weight: .semibold))
                .kerning(0.45)
                .foregroundStyle(.black)
                .fixedSize()
                .position(x: 73.9, y: 32.7)
        }
        .frame(width: 402, height: 62)
    }
}
