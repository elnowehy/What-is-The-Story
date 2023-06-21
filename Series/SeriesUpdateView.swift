//
//  CreateSeriesView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-01-19.
//
//  This view will allow creators to create anew series by providing the necessary information.
//
//  Access: Account -> CreateSeriesView


import SwiftUI
import AVFAudio
import PhotosUI

struct SeriesUpdateView: View {
    @ObservedObject var seriesVM: SeriesVM
    @EnvironmentObject var profileVM: ProfileVM
    @EnvironmentObject var theme: Theme
    @StateObject var categoryVM = CategoryVM()
    @State private var posterPicker: PhotosPickerItem?
    @State private var trailerPicker: PhotosPickerItem?
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategories: Set<String>
    @StateObject var episodeVM = EpisodeVM()
    private var initCategories = [String]()
    @State var tagText = ""
    @State var enteredTags = [String]()
    @StateObject var searchVM = SearchVM()
    @StateObject var tagVM = TagVM()
    @State private var isSaving: Bool = false
    
    init(seriesVM: SeriesVM) {
        self.seriesVM = seriesVM
        _selectedCategories = State(initialValue: seriesVM.series.categories)
    }
    
    
    var body: some View {
        ZStack {
            VStack {
                TextField("Title", text: $seriesVM.series.title)
                    .padding(.top, 20)
                    .font(theme.typography.text)
                    .textFieldStyle(TextFieldBaseStyle(theme: theme))
                    .padding(.horizontal)
                
                TextEditor(text: $seriesVM.series.synopsis)
                    .frame(minHeight: 100)
                    .padding(.horizontal)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding(.bottom)
                    .textFieldStyle(TextFieldBaseStyle(theme: theme))
                
                CategorySelectionView(selectedCategories: $selectedCategories).environmentObject(categoryVM)
                
                TagSearchBarView(searchText: $tagText, enteredTags: $enteredTags)
                    .environmentObject(searchVM)
                
                Divider()
                    .padding(.horizontal)
                
                HStack {
                    Spacer()
                    
                    PhotosPicker(selection: $posterPicker, matching: .images) {
                        Label("Select Poster", systemImage: "photo")
                            .font(theme.typography.body)
                            .padding(.vertical)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    PhotosPicker(selection: $trailerPicker, matching: .videos) {
                        Label("Select Trailer", systemImage: "film")
                            .font(theme.typography.body)
                            .padding(.vertical)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                
                HStack {
                    Spacer()
                    Button("Save") {
                        SaveSeries()
                    }
                    .buttonStyle(ButtonBaseStyle(theme: theme))
                    
                    Spacer()
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(ButtonBaseStyle(theme: theme))
                    Spacer()
                }
                
            }
            .background(theme.colors.primaryBackground)
            .task {
                episodeVM.episode.series = seriesVM.series.id
                selectedCategories = seriesVM.series.categories
                if !seriesVM.series.episodes.isEmpty {
                    episodeVM.episodeIds = seriesVM.series.episodes
                    await episodeVM.fetch()
                }
                if !seriesVM.series.tags.isEmpty {
                    for tag in seriesVM.series.tags {
                        tagVM.tagList.append(Tag(id: tag))
                        enteredTags.append(tag)
                    }
                }
            }
            
            if isSaving {
                SavingProgressView()
            }
            
        }
        .onChange(of: isSaving) { newValue in
            if !newValue {
                dismiss()
            }
        }
    }
    
    @MainActor
    private func SaveSeries() {
        Task {
            isSaving = true
            let oldCategories = Set(seriesVM.series.categories)
            let oldTags = Set(seriesVM.series.tags)
            seriesVM.series.categories = selectedCategories
            seriesVM.series.tags = Set(enteredTags)
            await updatePoster()
            await updateTrailer()
            await updateSeries()
            updateCategories(oldCategories: oldCategories)
            updateTags(oldTags: oldTags)
            isSaving = false
        }
    }
    
    private func updatePoster() async {
        guard let picker = posterPicker else { return }
        seriesVM.updatePoster = true
        
        do {
            if let data = try await picker.loadTransferable(type: Data.self) {
                if let uiImage = UIImage(data: data) {
                    seriesVM.posterImage = uiImage
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func updateTrailer() async {
        guard let picker = trailerPicker else { return }
        seriesVM.updateTrailer = true
        
        do {
            if let data = try await picker.loadTransferable(type: Data.self) {
                seriesVM.trailerData = data
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func updateCategories(oldCategories: Set<String>) {
        let added = selectedCategories.subtracting(oldCategories)
        let addedCategoryIDs = Array(added)
        let addedCategories: [Category] = addedCategoryIDs.map { Category(id: $0) }
        
        let removed = oldCategories.subtracting(selectedCategories)
        let removedCategoryIDs = Array(removed)
        let removedCategories: [Category] = removedCategoryIDs.map { Category(id: $0) }

        
        if !addedCategories.isEmpty {
            categoryVM.addContents(categories: addedCategories, id: seriesVM.series.id, type: .series)
        }
        
        if !removedCategories.isEmpty {
            categoryVM.removeContents(categories: removedCategories, id: seriesVM.series.id, type: .series)
        }
    }
    
    private func updateTags(oldTags: Set<String>) {
        let selectedTags = Set(enteredTags)
        let added = selectedTags.subtracting(oldTags)
        let addedTagIDs = Array(added)
        let addedTags: [Tag] = addedTagIDs.map { Tag(id: $0) }
        
        let removed = oldTags.subtracting(selectedTags)
        let removedTagIDs = Array(removed)
        let removedTags: [Tag] = removedTagIDs.map { Tag(id: $0) }
        
        if !addedTags.isEmpty {
            tagVM.addContents(tags: addedTags, id: seriesVM.series.id, type: .series)
        }
        
        if !removedTags.isEmpty {
            tagVM.removeContents(tags: removedTags, id: seriesVM.series.id, type: .series)
        }
    }
    
    private func updateSeries() async {
        if seriesVM.series.id.isEmpty {
            seriesVM.series.profile = profileVM.profile.id
            seriesVM.series.userId = profileVM.profile.userId
            let seriesId = await seriesVM.create()
            await profileVM.addSeries(seriesId: seriesId)
        } else {
            await seriesVM.update()
        }
    }
    
}



//struct SeriesUPdate_Previews: PreviewProvider {
//    static var previews: some View {
//        SeriesUpdate()
//    }
//}
