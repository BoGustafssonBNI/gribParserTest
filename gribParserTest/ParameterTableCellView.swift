//
//  ParameterTableCellView.swift
//  gribParserTest
//
//  Created by Bo Gustafsson on 2019-01-03.
//  Copyright © 2019 Bo Gustafsson. All rights reserved.
//

protocol ParameterSelection {
    var parameterSelected : [GribParameterData: Bool] {get set}
    var rotationCaseForParameter : [GribParameterData: GribParameterRotationCases] {get set}
}

import Cocoa

class ParameterTableCellView: NSTableCellView {
    
    var parameter : GribParameterData? {
        didSet {
            if let name = parameter?.name {
                parameterSelectionButton?.title = name
            }
            if let para = parameter, let del = delegate {
                if let value = del.parameterSelected[para] {
                    parameterSelectionButton?.state = value ? .on : .off
                }
                if let rotationCase = del.rotationCaseForParameter[para] {
                    rotationCaseSelector?.setSelected(true, forSegment: rotationCase.rawValue)
                }
            }
        }
    }
    var delegate : ParameterSelection? {
        didSet {
            if let para = parameter {
                if let value = delegate?.parameterSelected[para] {
                    parameterSelectionButton?.state = value ? .on : .off
                } else {
                    delegate?.parameterSelected[para] = false
                }
                if let rotationCase = delegate?.rotationCaseForParameter[para] {
                    rotationCaseSelector?.setSelected(true, forSegment: rotationCase.rawValue)
                } else {
                    delegate?.rotationCaseForParameter[para] = selectedCase
                }
            }
        }
    }
    
    private func initialize() {
        
    }
    @IBOutlet weak private var parameterSelectionButton: NSButton? {
        didSet {
            if let para = parameter {
                if let value = delegate?.parameterSelected[para] {
                    parameterSelectionButton?.state = value ? .on : .off
                } else {
                    delegate?.parameterSelected[para] = parameterSelectionButton!.state == .on
                }
            }
        }
    }
    @IBOutlet weak var rotationCaseSelector: NSSegmentedControl? {
        didSet {
            if let para = parameter {
                if let rotationCase = delegate?.rotationCaseForParameter[para] {
                    rotationCaseSelector?.setSelected(true, forSegment: rotationCase.rawValue)
                } else {
                    delegate?.rotationCaseForParameter[para] = selectedCase
                }
            }
        }
    }
    
    @IBAction private func parameterSelection(_ sender: NSButton) {
        if let state = parameterSelectionButton?.state {
            delegate?.parameterSelected[parameter!] = state == .on
        }
    }
    @IBAction func newRotationCaseSelected(_ sender: NSSegmentedControl) {
        if let param = parameter {
            delegate?.rotationCaseForParameter[param] = selectedCase
        }
    }
    private var selectedCase : GribParameterRotationCases {
        get {
            switch rotationCaseSelector!.selectedSegment {
            case 0:
                return .none
            case 1:
                return .u
            case 2:
                return .v
            default:
                return .none
            }
        }
    }
}
