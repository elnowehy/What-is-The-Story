//
//  SearchViews.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-05-23.
//

import SwiftUI

struct SearchView: View {
    @StateObject var searchVM = SearchVM()
    @State var searchText: String = ""
    @State var searchBy: SearchVM.SearchAttribute = .all
    @State var selectedCategories = Set<String>()
    @StateObject var categoryVM = CategoryVM()

    var body: some View {
        VStack {
            CategorySelectionView(selectedCategories: $selectedCategories).environmentObject(categoryVM)
            
            Picker("Search by", selection: $searchBy) {
                Text("All").tag(SearchVM.SearchAttribute.all)
                Text("Series Title").tag(SearchVM.SearchAttribute.seriesTitle)
                Text("Episode Title").tag(SearchVM.SearchAttribute.episodeTitle)
                Text("Profile").tag(SearchVM.SearchAttribute.profile)
            }
            .pickerStyle(SegmentedPickerStyle())
            
//            TextField("Search", text: $searchText, onCommit: {
//                if searchBy == .category {
//                    searchVM.searchByCategories(categories: selectedCategories)
//                } else {
//                    searchVM.search(query: searchText, by: searchBy)
//                }
//            })
//            .textFieldStyle(RoundedBorderTextFieldStyle())
//            .padding()
            
            ForEach(searchVM.searchResults, id: \.self) { searchResult in
                SearchResultRow(searchResult: searchResult)
            }

        }
        .navigationTitle("Search")
    }
}

enum SearchAttribute {
    case all, seriesTitle, episodeTitle, category, profile, hashtag
}


struct SearchResultRow: View {
    var searchResult: SearchResult  // now a SearchResult instead of Any

    var body: some View {
        VStack(alignment: .leading) {
            Text(searchResult.title)
                .font(.headline)
            Text(searchResult.description)  // or whatever property you use to store the description
                .font(.subheadline)
            // ...any other properties you want to display...
        }
    }
}





//struct SearchView_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchViews()
//    }
//}
