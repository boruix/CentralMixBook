//
//  Ingredient.swift
//  CentralMixBook
//
//

import Combine
import Foundation

class Ingredient: Codable, ObservableObject {
    enum CodingKeys: CodingKey {
        case name
        case type
        case subtype
        case stock
        case price
        case supplier
        case notes
        case restock
    }

    @Published var name = ""
    @Published var type = IngredientType.base.id
    @Published var subtype = IngredientType.base.subtypes[0]
    @Published var stock = false
    @Published var price = ""
    @Published var supplier = ""
    @Published var notes = ""
    @Published var restock = false
    
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
        restock = try container.decode(Bool.self, forKey: .restock)
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
        try container.encode(restock, forKey: .restock)
    }
}

// MARK: Comparable
extension Ingredient: Comparable {
    static func < (lhs: Ingredient, rhs: Ingredient) -> Bool {
        return lhs.name < rhs.name
    }
}

// MARK: Equatable
extension Ingredient: Equatable {
    static func == (lhs: Ingredient, rhs: Ingredient) -> Bool {
        return lhs.name == rhs.name
    }
}

// MARK: Identifiable
extension Ingredient: Identifiable {
    // need Identifiable to be able to loop over [Ingredient]
    var id: String { name }
}

// MARK: validations
extension Ingredient {
    // name is not empty
    var hasValidName: Bool {
        return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // name is unique
    func hasUniqueName(in inventory: Inventory) -> Bool {
        for existingIngredient in inventory.ingredients {
            if existingIngredient.name.uppercased() == name.uppercased() {
                return false
            }
        }
        return true
    }
    
    // price is empty or an integer
    var hasValidPrice: Bool {
        return price.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || (Int(price) != nil)
    }
}

// MARK: editing functions
extension Ingredient {
    func copy(from original: Ingredient) {
        name = original.name
        type = original.type
        subtype = original.subtype
        stock = original.stock
        price = original.price
        supplier = original.supplier
        notes = original.notes
        restock = original.restock
    }
    
    func trimStrings() {
        name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        price = price.trimmingCharacters(in: .whitespacesAndNewlines)
        supplier = supplier.trimmingCharacters(in: .whitespacesAndNewlines)
        notes = notes.trimmingCharacters(in: .whitespaces)
    }
}
