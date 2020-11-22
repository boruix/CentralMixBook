//
//  AddSpecView.swift
//  CentralMixBook
//
//

import SwiftUI

struct AddSpecView: View {
    @EnvironmentObject var dex: Dex
    
    @Binding var showingAdd: Bool
    
    @StateObject private var spec = Spec()
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    private let impactGenerator = UIImpactFeedbackGenerator(style: .light)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    var body: some View {
        NavigationView {
            Form {
                SpecEditorView(spec: spec)
                
                Button(action: {
                    // add new spec
                    addNewSpec(newSpec: spec)
                }) {
                    Text("Add new specification")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationBarTitle("Add New Spec")
            .navigationBarItems(
                leading: CancelButton(showingSheet: $showingAdd),
                trailing: Button(action: {
                    // show add spec sheet
                    addNewSpec(newSpec: spec)
                }) { Text("Add").padding(.leading).padding(.vertical) }
            )
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(alertTitle),
                      message: Text(alertMessage),
                      dismissButton: .default(Text("OK")))
            }
        }
    }
        
    private func addNewSpec(newSpec: Spec) {
        newSpec.trimStrings()
        
        // validation: name is empty
        guard newSpec.hasValidName else {
            specError(
                title: "Specification name is empty",
                message: "Please enter a name"
            )
            return
        }

        // validation: has at least one ingredient
        guard newSpec.hasIngredients else {
            specError(
                title: "Specification has no ingredients",
                message: "Please enter at least one ingredient"
            )
            return
        }
        
        // validation: array of SpecIngredients is fully populated
        guard newSpec.hasValidIngredients else {
            specError(
                title: "Specification has invalid ingredients",
                message: "Please fill out or remove all incomplete ingredients"
            )
            return
        }
        
        // validation: has at least one direction
        guard newSpec.hasDirections else {
            specError(
                title: "Specification has no directions",
                message: "Please enter at least one direction"
            )
            return
        }
        
        // validation: array of directions is fully populated
        guard newSpec.hasValidDirections else {
            specError(
                title: "Specification has empty directions",
                message: "Please fill out or remove all empty directions"
            )
            return
        }
        
        dex.add(spec)
        showingAdd = false
        impactGenerator.impactOccurred()
    }
    
    private func specError(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
        notificationGenerator.notificationOccurred(.error)
    }
}

struct AddSpecView_Previews: PreviewProvider {
    @State static var showingAdd = true

    static var previews: some View {
        AddSpecView(showingAdd: $showingAdd)
    }
}
