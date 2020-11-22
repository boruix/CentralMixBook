//
//  SpecEditorView.swift
//  CentralMixBook
//
//  Created by Borui Xu on 11/13/20.
//

import SwiftUI

struct SpecEditorView: View {
    @EnvironmentObject var inventory: Inventory

    @ObservedObject var spec: Spec
    @State var ingredientsInvalidAttempts = [0]
    @State var directionsInvalidAttempts = [0]
    
    private let impactGenerator = UIImpactFeedbackGenerator(style: .light)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()

    var body: some View {
        Group {
            // MARK: name, bar, location, type
            Section(header: Text("Drink Information").fontWeight(.bold)) {
                TextField("Name of drink", text: $spec.name)
                    .autocapitalization(UITextAutocapitalizationType.words)
                
                HStack {
                    Image(systemName: "house").frame(width: 30)
                    TextField("Bar of origin", text: $spec.barName)
                        .autocapitalization(UITextAutocapitalizationType.words)
                }
                
                HStack {
                    Image(systemName: "mappin.and.ellipse").frame(width: 30)
                    TextField("Location of bar", text: $spec.barLocation)
                        .autocapitalization(UITextAutocapitalizationType.words)
                }
                
                HStack {
                    Image(systemName: "tag").frame(width: 30)
                    Text("Cocktail type")
                    Spacer()
                    
                    MenuPicker(
                        selection: $spec.type,
                        pickerName: "Cocktail type",
                        options: CocktailType.allCases.map { $0.id },
                        labelView: AnyView(Text(spec.type))
                    )
                }
            }
            
            // MARK: ingredients list
            Section(header: Text("Ingredients").fontWeight(.bold)) {
                ForEach(spec.ingredients.indices, id: \.self) { i in
                    HStack{
                        TextField("Amount", text: $spec.ingredients[i].amount)
                            .disableAutocorrection(true)
                            .frame(width: 70)
                            .keyboardType(.numbersAndPunctuation)
                            .onChange(of: spec.ingredients[i].amount) { amount in
                                spec.ingredients[i].amount = replaceFractions(amount)
                            }
                        
                        NavigationLink(
                            destination:
                                AddIngredientToSpecView(inventory: inventory,
                                                        spec: spec,
                                                        index: i)
                        ) {
                            if spec.ingredients[i].name.isEmpty {
                                Text("New ingredient")
                                    .foregroundColor(.secondary)
                            } else {
                                Text(spec.ingredients[i].name)
                            }
                        }
                    }
                    // need this buttonStyle to make stock button responsive
                    .buttonStyle(BorderlessButtonStyle())
                    .modifier(ShakeAnimation(shakes: ingredientsInvalidAttempts[i]))
                    .animation(Animation.linear)
                }
                .onDelete(perform: deleteIngredient)
                
                // MARK: add ingredient button
                Button(action: {
                    // checks all ingredient name fields are non-empty first
                    var pass = true
                    for i in 0 ..< spec.ingredients.count {
                        if spec.ingredients[i].name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            ingredientsInvalidAttempts[i] += 1
                            pass = false
                        }
                    }
                    
                    if spec.ingredients.count == 0 || pass {
                        ingredientsInvalidAttempts.append(0)    // must come first
                        withAnimation {
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
                
                // MARK: garnish
                TextField("Garnish", text: $spec.garnish)
                    .onChange(of: spec.garnish) { garnish in
                        spec.garnish = replaceFractions(garnish)
                    }
                
                // MARK: glassware
                HStack {
                    Text("Glass")
                    Spacer()
                    
                    MenuPicker(
                        selection: $spec.glassware,
                        pickerName: "Glassware",
                        options: Glassware.allCases.map { $0.id },
                        labelView: AnyView(Text(spec.glassware))
                    )
                }
                
                // MARK: ice
                HStack {
                    Text("Ice")
                    Spacer()
                    
                    MenuPicker(
                        selection: $spec.ice,
                        pickerName: "Ice",
                        options: Ice.allCases.map { $0.id },
                        labelView: AnyView(Text(spec.ice))
                    )
                }
            }
            
            // MARK: directions list
            Section(header: Text("Directions").fontWeight(.bold)) {
                ForEach(spec.directions.indices, id: \.self) { i in
                    HStack(alignment: .top) {
                        Image(systemName: "\(i + 1).circle").padding(.top, 9)
                        
                        MultiLineTextInput(
                            title: "New direction",
                            text: $spec.directions[i]
                        )
                        .onChange(of: spec.directions[i]) { direction in
                            spec.directions[i] = replaceFractions(direction)
                        }
                    }
                    .modifier(ShakeAnimation(shakes: directionsInvalidAttempts[i]))
                    .animation(Animation.linear)
                }
                .onDelete(perform: deleteDirection)
                
                // MARK: add direction button
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
                        directionsInvalidAttempts.append(0) // must come first
                        withAnimation { spec.directions.append("") }
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
            
            // MARK: editor's notes
            Section(header: Text("Editor's Notes").fontWeight(.bold)) {
                TextField("None", text: $spec.editorsNotes)
            }
        }
    }
    
    private func replaceFractions(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "1/2", with: "½")
            .replacingOccurrences(of: "1/3", with: "⅓")
            .replacingOccurrences(of: "2/3", with: "⅔")
            .replacingOccurrences(of: "1/4", with: "¼")
            .replacingOccurrences(of: "3/4", with: "¾")
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
