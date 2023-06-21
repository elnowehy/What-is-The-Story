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
    @EnvironmentObject var theme: Theme
    
    var body: some View {
        Menu {
            ForEach(categoryVM.categoryList) { category in
                Button(action: {
                    if selectedCategories.contains(category.id) {
                        selectedCategories.remove(category.id)
                    } else {
                        selectedCategories.insert(category.id)
                    }
                }) {
                    HStack {
                        Text(category.id)
                        Spacer()
                        if selectedCategories.contains(category.id) {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .buttonStyle(ButtonBaseStyle(theme: theme))
            }
        } label: {
            HStack {
                Text("Select Category")
                Spacer()
                Image(systemName: "chevron.down")
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1)
            )
        }
        .task {
            await categoryVM.fetchCategories()
        }
    }
}


//struct CategoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        CategorySelectionView(selectedCategories: <#Binding<Set<String>>#>)
//    }
//}
