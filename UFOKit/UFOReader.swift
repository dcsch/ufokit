//
//  UFOReader.swift
//  UFOKit
//
//  Created by David Schweinsberg on 12/22/17.
//  Copyright © 2017 David Schweinsberg. All rights reserved.
//

import Foundation

public enum UFOError: Error {
  case unsupportedVersion
  case notDirectoryPath
  case glyphNameNotFound
}

public enum UFOFormatVersion: Int, Codable {
  case version1 = 1
  case version2 = 2
  case version3 = 3
}

public struct MetaInfo: Codable {
  let creator: String
  let formatVersion: UFOFormatVersion
}

public struct FontInfo: Codable {

  // Generic Identification Information
  var familyName: String?
  var styleName: String?
  var styleMapFamilyName: String?
  var styleMapStyleName: String?
  var versionMajor: Int?
  var versionMinor: Int?
  var year: Int?

  // Generic Legal Information
  var copyright: String?
  var trademark: String?

  // Generic Dimension Information
  var unitsPerEm: Float?
  var descender: Float?
  var xHeight: Float?
  var capHeight: Float?
  var ascender: Float?
  var italicAngle: Float?

  // Generic Miscellaneous Information
  var note: String?

  // OpenType head Table Fields
  var openTypeHeadCreated: String?
  var openTypeHeadLowestRecPPEM: Float?
  var openTypeHeadFlags: [Int]?

  // OpenType hhea Table Fields
  var openTypeHheaAscender: Float?
  var openTypeHheaDescender: Float?
  var openTypeHheaLineGap: Float?
  var openTypeHheaCaretSlopeRise: Int?
  var openTypeHheaCaretSlopeRun: Int?
  var openTypeHheaCaretOffset: Float?

  // OpenType Name Table Fields
  var openTypeNameDesigner: String?
  var openTypeNameDesignerURL: String?
  var openTypeNameManufacturer: String?
  var openTypeNameManufacturerURL: String?
  var openTypeNameLicense: String?
  var openTypeNameLicenseURL: String?
  var openTypeNameVersion: String?
  var openTypeNameUniqueID: String?
  var openTypeNameDescription: String?
  var openTypeNamePreferredFamilyName: String?
  var openTypeNamePreferredSubfamilyName: String?
  var openTypeNameCompatibleFullName: String?
  var openTypeNameSampleText: String?
  var openTypeNameWWSFamilyName: String?
  var openTypeNameWWSSubfamilyName: String?

  // OpenType OS/2 Table Fields
  var openTypeOS2WidthClass: Int?
  var openTypeOS2WeightClass: Int?
  var openTypeOS2Selection: [Int]?
  var openTypeOS2VendorID: String?
  var openTypeOS2Panose: [Int]?
  var openTypeOS2FamilyClass: [Int]?
  var openTypeOS2UnicodeRanges: [Int]?
  var openTypeOS2CodePageRanges: [Int]?
  var openTypeOS2TypoAscender: Float?
  var openTypeOS2TypoDescender: Float?
  var openTypeOS2TypoLineGap: Float?
  var openTypeOS2WinAscent: Float?
  var openTypeOS2WinDescent: Float?
  var openTypeOS2Type: [Int]?
  var openTypeOS2SubscriptXSize: Float?
  var openTypeOS2SubscriptYSize: Float?
  var openTypeOS2SubscriptXOffset: Float?
  var openTypeOS2SubscriptYOffset: Float?
  var openTypeOS2SuperscriptXSize: Float?
  var openTypeOS2SuperscriptYSize: Float?
  var openTypeOS2SuperscriptXOffset: Float?
  var openTypeOS2SuperscriptYOffset: Float?
  var openTypeOS2StrikeoutSize: Float?
  var openTypeOS2StrikeoutPosition: Float?

