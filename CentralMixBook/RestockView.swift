//
//  RestockView.swift
//  CentralMixBook
//
//

import SwiftUI

struct RestockView: View {
    @EnvironmentObject var inventory: Inventory
    @EnvironmentObject var dex: Dex
    @EnvironmentObject var userSettings: UserSettings
    
    @State private var restockTuples = [(specs: [Spec], ingredients: [Ingredient], cost: Int)]()
    
    // restock-marked ingredients
    private var restockIngredients: [Ingredient] {
        return inventory.ingredients.filter { $0.restock }
    }

    // specs that can be made using in-stock and restock-marked ingredients
    private var currentRestockSpecs: [Spec] {
        var newSpecs = [Spec]()

        for spec in dex.specs {
            var complete = true
            var usingRestock = false
            
            for specIngredient in spec.ingredients {
                if let foundIngredient = inventory.getIngredientFromName(specIngredient.name) {
                    if !foundIngredient.stock && !restockIngredients.contains(foundIngredient) {
                        complete = false
                        break
                    } else if restockIngredients.contains(foundIngredient) {
                        usingRestock = true
                    } 
                } else {
                    complete = false
                    break
                }
            }
            if complete && usingRestock { newSpecs.append(spec) }
        }
        return newSpecs
    }
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: ingredients to restock
                Section(header: Text("Ingredients marked for restock:"),
                        footer: Text(restockIngredients.isEmpty
                                     ? "Long press on an ingredient to mark it for restock"
                                     : "Cost: \(restockIngredients.map { Int($0.price) ?? 0 }.reduce(0, +))")) {
                    if restockIngredients.isEmpty {
                        Text("None")
                    } else {
                        ForEach(restockIngredients) { ingredient in
                            InventoryRowView(ingredient: ingredient, sort: "type")
                        }
                    }
                }
                
                // MARK: possible new specs
                if !restockIngredients.isEmpty {
                    Section(header: Text(currentRestockSpecs.isEmpty ? "No new specs can be made yet" : "Can make these new specs:")) {
                        ForEach(currentRestockSpecs) { spec in
                            NavigationLink(destination: SpecDetailedView(spec: spec)) {
                                SpecRowView(spec: spec, sort: "glassware")
                            }
                        }
                    }
                }
                
                Section(footer: VStack { Divider().frame(height: 1.5).background(Color.secondary) }) { }
                
                // MARK: button: find ingredients
                // FIXME: add loading screen
                Button(action: {
                    // reset restock variables
                    restockTuples = []
                    var minCostSpecs = getMinCostSpecs(ignoring: restockIngredients)
                    
                    // loop through until all specs can be made
                    while minCostSpecs != nil {
                        restockTuples.append(minCostSpecs!)
                        minCostSpecs = getMinCostSpecs(ignoring: restockTuples.flatMap { $0.ingredients } + restockIngredients)
                    }
                }) {
                    Text("Find next ingredients")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                // MARK: next ingredients & specs
                ForEach(restockTuples.indices, id: \.self) { i in
                    Section(header: Text("Get these ingredients next:")) {
                        ForEach(restockTuples[i].ingredients) { ingredient in
                            InventoryRowView(ingredient: ingredient, sort: "type")
                        }
                    }
                    
                    Section(header: Text("To make these specs:"),
                            footer:
                                VStack {
                                    HStack {
                                        Text("Cost: \(restockTuples[i].cost)")
                                        Spacer()
                                        Text("Cumulative cost: \(restockTuples[0 ... i].map { $0.cost }.reduce(0, +))")
                                    }
                                    
                                    if i < restockTuples.count - 1 {
                                        Divider()
                                            .frame(height: 1)
                                            .background(Color.secondary)
                                            .padding(.vertical)
                                    }
                                }
                    ) {
                        ForEach(restockTuples[i].specs) { spec in
                            NavigationLink(destination: SpecDetailedView(spec: spec)) {
                                SpecRowView(spec: spec, sort: "glassware")
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Restock List")
        }
    }
    
    // gets the set of specs that requires minimum cost and maximum number of missing ingredients to complete
    func getMinCostSpecs(ignoring: [Ingredient]) -> (specs: [Spec], ingredients: [Ingredient], cost: Int)? {
        var incompleteSpecs = [(spec: Spec, numOos: Int, ingredients: [Ingredient], cost: Int)]()
        
        for spec in dex.specs {
            var numOos = 0
            var missingIngredients = [Ingredient]()
            var cost = 0
            
            for specIngredient in spec.ingredients {
                if let foundIngredient = inventory.getIngredientFromName(specIngredient.name) {
                    if !foundIngredient.stock && !ignoring.contains(foundIngredient) {
                        if !foundIngredient.price.isEmpty { numOos += 1 }
                        missingIngredients.append(foundIngredient)
                        cost += Int(foundIngredient.price) ?? 0
                    }
                }
            }
            
            if numOos > 0 {
                incompleteSpecs.append((spec, numOos, missingIngredients, cost))
            }
        }
        
        // get set of specs that requires minimum cost of missing ingredients to complete
        var sorted = incompleteSpecs.sorted { $0.cost < $1.cost }
        sorted = sorted.filter { $0.cost == sorted[0].cost }
        
        // return set of specs that requires minimum cost and maximum number of missing ingredients to complete
        sorted = sorted.sorted { $0.numOos > $1.numOos }
        sorted = sorted.filter { $0.numOos == sorted[0].numOos }
        
        // if more than one spec, find the one(s) with the most used ingredients
        if sorted.isEmpty {
            return nil
        } else if sorted.count == 1 {
            return ([sorted[0].spec], sorted[0].ingredients, sorted[0].cost)
        } else {
            let mostUsedSet = getMostUsedSet(from: sorted.map { $0.ingredients })
            sorted = sorted.filter { $0.ingredients.map { $0.name } == mostUsedSet }
            return (sorted.map { $0.spec }, sorted[0].ingredients, sorted[0].cost)
        }
    }
    
    func getMostUsedSet(from setsOfIngredients: [[Ingredient]]) -> [String] {
        // initialize dictionary of [ingredient.name : spec.name]
        var numSpecs = [[String]:Int]()
        for set in setsOfIngredients { numSpecs[set.map { $0.name }] = 0 }
        
        // increment each time a potential next ingredient is in a new spec
        for spec in dex.specs {
            for specIngredient in spec.ingredients {
                for set in setsOfIngredients {
                    let ingredientNames = set.map { $0.name }
                    
                    if ingredientNames.contains(specIngredient.name) {
                        numSpecs[ingredientNames]! += 1
                    }
                }
            }
        }
        
        // return the set of ingredient names that is used in most specs
        let sorted = numSpecs.sorted { $0.value > $1.value }
        return sorted[0].key
    }
}

struct RestockView_Previews: PreviewProvider {
    static var previews: some View {
        RestockView()
    }
}
