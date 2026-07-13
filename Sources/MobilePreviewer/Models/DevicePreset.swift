import Foundation

struct DevicePreset: Identifiable, Hashable {
    let id: String
    let name: String
    let width: CGFloat
    let height: CGFloat

    static let presets: [DevicePreset] = [
        DevicePreset(id: "iphone-13-mini", name: "iPhone 13 mini", width: 375, height: 812),
        DevicePreset(id: "iphone-15-pro", name: "iPhone 15 Pro", width: 393, height: 852),
        DevicePreset(id: "iphone-16-pro-max", name: "iPhone 16 Pro Max", width: 440, height: 956),
        DevicePreset(id: "pixel", name: "Pixel", width: 412, height: 915)
    ]
}
