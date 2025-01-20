//
//  GribGeographyData.swift
//  gribParserTest
//
//  Created by Bo Gustafsson on 2019-01-01.
//  Copyright © 2019 Bo Gustafsson. All rights reserved.
//

import Foundation

struct GribGeographyData : Equatable {
    var radiusOfTheEarth = 6371229.0
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
    var gridType = GribGridType.regularII
    var nX = 0
    var nY = 0
    var laDInDegrees = 0.0
    var loVInDegrees = 0.0
    var dxInMetres = 0.0
    var dyInMetres = 0.0
    var latin1InDegrees = 0.0
    var latin2InDegrees = 0.0
    var coordinateOfFirstGridPoint : GribCoordinate {
        get {
            return GribCoordinate(lon: longitudeOfFirstGridPointInDegrees, lat: latitudeOfFirstGridPointInDegrees, geography: self)
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
        lhs.longitudeOfSouthernPoleInDegrees == rhs.longitudeOfSouthernPoleInDegrees &&
        lhs.nX == rhs.nX &&
        lhs.nY == rhs.nY &&
        lhs.laDInDegrees == rhs.laDInDegrees &&
        lhs.loVInDegrees == rhs.loVInDegrees &&
        lhs.dxInMetres == rhs.dxInMetres &&
        lhs.dyInMetres == rhs.dyInMetres &&
        lhs.latin1InDegrees == rhs.latin1InDegrees &&
        lhs.latin2InDegrees == rhs.latin2InDegrees
    }
}
