//
//  GlyphSet.swift
//  UFOKit
//
//  Created by David Schweinsberg on 12/18/17.
//  Copyright © 2017 David Schweinsberg. All rights reserved.
//

import Foundation
import FontPens
import os.log

public enum GLIFFormatVersion: Int {
  case version1 = 1
  case version2 = 2
}

class UnicodesParser: NSObject, XMLParserDelegate {
  var unicodes: [Int] = []

  func parser(_ parser: XMLParser, didStartElement elementName: String,
              namespaceURI: String?, qualifiedName qName: String?,
              attributes attributeDict: [String: String] = [:]) {
    switch elementName {
    case "unicode":
      if let hexcode = attributeDict["hex"],
        let value = Int(hexcode, radix: 16),
        !unicodes.contains(value) {
        unicodes.append(value)
      }
    default:
      break
    }
  }

}

class ComponentsParser: NSObject, XMLParserDelegate {
  var components: [String] = []

  func parser(_ parser: XMLParser, didStartElement elementName: String,
              namespaceURI: String?, qualifiedName qName: String?,
              attributes attributeDict: [String: String] = [:]) {
    switch elementName {
    case "component":
      if let base = attributeDict["base"] {
        components.append(base)
      }
    default:
      break
    }
  }

}

public protocol FSGlyph {
  var width: CGFloat { get set }
  var height: CGFloat { get set }
  var unicodes: [NSNumber] { get set }
  var note: String { get set }
  var lib: Data { get set }
  var image: [String: Any] { get set }
  var guidelines: [[String: Any]] { get set }
  var anchors: [[String: Any]] { get set }
}

public struct Glyph {
  public var width: Double?
  public var height: Double?
  public var unicodes: [Unicode.Scalar]?
  public var note: String?
  public var lib: Data?
  public var image: [String: Any]?
  public var guidelines: [[String: Any]]?
  public var anchors: [[String: Any]]?

  public init() {
  }

}

public struct GlyphSet: GlyphComponents {
  let dirURL: URL
  let ufoFormatVersion: UFOFormatVersion
  public var contents: [String: String]

  public init(dirURL: URL, ufoFormatVersion: UFOFormatVersion) throws {
    if !dirURL.hasDirectoryPath {
      throw UFOError.notDirectoryPath
    }
    self.dirURL = dirURL
    self.ufoFormatVersion = ufoFormatVersion
    self.contents = [:]
    try rebuildContents()
  }

  public mutating func rebuildContents() throws {
    let contentsURL = dirURL.appendingPathComponent(Filename.contentsFilename)
    do {
      let contentsData = try Data(contentsOf: contentsURL)
      let decoder = PropertyListDecoder()
      contents = try decoder.decode([String: String].self, from: contentsData)
    } catch {
      // Proceed with empty contents
    }
  }

  public var reverseContents: [String: String] {
    get {
      return [:]
    }
  }

  public func writeContents() throws {
    let encoder = PropertyListEncoder()
    encoder.outputFormat = .xml
    let contentsData = try encoder.encode(contents)
    let contentsURL = dirURL.appendingPathComponent(Filename.contentsFilename)
    try contentsData.write(to: contentsURL)
  }

  public func readLayerInfo() {

  }

  public func writeLayerInfo() {

  }

  public func glif(glyphName: String) throws -> Data {
    guard let fileName = contents[glyphName] else {
      throw UFOError.glyphNameNotFound
    }
    let fileURL = dirURL.appendingPathComponent(fileName)
    return try Data(contentsOf: fileURL)
  }

  public func glifModificationTime(glyphName: String) throws -> Date {
    guard let fileName = contents[glyphName] else {
      throw UFOError.glyphNameNotFound
    }
    let fileURL = dirURL.appendingPathComponent(fileName)
    let attr = try FileManager.default.attributesOfItem(atPath: fileURL.path)
    return attr[.modificationDate] as? Date ?? Date()
  }

