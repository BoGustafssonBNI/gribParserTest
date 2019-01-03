//
//  GribFile.swift
//  gribParserTest
//
//  Created by Bo Gustafsson on 2019-01-02.
//  Copyright © 2019 Bo Gustafsson. All rights reserved.
//

import Foundation

struct GribFile {
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
}
