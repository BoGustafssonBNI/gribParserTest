//
//  GribFile.swift
//  gribParserTest
//
//  Created by Bo Gustafsson on 2019-01-02.
//  Copyright © 2019 Bo Gustafsson. All rights reserved.
//

import Foundation

struct GribFile: Equatable {
    var fileURL : URL
    var parser : GribParser
    init?(fileURL: URL) {
        self.fileURL = fileURL
        let filename = fileURL.path
        do {
            self.parser = try GribParser(file: filename)
        } catch {
            return nil
        }
    }
    static func == (lhs: GribFile, rhs: GribFile) -> Bool {
        return lhs.fileURL.lastPathComponent == rhs.fileURL.lastPathComponent && lhs.parser.parameterList.count == rhs.parser.parameterList.count && lhs.parser.dataTime == rhs.parser.dataTime && lhs.parser.gridDimensions == rhs.parser.gridDimensions
    }
}
