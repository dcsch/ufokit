//
//  GlyphSetTests.swift
//  UFOKitTests
//
//  Created by David Schweinsberg on 3/13/21.
//  Copyright © 2021 David Schweinsberg. All rights reserved.
//

import XCTest
import FontPens
@testable import UFOKit

class GlyphSetTests: XCTestCase {

  var ufoReader: UFOReader!

  override func setUp() {
    super.setUp()

    let testFileURL = URL(fileURLWithPath: #file)
    let testDirURL = testFileURL.deletingLastPathComponent()
    let resourceURL = testDirURL.appendingPathComponent("data/test_v3.ufo")
    do {
      ufoReader = try UFOReader(url: resourceURL)
    } catch {
      print("Error: \(error)")
    }
  }

  override func tearDown() {
    super.tearDown()
  }

  func testWriteGlyph() throws {

    let glyphSet = try self.ufoReader.glyphSet()

    let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(ProcessInfo().globallyUniqueString)
    let ufoWriter = try UFOWriter(url: url)
    var writerGlyphSet = try ufoWriter.glyphSet()
    try writerGlyphSet.writeGlyph(glyphName: "A") { (_ pen: inout GLIFPointPen) in
      do {
        try glyphSet.readGlyph(glyphName: "A", pointPen: &pen)
      } catch {
        print("Exception: \(error)")
      }
    }
  }

}
