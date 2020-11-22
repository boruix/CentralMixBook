//
//  SpecsListView.swift
//  CentralMixBook
//
//

import SwiftUI

struct SpecsListView: View {
    @EnvironmentObject var dex: Dex
    @EnvironmentObject var userSettings: UserSettings
    
    let text: String
    let specs: [Spec]
    
    @State private var collapseSection = false
    private let generator = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        if specs.count > 0 {
            Section(header: HeaderView(text: text,
                                       fontType: .body,
                                       imageScale: .small,
                                       collapseSection: $collapseSection)
            ) {
                ForEach(specs) { spec in
                    if !collapseSection {
                        NavigationLink(destination: SpecDetailedView(spec: spec)) {
                            HStack {
                                Button(action: {
                                    // toggles .favorite for a spec in dex
                                    withAnimation { dex.toggleFavorite(spec) }
                                    generator.impactOccurred()
                                }) {
                                    Image(systemName: spec.favorite ? "star.fill" : "star")
                                }
                                
                                SpecRowView(
                                    spec: spec,
                                    sort: userSettings.specsSort
                                )
                            }
                            // makes favorite button responsive
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                }
                .onDelete(perform: deleteSpec)
            }
        }
    }
    
    private func deleteSpec(at offsets: IndexSet) {
        offsets.forEach { offset in
            dex.delete(specs[offset])
        }
        generator.impactOccurred()
    }
}
