//
//  FirebaseUtils.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-03-12.
//

import SwiftUI
import FirebaseStorage
import FirebaseFirestoreSwift



@MainActor
func storeImage(ref: StorageReference, uiImage: UIImage, quality: Double) async -> URL {
    var url = URL(string: "")
    guard let data = uiImage.jpegData(compressionQuality: quality) else {
        // set alert box or something
        // print(error.localizedDescription)
        return url!
    }
    
    let metadata = StorageMetadata()
    metadata.contentType = "image/jpg"
    
    do {
        let _ = try await ref.putDataAsync(data, metadata: metadata)
        url = try await ref.downloadURL()
    } catch {
        print(error.localizedDescription)
    }
    return url!
}
    


