//
//  GribInitEnvironment.swift
//  gribParserTest
//
//  Created by Bo Gustafsson on 2023-01-20.
//  Copyright © 2023 Bo Gustafsson. All rights reserved.
//

import Foundation

struct GribInitEnvironment {
    let initialized : Bool
    init() {
        if let path = Bundle.main.resourcePath {
            setenv("ECCODES_DEFINITION_PATH", path + "/definitions",1)
            initialized = true
        } else {
            initialized = false
        }
    }
}
