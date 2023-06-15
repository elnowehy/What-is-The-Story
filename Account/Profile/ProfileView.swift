//
//  ProfileView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-16.
//
// this view has the profile info and option to edit the view

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var profileVM: ProfileVM
    @EnvironmentObject var userVM: UserVM
    @EnvironmentObject var theme: Theme
    @State private var isPresentingProfileEdit = false
    
    var body: some View {
        ZStack {
            AsyncImage(url: profileVM.info.background, content: { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }) {
                ProgressView()
            }


            NavigationStack {
                VStack(alignment: .leading) {
                    Spacer().frame(height: theme.dimensions.cardHieght)
                    
                    HStack(alignment: .center) {
                        AsyncImage(url: profileVM.profile.avatar, content: { image in
                            image
                                .resizable()
                                .thumbStyle(theme: theme)
                        }) {
                            ProgressView()
                        }

                        Text(profileVM.profile.tagline)
                            .modifier(TextBaseStyle(theme: theme))

                    }
                    .background(theme.colors.accent.opacity(0.5))
                    
                    ScrollView {
                        HStack {
                            Text(profileVM.info.bio)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding()
                                .background(theme.colors.accent.opacity(0.5))
                                .frame(maxWidth: 150)
                                .cornerRadius(theme.shapes.largeCornerRadius)
                            
                            AsyncImage(url: profileVM.info.photo, content: { image in
                                image
                                    .resizable()
                                    .photoStyle(theme: theme)
                            }) {
                                ProgressView()
                            }
                            .padding(theme.spacing.medium)
                        }
                    }

                }
                .foregroundColor(theme.colors.text)
                .navigationBarTitle(profileVM.profile.brand)
                
                .navigationBarItems(
                    trailing: profileVM.profile.userId == userVM.user.id ? AnyView(
                        Button(action: {
                            self.isPresentingProfileEdit = true
                        }) {
                            Text("Edit")
                        }
                    ) : AnyView(EmptyView())
                )
                
            }
            .sheet(isPresented: $isPresentingProfileEdit) {
                ProfileUpdate(presentationMode: $isPresentingProfileEdit)
            }
            .onAppear{
                Task {
                    await profileVM.fetch()
                    await profileVM.fetchInfo()
                }
            }
        }
    }
}



struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
