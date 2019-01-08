//
//  GribPoint.swift
//  gribParserTest
//
//  Created by Bo Gustafsson on 2019-01-06.
//  Copyright © 2019 Bo Gustafsson. All rights reserved.
//

import Foundation

struct GribPoint {
    var point : Point
    var coordinate : GribCoordinate
    var index : Int
    init(from point: Point, geography: GribGeographyData, dimensions: GribGridDimensions) {
        self.point = point
        self.coordinate = GribCoordinate.init(lon: point.lon, lat: point.lat, geography: geography)
        self.index = self.coordinate.i + dimensions.nI * self.coordinate.j
    }
 }

extension Array where Element == GribPoint {
    func indices(for id: Int) -> [Int] {
        let ps = self.filter{$0.point.id == id}
        var indices = [Int]()
        for p in ps {
            indices.append(p.index)
        }
        return indices
    }
    func rotationMatrices(for id: Int, geography: GribGeographyData) -> [GribRotationMatrix] {
        let ps = self.filter{$0.point.id == id}
        var matrices = [GribRotationMatrix]()
        for p in ps {
            matrices.append(GribRotationMatrix.init(coordinate: p.coordinate, geography: geography))
        }
        return matrices
    }

}

