import Foundation

struct DevicePreset: Identifiable, Hashable {
    let id: String
    let name: String
    let width: CGFloat
    let height: CGFloat

    static let presets: [DevicePreset] = [
        DevicePreset(id: "iphone-13-mini", name: "iPhone 13 mini", width: 375, height: 812),
        DevicePreset(id: "iphone-13-and-13-pro", name: "iPhone 13 & 13 Pro", width: 390, height: 844),
        DevicePreset(id: "iphone-13-pro-max", name: "iPhone 13 Pro Max", width: 428, height: 926),

        DevicePreset(id: "iphone-14", name: "iPhone 14", width: 390, height: 844),
        DevicePreset(id: "iphone-14-plus", name: "iPhone 14 Plus", width: 428, height: 926),
        DevicePreset(id: "iphone-14-pro", name: "iPhone 14 Pro", width: 393, height: 852),
        DevicePreset(id: "iphone-14-pro-max", name: "iPhone 14 Pro Max", width: 430, height: 932),

        DevicePreset(id: "iphone-15-and-15-pro", name: "iPhone 15 & 15 Pro", width: 393, height: 852),
        DevicePreset(id: "iphone-15-plus-and-15-pro-max", name: "iPhone 15 Plus & 15 Pro Max", width: 430, height: 932),

        DevicePreset(id: "iphone-16", name: "iPhone 16", width: 393, height: 852),
        DevicePreset(id: "iphone-16-plus", name: "iPhone 16 Plus", width: 430, height: 932),
        DevicePreset(id: "iphone-16-pro", name: "iPhone 16 Pro", width: 402, height: 874),
        DevicePreset(id: "iphone-16-pro-max", name: "iPhone 16 Pro Max", width: 440, height: 956),
        DevicePreset(id: "iphone-16e", name: "iPhone 16e", width: 390, height: 844),

        DevicePreset(id: "iphone-17-and-17-pro", name: "iPhone 17 & 17 Pro", width: 402, height: 874),
        DevicePreset(id: "iphone-17-air", name: "iPhone 17 Air", width: 420, height: 912),
        DevicePreset(id: "iphone-17-pro-max", name: "iPhone 17 Pro Max", width: 440, height: 956)
    ]

    static let defaultPreset = presets.first { $0.id == "iphone-17-and-17-pro" }!
}
