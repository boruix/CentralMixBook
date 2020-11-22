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

    // specs that use this ingredient
    private var relatedSpecs: [Spec] {
        var relatedSpecs = [Spec]()
        
        for spec in dex.specs {
            let specIngredients = spec.ingredients.map { $0.name }
            if specIngredients.contains(ingredient.name) {
                relatedSpecs.append(spec)
            }
        }
        return relatedSpecs
    }
    
    var body: some View {
        Form {
            Section(header: Text("Ingredient Information").fontWeight(.bold)) {
                // MARK: name
                Text(ingredient.name)
                    .font(.title3)
                    .fontWeight(.bold)

                // MARK: type and subtype
                HStack {
                    Text(ingredient.type).fontWeight(.semibold)
                    Spacer()
                    Text(ingredient.subtype)
                }
            }
            
            if !ingredient.price.isEmpty || !ingredient.supplier.isEmpty {
                Section(header: Text("Purchase Information").fontWeight(.bold)) {
                    // MARK: price
                    if !ingredient.price.isEmpty {
                        Label(ingredient.price, systemImage: "dollarsign.square")
                            .foregroundColor(.primary)
                    }
                    
                    // MARK: supplier
                    if !ingredient.supplier.isEmpty {
                        Label(ingredient.supplier, systemImage: "mappin.and.ellipse")
                            .foregroundColor(.primary)
                    }
                }
            }
            
            // MARK: notes
            if !ingredient.notes.isEmpty && ingredient.notes != "None" {
                Section(header: Text("Notes").fontWeight(.bold)) {
                    Text(ingredient.notes)
                }
            }
            
            // MARK: related specifications
            if !relatedSpecs.isEmpty {
                Section(header: Text("Related Specifications").fontWeight(.bold)) {
                    ForEach(relatedSpecs) { spec in
                        NavigationLink(destination: SpecDetailedView(spec: spec)) {
                            SpecRowView(spec: spec, sort: "glassware")
                        }
                    }
                }
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(trailing: EditButton(showingSheet: $showingEdit))
        .sheet(isPresented: $showingEdit) {
            EditExistingIngredientView(
                ingredient: ingredient,
                showingEdit: $showingEdit
            )
        }
    }
}
