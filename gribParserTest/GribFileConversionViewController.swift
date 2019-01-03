//
//  ViewController.swift
//  gribParserTest
//
//  Created by Bo Gustafsson on 2018-12-28.
//  Copyright © 2018 Bo Gustafsson. All rights reserved.
//

import Cocoa

enum ConversionTypes: String {
    case points = "Point time-series"
    case tecplotFields = "Tecplot fields"
}

class GribFileConversionViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, ParameterSelection {
    
    @IBOutlet weak var gribFileTable: NSTableView! {
        didSet {
            gribFileTable.rowHeight = 77
        }
    }
    @IBOutlet weak var parameterSelectionTable: NSTableView! {
        didSet {
            parameterSelectionTable.rowHeight = 24
         }
    }
    
    @IBOutlet weak var fileSearchURLButton: NSButton!
    @IBOutlet weak var OutputURLButton: NSButton!
    @IBOutlet weak var conversionTypeSelector: NSPopUpButton!
    @IBOutlet weak var pointSpecificationURLButton: NSButton!
    
    private var conversionType = ConversionTypes.points
    var gribFiles : [GribFile]? {
        didSet {
            if gribFiles != nil {
                var tempList = [GribParameterData]()
                for file in gribFiles! {
                    let params = file.parser.parameterList
                    for param in params {
                        if !tempList.contains(param) {
                            tempList.append(param)
                        }
                    }
                }
                if !tempList.isEmpty {
                    tempList.sort{$0.paramId < $1.paramId}
                    parameterList = tempList
                    
                }
            }
            gribFileTable.reloadData()
        }
    }
    
    var parameterList : [GribParameterData]? {
        didSet {
            parameterSelectionTable.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        conversionTypeSelector.removeAllItems()
        conversionTypeSelector.addItem(withTitle: ConversionTypes.points.rawValue)
        conversionTypeSelector.addItem(withTitle: ConversionTypes.tecplotFields.rawValue)
        conversionTypeSelector.selectItem(withTitle: conversionType.rawValue)
        pointSpecificationURLButton.isHidden = conversionType == .tecplotFields ? true : false
        gribFileTable.delegate = self
        gribFileTable.dataSource = self
        parameterSelectionTable.dataSource = self
        parameterSelectionTable.delegate = self
     }
    
    private var urlsFromOpenPanel : [URL]! {
        didSet {
            if !urlsFromOpenPanel.isEmpty {
                let fm = FileManager.default
                var newURLs = [URL]()
                for url in urlsFromOpenPanel {
                    if url.hasDirectoryPath {
                        if let enumerator = fm.enumerator(at: url, includingPropertiesForKeys: [.isDirectoryKey, .isRegularFileKey]) {
                            for case let fileURL as URL in enumerator {
                                if !fileURL.hasDirectoryPath {
                                    newURLs.append(fileURL)
                                }
                                //                                }
                            }
                        }
                    } else {
                        newURLs.append(url)
                        print("\(url) is a file")
                    }
                }
                if !newURLs.isEmpty {
                    newURLs.sort{$0.lastPathComponent < $1.lastPathComponent}
                    initializeNewGribFiles(urls: newURLs)
                }
                print(newURLs)
            }
        }
    }
    
    private func initializeNewGribFiles(urls: [URL]) {
        var gribTemp = [GribFile]()
        for url in urls {
            if let file = GribFile(fileURL: url) {
                gribTemp.append(file)
            }
        }
        if !gribTemp.isEmpty {gribFiles = gribTemp}
    }
    
    
    @IBAction func searchForFileURLs(_ sender: NSButton) {
        let op = NSOpenPanel()
        op.canChooseDirectories = true
        op.canChooseFiles = true
        op.allowsMultipleSelection = true
        op.canCreateDirectories = false
        op.begin { (result) -> Void in
            if result == NSApplication.ModalResponse.OK {
                let urls = op.urls
                DispatchQueue.main.async {
                    self.urlsFromOpenPanel = urls
                }
            }
        }
    }
    
    //    Mark: TableView methods
    
    var parameterSelected = [GribParameterData: Bool]()
    
    let gribFileCell = NSUserInterfaceItemIdentifier.init("GribFileInfoCell")
    let parameterCell = NSUserInterfaceItemIdentifier.init("ParameterCell")
    
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        switch tableView {
        case gribFileTable:
            if let rows = gribFiles?.count {
                return rows
            }
        case parameterSelectionTable:
            if let rows = parameterList?.count {
                return rows
            }
        default:
            break
        }
        return 0
    }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        switch tableView {
        case gribFileTable:
            if let file = gribFiles?[row] {
                if let cell = gribFileTable.makeView(withIdentifier: gribFileCell, owner: self) as? GribFileInfoTableCellView {
                    cell.gribFile = file
                    return cell
                }
            }
        case parameterSelectionTable:
            if let parameter = parameterList?[row] {
                if let cell = parameterSelectionTable.makeView(withIdentifier: parameterCell, owner: self) as? ParameterTableCellView {
                    cell.parameter = parameter
                    cell.delegate = self
                    return cell
                }
            }
        default:
            break
        }
        return nil
    }
}

