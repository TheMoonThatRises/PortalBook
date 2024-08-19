//
//  Image+barCode.swift
//  PortalBook
//
//  Created by TheMoonThatRises on 8/18/24.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

// adapted from https://stackoverflow.com/a/76334682
extension Image {

    enum BarCode {
        case qrCode
        case code128Barcode
    }

    init(code: String, _ type: BarCode) {
        let context = CIContext()
        let filter: CIFilter

        switch type {
        case .qrCode:
            let aFilter = CIFilter.qrCodeGenerator()
            aFilter.message = Data(code.utf8)
            filter = aFilter
        case .code128Barcode:
            let aFilter = CIFilter.code128BarcodeGenerator()
            aFilter.message = Data(code.utf8)
            filter = aFilter
        }

        if let ciImage = filter.outputImage,
           let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            self.init(cgImage, scale: 1, label: Text("BarCode"))
        } else {
            self.init(systemName: "xmark.circle")
        }

    }
}
