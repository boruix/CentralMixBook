//
//  Menus.swift
//  CentralMixBook
//
//

import SwiftUI

// MARK: sort by menu
struct SortByMenu: View {
    @Binding var sortBy: String
    let options: [String]
    
    var body: some View {
        MenuPicker(
            selection: $sortBy,
            pickerName: "Sort by",
            options: options.reversed(),
            labelView: AnyView(Image(systemName: "arrow.up.arrow.down").padding())
        )
    }
}

// MARK: menu picker
struct MenuPicker: View {
    @Binding var selection: String
    let pickerName: String
    let options: [String]
    let labelView: AnyView
    var onChangeActions: (_ newSelection: String) -> Void = { _ in return }
    
    let generator = UISelectionFeedbackGenerator()
    
    var body: some View {
        Menu {
            Picker(pickerName, selection: $selection) {
                ForEach(options, id: \.self) { option in
                    Text(option)
                }
            }
        } label: {
            labelView
        }
        .onChange(of: selection) { newSelection in
            onChangeActions(newSelection)
            generator.selectionChanged()
        }
    }
}
