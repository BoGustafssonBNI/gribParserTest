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
    var coordinateOfFirstGridPoint = (x: 0.0, y: 0.0)
    var coordinateOfLastGridPoint = (x: 0.0, y: 0.0)
    init() {}
    init?(from geographyValues: [GribGeography: Any]) {
        guard geographyValues[.gridType] is GribGridType else { return nil }
        for (key, value) in geographyValues {
            switch key {
            case .bitmapPresent: bitmapPresent = value as! Bool
            case .latitudeOfFirstGridPointInDegrees: latitudeOfFirstGridPointInDegrees = value as! Double
            case .longitudeOfFirstGridPointInDegrees: longitudeOfFirstGridPointInDegrees = value as! Double
            case .latitudeOfLastGridPointInDegrees: latitudeOfLastGridPointInDegrees = value as! Double
            case .longitudeOfLastGridPointInDegrees: longitudeOfLastGridPointInDegrees = value as! Double
            case .iScansNegatively: iScansNegatively = value as! Bool
                case .jScansPositively: jScansPositively = value as! Bool
            case .jPointsAreConsecutive: jPointsAreConsecutive = value as! Bool
            case .gridType: self.gridType = value as! GribGridType
            case .iDirectionIncrementInDegrees: iDirectionIncrementInDegrees = value as! Double
            case .jDirectionIncrementInDegrees: jDirectionIncrementInDegrees = value as! Double
            case .latitudeOfSouthernPoleInDegrees: latitudeOfSouthernPoleInDegrees = value as! Double
            case .longitudeOfSouthernPoleInDegrees: longitudeOfSouthernPoleInDegrees = value as! Double
            case .angleOfRotationInDegrees: angleOfRotationInDegrees = value as! Double
            case .nX: nX = value as! Int
            case .nY: nY = value as! Int
            case .laDInDegrees: laDInDegrees = value as! Double
            case .loVInDegrees: loVInDegrees = value as! Double
            case .dxInMetres: dxInMetres = value as! Double
            case .dyInMetres: dyInMetres = value as! Double
            case .latin1InDegrees: latin1InDegrees = value as! Double
            case .latin2InDegrees: latin2InDegrees = value as! Double
            }
        }
        switch self.gridType {
        case .regularII:
            self.coordinateOfFirstGridPoint = (x: self.longitudeOfFirstGridPointInDegrees, y: self.latitudeOfFirstGridPointInDegrees)
            self.coordinateOfLastGridPoint = (x: self.longitudeOfLastGridPointInDegrees, y: self.latitudeOfLastGridPointInDegrees)
        case .rotatedII:
            self.coordinateOfFirstGridPoint = (x: self.latitudeOfFirstGridPointInDegrees, y: self.longitudeOfFirstGridPointInDegrees)
            self.coordinateOfLastGridPoint = (x: self.longitudeOfLastGridPointInDegrees, y: self.latitudeOfLastGridPointInDegrees)
        case .lambert:
            let zrad = Double.pi / 180.0
            let n : Double
            let f : Double
            if abs(self.latin1InDegrees - self.latin2InDegrees) > 0.01 {
                let cosLatinRatio = log(cos(zrad * self.latin1InDegrees) / cos(zrad * self.latin2InDegrees))
                let tanLatinRatio = log(tan(Double.pi / 4.0 + zrad * self.latin2InDegrees / 2.0) / tan(Double.pi / 4.0 + zrad * self.latin1InDegrees / 2.0))
                n = cosLatinRatio / tanLatinRatio
                f = cos(zrad * self.latin1InDegrees) * pow(tan(Double.pi / 4.0 + zrad * self.latin1InDegrees / 2.0), n) / n
            } else {
                n = sin(zrad * self.latin1InDegrees)
                f = cos(zrad * self.latin1InDegrees) * pow(tan(Double.pi / 4.0 + zrad * self.latin1InDegrees / 2.0), n) / n
            }
            let rho0 = self.radiusOfTheEarth * f / pow(tan(Double.pi / 4.0 + zrad * self.laDInDegrees / 2.0), n)
            let rho1 = self.radiusOfTheEarth * f / pow(tan(Double.pi / 4.0 + zrad * self.latitudeOfFirstGridPointInDegrees / 2.0), n)
            let theta1 = n * zrad * (self.longitudeOfFirstGridPointInDegrees - self.loVInDegrees)
            self.coordinateOfFirstGridPoint = (x: rho1 * sin(theta1), y: rho0 - rho1 * cos(theta1))
            self.coordinateOfLastGridPoint = (x: rho1 * sin(theta1) + dxInMetres * Double(nX - 1), y: rho0 - rho1 * cos(theta1) + dyInMetres * Double(nY - 1))
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
