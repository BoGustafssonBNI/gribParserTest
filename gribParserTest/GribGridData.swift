//
//  GribGridData.swift
//  gribParserTest
//
//  Created by Bo Gustafsson on 2019-01-01.
//  Copyright © 2019 Bo Gustafsson. All rights reserved.
//

import Foundation
struct GribGridData {
    let coordinates : [GribCoordinate]
    let rotationMatrices : [GribRotationMatrix]
    init?(from parser: GribParser) {
        do {
            let grid = try parser.getGridData()
            self.coordinates = grid.coordinates
            self.rotationMatrices = grid.rotationMatrices
        } catch {
            return nil
        }
    }
}

