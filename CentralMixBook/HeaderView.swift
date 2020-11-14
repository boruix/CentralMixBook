//
//  HeaderView.swift
//  CentralMixBook
//
//

import SwiftUI

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
                .rotation3DEffect(.degrees(rotateAmount), axis: (x: 1, y: 0, z: 0))
        }
        // makes the whole HStack tappable, including the blank areas
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                generator.impactOccurred()
                collapseSection.toggle()
                rotateAmount = (rotateAmount + 180).truncatingRemainder(dividingBy: 360)
            }
        }
    }
}

struct HeaderView_Previews: PreviewProvider {
    @State static var collapseSection = false
    
    static var previews: some View {
        HeaderView(text: "Example", fontType: .body, imageScale: .medium, collapseSection: $collapseSection)
    }
}
