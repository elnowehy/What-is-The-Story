//
//  AccountTabView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-13.
//
// this view has a ProfileView at the top and other user options/menu at the bottom

import SwiftUI

struct AccountMenu: View {
    let columns = [ GridItem(.adaptive(minimum: 100)) ]
    @EnvironmentObject var authManager: AuthManager
    

    
    var body: some View {
        VStack {
            ProfileView()
            Spacer()
            NavigationStack {
                VStack(alignment: .leading) {
                    LazyVGrid(columns: columns, spacing: 16) {
                        NavigationLink(destination: ProfileView()) {
                            VStack(spacing: 8) {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 25))
                                
                                Text("Profile")
                                    .font(.system(size: 14))
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        NavigationLink(destination: CreateView()) {
                            VStack(spacing: 8) {
                                Image(systemName: "pencil.and.outline")
                                    .font(.system(size: 25))
                                
                                Text("Create")
                                    .font(.system(size: 14))
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        NavigationLink(destination: EarningsView()) {
                            VStack(spacing: 8) {
                                Image(systemName: "chart.bar.xaxis")
                                    .font(.system(size: 25))
                                
                                Text("Earnings")
                                    .font(.system(size: 14))
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        NavigationLink(destination: SettingsView()) {
                            VStack(spacing: 8) {
                                Image(systemName: "gearshape")
                                    .font(.system(size: 25))
                                
                                Text("Settings")
                                    .font(.system(size: 14))
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .navigationTitle("Account")
                // .navigationBarTitleDisplayMode(.inline)
            }
            
        }
    }
}

/*
 struct AccountTabView_Previews: PreviewProvider {
 static var previews: some View {
 AccountTabView()
 }
 }
 */
