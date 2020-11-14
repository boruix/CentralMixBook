//
//  EditExistingIngredientView.swift
//  CentralMixBook
//
//

import SwiftUI

struct EditExistingIngredientView: View {
    @EnvironmentObject var inventory: Inventory
    @EnvironmentObject var dex: Dex

    @ObservedObject var ingredient: Ingredient
    @Binding var showingEdit: Bool
    
    @StateObject private var editedIngredient = Ingredient()
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    private let impactGenerator = UIImpactFeedbackGenerator(style: .light)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    var body: some View {
        NavigationView {
            Form {
                IngredientEditorView(ingredient: editedIngredient)
                
                Button(action: {
                    // save changes to existing ingredient
                    editIngredient(from: ingredient, to: editedIngredient)
                }) {
                    Text("Save changes")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationBarTitle("Edit Ingredient")
            .navigationBarItems(leading: Button(action: {
                // dismiss current edit ingredient sheet
                showingEdit = false
                impactGenerator.impactOccurred()
            }) {
                Text("Cancel").foregroundColor(.red)
            }, trailing: Button(action: {
                // save changes to existing ingredient
                editIngredient(from: ingredient, to: editedIngredient)
            }) { Text("Save") })
            // to stop unsaved edits from propagating back to views
            .onAppear() { editedIngredient.copy(from: ingredient) }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func editIngredient(from original: Ingredient, to edited: Ingredient) {
        edited.trimStrings()

        // validation: name is empty
        guard edited.hasValidName else {
            ingredientError(title: "Ingredient name is empty", message: "Please enter a name")
            return
        }

        // validation: name is unique
        if edited.name.uppercased() != original.name.uppercased() {
            guard edited.hasUniqueName(ingredient: edited, inventory: inventory) else {
                ingredientError(title: "An existing ingredient already has this name", message: "Please enter a new name")
                return
            }
        }
        
        // validation: price is a numeric value
        guard edited.hasValidPrice else {
            ingredientError(title: "Invalid price", message: "Please enter a valid price")
            return
        }

        // if ingredient type is not base or modifier, make subtype empty
        if !["base", "modifier"].contains(edited.type) {
            edited.subtype = ""
        }
        
        // update edited ingredient name in specs
        if original.name != edited.name {
            for i in 0 ..< dex.specs.count {
                for j in 0 ..< dex.specs[i].ingredients.count {
                    if dex.specs[i].ingredients[j].ingredient == original.name {
                        dex.specs[i].ingredients[j].ingredient = edited.name
                    }
                }
            }
        }
        
        inventory.edit(from: original, to: edited)
        showingEdit = false
        impactGenerator.impactOccurred()
    }
    
    private func ingredientError(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
        notificationGenerator.notificationOccurred(.error)
    }
}

struct EditExistingIngredientView_Previews: PreviewProvider {
    @State static var showingEdit = false
    
    static var previews: some View {
        EditExistingIngredientView(ingredient: Ingredient(), showingEdit: $showingEdit)
    }
}
