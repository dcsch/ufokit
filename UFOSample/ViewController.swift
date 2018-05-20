//
//  ViewController.swift
//  UFOSample
//
//  Created by David Schweinsberg on 12/18/17.
//  Copyright © 2017 David Schweinsberg. All rights reserved.
//

import AppKit
import UFOKit

class ViewController: NSViewController {

  @IBOutlet weak var glyphView: GlyphView!
  @IBOutlet weak var popUpButton: NSPopUpButton!

  var info: UFOKit.FontInfo?

  func open(url: URL) {
    do {
      let ufoReader = try UFOReader(url: url)
      let glyphSet = try ufoReader.glyphSet()
      info = try ufoReader.readInfo()
      let pen = QuartzPen(glyphSet: glyphSet)
      try glyphSet.readGlyph(glyphName: "atilde", pointPen: pen)
      let boundingBox = expandToFontBoundingBox(pen.path.boundingBox)
      calculateBounds(containing: boundingBox)
      glyphView.glyphPath = pen.path
    } catch UFOError.notDirectoryPath {
      print("Exception: ")
    } catch {
      print("Something else: \(error)")
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    NotificationCenter.default.addObserver(forName: NSWindow.didResizeNotification,
                                           object: view.window,
                                           queue: nil, using: windowResized)

    do {
      let homeURL = FileManager.default.homeDirectoryForCurrentUser
      let fontsURL = homeURL.appendingPathComponent("projects/fonts")
      let ufoURL = fontsURL.appendingPathComponent("Lato-Black (UFO1).ufo")
//      let fontsURL = homeURL.appendingPathComponent("adobe-fonts/source-sans-pro/Roman/Masters/master_0")
//      let ufoURL = fontsURL.appendingPathComponent("SourceSans_ExtraLight.ufo")
//      let fontsURL = homeURL.appendingPathComponent("adobe-fonts/source-sans-pro/Italic/Masters/master_0")
//      let ufoURL = fontsURL.appendingPathComponent("SourceSans_ExtraLight-Italic.ufo")
      let ufoReader = try UFOReader(url: ufoURL)
      let glyphSet = try ufoReader.glyphSet()

//      let unicodes = try glyphSet.unicodes()
//      let cmap = try ufoReader.characterMapping()
//      print(cmap)

//      let components = try glyphSet.componentReferences()
//      print(components)

//      let groups = try ufoReader.readGroups()
//      print(groups)

      info = try ufoReader.readInfo()

//      let kerning = try ufoReader.readKerning()
//      print(kerning)

      struct RoboFontGuide: Codable {
        var angle: Int
        var isGlobal: Int
        var magnetic: Int
        var name: String
        var x: Int
        var y: Int
      }

      struct RoboFontSort: Codable {
        var ascending: [String]
        var type: String
      }

      class RoboFontLib: Codable {
        var compileSettingsAutohint: Bool?
        var compileSettingsCheckOutlines: Bool?
        var compileSettingsDecompose: Bool?
        var compileSettingsGenerateFormat: Int?
        var compileSettingsReleaseMode: Bool?
        var foregroundLayerStrokeColor: [Double]?
        var guides: [RoboFontGuide]?
        var italicSlantOffset: Int?
        var layerOrder: [String]?
        var maskLayerStrokeColor: [Double]?
        var segmentType: String?
        var shouldAddPointsInSplineConversion: Bool?
        var sort: [RoboFontSort]?
        var groupColors: [String: [Double]]?
        var glyphOrder: [String]?
        var postscriptNames: [String: String]?

        enum CodingKeys: String, CodingKey {
          case compileSettingsAutohint = "com.typemytype.robofont.compileSettings.autohint"
          case compileSettingsCheckOutlines = "com.typemytype.robofont.compileSettings.checkOutlines"
          case compileSettingsDecompose = "com.typemytype.robofont.compileSettings.decompose"
          case compileSettingsGenerateFormat = "com.typemytype.robofont.compileSettings.generateFormat"
          case compileSettingsReleaseMode = "com.typemytype.robofont.compileSettings.releaseMode"
          case foregroundLayerStrokeColor = "com.typemytype.robofont.foreground.layerStrokeColor"
          case guides = "com.typemytype.robofont.guides"
          case italicSlantOffset = "com.typemytype.robofont.italicSlantOffset"
          case layerOrder = "com.typemytype.robofont.layerOrder"
          case maskLayerStrokeColor = "com.typemytype.robofont.mask.layerStrokeColor"
          case segmentType = "com.typemytype.robofont.segmentType"
          case shouldAddPointsInSplineConversion = "com.typemytype.robofont.shouldAddPointsInSplineConversion"
          case sort = "com.typemytype.robofont.sort"
          case groupColors = "com.typesupply.MetricsMachine4.groupColors"
          case glyphOrder = "public.glyphOrder"
          case postscriptNames = "public.postscriptNames"
        }
      }

      let libData = try ufoReader.readLib()
      let decoder = PropertyListDecoder()
      let libProps = try decoder.decode(RoboFontLib.self, from: libData)
      print(libProps.glyphOrder as Any)

//      let features = try ufoReader.readFeatures()
//      print(features)

//      let modDate = try glyphSet.glifModificationTime(glyphName: "atilde")

      let pen = QuartzPen(glyphSet: glyphSet)
//      try glyphSet.readGlyph(glyphName: "a", pointPen: pen)
//      try glyphSet.readGlyph(glyphName: "A", pointPen: pen)
//      try glyphSet.readGlyph(glyphName: "at", pointPen: pen)
      try glyphSet.readGlyph(glyphName: "atilde", pointPen: pen)
//      try glyphSet.readGlyph(glyphName: "period", pointPen: pen)

      let boundingBox = expandToFontBoundingBox(pen.path.boundingBox)
      calculateBounds(containing: boundingBox)

//        glyphView.bounds = bounds
      glyphView.glyphPath = pen.path

    } catch UFOError.notDirectoryPath {
      print("Exception: ")
    } catch {
      print("Something else: \(error)")
    }
  }

  func windowResized(_ notification: Notification) {
    if let path = glyphView.glyphPath {
      let boundingBox = expandToFontBoundingBox(path.boundingBox)
      calculateBounds(containing: boundingBox)
      glyphView.needsDisplay = true
    }
  }

  func expandToFontBoundingBox(_ rect: CGRect) -> CGRect {
    if let descender = info?.descender,
      let ascender = info?.ascender {
      return rect.union(CGRect(x: 0.0, y: descender,
                               width: 0.0, height: ascender - descender))
    } else {
      return rect
    }
  }

  func calculateBounds(containing rect: CGRect) {
    let margin: CGFloat = 20.0
    let bounds = rect
    let boundsAspectRatio = bounds.width / bounds.height
    let frame = glyphView.frame
    let frameAspectRatio = frame.width / frame.height
    let scale = frameAspectRatio < boundsAspectRatio ?
      bounds.width / frame.width :
      bounds.height / frame.height
    let width = frame.size.width * scale;
    let height = frame.size.height * scale;
    glyphView.bounds = bounds.insetBy(dx: (bounds.width - width) / 2.0 - 2.0 * margin,
                                      dy: (bounds.height - height) / 2.0 - 2.0 * margin)
  }

  override var representedObject: Any? {
    didSet {
    // Update the view, if already loaded.
    }
  }

  @IBAction func openDocument(_ sender: Any?) {
    let panel = NSOpenPanel()
    panel.allowedFileTypes = ["ufo"]
    panel.beginSheetModal(for: self.view.window!) { (response: NSApplication.ModalResponse) in
      if response == .OK {
        self.open(url: panel.url!)
      }
    }
  }
}
