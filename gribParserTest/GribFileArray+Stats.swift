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
struct GribFileAverageResults: Comparable, Equatable {
    
    var date = Date()
    var gribValueData = GribValueData()
    
    static func < (lhs: GribFileAverageResults, rhs: GribFileAverageResults) -> Bool {
        lhs.date < rhs.date
    }
    static func == (lhs: GribFileAverageResults, rhs: GribFileAverageResults) -> Bool {
        lhs.date == rhs.date
    }
    
    static func Average(gribFiles: [[GribFile]], for parameters: [GribParameterData], wSpeedParameter: GribParameterData?, uParameter: GribParameterData?, vParameter: GribParameterData?) async throws -> [GribFileAverageResults] {
        
        let numberOfIterations = gribFiles.count
        var result = [GribFileAverageResults].init(repeating: GribFileAverageResults(), count: numberOfIterations)
        try await withThrowingTaskGroup(of: (Int, GribFileAverageResults).self) {group in
            for i in 0..<numberOfIterations {
                group.addTask(priority: .userInitiated) {
                     return (i, try await gribFiles[i].average(for: parameters, using: wSpeedParameter, uParameter: uParameter, vParameter: vParameter))
                }
            }
            for try await (i, averageData) in group {
                result[i] = averageData
            }
        }
        return result
    }
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

    func average(for parameters: [GribParameterData], using wSpeedParameter: GribParameterData? = nil, uParameter: GribParameterData? = nil, vParameter: GribParameterData? = nil) async throws -> GribFileAverageResults {
        guard let firstFile = self.first, let firstDate = firstFile.parser.dataTime.date else {
            throw GribFileErrors.GribFileAverageError
        }
        let dimensions = firstFile.parser.gridDimensions
        if let wSpeedParameter = wSpeedParameter {
            print("wSpeedParameter \(wSpeedParameter.name) set in avergage")
        }
        var sumData = GribValueData()
        var nData = [GribParameterData: Int]()
        var sumTime = 0.0
        for file in self {
            guard dimensions == file.parser.gridDimensions, let fileDate = file.parser.dataTime.date, let data = file.parser.getValues(for: parameters) else {
                throw GribFileErrors.GribFileAverageError
            }
            sumTime += fileDate.timeIntervalSince(firstDate) / Double(self.count)
            if let windSpeedParameter = wSpeedParameter, let uParameter = uParameter, let vParameter = vParameter, let u = data[uParameter], let v = data[vParameter] {
                var speed = [Double]()
                if let s = sumData[windSpeedParameter] {
                    for i in 0..<u.count {
                        speed.append(s[i] + sqrt(u[i] * u[i] + v[i] * v[i]))
                    }
                } else {
                    for i in 0..<u.count {
                        speed.append(sqrt(u[i] * u[i] + v[i] * v[i]))
                    }
                }
                sumData[windSpeedParameter] = speed
                if let nd = nData[windSpeedParameter] {
                    nData[windSpeedParameter] = nd + 1
                } else {
                    nData[windSpeedParameter] = 1
                }
            }
            for (parameter, values) in data {
                var sum = [Double]()
                if let s = sumData[parameter] {
                    for i in 0..<s.count {
                        sum.append(s[i] + values[i])
                    }
                } else {
                    for value in values {
                        sum.append(value)
                    }
                }
                if let nd = nData[parameter] {
                    nData[parameter] = nd + 1
                } else {
                    nData[parameter] = 1
                }
                sumData[parameter] = sum
            }
        }
        let meanDate = Date(timeInterval: sumTime, since: firstDate)
        var newParameters = parameters
        if let windSpeedParameter = wSpeedParameter {
            newParameters.append(windSpeedParameter)
        }
        for parameter in newParameters {
            if let nd = nData[parameter], let data = sumData[parameter] {
                var temparray = [Double]()
                for value in data {
                    temparray.append(value / Double(nd))
                }
                sumData[parameter] = temparray
            }
        }
        return GribFileAverageResults(date: meanDate, gribValueData: sumData)
    }
}
