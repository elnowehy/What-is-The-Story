//
//  FirebaseUtils.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-03-12.
//

import SwiftUI
import FirebaseStorage
// import FirebaseFireStoreSwift



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
    
@MainActor
func storeVideo(ref: StorageReference, data: Data) async -> URL {
    var url = URL(string: "")

    let metadata = StorageMetadata()
    metadata.contentType = "video/mp4"
    
    do {
        let _ = try await ref.putDataAsync(data, metadata: metadata)
        url = try await ref.downloadURL()
    } catch {
        print(error.localizedDescription)
    }
    return url!
}

func uploadVideo(videoURL: URL, ref: StorageReference) async throws -> URL {
    let metadata = StorageMetadata()
    metadata.contentType = "video/mp4"
    
    let uploadTask = ref.putFile(from: videoURL, metadata: metadata)
    
    return try await withUnsafeThrowingContinuation { continuation in
        uploadTask.observe(.progress) { snapshot in
            guard let progress = snapshot.progress else { return }
            let percentage = Double(progress.completedUnitCount) / Double(progress.totalUnitCount) * 100.0
            print("Upload progress: \(percentage)%")
        }
        uploadTask.observe(.success) { snapshot in
            ref.downloadURL { url, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let url = url {
                    continuation.resume(returning: url)
                } else {
                    let error = NSError(domain: "UploadError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred."])
                    continuation.resume(throwing: error)
                }
            }
        }
        uploadTask.observe(.failure) { snapshot in
            let error = NSError(domain: "UploadError", code: 0, userInfo: [NSLocalizedDescriptionKey: snapshot.error?.localizedDescription ?? "Unknown error occurred."])
            continuation.resume(throwing: error)
        }
    }
}
