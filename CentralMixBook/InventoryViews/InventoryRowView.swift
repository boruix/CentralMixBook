//
//  InventoryRowView.swift
//  CentralMixBook
//
//

import SwiftUI

struct InventoryRowView: View {
    @EnvironmentObject var inventory: Inventory
    
    @ObservedObject var ingredient: Ingredient
    let sort: String
    
    private let generator = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        NavigationLink(destination: IngredientDetailedView(ingredient: ingredient)) {
            HStack {
                StockButton(ingredient: ingredient)
                
                VStack(alignment: .leading) {
                    HStack {
                        Text(ingredient.name)
                        Spacer()
                        if ingredient.restock { Image(systemName: "bag") }
                    }
                    
                    if !ingredient.supplier.isEmpty && !ingredient.price.isEmpty {
                        HStack {
                            Text(sort == "supplier" ? ingredient.type : ingredient.supplier)
                                .fontWeight(.light)
                            
                            Spacer()
                            Text(ingredient.price).fontWeight(.light)
                        }
                        .font(.callout)
                        .foregroundColor(.secondary)
                    }
                }
                .lineLimit(1)
            }
            // makes stock button responsive
            .buttonStyle(BorderlessButtonStyle())
            .contextMenu { RestockButton(ingredient: ingredient) }
        }
    }
}
