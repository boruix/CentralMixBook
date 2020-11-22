//
//  StackViews.swift
//  CentralMixBook
//
//

import SwiftUI

// MARK: collapsible section header
struct HeaderView: View {
    let text: String
    let fontType: Font
    let imageScale: Image.Scale
    @Binding var collapseSection: Bool
    
    @State private var rotateAmount = 0.0
    private let generator = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        HStack {
            Text(text)
                .font(fontType)
                .fontWeight(.bold)
            
            Spacer()
            
            Image(systemName: "chevron.up")
                .imageScale(imageScale)
                .rotation3DEffect(
                    .degrees(rotateAmount),
                    axis: (x: 1, y: 0, z: 0)
                )
        }
        // makes the whole HStack tappable, including the blank areas
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                collapseSection.toggle()
                rotateAmount = collapseSection ? 180 : 0
                generator.impactOccurred()
            }
        }
    }
}

// MARK: multi-line text input
struct MultiLineTextInput: View {
    let title: String
    @Binding var text: String
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(title)
                    .foregroundColor(.secondary)
                    .padding(.leading, 4)
            }
            
            TextEditor(text: $text)
        }
    }
}
