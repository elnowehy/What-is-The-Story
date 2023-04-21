//
//  CategoryView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-04-19.
//

import SwiftUI

struct CategorySelectionView: View {
    @EnvironmentObject var categoryVM: CategoryVM
    @Binding var selectedCategories: Set<String>
    
    var body: some View {
        Menu {
            ForEach(categoryVM.categoryList) { category in
                Button(action: {
                    if selectedCategories.contains(category.name) {
                        selectedCategories.remove(category.name)
                    } else {
                        selectedCategories.insert(category.name)
                    }
                }) {
                    HStack {
                        Text(category.name)
                        Spacer()
                        if selectedCategories.contains(category.name) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        } label: {
            HStack {
                Text("Select Category")
                Spacer()
                Image(systemName: "chevron.down")
            }
            .padding()
            .foregroundColor(.primary)
            .overlay(
                RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1)
            )
        }
        .onAppear {
            categoryVM.fetch()
            print(categoryVM.categoryList.count)
        }
    }
}


//struct CategoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        CategorySelectionView(selectedCategories: <#Binding<Set<String>>#>)
//    }
//}
