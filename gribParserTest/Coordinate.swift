//
//  Coordinate.swift
//  gribParserTest
//
//  Created by Bo Gustafsson on 2018-12-30.
//  Copyright © 2018 Bo Gustafsson. All rights reserved.
//

import Foundation

struct Coordinate {
    var lat = 0.0
    var lon = 0.0
    var latRot = 0.0
    var lonRot = 0.0
    var i = 0
    var j = 0
    init(i: Int, j: Int, lon: Double, lat: Double, longitudeOfFirstGridPointInDegrees lon0: Double, latitudeOfFirstGridPointInDegrees lat0: Double, iDirectionIncrementInDegrees deltaLon: Double, jDirectionIncrementInDegrees deltaLat: Double) {
        self.i = i
        self.j = j
        self.lon = lon
        self.lat = lat
        self.lonRot = lon0 + deltaLon * Double(i)
        self.latRot = lat0 + deltaLat * Double(j)
    }
}
