import SwiftUI

struct ViewHistoryItem: Identifiable {
    let id = UUID()
    let viewRating: ViewRating
    let episode: Episode
}

struct UserViewHistoryView: View {
    @StateObject var viewRatingVM = ViewRatingVM()
    @StateObject var episodeVM = EpisodeVM()
    @EnvironmentObject var userVM: UserVM
    @State private var sortOption = 0
    @State private var ascendingOrder = false
    @State private var viewHistoryItems: [ViewHistoryItem] = []
    @EnvironmentObject var theme: Theme
    
    let pageSize = AppSettings.pageSize
    
    let sortOptions = ["Timestamp", "Rating"]

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
                    fetchAndSortViewHistory()
                }
                
                Toggle(isOn: $ascendingOrder) {
                    Text("Ascending Order")
                }
                .padding()
                .onChange(of: ascendingOrder) { _ in
                    fetchAndSortViewHistory()
                }

                List {
                    ForEach(viewHistoryItems.indices, id: \.self) { index in
                        VStack(alignment: .leading) {
                            Text("Episode Title: \(viewHistoryItems[index].episode.title)")
                            Text("Rating: \(viewHistoryItems[index].viewRating.rating)")
                            Text("Timestamp: \(viewHistoryItems[index].viewRating.timestamp)")
                        }
                    }
                    .onDelete(perform: delete)

                    if viewRatingVM.paginator.hasMoreData && !viewRatingVM.paginator.isLoading {
                        ProgressView() // Show a loading indicator while loading more data
                            .onAppear(perform: fetchAndSortViewHistory)
                    }
                }
                .font(theme.typography.subtitle)
            }
            .navigationTitle("View History")
            .task {
                print("userVM: \(userVM.user.id)")
                viewRatingVM.userId = userVM.user.id
                print(".task user Id: \(viewRatingVM.userId)")
                fetchAndSortViewHistory()
            }
        }
    }
    
    private func fetchAndSortViewHistory() {
        Task {
            let sortOrder = ascendingOrder
            ? (sortOption == 0 ? ViewRatingVM.SortOrder.timestampAscending : ViewRatingVM.SortOrder.ratingAscending)
            : (sortOption == 0 ? ViewRatingVM.SortOrder.timestampDescending : ViewRatingVM.SortOrder.ratingDescending)
            
            await viewRatingVM.fetchUserHistory(sortOrder: sortOrder)
            
            let snapshot = viewRatingVM.viewHistory.sorted(by: {
                if sortOption == 0 {
                    return ascendingOrder ? $0.timestamp < $1.timestamp : $0.timestamp > $1.timestamp
                } else {
                    return ascendingOrder ? $0.rating < $1.rating : $0.rating > $1.rating
                }
            })

            episodeVM.episodeIds = snapshot.map { $0.episodeId }
            await episodeVM.fetch()
            viewHistoryItems = zip(snapshot, episodeVM.episodeList).map(ViewHistoryItem.init)
        }
    }
    
    func delete(at offsets: IndexSet) {
        Task {
            let itemsToDelete = offsets.map { viewHistoryItems[$0] }
            for item in itemsToDelete {
                // Remove from ViewRating
                viewRatingVM.viewRating = item.viewRating
                await viewRatingVM.delete()
                
                // Remove from viewHistoryItems
                if let first = offsets.first {
                    viewHistoryItems.remove(at: first)
                }
            }
        }
    }
}


struct UserViewHistory_Previews: PreviewProvider {
    static var previews: some View {
        UserViewHistoryView()
    }
}

