//
//  IngredientEditorView.swift
//  CentralMixBook
//
//

import SwiftUI

struct IngredientEditorView: View {
    @ObservedObject var ingredient: Ingredient
    
    @State private var baseSubtype = IngredientType.base.subtypes[0]
    @State private var modifierSubtype = IngredientType.modifier.subtypes[0]
    private let generator = UISelectionFeedbackGenerator()
        
    var body: some View {
        Group {
            Section(header: Text("Ingredient Information").fontWeight(.bold)) {
                // ingredient name
                TextField("Ingredient name", text: $ingredient.name)
                    .disableAutocorrection(true)

                // ingredient type
                HStack {
                    Label("Type", systemImage: "tag").foregroundColor(.primary)
                    Spacer()
            
                    Menu {
                        Picker("Type", selection: $ingredient.type) {
                            ForEach(IngredientType.allCases) { type in
                                Text(type.rawValue.capitalized)
                            }
                        }
                    } label: { Text(ingredient.type.capitalized) }
                    .onAppear() {
                        // initialize memory of last selected subtypes
                        if ingredient.type == "base" {
                            baseSubtype = ingredient.subtype
                        } else if ingredient.type == "modifier" {
                            modifierSubtype = ingredient.subtype
                        }
                    }
                    .onChange(of: ingredient.type) { newType in
                        // changed subtype selection to last selected
                        if newType == "base" {
                            ingredient.subtype = baseSubtype
                        } else if newType == "modifier" {
                            ingredient.subtype = modifierSubtype
                        } else {
                            ingredient.subtype = ""
                        }
                        generator.selectionChanged()
                    }
                }

                // ingredient subtype
                HStack {
                    Label("Subtype", systemImage: "tag.circle")
                        .foregroundColor(["base", "modifier"].contains(ingredient.type) ? .primary : .secondary)
                    
                    Spacer()
                    
                    if ingredient.type == "base" {
                        Menu {
                            Picker("Base subtype", selection: $ingredient.subtype) {
                                ForEach(IngredientType.base.subtypes, id: \.self) { subtype in
                                    Text(subtype.capitalized)
                                }
                            }
                        } label: { Text(ingredient.subtype.capitalized) }
                        .onChange(of: ingredient.subtype) { newSubtype in
                            // memory of last selected baseSubtype
                            baseSubtype = ingredient.subtype
                            generator.selectionChanged()
                        }
                    } else if ingredient.type == "modifier" {
                        Menu {
                            Picker("Modifier subtype", selection: $ingredient.subtype) {
                                ForEach(IngredientType.modifier.subtypes, id: \.self) { subtype in
                                    Text(subtype.capitalized)
                                }
                            }
                        } label: { Text(ingredient.subtype.capitalized) }
                    } else {
                        Text("None").foregroundColor(.secondary)
                    }
                }
                
                // in-stock / out-of-stock
                Picker("Stock", selection: $ingredient.stock) {
                    Text("Out of Stock").tag(false)
                    Text("In Stock").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: ingredient.stock) { _ in
                    generator.selectionChanged()
                }
            }
            
            Section(header: Text("Purchase Information").fontWeight(.bold)) {
                // ingredient price
                HStack {
                    Image(systemName: "dollarsign.square")
                    TextField("Price", text: $ingredient.price)
                        .keyboardType(.numberPad)
                }
                
                // ingredient supplier
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                    TextField("Supplier", text: $ingredient.supplier)
                }
            }

            // ingredient notes
            Section(header: Text("Notes").fontWeight(.bold)) {
                TextEditor(text: $ingredient.notes)
                    .foregroundColor(ingredient.notes == "None" ? .secondary : .primary)
            }
        }
    }
}