  func readGlyph<T: PointPen>(glifData: Data, glyph: inout Glyph, pointPen: inout T) throws {
    let glifDoc = try XMLDocument(data: glifData, options: [.documentTidyXML])
    if let root = glifDoc.rootElement(),
      let children = root.children {
      var unicodes = [Unicode.Scalar]()
      var guidelinesArray = [[String: Any]]()
      var anchorsArray = [[String: Any]]()
      var readOutline = false
      var readAdvance = false
      var readImage = false
      var readNote = false
      var readLib = false
      for child in children {
        guard let childElement = child as? XMLElement else { continue }
        if childElement.name == "outline" {
          if readOutline {
            throw GlifError.moreThanOneOutline
          }
          try buildOutline(outline: childElement, pointPen: &pointPen)
          readOutline = true
        } else if childElement.name == "advance" {
          if readAdvance {
            throw GlifError.moreThanOneAdvance
          }
          let widthAttr = childElement.attribute(forName: "width")
          glyph.width = Double(widthAttr?.stringValue ?? "0")
          readAdvance = true
        } else if childElement.name == "unicode" {
          let hexAttr = childElement.attribute(forName: "hex")
          if let hexValue = Int(hexAttr?.stringValue ?? "", radix: 16),
            let scalar = Unicode.Scalar(hexValue),
            unicodes.contains(scalar) == false {
            unicodes.append(scalar)
          } else {
            throw GlifError.illegalUnicodeValue
          }
        } else if childElement.name == "guideline" {
          // TODO: We need some test data with guidelines
          if let attributes = childElement.attributes {
            var guidelines = [String: Any]()
            for attr in attributes {
              if let name = attr.name, let value = attr.stringValue {
                guidelines[name] = Double(value) ?? value
              }
            }
            guidelinesArray.append(guidelines)
          }
        } else if childElement.name == "anchor" {
          if let attributes = childElement.attributes {
            var anchors = [String: Any]()
            for attr in attributes {
              if let name = attr.name, let value = attr.stringValue {
                anchors[name] = Double(value) ?? value
              }
            }
            anchorsArray.append(anchors)
          }
        } else if childElement.name == "image" {
          if readImage {
            throw GlifError.moreThanOneImage
          }
          readImage = true
        } else if childElement.name == "note" {
          if readNote {
            throw GlifError.moreThanOneNote
          }
          readNote = true
        } else if childElement.name == "lib" {
          if readLib {
            throw GlifError.moreThanOneLib
          }
          if let libChild = childElement.child(at: 0) as? XMLElement {
            glyph.lib = libChild.xmlString.data(using: .utf8)
          }
          readLib = true
        }
      }
      glyph.unicodes = unicodes
      glyph.guidelines = guidelinesArray
      glyph.anchors = anchorsArray
    }
  }

  public func readGlyph<T: PointPen>(glyphName: String,
                        glyph: inout Glyph,
                        pointPen: inout T) throws {
    let glifData = try glif(glyphName: glyphName)
    try readGlyph(glifData: glifData, glyph: &glyph, pointPen: &pointPen)
  }

  public func readGlyph<T: PointPen>(glyphName: String,
                        glyph fsGlyph: inout FSGlyph,
                        pointPen: inout T) throws {
    let glifData = try glif(glyphName: glyphName)
    var glyph = Glyph()
    try readGlyph(glifData: glifData, glyph: &glyph, pointPen: &pointPen)
    if let width = glyph.width {
      fsGlyph.width = CGFloat(width)
    }
    if let height = glyph.height {
      fsGlyph.height = CGFloat(height)
    }
    if let unicodes = glyph.unicodes {
      fsGlyph.unicodes = unicodes.map { NSNumber(value: $0.value) }
    }
    if let note = glyph.note {
      fsGlyph.note = note
    }
    if let lib = glyph.lib {
      fsGlyph.lib = lib
    }
    if let image = glyph.image {
      fsGlyph.image = image
    }
    if let guidelines = glyph.guidelines {
      fsGlyph.guidelines = guidelines
    }
    if let anchors = glyph.anchors {
      fsGlyph.anchors = anchors
    }
  }

  public func readGlyph<T: PointPen>(glyphName: String, pointPen: inout T) throws {
    let glifData = try glif(glyphName: glyphName)
    var glyph = Glyph()
    try readGlyph(glifData: glifData, glyph: &glyph, pointPen: &pointPen)
  }

  public mutating func writeGlyph(glyphName: String, glyph: Glyph, drawPointsFunc: (_ pen: inout GLIFPointPen) -> Void) throws {

    // glyph
    let root = XMLElement(name: "glyph")
    let glifDoc = XMLDocument(rootElement: root)
    glifDoc.version = "1.0"
    glifDoc.characterEncoding = "UTF-8"
          // name="D" format="2">
      if let nameAttribute = XMLNode.attribute(withName: "name", stringValue: glyphName) as? XMLNode {
          root.addAttribute(nameAttribute)
      }
      //TODO
      if let formatAttribute = XMLNode.attribute(withName: "format", stringValue: "2") as? XMLNode {
          root.addAttribute(formatAttribute)
      }
     
     
    // advance
    let advanceElement = XMLElement(name: "advance")
    root.addChild(advanceElement)
    if let width = glyph.width, width != 0,
      let widthAttr = XMLNode.attribute(withName: "width",
                                        stringValue: String(format: "%g", width)) as? XMLNode {
      advanceElement.addAttribute(widthAttr)
    }
    if let height = glyph.height, height != 0,
      let heightAttr = XMLNode.attribute(withName: "height",
                                         stringValue: String(format: "%g", height)) as? XMLNode {
      advanceElement.addAttribute(heightAttr)
    }
    if advanceElement.attributes?.count == 0 {
      // Either width or height must be present
      throw UFOError.advanceValueMissing
    }

    // unicode
      if let unicodes = glyph.unicodes {
          for unicode in unicodes {
              let unicodeElement = XMLElement(name: "unicode")
              root.addChild(unicodeElement)
              if let unicodeAttr = XMLNode.attribute(withName: "hex",
                                                      stringValue: String(format:"%04X", unicode.value)) as? XMLNode {
                  unicodeElement.addAttribute(unicodeAttr)
              }
          }
      }
    // note

    // image

    // guideline

    // anchor

    // outline
    let outlineElement = XMLElement(name: "outline")
    root.addChild(outlineElement)
    var pen = GLIFPointPen(outlineElement: outlineElement)
    drawPointsFunc(&pen)

    // lib

    let data = glifDoc.xmlData(options: [.nodeCompactEmptyElement, .nodePrettyPrint])
    let filename = contents[glyphName] ?? Filenames.filename(glyphName: glyphName, suffix: ".glif")
    if !contents.keys.contains(glyphName) {
      contents[glyphName] = filename
    }
    let glifURL = dirURL.appendingPathComponent(filename)
    try data.write(to: glifURL)
  }

