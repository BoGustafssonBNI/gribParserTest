//
//  GribFileArray+Stats.swift
//  gribParserTest
//
//  Created by Bo Gustafsson on 2023-01-11.
//  Copyright © 2023 Bo Gustafsson. All rights reserved.
//

import Foundation

extension Array where Element == GribFile {
    func average(for parameters: [GribParameterData], uParameter: GribParameterData? = nil, vParameter: GribParameterData? = nil, to url: URL, title: String, swPoint: Point? = nil, nePoint: Point? = nil, iSkip: Int = 1, jSkip: Int = 1) throws {
        let refDate = MyDateConverter.shared.date(from: "189912300000")!
        let fileName = url.path
        guard let firstFile = self.first, let gridData = GribGridData.init(from: firstFile.parser) else {
            throw GribFileErrors.GribFileAverageError
        }
        var variables = ""
        if firstFile.parser.geographyData.rotated {
            variables = "X Y Lon Lat"
        } else {
            variables = "Lon Lat"
        }
        for p in parameters {
            variables += " " + p.shortName
        }
        let nvar : Int
        if firstFile.parser.geographyData.rotated {
            nvar = 4 + parameters.count
        } else {
            nvar = 2 + parameters.count
        }
        
        var iMax = 0
        var jMax = 0
        var indices = [Int]()
        if let swP = swPoint, let neP = nePoint {
            let swGribPoint = GribCoordinate(lon: swP.lon, lat: swP.lat, geography: firstFile.parser.geographyData)
            let neGribPoint = GribCoordinate(lon: neP.lon, lat: neP.lat, geography: firstFile.parser.geographyData)
            let subGrid = firstFile.parser.getSubGrid(swCorner: swGribPoint, neCorner: neGribPoint, iStep: iSkip, jStep: jSkip)
            iMax = subGrid.iMax
            jMax = subGrid.jMax
            indices = subGrid.indices
       } else {
            let subGrid = firstFile.parser.getSubGrid(iStep: iSkip, jStep: jSkip)
            iMax = subGrid.iMax
            jMax = subGrid.jMax
            indices = subGrid.indices
        }

        let dimensions = firstFile.parser.gridDimensions




        var sumData = GribValueData()
        for file in self {
            guard dimensions == file.parser.gridDimensions, let fileDate = file.parser.dataTime.date, let data = file.parser.getValues(for: parameters) else {
                throw GribFileErrors.GribFileAverageError
            }
            for (parameter, values) in data {
                var sum = [Double]()
                if let s = sumData[parameter] {
                    for i in 0..<sum.count {
                        sum[i] = s[i] + values[i] / Double(self.count)
                    }
                } else {
                    for value in values {
                        sum.append(value / Double(self.count))
                    }
                }
                sumData[parameter] = sum
            }
        }
        
            if firstFile.parser.geographyData.rotated {
                if let uP = uParameter, let vP = vParameter, let uRot = sumData[uP], let vRot = sumData[vP] {
                    var u = [Double]()
                    var v = [Double]()
                    for i in 0..<uRot.count {
                        let matrix = gridData.rotationMatrices[i]
                        let uv = matrix.rotateWind(uRot: uRot[i], vRot: vRot[i])
                        u.append(uv.u)
                        v.append(uv.v)
                    }
                    sumData[uP] = u
                    sumData[vP] = v
                }
            }
        for i in indices {
            let lon = gridData.coordinates[i].lon
        }
            let ndata = iMax * jMax
            for param in parameters {
                if let uP = uParameter, uP == param {
                    do {
                        try exportArray(array: u)
                    } catch {
                        throw error
                    }
                } else if let vP = vParameter, vP == param {
                    do {
                        try exportArray(array: v)
                    } catch {
                        throw error
                    }
                } else {
                    if let y = data[param] {
                        var yPoints = [Float]()
                        for i in indices {
                            yPoints.append(Float(y[i]))
                        }
                        do {
                            try exportArray(array: yPoints)
                        } catch {
                            throw error
                        }
                        
                    } else {
                        let y = [Float].init(repeating: Float(missingValue), count: ndata)
                        do {
                            try exportArray(array: y)
                        } catch {
                            throw error
                        }
                    }
                }
            }
            delegate?.numberWritten = zoneNumber
            zoneNumber += 1
        }
        closeTecFile()
        delegate?.done = true

    }
}
