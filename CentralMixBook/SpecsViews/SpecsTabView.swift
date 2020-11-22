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

    @ObservedObject var searchBar = SearchBar()
    @State private var showingAdd = false

    // specs filtered by search bar and show / hide incomplete specs button
    private var filteredSpecs: [Spec] {
        if searchBar.text.isEmpty {
            if userSettings.hideIncomplete {
                var filteredSpecs = [Spec]()
                let oosIngredients = inventory.ingredients.filter { !$0.stock }
                let oosIngredientNames = oosIngredients.map { $0.name }

                for spec in dex.specs {
                    let specIngredients = spec.ingredients.map { $0.name }
                    
                    if Set(oosIngredientNames).intersection(specIngredients).isEmpty {
                        filteredSpecs.append(spec)
                    }
                }
                return filteredSpecs
            } else {
                return dex.specs
            }
        } else {
            return dex.specs.filter { $0.name.localizedStandardContains(searchBar.text) }
        }
    }
    
    // FIXME: account for specs with no bar name / location
    var body: some View {
        NavigationView {
            Form {
                // MARK: favorites
                SpecSuperSectionView(
                    superSectionName: "Favorites",
                    subSpecs: filteredSpecs.filter { $0.favorite },
                    dexHasAny: !dex.specs.filter { $0.favorite }.isEmpty,
                    collapsed: $userSettings.collapseFavorites
                )
                
                // MARK: not-favorites
                SpecSuperSectionView(
                    superSectionName: "Specs",
                    subSpecs: filteredSpecs.filter { !$0.favorite },
                    dexHasAny: !dex.specs.filter { !$0.favorite }.isEmpty,
                    collapsed: $userSettings.collapseOthers
                )
            }
            .navigationBarTitle("Specifications")
            .add(searchBar)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    // MARK: toggle show incomplete
                    ShowHideButton(setting: $userSettings.hideIncomplete)
                }
                
                ToolbarItem(placement: .bottomBar) { Spacer() }
                
                ToolbarItem(placement: .bottomBar) {
                    // MARK: sort specs menu
                    SortByMenu(sortBy: $userSettings.specsSort,
                               options: UserSettings.SpecsSortBy.allCases.map { $0.id })
                }
                
                ToolbarItem(placement: .bottomBar) { Spacer() }
                
                ToolbarItem(placement: .bottomBar) {
                    // MARK: add spec button
                    AddButton(showingAdd: $showingAdd)
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

// MARK: SpecSuperSectionView
private struct SpecSuperSectionView: View {
    @EnvironmentObject var dex: Dex
    @EnvironmentObject var userSettings: UserSettings

    let superSectionName: String
    let subSpecs: [Spec]
    let dexHasAny: Bool
    @Binding var collapsed: Bool
    
    private var subSectionTypes: [String] {
        // sections to sort specs by
        switch userSettings.specsSort {
        case "Bar":
            return dex.barNamesAndLocations
        case "Type":
            return CocktailType.allCases.map { $0.id }
        case "Glassware":
            return Glassware.allCases.map { $0.id }
        default:
            return []
        }
    }
    
    var body: some View {
        Section(
            header: HeaderView(text: superSectionName,
                               fontType: .subheadline,
                               imageScale: .large,
                               collapseSection: $collapsed)
        ) {
            if !collapsed {
                if subSpecs.isEmpty {
                    if dexHasAny {
                        Text("No \(superSectionName.lowercased()) with all ingredients in stock")
                    } else {
                        Text("No \(superSectionName.lowercased())")
                    }
                } else {
                    ForEach(subSectionTypes, id: \.self) { subSection in
                        switch userSettings.specsSort {
                        case "Bar":
                            SpecsListView(
                                text: subSection,
                                specs: subSpecs.filter { $0.barName + ($0.barLocation.isEmpty ? "" : ", " + $0.barLocation) == subSection }
                            )
                        case "Type":
                            SpecsListView(
                                text: subSection,
                                specs: subSpecs.filter { $0.type == subSection }
                            )
                        case "Glassware":
                            SpecsListView(
                                text: subSection,
                                specs: subSpecs.filter { $0.glassware == subSection }
                            )
                        default:
                            EmptyView()
                        }
                    }
                    
                    if userSettings.specsSort == "Bar" {
                        SpecsListView(
                            text: "No bar listed",
                            specs: subSpecs.filter { $0.barName.isEmpty }
                        )
                    }
                }
            }
        }
    }
}

