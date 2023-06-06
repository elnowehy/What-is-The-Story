//
//  TagViews.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-06-05.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    @Binding var enteredTags: [String]
    @EnvironmentObject var searchVM: SearchVM
    @State private var showSuggestions = false

    var body: some View {
        VStack {
            TextField("Search", text: $searchText, onCommit: { addTag() })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .onChange(of: searchText) { newValue in
                    if newValue.last == " " {
                        addTag()
                    } else {
                        Task {
                            do {
                                try await searchVM.fetchTagSuggestions(tagPrefix: newValue)
                                showSuggestions = !searchVM.tagSuggestions.isEmpty
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
            
            if showSuggestions {
                TagSuggestionsView(tagSuggestions: searchVM.tagSuggestions, onSuggestionTap: { tag in
                    selectTag(tag)
                    showSuggestions = false
                })
            }

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 8) {
                    ForEach(enteredTags, id: \.self) { tag in
                        TagView(tag: tag, onRemove: removeTag)
                    }
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
            }
            

        }
     }
    
    func addTag() {
        let trimmedText = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        if !trimmedText.isEmpty && !enteredTags.contains(trimmedText) {
            enteredTags.append(trimmedText)
        }
        searchText = ""
    }
    
    func removeTag(_ tag: String) {
        enteredTags.removeAll { $0 == tag }
    }
    
    func selectTag(_ tag: String) {
        searchText = tag
    }
}


struct TagView: View {
    let tag: String
    let onRemove: (String) -> Void
    
    var body: some View {
        HStack {
            Text(tag)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            
            Button(action: {
                onRemove(tag)
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.blue)
                    .padding(.leading, 4)
            }
        }
    }
}

struct TagSuggestionsView: View {
    let tagSuggestions: [Tag]
    let onSuggestionTap: (String) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(tagSuggestions) { tag in
                    Button(action: {
                        onSuggestionTap(tag.id)
                    }) {
                        Text(tag.id)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                    }
                    .foregroundColor(.primary)
                    .background(Color.secondary.opacity(0.1))
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color.secondary.colorInvert())
            .cornerRadius(8)
            .padding(.horizontal)
        }
    }
}





