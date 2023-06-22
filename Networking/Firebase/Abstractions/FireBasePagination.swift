//
//  Pagination.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-06-21.
//

import Foundation
import FirebaseFirestore

// Make DocumentSnapshot conform to this protocol
//extension DocumentSnapshot: Paginatable {
//    var id: String {
//        return documentID
//    }
//}

struct DBPaginatable: Paginatable {
    let id: String
    let document: DocumentSnapshot

    init(document: DocumentSnapshot) {
        self.id = document.documentID
        self.document = document
    }
}


