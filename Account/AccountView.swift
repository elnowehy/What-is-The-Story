//
//  AccountTabView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-13.
//

import SwiftUI

struct AccountView: View {
    let columns = [        GridItem(.adaptive(minimum: 120))    ]
    
    var body: some View {
        VStack {
            NavigationStack {
                ProfileView()
                Spacer()
                
                VStack(alignment: .leading) {
                    LazyVGrid(columns: columns, spacing: 16) {
                        NavigationLink(destination: ProfileView()) {
                            VStack(spacing: 8) {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 32))
                                
                                Text("Profile")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        NavigationLink(destination: CreateView()) {
                            VStack(spacing: 8) {
                                Image(systemName: "pencil.and.outline")
                                    .font(.system(size: 32))
                                
                                Text("Create")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        NavigationLink(destination: EarningsView()) {
                            VStack(spacing: 8) {
                                Image(systemName: "chart.bar.xaxis")
                                    .font(.system(size: 32))
                                
                                Text("Earnings")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        NavigationLink(destination: SettingsView()) {
                            VStack(spacing: 8) {
                                Image(systemName: "gearshape")
                                    .font(.system(size: 32))
                                
                                Text("Settings")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                // .navigationTitle("Account")
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
