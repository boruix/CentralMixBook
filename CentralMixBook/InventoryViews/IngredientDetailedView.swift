//
//  IngredientDetailedView.swift
//  CentralMixBook
//
//

import SwiftUI

struct IngredientDetailedView: View {
    @EnvironmentObject var dex: Dex

    @ObservedObject var ingredient: Ingredient
    
    @State private var showingEdit = false
    @State private var hasRelatedSpecs = false
    private let generator = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        Form {
            Section(header: Text("Ingredient Information").fontWeight(.bold)) {
                // name
                Text(ingredient.name)
                    .font(.headline)
                    .fontWeight(.bold)

                // type and subtype
                HStack {
                    Text(ingredient.type.capitalized).fontWeight(.medium)
                    Spacer()
                    Text(ingredient.subtype.capitalized)
                }
            }
            
            if !ingredient.price.isEmpty && !ingredient.supplier.isEmpty {
                Section(header: Text("Purchase Information").fontWeight(.bold)) {
                    // price
                    if !ingredient.price.isEmpty {
                        HStack {
                            Image(systemName: "dollarsign.square")
                            Text(ingredient.price)
                        }
                    }
                    
                    // supplier
                    if !ingredient.supplier.isEmpty {
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                            Text(ingredient.supplier)
                        }
                    }
                }
            }
            
            // notes
            if !ingredient.notes.isEmpty && ingredient.notes != "None" {
                Section(header: Text("Notes").fontWeight(.bold)) {
                    Text(ingredient.notes)
                }
            }
            
            // list specifications with this ingredients if there are any
            Section(header: Text(hasRelatedSpecs ? "Related Specifications" : "").fontWeight(.bold)) {
                ForEach(dex.specs) { spec in
                    ForEach(spec.ingredients.indices, id: \.self) { i in
                        if spec.ingredients[i].ingredient == ingredient.name {
                            NavigationLink(destination: SpecDetailedView(spec: spec)) {
                                SpecRowView(spec: spec, sort: "bar location")
                                    .onAppear() { hasRelatedSpecs = true }
                            }
                        }
                    }
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
            EditExistingIngredientView(ingredient: ingredient, showingEdit: $showingEdit)
        }
    }
}
