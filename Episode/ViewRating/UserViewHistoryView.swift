//
//  UserViewHistory.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-05-12.
//

import SwiftUI

struct UserViewHistoryView: View {
    @StateObject var viewRatingVM = ViewRatingVM()
    @StateObject var episodeVM = EpisodeVM()
    @EnvironmentObject var userVM: UserVM
    @State private var sortOption = 0
    @State private var ascendingOrder = false
    var viewHistoryList: [ViewRating] {
        return sortedViewRatings()
    }
    
    let pageSize = 3
    
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
                
                Toggle(isOn: $ascendingOrder) {
                    Text("Ascending Order")
                }
                .padding()

                List {
                    ForEach(viewHistoryList.indices, id: \.self) { index in
                        VStack(alignment: .leading) {
                            if index < episodeVM.episodeList.count {
                                Text("Episode Title: \(episodeVM.episodeList[index].title)")
                            } else {
                                Text("Loading Episode...")
                            }
                            Text("Rating: \(viewHistoryList[index].rating)")
                            Text("Timestamp: \(viewHistoryList[index].timestamp)")
                        }
                    }
                    .onDelete(perform: delete)

                    if viewRatingVM.paginator.hasMoreData && !viewRatingVM.paginator.isLoading {
                        ProgressView() // Show a loading indicator while loading more data
                            .onAppear() {
                                Task {
                                    print(".onAppear1 User Id: \(viewRatingVM.userId)")
                                    await viewRatingVM.fetchUserHistory(pageSize: pageSize) // Load more data when the user scrolls to the bottom
                                    let snapshot = viewHistoryList
                                    episodeVM.episodeIds = snapshot.map { $0.episodeId }
                                    await episodeVM.fetch()
                                    print("Episode List: \(episodeVM.episodeIds.count)")

                                }
                            }
                    }
                }
                .onAppear {
                    Task {
                        print(".onAppear2 User Id: \(viewRatingVM.userId)")
                        let snapshot = viewHistoryList
                        episodeVM.episodeIds = snapshot.map { $0.episodeId }
                        await episodeVM.fetch()
                        print("Episode List: \(episodeVM.episodeIds.count)")
                    }
                }
            }
            .navigationTitle("View History")
            .task {
                print("userVM: \(userVM.user.id)")
                viewRatingVM.userId = userVM.user.id
                print(".task user Id: \(viewRatingVM.userId)")
                await viewRatingVM.fetchUserHistory(pageSize: pageSize)
            }
        }
    }
    
    func sortedViewRatings() -> [ViewRating] {
        var sortedViewRatings: [ViewRating] = []
        switch sortOptions[sortOption] {
        case "Timestamp":
            sortedViewRatings = viewRatingVM.viewHistory.sorted(by: { ascendingOrder ? $0.timestamp < $1.timestamp : $0.timestamp > $1.timestamp })
        case "Rating":
            sortedViewRatings = viewRatingVM.viewHistory.sorted(by: { ascendingOrder ? $0.rating < $1.rating : $0.rating > $1.rating })
        default:
            break
        }
        return sortedViewRatings
    }
    
    func delete(at offsets: IndexSet) {
        Task {
            let viewRatingsToDelete = offsets.map { sortedViewRatings()[$0] }
            for viewRating in viewRatingsToDelete {
                viewRatingVM.viewRating = viewRating
                await viewRatingVM.delete()
            }
            let snapshot = viewHistoryList
            episodeVM.episodeIds = snapshot.map { $0.episodeId }
            await episodeVM.fetch()
        }
    }
}


struct UserViewHistory_Previews: PreviewProvider {
    static var previews: some View {
        UserViewHistoryView()
    }
}
