//
//  PointExports.swift
//  gribParserTest
//
//  Created by Bo Gustafsson on 2019-01-06.
//  Copyright © 2019 Bo Gustafsson. All rights reserved.
//

import Foundation
enum PointExportErrors: Error {
    case DataReadError(GribFile)
    case cancelled
    case DataWriteError
}

class PointExports {
    let missingValue = -9999.0
    let delimiter = ","
    let encoding = String.Encoding.utf8
    var delegate : ExportProgressDelegate?
    
    func exportPointFiles(gribFiles: [GribFile], for parameters: [GribParameterData], uParameter: GribParameterData?, vParameter: GribParameterData?, at points: [Point], to url: URL) throws {
        let refDate = MyDateConverter.shared.date(from: "189912300000")!
        var variables = "Time"
        for p in parameters {
            variables += delimiter + p.name
        }
        variables += "\n"
        var outData = [String]()
        let ids = points.uniqueIDs
        for _ in ids {
            outData.append(variables)
        }
        var first = true
        var lastDimension = GribGridDimensions()
        var lastGeographyData = GribGeographyData()
        var indicesForID = [Int: [Int]]()
        var matricesForID = [Int: [GribRotationMatrix]]()
        var gribPoints = [GribPoint]()
        let numberOfGribFiles = gribFiles.count
        delegate?.numberToWrite = numberOfGribFiles
        var fileNo = 0
        for file in gribFiles {
            if let cancel = delegate?.cancel, cancel {
                throw PointExportErrors.cancelled
            }
            delegate?.progress = Double(fileNo) / Double(numberOfGribFiles)
            let solutionTime = file.parser.dataTime.date.timeIntervalSince(refDate) / 86400.0
            if first || lastDimension != file.parser.gridDimensions || lastGeographyData != file.parser.geographyData {
                lastGeographyData = file.parser.geographyData
                lastDimension = file.parser.gridDimensions
                first = false
                gribPoints = []
                for p in points {
                    if let gp = GribPoint(from: p, geography: lastGeographyData, dimensions: lastDimension) {
                        gribPoints.append(gp)
                    }
                }
                for id in ids {
                    indicesForID[id] = gribPoints.indices(for: id)
                    matricesForID[id] = gribPoints.rotationMatrices(for: id, geography: lastGeographyData)
                    if indicesForID[id]!.count == 0 {print("no points for id=\(id)")}
                }
            }
            
            guard let data = file.parser.getValues(for: parameters)  else {throw PointExportErrors.DataReadError(file)}
            var nID = 0
            for id in ids {
                if let indices = indicesForID[id] {
                    var u = [Double]()
                    var v = [Double]()
                    if lastGeographyData.rotated, let uP = uParameter, let vP = vParameter, let uRot = data[uP], let vRot = data[vP], let matrices = matricesForID[id] {
                        for i in 0..<indices.count {
                            let wind = matrices[i].rotateWind(uRot: uRot[indices[i]], vRot: vRot[indices[i]])
                            u.append(wind.u)
                            v.append(wind.v)
                        }
                    }
                    var line = String(solutionTime)
                    for param in parameters {
                        if let uP = uParameter, uP == param {
                            line += delimiter + String(u.average)
                        } else if let vP = vParameter, vP == param {
                            line += delimiter + String(v.average)
                        } else {
                            if let y = data[param] {
                                line += delimiter + String(y.averageOf(indices: indices))
                            } else {
                                line += delimiter + String(missingValue)
                            }
                        }
                    }
                    line += "\n"
                    outData[nID] += line
                }
                nID += 1
            }
            fileNo += 1
            delegate?.numberWritten = fileNo
        }
        let directory = url.path
        var nID = 0
        for id in ids {
            do {
                try outData[nID].write(toFile: directory + "/PID\(id).csv", atomically: true, encoding: encoding)
            } catch {
                throw PointExportErrors.DataWriteError
            }
            nID += 1
        }
        delegate?.done = true
    }
}
extension Array where Element == Double {
    var average: Double {
        var a = 0.0
        let n = self.count
        for x in self {
            a += x
        }
        if n > 0 {return a/Double(n)}
        return 0.0
    }
    func averageOf(indices: [Int]) -> Double {
        var a = 0.0
        var n = 0
        for i in indices {
            a += self[i]
            n += 1
        }
        if n > 0 {return a/Double(n)}
        return 0.0
    }
}
