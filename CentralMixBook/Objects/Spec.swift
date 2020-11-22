//
//  Spec.swift
//  CentralMixBook
//
//

import Foundation

class Spec: Codable, Identifiable, ObservableObject {
    enum CodingKeys: CodingKey {
        case name
        case barName
        case barLocation
        case type
        case ingredients
        case garnish
        case glassware
        case ice
        case directions
        case editorsNotes
        case favorite
    }
    
    var id = UUID()
    @Published var name = ""
    @Published var barName = ""
    @Published var barLocation = ""
    @Published var type = CocktailType.oldFashioned.id
    @Published var ingredients = [SpecIngredient()]
    @Published var garnish = ""
    @Published var glassware = Glassware.coupe.id
    @Published var ice = Ice.none.id
    @Published var directions = [""]
    @Published var editorsNotes = ""
    @Published var favorite = false
    
    init() { }
    
    // allows an ObservableObject to conform to Codable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        barName = try container.decode(String.self, forKey: .barName)
        barLocation = try container.decode(String.self, forKey: .barLocation)
        type = try container.decode(String.self, forKey: .type)
        ingredients = try container.decode([SpecIngredient].self, forKey: .ingredients)
        garnish = try container.decode(String.self, forKey: .garnish)
        glassware = try container.decode(String.self, forKey: .glassware)
        ice = try container.decode(String.self, forKey: .ice)
        directions = try container.decode([String].self, forKey: .directions)
        editorsNotes = try container.decode(String.self, forKey: .editorsNotes)
        favorite = try container.decode(Bool.self, forKey: .favorite)
    }
    
    // allows an ObservableObject to conform to Codable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
        try container.encode(barName, forKey: .barName)
        try container.encode(barLocation, forKey: .barLocation)
        try container.encode(type, forKey: .type)
        try container.encode(ingredients, forKey: .ingredients)
        try container.encode(garnish, forKey: .garnish)
        try container.encode(glassware, forKey: .glassware)
        try container.encode(ice, forKey: .ice)
        try container.encode(directions, forKey: .directions)
        try container.encode(editorsNotes, forKey: .editorsNotes)
        try container.encode(favorite, forKey: .favorite)
    }
}

// MARK: Comparable
extension Spec: Comparable {
    static func < (lhs: Spec, rhs: Spec) -> Bool {
        return lhs.name < rhs.name
    }
}

// MARK: Equatable
extension Spec: Equatable {
    static func == (lhs: Spec, rhs: Spec) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: validation variables
extension Spec {
    // name is not empty
    var hasValidName: Bool {
        return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // has at least one ingredient
    var hasIngredients: Bool {
        return !ingredients.isEmpty
    }
    
    // array of SpecIngredients has name field(s) fully populated
    var hasValidIngredients: Bool {
        for ingredient in ingredients {
            if ingredient.name.isEmpty { return false }
        }
        return true
    }
    
    // has at least one direction
    var hasDirections: Bool {
        return !directions.isEmpty
    }
    
    // array of direction(s) is fully populated
    var hasValidDirections: Bool {
        for direction in directions {
            if direction.isEmpty { return false }
        }
        return true
    }
}

// MARK: editing functions
extension Spec {
    func trimStrings() {
        name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        barName = barName.trimmingCharacters(in: .whitespacesAndNewlines)
        barLocation = barLocation.trimmingCharacters(in: .whitespacesAndNewlines)
        garnish = garnish.trimmingCharacters(in: .whitespacesAndNewlines)
        editorsNotes = editorsNotes.trimmingCharacters(in: .whitespaces)
        
        for ingredient in ingredients {
            ingredient.amount = ingredient.amount.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        for i in 0 ..< directions.count {
            directions[i] = directions[i].trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    func copy(from original: Spec) {
        name = original.name
        barName = original.barName
        barLocation = original.barLocation
        type = original.type
        ingredients = original.ingredients
        garnish = original.garnish
        glassware = original.glassware
        ice = original.ice
        directions = original.directions
        editorsNotes = original.editorsNotes
        favorite = original.favorite
    }
}
