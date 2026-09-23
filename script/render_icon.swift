// Renders Icon/AppIcon.icns from the "Soft depth" design: a white tile with a
// top-light diagonal gradient, an inner highlight edge, and a soft drop shadow.
// Values come from the mockup's 176 px tile, scaled to Apple's 824 pt body on a
// 1024 pt canvas. Run: swift script/render_icon.swift
import AppKit
import SwiftUI

let canvas: CGFloat = 1024
let body: CGFloat = 824
let k = body / 176 // mockup px -> icon pt

struct Tile: View {
    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 176 * 0.22 * k, style: .continuous)

        ZStack {
            // 0 14px 28px -10px rgba(0,0,0,0.2): negative spread = a smaller caster.
            shape
                .fill(.black)
                .padding(10 * k)
                .blur(radius: 14 * k)
                .offset(y: 14 * k)
                .opacity(0.2)

            // 0 1px 2px rgba(0,0,0,0.06)
            shape
                .fill(.black)
                .blur(radius: 1 * k)
                .offset(y: 1 * k)
                .opacity(0.06)

            // linear-gradient(155deg, #FFFFFF 0%, #FBFBFC 55%, #F1F1F3 100%)
            shape.fill(LinearGradient(
                stops: [
                    .init(color: Color(red: 1, green: 1, blue: 1), location: 0),
                    .init(color: Color(red: 0xFB / 255, green: 0xFB / 255, blue: 0xFC / 255), location: 0.55),
                    .init(color: Color(red: 0xF1 / 255, green: 0xF1 / 255, blue: 0xF3 / 255), location: 1)
                ],
                startPoint: UnitPoint(x: 0.289, y: 0.047),
                endPoint: UnitPoint(x: 0.711, y: 0.953)
            ))

            // inset 0 1px 0 rgba(255,255,255,0.9): bright top edge.
            shape
                .stroke(.white.opacity(0.9), lineWidth: 2 * k)
                .offset(y: 1 * k)
                .mask(shape)

            // inset 0 -1px 1px rgba(0,0,0,0.04): faint bottom edge.
            shape
                .stroke(.black.opacity(0.04), lineWidth: 2 * k)
                .blur(radius: 0.5 * k)
                .offset(y: -1 * k)
                .mask(shape)
        }
        .frame(width: 824, height: 824)
        .frame(width: canvas, height: canvas)
        // The drop shadow's tail would be cut off at the canvas edge; fade it
        // out below the tile (which ends at 0.902) so there's no hard line.
        .mask(LinearGradient(
            stops: [.init(color: .black, location: 0.905), .init(color: .clear, location: 1)],
            startPoint: .top,
            endPoint: .bottom
        ))
    }
}

let root = URL(fileURLWithPath: CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : ".")
let iconset = root.appendingPathComponent("Icon/AppIcon.iconset")
try? FileManager.default.removeItem(at: iconset)
try FileManager.default.createDirectory(at: iconset, withIntermediateDirectories: true)

MainActor.assumeIsolated {
    for (points, scales) in [(16, [1, 2]), (32, [1, 2]), (128, [1, 2]), (256, [1, 2]), (512, [1, 2])] {
        for scale in scales {
            let renderer = ImageRenderer(content: Tile())
            renderer.scale = CGFloat(points * scale) / canvas
            let rep = NSBitmapImageRep(cgImage: renderer.cgImage!)
            let name = scale == 1 ? "icon_\(points)x\(points).png" : "icon_\(points)x\(points)@2x.png"
            try! rep.representation(using: .png, properties: [:])!.write(to: iconset.appendingPathComponent(name))
        }
    }
}
print("wrote \(iconset.path)")
