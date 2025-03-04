//
//  GribParser.swift
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
enum GribTime: String {
    case dataDate
    case dataTime
}



typealias FilePointer = UnsafeMutablePointer<FILE>?

enum GribErrors: Error {
    case CouldNotOpenFile
    case CouldNotGetFileHandle
    case CouldNotCreateKeysIterator
    case CouldNotParseDate
    case CouldNotCreateGeographyData
}

struct GribParser {
    var parameterList = [GribParameterData]()
    var geographyData = GribGeographyData()
    var gridDimensions = GribGridDimensions()
    var dataTime = GribTimeData()
    private var fileName : String?
    init(file: String) throws {
        let _ = GribInitEnvironment()
        fileName = file
        var filePointer : FilePointer?
        filePointer = fopen(file, "r")
        if let fp = filePointer, fp == nil {
            throw GribErrors.CouldNotOpenFile
        }
        do {
            geographyData = try getGeography(filePointer: filePointer)
            parameterList = try getParameterList(filePointer: filePointer)
            gridDimensions = try getGridDimensions(filePointer: filePointer)
            dataTime = try getTime(filePointer: filePointer)
            fclose(filePointer!)
        } catch let error {
            throw error
        }
    }
    private func getTime(filePointer: FilePointer?) throws -> GribTimeData {
        //        let MAX_KEY_LEN = 255
        let MAX_VAL_LEN = 1024
        let key_iterator_filter_flags : Int32  = GRIB_KEYS_ITERATOR_ALL_KEYS
        let name_space = GribNameSpaces.time.rawValue
        var err: Int32  = 0
        var value = [CChar]()
        value.reserveCapacity(MAX_VAL_LEN)
        let p : OpaquePointer? = nil
        guard let fp = filePointer, fp != nil else {
            throw GribErrors.CouldNotGetFileHandle
        }
        rewind(fp)
        let h = codes_handle_new_from_file(p,fp,PRODUCT_GRIB,&err)
        let kiter = codes_keys_iterator_new(h, UInt(key_iterator_filter_flags), name_space)
        if (kiter == nil) {
            throw GribErrors.CouldNotCreateKeysIterator
        }
        var time = GribTimeData()
        while(codes_keys_iterator_next(kiter) == 1)
        {
            let name = codes_keys_iterator_get_name(kiter)
            var vlen = MAX_VAL_LEN
            bzero(&value, vlen)
            codes_get_string(h,name,&value,&vlen)
            if let string = String(validatingUTF8: name!), let svalue = String(validatingUTF8: &value) {
                 switch string {
                case GribTime.dataDate.rawValue:
                    if let itime = Int(svalue), itime > 20300000 {
                        time.dataDate = String(itime - 1000000)
                    } else {
                        time.dataDate = svalue
                    }
                case GribTime.dataTime.rawValue:
                    time.dataTime = svalue
                default:
                    break
                }
            }
        }
        codes_keys_iterator_delete(kiter)
        codes_handle_delete(h)
        if !time.dataDate.isEmpty && !time.dataTime.isEmpty, let date = MyDateConverter.shared.date(from: time.dataDate + time.dataTime){
            time.date = date
        } else {
            throw GribErrors.CouldNotParseDate
        }
        return time
    }

