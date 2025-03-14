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
    let contentType: Any // This could be an Episode or a Series
}

struct BookmarkListView: View {
    @StateObject var bookmarkVM = BookmarkVM()
    @StateObject var episodeVM = EpisodeVM()
    @StateObject var seriesVM = SeriesVM()
    @EnvironmentObject var userVM: UserVM
    @EnvironmentObject var theme: Theme
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
                .toggleStyle(ToggleBaseStyle(theme: theme))
                .padding()
                .onChange(of: ascendingOrder) { _ in
                    reset()
                    fetchAndSortBookmarks()
                }
                
                List {
                    ForEach(bookmarkItems.indices, id: \.self) { index in
                        VStack(alignment: .leading) {
                            if let episode = bookmarkItems[index].contentType as? Episode {
                                
                                NavigationLink(destination: EpisodeView(episode: episode, mode: .update)
                                    .environmentObject(episodeVM)
                                    .environmentObject(seriesVM)
                                ) {
                                    Text(episode.title)
                                        .font(theme.typography.subtitle)
                                }
                            } else if let series = bookmarkItems[index].contentType as? Series {
                                NavigationLink(destination: SeriesView(seriesVM: seriesVM, series: series, mode: .view))
                                {

                                    Text(series.title)
                                        .font(theme.typography.subtitle)
                                }
                            }
                            Text("\(formattedTimestamp(for: bookmarkItems[index].bookmark.timestamp))")
                                .font(theme.typography.text)
                                .foregroundColor(theme.colors.accent)

                        }
                        .font(theme.typography.subtitle)
                        if bookmarkVM.paginator.hasMoreData && !bookmarkVM.paginator.isLoading && index == bookmarkItems.count - 1 {
                            ProgressView() // Show a loading indicator while loading more data
                                .onAppear(perform: fetchAndSortBookmarks)
                        }
                    }
                    .onDelete(perform: delete)
                
                }
            }
            .navigationTitle("Bookmarks")
            .onAppear() {
                reset()
                bookmarkVM.userId = userVM.user.id
                fetchAndSortBookmarks()
            }
        }
    }
    
    private func reset() {
        bookmarkVM.paginator.reset()
        bookmarkItems = []
        bookmarkVM.bookmarks = []
        seriesVM.currentPage = 0
        episodeVM.currentPage = 0
        episodeVM.episodeIds.removeAll()
        episodeVM.episodeList.removeAll()
        seriesVM.seriesIds.removeAll()
        seriesVM.seriesList.removeAll()
    }
    
    private func fetchAndSortBookmarks() {
        Task {
            enum BookmarConent {
                case episode(Episode)
                case series(Series)
                case none
            }
            
            let sortOrder = ascendingOrder ? BookmarkVM.SortOrder.timestampAscending : BookmarkVM.SortOrder.timestampDescending
            await bookmarkVM.fetchUserBookmarks(sortOrder: sortOrder)
            
            let snapshot = bookmarkVM.bookmarks.sorted(by: {
                return ascendingOrder ? $0.timestamp < $1.timestamp : $0.timestamp > $1.timestamp
            })

            for bookmark in snapshot {
                switch bookmark.contentType {
                case .episode:
                    episodeVM.episodeIds.append(bookmark.contentId)
                case .series:
                    seriesVM.seriesIds.append(bookmark.contentId)
                default:
                    break
                }
            }
            
            _ = await episodeVM.fetch()
            _ = await seriesVM.fetch()

            let contentItems: [BookmarConent] = snapshot.map { bookmark in
                switch bookmark.contentType {
                case .episode:
                    if let episode = episodeVM.episodeList.first(where: { $0.id == bookmark.contentId }) {
                        return .episode(episode)
                    }
                case .series:
                    if let series = seriesVM.seriesList.first(where: { $0.id == bookmark.contentId }) {
                        return .series(series)
                    }
                default:
                    return .none
                }
                return .none
            }

            // bookmarkItems = zip(snapshot, contentItems).map(BookmarkItem.init)
            bookmarkItems = zip(snapshot, contentItems).map { bookmark, content in
                switch content {
                case .episode(let episode):
                    return BookmarkItem(bookmark: bookmark, contentType: episode)
                case .series(let series):
                    return BookmarkItem(bookmark: bookmark, contentType: series)
                case .none:
                    // Handle the none case if needed
                    return BookmarkItem(bookmark: bookmark, contentType: Episode())
                }
            }
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
