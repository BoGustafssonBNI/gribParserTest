//
//  BinaryFileStream.swift
//  testBinaryOutputs
//
//  Created by Bo Gustafsson on 2024-01-10.
//

import Foundation

extension OutputStream {
    enum OutputStreamError: Error {
         case stringConversionFailure
         case bufferFailure
         case writeFailure
     }

     /// Write `String` to `OutputStream`
     ///
     /// - parameter string:                The `String` to write.
     /// - parameter encoding:              The `String.Encoding` to use when writing the string. This will default to `.utf8`.
     /// - parameter allowLossyConversion:  Whether to permit lossy conversion when writing the string. Defaults to `false`.

     func write(_ string: String, encoding: String.Encoding = .utf8, allowLossyConversion: Bool = false) throws {
         guard let data = string.data(using: encoding, allowLossyConversion: allowLossyConversion) else {
             throw OutputStreamError.stringConversionFailure
         }
         try write(data)
     }

     /// Write `Data` to `OutputStream`
     ///
     /// - parameter data:                  The `Data` to write.

     func write(_ data: Data) throws {
         try data.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) throws in
             guard var pointer = buffer.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                 throw OutputStreamError.bufferFailure
             }

             var bytesRemaining = buffer.count

             while bytesRemaining > 0 {
                 let bytesWritten = write(pointer, maxLength: bytesRemaining)
                 if bytesWritten < 0 {
                     throw OutputStreamError.writeFailure
                 }

                 bytesRemaining -= bytesWritten
                 pointer += bytesWritten
             }
         }
     }
    func write(array: [Float]) throws {
        var values = array
        let data = Data(bytes: &values, count: MemoryLayout<Float>.size * values.count)
        try write(data)
    }
    func write(array: [Int32]) throws {
        var values = array
        let data = Data(bytes: &values, count: MemoryLayout<Int32>.size * values.count)
        try write(data)
    }
}
