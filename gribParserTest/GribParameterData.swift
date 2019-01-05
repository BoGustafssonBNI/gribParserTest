//
//  GribParameterData.swift
//  gribParserTest
//
//  Created by Bo Gustafsson on 2019-01-01.
//  Copyright © 2019 Bo Gustafsson. All rights reserved.
//

import Foundation

struct GribParameterData {
    var centre : String?
    var paramId = 0
    var units = ""
    var name = ""
    var shortName = ""
}

extension GribParameterData: Hashable {
    static func == (lhs: GribParameterData, rhs: GribParameterData) -> Bool {
        return lhs.paramId == rhs.paramId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.paramId)
    }
}

