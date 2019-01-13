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
        var filteredLine = ""
        if delimiter == "\t" {
            var cSet = CharacterSet.whitespaces
            cSet.remove("\t")
            filteredLine = textLine.components(separatedBy: cSet).joined()
        } else if delimiter == " " {
            let words = textLine.components(separatedBy: " ")
            for w in words {
                if w != " " && !w.isEmpty{
                    filteredLine += w + " "
                }
            }
            filteredLine = String(filteredLine.dropLast())
        } else {
            filteredLine = textLine.components(separatedBy: .whitespaces).joined()
        }
        let components = filteredLine.components(separatedBy: delimiter)
        if components.count < 3 {return nil}
         if let cd = components.first, let id = Int(cd), let lon = Double(components[1]), let lat = Double(components[2]) {
            self.id = id
            self.lat = lat
            self.lon = lon
        } else {
            return nil
        }
    }
    var position : String {
        get {
            return String(format: "%.2lf", self.lon) + "°E," + String(format: "%.2lf", lat) + "°N"
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
            var encoding = String.Encoding.ascii
            let fileContent = try String.init(contentsOf: fileURL, usedEncoding: &encoding)
            let eol : String
            if fileContent.contains("\r\n") {
                eol = "\r\n"
            } else if fileContent.contains("\n") {
                eol = "\n"
            } else {
                eol = "\r"
            }
            let delimiter : String
            if fileContent.contains(";") {
                delimiter = ";"
            } else if fileContent.contains("\t") {
                delimiter = "\t"
            } else if fileContent.contains(","){
                delimiter = ","
            } else {
                delimiter = " "
            }
            let lines = fileContent.components(separatedBy: eol)
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
