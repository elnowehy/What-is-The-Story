//
//  Paginator.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-05-12.
//

import Foundation

class Paginator<T, PaginatableItem: Paginatable>: ObservableObject {
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var hasMoreData: Bool = true

    private var lastItem: PaginatableItem? = nil

    @MainActor
    func loadMoreData(fetch: @escaping (PaginatableItem?) async throws -> PaginatedResult<T, PaginatableItem>, appendTo data: inout [T]) async {
        guard !isLoading, hasMoreData else { return }

        isLoading = true

        do {
            let paginatedResult = try await fetch(lastItem)
            lastItem = paginatedResult.lastItem
            if paginatedResult.items.isEmpty {
                hasMoreData = false
            } else {
                data.append(contentsOf: paginatedResult.items)
            }
        } catch {
            print("Error fetching more data: \(error.localizedDescription)")
        }

        isLoading = false
    }
    
    func reset() {
        lastItem = nil
        hasMoreData = true
        isLoading = false
    }
}

protocol Paginatable {
    var id: String { get }
}

struct PaginatedResult<Item: Any, PaginatableItem: Paginatable> {
    var items: [Item]
    var lastItem: PaginatableItem?
}

class ArrayPaginator<T>: ObservableObject {
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var hasMoreData: Bool = true
    
    func loadMoreData(fetch: @escaping () async throws -> [T]) async throws -> [T] {
        guard !isLoading, hasMoreData else { return [] }

        isLoading = true

        do {
            let fetchedItems = try await fetch()
            if fetchedItems.isEmpty {
                hasMoreData = false
            }
            
            isLoading = false
            return fetchedItems
        } catch {
            isLoading = false
            throw error
        }
    }

    func reset() {
        hasMoreData = true
        isLoading = false
    }
}
