//
//  SubGridSpecificationViewController.swift
//  gribParserTest
//
//  Created by Bo Gustafsson on 2019-01-11.
//  Copyright © 2019 Bo Gustafsson. All rights reserved.
//

import Cocoa

protocol SubGridSpecificationDelegate {
    var swCornerPoint : Point? {get set}
    var neCornerPoint : Point? {get set}
    var iSkip : Int? {get set}
    var jSkip : Int? {get set}
}

class SubGridSpecificationViewController: NSViewController {

    
    @IBOutlet weak private var swLonTextField: NSTextField? {
        didSet {
            if let x = swLon {
                swLonTextField?.cell?.title = String(x)
            } else {
                swLonTextField?.cell?.title = ""
            }
        }
    }
    @IBOutlet weak private var swLatTextField: NSTextField? {
        didSet {
            if let x = swLat {
                swLatTextField?.cell?.title = String(x)
            } else {
                swLatTextField?.cell?.title = ""
            }
        }
    }
    @IBOutlet weak private var neLonTextField: NSTextField? {
        didSet {
            if let x = neLon {
                neLonTextField?.cell?.title = String(x)
            } else {
                neLonTextField?.cell?.title = ""
            }
        }
    }
    @IBOutlet weak private var neLatTextField: NSTextField? {
        didSet {
            if let x = neLat {
                neLatTextField?.cell?.title = String(x)
            } else {
                neLatTextField?.cell?.title = ""
            }
        }
    }
    @IBOutlet weak private var iSkipTextField: NSTextField? {
        didSet {
            if let i = iSkip {
                iSkipTextField?.cell?.title = String(i)
            } else {
                iSkipTextField?.cell?.title = ""
            }
        }
    }
    @IBOutlet weak private var jSkipTextField: NSTextField? {
        didSet {
            if let j = jSkip {
                jSkipTextField?.cell?.title = String(j)
            } else {
                jSkipTextField?.cell?.title = ""
            }
        }
    }
    
    
    var delegate: SubGridSpecificationDelegate?
    var swLon : Double? {
        didSet {
            if let x = swLon {
                swLonTextField?.cell?.title = String(x)
            } else {
                swLonTextField?.cell?.title = ""
            }
        }
    }
    var swLat : Double? {
        didSet {
            if let x = swLat {
                swLatTextField?.cell?.title = String(x)
            } else {
                swLatTextField?.cell?.title = ""
            }
        }
    }
    var neLon : Double? {
        didSet {
            if let x = neLon {
                neLonTextField?.cell?.title = String(x)
            } else {
                neLonTextField?.cell?.title = ""
            }
        }
    }
    var neLat : Double? {
        didSet {
            if let x = neLat {
                neLatTextField?.cell?.title = String(x)
            } else {
                neLatTextField?.cell?.title = ""
            }
        }
    }
    var iSkip : Int? {
        didSet {
            if let i = iSkip {
                iSkipTextField?.cell?.title = String(i)
            } else {
                iSkipTextField?.cell?.title = ""
            }
        }
    }
    var jSkip : Int? {
        didSet {
            if let j = jSkip {
                jSkipTextField?.cell?.title = String(j)
            } else {
                jSkipTextField?.cell?.title = ""
            }
        }
    }
    
    
 
    @IBAction private func newNumber(_ sender: NSTextField) {
        if let title = sender.cell?.title, let x = Double(title) {
            switch sender {
            case swLonTextField!:
                swLon = x
            case swLatTextField!:
                swLat = x
            case neLonTextField!:
                neLon = x
            case neLatTextField!:
                neLat = x
            case iSkipTextField!:
                iSkip = Int(x)
                _ = test()
            case jSkipTextField!:
                jSkip = Int(x)
                _ = test()
            default:
                break
            }
        }
    }
    
    private func test() -> Bool {
        if let swL = swLat, let neL = neLat, neL <= swL {return false}
        
        if let swL = swLon, let neL = neLon, neL <= swL {return false}
        if let i = iSkip, i <= 0 {
            iSkip = nil
            return false
        }
        if let i = jSkip, i <= 0 {
            jSkip = nil
            return false
        }
        return true
   }
    
    @IBAction private func done(_ sender: NSButton) {
        if test() {
            if let lat = swLat, let lon = swLon {
                delegate?.swCornerPoint = Point(id: 1, lon: lon, lat: lat)
            } else {
                delegate?.swCornerPoint = nil
            }
            if let lat = neLat, let lon = neLon {
                delegate?.neCornerPoint = Point(id: 1, lon: lon, lat: lat)
            } else {
                delegate?.neCornerPoint = nil
            }
            if let iS = iSkip {
                delegate?.iSkip = iS
            } else {
                delegate?.iSkip = nil
            }
            if let jS = jSkip {
                delegate?.jSkip = jS
            } else {
                delegate?.jSkip = nil
            }
            self.presentingViewController?.dismiss(self)
        }
    }
    @IBAction private func cancel(_ sender: NSButton) {
        self.presentingViewController?.dismiss(self)
    }
    @IBAction private func reset(_ sender: NSButton) {
        swLon = nil
        swLat = nil
        neLon = nil
        neLat = nil
        iSkip = nil
        jSkip = nil
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        view.window?.title = "Output grid dimensions"
    }
}
