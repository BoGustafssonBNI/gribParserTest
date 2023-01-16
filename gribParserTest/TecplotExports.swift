//
//  TecplotExports.swift
//  gribParserTest
//
//  Created by Bo Gustafsson on 2019-01-01.
//  Copyright © 2019 Bo Gustafsson. All rights reserved.
//

import Foundation

enum TecplotExportErrors: Error {
    case GridDataReadError(GribFile)
    case DataReadError(GribFile)
    case CouldNotCreateHeader(String)
    case DataWriteError
    case Cancelled
}
class TecplotExports {
    let missingValue = -9999.9
    var delegate : ExportProgressDelegate?
    
//    func exportGribFiles(gribFiles: [GribFile], for parameters: [GribParameterData], uParameter: GribParameterData?, vParameter: GribParameterData?, to url: URL, title: String) throws {
//        let firstFile = gribFiles.first!
//        let refDate = MyDateConverter.shared.date(from: "189912300000")!
//        var variables = ""
//        if firstFile.parser.geographyData.rotated {
//            variables = "X Y Lon Lat"
//        } else {
//            variables = "Lon Lat"
//        }
//        for p in parameters {
//            variables += " " + p.shortName
//        }
//        let fileName = url.path
//        openTecFile(title: title, fileName: fileName, variables: variables)
//        var first = true
//        var lastDimension = GribGridDimensions()
//        var gridReferenceZone = 1
//        var lastGridData : GribGridData?
//        let numberOfExpectedZones = gribFiles.count
//        delegate?.numberToWrite = numberOfExpectedZones
//        var zoneNumber = 1
//        for file in gribFiles {
//            if let cancel = delegate?.cancel, cancel {
//                closeTecFile()
//                throw TecplotExportErrors.Cancelled
//            }
//            delegate?.progress = Double(zoneNumber) / Double(numberOfExpectedZones)
//            let zoneTitle = file.parser.dataTime.dataDate + file.parser.dataTime.dataTime
//            let solutionTime = (file.parser.dataTime.date?.timeIntervalSince(refDate) ?? 0.0) / 86400.0
//            if first || lastDimension != file.parser.gridDimensions || lastGridData == nil {
//                let nvar : Int
//                if file.parser.geographyData.rotated {
//                    nvar = 4 + parameters.count
//                } else {
//                    nvar = 2 + parameters.count
//                }
//                do {
//                    try header(zoneTitle: zoneTitle, solutionTime: solutionTime, strandID: 1, imax: file.parser.gridDimensions.nI, jmax: file.parser.gridDimensions.nJ, nvar: nvar)
//                } catch {
//                    throw error
//                }
//                lastGridData = GribGridData.init(from: file.parser)
//                lastDimension = file.parser.gridDimensions
//                gridReferenceZone = zoneNumber
//                first = false
//                guard let gridData = lastGridData else {throw TecplotExportErrors.GridDataReadError(file)}
//                if file.parser.geographyData.rotated {
//                    var x = [Double]()
//                    var y = [Double]()
//                    for c in gridData.coordinates {
//                        x.append(c.lonRot)
//                        y.append(c.latRot)
//                    }
//                    do {
//                        try exportArray(array: x)
//                        try exportArray(array: y)
//                    } catch {
//                        throw error
//                    }
//                }
//                var lon = [Double]()
//                var lat = [Double]()
//                for c in gridData.coordinates {
//                    lon.append(c.lon)
//                    lat.append(c.lat)
//                }
//                do {
//                    try exportArray(array: lon)
//                    try exportArray(array: lat)
//                } catch {
//                    throw error
//                }
//            } else {
//                let nvar : Int
//                let ncoord : Int
//                if file.parser.geographyData.rotated {
//                    nvar = 4 + parameters.count
//                    ncoord = 4
//                } else {
//                    nvar = 2 + parameters.count
//                    ncoord = 2
//                }
//                do {
//                    try header(zoneTitle: zoneTitle, solutionTime: solutionTime, strandID: 1, imax: file.parser.gridDimensions.nI, jmax: file.parser.gridDimensions.nJ, nvar: nvar, zoneForSharedCoordinates: gridReferenceZone, numberOfCoordinates: ncoord)
//                } catch {
//                    throw error
//                }
//
//            }
//
//            guard let gridData = lastGridData else {throw TecplotExportErrors.GridDataReadError(file)}
//            guard let data = file.parser.getValues(for: parameters)  else {throw TecplotExportErrors.DataReadError(file)}
//            var u = [Double]()
//            var v = [Double]()
//            if file.parser.geographyData.rotated {
//                if let uP = uParameter, let vP = vParameter, let uRot = data[uP], let vRot = data[vP] {
//                    var index = 0
//                    for matrix in gridData.rotationMatrices {
//                        let uv = matrix.rotateWind(uRot: uRot[index], vRot: vRot[index])
//                        u.append(uv.u)
//                        v.append(uv.v)
//                        index += 1
//                    }
//                }
//            }
//            let ndata = file.parser.gridDimensions.nI * file.parser.gridDimensions.nJ
//            for param in parameters {
//                if let uP = uParameter, uP == param {
//                    do {
//                        try exportArray(array: u)
//                    } catch {
//                        throw error
//                    }
//                } else if let vP = vParameter, vP == param {
//                    do {
//                        try exportArray(array: v)
//                    } catch {
//                        throw error
//                    }
//                } else {
//                    if let y = data[param] {
//                        do {
//                            try exportArray(array: y)
//                        } catch {
//                            throw error
//                        }
//
//                    } else {
//                        let y = [Double].init(repeating: missingValue, count: ndata)
//                        do {
//                            try exportArray(array: y)
//                        } catch {
//                            throw error
//                        }
//
//                    }
//                }
//            }
//            delegate?.numberWritten = zoneNumber
//            zoneNumber += 1
//        }
//        closeTecFile()
//        delegate?.done = true
//    }
    func exportGribFiles(gribFiles: [GribFile], for parameters: [GribParameterData], uParameter: GribParameterData?, vParameter: GribParameterData?, to url: URL, title: String, swPoint: Point?, nePoint: Point?, iSkip: Int, jSkip: Int) throws {
        let firstFile = gribFiles.first!
        let refDate = MyDateConverter.shared.date(from: "189912300000")!
        var variables = ""
        if firstFile.parser.geographyData.rotated {
            variables = "X Y Lon Lat"
        } else {
            variables = "Lon Lat"
        }
        for p in parameters {
            variables += " " + p.shortName
        }
        let fileName = url.path
        openTecFile(title: title, fileName: fileName, variables: variables)
        var first = true
        var lastDimension = GribGridDimensions()
        var gridReferenceZone = 1
        var lastGridData : GribGridData?
        let numberOfExpectedZones = gribFiles.count
        delegate?.numberToWrite = numberOfExpectedZones
        var zoneNumber = 1
        var iMax = 0
        var jMax = 0
        var indices = [Int]()
        for file in gribFiles {
            if let cancel = delegate?.cancel, cancel {
                closeTecFile()
                throw TecplotExportErrors.Cancelled
            }
            delegate?.progress = Double(zoneNumber) / Double(numberOfExpectedZones)
            let zoneTitle = file.parser.dataTime.dataDate + file.parser.dataTime.dataTime
            let solutionTime = (file.parser.dataTime.date?.timeIntervalSince(refDate) ?? 0.0) / 86400.0
            if first || lastDimension != file.parser.gridDimensions || lastGridData == nil {
                let nvar : Int
                if file.parser.geographyData.rotated {
                    nvar = 4 + parameters.count
                } else {
                    nvar = 2 + parameters.count
                }
                lastGridData = GribGridData.init(from: file.parser)
                lastDimension = file.parser.gridDimensions
                if let swP = swPoint, let neP = nePoint {
                    let swGribPoint = GribCoordinate(lon: swP.lon, lat: swP.lat, geography: file.parser.geographyData)
                    let neGribPoint = GribCoordinate(lon: neP.lon, lat: neP.lat, geography: file.parser.geographyData)
                    let subGrid = file.parser.getSubGrid(swCorner: swGribPoint, neCorner: neGribPoint, iStep: iSkip, jStep: jSkip)
                    iMax = subGrid.iMax
                    jMax = subGrid.jMax
                    indices = subGrid.indices
               } else {
                    let subGrid = file.parser.getSubGrid(iStep: iSkip, jStep: jSkip)
                    iMax = subGrid.iMax
                    jMax = subGrid.jMax
                    indices = subGrid.indices
                }
                gridReferenceZone = zoneNumber
                first = false
                guard let gridData = lastGridData else {throw TecplotExportErrors.GridDataReadError(file)}
                do {
                    try header(zoneTitle: zoneTitle, solutionTime: solutionTime, strandID: 1, imax: iMax, jmax: jMax, nvar: nvar)
                } catch {
                    throw error
                }
                if file.parser.geographyData.rotated {
                    var x = [Float]()
                    var y = [Float]()
                    for i in indices {
                        x.append(Float(gridData.coordinates[i].lonRot))
                        y.append(Float(gridData.coordinates[i].latRot))
                    }
                    do {
                        try exportArray(array: x)
                        try exportArray(array: y)
                    } catch {
                        throw error
                    }
                }
                var lon = [Float]()
                var lat = [Float]()
                for i in indices {
                    lon.append(Float(gridData.coordinates[i].lon))
                    lat.append(Float(gridData.coordinates[i].lat))
                }
                do {
                    try exportArray(array: lon)
                    try exportArray(array: lat)
                } catch {
                    throw error
                }
            } else {
                let nvar : Int
                let ncoord : Int
                if file.parser.geographyData.rotated {
                    nvar = 4 + parameters.count
                    ncoord = 4
                } else {
                    nvar = 2 + parameters.count
                    ncoord = 2
                }
                do {
                    try header(zoneTitle: zoneTitle, solutionTime: solutionTime, strandID: 1, imax: iMax, jmax: jMax, nvar: nvar, zoneForSharedCoordinates: gridReferenceZone, numberOfCoordinates: ncoord)
                } catch {
                    throw error
                }
                
            }
            
            guard let gridData = lastGridData else {throw TecplotExportErrors.GridDataReadError(file)}
            guard let data = file.parser.getValues(for: parameters)  else {throw TecplotExportErrors.DataReadError(file)}
            var u = [Float]()
            var v = [Float]()
            if file.parser.geographyData.rotated {
                if let uP = uParameter, let vP = vParameter, let uRot = data[uP], let vRot = data[vP] {
                    for i in indices {
                        let matrix = gridData.rotationMatrices[i]
                        let uv = matrix.rotateWind(uRot: uRot[i], vRot: vRot[i])
                        u.append(Float(uv.u))
                        v.append(Float(uv.v))
                    }
                }
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
    
    
    
    func exportGribFiles(gribFiles: [GribFile], of type: GribFileAverageTypes, for parameters: [GribParameterData], uParameter: GribParameterData?, vParameter: GribParameterData?, to url: URL, title: String, swPoint: Point?, nePoint: Point?, iSkip: Int, jSkip: Int) throws {
        
        let refDate = MyDateConverter.shared.date(from: "189912300000")!
        let gribsToAverage = gribFiles.gribsToAverage(of: type)
        delegate?.progressText = "averaged out of"
        delegate?.numberToWrite = gribsToAverage.count
        var numberComputed = 0
        var averageData = [(date: Date, gribValueData: GribValueData)]()
        for gribFileArray in gribsToAverage {
            if let cancel = delegate?.cancel, cancel {
                throw TecplotExportErrors.Cancelled
            }
            do {
                delegate?.numberWritten = numberComputed
                delegate?.progress = Double(numberComputed) / Double(gribsToAverage.count)
                let average = try gribFileArray.average(for: parameters)
                averageData.append(average)
                numberComputed += 1
            } catch let error {
                throw error
            }
        }
        /// Common grid is assumed for all fields
        ///
        guard let firstFile = gribFiles.first else {
            throw TecplotExportErrors.Cancelled
        }
        let geography = firstFile.parser.geographyData
        guard let gridData = try? firstFile.parser.getGridData() else {
            throw TecplotExportErrors.GridDataReadError(firstFile)
        }
        var iMax = 0
        var jMax = 0
        var indices = [Int]()
        if let swP = swPoint, let neP = nePoint {
            let swGribPoint = GribCoordinate(lon: swP.lon, lat: swP.lat, geography: geography)
            let neGribPoint = GribCoordinate(lon: neP.lon, lat: neP.lat, geography: geography)
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

        var variables = ""
        let nvar : Int
        let ncoord : Int
        if geography.rotated {
            variables = "X Y Lon Lat"
            nvar = 4 + parameters.count
            ncoord = 4
        } else {
            variables = "Lon Lat"
            nvar = 2 + parameters.count
            ncoord = 2
       }
        for p in parameters {
            variables += " " + p.shortName
        }
        let gridReferenceZone = 1

        
        
        
        
        let fileName = url.path
        openTecFile(title: title, fileName: fileName, variables: variables)
        var first = true
        let numberOfExpectedZones = averageData.count
        delegate?.progressText = "written out of"
        delegate?.numberWritten = 0
        delegate?.numberToWrite = numberOfExpectedZones
        var zoneNumber = 1
        for average in averageData {
            if let cancel = delegate?.cancel, cancel {
                closeTecFile()
                throw TecplotExportErrors.Cancelled
            }
            delegate?.progress = Double(zoneNumber) / Double(numberOfExpectedZones)
            let zoneTitle : String
            let solutionTime : Double
            switch type {
            case .Daily:
                zoneTitle = "\(Calendar.UTCCalendar.component(.year, from: average.date))-\(Calendar.UTCCalendar.component(.month, from: average.date))-\(Calendar.UTCCalendar.component(.day, from: average.date))"
                solutionTime = average.date.timeIntervalSince(refDate) / 86400.0
           case .Monthly:
                zoneTitle = "\(Calendar.UTCCalendar.component(.year, from: average.date))-\(Calendar.UTCCalendar.component(.month, from: average.date))"
                solutionTime = average.date.timeIntervalSince(refDate) / 86400.0
            case .Average:
                zoneTitle = "Average field"
                solutionTime = average.date.timeIntervalSince(refDate) / 86400.0
            case .Seasonal:
                zoneTitle = "Month \(zoneNumber)"
                solutionTime = average.date.timeIntervalSince(refDate) / 86400.0
            }
            if first {
                first = false
                do {
                    try header(zoneTitle: zoneTitle, solutionTime: solutionTime, strandID: 1, imax: iMax, jmax: jMax, nvar: nvar)
                } catch {
                    throw error
                }
                if geography.rotated {
                    var x = [Float]()
                    var y = [Float]()
                    for i in indices {
                        x.append(Float(gridData.coordinates[i].lonRot))
                        y.append(Float(gridData.coordinates[i].latRot))
                    }
                    do {
                        try exportArray(array: x)
                        try exportArray(array: y)
                    } catch {
                        throw error
                    }
                }
                var lon = [Float]()
                var lat = [Float]()
                for i in indices {
                    lon.append(Float(gridData.coordinates[i].lon))
                    lat.append(Float(gridData.coordinates[i].lat))
                }
                do {
                    try exportArray(array: lon)
                    try exportArray(array: lat)
                } catch {
                    throw error
                }
            } else {
                do {
                    try header(zoneTitle: zoneTitle, solutionTime: solutionTime, strandID: 1, imax: iMax, jmax: jMax, nvar: nvar, zoneForSharedCoordinates: gridReferenceZone, numberOfCoordinates: ncoord)
                } catch {
                    throw error
                }
                
            }
            
            let data = average.gribValueData
            var u = [Float]()
            var v = [Float]()
            if geography.rotated {
                if let uP = uParameter, let vP = vParameter, let uRot = data[uP], let vRot = data[vP] {
                    for i in indices {
                        let matrix = gridData.rotationMatrices[i]
                        let uv = matrix.rotateWind(uRot: uRot[i], vRot: vRot[i])
                        u.append(Float(uv.u))
                        v.append(Float(uv.v))
                    }
                }
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


    private func header(zoneTitle: String, solutionTime: Double, strandID: Int, imax: Int, jmax:Int, nvar: Int) throws {
        var solutionT = solutionTime
        var zonetype : Int32 = 0
        var strandID32 : Int32 = Int32(strandID)
        var imax32 : Int32 = Int32(imax)
        var jmax32 : Int32 = Int32(jmax)
        var kmax : Int32 = 1
        var icellmax : Int32 = 0
        var jcellmax : Int32 = 0
        var kcellmax : Int32 = 0
        var parentzone : Int32 = 0
        var isblock : Int32 = 1
        var Numfaceconnections : Int32 = 0
        var faceneighbormode : Int32 = 0
        var totalnumfacenodes : Int32 = 0
        var numconnectedboundaryfaces : Int32 = 0
        var totalnumboundaryconnections : Int32 = 0
        var shareconnectivityfromzone : Int32 = 0
        
        let io = teczne142(zoneTitle, &zonetype, &imax32, &jmax32, &kmax, &icellmax, &jcellmax, &kcellmax, &solutionT, &strandID32, &parentzone, &isblock, &Numfaceconnections, &faceneighbormode, &totalnumfacenodes, &numconnectedboundaryfaces, &totalnumboundaryconnections, nil, nil, nil, &shareconnectivityfromzone)
        if io != 0 {throw TecplotExportErrors.CouldNotCreateHeader(zoneTitle)}
    }
    private func header(zoneTitle: String, solutionTime: Double, strandID: Int, imax: Int, jmax:Int, nvar: Int, zoneForSharedCoordinates: Int, numberOfCoordinates: Int) throws {
        var solutionT = solutionTime
        var zonetype : Int32 = 0
        var strandID32 : Int32 = Int32(strandID)
        var imax32 : Int32 = Int32(imax)
        var jmax32 : Int32 = Int32(jmax)
        var kmax : Int32 = 1
        var icellmax : Int32 = 0
        var jcellmax : Int32 = 0
        var kcellmax : Int32 = 0
        var parentzone : Int32 = 0
        var isblock : Int32 = 1
        var Numfaceconnections : Int32 = 0
        var faceneighbormode : Int32 = 0
        var totalnumfacenodes : Int32 = 0
        var numconnectedboundaryfaces : Int32 = 0
        var totalnumboundaryconnections : Int32 = 0
        var shareconnectivityfromzone : Int32 = 0
        
        var shareVarFromZone : [Int32] = []
        
        for _ in 0..<numberOfCoordinates {
            shareVarFromZone.append(Int32(zoneForSharedCoordinates))
        }
        for _ in numberOfCoordinates..<nvar {
            shareVarFromZone.append(0)
        }
        let io = teczne142(zoneTitle, &zonetype, &imax32, &jmax32, &kmax, &icellmax, &jcellmax, &kcellmax, &solutionT, &strandID32, &parentzone, &isblock, &Numfaceconnections, &faceneighbormode, &totalnumfacenodes, &numconnectedboundaryfaces, &totalnumboundaryconnections, nil, nil, &shareVarFromZone, &shareconnectivityfromzone)
        if io != 0 {throw TecplotExportErrors.CouldNotCreateHeader(zoneTitle)}
    }
    private func exportArray(array: [Double]) throws {
        var isDouble : Int32 = 1
        var numPoints = Int32(array.count)
        let io = tecdat142(&numPoints, array, &isDouble)
        if io != 0 {
            throw TecplotExportErrors.DataWriteError
        }
    }
    private func exportArray(array: [Float]) throws {
        var isDouble : Int32 = 0
        var numPoints = Int32(array.count)
        let io = tecdat142(&numPoints, array, &isDouble)
        if io != 0 {
            throw TecplotExportErrors.DataWriteError
        }
    }


    func exportSingleField(gridDimensions: GribGridDimensions, gridData : GribGridData, data: GribValueData) {
        let params = [GribParameterData](data.keys)
        var variables = "X Y Lon Lat"
        for p in params {
            variables += " " + p.shortName
        }
        let title = "test"
        let fileName = NSHomeDirectory() + "/test.plt"
        var tecData = [[Double]]()
        var x = [Double]()
        var y = [Double]()
        var lon = [Double]()
        var lat = [Double]()
        for c in gridData.coordinates {
            x.append(c.lonRot)
            y.append(c.latRot)
            lon.append(c.lon)
            lat.append(c.lat)
        }
        tecData.append(x)
        tecData.append(y)
        tecData.append(lon)
        tecData.append(lat)
        for p in params {
            if let z = data[p] {
                tecData.append(z)
            }
        }
        openTecFile(title: title, fileName: fileName, variables: variables)
        write_2d_zone(zoneTitle: "First", solutionTime: 0.0, strandID: 0, imax: gridDimensions.nI, jmax: gridDimensions.nJ, nvar: 4 + params.count, data: tecData, first: true)
        closeTecFile()
    }
    private func openTecFile(title: String, fileName: String, variables: String) {
        let scratchDir = NSHomeDirectory()
        // Specify whether the file is a full data file (containing both grid and solution data), a grid file or a solution file. 0=Full 1=Grid 2=Solution
        var fileType : Int32 = 0
// Specifies the file format to be used. Ignored by TecIO-MPI, which always writes .szplt files. 0=Tecplot binary (.plt) 1=Tecplot subzone (.szplt)
        var fileFormat : Int32 = 0
        
        var debug : Int32 = 1
        var visDouble : Int32 = 0
        
        tecini142(title, variables, fileName, scratchDir,&fileFormat, &fileType, &debug, &visDouble)
    }
    private func closeTecFile() {
        tecend142()
    }
    
    
    private func write_2d_zone(zoneTitle: String, solutionTime: Double, strandID: Int, imax: Int, jmax:Int, nvar: Int, data: [[Double]], first: Bool) {
        var solutionT = solutionTime
        var zonetype : Int32 = 0
        var strandID32 : Int32 = Int32(strandID)
        var imax32 : Int32 = Int32(imax)
        var jmax32 : Int32 = Int32(jmax)
        var numPoints = imax32 * jmax32
        var kmax : Int32 = 1
        var icellmax : Int32 = 0
        var jcellmax : Int32 = 0
        var kcellmax : Int32 = 0
        var parentzone : Int32 = 0
        var isblock : Int32 = 1
        var Numfaceconnections : Int32 = 0
        var faceneighbormode : Int32 = 0
        var totalnumfacenodes : Int32 = 0
        var numconnectedboundaryfaces : Int32 = 0
        var totalnumboundaryconnections : Int32 = 0
        var shareconnectivityfromzone : Int32 = 0
        var isDouble : Int32 = 1

        if first {
            let io = teczne142(zoneTitle, &zonetype, &imax32, &jmax32, &kmax, &icellmax, &jcellmax, &kcellmax, &solutionT, &strandID32, &parentzone, &isblock, &Numfaceconnections, &faceneighbormode, &totalnumfacenodes, &numconnectedboundaryfaces, &totalnumboundaryconnections, nil, nil, nil, &shareconnectivityfromzone)
            if io == 0 {
                print("io = 0")
            }
            for n in 0..<nvar {
                var d = data[n]
                let io = tecdat112(&numPoints, &d, &isDouble)
                if io == 0 {
                    print("io = 0")
                }
            }
        } else {
            var shareVarFromZone : [Int32] = [1, 1, 1, 1]
            for _ in 4..<nvar {
                shareVarFromZone.append(0)
            }
            let io = teczne142(zoneTitle, &zonetype, &imax32, &jmax32, &kmax, &icellmax, &jcellmax, &kcellmax, &solutionT, &strandID32, &parentzone, &isblock, &Numfaceconnections, &faceneighbormode, &totalnumfacenodes, &numconnectedboundaryfaces, &totalnumboundaryconnections, nil, nil, &shareVarFromZone, &shareconnectivityfromzone)
            if io == 0 {
                print("io = 0")
            }
            for n in 4..<nvar {
                var d = data[n]
                let io = tecdat142(&numPoints, &d, &isDouble)
                if io != 0 {
                    print("io = \(io)")
                }
            }
        }
        
    }
}
