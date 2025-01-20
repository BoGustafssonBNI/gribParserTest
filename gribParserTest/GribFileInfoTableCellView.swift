//
//  GribFileInfoTableCellView.swift
//  gribParserTest
//
//  Created by Bo Gustafsson on 2019-01-03.
//  Copyright © 2019 Bo Gustafsson. All rights reserved.
//

import Cocoa

class GribFileInfoTableCellView: NSTableCellView {
    
    @IBOutlet weak var fileNameTextField: NSTextField?
    @IBOutlet weak var gridDataTextField: NSTextField?
    @IBOutlet weak var geographyTextField: NSTextField?
    
    
    var gribFile : GribFile? {
        didSet {
            if let name = gribFile?.fileURL.lastPathComponent {
                fileNameTextField?.cell?.title = name
            }
            if let gridDimensions = gribFile?.parser.gridDimensions, let parameters = gribFile?.parser.parameterList {
                gridDataTextField?.cell?.title = "Grid dimension: I = \(gridDimensions.nI), J = \(gridDimensions.nJ) and Contains \(parameters.count) parameters"
            }
            if let geography = gribFile?.parser.geographyData {
                geographyTextField?.cell?.title = getCoord(geography: geography)
            }
        }
    }
    private func getCoord(geography: GribGeographyData) -> String {
        if geography.gridType == .rotatedII {
            let regCoordFirst = GribCoordinate(lonRot: geography.longitudeOfFirstGridPointInDegrees, latRot: geography.latitudeOfFirstGridPointInDegrees, geography: geography)
            let regCoordLast = GribCoordinate(lonRot: geography.longitudeOfLastGridPointInDegrees, latRot: geography.latitudeOfLastGridPointInDegrees, geography: geography)
            return "\(geography.gridType.rawValue) grid: \(geography.latitudeOfFirstGridPointInDegrees)°N\(geography.longitudeOfFirstGridPointInDegrees)°E to \(geography.latitudeOfLastGridPointInDegrees)°N\(geography.longitudeOfLastGridPointInDegrees)°E with resolution \(geography.iDirectionIncrementInDegrees)°x\(geography.jDirectionIncrementInDegrees)°,\n Location of south pole: \(geography.latitudeOfSouthernPoleInDegrees)°N, \(geography.longitudeOfSouthernPoleInDegrees)°E, \(geography.angleOfRotationInDegrees)°,\n actual grid: \(regCoordFirst.lat.twoDecimals)°N\(regCoordFirst.lon.twoDecimals)°E to \(regCoordLast.lat.twoDecimals)°N\(regCoordLast.lon.twoDecimals)°E"
        }
        return "\(geography.gridType.rawValue) grid: \(geography.latitudeOfFirstGridPointInDegrees)°N\(geography.longitudeOfFirstGridPointInDegrees)°E to \(geography.latitudeOfLastGridPointInDegrees)°N\(geography.longitudeOfLastGridPointInDegrees)°E with resolution \(geography.iDirectionIncrementInDegrees)°x\(geography.jDirectionIncrementInDegrees)°"
    }
}
fileprivate extension Double {
    var twoDecimals : String {
        get {
            return String(0.01 * (self * 100.0).rounded())
        }
    }
}

