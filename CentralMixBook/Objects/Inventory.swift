//
//  Inventory.swift
//  CentralMixBook
//
//

import Foundation

class Inventory: ObservableObject {
    @Published private(set) var ingredients: [Ingredient]
    
    static let saveKey = "CMB-Inventory"
    let filename = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(saveKey)
    
    init() {
        ingredients = Bundle.main.decode("DefaultIngredients.json")
        ingredients = ingredients.sorted()
        return
        
        if let data = try? Data(contentsOf: filename) {
            if let decoded = try? JSONDecoder().decode([Ingredient].self, from: data) {
                ingredients = decoded
            } else {
                ingredients = []
            }
        } else {
            ingredients = Bundle.main.decode("DefaultIngredients.json")
        }
        ingredients = ingredients.sorted()
    }
}

// MARK: variables
extension Inventory {
    var ingredientNames: [String] {
        return ingredients.map { $0.name }
    }
    
    var suppliers: [String] {
        let sorted = Array(Set(ingredients.map { $0.supplier })).sorted()
        return sorted.filter { !$0.isEmpty }
    }
}

// MARK: functions
extension Inventory {
    private func save() {
        do {
            let data = try JSONEncoder().encode(ingredients.sorted())
            try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
        } catch {
            print("Unable to save data.")
        }
    }
    
    func add(_ ingredient: Ingredient) {
        ingredients.append(ingredient)
        ingredients = ingredients.sorted()
        save()
    }
    
    func delete(_ ingredient: Ingredient) {
        if let i = ingredients.firstIndex(of: ingredient) {
            ingredients.remove(at: i)
        }
        save()
    }
    
    func edit(from existing: Ingredient, to new: Ingredient) {
        objectWillChange.send()
        existing.copy(from: new)
        save()
    }
    
    func toggleStock(_ ingredient: Ingredient) {
        objectWillChange.send()
        ingredient.stock.toggle()
        save()
    }
    
    func toggleRestock(_ ingredient: Ingredient) {
        objectWillChange.send()
        ingredient.restock.toggle()
        save()
    }
    
    // used for retrieving the Ingredient from Spec.SpecIngredient.name
    func getIngredientFromName(_ name: String) -> Ingredient? {
        if let i = ingredients.firstIndex(where: { $0.id == name }) {
            return ingredients[i]
        } else {
            return nil
        }
    }
}
