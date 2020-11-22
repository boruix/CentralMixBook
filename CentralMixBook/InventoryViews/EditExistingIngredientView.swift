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
            .navigationBarItems(
                leading: CancelButton(showingSheet: $showingEdit),
                trailing: Button(action: {
                    // save changes to existing ingredient
                    editIngredient(from: ingredient, to: editedIngredient)
                }) { Text("Save").padding(.leading).padding(.vertical) }
            )
            // to stop unsaved edits from propagating back to views
            .onAppear() { editedIngredient.copy(from: ingredient) }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(alertTitle),
                      message: Text(alertMessage),
                      dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func editIngredient(from original: Ingredient, to edited: Ingredient) {
        edited.trimStrings()

        // validation: name is empty
        guard edited.hasValidName else {
            ingredientError(
                title: "Ingredient name is empty",
                message: "Please enter a name"
            )
            return
        }

        // validation: name is unique
        if edited.name.uppercased() != original.name.uppercased() {
            guard edited.hasUniqueName(in: inventory) else {
                ingredientError(
                    title: "An existing ingredient already has this name",
                    message: "Please enter a new name"
                )
                return
            }
        }
        
        // validation: price is empty or an integer
        guard edited.hasValidPrice else {
            ingredientError(
                title: "Invalid price",
                message: "Please enter a valid integer price"
            )
            return
        }

        // if ingredient type is not base or modifier, make subtype empty
        if !["Base", "Modifier"].contains(edited.type) {
            edited.subtype = ""
        }
        
        // update edited ingredient name in specs
        if original.name != edited.name {
            for spec in dex.specs {
                for specIngredient in spec.ingredients {
                    if specIngredient.name == original.name {
                        specIngredient.name = edited.name
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
        EditExistingIngredientView(
            ingredient: Ingredient(),
            showingEdit: $showingEdit
        )
    }
}
