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
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
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
            
            if !searchVM.tagSuggestions.isEmpty {
                TagSuggestionsView(tagSuggestions: searchVM.tagSuggestions, onSuggestionTap: addTag)
            }
        }
     }
    
    func addTag() {
        let trimmedText = searchText.trimmingCharacters(in: .whitespaces)
        if !trimmedText.isEmpty && !enteredTags.contains(trimmedText) {
            enteredTags.append(trimmedText)
        }
        searchText = ""
    }
    
    func removeTag(_ tag: String) {
        enteredTags.removeAll { $0 == tag }
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
    let onSuggestionTap: () -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 8) {
                ForEach(tagSuggestions) { tag in
                    Button(action: {
                        onSuggestionTap()
                    }) {
                        Text(tag.id)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
        }
    }
}

