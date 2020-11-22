//
//  InventoryTabView.swift
//  CentralMixBook
//
//

import SwiftUI

// MARK: InventoryTabView
struct InventoryTabView: View {
    @EnvironmentObject var inventory: Inventory
    @EnvironmentObject var userSettings: UserSettings
    
    @ObservedObject var searchBar = SearchBar()
    @State private var showingAdd = false

    // inventory filtered by search bar and show / hide out-of-stock button
    private var filteredInventory: [Ingredient] {
        if searchBar.text.isEmpty {
            return inventory.ingredients.filter { $0.stock || !userSettings.hideOutOfStock }
        } else {
            return inventory.ingredients.filter { $0.name.localizedStandardContains(searchBar.text) }
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                if filteredInventory.isEmpty {
                    // MARK: if no ingredients showing
                    Text(userSettings.hideOutOfStock
                            ? "No ingredients in stock"
                            : "No ingredients added")
                } else {
                    // MARK: if sort by type
                    switch userSettings.inventorySort {
                    case "Type":
                        InventorySuperSectionView(
                            superSectionName: "Base Spirits",
                            subSectionTypes: IngredientType.base.subtypes,
                            subInventory: filteredInventory.filter { $0.type == "Base" }
                        )
                        
                        InventorySuperSectionView(
                            superSectionName: "Modifiers",
                            subSectionTypes: IngredientType.modifier.subtypes,
                            subInventory: filteredInventory.filter { $0.type == "Modifier" }
                        )
                        
                        ForEach(["Bitters", "Sweetener", "Juice", "Topper", "Other"], id: \.self) { ingredientType in
                            InventorySectionView(
                                sectionName: ingredientType + (["Bitters", "Other"].contains(ingredientType) ? "" : "s"),
                                inventorySection: filteredInventory.filter { $0.type == ingredientType }
                            )
                        }
                        
                    // MARK: if sort by supplier
                    case "Supplier":
                        ForEach(inventory.suppliers, id: \.self) { supplier in
                            InventorySectionView(
                                sectionName: supplier,
                                inventorySection: filteredInventory.filter { $0.supplier == supplier }
                            )
                        }
                        
                        InventorySectionView(
                            sectionName: "No supplier listed",
                            inventorySection: filteredInventory.filter { $0.supplier.isEmpty }
                        )
                        
                    // MARK: if sort by price
                    case "Price":
                        let pricedInventory = filteredInventory.filter { !$0.price.isEmpty }
                        
                        InventorySectionView(
                            sectionName: "$10 or under",
                            inventorySection: pricedInventory.filter { Int($0.price)! <= 10 }
                        )
                        
                        InventorySectionView(
                            sectionName: "Over $10, up to $20",
                            inventorySection: pricedInventory.filter { (11...20).contains(Int($0.price)!) }
                        )
                        
                        InventorySectionView(
                            sectionName: "Over $20, up to $25",
                            inventorySection: pricedInventory.filter { (21...25).contains(Int($0.price)!) }
                        )
                        
                        InventorySectionView(
                            sectionName: "Over $25, up to $30",
                            inventorySection: pricedInventory.filter { (26...30).contains(Int($0.price)!) }
                        )
                        
                        InventorySectionView(
                            sectionName: "Over $30, up to $40",
                            inventorySection: pricedInventory.filter { (31...40).contains(Int($0.price)!) }
                        )
                        
                        InventorySectionView(
                            sectionName: "Over $40",
                            inventorySection: pricedInventory.filter { Int($0.price)! > 40 }
                        )
                        
                        InventorySectionView(
                            sectionName: "No price listed",
                            inventorySection: filteredInventory.filter { $0.price.isEmpty }
                        )
                    default:
                        EmptyView()
                    }
                }
            }
            .navigationBarTitle("Inventory")
            .add(searchBar)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    // MARK: toggle show oos
                    ShowHideButton(setting: $userSettings.hideOutOfStock)
                }
                
                ToolbarItem(placement: .bottomBar) { Spacer() }
                
                ToolbarItem(placement: .bottomBar) {
                    // MARK: sort inventory menu
                    SortByMenu(
                        sortBy: $userSettings.inventorySort,
                        options: UserSettings.InventorySortBy.allCases.map { $0.id }
                    )
                }
                
                ToolbarItem(placement: .bottomBar) { Spacer() }
                
                ToolbarItem(placement: .bottomBar) {
                    // MARK: add ingredient button
                    AddButton(showingAdd: $showingAdd)
                }
            }
            // prevents toolbar from disappearing when navigating
            .onAppear() { inventory.objectWillChange.send() }
            .sheet(isPresented: $showingAdd) {
                AddIngredientToInventoryView(
                    ingredient: Ingredient(),
                    showingAdd: $showingAdd
                )
            }
        }
    }
}

// MARK: InventorySuperSectionView
private struct InventorySuperSectionView: View {
    let superSectionName: String
    let subSectionTypes: [String]
    let subInventory: [Ingredient]
    
    @State private var collapsed = false
    
    var body: some View {
        if !subInventory.isEmpty {
            Section(
                header: HeaderView(text: superSectionName,
                                   fontType: .subheadline,
                                   imageScale: .large,
                                   collapseSection: $collapsed),
                footer: Text("Count: \(subInventory.count)")
            ) {
                if !collapsed {
                    ForEach(subSectionTypes, id: \.self) { type in
                        InventorySectionView(
                            sectionName: type,
                            inventorySection: subInventory.filter { $0.subtype == type },
                            fontType: .body,
                            imageScale: .small,
                            footerCount: false
                        )
                    }
                }
            }
        }
    }
}