    private func getParameterList(filePointer: FilePointer?) throws -> [GribParameterData] {
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
        guard let fp = filePointer, fp != nil else {
            throw GribErrors.CouldNotGetFileHandle
        }
        rewind(fp)
        var h = codes_handle_new_from_file(p, fp, PRODUCT_GRIB, &err)
        while (h != nil)
        {
            grib_count += 1
            let kiter = codes_keys_iterator_new(h, UInt(key_iterator_filter_flags), name_space)
            if (kiter == nil) {
                throw GribErrors.CouldNotCreateKeysIterator
            }
            var parameter = GribParameterData()
            while(codes_keys_iterator_next(kiter) == 1)
            {
                let name = codes_keys_iterator_get_name(kiter)
                var vlen = MAX_VAL_LEN
                bzero(&value, vlen)
                codes_get_string(h,name,&value,&vlen)
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
                        print("Unknown parameter \(string), \(svalue)")
                        break
                    }
                }
            }
            result.append(parameter)
            codes_keys_iterator_delete(kiter)
            codes_handle_delete(h)
            h = codes_handle_new_from_file(p,fp,PRODUCT_GRIB,&err)
        }
        if h != nil {codes_handle_delete(h)}
        return result
    }
    private func getGeography(filePointer: FilePointer?) throws -> GribGeographyData {
        //        let MAX_KEY_LEN = 255
        let MAX_VAL_LEN = 1024
        let key_iterator_filter_flags : Int32  = GRIB_KEYS_ITERATOR_ALL_KEYS
        let name_space = GribNameSpaces.geography.rawValue
        var err: Int32  = 0
        var grib_count = 0
        var value = [CChar]()
        value.reserveCapacity(MAX_VAL_LEN)
        let p : OpaquePointer? = nil
        guard let fp = filePointer, fp != nil else {
            throw GribErrors.CouldNotGetFileHandle
        }
        rewind(fp)
        let h = codes_handle_new_from_file(p,fp,PRODUCT_GRIB,&err)
        grib_count += 1
        let kiter = codes_keys_iterator_new(h, UInt(key_iterator_filter_flags), name_space)
        if (kiter == nil) {
            throw GribErrors.CouldNotCreateKeysIterator
        }
        var geographyValues = [GribGeography: Any]()
        while(codes_keys_iterator_next(kiter) == 1)
        {
            let name = codes_keys_iterator_get_name(kiter)
            var vlen = MAX_VAL_LEN
            bzero(&value, vlen)
            if let s = String(validatingUTF8: name!), s != "bitmap" {
                codes_get_string(h,name,&value,&vlen)
                if let string = String(validatingUTF8: name!), let svalue = String(validatingUTF8: &value) {
                    print("String: \(string), value: \(svalue)")
                    switch string {
                    case GribGeography.bitmapPresent.rawValue:
                        if let i = Int(svalue) {
                            geographyValues[GribGeography.bitmapPresent] = i == 1 ? true : false
                        }
                    case GribGeography.latitudeOfFirstGridPointInDegrees.rawValue:
                        if let x = Double(svalue) {
                            geographyValues[GribGeography.latitudeOfFirstGridPointInDegrees] = x
                        }
                    case GribGeography.longitudeOfFirstGridPointInDegrees.rawValue:
                        if let x = Double(svalue) {
                            geographyValues[GribGeography.longitudeOfFirstGridPointInDegrees] = x
                        }
                    case GribGeography.latitudeOfLastGridPointInDegrees.rawValue:
                        if let x = Double(svalue) {
                            geographyValues[GribGeography.latitudeOfLastGridPointInDegrees] = x
                        }
                    case GribGeography.longitudeOfLastGridPointInDegrees.rawValue:
                        if let x = Double(svalue) {
                            geographyValues[GribGeography.longitudeOfLastGridPointInDegrees] = x
                        }
                    case GribGeography.iScansNegatively.rawValue:
                        if let i = Int(svalue) {
                            geographyValues[GribGeography.iScansNegatively] = i == 1 ? true : false
                        }
                    case GribGeography.jScansPositively.rawValue:
                        if let i = Int(svalue) {
                            geographyValues[GribGeography.jScansPositively] = i == 1 ? true : false
                        }
                    case GribGeography.jPointsAreConsecutive.rawValue:
                        if let i = Int(svalue) {
                            geographyValues[GribGeography.jPointsAreConsecutive] = i == 1 ? true : false
                        }
                    case GribGeography.jDirectionIncrementInDegrees.rawValue:
                        if let x = Double(svalue) {
                            geographyValues[GribGeography.jDirectionIncrementInDegrees] = x
                        }
                    case GribGeography.iDirectionIncrementInDegrees.rawValue:
                        if let x = Double(svalue) {
                            geographyValues[GribGeography.iDirectionIncrementInDegrees] = x
                        }
                    case GribGeography.latitudeOfSouthernPoleInDegrees.rawValue:
                        if let x = Double(svalue) {
                            geographyValues[GribGeography.latitudeOfSouthernPoleInDegrees] = x
                        }
                    case GribGeography.longitudeOfSouthernPoleInDegrees.rawValue:
                        if let x = Double(svalue) {
                            geographyValues[GribGeography.longitudeOfSouthernPoleInDegrees] = x
                        }
                    case GribGeography.angleOfRotationInDegrees.rawValue:
                        if let x = Double(svalue) {
                            geographyValues[GribGeography.angleOfRotationInDegrees] = x
                        }
                    case GribGeography.gridType.rawValue:
                        if let gridType = GribGridType(rawValue: svalue) {
                            geographyValues[GribGeography.gridType] = gridType
                        } else {
                            geographyValues[GribGeography.gridType] = GribGridType.regularII
                            print("Error: unknown gridType = \(svalue)")
                        }
                    case GribGeography.nX.rawValue:
                        if let x = Int(svalue) {
                            geographyValues[GribGeography.nX] = x
                        }
                    case GribGeography.nY.rawValue:
                        if let x = Int(svalue) {
                            geographyValues[GribGeography.nY] = x
                        }
                    case GribGeography.laDInDegrees.rawValue:
                        if let x = Double(svalue) {
                            geographyValues[GribGeography.laDInDegrees] = x
                        }
                    case GribGeography.loVInDegrees.rawValue:
                        if let x = Double(svalue) {
                            geographyValues[GribGeography.loVInDegrees] = x
                        }
                    case GribGeography.dxInMetres.rawValue:
                        if let x = Double(svalue) {
                            geographyValues[GribGeography.dxInMetres] = x
                        }
                    case GribGeography.dyInMetres.rawValue:
                        if let x = Double(svalue) {
                            geographyValues[GribGeography.dyInMetres] = x
                        }
                    case GribGeography.latin1InDegrees.rawValue:
                        if let x = Double(svalue) {
                            geographyValues[GribGeography.latin1InDegrees] = x
                        }
                    case GribGeography.latin2InDegrees.rawValue:
                        if let x = Double(svalue) {
                            geographyValues[GribGeography.latin2InDegrees] = x
                        }
                   default:
                        print("Not set")
                        break
                    }
                }
            }
        }
        guard let geography = GribGeographyData(from: geographyValues) else {
            throw GribErrors.CouldNotCreateGeographyData
        }
        codes_keys_iterator_delete(kiter)
        codes_handle_delete(h)
        return geography
    }
    private func getGridDimensions(filePointer: FilePointer?) throws -> GribGridDimensions {
        var dimensions = GribGridDimensions()
        let p : OpaquePointer? = nil
        var err : Int32 = 0
        guard let fp = filePointer, fp != nil else {
            throw GribErrors.CouldNotGetFileHandle
        }
        rewind(fp)
        let h = codes_handle_new_from_file(p,fp,PRODUCT_GRIB,&err)
        guard h != nil else {throw GribErrors.CouldNotGetFileHandle}
        var nI = 0
        var nJ = 0
        codes_get_long(h, "Ni", &nI)
        codes_get_long(h, "Nj", &nJ)
        dimensions.nI = nI
        dimensions.nJ = nJ
        codes_handle_delete(h)
        return dimensions
    }
    func getGridData() throws -> (coordinates: [GribCoordinate], rotationMatrices: [GribRotationMatrix]) {
        let p : OpaquePointer? = nil
        var err : Int32 = 0
        var filePointer : FilePointer?
        guard let file = fileName else {
            throw GribErrors.CouldNotOpenFile
        }
        filePointer = fopen(file, "r")
        guard let fp = filePointer, fp != nil else {
            throw GribErrors.CouldNotGetFileHandle
        }
        rewind(fp)
        let h = codes_handle_new_from_file(p,fp,PRODUCT_GRIB,&err)
        guard h != nil else {throw GribErrors.CouldNotGetFileHandle}
        var nI = 0
        var nJ = 0
        codes_get_long(h, "Ni", &nI)
        codes_get_long(h, "Nj", &nJ)
        var x = 0.0
        var y = 0.0
        var value = 0.0
        let iterator = codes_grib_iterator_new(h, 0, &err)
        var i = 0
        var j = 0
        var coordinates = [GribCoordinate]()
        var rotationMatrices = [GribRotationMatrix]()
        while codes_grib_iterator_next(iterator, &y, &x, &value) == 1 {
            let coord = GribCoordinate(i: i, j: j, lon: x, lat: y, geography: geographyData)
            let rotationMatrix = GribRotationMatrix(coordinate: coord, geography: geographyData)
            coordinates.append(coord)
            rotationMatrices.append(rotationMatrix)
            if i == nI - 1 {
                i = 0
                j += 1
            } else {
                i += 1
            }
        }
        codes_grib_iterator_delete(iterator)
        codes_handle_delete(h)
        fclose(fp)
        return (coordinates, rotationMatrices)
    }
    func getValues(for parameter: GribParameterData) -> [Double]? {
        //        let MAX_KEY_LEN = 255
        let MAX_VAL_LEN = 1024
        var err: Int32  = 0
        var value = [CChar]()
        value.reserveCapacity(MAX_VAL_LEN)
        var filePointer : FilePointer?
        guard let file = fileName else {
            return nil
        }
        filePointer = fopen(file, "r")
        guard let f = filePointer, f != nil else {return nil}
        rewind(f)
        let p : OpaquePointer? = nil
        var h = codes_handle_new_from_file(p,f,PRODUCT_GRIB,&err)
        while (h != nil)
        {
            var vlen = MAX_VAL_LEN
            bzero(&value, vlen)
            codes_get_string(h, GribParameter.name.rawValue, &value, &vlen)
            if let svalue = String(validatingUTF8: &value) {
                if parameter.name == svalue {
                    var size = 0
                    codes_get_size(h, "values", &size)
                    var data = [Double](repeating: 0.0, count: size)
                    codes_get_double_array(h, "values", &data, &size)
                    codes_handle_delete(h)
                    fclose(f)
                    return data
                }
            }
            codes_handle_delete(h)
            h = codes_handle_new_from_file(p,f,PRODUCT_GRIB,&err)
        }
        fclose(f)
        return nil
    }
    func getValues(for parameters: [GribParameterData]) -> GribValueData? {
        let MAX_VAL_LEN = 1024
        var err: Int32  = 0
        var value = [CChar]()
        value.reserveCapacity(MAX_VAL_LEN)
        var filePointer : FilePointer?
        guard let file = fileName else {
            return nil
        }
        filePointer = fopen(file, "r")
        guard let f = filePointer, f != nil else {return nil}
        rewind(f)
        let p : OpaquePointer? = nil
        var h = codes_handle_new_from_file(p,f,PRODUCT_GRIB,&err)
        var names = [String]()
        for parameter in parameters {
            names.append(parameter.name)
        }
        var result : GribValueData = [:]
        while (h != nil)
        {
            var vlen = MAX_VAL_LEN
            bzero(&value, vlen)
            codes_get_string(h, GribParameter.name.rawValue, &value, &vlen)
            if let svalue = String(validatingUTF8: &value) {
                if let index = names.firstIndex(of: svalue) {
                    var size = 0
                    codes_get_size(h, "values", &size)
                    var data = [Double](repeating: 0.0, count: size)
                    codes_get_double_array(h, "values", &data, &size)
                    result[parameters[index]] = data
                }
            }
            codes_handle_delete(h)
            h = codes_handle_new_from_file(p,f,PRODUCT_GRIB,&err)
        }
        fclose(f)
        return result
    }
    
    func getValues(lons: [Double], lats: [Double], for parameters: [GribParameterData]) -> GribValueData? {
        guard let coordinates = getCoordinates(lons: lons, lats: lats) else {return nil}
        let indices = getIndices(from: coordinates)
        return getValues(at: indices, for: parameters)
    }
    
    func getValues(at indices: [Int], for parameters: [GribParameterData]) -> GribValueData? {
        let MAX_VAL_LEN = 1024
        var err: Int32  = 0
        var value = [CChar]()
        value.reserveCapacity(MAX_VAL_LEN)
        var filePointer : FilePointer?
        guard let file = fileName else {
            return nil
        }
        filePointer = fopen(file, "r")
        guard let f = filePointer, f != nil else {return nil}
        rewind(f)
        let p : OpaquePointer? = nil
        var h = codes_handle_new_from_file(p,f,PRODUCT_GRIB,&err)
        var names = [String]()
        for parameter in parameters {
            names.append(parameter.name)
        }
        var result : GribValueData = [:]
        while (h != nil)
        {
            var vlen = MAX_VAL_LEN
            bzero(&value, vlen)
            codes_get_string(h, GribParameter.name.rawValue, &value, &vlen)
            if let svalue = String(validatingUTF8: &value) {
                if let index = names.firstIndex(of: svalue) {
                    var size = 0
                    codes_get_size(h, "values", &size)
                    var data = [Double](repeating: 0.0, count: size)
                    codes_get_double_array(h, "values", &data, &size)
                    var tempArray = [Double]()
                    for index in indices {
                        tempArray.append(data[index])
                    }
                    result[parameters[index]] = tempArray
                }
            }
            codes_handle_delete(h)
            h = codes_handle_new_from_file(p,f,PRODUCT_GRIB,&err)
        }
        fclose(f)
        return result
    }
