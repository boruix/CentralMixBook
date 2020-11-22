//
//  AddIngredientToSpecView.swift
//  CentralMixBook
//
//

import SwiftUI

struct AddIngredientToSpecView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var inventory: Inventory
    @ObservedObject var spec: Spec
    var index: Int
    
    @State private var searchInput = ""
    @State private var showingAddIngredientToInventory = false
    private let generator = UIImpactFeedbackGenerator(style: .light)
    
    // top 10 ingredient search results
    private var predictions: [String] {
        if !searchInput.isEmpty {
            // show ingredients that being with the search input first
            var predictions = inventory.ingredientNames.filter { $0.uppercased().hasPrefix(searchInput.uppercased()) }
            if predictions.count >= 10 {
                return Array(predictions[0 ..< 10])
            }
            
            // then show ingredients that contain the search input
            predictions += inventory.ingredientNames.filter { $0.localizedStandardContains(searchInput) && !predictions.contains($0) }
            if predictions.count >= 10 {
                return Array(predictions[0 ..< 10])
            } else {
                return predictions
            }
        } else {
            return []
        }
    }

    var body: some View {
        Form {
            // MARK: search bar
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search for ingredient",text: $searchInput)
            }
            
            // MARK: list of matched ingredients
            ForEach(predictions, id: \.self) { ingredientName in
                Button(action: {
                    // call the publisher for nested value changes to propagate
                    spec.objectWillChange.send()
                    
                    // add ingredient name to spec's list of ingredients
                    spec.ingredients[index].name = ingredientName
                    generator.impactOccurred()
                    presentationMode.wrappedValue.dismiss()
                }) { Text(ingredientName) }
            }
            
            // MARK: create ingredient button
            if !searchInput.isEmpty {
                Button(action: {
                    showingAddIngredientToInventory = true
                    generator.impactOccurred()
                }) {
                    Text("Create new ingredient").fontWeight(.semibold)
                }
            }
        }
        .navigationBarTitle("Ingredient Search")
        .sheet(isPresented: $showingAddIngredientToInventory) {
            AddIngredientToInventoryView(
                ingredient: Ingredient(),
                showingAdd: $showingAddIngredientToInventory
            )
        }
    }
}
