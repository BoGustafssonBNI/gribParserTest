//
//  GribFileArray+Stats.swift
//  gribParserTest
//
//  Created by Bo Gustafsson on 2023-01-11.
//  Copyright © 2023 Bo Gustafsson. All rights reserved.
//

import Foundation

enum GribFileAverageTypes : String, CaseIterable {
    case Average = "Average"
    case Seasonal = "Seasonal"
    case Monthly = "Monthly"
    case Daily = "Daily"
}


extension Array where Element == GribFile {
    func gribsToAverage(of type: GribFileAverageTypes) -> [[GribFile]] {
        var gribsToAverage = [[GribFile]]()
        switch type {
        case .Average:
            gribsToAverage.append(self)
        case .Seasonal:
            for month in 1...12 {
                let subGF = self.filter({Calendar.UTCCalendar.component(.month, from: $0.parser.dataTime.date!) == month})
                if !subGF.isEmpty {
                    gribsToAverage.append(subGF)
                }
            }
        case .Monthly:
            if let startDate = self.first?.parser.dataTime.date, let endDate = self.last?.parser.dataTime.date {
                for year in Calendar.UTCCalendar.component(.year, from: startDate)...Calendar.UTCCalendar.component(.year, from: endDate) {
                    let subYear = self.filter({Calendar.UTCCalendar.component(.year, from: $0.parser.dataTime.date!) == year})
                    for month in 1...12 {
                        let subGF = subYear.filter({Calendar.UTCCalendar.component(.month, from: $0.parser.dataTime.date!) == month})
                        if !subGF.isEmpty {
                            gribsToAverage.append(subGF)
                        }
                    }
                }
            }
        case .Daily:
            if let startDate = self.first?.parser.dataTime.date, let endDate = self.last?.parser.dataTime.date {
                for year in Calendar.UTCCalendar.component(.year, from: startDate)...Calendar.UTCCalendar.component(.year, from: endDate) {
                    let subYear = self.filter({Calendar.UTCCalendar.component(.year, from: $0.parser.dataTime.date!) == year})
                    for month in 1...12 {
                        let subMonth = subYear.filter({Calendar.UTCCalendar.component(.month, from: $0.parser.dataTime.date!) == month})
                        if !subMonth.isEmpty, let date = Calendar.UTCCalendar.date(from: DateComponents(year: year, month: month)), let dayRange = Calendar.UTCCalendar.range(of: .day, in: .month, for: date) {
                            for day in dayRange {
                                let subDay = subMonth.filter({Calendar.UTCCalendar.component(.day, from: $0.parser.dataTime.date!) == day})
                                if !subDay.isEmpty {
                                    gribsToAverage.append(subDay)
                                }
                            }
                        }
                    }
                }
            }
        }
        return gribsToAverage
    }

    func average(for parameters: [GribParameterData]) throws -> (date: Date, gribValueData: GribValueData) {
        guard let firstFile = self.first, let firstDate = firstFile.parser.dataTime.date else {
            throw GribFileErrors.GribFileAverageError
        }
        let dimensions = firstFile.parser.gridDimensions
        var sumData = GribValueData()
        var sumTime = 0.0
        for file in self {
            guard dimensions == file.parser.gridDimensions, let fileDate = file.parser.dataTime.date, let data = file.parser.getValues(for: parameters) else {
                throw GribFileErrors.GribFileAverageError
            }
            sumTime += fileDate.timeIntervalSince(firstDate) / Double(self.count)
            for (parameter, values) in data {
                var sum = [Double]()
                if let s = sumData[parameter] {
                    for i in 0..<s.count {
                        sum.append(s[i] + values[i] / Double(self.count))
                    }
                } else {
                    for value in values {
                        sum.append(value / Double(self.count))
                    }
                }
                sumData[parameter] = sum
            }
        }
        let meanDate = Date(timeInterval: sumTime, since: firstDate)
        return (meanDate, sumData)
    }
}
