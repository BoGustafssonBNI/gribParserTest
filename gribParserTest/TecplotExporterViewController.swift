//
//  TecplotExporterViewController.swift
//  gribParserTest
//
//  Created by Bo Gustafsson on 2019-01-04.
//  Copyright © 2019 Bo Gustafsson. All rights reserved.
//

import Cocoa

class TecplotExporterViewController: NSViewController {
    
    var gribFiles : [GribFile]?
    var parameters : [GribParameterData]?
    var outputURL : URL?
    private let fileName = "Tec" + MyDateConverter.shared.string(from: Date()) + ".plt"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
