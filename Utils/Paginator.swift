//
//  Paginator.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-05-12.
//

import Foundation

class Paginator<T>: ObservableObject {
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var hasMoreData: Bool = true

    private var currentPage: Int = 0
    private var pageSize: Int = AppSettings.pageSize

    func loadMoreData(fetch: @escaping (Int, Int) async throws -> [T], appendTo data: inout [T]) async {
        guard !isLoading, hasMoreData else { return }

        isLoading = true
        currentPage += 1

        do {
            let moreData = try await fetch(currentPage, pageSize)
            if moreData.isEmpty {
                hasMoreData = false
            } else {
                data.append(contentsOf: moreData)
            }
        } catch {
            print("Error fetching more data: \(error.localizedDescription)")
        }

        isLoading = false
    }
}
