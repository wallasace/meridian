// Builds icon.icns: a meridian globe over the app's night blue.
import Cocoa

func draw(_ s: CGFloat) -> NSBitmapImageRep {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(s), pixelsHigh: Int(s),
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let ctx = NSGraphicsContext.current!.cgContext

    // Squircle with the margin Apple uses on app icons (~10%).
    let m = s * 0.094, side = s - m * 2
    let card = CGRect(x: m, y: m, width: side, height: side)
    let path = CGPath(roundedRect: card, cornerWidth: side * 0.2237, cornerHeight: side * 0.2237, transform: nil)

    ctx.saveGState()
    ctx.addPath(path); ctx.clip()
    let sp = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [NSColor(srgbRed: 0.137, green: 0.180, blue: 0.259, alpha: 1).cgColor,
                 NSColor(srgbRed: 0.043, green: 0.063, blue: 0.106, alpha: 1).cgColor] as CFArray,
        locations: [0, 1])!
    ctx.drawLinearGradient(sp, start: CGPoint(x: card.minX, y: card.maxY),
                           end: CGPoint(x: card.maxX, y: card.minY), options: [])
    ctx.restoreGState()

    // Centered globe, stroke scaled to size.
    let c = CGPoint(x: s/2, y: s/2), r = side * 0.276
    let w = max(s * 0.0185, 0.8)
    ctx.setStrokeColor(NSColor(srgbRed: 0.498, green: 0.690, blue: 0.918, alpha: 1).cgColor)
    ctx.setLineWidth(w)
    ctx.setLineCap(.round)

    ctx.addEllipse(in: CGRect(x: c.x-r, y: c.y-r, width: r*2, height: r*2))
    ctx.strokePath()

    ctx.move(to: CGPoint(x: c.x-r, y: c.y))          // equator
    ctx.addLine(to: CGPoint(x: c.x+r, y: c.y))
    ctx.strokePath()

    for k in [CGFloat(0.5), -0.5] {                   // two meridians
        ctx.move(to: CGPoint(x: c.x, y: c.y+r))
        ctx.addCurve(to: CGPoint(x: c.x, y: c.y-r),
                     control1: CGPoint(x: c.x + r*k*1.79, y: c.y + r*0.56),
                     control2: CGPoint(x: c.x + r*k*1.79, y: c.y - r*0.56))
        ctx.strokePath()
    }

    // Live dot, the same green as the "LIVE" label.
    let dr = side * 0.052
    ctx.setFillColor(NSColor(srgbRed: 0.294, green: 0.784, blue: 0.604, alpha: 1).cgColor)
    ctx.fillEllipse(in: CGRect(x: c.x + r*0.82, y: c.y + r*0.82, width: dr, height: dr))

    NSGraphicsContext.restoreGraphicsState()
    return rep
}

let dir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "Meridian.iconset"
try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
for (px, name) in [(16,"16x16"),(32,"16x16@2x"),(32,"32x32"),(64,"32x32@2x"),
                   (128,"128x128"),(256,"128x128@2x"),(256,"256x256"),
                   (512,"256x256@2x"),(512,"512x512"),(1024,"512x512@2x")] {
    let png = draw(CGFloat(px)).representation(using: .png, properties: [:])!
    try! png.write(to: URL(fileURLWithPath: "\(dir)/icon_\(name).png"))
}
print("iconset gerado em \(dir)")
