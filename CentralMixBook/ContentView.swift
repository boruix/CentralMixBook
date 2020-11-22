//
//  ContentView.swift
//  CentralMixBook
//
//

import SwiftUI

struct ContentView: View {
    var inventory = Inventory()
    var dex = Dex()
    var userSettings = UserSettings()

    var body: some View {
        TabView {
            SpecsTabView()
                .tabItem {
                    Image(systemName: "book")
                    Text("Specs")
                }
            
            InventoryTabView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Inventory")
                }
            
            RestockView()
                .tabItem {
                    Image(systemName: "bag")
                    Text("Restock")
                }
        }
        .environmentObject(inventory)
        .environmentObject(dex)
        .environmentObject(userSettings)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
