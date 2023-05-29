//
//  BookmarkListView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-05-19.
//

import SwiftUI

struct BookmarkItem: Identifiable {
    let id = UUID()
    let bookmark: Bookmark
    let content: Any // This could be an Episode or a Series
}

struct BookmarkListView: View {
    @StateObject var bookmarkVM = BookmarkVM()
    @StateObject var episodeVM = EpisodeVM()
    @StateObject var seriesVM = SeriesVM()
    @EnvironmentObject var userVM: UserVM
    @State private var sortOption = 0
    @State private var ascendingOrder = false
    @State private var bookmarkItems: [BookmarkItem] = []
    
    let pageSize = AppSettings.pageSize
    
    let sortOptions = ["Timestamp"]

    var body: some View {
        NavigationStack {
            VStack {
                Toggle(isOn: $ascendingOrder) {
                    Text("Ascending Order")
                }
                .padding()
                .onChange(of: ascendingOrder) { _ in
                    fetchAndSortBookmarks()
                }

                List {
                    ForEach(bookmarkItems.indices, id: \.self) { index in
                        VStack(alignment: .leading) {
                            if let episode = bookmarkItems[index].content as? Episode {
                                Text("Episode")
                                Text("Title: \(episode.title)")
                            } else if let series = bookmarkItems[index].content as? Series {
                                Text("Series")
                                Text("Title: \(series.title)")
                            }
                            Text("Timestamp: \(bookmarkItems[index].bookmark.timestamp)")
                        }
                    }
                    .onDelete(perform: delete)

                    if bookmarkVM.paginator.hasMoreData && !bookmarkVM.paginator.isLoading {
                        ProgressView() // Show a loading indicator while loading more data
                            .onAppear(perform: fetchAndSortBookmarks)
                    }
                }
            }
            .navigationTitle("Bookmarks")
            .task {
                bookmarkVM.userId = userVM.user.id
                fetchAndSortBookmarks()
            }
        }
    }
    
    private func fetchAndSortBookmarks() {
        Task {
            let sortOrder = ascendingOrder ? BookmarkVM.SortOrder.timestampAscending : BookmarkVM.SortOrder.timestampDescending
            await bookmarkVM.fetchUserBookmarks(pageSize: pageSize, sortOrder: sortOrder)
            
            let snapshot = bookmarkVM.bookmarks.sorted(by: {
                return ascendingOrder ? $0.timestamp < $1.timestamp : $0.timestamp > $1.timestamp
            })

            for bookmark in snapshot {
                switch bookmark.contentType {
                case .episode:
                    episodeVM.episodeIds.append(bookmark.contentId)
                    
                case .series:
                    seriesVM.seriesIds.append(bookmark.contentId)
                }
            }
            
            await episodeVM.fetch()
            await seriesVM.fetch()

            let contentItems: [Any] = snapshot.map { bookmark in
                switch bookmark.contentType {
                case .episode:
                    return episodeVM.episodeList.first(where: { $0.id == bookmark.contentId })
                case .series:
                    return seriesVM.seriesList.first(where: { $0.id == bookmark.contentId })
                }
            }

            bookmarkItems = zip(snapshot, contentItems).map(BookmarkItem.init)
        }
    }


    
    func delete(at offsets: IndexSet) {
        let itemsToDelete = offsets.map { bookmarkItems[$0] }
        for item in itemsToDelete {
            // Remove from bookmarkVM
            bookmarkVM.bookmark = item.bookmark
            bookmarkVM.delete()
            
            // Remove from bookmarkItems
            if let first = offsets.first {
                bookmarkItems.remove(at: first)
            }
        }
    }
}

struct BookmarListView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarkListView()
    }
}
