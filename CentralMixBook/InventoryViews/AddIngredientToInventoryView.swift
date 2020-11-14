//
//  AddIngredientToInventoryView.swift
//  CentralMixBook
//
//

import SwiftUI

struct AddIngredientToInventoryView: View {
    @EnvironmentObject var inventory: Inventory
    
    @ObservedObject var ingredient: Ingredient
    @Binding var showingAdd: Bool
    
    var newIngredient = Ingredient()
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    private let impactGenerator = UIImpactFeedbackGenerator(style: .light)
    private let notificationGenerator = UINotificationFeedbackGenerator()

    var body: some View {
        NavigationView {
            Form {
                IngredientEditorView(ingredient: newIngredient)
                
                Button(action: {
                    // add new ingredient to ingredients arrary in inventory
                    addIngredientToInventory(newIngredient: newIngredient)
                }) {
                    Text("Add new ingredient")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationBarTitle("Add New Ingredient")
            .navigationBarItems(leading: Button(action: {
                // dismiss current add ingredient sheet
                showingAdd = false
                impactGenerator.impactOccurred()
            }) {
                Text("Cancel").foregroundColor(.red)
            }, trailing: Button(action: {
                // add new ingredient to ingredients arrary in inventory
                addIngredientToInventory(newIngredient: newIngredient)
            }) { Text("Add") })
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        // for creating ingredient from non-existent listed ingredient on a spec
        .onAppear() { newIngredient.name = ingredient.name }
    }
    
    private func addIngredientToInventory(newIngredient: Ingredient) {
        newIngredient.trimStrings()

        // validation: name is empty
        guard newIngredient.hasValidName else {
            ingredientError(title: "Ingredient name is empty", message: "Please enter a name")
            return
        }

        // validation: name is unique
        guard newIngredient.hasUniqueName(ingredient: newIngredient, inventory: inventory) else {
            ingredientError(title: "An existing ingredient already has this name", message: "Please enter a new name")
            return
        }
        
        // validation: price is a numeric value
        guard newIngredient.hasValidPrice else {
            ingredientError(title: "Invalid price", message: "Please enter a valid price")
            return
        }
        
        // if ingredient type is not base or modifier, make subtype empty
        if !["base", "modifier"].contains(newIngredient.type) {
            newIngredient.subtype = ""
        }
        
        inventory.add(newIngredient)
        showingAdd = false
        impactGenerator.impactOccurred()
    }
    
    private func ingredientError(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
        notificationGenerator.notificationOccurred(.error)
    }
}

struct AddIngredientToInventoryView_Previews: PreviewProvider {
    @State static var showingAdd = true

    static var previews: some View {
        AddIngredientToInventoryView(ingredient: Ingredient(), showingAdd: $showingAdd)
    }
}
