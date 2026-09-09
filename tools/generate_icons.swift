// Original vector mark. Run from repository root: swift tools/generate_icons.swift
import AppKit
let fm = FileManager.default
func icon(_ size: Int, _ path: String) {
    let rep = NSBitmapImageRep(bitmapDataPlanes:nil,pixelsWide:size,pixelsHigh:size,bitsPerSample:8,samplesPerPixel:4,hasAlpha:true,isPlanar:false,colorSpaceName:.deviceRGB,bytesPerRow:0,bitsPerPixel:0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep:rep)
    let s = CGFloat(size)
    NSColor(calibratedRed:0.03,green:0.06,blue:0.14,alpha:1).setFill()
    NSBezierPath(rect:NSRect(x:0,y:0,width:s,height:s)).fill()
    for i in 0..<3 {
        let inset = s * (0.12 + CGFloat(i)*0.08)
        let p = NSBezierPath(ovalIn:NSRect(x:inset,y:inset,width:s-2*inset,height:s-2*inset))
        p.lineWidth = s * (i == 2 ? 0.035:0.009)
        NSColor(calibratedRed:0.34,green:0.98,blue:0.93,alpha:i == 2 ? 1:0.25).setStroke();p.stroke()
    }
    let bolt = NSBezierPath()
    bolt.move(to:NSPoint(x:s*0.55,y:s*0.75));bolt.line(to:NSPoint(x:s*0.34,y:s*0.45));bolt.line(to:NSPoint(x:s*0.49,y:s*0.45));bolt.line(to:NSPoint(x:s*0.43,y:s*0.23));bolt.line(to:NSPoint(x:s*0.67,y:s*0.55));bolt.line(to:NSPoint(x:s*0.53,y:s*0.55));bolt.close()
    NSColor(calibratedRed:1,green:0.84,blue:0.42,alpha:1).setFill();bolt.fill()
    NSGraphicsContext.restoreGraphicsState()
    try! rep.representation(using:.png,properties:[:])!.write(to:URL(fileURLWithPath:path))
}
for (d,s) in [("mdpi",48),("hdpi",72),("xhdpi",96),("xxhdpi",144),("xxxhdpi",192)] {icon(s,"android/app/src/main/res/mipmap-\(d)/ic_launcher.png")}
for s in [192,512] {icon(s,"web/icons/Icon-\(s).png");icon(s,"web/icons/Icon-maskable-\(s).png")}
icon(32,"web/favicon.png")
let folder="ios/Runner/Assets.xcassets/AppIcon.appiconset"
let json=try! JSONSerialization.jsonObject(with:Data(contentsOf:URL(fileURLWithPath:folder+"/Contents.json"))) as! [String:Any]
for item in json["images"] as! [[String:Any]] {
    if let filename=item["filename"] as? String,let size=item["size"] as? String,let scale=item["scale"] as? String {
        let base=Double(size.components(separatedBy:"x")[0])!
        let multiplier=Double(scale.replacingOccurrences(of:"x",with:""))!
        icon(Int(base*multiplier),folder+"/"+filename)
    }
}
