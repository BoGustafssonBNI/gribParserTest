//
//  GribTimeData.swift
//  gribParserTest
//
//  Created by Bo Gustafsson on 2019-01-04.
//  Copyright © 2019 Bo Gustafsson. All rights reserved.
//

import Foundation

struct GribTimeData {
    var dataDate = ""
    var dataTime = ""
    var date = Date()
//    var date : Date? {
//        get {
//            if !dataDate.isEmpty && !dataTime.isEmpty, let date = MyDateConverter.shared.date(from: dataDate + dataTime){
//                return date
//            }
//            return nil
//        }
//    }
    static func == (lhs: GribTimeData, rhs: GribTimeData) -> Bool {
        return lhs.dataDate == rhs.dataDate && lhs.dataTime == rhs.dataTime
    }
}
