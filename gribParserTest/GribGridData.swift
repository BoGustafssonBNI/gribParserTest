//
//  GribGridData.swift
//  gribParserTest
//
//  Created by Bo Gustafsson on 2019-01-01.
//  Copyright © 2019 Bo Gustafsson. All rights reserved.
//

import Foundation
struct GribGridData {
    var coordinates = [GribCoordinate]()
    var nI = 0
    var nJ = 0
    var rotationMatrices = [GribRotationMatrix]()
}

