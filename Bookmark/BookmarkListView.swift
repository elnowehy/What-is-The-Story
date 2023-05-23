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
                Picker("Sort by", selection: $sortOption) {
                    ForEach(0..<sortOptions.count) {
                        Text(self.sortOptions[$0])
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .onChange(of: sortOption) { _ in
                    fetchAndSortBookmarks()
                }
                
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
                                Text("Title: \(episode.title)")
                            } else if let series = bookmarkItems[index].content as? Series {
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
            
            var bookmarkItemsTemp: [BookmarkItem] = []
            for bookmark in snapshot {
                switch bookmark.contentType {
                case .episode:
                    episodeVM.episode.id = bookmark.contentId
                    await episodeVM.fetch()
                    let bookmarkItem = BookmarkItem(bookmark: bookmark, content: episodeVM.episode)
                    bookmarkItemsTemp.append(bookmarkItem)
                    
                case .series:
                    seriesVM.series.id = bookmark.contentId
                    await seriesVM.fetch()
                    let bookmarkItem = BookmarkItem(bookmark: bookmark, content: seriesVM.series)
                    bookmarkItemsTemp.append(bookmarkItem)
                }
            }
            bookmarkItems = bookmarkItemsTemp
        }
    }

    
    func delete(at offsets: IndexSet) {
        Task {
            let itemsToDelete = offsets.map { bookmarkItems[$0] }
            for item in itemsToDelete {
                // Remove from bookmarkVM
                bookmarkVM.bookmark = item.bookmark
                await bookmarkVM.delete()
                
                // Remove from bookmarkItems
                if let first = offsets.first {
                    bookmarkItems.remove(at: first)
                }
            }
        }
    }
}

struct BookmarListView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarkListView()
    }
}
