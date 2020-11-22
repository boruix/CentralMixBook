//
//  SpecIngredient.swift
//  CentralMixBook
//
//

import Foundation

class SpecIngredient: Codable, ObservableObject {
    enum CodingKeys: CodingKey {
        case amount
        case name
    }
    
    @Published var amount = ""
    @Published var name = ""
    
    init() { }
    
    // allows an ObservableObject to conform to Codable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        amount = try container.decode(String.self, forKey: .amount)
        name = try container.decode(String.self, forKey: .name)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(amount, forKey: .amount)
        try container.encode(name, forKey: .name)
    }
}
