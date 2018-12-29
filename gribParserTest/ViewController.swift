//
//  ViewController.swift
//  gribParserTest
//
//  Created by Bo Gustafsson on 2018-12-28.
//  Copyright © 2018 Bo Gustafsson. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
let parse = Parse()
    override func viewDidLoad() {
        super.viewDidLoad()

        parse.getKeys(file: NSHomeDirectory() + "/MESAN_201412022300+000H00M")
    }


}

