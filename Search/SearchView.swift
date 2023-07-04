//
//  SearchViews.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-05-23.
//

import SwiftUI

struct SearchView: View {
    @StateObject var searchVM = SearchVM()
    @State var tagText = ""
    @State var enteredTags = [String]()
    @EnvironmentObject var theme: Theme
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: theme.spacing.medium) {
                CategoryGridView().environmentObject(searchVM)
                
                HStack(alignment: .top) {
                    TagSearchBarView(searchText: $tagText, enteredTags: $enteredTags)
                        .environmentObject(searchVM)
                        .frame(maxWidth: .infinity)
                    
                    Button("Search") {
                        performSearch()
                    }
                    .buttonStyle(ButtonBaseStyle(theme: theme))
                }
                .frame(maxWidth: .infinity)
                
                
                SearchResultView(searchResults: searchVM.searchResults)
            }
            .padding()
        }
    }
    
    func performSearch() {
        searchVM.search(tags: enteredTags)
    }
}

struct CategoryGridView: View {
    @EnvironmentObject var searchVM: SearchVM
    @EnvironmentObject var theme: Theme
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: theme.spacing.button) {
                ForEach(searchVM.categories) { category in
                    Button(action: {
                        searchVM.toggleCategorySelection(category)
                    }) {
                        Text(category.id)
                    }
                    .buttonStyle(CategoryButtonStyle(theme: theme, isSelected: searchVM.isSelectedCategory(category)))
                }
            }
            .padding(.horizontal)
            .onAppear {
                searchVM.fetchCategories()
            }
        }
    }
}

struct SearchResultView: View {
    var searchResults: [SearchResult]
    
    var body: some View {
        List(searchResults, id: \.id) { searchResult in
            SearchResultRowView(searchResult: searchResult)
        }
    }
}

struct SearchResultRowView: View {
    var searchResult: SearchResult
    @StateObject private var seriesVM = SeriesVM()
    @StateObject private var episodeVM = EpisodeVM()
    @EnvironmentObject var profileVM: ProfileVM

    var body: some View {
        if searchResult.contentType == .series {
            NavigationLink(
                destination: SeriesView(seriesVM: seriesVM, series: seriesVM.series, mode: .view),
                label: {
                    HStack {
                        Text("Series: ")
                        Text(searchResult.title)
                    }
                }
            )
            .onAppear {
                Task {
                    seriesVM.seriesIds.append(searchResult.id)
                    await seriesVM.fetch()
                }
            }
        } else {
            NavigationLink(
                destination: EpisodeView(episode: episodeVM.episode, mode: .view)
                    .environmentObject(episodeVM)
                    .environmentObject(seriesVM),
                label: {
                    HStack {
                        Text("Episode: ")
                        Text(searchResult.title)
                    }
                }
            )
            .onAppear {
                Task {
                    episodeVM.episodeIds.append(searchResult.id)
                    await episodeVM.fetch()
                }
            }
        }
    }
}




struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
