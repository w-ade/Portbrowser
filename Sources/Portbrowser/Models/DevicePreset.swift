import Foundation

struct DevicePreset: Identifiable, Hashable {
    let id: String
    let name: String
    let width: CGFloat
    let height: CGFloat
    /// Dynamic Island width in points; nil for notch devices (16e, 17e).
    var islandWidth: CGFloat? = 126
    /// Center of the status-bar time's glyph box, in points from the top-left.
    var clockCenter = CGPoint(x: 73.9, y: 32.7)

    // Measured from an iPhone 18 Pro screenshot (iOS 27): smaller island, time shifted right.
    private static let island18: CGFloat = 95
    private static let clock18 = CGPoint(x: 82.0, y: 32.35)

    static let presets: [DevicePreset] = [
        DevicePreset(id: "iphone-16", name: "iPhone 16", width: 393, height: 852),
        DevicePreset(id: "iphone-16-plus", name: "iPhone 16 Plus", width: 430, height: 932),
        DevicePreset(id: "iphone-16-pro", name: "iPhone 16 Pro", width: 402, height: 874),
        DevicePreset(id: "iphone-16-pro-max", name: "iPhone 16 Pro Max", width: 440, height: 956),
        DevicePreset(id: "iphone-16e", name: "iPhone 16e", width: 390, height: 844, islandWidth: nil),

        DevicePreset(id: "iphone-17-and-17-pro", name: "iPhone 17 & 17 Pro", width: 402, height: 874),
        DevicePreset(id: "iphone-17-pro-max", name: "iPhone 17 Pro Max", width: 440, height: 956),
        DevicePreset(id: "iphone-17e", name: "iPhone 17e", width: 390, height: 844, islandWidth: nil),
        DevicePreset(id: "iphone-air", name: "iPhone Air", width: 420, height: 912),

        DevicePreset(id: "iphone-18-pro", name: "iPhone 18 Pro", width: 402, height: 874, islandWidth: island18, clockCenter: clock18),
        DevicePreset(id: "iphone-18-pro-max", name: "iPhone 18 Pro Max", width: 440, height: 956, islandWidth: island18, clockCenter: clock18)
    ]

    static let defaultPreset = presets.first { $0.id == "iphone-18-pro" }!
}
