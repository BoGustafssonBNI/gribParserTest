//
//  GribCoordinate.swift
//  gribParserTest
//
//  Created by Bo Gustafsson on 2018-12-30.
//  Copyright © 2018 Bo Gustafsson. All rights reserved.
//

import Foundation

struct GribCoordinate {
    var lat = 0.0
    var lon = 0.0
    var latRot = 0.0
    var lonRot = 0.0
    var i = 0
    var j = 0
    init(i: Int, j: Int, lon: Double, lat: Double, geography: GribGeographyData) {
        self.i = i
        self.j = j
        self.lon = lon < 180.0 ? lon : lon - 360.0
        self.lat = lat
        switch geography.gridType {
        case .regularII, .rotatedII:
            self.lonRot = geography.longitudeOfFirstGridPointInDegrees + geography.iDirectionIncrementInDegrees * Double(i)
            self.latRot = geography.latitudeOfFirstGridPointInDegrees + geography.jDirectionIncrementInDegrees * Double(j)
        case .lambert:
            let zrad = Double.pi / 180.0
            let n : Double
            let f : Double
            if abs(geography.latin1InDegrees - geography.latin2InDegrees) > 0.01 {
                let cosLatinRatio = log(cos(zrad * geography.latin1InDegrees) / cos(zrad * geography.latin2InDegrees))
                let tanLatinRatio = log(tan(Double.pi / 4.0 + zrad * geography.latin2InDegrees / 2.0) / tan(Double.pi / 4.0 + zrad * geography.latin1InDegrees / 2.0))
                n = cosLatinRatio / tanLatinRatio
                f = cos(zrad * geography.latin1InDegrees) * pow(tan(Double.pi / 4.0 + zrad * geography.latin1InDegrees / 2.0), n) / n
            } else {
                n = sin(zrad * geography.latin1InDegrees)
                f = cos(zrad * geography.latin1InDegrees) * pow(tan(Double.pi / 4.0 + zrad * geography.latin1InDegrees / 2.0), n) / n
            }
            let rho = geography.radiusOfTheEarth * f / pow(tan(Double.pi / 4.0 + zrad * self.lat / 2.0), n)
            let rho0 = geography.radiusOfTheEarth * f / pow(tan(Double.pi / 4.0 + zrad * geography.laDInDegrees / 2.0), n)
            let theta = n * zrad * (self.lon - geography.loVInDegrees)
            self.lonRot = rho * sin(theta)
            self.latRot = rho0 - rho * cos(theta)
         }
    }
    init(lon: Double, lat: Double, geography: GribGeographyData ) {
        self.lat = lat
        self.lon = lon < 180.0 ? lon : lon - 360.0
        switch geography.gridType {
        case .rotatedII:
            let zrad = Double.pi / 180.0
            let zradi = 1.0 / zrad
            let zsycen = sin(zrad * (geography.latitudeOfSouthernPoleInDegrees + 90.0))
            let zcycen = cos(zrad * (geography.latitudeOfSouthernPoleInDegrees + 90.0))
            let zxmxc = zrad * (self.lon - geography.longitudeOfSouthernPoleInDegrees)
            let zsxmxc = sin(zxmxc)
            let zcxmxc = cos(zxmxc)
            let zsyreg = sin(zrad * self.lat)
            let zcyreg = cos(zrad * self.lat)
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
            self.i = Int((lonRot - geography.longitudeOfFirstGridPointInDegrees) / geography.iDirectionIncrementInDegrees)
            self.j = Int((latRot - geography.latitudeOfFirstGridPointInDegrees) / geography.jDirectionIncrementInDegrees)
        case .lambert:
            let zrad = Double.pi / 180.0
            let n : Double
            let f : Double
            if abs(geography.latin1InDegrees - geography.latin2InDegrees) > 0.01 {
                let cosLatinRatio = log(cos(zrad * geography.latin1InDegrees) / cos(zrad * geography.latin2InDegrees))
                let tanLatinRatio = log(tan(Double.pi / 4.0 + zrad * geography.latin2InDegrees / 2.0) / tan(Double.pi / 4.0 + zrad * geography.latin1InDegrees / 2.0))
                n = cosLatinRatio / tanLatinRatio
                f = cos(zrad * geography.latin1InDegrees) * pow(tan(Double.pi / 4.0 + zrad * geography.latin1InDegrees / 2.0), n) / n
            } else {
                n = sin(zrad * geography.latin1InDegrees)
                f = cos(zrad * geography.latin1InDegrees) * pow(tan(Double.pi / 4.0 + zrad * geography.latin1InDegrees / 2.0), n) / n
            }
            let rho = geography.radiusOfTheEarth * f / pow(tan(Double.pi / 4.0 + zrad * self.lat / 2.0), n)
            let rho0 = geography.radiusOfTheEarth * f / pow(tan(Double.pi / 4.0 + zrad * geography.laDInDegrees / 2.0), n)
            let theta = n * zrad * (self.lon - geography.loVInDegrees)
            self.lonRot = rho * sin(theta)
            self.latRot = rho0 - rho * cos(theta)
            let firstGridpoint = geography.coordinateOfFirstGridPoint
            self.i = Int((self.lonRot - firstGridpoint.x) / geography.dxInMetres)
            self.j = Int((self.latRot - firstGridpoint.y) / geography.dyInMetres)
         case .regularII:
            self.latRot = self.lat
            self.lonRot = self.lon
            self.i = Int((lonRot - geography.longitudeOfFirstGridPointInDegrees) / geography.iDirectionIncrementInDegrees)
            self.j = Int((latRot - geography.latitudeOfFirstGridPointInDegrees) / geography.jDirectionIncrementInDegrees)
        }
    }
    init(lonRot: Double, latRot: Double, geography: GribGeographyData ) {
        switch geography.gridType {
        case .rotatedII:
            let zrad = Double.pi / 180.0
            let zradi = 1.0 / zrad
            let zsycen = sin(zrad*(geography.latitudeOfSouthernPoleInDegrees+90.0))
            let zcycen = cos(zrad*(geography.latitudeOfSouthernPoleInDegrees+90.0))
            let zsxrot = sin(zrad*lonRot)
            let zcxrot = cos(zrad*lonRot)
            let zsyrot = sin(zrad*latRot)
            let zcyrot = cos(zrad*latRot)
            var zsyreg = zcycen*zsyrot + zsycen*zcyrot*zcxrot
            zsyreg = max(zsyreg,-1.0)
            zsyreg = min(zsyreg,+1.0)
            let lat = asin(zsyreg)*zradi
            let zcyreg = cos(lat*zrad)
            var zcxmxc = (zcycen*zcyrot*zcxrot - zsycen*zsyrot)/zcyreg
            zcxmxc = max(zcxmxc,-1.0)
            zcxmxc = min(zcxmxc,+1.0)
            let zsxmxc = zcyrot*zsxrot/zcyreg
            var zxmxc = acos(zcxmxc)*zradi
            if zsxmxc < 0.0 {zxmxc = -zxmxc}
            let lon = zxmxc + geography.longitudeOfSouthernPoleInDegrees
            self.lat = lat
            self.lon = lon
            self.i = Int((lonRot - geography.longitudeOfFirstGridPointInDegrees) / geography.iDirectionIncrementInDegrees)
            self.j = Int((latRot - geography.latitudeOfFirstGridPointInDegrees) / geography.jDirectionIncrementInDegrees)
        case .lambert:
            let zrad = Double.pi / 180.0
            let n : Double
            let f : Double
            if abs(geography.latin1InDegrees - geography.latin2InDegrees) > 0.01 {
                let cosLatinRatio = log(cos(zrad * geography.latin1InDegrees) / cos(zrad * geography.latin2InDegrees))
                let tanLatinRatio = log(tan(Double.pi / 4.0 + zrad * geography.latin2InDegrees / 2.0) / tan(Double.pi / 4.0 + zrad * geography.latin1InDegrees / 2.0))
                n = cosLatinRatio / tanLatinRatio
                f = cos(zrad * geography.latin1InDegrees) * pow(tan(Double.pi / 4.0 + zrad * geography.latin1InDegrees / 2.0), n) / n
            } else {
                n = sin(zrad * geography.latin1InDegrees)
                f = cos(zrad * geography.latin1InDegrees) * pow(tan(Double.pi / 4.0 + zrad * geography.latin1InDegrees / 2.0), n) / n
            }
            let rho0 = geography.radiusOfTheEarth * f / pow(tan(Double.pi / 4.0 + zrad * geography.laDInDegrees / 2.0), n)
            let rho = (n < 0.0 ? -1.0 : 1.0) * sqrt(lonRot * lonRot + (rho0 - latRot) * (rho0 - latRot))
            let theta = atan2(lonRot, (rho0 - latRot))
            self.lat = (2.0 * atan(pow(geography.radiusOfTheEarth * f / rho, 1.0 / n)) - Double.pi / 2.0) / zrad
            self.lon = theta / n / zrad + geography.loVInDegrees
            let firstGridpoint = geography.coordinateOfFirstGridPoint
            self.i = Int((lonRot - firstGridpoint.x) / geography.dxInMetres)
            self.j = Int((latRot - firstGridpoint.y) / geography.dyInMetres)
        case .regularII:
            self.lat = latRot
            self.lon = lonRot
            self.i = Int((lonRot - geography.longitudeOfFirstGridPointInDegrees) / geography.iDirectionIncrementInDegrees)
            self.j = Int((latRot - geography.latitudeOfFirstGridPointInDegrees) / geography.jDirectionIncrementInDegrees)

        }
        self.latRot = latRot
        self.lonRot = lonRot
    }
}

extension GribCoordinate: Comparable, Equatable {
    static func < (lhs: GribCoordinate, rhs: GribCoordinate) -> Bool {
        if lhs.j < rhs.j {return true}
        if lhs.j == rhs.j && lhs.i < rhs.i {return true}
        return false
    }
}
