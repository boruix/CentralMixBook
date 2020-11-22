//
//  Enums.swift
//  CentralMixBook
//
//

import Foundation

// MARK: ingredient types
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
            return ["Brandy", "Gin", "Mezcal", "Rum", "Tequila", "Vodka", "Whiskey", "Other"]
        case .modifier:
            // fortifed wine = sherry, port, madeira
            return ["Amaro / Aperitif / Digestif", "Fortified Wine", "Liqueur", "Vermouth"]
        default:
            return []
        }
    }
    
    var id: String { rawValue.capitalized }
}


// MARK: cocktail types
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
    
    var id: String { rawValue.capitalized }
}

// MARK: glassware types
enum Glassware: String, CaseIterable, Identifiable {
    case coupe = "Coupe"                            // 5, 5½, 6, or 9¾
    case doubleRocks = "Double rocks"               // 13 or 14
    case highball = "Highball"                      // 11 or 12
    case julep = "Julep"                            // 13
    case nickAndNora = "Nick & Nora"                // 5 or 6
    case pilsner = "Pilsner"                        // 12 or 16
    case punch = "Punch bowl"
    case singleRocks = "Single rocks"               // 9 or 9½
    
    var id: String { rawValue }
}

// MARK: ice types
enum Ice: String, CaseIterable, Identifiable {
    case none = "None"
    case oneAndOneQuarterInchCube = "1¼-in cubes"
    case twoInchCube = "2-in cube"
    case crushed = "Crushed"
    case sphere = "Large sphere"
    
    var id: String { rawValue }
}