//    //    MARK: - This does not work on rotated grids :-(
//    func getValues(lons: [Double], lats: [Double], for parameters: [GribParameterData]) -> GribValueData? {
//        let MAX_VAL_LEN = 1024
//        var err: Int32  = 0
//        var value = [CChar]()
//        value.reserveCapacity(MAX_VAL_LEN)
//        guard let f = filePointer else {return nil}
//        rewind(f)
//        let p : OpaquePointer? = nil
//        var h = codes_handle_new_from_file(p,f,PRODUCT_GRIB,&err)
//        var names = [String]()
//        for parameter in parameters {
//            names.append(parameter.name)
//        }
//        var result : GribValueData = [:]
//        while (h != nil)
//        {
//            var vlen = MAX_VAL_LEN
//            bzero(&value, vlen)
//            codes_get_string(h, GribParameter.name.rawValue, &value, &vlen)
//            if let svalue = String(validatingUTF8: &value) {
//                if let index = names.firstIndex(of: svalue) {
//                    let size = lons.count
//                    var x = lons
//                    var y = lats
//                    var outLats = [Double].init(repeating: 0.0, count: size)
//                    var outLons = [Double].init(repeating: 0.0, count: size)
//                    var values = [Double].init(repeating: 0.0, count: size)
//                    var distances = [Double].init(repeating: 0.0, count: size)
//                    var indexes = [Int32].init(repeating: 0, count: lons.count)
//                    codes_nearest_find_multiple(h, 0, &y, &x, size, &outLats, &outLons, &values, &distances, &indexes)
//                    result[parameters[index]] = values
//                }
//            }
//            codes_handle_delete(h)
//            h = codes_handle_new_from_file(p,f,PRODUCT_GRIB,&err)
//        }
//        return result
//    }

    func getCoordinates(lons: [Double], lats: [Double]) -> [GribCoordinate]? {
        let numberOfPositions = lons.count
        guard numberOfPositions == lats.count else {return nil}
        var result = [GribCoordinate]()
        for n in 0..<numberOfPositions {
            let coordinate = GribCoordinate(lon: lons[n], lat: lats[n], geography: self.geographyData)
            result.append(coordinate)
        }
        return result
    }
    
    func getIndices(from coordinates: [GribCoordinate]) -> [Int] {
        var result = [Int]()
        for coordinate in coordinates {
            result.append(getIndex(from: coordinate))
        }
        return result
    }
    
    func getIndex(from coordinate: GribCoordinate) -> Int {
        return coordinate.i + self.gridDimensions.nI * coordinate.j
    }
    
    func getSubGrid(swCorner: GribCoordinate, neCorner: GribCoordinate, iStep: Int, jStep: Int) -> (iMax: Int, jMax: Int, indices: [Int]) {
        var indices = [Int]()
        let iMax = (neCorner.i - swCorner.i + 1)/iStep
        let jMax = (neCorner.j - swCorner.j + 1)/jStep
        for j in 0..<jMax {
            let jC = swCorner.j + j * jStep
            for i in 0..<iMax {
                let iC = swCorner.i + i * iStep
                let index = iC + jC * self.gridDimensions.nI
                indices.append(index)
            }
        }
        return (iMax, jMax, indices)
    }
    func getSubGrid(iStep: Int, jStep: Int) -> (iMax: Int, jMax: Int, indices: [Int]) {
        var indices = [Int]()
        let iMax = self.gridDimensions.nI/iStep
        let jMax = self.gridDimensions.nJ/jStep
        for j in 0..<jMax {
            let jC = j * jStep
            for i in 0..<iMax {
                let iC = i * iStep
                let index = iC + jC * self.gridDimensions.nI
                indices.append(index)
            }
        }
        return (iMax, jMax, indices)
    }

    
}
