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
            Section(header: Text("Drink Information").fontWeight(.bold)) {
                // name
                Text(spec.name)
                    .font(.title3)
                    .fontWeight(.bold)
            
                // bar name
                if !spec.barName.isEmpty {
                    HStack {
                        Image(systemName: "house").frame(width: 30)
                        Text(spec.barName)
                    }
                }
                
                // bar city
                if !spec.barLocation.isEmpty {
                    HStack {
                        Image(systemName: "mappin.and.ellipse").frame(width: 30)
                        Text(spec.barLocation)
                    }
                }
                
                // cocktail type
                HStack {
                    Image(systemName: "tag").frame(width: 30)
                    Text(spec.type.capitalized)
                }
            }
            
            // list of ingredients
            Section(header: Text("Ingredients").fontWeight(.bold)) {
                ForEach(spec.ingredients.indices, id: \.self) { i in
                    if let j = inventory.ingredients.firstIndex(where: { $0.name == spec.ingredients[i].ingredient }) {
                        // specification ingredient found in inventory
                        NavigationLink(destination: IngredientDetailedView(ingredient: inventory.ingredients[j])) {
                            HStack{
                                // toggles .stock for an ingredient in inventory
                                Button(action: {
                                    inventory.toggleStock(spec.ingredients[i].ingredient)
                                    generator.impactOccurred()
                                }) {
                                    Image(systemName: inventory.ingredients[j].stock ? "checkmark.circle.fill" : "circle")
                                }
                                
                                Text(spec.ingredients[i].amount)
                                    .font(.callout)
                                    .fontWeight(.semibold)
                                + Text(spec.ingredients[i].amount.isEmpty ? "" : " ")
                                + Text(spec.ingredients[i].ingredient)
                            }
                            // makes stock button responsive
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    } else {
                        // specification ingredient not found in inventory
                        Button(action: {
                            // add missing ingredient to inventory
                            missingIngredient.name = spec.ingredients[i].ingredient
                            showingAdd = true
                            generator.impactOccurred()
                        }) {
                            HStack{
                                Image(systemName: "xmark.circle")
                                    .foregroundColor(.secondary)

                                Text(spec.ingredients[i].amount + " ")
                                    .font(.callout)
                                    .fontWeight(.semibold)
                                + Text(spec.ingredients[i].ingredient)
                            }
                            .foregroundColor(.primary)
                        }
                        .sheet(isPresented: $showingAdd) {
                            AddIngredientToInventoryView(ingredient: missingIngredient, showingAdd: $showingAdd)
                        }
                    }
                }
                
                // garnish
                Text("GARNISH: ")
                    .font(.caption)
                    .fontWeight(.bold)
                + Text(spec.garnish.isEmpty ? "None" : spec.garnish)
                
                HStack {
                    // glassware
                    Text("GLASS: ")
                        .font(.caption)
                        .fontWeight(.bold)
                        + Text(spec.glassware.isEmpty ? "None" : spec.glassware.capitalized)
                    
                    Spacer()
                    
                    // ice
                    Text("ICE: ")
                        .font(.caption)
                        .fontWeight(.bold)
                    + Text(spec.ice.isEmpty ? "None" : spec.ice)
                }
            }
            
            // list of directions
            Section(header: Text("Directions").fontWeight(.bold)) {
                ForEach(spec.directions.indices, id: \.self) { i in
                    HStack(alignment: .top) {
                        Image(systemName: "\(i + 1).circle")
                            .padding(.top, 2)
                        
                        Text(spec.directions[i])
                    }
                }
            }
            
            // editor's notes
            if !spec.editorsNotes.isEmpty {
                Section(header: Text("Editor's Notes").fontWeight(.bold)) {
                    Text(spec.editorsNotes)
                }
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            // show edit ingredient sheet
            showingEdit = true
            generator.impactOccurred()
        }) { Text("Edit") })
        .sheet(isPresented: $showingEdit) {
            EditExistingSpecView(spec: spec, showingEdit: $showingEdit)
        }
    }
}
