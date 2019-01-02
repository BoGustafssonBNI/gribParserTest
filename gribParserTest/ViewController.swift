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
//           let parse = try Parse(file: NSHomeDirectory() + "/MESAN_201812260000+000H00M")
            let parse = try Parse(file: NSHomeDirectory() + "/Temp/MesanTemp/RCA_196101010000+000H00M")

            let lons = [16.588376, 20.0]
            let lats = [58.783734, 62.0]
            if let oneDataseries = parse.getValues(lons: lons, lats: lats, for: [parse.parameterList[0]]) {
                print(oneDataseries.first!)
                print(Coordinate.init(lon: 6.032269, lat: 52.81264, geography: parse.geographyData))
                
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

