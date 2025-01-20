//
//  GribGeography.swift
//  gribParserTest
//
//  Created by Bo Gustafsson on 2025-01-18.
//  Copyright © 2025 Bo Gustafsson. All rights reserved.
//


enum GribGeography: String {
    case bitmapPresent = "bitmapPresent"
    case latitudeOfFirstGridPointInDegrees = "latitudeOfFirstGridPointInDegrees"
    case longitudeOfFirstGridPointInDegrees = "longitudeOfFirstGridPointInDegrees"
    case latitudeOfLastGridPointInDegrees = "latitudeOfLastGridPointInDegrees"
    case longitudeOfLastGridPointInDegrees = "longitudeOfLastGridPointInDegrees"
    case iScansNegatively = "iScansNegatively"
    case jScansPositively = "jScansPositively"
    case jPointsAreConsecutive = "jPointsAreConsecutive"
    case jDirectionIncrementInDegrees = "jDirectionIncrementInDegrees"
    case iDirectionIncrementInDegrees = "iDirectionIncrementInDegrees"
    case latitudeOfSouthernPoleInDegrees = "latitudeOfSouthernPoleInDegrees"
    case longitudeOfSouthernPoleInDegrees = "longitudeOfSouthernPoleInDegrees"
    case angleOfRotationInDegrees = "angleOfRotationInDegrees"
    case gridType = "gridType"
    case nX = "Nx"
    case nY = "Ny"
    case laDInDegrees = "LaDInDegrees" //LaD - Latitude where Dx and Dy are specified
    case loVInDegrees = "LoVInDegrees" //LoV - Longitude of meridian parallel to Y-axis along which latitude increases as the Y- coordinate increases
    case dxInMetres = "DxInMetres"
    case dyInMetres = "DyInMetres"
    case latin1InDegrees = "Latin1InDegrees" //Latin 1 - first latitude from the pole at which the secant cone cuts the sphere
    case latin2InDegrees = "Latin2InDegrees" //Latin 2 - second latitude from the pole at which the secant cone cuts the sphere
    // If Latin 1 = Latin 2, then the projection is on a tangent cone.
}
