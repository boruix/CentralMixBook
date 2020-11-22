//
//  Buttons.swift
//  CentralMixBook
//
//

import SwiftUI

// MARK: add button
struct AddButton: View {
    @Binding var showingAdd: Bool
    
    let generator = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        Button(action: {
            showingAdd = true
            generator.impactOccurred()
        }) {
            Image(systemName: "plus")
        }
    }
}

// MARK: cancel button
struct CancelButton: View {
    @Binding var showingSheet: Bool
    
    let generator = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        Button(action: {
            showingSheet = false
            generator.impactOccurred()
        }) {
            Text("Cancel")
                .foregroundColor(.red)
                .padding(.trailing)
                .padding(.vertical)
        }
    }
}

// MARK: edit button
struct EditButton: View {
    @Binding var showingSheet: Bool
    
    let generator = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        Button(action: {
            showingSheet = true
            generator.impactOccurred()
        }) {
            Text("Edit")
                .padding(.leading)
                .padding(.vertical)
        }
    }
}

// MARK: restock button
struct RestockButton: View {
    @EnvironmentObject var inventory: Inventory

    @ObservedObject var ingredient: Ingredient
    
    let generator = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        Button(action: {
            withAnimation { inventory.toggleRestock(ingredient) }
        }) {
            HStack {
                Text(ingredient.restock ? "Remove from restock list" : "Add to restock list")
                Image(systemName: ingredient.restock ? "bag.badge.minus" : "bag.badge.plus")
            }
        }
    }
}

// MARK: show / hide button
struct ShowHideButton: View {
    @Binding var setting: Bool
    
    let generator = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        Button(action: {
            withAnimation { setting.toggle() }
            generator.impactOccurred()      // needs to come after
        }) {
            Image(
                systemName:
                    setting
                    ? "line.horizontal.3.decrease.circle.fill"
                    : "line.horizontal.3.decrease.circle"
            )
        }
    }
}

// MARK: stock button
struct StockButton: View {
    @EnvironmentObject var inventory: Inventory

    @ObservedObject var ingredient: Ingredient
    
    let generator = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        Button(action: {
            withAnimation { inventory.toggleStock(ingredient) }
            generator.impactOccurred()
        }) {
            Image(systemName: ingredient.stock ? "checkmark.circle.fill" : "circle")
        }
    }
}


