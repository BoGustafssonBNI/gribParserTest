//
//  ViewController.swift
//  gribParserTest
//
//  Created by Bo Gustafsson on 2018-12-28.
//  Copyright © 2018 Bo Gustafsson. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        do {
//            let parse = try Parse(file: NSHomeDirectory() + "/MESAN_199712102100+000H00M")
            let parse = try Parse(file: NSHomeDirectory() + "/MESAN_201812260000+000H00M")

            if let oneDataseries = parse.getValues(for: parse.parameterList[2]) {
                print(oneDataseries[0])
            }
            if let collection = parse.getValues(for: parse.parameterList) {
                print(collection.count)
                let tecExporter = TecplotExports()
                tecExporter.exportField(gridData: parse.gridData, data: collection)
            }
        } catch {
            print(error)
        }
//        parse.getKeys(file: NSHomeDirectory() + "/MESAN_201812260000+000H00M")
    }


}

