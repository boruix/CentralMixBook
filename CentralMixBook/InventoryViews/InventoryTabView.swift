//
//  InventoryTabView.swift
//  CentralMixBook
//
//

import SwiftUI

struct InventoryTabView: View {
    @EnvironmentObject var inventory: Inventory
    @EnvironmentObject var userSettings: UserSettings
    
    @State private var showingAdd = false
    private let generator = UIImpactFeedbackGenerator(style: .light)

    var filteredInventory: [Ingredient] {
        if userSettings.hideOutOfStock {
            return inventory.ingredients.filter { $0.stock }
        } else {
            return inventory.ingredients
        }
    }
    
    var baseInventory: [Ingredient] {
        return filteredInventory.filter { $0.type == "base" }
    }
    
    var modifierInventory: [Ingredient] {
        return filteredInventory.filter { $0.type == "modifier" }
    }
    
    var body: some View {
        NavigationView {
            Form {
                if baseInventory.count > 0 {
                    
                    Section(header: HeaderView(text: "Base Spirits", fontType: .subheadline, imageScale: .large, collapseSection: $userSettings.collapseBases)) {
                        
                        if !userSettings.collapseBases {
                            
                            ForEach(IngredientType.base.subtypes, id: \.self) { base in
                                InventoryTypeView(text: base.capitalized, typeInventory: baseInventory.filter { $0.subtype == base }, fontType: .body, imageScale: .small)
                            }
                        }
                    }
                }
                
                if modifierInventory.count > 0 {
                    
                    Section(header: HeaderView(text: "Modifiers", fontType: .subheadline, imageScale: .large, collapseSection: $userSettings.collapseModifiers)) {
                        
                        if !userSettings.collapseModifiers {
                            
                            ForEach(IngredientType.modifier.subtypes, id: \.self) { modifier in
                                InventoryTypeView(text: modifier.capitalized, typeInventory: modifierInventory.filter { $0.subtype == modifier}, fontType: .body, imageScale: .small)
                            }
                        }
                    }
                }
                
                InventoryTypeView(text: "Bitters", typeInventory: filteredInventory.filter { $0.type == "bitters" })
                
                InventoryTypeView(text: "Sweeteners",  typeInventory: filteredInventory.filter { $0.type == "sweetener" })
                
                InventoryTypeView(text: "Juices", typeInventory: filteredInventory.filter { $0.type == "juice" })
                
                InventoryTypeView(text: "Toppers", typeInventory: filteredInventory.filter { $0.type == "topper" })
                
                InventoryTypeView(text: "Other", typeInventory: filteredInventory.filter { $0.type == "other" })
            }
            .navigationBarTitle("Inventory")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {
                        // show or hide out-of-stock ingredients
                        withAnimation { userSettings.hideOutOfStock.toggle() }
                        generator.impactOccurred()      // needs to come after
                    }) {
                        Image(systemName: userSettings.hideOutOfStock ? "line.horizontal.3.decrease.circle.fill" : "line.horizontal.3.decrease.circle")
                    }
                }
                
                ToolbarItem(placement: .bottomBar) { Spacer() }
                
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {
                        // add new ingredient to ingredients arrary in Inventory
                        showingAdd = true
                        generator.impactOccurred()
                    }) { Image(systemName: "plus") }
                }
            }
            // prevents toolbar from disappearing when navigating
            .onAppear() { inventory.objectWillChange.send() }
            .sheet(isPresented: $showingAdd) {
                AddIngredientToInventoryView(ingredient: Ingredient(), showingAdd: $showingAdd)
            }
        }
    }
}
