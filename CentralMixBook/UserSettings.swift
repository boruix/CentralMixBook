//
//  UserSettings.swift
//  CentralMixBook
//
//  Created by Borui Xu on 11/14/20.
//

import Foundation

class UserSettings: ObservableObject {
    @Published var hideOutOfStock: Bool {
        didSet {
            UserDefaults.standard.set(hideOutOfStock, forKey: "hideOutOfStock")
        }
    }
    
    @Published var collapseBases: Bool {
        didSet {
            UserDefaults.standard.set(collapseBases, forKey: "collapseBases")
        }
    }
    
    @Published var collapseModifiers: Bool {
        didSet {
            UserDefaults.standard.set(collapseModifiers, forKey: "collapseModifiers")
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
    
    @Published var sortBy: String {
        didSet { UserDefaults.standard.set(sortBy, forKey: "sortBy") }
    }
    
    enum SortBy: String, CaseIterable, Identifiable {
        case type
        case barName = "bar name"
        case barLocation = "bar location"
        
        var id: String { return rawValue }
    }
    
    init() {
        self.collapseBases = UserDefaults.standard.object(forKey: "collapseBases") as? Bool ?? false
        self.collapseModifiers = UserDefaults.standard.object(forKey: "collapseModifiers") as? Bool ?? false
        self.hideOutOfStock = UserDefaults.standard.object(forKey: "hideOutOfStock") as? Bool ?? false
        self.hideIncomplete = UserDefaults.standard.object(forKey: "hideIncomplete") as? Bool ?? false
        self.collapseFavorites = UserDefaults.standard.object(forKey: "collapseFavorites") as? Bool ?? false
        self.collapseOthers = UserDefaults.standard.object(forKey: "collapseOthers") as? Bool ?? false
        self.sortBy = UserDefaults.standard.object(forKey: "sortBy") as? String ?? "type"
    }
}
