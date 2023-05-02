//
//  LandingPageView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-04-26.
//
import SwiftUI

struct LandingPageView: View {
    @StateObject private var landingPageVM = LandingPageVM()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Category selection
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(landingPageVM.categories) { category in
                            Button(action: {
                                landingPageVM.selectCategory(category)
                            }) {
                                Text(category.name)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(landingPageVM.selectedCategory == category ? Color.blue : Color.clear)
                                    .foregroundColor(landingPageVM.selectedCategory == category ? Color.white : Color.primary)
                                    .cornerRadius(4)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Featured series
                Text("Featured Series")
                    .font(.title)
                    .padding(.horizontal)
                SeriesListView(seriesList: $landingPageVM.featuredSeries, landingPageVM: landingPageVM, listType: .featured)

                // Popular series
                Text("Popular Series")
                    .font(.title)
                    .padding(.horizontal)
                SeriesListView(seriesList: $landingPageVM.popularSeries, landingPageVM: landingPageVM, listType: .popular)

                // New series
                Text("New Series")
                    .font(.title)
                    .padding(.horizontal)
                SeriesListView(seriesList: $landingPageVM.newSeries, landingPageVM: landingPageVM, listType: .new)

                // Trending series
                Text("Trending Series")
                    .font(.title)
                    .padding(.horizontal)
                SeriesListView(seriesList: $landingPageVM.trendingSeries, landingPageVM: landingPageVM, listType: .trending)
            }
        }
    }
}

struct SeriesListView: View {
    @Binding var seriesList: [Series]
    @ObservedObject var landingPageVM: LandingPageVM
    let listType: LandingPageVM.SeriesListType

    @State private var lastDisplayedSeries: Series?

    var body: some View {
        LazyVStack(spacing: 16) {
            ForEach(seriesList) { series in
                SeriesRow(series: series)
                    .onAppear {
                        lastDisplayedSeries = series
                    }
            }
        }
        .onChange(of: lastDisplayedSeries) { lastSeries in
            if lastSeries == seriesList.last && landingPageVM.hasMoreData {
                Task {
                    await landingPageVM.loadMoreSeries(for: listType)
                }
            }
        }
        .padding(.horizontal)
    }
}






struct SeriesRow: View {
    let series: Series

    var body: some View {
        HStack {
            // Series image
            Image("placeholder")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 120)
                .cornerRadius(4)
            
            // Series details
            VStack(alignment: .leading, spacing: 8) {
                Text(series.title)
                    .font(.headline)
                Text(series.synopsis)
                    .font(.subheadline)
                    .lineLimit(2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct LandingPageView_Previews: PreviewProvider {
    static var previews: some View {
        LandingPageView()
    }
}

