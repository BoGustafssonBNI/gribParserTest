//
//  GribFileInfoTableCellView.swift
//  gribParserTest
//
//  Created by Bo Gustafsson on 2019-01-03.
//  Copyright © 2019 Bo Gustafsson. All rights reserved.
//

import Cocoa

class GribFileInfoTableCellView: NSTableCellView {
    
    @IBOutlet weak var fileNameTextField: NSTextField?
    @IBOutlet weak var gridDataTextField: NSTextField?
    @IBOutlet weak var geographyTextField: NSTextField?
    
    var gribFile : GribFile? {
        didSet {
            if let name = gribFile?.fileURL.lastPathComponent {
                fileNameTextField?.cell?.title = name
            }
            if let gridDimensions = gribFile?.parser.gridDimensions {
                gridDataTextField?.cell?.title = "I = \(gridDimensions.nI), J = \(gridDimensions.nJ)"
            }
            if let geography = gribFile?.parser.geographyData {
                geographyTextField?.cell?.title = "\(geography.latitudeOfFirstGridPointInDegrees)°N\(geography.longitudeOfFirstGridPointInDegrees)°E - \(geography.latitudeOfLastGridPointInDegrees)°N\(geography.longitudeOfLastGridPointInDegrees)°E, \(geography.iDirectionIncrementInDegrees)°x\(geography.jDirectionIncrementInDegrees)°"
            }
        }
    }
}
