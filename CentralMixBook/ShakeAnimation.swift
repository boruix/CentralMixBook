//
//  ShakeAnimation.swift
//  CentralMixBook
//
//

import SwiftUI

// will add a shake animation to a view, can provide number of shakes
struct ShakeAnimation: GeometryEffect {
    var position: CGFloat
    var animatableData: CGFloat {
        get { position }
        set { position = newValue }
    }
    
    init(shakes: Int) {
        position = CGFloat(shakes)
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        return ProjectionTransform(CGAffineTransform(translationX: -10 * sin(position * 4 * .pi), y: 0))
    }
}
