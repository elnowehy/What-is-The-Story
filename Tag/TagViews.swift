//
//  TagViews.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-06-05.
//

import SwiftUI

struct TagSearchBarView: View {
    @Binding var searchText: String
    @Binding var enteredTags: [String]
    @EnvironmentObject var searchVM: SearchVM
    @State private var showSuggestions = false
    @EnvironmentObject var theme: Theme

    var body: some View {
        VStack(alignment: .leading) {
            TextField("Search", text: $searchText, onCommit: { addTag() })
                .textFieldStyle(TextFieldBaseStyle(theme: theme, maxWidth: 100))
                .onChange(of: searchText) { newValue in
                    if newValue.last == " " {
                        addTag()
                    } else {
                        Task {
                            do {
                                _ = try await searchVM.fetchTagSuggestions(tagPrefix: newValue)
                                showSuggestions = !searchVM.tagSuggestions.isEmpty
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if showSuggestions {
                TagSuggestionsView(tagSuggestions: searchVM.tagSuggestions, onSuggestionTap: { tag in
                    selectTag(tag)
                }, showSuggestions: $showSuggestions)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 8) {
                    ForEach(enteredTags, id: \.self) { tag in
                        TagView(tag: tag, onRemove: removeTag)
                    }
                }
                // .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(minHeight: 0, maxHeight: .infinity, alignment: .top)
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
    @EnvironmentObject var theme: Theme
    
    var body: some View {
        HStack {
            Text(tag)
                .modifier(TagTextBaseStyle(theme: theme))
            
            Button(action: {
                onRemove(tag)
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(theme.colors.text)
                    .padding(.leading, 0)
            }
            .buttonStyle(ButtonBaseStyle(theme: theme))
        }
    }
}

struct TagSuggestionsView: View {
    let tagSuggestions: [Tag]
    let onSuggestionTap: (String) -> Void
    @Binding var showSuggestions: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(tagSuggestions) { tag in
                    Button(action: {
                        onSuggestionTap(tag.id)
                        showSuggestions = false
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

