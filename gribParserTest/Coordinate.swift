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
    init(lon: Double, lat: Double, geography: GribGeographyData ) {
        if geography.rotated {
        let zrad = Double.pi / 180.0
        let zradi = 1.0 / zrad
        let zsycen = sin(zrad * (geography.latitudeOfSouthernPoleInDegrees + 90.0))
        let zcycen = cos(zrad * (geography.latitudeOfSouthernPoleInDegrees + 90.0))
        let zxmxc = zrad * (lon - geography.longitudeOfSouthernPoleInDegrees)
        let zsxmxc = sin(zxmxc)
        let zcxmxc = cos(zxmxc)
        let zsyreg = sin(zrad * lat)
        let zcyreg = cos(zrad * lat)
        var zsyrot = zcycen * zsyreg - zsycen * zcyreg * zcxmxc
        zsyrot = max(zsyrot, -1.0)
        zsyrot = min(zsyrot, 1.0)
        let latRot = asin(zsyrot) * zradi
        let zcyrot = cos(latRot*zrad)
        var zcxrot = (zcycen * zcyreg * zcxmxc + zsycen * zsyreg) / zcyrot
        zcxrot = max(zcxrot, -1.0)
        zcxrot = min(zcxrot, 1.0)
        let zsxrot = zcyreg * zsxmxc / zcyrot
        var lonRot = acos(zcxrot) * zradi
        if zsxrot < 0.0 {lonRot = -lonRot}
            self.latRot = latRot
            self.lonRot = lonRot
        } else {
            self.latRot = lat
            self.lonRot = lon

        }
        self.lat = lat
        self.lon = lon
        self.i = Int((lonRot - geography.longitudeOfFirstGridPointInDegrees) / geography.iDirectionIncrementInDegrees)
        self.j = Int((latRot - geography.latitudeOfFirstGridPointInDegrees) / geography.jDirectionIncrementInDegrees)
    }
}

extension Coordinate: Comparable, Equatable {
    static func < (lhs: Coordinate, rhs: Coordinate) -> Bool {
        if lhs.j < rhs.j {return true}
        if lhs.j == rhs.j && lhs.i < rhs.i {return true}
        return false
    }
}
