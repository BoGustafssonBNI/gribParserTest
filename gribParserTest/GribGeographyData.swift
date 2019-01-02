//
//  GribGeographyData.swift
//  gribParserTest
//
//  Created by Bo Gustafsson on 2019-01-01.
//  Copyright © 2019 Bo Gustafsson. All rights reserved.
//

import Foundation

struct GribGeographyData {
    var bitmapPresent = false
    var latitudeOfFirstGridPointInDegrees = 0.0
    var longitudeOfFirstGridPointInDegrees = 0.0
    var latitudeOfLastGridPointInDegrees = 0.0
    var longitudeOfLastGridPointInDegrees = 0.0
    var iScansNegatively = false
    var jScansPositively = true
    var jPointsAreConsecutive = false
    var jDirectionIncrementInDegrees = 0.0
    var iDirectionIncrementInDegrees = 0.0
    var latitudeOfSouthernPoleInDegrees = 0.0
    var longitudeOfSouthernPoleInDegrees = 0.0
    var angleOfRotationInDegrees = 0.0
    var gridType = ""
    var rotated : Bool  {
        get {
            return self.gridType.contains("rotated")
        }
    }
}
