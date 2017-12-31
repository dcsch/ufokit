//
//  ViewController.swift
//  UFOSample
//
//  Created by David Schweinsberg on 12/18/17.
//  Copyright © 2017 David Schweinsberg. All rights reserved.
//

import Cocoa
import UFOKit

class ViewController: NSViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    do {
      let homeURL = FileManager.default.homeDirectoryForCurrentUser
      let fontsURL = homeURL.appendingPathComponent("adobe-fonts/source-sans-pro/Roman/Masters/master_0")
      let ufoURL = fontsURL.appendingPathComponent("SourceSans_ExtraLight.ufo")
      let ufoReader = try UFOReader(url: ufoURL)
      let glyphSet = try ufoReader.glyphSet()

//      let unicodes = try glyphSet.unicodes()
//      let cmap = try ufoReader.characterMapping()
//      print(cmap)

//      let components = try glyphSet.componentReferences()
//      print(components)

//      let groups = try ufoReader.readGroups()
//      print(groups)

//      let info = try ufoReader.readInfo()

//      let kerning = try ufoReader.readKerning()
//      print(kerning)

//      let lib = try ufoReader.readLib()
//      print(lib)

//      let features = try ufoReader.readFeatures()
//      print(features)

//      let modDate = try glyphSet.glifModificationTime(glyphName: "atilde")

      let pen = QuartzPen(glyphSet: glyphSet)
//      try glyphSet.readGlyph(glyphName: "a", pointPen: pen)
//      try glyphSet.readGlyph(glyphName: "A", pointPen: pen)
      try glyphSet.readGlyph(glyphName: "at", pointPen: pen)
//      try glyphSet.readGlyph(glyphName: "atilde", pointPen: pen)

      if let glyphView = self.view as? GlyphView {
        glyphView.glyphPath = pen.path
      }

    } catch UFOError.notDirectoryPath {
      print("Exception: ")
    } catch {
      print("Something else: \(error)")
    }
  }

  override var representedObject: Any? {
    didSet {
    // Update the view, if already loaded.
    }
  }


}
