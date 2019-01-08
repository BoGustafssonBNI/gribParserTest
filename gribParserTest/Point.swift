//
//  Point.swift
//  gribParserTest
//
//  Created by Bo Gustafsson on 2019-01-08.
//  Copyright © 2019 Bo Gustafsson. All rights reserved.
//

import Foundation

struct Point {
    var id : Int
    var lat : Double
    var lon : Double
    init(id: Int, lon: Double, lat: Double) {
        self.id = id
        self.lon = lon
        self.lat = lat
    }
    init?(from textLine: String, using delimiter: String) {
        let components = (textLine.components(separatedBy: .whitespaces).joined()).components(separatedBy: delimiter)
        if components.count < 3 {return nil}
         if let cd = components.first, let id = Int(cd), let lon = Double(components[1]), let lat = Double(components[2]) {
            self.id = id
            self.lat = lat
            self.lon = lon
        } else {
            return nil
        }
    }
}

extension Array where Element == Point {
    var uniqueIDs : [Int] {
        get {
            var result = [Int]()
            for p in self {
                if !result.contains(p.id) {
                    result.append(p.id)
                }
            }
            return result
        }
    }
    func numberOfPoints(for id: Int) -> Int {
        return (self.filter{$0.id == id}).count
    }
    func points(for id: Int) -> [Point] {
        return self.filter{$0.id == id}
    }
    init?(from fileURL: URL, separatedBy delimiter: String) {
        var pointArray = [Point]()
        do {
            let fileContent = try String.init(contentsOf: fileURL)
            let lines = fileContent.components(separatedBy: "\n")
            for line in lines {
                if let point = Point(from: line, using: delimiter) {
                    pointArray.append(point)
                }
            }
            if pointArray.count > 0 {
                self = pointArray
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
}
