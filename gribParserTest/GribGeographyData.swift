//
//  GribGeographyData.swift
//  gribParserTest
//
//  Created by Bo Gustafsson on 2019-01-01.
//  Copyright © 2019 Bo Gustafsson. All rights reserved.
//

import Foundation

struct GribGeographyData : Equatable {
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
    static func == (lhs: GribGeographyData, rhs: GribGeographyData) -> Bool {
        return lhs.angleOfRotationInDegrees == rhs.angleOfRotationInDegrees &&
        lhs.bitmapPresent == rhs.bitmapPresent &&
        lhs.gridType == rhs.gridType &&
        lhs.iDirectionIncrementInDegrees == rhs.iDirectionIncrementInDegrees &&
        lhs.iScansNegatively == rhs.iScansNegatively &&
        lhs.jDirectionIncrementInDegrees == rhs.jDirectionIncrementInDegrees &&
        lhs.jScansPositively == rhs.jScansPositively &&
        lhs.jPointsAreConsecutive == rhs.jPointsAreConsecutive &&
        lhs.latitudeOfFirstGridPointInDegrees == rhs.latitudeOfFirstGridPointInDegrees &&
        lhs.latitudeOfLastGridPointInDegrees == rhs.latitudeOfLastGridPointInDegrees &&
        lhs.latitudeOfSouthernPoleInDegrees == rhs.latitudeOfSouthernPoleInDegrees &&
        lhs.longitudeOfFirstGridPointInDegrees == rhs.longitudeOfFirstGridPointInDegrees &&
        lhs.longitudeOfLastGridPointInDegrees == rhs.longitudeOfLastGridPointInDegrees &&
        lhs.longitudeOfSouthernPoleInDegrees == rhs.longitudeOfSouthernPoleInDegrees
    }
}
