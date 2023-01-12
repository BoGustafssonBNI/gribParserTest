//
//  GribValueData.swift
//  gribParserTest
//
//  Created by Bo Gustafsson on 2019-01-01.
//  Copyright © 2019 Bo Gustafsson. All rights reserved.
//

import Foundation

typealias GribValueData = [GribParameterData: [Double]]

extension Dictionary where Key == GribParameterData, Value == Array<Double> {
    func getValueDataAtIndices(indices: [Int]) -> GribValueData {
        var result = GribValueData()
        for (key, value) in self {
            var tempArray = [Double]()
            for index in indices {
                tempArray.append(value[index])
            }
            result[key] = tempArray
        }
        return result
    }
    
    
}
