//
//  FaQView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-05-11.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About Our App")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    Text("Our Mission")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Our mission is to provide an interactive and engaging platform for viewers to enjoy and discuss their favorite shows. We aim to create a community where fans can come together, share their thoughts, and enrich their viewing experience.")
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Our Team")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Our team consists of passionate developers, designers, and content creators who are dedicated to making this platform the best it can be. We love TV shows just as much as you do and we're always working hard to improve and expand our app.")
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Add more sections as needed...
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
            .navigationTitle("About Us")
        }
    }
}


struct AboutVieww_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
