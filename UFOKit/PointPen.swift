//
//  PointPen.swift
//  UFOKit
//
//  Created by David Schweinsberg on 12/18/17.
//  Copyright © 2017 David Schweinsberg. All rights reserved.
//

import Foundation
import os.log

public enum SegmentType {
  case move
  case line
  case offCurve
  case curve
  case qCurve
}

struct Point {
  var pt: CGPoint
  var type: SegmentType
  var smooth: Bool
  var name: String?
  var identifier: String?
}

public protocol PointPen {
  func beginPath(identifier: String?)
  func endPath()
  func addPoint(_ pt: CGPoint, segmentType: SegmentType, smooth: Bool, name: String?, identifier: String?)
  func addComponent(baseGlyphName: String, transformation: CGAffineTransform, identifier: String?) throws
}

public class QuartzPen: PointPen {
  public let path = CGMutablePath()
  var points = [Point]()
  let glyphSet: GlyphSet

  public init(glyphSet: GlyphSet) {
    self.glyphSet = glyphSet
  }

  public func beginPath(identifier: String?) {
  }

  public func endPath() {
    let count = points.count

    var offset = 0
    while offset < count {
      let point = points[offset % count]
      let point_plus1 = points[(offset + 1) % count]
      let point_plus2 = points[(offset + 2) % count]
      let point_plus3 = points[(offset + 3) % count]

      if offset == 0 {
        path.move(to: point.pt)
      }

      if point_plus1.type == .line {
        path.addLine(to: point_plus1.pt)
        offset += 1
      } else if ((point.type == .curve || point.type == .line) &&
        point_plus1.type == .offCurve && point_plus2.type == .offCurve &&
        point_plus3.type == .curve) {
        path.addCurve(to: point_plus3.pt,
                      control1: point_plus1.pt,
                      control2: point_plus2.pt)
        offset += 3
      } else {
        os_log("point case not catered for!!")
        break
      }
    }

    points.removeAll()
  }

  public func addPoint(_ pt: CGPoint, segmentType: SegmentType, smooth: Bool, name: String?, identifier: String?) {
    points.append(Point(pt: pt, type: segmentType, smooth: smooth, name: name, identifier: identifier))
  }

  public func addComponent(baseGlyphName: String, transformation: CGAffineTransform, identifier: String?) throws {
    let componentPen = QuartzPen(glyphSet: glyphSet)
    try glyphSet.readGlyph(glyphName: baseGlyphName, pointPen: componentPen)
    path.addPath(componentPen.path, transform: transformation)
  }
}
