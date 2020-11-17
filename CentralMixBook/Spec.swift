//
//  Spec.swift
//  CentralMixBook
//
//

import Foundation

// need CaseIterable to loop over allCases for pickers
enum CocktailType: String, CaseIterable, Identifiable {
    case oldFashioned = "old-fashioned"
        // spirit driven
        // balanced by a small amount of sweetness
        // seasoned with bitters and a garnish
    case martini
        // composed of alcohol and aromatized wine; typically gin or vodka and dry vermouth
        // flexible in regard to the proportions of those ingredients, and its balance is dependent on the preference of the drinker
        // garnish has a big impact on the overall flavor and experience of the drink
    case daiquiri
        // composed of a spirit, citrus, and sweetener; typically rum, lime juice, and simple syrup
        // flexible in regard to the proportion of citrus to sweetener, which depend on the preference of the drinker and the acidity and sweetness of the citrus juice
        // requires a level of improvisation due to the inconsistency of citrus juices
    case sidecar
        // core flavor is composed of a spirit and a substantial amount of flavorful liqueur
        // both balanced and seasoned by liqueur, which also provides sweetness, sometimes in combination with another sweetener
        // balanced by highly acidic citrus juice, typically lemon or lime
    case whiskeyHighball = "whiskey highball"
        // composed of a core spirit that also provides seasoning, and is balanced by a nonalcoholic mixer
        // core can be split between any number of spirits, wines, or fortified wines
        // can be effervescent or still
    case flip
        // characteristic flavor arises from the combination of a core spirit or fortified wine and a rich ingredient
        // balanced by its rich ingredients, such as eggs, dairy, coconut milk, or dense liqueurs and syrups
        // seasoned with aromatic spices on top of the finished cocktail, a role that can also be played by a highly flavorful liqueur, such as amaro
    
    var id: String { self.rawValue }
}

// need CaseIterable to loop over allCases for pickers
enum Glassware: String, CaseIterable, Identifiable {
    case coupe                                      // 5, 5½, 6, or 9¾
    case doubleRocks = "double rocks"               // 13 or 14
    case highball                                   // 11 or 12
    case julep                                      // 13
    case nickAndNora = "Nick & Nora"                // 5 or 6
    case pilsner                                    // 12 or 16
    case punch = "punch bowl"
    case singleRocks = "single rocks"               // 9 or 9½
    
    var id: String { self.rawValue }
}

// need CaseIterable to loop over allCases for pickers
enum Ice: String, CaseIterable, Identifiable {
    case none = "None"
    case oneAndOneQuarterInchCube = "1¼-in cubes"
    case twoInchCube = "2-in cube"
    case crushed = "Crushed"
    case sphere = "Large Sphere"
    
    var id: String { self.rawValue }
}

class SpecIngredient: Codable, Equatable, ObservableObject {
    enum CodingKeys: CodingKey {
        case amount
        case ingredient
    }
    
    @Published var amount = ""
    @Published var ingredient = ""
    
    // equatable
    static func == (lhs: SpecIngredient, rhs: SpecIngredient) -> Bool {
        return lhs.ingredient == rhs.ingredient
    }
    
    init() { }
    
    // allows an ObservableObject to conform to Codable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        amount = try container.decode(String.self, forKey: .amount)
        ingredient = try container.decode(String.self, forKey: .ingredient)
    }
    
    // allows an ObservableObject to conform to Codable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(amount, forKey: .amount)
        try container.encode(ingredient, forKey: .ingredient)
    }
}

class Spec: Codable, Comparable, Equatable, Identifiable, ObservableObject {
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
    @Published var type = CocktailType.oldFashioned.rawValue
    @Published var ingredients = [SpecIngredient()]
    @Published var garnish = ""
    @Published var glassware = Glassware.coupe.rawValue
    @Published var ice = Ice.none.rawValue
    @Published var directions = [""]
    @Published var editorsNotes = ""
    @Published var favorite = false
    
    // validation: name is not empty
    var hasValidName: Bool {
        return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // validation: has at least one ingredient
    var hasIngredients: Bool {
        return !ingredients.isEmpty
    }
    
    // validation: array of SpecIngredients has ingredient field fully populated
    var hasValidIngredients: Bool {
        for i in 0 ..< ingredients.count {
            if ingredients[i].ingredient.isEmpty {
                return false
            }
        }
        
        return true
    }
    
    // validation: has at least one direction
    var hasDirections: Bool {
        return !directions.isEmpty
    }
    
    // validation: array of directions is fully populated
    var hasValidDirections: Bool {
        for i in 0 ..< directions.count {
            if directions[i].isEmpty {
                return false
            }
        }
        
        return true
    }
    
    // equatable
    static func == (lhs: Spec, rhs: Spec) -> Bool {
        return lhs.id == rhs.id
    }
    
    // comparable
    static func < (lhs: Spec, rhs: Spec) -> Bool {
        return lhs.name < rhs.name
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
    
    func trimStrings() {
        name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        barName = barName.trimmingCharacters(in: .whitespacesAndNewlines)
        barLocation = barLocation.trimmingCharacters(in: .whitespacesAndNewlines)
        garnish = garnish.trimmingCharacters(in: .whitespaces)
        editorsNotes = editorsNotes.trimmingCharacters(in: .whitespaces)
        
        for i in 0 ..< ingredients.count {
            ingredients[i].amount = ingredients[i].amount.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        for i in 0 ..< directions.count {
            directions[i] = directions[i].trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
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

class Dex: ObservableObject {
    @Published private(set) var specs: [Spec]
    
    var barNames: [String] {
        var names = [String]()
        specs.forEach { spec in
            if !names.contains(spec.barName) {
                names.append(spec.barName)
            }
        }
        return names.sorted()
    }
    
    var barNamesAndLocations: [String] {
        var namesAndLocations = [String]()
        specs.forEach { spec in
            if !namesAndLocations.contains(spec.barName + ", " + spec.barLocation) {
                namesAndLocations.append(spec.barName + ", " + spec.barLocation)
            }
        }
        return namesAndLocations.sorted()
    }
    
    static let saveKey = "CMB-Specs"
    let filename = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(saveKey)
    
    init() {
        if let data = try? Data(contentsOf: filename) {
            if let decoded = try? JSONDecoder().decode([Spec].self, from: data) {
                specs = decoded
            } else {
                specs = []
            }
        } else {
            specs = Bundle.main.decode("DefaultSpecs.json")
        }
        
        specs = specs.sorted()
    }
    
    private func save() {
        do {
            let data = try JSONEncoder().encode(self.specs.sorted())
            try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
        } catch {
            print("Unable to save data.")
        }
    }
    
    func add(_ spec: Spec) {
        specs.append(spec)
        save()
    }
    
    func delete(_ spec: Spec) {
        if let index = specs.firstIndex(of: spec) {
            specs.remove(at: index)
        }
        save()
    }
    
    func edit(from existing: Spec, to new: Spec) {
        objectWillChange.send()
        existing.copy(from: new)
        save()
    }
    
    func toggleFavorite(_ spec: Spec) {
        objectWillChange.send()
        spec.favorite.toggle()
        save()
    }
}
