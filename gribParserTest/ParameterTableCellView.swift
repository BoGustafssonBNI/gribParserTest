//
//  ParameterTableCellView.swift
//  gribParserTest
//
//  Created by Bo Gustafsson on 2019-01-03.
//  Copyright © 2019 Bo Gustafsson. All rights reserved.
//

protocol ParameterSelection {
    var parameterSelected : [GribParameterData: Bool] {get set}
}

import Cocoa

class ParameterTableCellView: NSTableCellView {
    
    var parameter : GribParameterData? {
        didSet {
            if let name = parameter?.name {
                parameterSelectionButton?.title = name
                parameterSelectionButton?.state = .on
                delegate?.parameterSelected[parameter!] = true
            }
        }
    }
    var delegate : ParameterSelection? {
        didSet {
            if let para = parameter {
                delegate?.parameterSelected[para] = true
            }
        }
    }
    
    @IBOutlet weak private var parameterSelectionButton: NSButton?

    @IBAction private func parameterSelection(_ sender: NSButton) {
        if let state = parameterSelectionButton?.state {
            delegate?.parameterSelected[parameter!] = state == .on
        }
    }
    
}
