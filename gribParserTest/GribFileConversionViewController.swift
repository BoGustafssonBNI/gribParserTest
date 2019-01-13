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

class GribFileConversionViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, ParameterSelection, SubGridSpecificationDelegate {
    
    
    @IBOutlet weak var fileSearchURLButton: NSButton!
    @IBOutlet weak var OutputURLButton: NSButton!
    @IBOutlet weak var conversionTypeSelector: NSPopUpButton!
    @IBOutlet weak var specificationButton: NSButton!
    @IBOutlet weak var performConversionButton: NSButton!
    @IBOutlet weak var selectAllButton: NSButton!
    @IBOutlet weak var unselectAllButton: NSButton!
    @IBOutlet weak var showAllButton: NSButton!
    
    
    var firstDate : Date?
    var lastDate : Date?
    var gribFilesTimeIntervals = [TimeInterval]()
    
    var gribFiles : [GribFile]? {
        didSet {
            if gribFiles != nil {
                var tempList = [GribParameterData]()
                gribFilesTimeIntervals = []
                var fD = Date()
                var lD = Date.init(timeIntervalSince1970: 0.0)
                var previousDate : Date?
                for file in gribFiles! {
                    let params = file.parser.parameterList
                    for param in params {
                        if !tempList.contains(param) {
                            tempList.append(param)
                        }
                    }
                    if let date = file.parser.dataTime.date {
                        fD = min(date, fD)
                        lD = max(date, lD)
                        if let pD = previousDate {
                            let tDiff = date.timeIntervalSince(pD)
                            if !gribFilesTimeIntervals.contains(tDiff) {
                                gribFilesTimeIntervals.append(tDiff)
                            }
                        }
                        previousDate = date
                     }
                }
                if fD <= lD {
                    firstDate = fD
                    lastDate = lD
                    setDateInTableColumnHeader()
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
        setSpecificationButtonTitle()
        performConversionButton.isEnabled = false
        showAllButton.isEnabled = false
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        view.window?.title = "Grib Parser"
    }
    private func setSpecificationButtonTitle() {
        switch conversionType {
        case .points:
            specificationButton.title = "Set file for point(s)"
            specificationButton.toolTip = "Choose a file that specifices which points to extract. The file should include 3 columns: id, lon and lat. All points with same id will be averaged. File should be ASCII, any separator should work (e.g., space, comma, tab etc.)"
        case .tecplotFields:
            specificationButton.title = subGridInfoString()
            specificationButton.toolTip = "Specifies/shows sub-grid to extract"
        }
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
        setSpecificationButtonTitle()
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
                specificationButton.title = url.path
                performConversionButton.isEnabled = canPerformConversion
            }
        }
    }
    let setSubGridSpecificationSegue : NSStoryboardSegue.Identifier = "setSubGridSpecificationSegue"
    
    @IBAction func setOutputSpecification(_ sender: NSButton) {
        switch conversionType {
        case .points:
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
        case .tecplotFields:
            performSegue(withIdentifier: setSubGridSpecificationSegue, sender: self)
        }
    }
    
    var swCornerPoint: Point? {
        didSet {
            setSpecificationButtonTitle()
        }
    }
    
    var neCornerPoint: Point? {
        didSet {
            setSpecificationButtonTitle()
        }
    }
    
    var iSkip: Int? {
        didSet {
            setSpecificationButtonTitle()
        }
    }
    
    var jSkip: Int? {
        didSet {
            setSpecificationButtonTitle()
        }
    }
    
    private func subGridInfoString() -> String {
        var strings = [String]()
        if let swC = swCornerPoint {
            strings.append("SW:" + swC.position)
        }
        if let neC = neCornerPoint {
            strings.append("NE:" + neC.position)
        }
        if let iS = iSkip {
            strings.append("Δi=\(iS)")
        }
        if let jS = jSkip {
            strings.append("Δj=\(jS)")
        }
        if strings.count > 0 {
            return strings.joined(separator: ",")
        } else {
            return "Specify sub-grid"
        }
    }
    
    @IBOutlet weak var spinner: NSProgressIndicator!
    
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
                    spinner.isHidden = false
                    spinner.startAnimation(nil)
                    DispatchQueue.global(qos: .userInitiated).async {[weak weakself = self] in
                        weakself?.initializeNewGribFiles(urls: newURLs)
                    }
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
        gribTemp.sort(by: {return $0.parser.dataTime.date ?? Date() < $1.parser.dataTime.date ?? Date()})
        if !gribTemp.isEmpty {
            DispatchQueue.main.async {
                self.gribFiles = gribTemp
                self.spinner.stopAnimation(nil)
                self.spinner.isHidden = true
            }
        }
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
                    self.OutputURLButton.title = url.path
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
            let row = gribFileTable.selectedRow
            if row >= 0 {
                gribFileTable.deselectRow(row)
            }
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
            vc.swCornerPoint = swCornerPoint
            vc.neCornerPoint = neCornerPoint
            vc.iSkip = iSkip
            vc.jSkip = jSkip
        } else if segue.identifier == setSubGridSpecificationSegue, let vc = segue.destinationController as? SubGridSpecificationViewController {
            vc.delegate = self
            vc.swLon = swCornerPoint?.lon
            vc.swLat = swCornerPoint?.lat
            vc.neLon = neCornerPoint?.lon
            vc.neLat = neCornerPoint?.lat
            vc.iSkip = iSkip
            vc.jSkip = jSkip
        }
    }
    
    
    
    //    Mark: - TableView methods
    
    @IBOutlet weak var gribFileTable: NSTableView! {
        didSet {
            gribFileTable.delegate = self
            gribFileTable.dataSource = self
            gribFileTable.rowHeight = 77
        }
    }
    @IBOutlet weak var parameterSelectionTable: NSTableView! {
        didSet {
            parameterSelectionTable.dataSource = self
            parameterSelectionTable.delegate = self
            parameterSelectionTable.rowHeight = 24
        }
    }
    let gribFileCell = NSUserInterfaceItemIdentifier.init("GribFileInfoCell")
    let parameterCell = NSUserInterfaceItemIdentifier.init("ParameterCell")
    
    private func setDateInTableColumnHeader() {
        if let fD = firstDate, let lD = lastDate, let numberOfFiles = gribFiles?.count {
            let beginning = MyDateConverter.shared.string(from: fD)
            let end = MyDateConverter.shared.string(from: lD)
            var timeInterval = ""
            for tDiff in gribFilesTimeIntervals {
                 timeInterval += ", Δt=\(tDiff/3600.0)h"
            }
            if let column = gribFileTable.tableColumns.first {
                column.headerCell.title = "\(numberOfFiles) grib files from \(beginning) to \(end)" + timeInterval
            }
        }
    }
    
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
    
    func tableView(_ tableView: NSTableView, rowActionsForRow row: Int, edge: NSTableView.RowActionEdge) -> [NSTableViewRowAction] {
        switch tableView {
        case gribFileTable:
            let action = NSTableViewRowAction(style: .destructive, title: "Delete", handler:
            {action, row in
                self.gribFiles?.remove(at: row)
                tableView.removeRows(at: IndexSet.init(integer: row), withAnimation: .effectFade)
            })
            return [action]
        case parameterSelectionTable:
            return []
        default:
            return []
        }
    }
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        switch tableView {
        case gribFileTable:
            return true
        case parameterSelectionTable:
            return false
        default:
            return false
        }
    }
    func tableView(_ tableView: NSTableView, shouldSelect tableColumn: NSTableColumn?) -> Bool {
        switch tableView {
        case gribFileTable:
            return true
        case parameterSelectionTable:
            return false
        default:
            return false
        }
    }
}

