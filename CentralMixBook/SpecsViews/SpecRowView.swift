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
                Text(sort == "type" ? spec.barName : spec.type.capitalized)
                    .fontWeight(.light)
                
                Spacer()
                
                Text(sort == "bar location" ? spec.barName : spec.barLocation)
                    .fontWeight(.light)
            }
            .padding(.trailing, 10)
            .font(.callout)
            .foregroundColor(.secondary)
        }
    }
}
