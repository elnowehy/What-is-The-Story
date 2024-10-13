//
//  BookmarkView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-05-19.
//

import Foundation

class BookmarkVM: ObservableObject {
    @Published var bookmark = Bookmark()
    private var bookmarkManager = BookmarkManager()
    @Published var userId: String = ""
    @Published var isLoading = false
    @Published var bookmarks: [Bookmark] = []
    public var paginator = Paginator<Bookmark, DBPaginatable>()
    
    enum SortOrder {
        case timestampAscending
        case timestampDescending
    }

    
    
    func add() {
        Task {
            bookmarkManager.bookmark = bookmark
            await bookmarkManager.add()
        }
    }

    @MainActor
    func fetch() async {
        bookmarkManager.bookmark.userId = bookmark.userId
        bookmarkManager.bookmark.contentId = bookmark.contentId

        // Fetch user's rating from the ViewsRatings database
        isLoading = true
        let result = await bookmarkManager.fetch()
        switch result {
        case .success:
            self.bookmark = bookmarkManager.bookmark
        case .notFound:
            print("bookmark not found")
        case .error(let error):
            print(error.localizedDescription)
        }
        isLoading = false
    }
    
//    @MainActor
//    func fetchUserBookmarks(pageSize: Int, sortOrder: SortOrder) async {
// 
//        await paginator.loadMoreData(fetch: { page, pageSize in
//            await self.bookmarkManager.fetchUserBookmarks( userId: self.userId, sortOrder: sortOrder, pageSize: pageSize)
//        }, appendTo: &self.bookmarks)
//
//    }
    
    @MainActor
    func fetchUserBookmarks(sortOrder: SortOrder) async {
        
        await paginator.loadMoreData(fetch: { (lastDocument: DBPaginatable?) in
            // Inside this closure, call the actual fetch method from the manager
            return try await self.bookmarkManager.fetchUserBookmarks(userId: self.userId, sortOrder: sortOrder, startAfter: lastDocument)
        }, appendTo: &self.bookmarks)
    }
    
    @MainActor
    func delete() async {
        bookmarkManager.bookmark = bookmark
        await bookmarkManager.delete()
    }
    
}
