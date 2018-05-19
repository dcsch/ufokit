//
//  FontInfo.swift
//  UFOKit
//
//  Created by David Schweinsberg on 5/17/18.
//  Copyright © 2018 David Schweinsberg. All rights reserved.
//

import Foundation

let fontStyleToName = [64: "regular",
                       1: "italic",
                       32: "bold",
                       33: "bold italic"]

let widthNameToClass = ["Ultra-condensed": 1,
                        "Extra-condensed": 2,
                        "Condensed": 3,
                        "Semi-condensed": 4,
                        "Medium (normal)": 5,
                        "Semi-expanded": 6,
                        "Expanded": 7,
                        "Extra-expanded": 8,
                        "Ultra-expanded": 9]

let msCharSetToWindowsCharacterSet = [0: 1,
                                      1: 2,
                                      2: 3,
                                      77: 4,
                                      128: 5,
                                      129: 6,
                                      130: 7,
                                      134: 8,
                                      136: 9,
                                      161: 10,
                                      162: 11,
                                      163: 12,
                                      177: 13,
                                      178: 14,
                                      186: 15,
                                      200: 16,
                                      204: 17,
                                      222: 18,
                                      238: 19,
                                      255: 20]

public struct FontInfoV1: Codable {
  var ascender: Float?
  var capHeight: Float?
  var copyright: String?
  var createdBy: String?
  var descender: Float?
  var defaultWidth: Float?
  var designer: String?
  var designerURL: String?
  var familyName: String?
  var fondID: Int?
  var fondName: String?
  var fontName: String?
  var fontStyle: Int?
  var fullName: String?
  var italicAngle: Float?
  var license: String?
  var licenseURL: String?
  var menuName: String?
  var msCharSet: Int?
  var note: String?
  var notice: String?
  var otFamilyName: String?
  var otStyleName: String?
  var otMacName: String?
  var slantAngle: Float?
  var styleName: String?
  var trademark: String?
  var ttUniqueID: String?
  var ttVendor: String?
  var ttVersion: String?
  var uniqueID: Int?
  var unitsPerEm: Float?
  var vendorURL: String?
  var versionMajor: Int?
  var versionMinor: Int?
  var weightName: String?
  var weightValue: Int?
  var widthName: String?
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

  init(fontInfoV1: FontInfoV1) throws {
    self.ascender = fontInfoV1.ascender;
    self.capHeight = fontInfoV1.capHeight;
    self.copyright = fontInfoV1.copyright
    self.openTypeNameManufacturer = fontInfoV1.createdBy
    self.descender = fontInfoV1.descender
    self.postscriptDefaultWidthX = fontInfoV1.defaultWidth
    self.openTypeNameDesigner = fontInfoV1.designer
    self.openTypeNameDesignerURL = fontInfoV1.designerURL
    self.familyName = fontInfoV1.familyName
    self.macintoshFONDFamilyID = fontInfoV1.fondID
    self.postscriptFontName = fontInfoV1.fondName
    self.postscriptFontName = fontInfoV1.fontName
    if let fontStyle = fontInfoV1.fontStyle {
      if fontStyleToName.keys.contains(fontStyle) {
        self.styleMapStyleName = fontStyleToName[fontStyle];
      } else {
        throw UFOError.cannotConvertValue
      }
    }
    self.postscriptFullName = fontInfoV1.fullName
    self.italicAngle = fontInfoV1.italicAngle
    self.openTypeNameLicense = fontInfoV1.license
    self.openTypeNameLicenseURL = fontInfoV1.licenseURL
    self.styleMapFamilyName = fontInfoV1.menuName
    if let msCharSet = fontInfoV1.msCharSet {
      if msCharSetToWindowsCharacterSet.keys.contains(msCharSet) {
        self.self.postscriptWindowsCharacterSet = msCharSetToWindowsCharacterSet[msCharSet];
      } else {
        throw UFOError.cannotConvertValue
      }
    }
    self.note = fontInfoV1.note
    self.openTypeNameDescription = fontInfoV1.notice
    self.openTypeNamePreferredFamilyName = fontInfoV1.otFamilyName
    self.openTypeNamePreferredSubfamilyName = fontInfoV1.otStyleName
    self.openTypeNameCompatibleFullName = fontInfoV1.otMacName
    self.postscriptSlantAngle = fontInfoV1.slantAngle
    self.styleName = fontInfoV1.styleName
    self.trademark = fontInfoV1.trademark
    self.openTypeNameUniqueID = fontInfoV1.ttUniqueID
    self.openTypeOS2VendorID = fontInfoV1.ttVendor
    self.openTypeNameVersion = fontInfoV1.ttVersion
    self.postscriptUniqueID = fontInfoV1.uniqueID
    self.unitsPerEm = fontInfoV1.unitsPerEm
    self.openTypeNameManufacturerURL = fontInfoV1.vendorURL
    self.versionMajor = fontInfoV1.versionMajor
    self.versionMinor = fontInfoV1.versionMinor
    self.postscriptWeightName = fontInfoV1.weightName
    self.openTypeOS2WeightClass = fontInfoV1.weightValue
    if let widthName = fontInfoV1.widthName {
      if widthNameToClass.keys.contains(widthName) {
        self.openTypeOS2WidthClass = widthNameToClass[widthName];
      } else {
        throw UFOError.cannotConvertValue
      }
    }
  }
}
