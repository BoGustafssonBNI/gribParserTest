//
//  BTmodelExports.swift
//  gribParserTest
//
//  Created by Bo Gustafsson on 2024-01-10.
//  Copyright © 2024 Bo Gustafsson. All rights reserved.
//

import Foundation
enum BTmodelExportErrors: Error {
    case GridDataReadError(GribFile)
    case DataReadError(GribFile)
    case CouldNotOpenStreams
    case DataWriteError
    case Cancelled
}

struct BTmodelExports {
    var delegate : ExportProgressDelegate?
    init(delegate: ExportProgressDelegate? = nil) {
        self.delegate = delegate
    }

    mutating func exportGribFiles(gribFiles: [GribFile], uParameter: GribParameterData, vParameter: GribParameterData, pParameter: GribParameterData, to url: URL) throws {
        let firstFile = gribFiles.first!
        var first = true
        let firstDate = firstFile.parser.dataTime.date
        let timeStamp = MyDateConverter.shared.string(from: firstDate)
        let wURL = url.appending(component: "w\(timeStamp).bin")
        let pURL = url.appending(component: "p\(timeStamp).bin")
        guard let wStream = OutputStream(url: wURL, append: false), let pStream = OutputStream(url: pURL, append: false) else {
            throw BTmodelExportErrors.CouldNotOpenStreams
        }
        wStream.open()
        pStream.open()
        var lastDimension = GribGridDimensions()
        let parameters = [uParameter, vParameter, pParameter]
        var lastGridData : GribGridData?
        let numberOfExpectedZones = gribFiles.count
        delegate?.numberToWrite = numberOfExpectedZones
        var zoneNumber = 1
        for file in gribFiles {
            if let cancel = delegate?.cancel, cancel {
                pStream.close()
                wStream.close()
                throw BTmodelExportErrors.Cancelled
            }
            delegate?.progress = Double(zoneNumber) / Double(numberOfExpectedZones)
            if first || lastDimension != file.parser.gridDimensions || lastGridData == nil {
                lastGridData = GribGridData.init(from: file.parser)
                lastDimension = file.parser.gridDimensions
                let geography = file.parser.geographyData
                first = false
                guard lastGridData != nil else {throw BTmodelExportErrors.GridDataReadError(file)}
                do {
                    try wStream.write("s", encoding: .ascii)
                    try wStream.write(array: [Int32(lastDimension.nI), Int32(lastDimension.nJ)])
                    try wStream.write(array: geography.btGeography)
                    try pStream.write("s", encoding: .ascii)
                    try pStream.write(array: [Int32(lastDimension.nI), Int32(lastDimension.nJ)])
                    try pStream.write(array: geography.btGeography)
                } catch {
                    throw error
                }
            }
            
            guard let gridData = lastGridData else {throw BTmodelExportErrors.GridDataReadError(file)}
            guard let data = file.parser.getValues(for: parameters), let uRot = data[uParameter], let vRot = data[vParameter], let press = data[pParameter]  else {throw BTmodelExportErrors.DataReadError(file)}
            var exportArray = [Float]()
            for i in 0..<uRot.count {
                let matrix = gridData.rotationMatrices[i]
                let uv = matrix.rotateWind(uRot: uRot[i], vRot: vRot[i])
                let speed = sqrt(uv.u * uv.u + uv.v * uv.v)
                let cd = speed < 6 ? 1.1e-3 : 0.73e-3 + 0.063e-3 * speed
                let tx = Float(1.3 * cd * uv.u * abs(uv.u))
                let ty = Float(1.3 * cd * uv.v * abs(uv.v))
                exportArray.append(tx)
                exportArray.append(ty)
            }
            try wStream.write("d", encoding: .ascii)
            try wStream.write(array: exportArray)
            var pExportArray = [Float]()
            for i in 0..<press.count {
                pExportArray.append(Float(press[i]))
            }
            try pStream.write("d", encoding: .ascii)
            try pStream.write(array: pExportArray)
            delegate?.numberWritten = zoneNumber
            zoneNumber += 1
        }
        pStream.close()
        wStream.close()
        delegate?.done = true
    }
    
    
}

extension GribGeographyData {
    var btGeography : [Float] {
        get {
            let pxsw = Float(longitudeOfFirstGridPointInDegrees)
            let pysw = Float(latitudeOfFirstGridPointInDegrees)
            let pxcen = Float(longitudeOfSouthernPoleInDegrees)
            let pycen = Float(latitudeOfSouthernPoleInDegrees)
            let pxdelta = Float(iDirectionIncrementInDegrees)
            let pydelta = Float(jDirectionIncrementInDegrees)
            return [pxsw, pysw, pxcen, pycen, pxdelta, pydelta]
        }
    }
}
