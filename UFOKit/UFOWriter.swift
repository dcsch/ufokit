//
//  UFOWriter.swift
//  UFOKit
//
//  Created by David Schweinsberg on 10/15/18.
//  Copyright © 2018 David Schweinsberg. All rights reserved.
//

import Foundation

public class UFOWriter {
  public let url: URL
  public let formatVersion: UFOFormatVersion
  public let fileCreator: String

  public init(url: URL, formatVersion: UFOFormatVersion = .version3,
              fileCreator: String = "com.typista.UFOKit") throws {
    self.url = url
    self.formatVersion = formatVersion
    self.fileCreator = fileCreator

    // Does the file already exist? If so, what version is it?
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: url.path) {
      let metaInfo = try UFOReader.readMetaInfo(url: url)
      let previousFormatVersion = metaInfo.formatVersion
      if previousFormatVersion.rawValue > formatVersion.rawValue {
        throw UFOError.cannotSaveToEarlierVersion
      }
    }

    try writeMetaInfo()
  }

  func writeMetaInfo() throws {
    let metaInfo = MetaInfo(creator: fileCreator,
                            formatVersion: formatVersion)
    let encoder = PropertyListEncoder()
    let metaInfoData = try encoder.encode(metaInfo)
    let metaInfoURL = url.appendingPathComponent("metainfo.plist")
    try metaInfoData.write(to: metaInfoURL)
  }

  public func writeGroups(_ groups: [String: [String]]) throws {
    let encoder = PropertyListEncoder()
    let groupsData = try encoder.encode(groups)
    let groupsURL = url.appendingPathComponent("groups.plist")
    try groupsData.write(to: groupsURL)
  }

  public func writeInfo(_ info: FontInfo) throws {
    let encoder = PropertyListEncoder()
    let infoData = try encoder.encode(info)
    let infoURL = url.appendingPathComponent("fontinfo.plist")
    try infoData.write(to: infoURL)
  }

  public func writeKerning(_ kerning: [String: [String: Int]]) throws {
    let encoder = PropertyListEncoder()
    let kerningData = try encoder.encode(kerning)
    let kerningURL = url.appendingPathComponent("kerning.plist")
    try kerningData.write(to: kerningURL)
  }

  public func writeLib(_ libData: Data) throws {
    let libURL = url.appendingPathComponent("lib.plist")
    try libData.write(to: libURL)
  }

  public func writeFeatures(_ features: String) throws {
    let featuresData = features.data(using: .ascii) ?? Data()
    let featuresURL = url.appendingPathComponent("features.fea")
    try featuresData.write(to: featuresURL)
  }

  public func writeLayerContents(_ layerOrder: [(String, String)]) throws {

    // Convert the tuples into arrays
    var layerArrays = [[String]]()
    for layer in layerOrder {
      layerArrays.append([layer.0, layer.1])
    }
    let encoder = PropertyListEncoder()
    let layerContentsData = try encoder.encode(layerArrays)
    let layerContentsURL = url.appendingPathComponent("layercontents.plist")
    try layerContentsData.write(to: layerContentsURL)
  }

  public func makeGlyphPath() {

  }

  public func glyphSet() {

  }

}
