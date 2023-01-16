//
//  TecplotExporterViewController.swift
//  gribParserTest
//
//  Created by Bo Gustafsson on 2019-01-04.
//  Copyright © 2019 Bo Gustafsson. All rights reserved.
//

import Cocoa

protocol ExportProgressDelegate {
    var progress : Double {get set}
    var numberToWrite : Int {get set}
    var numberWritten : Int {get set}
    var progressText : String {get set}
    var cancel : Bool {get}
    var done : Bool {get set}
}


class ExporterViewController: NSViewController, ExportProgressDelegate {
    var gribFiles : [GribFile]?
    var parameters : [GribParameterData]?
    var uParameter : GribParameterData?
    var vParameter : GribParameterData?
    var pointsToExport : [Point]?
    var outputURL : URL?
    var swCornerPoint : Point?
    var neCornerPoint : Point?
    var iSkip : Int?
    var jSkip : Int?
    var conversionType : ConversionTypes?
    var averageType : GribFileAverageTypes?
    private let tecFileName = "Tec" + MyDateConverter.shared.string(from: Date()) + ".plt"
    private let tecExporter = TecplotExports()
    private let pointExporter = PointExports()
    
    var progress: Double = 0.0 {
        didSet {
            DispatchQueue.main.async {
                self.progresIndicator?.doubleValue = self.progress
            }
            
        }
    }
    var progressText = "written out of"
    var numberToWrite: Int = 0
    var numberWritten: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.progressLabel?.cell?.title = "\(self.numberWritten) \(self.progressText) \(self.numberToWrite)"
            }
        }
    }
    var cancel = false
    var done = false {
        didSet {
            DispatchQueue.main.async {
                self.presentingViewController?.dismiss(self)
            }
        }
    }
    

    
    @IBOutlet weak private var progresIndicator: NSProgressIndicator?
    @IBOutlet weak private var progressLabel: NSTextField?
    @IBOutlet weak private var cancelButton: NSButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cancelButton?.isHidden = true
        if let ct = conversionType, let gb = gribFiles, let params = parameters, let url = outputURL {
            switch ct {
            case .tecplotFields:
                tecExporter.delegate = self
                
                let file = url.appendingPathComponent(tecFileName)
                cancelButton?.isHidden = false
                let queue = DispatchQueue.global(qos: .userInitiated)
                queue.async { [weak weakself = self] in
                    do {
                        let iS = weakself?.iSkip ?? 1
                        let jS = weakself?.jSkip ?? 1
                        if let averageType = weakself?.averageType {
                            try weakself?.tecExporter.exportGribFiles(gribFiles: gb, of: averageType, for: params, uParameter: weakself?.uParameter, vParameter: weakself?.vParameter, to: file, title: "test", swPoint: weakself?.swCornerPoint, nePoint: weakself?.neCornerPoint, iSkip: iS, jSkip: jS)
                        } else {
                            try weakself?.tecExporter.exportGribFiles(gribFiles: gb, for: params, uParameter: weakself?.uParameter, vParameter: weakself?.vParameter, to: file, title: "test", swPoint: weakself?.swCornerPoint, nePoint: weakself?.neCornerPoint, iSkip: iS, jSkip: jS)
                        }
                   } catch {
                        print("Tec write error \(error)")
                    }
                }
            case .points:
                pointExporter.delegate = self
                cancelButton?.isHidden = false
                if let points = pointsToExport {
                    let queue = DispatchQueue.global(qos: .userInitiated)
                    queue.async { [weak weakself = self] in
                        do {
                            try weakself?.pointExporter.exportPointFiles(gribFiles: gb, for: params, uParameter: weakself?.uParameter, vParameter: weakself?.vParameter, at: points, to: url)
                        } catch {
                            print("Point write error \(error)")
                        }
                    }
                }
            }
        }
        
    }
    override func viewWillAppear() {
        super.viewWillAppear()
        view.window?.title = "Data Export"
    }
    @IBAction private func cancelProcess(_ sender: NSButton) {
        cancelButton?.title = "Cancelled"
        cancelButton?.isEnabled = false
        cancel = true
        DispatchQueue.main.async {
            self.presentingViewController?.dismiss(self)
        }
    }
    
}
