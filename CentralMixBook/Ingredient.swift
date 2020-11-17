//
//  Ingredient.swift
//  CentralMixBook
//
//

import Combine
import Foundation

// need CaseIterable to loop over allCases for pickers
enum IngredientType: String, CaseIterable, Identifiable {
    case base
    case modifier
    case bitters
    case sweetener
    case juice
    case topper
    case other
    
    var subtypes: [String] {
        switch self {
        case .base:
            return ["brandy", "gin", "mezcal", "rum", "tequila", "vodka", "whiskey", "other"]
        case .modifier:
            // fortifed wine = sherry, port, madeira
            return ["amaro / aperitif / digestif", "fortified wine", "liqueur", "vermouth"]
        default:
            return []
        }
    }
    
    var id: String { rawValue }
}

// need Identifiable to loop over ingredients in InventoryTypeView
class Ingredient: Codable, Comparable, Equatable, Identifiable, ObservableObject {
    enum CodingKeys: CodingKey {
        case name
        case type
        case subtype
        case stock
        case price
        case supplier
        case notes
    }

    @Published var name = ""
    @Published var type = IngredientType.base.rawValue
    @Published var subtype = IngredientType.base.subtypes[0]
    @Published var stock = false
    @Published var price = ""
    @Published var supplier = ""
    @Published var notes = "None"
    var id: String { name }
    
    // validation: name is not empty
    var hasValidName: Bool {
        return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // validation: name is unique
    func hasUniqueName(ingredient: Ingredient, inventory: Inventory) -> Bool {
        for existingIngredient in inventory.ingredients {
            if existingIngredient.name.uppercased() == ingredient.name.uppercased() {
                return false
            }
        }
        
        return true
    }
    
    // validation: price is a numeric value
    var hasValidPrice: Bool {
        return price.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || (Int(price) != nil)
    }
    
    // equatable
    static func == (lhs: Ingredient, rhs: Ingredient) -> Bool {
        return lhs.name == rhs.name
    }
    
    // comparable
    static func < (lhs: Ingredient, rhs: Ingredient) -> Bool {
        return lhs.name < rhs.name
    }

    func copy(from original: Ingredient) {
        name = original.name
        type = original.type
        subtype = original.subtype
        stock = original.stock
        price = original.price
        supplier = original.supplier
        notes = original.notes
    }
    
    func trimStrings() {
        name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        price = price.trimmingCharacters(in: .whitespacesAndNewlines)
        supplier = supplier.trimmingCharacters(in: .whitespacesAndNewlines)
        notes = notes.trimmingCharacters(in: .whitespaces)
    }
    
    init() { }
    
    // allows an ObservableObject to conform to Codable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        type = try container.decode(String.self, forKey: .type)
        subtype = try container.decode(String.self, forKey: .subtype)
        stock = try container.decode(Bool.self, forKey: .stock)
        price = try container.decode(String.self, forKey: .price)
        supplier = try container.decode(String.self, forKey: .supplier)
        notes = try container.decode(String.self, forKey: .notes)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
        try container.encode(subtype, forKey: .subtype)
        try container.encode(stock, forKey: .stock)
        try container.encode(price, forKey: .price)
        try container.encode(supplier, forKey: .supplier)
        try container.encode(notes, forKey: .notes)
    }
}

class Inventory: ObservableObject {
    @Published private(set) var ingredients: [Ingredient]
    
    var ingredientNames: [String] {
        var names = [String]()
        ingredients.forEach { ingredient in
            names.append(ingredient.name)
        }
        return names
    }
    
    static let saveKey = "CMB-Inventory"
    let filename = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(saveKey)
    
    init() {
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
    
    func toggleStock(_ ingredientName: String) {
        if let i = ingredients.firstIndex(where: { $0.name == ingredientName }) {
            objectWillChange.send()
            ingredients[i].stock.toggle()
            save()
        }
    }
    
    // used for finding ingredient.stock to determine incomplete specs
    func getIngredient(_ ingredientName: String) -> Ingredient? {
        if let i = ingredients.firstIndex(where: { $0.name == ingredientName }) {
            return ingredients[i]
        } else {
            return nil
        }
    }
}
