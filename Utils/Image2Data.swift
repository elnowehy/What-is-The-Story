//
//  Image2Data.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-03-12.
//

import SwiftUI

func image2pngData(uiImage: UIImage) throws -> Data {
    guard let data = uiImage.pngData() else {
        print("can't convert image to data")
        throw ConversionError.pngImageConversionFailed
    }
    return data
}

func pngData2Image(data: Data) throws -> UIImage {
    guard let uiImage = UIImage(data: data) else {
        print("can't convert image to data")
        throw ConversionError.dataToImageConversionFailed
    }
    return uiImage
}


enum ConversionError: Error {
    case pngImageConversionFailed
    case dataToImageConversionFailed
}
