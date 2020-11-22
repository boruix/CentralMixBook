//
//  InventorySectionView.swift
//  CentralMixBook
//
//

import SwiftUI

struct InventorySectionView: View {
    @EnvironmentObject var inventory: Inventory
    @EnvironmentObject var userSettings: UserSettings

    let sectionName: String
    let inventorySection: [Ingredient]
    var fontType: Font = .subheadline
    var imageScale: Image.Scale = .large
    var footerCount: Bool = true
    
    @State var collapseSection = false
    private let generator = UIImpactFeedbackGenerator(style: .light)
    
    private var footerView: some View {
        if footerCount {
            return AnyView(Text("Count: \(inventorySection.count)"))
        } else {
            return AnyView(EmptyView())
        }
    }
    
    var body: some View {
        if inventorySection.count > 0 {
            Section(
                header:HeaderView(text: sectionName,
                                  fontType: fontType,
                                  imageScale: imageScale,
                                  collapseSection: $collapseSection),
                footer: footerView
            ) {
                if !collapseSection {
                    ForEach(inventorySection) { ingredient in
                        InventoryRowView(
                            ingredient: ingredient,
                            sort: userSettings.inventorySort
                        )
                    }
                    .onDelete(perform: deleteIngredient)
                }
            }
        }
    }
    
    private func deleteIngredient(at offsets: IndexSet) {
        offsets.forEach { offset in
            inventory.delete(inventorySection[offset])
        }
        generator.impactOccurred()
    }
}
