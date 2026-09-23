import AppKit
import SwiftUI

struct ContentView: View {
    @ObservedObject var session: BrowserSession
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isLandscape = false

    // iOS keeps status-bar glyphs the same size on every iPhone, so the bar
    // is laid out at the device's width rather than scaled from one design.
    private let statusHeight: CGFloat = 62

    private var preset: DevicePreset {
        session.devicePreset
    }

    private var viewportWidth: CGFloat {
        isLandscape ? preset.height : preset.width
    }

    private var viewportHeight: CGFloat {
        isLandscape ? preset.width : preset.height
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
        IPhoneStatusOverlay(preset: preset, width: viewportWidth)
            .frame(width: viewportWidth, height: statusHeight, alignment: .topLeading)
            .scaleEffect(scale, anchor: .topLeading)
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
    let preset: DevicePreset
    let width: CGFloat

    var body: some View {
        ZStack(alignment: .topLeading) {
            if let islandWidth = preset.islandWidth {
                Capsule(style: .continuous)
                    .fill(.black)
                    .frame(width: islandWidth, height: 37)
                    .position(x: width / 2, y: 14 + 37 / 2)
            }

            // The asset now holds only the right-hand icons; pin them to the
            // right edge so they keep their inset on wider devices.
            if let imageURL = Bundle.module.url(
                forResource: "iphone-status-bar",
                withExtension: "svg"
            ), let statusImage = NSImage(contentsOf: imageURL) {
                Image(nsImage: statusImage)
                    .resizable()
                    .interpolation(.high)
                    .frame(width: 402, height: 62)
                    .offset(x: width - 402)
            }

            StatusClock(center: preset.clockCenter)
        }
        .frame(width: width, height: 62, alignment: .topLeading)
    }
}

// Live replacement for the time the status-bar asset used to bake in.
private struct StatusClock: View {
    let center: CGPoint

    var body: some View {
        TimelineView(.everyMinute) { context in
            Text(context.date.formatted(.dateTime.hour(.defaultDigits(amPM: .omitted)).minute(.twoDigits)))
                .font(.system(size: 17, weight: .semibold))
                .kerning(0.45)
                .foregroundStyle(.black)
                .fixedSize()
                .position(center)
        }
    }
}
