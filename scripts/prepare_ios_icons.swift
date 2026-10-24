// Deterministic packaging of the existing emblem, not a new logo design.
// Runs only on the macOS builder; outputs opaque PNGs required by the store.
import AppKit
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let source = root.appendingPathComponent("assets/images/lullabyte_emblem.png")
guard let emblem = NSImage(contentsOf: source) else { fatalError("Missing LullaByte emblem") }
let directory = root.appendingPathComponent("ios/Runner/Assets.xcassets/AppIcon.appiconset")
let manifest = try Data(contentsOf: directory.appendingPathComponent("Contents.json"))
let json = try JSONSerialization.jsonObject(with: manifest) as! [String: Any]
for entry in json["images"] as! [[String: Any]] {
    guard let filename = entry["filename"] as? String,
          let size = entry["size"] as? String,
          let scale = entry["scale"] as? String,
          let points = Double(size.components(separatedBy: "x")[0]),
          let multiplier = Double(scale.replacingOccurrences(of: "x", with: "")) else { continue }
    let pixels = Int((points * multiplier).rounded())
    guard let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pixels,
        pixelsHigh: pixels, bitsPerSample: 8, samplesPerPixel: 3, hasAlpha: false,
        isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)
        else { fatalError("Cannot allocate app icon") }
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
    NSColor(calibratedRed: 1, green: 0.984, blue: 0.973, alpha: 1).setFill()
    NSRect(x: 0, y: 0, width: CGFloat(pixels), height: CGFloat(pixels)).fill()
    let edge = CGFloat(pixels) * 0.84
    let inset = (CGFloat(pixels) - edge) / 2
    emblem.draw(in: NSRect(x: inset, y: inset, width: edge, height: edge))
    NSGraphicsContext.restoreGraphicsState()
    guard let data = bitmap.representation(using: .png, properties: [:]) else { fatalError("Cannot encode icon") }
    try data.write(to: directory.appendingPathComponent(filename))
}
print("Generated opaque LullaByte app icons.")
