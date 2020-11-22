//
//  SpecDetailedView.swift
//  CentralMixBook
//
//

import SwiftUI

struct SpecDetailedView: View {
    @EnvironmentObject var inventory: Inventory
    
    @ObservedObject var spec: Spec
    
    var missingIngredient = Ingredient()
    @State private var showingAdd = false
    @State private var showingEdit = false
    private let generator = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        Form {
            // MARK: name, bar, location, type
            Section(header: Text("Drink Information").fontWeight(.bold)) {
                Text(spec.name).fontWeight(.heavy)
            
                if !spec.barName.isEmpty {
                    Label(spec.barName, systemImage: "house")
                }
                
                if !spec.barLocation.isEmpty {
                    Label(spec.barLocation, systemImage: "mappin.and.ellipse")
                }
                
                Label(spec.type.capitalized, systemImage: "tag")
            }
            .foregroundColor(.primary)
            
            // MARK: ingredients
            Section(header: Text("Ingredients").fontWeight(.bold)) {
                ForEach(spec.ingredients.indices, id: \.self) { i in
                    if let foundIngredient = inventory.getIngredientFromName(spec.ingredients[i].name) {
                        // specification ingredient found in inventory
                        NavigationLink(destination: IngredientDetailedView(ingredient: foundIngredient)) {
                            HStack{
                                // toggles .stock for an ingredient
                                Button(action: {
                                    inventory.toggleStock(foundIngredient)
                                    generator.impactOccurred()
                                }) {
                                    Image(systemName: foundIngredient.stock ? "checkmark.circle.fill" : "circle")
                                }
                                
                                Text(spec.ingredients[i].amount)
                                    .font(.callout)
                                    .fontWeight(.semibold)
                                + Text(spec.ingredients[i].amount.isEmpty ? "" : " ")
                                + Text(spec.ingredients[i].name)
                                
                                Spacer()
                                
                                if foundIngredient.restock {
                                    Image(systemName: "bag")
                                }
                            }
                            // makes stock button responsive
                            .buttonStyle(BorderlessButtonStyle())
                            .contextMenu {
                                // toggles .restock for an ingredient
                                Button(action: {
                                    withAnimation { inventory.toggleRestock(foundIngredient) }
                                }) {
                                    HStack {
                                        if foundIngredient.restock {
                                            Text("Remove from restock list")
                                            Image(systemName: "bag.badge.minus")
                                        } else {
                                            Text("Add to restock list")
                                            Image(systemName: "bag.badge.plus")
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        // specification ingredient not found in inventory
                        Button(action: {
                            // add missing ingredient to inventory
                            missingIngredient.name = spec.ingredients[i].name
                            showingAdd = true
                            generator.impactOccurred()
                        }) {
                            HStack{
                                Image(systemName: "xmark.circle")
                                    .foregroundColor(.secondary)

                                Text(spec.ingredients[i].amount + " ")
                                    .font(.callout)
                                    .fontWeight(.semibold)
                                + Text(spec.ingredients[i].name)
                            }
                            .foregroundColor(.primary)
                        }
                        .sheet(isPresented: $showingAdd) {
                            AddIngredientToInventoryView(ingredient: missingIngredient, showingAdd: $showingAdd)
                        }
                    }
                }
                
                // MARK: garnish
                Text("GARNISH: ")
                    .font(.caption)
                    .fontWeight(.bold)
                + Text(spec.garnish.isEmpty ? "None" : spec.garnish)
                
                HStack {
                    // MARK: glassware
                    Text("GLASS: ")
                        .font(.caption)
                        .fontWeight(.bold)
                        + Text(spec.glassware.isEmpty ? "None" : spec.glassware.capitalized)
                    
                    Spacer()
                    
                    // MARK: ice
                    Text("ICE: ")
                        .font(.caption)
                        .fontWeight(.bold)
                    + Text(spec.ice.isEmpty ? "None" : spec.ice)
                }
            }
            
            // MARK: directions
            Section(header: Text("Directions").fontWeight(.bold)) {
                ForEach(spec.directions.indices, id: \.self) { i in
                    Label(spec.directions[i], systemImage: "\(i + 1).circle")
                        .foregroundColor(.primary)
                }
            }
            
            // MARK: editor's notes
            if !spec.editorsNotes.isEmpty {
                Section(header: Text("Editor's Notes").fontWeight(.bold)) {
                    Text(spec.editorsNotes)
                }
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(trailing: EditButton(showingSheet: $showingEdit))
        .sheet(isPresented: $showingEdit) {
            EditExistingSpecView(spec: spec, showingEdit: $showingEdit)
        }
    }
}
