//
//  Dex.swift
//  CentralMixBook
//
//

import Foundation

// MARK: class Dex: ObservableObject
class Dex: ObservableObject {
    @Published private(set) var specs: [Spec]
    
    static let saveKey = "CMB-Specs"
    let filename = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(saveKey)
    
    init() {
        specs = Bundle.main.decode("DefaultSpecs.json")
        specs = specs.sorted()
        return
        
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
}

// MARK: variables
extension Dex {
    var barNamesAndLocations: [String] {
        let hasBarName = specs.filter { !$0.barName.isEmpty }
        let barDescriptions = hasBarName.map {$0.barName + ($0.barLocation.isEmpty ? "" : ", " + $0.barLocation) }
        return Array(Set(barDescriptions)).sorted()
    }
}

// MARK: functions
extension Dex {
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
        specs = specs.sorted()
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