  // OpenType vhea Table Fields
  var openTypeVheaVertTypoAscender: Float?
  var openTypeVheaVertTypoDescender: Float?
  var openTypeVheaVertTypoLineGap: Float?
  var openTypeVheaCaretSlopeRise: Int?
  var openTypeVheaCaretSlopeRun: Int?
  var openTypeVheaCaretOffset: Float?

  // PostScript Specific Data
  var postscriptFontName: String?
  var postscriptFullName: String?
  var postscriptSlantAngle: Float?
  var postscriptUniqueID: Int?
  var postscriptUnderlineThickness: Float?
  var postscriptUnderlinePosition: Float?
  var postscriptIsFixedPitch: Bool?
  var postscriptBlueValues: [Int]?
  var postscriptOtherBlues: [Int]?
  var postscriptFamilyBlues: [Int]?
  var postscriptFamilyOtherBlues: [Int]?
  var postscriptStemSnapH: [Int]?
  var postscriptStemSnapV: [Int]?
  var postscriptBlueFuzz: Float?
  var postscriptBlueShift: Float?
  var postscriptBlueScale: Float?
  var postscriptForceBold: Bool?
  var postscriptDefaultWidthX: Float?
  var postscriptNominalWidthX: Float?
  var postscriptWeightName: String?
  var postscriptDefaultCharacter: String?
  var postscriptWindowsCharacterSet: Int?

  // Macintosh FOND Resource Data
  var macintoshFONDFamilyID: Int?
  var macintoshFONDName: String?
}

public class UFOReader {
  public let url: URL
  public let metaInfo: MetaInfo

  public init(url: URL) throws {
    self.url = url
    metaInfo = try UFOReader.readMetaInfo(url: url)
  }

  class func readMetaInfo(url: URL) throws -> MetaInfo {
    let metaInfoURL = url.appendingPathComponent("metainfo.plist")
    let metaInfoData = try Data(contentsOf: metaInfoURL)
    let decoder = PropertyListDecoder()
    return try decoder.decode(MetaInfo.self, from: metaInfoData)
  }

  public func readGroups() throws -> [String: [String]] {
    let groupsURL = url.appendingPathComponent("groups.plist")
    let groupsData = try Data(contentsOf: groupsURL)
    let decoder = PropertyListDecoder()
    return try decoder.decode([String: [String]].self, from: groupsData)
  }

  public func readInfo() throws -> FontInfo {
    let infoURL = url.appendingPathComponent("fontinfo.plist")
    let infoData = try Data(contentsOf: infoURL)
    let decoder = PropertyListDecoder()
    return try decoder.decode(FontInfo.self, from: infoData)
  }

  public func readKerning() throws -> [String: [String: Int]] {
    let kerningURL = url.appendingPathComponent("kerning.plist")
    let kerningData = try Data(contentsOf: kerningURL)
    let decoder = PropertyListDecoder()
    return try decoder.decode([String: [String: Int]].self, from: kerningData)
  }

  public func readLib() throws -> Data {
    let libURL = url.appendingPathComponent("lib.plist")
    return try Data(contentsOf: libURL)
  }

  public func readFeatures() throws -> String {
    let featuresURL = url.appendingPathComponent("features.fea")
    let featuresData = try Data(contentsOf: featuresURL)
    return String(data: featuresData, encoding: .ascii) ?? ""
  }

  public func glyphSet() throws -> GlyphSet {
    let glyphDirURL = url.appendingPathComponent("glyphs")
    return try GlyphSet(dirURL: glyphDirURL, ufoFormatVersion: metaInfo.formatVersion)
  }

  public func characterMapping() throws -> [Int: [String]] {
    var characterMap: [Int: [String]] = [:]
    let glyphSet = try self.glyphSet()
    let unicodes = try glyphSet.unicodes()
    for (glyphName, unicodes) in unicodes {
      for unicode in unicodes {
        if var glyphNames = characterMap[unicode] {
          glyphNames.append(glyphName)
        } else {
          characterMap[unicode] = [glyphName]
        }
      }
    }
    return characterMap
  }
}
