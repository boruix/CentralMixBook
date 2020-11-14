//
//  InventoryRowView.swift
//  CentralMixBook
//
//

import SwiftUI

struct InventoryRowView: View {
    @EnvironmentObject var inventory: Inventory
    
    @ObservedObject var ingredient: Ingredient
    
    private let generator = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        NavigationLink(destination: IngredientDetailedView(ingredient: ingredient)) {
            HStack {
                Button(action: {
                    // toggles .stock for an ingredient in inventory
                    inventory.toggleStock(ingredient.name)
                    generator.impactOccurred()
                }) {
                    Image(systemName: ingredient.stock ? "checkmark.circle.fill" : "circle")
                }
                
                Text(ingredient.name).font(.callout)
            }
            // makes stock button responsive
            .buttonStyle(BorderlessButtonStyle())
        }
    }
}
