//
//  SpecRowView.swift
//  CentralMixBook
//
//  Created by Borui Xu on 11/12/20.
//

import SwiftUI

struct SpecRowView: View {
    @ObservedObject var spec: Spec
    let sort: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(spec.name)
            
            HStack {
                Text(sort == "bar name" ? spec.type.capitalized : spec.barName)
                    .fontWeight(.light)
                
                Spacer()
                
                Text(sort == "glassware" ? spec.type.capitalized : spec.glassware.capitalized)
                    .fontWeight(.light)
            }
            .padding(.trailing, 10)
            .font(.callout)
            .foregroundColor(.secondary)
            .contextMenu {
                Label(spec.barName, systemImage: "house")
                Label(spec.barLocation, systemImage: "mappin.and.ellipse")
                Label(spec.type.capitalized, systemImage: "tag")
                Text("Garnish: " + (spec.garnish == "" ? "None" : spec.garnish))
                Text("Glass: " + spec.glassware.capitalized)
                Label("Ice: " + spec.ice, systemImage: "cube")
            }
        }
    }
}
