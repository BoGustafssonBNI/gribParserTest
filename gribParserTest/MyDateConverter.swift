//
//  MyDateConverter.swift
//  ReAnalysisDownload
//
//  Created by Bo Gustafsson on 2018-12-28.
//  Copyright © 2018 Bo Gustafsson. All rights reserved.
//
//  Converts a string of format "yyyymmddhhmm" to date


import Foundation

class MyDateConverter: DateFormatter {
    static let shared = MyDateConverter()
    override init() {
        super.init()
        self.locale = Locale(identifier: "en_US_POSIX")
        self.dateFormat = "yyyyMMddHHmm"
        self.timeZone = TimeZone(secondsFromGMT: 0)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
