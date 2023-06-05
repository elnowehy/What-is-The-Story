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

    var body: some View {
        VStack {
            SearchBarView(searchText: $tagText, enteredTags: $enteredTags)
                .environmentObject(searchVM)
            
            CategoryGridView().environmentObject(searchVM)
            
            Button("Search") {
                performSearch()
            }
            .buttonStyle(.bordered)
            .padding()

            SearchResultView(searchResults: searchVM.searchResults)
        }
        .navigationTitle("Search")
    }

    func performSearch() {
        // Send search parameters to `searchVM`
        searchVM.search(tags: enteredTags)
    }
}



struct CategoryGridView: View {
    @EnvironmentObject var searchVM: SearchVM
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(searchVM.categories) { category in
                    CategoryButton(category: category)
                        .padding(8)
                        .background(searchVM.isSelectedCategory(category) ? Color.blue.opacity(0.5) : Color.clear)
                        .cornerRadius(8)
                        .onTapGesture {
                            searchVM.toggleCategorySelection(category)
                        }
                }
            }
            .padding()
        }
        .frame(maxHeight: .infinity)
        .background(Color.white) // Add background color if needed
        .onAppear {
            searchVM.fetchCategories()
        }
    }
}


struct CategoryButton: View {
    var category: Category
    @EnvironmentObject var searchVM: SearchVM
    
    var body: some View {
        Text(category.id)
            .font(.headline)
            .foregroundColor(.white)
            .padding(8)
            .background(Color.blue)
            .cornerRadius(8)
    }
    
}


struct SearchResultView: View {
    var searchResults: [SearchResult]

    var body: some View {
        // Display the search results here using data from `searchResults`
        // Customize the view based on your desired UI representation for search results
        List(searchResults, id: \.self) { searchResult in
            Text(searchResult.title)
            Text(searchResult.description)
        }
    }
}



struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
