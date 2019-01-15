//
//  GribGridDimensions.swift
//  gribParserTest
//
//  Created by Bo Gustafsson on 2019-01-03.
//  Copyright © 2019 Bo Gustafsson. All rights reserved.
//

import Foundation
struct GribGridDimensions: Equatable {
    var nI = 0
    var nJ = 0
    static func == (lhs: GribGridDimensions, rhs: GribGridDimensions) -> Bool {
        return lhs.nI == rhs.nI && lhs.nJ == rhs.nJ
    }
}
