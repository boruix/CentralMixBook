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
                // MARK: name
                TextField("Ingredient name", text: $ingredient.name)
                    .autocapitalization(UITextAutocapitalizationType.words)
                    .disableAutocorrection(true)

                // MARK: type
                HStack {
                    Label("Type", systemImage: "tag").foregroundColor(.primary)
                    
                    Spacer()
            
                    MenuPicker(
                        selection: $ingredient.type,
                        pickerName: "Type",
                        options: IngredientType.allCases.map { $0.id },
                        labelView: AnyView(Text(ingredient.type))
                    ) { newType in
                        // change subtype selection to last selected
                        switch newType {
                        case "Base":
                            ingredient.subtype = baseSubtype
                        case "Modifier":
                            ingredient.subtype = modifierSubtype
                        default:
                            ingredient.subtype = ""
                        }
                    }
                    .onAppear() {
                        // initialize memory of last selected subtype
                        if ingredient.type == "Base" {
                            baseSubtype = ingredient.subtype
                        } else if ingredient.type == "Modifier" {
                            modifierSubtype = ingredient.subtype
                        }
                    }
                }

                // MARK: subtype
                HStack {
                    Label("Subtype", systemImage: "tag.circle")
                        .foregroundColor(["Base", "Modifier"].contains(ingredient.type) ? .primary : .secondary)
                    
                    Spacer()
                    
                    switch ingredient.type {
                    case "Base":
                        MenuPicker(
                            selection: $ingredient.subtype,
                            pickerName: "Base subtype",
                            options: IngredientType.base.subtypes,
                            labelView: AnyView(Text(ingredient.subtype))
                        ) { newSubtype in
                            // memory of last selected baseSubtype
                            baseSubtype = newSubtype
                        }
                    case "Modifier":
                        MenuPicker(
                            selection: $ingredient.subtype,
                            pickerName: "Modifier subtype",
                            options: IngredientType.modifier.subtypes,
                            labelView: AnyView(Text(ingredient.subtype))
                        ) { newSubtype in
                            // memory of last selected modifierSubtype
                            modifierSubtype = newSubtype
                        }
                    default:
                        Text("None").foregroundColor(.secondary)
                    }
                }
                
                // MARK: in-stock / out-of-stock
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
                // MARK: price
                HStack {
                    Image(systemName: "dollarsign.square")
                    TextField("Price", text: $ingredient.price)
                        .keyboardType(.numberPad)
                }
                
                // MARK: supplier
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                    TextField("Supplier", text: $ingredient.supplier)
                        .autocapitalization(UITextAutocapitalizationType.words)
                }
            }

            // MARK: notes
            Section(header: Text("Notes").fontWeight(.bold)) {
                MultiLineTextInput(title: "None", text: $ingredient.notes)
            }
        }
    }
}