  public func deleteGlyph(glyphName: String) {

  }

  public func unicodes(glyphNames: [String]? = nil) throws -> [String: [Int]] {
    var unicodes: [String: [Int]] = [:]
    let glyphNames = glyphNames ?? Array(contents.keys)
    for glyphName in glyphNames {
      let data = try glif(glyphName: glyphName)
      let parser = XMLParser(data: data)
      let delegate = UnicodesParser()
      parser.delegate = delegate
      parser.parse()
      unicodes[glyphName] = delegate.unicodes
    }
    return unicodes
  }

  public func componentReferences(glyphNames: [String]? = nil) throws -> [String: [String]] {
    var components: [String: [String]] = [:]
    let glyphNames = glyphNames ?? Array(contents.keys)
    for glyphName in glyphNames {
      let data = try glif(glyphName: glyphName)
      let parser = XMLParser(data: data)
      let delegate = ComponentsParser()
      parser.delegate = delegate
      parser.parse()
      components[glyphName] = delegate.components
    }
    return components
  }

//  public func imageReferences(glyphNames: [String]? = nil) throws {
//
//  }

  func buildOutline<T: PointPen>(outline: XMLElement, pointPen: inout T) throws {
    guard let children = outline.children else { return }
    for node in children {
      guard let element = node as? XMLElement else { continue }
      if element.name == "contour" {
        if element.childCount == 1 {
          // Anchor
        } else {
          try buildOutlineContour(contour: element, pointPen: &pointPen)
        }
      } else if node.name == "component" {
        try buildOutlineComponent(component: element, pointPen: &pointPen)
      }
    }
  }

  func buildOutlineContour<T: PointPen>(contour: XMLElement, pointPen: inout T) throws {
    try pointPen.beginPath(identifier: nil)
    if contour.childCount > 0 {
      try buildOutlinePoints(contour: contour, pointPen: &pointPen)
    }
    try pointPen.endPath()
  }

  func buildOutlinePoints<T: PointPen>(contour: XMLElement, pointPen: inout T) throws {
    for node in contour.children! {
      if let element = node as? XMLElement {
        let x = Double(element.attribute(forName: "x")?.stringValue ?? "0") ?? 0
        let y = Double(element.attribute(forName: "y")?.stringValue ?? "0") ?? 0
        let typeStr = element.attribute(forName: "type")?.stringValue ?? "offcurve"
        var type: SegmentType
        switch typeStr {
        case "move":
          type = .move
        case "line":
          type = .line
        case "offcurve":
          type = .offCurve
        case "curve":
          type = .curve
        case "qcurve":
          type = .qCurve
        default:
          type = .offCurve
        }
        let smooth = element.attribute(forName: "smooth")?.stringValue ?? "no" == "yes"
        let name = element.attribute(forName: "name")?.stringValue
        try pointPen.addPoint(CGPoint(x: x, y: y),
                              segmentType: type,
                              smooth: smooth,
                              name: name,
                              identifier: nil)
      }
    }
  }

  func buildOutlineComponent<T: PointPen>(component: XMLElement, pointPen: inout T) throws {
    let base = component.attribute(forName: "base")?.stringValue ?? ""
    let xScale = CGFloat(Double(component.attribute(forName: "xScale")?.stringValue ?? "1") ?? 1)
    let xyScale = CGFloat(Double(component.attribute(forName: "xyScale")?.stringValue ?? "0") ?? 0)
    let yxScale = CGFloat(Double(component.attribute(forName: "yxScale")?.stringValue ?? "0") ?? 0)
    let yScale = CGFloat(Double(component.attribute(forName: "yScale")?.stringValue ?? "1") ?? 1)
    let xOffset = CGFloat(Double(component.attribute(forName: "xOffset")?.stringValue ?? "0") ?? 0)
    let yOffset = CGFloat(Double(component.attribute(forName: "yOffset")?.stringValue ?? "0") ?? 0)
    let transform = CGAffineTransform(a: xScale, b: xyScale,
                                      c: yxScale, d: yScale,
                                      tx: xOffset, ty: yOffset)
    try pointPen.addComponent(baseGlyphName: base, transformation: transform,
                              identifier: nil)
  }

}
