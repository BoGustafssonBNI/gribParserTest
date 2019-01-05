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
}

class TecplotExports {
    let missingValue = -9999.9
    
    func exportGribFiles(gribFiles: [GribFile], for parameters: [GribParameterData], uParameter: GribParameterData?, vParameter: GribParameterData?, to url: URL, title: String) throws {
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
        var zoneNumber = 1
        for file in gribFiles {
            var tecData = [[Double]]()
            let zoneTitle = file.parser.dataTime.dataDate + file.parser.dataTime.dataTime
            let solutionTime = file.parser.dataTime.date?.timeIntervalSince(refDate) ?? 0
            if first || lastDimension != file.parser.gridDimensions || lastGridData == nil {
                let nvar : Int
                if file.parser.geographyData.rotated {
                    nvar = 4 + parameters.count
                } else {
                    nvar = 2 + parameters.count
                }
                do {
                    try header(zoneTitle: zoneTitle, solutionTime: solutionTime, strandID: 1, imax: file.parser.gridDimensions.nI, jmax: file.parser.gridDimensions.nJ, nvar: nvar)
                } catch {
                    throw error
                }
                lastGridData = GribGridData.init(from: file.parser)
                lastDimension = file.parser.gridDimensions
                gridReferenceZone = zoneNumber
                first = false
                guard let gridData = lastGridData else {throw TecplotExportErrors.GridDataReadError(file)}
                if file.parser.geographyData.rotated {
                    var x = [Double]()
                    var y = [Double]()
                    for c in gridData.coordinates {
                        x.append(c.lonRot)
                        y.append(c.latRot)
                    }
                    tecData.append(x)
                    tecData.append(y)
                }
                var lon = [Double]()
                var lat = [Double]()
                for c in gridData.coordinates {
                    lon.append(c.lon)
                    lat.append(c.lat)
                }
                tecData.append(lon)
                tecData.append(lat)
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
                    try header(zoneTitle: zoneTitle, solutionTime: solutionTime, strandID: 1, imax: file.parser.gridDimensions.nI, jmax: file.parser.gridDimensions.nJ, nvar: nvar, zoneForSharedCoordinates: gridReferenceZone, numberOfCoordinates: ncoord)
                } catch {
                    throw error
                }

            }
            
            guard let gridData = lastGridData else {throw TecplotExportErrors.GridDataReadError(file)}
            guard let data = file.parser.getValues(for: parameters)  else {throw TecplotExportErrors.DataReadError(file)}
            var u = [Double]()
            var v = [Double]()
            if file.parser.geographyData.rotated {
                if let uP = uParameter, let vP = vParameter, let uRot = data[uP], let vRot = data[vP] {
                    var index = 0
                    for matrix in gridData.rotationMatrices {
                        let uv = matrix.rotateWind(uRot: uRot[index], vRot: vRot[index])
                        u.append(uv.u)
                        v.append(uv.v)
                        index += 1
                    }
                }
            }
            let ndata = file.parser.gridDimensions.nI * file.parser.gridDimensions.nJ
            for param in parameters {
                if let y = data[param] {
                    if let uP = uParameter, uP == param {
                        tecData.append(u)
                    } else if let vP = vParameter, vP == param {
                        tecData.append(v)
                    } else {
                        tecData.append(y)
                    }
                } else {
                    let y = [Double].init(repeating: missingValue, count: ndata)
                    tecData.append(y)
                }
            }
        }
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
        var sharevarfromzone : Int32 = 0
        var shareconnectivityfromzone : Int32 = 0
        
        var shareVarFromZone : [Int32] = []
        
        for _ in 0..<numberOfCoordinates {
            shareVarFromZone.append(Int32(zoneForSharedCoordinates))
        }
        for _ in numberOfCoordinates..<nvar {
            shareVarFromZone.append(0)
        }
        let io = teczne142(zoneTitle, &zonetype, &imax32, &jmax32, &kmax, &icellmax, &jcellmax, &kcellmax, &solutionT, &strandID32, &parentzone, &isblock, &Numfaceconnections, &faceneighbormode, &totalnumfacenodes, &numconnectedboundaryfaces, &totalnumboundaryconnections, nil, nil, &sharevarfromzone, &shareconnectivityfromzone)
        if io != 0 {throw TecplotExportErrors.CouldNotCreateHeader(zoneTitle)}
    }
    private func exportDoubleArray(array: [Double]) throws {
        var isDouble : Int32 = 1
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
        var sharevarfromzone : Int32 = 0
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
            let io = teczne142(zoneTitle, &zonetype, &imax32, &jmax32, &kmax, &icellmax, &jcellmax, &kcellmax, &solutionT, &strandID32, &parentzone, &isblock, &Numfaceconnections, &faceneighbormode, &totalnumfacenodes, &numconnectedboundaryfaces, &totalnumboundaryconnections, nil, nil, &sharevarfromzone, &shareconnectivityfromzone)
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
