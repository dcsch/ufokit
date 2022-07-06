//
//  GLIFPointPen.swift
//  UFOKit
//
//  Created by David Schweinsberg on 10/17/18.
//  Copyright © 2018 David Schweinsberg. All rights reserved.
//

import Foundation
import FontPens

public struct GLIFPointPen: PointPen {
  let outlineElement: XMLElement
  var currentContour: XMLElement?
  var prevOffCurveCount = 0

  public init(outlineElement: XMLElement) {
    self.outlineElement = outlineElement
  }

  public mutating func beginPath(identifier: String? = nil) throws {
    if currentContour != nil {
      throw UFOError.currentPathNotEnded
    }
    currentContour = XMLElement(name: "contour")
    prevOffCurveCount = 0
  }
    
    public mutating func closePath() throws {
        if let currentContour = currentContour {
            if firstSegmentType == .move && lastSegmentType == .offCurve {
              throw UFOError.openContourEndsOffCurve
            }
            let length = currentContour.childCount
            guard length != 0,
                  let first = currentContour.children?[0] as? XMLElement,
                  let last = currentContour.children? [length - 1] as? XMLElement,
                  first.name == "point",
                  last.name == "point",
                  let connectionType = last.attribute(forName: "type" )
            else { throw UFOError.pathNotBegun }
            first.attribute(forName: "type")?.stringValue = connectionType.stringValue
            currentContour.removeChild(at: length - 1)
            outlineElement.addChild(currentContour)
        } else {
            throw UFOError.pathNotBegun
        }
        currentContour = nil
    }
    
  public mutating func endPath() throws {
    if let currentContour = currentContour {
      if firstSegmentType == .move && lastSegmentType == .offCurve {
        throw UFOError.openContourEndsOffCurve
      }
      outlineElement.addChild(currentContour)
    } else {
      throw UFOError.pathNotBegun
    }
    currentContour = nil
  }

  public mutating func addPoint(_ pt: CGPoint,
                                segmentType: SegmentType = .offCurve,
                                smooth: Bool = false,
                                name: String? = nil,
                                identifier: String? = nil) throws {
    if let currentContour = currentContour {
      let point = XMLElement(name: "point")
      point.setAttributesWith(["x": String(format: "%g", pt.x),
                               "y": String(format: "%g", pt.y)])
      if currentContour.childCount > 0 && segmentType == .move {
        throw UFOError.moveMustBeFirst
      }
      if segmentType == .line && currentContour.childCount > 0 && lastSegmentType == .offCurve {
        throw UFOError.offCurveNotFollowedByCurve
      }
      if segmentType == .curve && prevOffCurveCount > 2 {
        throw UFOError.tooManyOffCurvesBeforeCurve
      }
      if segmentType != .offCurve {
        point.addAttribute(GLIFPointPen.createAttribute(name: "type",
                                                        value: String(describing: segmentType)))
        prevOffCurveCount = 0
      } else {
        prevOffCurveCount += 1
      }
      if smooth {
        if segmentType == .offCurve {
          throw UFOError.offCurveCannotBeSmooth
        }
        point.addAttribute(GLIFPointPen.createAttribute(name: "smooth", value: "yes"))
      }
      if let name = name {
        point.addAttribute(GLIFPointPen.createAttribute(name: "name", value: name))
      }
      if let identifier = identifier {
        point.addAttribute(GLIFPointPen.createAttribute(name: "identifier", value: identifier))
      }
      currentContour.addChild(point)
    } else {
      throw UFOError.pathNotBegun
    }
  }

  public mutating func addComponent(baseGlyphName: String,
                                    transformation: CGAffineTransform,
                                    identifier: String? = nil) throws {
    let component = XMLElement(name: "component")
    component.addAttribute(GLIFPointPen.createAttribute(name: "base", value: baseGlyphName))
    if transformation.a != 1.0 {
      component.addAttribute(
        GLIFPointPen.createAttribute(name: "xScale",
                                     value: String(format: "%g", transformation.a)))
    }
    if transformation.b != 0.0 {
      component.addAttribute(
        GLIFPointPen.createAttribute(name: "xyScale",
                                     value: String(format: "%g", transformation.b)))
    }
    if transformation.c != 0.0 {
      component.addAttribute(
        GLIFPointPen.createAttribute(name: "yxScale",
                                     value: String(format: "%g", transformation.c)))
    }
    if transformation.d != 1.0 {
      component.addAttribute(
        GLIFPointPen.createAttribute(name: "yScale",
                                     value: String(format: "%g", transformation.d)))
    }
    if transformation.tx != 0.0 {
      component.addAttribute(
        GLIFPointPen.createAttribute(name: "xOffset",
                                     value: String(format: "%g", transformation.tx)))
    }
    if transformation.ty != 0.0 {
      component.addAttribute(
        GLIFPointPen.createAttribute(name: "yOffset",
                                     value: String(format: "%g", transformation.ty)))
    }
    outlineElement.addChild(component)
  }

  static func createAttribute(name: String, value: String) -> XMLNode {
    return XMLNode.attribute(withName: name, stringValue: value) as! XMLNode
  }

  static func segmentType(contour: XMLElement, index: Int) -> SegmentType? {
    if let point = contour.child(at: index) as? XMLElement {
      if let typeStr = point.attribute(forName: "type")?.stringValue {
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
        return type
      }
      return .offCurve
    }
    return nil
  }

  var firstSegmentType: SegmentType? {
    get {
      if let currentContour = currentContour {
        return GLIFPointPen.segmentType(contour: currentContour, index: 0)
      } else {
        return nil
      }
    }
  }

  var lastSegmentType: SegmentType? {
    get {
      if let currentContour = currentContour {
        return GLIFPointPen.segmentType(contour: currentContour, index: currentContour.childCount - 1)
      } else {
        return nil
      }
    }
  }

}
