//
//  LandingPageView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-04-26.
//
import SwiftUI

struct LandingPageView: View {
    @StateObject private var landingPageVM = LandingPageVM()
    @EnvironmentObject var theme: Theme

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: theme.spacing.medium) {
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: theme.spacing.button) {
                        ForEach(landingPageVM.categories) { category in
                            Button(action: {
                                landingPageVM.selectCategory(category)
                            }) {
                                Text(category.id)
                            }
                            .buttonStyle(CategoryButtonStyle(theme: theme, isSelected: landingPageVM.selectedCategory == category))
                        }
                    }
                    .padding(.horizontal)
                }
                
                
                Text("Featured Episodes")
                    .modifier(LargeTitleStyle(theme: theme))
                SeriesListView(seriesList: $landingPageVM.featuredSeries, landingPageVM: landingPageVM, listType: AppSettings.SeriesListType.featured)
                
                
                Text("Popular Series")
                    .modifier(LargeTitleStyle(theme: theme))
                SeriesListView(seriesList: $landingPageVM.popularSeries, landingPageVM: landingPageVM, listType: AppSettings.SeriesListType.popular)
                
                Text("New Series")
                    .modifier(LargeTitleStyle(theme: theme))
                SeriesListView(seriesList: $landingPageVM.newSeries, landingPageVM: landingPageVM, listType: AppSettings.SeriesListType.new)
                
                // Trending series
                Text("Trending Series")
                    .modifier(LargeTitleStyle(theme: theme))
                SeriesListView(seriesList: $landingPageVM.trendingSeries, landingPageVM: landingPageVM, listType: AppSettings.SeriesListType.trending)
            }
        }
        .padding()
    }
}

struct SeriesListView: View {
    @Binding var seriesList: [Series]
    @ObservedObject var landingPageVM: LandingPageVM
    let listType: AppSettings.SeriesListType
    @EnvironmentObject var theme: Theme

    @State private var lastDisplayedSeries: Series?

    var body: some View {
        let uniqueSeriesList = seriesList.map { series in
            return (id: "\(series.id)_\(listType.hashValue)", series: series)
        }

        LazyHStack(spacing: theme.spacing.cardPadding) {
            ForEach(uniqueSeriesList, id: \.id) { item in
                SeriesRow(series: item.series, seriesVM: landingPageVM.seriesVM)
                    .onAppear {
                        lastDisplayedSeries = item.series
                    }
                   .modifier(NavigationLinkStyle(theme: theme))
            }
        }
        .onChange(of: lastDisplayedSeries) { lastSeries in
            var paginator =  landingPageVM.newPaginator
            var fetchSeries = landingPageVM.fetchNewSeries
            switch listType {
            case .featured:
                paginator = landingPageVM.featuredPaginator
                fetchSeries = landingPageVM.fetchFeaturedSeries
            case .new:
                paginator = landingPageVM.newPaginator
                fetchSeries = landingPageVM.fetchNewSeries
            case .popular:
                paginator = landingPageVM.popularPaginator
                fetchSeries = landingPageVM.fetchPopularSeries
            case .trending:
                paginator = landingPageVM.trendingPaginator
                fetchSeries = landingPageVM.fetchTrendingSeries
            }

            if paginator.hasMoreData &&
                !paginator.isLoading {
                ProgressView() // Show a loading indicator while loading more data
                    .task{ await fetchSeries() }
            }
        }
    }
    
}

struct LandingPageView_Previews: PreviewProvider {
    static var previews: some View {
        LandingPageView()
    }
}

