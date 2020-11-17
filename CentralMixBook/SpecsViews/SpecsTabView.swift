//
//  SpecsTabView.swift
//  CentralMixBook
//
//

import SwiftUI

struct SpecsTabView: View {
    @EnvironmentObject var inventory: Inventory
    @EnvironmentObject var dex: Dex
    @EnvironmentObject var userSettings: UserSettings

    @State private var showingAdd = false
    private let impactGenerator = UIImpactFeedbackGenerator(style: .light)
    private let selectionGenerator = UISelectionFeedbackGenerator()

    private var sortOptions: [String] {
        switch userSettings.sortBy {
        case "bar name":
            return dex.barNamesAndLocations
        case "type":
            return CocktailType.allCases.map { $0.rawValue }
        case "glassware":
            return Glassware.allCases.map { $0.rawValue }
        default:
            return []
        }
    }
    
    private var filteredSpecs: [Spec] {
        var filteredSpecs = [Spec]()
        
        if userSettings.hideIncomplete {
            dex.specs.forEach { spec in
                var complete = true
                
                for specIngredient in spec.ingredients {
                    if let foundIngredient = inventory.getIngredient(specIngredient.ingredient) {
                        if !foundIngredient.stock {
                            complete = false
                            break
                        }
                    } else {
                        complete = false
                        break
                    }
                }
                if complete { filteredSpecs.append(spec) }
            }
            return filteredSpecs
        } else {
            return dex.specs
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: HeaderView(text: "Favorites", fontType: .subheadline, imageScale: .large, collapseSection: $userSettings.collapseFavorites)) {
                    if !userSettings.collapseFavorites {
                        if dex.specs.filter { $0.favorite }.count == 0 {
                            Text("No favorites")
                        } else if filteredSpecs.filter { $0.favorite }.count == 0 {
                            Text("No favorites with all ingredients in stock")
                        } else {
                            ForEach(sortOptions, id: \.self) { sort in
                                switch userSettings.sortBy {
                                case "bar name":
                                    SpecsListView(text: sort, specs: filteredSpecs.filter { $0.favorite && $0.barName + ", " + $0.barLocation == sort }, sortBy: userSettings.sortBy)
                                case "type":
                                    SpecsListView(text: sort.capitalized, specs: filteredSpecs.filter { $0.favorite && $0.type == sort }, sortBy: userSettings.sortBy)
                                case "glassware":
                                    SpecsListView(text: sort.capitalized, specs: filteredSpecs.filter { $0.favorite && $0.glassware == sort }, sortBy: userSettings.sortBy)
                                default:
                                    EmptyView()
                                }
                            }
                        }
                    }
                }
                
                Section(header: HeaderView(text: "All Other Specifications", fontType: .subheadline, imageScale: .large, collapseSection: $userSettings.collapseOthers)) {
                    if !userSettings.collapseOthers {
                        if dex.specs.filter { !$0.favorite }.count == 0 {
                            Text("No specifications")
                        } else if filteredSpecs.filter { !$0.favorite }.count == 0 {
                            Text("No specs with all ingredients in stock")
                        } else {
                            ForEach(sortOptions, id: \.self) { sort in
                                switch userSettings.sortBy {
                                case "bar name":
                                    SpecsListView(text: sort, specs: filteredSpecs.filter { !$0.favorite && $0.barName + ", " + $0.barLocation == sort }, sortBy: userSettings.sortBy)
                                case "type":
                                    SpecsListView(text: sort.capitalized, specs: filteredSpecs.filter { !$0.favorite && $0.type == sort }, sortBy: userSettings.sortBy)
                                case "glassware":
                                    SpecsListView(text: sort.capitalized, specs: filteredSpecs.filter { !$0.favorite && $0.glassware == sort }, sortBy: userSettings.sortBy)
                                default:
                                    EmptyView()
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Specifications")
            .toolbar {
                // show or hide specifications with missing ingredients
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {
                        withAnimation { userSettings.hideIncomplete.toggle() }
                        impactGenerator.impactOccurred()
                    }) {
                        Image(systemName: userSettings.hideIncomplete ? "line.horizontal.3.decrease.circle.fill" : "line.horizontal.3.decrease.circle")
                    }
                }
                
                ToolbarItem(placement: .bottomBar) { Spacer() }
                
                // sort specifications
                ToolbarItem(placement: .bottomBar) {
                    Menu {
                        Picker("Sort by", selection: $userSettings.sortBy) {
                            ForEach(UserSettings.SortBy.allCases.reversed()) { option in
                                Text(option.rawValue.capitalized)
                            }
                        }
                    } label: {
                        // this one in particular needs padding for tapability
                        Image(systemName: "arrow.up.arrow.down").padding()
                    }
                    .onChange(of: userSettings.sortBy) { _ in
                        selectionGenerator.selectionChanged()
                    }
                }
                
                ToolbarItem(placement: .bottomBar) { Spacer() }
                
                // add a new specification
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {
                        showingAdd = true
                        impactGenerator.impactOccurred()
                    }) { Image(systemName: "plus") }
                }
            }
            // prevents toolbar from disappearing when navigating
            .onAppear() { dex.objectWillChange.send() }
            .sheet(isPresented: $showingAdd) {
                AddSpecView(showingAdd: $showingAdd)
            }
        }
    }
}
