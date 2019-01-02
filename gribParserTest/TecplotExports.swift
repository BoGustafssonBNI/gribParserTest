//
//  TecplotExports.swift
//  gribParserTest
//
//  Created by Bo Gustafsson on 2019-01-01.
//  Copyright © 2019 Bo Gustafsson. All rights reserved.
//

import Foundation


class TecplotExports {
    func exportField(gridData : GribGridData, data: GribValueData) {
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
        write_2d_zone(zoneTitle: "First", solutionTime: 0.0, strandID: 0, imax: gridData.nI, jmax: gridData.nJ, nvar: 4 + params.count, data: tecData, first: true)
        closeTecFile()
    }
    private func openTecFile(title: String, fileName: String, variables: String) {
        let scratchDir = NSHomeDirectory()
        var fileType : Int32 = 0
        var debug : Int32 = 1
        var visDouble : Int32 = 0
        
        tecini112(title, variables, fileName, scratchDir, &fileType, &debug, &visDouble)
    }
    private func closeTecFile() {
        tecend()
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
            let io = teczne112(zoneTitle, &zonetype, &imax32, &jmax32, &kmax, &icellmax, &jcellmax, &kcellmax, &solutionT, &strandID32, &parentzone, &isblock, &Numfaceconnections, &faceneighbormode, &totalnumfacenodes, &numconnectedboundaryfaces, &totalnumboundaryconnections, nil, nil, nil, &shareconnectivityfromzone)
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
            let io = teczne112(zoneTitle, &zonetype, &imax32, &jmax32, &kmax, &icellmax, &jcellmax, &kcellmax, &solutionT, &strandID32, &parentzone, &isblock, &Numfaceconnections, &faceneighbormode, &totalnumfacenodes, &numconnectedboundaryfaces, &totalnumboundaryconnections, nil, nil, &sharevarfromzone, &shareconnectivityfromzone)
            if io == 0 {
                print("io = 0")
            }
            for n in 4..<nvar {
                var d = data[n]
                let io = tecdat112(&numPoints, &d, &isDouble)
                if io != 0 {
                    print("io = \(io)")
                }
            }
        }
        
    }
}
