import AppKit
import SwiftUI

struct ContentView: View {
    @ObservedObject var session: BrowserSession
    @State private var selectedPreset = DevicePreset.defaultPreset
    @State private var isLandscape = false
    private let statusHeight: CGFloat = 62

    private var viewportWidth: CGFloat {
        isLandscape ? selectedPreset.height : selectedPreset.width
    }

    private var viewportHeight: CGFloat {
        isLandscape ? selectedPreset.width : selectedPreset.height
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
            .frame(width: viewportWidth, height: statusHeight, alignment: .top)
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
        }
    }
}
