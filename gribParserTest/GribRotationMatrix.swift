//
//  GribRotationMatrix.swift
//  gribParserTest
//
//  Created by Bo Gustafsson on 2018-12-30.
//  Copyright © 2018 Bo Gustafsson. All rights reserved.
//

import Foundation
struct GribRotationMatrix {
    var a = 1.0
    var b = 0.0
    var c = 0.0
    var d = 1.0
    init() {}
    init(coordinate: GribCoordinate, geography: GribGeographyData) {
        if geography.rotated {
            self.init(longitudeOfSouthernPoleInDegrees: geography.longitudeOfSouthernPoleInDegrees, latitudeOfSouthernPoleInDegrees: geography.latitudeOfSouthernPoleInDegrees, coordinate: coordinate)
        } else {
            self.init()
        }
    }
    private init(longitudeOfSouthernPoleInDegrees: Double, latitudeOfSouthernPoleInDegrees: Double, coordinate: GribCoordinate) {
        self.init(longitudeOfSouthernPoleInDegrees: longitudeOfSouthernPoleInDegrees, latitudeOfSouthernPoleInDegrees: latitudeOfSouthernPoleInDegrees, lon: coordinate.lon, lat: coordinate.lat, lonRot: coordinate.lonRot, latRot: coordinate.latRot)
    }
    private init(longitudeOfSouthernPoleInDegrees: Double, latitudeOfSouthernPoleInDegrees: Double, lon: Double, lat: Double, lonRot: Double, latRot: Double) {
        let zrad = Double.pi / 180.0
        let zsyc = sin((latitudeOfSouthernPoleInDegrees+90.0)*zrad)
        let zcyc = cos((latitudeOfSouthernPoleInDegrees+90.0)*zrad)
        let zcyreg = cos(lat*zrad)
        let zxmxc = lon - longitudeOfSouthernPoleInDegrees
        let zsxmxc = sin(zxmxc*zrad)
        let zcxmxc = cos(zxmxc*zrad)
        let zsxrot = sin(lonRot*zrad)
        let zcxrot = cos(lonRot*zrad)
        let zsyrot = sin(latRot*zrad)
        let zcyrot = cos(latRot*zrad)
        self.a = zcxmxc * zcxrot + zcyc * zsxmxc * zsxrot
        self.b = zcyc*zsxmxc*zcxrot*zsyrot + zsyc*zsxmxc*zcyrot - zcxmxc*zsxrot*zsyrot
        self.c = -zsyc * zsxrot / zcyreg
        self.d = (zcyc*zcyrot - zsyc*zcxrot*zsyrot)/zcyreg
    }
    func rotateWind(uRot: Double, vRot: Double) -> (u: Double, v: Double) {
        let u = a * uRot + b * vRot
        let v = c * uRot + d * vRot
        return(u, v)
    }
}
