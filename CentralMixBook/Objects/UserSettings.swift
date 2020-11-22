//
//  UserSettings.swift
//  CentralMixBook
//
//

import Foundation

class UserSettings: ObservableObject {
    @Published var hideOutOfStock: Bool {
        didSet {
            UserDefaults.standard.set(hideOutOfStock, forKey: "hideOutOfStock")
        }
    }
    
    @Published var hideIncomplete: Bool {
        didSet {
            UserDefaults.standard.set(hideIncomplete, forKey: "hideIncomplete")
        }
    }
    
    @Published var collapseFavorites: Bool {
        didSet {
            UserDefaults.standard.set(collapseFavorites, forKey: "collapseFavorites")
        }
    }
    
    @Published var collapseOthers: Bool {
        didSet {
            UserDefaults.standard.set(collapseOthers, forKey: "collapseOthers")
        }
    }
    
    @Published var specsSort: String {
        didSet {
            UserDefaults.standard.set(specsSort, forKey: "specsSort")
        }
    }
    
    @Published var inventorySort: String {
        didSet {
            UserDefaults.standard.set(inventorySort, forKey: "inventorySort")
        }
    }
    
    enum SpecsSortBy: String, CaseIterable, Identifiable {
        case bar
        case glassware
        case type
        
        var id: String { return rawValue.capitalized }
    }
    
    enum InventorySortBy: String, CaseIterable, Identifiable {
        case price
        case supplier
        case type
        
        var id: String { return rawValue.capitalized }
    }
    
    init() {
        self.hideOutOfStock = UserDefaults.standard.object(forKey: "hideOutOfStock") as? Bool ?? false
        self.hideIncomplete = UserDefaults.standard.object(forKey: "hideIncomplete") as? Bool ?? false
        
        self.collapseFavorites = UserDefaults.standard.object(forKey: "collapseFavorites") as? Bool ?? false
        self.collapseOthers = UserDefaults.standard.object(forKey: "collapseOthers") as? Bool ?? false
        
        self.specsSort = UserDefaults.standard.object(forKey: "specsSort") as? String ?? "Type"
        self.inventorySort = UserDefaults.standard.object(forKey: "inventorySort") as? String ?? "Type"
    }
}
