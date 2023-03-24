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
        return url!
    }
    
    do {
        _ = try await ref.putDataAsync(data)
        url = try await ref.downloadURL()
    } catch {
        print(error.localizedDescription)
    }
    return url!
}
    


