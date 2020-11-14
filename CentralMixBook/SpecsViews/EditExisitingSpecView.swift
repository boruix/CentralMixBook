//
//  EditExistingSpecView.swift
//  CentralMixBook
//
//  Created by Borui Xu on 11/13/20.
//

import SwiftUI

struct EditExistingSpecView: View {
    //@EnvironmentObject var inventory: Inventory
    @EnvironmentObject var dex: Dex
    
    @ObservedObject var spec: Spec
    @Binding var showingEdit: Bool
    
    @StateObject private var editedSpec = Spec()
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    private let impactGenerator = UIImpactFeedbackGenerator(style: .light)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    var body: some View {
        NavigationView {
            Form {
                // invalidAttempts arrays need spec to initalize correct length
                SpecEditorView(spec: editedSpec, ingredientsInvalidAttempts: [Int](repeating: 0, count: spec.ingredients.count), directionsInvalidAttempts: [Int](repeating: 0, count: spec.directions.count))
                
                Button(action: {
                    // save changes to existing specification
                    editSpec(from: spec, to: editedSpec)
                }) {
                    Text("Save changes")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationBarTitle("Edit Specification")
            .navigationBarItems(leading: Button(action: {
                // dismiss current add specification sheet
                showingEdit = false
                impactGenerator.impactOccurred()
            }) {
                Text("Cancel").foregroundColor(.red)
            }, trailing: Button(action: {
                // save changes to existing specification
                editSpec(from: spec, to: editedSpec)
            }) { Text("Save") })
            // to stop unsaved edits from propagating back to views
            .onAppear() {editedSpec.copy(from: spec) }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func editSpec(from original: Spec, to edited: Spec) {
        edited.trimStrings()

        // validation: name is empty
        guard edited.hasValidName else {
            specError(title: "Specification name is empty", message: "Please enter a name")
            return
        }

        // validation: has at least one ingredient
        guard edited.hasIngredients else {
            specError(title: "Specification has no ingredients", message: "Please enter at least one ingredient")
            return
        }
        
        // validation: array of SpecIngredients is fully populated
        guard edited.hasValidIngredients else {
            specError(title: "Specification has invalid ingredients", message: "Please fill out or remove all incomplete ingredients")
            return
        }
        
        // validation: has at least one direction
        guard edited.hasDirections else {
            specError(title: "Specification has no directions", message: "Please enter at least one direction")
            return
        }
        
        // validation: array of directions is fully populated
        guard edited.hasValidDirections else {
            specError(title: "Specification has empty directions", message: "Please fill out or remove all empty directions")
            return
        }
        
        dex.edit(from: original, to: edited)
        showingEdit = false
        impactGenerator.impactOccurred()
    }
    
    private func specError(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
        notificationGenerator.notificationOccurred(.error)
    }
}

struct EditExistingSpecView_Previews: PreviewProvider {
    @State static var showingEdit = true
    
    static var previews: some View {
        EditExistingSpecView(spec: Spec(), showingEdit: $showingEdit)
    }
}
