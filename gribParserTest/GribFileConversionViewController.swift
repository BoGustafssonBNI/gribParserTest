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
    
    
    @IBOutlet weak var fileSearchURLButton: NSButton!
    @IBOutlet weak var OutputURLButton: NSButton!
    @IBOutlet weak var conversionTypeSelector: NSPopUpButton!
    @IBOutlet weak var pointSpecificationURLButton: NSButton!
    @IBOutlet weak var performConversionButton: NSButton!
    @IBOutlet weak var selectAllButton: NSButton!
    @IBOutlet weak var unselectAllButton: NSButton!
    @IBOutlet weak var showAllButton: NSButton!
    
    
    
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
                    allParametersList = tempList
                }
            }
            performConversionButton.isEnabled = canPerformConversion
            gribFileTable.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        conversionTypeSelector.removeAllItems()
        conversionTypeSelector.addItem(withTitle: ConversionTypes.points.rawValue)
        conversionTypeSelector.addItem(withTitle: ConversionTypes.tecplotFields.rawValue)
        conversionTypeSelector.selectItem(withTitle: conversionType.rawValue)
        pointSpecificationURLButton.isHidden = conversionType == .tecplotFields ? true : false
        performConversionButton.isEnabled = false
        showAllButton.isEnabled = false
        gribFileTable.delegate = self
        gribFileTable.dataSource = self
        parameterSelectionTable.dataSource = self
        parameterSelectionTable.delegate = self
     }
    
    private var canPerformConversion : Bool {
        get {
            let result = outputURL != nil && (conversionType == .points ? pointsForExtraction != nil : true)
            var select = false
            for (_, selected) in parameterSelected {
                select = select || selected
            }
            return result && select
        }
    }
    
    
    private var conversionType = ConversionTypes.points

    @IBAction func changedConversionType(_ sender: NSPopUpButton) {
        if let item = conversionTypeSelector.titleOfSelectedItem {
            switch item {
            case ConversionTypes.points.rawValue:
                conversionType = .points
            case ConversionTypes.tecplotFields.rawValue:
                conversionType = .tecplotFields
            default:
                break
            }
        }
        performConversionButton.isEnabled = canPerformConversion
        pointSpecificationURLButton.isHidden = conversionType == .tecplotFields ? true : false
    }
    
    var pointSpecificationFileURL : URL? {
        didSet {
            if let url = pointSpecificationFileURL {
                if let points = [Point].init(from: url, separatedBy: ",") {
                    pointsForExtraction = points
                }
            }
        }
    }
    
    var pointsForExtraction : [Point]? {
        didSet {
            if let url = pointSpecificationFileURL {
                pointSpecificationURLButton.title = url.absoluteString
                performConversionButton.isEnabled = canPerformConversion
            }
        }
    }
    
    @IBAction func getPointSpecificationURL(_ sender: NSButton) {
        let op = NSOpenPanel()
        op.canChooseDirectories = false
        op.canChooseFiles = true
        op.allowsMultipleSelection = false
        op.canCreateDirectories = false
        op.allowedFileTypes = ["txt","csv"]
        op.begin { (result) -> Void in
            if result == NSApplication.ModalResponse.OK, let url = op.url {
                DispatchQueue.main.async {
                    self.pointSpecificationFileURL = url
                }
            }
        }
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
                    }
                }
                if !newURLs.isEmpty {
                    newURLs.sort{$0.lastPathComponent < $1.lastPathComponent}
                    initializeNewGribFiles(urls: newURLs)
                }
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
//        op.begin {(result) -> Void in
//            if result == NSApplication.ModalResponse.OK {
//                let urls = op.urls
//                DispatchQueue.main.async { self.urlsFromOpenPanel = urls
//                }
//            }
//        }
        let result = op.runModal()
        if result == NSApplication.ModalResponse.OK {
            let urls = op.urls
            urlsFromOpenPanel = urls
        }
    }
    
    private var outputURL : URL?
    
    @IBAction func setOutputDirectory(_ sender: NSButton) {
        let op = NSOpenPanel()
        op.canChooseDirectories = true
        op.canChooseFiles = false
        op.allowsMultipleSelection = false
        op.canCreateDirectories = true
        op.begin { (result) -> Void in
            if result == NSApplication.ModalResponse.OK, let url = op.url {
                DispatchQueue.main.async {
                    self.outputURL = url
                    self.OutputURLButton.title = url.absoluteString
                }
            }
        }

    }
    private var allParametersList : [GribParameterData]?
    
    var parameterList : [GribParameterData]? {
        didSet {
            parameterSelectionTable.reloadData()
            performConversionButton.isEnabled = canPerformConversion
        }
    }

    var parameterSelected = [GribParameterData: Bool]() {
        didSet {
            performConversionButton.isEnabled = canPerformConversion
        }
    }
    
    var rotationCaseForParameter = [GribParameterData: GribParameterRotationCases]()
    
    @IBAction func showAllParameters(_ sender: NSButton) {
        if let list = allParametersList {
            parameterList = list
            showAllButton.isEnabled = false
        }
    }
    
    @IBAction func selectAllParameters(_ sender: NSButton) {
        if let list = parameterList {
            for param in list {
                parameterSelected[param] = sender == selectAllButton
             }
        }
        parameterSelectionTable.reloadData()
    }
    
    let exportSegueIdentifier : NSStoryboardSegue.Identifier = "TecplotExportSegue"
    @IBAction func convert(_ sender: NSButton) {
        performSegue(withIdentifier: exportSegueIdentifier, sender: self)
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == exportSegueIdentifier, let vc = segue.destinationController as? ExporterViewController, let outURL = outputURL, let files = gribFiles {
            vc.gribFiles = files
            var params = [GribParameterData]()
            var uParam : GribParameterData?
            var vParam : GribParameterData?
            for (param, write) in parameterSelected {
                if write {
                    if let rotCase = rotationCaseForParameter[param] {
                        switch rotCase {
                        case .u:
                            uParam = param
                        case .v:
                            vParam = param
                        case .none:
                            break
                        }
                    }
                    params.append(param)
                }
            }
            vc.parameters = params
            vc.uParameter = uParam
            vc.vParameter = vParam
            vc.outputURL = outURL
            vc.conversionType = conversionType
            vc.pointsToExport = pointsForExtraction
        }
    }
    
    
    
    //    Mark: TableView methods
    
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
    let gribFileCell = NSUserInterfaceItemIdentifier.init("GribFileInfoCell")
    let parameterCell = NSUserInterfaceItemIdentifier.init("ParameterCell")
    
    @IBAction func selectedFile(_ sender: NSTableView) {
        let row = sender.selectedRow
        if row >= 0, let file = gribFiles?[row] {
            showAllButton.isEnabled = true
            parameterList = file.parser.parameterList
        }
    }
    
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

