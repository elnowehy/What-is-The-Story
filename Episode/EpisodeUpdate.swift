//
//  CreateViodeoView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-01-19.
//
//  This view will allow creators to create a new video by providing the necessary information.

import SwiftUI
import PhotosUI

struct EpisodeUpdate: View {
    @ObservedObject var episodeVM: EpisodeVM
    var mode: Mode
    @EnvironmentObject var seriesVM: SeriesVM
    @State private var videoPicker: PhotosPickerItem?
    @Environment(\.dismiss) private var dismiss
    @State private var isSaving: Bool = false
    @StateObject var pollVM = PollVM()
    @State private var rewardPerViews: Int = 0
    @State private var rewardExpiryDate: Date = Date()
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                TextField("Title", text: $episodeVM.episode.title)
                    .padding(.top, 20)
                Toggle("Open for Vote?", isOn: $episodeVM.episode.hasPoll)
                if episodeVM.episode.hasPoll  {
                    PollUpdateView(pollVM: pollVM)
                }
                TextEditor(text: $episodeVM.episode.synopsis)
                
                Divider()
                
                TextField("Reward Per Views", value: $rewardPerViews, format: .number)
                    .keyboardType(.numberPad)
                    .padding()
                
                DatePicker("Reward Expiry Date", selection: $rewardExpiryDate, displayedComponents: .date)
                    .padding()
                
                Divider()
                
                PhotosPicker(selection: $videoPicker, matching: .videos) {
                    Label("Upload the Episode", systemImage: "film")
                }
                
                Spacer()
                HStack {
                    Spacer()
                    Button("Save") {
                        SaveEpisode()
                    }
                    Spacer()
                    Button("Cancel") {
                        dismiss()
                    }
                    Spacer()
                }
                Spacer()
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Invalid Input"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .navigationBarBackButtonHidden()
            .onAppear{
                if mode == .add {
                    let seriesId = episodeVM.episode.series
                    episodeVM.episode = Episode()
                    episodeVM.episode.series = seriesId
                }
                
                if episodeVM.episode.hasPoll {
                    Task {
                        let userTokenBalanceVM = UserTokenBalanceVM()
                        userTokenBalanceVM.userTokenBalance.userId = episodeVM.episode.userId
                        await userTokenBalanceVM.fetch()
                        pollVM.poll.id = episodeVM.episode.id
                        pollVM.setUserTokenBalanceVM(userTokenBalanceVM)
                        await pollVM.fetch()
                    }
                }
                
                if mode == .update {
                    rewardPerViews = episodeVM.episode.rewardPerViews
                    rewardExpiryDate = episodeVM.episode.rewardExpiryDate
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
    
    private func SaveEpisode() {
        Task {
            isSaving = true
            seriesVM.series.id = episodeVM.episode.series
            if videoPicker != nil {
                episodeVM.updateVideo = true
                do {
                    if let data = try await videoPicker?.loadTransferable(type: Data.self) {
                        episodeVM.videoData = data
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
            
            episodeVM.episode.rewardPerViews = rewardPerViews
            episodeVM.episode.rewardExpiryDate = rewardExpiryDate
            
            if episodeVM.episode.id.isEmpty {
                episodeVM.episode.series = seriesVM.series.id
                episodeVM.episode.userId = seriesVM.series.userId
                let id = await episodeVM.create()
                await seriesVM.addEpisode(episodeId: id)
            } else {
                await episodeVM.update()
            }
            
            if episodeVM.episode.hasPoll {
                pollVM.poll.id = episodeVM.episode.id
                pollVM.update()
            }
            isSaving = false
        }
    }
    
    private func validateInput() -> Bool {
        // Validate rewardPerViews
        if rewardPerViews <= 0 {
            alertMessage = "Reward per views must be a positive number."
            return false
        }

        // Validate rewardExpiryDate
        if rewardExpiryDate <= Date() {
            alertMessage = "Reward expiry date must be in the future."
            return false
        }

        return true
    }
}

