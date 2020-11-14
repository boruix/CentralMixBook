//
//  AddIngredientToSpecView.swift
//  CentralMixBook
//
//

import SwiftUI

struct AddIngredientToSpecView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var inventory: Inventory
    
    @ObservedObject var spec: Spec
    var index: Int
    
    @State private var searchInput = ""
    @State private var predictedIngredients = [String]()
    @State private var showingAddIngredientToInventory = false
    private let generator = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        Form {
            HStack {
                Image(systemName: "magnifyingglass")
                
                AutocompleteTextField(title: "Search for ingredient", input: $searchInput, predictableValues: inventory.ingredientNames, predictedValues: $predictedIngredients)
            }
            
            // list of autocomplete ingredients
            ForEach(predictedIngredients.indices, id: \.self) { i in
                Button(action: {
                    // call the publisher for nested value changes to propagate
                    spec.objectWillChange.send()
                    
                    // add ingredient name to spec's list of ingredients
                    spec.ingredients[index].ingredient = predictedIngredients[i]
                    generator.impactOccurred()
                    presentationMode.wrappedValue.dismiss()
                }) { Text(predictedIngredients[i]) }
            }
            
            // can create new ingredient if does not exist
            if !searchInput.isEmpty {
                Button(action: {
                    showingAddIngredientToInventory = true
                    generator.impactOccurred()
                }) { Text("Create new ingredient").fontWeight(.semibold) }
            }
        }
        .navigationBarTitle("Ingredient Search")
        .sheet(isPresented: $showingAddIngredientToInventory) {
            AddIngredientToInventoryView(ingredient: Ingredient(), showingAdd: $showingAddIngredientToInventory)
        }
    }
}

// TextField capable of making predictions based on provided predictable values
struct AutocompleteTextField: View {

    // titleKey in TextField when no input
    var title: String
    
    // current input in TextField
    @Binding var input: String
    
    // all possible predictable values
    var predictableValues: Array<String>

    // values that are being predicted based on the predictable values
    @Binding var predictedValues: Array<String>

    @State private var isBeingEdited: Bool = false

    init(title: String, input: Binding<String>, predictableValues: [String], predictedValues: Binding<Array<String>>) {
        self.title = title
        self._input = input
        self.predictableValues = predictableValues
        self._predictedValues = predictedValues
    }

    var body: some View {
        TextField(title, text: self.$input, onEditingChanged: { editing in realTimePrediction(status: editing) }, onCommit: { makePrediction() })
    }

    // schedules prediction when an input is being made
    private func realTimePrediction(status: Bool) {
        isBeingEdited = status
        
        if status {
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
                makePrediction()
                if !isBeingEdited { timer.invalidate() }
            }
        }
    }

    // makes prediciton based on current input
    private func makePrediction() {
        predictedValues = []
        
        if !input.isEmpty {
            predictableValues.forEach { value in
                if value.uppercased().hasPrefix(input.uppercased()) {
                    if !predictedValues.contains(String(value)) {
                        predictedValues.append(String(value))
                    }
                }
                
                if predictedValues.count == 10 { return }
            }
        }
    }
}
