//
//  InventoryTypeView.swift
//  CentralMixBook
//
//

import SwiftUI

struct InventoryTypeView: View {
    @EnvironmentObject var inventory: Inventory

    let text: String
    let typeInventory: [Ingredient]
    var fontType: Font = .subheadline
    var imageScale: Image.Scale = .large
    
    @State private var collapseSection = false
    private let generator = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        if typeInventory.count > 0 {
            
            Section(header: HeaderView(text: text, fontType: fontType, imageScale: imageScale, collapseSection: $collapseSection)) {
                
                if !collapseSection {
                    ForEach(typeInventory) { ingredient in
                        InventoryRowView(ingredient: ingredient)
                    }
                    .onDelete(perform: deleteIngredient)
                }
            }
        }
    }
    
    private func deleteIngredient(at offsets: IndexSet) {
        offsets.forEach { offset in
            inventory.delete(typeInventory[offset])
        }
        generator.impactOccurred()
    }
}
