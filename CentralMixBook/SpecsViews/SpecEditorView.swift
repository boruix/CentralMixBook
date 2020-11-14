//
//  SpecEditorView.swift
//  CentralMixBook
//
//  Created by Borui Xu on 11/13/20.
//

import SwiftUI

struct SpecEditorView: View {
    @ObservedObject var spec: Spec
    @State var ingredientsInvalidAttempts = [0]
    @State var directionsInvalidAttempts = [0]
    private let impactGenerator = UIImpactFeedbackGenerator(style: .light)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()

    var body: some View {
        Group {
            Section(header: Text("Drink Information").fontWeight(.bold)) {
                TextField("Name of drink", text: $spec.name)
                TextField("Bar of origin", text: $spec.barName)
                TextField("Location of bar", text: $spec.barLocation)
                
                HStack {
                    Text("Cocktail type")
                    Spacer()
                    
                    Menu {
                        Picker("Cocktail type", selection: $spec.type) {
                            ForEach(CocktailType.allCases) { type in
                                Text(type.rawValue.capitalized)
                            }
                        }
                    } label: { Text(spec.type.capitalized) }
                    .onChange(of: spec.type) { _ in
                        selectionGenerator.selectionChanged()
                    }
                }
            }
            
            Section(header: Text("Ingredients").fontWeight(.bold)) {
                // list of added ingredients
                ForEach(spec.ingredients.indices, id: \.self) { i in
                    HStack{
                        TextField("Amount", text: $spec.ingredients[i].amount)
                            .disableAutocorrection(true)
                            .frame(width: 70)
                            .keyboardType(.numbersAndPunctuation)
                            .onChange(of: spec.ingredients[i].amount) { newAmount in
                                spec.ingredients[i].amount = newAmount
                                    .replacingOccurrences(of: "1/4", with: "¼")
                                    .replacingOccurrences(of: "1/2", with: "½")
                                    .replacingOccurrences(of: "3/4", with: "¾")
                            }
                        
                        NavigationLink(destination: AddIngredientToSpecView(spec: spec, index: i)) {
                            if spec.ingredients[i].ingredient.isEmpty {
                                Text("New ingredient")
                                    .foregroundColor(.secondary)
                            } else {
                                Text(spec.ingredients[i].ingredient)
                            }
                        }
                    }
                    // need this buttonStyle to make stock button responsive
                    .buttonStyle(BorderlessButtonStyle())
                    .modifier(ShakeAnimation(shakes: ingredientsInvalidAttempts[i]))
                    .animation(Animation.linear)
                }
                .onDelete(perform: deleteIngredient)
                
                // add new ingredient button
                Button(action: {
                    // checks all ingredient name fields are non-empty first
                    var pass = true
                    for i in 0 ..< spec.ingredients.count {
                        if spec.ingredients[i].ingredient.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            ingredientsInvalidAttempts[i] += 1
                            pass = false
                        }
                    }
                    
                    if spec.ingredients.count == 0 || pass {
                        // must come first
                        ingredientsInvalidAttempts.append(0)
                        withAnimation() {
                            spec.ingredients.append(SpecIngredient())
                        }
                        impactGenerator.impactOccurred()
                    } else {
                        notificationGenerator.notificationOccurred(.error)
                    }
                }) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Add ingredient")
                    }
                }
                
                // garnish
                TextField("Garnish", text: $spec.garnish)
                
                // glassware
                HStack {
                    Text("Glass")
                    Spacer()
                    
                    Menu {
                        Picker("Glassware", selection: $spec.glassware) {
                            ForEach(Glassware.allCases) { type in
                                Text(type.rawValue.capitalized)
                            }
                        }
                    } label: { Text(spec.glassware.capitalized) }
                    .onChange(of: spec.glassware) { _ in
                        selectionGenerator.selectionChanged()
                    }
                }
                
                // ice
                HStack {
                    Text("Ice")
                    Spacer()
                                            
                    Menu {
                        Picker("Cocktail type", selection: $spec.ice) {
                            ForEach(Ice.allCases) { type in
                                Text(type.rawValue)
                            }
                        }
                    } label: { Text(spec.ice) }
                    .onChange(of: spec.ice) { _ in
                        selectionGenerator.selectionChanged()
                    }
                }
            }
            
            Section(header: Text("Directions").fontWeight(.bold)) {
                // list of added directions
                ForEach(spec.directions.indices, id: \.self) { i in
                    HStack(alignment: .top) {
                        Image(systemName: "\(i + 1).circle")
                            .padding(.top, 9)
                        
                        MultiLineTextField("New direction", text: $spec.directions[i])
                    }
                    .modifier(ShakeAnimation(shakes: directionsInvalidAttempts[i]))
                    .animation(Animation.linear)
                }
                .onDelete(perform: deleteDirection)
                
                // add new direction button
                Button(action: {
                    // checks all existing directions are non-empty first
                    var pass = true
                    for i in 0 ..< spec.directions.count {
                        if spec.directions[i].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
                            directionsInvalidAttempts[i] += 1
                            pass = false
                        }
                    }
                    
                    if spec.directions.count == 0 || pass {
                        // must come first
                        directionsInvalidAttempts.append(0)
                        withAnimation() { spec.directions.append("") }
                        impactGenerator.impactOccurred()
                    } else {
                        notificationGenerator.notificationOccurred(.error)
                    }
                }) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Add direction")
                    }
                }
            }
            
            // editor's notes
            Section(header: Text("Editor's Notes").fontWeight(.bold)) {
                TextField("None", text: $spec.editorsNotes)
            }
        }
    }
    
    private func deleteIngredient(at offsets: IndexSet) {
        offsets.forEach { offset in
            spec.ingredients.remove(at: offset)
            ingredientsInvalidAttempts.remove(at: offset)
        }
        impactGenerator.impactOccurred()
    }
    
    private func deleteDirection(at offsets: IndexSet) {
        offsets.forEach { offset in
            spec.directions.remove(at: offset)
            directionsInvalidAttempts.remove(at: offset)
        }
        impactGenerator.impactOccurred()
    }
}
