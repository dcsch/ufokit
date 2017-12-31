//: Playground - noun: a place where people can play

import Cocoa
import PlaygroundSupport
import UFOKit

class GlyphView: NSView {
  var glyphPaths = [CGPath]()
  var transforms = [CGAffineTransform]()

  override func draw(_ dirtyRect: NSRect) {
    guard let context = NSGraphicsContext.current?.cgContext else {
      return
    }

    context.setFillColor(CGColor.white)
    context.fill(self.bounds)

    // Render the glyph path
    for (path, transform) in zip(glyphPaths, transforms) {
      context.saveGState()
      context.concatenate(transform)
      context.addPath(path)
      context.restoreGState()
    }
    context.setStrokeColor(CGColor.black)
    context.setFillColor(CGColor.black)
    context.strokePath()
//    context.fillPath()
  }
}

do {
  let homeURL = FileManager.default.homeDirectoryForCurrentUser
  let fontsURL = homeURL.appendingPathComponent("adobe-fonts/source-sans-pro/Roman/Masters/master_0")
  let ufoURL = fontsURL.appendingPathComponent("SourceSans_ExtraLight.ufo")
  let ufoReader = try UFOReader(url: ufoURL)
  let glyphSet = try ufoReader.glyphSet()

  let pen = QuartzPen(glyphSet: glyphSet)
//  try glyphSet.readGlyph(glyphName: "a", pointPen: pen)
  try glyphSet.readGlyph(glyphName: "A", pointPen: pen)
//  try glyphSet.readGlyph(glyphName: "at", pointPen: pen)
  let glyphView = GlyphView(frame: NSRect(x: 0, y: 0, width: 240, height: 480))
  glyphView.glyphPaths.append(pen.path)
  glyphView.transforms.append(CGAffineTransform.identity)

  let bounds = pen.path.boundingBox
//  glyphView.bounds = CGRect(x: 100, y: -300, width: 500, height: 1000)
  glyphView.bounds = bounds

  PlaygroundPage.current.liveView = glyphView
} catch UFOError.notDirectoryPath {
  print("notDirectoryPath")
} catch {
  print("Something else: \(error)")
}
