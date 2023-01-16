//
//  UTCCalendar.swift
//  gribParserTest
//
//  Created by Bo Gustafsson on 2023-01-16.
//  Copyright © 2023 Bo Gustafsson. All rights reserved.
//

import Foundation

extension Calendar {
    static var UTCCalendar : Calendar {
        get {
            var cal = Calendar.init(identifier: .iso8601)
            cal.timeZone = TimeZone(identifier: "UTC")!
            return cal
        }
    }
}
