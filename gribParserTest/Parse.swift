//
//  Parse.swift
//  gribParserTest
//
//  Created by Bo Gustafsson on 2018-12-28.
//  Copyright © 2018 Bo Gustafsson. All rights reserved.
//

import Foundation
enum GribNameSpaces : String {
    case ls = "ls"
    case parameter = "parameter"
    case statistics = "statistics"
    case time = "time"
    case geography = "geography"
    case vertical = "vertical"
    case mars = "mars"
}
enum GribParameter : String {
    case centre = "centre"
    case paramId = "paramId"
    case units = "units"
    case name = "name"
    case shortName = "shortName"
}
struct GribParameterData {
    var centre : String?
    var paramId = 0
    var units = ""
    var name = ""
    var shortName = ""
}
extension GribParameterData: Hashable {}

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
}
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
}

struct GribGridData {
    var coordinates = [Coordinate]()
    var nI = 0
    var nJ = 0
    var rotationMatrices = [RotationMatrix]()
}

typealias GribValueData = [GribParameterData: [Double]]

typealias FilePointer = UnsafeMutablePointer<FILE>?

enum GribErrors: Error {
    case CouldNotOpenFile
    case CouldNotGetFileHandle
    case CouldNotCreateKeysIterator
}

class Parse {
    var parameterList = [GribParameterData]()
    var geographyData = GribGeographyData()
    var gridData = GribGridData()
    private var filePointer : FilePointer?
    required init(file: String) throws {
        filePointer = fopen(file, "r")
        if filePointer == nil {
            throw GribErrors.CouldNotOpenFile
        }
        do {
            geographyData = try getGeography()
            parameterList = try getParameterList()
            gridData = try getGridData()
        } catch let error {
            throw error
        }
    }
    private func getParameterList() throws -> [GribParameterData] {
        //        let MAX_KEY_LEN = 255
        let MAX_VAL_LEN = 1024
        let key_iterator_filter_flags : Int32  = GRIB_KEYS_ITERATOR_ALL_KEYS
        let name_space = GribNameSpaces.parameter.rawValue
        var err: Int32  = 0
        var grib_count = 0
        var value = [CChar]()
        value.reserveCapacity(MAX_VAL_LEN)
        var result = [GribParameterData]()
        let p : OpaquePointer? = nil
        guard let fp = filePointer else {
            throw GribErrors.CouldNotGetFileHandle
        }
        rewind(fp)
        var h = grib_handle_new_from_file(p,fp,&err)
        while (h != nil)
        {
            grib_count += 1
            let kiter = grib_keys_iterator_new(h, UInt(key_iterator_filter_flags), name_space)
            if (kiter == nil) {
                throw GribErrors.CouldNotCreateKeysIterator
            }
            var parameter = GribParameterData()
            while(grib_keys_iterator_next(kiter) == 1)
            {
                let name = grib_keys_iterator_get_name(kiter)
                var vlen = MAX_VAL_LEN
                bzero(&value, vlen)
                grib_get_string(h,name,&value,&vlen)
                if let string = String(validatingUTF8: name!), let svalue = String(validatingUTF8: &value) {
                    switch string {
                    case GribParameter.centre.rawValue:
                        parameter.centre = svalue
                    case GribParameter.name.rawValue:
                        parameter.name = svalue
                    case GribParameter.paramId.rawValue:
                        if let ivalue = Int(svalue) {
                            parameter.paramId = ivalue
                        }
                    case GribParameter.shortName.rawValue:
                        parameter.shortName = svalue
                    case GribParameter.units.rawValue:
                        parameter.units = svalue
                    default:
                        break
                    }
                }
            }
            result.append(parameter)
            grib_keys_iterator_delete(kiter)
            grib_handle_delete(h)
            h = grib_handle_new_from_file(p,fp,&err)
        }
        if h != nil {grib_handle_delete(h)}
        return result
    }
    private func getGeography() throws -> GribGeographyData {
        //        let MAX_KEY_LEN = 255
        let MAX_VAL_LEN = 1024
        let key_iterator_filter_flags : Int32  = GRIB_KEYS_ITERATOR_ALL_KEYS
        let name_space = GribNameSpaces.geography.rawValue
        var err: Int32  = 0
        var grib_count = 0
        var value = [CChar]()
        value.reserveCapacity(MAX_VAL_LEN)
        let p : OpaquePointer? = nil
        guard let fp = filePointer else {
            throw GribErrors.CouldNotGetFileHandle
        }
        rewind(fp)
        let h = grib_handle_new_from_file(p,fp,&err)
        grib_count += 1
        let kiter = grib_keys_iterator_new(h, UInt(key_iterator_filter_flags), name_space)
        if (kiter == nil) {
            throw GribErrors.CouldNotCreateKeysIterator
        }
        var geography = GribGeographyData()
        while(grib_keys_iterator_next(kiter) == 1)
        {
            let name = grib_keys_iterator_get_name(kiter)
            var vlen = MAX_VAL_LEN
            bzero(&value, vlen)
            grib_get_string(h,name,&value,&vlen)
            if let string = String(validatingUTF8: name!), let svalue = String(validatingUTF8: &value) {
                switch string {
                case GribGeography.bitmapPresent.rawValue:
                    if let i = Int(svalue) {
                        geography.bitmapPresent = i == 1 ? true : false
                    }
                case GribGeography.latitudeOfFirstGridPointInDegrees.rawValue:
                    if let x = Double(svalue) {
                        geography.latitudeOfFirstGridPointInDegrees = x
                    }
                case GribGeography.longitudeOfFirstGridPointInDegrees.rawValue:
                    if let x = Double(svalue) {
                        geography.longitudeOfFirstGridPointInDegrees = x
                    }
                case GribGeography.latitudeOfLastGridPointInDegrees.rawValue:
                    if let x = Double(svalue) {
                        geography.latitudeOfLastGridPointInDegrees = x
                    }
                case GribGeography.longitudeOfLastGridPointInDegrees.rawValue:
                    if let x = Double(svalue) {
                        geography.longitudeOfLastGridPointInDegrees = x
                    }
                case GribGeography.iScansNegatively.rawValue:
                    if let i = Int(svalue) {
                        geography.iScansNegatively = i == 1 ? true : false
                    }
                case GribGeography.jScansPositively.rawValue:
                    if let i = Int(svalue) {
                        geography.jScansPositively = i == 1 ? true : false
                    }
                case GribGeography.jPointsAreConsecutive.rawValue:
                    if let i = Int(svalue) {
                        geography.jPointsAreConsecutive = i == 1 ? true : false
                    }
                case GribGeography.jDirectionIncrementInDegrees.rawValue:
                    if let x = Double(svalue) {
                        geography.jDirectionIncrementInDegrees = x
                    }
                case GribGeography.iDirectionIncrementInDegrees.rawValue:
                    if let x = Double(svalue) {
                        geography.iDirectionIncrementInDegrees = x
                    }
                case GribGeography.latitudeOfSouthernPoleInDegrees.rawValue:
                    if let x = Double(svalue) {
                        geography.latitudeOfSouthernPoleInDegrees = x
                    }
                case GribGeography.longitudeOfSouthernPoleInDegrees.rawValue:
                    if let x = Double(svalue) {
                        geography.longitudeOfSouthernPoleInDegrees = x
                    }
                case GribGeography.angleOfRotationInDegrees.rawValue:
                    if let x = Double(svalue) {
                        geography.angleOfRotationInDegrees = x
                    }
                case GribGeography.gridType.rawValue:
                    geography.gridType = svalue
                default:
                    break
                }
            }
        }
        grib_keys_iterator_delete(kiter)
        grib_handle_delete(h)
        return geography
    }
    private func getGridData() throws -> GribGridData {
        var gridData = GribGridData()
        let p : OpaquePointer? = nil
        var err : Int32 = 0
        guard let fp = filePointer else {
            throw GribErrors.CouldNotGetFileHandle
        }
        rewind(fp)
        let h = grib_handle_new_from_file(p,fp,&err)
        guard h != nil else {throw GribErrors.CouldNotGetFileHandle}
        var nI = 0
        var nJ = 0
        grib_get_long(h, "Ni", &nI)
        grib_get_long(h, "Nj", &nJ)
        gridData.nI = nI
        gridData.nJ = nJ
        var x = 0.0
        var y = 0.0
        var value = 0.0
        let iterator = grib_iterator_new(h, 0, &err)
        var i = 0
        var j = 0
        while grib_iterator_next(iterator, &y, &x, &value) == 1 {
            let coord = Coordinate(i: i, j: j, lon: x, lat: y, longitudeOfFirstGridPointInDegrees: geographyData.longitudeOfFirstGridPointInDegrees, latitudeOfFirstGridPointInDegrees: geographyData.latitudeOfFirstGridPointInDegrees, iDirectionIncrementInDegrees: geographyData.iDirectionIncrementInDegrees, jDirectionIncrementInDegrees: geographyData.jDirectionIncrementInDegrees)
            let rotationMatrix = RotationMatrix(longitudeOfSouthernPoleInDegrees: geographyData.longitudeOfSouthernPoleInDegrees, latitudeOfSouthernPoleInDegrees: geographyData.latitudeOfSouthernPoleInDegrees, coordinate: coord)
            gridData.coordinates.append(coord)
            gridData.rotationMatrices.append(rotationMatrix)
            if i == nI - 1 {
                i = 0
                j += 1
            } else {
                i += 1
            }
        }
        grib_iterator_delete(iterator)
        grib_handle_delete(h)
        return gridData
    }
    func getValues(for parameter: GribParameterData) -> [Double]? {
        //        let MAX_KEY_LEN = 255
        let MAX_VAL_LEN = 1024
        var err: Int32  = 0
        var value = [CChar]()
        value.reserveCapacity(MAX_VAL_LEN)
        guard let f = filePointer else {return nil}
        rewind(f)
        let p : OpaquePointer? = nil
        var h = grib_handle_new_from_file(p,f,&err)
        while (h != nil)
        {
            var vlen = MAX_VAL_LEN
            bzero(&value, vlen)
            grib_get_string(h, GribParameter.name.rawValue, &value, &vlen)
            if let svalue = String(validatingUTF8: &value) {
                if parameter.name == svalue {
                    var size = 0
                    grib_get_size(h, "values", &size)
                    var data = [Double](repeating: 0.0, count: size)
                    grib_get_double_array(h, "values", &data, &size)
                    grib_handle_delete(h)
                    return data
                }
            }
            grib_handle_delete(h)
            h = grib_handle_new_from_file(p,f,&err)
        }
        return nil
    }
    func getValues(for parameters: [GribParameterData]) -> GribValueData? {
        let MAX_VAL_LEN = 1024
        var err: Int32  = 0
        var value = [CChar]()
        value.reserveCapacity(MAX_VAL_LEN)
        guard let f = filePointer else {return nil}
        rewind(f)
        let p : OpaquePointer? = nil
        var h = grib_handle_new_from_file(p,f,&err)
        var names = [String]()
        for parameter in parameters {
            names.append(parameter.name)
        }
        var result : GribValueData = [:]
        while (h != nil)
        {
            var vlen = MAX_VAL_LEN
            bzero(&value, vlen)
            grib_get_string(h, GribParameter.name.rawValue, &value, &vlen)
            if let svalue = String(validatingUTF8: &value) {
                if let index = names.firstIndex(of: svalue) {
                    var size = 0
                    grib_get_size(h, "values", &size)
                    var data = [Double](repeating: 0.0, count: size)
                    grib_get_double_array(h, "values", &data, &size)
                    result[parameters[index]] = data
                }
            }
            grib_handle_delete(h)
            h = grib_handle_new_from_file(p,f,&err)
        }
        return result
    }
}
